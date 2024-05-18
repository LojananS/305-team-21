-- File path: bouncy_ball.vhd
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bouncy_ball IS
    PORT
    (
        sw9, pb1, pb2, clk, vert_sync, left_click : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        p1_x_pos, p2_x_pos, p3_x_pos : IN signed(10 DOWNTO 0);
        p1_gap_center, p2_gap_center, p3_gap_center : IN signed(9 DOWNTO 0);
        output_on, start, collision, reset : OUT std_logic;
        score : OUT integer range 0 to 99;
        RGB : OUT std_logic_vector(11 DOWNTO 0)
    );
END bouncy_ball;

ARCHITECTURE behavior OF bouncy_ball IS
    SIGNAL ball_on : std_logic;
    SIGNAL size : signed(9 DOWNTO 0) := to_signed(16, 10);
    SIGNAL ball_y_pos : signed(9 DOWNTO 0) := to_signed(240, 10);
    SIGNAL ball_x_pos : signed(10 DOWNTO 0) := to_signed(150, 11);
    SIGNAL ball_y_motion : signed(9 DOWNTO 0);

    SIGNAL start_move : std_logic := '0';
    SIGNAL prev_left_click : std_logic := '0';

    SIGNAL bird_address : std_logic_vector(9 DOWNTO 0);
    SIGNAL bird_data : std_logic_vector(11 DOWNTO 0);
    
    SIGNAL collision_internal : std_logic := '0';
    SIGNAL reset_internal : std_logic := '0';
    SIGNAL score_internal : integer range 0 to 99 := 0;
    
    SIGNAL passed_p1, passed_p2, passed_p3 : std_logic := '0';

    COMPONENT sprite_rom
        PORT (
            clk            : IN std_logic;
            sprite_address : IN std_logic_vector(9 DOWNTO 0);
            data_out       : OUT std_logic_vector(11 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    sprite_rom_inst : sprite_rom
        PORT MAP (
            clk => clk,
            sprite_address => bird_address,
            data_out => bird_data
        );

    Pixel_Display : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (unsigned(pixel_column) >= unsigned(ball_x_pos) AND 
                unsigned(pixel_column) < unsigned(ball_x_pos) + 32 AND
                unsigned(pixel_row) >= unsigned(ball_y_pos) AND 
                unsigned(pixel_row) < unsigned(ball_y_pos) + 32) THEN
                ball_on <= '1';
                bird_address <= std_logic_vector(to_unsigned(
                    (to_integer(unsigned(pixel_row)) - to_integer(unsigned(ball_y_pos))) * 32 +
                    (to_integer(unsigned(pixel_column)) - to_integer(unsigned(ball_x_pos))), 10));
            ELSE
                ball_on <= '0';
            END IF;
        END IF;
    END PROCESS Pixel_Display;

    RGB <= bird_data when ball_on = '1' and bird_data /= "000000000000" else (others => '0');
    output_on <= '1' when ball_on = '1' and bird_data /= "000000000000" else '0';
    
    -- Collision Detection Logic
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            collision_internal <= '0';
            IF sw9 = '1' THEN -- Check if collisions are enabled
                -- Check collision with Pipe 1
                IF ((ball_x_pos + 2*size >= p1_x_pos AND ball_x_pos + 5 < p1_x_pos + to_signed(30, 10)) AND
                    ((ball_y_pos + 5 <= p1_gap_center - to_signed(45, 10)) OR 
                     (ball_y_pos + 2*size - 6 >= p1_gap_center + to_signed(45, 10)))) THEN
                    collision_internal <= '1';
                END IF;

                -- Check collision with Pipe 2
                IF ((ball_x_pos + 2*size >= p2_x_pos AND ball_x_pos + 5 < p2_x_pos + to_signed(30, 10)) AND
                    ((ball_y_pos + 5 <= p2_gap_center - to_signed(45, 10)) OR 
                     (ball_y_pos + 2*size - 6 >= p2_gap_center + to_signed(45, 10)))) THEN
                    collision_internal <= '1';
                END IF;

                -- Check collision with Pipe 3
                IF ((ball_x_pos + 2*size >= p3_x_pos AND ball_x_pos + 5 < p3_x_pos + to_signed(30, 10)) AND
                    ((ball_y_pos + 5 <= p3_gap_center - to_signed(45, 10)) OR 
                     (ball_y_pos + 2*size - 6 >= p3_gap_center + to_signed(45, 10)))) THEN
                    collision_internal <= '1';
                END IF;
            END IF;
        END IF;
        collision <= collision_internal;
    END PROCESS;

    -- Score Calculation Logic
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF start_move = '1' THEN
                -- Check if the bird has passed the middle of the pipe
                IF (ball_x_pos > p1_x_pos + to_signed(15, 11)) AND (passed_p1 = '0') THEN
                    passed_p1 <= '1';
                    score_internal <= score_internal + 1;
                ELSIF ball_x_pos <= p1_x_pos THEN
                    passed_p1 <= '0';
                END IF;

                IF (ball_x_pos > p2_x_pos + to_signed(15, 11)) AND (passed_p2 = '0') THEN
                    passed_p2 <= '1';
                    score_internal <= score_internal + 1;
                ELSIF ball_x_pos <= p2_x_pos THEN
                    passed_p2 <= '0';
                END IF;

                IF (ball_x_pos > p3_x_pos + to_signed(15, 11)) AND (passed_p3 = '0') THEN
                    passed_p3 <= '1';
                    score_internal <= score_internal + 1;
                ELSIF ball_x_pos <= p3_x_pos THEN
                    passed_p3 <= '0';
                END IF;
				 
			   ELSIF reset_internal = '1' THEN
					score_internal <= 0;
            END IF;
            score <= score_internal;
        END IF;
    END PROCESS;

    Move_Ball: PROCESS (vert_sync, left_click, sw9, collision_internal, reset_internal)
        VARIABLE gravity_up : integer RANGE -100 TO 0 := 0;
        VARIABLE gravity_down : integer RANGE 0 TO 4 := 1;
        VARIABLE up : std_logic;
        VARIABLE count: integer RANGE 0 TO 7 := 0;
    BEGIN
        IF (rising_edge(vert_sync)) THEN
            IF (left_click = '1' AND prev_left_click = '0') THEN
                IF collision_internal = '1' THEN
                    reset_internal <= '1'; -- Reset pipes on click after collision
                ELSE
						start_move <= '1';
					 END IF;
            END IF;

            IF reset_internal = '1' THEN
                -- Reset ball position
                ball_y_pos <= to_signed(240, 10);
                ball_x_pos <= to_signed(150, 11);
                reset_internal <= '0'; -- Clear reset signal
            END IF;
				
				IF (start_move = '1') THEN
					 count := count + 1;
                IF (sw9 = '1') AND (collision_internal = '1') THEN
                    start_move <= '0'; -- Stop bird movement on collision only if collisions are enabled
                ELSE
                    IF (left_click = '1') AND (prev_left_click = '0') THEN
                        count := 0;
                        up := '1';
                    ELSIF (up = '1') THEN
                        IF (count = 1) THEN
                            gravity_up := -15;
                        ELSIF (count = 2) THEN
                            gravity_up := -10;
                        ELSIF (count = 4) THEN
                            gravity_up := -5;
                        ELSIF (count = 5) THEN
                            gravity_up := -3;
                        ELSIF (count = 6) THEN
                            gravity_up := -1;
                        ELSIF (count >= 7) THEN
                            up := '0';
                        END IF;
                        ball_y_motion <= to_signed(gravity_up, 10);
                    ELSIF (ball_y_pos >= to_signed(450, 10) - size*2) THEN
                        ball_y_motion <= to_signed(0, 10);
                    ELSE
                        IF (count > 0) THEN
                            gravity_down := 3;
                        ELSIF (count >= 3) THEN
                            gravity_down := 4;
                        END IF;
                        ball_y_motion <= to_signed(gravity_down, 10);
                    END IF;
                    ball_y_pos <= ball_y_pos + ball_y_motion;
                END IF;
            END IF;
            prev_left_click <= left_click;
        END IF;
        reset <= reset_internal;
		  start <= start_move;
    END PROCESS Move_Ball;
END behavior;
