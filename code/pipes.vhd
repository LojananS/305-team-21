LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.NUMERIC_STD.all;

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
	SIGNAL p1_x_pos			: signed(10 DOWNTO 0) := to_signed(400,11); 
	SIGNAL p1_y_pos			: signed(9 DOWNTO 0) := to_signed(0,10); -- Initializing y position of pipe to be at centre.
	SIGNAL p1_gap_center		: signed(9 DOWNTO 0) := to_signed(240,10);

	-- Pipe 2 Characteristics
	SIGNAL p2_on				: std_logic;
	SIGNAL p2_x_pos			: signed(10 DOWNTO 0) := to_signed(640,11);
	SIGNAL p2_y_pos			: signed(9 DOWNTO 0) := to_signed(0,10);
	SIGNAL p2_gap_center		: signed(9 DOWNTO 0) := to_signed(240,10);

	-- General Pipe Settings
	SIGNAL size 					: signed(9 DOWNTO 0);
	SIGNAL pipe_x_motion			: signed(10 DOWNTO 0);
	SIGNAL pipe_x_size 			: signed(9 DOWNTO 0);
	SIGNAL pipe_y_size 			: signed(9 DOWNTO 0);

	SIGNAL start_move				: std_logic := '0'; -- Pipe starts moving when enabled

BEGIN           

	pipe_x_size <= to_signed(50,10);
	pipe_y_size <= to_signed(479,10);

	-- Combinational logic for Pipe 1
p1_on <= '1' WHEN (unsigned(pixel_column) >= unsigned(p1_x_pos) AND 
                   unsigned(pixel_column) < unsigned(p1_x_pos) + unsigned(pipe_x_size) AND
                   (unsigned(pixel_row) < unsigned(p1_gap_center) - 30 OR 
                    unsigned(pixel_row) > unsigned(p1_gap_center) + 30))
                ELSE '0';

-- Combinational logic for Pipe 2
p2_on <= '1' WHEN (unsigned(pixel_column) >= unsigned(p2_x_pos) AND 
                   unsigned(pixel_column) < unsigned(p2_x_pos) + unsigned(pipe_x_size) AND
                   (unsigned(pixel_row) < unsigned(p2_gap_center) - 30 OR 
                    unsigned(pixel_row) > unsigned(p2_gap_center) + 30))
                ELSE '0';


    -- Control RGB output and overall output display
    RGB <= "010" when (p1_on = '1' or p2_on = '1'); -- "010" green is the color for the pipes
    output_on <= '1' when (p1_on = '1' or p2_on = '1') else '0';
			

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
            -- Checks if the entire pipe has left the screen
            if (p1_x_pos <= - 1) then  -- Ensuring the entire pipe is off-screen
                p1_x_pos <= to_signed(640, 11); -- Reset position to the right side of the screen
            else
                p1_x_pos <= p1_x_pos - to_signed(1, 11); -- Move the pipe left
            end if;

            -- Same logic for Pipe 2
            if (p2_x_pos + pipe_x_size < 0) then  -- Ensuring the entire pipe is off-screen
                p2_x_pos <= to_signed(640, 11); -- Reset position to the right side of the screen
            else
                p2_x_pos <= p2_x_pos - to_signed(1, 11); -- Move the pipe left
            end if;
        end if;
    end if;
end process Move_pipe;



END behavior;