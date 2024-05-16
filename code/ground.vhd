LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ground IS
    PORT
    (
        clk, vert_sync : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        output_on : OUT std_logic;
        RGB : OUT std_logic_vector(11 DOWNTO 0)
    );
END ground;

ARCHITECTURE behavior OF ground IS
    COMPONENT floor_rom IS
        PORT
        (
            clk            : IN STD_LOGIC;
            floor_address  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            data_out       : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

    -- Ground segment characteristics
    SIGNAL ground_y_pos : signed(9 DOWNTO 0) := to_signed(420, 10);
    SIGNAL ground_y_size : signed(9 DOWNTO 0) := to_signed(60, 10);

    TYPE ground_type IS ARRAY (0 TO 3) OF signed(10 DOWNTO 0);
    SIGNAL ground_x_pos : ground_type := (to_signed(0, 11), to_signed(213, 11), to_signed(426, 11), to_signed(640, 11));
    SIGNAL ground_on : std_logic_vector(3 DOWNTO 0);

    SIGNAL ground_address : std_logic_vector(15 DOWNTO 0);
    SIGNAL ground_data : std_logic_vector(11 DOWNTO 0);

BEGIN
    floor_rom_inst : floor_rom
        PORT MAP (
            clk => clk,
            floor_address => ground_address,
            data_out => ground_data
        );

    -- Combinational logic for ground display for each segment
    Ground_Display : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            ground_on <= (others => '0');
            FOR i IN 0 TO 3 LOOP
                IF (to_integer(unsigned(pixel_column)) >= to_integer(ground_x_pos(i)) AND
                    to_integer(unsigned(pixel_column)) < to_integer(ground_x_pos(i)) + 213 AND
                    to_integer(unsigned(pixel_row)) >= to_integer(ground_y_pos) AND
                    to_integer(unsigned(pixel_row)) < to_integer(ground_y_pos + ground_y_size)) THEN
                    ground_on(i) <= '1';
                    ground_address <= std_logic_vector(to_unsigned(
                        ((to_integer(unsigned(pixel_row)) - to_integer(unsigned(ground_y_pos))) * 640) +
                        (to_integer(unsigned(pixel_column)) - to_integer(ground_x_pos(i))), 16));
                END IF;
            END LOOP;
        END IF;
    END PROCESS Ground_Display;
	 
    -- Control RGB output and overall output display
    RGB <= ground_data WHEN (ground_on /= "0000") ELSE (others => '0');
    output_on <= '1' when ground_on > "0000" else '0';


    -- Process to Move ground segments continuously
    Move_ground: PROCESS (vert_sync)
    BEGIN
        IF rising_edge(vert_sync) THEN
            FOR i IN 0 TO 3 LOOP
                ground_x_pos(i) <= ground_x_pos(i) - to_signed(1, 11);
                -- Check and reset position
                IF ground_x_pos(i) < -to_signed(213, 11) THEN
                    ground_x_pos(i) <= to_signed(640, 11);
                END IF;
            END LOOP;
        END IF;
    END PROCESS Move_ground;

END behavior;
