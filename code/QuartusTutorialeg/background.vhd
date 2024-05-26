LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.game_type_pkg.ALL;

ENTITY background IS
    PORT
    (
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        pb1, clk, vert_sync: IN std_logic;
        input_state: IN std_logic_vector(3 DOWNTO 0);
        output_on                  : OUT std_logic;
        RGB                        : OUT std_logic_vector(11 DOWNTO 0)
    );        
END background;

ARCHITECTURE behavior OF background IS
    CONSTANT screen_width : INTEGER := 640;
    CONSTANT screen_height : INTEGER := 480;

    CONSTANT star_count : INTEGER := 20;
    TYPE star_array IS ARRAY (0 TO star_count-1) OF std_logic_vector(9 DOWNTO 0);
    SIGNAL star_y_positions : star_array := (
        std_logic_vector(to_unsigned(50, 10)),  
        std_logic_vector(to_unsigned(150, 10)), 
        std_logic_vector(to_unsigned(250, 10)), 
        std_logic_vector(to_unsigned(350, 10)), 
        std_logic_vector(to_unsigned(100, 10)), 
        std_logic_vector(to_unsigned(200, 10)), 
        std_logic_vector(to_unsigned(300, 10)), 
        std_logic_vector(to_unsigned(400, 10)), 
        std_logic_vector(to_unsigned(75, 10)),  
        std_logic_vector(to_unsigned(175, 10)), 
        std_logic_vector(to_unsigned(275, 10)), 
        std_logic_vector(to_unsigned(375, 10)), 
        std_logic_vector(to_unsigned(125, 10)), 
        std_logic_vector(to_unsigned(225, 10)), 
        std_logic_vector(to_unsigned(325, 10)), 
        std_logic_vector(to_unsigned(425, 10)), 
        std_logic_vector(to_unsigned(475, 10)), 
        std_logic_vector(to_unsigned(425, 10)), 
        std_logic_vector(to_unsigned(225, 10)), 
        std_logic_vector(to_unsigned(325, 10))
    );

    SIGNAL star_x_positions : star_array := (
        std_logic_vector(to_unsigned(100, 10)), 
        std_logic_vector(to_unsigned(200, 10)), 
        std_logic_vector(to_unsigned(300, 10)), 
        std_logic_vector(to_unsigned(400, 10)), 
        std_logic_vector(to_unsigned(500, 10)), 
        std_logic_vector(to_unsigned(600, 10)), 
        std_logic_vector(to_unsigned(150, 10)), 
        std_logic_vector(to_unsigned(250, 10)), 
        std_logic_vector(to_unsigned(350, 10)), 
        std_logic_vector(to_unsigned(450, 10)), 
        std_logic_vector(to_unsigned(550, 10)), 
        std_logic_vector(to_unsigned(50, 10)),  
        std_logic_vector(to_unsigned(120, 10)), 
        std_logic_vector(to_unsigned(220, 10)), 
        std_logic_vector(to_unsigned(320, 10)), 
        std_logic_vector(to_unsigned(420, 10)), 
        std_logic_vector(to_unsigned(520, 10)), 
        std_logic_vector(to_unsigned(620, 10)), 
        std_logic_vector(to_unsigned(80, 10)),  
        std_logic_vector(to_unsigned(180, 10))
    );

    CONSTANT moon_center_x : std_logic_vector(9 DOWNTO 0) := std_logic_vector(to_unsigned(540, 10));
    CONSTANT moon_center_y : std_logic_vector(9 DOWNTO 0) := std_logic_vector(to_unsigned(120, 10));
    CONSTANT moon_radius   : INTEGER := 30;
    CONSTANT sun_radius    : INTEGER := 40; 

    SIGNAL prev_left_click : std_logic := '0';
    SIGNAL start_move : std_logic := '0';
    SIGNAL toggle_state : std_logic := '0';
    SIGNAL pb1_prev : std_logic := '0';

    SIGNAL star_speed : std_logic_vector(9 DOWNTO 0) := std_logic_vector(to_unsigned(1, 10));

    SIGNAL star_on : std_logic;
    SIGNAL moon_on : std_logic;
    SIGNAL collision_occurred : std_logic := '0';
    SIGNAL reset_background : std_logic := '0';

    SIGNAL random_value : std_logic_vector(9 DOWNTO 0);

    COMPONENT galois_lfsr
        PORT
        (
            clk : IN std_logic;
            reset : IN std_logic;
            random_value : OUT std_logic_vector(9 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    lfsr_inst: galois_lfsr
        PORT MAP (
            clk => clk,
            reset => reset_background,
            random_value => random_value
        );

    Toggle_Background: PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF pb1 = '1' AND pb1_prev = '0' THEN
                toggle_state <= NOT toggle_state;
            END IF;
            pb1_prev <= pb1;
        END IF;
    END PROCESS;

    Move_Stars: PROCESS (vert_sync)
        VARIABLE game_state : state_type;
    BEGIN
        IF rising_edge(vert_sync) THEN
            game_state := to_state_type(input_state);

            IF game_state = HOME THEN
                -- Reset star positions to initial values
                FOR i IN 0 TO star_count-1 LOOP
                    star_x_positions(i) <= std_logic_vector(unsigned(random_value) MOD to_unsigned(screen_width, 10));
                    star_y_positions(i) <= std_logic_vector(unsigned(random_value) MOD to_unsigned(screen_height, 10));
                END LOOP;
            ELSIF game_state = PAUSE THEN
                null;
            ELSIF game_state = START THEN
                FOR i IN 0 TO star_count-1 LOOP
                    star_x_positions(i) <= std_logic_vector(unsigned(star_x_positions(i)) - unsigned(star_speed));

                    IF unsigned(star_x_positions(i)) < unsigned(to_unsigned(0, star_x_positions(i)'length)) THEN
                        star_x_positions(i) <= std_logic_vector(to_unsigned(screen_width, star_x_positions(i)'length));
                    END IF;
                END LOOP;
            END IF;
        END IF;
    END PROCESS Move_Stars;

    PROCESS (pixel_row, pixel_column)
        VARIABLE is_star : BOOLEAN := FALSE;
        VARIABLE is_moon_sun : BOOLEAN := FALSE;
        VARIABLE delta_x : INTEGER;
        VARIABLE delta_y : INTEGER;
        VARIABLE distance_squared : INTEGER;
    BEGIN
        is_star := FALSE;
        is_moon_sun := FALSE;

        FOR i IN 0 TO star_count-1 LOOP
            IF (pixel_row = star_y_positions(i) AND pixel_column = star_x_positions(i)) THEN
                is_star := TRUE;
            END IF;
        END LOOP;

        delta_x := to_integer(unsigned(pixel_column)) - to_integer(unsigned(moon_center_x));
        delta_y := to_integer(unsigned(pixel_row)) - to_integer(unsigned(moon_center_y));
        distance_squared := delta_x * delta_x + delta_y * delta_y;

        IF toggle_state = '0' AND distance_squared <= moon_radius * moon_radius THEN
            is_moon_sun := TRUE;
            RGB <= "111111111111";
        ELSIF toggle_state = '1' AND distance_squared <= sun_radius * sun_radius THEN
            is_moon_sun := TRUE;
            RGB <= "111110100000";
        ELSE
            IF toggle_state = '1' THEN
                RGB <= "000110101111";
            ELSE
                RGB <= "000000000000";
            END IF;
        END IF;

        IF toggle_state = '0' THEN
            FOR i IN 0 TO star_count-1 LOOP
                IF (pixel_row = star_y_positions(i) AND pixel_column = star_x_positions(i)) THEN
                    is_star := TRUE;
                    RGB <= "111111111111";
                END IF;
            END LOOP;
        END IF;
    END PROCESS;

    output_on <= '1' when (star_on = '1' or moon_on = '1') else '0';
END behavior;
