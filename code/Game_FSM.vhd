library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Game_FSM is
	PORT(
		sw9, pb1, pb2, pb3, left_click : IN STD_LOGIC;
		state_out	: OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- Output state
	);
end entity Game_FSM;

architecture structural of Game_FSM is

-- SW9, PB1, PB2, PB3, LEFT_CLICK,
-- 4	, 3  , 2  , 1	, 0

	type state_type is (HOME, START, PAUSE, RESET, GAME_END);
	signal game_state : state_type := HOME;

begin
-- Process to select state
    output_state_decode : process (sw9, pb1, pb2, pb3, left_click)
    begin
			case game_state is
				when HOME =>
					state_out <= "0000";
					if (left_click = '1') then
						game_state <= START;
					end if;
				when START =>
					state_out <= "0001";
					if (pb2 = '1') then
				when PAUSE =>
					state_out <= "0010";
				when RESET =>
					state_out <= "0011";
				when GAME_END =>
					state_out <= "0100";
				when others =>
					state_out <= "0000";
				end case;
    end process;
end architecture structural;