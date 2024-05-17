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
        p1_gap_center, p2_gap_center, p3_gap_center : OUT signed(9 DOWNTO 0)
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
            reset => '0',
            random_value => random_value
        );

    p1_on <= '1' WHEN (p1_x_pos_internal + pipe_x_size > to_signed(0, 11) AND
                       to_integer(unsigned(pixel_column)) >= to_integer(p1_x_pos_internal) AND 
                       to_integer(unsigned(pixel_column)) < to_integer(p1_x_pos_internal) + to_integer(pipe_x_size) AND
                       (to_integer(unsigned(pixel_row)) < to_integer(p1_gap_center_internal) - 45 OR 
                        to_integer(unsigned(pixel_row)) > to_integer(p1_gap_center_internal) + 45))
                ELSE '0';

    p2_on <= '1' WHEN (p2_x_pos_internal + pipe_x_size > to_signed(0, 11) AND
                       to_integer(unsigned(pixel_column)) >= to_integer(p2_x_pos_internal) AND 
                       to_integer(unsigned(pixel_column)) < to_integer(p2_x_pos_internal) + to_integer(pipe_x_size) AND
                       (to_integer(unsigned(pixel_row)) < to_integer(p2_gap_center_internal) - 45 OR 
                        to_integer(unsigned(pixel_row)) > to_integer(p2_gap_center_internal) + 45))
                ELSE '0';

    p3_on <= '1' WHEN (p3_x_pos_internal + pipe_x_size > to_signed(0, 11) AND
                       to_integer(unsigned(pixel_column)) >= to_integer(p3_x_pos_internal) AND 
                       to_integer(unsigned(pixel_column)) < to_integer(p3_x_pos_internal) + to_integer(pipe_x_size) AND
                       (to_integer(unsigned(pixel_row)) < to_integer(p3_gap_center_internal) - 45 OR 
                        to_integer(unsigned(pixel_row)) > to_integer(p3_gap_center_internal) + 45))
                ELSE '0';

    RGB <= "100010001000" WHEN (p1_on = '1' OR p2_on = '1' OR p3_on = '1');
    output_on <= '1' WHEN (p1_on = '1' OR p2_on = '1' OR p3_on = '1') ELSE '0';

    Move_pipe: PROCESS (vert_sync, left_click, reset, collision, reset_pipes)
    BEGIN
        IF rising_edge(vert_sync) THEN
            IF left_click = '1' AND start_move = '0' THEN
                start_move <= '1';
            END IF;

            IF reset_pipes = '1' THEN
                -- Reset pipes to their original positions
                p1_x_pos_internal <= to_signed(213, 11);
                p1_gap_center_internal <= to_signed(240, 10);
                p2_x_pos_internal <= to_signed(426, 11);
                p2_gap_center_internal <= to_signed(360, 10);
                p3_x_pos_internal <= to_signed(640, 11);
                p3_gap_center_internal <= to_signed(100, 10);
            ELSIF start_move = '1' THEN
                IF collision = '1' THEN
                    start_move <= '0'; -- Stop pipes movement on collision
                ELSE
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
                END IF;
            END IF;
        END IF;
    END PROCESS Move_pipe;

    p1_x_pos <= p1_x_pos_internal;
    p1_gap_center <= p1_gap_center_internal;
    p2_x_pos <= p2_x_pos_internal;
    p2_gap_center <= p2_gap_center_internal;
    p3_x_pos <= p3_x_pos_internal;
    p3_gap_center <= p3_gap_center_internal;

END behavior;
