LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.NUMERIC_STD.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY sprite_rom IS
    PORT
    (
        clk             :   IN STD_LOGIC;
        sprite_address  :   IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        data_out        :   OUT STD_LOGIC_VECTOR(11 DOWNTO 0) -- Updated to 12 bits
    );
END sprite_rom;

ARCHITECTURE SYN OF sprite_rom IS

    signal cycle_count : integer range 0 to 2500000 := 0;
    signal sprite_index : integer range 1 to 3 := 2;
    signal prev_sprite : integer range 1 to 3 := 2; -- Keep track of previous sprite to get correct state

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
        address_a   : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        q_a         : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) -- Updated to 12 bits
    );
    END COMPONENT;

    SIGNAL rom1_data, rom2_data, rom3_data : STD_LOGIC_VECTOR(11 DOWNTO 0); -- Updated to 12 bits

BEGIN
    -- Each ROM instance needs to be updated similarly as below:
    ROM1 : altsyncram
    GENERIC MAP (
        address_aclr_a => "NONE",
        clock_enable_input_a => "BYPASS",
        clock_enable_output_a => "BYPASS",
        init_file => "yeji.mif", -- Ensure this MIF file is formatted for 12-bit data
        intended_device_family => "Cyclone V",
        lpm_hint => "ENABLE_RUNTIME_MOD=NO",
        lpm_type => "altsyncram",
        numwords_a => 1024,
        operation_mode => "ROM",
        outdata_aclr_a => "NONE",
        outdata_reg_a => "UNREGISTERED",
        widthad_a => 10,
        width_a => 12, -- Updated to 12 bits
        width_byteena_a => 1
    )
    PORT MAP (
        clock0 => clk,
        address_a => sprite_address,
        q_a => rom1_data
    );
	 
	 data_out <= rom1_data;

    -- Multiplexer for selecting the output data based on the sprite index
--    with sprite_index select
--        data_out <= rom1_data when 1,
--                    rom1_data when 2,
--                    rom1_data when 3,
--                    rom1_data when others;
--
--    -- Process to cycle through sprites based on the clock and a counter
--    output_state_decode : process (clk)
--    begin
--        if rising_edge(clk) then
--            if cycle_count >= 2500000 then -- Timer to cycle sprites
--                -- Update sprite indices to cycle through different sprites
--                case sprite_index is
--                    when 1 =>
--                        sprite_index <= 2;
--                        prev_sprite <= 1;
--                    when 2 =>
--                        if prev_sprite = 3 then
--                            sprite_index <= 1;
--                        else
--                            sprite_index <= 3;
--                        end if;
--                        prev_sprite <= 2;
--                    when 3 =>
--                        sprite_index <= 2;
--                        prev_sprite <= 3;
--                    when others =>
--                        sprite_index <= 2;
--                end case;
--                cycle_count <= 0; -- Reset cycle counter
--            else
--                cycle_count <= cycle_count + 1;
--            end if;
--        end if;
--    end process;
END SYN;
