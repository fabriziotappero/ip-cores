library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;
library std;
use std.textio.all;



entity ToTextFile is
	generic(BitLen : natural := 8;
	NameOfFile: string := "c:\noise.dat");
	 port(
		 clk : in STD_LOGIC;
		 CE : in STD_LOGIC;
		 DataToSave : in STD_LOGIC_VECTOR(BitLen-1 downto 0)
	     );
end ToTextFile;


architecture ToTextFile of ToTextFile is

FUNCTION rat( value : std_logic )
    RETURN std_logic IS
  BEGIN
    CASE value IS
      WHEN '0' | '1' => RETURN value;
      WHEN 'H' => RETURN '1';
      WHEN 'L' => RETURN '0';
      WHEN OTHERS => RETURN '0';
    END CASE;
END rat;

FUNCTION rats( value : std_logic_vector ) RETURN std_logic_vector IS
variable rtt:std_logic_vector(value'Range);
  BEGIN					   
    for i in value'Range loop		
		rtt(i):=rat(value(i));
	end loop;
	return rtt;
END rats;


FILE RESULTS: TEXT OPEN WRITE_MODE IS NameOfFile;
begin
	
wrFile: process (clk) is
VARIABLE TX_LOC : LINE;	
variable dataint:Integer;
begin
	if rising_edge(clk) then
		if CE='1' then				  
			dataint:=CONV_INTEGER(UNSIGNED(rats(DataToSave)));
			STD.TEXTIO.write(TX_LOC,dataint);	
			STD.TEXTIO.writeline(results, TX_LOC); 
			STD.TEXTIO.Deallocate(TX_LOC);
		end if;
	end if;
end process;

end ToTextFile;
