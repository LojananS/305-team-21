LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.game_type_pkg.ALL;

ENTITY bouncy_ball IS
    PORT (
        sw9, pb1, clk, vert_sync, left_click: IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        input_state : IN std_logic_vector(3 DOWNTO 0); -- Input state for FSM
        output_state : OUT std_logic_vector(3 DOWNTO 0); -- Output state for FSM
        p1_x_pos, p2_x_pos, p3_x_pos : IN signed(10 DOWNTO 0);
        p1_gap_center, p2_gap_center, p3_gap_center : IN signed(9 DOWNTO 0);
        blue_box_x_pos: IN signed(10 DOWNTO 0);
        blue_box_y_pos : IN signed(9 DOWNTO 0);
        output_on, start_signal, collision, reset_signal, reset_blue_box: OUT std_logic;
        score : OUT integer range 0 to 999;
        hund_bcd, tens_bcd, units_bcd : OUT std_logic_vector(3 DOWNTO 0);
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

    SIGNAL bird_address : std_logic_vector(11 DOWNTO 0);
    SIGNAL bird_data : std_logic_vector(11 DOWNTO 0);
    
    SIGNAL collision_internal : std_logic := '0';
    SIGNAL reset_internal : std_logic := '0';
    SIGNAL reset_blue_box_internal : std_logic := '0';
    
    SIGNAL score_internal : integer range 0 to 999 := 0;
    SIGNAL passed_p1, passed_p2, passed_p3 : std_logic := '0';
    SIGNAL touched_blue_box : std_logic := '0';
    SIGNAL blue_box_touched_flag : std_logic := '0';
    SIGNAL hund_bcd_internal, tens_bcd_internal, units_bcd_internal : std_logic_vector(3 DOWNTO 0);

    SIGNAL sw9_captured : std_logic := '0'; -- Signal to capture the state of sw9

    COMPONENT sprite_rom
        PORT (
            clk            : IN std_logic;
            sprite_address : IN std_logic_vector(11 DOWNTO 0);
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
                    (to_integer(unsigned(pixel_column)) - to_integer(unsigned(ball_x_pos))), 12));
            ELSE
                ball_on <= '0';
            END IF;
        END IF;
    END PROCESS Pixel_Display;

    RGB <= bird_data when (ball_on = '1' and bird_data /= "000100010001");
    output_on <= '1' when (ball_on = '1' and bird_data /= "000100010001") else '0';

  

    Main_Process: PROCESS (vert_sync)
        VARIABLE gravity_up : integer RANGE -100 TO 0 := 0;
        VARIABLE gravity_down : integer RANGE 0 TO 4 := 1;
        VARIABLE up : std_logic;
        VARIABLE count: integer RANGE 0 TO 7 := 0;
        VARIABLE game_state : state_type;
    BEGIN
        IF rising_edge(vert_sync) THEN
            -- Default assignments to prevent latches
            collision_internal <= '0';
            reset_blue_box_internal <= '0';
            ball_y_motion <= ball_y_motion;
            ball_y_pos <= ball_y_pos;
            ball_x_pos <= ball_x_pos;
            start_move <= start_move;
            prev_left_click <= prev_left_click;
            touched_blue_box <= touched_blue_box;
            score_internal <= score_internal;
            hund_bcd_internal <= hund_bcd_internal;
            tens_bcd_internal <= tens_bcd_internal;
            units_bcd_internal <= units_bcd_internal;
            output_state <= input_state;

            -- Convert input_state to state_type
            game_state := to_state_type(input_state);

            -- Handling PAUSE state
            IF game_state = PAUSE THEN
                NULL;
            END IF;

            -- Handling home state
            IF game_state = home THEN
                -- Allow capturing sw9 state only in home state
                sw9_captured <= sw9;
					 output_state <= to_slv(START);
					 
            END IF;
				

            -- Handling START state
            IF game_state = START THEN
                output_state <= to_slv(START);  -- Start state

                IF sw9_captured = '1' THEN -- Check if collisions are enabled
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

                    -- Check collision with ground and ceiling
                    IF (ball_y_pos >= to_signed(450, 10) - size*2 OR ball_y_pos <= to_signed(-200, 10)) THEN
                        collision_internal <= '1';
                    END IF;
                END IF;

                -- Check collision with Blue Box
                IF ((ball_x_pos + 2*size >= blue_box_x_pos AND ball_x_pos + 5 < blue_box_x_pos + to_signed(20, 10)) AND
                    (ball_y_pos + 5 <= blue_box_y_pos + to_signed(20, 10) AND 
                    ball_y_pos + 2*size - 6 >= blue_box_y_pos)) THEN
                    touched_blue_box <= '1';
                ELSE
                    touched_blue_box <= '0';
                END IF;

                IF collision_internal = '1' THEN
                    output_state <= to_slv(RESET_GAME);  -- Collision state which is reset game right now. Can add endgame
                    ball_y_pos <= to_signed(240, 10); -- Reset ball y position
                    ball_x_pos <= to_signed(150, 11); -- Reset ball x position
                END IF;

                -- Score Calculation Logic
                -- Check if the bird has passed the middle of the pipe
                IF (ball_x_pos > p1_x_pos) AND (passed_p1 = '0') THEN
                    passed_p1 <= '1';
                    score_internal <= score_internal + 1;
                ELSIF ball_x_pos <= p1_x_pos THEN
                    passed_p1 <= '0';
                END IF;

                IF (ball_x_pos > p2_x_pos) AND (passed_p2 = '0') THEN
                    passed_p2 <= '1';
                    score_internal <= score_internal + 1;
                ELSIF ball_x_pos <= p2_x_pos THEN
                    passed_p2 <= '0';
                END IF;

                IF (ball_x_pos > p3_x_pos) AND (passed_p3 = '0') THEN
                    passed_p3 <= '1';
                    score_internal <= score_internal + 1;
                ELSIF ball_x_pos <= p3_x_pos THEN
                    passed_p3 <= '0';
                END IF;

                -- Check if the bird touched the coin
                IF touched_blue_box = '1' AND blue_box_touched_flag = '0' THEN
                    score_internal <= score_internal + 2;
                    blue_box_touched_flag <= '1'; -- Set the flag to indicate the coin has been touched
                ELSIF touched_blue_box = '0' THEN
                    blue_box_touched_flag <= '0'; -- Reset the flag when the coin is no longer touched
                END IF;

                IF reset_internal = '1' THEN
                    score_internal <= 0;
                END IF;

                score <= score_internal;
                hund_bcd_internal <= std_logic_vector(to_unsigned(score_internal / 100 , 4));
                tens_bcd_internal <= std_logic_vector(to_unsigned(score_internal / 10, 4));
                units_bcd_internal <= std_logic_vector(to_unsigned(score_internal MOD 10, 4));

                hund_bcd <= hund_bcd_internal;
                tens_bcd <= tens_bcd_internal;
                units_bcd <= units_bcd_internal;

                -- Moving logic
                IF (left_click = '1' AND prev_left_click = '0') THEN
                    IF collision_internal = '1' THEN
                        reset_internal <= '1'; -- Reset pipes on click after collision
                    ELSE
                        start_move <= '1'; -- Start the bird movement
                    END IF;
                END IF;

                IF reset_internal = '1' THEN
                    reset_internal <= '0'; -- Clear reset signal
                    start_move <= '0'; -- Stop the bird movement on reset
                END IF;

                IF start_move = '1' THEN
                    count := count + 1;
                    IF (left_click = '1' AND prev_left_click = '0') THEN
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

                prev_left_click <= left_click;
                reset_signal <= reset_internal;
                start_signal <= start_move;
            END IF;
        END IF;
        collision <= collision_internal;
        reset_blue_box <= reset_blue_box_internal;
    END PROCESS Main_Process;
END behavior;
