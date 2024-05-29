LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.NUMERIC_STD.all;

ENTITY display_controller IS
	PORT
		( ball_on, pipe_on, background_on, text_on, ground_on: IN std_logic;
			RGB_ball, RGB_pipe, RGB_background, RGB_ground	: IN std_logic_vector(11 downto 0);
		  red, green, blue 			: OUT std_logic_vector(3 downto 0));		
END display_controller;

ARCHITECTURE beh OF display_controller IS


BEGIN
	process(pipe_on, ball_on, background_on, text_on, ground_on, RGB_pipe, RGB_ball, RGB_background, RGB_ground)
begin
	if text_on = '1' then
		red <= "1110";
		green <= "1001";
		blue <= "0011";
	elsif ball_on = '1' then
		red <= RGB_ball(11 downto 8);
		green <= RGB_ball(7 downto 4);
		blue <= RGB_ball(3 downto 0);
	elsif ground_on = '1' then
		red <= RGB_ground(11 downto 8);
		green <= RGB_ground(7 downto 4);
		blue <= RGB_ground(3 downto 0);
	elsif pipe_on = '1' then
		red <= RGB_pipe(11 downto 8);
		green <= RGB_pipe(7 downto 4);
		blue <= RGB_pipe(3 downto 0);
	else
		red <= RGB_background(11 downto 8);
		green <= RGB_background(7 downto 4);
		blue <= RGB_background(3 downto 0);
    end if;
end process;

END ARCHITECTURE beh;