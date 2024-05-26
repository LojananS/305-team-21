LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE game_type_pkg IS
    TYPE state_type IS (HOME, START, PAUSE, RESET_GAME, GAME_END, TRAINING);

    FUNCTION to_state_type (state : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN state_type;
    FUNCTION to_slv(s : state_type) RETURN STD_LOGIC_VECTOR;
END PACKAGE game_type_pkg;
