----------------------------------------------------------------------------------
-- Engineer: Joao Carlos Nunes Bittencourt
----------------------------------------------------------------------------------
-- Create Date:    13:18:18 03/06/2012 
----------------------------------------------------------------------------------
-- Design Name:    Flags Package
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

package flags is
	constant equals :	std_logic_vector (3 downto 0) := "0001";
	constant above :	std_logic_vector (3 downto 0) := "0010";
	constant overflow :	std_logic_vector (3 downto 0) := "0100";
	constant error :	std_logic_vector (3 downto 0) := "1000";
end flags;