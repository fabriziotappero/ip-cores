library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.basic_size.all;
use work.basic_component.all;
entity parallel_find_top is
GENERIC (N: NATURAL := N ;  WIDTH :NATURAL := WIDTH);
port ( a : in WORD_ARRAY;
       y : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
         );
end parallel_find_top;

architecture gen_tree_arch  of parallel_find_top is
     CONSTANT STAGE : NATURAL :=log2_ceil(N);
     type STD_LOGIC_2D is array (STAGE DOWNTO 0, 2**STAGE-1 DOWNTO 0) of STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
	 SIGNAL p : STD_LOGIC_2D;
BEGIN
  --rename inputs
  in_gen : FOR i IN 0 TO (N-1) GENERATE
				p(STAGE , i) <= a(i);
		   END GENERATE in_gen;
--PADDING with zero's
  
pad0_gen : IF (N < 2**STAGE ) GENERATE
zero_gen : FOR i IN N TO 2**STAGE -1 GENERATE
  p(STAGE , i) <= (OTHERS=>'0');
  END GENERATE zero_gen;
  END GENERATE pad0_gen;

-- replicate structure
--STAGE_GEN
g : FOR s IN (STAGE-1)DOWNTO  0 GENERATE 
    --ROW_GEN
	q : FOR r IN 0 TO (2**s)-1 GENERATE
		 BT : mux_sel GENERIC MAP(level=> STAGE-s-1, Cell_count=>WIDTH)
		           port map(left_op=>p(s+1,2 * r),right_op=>p(s+1, 2*r +1),o=>p(s,r));
	END GENERATE q;
	END GENERATE g;
--rename output
  y <= p(0,0);
end gen_tree_arch;


