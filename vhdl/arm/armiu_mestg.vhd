-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.armpctrl.all;
use work.armdecode.all;
use work.arm_comp.all;
use work.armpmodel.all;
use work.ctrl_comp.all;

entity armiu_mestg is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_mestg_typ_in;
    o       : out armiu_mestg_typ_out
    );
end armiu_mestg;

architecture rtl of armiu_mestg is

  type armiu_mestg_tmp_type is record
    o       : armiu_mestg_typ_out;
    commit : std_logic;
    meid : std_logic_vector(2 downto 0);
    wrid : std_logic_vector(2 downto 0);
  end record;
  type armiu_mestg_reg_type is record
    pctrl : apc_pctrl;
    mexc : std_logic;
  end record;
  type armiu_mestg_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_mestg_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armiu_mestg_reg_type;
  signal rdbg, cdbg : armiu_mestg_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armiu_mestg_reg_type;
    variable t    : armiu_mestg_tmp_type;
    variable vdbg : armiu_mestg_dbg_type;
  begin 
    
    -- $(init(t:armiu_mestg_tmp_type))
    
    v := r;
    t.commit := not i.flush_v ;

    t.meid := i.pstate.fromME_pctrl_r.insn.id;
    t.wrid := i.pstate.fromWR_pctrl_r.insn.id;
    
    --if i.dco.me_mexc = '1' then
    --  v.mexc := '1';
    --end if;
    
    -- swp addresses
    t.o.dci.addr_in := i.pstate.fromDM_pctrl_r.data1;
    case i.pstate.fromDM_pctrl_r.insn.decinsn is
      when type_arm_swp =>
        t.o.dci.addr_in(1 downto 0) := (others => '0');
      when others =>
    end case;
    t.o.dci.addr_re := r.pctrl.data1;
    t.o.dci.atomic_readwrite := '0';
    case r.pctrl.insn.decinsn is
      when type_arm_swp =>
        t.o.dci.addr_re(1 downto 0) := (others => '0');
        t.o.dci.atomic_readwrite := '1';
      when others =>
    end case;
    
    -- reset
    if ( rst = '0' ) then
      v.mexc := '0';
    end if;
    
    -- pipeline propagation
    t.o.pctrl_r := r.pctrl;
    t.o.toWR_pctrl_v := v.pctrl;
    
    -- irq
    if (not (i.irqo.irl = IRQ_NOIRQ)) and
       (not (t.meid = t.wrid)) then
      t.commit := '0';
      t.o.toWR_pctrl_v.wr.wrop_trap.trap := '1';
      t.o.toWR_pctrl_v.wr.wrop_trap.traptype := apm_trap_irq;
      t.o.toWR_pctrl_v.data2(3 downto 0) := i.irqo.irl;
    end if;
    
    -- dcache input
    t.o.dci.data_in  := i.pstate.fromDM_pctrl_r.data2;
    t.o.dci.data_re  := r.pctrl.data2;
    
    t.o.dci.addrin_re := r.pctrl.me.meop_param.addrin and
                         r.pctrl.valid; 
    t.o.dci.annul := (not t.commit) ; 
    t.o.dci.forcewrite := '0';
    t.o.dci.forceread := '0';
    
    t.o.dci.param_r.size      := r.pctrl.me.meop_param.size;
    t.o.dci.param_r.read      := r.pctrl.me.meop_param.read;
    t.o.dci.param_r.lock      := r.pctrl.me.meop_param.lock;
    t.o.dci.param_r.writedata := r.pctrl.me.meop_param.writedata;
    t.o.dci.param_r.addrin    := r.pctrl.me.meop_param.addrin;
    t.o.dci.param_r.signed    := r.pctrl.me.meop_param.signed;
    
    -- pipeline flush
    if not (t.commit = '1') then
      t.o.toWR_pctrl_v.valid := '0';
    end if;
    
    if i.pstate.hold_r.hold = '0' then
      v.pctrl := i.fromDM_pctrl_v;
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
