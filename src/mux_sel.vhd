library ieee;
use ieee.std_logic_1164.all;
use work.basic_size.all;
use work.basic_component.all;
entity mux_sel is
GENERIC (level:INTEGER:=1; Cell_count:INTEGER:=width);
port(
	left_op:	in std_logic_vector(Cell_count-1 downto 0 );
	right_op: 	in std_logic_vector(Cell_count-1  downto 0 ); 
	o: 	out std_logic_vector(Cell_count-1 downto 0 )
);
end mux_sel;
architecture behav of mux_sel  is


SIGNAL choose_res :  STD_LOGIC_VECTOR(Cell_count-1 downto 0);
SIGNAL choose_cur :  STD_LOGIC_VECTOR(Cell_count-1 downto 0);
SIGNAL found_cur :  STD_LOGIC_VECTOR(Cell_count-1 downto 0);
SIGNAL choose_prev :  STD_LOGIC_VECTOR(Cell_count-1 downto 0);
SIGNAL found_prev : STD_LOGIC_VECTOR(Cell_count-1 downto 0);
begin

----------------------------------
ripple_part_inst: Ripple
GENERIC MAP(cells  => Cell_count)
PORT MAP(left_op   =>left_op (Cell_count-1 downto 0 ),
		 right_op  =>right_op(Cell_count-1 downto 0 ),
		 choose_cur=>choose_prev(Cell_count-1), 
		 found_cur=>found_prev(Cell_count-1),
		 choose_sel=>choose_res(Cell_count-1 downto 0 )
		);
ripple_part_Res_inst : Result
GENERIC MAP(Cell_count => Cell_count)
PORT MAP(i1  =>			left_op   (Cell_count-1 downto 0 ),
		 i2  =>			right_op  (Cell_count-1 downto 0 ),
		 choose_sel =>	choose_res(Cell_count-1 downto 0 ),
		 o=>o(Cell_count-1 downto 0) 
		);
----------------------------------
end behav;