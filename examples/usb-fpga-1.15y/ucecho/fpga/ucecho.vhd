library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ucecho is
   port(
      pc      : in unsigned(7 downto 0);
      pb      : out std_logic_vector(7 downto 0);
      CS      : in std_logic;
      CLK     : in std_logic

--      SCL     : in std_logic;
--      SDA     : in std_logic
   );
end ucecho;


architecture RTL of ucecho is

--signal declaration
signal pb_buf : unsigned(7 downto 0);

begin
    pb <= std_logic_vector( pb_buf ) when CS = '1' else (others => 'Z');

    dpUCECHO: process(CLK)
    begin
         if CLK' event and CLK = '1' then
	    if ( pc >= 97 ) and ( pc <= 122)
	    then
		pb_buf <= pc - 32;
	    else
		pb_buf <= pc;
	    end if;
	end if;
    end process dpUCECHO;
    
end RTL;
