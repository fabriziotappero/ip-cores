-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.armcmd.all;
use work.armpctrl.all;
use work.armpmodel.all;
use work.armdecode.all;
use work.armshiefter.all;
use work.armcmd_comp.all;

entity armcmd_sr is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_sr_typ_in;
    o       : out armcmd_sr_typ_out
    );
end armcmd_sr;

architecture rtl of armcmd_sr is

  type armcmd_sr_tmp_type is record
    o       : armcmd_sr_typ_out;
  end record;
  type armcmd_sr_reg_type is record
    dummy      : std_logic;
  end record;
  type armcmd_sr_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armcmd_sr_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armcmd_sr_reg_type;
  signal rdbg, cdbg : armcmd_sr_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armcmd_sr_reg_type;
    variable t    : armcmd_sr_tmp_type;
    variable vdbg : armcmd_sr_dbg_type;
  begin 
    
    -- $(init(t:armcmd_sr_tmp_type))
    
    v := r;

    t.o.ctrlo    := i.ctrli.ctrlo;
    
    t.o.r2_src  := acm_none;
    t.o.rd_src  := acm_rdnone;

    t.o.rsop_op2_src := apc_opsrc_none;
    t.o.rsop_styp := ash_styp_none;
    t.o.rsop_sdir := ash_sdir_snone;
    t.o.exop_setcpsr := '0';

    case i.ctrli.insn.decinsn is
      when type_arm_mrs => 
        t.o.rd_src  := acm_rdrrd;
      when type_arm_msr =>

        case i.ctrli.cnt is
          when ACM_CNT_ZERO =>

            -- [frame:] 
            --            RRSTG   |   RSSTG       EXSTG       DMSTG       MESTG       WRSTG
            --      --+-----------+-----------+-----------+-----------+-----------+----------+
            --        |           +           |           |           |           |
            --        |           |           | [cpsr]    |           |           |
            --        |  (regread)|  (shift)  |  | (aluop)|  (trans)  |   (dcache)| +(write)
            --        |           |    V      |  |        |           |           | | 
            --        |           |  [imrot]-op2-msr/rs   |           |           | +[spsr]
            --      --+-----------+-----------+-----+-----+-----------+-----------+-+--------+
            --                                      |                               | 
            --   (as wrdata on mrs) pctrl.data1:    +-------------------------------+    
            --   (as wrdata on msr[spsr]) 

            -- msr CPSR_[cxsf],#<imm>
            -- msr CPSR_[cxsf],<rm>  
            -- msr SPSR_[cxsf],#<imm>
            -- msr SPSR_[cxsf],<rm>  

            t.o.ctrlo.nextinsn := '0';

            t.o.rd_src  := acm_rdnone;
            t.o.rsop_op2_src := apc_opsrc_through;
        
            if i.ctrli.insn.insn(APM_MSR_F) = '1' or
              i.ctrli.insn.insn(APM_MSR_X) = '1' or
              i.ctrli.insn.insn(APM_MSR_S) = '1' then
              t.o.exop_setcpsr := '1';
            end if;
        
            if i.ctrli.insn.insn(ADE_MSR_IMM) = '1' then
              t.o.r2_src    := acm_none;
              t.o.rsop_styp := ash_styp_immrot;
              t.o.rsop_sdir := ash_sdir_snone;
            else
              t.o.r2_src    := acm_rrm;
              t.o.rsop_styp := ash_styp_none;
              t.o.rsop_sdir := ash_sdir_snone;
            end if;
           
          when others =>
            t.o.ctrlo.nextinsn := '0';
            t.o.ctrlo.hold := '1';

            -- wait until cmd commits
            if i.ctrli.insn.insn(ADE_MSR_R) = '1' then
              if (i.wrvalid = '1') and
                 (i.wrid = i.deid) then
                t.o.ctrlo.nextinsn := '1';
                t.o.ctrlo.hold := '0';
              end if;
            else
              if (i.exvalid = '1') and
                 (i.exid = i.deid) then
                t.o.ctrlo.nextinsn := '1';
                t.o.ctrlo.hold := '0';
              end if;
            end if;
        end case;        
      when others       => 
    end case;

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
