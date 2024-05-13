LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY background IS
    PORT
        ( pixel_row, pixel_column    : IN std_logic_vector(9 DOWNTO 0);
          pb1, clk, vert_sync, left_click : IN std_logic;
			output_on						: OUT std_logic;
			RGB									: OUT std_logic_vector(2 downto 0));        
END background;

ARCHITECTURE behavior OF background IS
    -- Screen dimensions
    CONSTANT screen_width : INTEGER := 640;
    CONSTANT screen_height : INTEGER := 480;

    -- Star positions
    CONSTANT star_count : INTEGER := 20; -- Number of stars
    TYPE star_array IS ARRAY (0 TO star_count-1) OF std_logic_vector(9 DOWNTO 0);
    CONSTANT star_y_positions : star_array := (
        std_logic_vector(to_unsigned(50, 10)),  -- Star 1
        std_logic_vector(to_unsigned(150, 10)), -- Star 2
        std_logic_vector(to_unsigned(250, 10)), -- Star 3
        std_logic_vector(to_unsigned(350, 10)), -- Star 4
        std_logic_vector(to_unsigned(100, 10)), -- Star 5
        std_logic_vector(to_unsigned(200, 10)), -- Star 6
        std_logic_vector(to_unsigned(300, 10)), -- Star 7
        std_logic_vector(to_unsigned(400, 10)), -- Star 8
        std_logic_vector(to_unsigned(75, 10)),  -- Star 9
        std_logic_vector(to_unsigned(175, 10)), -- Star 10
        std_logic_vector(to_unsigned(275, 10)), -- Star 11
        std_logic_vector(to_unsigned(375, 10)), -- Star 12
        std_logic_vector(to_unsigned(125, 10)), -- Star 13
        std_logic_vector(to_unsigned(225, 10)), -- Star 14
        std_logic_vector(to_unsigned(325, 10)), -- Star 15
        std_logic_vector(to_unsigned(425, 10)), -- Star 16
        std_logic_vector(to_unsigned(475, 10)), -- Star 17
        std_logic_vector(to_unsigned(425, 10)), -- Star 18
        std_logic_vector(to_unsigned(225, 10)), -- Star 19
        std_logic_vector(to_unsigned(325, 10))  -- Star 20
    );

    SIGNAL star_x_positions : star_array := (
        std_logic_vector(to_unsigned(100, 10)), -- Star 1
        std_logic_vector(to_unsigned(200, 10)), -- Star 2
        std_logic_vector(to_unsigned(300, 10)), -- Star 3
        std_logic_vector(to_unsigned(400, 10)), -- Star 4
        std_logic_vector(to_unsigned(500, 10)), -- Star 5
        std_logic_vector(to_unsigned(600, 10)), -- Star 6
        std_logic_vector(to_unsigned(150, 10)), -- Star 7
        std_logic_vector(to_unsigned(250, 10)), -- Star 8
        std_logic_vector(to_unsigned(350, 10)), -- Star 9
        std_logic_vector(to_unsigned(450, 10)), -- Star 10
        std_logic_vector(to_unsigned(550, 10)), -- Star 11
        std_logic_vector(to_unsigned(50, 10)),  -- Star 12
        std_logic_vector(to_unsigned(120, 10)), -- Star 13
        std_logic_vector(to_unsigned(220, 10)), -- Star 14
        std_logic_vector(to_unsigned(320, 10)), -- Star 15
        std_logic_vector(to_unsigned(420, 10)), -- Star 16
        std_logic_vector(to_unsigned(520, 10)), -- Star 17
        std_logic_vector(to_unsigned(620, 10)), -- Star 18
        std_logic_vector(to_unsigned(80, 10)),  -- Star 19
        std_logic_vector(to_unsigned(180, 10))  -- Star 20
    );

    -- Moon position and size
    CONSTANT moon_center_x : std_logic_vector(9 DOWNTO 0) := std_logic_vector(to_unsigned(540, 10));
    CONSTANT moon_center_y : std_logic_vector(9 DOWNTO 0) := std_logic_vector(to_unsigned(120, 10));
    CONSTANT moon_radius   : INTEGER := 30;
	 CONSTANT sun_radius    : INTEGER := 40; 

    SIGNAL prev_left_click : std_logic := '0';
    SIGNAL start_move : std_logic := '0';
	 SIGNAL toggle_state : std_logic := '0'; -- Toggle state for pb1
    SIGNAL pb1_prev : std_logic := '0'; -- Previous state of pb1 for edge detection

    SIGNAL star_speed : std_logic_vector(9 DOWNTO 0) := std_logic_vector(to_unsigned(1, 10));
	 
	 signal star_on : std_logic;
	 signal moon_on : std_logic;

BEGIN

-- Toggle Functionality for Background and Moon/Sun Transition
    Toggle_Background: PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF pb1 = '1' AND pb1_prev = '0' THEN
                toggle_state <= NOT toggle_state; -- Toggle the state on button press
            END IF;
            pb1_prev <= pb1; -- Update previous state
        END IF;
    END PROCESS;
	 
	 
    -- Move Stars Process
    Move_Stars: PROCESS (vert_sync, left_click)
    BEGIN
        IF rising_edge(vert_sync) THEN
            -- Start the movement on left click
            IF left_click = '1' AND prev_left_click = '0' THEN
                start_move <= '1';
            END IF;

            -- Move stars to the left
            IF start_move = '1' THEN
                FOR i IN 0 TO star_count-1 LOOP
                    star_x_positions(i) <= std_logic_vector(unsigned(star_x_positions(i)) - unsigned(star_speed));

                    -- Wrap around to the right if the star moves off-screen
                    IF unsigned(star_x_positions(i)) < unsigned(to_unsigned(0, star_x_positions(i)'length)) THEN
                        star_x_positions(i) <= std_logic_vector(to_unsigned(screen_width, star_x_positions(i)'length));
                    END IF;
                END LOOP;
            END IF;

            prev_left_click <= left_click;
        END IF;
    END PROCESS Move_Stars;

    -- Drawing Process
    PROCESS (pixel_row, pixel_column)
        VARIABLE is_star : BOOLEAN := FALSE;
        VARIABLE is_moon_sun : BOOLEAN := FALSE;
        VARIABLE delta_x : INTEGER;
        VARIABLE delta_y : INTEGER;
        VARIABLE distance_squared : INTEGER;
    BEGIN			
        is_star := FALSE;
        is_moon_sun := FALSE;

        -- Check if the current pixel corresponds to any of the star positions
        FOR i IN 0 TO star_count-1 LOOP
            IF (pixel_row = star_y_positions(i) AND pixel_column = star_x_positions(i)) THEN
                is_star := TRUE;
            END IF;
        END LOOP;

        -- Check if the current pixel corresponds to the moon or sun
        delta_x := to_integer(unsigned(pixel_column)) - to_integer(unsigned(moon_center_x));
        delta_y := to_integer(unsigned(pixel_row)) - to_integer(unsigned(moon_center_y));
        distance_squared := delta_x * delta_x + delta_y * delta_y;
		  
        IF toggle_state = '0' AND distance_squared <= moon_radius * moon_radius THEN
            is_moon_sun := TRUE;
            RGB <= "111"; -- White for the moon
        ELSIF toggle_state = '1' AND distance_squared <= sun_radius * sun_radius THEN
            is_moon_sun := TRUE;
            RGB <= "110"; -- Yellow for the sun
        ELSE
            -- Background color toggle based on the state
            IF toggle_state = '1' THEN
                RGB <= "001"; -- Blue background when toggled
            ELSE
                RGB <= "000"; -- Default black background
            END IF;
        END IF;
		  
		  -- Check if the current pixel corresponds to any of the star positions
        -- Only display stars if the moon is visible
        IF toggle_state = '0' THEN
            FOR i IN 0 TO star_count-1 LOOP
                IF (pixel_row = star_y_positions(i) AND pixel_column = star_x_positions(i)) THEN
                    is_star := TRUE;
                    RGB <= "111"; -- White for stars
                END IF;
            END LOOP;
        END IF;
		  
    END PROCESS;
	 output_on <= '1' when (star_on = '1' or moon_on = '1') else
						'0';
END behavior;
