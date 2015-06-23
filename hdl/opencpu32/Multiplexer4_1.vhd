--! @file
--! @brief 4:1 Mux using with-select

--! Use standard library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! Use CPU Definitions package
use work.pkgOpenCPU32.all;

--! Mux 5->1 circuit can select one of the 2 inputs into one output with some selection signal

--! Detailed description of this 
--! mux design element.
entity Multiplexer4_1 is
    generic (n : integer := nBits - 1);					--! Generic value (Used to easily change the size of the Alu on the package)
	 Port ( A   : in  STD_LOGIC_VECTOR (n downto 0);	--! First Input
           B   : in  STD_LOGIC_VECTOR (n downto 0);	--! Second Input
			  C   : in  STD_LOGIC_VECTOR (n downto 0);	--! Third Input
			  D   : in  STD_LOGIC_VECTOR (n downto 0);	--! Forth Input
			  E   : in  STD_LOGIC_VECTOR (n downto 0);	--! Fifth Input
           sel : in  dpMuxInputs;							--! Select inputs (1, 2, 3, 4, 5)
           S   : out  STD_LOGIC_VECTOR (n downto 0));	--! Mux Output
end Multiplexer4_1;

--! @brief Architure definition of the MUX
--! @details On this case we're going to use VHDL combinational description
architecture Behavioral of Multiplexer4_1 is

begin
	with sel select
		S <= A when fromMemory,
			  B when fromImediate,
			  C when fromRegFileA,
			  D when fromRegFileB,
			  E when fromAlu,
			  (others => 'Z') when others;

end Behavioral;

