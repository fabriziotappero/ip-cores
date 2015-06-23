library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.leval_package.all;

entity alu is
	port (
		in_a		: in std_logic_vector(OBJECT_SIZE-1 downto 0);
		in_b		: in std_logic_vector(OBJECT_SIZE-1 downto 0);
		funct		: in std_logic_vector(FUNCT_SIZE-1 downto 0);
		status	: out std_logic_vector(STATUS_REG_SIZE-1 downto 0);
		output	: out std_logic_vector(OBJECT_SIZE-1 downto 0));
end entity alu;

architecture rtl of alu is
-- DIVIDER IS TOO SLOW, DISABLED
--	component divider is
--		GENERIC(WIDTH_DIVID : Integer := 32;			  -- Width Dividend
--			WIDTH_DIVIS : Integer := 16);			  -- Width Divisor
--		port(dividend  : in     std_logic_vector (WIDTH_DIVID-1 downto 0);
--      	divisor   : in     std_logic_vector (WIDTH_DIVIS-1 downto 0);
--      	quotient  : out    std_logic_vector (WIDTH_DIVID-1 downto 0);
--      	remainder : out    std_logic_vector (WIDTH_DIVIS-1 downto 0));
--	end component divider;
	
	signal mul_res : std_logic_vector(DATUM_SIZE*2-3 downto 0);
	
	signal type_a : std_logic_vector(TYPE_SIZE-1 downto 0);
	signal gc_flag_a : std_logic;
	signal datum_a : std_logic_vector(DATUM_SIZE-1 downto 0);
	signal type_b : std_logic_vector(TYPE_SIZE-1 downto 0);
	signal gc_flag_b : std_logic;
	signal datum_b : std_logic_vector(DATUM_SIZE-1 downto 0);
	signal type_r : std_logic_vector(TYPE_SIZE-1 downto 0);
	signal gc_flag_r : std_logic;
	signal datum_r : std_logic_vector(DATUM_SIZE-1 downto 0);
	
--	signal div_r : std_logic_vector(DATUM_SIZE-1 downto 0);
--	signal mod_r : std_logic_vector(DATUM_SIZE-1 downto 0);
--	signal fti_r : std_logic_vector(DATUM_SIZE-1 downto 0);
--	signal itf_r : std_logic_vector(DATUM_SIZE-1 downto 0);
--	signal fad_r : std_logic_vector(DATUM_SIZE-1 downto 0);
--	signal fml_r : std_logic_vector(DATUM_SIZE-1 downto 0);
--	signal fdv_r : std_logic_vector(DATUM_SIZE-1 downto 0);
	
--	signal fti_v, fti_a : std_logic;
--	signal fad_v, fad_u, fad_a : std_logic;
--	signal fml_v, fml_u, fml_a : std_logic;
--	signal fdv_v, fdv_u, fdv_a, fdv_zero : std_logic;
	
begin

--	divider_inst : divider
--	generic map (26,26)
--	port map (
--		dividend => datum_a,
--		divisor => datum_b,
--		quotient => div_r,
--		remainder => mod_r);
--		

	-- Decode inputs
	type_a <= in_a(OBJECT_SIZE-1 downto 27);
	gc_flag_a <= in_a(26);
	datum_a <= in_a(25 downto 0);
	type_b <= in_b(OBJECT_SIZE-1 downto 27);
	gc_flag_b <= in_b(26);
	datum_b <= in_b(25 downto 0);
	
	-- SET STATUS FLAGS
	-- Overflow
	status(OVERFLOW) <= '0' when (mul_res(49 downto 25) = (mul_res(49 downto 25) xor mul_res(49 downto 25))) else '1';
	-- negative
	status(NEG) <= datum_r(25);
	-- zero
	status(ZERO) <= '1' when datum_r = (datum_r xor datum_r) else '0';
	-- type error
	status(TYP) <= '0' when type_a = type_b else '1';
	-- io-error
	status(IO) <= '0';
	--unused
	status(1) <= '0';
	status(6) <= '0';
	status(7) <= '0';
	
	mul_res <= (datum_a(24 downto 0) * datum_b(24 downto 0));
	
	-- set output to result
	output <= type_r & gc_flag_r & datum_r;
	
	process(funct, type_a, type_b, gc_flag_a, gc_flag_b, datum_a, datum_b, mul_res)
	begin
		type_r <= (others => '0');
		gc_flag_r <= '0';
		datum_r  <= (others => '0');
		case funct is
			when ALU_ADD =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= datum_a + datum_b;
				
			when ALU_SUB =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= datum_a - datum_b;
				
			when ALU_MUL =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r(24 downto 0) <= mul_res(24 downto 0);
				datum_r(25) <= datum_a(25) xor datum_b(25);
				
--			when ALU_DIV =>
--				type_r <= type_a;
--				gc_flag_r <= gc_flag_a;
--				datum_r <= div_r;
--				
--			when ALU_MOD =>
--				type_r <= type_a;
--				gc_flag_r <= gc_flag_a;
--				datum_r <= mod_r;
				
			when ALU_AND =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= datum_a and datum_b;
				
			when ALU_OR =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= datum_a or datum_b;
				
			when ALU_XOR =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= datum_a xor datum_b;
				
			when ALU_GET_TYPE =>
				type_r <= DT_INT;
				gc_flag_r <= '0';
				datum_r(TYPE_SIZE - 1 downto 0) <= type_b;
				datum_r(DATUM_SIZE - 1 downto TYPE_SIZE) <= (others => '0');
				
			when ALU_SET_TYPE =>
				type_r <= datum_b(TYPE_SIZE-1 downto 0);
				gc_flag_r <= '0';
				datum_r <= datum_a;
				
			when ALU_SET_DATUM =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= datum_b;
				
			when ALU_SET_GC =>
				type_r <= type_a;
				gc_flag_r <= datum_b(0);
				datum_r <= datum_a;
				
			when ALU_GET_GC =>
				type_r <= DT_INT;
				gc_flag_r <= '0';
				datum_r(0) <= gc_flag_b;
				datum_r(DATUM_SIZE - 1 downto 1) <= (others => '0');
				
			when ALU_CPY =>
				type_r <= type_b;
				gc_flag_r <= gc_flag_b;
				datum_r <= datum_b;
				
			-- shift right
			when ALU_SR =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= std_logic_vector(shift_right(unsigned(datum_a), 
					to_integer(unsigned(datum_b))));
				
			-- shift left
			when ALU_SL =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= std_logic_vector(shift_left(unsigned(datum_a), 
					to_integer(unsigned(datum_b))));
				
			when ALU_CMP_DATUM =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= datum_a - datum_b;
				
			when ALU_CMP_TYPE =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= "000000000000000000000" & (type_a - type_b);
				
			when ALU_CMP_TYPE_IMM =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= "000000000000000000000" & (type_a - datum_b(TYPE_SIZE - 1 downto 0));
				
			when ALU_CMP_GC =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= "0000000000000000000000000"&(gc_flag_a xor gc_flag_b);
				
			when ALU_CMP_GC_IMM =>
				type_r <= type_a;
				gc_flag_r <= gc_flag_a;
				datum_r <= "0000000000000000000000000"&(gc_flag_a xor datum_b(0));
				
			when ALU_CMP =>
				if type_a = type_b and
					datum_a = datum_b then -- we have equivalent objects
					datum_r <= (others => '0');
				else
					datum_r(DATUM_SIZE-1 downto DATUM_SIZE-4) <= "1111";
					datum_r(DATUM_SIZE-5 downto 0) <= (others => '0'); -- not same
				end if;
				
			when others =>
				type_r <= (others => '0');
				gc_flag_r <= '0';
				datum_r  <= (others => '0');
				
		end case;
	end process;
end rtl;
