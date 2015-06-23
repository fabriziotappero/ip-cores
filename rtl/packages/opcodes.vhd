----------------------------------------------------------------------------------
-- Engineer: Joao Carlos Nunes Bittencourt
----------------------------------------------------------------------------------
-- Create Date:    13:18:18 03/06/2012 
----------------------------------------------------------------------------------
-- Design Name:    Opcode Package
-- Package Name:   flags
----------------------------------------------------------------------------------
-- Project Name:   16-bit uRISC Processor
----------------------------------------------------------------------------------
-- Revision: 
-- 	1.0 - File Created
-- 	2.0 - Project refactoring
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package operations is
	constant add:		 std_logic_vector (4 downto 0) := "00000";
	constant addinc:	 std_logic_vector (4 downto 0) := "00001";
	constant inca: 		 std_logic_vector (4 downto 0) := "00011";
	constant subdec: 	 std_logic_vector (4 downto 0) := "00100";
	constant sub: 	 	 std_logic_vector (4 downto 0) := "00101";
	constant deca: 	 	 std_logic_vector (4 downto 0) := "00110";
	constant lsl:	 	 std_logic_vector (4 downto 0) := "01000"; -- Left shift logic
	constant asr: 	 	 std_logic_vector (4 downto 0) := "01001"; -- Aritmetic shift right
	constant zeros: 	 std_logic_vector (4 downto 0) := "10000";
	constant land: 	 	 std_logic_vector (4 downto 0) := "10001"; -- Logic and
	constant andnota: 	 std_logic_vector (4 downto 0) := "10010";
	constant passb: 	 std_logic_vector (4 downto 0) := "10011";
	constant andnotb: 	 std_logic_vector (4 downto 0) := "10100";
	constant passa: 	 std_logic_vector (4 downto 0) := "10101";
	constant lxor: 	 	 std_logic_vector (4 downto 0) := "10110"; -- Logic XOR
	constant lor: 	 	 std_logic_vector (4 downto 0) := "10111"; -- Logic OR
	constant lnor: 	 	 std_logic_vector (4 downto 0) := "11000"; -- Logic NOR
	constant lxnor: 	 std_logic_vector (4 downto 0) := "11001"; -- Logic XOR
	constant passnota: 	 std_logic_vector (4 downto 0) := "11010"; 
	constant ornota:  	 std_logic_vector (4 downto 0) := "11011"; 
	constant passnotb: 	 std_logic_vector (4 downto 0) := "11100"; 
	constant ornotb:  	 std_logic_vector (4 downto 0) := "11101"; 
	constant lnand:  	 std_logic_vector (4 downto 0) := "11110"; -- Logic NAND
	constant ones:  	 std_logic_vector (4 downto 0) := "11111";
	constant lcl:   	 std_logic_vector (4 downto 0) := "00010"; -- Load constant low
	constant lch:   	 std_logic_vector (4 downto 0) := "00111"; -- Load constant high
end operations;
