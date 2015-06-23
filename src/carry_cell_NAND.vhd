library ieee;
use ieee.std_logic_1164.all;
use work.basic_size.all;
entity carry_cell_NAND is
port(
	a:	IN std_logic;
	b: 	IN std_logic;
	choose_prev_bar	: in std_logic;
	found_prev_bar 		: in std_logic;
	choose_cur 		: out std_logic;
	found_cur 		: out std_logic
);
end carry_cell_NAND;
architecture behav of carry_cell_NAND  is

SIGNAL	found:	 	  std_logic;
SIGNAL	choose: 	  std_logic; 
SIGNAL	gci: 	 	  std_logic;
SIGNAL	gfi: 	 	  std_logic;
begin 
			gci 		<=  (NOT a) NOR b;
			gfi 		<=   ( a XNOR b);
			choose_cur  	<=  choose_prev_bar NAND (found_prev_bar NAND gci);
			found_cur   	<=  found_prev_bar NAND gfi;
end behav;