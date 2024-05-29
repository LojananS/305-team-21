LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.game_type_pkg.ALL;

ENTITY text_rom IS 
    PORT (
        character_address : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        pixel_row, pixel_col : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        clk: IN STD_LOGIC;
		  life: in integer range 0 to 3;
        score : IN integer range 0 to 999;
		  input_state: IN std_logic_vector(3 downto 0);
        output : OUT STD_LOGIC
    );
END text_rom;

ARCHITECTURE beh OF text_rom IS
    SIGNAL fr, fc : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL char_address : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL hunds_digit, tens_digit, units_digit: INTEGER RANGE 0 TO 9;

    COMPONENT char_rom
        PORT (
            character_address : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
            font_row, font_col : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            clock: IN STD_LOGIC;
            rom_mux_output : OUT STD_LOGIC
        );
    END COMPONENT;

    FUNCTION int_to_char (digit: INTEGER) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE digit IS
            WHEN 0 => RETURN "110000"; -- '0'
            WHEN 1 => RETURN "110001"; -- '1'
            WHEN 2 => RETURN "110010"; -- '2'
            WHEN 3 => RETURN "110011"; -- '3'
            WHEN 4 => RETURN "110100"; -- '4'
            WHEN 5 => RETURN "110101"; -- '5'
            WHEN 6 => RETURN "110110"; -- '6'
            WHEN 7 => RETURN "110111"; -- '7'
            WHEN 8 => RETURN "111000"; -- '8'
            WHEN 9 => RETURN "111001"; -- '9'
            WHEN OTHERS => RETURN "110000"; -- default to '0'
        END CASE;
    END FUNCTION;
	 
FUNCTION str_to_char (letter: string) RETURN STD_LOGIC_VECTOR IS
BEGIN
    CASE letter IS
			WHEN "A" => RETURN "000001"; -- 'a'
			WHEN "B" => RETURN "000010"; -- 'b'
			WHEN "C" => RETURN "000011"; -- 'c'
			WHEN "D" => RETURN "000100"; -- 'd'
			WHEN "E" => RETURN "000101"; -- 'e'
			WHEN "F" => RETURN "000110"; -- 'f'
			WHEN "G" => RETURN "000111"; -- 'g'
			WHEN "H" => RETURN "001000"; -- 'h'
			WHEN "I" => RETURN "001001"; -- 'i'
			WHEN "J" => RETURN "001010"; -- 'j'
			WHEN "K" => RETURN "001011"; -- 'k'
			WHEN "L" => RETURN "001100"; -- 'l'
			WHEN "M" => RETURN "001101"; -- 'm'
			WHEN "N" => RETURN "001110"; -- 'n'
			WHEN "O" => RETURN "001111"; -- 'o'
			WHEN "P" => RETURN "010000"; -- 'p'
			WHEN "Q" => RETURN "010001"; -- 'q'
			WHEN "R" => RETURN "010010"; -- 'r'
			WHEN "S" => RETURN "010011"; -- 's'
			WHEN "T" => RETURN "010100"; -- 't'
			WHEN "U" => RETURN "010101"; -- 'u'
			WHEN "V" => RETURN "010110"; -- 'v'
			WHEN "W" => RETURN "010111"; -- 'w'
			WHEN "X" => RETURN "011000"; -- 'x'
			WHEN "Y" => RETURN "011001"; -- 'y'
			WHEN "Z" => RETURN "011010"; -- 'z'
			WHEN "0" => RETURN "110000"; -- '0'
			WHEN "1" => RETURN "110001"; -- '1'
			WHEN "2" => RETURN "110010"; -- '2'
			WHEN "3" => RETURN "110011"; -- '3'
			WHEN "4" => RETURN "110100"; -- '4'
			WHEN "5" => RETURN "110101"; -- '5'
			WHEN "6" => RETURN "110110"; -- '6'
			WHEN "7" => RETURN "110111"; -- '7'
			WHEN "8" => RETURN "111000"; -- '8'
			WHEN "9" => RETURN "111001"; -- '9'
			WHEN ":" => return "100010"; -- ':'
		  WHEN OTHERS => RETURN "100000"; -- default to ' '
    END CASE;
END FUNCTION;


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
	 variable game_state : state_type;
    BEGIN
		IF rising_edge(clk) THEN
			game_state := to_state_type(input_state);
			-- Display "YEJI"
			IF (to_integer(unsigned(pixel_row)) >= 15 AND to_integer(unsigned(pixel_row)) < 24) THEN
				IF (to_integer(unsigned(pixel_col)) >= 0 AND to_integer(unsigned(pixel_col)) < 8) THEN
					 char_address <= str_to_char("Y"); -- ASCII for 'Y'
					 fc <= pixel_col(2 DOWNTO 0);
					 fr <= pixel_row(2 DOWNTO 0);
				ELSIF (to_integer(unsigned(pixel_col)) >= 8 AND to_integer(unsigned(pixel_col)) < 16) THEN
					 char_address <= str_to_char("E"); -- ASCII for 'E'
					 fc <= pixel_col(2 DOWNTO 0);
					 fr <= pixel_row(2 DOWNTO 0);
				ELSIF (to_integer(unsigned(pixel_col)) >= 16 AND to_integer(unsigned(pixel_col)) < 24) THEN
					 char_address <= str_to_char("J"); -- ASCII for 'J'
					 fc <= pixel_col(2 DOWNTO 0);
					 fr <= pixel_row(2 DOWNTO 0);
				ELSIF (to_integer(unsigned(pixel_col)) >= 24 AND to_integer(unsigned(pixel_col)) < 32) THEN
					 char_address <= str_to_char("I"); -- ASCII for 'I'
					 fc <= pixel_col(2 DOWNTO 0);
					 fr <= pixel_row(2 DOWNTO 0);
				END IF;
			END IF;

			IF game_state = HOME THEN
				 -- Display "FLAPPY BIRD"
				 IF (to_integer(unsigned(pixel_row)) >= 95 AND to_integer(unsigned(pixel_row)) < 112) THEN
					 IF (to_integer(unsigned(pixel_col)) >= 272 AND to_integer(unsigned(pixel_col)) < 288) THEN
						  char_address <= str_to_char("F"); -- ASCII for 'F'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 288 AND to_integer(unsigned(pixel_col)) < 304) THEN
						  char_address <= str_to_char("L"); -- ASCII for 'L'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 304 AND to_integer(unsigned(pixel_col)) < 320) THEN
						  char_address <= str_to_char("A"); -- ASCII for 'A'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 320 AND to_integer(unsigned(pixel_col)) < 336) THEN
						  char_address <= str_to_char("P"); -- ASCII for 'P'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 336 AND to_integer(unsigned(pixel_col)) < 352) THEN
						  char_address <= str_to_char("P"); -- ASCII for 'P'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 352 AND to_integer(unsigned(pixel_col)) < 368) THEN
						  char_address <= str_to_char("Y"); -- ASCII for 'Y'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 END IF;
				 ELSIF (to_integer(unsigned(pixel_row)) >= 112 AND to_integer(unsigned(pixel_row)) < 128) THEN
					 IF (to_integer(unsigned(pixel_col)) >= 288 AND to_integer(unsigned(pixel_col)) < 304) THEN
						  char_address <= str_to_char("B"); -- ASCII for 'B'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 304 AND to_integer(unsigned(pixel_col)) < 320) THEN
						  char_address <= str_to_char("I"); -- ASCII for 'I'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 320 AND to_integer(unsigned(pixel_col)) < 336) THEN
						  char_address <= str_to_char("R"); -- ASCII for 'R'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 336 AND to_integer(unsigned(pixel_col)) < 352) THEN
						  char_address <= str_to_char("D"); -- ASCII for 'D'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 END IF;
				 END IF;

					 
				 if (to_integer(unsigned(pixel_row)) >= 95 and to_integer(unsigned(pixel_row)) < 104) then
					if (to_integer(unsigned(pixel_col)) >= 80 and to_integer(unsigned(pixel_col)) < 88) then
						 char_address <= str_to_char("S"); -- ASCII for 's'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 88 and to_integer(unsigned(pixel_col)) < 96) then
						 char_address <= str_to_char("W"); -- ASCII for 'w'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 96 and to_integer(unsigned(pixel_col)) < 104) then
						 char_address <= str_to_char("9"); -- ASCII for '9'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 104 and to_integer(unsigned(pixel_col)) < 112) then
						 char_address <= str_to_char(":"); -- ASCII for ':'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 112 and to_integer(unsigned(pixel_col)) < 120) then
						 char_address <= str_to_char("T"); -- ASCII for 't'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 120 and to_integer(unsigned(pixel_col)) < 128) then
						 char_address <= str_to_char("R"); -- ASCII for 'r'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 128 and to_integer(unsigned(pixel_col)) < 136) then
						 char_address <= str_to_char("A"); -- ASCII for 'a'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 136 and to_integer(unsigned(pixel_col)) < 144) then
						 char_address <= str_to_char("I"); -- ASCII for 'i'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 144 and to_integer(unsigned(pixel_col)) < 152) then
						 char_address <= str_to_char("N"); -- ASCII for 'n'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 152 and to_integer(unsigned(pixel_col)) < 160) then
						 char_address <= str_to_char("I"); -- ASCII for 'i'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 160 and to_integer(unsigned(pixel_col)) < 168) then
						 char_address <= str_to_char("N"); -- ASCII for 'n'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 168 and to_integer(unsigned(pixel_col)) < 176) then
						 char_address <= str_to_char("G"); -- ASCII for 'g'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					end if;
				end if;
				
				
				 if (to_integer(unsigned(pixel_row)) >= 104 and to_integer(unsigned(pixel_row)) < 112) then
					if (to_integer(unsigned(pixel_col)) >= 80 AND to_integer(unsigned(pixel_col)) < 88) then
						 char_address <= str_to_char("S"); -- ASCII for 'S'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 88 AND to_integer(unsigned(pixel_col)) < 96) then
						 char_address <= str_to_char("W"); -- ASCII for 'W'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 96 AND to_integer(unsigned(pixel_col)) < 104) then
						 char_address <= str_to_char("8"); -- ASCII for '8'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 104 AND to_integer(unsigned(pixel_col)) < 112) then
						 char_address <= str_to_char(":"); -- ASCII for ':'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 112 AND to_integer(unsigned(pixel_col)) < 120) then
						 char_address <= str_to_char("G"); -- ASCII for 'g'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 120 AND to_integer(unsigned(pixel_col)) < 128) then
						 char_address <= str_to_char("O"); -- ASCII for 'o'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 128 AND to_integer(unsigned(pixel_col)) < 136) then
						 char_address <= str_to_char("D"); -- ASCII for 'd'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 136 AND to_integer(unsigned(pixel_col)) < 144) then
						 char_address <= str_to_char(" "); -- ASCII for ' '
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 144 AND to_integer(unsigned(pixel_col)) < 152) then
						 char_address <= str_to_char("M"); -- ASCII for 'm'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 152 AND to_integer(unsigned(pixel_col)) < 160) then
						 char_address <= str_to_char("O"); -- ASCII for 'o'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 160 AND to_integer(unsigned(pixel_col)) < 168) then
						 char_address <= str_to_char("D"); -- ASCII for 'd'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					elsif (to_integer(unsigned(pixel_col)) >= 168 AND to_integer(unsigned(pixel_col)) < 176) then
						 char_address <= str_to_char("E"); -- ASCII for 'e'
						 fc <= pixel_col(2 downto 0);
						 fr <= pixel_row(2 downto 0);
					end if;
				end if;
				
				if (to_integer(unsigned(pixel_row)) >= 112 and to_integer(unsigned(pixel_row)) < 120) then
					 if (to_integer(unsigned(pixel_col)) >= 80 AND to_integer(unsigned(pixel_col)) < 88) then
						  char_address <= str_to_char("K"); -- ASCII for 'K'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 88 AND to_integer(unsigned(pixel_col)) < 96) then
						  char_address <= str_to_char("E"); -- ASCII for 'E'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 96 AND to_integer(unsigned(pixel_col)) < 104) then
						  char_address <= str_to_char("Y"); -- ASCII for 'Y'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 104 AND to_integer(unsigned(pixel_col)) < 112) then
						  char_address <= str_to_char("3"); -- ASCII for '3'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 112 AND to_integer(unsigned(pixel_col)) < 120) then
						  char_address <= str_to_char(":"); -- ASCII for ':'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 120 AND to_integer(unsigned(pixel_col)) < 128) then
						  char_address <= str_to_char("R"); -- ASCII for 'R'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 128 AND to_integer(unsigned(pixel_col)) < 136) then
						  char_address <= str_to_char("E"); -- ASCII for 'E'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 136 AND to_integer(unsigned(pixel_col)) < 144) then
						  char_address <= str_to_char("S"); -- ASCII for 'S'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 144 AND to_integer(unsigned(pixel_col)) < 152) then
						  char_address <= str_to_char("E"); -- ASCII for 'E'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 152 AND to_integer(unsigned(pixel_col)) < 160) then
						  char_address <= str_to_char("T"); -- ASCII for 'T'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 end if;
				end if;

				if (to_integer(unsigned(pixel_row)) >= 120 and to_integer(unsigned(pixel_row)) < 128) then
					 if (to_integer(unsigned(pixel_col)) >= 80 AND to_integer(unsigned(pixel_col)) < 88) then
						  char_address <= str_to_char("K"); -- ASCII for 'K'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 88 AND to_integer(unsigned(pixel_col)) < 96) then
						  char_address <= str_to_char("E"); -- ASCII for 'E'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 96 AND to_integer(unsigned(pixel_col)) < 104) then
						  char_address <= str_to_char("Y"); -- ASCII for 'Y'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 104 AND to_integer(unsigned(pixel_col)) < 112) then
						  char_address <= str_to_char("2"); -- ASCII for '2'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 112 AND to_integer(unsigned(pixel_col)) < 120) then
						  char_address <= str_to_char(":"); -- ASCII for ':'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 120 AND to_integer(unsigned(pixel_col)) < 128) then
						  char_address <= str_to_char("S"); -- ASCII for 'S'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 128 AND to_integer(unsigned(pixel_col)) < 136) then
						  char_address <= str_to_char("T"); -- ASCII for 'T'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 136 AND to_integer(unsigned(pixel_col)) < 144) then
						  char_address <= str_to_char("A"); -- ASCII for 'A'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 144 AND to_integer(unsigned(pixel_col)) < 152) then
						  char_address <= str_to_char("R"); -- ASCII for 'R'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 152 AND to_integer(unsigned(pixel_col)) < 160) then
						  char_address <= str_to_char("T"); -- ASCII for 'T'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 end if;
				end if;

				if (to_integer(unsigned(pixel_row)) >= 128 and to_integer(unsigned(pixel_row)) < 136) then
					 if (to_integer(unsigned(pixel_col)) >= 80 AND to_integer(unsigned(pixel_col)) < 88) then
						  char_address <= str_to_char("K"); -- ASCII for 'K'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 88 AND to_integer(unsigned(pixel_col)) < 96) then
						  char_address <= str_to_char("E"); -- ASCII for 'E'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 96 AND to_integer(unsigned(pixel_col)) < 104) then
						  char_address <= str_to_char("Y"); -- ASCII for 'Y'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 104 AND to_integer(unsigned(pixel_col)) < 112) then
						  char_address <= str_to_char("1"); -- ASCII for '1'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 112 AND to_integer(unsigned(pixel_col)) < 120) then
						  char_address <= str_to_char(":"); -- ASCII for ':'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 120 AND to_integer(unsigned(pixel_col)) < 128) then
						  char_address <= str_to_char("P"); -- ASCII for 'P'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 128 AND to_integer(unsigned(pixel_col)) < 136) then
						  char_address <= str_to_char("A"); -- ASCII for 'A'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 136 AND to_integer(unsigned(pixel_col)) < 144) then
						  char_address <= str_to_char("U"); -- ASCII for 'U'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 144 AND to_integer(unsigned(pixel_col)) < 152) then
						  char_address <= str_to_char("S"); -- ASCII for 'S'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 152 AND to_integer(unsigned(pixel_col)) < 160) then
						  char_address <= str_to_char("E"); -- ASCII for 'E'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 end if;
				end if;

				if (to_integer(unsigned(pixel_row)) >= 136 and to_integer(unsigned(pixel_row)) < 144) then
					 if (to_integer(unsigned(pixel_col)) >= 80 AND to_integer(unsigned(pixel_col)) < 88) then
						  char_address <= str_to_char("K"); -- ASCII for 'K'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 88 AND to_integer(unsigned(pixel_col)) < 96) then
						  char_address <= str_to_char("E"); -- ASCII for 'E'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 96 AND to_integer(unsigned(pixel_col)) < 104) then
						  char_address <= str_to_char("Y"); -- ASCII for 'Y'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 104 AND to_integer(unsigned(pixel_col)) < 112) then
						  char_address <= str_to_char("0"); -- ASCII for '0'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 112 AND to_integer(unsigned(pixel_col)) < 120) then
						  char_address <= str_to_char(":"); -- ASCII for ':'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 120 AND to_integer(unsigned(pixel_col)) < 128) then
						  char_address <= str_to_char("M"); -- ASCII for 'M'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 128 AND to_integer(unsigned(pixel_col)) < 136) then
						  char_address <= str_to_char("A"); -- ASCII for 'A'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 136 AND to_integer(unsigned(pixel_col)) < 144) then
						  char_address <= str_to_char("G"); -- ASCII for 'G'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 144 AND to_integer(unsigned(pixel_col)) < 152) then
						  char_address <= str_to_char("I"); -- ASCII for 'I'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 elsif (to_integer(unsigned(pixel_col)) >= 152 AND to_integer(unsigned(pixel_col)) < 160) then
						  char_address <= str_to_char("C"); -- ASCII for 'C'
						  fc <= pixel_col(2 downto 0);
						  fr <= pixel_row(2 downto 0);
					 end if;
				end if;

			ELSIF game_state = PAUSE THEN
				IF (to_integer(unsigned(pixel_row)) >= 95 AND to_integer(unsigned(pixel_row)) < 112) THEN
					IF (to_integer(unsigned(pixel_col)) >= 272 AND to_integer(unsigned(pixel_col)) < 288) THEN
						 char_address <= str_to_char("P"); -- ASCII for 'P'
						 fc <= pixel_col(3 DOWNTO 1);
						 fr <= pixel_row(3 DOWNTO 1);
					ELSIF (to_integer(unsigned(pixel_col)) >= 288 AND to_integer(unsigned(pixel_col)) < 304) THEN
						 char_address <= str_to_char("A"); -- ASCII for 'A'
						 fc <= pixel_col(3 DOWNTO 1);
						 fr <= pixel_row(3 DOWNTO 1);
					ELSIF (to_integer(unsigned(pixel_col)) >= 304 AND to_integer(unsigned(pixel_col)) < 320) THEN
						 char_address <= str_to_char("U"); -- ASCII for 'U'
						 fc <= pixel_col(3 DOWNTO 1);
						 fr <= pixel_row(3 DOWNTO 1);
					ELSIF (to_integer(unsigned(pixel_col)) >= 320 AND to_integer(unsigned(pixel_col)) < 336) THEN
						 char_address <= str_to_char("S"); -- ASCII for 'S'
						 fc <= pixel_col(3 DOWNTO 1);
						 fr <= pixel_row(3 DOWNTO 1);
					ELSIF (to_integer(unsigned(pixel_col)) >= 336 AND to_integer(unsigned(pixel_col)) < 352) THEN
						 char_address <= str_to_char("E"); -- ASCII for 'E'
						 fc <= pixel_col(3 DOWNTO 1);
						 fr <= pixel_row(3 DOWNTO 1);
					ELSIF (to_integer(unsigned(pixel_col)) >= 352 AND to_integer(unsigned(pixel_col)) < 368) THEN
						 char_address <= str_to_char("D"); -- ASCII for 'D'
						 fc <= pixel_col(3 DOWNTO 1);
						 fr <= pixel_row(3 DOWNTO 1);
					END IF;
				END IF;
			ELSIF game_state = START THEN
				 hunds_digit <= score / 100;
				 tens_digit <= score / 10;
				 units_digit <= score MOD 10;
				 -- Display the tens digit
				 IF (((to_integer(unsigned(pixel_row))) >= 80 AND (to_integer(unsigned(pixel_row)) < 96) AND
					  (to_integer(unsigned(pixel_col)) >= 272 AND (to_integer(unsigned(pixel_col)) < 288))) AND score >= 100) THEN
					  char_address <= int_to_char(hunds_digit);
					  fc <= pixel_col(3 DOWNTO 1);
					  fr <= pixel_row(3 DOWNTO 1);
				 ELSIF (((to_integer(unsigned(pixel_row))) >= 80 AND (to_integer(unsigned(pixel_row)) < 96) AND
					  (to_integer(unsigned(pixel_col)) >= 288 AND (to_integer(unsigned(pixel_col)) < 304))) AND score >= 10) THEN
					  char_address <= int_to_char(tens_digit);
					  fc <= pixel_col(3 DOWNTO 1);
					  fr <= pixel_row(3 DOWNTO 1);
				 -- Display the units digit
				 ELSIF ((to_integer(unsigned(pixel_row))) >= 80 AND (to_integer(unsigned(pixel_row)) < 96) AND
					  (to_integer(unsigned(pixel_col)) >= 304 AND (to_integer(unsigned(pixel_col)) < 320))) THEN
					  char_address <= int_to_char(units_digit);
					  fc <= pixel_col(3 DOWNTO 1);
					  fr <= pixel_row(3 DOWNTO 1);
				 ELSIF ((to_integer(unsigned(pixel_row))) >= 80 AND (to_integer(unsigned(pixel_row)) < 96) AND
					  (to_integer(unsigned(pixel_col)) >= 320 AND (to_integer(unsigned(pixel_col)) < 336))) THEN
					  char_address <= "100000";
					  fc <= pixel_col(3 DOWNTO 1); --Empty space since the 4 is glitched
					  fr <= pixel_row(3 DOWNTO 1);
				 END IF;
				 IF (to_integer(unsigned(pixel_row)) >= 24 AND to_integer(unsigned(pixel_row)) < 32 AND 
					  to_integer(unsigned(pixel_col)) >= 0 AND to_integer(unsigned(pixel_col)) < 8) THEN
						 char_address <= int_to_char(life);  -- display of life temp
						 fc <= pixel_col(2 DOWNTO 0);
						 fr <= pixel_row(2 DOWNTO 0);
				 END IF;
			ELSIF game_state = GAME_END THEN
				IF (to_integer(unsigned(pixel_row)) >= 95 AND to_integer(unsigned(pixel_row)) < 112) THEN
					 IF (to_integer(unsigned(pixel_col)) >= 272 AND to_integer(unsigned(pixel_col)) < 288) THEN
						  char_address <= str_to_char("G"); -- ASCII for 'G'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 288 AND to_integer(unsigned(pixel_col)) < 304) THEN
						  char_address <= str_to_char("A"); -- ASCII for 'A'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 304 AND to_integer(unsigned(pixel_col)) < 320) THEN
						  char_address <= str_to_char("M"); -- ASCII for 'M'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 320 AND to_integer(unsigned(pixel_col)) < 336) THEN
						  char_address <= str_to_char("E"); -- ASCII for 'E'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 END IF;
				ELSIF (to_integer(unsigned(pixel_row)) >= 112 AND to_integer(unsigned(pixel_row)) < 128) THEN
					 IF (to_integer(unsigned(pixel_col)) >= 288 AND to_integer(unsigned(pixel_col)) < 304) THEN
						  char_address <= str_to_char("O"); -- ASCII for 'O'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 304 AND to_integer(unsigned(pixel_col)) < 320) THEN
						  char_address <= str_to_char("V"); -- ASCII for 'V'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 320 AND to_integer(unsigned(pixel_col)) < 336) THEN
						  char_address <= str_to_char("E"); -- ASCII for 'E'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 ELSIF (to_integer(unsigned(pixel_col)) >= 336 AND to_integer(unsigned(pixel_col)) < 352) THEN
						  char_address <= str_to_char("R"); -- ASCII for 'R'
						  fc <= pixel_col(3 DOWNTO 1);
						  fr <= pixel_row(3 DOWNTO 1);
					 END IF;
				END IF;
			END IF;
		END IF;
    END PROCESS;
END ARCHITECTURE beh;