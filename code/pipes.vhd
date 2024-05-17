LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pipes IS
    PORT
    (
        clk, vert_sync, left_click, reset, collision, reset_pipes : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        output_on : OUT std_logic;
        RGB : OUT std_logic_vector(11 DOWNTO 0);
        p1_x_pos, p2_x_pos, p3_x_pos : OUT signed(10 DOWNTO 0);
        p1_y_pos, p2_y_pos, p3_y_pos : OUT signed(9 DOWNTO 0)
    );		
END pipes;

ARCHITECTURE behavior OF pipes IS
    SIGNAL p1_on : std_logic;
    SIGNAL p1_x_pos_internal : signed(10 DOWNTO 0) := to_signed(213, 11);
    SIGNAL p1_y_pos_internal : signed(9 DOWNTO 0) := to_signed(240, 10);

    SIGNAL p2_on : std_logic;
    SIGNAL p2_x_pos_internal : signed(10 DOWNTO 0) := to_signed(426, 11);
    SIGNAL p2_y_pos_internal : signed(9 DOWNTO 0) := to_signed(360, 10);

    SIGNAL p3_on : std_logic;
    SIGNAL p3_x_pos_internal : signed(10 DOWNTO 0) := to_signed(640, 11);
    SIGNAL p3_y_pos_internal : signed(9 DOWNTO 0) := to_signed(100, 10);

    SIGNAL pipe_x_size : signed(9 DOWNTO 0) := to_signed(30, 10); -- Updated to 30 pixels width
    SIGNAL start_move : std_logic := '0';

    SIGNAL random_value : std_logic_vector(9 DOWNTO 0);
	 
    SIGNAL pipe_address : std_logic_vector(15 DOWNTO 0);
    SIGNAL pipe_data : std_logic_vector(12 DOWNTO 0);

    COMPONENT galois_lfsr
        PORT
        (
            clk : IN std_logic;
            reset : IN std_logic;
            random_value : OUT std_logic_vector(9 DOWNTO 0)
        );
    END COMPONENT;
	 
    COMPONENT pipe_rom IS
    PORT
    (
        clk             :   IN STD_LOGIC;
        pipe_address    :   IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        data_out        :   OUT STD_LOGIC_VECTOR(12 DOWNTO 0) -- 13 bits: 12-bit RGB + 1-bit transparency
    );
    END COMPONENT pipe_rom;

BEGIN
    lfsr_inst: galois_lfsr
        PORT MAP (
            clk => clk,
            reset => '0',
            random_value => random_value
        );

    pipe_rom_inst : pipe_rom
        PORT MAP (
            clk => clk,
            pipe_address => pipe_address,
            data_out => pipe_data
        );

    Pipe_Display : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            -- Check for pipe 1
            IF (pixel_column >= std_logic_vector(signed(p1_x_pos_internal)) AND 
                pixel_column < std_logic_vector(signed(p1_x_pos_internal) + pipe_x_size) AND
                pixel_row >= std_logic_vector(signed(p1_y_pos_internal)) AND
                pixel_row < std_logic_vector(signed(p1_y_pos_internal) + to_signed(240, 10))) THEN
                pipe_address <= std_logic_vector(to_unsigned(
                    (to_integer(signed(pixel_row)) - to_integer(p1_y_pos_internal)) * 30 + 
                    (to_integer(signed(pixel_column)) - to_integer(p1_x_pos_internal)), 16));
                IF pipe_data(0) = '1' THEN
                    p1_on <= '1';
                ELSE
                    p1_on <= '0';
                END IF;
            ELSE
                p1_on <= '0';
            END IF;

            -- Check for pipe 2
            IF (pixel_column >= std_logic_vector(signed(p2_x_pos_internal)) AND 
                pixel_column < std_logic_vector(signed(p2_x_pos_internal) + pipe_x_size) AND
                pixel_row >= std_logic_vector(signed(p2_y_pos_internal)) AND
                pixel_row < std_logic_vector(signed(p2_y_pos_internal) + to_signed(240, 10))) THEN
                pipe_address <= std_logic_vector(to_unsigned(
                    (to_integer(signed(pixel_row)) - to_integer(p2_y_pos_internal)) * 60 + 
                    (to_integer(signed(pixel_column)) - to_integer(p2_x_pos_internal)), 16));
                IF pipe_data(0) = '1' THEN
                    p2_on <= '1';
                ELSE
                    p2_on <= '0';
                END IF;
            ELSE
                p2_on <= '0';
            END IF;

            -- Check for pipe 3
            IF (pixel_column >= std_logic_vector(signed(p3_x_pos_internal)) AND 
                pixel_column < std_logic_vector(signed(p3_x_pos_internal) + pipe_x_size) AND
                pixel_row >= std_logic_vector(signed(p3_y_pos_internal)) AND
                pixel_row < std_logic_vector(signed(p3_y_pos_internal) + to_signed(240, 10))) THEN
                pipe_address <= std_logic_vector(to_unsigned(
                    (to_integer(signed(pixel_row)) - to_integer(p3_y_pos_internal)) * 120 + 
                    (to_integer(signed(pixel_column)) - to_integer(p3_x_pos_internal)), 16));
                IF pipe_data(0) = '1' THEN
                    p3_on <= '1';
                ELSE
                    p3_on <= '0';
                END IF;
            ELSE
                p3_on <= '0';
            END IF;
        END IF;
    END PROCESS Pipe_Display;

    RGB <= pipe_data(12 DOWNTO 1) WHEN (p1_on = '1' OR p2_on = '1' OR p3_on = '1');
    output_on <= '1' WHEN (p1_on = '1' OR p2_on = '1' OR p3_on = '1') ELSE '0';

    Move_pipe: PROCESS (vert_sync, left_click, reset, collision, reset_pipes)
    BEGIN
        IF rising_edge(vert_sync) THEN
            IF left_click = '1' AND start_move = '0' THEN
                start_move <= '1';
            END IF;

            IF reset_pipes = '1' AND start_move = '1' THEN
                -- Reset pipes to their original positions
                p1_x_pos_internal <= to_signed(213, 11);
                p1_y_pos_internal <= to_signed(240, 10);
                p2_x_pos_internal <= to_signed(426, 11);
                p2_y_pos_internal <= to_signed(360, 10);
                p3_x_pos_internal <= to_signed(640, 11);
                p3_y_pos_internal <= to_signed(100, 10);
                start_move <= '1'; -- Restart pipes movement
            ELSIF start_move = '1' THEN
                IF collision = '1' THEN
                    start_move <= '0'; -- Stop pipes movement on collision
                ELSE
                    IF (p1_x_pos_internal + pipe_x_size <= to_signed(0, 11)) THEN
                        p1_x_pos_internal <= to_signed(640, 11);
                        p1_y_pos_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                    ELSE
                        p1_x_pos_internal <= p1_x_pos_internal - to_signed(1, 11);
                    END IF;

                    IF (p2_x_pos_internal + pipe_x_size <= to_signed(0, 11)) THEN
                        p2_x_pos_internal <= to_signed(640, 11);
                        p2_y_pos_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                    ELSE
                        p2_x_pos_internal <= p2_x_pos_internal - to_signed(1, 11);
                    END IF;

                    IF (p3_x_pos_internal + pipe_x_size <= to_signed(0, 11)) THEN
                        p3_x_pos_internal <= to_signed(640, 11);
                        p3_y_pos_internal <= (signed(random_value) MOD to_signed(310, 10)) + to_signed(55, 10);
                    ELSE
                        p3_x_pos_internal <= p3_x_pos_internal - to_signed(1, 11);
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS Move_pipe;

    p1_x_pos <= p1_x_pos_internal;
    p1_y_pos <= p1_y_pos_internal;
    p2_x_pos <= p2_x_pos_internal;
    p2_y_pos <= p2_y_pos_internal;
    p3_x_pos <= p3_x_pos_internal;
    p3_y_pos <= p3_y_pos_internal;

END behavior;
