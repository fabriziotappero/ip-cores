
library ieee;
use ieee.std_logic_1164.all;

package eclipse_components is

  component RAM128X18_25um is
   port (WA, RA : in std_logic_vector (6 downto 0);
         WD : in std_logic_vector (17 downto 0);
         WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;
         RD : out std_logic_vector (17 downto 0) );
  end component;

  component RAM256X9_25um is
   port (WA, RA : in std_logic_vector (7 downto 0);
         WD : in std_logic_vector (8 downto 0);
         WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;
         RD : out std_logic_vector (8 downto 0) );
  end component;

  component RAM512X4_25um
   port (WA, RA : in std_logic_vector (8 downto 0);
         WD : in std_logic_vector (3 downto 0);
         WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;
         RD : out std_logic_vector (3 downto 0));
  end component;

  component RAM1024X2_25um is
  port (WA, RA : in std_logic_vector (9 downto 0);
        WD : in std_logic_vector (1 downto 0);
        WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;
        RD : out std_logic_vector (1 downto 0) );
  end component;

end eclipse_components;

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;

entity eclipse_sim_ram is
   generic (abits : integer := 8; dbits : integer := 16);
   port (WA, RA : in std_logic_vector (abits-1 downto 0);
         WD : in std_logic_vector (dbits-1 downto 0);
         WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;
         RD : out std_logic_vector (dbits-1 downto 0) );	
end;

architecture arch of eclipse_sim_ram is
  type dregtype is array (0 to 2**abits - 1) 
	of std_logic_vector(dbits -1 downto 0);
begin

  rp : process(rclk, wclk, re, ra, asyncrd) 
  variable rfd : dregtype;
  begin
    if rising_edge(wclk) then
      if we = '1' then rfd(conv_integer(wa)) := WD; end if;
    end if;
    if (re = '1') and (ASYNCRD = '1') then 
	RD <= rfd(conv_integer(ra));
    end if;
    if rising_edge(rclk) and (re = '1') and (ASYNCRD = '0') then 
	RD <= rfd(conv_integer(ra));
    end if;
  end process;

end arch;

library ieee;
use ieee.std_logic_1164.all;

entity RAM128X18_25um is
   port (WA, RA : in std_logic_vector (6 downto 0);
         WD : in std_logic_vector (17 downto 0);
         WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;
         RD : out std_logic_vector (17 downto 0) );	
end RAM128X18_25um;

architecture arch of RAM128X18_25um is
begin
  x : entity work.eclipse_sim_ram generic map (7, 18)
      port map (wa, ra, wd, we, re, wclk, rclk, asyncrd, rd);
end arch;

library ieee;
use ieee.std_logic_1164.all;

entity RAM256X9_25um is
   port (WA, RA : in std_logic_vector (7 downto 0);
         WD : in std_logic_vector (8 downto 0);
         WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;
         RD : out std_logic_vector (8 downto 0) );	
end RAM256X9_25um;

architecture arch of RAM256X9_25um is
begin
  x : entity work.eclipse_sim_ram generic map (8, 9)
      port map (wa, ra, wd, we, re, wclk, rclk, asyncrd, rd);
end arch;

library ieee;
use ieee.std_logic_1164.all;

entity RAM512X4_25um is
   port (WA, RA : in std_logic_vector (8 downto 0);
         WD : in std_logic_vector (3 downto 0);
         WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;	
         RD : out std_logic_vector (3 downto 0));
end RAM512X4_25um;

architecture arch of RAM512X4_25um is
begin
  x : entity work.eclipse_sim_ram generic map (9, 4)
      port map (wa, ra, wd, we, re, wclk, rclk, asyncrd, rd);
end arch;

library ieee;
use ieee.std_logic_1164.all;

entity RAM1024X2_25um is
  port (WA, RA : in std_logic_vector (9 downto 0);
        WD : in std_logic_vector (1 downto 0);
        WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;
        RD : out std_logic_vector (1 downto 0) );	
end RAM1024X2_25um;

architecture arch of RAM1024X2_25um is
begin
  x : entity work.eclipse_sim_ram generic map (10, 2)
      port map (wa, ra, wd, we, re, wclk, rclk, asyncrd, rd);
end arch;
