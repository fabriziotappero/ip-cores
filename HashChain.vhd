--------------------------------------------------------------------------------
-- Create Date:    03:46:54 10/31/05
-- Design Name:    
-- Module Name:    Hash - Behavioral
-- Project Name:   Deflate
-- Revision:
-- Revision 0.25 - Only one hash algorithm
-- Additional Comments:
-- The remarked comments for synchronous reser result in the use of more 192 slices witn a maximum frequency of 129 Mhz
--	But if the code is commented as it is now the number of slices utlised is 5 without a known clock , need to specifiy that as a compile time constraint.
-- TO DO: 
-- Wishbone interface
-- Concurrent Hashkey generation
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
			 
entity HashChain is
    Generic
	      (																					  -- Data bus width currently set at 8
			 Data_Width : natural := 8;												  -- Width of the hash key generated now at 32 bits
			 Hash_Width : natural := 32
         );
    Port ( Hash_O   : inout std_logic_vector (Hash_Width - 1 downto 0);   -- Hash value of previous data
           Data_in  : in  std_logic_vector (Data_Width-1 downto 0);       -- Data input from byte stream
			  Clock,													                    -- Clock
			  Reset,
			  Start,													                    -- Reset
			  O_E : in  bit	;	                     						     -- Output Enable
           Busy,
			  Done : out bit													           -- Enabled when the hash key has been generated
			  );
end HashChain;
 
--An algorithm produced by Professor Daniel J. Bernstein and 
--shown first to the world on the usenet newsgroup comp.lang.c. 
--It is one of the most efficient hash functions ever published
--Actual function hash(i) = hash(i - 1) * 33 + str[i];
--Function now implemented using XOR hash(i) = hash(i - 1) * 33 ^ str[i];
architecture DJB2 of HashChain is
signal mode: integer := 0;
signal tempval, hash:std_logic_vector (Hash_Width - 1 downto 0):= X"00000000" ;
signal multiplier:std_logic_vector (39 downto 0):= X"0000000000" ;
begin


mealymachine: process (Clock)
begin
        if Reset = '1' and Clock = '1' then	     -- Reset
		     mode <= 0;
        elsif start = '1' and Clock = '1' then	  -- Start
		     mode <= 1;									  -- Multiply previous key by 33	  ( Clock = 1 )
		  elsif mode = 1 then							  
		     mode <= 2;									  -- Ex-OR input with existing key ( Clock = 0 )
		  elsif mode = 2 then							  
		     mode <= 3;									  -- Latch output                  ( Clock = 1 )
		  else
		     mode <= 4;
        end if;
end process mealymachine;

hash <= X"000016c7"  when mode = 0 else			   --initialise the hash key to 5831
		  multiplier(31 downto 0) xor tempval   when mode = 2 else	   --Ex or with the current input
		  hash;												   --keep current value

multiplier <= hash * X"21" when mode = 1 else		      --Multiply by 33
				  X"0000000000";

tempval <= X"00000000" when mode /= 1 else		   --Temporary value to be able to Exor the input with the hash key
           tempval+ Data_in;

busy <= '1' when mode > 0 and mode < 3 else		   --Indicates that the key is being generated
        '0' ;


Hash_O <= hash when mode = 3 and O_E = '1' else   --Output buffer
          Hash_O;                                 --Hash op bufffer
			 									

done <= '1' when mode = 3 else                    --1 after hash key has been calculated 
        '0';


end DJB2;

Configuration djb2_hash of hashchain is 
for djb2
end for;
end djb2_hash;
