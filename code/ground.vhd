LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

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
        clk             :   IN STD_LOGIC;
        floor_address  :   IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        data_out        :   OUT STD_LOGIC_VECTOR(11 DOWNTO 0) -- Set to 12 bits color depth
    );
    END COMPONENT;
    
    -- Ground Characteristics
    SIGNAL ground_on : std_logic;
    SIGNAL ground_x_pos : signed(10 DOWNTO 0) := to_signed(0, 11);
    SIGNAL ground_y_pos : signed(9 DOWNTO 0) := to_signed(420, 10);

    -- General Ground Settings
    SIGNAL ground_x_size : signed(9 DOWNTO 0) := to_signed(640, 10); -- Width of the ground
    SIGNAL ground_y_size : signed(9 DOWNTO 0) := to_signed(60, 10); -- Height covering 420 to 480
     
    SIGNAL ground_address : std_logic_vector(15 DOWNTO 0);
    SIGNAL ground_data : std_logic_vector(11 DOWNTO 0);

BEGIN

    floor_rom_inst : floor_rom
        PORT MAP (
            clk => clk,
            floor_address => ground_address,
            data_out => ground_data
        );

    -- Combinational logic for ground display
    Ground_Display : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (unsigned(pixel_column) >= unsigned(ground_x_pos) AND
                unsigned(pixel_column) < unsigned(ground_x_pos) + unsigned(ground_x_size) AND
                unsigned(pixel_row) >= unsigned(ground_y_pos) AND
                unsigned(pixel_row) < unsigned(ground_y_pos) + unsigned(ground_y_size)) THEN
                ground_on <= '1';
                ground_address <= std_logic_vector(to_unsigned(
                    (to_integer(unsigned(pixel_row)) - to_integer(unsigned(ground_y_pos))) * 640 +
                    (to_integer(unsigned(pixel_column)) - to_integer(unsigned(ground_x_pos))), 16));
            ELSE
                ground_on <= '0';
            END IF;
        END IF;
    END PROCESS Ground_Display;

    -- Control RGB output and overall output display
    RGB <= ground_data WHEN ground_on = '1' ELSE (others => '0');
    output_on <= ground_on;
END behavior;
