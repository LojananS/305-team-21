LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bouncy_ball IS
    PORT
    (
        sw9, pb1, pb2, clk, vert_sync, left_click : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        output_on : OUT std_logic;
        RGB : OUT std_logic_vector(2 downto 0)
    );
END bouncy_ball;

ARCHITECTURE behavior OF bouncy_ball IS
    SIGNAL ball_on : std_logic;
    SIGNAL size : signed(9 DOWNTO 0) := to_signed(8, 10);
    SIGNAL ball_y_pos : signed(9 DOWNTO 0) := to_signed(240, 10);
    SIGNAL ball_x_pos : signed(10 DOWNTO 0) := to_signed(150, 11);
    SIGNAL ball_y_motion : signed(9 DOWNTO 0);

    SIGNAL start_move : std_logic := '0';
    SIGNAL prev_left_click : std_logic := '0';

    SIGNAL bird_address : std_logic_vector(7 DOWNTO 0);
    SIGNAL bird_data : std_logic_vector(2 DOWNTO 0);

    -- Assume sprite_rom is a component defined elsewhere
    COMPONENT sprite_rom
        PORT (
            clk            : IN std_logic;
            sprite_address : IN std_logic_vector(7 DOWNTO 0);
            data_out       : OUT std_logic_vector(2 DOWNTO 0)
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
                unsigned(pixel_column) < unsigned(ball_x_pos) + 16 AND
                unsigned(pixel_row) >= unsigned(ball_y_pos) AND 
                unsigned(pixel_row) < unsigned(ball_y_pos) + 16) THEN
                ball_on <= '1';
                bird_address <= std_logic_vector(to_unsigned(
                    (to_integer(unsigned(pixel_row)) - to_integer(unsigned(ball_y_pos))) * 16 +
                    (to_integer(unsigned(pixel_column)) - to_integer(unsigned(ball_x_pos))), 8));
            ELSE
                ball_on <= '0';
            END IF;
        END IF;
    END PROCESS Pixel_Display;
    
    RGB <= bird_data when ball_on = '1' and bird_data /= "000" else (others => '0');
    output_on <= '1' when ball_on = '1' and bird_data /= "000" else '0';
    
    Move_Ball: PROCESS (vert_sync, left_click, sw9)
    BEGIN
        IF (rising_edge(vert_sync)) THEN
            IF (sw9 = '1') AND (left_click = '1' AND prev_left_click = '0') THEN
                start_move <= '1';
            END IF;
            IF (start_move = '1') THEN
                IF (ball_y_pos >= to_signed(479, 10) - size) THEN
                    ball_y_motion <= to_signed(-1, 10);
                ELSIF (ball_y_pos <= size) THEN
                    ball_y_motion <= to_signed(1, 10);
                ELSE
                    -- Check if left click should be handled based on sw9
                    IF (sw9 = '1') AND (left_click = '1') THEN
                        ball_y_motion <= to_signed(-10, 10); -- Move up rapidly
                    ELSE
                        ball_y_motion <= to_signed(1, 10); -- Gravity pulls down slowly
                    END IF;
                END IF;
                ball_y_pos <= ball_y_pos + ball_y_motion;
            END IF;
            prev_left_click <= left_click;
        END IF;
    END PROCESS Move_Ball;
END behavior;