-- lem1_9min_defs.vhd
-- type declarations & constants

library IEEE;
use IEEE.std_logic_1164.all;

package definitions is

-- machine instructions memonics sorted by code & sub-code
--	ir(8..6) op-codes
constant opMSC:	std_logic_vector(2 downto 0) :="000";
--	ir(5..4) sub op-codes
constant opHLT:	std_logic_vector(1 downto 0) :="00";
constant opAnC:	std_logic_vector(1 downto 0) :="01";
--	ir(8..6) op-codes cont'd
constant opST:		std_logic_vector(2 downto 0) :="001";
constant opLD:		std_logic_vector(2 downto 0) :="010";
constant opLDC:	std_logic_vector(2 downto 0) :="011";
constant opAND:	std_logic_vector(2 downto 0) :="100";
constant opOR:		std_logic_vector(2 downto 0) :="101";
constant opXOR:	std_logic_vector(2 downto 0) :="110";
constant opADC:	std_logic_vector(2 downto 0) :="111";

end definitions;