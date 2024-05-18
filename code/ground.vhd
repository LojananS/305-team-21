LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ground IS
    PORT
    (
        clk, vert_sync, left_click, collision, reset : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
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

    SIGNAL start_move : std_logic := '1';
    SIGNAL collision_occurred : std_logic := '0';
    SIGNAL reset_ground : std_logic := '0';
    SIGNAL prev_left_click : std_logic := '0';

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

    Move_Ground: PROCESS (vert_sync, left_click, collision, reset)
    BEGIN
        IF rising_edge(vert_sync) THEN
            IF collision = '1' THEN
                start_move <= '0';
                collision_occurred <= '1';
            END IF;

            IF collision_occurred = '1' AND left_click = '1' THEN
                reset_ground <= '1';
                collision_occurred <= '0';
            END IF;
				
				IF reset_ground = '1' THEN
					 -- Reset ground positions to initial values
					 ground_x_pos <= (to_signed(0, 11), to_signed(320, 11), to_signed(639, 11));
					 start_move <= '1';
					 reset_ground <= '0';
				END IF;

			IF start_move = '1' THEN
				FOR i IN 0 TO 2 LOOP
					ground_x_pos(i) <= ground_x_pos(i) - to_signed(1, 11);
					IF ground_x_pos(i) < -to_signed(ground_x_size, 11) THEN
						ground_x_pos(i) <= ground_x_pos((i + 2) MOD 3) + to_signed(ground_x_size - 2, 11);
					END IF;
				END LOOP;
			END IF;

            prev_left_click <= left_click;
        END IF;
    END PROCESS Move_Ground;

END behavior;
