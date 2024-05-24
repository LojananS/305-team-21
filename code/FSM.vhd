-- File path: game_fsm.vhd
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ARCHITECTURE behavior OF game_fsm IS
    TYPE game_state_type IS (IDLE, PLAY, PAUSE, GAME_OVER);
    SIGNAL current_state, next_state : game_state_type := IDLE;

    SIGNAL start_internal : std_logic := '0';
    SIGNAL pause_internal : std_logic := '0';
    SIGNAL reset_internal_signal : std_logic := '0';
BEGIN
    -- State transition process
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            current_state <= IDLE;
        ELSIF rising_edge(clk) THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    -- Next state logic
    PROCESS (current_state, left_click, collision, pb2, sw0)
    BEGIN
        CASE current_state IS
            WHEN IDLE =>
                IF left_click = '1' THEN
                    next_state <= PLAY;
                ELSE
                    next_state <= IDLE;
                END IF;

            WHEN PLAY =>
                IF collision = '1' THEN
                    next_state <= GAME_OVER;
                ELSIF pb2 = '0' THEN
                    next_state <= PAUSE;
                ELSE
                    next_state <= PLAY;
                END IF;

            WHEN PAUSE =>
                IF pb2 = '0' THEN
                    next_state <= PLAY;
                ELSE
                    next_state <= PAUSE;
                END IF;

            WHEN GAME_OVER =>
                IF left_click = '1' THEN
                    next_state <= IDLE;
                ELSE
                    next_state <= GAME_OVER;
                END IF;

            WHEN OTHERS =>
                next_state <= IDLE;
        END CASE;
    END PROCESS;

    -- Output logic
    PROCESS (current_state)
    BEGIN
        CASE current_state IS
            WHEN IDLE =>
                start_internal <= '0';
                reset_internal_signal <= '0';
                pause_internal <= '0';

            WHEN PLAY =>
                start_internal <= '1';
                reset_internal_signal <= '0';
                pause_internal <= '0';

            WHEN PAUSE =>
                start_internal <= '0';
                reset_internal_signal <= '0';
                pause_internal <= '1';

            WHEN GAME_OVER =>
                start_internal <= '0';
                reset_internal_signal <= '1';
                pause_internal <= '0';

            WHEN OTHERS =>
                start_internal <= '0';
                reset_internal_signal <= '0';
                pause_internal <= '0';
        END CASE;
    END PROCESS;

    start <= start_internal;
    pause <= pause_internal;
    reset_internal <= reset_internal_signal;
    current_state <= std_logic_vector(to_unsigned(current_state, 2));
END behavior;
