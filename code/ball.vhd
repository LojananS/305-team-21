LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; -- Correct library for numeric operations

ENTITY ball IS
    PORT
    (
        clk                     : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
		  output_on						: OUT std_logic;
        RGB                     : OUT std_logic_vector(2 DOWNTO 0)
    );
END ball;

ARCHITECTURE behavior OF ball IS

    COMPONENT sprite_rom
        PORT (
            clk            : IN std_logic;
            sprite_address : IN std_logic_vector(7 DOWNTO 0);
            data_out       : OUT std_logic_vector(2 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL ball_on          : std_logic;
    SIGNAL size             : std_logic_vector(9 DOWNTO 0);
    SIGNAL ball_y_pos, ball_x_pos : std_logic_vector(9 DOWNTO 0);
    SIGNAL bird_address     : std_logic_vector(7 DOWNTO 0);
    SIGNAL bird_data        : std_logic_vector(2 DOWNTO 0);

BEGIN

    sprite_rom_inst : sprite_rom
        PORT MAP (
            clk => clk,
            sprite_address => bird_address,
            data_out => bird_data
        );

    size <= std_logic_vector(to_unsigned(16, 10));  -- size of the sprite
    ball_x_pos <= std_logic_vector(to_unsigned(150, 10));  -- Horizontal center of the sprite
    ball_y_pos <= std_logic_vector(to_unsigned(240, 10));  -- Vertical center of the sprite

    -- Process to handle the pixel-by-pixel display
	Pixel_Display : PROCESS (clk)
	BEGIN
		IF rising_edge(clk) THEN
			-- Calculate offset within the sprite
			IF unsigned(pixel_column) >= unsigned(ball_x_pos) AND 
				unsigned(pixel_column) < unsigned(ball_x_pos) + 16 AND  -- Adjusted to explicit sprite width
				unsigned(pixel_row) >= unsigned(ball_y_pos) AND 
				unsigned(pixel_row) < unsigned(ball_y_pos) + 16 THEN  -- Adjusted to explicit sprite height
				ball_on <= '1';
			-- Calculate relative positions within sprite dimensions
				bird_address <= std_logic_vector(to_unsigned(
					(to_integer(unsigned(pixel_row)) - to_integer(unsigned(ball_y_pos))) * 16 +
					(to_integer(unsigned(pixel_column)) - to_integer(unsigned(ball_x_pos))), 8));
			ELSE
				ball_on <= '0';
			END IF;

			-- Set the RGB output based on the sprite data or default to black
			IF ball_on = '1' THEN
				RGB <= bird_data;
			ELSE
				RGB <= (others => '0');
			END IF;
		END IF;
	END PROCESS Pixel_Display;
	
	output_on <= '1';
END behavior;
