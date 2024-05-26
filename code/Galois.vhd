LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.game_type_pkg.ALL;

ENTITY galois_lfsr IS
    PORT
    (
        clk : IN std_logic;
        state_in : IN std_logic_vector(3 DOWNTO 0); -- Game State
        random_value : OUT std_logic_vector(9 DOWNTO 0) -- 10-bit LFSR
    );
END galois_lfsr;

ARCHITECTURE behavior OF galois_lfsr IS
    SIGNAL lfsr_reg : std_logic_vector(9 DOWNTO 0) := "0000000001"; -- Initial value
    SIGNAL dynamic_seed : std_logic_vector(9 DOWNTO 0) := "0000000000";
    SIGNAL seed_counter : unsigned(9 DOWNTO 0) := (others => '0'); -- 10-bit counter
BEGIN
    PROCESS (clk, state_in)
    BEGIN
<<<<<<< HEAD
        IF reset = '1' THEN
            seed_counter <= (others => '0'); -- Reset the counter
            dynamic_seed <= lfsr_reg; -- Use current LFSR value as seed
            lfsr_reg <= dynamic_seed; -- Reset LFSR to dynamic seed
=======
        IF (to_state_type(state_in) = RESET_GAME) THEN
            lfsr_reg <= "0000000001"; -- Reset to seed value
>>>>>>> 575764bd812c766414a2f0f66cce07d4ea17232f
        ELSIF rising_edge(clk) THEN
            -- Update the LFSR value
            lfsr_reg <= lfsr_reg(8 DOWNTO 0) & (lfsr_reg(9) XOR lfsr_reg(6)); -- Taps at positions 9 and 6
            -- Increment the seed counter
            seed_counter <= seed_counter + 1;
            -- Update the dynamic seed periodically (every 1024 cycles)
            IF seed_counter = 1023 THEN
                dynamic_seed <= lfsr_reg; -- Capture the current LFSR value as the new seed
            END IF;
        END IF;
    END PROCESS;
    random_value <= lfsr_reg;
END behavior;
