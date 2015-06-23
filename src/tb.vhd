	library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use work.basic_size.all;
	use work.basic_component.all;
	entity tb is
	port( clk,reset: in std_logic;
		in_data  :	in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
		enable :    in STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		output		 :  OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
			);
	end tb;
	architecture behav of tb  is
	signal  inputs_reg0 : WORD_ARRAY;
	signal  inputs_reg1 : WORD_ARRAY;
	signal  outputs_reg0 : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
	signal  outputs_reg1 : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
	
	begin
-- Serial send the data 
	 process(clk)
		 begin 		
	if clk='1' and clk'event then 
	for i in 0 to (N-2) loop 		
		 inputs_reg0(i+1) <= inputs_reg0(i) ;	 	
		end loop ;
		inputs_reg0(0) <= in_data ;
		end if;
end process;

FIND_MAX :  parallel_find_top PORT MAP 
        ( a => inputs_reg0,
          y => outputs_reg0
         );
 
          process(clk,reset)
		 begin 
		 if reset = '1' then
			
		 elsif clk='1' and clk'event then 
				outputs_reg1 <= outputs_reg0 ;
				output <= outputs_reg1 ;
		 end if;
		end process;
	
	end behav;