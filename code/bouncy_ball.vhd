LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bouncy_ball IS
    PORT
    (
        sw9, pb1, pb2, clk, vert_sync, left_click : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        output_on : OUT std_logic;
        RGB : OUT std_logic_vector(11 DOWNTO 0)
    );
END bouncy_ball;

ARCHITECTURE behavior OF bouncy_ball IS
    SIGNAL ball_on : std_logic;
    SIGNAL size : signed(9 DOWNTO 0) := to_signed(16, 10);
    SIGNAL ball_y_pos : signed(9 DOWNTO 0) := to_signed(240, 10);
    SIGNAL ball_x_pos : signed(10 DOWNTO 0) := to_signed(150, 11);
    SIGNAL ball_y_motion : signed(9 DOWNTO 0);

    SIGNAL start_move : std_logic := '0';
    SIGNAL prev_left_click : std_logic := '0';

    SIGNAL bird_address : std_logic_vector(9 DOWNTO 0);
    SIGNAL bird_data : std_logic_vector(11 DOWNTO 0);

    -- Assume sprite_rom is a component defined elsewhere
    COMPONENT sprite_rom
        PORT (
            clk            : IN std_logic;
            sprite_address : IN std_logic_vector(9 DOWNTO 0);
            data_out       : OUT std_logic_vector(11 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    -- Instantiating the sprite ROM
    sprite_rom_inst : sprite_rom
        PORT MAP (
            clk => clk,
            sprite_address => bird_address,
            data_out => bird_data
        );

    Pixel_Display : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (unsigned(pixel_column) >= unsigned(ball_x_pos) AND 
                unsigned(pixel_column) < unsigned(ball_x_pos) + 32 AND
                unsigned(pixel_row) >= unsigned(ball_y_pos) AND 
                unsigned(pixel_row) < unsigned(ball_y_pos) + 32) THEN
                ball_on <= '1';
                bird_address <= std_logic_vector(to_unsigned(
                    (to_integer(unsigned(pixel_row)) - to_integer(unsigned(ball_y_pos))) * 32 +
                    (to_integer(unsigned(pixel_column)) - to_integer(unsigned(ball_x_pos))), 10));
            ELSE
                ball_on <= '0';
            END IF;
        END IF;
    END PROCESS Pixel_Display;

    RGB <= bird_data when ball_on = '1' and bird_data /= "000000000000" else (others => '0');
    output_on <= '1' when ball_on = '1' and bird_data /= "000000000000" else '0';

    Move_Ball: PROCESS (vert_sync, left_click, sw9)
		variable gravity_up : integer range -100 to 0 := 0;
		variable gravity_down : integer range 0 to 4 := 1;
		variable up : std_logic;
		variable count: integer range 0 to 7 := 0;
    BEGIN
        IF (rising_edge(vert_sync)) THEN
				count := count + 1;
            IF (sw9 = '1') AND (left_click = '1' AND prev_left_click = '0') THEN
                start_move <= '1';
            END IF;
				
            IF (start_move = '1') THEN
					IF (sw9 = '1') AND (left_click = '1') and (prev_left_click = '0') THEN
						count := 0;
						up := '1';
					elsif (up = '1') then   --make the count interval to be one maybe
						if (count <= 1) then
							 gravity_up := -15;
						elsif (count >= 2 and count <= 3) then
							 gravity_up := -10;
						elsif (count >= 4 and count <= 5) then
							 gravity_up := -5;
						elsif (count >= 6) then
							 up := '0';
						end if;
						ball_y_motion <= to_signed(gravity_up, 10);
					ELSIF (ball_y_pos >= to_signed(420, 10) - size*2) THEN
						ball_y_motion <= to_signed(0, 10);
					else
						if (count <= 3) then  --same applies here
							 gravity_down := 1;
						elsif (count >= 4 and count <= 6) then
							 gravity_down := 2;
						elsif (count >= 7) then
						 gravity_down := 4;
						end if;
						ball_y_motion <= to_signed(gravity_down, 10);
					END IF;
               ball_y_pos <= ball_y_pos + ball_y_motion;
            END IF; -- start move if
            prev_left_click <= left_click;
        END IF; -- rising edge if
    END PROCESS Move_Ball;
END behavior;
