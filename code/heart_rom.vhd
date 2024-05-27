LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY heart_rom IS
    PORT
    (
        clk             :   IN STD_LOGIC;
        heart1_on       :   IN STD_LOGIC;
        heart2_on       :   IN STD_LOGIC;
        heart3_on       :   IN STD_LOGIC;
        heart_address   :   IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        heart1_data_out :   OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
        heart2_data_out :   OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
        heart3_data_out :   OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
END heart_rom;

ARCHITECTURE HEART_SYN OF heart_rom IS

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
        address_a   : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        q_a         : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) -- Updated to 12 bits
    );
    END COMPONENT;

    SIGNAL heart1_address : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL heart2_address : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL heart3_address : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL rom1_data : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL rom2_data : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL rom3_data : STD_LOGIC_VECTOR(11 DOWNTO 0);

BEGIN
    -- ROM instance for heart 1
    HEART_ROM1 : altsyncram
    GENERIC MAP (
        address_aclr_a => "NONE",
        clock_enable_input_a => "BYPASS",
        clock_enable_output_a => "BYPASS",
        init_file => "hearts16.MIF",
        intended_device_family => "Cyclone V",
        lpm_hint => "ENABLE_RUNTIME_MOD=NO",
        lpm_type => "altsyncram",
        numwords_a => 512,
        operation_mode => "ROM",
        outdata_aclr_a => "NONE",
        outdata_reg_a => "UNREGISTERED",
        widthad_a => 9,
        width_a => 12,
        width_byteena_a => 1
    )
    PORT MAP (
        clock0 => clk,
        address_a => heart1_address,
        q_a => rom1_data
    );

    -- ROM instance for heart 2
    HEART_ROM2 : altsyncram
    GENERIC MAP (
        address_aclr_a => "NONE",
        clock_enable_input_a => "BYPASS",
        clock_enable_output_a => "BYPASS",
        init_file => "hearts16.MIF",
        intended_device_family => "Cyclone V",
        lpm_hint => "ENABLE_RUNTIME_MOD=NO",
        lpm_type => "altsyncram",
        numwords_a => 512,
        operation_mode => "ROM",
        outdata_aclr_a => "NONE",
        outdata_reg_a => "UNREGISTERED",
        widthad_a => 9,
        width_a => 12,
        width_byteena_a => 1
    )
    PORT MAP (
        clock0 => clk,
        address_a => heart2_address,
        q_a => rom2_data
    );

    -- ROM instance for heart 3
    HEART_ROM3 : altsyncram
    GENERIC MAP (
        address_aclr_a => "NONE",
        clock_enable_input_a => "BYPASS",
        clock_enable_output_a => "BYPASS",
        init_file => "hearts16.MIF",
        intended_device_family => "Cyclone V",
        lpm_hint => "ENABLE_RUNTIME_MOD=NO",
        lpm_type => "altsyncram",
        numwords_a => 512,
        operation_mode => "ROM",
        outdata_aclr_a => "NONE",
        outdata_reg_a => "UNREGISTERED",
        widthad_a => 9,
        width_a => 12,
        width_byteena_a => 1
    )
    PORT MAP (
        clock0 => clk,
        address_a => heart3_address,
        q_a => rom3_data
    );

    -- Select the address for heart 1
    heart1_address <= heart_address when heart1_on = '1' else (others => '0');

    -- Select the address for heart 2
    heart2_address <= heart_address when heart2_on = '1' else (others => '0');

    -- Select the address for heart 3
    heart3_address <= heart_address when heart3_on = '1' else (others => '0');

    -- Assign ROM data to the output
    heart1_data_out <= rom1_data;
    heart2_data_out <= rom2_data;
    heart3_data_out <= rom3_data;

END HEART_SYN;
