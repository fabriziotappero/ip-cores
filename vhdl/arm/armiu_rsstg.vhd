-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.armshiefter.all;
use work.armpctrl.all;
use work.armctrl.all;
use work.armpmodel.all;
use work.armdecode.all;
use work.arm_comp.all;

entity armiu_rsstg is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_rsstg_typ_in;
    o       : out armiu_rsstg_typ_out
    );
end armiu_rsstg;

architecture rtl of armiu_rsstg is

  type armiu_rsstg_tmp_type is record
    o       : armiu_rsstg_typ_out;
    commit : std_logic;
    shieftout      : std_logic_vector(31 downto 0);
    cond_fail : std_logic;
  end record;
  type armiu_rsstg_reg_type is record
    pctrl : apc_pctrl;
    buf1 : std_logic_vector(31 downto 0);
    buf2 : std_logic_vector(31 downto 0);
  end record;
  type armiu_rsstg_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_rsstg_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armiu_rsstg_reg_type;
  signal rdbg, cdbg : armiu_rsstg_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armiu_rsstg_reg_type;
    variable t    : armiu_rsstg_tmp_type;
    variable vdbg : armiu_rsstg_dbg_type;
  begin 
    
    -- $(init(t:armiu_rsstg_tmp_type))
    
    v := r;
    t.commit := not i.flush_v;
    
    aas_shieft( r.pctrl.insn.insn,
                r.pctrl.rs.rsop_sdir,
                r.pctrl.rs.rsop_styp,
                r.pctrl.data1,
                r.pctrl.data2,
                i.pstate.fromEX_cpsr_r.ex.c,
                t.shieftout,
                v.pctrl.rs.rs_shieftcarryout
                );
    
    -- reset
    if ( rst = '0' ) then
    end if;

    -- pipeline propagation
    t.o.pctrl_r := r.pctrl;
    t.o.toEX_pctrl_v := v.pctrl;
    
    -- pipeline flush
    if not (t.commit = '1') then
      t.o.toEX_pctrl_v.valid := '0';
    end if;

    case r.pctrl.rs.rsop_op1_src is
      when apc_opsrc_through => t.o.toEX_pctrl_v.data1 := r.pctrl.data1;
      when apc_opsrc_buf     => t.o.toEX_pctrl_v.data1 := r.buf1;
      when apc_opsrc_alures  => t.o.toEX_pctrl_v.data1 := i.fromEX_alures_v;
      when apc_opsrc_none    =>
      when others => 
    end case;

    case r.pctrl.rs.rsop_op2_src is
      when apc_opsrc_through => t.o.toEX_pctrl_v.data2 := t.shieftout;
      when apc_opsrc_buf     => t.o.toEX_pctrl_v.data2 := r.buf2;
      when apc_opsrc_alures  => t.o.toEX_pctrl_v.data2 := i.fromEX_alures_v;
      when apc_opsrc_none    =>
      when others => 
    end case;

    case r.pctrl.rs.rsop_buf1_src is
      when apc_bufsrc_through => v.buf1 := r.pctrl.data1;
      when apc_bufsrc_alures  => v.buf1 := i.fromEX_alures_v;
      when apc_bufsrc_none    =>
      when others => 
    end case;

    case r.pctrl.rs.rsop_buf2_src is
      when apc_bufsrc_through => v.buf2 := t.shieftout;
      when apc_bufsrc_alures  => v.buf2 := i.fromEX_alures_v;
      when apc_bufsrc_none    =>
      when others => 
    end case;

    t.cond_fail := '0';                 -- tmp for dbg
    if act_checkcond(i.fromEX_cpsr_v,r.pctrl.insn.insn(ADE_COND_U downto ADE_COND_D)) = '0' then
      t.cond_fail := '1';                 -- tmp for dbg
      t.o.toEX_pctrl_v.valid := '0';
    end if;
    
    -- todo: add pctrl owner propagation
    
    if i.pstate.hold_r.hold = '0' then
      if apc_is_valid(i.fromRR_pctrl_v) then
        v.pctrl := i.fromRR_pctrl_v;
      else
        if not apc_is_straddr(r.pctrl) then
          v.pctrl := i.fromRR_pctrl_v;
        else
          -- wait for store data (coming after this one)
          t.o.toEX_pctrl_v.valid := '0';
        end if;
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
