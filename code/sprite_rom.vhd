LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.NUMERIC_STD.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY sprite_rom IS
    PORT
    (
        clk             :   IN STD_LOGIC;
        sprite_address  :   IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        data_out        :   OUT STD_LOGIC_VECTOR(11 DOWNTO 0) -- Updated to 12 bits
    );
END sprite_rom;

ARCHITECTURE SYN OF sprite_rom IS

    signal cycle_count : integer range 0 to 2500000 := 0;
    signal sprite_index : integer range 0 to 2 := 1;
    signal prev_sprite : integer range 0 to 2 := 1; -- Keep track of previous sprite to get correct state
	 SIGNAL base_address    : STD_LOGIC_VECTOR(11 DOWNTO 0);
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
    BIRD_ROM : altsyncram
    GENERIC MAP (
        address_aclr_a => "NONE",
        clock_enable_input_a => "BYPASS",
        clock_enable_output_a => "BYPASS",
        init_file => "bird_sprite.mif", -- Bird state up MIF file with 12 bit color depth
        intended_device_family => "Cyclone V",
        lpm_hint => "ENABLE_RUNTIME_MOD=NO",
        lpm_type => "altsyncram",
        numwords_a => 3072, -- Depth of address
        operation_mode => "ROM",
        outdata_aclr_a => "NONE",
        outdata_reg_a => "UNREGISTERED",
        widthad_a => 12, -- Since depth of address is 3072, we need 2^12
        width_a => 12, -- 12-bit color
        width_byteena_a => 1
    )
    PORT MAP (
        clock0 => clk,
        address_a => combined_address,
        q_a => rom_data -- Set to rom_data
    );

    -- Process to cycle through sprites based on the clock and a counter
    output_state_decode : process (clk)
    begin
        if rising_edge(clk) then
            if cycle_count >= 2500000 then -- Timer to cycle sprites
                -- Update sprite indices to cycle through different sprites
                case sprite_index is
                    when 0 =>
								base_address <= "000000000000"; -- 0000 in Binary
                        sprite_index <= 1;
                        prev_sprite <= 0;
                    when 1 =>
                        if prev_sprite = 2 then
                            sprite_index <= 0;
                        else
                            sprite_index <= 2;
                        end if;
								base_address <= "010000000000"; -- 1024 in binary
                        prev_sprite <= 1;
                    when 2 =>
								base_address <= "100000000000"; -- 2048 in binary
                        sprite_index <= 1;
                        prev_sprite <= 2;
                    when others =>
								base_address <= "010000000000"; -- 1024 in binary
                        sprite_index <= 1; -- Default sprite state will be middle state
                end case;
                cycle_count <= 0; -- Reset cycle counter
            else
                cycle_count <= cycle_count + 1; -- Increment cycle count every clock cycle
            end if;
        end if;
    end process;

    -- Calculate the combined address
    combined_address <= std_logic_vector(unsigned(base_address) + unsigned(sprite_address));

    -- Assign ROM data to the output
    data_out <= rom_data;
END SYN;
