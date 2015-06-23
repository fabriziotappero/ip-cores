--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.std_logic_unsigned.all;

package outconverter is
  
   constant stage : natural := 3;

   constant FFTDELAY:integer:=13+2*STAGE;
   constant FACTORDELAY:integer:=6;
   constant OUTDELAY:integer:=9;

   function counter2addr(
		counter : std_logic_vector; 
		mask1:std_logic_vector;
		mask2:std_logic_vector
	) return std_logic_vector;   

	function outcounter2addr(counter : std_logic_vector) return std_logic_vector;
end outconverter;


package body outconverter is

	function counter2addr(
		counter : std_logic_vector; 
		mask1:std_logic_vector;
		mask2:std_logic_vector
	) return std_logic_vector is
	variable result	:std_logic_vector(counter'range);
	begin					  
		for n in mask1'range loop
			if mask1(n)='1' then
				result( 2*n+1 downto 2*n ):=counter( 1 downto 0 );
			elsif mask2(n)='1' and n/=STAGE-1 then
				result( 2*n+1 downto 2*n ):=counter( 2*n+3 downto 2*n+2 );
			else
				result( 2*n+1 downto 2*n ):=counter( 2*n+1 downto 2*n );
			end if;
		end loop;
		return result;
	end counter2addr;
	function outcounter2addr(counter : std_logic_vector) return std_logic_vector is
	   variable result	:std_logic_vector(counter'range);
	begin					  
		for n in 0 to STAGE-1 loop
			result( 2*n+1 downto 2*n ):=counter( counter'high-2*n downto counter'high-2*n-1 );
		end loop;
		return result;
	end outcounter2addr;

end outconverter;
