LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY galois_lfsr IS
    PORT
    (
        clk : IN std_logic;
        reset : IN std_logic;
        random_value : OUT std_logic_vector(9 DOWNTO 0) -- 10-bit LFSR
    );
END galois_lfsr;

ARCHITECTURE behavior OF galois_lfsr IS
    SIGNAL lfsr_reg : std_logic_vector(9 DOWNTO 0) := "0000000001"; -- Seed value
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            lfsr_reg <= "0000000001"; -- Reset to seed value
        ELSIF rising_edge(clk) THEN
            lfsr_reg <= lfsr_reg(8 DOWNTO 0) & (lfsr_reg(9) XOR lfsr_reg(6)); -- Taps at positions 9 and 6
        END IF;
    END PROCESS;
    random_value <= lfsr_reg;
END behavior;
