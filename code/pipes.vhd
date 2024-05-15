LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY pipes IS
	PORT
		( clk, vert_sync, left_click : IN std_logic;
          pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
			output_on : OUT std_logic;
			RGB : OUT std_logic_vector(11 DOWNTO 0)
			);		
END pipes;

ARCHITECTURE behavior OF pipes IS
	-- Pipe 1 Characteristics
	SIGNAL p1_on : std_logic;
	SIGNAL p1_x_pos : signed(10 DOWNTO 0) := to_signed(300, 11); 
	SIGNAL p1_y_pos : signed(9 DOWNTO 0) := to_signed(0, 10); -- at the top
	SIGNAL p1_gap_center : signed(9 DOWNTO 0) := to_signed(240, 10);

	-- Pipe 2 Characteristics
	SIGNAL p2_on : std_logic;
	SIGNAL p2_x_pos : signed(10 DOWNTO 0) := to_signed(640, 11);
	SIGNAL p2_y_pos : signed(9 DOWNTO 0) := to_signed(0, 10);
	SIGNAL p2_gap_center : signed(9 DOWNTO 0) := to_signed(240, 10);

	-- General Pipe Settings
	SIGNAL size : signed(9 DOWNTO 0);
	SIGNAL pipe_x_motion : signed(10 DOWNTO 0);
	SIGNAL pipe_x_size : signed(9 DOWNTO 0);
	SIGNAL pipe_y_size : signed(9 DOWNTO 0);

	SIGNAL start_move : std_logic := '0'; -- Pipe starts moving when enabled

BEGIN           

	pipe_x_size <= to_signed(40, 10);
	pipe_y_size <= to_signed(479, 10);

	-- Combinational logic for Pipe 1
	p1_on <= '1' WHEN (unsigned(pixel_column) >= unsigned(p1_x_pos) AND 
	                   unsigned(pixel_column) < unsigned(p1_x_pos) + unsigned(pipe_x_size) AND
	                   (unsigned(pixel_row) < unsigned(p1_gap_center) - 45 OR 
	                    unsigned(pixel_row) > unsigned(p1_gap_center) + 45))
	            ELSE '0';

	-- Combinational logic for Pipe 2
	p2_on <= '1' WHEN (unsigned(pixel_column) >= unsigned(p2_x_pos) AND 
	                   unsigned(pixel_column) < unsigned(p2_x_pos) + unsigned(pipe_x_size) AND
	                   (unsigned(pixel_row) < unsigned(p2_gap_center) - 45 OR 
	                    unsigned(pixel_row) > unsigned(p2_gap_center) + 45))
	            ELSE '0';

	-- Control RGB output and overall output display
	RGB <= "100010001000" WHEN (p1_on = '1' OR p2_on = '1'); -- "100010001000" grey is the color for the pipes
	output_on <= '1' WHEN (p1_on = '1' OR p2_on = '1') ELSE '0';

	Move_pipe: PROCESS (vert_sync, left_click)
	BEGIN
	    -- Move pipe once every vertical sync
	    IF (rising_edge(vert_sync)) THEN 
	        -- Start the movement
	        IF (left_click = '1' AND start_move = '0') THEN
	            start_move <= '1';
	        END IF;

	        -- Proceeds with the game
	        IF (start_move = '1') THEN
	            -- Checks if the entire pipe has left the screen
	            IF (p1_x_pos + 2*pipe_x_size <= to_signed(0, 11)) THEN  -- Ensuring the entire pipe is off-screen
	                p1_x_pos <= to_signed(640, 11); -- Reset position to the right side of the screen
	            ELSE
	                p1_x_pos <= p1_x_pos - to_signed(1, 11); -- Move the pipe left
	            END IF;

	            -- Same logic for Pipe 2
	            IF (p2_x_pos + 2*pipe_x_size <= to_signed(0, 11)) THEN  -- Ensuring the entire pipe is off-screen
	                p2_x_pos <= to_signed(640, 11); -- Reset position to the right side of the screen
	            ELSE
	                p2_x_pos <= p2_x_pos - to_signed(1, 11); -- Move the pipe left
	            END IF;
	        END IF;
	    END IF;
	END PROCESS Move_pipe;

END behavior;
