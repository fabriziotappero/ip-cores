--! @file
--! @brief Instruction Register (IR)
--! @details It is a part of the control unit.										\n
--! The output of the IR is 8-bit word. It is divided into two nibbles.		\n
--! Upper Nibble			Lower Nibble													\n
--! 2-state					3-state															\n
--! CU						W-bus																\n
--! The provided instruction set is:													\n
--! LDA \t 0000 Load Accumulator with corresponding memory content					\n													
--! ADD \t 0001 Add the content of the AC to the content of the memory adder		\n 
--! SUB \t 0010 Subtract the content of the memory location from the AC			\n
--! OUT \t 1110 Transfer the AC content to the output port								\n
--! HLT \t 1111 Stop processing data															\n
--! Fetch 	= 3 cycles
--! Execute = 3 cycles

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY IR IS
 port (	clk	: in  std_logic;								--! Rising edge clock
			clr	: in  std_logic;								--! Active high asynchronous clear
			li		: in  std_logic;								--! Active low load instruction into IR
			ei 	: in  std_logic;								--! Active low enable IR output
			d		: in  std_logic_vector(7 downto 0);		--! IR 8-bit input data word from W-bus
			q_w	: out std_logic_vector(3 downto 0);		--! IR 4-bit output data word to W-bus
			q_c 	: out std_logic_vector(3 downto 0));	--! IR 4-bit output control word to Control-Sequencer block
END IR ;

ARCHITECTURE behave OF IR IS
BEGIN
process (clr,clk,li,ei)
begin
 if clr = '1' then
	q_w <= (others => '0');
	q_c <= (others => '0');
 elsif rising_edge(clk) then
	if li = '0' then 
		q_c <= d(7 downto 4);
	end if;
 end if;
 		if ei = '0' then q_w <= d(3 downto 0);
		else  q_w <= "ZZZZ";
		end if;
end process;
END behave;

