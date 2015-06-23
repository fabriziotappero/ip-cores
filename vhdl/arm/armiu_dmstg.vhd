-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.armpctrl.all;
use work.arm_comp.all;

entity armiu_dmstg is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_dmstg_typ_in;
    o       : out armiu_dmstg_typ_out
    );
end armiu_dmstg;

architecture rtl of armiu_dmstg is

  type armiu_dmstg_tmp_type is record
    o       : armiu_dmstg_typ_out;
    commit : std_logic;
  end record;
  type armiu_dmstg_reg_type is record
    pctrl : apc_pctrl;
  end record;
  type armiu_dmstg_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_dmstg_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armiu_dmstg_reg_type;
  signal rdbg, cdbg : armiu_dmstg_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armiu_dmstg_reg_type;
    variable t    : armiu_dmstg_tmp_type;
    variable vdbg : armiu_dmstg_dbg_type;
  begin 
    
    -- $(init(t:armiu_dmstg_tmp_type))
    
    v := r;
    t.commit := not i.flush_v;
    
    -- reset
    if ( rst = '0' ) then
    end if;

    -- pipeline propagation
    t.o.pctrl_r := r.pctrl;
    t.o.toME_pctrl_v := v.pctrl;

    -- pipeline flush
    if not (t.commit = '1') then
      t.o.toME_pctrl_v.valid := '0';
    end if;
    
    if i.pstate.hold_r.hold = '0' then
      v.pctrl := i.fromEX_pctrl_v;
      if apc_is_straddr(r.pctrl) then
        v.pctrl.data1 := r.pctrl.data1;  -- address in writedata frame
      end if;
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
