-- 		16 bits ALU INTERFACE
--
--	Purpose: This package defines types and constants for interfacing with the 16 bits ALU.


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ALU_INT is
	-- Op codes of the ALU
	type ALU_OPCODE is (bXOR, bAND, bOR, bNOT, SADD, UADD, SSUB, USUB, LSHIFT, RSHIFT, NOP);
	
	-- Limits of a 16 bit representation
	constant MAX_SIGNED:integer := (2**15)-1;
	constant MIN_SIGNED:integer := -(2**15);
	
	constant MAX_UNSIGNED:integer := (2**16)-1;
end ALU_INT;

package body ALU_INT is
end ALU_INT;

