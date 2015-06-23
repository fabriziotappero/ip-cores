library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.basic_size.all;
package basic_component is
component parallel_find_top is
GENERIC (N: NATURAL := N ;  WIDTH :NATURAL := WIDTH);
port ( a : in WORD_ARRAY;
       y : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
         );
end component parallel_find_top;

component mux_sel is
GENERIC (level:INTEGER:=0; Cell_count:INTEGER:=8);
port(
	left_op:	in std_logic_vector(Cell_count-1 downto 0 );
	right_op: 	in std_logic_vector(Cell_count-1  downto 0 ); 
	o: 	out std_logic_vector(Cell_count-1 downto 0 )
);
end component mux_sel;

component  Ripple is
GENERIC (cells :  Natural:=6);
port(
	left_op :	IN std_logic_vector (cells -1  DOWNTO 0);
	right_op : 	IN std_logic_vector (cells -1  DOWNTO 0);
	choose_cur : out std_logic;
	found_cur : out std_logic;
	choose_sel : 	OUT std_logic_vector (cells -1  DOWNTO 0));
end component Ripple;
component Result is
GENERIC (Cell_count :  Natural:=6);
port(
	i1:	in std_logic_vector(Cell_count-1 downto 0);
	i2: 	in std_logic_vector(Cell_count-1  downto 0); 
	choose_sel : In  std_logic_vector(Cell_count-1 downto 0);
	o: 	out std_logic_vector(Cell_count-1 downto 0 ));
	end component Result;
	
COMPONENT carry_cell_NOR is
port(
	a:	IN std_logic;
	b: 	IN std_logic;
	choose_prev		: in std_logic;
	found_prev 		: in std_logic;
	choose_cur_bar 		: out std_logic;
	found_cur_bar 		: out std_logic);
end COMPONENT carry_cell_NOR;
COMPONENT carry_cell_NAND is
port(
	a:	IN std_logic;
	b: 	IN std_logic;
	choose_prev_bar		: in std_logic;
	found_prev_bar 		: in std_logic;
	choose_cur 		: out std_logic;
	found_cur 		: out std_logic);
end COMPONENT carry_cell_NAND;


end package basic_component; 

package body basic_component is
end package body;