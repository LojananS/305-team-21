library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.game_type_pkg.ALL;

entity Game_FSM is
	PORT(
		clk, sw9, pb1, pb2, pb3, left_click : IN STD_LOGIC;
		state_in		: IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Input state
		state_out	: OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- Output state
	);
end entity Game_FSM;

architecture structural of Game_FSM is
	signal game_state : state_type := HOME;
	signal prev_pb1, prev_pb2 : std_logic := '1';

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
                if (pb2 = '0' and prev_pb2 = '1') then
                    game_state <= PAUSE;
                elsif (pb3 = '1') then
                    game_state <= RESET_GAME;
                end if;
				when PAUSE =>
					state_out <= to_slv(PAUSE);
                if (pb2 = '0' and prev_pb2 = '0') then
                    game_state <= START;
                end if;
				when RESET_GAME =>
					if (left_click = '1') then
						state_out <= to_slv(START);
						game_state <= START;
					else
						state_out <= to_slv(RESET_GAME);
						game_state <= RESET_GAME;
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
	 
	 Pb_Check : process (clk)
	 begin
		if (rising_edge(clk)) then
			prev_pb2 <= pb2;
		end if;
	 end process;
end architecture structural;