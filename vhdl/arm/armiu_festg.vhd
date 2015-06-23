-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.armdecode.all;
use work.arm_comp.all;

entity armiu_festg is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_festg_typ_in;
    o       : out armiu_festg_typ_out
    );
end armiu_festg;

architecture rtl of armiu_festg is

  type armiu_festg_tmp_type is record
    o   : armiu_festg_typ_out;
    commit : std_logic;
    ico_insn : std_logic_vector(31 downto 0);
    reqinsn : std_logic;
  end record;
  type armiu_festg_reg_type is record
    cmp_valid : std_logic;
    toDE_insn : ade_feinsn;
    branch, trap : std_logic;
  end record;
  type armiu_festg_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_festg_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armiu_festg_reg_type;
  signal rdbg, cdbg : armiu_festg_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armiu_festg_reg_type;
    variable t    : armiu_festg_tmp_type;
    variable vdbg : armiu_festg_dbg_type;
  begin 
    
    -- $(init(t:armiu_festg_tmp_type))
    
    v := r;

    t.commit := not i.flush_v;
    t.ico_insn := i.ico.dat_line_v.data(0);
    
    t.reqinsn := (i.pstate.nextinsn_v and r.cmp_valid and (not r.trap));
    
    -- streaming
    if i.pstate.hold_r.hold = '0' and i.pstate.nextinsn_v = '1' then  -- and t.ici_null = '0
      v.toDE_insn.insn := t.ico_insn;
      v.toDE_insn.valid := r.cmp_valid;
      v.toDE_insn.trap := r.trap;
    end if;

    -- pipeline overrun, memory-data-strobe while holding pipeline
    if i.ico.mstrobe = '1' then
      v.toDE_insn.insn := t.ico_insn;
      v.toDE_insn.valid := r.cmp_valid;
      v.toDE_insn.trap := r.trap;
    end if;

    -- flush pipeline
    if not (t.commit = '1') then
      v.toDE_insn.trap := '0';
      v.toDE_insn.valid := '0';
      v.cmp_valid := '0';
      v.trap := '0';
    end if;
    
    -- pipeline step
    if i.pstate.hold_r.hold = '0' then
      v.cmp_valid := i.fromIM_addrvalid_v;
      v.trap := i.fromIM_trap_v;
      if i.pstate.nextinsn_v = '1' then
        v.toDE_insn.pc := i.fromIM_addrphy_v;
        v.toDE_insn.pc_vir := i.fromIM_addrvir_v;
        v.branch := i.fromIM_branch_v;
      end if;
    end if;

    -- reset
    if ( rst = '0' ) then
      v.cmp_valid := '0';
      v.toDE_insn.valid := '0';
    end if;

    -- icache input
    t.o.ici.pc_v := i.fromIM_addrphy_v;
    t.o.ici.pc_r := r.toDE_insn.pc;
    t.o.ici.bra_v := i.fromIM_branch_v;
    t.o.ici.bra_r := r.branch;
    t.o.ici.annul := not (t.reqinsn);
    t.o.ici.flush := '0';
    
    t.o.toDE_insn_v := v.toDE_insn;
    t.o.toDE_insn_r := r.toDE_insn;
    
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
