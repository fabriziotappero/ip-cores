-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.corelib.all;
use work.arm_comp.all;
use work.bus_comp.all;
use work.cache_comp.all;

entity arm_proc is
  generic (
    TEST_CACHE : boolean := false
  );
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    clkn   : in  std_logic;
    i      : in arm_proc_typ_in;
    o      : out arm_proc_typ_out;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type
    );
end arm_proc;

architecture rtl of arm_proc is

  type arm_tmp_type is record
    arm_i : armiu_typ_in;
  end record;
  type arm_reg_type is record
    dummy      : std_logic;
  end record;
  type arm_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : arm_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : arm_reg_type;
  signal rdbg, cdbg : arm_dbg_type;

  signal arm_i : armiu_typ_in;
  signal arm_o : armiu_typ_out;

  signal ici : genic_type_in;
  signal ico : genic_type_out;
  signal dci : gendc_type_in;
  signal dco : gendc_type_out;

  signal hold : cli_hold;
  
begin  
    
  hold.dhold <= dco.hold;
  hold.ihold <= ico.hold;
  hold.hold <= dco.hold or ico.hold;
  
  arm0: armiu port map (rst, clk, clkn, hold, ici, ico, dci, dco, arm_i, arm_o);
  arm_i.irqo <= i.irqo;
  o.irqi <= arm_o.irqi;
  --arm0: tbench_armcache-port map (rst, clk, clkn, hold, ici, ico, dci, dco, arm_i, arm_o);
  
  cache0: armcache port map ( rst, clk, hold, ici, ico, dci, dco, ahbi, ahbo, apbi, apbo );

end rtl;

