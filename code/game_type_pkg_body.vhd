LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.game_type_pkg.ALL;

PACKAGE BODY game_type_pkg IS
    FUNCTION to_state_type (state : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN state_type IS
    BEGIN
        CASE state IS
            WHEN "0000" => RETURN HOME;
            WHEN "0001" => RETURN START;
            WHEN "0010" => RETURN PAUSE;
            WHEN "0011" => RETURN RESET_GAME;
            WHEN "0100" => RETURN GAME_END;
				WHEN "0101" => RETURN TRAINING;
            WHEN OTHERS => RETURN HOME;
        END CASE;
    END FUNCTION;

    FUNCTION to_slv(s : state_type) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE s IS
            WHEN HOME      => RETURN "0000";
            WHEN START     => RETURN "0001";
            WHEN PAUSE     => RETURN "0010";
            WHEN RESET_GAME=> RETURN "0011";
            WHEN GAME_END  => RETURN "0100";
				WHEN TRAINING  => RETURN "0101";
            WHEN OTHERS    => RETURN "0000";
        END CASE;
    END FUNCTION;
END PACKAGE BODY game_type_pkg;
