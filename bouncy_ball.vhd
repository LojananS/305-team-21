LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY bouncy_ball IS
	PORT
		( pb1, pb2, clk, vert_sync, left_click	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
--		  red, green, blue 			: OUT std_logic;
			output_on				: OUT std_logic;
		  RGB							: OUT std_logic_vector(2 downto 0));		
END bouncy_ball;

architecture behavior of bouncy_ball is

SIGNAL ball_on					: std_logic;
SIGNAL size 					: std_logic_vector(9 DOWNTO 0);  
SIGNAL ball_y_pos				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240,10); -- Initializing y position of ball to be at centre. idk why it doesn't work in architecture
SIGNAL ball_x_pos				: std_logic_vector(10 DOWNTO 0);
SIGNAL ball_y_motion			: std_logic_vector(9 DOWNTO 0);

SIGNAL start_move				: std_logic := '0'; -- Bird starts at centre
SIGNAL prev_left_click		: std_logic := '0'; -- Checking previous left click

BEGIN           

size <= CONV_STD_LOGIC_VECTOR(8,10);

-- ball_x_pos sets the x position of the ball from the left side
ball_x_pos <= CONV_STD_LOGIC_VECTOR(200,11);

-- Ball_on changes the color of the pixels it is on. So background colour will change for the pixels it is on
ball_on <= '1' when ( ('0' & ball_x_pos <= '0' & pixel_column + size) and ('0' & pixel_column <= '0' & ball_x_pos + size) 	-- x_pos - size <= pixel_column <= x_pos + size
					and ('0' & ball_y_pos <= pixel_row + size) and ('0' & pixel_row <= ball_y_pos + size) )  else	-- y_pos - size <= pixel_row <= y_pos + size
			'0';

-- Colours for pixel data on video signal
-- Changing the colors of ball to yellow (110) and background to cyan (011)
RGB <= "110" when ball_on = '1' else
		"000";
output_on <= ball_on;
		
--Red <=  '1' when ball_on = '1' else
--			'0';
--
--Green <= '1' when ball_on = '1' else
--			'0';
--			
--Blue <=  '0';


Move_Ball: process (vert_sync, left_click)
begin
-- Move ball once every vertical sync
	if (rising_edge(vert_sync)) then 
	-- Start the movement
		if (left_click = '1' and prev_left_click = '0' and start_move ='0') then
			start_move <= '1';
		end if;
		
	-- Proceeds with the game
		if (start_move = '1') then
			if (prev_left_click = '1') then
				ball_y_motion <= CONV_STD_LOGIC_VECTOR(1,10);
			else
				if ( ('0' & ball_y_pos >= CONV_STD_LOGIC_VECTOR(479,10) - size) ) then -- Checks if bottom of screen and sets motion to -2 pixels if it is (bounces off bottom)
					ball_y_motion <= - CONV_STD_LOGIC_VECTOR(2,10);
		
				elsif (ball_y_pos <= size) then -- Checks if top of screen and sets motion to 2 pixels if it is (bounces off top)
					ball_y_motion <= CONV_STD_LOGIC_VECTOR(1,10);
				else
					if (left_click = '1') then
						ball_y_motion <= - CONV_STD_LOGIC_VECTOR(50,10); -- Moves up by 50 pixels
					else
						ball_y_motion <= CONV_STD_LOGIC_VECTOR(1,10); -- Moves down by 1 pixels
					end if;
				end if;
			end if;
			ball_y_pos <= ball_y_pos + ball_y_motion; -- Compute next ball Y position
		end if;
		prev_left_click <= left_click;
	end if;
end process Move_Ball;

END behavior;

