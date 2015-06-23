library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;
library std;
use std.textio.all;



entity FromTextFile is
	generic(BitLen : natural := 8;
			IsSigned: natural:=0; -- you can choose signed or unsigned value you have in text file
			NameOfFile: string := "c:\noise.dat");
	 port(
		 clk : in STD_LOGIC;
		 CE : in STD_LOGIC;
		 DataFromFile : out STD_LOGIC_VECTOR(BitLen-1 downto 0)
	     );
end FromTextFile;


architecture FromTextFile of FromTextFile is


FILE RESULTS: TEXT OPEN READ_MODE IS NameOfFile;
begin
	
rxFile: process (clk) is
VARIABLE RX_LOC : LINE;	
variable dataint:Integer;
begin
	if rising_edge(clk) then
		if CE='1' then				  
		STD.TEXTIO.readline(results, RX_LOC); 
		STD.TEXTIO.read(RX_LOC,dataint);	
		if (IsSigned=1) then
			DataFromFile<=std_logic_vector(signed(CONV_STD_LOGIC_VECTOR(dataint,BitLen)));
		else
			DataFromFile<=std_logic_vector(unsigned(CONV_STD_LOGIC_VECTOR(dataint,BitLen)));
		end if;
		STD.TEXTIO.Deallocate(RX_LOC);
		end if;
	end if;
end process;

end FromTextFile;
