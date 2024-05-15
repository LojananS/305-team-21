LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY text_rom IS 
    PORT (
        character_address : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        pixel_row, pixel_col : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        clk : IN STD_LOGIC;
        output : OUT STD_LOGIC
    );
END text_rom;

ARCHITECTURE beh OF text_rom IS
    SIGNAL fr, fc : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL char_address : STD_LOGIC_VECTOR(5 DOWNTO 0);

    COMPONENT char_rom
        PORT (
            character_address : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
            font_row, font_col : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            clock: IN STD_LOGIC;
            rom_mux_output : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN 
    -- Instantiate char_rom
    char_rom_inst : char_rom 
        PORT MAP (
            character_address => char_address, 
            font_row => fr,
            font_col => fc, 
            clock => clk, 
            rom_mux_output => output
        );

    -- Process for setting character address and font row/column
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (to_integer(unsigned(pixel_row)) > 16 AND to_integer(unsigned(pixel_row)) < 32 AND 
                to_integer(unsigned(pixel_col)) > 0 AND to_integer(unsigned(pixel_col)) < 16) THEN
                char_address <= "011001"; -- ASCII for 'Y'
                fc <= pixel_col(3 DOWNTO 1);
                fr <= pixel_row(3 DOWNTO 1);
            ELSif (to_integer(unsigned(pixel_row)) > 16 AND to_integer(unsigned(pixel_row)) < 32 AND 
                to_integer(unsigned(pixel_col)) > 16 AND to_integer(unsigned(pixel_col)) < 32) THEN
                char_address <= "000101"; -- ASCII for 'E'
                fc <= pixel_col(3 DOWNTO 1);
                fr <= pixel_row(3 DOWNTO 1);
				ELSif (to_integer(unsigned(pixel_row)) > 16 AND to_integer(unsigned(pixel_row)) < 32 AND 
                to_integer(unsigned(pixel_col)) > 32 AND to_integer(unsigned(pixel_col)) < 48) THEN
                char_address <= "001010"; -- ASCII for 'J'
                fc <= pixel_col(3 DOWNTO 1);
                fr <= pixel_row(3 DOWNTO 1);
				ELSif (to_integer(unsigned(pixel_row)) > 16 AND to_integer(unsigned(pixel_row)) < 32 AND 
                to_integer(unsigned(pixel_col)) > 48 AND to_integer(unsigned(pixel_col)) < 64) THEN
                char_address <= "001001"; -- ASCII for 'I'
                fc <= pixel_col(3 DOWNTO 1);
                fr <= pixel_row(3 DOWNTO 1);
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE beh;
