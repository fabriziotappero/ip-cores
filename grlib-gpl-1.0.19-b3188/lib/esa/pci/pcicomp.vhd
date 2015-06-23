library ieee;
library grlib;

use grlib.amba.all;
use ieee.std_logic_1164.all;

package pcicomp is

  component pciarb is
    generic(
      pindex     : integer := 0;
      paddr      : integer := 0;
      pmask      : integer := 16#FFF#;
      nb_agents  : integer := 4;
      apb_en     : integer := 1;
      netlist    : integer := 0);
    port(
      clk     : in std_ulogic;
      rst_n   : in std_ulogic;
      req_n   : in std_logic_vector(0 to nb_agents-1);
      frame_n : in std_logic;
      gnt_n   : out std_logic_vector(0 to nb_agents-1);
      pclk    : in std_ulogic;
      prst_n  : in std_ulogic;
      apbi    : in apb_slv_in_type;
      apbo    : out apb_slv_out_type
    );
  end component;
end package;
