LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.NUMERIC_STD.all;
USE work.game_type_pkg.ALL;


ENTITY text_rom IS 
    PORT (
        pixel_row, pixel_col : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        clk, collision, left_click: IN STD_LOGIC;
        input_state: IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Input state from FSM
        score : IN integer range 0 to 999;
        output_on : OUT STD_LOGIC;
        RGB : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
END text_rom;

ARCHITECTURE beh OF text_rom IS
    SIGNAL fr, fc : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL char_address : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL collision_occured, reset_text, disp_score : STD_LOGIC;
    SIGNAL hunds_digit, tens_digit, units_digit: INTEGER RANGE 0 TO 9;
    SIGNAL init_disp : STD_LOGIC := '1';

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

BEGIN 
    -- Instantiate char_rom
    char_rom_inst : char_rom 
        PORT MAP (
            character_address => char_address, 
            font_row => fr,
            font_col => fc, 
            clock => clk, 
            rom_mux_output => output_on
        );

    PROCESS (clk, input_state)
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

            -- Handle state transitions based on FSM state
            IF input_state = to_slv(RESET_GAME) THEN
                init_disp <= '1'; -- Reset initial display flag
                disp_score <= '0';
                collision_occured <= '0';
                reset_text <= '0';
            ELSIF input_state = to_slv(START) THEN
                init_disp <= '0';
                disp_score <= '1';
            ELSIF input_state = to_slv(GAME_END) THEN
                collision_occured <= '1';
            ELSIF collision_occured = '1' AND left_click = '1' THEN
                reset_text <= '1';
                collision_occured <= '0';
            ELSIF reset_text = '1' THEN
                init_disp <= '1'; -- Reset initial display flag
                disp_score <= '0';
                reset_text <= '0'; -- Clear reset signal
            END IF;

            IF init_disp = '1' THEN
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
            ELSIF disp_score = '1' THEN
                hunds_digit <= score / 100;
                tens_digit <= score / 10;
                units_digit <= score MOD 10;
                -- Display the hundreds digit
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
                    fc <= pixel_col(3 DOWNTO 1); -- Empty space since the 4 is glitched
                    fr <= pixel_row(3 DOWNTO 1);
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE beh;