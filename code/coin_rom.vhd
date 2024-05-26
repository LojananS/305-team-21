LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.NUMERIC_STD.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY coin_rom IS
    PORT
    (
        clk              : IN STD_LOGIC;
        powerup_selected : IN integer range 0 to 3;
        coin_address     : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        coin_data_out    : OUT STD_LOGIC_VECTOR(11 DOWNTO 0) -- Updated to 12 bits
    );
END coin_rom;

ARCHITECTURE COIN_SYN OF coin_rom IS

    signal base_address : STD_LOGIC_VECTOR(11 DOWNTO 0);
    signal combined_address : STD_LOGIC_VECTOR(11 DOWNTO 0);

    COMPONENT altsyncram
    GENERIC (
        address_aclr_a          : STRING;
        clock_enable_input_a    : STRING;
        clock_enable_output_a   : STRING;
        init_file               : STRING;
        intended_device_family  : STRING;
        lpm_hint                : STRING;
        lpm_type                : STRING;
        numwords_a              : NATURAL;
        operation_mode          : STRING;
        outdata_aclr_a          : STRING;
        outdata_reg_a           : STRING;
        widthad_a               : NATURAL;
        width_a                 : NATURAL;
        width_byteena_a         : NATURAL
    );
    PORT (
        clock0      : IN STD_LOGIC;
        address_a   : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
        q_a         : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) -- Updated to 12 bits
    );
    END COMPONENT;

    SIGNAL rom_data : STD_LOGIC_VECTOR(11 DOWNTO 0); -- Updated to 12 bits

BEGIN
    POWER_ROM : altsyncram
    GENERIC MAP (
        address_aclr_a => "NONE",
        clock_enable_input_a => "BYPASS",
        clock_enable_output_a => "BYPASS",
        init_file => "powerup.MIF", -- powerup MIF file with 12 bit color depth
        intended_device_family => "Cyclone V",
        lpm_hint => "ENABLE_RUNTIME_MOD=NO",
        lpm_type => "altsyncram",
        numwords_a => 2560, -- Depth of address
        operation_mode => "ROM",
        outdata_aclr_a => "NONE",
        outdata_reg_a => "UNREGISTERED",
        widthad_a => 12, -- Since depth of address is 2560, we need 2^12
        width_a => 12, -- 12-bit color
        width_byteena_a => 1
    )
    PORT MAP (
        clock0 => clk,
        address_a => combined_address,
        q_a => rom_data -- Set to rom_data
    );

    -- Process to select base address based on powerup_selected
    select_base_address : process (powerup_selected)
    begin
        case powerup_selected is
            when 0 =>
                base_address <= "000000000000"; -- 0 in Binary
            when 1 =>
                base_address <= "001000000000"; -- 256 in Binary
            when 2 =>
                base_address <= "010000000000"; -- 512 in Binary
            when 3 =>
                base_address <= "110000000000"; -- 1536 in Binary
            when others =>
                base_address <= "000000000000"; -- Default to 0 in binary
        end case;
    end process select_base_address;

    -- Calculate the combined address
    combined_address <= std_logic_vector(unsigned(base_address) + unsigned(coin_address));

    -- Assign ROM data to the output
    coin_data_out <= rom_data;

END COIN_SYN;
