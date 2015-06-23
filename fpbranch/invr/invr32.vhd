library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;




entity invr32 is 
	port (
		
		clk : in std_logic;
		dvd32: in std_logic_vector(31 downto 0);		
		qout32: out std_logic_vector(31 downto 0)
	);
end invr32;

architecture invr32_arch of invr32 is 

	component altsyncram
	generic (
		address_aclr_a		: string;
		clock_enable_input_a		: string;
		clock_enable_output_a		: string;
		init_file		: string;
		intended_device_family		: string;
		lpm_hint		: string;
		lpm_type		: string;
		numwords_a		: natural;
		operation_mode		: string;
		outdata_aclr_a		: string;
		outdata_reg_a		: string;
		widthad_a		: natural;
		width_a		: natural;
		width_byteena_a		: natural
	);
	port (
			clock0	: in std_logic ;
			address_a	: in std_logic_vector (9 downto 0);
			q_a	: out std_logic_vector (17 downto 0)
	);
	end component;

	signal s0sgn			: std_logic;
	signal s0uexp,s0e129	: std_logic_vector(7 downto 0);
	signal s0q				: std_logic_vector(17 downto 0);
	
begin
	
	altsyncram_component : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "X:/Tesis/Workspace/hw/rt_lib/arith/src/trunk/fpbranch/invr/meminvr.mif",
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 1024,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		widthad_a => 10,
		width_a => 18,
		width_byteena_a => 1
	)
	port map (
		clock0 => clk,
		address_a => dvd32(22 downto 13),
		q_a => s0q
	);
	--! SNAN?
	process (clk)
	begin
		if clk'event and clk='1' then
			
			--!Carga de Operando.
			s0sgn <= dvd32(31);
			s0uexp <= dvd32(30 downto 23);
			
			
			--! Etapa 0: Calcular direcci&oacute;n a partir del exponente, salida y normalizaci&oacute;n de la mantissa.
			qout32(31) <= s0sgn;
			if s0q(17)='1' then
				qout32(22 downto 7) <= (others => '0');
				qout32(30 downto 23) <= s0e129+255;
			else
				qout32(22 downto 7) <= s0q(15 downto 0);
				qout32(30 downto 23) <= s0e129+254;
			end if;	
		
		end if;
	end process;
	
	--! Combinatorial Gremlin: Etapa 0, calculo del exponente. 
	process(s0uexp)
	begin
		for i in 7 downto 0 loop 
			s0e129(i)<=not(s0uexp(i));
		end loop;
	end process;
	qout32(6 downto 0) <= (others => '0');

end invr32_arch;