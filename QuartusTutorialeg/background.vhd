LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY background IS
	PORT
		( pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic);		
END background;

ARCHITECTURE behavior OF background IS
	-- Screen dimensions
	CONSTANT screen_width : INTEGER := 640;
	CONSTANT screen_height : INTEGER := 480;

	-- Star positions
	CONSTANT star_count : INTEGER := 20; -- Number of stars
	TYPE star_array IS ARRAY (0 TO star_count-1) OF std_logic_vector(9 DOWNTO 0);
	CONSTANT star_x_positions : star_array := (
		CONV_STD_LOGIC_VECTOR(100, 10), -- Star 1
		CONV_STD_LOGIC_VECTOR(200, 10), -- Star 2
		CONV_STD_LOGIC_VECTOR(300, 10), -- Star 3
		CONV_STD_LOGIC_VECTOR(400, 10), -- Star 4
		CONV_STD_LOGIC_VECTOR(500, 10), -- Star 5
		CONV_STD_LOGIC_VECTOR(600, 10), -- Star 6
		CONV_STD_LOGIC_VECTOR(150, 10), -- Star 7
		CONV_STD_LOGIC_VECTOR(250, 10), -- Star 8
		CONV_STD_LOGIC_VECTOR(350, 10), -- Star 9
		CONV_STD_LOGIC_VECTOR(450, 10), -- Star 10
		CONV_STD_LOGIC_VECTOR(550, 10), -- Star 11
		CONV_STD_LOGIC_VECTOR(50, 10),  -- Star 12
		CONV_STD_LOGIC_VECTOR(120, 10), -- Star 13
		CONV_STD_LOGIC_VECTOR(220, 10), -- Star 14
		CONV_STD_LOGIC_VECTOR(320, 10), -- Star 15
		CONV_STD_LOGIC_VECTOR(420, 10), -- Star 16
		CONV_STD_LOGIC_VECTOR(520, 10), -- Star 17
		CONV_STD_LOGIC_VECTOR(620, 10), -- Star 18
		CONV_STD_LOGIC_VECTOR(80, 10),  -- Star 19
		CONV_STD_LOGIC_VECTOR(180, 10)  -- Star 20
	);
	CONSTANT star_y_positions : star_array := (
		CONV_STD_LOGIC_VECTOR(50, 10),  -- Star 1
		CONV_STD_LOGIC_VECTOR(150, 10), -- Star 2
		CONV_STD_LOGIC_VECTOR(250, 10), -- Star 3
		CONV_STD_LOGIC_VECTOR(350, 10), -- Star 4
		CONV_STD_LOGIC_VECTOR(100, 10), -- Star 5
		CONV_STD_LOGIC_VECTOR(200, 10), -- Star 6
		CONV_STD_LOGIC_VECTOR(300, 10), -- Star 7
		CONV_STD_LOGIC_VECTOR(400, 10), -- Star 8
		CONV_STD_LOGIC_VECTOR(75, 10),  -- Star 9
		CONV_STD_LOGIC_VECTOR(175, 10), -- Star 10
		CONV_STD_LOGIC_VECTOR(275, 10), -- Star 11
		CONV_STD_LOGIC_VECTOR(375, 10), -- Star 12
		CONV_STD_LOGIC_VECTOR(125, 10), -- Star 13
		CONV_STD_LOGIC_VECTOR(225, 10), -- Star 14
		CONV_STD_LOGIC_VECTOR(325, 10), -- Star 15
		CONV_STD_LOGIC_VECTOR(425, 10), -- Star 16
		CONV_STD_LOGIC_VECTOR(475, 10), -- Star 17
		CONV_STD_LOGIC_VECTOR(425, 10), -- Star 18
		CONV_STD_LOGIC_VECTOR(225, 10), -- Star 19
		CONV_STD_LOGIC_VECTOR(325, 10)  -- Star 20
	);

BEGIN
	PROCESS (pixel_row, pixel_column)
		VARIABLE is_star : BOOLEAN := FALSE;
	BEGIN
		is_star := FALSE;
		-- Check if current pixel corresponds to any of the star positions
		FOR i IN 0 TO star_count-1 LOOP
			IF (pixel_row = star_y_positions(i) AND pixel_column = star_x_positions(i)) THEN
				is_star := TRUE;
			END IF;
		END LOOP;

		if(is_star = TRUE) then
			red <= '1';
			green <= '1';
			blue <= '1';
		else 
			red <= '0';
			green <= '0';
			blue <= '0';
		end if;
		-- Set colors based on whether the current pixel is a star or background
		
	END PROCESS;

		

END behavior;