LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.game_type_pkg.ALL;

ENTITY pipes IS
    PORT
    (
        clk, vert_sync: IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        input_state : IN std_logic_vector(3 DOWNTO 0); -- Input state for FSM
        output_on : OUT std_logic;
        RGB : OUT std_logic_vector(11 DOWNTO 0);
        p1_x_pos, p2_x_pos, p3_x_pos : OUT signed(10 DOWNTO 0);
        p1_gap_center, p2_gap_center, p3_gap_center : OUT signed(9 DOWNTO 0);
        blue_box_x_pos, red_box_x_pos : OUT signed(10 DOWNTO 0);
        blue_box_y_pos, red_box_y_pos : OUT signed(9 DOWNTO 0);
        reset_blue_box, reset_red_box : IN std_logic;
        ball_x_pos : IN signed(10 DOWNTO 0); -- Add ball position inputs
        ball_y_pos : IN signed (9 DOWNTO 0);
        ball_size : IN signed(9 DOWNTO 0); -- Add ball size input
        score : IN integer range 0 to 999;
        pb1 : IN std_logic
    );      
END pipes;

ARCHITECTURE behavior OF pipes IS
    CONSTANT GROUND_HEIGHT : integer range 0 to 30 := 30;
    CONSTANT PIPE_WIDTH : integer range 0 to 60 := 60;
    CONSTANT PIPE_HEIGHT : integer range 0 to 960 := 960;
    CONSTANT GAP_SIZE : integer range 0 to 90 := 90;
	 CONSTANT VERTICAL_OFFSET : integer range 0 to 240 := 240;

    SIGNAL p1_on : std_logic;
    SIGNAL p1_x_pos_internal : signed(10 DOWNTO 0) := to_signed(213, 11);
	 SIGNAL p1_y_pos_internal : signed(10 DOWNTO 0) := to_signed(240, 11);
    SIGNAL p1_gap_center_internal : signed(9 DOWNTO 0) := to_signed(240, 10);

    SIGNAL p2_on : std_logic;
    SIGNAL p2_x_pos_internal : signed(10 DOWNTO 0) := to_signed(426, 11);
	 SIGNAL p2_y_pos_internal : signed(10 DOWNTO 0) := to_signed(240, 11);
    SIGNAL p2_gap_center_internal : signed(9 DOWNTO 0) := to_signed(360, 10);

    SIGNAL p3_on : std_logic;
    SIGNAL p3_x_pos_internal : signed(10 DOWNTO 0) := to_signed(640, 11);
	 SIGNAL p3_y_pos_internal : signed(10 DOWNTO 0) := to_signed(240, 11);
    SIGNAL p3_gap_center_internal : signed(9 DOWNTO 0) := to_signed(100, 10);

    SIGNAL pipe_x_size : signed(9 DOWNTO 0) := to_signed(60, 10);
    SIGNAL start_move : std_logic := '0';

    SIGNAL random_value : std_logic_vector(9 DOWNTO 0);

    SIGNAL blue_box_on : std_logic := '0';
    SIGNAL blue_box_x_pos_internal : signed(10 DOWNTO 0) := to_signed(1000, 11);
    SIGNAL blue_box_y_pos_internal : signed(9 DOWNTO 0);

    SIGNAL red_box_on : std_logic := '0';
    SIGNAL red_box_x_pos_internal : signed(10 DOWNTO 0) := to_signed(800, 11);
    SIGNAL red_box_y_pos_internal : signed(9 DOWNTO 0);

    SIGNAL blue_box_size : signed(9 DOWNTO 0) := to_signed(32, 10); -- size of the blue box
    SIGNAL blue_box_visible : std_logic := '1'; -- Visibility of the blue box

    SIGNAL red_box_size : signed(9 DOWNTO 0) := to_signed(32, 10); -- size of the red box
    SIGNAL red_box_visible : std_logic := '1'; -- Visibility of the red box

    SIGNAL coin_color : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL coin_address : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL selected_color : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    SIGNAL toggle_state : std_logic := '0';
    SIGNAL pb1_prev : std_logic := '0';

    SIGNAL move_speed : signed(10 DOWNTO 0) := to_signed(1, 11); -- Initial speed

    SIGNAL coin_active : std_logic := '0';
    SIGNAL red_box_active : std_logic := '0';

    SIGNAL pipe_color : std_logic_vector(11 DOWNTO 0);
	 SIGNAL pipe_address : std_logic_vector(15 DOWNTO 0);

    COMPONENT galois_lfsr
        PORT
        (
            clk : IN std_logic;
            reset : IN std_logic;
            random_value : OUT std_logic_vector(9 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT coin_rom
        PORT
        (
            clk : IN STD_LOGIC;
            coin_address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            coin_data_out : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;
	 
	 COMPONENT pipe_rom IS
		PORT
		(
			clk             :   IN STD_LOGIC;
			address_out  :   IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			data_out        :   OUT STD_LOGIC_VECTOR(11 DOWNTO 0) -- Updated to 12 bits
		);
	END COMPONENT pipe_rom;

BEGIN
    lfsr_inst: galois_lfsr
        PORT MAP (
            clk => clk,
            reset => '0',
            random_value => random_value
        );
    coin_inst: coin_rom
        PORT MAP (
            clk => clk,
            coin_address => coin_address,
            coin_data_out => coin_color
        );
    
	 pipe_inst: pipe_rom
        PORT MAP (
            clk => clk,
            address_out => pipe_address,
				data_out => pipe_color
        );
		  
    Toggle_pipes: PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF pb1 = '1' AND pb1_prev = '0' THEN
                toggle_state <= NOT toggle_state;
            END IF;
            pb1_prev <= pb1;
        END IF;
    END PROCESS;

--    PROCESS (clk)
--    BEGIN
--        IF rising_edge(clk) THEN
--            IF toggle_state = '1' THEN
--                pipe_color <= "001010100000"; -- HEX code '2A0'
--            ELSE
--                pipe_color <= "100010001000"; -- Original pipe color
--            END IF;
--        END IF;
--    END PROCESS;
					 
	Pipe_Display : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            -- Pipe 1
            IF (p1_x_pos_internal + pipe_x_size > to_signed(0, 11) AND
                to_integer(unsigned(pixel_column)) >= to_integer(p1_x_pos_internal) AND 
                to_integer(unsigned(pixel_column)) < to_integer(p1_x_pos_internal) + to_integer(pipe_x_size) AND
                (to_integer(unsigned(pixel_row)) < to_integer(p1_y_pos_internal) - 240 OR 
                 to_integer(unsigned(pixel_row)) > to_integer(p1_y_pos_internal) + 240)) THEN
                p1_on <= '1';
                pipe_address <= std_logic_vector(to_unsigned(
                    (to_integer(unsigned(pixel_row)) + VERTICAL_OFFSET) mod PIPE_HEIGHT * PIPE_WIDTH + 
                    (to_integer(unsigned(pixel_column)) mod PIPE_WIDTH), 16));
            ELSE
                p1_on <= '0';
            END IF;

            -- Pipe 2
            IF (p2_x_pos_internal + pipe_x_size > to_signed(0, 11) AND
                to_integer(unsigned(pixel_column)) >= to_integer(p2_x_pos_internal) AND 
                to_integer(unsigned(pixel_column)) < to_integer(p2_x_pos_internal) + to_integer(pipe_x_size) AND
                (to_integer(unsigned(pixel_row)) < to_integer(p2_y_pos_internal) OR 
                 to_integer(unsigned(pixel_row)) > to_integer(p2_y_pos_internal))) THEN
                p2_on <= '1';
                pipe_address <= std_logic_vector(to_unsigned(
                    (to_integer(unsigned(pixel_row)) + VERTICAL_OFFSET) mod PIPE_HEIGHT * PIPE_WIDTH + 
                    (to_integer(unsigned(pixel_column)) mod PIPE_WIDTH), 16));
            ELSE
                p2_on <= '0';
            END IF;

            -- Pipe 3
            IF (p3_x_pos_internal + pipe_x_size > to_signed(0, 11) AND
                to_integer(unsigned(pixel_column)) >= to_integer(p3_x_pos_internal) AND 
                to_integer(unsigned(pixel_column)) < to_integer(p3_x_pos_internal) + to_integer(pipe_x_size) AND
                (to_integer(unsigned(pixel_row)) < to_integer(p3_y_pos_internal) OR 
                 to_integer(unsigned(pixel_row)) > to_integer(p3_y_pos_internal))) THEN
                p3_on <= '1';
                pipe_address <= std_logic_vector(to_unsigned(
                    (to_integer(unsigned(pixel_row)) + VERTICAL_OFFSET) mod PIPE_HEIGHT * PIPE_WIDTH + 
                    (to_integer(unsigned(pixel_column)) mod PIPE_WIDTH), 16));
            ELSE
                p3_on <= '0';
            END IF;
        END IF;
    END PROCESS Pipe_Display;
	

    Coin_Display : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (to_integer(unsigned(pixel_column)) >= to_integer(blue_box_x_pos_internal) AND 
                to_integer(unsigned(pixel_column)) < to_integer(blue_box_x_pos_internal) + to_integer(blue_box_size) AND
                to_integer(unsigned(pixel_row)) >= to_integer(blue_box_y_pos_internal) AND 
                to_integer(unsigned(pixel_row)) < to_integer(blue_box_y_pos_internal) + to_integer(blue_box_size)) THEN
                blue_box_on <= '1';
                coin_address <= std_logic_vector(to_unsigned(
                    (to_integer(unsigned(pixel_row)) - to_integer(unsigned(blue_box_y_pos_internal))) * 32 +
                    (to_integer(unsigned(pixel_column)) - to_integer(unsigned(blue_box_x_pos_internal))), 10));
            ELSE
                blue_box_on <= '0';
            END IF;
        END IF;
    END PROCESS Coin_Display;

    Red_Box_Display : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (to_integer(unsigned(pixel_column)) >= to_integer(red_box_x_pos_internal) AND 
                to_integer(unsigned(pixel_column)) < to_integer(red_box_x_pos_internal) + to_integer(red_box_size) AND
                to_integer(unsigned(pixel_row)) >= to_integer(red_box_y_pos_internal) AND 
                to_integer(unsigned(pixel_row)) < to_integer(red_box_y_pos_internal) + to_integer(red_box_size)) THEN
                red_box_on <= '1';
            ELSE
                red_box_on <= '0';
            END IF;
        END IF;
    END PROCESS Red_Box_Display;
    
    PROCESS (blue_box_on, blue_box_visible, red_box_on, red_box_visible, coin_color, p1_on, p2_on, p3_on, pipe_color)
    BEGIN
        IF blue_box_on = '1' AND coin_color /= "000100010001" AND blue_box_visible = '1' THEN
            selected_color <= coin_color;
        ELSIF red_box_on = '1' AND red_box_visible = '1' THEN
            selected_color <= "111000000000"; -- Red color for red box
        ELSIF (p1_on = '1' OR p2_on = '1' OR p3_on = '1') AND (pipe_color /= "000100010001") THEN
            selected_color <= pipe_color;
        ELSE
            selected_color <= "000000000000";
        END IF;
    END PROCESS;

    -- RGB and output enable logic
    RGB <= selected_color;

    output_on <= '1' WHEN selected_color /= "000000000000" ELSE '0';

    Move_pipe: PROCESS (vert_sync, reset_blue_box, reset_red_box, blue_box_visible, red_box_visible)
        VARIABLE game_state : state_type;
    BEGIN
        IF rising_edge(vert_sync) THEN
            -- Convert input_state to state_type
            game_state := to_state_type(input_state);
        
            IF (game_state = RESET_GAME OR game_state = HOME) THEN
                -- Reset pipes to their original positions
                p1_x_pos_internal <= to_signed(213, 11);
                p1_gap_center_internal <= to_signed(240, 10);
                p2_x_pos_internal <= to_signed(426, 11);
                p2_gap_center_internal <= to_signed(360, 10);
                p3_x_pos_internal <= to_signed(640, 11);
                p3_gap_center_internal <= to_signed(100, 10);
                blue_box_x_pos_internal <= to_signed(1000, 11);
                blue_box_y_pos_internal <= to_signed(240, 10);
                red_box_x_pos_internal <= to_signed(800, 11);
                red_box_y_pos_internal <= to_signed(240, 10);
                coin_active <= '0';
                red_box_active <= '0';
                blue_box_visible <= '1'; -- Make the blue box visible again
                red_box_visible <= '1'; -- Make the red box visible again
            ELSIF game_state = PAUSE THEN
                null;
            ELSIF game_state = START THEN
            
                -- Adjust speed based on score
                IF score >= 20 THEN
                    move_speed <= to_signed(3, 11); -- Speed increases significantly
                ELSIF score >= 10 THEN
                    move_speed <= to_signed(2, 11); -- Speed increases moderately
                ELSE
                    move_speed <= to_signed(1, 11); -- Default speed
                END IF;

                IF (p1_x_pos_internal + pipe_x_size <= to_signed(0, 11)) THEN
                    p1_x_pos_internal <= to_signed(640, 11);
                    p1_gap_center_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                    IF coin_active = '0' THEN
                        coin_active <= '1';
                        blue_box_x_pos_internal <= to_signed(640 + 50, 11); -- Coin appears 50 units after the pipe
                        blue_box_y_pos_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                        blue_box_visible <= '1'; -- Make the coin visible again
                    END IF;
                ELSE
                    p1_x_pos_internal <= p1_x_pos_internal - move_speed;
                END IF;

                IF (p2_x_pos_internal + pipe_x_size <= to_signed(0, 11)) THEN
                    p2_x_pos_internal <= to_signed(640, 11);
                    p2_gap_center_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                    IF coin_active = '0' THEN
                        coin_active <= '1';
                        blue_box_x_pos_internal <= to_signed(640 + 50, 11); -- Coin appears 50 units after the pipe
                        blue_box_y_pos_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                        blue_box_visible <= '1'; -- Make the coin visible again
                    END IF;
                ELSE
                    p2_x_pos_internal <= p2_x_pos_internal - move_speed;
                END IF;

                IF (p3_x_pos_internal + pipe_x_size <= to_signed(0, 11)) THEN
                    p3_x_pos_internal <= to_signed(640, 11);
                    p3_gap_center_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                    IF coin_active = '0' THEN
                        coin_active <= '1';
                        blue_box_x_pos_internal <= to_signed(640 + 50, 11); -- Coin appears 50 units after the pipe
                        blue_box_y_pos_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                        blue_box_visible <= '1'; -- Make the coin visible again
                    END IF;
                ELSE
                    p3_x_pos_internal <= p3_x_pos_internal - move_speed;
                END IF;

                -- Move blue box (coin) independently if it is active
                IF coin_active = '1' THEN
                    IF blue_box_x_pos_internal + blue_box_size <= to_signed(0, 11) THEN
                        coin_active <= '0'; -- Coin moves off the screen and resets
                    ELSE
                        blue_box_x_pos_internal <= blue_box_x_pos_internal - move_speed;
                    END IF;
                END IF;

                -- Move red box independently if it is active
                IF red_box_active = '1' THEN
                    IF red_box_x_pos_internal + red_box_size <= to_signed(0, 11) THEN
                        red_box_active <= '0'; -- Red box moves off the screen and resets
                    ELSE
                        red_box_x_pos_internal <= red_box_x_pos_internal - move_speed;
                    END IF;
                ELSE
                    -- Activate red box at a random position above ground and after pipes
                    red_box_active <= '1';
                    red_box_x_pos_internal <= to_signed(640 + 100, 11); -- Red box appears 100 units after the pipe
                    red_box_y_pos_internal <= (signed(random_value) MOD to_signed(310 - GROUND_HEIGHT - 50, 10)) + to_signed(55, 10);
                    red_box_visible <= '1'; -- Make the red box visible again
                END IF;
            END IF;

            IF blue_box_visible = '1' AND 
               (ball_x_pos + ball_size >= blue_box_x_pos_internal AND ball_x_pos <= blue_box_x_pos_internal + blue_box_size) AND 
               (ball_y_pos + ball_size >= blue_box_y_pos_internal AND ball_y_pos <= blue_box_y_pos_internal + blue_box_size) THEN
                blue_box_visible <= '0'; -- Make the coin invisible when touched
            END IF;

            IF red_box_visible = '1' AND 
               (ball_x_pos + ball_size >= red_box_x_pos_internal AND ball_x_pos <= red_box_x_pos_internal + red_box_size) AND 
               (ball_y_pos + ball_size >= red_box_y_pos_internal AND ball_y_pos <= red_box_y_pos_internal + red_box_size) THEN
                red_box_visible <= '0'; -- Make the red box invisible when touched
            END IF;
        END IF;
    END PROCESS Move_pipe;

    p1_x_pos <= p1_x_pos_internal;
    p1_gap_center <= p1_gap_center_internal;
    p2_x_pos <= p2_x_pos_internal;
    p2_gap_center <= p2_gap_center_internal;
    p3_x_pos <= p3_x_pos_internal;
    p3_gap_center <= p3_gap_center_internal;
    blue_box_x_pos <= blue_box_x_pos_internal;
    blue_box_y_pos <= blue_box_y_pos_internal;
    red_box_x_pos <= red_box_x_pos_internal;
    red_box_y_pos <= red_box_y_pos_internal;

END behavior;
