library ieee;
use ieee.std_logic_1164.all;
library gaisler;
use gaisler.misc.all;
library techmap;
use techmap.allclkgen.all;
use techmap.gencomp.all;
library grlib;
use grlib.stdlib.all;


------------------------------------------------------------------
-- Altera Cyclone ep1c20 clock generator ---------------------------------------
------------------------------------------------------------------

entity clkgen_ep1c20board is
 generic (
    tech     : integer := DEFFABTECH; 
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    sdinvclk : integer := 0;
    freq     : integer := 50000);
  port (
    clkin   : in  std_logic;
    clkout  : out  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    sdclk   : out std_logic;			-- SDRAM clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type);
end; 

architecture rtl of clkgen_ep1c20board is

  constant VERSION : integer := 1;
  constant CLKIN_PERIOD : integer := 20;

  signal   s_clk             : std_logic;
  
  signal intclk : std_ulogic;
  
begin
  

  gen : if (tech = inferred)
  generate
    intclk <= clkin;
    sdclk <= not intclk when SDINVCLK = 1 else intclk;
    clk <= intclk; clkn <= not intclk;
    cgo.clklock <= '1'; cgo.pcilock <= '1';
  end generate;

  alt : if (tech /= inferred) generate
  
    pll1 : altera_pll 
      generic map (clk_mul, clk_div, freq)
      port map ( inclk0 => clkin, e0 => clkout, c0 => open, 
                 locked => open);
    pll2 : altera_pll 
      generic map (clk_mul, clk_div, freq)
      port map ( inclk0 => cgi.pllref, e0 => sdclk, c0 => s_clk, 
                 locked => cgo.clklock);
    clk  <= s_clk;
    clkn <= not s_clk;

  end generate;
 
  -- pragma translate_off
  bootmsg : report_version 
  generic map (
    "clkgen_ep1c20board" & ": EP1C20 board sdram/pci clock generator, version " & tost(VERSION),
    "clkgen_ep1c20board" & ": Frequency " &  tost(freq) & " KHz, PLL scaler " & tost(clk_mul) & "/" & tost(clk_div));
  -- pragma translate_on


end;


