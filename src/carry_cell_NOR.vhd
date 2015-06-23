library ieee;
use ieee.std_logic_1164.all;
use work.basic_size.all;
entity carry_cell_NOR is
port(
	a:	IN std_logic;
	b: 	IN std_logic;
	choose_prev	: in std_logic;
	found_prev 		: in std_logic;
	choose_cur_bar 		: out std_logic;
	found_cur_bar 		: out std_logic
);
end carry_cell_NOR;
architecture behav of carry_cell_NOR  is

SIGNAL	found:	 	  std_logic;
SIGNAL	choose: 	  std_logic; 
SIGNAL	gci: 	 	  std_logic;
SIGNAL	gfi: 	 	  std_logic;
begin 
			gci 		<=  (NOT b) NAND a;
			gfi 		<=  ( a XOR b);
			choose_cur_bar<=  choose_prev NOR (found_prev NOR gci);
			found_cur_bar   	<=  ( (found_prev) NOR gfi);
end behav;