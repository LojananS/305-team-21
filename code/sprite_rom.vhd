LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.NUMERIC_STD.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY sprite_rom IS
	PORT
	(
		clk				: 	IN STD_LOGIC;
		sprite_address	:	IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		data_out		:	OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END sprite_rom;


ARCHITECTURE SYN OF sprite_rom IS

	signal cycle_count : integer := 0;
	signal sprite_index : integer range 1 to 3 := 2;
	signal prev_sprite : integer range 1 to 3 := 2; -- Keep track of previous sprite to get correct state
	
	COMPONENT altsyncram
	GENERIC (
		address_aclr_a			: STRING;
		clock_enable_input_a	: STRING;
		clock_enable_output_a	: STRING;
		init_file				: STRING;
		intended_device_family	: STRING;
		lpm_hint				: STRING;
		lpm_type				: STRING;
		numwords_a				: NATURAL;
		operation_mode			: STRING;
		outdata_aclr_a			: STRING;
		outdata_reg_a			: STRING;
		widthad_a				: NATURAL;
		width_a					: NATURAL;
		width_byteena_a			: NATURAL
	);
	PORT (
		clock0		: IN STD_LOGIC ;
		address_a	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_a			: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
	END COMPONENT;
	
	SIGNAL rom1_data, rom2_data, rom3_data : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN
	ROM1 : altsyncram
	GENERIC MAP (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "bird_sprite1.mif", -- Gets state of bird_sprite
		intended_device_family => "Cyclone V",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 256, -- Depth of 256
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		widthad_a => 8, -- Address width of 8 e.g. 00 to FF is converted to binary by Synthesis tool
		width_a => 3, -- RGB data width is 3 e.g. 000 to 111
		width_byteena_a => 1
	)
	PORT MAP (
		clock0 => clk,
		address_a => sprite_address,
		q_a => rom1_data
	);
	
	ROM2 : altsyncram
	GENERIC MAP (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "bird_sprite2.mif", -- Gets state of bird_sprite2
		intended_device_family => "Cyclone V",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 256, -- Depth of 256
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		widthad_a => 8, -- Address width of 8 e.g. 00 to FF is converted to binary by Synthesis tool
		width_a => 3, -- RGB data width is 3 e.g. 000 to 111
		width_byteena_a => 1
	)
	PORT MAP (
		clock0 => clk,
		address_a => sprite_address,
		q_a => rom2_data
	);
	
	ROM3 : altsyncram
	GENERIC MAP (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "bird_sprite3.mif", -- Gets state of bird_sprite
		intended_device_family => "Cyclone V",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 256, -- Depth of 256
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		widthad_a => 8, -- Address width of 8 e.g. 00 to FF is converted to binary by Synthesis tool
		width_a => 3, -- RGB data width is 3 e.g. 000 to 111
		width_byteena_a => 1
	)
	PORT MAP (
		clock0 => clk,
		address_a => sprite_address,
		q_a => rom3_data
	);
	
	-- Multiplexer for selecting
	with sprite_index select
		data_out <= rom1_data when 1,
						rom2_data when 2,
						rom3_data when 3,
						rom2_data when others;

	-- Process to select the states
	output_state_decode : process (clk)
	begin
		if (rising_edge(clk)) then
			if (cycle_count >= 12500000) then
			-- Finite State Machine for the bird_sprite
				case sprite_index is
					when 1 =>
						sprite_index <= 2;
						prev_sprite <= 1;
					when 2 =>
						if (prev_sprite = 3) then
							sprite_index <= 1;
							prev_sprite <= 2;
						else
							sprite_index <= 3;
							prev_sprite <= 2;
						end if;
					when 3 =>
						sprite_index <= 2;
						prev_sprite <= 3;
					when others =>
						sprite_index <= 2;
						prev_sprite <= 2;
				end case;
				cycle_count <= 0; -- Resets counter to 0
			else
				cycle_count <= cycle_count + 1;
			end if;
		end if;
	end process;
END SYN;