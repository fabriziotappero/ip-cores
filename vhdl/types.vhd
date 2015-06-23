--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package types is
  
	subtype slv_36 is std_logic_VECTOR(35 downto 0);  
	subtype slv_32 is std_logic_VECTOR(31 downto 0);
	subtype slv_16 is std_logic_VECTOR(15 downto 0);
	subtype slv_8 is std_logic_VECTOR(7 downto 0);
	subtype slv_4 is std_logic_VECTOR(3 downto 0);
	
	type slv_32_array is array (integer range <>) of slv_32;

-- Declare constants
--	constant op_add : bit_8 := X"00";
--	constant op_sub : bit_8 := X"01";

-- Declare functions and procedure
	function bits_to_natural (lv : in std_logic_vector) return natural;
	
end types;


package body types is

	function bits_to_natural (lv : in std_logic_vector) return natural is
		variable result : natural := 0;
		variable bits : bit_vector(lv'range);
		begin
		
			bits := To_bitvector(lv);
			for index in bits'range loop
					result := result * 2 + bit'pos(bits(index));
			end loop;
			return result;
		end bits_to_natural;
 
end types;
