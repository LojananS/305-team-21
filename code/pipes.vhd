LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pipes IS
    PORT
    (
        clk, vert_sync, left_click, reset: IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        output_on : OUT std_logic;
        RGB : OUT std_logic_vector(11 DOWNTO 0)
    );		
END pipes;

ARCHITECTURE behavior OF pipes IS
    -- Pipe 1 Characteristics
    SIGNAL p1_on : std_logic;
    SIGNAL p1_x_pos : signed(10 DOWNTO 0) := to_signed(213, 11); 
    SIGNAL p1_gap_center : signed(9 DOWNTO 0) := to_signed(240, 10);

    -- Pipe 2 Characteristics
    SIGNAL p2_on : std_logic;
    SIGNAL p2_x_pos : signed(10 DOWNTO 0) := to_signed(426, 11);
    SIGNAL p2_gap_center : signed(9 DOWNTO 0) := to_signed(360, 10);

    -- Pipe 3 Characteristics
    SIGNAL p3_on : std_logic;
    SIGNAL p3_x_pos : signed(10 DOWNTO 0) := to_signed(640, 11);
    SIGNAL p3_gap_center : signed(9 DOWNTO 0) := to_signed(100, 10);

    -- General Pipe Settings
    SIGNAL size : signed(9 DOWNTO 0);
    SIGNAL pipe_x_motion : signed(10 DOWNTO 0);
    SIGNAL pipe_x_size : signed(9 DOWNTO 0) := to_signed(30, 10);

    SIGNAL start_move : std_logic := '0'; -- Pipe starts moving when enabled

    -- LFSR Signal
    SIGNAL random_value : std_logic_vector(9 DOWNTO 0);
	 SIGNAL start_up : std_logic := '1';

    COMPONENT galois_lfsr
        PORT
        (
            clk : IN std_logic;
            reset : IN std_logic;
            random_value : OUT std_logic_vector(9 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    -- Instantiate the LFSR
    lfsr_inst: galois_lfsr
        PORT MAP (
            clk => clk,
            reset => '0',
            random_value => random_value
        );

    -- Combinational logic for Pipe 1
    p1_on <= '1' WHEN (p1_x_pos + pipe_x_size > to_signed(0, 11) AND
                       to_integer(unsigned(pixel_column)) >= to_integer(p1_x_pos) AND 
                       to_integer(unsigned(pixel_column)) < to_integer(p1_x_pos) + to_integer(pipe_x_size) AND
                       (to_integer(unsigned(pixel_row)) < to_integer(p1_gap_center) - 45 OR 
                        to_integer(unsigned(pixel_row)) > to_integer(p1_gap_center) + 45))
                ELSE '0';

    -- Combinational logic for Pipe 2
    p2_on <= '1' WHEN (p2_x_pos + pipe_x_size > to_signed(0, 11) AND
                       to_integer(unsigned(pixel_column)) >= to_integer(p2_x_pos) AND 
                       to_integer(unsigned(pixel_column)) < to_integer(p2_x_pos) + to_integer(pipe_x_size) AND
                       (to_integer(unsigned(pixel_row)) < to_integer(p2_gap_center) - 45 OR 
                        to_integer(unsigned(pixel_row)) > to_integer(p2_gap_center) + 45))
                ELSE '0';

    -- Combinational logic for Pipe 3
    p3_on <= '1' WHEN (p3_x_pos + pipe_x_size > to_signed(0, 11) AND
                       to_integer(unsigned(pixel_column)) >= to_integer(p3_x_pos) AND 
                       to_integer(unsigned(pixel_column)) < to_integer(p3_x_pos) + to_integer(pipe_x_size) AND
                       (to_integer(unsigned(pixel_row)) < to_integer(p3_gap_center) - 45 OR 
                        to_integer(unsigned(pixel_row)) > to_integer(p3_gap_center) + 45))
                ELSE '0';

    -- Control RGB output and overall output display
    RGB <= "100010001000" WHEN (p1_on = '1' OR p2_on = '1' OR p3_on = '1'); -- "100010001000" grey is the color for the pipes
    output_on <= '1' WHEN (p1_on = '1' OR p2_on = '1' OR p3_on = '1') ELSE '0';
	
	Move_pipe: PROCESS (vert_sync, left_click, reset)
    BEGIN
        -- Randomize the gap center on reset
        IF rising_edge(vert_sync) THEN
            -- Start the movement
            IF left_click = '1' AND start_move = '0' THEN
                start_move <= '1';
            END IF;

            -- Proceeds with the game
            IF start_move = '1' THEN
                -- Checks if the entire pipe has left the screen for Pipe 1
                IF (p1_x_pos + pipe_x_size <= to_signed(0, 11)) THEN  -- Ensuring the entire pipe is off-screen
                    p1_x_pos <= to_signed(640, 11); -- Reset position to the right side of the screen
                    p1_gap_center <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10); -- New random gap center
                ELSE
                    p1_x_pos <= p1_x_pos - to_signed(1, 11); -- Move the pipe left
                END IF;

                -- Checks if the entire pipe has left the screen for Pipe 2
                IF (p2_x_pos + pipe_x_size <= to_signed(0, 11)) THEN  -- Ensuring the entire pipe is off-screen
                    p2_x_pos <= to_signed(640, 11); -- Reset position to the right side of the screen
                    p2_gap_center <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10); -- New random gap center
                ELSE
                    p2_x_pos <= p2_x_pos - to_signed(1, 11); -- Move the pipe left
                END IF;

                -- Checks if the entire pipe has left the screen for Pipe 3
                IF (p3_x_pos + pipe_x_size <= to_signed(0, 11)) THEN  -- Ensuring the entire pipe is off-screen
                    p3_x_pos <= to_signed(640, 11); -- Reset position to the right side of the screen
                    p3_gap_center <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10); -- New random gap center
                ELSE
                    p3_x_pos <= p3_x_pos - to_signed(1, 11); -- Move the pipe left
                END IF;
            END IF;
        END IF;
    END PROCESS Move_pipe;

END behavior;
