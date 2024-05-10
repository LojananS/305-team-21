LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

ENTITY pipes IS
	PORT
		( clk, vert_sync, left_click	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
			output_on						: OUT std_logic;
			RGB							: OUT std_logic_vector(2 downto 0));		
END pipes;

architecture behavior of pipes is
	-- Pipe 1 Characteristics
	SIGNAL p1_on				: std_logic;
	SIGNAL p1_x_pos			: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(600,11); 
	SIGNAL p1_y_pos			: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,10); -- Initializing y position of pipe to be at centre.
	SIGNAL p1_gap_center		: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240,10);

	-- Pipe 2 Characteristics
	SIGNAL p2_on				: std_logic;
	SIGNAL p2_x_pos			: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(350,11);
	SIGNAL p2_y_pos			: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,10);
	SIGNAL p2_gap_center		: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240,10);

	-- General Pipe Settings
	SIGNAL size 					: std_logic_vector(9 DOWNTO 0);
	SIGNAL gap_size				: std_logic_vector(9 DOWNTO 0);
	SIGNAL pipe_x_motion			: std_logic_vector(10 DOWNTO 0);
	SIGNAL pipe_x_size 			: std_logic_vector(9 DOWNTO 0);
	SIGNAL pipe_y_size 			: std_logic_vector(9 DOWNTO 0);

	SIGNAL start_move				: std_logic := '0'; -- Pipe starts moving when enabled

BEGIN           

	pipe_x_size <= CONV_STD_LOGIC_VECTOR(12,10);
	pipe_y_size <= CONV_STD_LOGIC_VECTOR(479,10);
	gap_size <= CONV_STD_LOGIC_VECTOR(30,10);

	-- pipe_on changes the color of the pixels it is on. So background colour will change for the pixels it is on
		p1_on <= '1' when (pixel_column >= p1_x_pos AND pixel_column < p1_x_pos + pipe_x_size AND
                         ((pixel_row < p1_gap_center - gap_size) OR 
                          (pixel_row > p1_gap_center + gap_size))) else '0';
								  
		p2_on <= '1' when (pixel_column >= p2_x_pos AND pixel_column < p2_x_pos + pipe_x_size AND
                         ((pixel_row < p2_gap_center - gap_size) OR 
                          (pixel_row > p2_gap_center + gap_size))) else '0';

	-- Colours for pixel data on video signal
	-- Changing the color of pipe to green (010)
	RGB <= "010" when p1_on = '1' or p2_on ='1' else
			"000";
	output_on <= p1_on or p2_on;

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
				if (p1_x_pos <= -pipe_x_size) then -- Checks if left of screen
					p1_x_pos <= CONV_STD_LOGIC_VECTOR(640,11);
				else
					p1_x_pos <= p1_x_pos - CONV_STD_LOGIC_VECTOR(1,11);
				end if;
				
				if (p2_x_pos <= -pipe_x_size) then -- Checks if left of screen
					p2_x_pos <= CONV_STD_LOGIC_VECTOR(640,11);
				else
					p2_x_pos <= p2_x_pos - CONV_STD_LOGIC_VECTOR(1,11);
				end if;
			end if;
		end if;
	end process Move_pipe;

END behavior;