LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.game_type_pkg.ALL;

ENTITY ground IS
    PORT
    (
<<<<<<< HEAD
        clk, vert_sync: IN std_logic;
=======
        clk, vert_sync, left_click : IN std_logic;
		  input_state : IN std_logic_vector(3 DOWNTO 0);
>>>>>>> 575764bd812c766414a2f0f66cce07d4ea17232f
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
		  input_state: IN std_logic_vector(3 downto 0);
        output_on : OUT std_logic;
        RGB : OUT std_logic_vector(11 DOWNTO 0)
    );
END ground;

ARCHITECTURE behavior OF ground IS
    COMPONENT floor_rom IS
        PORT
        (
            clk            : IN std_logic;
            floor_address  : IN std_logic_vector(15 DOWNTO 0);
            data_out       : OUT std_logic_vector(11 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL ground_y_pos : signed(9 DOWNTO 0) := to_signed(450, 10);
    SIGNAL ground_y_size : signed(9 DOWNTO 0) := to_signed(30, 10);

    TYPE ground_type IS ARRAY (0 TO 2) OF signed(10 DOWNTO 0);
    SIGNAL ground_x_pos : ground_type := (to_signed(0, 11), to_signed(320, 11), to_signed(640, 11));
    CONSTANT ground_x_size : integer range 0 to 320 := 320;
    SIGNAL ground_on : std_logic_vector(2 DOWNTO 0);

    SIGNAL ground_address : std_logic_vector(15 DOWNTO 0);
    SIGNAL ground_data : std_logic_vector(11 DOWNTO 0);

BEGIN
    floor_rom_inst : floor_rom
        PORT MAP (
            clk => clk,
            floor_address => ground_address,
            data_out => ground_data
        );

    Ground_Display : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            ground_on <= (others => '0');
            FOR i IN 0 TO 2 LOOP
                IF (to_integer(unsigned(pixel_column)) >= to_integer(ground_x_pos(i)) AND
                    to_integer(unsigned(pixel_column)) < to_integer(ground_x_pos(i)) + ground_x_size AND
                    to_integer(unsigned(pixel_row)) >= to_integer(ground_y_pos) AND
                    to_integer(unsigned(pixel_row)) < to_integer(ground_y_pos + ground_y_size)) THEN
                    ground_on(i) <= '1';
                    ground_address <= std_logic_vector(to_unsigned(
                        ((to_integer(unsigned(pixel_row)) - to_integer(unsigned(ground_y_pos))) * 320) +
                        (to_integer(unsigned(pixel_column)) - to_integer(ground_x_pos(i))), 16));
                END IF;
            END LOOP;
        END IF;
    END PROCESS Ground_Display;
    
    RGB <= ground_data WHEN (ground_on /= "000") ELSE (others => '0');
    output_on <= '1' WHEN ground_on > "000" ELSE '0';

<<<<<<< HEAD
	Move_Ground: PROCESS (vert_sync)
	variable game_state : state_type;
	BEGIN
		IF rising_edge(vert_sync) THEN
			game_state := to_state_type(input_state);
			if game_state = PAUSE or game_state = GAME_END then
				null;
			elsif game_state = START or game_state = HOME then
				FOR i IN 0 TO 2 LOOP
						ground_x_pos(i) <= ground_x_pos(i) - to_signed(1, 11);
						IF ground_x_pos(i) < -to_signed(ground_x_size, 11) THEN
							ground_x_pos(i) <= ground_x_pos((i + 2) MOD 3) + to_signed(ground_x_size - 2, 11);
						END IF;
					END LOOP;
			end if;
=======
	Move_Ground: PROCESS (vert_sync, left_click, input_state)
		variable game_state : state_type;
	BEGIN
		IF rising_edge(vert_sync) THEN
			game_state := to_state_type(input_state);
			IF game_state = RESET_GAME THEN
				 -- Reset ground positions to initial values
				ground_x_pos <= (to_signed(0, 11), to_signed(320, 11), to_signed(639, 11));
			END IF;
			
			IF game_state = START THEN
				FOR i IN 0 TO 2 LOOP
					ground_x_pos(i) <= ground_x_pos(i) - to_signed(1, 11);
					IF ground_x_pos(i) < -to_signed(ground_x_size, 11) THEN
						ground_x_pos(i) <= ground_x_pos((i + 2) MOD 3) + to_signed(ground_x_size - 2, 11);
					END IF;
				END LOOP;

            prev_left_click <= left_click;
			END IF;
>>>>>>> 575764bd812c766414a2f0f66cce07d4ea17232f
		END IF;
	END PROCESS Move_Ground;

END behavior;