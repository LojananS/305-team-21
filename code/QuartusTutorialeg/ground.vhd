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
    -- Ground Characteristics
    SIGNAL ground_on : std_logic;
    SIGNAL ground_x_pos : signed(10 DOWNTO 0) := to_signed(0, 11);
    SIGNAL ground_y_pos : signed(9 DOWNTO 0) := to_signed(420, 10); -- Updated to 400

    -- General Ground Settings
    SIGNAL ground_x_size : signed(9 DOWNTO 0) := to_signed(640, 10); -- Width of the ground
    SIGNAL ground_y_size : signed(9 DOWNTO 0) := to_signed(60, 10); -- Height covering 400 to 480

    SIGNAL start_move : std_logic := '0'; -- ground starts moving when enabled

BEGIN
    -- Combinational logic for ground
    ground_on <= '1' WHEN (unsigned(pixel_column) >= unsigned(ground_x_pos) AND
                           unsigned(pixel_column) < unsigned(ground_x_pos) + unsigned(ground_x_size) AND
                           unsigned(pixel_row) >= unsigned(ground_y_pos) AND
                           unsigned(pixel_row) < unsigned(ground_y_pos) + unsigned(ground_y_size))
                ELSE '0';

    -- Control RGB output and overall output display
    RGB <= "011001100110" WHEN ground_on = '1'; -- "011001100110" dark grey is the color for the ground
    output_on <= '1' WHEN ground_on = '1' ELSE '0';
END behavior;
