LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.NUMERIC_STD.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY pipe_rom IS
    PORT
    (
        clk             :   IN STD_LOGIC;
        pipe_address  :   IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        data_out        :   OUT STD_LOGIC_VECTOR(12 DOWNTO 0) -- Updated to 12 bits
    );
END pipe_rom;

ARCHITECTURE PIPE_SYN OF pipe_rom IS

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
        q_a         : OUT STD_LOGIC_VECTOR (12 DOWNTO 0) -- Updated to 13 bits
    );
    END COMPONENT;

    SIGNAL pipe_rom1_data : STD_LOGIC_VECTOR(12 DOWNTO 0); -- Updated to 13 bits

BEGIN
    pipe_rom1 : altsyncram
    GENERIC MAP (
        address_aclr_a => "NONE",
        clock_enable_input_a => "BYPASS",
        clock_enable_output_a => "BYPASS",
        init_file => "pipe.mif", -- Pipe MIF file with 12 bit color depth
        intended_device_family => "Cyclone V",
        lpm_hint => "ENABLE_RUNTIME_MOD=NO",
        lpm_type => "altsyncram",
        numwords_a => 57600, -- Depth of address
        operation_mode => "ROM",
        outdata_aclr_a => "NONE",
        outdata_reg_a => "UNREGISTERED",
        widthad_a => 16, -- Since depth of address is 57600, we need 2^16
        width_a => 13, -- 12-bit color and 1 parity
        width_byteena_a => 1
    )
    PORT MAP (
        clock0 => clk,
        address_a => pipe_address,
        q_a => pipe_rom1_data -- Set to pipe_rom1_data signal
    );
	 data_out <= pipe_rom1_data;
END PIPE_SYN;
