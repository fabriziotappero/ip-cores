--! @file
--! @brief Tri-State buffer http://en.wikipedia.org/wiki/Three-state_logic

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! Use CPU Definitions package
use work.pkgOpenCPU32.all;

--! In digital electronics three-state, tri-state, or 3-state logic allows an output port to assume a \n
--! high impedance state in addition to the 0 and 1 logic levels, effectively removing the output from the circuit.

--! In digital electronics three-state, tri-state, or 3-state logic allows an output port to assume a \n
--! high impedance state in addition to the 0 and 1 logic levels, effectively removing the output from the circuit. 
--! This allows multiple circuits to share the same output line or lines (such as a bus).
entity TriStateBuffer is
    generic (n : integer := nBits - 1);					--! Generic value (Used to easily change the size of the Alu on the package)
	 Port ( A : in  STD_LOGIC_VECTOR (n downto 0);		--! Buffer Input
           sel : in  typeEnDis;								--! Enable or Disable the output
           S : out  STD_LOGIC_VECTOR (n downto 0));	--! TriState buffer output
end TriStateBuffer;

--! @brief Architure definition of the TriStateBuffer
--! @details On this case we're going to use VHDL combinational description (Simple combination circuit)
architecture Behavioral of TriStateBuffer is

begin
	with sel select
		S <= A when enable,
			  (others => 'Z') when disable;

end Behavioral;

