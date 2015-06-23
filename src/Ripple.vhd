library ieee;
use ieee.std_logic_1164.all;
use work.basic_size.all;
use work.basic_component.all;
entity Ripple is
GENERIC (cells :  Natural:=8);
port(
	left_op :	IN std_logic_vector (cells -1  DOWNTO 0);
	right_op : 	IN std_logic_vector (cells -1  DOWNTO 0);
	choose_cur : out std_logic;
	found_cur : out std_logic;
	choose_sel : 	OUT std_logic_vector (cells -1  DOWNTO 0));
end entity Ripple;
architecture behav of Ripple  is
SIGNAL	found_i:	 std_logic_vector (cells+1  DOWNTO 0);
SIGNAL	choose_i: 	 std_logic_vector (cells+1  DOWNTO 0); 
SIGNAL	a: 	 std_logic_vector (cells  DOWNTO 0); 
SIGNAL	b: 	 std_logic_vector (cells  DOWNTO 0); 
SIGNAL	sel_out: 	 std_logic_vector (cells  DOWNTO 0);
begin

   choose_i(2*((cells+1 )/ 2)) <= '0';
   found_i (2*((cells+1 )/ 2))  <= '0';
--rename inputs
 re_g:IF (cells mod 2) =0 GENERATE 
    a(cells-1   DOWNTO 0)  <= left_op;
    b(cells-1   DOWNTO 0)  <= right_op;
END GENERATE re_g;
 --PADDING with zero's
--- PADDING ODD to EVEN
pad_gen : IF (cells mod 2) /=0 GENERATE 
     a  <= left_op  & '0';
     b  <= right_op & '0';
END GENERATE pad_gen;

-- Start based on the number of Bits if Even or Odd
-- Sure not equal zero 
--even_cell :
 g_ripple : FOR i In ((cells+1)/2 )  downto 1 generate
	BEGIN
	 carry_cell_NOR_Inst : carry_cell_NOR    PORT MAP (
			a =>a(2*i-1), b=>b(2*i-1),
			choose_prev =>choose_i(2*i ),
			found_prev  =>found_i(2*i ),
			choose_cur_bar =>choose_i(2*i-1 ),
			found_cur_bar  =>found_i(2*i -1 ));
			--Result Muxing
			sel_out(2*i-1)  <= NOT choose_i(2*i-1);
	carry_cell_NAND_Inst : carry_cell_NAND PORT MAP(
			a =>a(2*i -2), b=>b(2*i -2),
			choose_prev_bar =>choose_i(2*i-1),
			found_prev_bar  =>found_i(2*i -1 ),
			choose_cur =>choose_i(2*i  - 2),
			found_cur  =>found_i(2*i  - 2));
			sel_out (2*i  - 2)  <= choose_i(2*i  - 2);
	end generate g_ripple;
  choose_sel <= sel_out(2*((cells+1)/2)-1  DOWNTO (cells mod 2));
  choose_cur <=choose_i(cells mod 2) ;
  found_cur <=  found_i(cells mod 2);
 
end behav;