--! @file
--! @brief Read Only Memory 
--! @details It is used to store the program on it. It replaces a RAM on the original design.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY ROM_16_8 IS
PORT( read     : IN     std_logic;									--! Active low enable ROM signal, (tri-state)
      address  : IN     std_logic_vector (3 DOWNTO 0);		--! 4-bit ROM address bits from MAR
      data_out : OUT    std_logic_vector (7 DOWNTO 0));		--! 8-bit ROM output word to W-bus
END ROM_16_8 ;

ARCHITECTURE behave OF ROM_16_8 IS
type mem is array (0 to 15) of std_logic_vector(7 downto 0) ;
signal rom : mem;
BEGIN
	--! @verbatim
	--! This program works as follow:
	--!
	--! Load 5 to AC (memory content of 9)
	--! Output 5 (content of AC)
	--! Add 7 (memory content of 10) to 5 (AC content)
	--! Output 12 (content of AC)
	--! Add 3 (memory content of 11) to 12 (AC content)
	--! Subtract 4 (memory content of 12) from 15 (AC content)
	--! Output 11 (content of AC)
	--!
	--! @endverbatim
		rom <= (
				0 => "00001001" ,  -- LDA 9h ... Load AC with the content of memory location 9
				1 => "11101111" ,  -- OUT
				2 => "00011010" ,  -- ADD Ah ... Add the contents of memory location A to the AC content and replace the AC
 				3 => "11101111" ,  -- OUT
				4 => "00011011" ,  -- ADD Bh ... Add the contents of memory location B to the AC content and replace the AC
				5 => "00101100" ,  -- SUB Ch ... Sub the contents of memory location C from the AC content and replace the AC
 			   6 => "11101111" ,  -- OUT
				7 => "11111111" ,  -- HLT 
				8 => "11111111" ,
  			   9 => "00000101" ,  --5
				10=> "00000111" ,  --7
				11=> "00000011" ,  --3
				12=> "00000100" ,  --4
				13=> "11111111" , 
				14=> "11111111" , 
				15=> "11111111" );

	process (read,address)
	begin
		if read = '0' then
			data_out <= rom(conv_integer(address)) ;
		 else
		 	data_out <= (data_out'range => 'Z');
		end if; 
   end process ;
END behave;
