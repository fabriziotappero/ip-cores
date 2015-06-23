library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

package ge_clkgen is

  component ClockGenerator
    port (
      Clk     : in  std_ulogic;
      Reset   : in  std_ulogic;
      oMCLK   : out std_ulogic;
      oBCLK   : out std_ulogic;
      oSCLK   : out std_ulogic;
      oLRCOUT : out std_ulogic);
  end component;


end ge_clkgen;
