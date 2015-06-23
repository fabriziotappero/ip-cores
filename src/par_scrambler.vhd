----------------------------------------------------------------------
----                                                              ----
---- Parallel Scrambler.                                              
----                                                              ----
---- This file is part of the Configurable Parallel Scrambler project 
---- http://opencores.org/project,parallel_scrambler              ----
----                                                              ----
---- Description                                                  ----
---- Parallel scrambler/descrambler module, user reconfigurable   ----
----                                                 			  ----
----                                                              ----
---- License: LGPL                                                ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Howard Yin, sparkish@opencores.org                         ----
----                                                              ----
----------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all;

entity par_scrambler is 
	generic (
		Data_Width 			: integer	:= 8;		-- Input/output data width
		Polynomial_Width	: integer	:= 8		-- Polynomial width
		);
	port ( 
		rst					: in std_logic;			-- Async reset
		clk					: in std_logic;			-- System clock
		scram_rst			: in std_logic;			-- Scrambler reset, use for initialization.
		Polynomial			: in std_logic_vector (Polynomial_Width downto 0);	-- Polynomial. Example: 1+x^4+x^6+x^7 represent as "11010001"
		data_in 			: in std_logic_vector (Data_Width-1 downto 0);		-- Data input
		scram_en			: in std_logic; 									-- Input valid
		data_out 			: out std_logic_vector (Data_Width-1 downto 0);		-- Data output
		out_valid			: out std_logic										-- Output valid
		);
end par_scrambler;

architecture behavior of par_scrambler is 

begin 
    
    scram_p : process (clk,rst) 
		variable c : std_logic	:= '0';
		variable lfsr_q: std_logic_vector (Polynomial_Width-1 downto 0)	:= (others => '1');
		variable lfsr_c: std_logic_vector (Data_Width-1 downto 0) := (others => '0');
	begin 
		if (rst = '1') then 
			lfsr_q 		:= (others => '1');
			out_valid 	<= '0';
			data_out	<= (others => '0');
			c			:= '0';
		elsif (clk'EVENT and clk = '1') then
			out_valid <= scram_en;
			if (scram_rst = '1') then 
				lfsr_q := (others => '1');
			elsif (scram_en = '1') then 
				for i in 0 to Data_Width-1 loop
					c	:= lfsr_q (Polynomial_Width-1);
					xor_loop : for j in 1 to Polynomial_Width-2 loop
						if Polynomial(j) = '1' then
							c	:= c xor lfsr_q(j-1);
						end if;
					end loop xor_loop;
					lfsr_q	:= lfsr_q (Polynomial_Width-2 downto 0) & c;
					lfsr_c	:= c & lfsr_c(Data_Width-1 downto 1);
				end loop;
				data_out <= lfsr_c xor data_in; 
			end if; 
        end if; 
    end process; 
	
end architecture behavior; 