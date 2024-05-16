LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY text_rom IS 
    PORT (
        character_address : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        pixel_row, pixel_col : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        clk, start : IN STD_LOGIC;
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

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            -- Display "YEJI"
            IF (to_integer(unsigned(pixel_row)) >= 15 AND to_integer(unsigned(pixel_row)) < 24) THEN
                IF (to_integer(unsigned(pixel_col)) >= 0 AND to_integer(unsigned(pixel_col)) < 8) THEN
                    char_address <= "011001"; -- ASCII for 'Y'
						  fc <= pixel_col(2 DOWNTO 0);
						  fr <= pixel_row(2 DOWNTO 0);
                ELSIF (to_integer(unsigned(pixel_col)) >= 8 AND to_integer(unsigned(pixel_col)) < 16) THEN
                    char_address <= "000101"; -- ASCII for 'E'
						  fc <= pixel_col(2 DOWNTO 0);
						  fr <= pixel_row(2 DOWNTO 0);
                ELSIF (to_integer(unsigned(pixel_col)) >= 16 AND to_integer(unsigned(pixel_col)) < 24) THEN
                    char_address <= "001010"; -- ASCII for 'J'
						  fc <= pixel_col(2 DOWNTO 0);
						  fr <= pixel_row(2 DOWNTO 0);
                ELSIF (to_integer(unsigned(pixel_col)) >= 24 AND to_integer(unsigned(pixel_col)) < 32) THEN
                    char_address <= "001001"; -- ASCII for 'I'
						  fc <= pixel_col(2 DOWNTO 0);
						  fr <= pixel_row(2 DOWNTO 0);
                END IF;
            END IF;

            IF (start = '0') THEN
                -- Display "FLAPPY BIRD"
                IF (to_integer(unsigned(pixel_row)) >= 95 AND to_integer(unsigned(pixel_row)) < 112) THEN
                    IF (to_integer(unsigned(pixel_col)) >= 272 AND to_integer(unsigned(pixel_col)) < 288) THEN
                        char_address <= "000110"; -- ASCII for 'F'
								fc <= pixel_col(3 DOWNTO 1);
								fr <= pixel_row(3 DOWNTO 1);
                    ELSIF (to_integer(unsigned(pixel_col)) >= 288 AND to_integer(unsigned(pixel_col)) < 304) THEN
                        char_address <= "001100"; -- ASCII for 'L'
								fc <= pixel_col(3 DOWNTO 1);
								fr <= pixel_row(3 DOWNTO 1);
                    ELSIF (to_integer(unsigned(pixel_col)) >= 304 AND to_integer(unsigned(pixel_col)) < 320) THEN
                        char_address <= "000001"; -- ASCII for 'A'
								fc <= pixel_col(3 DOWNTO 1);
								fr <= pixel_row(3 DOWNTO 1);
                    ELSIF (to_integer(unsigned(pixel_col)) >= 320 AND to_integer(unsigned(pixel_col)) < 336) THEN
                        char_address <= "010000"; -- ASCII for 'P'
								fc <= pixel_col(3 DOWNTO 1);
								fr <= pixel_row(3 DOWNTO 1);
                    ELSIF (to_integer(unsigned(pixel_col)) >= 336 AND to_integer(unsigned(pixel_col)) < 352) THEN
                        char_address <= "010000"; -- ASCII for 'P'
								fc <= pixel_col(3 DOWNTO 1);
								fr <= pixel_row(3 DOWNTO 1);
                    ELSIF (to_integer(unsigned(pixel_col)) >= 352 AND to_integer(unsigned(pixel_col)) < 368) THEN
                        char_address <= "011001"; -- ASCII for 'Y'
								fc <= pixel_col(3 DOWNTO 1);
								fr <= pixel_row(3 DOWNTO 1);
                    END IF;
                    
                ELSIF (to_integer(unsigned(pixel_row)) >= 112 AND to_integer(unsigned(pixel_row)) < 128) THEN
                    IF (to_integer(unsigned(pixel_col)) >= 288 AND to_integer(unsigned(pixel_col)) < 304) THEN
                        char_address <= "000010"; -- ASCII for 'B'
								fc <= pixel_col(3 DOWNTO 1);
								fr <= pixel_row(3 DOWNTO 1);
                    ELSIF (to_integer(unsigned(pixel_col)) >= 304 AND to_integer(unsigned(pixel_col)) < 320) THEN
                        char_address <= "001001"; -- ASCII for 'I'
								fc <= pixel_col(3 DOWNTO 1);
								fr <= pixel_row(3 DOWNTO 1);
                    ELSIF (to_integer(unsigned(pixel_col)) >= 320 AND to_integer(unsigned(pixel_col)) < 336) THEN
                        char_address <= "010010"; -- ASCII for 'R'
								fc <= pixel_col(3 DOWNTO 1);
								fr <= pixel_row(3 DOWNTO 1);
                    ELSIF (to_integer(unsigned(pixel_col)) >= 336 AND to_integer(unsigned(pixel_col)) < 352) THEN
                        char_address <= "000100"; -- ASCII for 'D'
								fc <= pixel_col(3 DOWNTO 1);
								fr <= pixel_row(3 DOWNTO 1);
                    END IF;
                END IF;
				ELSIF (start = '1') THEN
					IF ((to_integer(unsigned(pixel_row))) >= 80 AND (to_integer(unsigned(pixel_row)) < 96 
							AND (to_integer(unsigned(pixel_col))) >= 304 AND (to_integer(unsigned(pixel_col)) < 320))) THEN
							char_address <= "110000"; -- "0"
							fc <= pixel_col(3 DOWNTO 1);
							fr <= pixel_row(3 DOWNTO 1);
					END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE beh;
