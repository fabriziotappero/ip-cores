----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:11:55 11/27/2009 
-- Design Name: 
-- Module Name:    IPV4_LUT_INDEXER - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IPV4_LUT_INDEXER is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           transmit_enable : in  STD_LOGIC;
           LUT_index : out  STD_LOGIC_VECTOR (5 downto 0));
end IPV4_LUT_INDEXER;

architecture Behavioral of IPV4_LUT_INDEXER is

component dist_mem_64x8 is
  port (
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 5 downto 0 ); 
    qspo : out STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end component;

component COUNTER_6B_LUT_FIFO_MODE is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           funct_sel : in  STD_LOGIC; -- 0 for lut addressing, 1 for fifo addressing -- only LUT support is used
           count_en : in  STD_LOGIC;
           value_O : inout  STD_LOGIC_VECTOR (5 downto 0));
end component;

component comp_6b_equal is
  port (
    qa_eq_b : out STD_LOGIC; 
    clk : in STD_LOGIC := 'X'; 
    a : in STD_LOGIC_VECTOR ( 5 downto 0 ); 
    b : in STD_LOGIC_VECTOR ( 5 downto 0 ) 
  );
end component;

signal count_en_sig , count_end , rst_counter: std_logic :='0';
signal count_val: std_logic_Vector(5 downto 0):=(others=>'0');
signal count_en_sig_comb : std_logic;
constant lut_upper_address :std_logic_vector(5 downto 0):="100110"; -- position 38

begin

process(clk)
begin
if (rst='1' or count_end='1') then	
	count_en_sig<='0';
	rst_counter<='1';
else
   rst_counter<='0';
	if clk'event and clk='1' then
		if (transmit_enable='1' and count_en_sig='0') then
			count_en_sig<='1';
		end if;
	end if;
end if;
end process;

LUT_END_CHECK : comp_6b_equal port map (
qa_eq_b =>count_end, 
    clk =>clk,
    a =>count_val,
    b =>lut_upper_address

);

count_en_sig_comb <=count_en_sig or transmit_enable;



LUT_INDEXER_MODULE : COUNTER_6B_LUT_FIFO_MODE port map (
	rst => rst_counter,
   clk => clk,
   funct_sel =>'0', -- for now only one function is supported
   count_en =>count_en_sig_comb,
   value_O =>count_val
);

LUT_index<=count_val;


end Behavioral;

