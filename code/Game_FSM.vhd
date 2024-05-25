library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.game_type_pkg.ALL;

entity Game_FSM is
	PORT(
		sw9, pb1, pb2, pb3, left_click : IN STD_LOGIC;
		state_in		: IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Input state
		state_out	: OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- Output state
	);
end entity Game_FSM;

architecture structural of Game_FSM is
	signal game_state : state_type := HOME;

begin
-- Process to select state
    output_state_decode : process (sw9, pb1, pb2, pb3, left_click)
    begin
			game_state <= to_state_type(state_in);
			case game_state is
				when HOME =>
					state_out <= to_slv(HOME);
					if (left_click = '1') then
						game_state <= START;
					end if;
				when START =>
					state_out <= to_slv(START);
                if (pb2 = '1') then
                    game_state <= PAUSE;
                elsif (pb3 = '1') then
                    game_state <= RESET;
                elsif (sw9 = '1') then
                    game_state <= GAME_END;
                end if;
				when PAUSE =>
					state_out <= to_slv(PAUSE);
                if (pb2 = '1') then
                    game_state <= START;
                end if;
				when RESET =>
					state_out <= to_slv(RESET);
					if (left_click = '1') then
						game_state <= START;
					end if;
				when GAME_END =>
					state_out <= to_slv(GAME_END);
						if (left_click = '1') then
							game_state <= START;
						end if;
				when others =>
					state_out <= to_slv(HOME);
			end case;
    end process;
end architecture structural;