library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity lightshow is
   port(
      led     : out std_logic_vector(11 downto 0);
      CLK     : in std_logic		-- 32 MHz
   );
end lightshow;

--signal declaration
architecture RTL of lightshow is

type tPattern is array(11 downto 0) of integer range 0 to 15;

signal pattern1 : tPattern := (0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1);
signal pattern2 : tPattern := (6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5);
signal pattern3 : tPattern := (0, 1, 4, 9, 4, 1, 0, 0, 0, 0, 0, 0);

type tXlatTable1 is array(0 to 12) of integer range 0 to 1023;
constant xt1 : tXlatTable1 := (0, 0, 1, 4, 13, 31, 64, 118, 202, 324, 493, 722, 1023);
type tXlatTable2 is array(0 to 9) of integer range 0 to 255;
--constant xt2 : tXlatTable2 := (0, 1, 11, 38, 90, 175, 303, 481, 718, 1023);
constant xt2 : tXlatTable2 := (0, 0, 3, 9, 22, 44, 76, 120, 179, 255);

signal cp1 : std_logic_vector(22 downto 0);
signal cp2 : std_logic_vector(22 downto 0);
signal cp3 : std_logic_vector(22 downto 0);
signal d : std_logic_vector(16 downto 0);

begin
    dpCLK: process(CLK)
    begin
         if CLK' event and CLK = '1' then

	    if ( cp1 = conv_std_logic_vector(3000000,23) )
	    then
		pattern1(10 downto 0) <= pattern1(11 downto 1);
		pattern1(11) <= pattern1(0);
		cp1 <= (others => '0');
	    else
		cp1 <= cp1 + 1;
	    end if;

	    if ( cp2 = conv_std_logic_vector(2200000,23) )
	    then
		pattern2(10 downto 0) <= pattern2(11 downto 1);
		pattern2(11) <= pattern2(0);
		cp2 <= (others => '0');
	    else
		cp2 <= cp2 + 1;
	    end if;

	    if ( cp3 = conv_std_logic_vector(1500000,23) )
	    then
		pattern3(11 downto 1) <= pattern3(10 downto 0);
		pattern3(0) <= pattern3(11);
		cp3 <= (others => '0');
	    else
		cp3 <= cp3 + 1;
	    end if;
	    
	    if ( d = conv_std_logic_vector(1278*64-1,17) )
	    then
    		d <= (others => '0');
	    else
		d <= d + 1;
	    end if;
	    
	    for i in 0 to 11 loop
  	        if ( d(16 downto 6) < conv_std_logic_vector( xt1(pattern1(i) + pattern2(i)) + xt2(pattern3(i)) ,11) )
		then
		    led(i) <= '1';
		else
		    led(i) <= '0';
		end if;
	    end loop;
	    
	end if;
    end process dpCLK;
    
end RTL;
