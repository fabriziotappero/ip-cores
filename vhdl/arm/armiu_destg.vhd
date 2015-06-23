-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.memdef.all;
use work.int.all;
use work.armdecode.all;
use work.arm_comp.all;

entity armiu_destg is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_destg_typ_in;
    o       : out armiu_destg_typ_out
    );
end armiu_destg;

architecture rtl of armiu_destg is

  type armiu_destg_tmp_type is record
    o : armiu_destg_typ_out;
    commit : std_logic;
    decinsn : ade_deinsn;
  end record;
  type armiu_destg_reg_type is record
    decinsn : ade_deinsn;
    id      : std_logic_vector(2 downto 0);
  end record;
  type armiu_destg_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_destg_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armiu_destg_reg_type;
  signal rdbg, cdbg : armiu_destg_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armiu_destg_reg_type;
    variable t    : armiu_destg_tmp_type;
    variable vdbg : armiu_destg_dbg_type;
  begin 
    
    -- $(init(t:armiu_destg_tmp_type))
    
    v := r;
    t.commit := not i.flush_v;
      
    t.decinsn.insn.pc_8 := i.fromFE_insn_v.pc_vir;
    t.decinsn.insn.insn := i.fromFE_insn_r.insn;
    t.decinsn.insn.insn := lmd_convert ( t.decinsn.insn.insn, CFG_BO_INSN, CFG_BO_PROC );
    t.decinsn.insn.decinsn := ade_decode_v4 ( t.decinsn.insn.insn );
    ade_decode_amode ( t.decinsn.insn.insn, t.decinsn.insn.am );
    t.decinsn.insn.valid := i.fromFE_insn_r.valid;
    t.decinsn.insn.id := r.id;
    
    if i.fromFE_insn_r.trap = '1' then
      t.decinsn.insn.decinsn := type_arm_nop;
      t.decinsn.insn.valid := '1';
      t.decinsn.trap := '1';
    end if;
    
    t.decinsn.insn.insntyp := ade_typmisc;
    case t.decinsn.insn.decinsn is
      when type_arm_invalid => 
      when type_arm_nop => 
      when type_arm_mrs | 
           type_arm_msr => 
      when type_arm_bx => 
      when type_arm_mul => 
        t.decinsn.insn.insntyp := ade_typalu;
      when type_arm_mla => 
        t.decinsn.insn.insntyp := ade_typalu;
      when type_arm_sumull => 
        t.decinsn.insn.insntyp := ade_typalu;
      when type_arm_sumlal => 
        t.decinsn.insn.insntyp := ade_typalu;
      when type_arm_teq |  
           type_arm_cmn |  
           type_arm_tst |  
           type_arm_cmp => 
        t.decinsn.insn.insntyp := ade_typalu;
      when type_arm_and |
           type_arm_sub |
           type_arm_eor |
           type_arm_rsb |
           type_arm_add |
           type_arm_orr |
           type_arm_bic |
           type_arm_mov |
           type_arm_mvn | 
           type_arm_sbc |  
           type_arm_adc |  
           type_arm_rsc =>
        t.decinsn.insn.insntyp := ade_typalu;
      when type_arm_str1 |
           type_arm_str2 |
           type_arm_str3 |
           type_arm_strhb =>
        t.decinsn.insn.insntyp := ade_typmem;
      when type_arm_ldr1 |
           type_arm_ldrhb =>
        t.decinsn.insn.insntyp := ade_typmem;
      when type_arm_stm =>              
        t.decinsn.insn.insntyp := ade_typmem;
      when type_arm_ldm =>              
        t.decinsn.insn.insntyp := ade_typmem;
      when type_arm_b =>
      when type_arm_swp => 
        t.decinsn.insn.insntyp := ade_typmem;
      when type_arm_stc =>
        t.decinsn.insn.insntyp := ade_typcp;
      when type_arm_ldc =>
        t.decinsn.insn.insntyp := ade_typcp;
      when type_arm_mrc |
           type_arm_mcr =>
        t.decinsn.insn.insntyp := ade_typcp;
      when type_arm_cdp =>
        t.decinsn.insn.insntyp := ade_typcp;
      when type_arm_swi =>
      when type_arm_undefined =>
      when others => 
    end case;

    -- pipeline flush
    if not (t.commit = '1') then
      t.decinsn.insn.valid := '0';
    end if;

    -- pipeline step
    if i.pstate.hold_r.hold = '0' then
      if i.pstate.nextinsn_v = '1' then
        v.decinsn := t.decinsn;
        v.decinsn.insn.pc_8 := i.fromFE_insn_v.pc_vir;
        v.decinsn.insn.id := r.id;
        lin_incdec(r.id,v.id,'1','1');
      end if;
    end if;
    
    t.o.toDR_insn_r := r.decinsn;
    t.o.toDR_insn_v := v.decinsn;
    
    -- reset
    if ( rst = '0' ) then
      v.decinsn.insn.valid := '0';
      v.id := (others => '0');
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
