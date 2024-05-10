LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY pipes IS
	PORT
		( clk, vert_sync, left_click	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
--		  red, green, blue 			: OUT std_logic;
			output_on						: OUT std_logic;
			RGB							: OUT std_logic_vector(2 downto 0));		
END pipes;

architecture behavior of pipes is

SIGNAL pipe_on					: std_logic;
SIGNAL size 					: std_logic_vector(9 DOWNTO 0);  
SIGNAL pipe_y_pos				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,10); -- Initializing y position of pipe to be at centre.
SIGNAL pipe_x_pos				: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500,11);
SIGNAL pipe_x_motion			: std_logic_vector(10 DOWNTO 0);
SIGNAL pipe_x_size 			: std_logic_vector(9 DOWNTO 0);
SIGNAL pipe_y_size 			: std_logic_vector(9 DOWNTO 0);

SIGNAL start_move				: std_logic := '0'; -- Pipe starts at right sides

BEGIN           

pipe_x_size <= CONV_STD_LOGIC_VECTOR(12,10);
pipe_y_size <= CONV_STD_LOGIC_VECTOR(479,10);

-- pipe_on changes the color of the pixels it is on. So background colour will change for the pixels it is on
pipe_on <= '1' when ( ('0' & pipe_x_pos <= '0' & pixel_column + pipe_x_size) and ('0' & pixel_column <= '0' & pipe_x_pos + pipe_x_size)
					and ('0' & pipe_y_pos <= pixel_row) and ('0' & pixel_row <= pipe_y_pos + pipe_y_size))  else
			'0';

-- Colours for pixel data on video signal
-- Changing the colors of pipe to yellow (110) and background to cyan (011)
RGB <= "111" when pipe_on = '1' else
		"000";
		
--Red <=  '1' when pipe_on = '1' else
--			'0';
--
--Green <= '1' when pipe_on = '1' else
--			'0';
--			
--Blue <=  '1' when pipe_on = '1' else
--			'0';
output_on <= pipe_on;

Move_pipe: process (vert_sync, left_click)
begin
-- Move pipe once every vertical sync
	if (rising_edge(vert_sync)) then 
	-- Start the movement
		if (left_click = '1' and start_move ='0') then
			start_move <= '1';
		end if;
		
	-- Proceeds with the game
		if (start_move = '1') then
			if (pipe_x_pos <= -pipe_x_size) then -- Checks if left of screen
				pipe_x_pos <= CONV_STD_LOGIC_VECTOR(650,11);
			else
				pipe_x_pos <= pipe_x_pos - CONV_STD_LOGIC_VECTOR(1,11);
			end if;
		end if;
	end if;
end process Move_pipe;

END behavior;