LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

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

BEGIN
	altsyncram_component : altsyncram
	GENERIC MAP (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "bird_sprite.mif", -- bird_sprite MIF file to initialize
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
		q_a => data_out
	);
END SYN;