library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity serial_div2 is 
	generic (	M_PP	:	natural	:= 34;				-- Size of dividend
					N_PP	:	natural	:= 19;				-- Size of divisor
					R_PP	:	natural	:= 0;					-- Size of remainder
					S_PP	:	natural	:= 0;					-- Skip this many bits (known leading zeros)
					COUNT_WIDTH_PP	: natural	:= 6;		-- 2^COUNT_WIDTH_PP-1 >= (M_PP+R_PP-S_PP-1)
					HELD_OUTPUT_PP	: natural	:= 1		-- Set to 1 if stable output should be held
	);																-- from previous operation, during current operation.
	port (  clk_i			: in std_logic;
			  clk_en_i		: in std_logic := '1';
			  rst_i			: in std_logic := '0';
			  divide_i		: in std_logic := '1';
			  dividend_i	: in std_logic_vector(M_PP-1 downto 0) := (others => '0');
			  divisor_i		: in std_logic_vector(N_PP-1 downto 0) := (others => '0');
			  quotient_o	: out std_logic_vector(M_PP+R_PP-N_PP+1 downto 0);			 --17
			  done_o			: out std_logic
  );
end serial_div2;

architecture Behavioral of serial_div2 is
																													 
signal  divide_count 	: std_logic_vector(COUNT_WIDTH_PP-1 downto 0) := (others => '0');
signal  divisor_node  	: std_logic_vector(M_PP+N_PP-1 downto 0);						 
signal  quotient_node  	: std_logic_vector(M_PP-N_PP+R_PP+1 downto 0);
signal  remainder_node 	: std_logic_vector(M_PP+N_PP-1 downto 0);  -- Subtract node has extra "sign" bit
--signal  remainder_node2 	: std_logic_vector(M_PP-1 downto 0);  -- Subtract node has extra "sign" bit
--signal msb_indicate		: std_logic ;

begin
	s_div : process(clk_i)
	begin	-- s_div
	   if(clk_i'event and clk_i='1') then
		  if (rst_i = '1') then
	       quotient_node 	 	<=  (others => '0');
	       divide_count 	<=  (others => '0');
			 divisor_node	<=  (others => '0');
			 remainder_node <=  (others => '0');
--		    quotient_o 	<=  (others => '0');
			 done_o				<= '0';
--			 msb_indicate 	<= '0';
	 	  else
		  	 if (clk_en_i = '1') then
				 if (divide_i = '1') then	 				 
					 done_o 	<= '0';
--					 quotient_o 		<=  (others => '0');
			       quotient_node 	 	<=  (others => '0');
			       divide_count 	<=  (others => '0');
					 divisor_node(M_PP+N_PP-1 downto M_PP)	<=  divisor_i;
					 divisor_node(M_PP-1 downto 0)  <= (others => '0');
					 remainder_node(M_PP+N_PP-1 downto N_PP)	<= dividend_i;
					 remainder_node(N_PP-1 downto 0) <= (others => '0');
--					 msb_indicate 	<= '0';

				elsif (conv_integer(divide_count) = (M_PP-11) ) then   --- works with (-11), no explanation right now	
				 
					done_o 	<= '1';
					quotient_o 		<= quotient_node;  
				 else 
				 	if (remainder_node > divisor_node) then
						remainder_node <= remainder_node - divisor_node;
						quotient_node	<= quotient_node(M_PP+R_PP-N_PP downto 0)	 & '1';
					else
						quotient_node	<= quotient_node(M_PP+R_PP-N_PP downto 0)	 & '0';
					end if;

					    	-- final shift...	  TODO
					divide_count 	<= divide_count + 1;		-- Advance the counter
					divisor_node	<= '0' & divisor_node(M_PP +N_PP-1 downto 1);
				 end if;			-- DIVIDE
				 
			 end if;			-- clk_en
		  end if;			-- RST
		end if;				-- CLK
	end process s_div;
				
				  -- quotient_o 		<= quotient_node;      	-- final shift...	  TODO

end Behavioral;