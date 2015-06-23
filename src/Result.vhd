library ieee;
use ieee.std_logic_1164.all;
use work.basic_size.all;
entity Result is
GENERIC (Cell_count :  Natural:=5);
port(
	i1:	in std_logic_vector(Cell_count-1 downto 0);
	i2: 	in std_logic_vector(Cell_count-1  downto 0); 
		choose_sel : In  std_logic_vector(Cell_count-1 downto 0);
	o: 	out std_logic_vector(Cell_count-1 downto 0 )
);
end Result;
architecture behav of Result  is


begin

--Result
 out_g : for i in 0  to Cell_count-1 generate 
		with choose_sel(i) select 
		     o(i) <= i1(i) when '1' , i2(i) when '0';
		end generate out_g;
	
		
end behav;