-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.arm_comp.all;
use work.armpctrl.all;
use work.armpmodel.all;
use work.armdecode.all;

entity armiu_wrstg is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_wrstg_typ_in;
    o       : out armiu_wrstg_typ_out
    );
end armiu_wrstg;

architecture rtl of armiu_wrstg is

  type armiu_wrstg_tmp_type is record
    o       : armiu_wrstg_typ_out;
    trap : apm_trapctrl;
    oldcpsr : apm_cpsr;
    newcpsr : apm_cpsr;
    oldspsr : apm_cpsr;
    newspsr : apm_cpsr;
    setspsr_mode : std_logic_vector(4 downto 0);
    spsr : apm_spsr;
    irqi_intack : std_logic;
  end record;
  type armiu_wrstg_reg_type is record
    pctrl : apc_pctrl;
    spsr : apm_spsr;
  end record;
  type armiu_wrstg_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_wrstg_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armiu_wrstg_reg_type;
  signal rdbg, cdbg : armiu_wrstg_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armiu_wrstg_reg_type;
    variable t    : armiu_wrstg_tmp_type;
    variable vdbg : armiu_wrstg_dbg_type;
  begin 

    -- $(init(t:armiu_wrstg_tmp_type))
    
    v := r;
    
    t.o.toDR_dabort_v := '0';
    t.o.toRR_rd_v := r.pctrl.wr.wrop_rd;
    t.o.toRR_rd_valid_v := '0';
    t.o.toEX_cpsrset_v := '0';
    t.o.toIM_branch_v := '0';
    t.o.irqi.intack := '0';
    t.o.irqi.irl := r.pctrl.data2(3 downto 0);
    t.irqi_intack := '0';
    t.trap := r.pctrl.wr.wrop_trap;
    
    t.setspsr_mode := r.pctrl.ex.ex_cpsr.wr.mode;
    t.oldspsr := apm_bankspsr( t.setspsr_mode, r.spsr );
    t.newspsr := t.oldspsr;
    t.spsr := r.spsr;
  
    if apc_is_memload(r.pctrl) then
      v.pctrl.me.mexc         := i.dco.wr_mexc;
      v.pctrl.data1           := i.dco.wr_data;
    end if;
    
    t.o.toRR_rd_data_v    := v.pctrl.data1;
    t.o.toIM_branchaddr_v := v.pctrl.data1;
    t.o.toCPWR_crd_data_v := v.pctrl.data1;
    
    -- swp loadmem frame
    case r.pctrl.insn.decinsn is
      when type_arm_swp | 
           type_arm_ldr1 =>
        --if ConditionPassed(cond) then
        --  if Rn[1:0] == 0b00 then
        --    temp = Memory[Rn,4]
        --  else if Rn[1:0] == 0b01 then
        --    temp = Memory[Rn,4] Rotate_Right 8
        --  else if Rn[1:0] == 0b10 then
        --    temp = Memory[Rn,4] Rotate_Right 16
        --  else /* Rn[1:0] == 0b11 */
        --    temp = Memory[Rn,4] Rotate_Right 24
        --  Memory[Rn,4] = Rm
        --  Rd = temp
        if r.pctrl.insn.insn(ADE_SWPB_C) = '0' then
          case r.pctrl.data1(1 downto 0) is
            when "00" =>
            when "01" => t.o.toRR_rd_data_v := t.o.toRR_rd_data_v( 7 downto 0) & t.o.toRR_rd_data_v(31 downto  8);
            when "10" => t.o.toRR_rd_data_v := t.o.toRR_rd_data_v(15 downto 0) & t.o.toRR_rd_data_v(31 downto 16);
            when "11" => t.o.toRR_rd_data_v := t.o.toRR_rd_data_v(23 downto 0) & t.o.toRR_rd_data_v(31 downto 24);
            when others =>
          end case;
        end if;
      when others =>
    end case;
    
    if apc_is_valid(r.pctrl) then

      -- mem exception
      if apc_is_mem(r.pctrl) then
        if v.pctrl.me.mexc = '1' then
          t.trap.trap := '1';
          t.trap.traptype := apm_trap_dabort;
        end if;
      end if;
      
      -- trap
      if (t.trap.trap = '0') then
        
        -- write register
        if r.pctrl.wr.wrop_rdvalid = '1' then
          t.o.toRR_rd_valid_v := '1';
        end if;
      
        -- branching
        if apc_is_branch(r.pctrl) then
          if apc_is_memload(r.pctrl) then
            t.o.toIM_branch_v := '1';
          end if;
        end if;
      
        case r.pctrl.insn.decinsn is
          when type_arm_msr =>
            if r.pctrl.insn.insn(ADE_MSR_R) = '1' then
              if apm_is_hasspsr(t.setspsr_mode) then
                t.newspsr := apm_msr ( r.pctrl.insn.insn, apm_stdtocpsr(r.pctrl.insn.insn) , t.oldspsr);
                apm_setspsr (t.setspsr_mode, t.spsr, t.newspsr);
              end if;
            end if;
          when others =>
        end case;
      
      else
        
        case t.trap.traptype is
          when apm_trap_reset =>
-- $(del)
-- R14_svc = UNPREDICTABLE value
-- SPSR_svc = UNPREDICTABLE value
-- CPSR[4:0] = 0b10011 /* Enter Supervisor mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- CPSR[6] = 1 /* Disable fast interrupts */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF0000
-- else
-- PC = 0x00000000
-- $(/del)

            t.o.toIM_branch_v := '1';
            t.o.toIM_branchaddr_v := APM_RESET_VEC;
            t.o.toEX_cpsrset_v := '1';
  
            t.newcpsr.wr.i := '1';
            t.newcpsr.wr.f := '1';
            t.newcpsr.wr.mode := APM_SVC;
          
          when apm_trap_undef =>

-- $(del)
-- R14_und = address of next instruction after the undefined instruction
-- SPSR_und = CPSR
-- CPSR[4:0] = 0b11011 /* Enter Undefined mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- /* CPSR[6] is unchanged */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF0004
-- else
-- PC = 0x00000004
-- $(/del)

            t.spsr.und_SPSR := r.pctrl.ex.ex_cpsr;

            t.o.toIM_branch_v := '1';
            t.o.toIM_branchaddr_v := APM_UNDEF_VEC;
            t.o.toEX_cpsrset_v := '1';
          
            t.newcpsr.wr.i := '1';
            t.newcpsr.wr.mode := APM_UND;
          
          when apm_trap_swi      =>

-- $(del)
-- R14_svc = address of next instruction after the SWI instruction
-- SPSR_svc = CPSR
-- CPSR[4:0] = 0b10011 /* Enter Supervisor mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- /* CPSR[6] is unchanged */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF0008
-- else
-- PC = 0x00000008
-- $(/del)
          
            t.spsr.svc_SPSR := r.pctrl.ex.ex_cpsr;
          
            t.o.toIM_branch_v := '1';
            t.o.toIM_branchaddr_v := APM_SWI_VEC;
            t.o.toEX_cpsrset_v := '1';
            
            t.newcpsr.wr.i := '1';
            t.newcpsr.wr.mode := APM_SVC;
          
          when apm_trap_prefch =>

-- $(del)
-- R14_abt = address of the aborted instruction + 4
-- SPSR_abt = CPSR
-- CPSR[4:0] = 0b10111 /* Enter Abort mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- /* CPSR[6] is unchanged */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF000C
-- else
-- PC = 0x0000000C
-- $(/del)
          
            t.spsr.abt_SPSR := r.pctrl.ex.ex_cpsr;
          
            t.o.toIM_branch_v := '1';
            t.o.toIM_branchaddr_v := APM_PREFCH_VEC;
            t.o.toEX_cpsrset_v := '1';
          
            t.newcpsr.wr.i := '1';
            t.newcpsr.wr.mode := APM_ABT;
          
          when apm_trap_dabort   =>

-- $(del)
-- R14_abt = address of the aborted instruction + 8
-- SPSR_abt = CPSR
-- CPSR[4:0] = 0b10111 /* Enter Abort mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- /* CPSR[6] is unchanged */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF0010
-- else
-- PC = 0x00000010
-- $(/del)
          
            t.spsr.abt_SPSR := r.pctrl.ex.ex_cpsr;

            t.o.toDR_dabort_v := '1';
            t.o.toIM_branch_v := '1';
            t.o.toIM_branchaddr_v := APM_DABORT_VEC;
            t.o.toRR_rd_data_v := r.pctrl.insn.pc_8;
            t.o.toEX_cpsrset_v := '1';
            
            t.newcpsr.wr.i := '1';
            t.newcpsr.wr.mode := APM_ABT;
            
          when apm_trap_irq      =>

-- $(del)
-- R14_irq = address of next instruction to be executed + 4
-- SPSR_irq = CPSR
-- CPSR[4:0] = 0b10010 /* Enter IRQ mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- /* CPSR[6] is unchanged */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF0018
-- else
-- PC = 0x00000018
-- $(/del)
            t.irqi_intack := '1';
            
            t.spsr.irq_SPSR := r.pctrl.ex.ex_cpsr;
          
            t.o.toIM_branch_v := '1';
            t.o.toIM_branchaddr_v := APM_IRQ_VEC;
            t.o.toEX_cpsrset_v := '1';

            t.newcpsr.wr.i := '1';
            t.newcpsr.wr.mode := APM_IRQ;
          
          when apm_trap_fiq      =>

-- $(del)
-- R14_fiq = address of next instruction to be executed + 4
-- SPSR_fiq = CPSR
-- CPSR[4:0] = 0b10001 /* Enter FIQ mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- CPSR[6] = 1 /* Disable fast interrupts */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF001C
-- else
-- PC = 0x0000001C
-- $(/del)

            t.spsr.fiq_SPSR := r.pctrl.ex.ex_cpsr;
          
            t.o.toIM_branch_v := '1';
            t.o.toIM_branchaddr_v := APM_FIQ_VEC;
            t.o.toEX_cpsrset_v := '1';

            t.newcpsr.wr.i := '1';
            t.newcpsr.wr.f := '1';
            t.newcpsr.wr.mode := APM_FIQ;
          
          when others            => 
        end case;

        t.o.toRR_rd_v := apm_bankreg(t.newcpsr.wr.mode,APM_REG_LINK);
        t.o.toRR_rd_valid_v := '1';
        
      end if;
    end if;
    

    -- reset
    if ( rst = '0' ) then
    end if;

    -- pipeline propagation
    t.o.pctrl_r := r.pctrl;
    t.o.spsr_r := r.spsr;
    
    t.o.toEX_cpsr_v := t.newcpsr;
    
    if i.pstate.hold_r.hold = '0' then
      v.spsr := t.spsr;
      v.pctrl := i.fromME_pctrl_v;
      t.o.irqi.intack := t.irqi_intack;
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
