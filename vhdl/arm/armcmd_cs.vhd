-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.armpctrl.all;
use work.armpmodel.all;
use work.armcmd.all;
use work.armcmd_comp.all;

entity armcmd_cs is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_cs_typ_in;
    o       : out armcmd_cs_typ_out
    );
end armcmd_cs;

architecture rtl of armcmd_cs is

  type armcmd_cs_tmp_type is record
    o       : armcmd_cs_typ_out;
  end record;
  type armcmd_cs_reg_type is record
    dummy      : std_logic;
  end record;
  type armcmd_cs_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armcmd_cs_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armcmd_cs_reg_type;
  signal rdbg, cdbg : armcmd_cs_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armcmd_cs_reg_type;
    variable t    : armcmd_cs_tmp_type;
    variable vdbg : armcmd_cs_dbg_type;
  begin 
    
    -- $(init(t:armcmd_cs_tmp_type))
    
    v := r;
    
    -- reset
    if ( rst = '0' ) then
    end if;
    
    c <= v;
    
    o <= t.o;
    
    -- pragma translate_off
    vdbg := rdbg;
    vdbg.dbg := t;
    cdbg <= vdbg;
    -- pragma translate_on  
    
  end process p0;
    
  pregs : process (clk, c)
  begin
    if rising_edge(clk) then
      r <= c;
      -- pragma translate_off
      rdbg <= cdbg;
      -- pragma translate_on
    end if;
  end process;
  
end rtl;
