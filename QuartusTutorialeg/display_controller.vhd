LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.NUMERIC_STD.all;

ENTITY display_controller IS
	PORT
		( clk, ball_on, pipe_on, background_on	: IN std_logic;
			RGB_ball, RGB_pipe, RGB_background					: IN std_logic_vector(2 downto 0);
		  red, green, blue 			: OUT std_logic);		
END display_controller;

ARCHITECTURE beh OF display_controller IS


BEGIN
	process(pipe_on, ball_on, background_on, RGB_pipe, RGB_ball, RGB_background)
begin
    if pipe_on = '1' then
        red <= RGB_pipe(2);
        green <= RGB_pipe(1);
        blue <= RGB_pipe(0);
    elsif ball_on = '1' then
        red <= RGB_ball(2);
        green <= RGB_ball(1);
        blue <= RGB_ball(0);
    else
        red <= RGB_background(2);
        green <= RGB_background(1);
        blue <= RGB_background(0);
    end if;
end process;

END ARCHITECTURE beh;