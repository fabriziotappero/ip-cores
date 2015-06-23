--! @file
--! @brief 3:1 Mux using with-select

--! Use standard library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--! Use CPU Definitions package
use work.pkgOpenCPU32.all;

--! Mux 3->1 circuit can select one of the 2 inputs into one output with some selection signal

--! Detailed description of this 
--! mux design element.
entity Multiplexer3_1 is
    generic (n : integer := nBits - 1);					--! Generic value (Used to easily change the size of the Alu on the package)
	 Port ( A : in  STD_LOGIC_VECTOR (n downto 0);		--! First Input
           B : in  STD_LOGIC_VECTOR (n downto 0);		--! Second Input
           C : in  STD_LOGIC_VECTOR (n downto 0);		--! Third Input
           sel : in dpMuxAluIn;								--! Select inputs (fromMemory, fromImediate, fromRegFileA)
           S : out  STD_LOGIC_VECTOR (n downto 0));	--! Mux Output
end Multiplexer3_1;

--! @brief Architure definition of the MUX
--! @details On this case we're going to use VHDL combinational description
architecture Behavioral of Multiplexer3_1 is

begin
	with sel select
		S <= A when fromMemory,
			  B when fromImediate,
			  C when fromRegFileA,			  			  
			  (others => 'Z') when others;

end Behavioral;

