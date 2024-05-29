LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.game_type_pkg.ALL;

ENTITY background IS
    PORT
    (
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        pb1, clk, vert_sync: IN std_logic;
		  input_state: IN std_logic_vector(3 downto 0);
        output_on                  : OUT std_logic;
        RGB                        : OUT std_logic_vector(11 DOWNTO 0)
    );        
END background;

ARCHITECTURE behavior OF background IS
    CONSTANT screen_width : INTEGER range 0 to 640 := 640;
    CONSTANT screen_height : INTEGER range 0 to 480:= 480; 

    SIGNAL prev_left_click : std_logic := '0';
    SIGNAL start_move : std_logic := '0';
    SIGNAL toggle_state : std_logic := '0';
    SIGNAL pb1_prev : std_logic := '0';
	 
	 SIGNAL bg_address : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL bg_data : STD_LOGIC_VECTOR(11 DOWNTO 0);
	 SIGNAL morningbg_address : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL morningbg_data : STD_LOGIC_VECTOR(11 DOWNTO 0);
	 SIGNAL nightbg_on, morningbg_on : STD_LOGIC;
	 
	 SIGNAL bg_x_pos : INTEGER range 0 to 640 := 0;
    SIGNAL bg_y_pos : INTEGER range 0 to 480 := 0;
	 
	 COMPONENT bg_rom is
		PORT
		(
        clk             :   IN STD_LOGIC;
        address_out  :   IN STD_LOGIC_VECTOR(14 DOWNTO 0);
        data_out        :   OUT STD_LOGIC_VECTOR(11 DOWNTO 0) -- Updated to 12 bits
		);
	END COMPONENT bg_rom;
	
	COMPONENT morningbg_rom IS
    PORT
    (
        clk             :   IN STD_LOGIC;
        address_out  :   IN STD_LOGIC_VECTOR(14 DOWNTO 0);
        data_out        :   OUT STD_LOGIC_VECTOR(11 DOWNTO 0) -- Updated to 12 bits
    );
	END COMPONENT morningbg_rom;
	
BEGIN
	bg_inst : bg_rom
		PORT MAP (
			clk => clk,
			address_out => bg_address,
			data_out => bg_data
		);
	morningbg_inst : morningbg_rom
		PORT MAP (
			clk => clk,
			address_out => morningbg_address,
			data_out => morningbg_data
		);
		
		Toggle_Background: PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF pb1 = '1' AND pb1_prev = '0' THEN
                toggle_state <= NOT toggle_state;
            END IF;
            pb1_prev <= pb1;
        END IF;
    END PROCESS;

		BG_Display : PROCESS (clk)
			BEGIN
				IF rising_edge(clk) THEN
					IF (unsigned(pixel_column) >= bg_x_pos AND 
						unsigned(pixel_column) < bg_x_pos + 640 AND
						unsigned(pixel_row) >= bg_y_pos AND 
						unsigned(pixel_row) < bg_y_pos + 480) THEN
						IF (toggle_state = '0') then
						morningbg_on <= '0';
						nightbg_on <= '1';
						bg_address <= std_logic_vector(to_unsigned(
                    ((to_integer(unsigned(pixel_row)) - bg_y_pos) / 4) * 160 +
                    ((to_integer(unsigned(pixel_column)) - bg_x_pos) / 4), 15));
						ELSIF (toggle_state = '1') then
						nightbg_on <= '0';
						morningbg_on <= '1';
						morningbg_address <= std_logic_vector(to_unsigned(
                    ((to_integer(unsigned(pixel_row)) - bg_y_pos) / 4) * 160 +
                    ((to_integer(unsigned(pixel_column)) - bg_x_pos) / 4), 15));
						END IF;
					END IF;
				END IF;
		END PROCESS BG_Display;
		
    RGB <= bg_data when nightbg_on = '1' ELSE 
				morningbg_data when morningbg_on = '1' else 
				(others => '0');
	 output_on <= '1' when nightbg_on = '1' else
						'1' when morningbg_on = '1' else
						'0';
END behavior;

--PROCESS (pixel_row, pixel_column)
--        VARIABLE is_star : BOOLEAN := FALSE;
--        VARIABLE is_moon_sun : BOOLEAN := FALSE;
--        VARIABLE delta_x : INTEGER;
--        VARIABLE delta_y : INTEGER;
--        VARIABLE distance_squared : INTEGER;
--    BEGIN
--        is_star := FALSE;
--        is_moon_sun := FALSE;
--
--        FOR i IN 0 TO star_count-1 LOOP
--            IF (pixel_row = star_y_positions(i) AND pixel_column = star_x_positions(i)) THEN
--                is_star := TRUE;
--            END IF;
--        END LOOP;
--
--        delta_x := to_integer(unsigned(pixel_column)) - to_integer(unsigned(moon_center_x));
--        delta_y := to_integer(unsigned(pixel_row)) - to_integer(unsigned(moon_center_y));
--        distance_squared := delta_x * delta_x + delta_y * delta_y;
--
--        IF toggle_state = '0' AND distance_squared <= moon_radius * moon_radius THEN
--            is_moon_sun := TRUE;
--            RGB <= "111111111111";
--        ELSIF toggle_state = '1' AND distance_squared <= sun_radius * sun_radius THEN
--            is_moon_sun := TRUE;
--            RGB <= "111110100000";
--        ELSE
--            IF toggle_state = '1' THEN
--                RGB <= "000110101111";
--            ELSE
--                RGB <= "000000000000";
--            END IF;
--        END IF;
--
--        IF toggle_state = '0' THEN
--            FOR i IN 0 TO star_count-1 LOOP
--                IF (pixel_row = star_y_positions(i) AND pixel_column = star_x_positions(i)) THEN
--                    is_star := TRUE;
--                    RGB <= "111111111111";
--                END IF;
--            END LOOP;
--        END IF;
--    END PROCESS;
--
--    output_on <= '1' when (star_on = '1' or moon_on = '1') else '0';