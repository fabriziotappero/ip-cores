-- ==============================================================================
-- Generic signed/unsigned restoring divider Testbench 
-- 
-- This library is free software; you can redistribute it and/or modify it 
-- under the terms of the GNU Lesser General Public License as published 
-- by the Free Software Foundation; either version 2.1 of the License, or 
-- (at your option) any later version.
-- 
-- This library is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.   See the GNU Lesser General Public 
-- License for more details.   See http://www.gnu.org/copyleft/lesser.txt
-- 
-- ------------------------------------------------------------------------------
-- Version   Author          Date          Changes
-- 0.1       Hans Tiggeler   07/18/02      Tested on Modelsim SE 5.6
-- ==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity divider_tb is
generic (width_divider : integer := 8;			  
         width_divisor : integer := 8);
end entity divider_tb;

architecture rtl of divider_tb is

component divider is
    generic (width_divid : integer := 4;			  
             width_divis : integer := 4);
    port (	dividend  : in   std_logic_vector (width_divid-1 downto 0);
      		divisor   : in     std_logic_vector (width_divis-1 downto 0);
      		quotient  : out    std_logic_vector (width_divid-1 downto 0);
      		remainder : out    std_logic_vector (width_divis-1 downto 0);
      		twocomp   : in     std_logic);			  -- '1'=2's complement, '0'=unsigned
end component divider;


signal dividend_s  :  std_logic_vector (width_divider-1 downto 0);
signal divisor_s   :  std_logic_vector (width_divisor-1 downto 0);
signal quotient_s  :  std_logic_vector (width_divider-1 downto 0);
signal remainder_s :  std_logic_vector (width_divisor-1 downto 0);
signal twocomp_s   :  std_logic;

signal q_s  : integer;
signal r_s  : integer;


begin
    dut : divider
		generic map (width_divid =>  width_divider,
		             width_divis =>  width_divisor)
		port map (dividend  => dividend_s,
		          divisor   => divisor_s,
		          quotient  => quotient_s,
		          remainder => remainder_s,
		          twocomp   => twocomp_s);

process 
	begin	
		twocomp_s  <= '0';
		dividend_s <= (others => '0');
		divisor_s  <= (others => '1');
		wait for 20 ns;

		for twocomp_v in 0 to 1 loop
			if twocomp_v=0 then
				twocomp_s<= '0';report "**** Testing Unsigned Divider ****"; 
			else 
				twocomp_s<= '1';report "**** Testing Signed Divider ****";
			end if;
			for i in 0 to (2 ** width_divider - 1) loop 
				for j in 1 to (2 ** width_divisor - 1) loop
					dividend_s <= conv_std_logic_vector(i,width_divider);	
					divisor_s  <= conv_std_logic_vector(j,width_divisor);

					wait for 10 ns;
					if twocomp_s='1' then						
						q_s <=conv_integer(signed(dividend_s)) /   conv_integer(signed(divisor_s));
						r_s <=conv_integer(signed(dividend_s)) rem conv_integer(signed(divisor_s));
						wait for 1 ns;
						if (q_s <= (2**(width_divider-1)-1)) then	  -- check for overflow -2^(n-1) .. 2^(n-1)-1
							assert (q_s=conv_integer(signed(quotient_s)))  report "Signed quotient failure" severity note;
							assert (r_s=conv_integer(signed(remainder_s))) report "Signed remainder failure" severity note;
						else
							report "Overflow, Signed divide skipped";
						end if;
					else 
						q_s <=conv_integer(dividend_s) /   conv_integer(divisor_s);
						r_s <=conv_integer(dividend_s) rem conv_integer(divisor_s);
						wait for 1 ns;
						assert (q_s=conv_integer(quotient_s))  report "Unsigned quotient failure" severity note;
						assert (r_s=conv_integer(remainder_s)) report "Unsigned remainder failure" severity note;
					end if;
					wait for 10 ns;
				end loop;
			end loop;
		end loop;
		
		assert (false) report " end of sim" severity failure;
 end process;


end architecture rtl;
