--! @file
--! @brief Register File unit http://en.wikipedia.org/wiki/Register_file

--! Use standard library and import the packages (std_logic_1164,std_logic_unsigned,std_logic_arith)
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--! Use CPU Definitions package
use work.pkgOpenCPU32.all;

--! A register file is an array of processor registers in a central processing unit (CPU).

--! A register file is an array of processor registers in a central processing unit (CPU).\n 
--! Modern integrated circuit-based register files are usually implemented by way of fast static RAMs with multiple ports.\n 
--! Such RAMs are distinguished by having dedicated read and write ports, whereas ordinary multiported SRAMs will usually read and write\n
--! through the same ports.
entity RegisterFile is
    generic (n : integer := nBits - 1);						--! Generic value (Used to easily change the size of the registers)
	 Port ( clk : in  STD_LOGIC;									--! Clock signal
           writeEn : in  STD_LOGIC;								--! Write enable
           writeAddr : in  generalRegisters;					--! Write Adress
           input : in  STD_LOGIC_VECTOR (n downto 0);		--! Input 
           Read_A_En : in  STD_LOGIC;							--! Enable read A
           Read_A_Addr : in  generalRegisters;				--! Read A adress
           Read_B_En : in  STD_LOGIC;							--! Enable read A
           Read_B_Addr : in  generalRegisters;  			--! Read B adress
           A_Out : out  STD_LOGIC_VECTOR (n downto 0);	--! Output A
           B_Out : out  STD_LOGIC_VECTOR (n downto 0));	--! Output B
end RegisterFile;

--! @brief This register file will have one input and two ouputs.
--! @details This will permit to read two registers on the same clock, but will need n clock cicles for n register assignments...

architecture Behavioral of RegisterFile is
subtype reg is STD_LOGIC_VECTOR (n downto 0);			-- Define register type
type regArray is array (0 to (numGenRegs-1)) of reg;	-- Define register type array
signal regFile : regArray;										-- This signal will infer an FF array if assigned by a clock edge...
begin
	
	-- Write some register value...
	writeProcess: process (clk)
	begin
		if rising_edge(clk) then
			if (writeEn = '1') then
				regFile(CONV_INTEGER(reg2Num(writeAddr))) <= input;
			end if;
		end if;
	end process;
	
	-- Read some register in port A
	readAProcess : process(Read_A_En,Read_A_Addr)
	begin
		if (Read_A_En = '1') then
			A_Out <= regFile(CONV_INTEGER(reg2Num(Read_A_Addr)));
		else
			A_Out <= (others => 'Z');
		end if;
	end process;
	
	-- Read some register in port B
	readBProcess : process(Read_B_En,Read_B_Addr)
	begin
		if (Read_B_En = '1') then
			B_Out <= regFile(CONV_INTEGER(reg2Num(Read_B_Addr)));
		else
			B_Out <= (others => 'Z');
		end if;
	end process;

end Behavioral;

