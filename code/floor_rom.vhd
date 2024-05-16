LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.NUMERIC_STD.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY floor_rom IS
    PORT
    (
        clk             :   IN STD_LOGIC;
        floor_address  :   IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Address is 16 bits
        data_out        :   OUT STD_LOGIC_VECTOR(11 DOWNTO 0) -- Set to 12 bits color depth
    );
END floor_rom;

ARCHITECTURE FloorSYN OF floor_rom IS

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
        clock0      : IN STD_LOGIC ;
        address_a   : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        q_a         : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) -- Updated to 12 bits
    );
    END COMPONENT;
	 
	 SIGNAL floor_rom_data : STD_LOGIC_VECTOR(11 DOWNTO 0);

BEGIN
    floor_rom_sync : altsyncram
    GENERIC MAP (
        address_aclr_a => "NONE",
        clock_enable_input_a => "BYPASS",
        clock_enable_output_a => "BYPASS",
        init_file => "floor.MIF", -- Floor MIF file with 12 bit color depth
        intended_device_family => "Cyclone V",
        lpm_hint => "ENABLE_RUNTIME_MOD=NO",
        lpm_type => "altsyncram",
        numwords_a => 19200, -- Depth of address is 19200
        operation_mode => "ROM",
        outdata_aclr_a => "NONE",
        outdata_reg_a => "UNREGISTERED",
        widthad_a => 15, -- Since depth of address is 19200, we need 2^15
        width_a => 12, -- 12-bit color
        width_byteena_a => 1
    )
    PORT MAP (
        clock0 => clk,
        address_a => floor_address,
        q_a => floor_rom_data -- Sends out the data to output
    );
	 
	 data_out <= floor_rom_data;
END FloorSYN;
