library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ucecho is
   port(
      pc      : in unsigned(7 downto 0);
      pb      : out unsigned(7 downto 0);
      CLK     : in std_logic
   );
end ucecho;


architecture RTL of ucecho is

--signal declaration
signal pb_buf : unsigned(7 downto 0);

begin
    dpUCECHO: process(CLK)
    begin
         if CLK' event and CLK = '1' then
	    if ( pc >= 97 ) and ( pc <= 122)
	    then
		pb_buf <= pc - 32;
	    else
		pb_buf <= pc;
	    end if;
	    pb <= pb_buf;
	end if;
    end process dpUCECHO;
    
end RTL;
