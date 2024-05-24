LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pipes IS
    PORT
    (
        clk, vert_sync, start, reset, collision, reset_pipes, pause: IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        output_on : OUT std_logic;
        RGB : OUT std_logic_vector(11 DOWNTO 0);
        p1_x_pos, p2_x_pos, p3_x_pos : OUT signed(10 DOWNTO 0);
        p1_gap_center, p2_gap_center, p3_gap_center : OUT signed(9 DOWNTO 0);
        blue_box_x_pos : OUT signed(10 DOWNTO 0);
        blue_box_y_pos : OUT signed(9 DOWNTO 0);
        reset_blue_box : IN std_logic
    );		
END pipes;

ARCHITECTURE behavior OF pipes IS
    SIGNAL p1_on : std_logic;
    SIGNAL p1_x_pos_internal : signed(10 DOWNTO 0) := to_signed(213, 11); 
    SIGNAL p1_gap_center_internal : signed(9 DOWNTO 0) := to_signed(240, 10);

    SIGNAL p2_on : std_logic;
    SIGNAL p2_x_pos_internal : signed(10 DOWNTO 0) := to_signed(426, 11);
    SIGNAL p2_gap_center_internal : signed(9 DOWNTO 0) := to_signed(360, 10);

    SIGNAL p3_on : std_logic;
    SIGNAL p3_x_pos_internal : signed(10 DOWNTO 0) := to_signed(640, 11);
    SIGNAL p3_gap_center_internal : signed(9 DOWNTO 0) := to_signed(100, 10);

    SIGNAL pipe_x_size : signed(9 DOWNTO 0) := to_signed(30, 10);
    SIGNAL start_move : std_logic := '0';

    SIGNAL random_value : std_logic_vector(9 DOWNTO 0);

    SIGNAL blue_box_on : std_logic;
    SIGNAL blue_box_x_pos_internal : signed(10 DOWNTO 0) := to_signed(1000, 11);
    SIGNAL blue_box_y_pos_internal : signed(9 DOWNTO 0);

    SIGNAL blue_box_size : signed(9 DOWNTO 0) := to_signed(32, 10); -- size of the blue box
	 
	 SIGNAL coin_color : STD_LOGIC_VECTOR(11 DOWNTO 0);
	 SIGNAL coin_address : STD_LOGIC_VECTOR(9 DOWNTO 0);
	 SIGNAL selected_color : STD_LOGIC_VECTOR(11 DOWNTO 0);

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
        clk             :   IN STD_LOGIC;
        coin_address  :   IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        coin_data_out        :   OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
		);
	 END COMPONENT;

BEGIN
    lfsr_inst: galois_lfsr
        PORT MAP (
            clk => clk,
            reset => reset,
            random_value => random_value
        );
		coin_inst: coin_rom
        PORT MAP (
            clk => clk,
            coin_address => coin_address,
            coin_data_out => coin_color
        );

--    p1_on <= '1' WHEN (p1_x_pos_internal + pipe_x_size > to_signed(0, 11) AND
--                       to_integer(unsigned(pixel_column)) >= to_integer(p1_x_pos_internal) AND 
--                       to_integer(unsigned(pixel_column)) < to_integer(p1_x_pos_internal) + to_integer(pipe_x_size) AND
--                       (to_integer(unsigned(pixel_row)) < to_integer(p1_gap_center_internal) - 45 OR 
--                        to_integer(unsigned(pixel_row)) > to_integer(p1_gap_center_internal) + 45))
--                ELSE '0';
--
--    p2_on <= '1' WHEN (p2_x_pos_internal + pipe_x_size > to_signed(0, 11) AND
--                       to_integer(unsigned(pixel_column)) >= to_integer(p2_x_pos_internal) AND 
--                       to_integer(unsigned(pixel_column)) < to_integer(p2_x_pos_internal) + to_integer(pipe_x_size) AND
--                       (to_integer(unsigned(pixel_row)) < to_integer(p2_gap_center_internal) - 45 OR 
--                        to_integer(unsigned(pixel_row)) > to_integer(p2_gap_center_internal) + 45))
--                ELSE '0';
--
--    p3_on <= '1' WHEN (p3_x_pos_internal + pipe_x_size > to_signed(0, 11) AND
--                       to_integer(unsigned(pixel_column)) >= to_integer(p3_x_pos_internal) AND 
--                       to_integer(unsigned(pixel_column)) < to_integer(p3_x_pos_internal) + to_integer(pipe_x_size) AND
--                       (to_integer(unsigned(pixel_row)) < to_integer(p3_gap_center_internal) - 45 OR 
--                        to_integer(unsigned(pixel_row)) > to_integer(p3_gap_center_internal) + 45))
--                ELSE '0';

	Pixel_Display : PROCESS (clk)
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
    END PROCESS Pixel_Display;
	 
	  PROCESS (blue_box_on, coin_color, p1_on, p2_on, p3_on)
    BEGIN
        IF blue_box_on = '1' AND coin_color /= "000100010001" THEN
            selected_color <= coin_color;
        ELSIF p1_on = '1' OR p2_on = '1' OR p3_on = '1' THEN
            selected_color <= "100010001000";
        ELSE
            selected_color <= "000000000000";
        END IF;
    END PROCESS;

    -- RGB and output enable logic
    RGB <= selected_color;

--    RGB <= coin_color WHEN blue_box_on = '1' AND coin_color /= "000100010001" ELSE
--			"100010001000" WHEN (p1_on = '1' OR p2_on = '1' OR p3_on = '1');

    output_on <= '1' WHEN (blue_box_on = '1' OR p1_on = '1' OR p2_on = '1' OR p3_on = '1') ELSE '0';

    Move_pipe: PROCESS (vert_sync, reset, collision, reset_pipes, reset_blue_box)
    BEGIN
        IF rising_edge(vert_sync) THEN
--            IF (pause = '0') THEN
            IF reset_pipes = '1' OR reset_blue_box = '1' THEN
                -- Reset pipes to their original positions
                p1_x_pos_internal <= to_signed(213, 11);
                p1_gap_center_internal <= to_signed(240, 10);
                p2_x_pos_internal <= to_signed(426, 11);
                p2_gap_center_internal <= to_signed(360, 10);
                p3_x_pos_internal <= to_signed(640, 11);
                p3_gap_center_internal <= to_signed(100, 10);
                blue_box_x_pos_internal <= to_signed(600, 11);
					 blue_box_y_pos_internal <= to_signed(240, 10);
--                blue_box_y_pos_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                start_move <= '0';
            ELSIF start = '1' THEN
                IF (p1_x_pos_internal + pipe_x_size <= to_signed(0, 11)) THEN
                    p1_x_pos_internal <= to_signed(640, 11);
                    p1_gap_center_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                ELSE
                    p1_x_pos_internal <= p1_x_pos_internal - to_signed(1, 11);
                END IF;

                IF (p2_x_pos_internal + pipe_x_size <= to_signed(0, 11)) THEN
                    p2_x_pos_internal <= to_signed(640, 11);
                    p2_gap_center_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                ELSE
                    p2_x_pos_internal <= p2_x_pos_internal - to_signed(1, 11);
                END IF;

                IF (p3_x_pos_internal + pipe_x_size <= to_signed(0, 11)) THEN
                    p3_x_pos_internal <= to_signed(640, 11);
                    p3_gap_center_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                ELSE
                    p3_x_pos_internal <= p3_x_pos_internal - to_signed(1, 11);
                END IF;

                -- Move blue box
                IF (blue_box_x_pos_internal + blue_box_size <= to_signed(0, 11)) THEN
							blue_box_x_pos_internal <= to_signed(400, 11);
					 blue_box_y_pos_internal <= to_signed(240, 10);
--                    blue_box_x_pos_internal <= to_signed(1920, 11);
--                    blue_box_y_pos_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                ELSE
                    blue_box_x_pos_internal <= blue_box_x_pos_internal - to_signed(1, 11);
                END IF;
            END IF;
--            END IF;
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

END behavior;

--ENTITY pipes IS
--    PORT
--    (
--        clk, vert_sync, left_click, reset, collision, reset_pipes : IN std_logic;
--        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
--        output_on : OUT std_logic;
--        RGB : OUT std_logic_vector(11 DOWNTO 0);
--        p1_x_pos, p2_x_pos, p3_x_pos : OUT signed(10 DOWNTO 0);
--        p1_y_pos, p2_y_pos, p3_y_pos : OUT signed(10 DOWNTO 0)
--    );		
--END pipes;
--
--ARCHITECTURE behavior OF pipes IS
--    SIGNAL p1_on, p2_on, p3_on : std_logic;
--    SIGNAL p1_x_pos_internal, p2_x_pos_internal, p3_x_pos_internal : signed(10 DOWNTO 0) := to_signed(213, 11);
--    SIGNAL p1_y_pos_internal, p2_y_pos_internal, p3_y_pos_internal : signed(10 DOWNTO 0) := to_signed(-240, 11); -- Start above the screen
--
--    SIGNAL pipe_x_size : signed(9 DOWNTO 0) := to_signed(60, 10);
--    SIGNAL pipe_y_size : signed(10 DOWNTO 0) := to_signed(960, 11);
--    SIGNAL start_move : std_logic := '0';
--    SIGNAL random_value : std_logic_vector(9 DOWNTO 0);
--
--    SIGNAL pipe_address1, pipe_address2, pipe_address3 : std_logic_vector(15 DOWNTO 0);
--    SIGNAL selected_pipe_address : std_logic_vector(15 DOWNTO 0);
--    SIGNAL pipe_data : std_logic_vector(12 DOWNTO 0);
--
--    COMPONENT galois_lfsr
--        PORT
--        (
--            clk : IN std_logic;
--            reset : IN std_logic;
--            random_value : OUT std_logic_vector(9 DOWNTO 0)
--        );
--    END COMPONENT;
--
--    COMPONENT pipe_rom IS
--        PORT
--        (
--            clk             :   IN std_logic;
--            address_out    :   IN std_logic_vector(15 DOWNTO 0);
--            data_out        :   OUT std_logic_vector(12 DOWNTO 0) -- Updated to 12 bits
--        );
--    END COMPONENT pipe_rom;
--
--BEGIN
--    lfsr_inst: galois_lfsr
--        PORT MAP (
--            clk => clk,
--            reset => '0',
--            random_value => random_value
--        );
--
--    pipe_rom_inst : pipe_rom
--        PORT MAP (
--            clk => clk,
--            address_out => selected_pipe_address,
--            data_out => pipe_data
--        );
--
--    Pipe_Display : PROCESS (clk)
--    BEGIN
--        IF rising_edge(clk) THEN
--            -- Determine if pixel is within each pipe
--            IF (signed(pixel_column) >= p1_x_pos_internal AND 
--                signed(pixel_column) < (p1_x_pos_internal + pipe_x_size) AND 
--                signed(pixel_row) >= p1_y_pos_internal AND 
--                signed(pixel_row) < (p1_y_pos_internal + pipe_y_size)) THEN
--					 
--                pipe_address1 <= std_logic_vector(resize(signed(pixel_column) - p1_x_pos_internal, 16) + 
--                    resize((signed(pixel_row) - p1_y_pos_internal) * to_signed(60, 16), 16));
--
--						p1_on <= '1';
--
--            ELSE
--                p1_on <= '0';
--            END IF;
--
--            IF (signed(pixel_column) >= p2_x_pos_internal AND 
--                signed(pixel_column) < (p2_x_pos_internal + pipe_x_size) AND 
--                signed(pixel_row) >= p2_y_pos_internal AND 
--                signed(pixel_row) < (p2_y_pos_internal + pipe_y_size)) THEN
--					 
--					 pipe_address2 <= std_logic_vector(resize(signed(pixel_column) - p2_x_pos_internal, 16) + 
--                    resize((signed(pixel_row) - p2_y_pos_internal) * to_signed(60, 16), 16));
--						p2_on <= '1';
--            ELSE
--                p2_on <= '0';
--            END IF;
--
--            IF (signed(pixel_column) >= p3_x_pos_internal AND 
--                signed(pixel_column) < (p3_x_pos_internal + pipe_x_size) AND 
--                signed(pixel_row) >= p3_y_pos_internal AND 
--                signed(pixel_row) < (p3_y_pos_internal + pipe_y_size)) THEN
--					 
--                pipe_address3 <= std_logic_vector(resize(signed(pixel_column) - p3_x_pos_internal, 16) + 
--                    resize((signed(pixel_row) - p3_y_pos_internal) * to_signed(60, 16), 16));
--						p3_on <= '1';
--            ELSE
--                p3_on <= '0';
--            END IF;
--
--            -- Multiplex the addresses based on which pipe is on
--            IF p1_on = '1' THEN
--                selected_pipe_address <= pipe_address1;
--				END IF;
--            IF p2_on = '1' THEN
--                selected_pipe_address <= pipe_address2;
--				END IF;
--            IF p3_on = '1' THEN
--                selected_pipe_address <= pipe_address3;
--            END IF;
--        END IF;
--    END PROCESS Pipe_Display;
--
--    RGB <= pipe_data(12 DOWNTO 1) WHEN (pipe_data(0) = '1') AND (p1_on = '1' OR p2_on = '1' OR p3_on = '1');
--    output_on <= '1' WHEN (p1_on = '1' OR p2_on = '1' OR p3_on = '1') ELSE '0';
--
--    Move_pipe: PROCESS (vert_sync)
--    BEGIN
--        IF rising_edge(vert_sync) THEN
--            IF reset_pipes = '1' THEN
--                p1_x_pos_internal <= to_signed(213, 11);
--                p1_y_pos_internal <= to_signed(-240, 11);  -- Start above the screen
--                p2_x_pos_internal <= to_signed(426, 11);
--                p2_y_pos_internal <= to_signed(-240, 11);  -- Start above the screen
--                p3_x_pos_internal <= to_signed(640, 11);
--                p3_y_pos_internal <= to_signed(-240, 11);  -- Start above the screen
--                start_move <= '1';
--            ELSIF start_move = '1' THEN
--                IF collision = '1' THEN
--                    start_move <= '0';
--                ELSE
--                    -- Update p1 position
--                    IF (p1_x_pos_internal + pipe_x_size <= to_signed(0, 11)) THEN
--                        p1_x_pos_internal <= to_signed(640, 11);
--                        p1_y_pos_internal <= (signed(random_value) MOD to_signed(310, 11)) + to_signed(55, 11);
--                    ELSE
--                        p1_x_pos_internal <= p1_x_pos_internal - to_signed(1, 11);
--                    END IF;
--
--                    -- Update p2 position
--                    IF (p2_x_pos_internal + pipe_x_size <= to_signed(0, 11)) THEN
--                        p2_x_pos_internal <= to_signed(640, 11);
--                        p2_y_pos_internal <= (signed(random_value) MOD to_signed(310, 11)) + to_signed(55, 11);
--                    ELSE
--                        p2_x_pos_internal <= p2_x_pos_internal - to_signed(1, 11);
--                    END IF;
--
--                    -- Update p3 position
--                    IF (p3_x_pos_internal + pipe_x_size <= to_signed(0, 11)) THEN
--                        p3_x_pos_internal <= to_signed(640, 11);
--                        p3_y_pos_internal <= (signed(random_value) MOD to_signed(310, 11)) + to_signed(55, 11);
--                    ELSE
--                        p3_x_pos_internal <= p3_x_pos_internal - to_signed(1, 11);
--                    END IF;
--                END IF;
--            END IF;
--        END IF;
--    END PROCESS Move_pipe;
--
--    p1_x_pos <= p1_x_pos_internal;
--    p1_y_pos <= p1_y_pos_internal;
--    p2_x_pos <= p2_x_pos_internal;
--    p2_y_pos <= p2_y_pos_internal;
--    p3_x_pos <= p3_x_pos_internal;
--    p3_y_pos <= p3_y_pos_internal;
--
--END behavior;
