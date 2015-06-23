-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.int.all;
use work.memdef.all;
use work.armpmodel.all;
use work.armpctrl.all;
use work.armdecode.all;
use work.armdebug.all;
use work.arm_comp.all;

entity armiu_exstg is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_exstg_typ_in;
    o       : out armiu_exstg_typ_out
    );
end armiu_exstg;

architecture rtl of armiu_exstg is

  type exstg_tmp_resultsrc is (exstg_src_log, exstg_src_add);
  type armiu_exstg_tmp_type is record
    o       : armiu_exstg_typ_out;
    commit : std_logic;
    op1, op2: std_logic_vector(31 downto 0);  -- adder inputs
    log_AND, log_EOR, log_ORR : std_logic_vector(31 downto 0);  -- logic cmds
    log_MOV, log_BIC, log_MVN : std_logic_vector(31 downto 0);  --  move cmds
    add_carry, add_issub, add_usecarry, add_use : std_logic;  -- adder param
    src : exstg_tmp_resultsrc;
    src_log_data : std_logic_vector(31 downto 0);
    src_add_data : std_logic_vector(31 downto 0);
    result : std_logic_vector(31 downto 0);
    cpsr, newcpsr, spsr : apm_cpsr;
    
    -- pragma translate_off
    dbgaluop : adg_dbgaluop;
    -- pragma translate_on
  end record;
  type armiu_exstg_reg_type is record
    pctrl : apc_pctrl;
    cpsr : apm_cpsr;
    buf : std_logic_vector(31 downto 0);
  end record;
  type armiu_exstg_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_exstg_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armiu_exstg_reg_type;
  signal rdbg, cdbg : armiu_exstg_dbg_type;

begin  
    
  p0: process (clk, rst, r, i  )
    variable v    : armiu_exstg_reg_type;
    variable t    : armiu_exstg_tmp_type;
    variable vdbg : armiu_exstg_dbg_type;
  begin 
    
    -- $(init(t:armiu_exstg_tmp_type))
    
    v := r;
    
    t.commit := not i.flush_v;
    t.spsr := r.cpsr;
    t.spsr := apm_bankspsr(r.cpsr.wr.mode, i.fromWR_spsr_r);
           
    t.add_carry := r.cpsr.ex.c;
    t.add_issub := '0';
    t.add_usecarry := '0';
    t.add_use := '0';
    
    t.op1 := (others => '0');
    t.op2 := (others => '0');
    
    t.log_AND := r.pctrl.data1 and r.pctrl.data2;
    t.log_EOR := r.pctrl.data1 xor r.pctrl.data2;
    t.log_ORR := r.pctrl.data1 or r.pctrl.data2;
    t.log_MOV := r.pctrl.data2;
    t.log_BIC := r.pctrl.data1 and not r.pctrl.data2;
    t.log_MVN := not r.pctrl.data2;
    
    t.src_log_data := t.log_AND; 
    case r.pctrl.ex.exop_aluop is
      when ADE_OP_AND => t.src := exstg_src_log; t.src_log_data := t.log_AND; 
      when ADE_OP_EOR => t.src := exstg_src_log; t.src_log_data := t.log_EOR; 
      when ADE_OP_SUB => t.src := exstg_src_add; t.add_issub := '1'; t.add_use := '1';
                         t.op1 := r.pctrl.data1;
                         t.op2 := r.pctrl.data2;
      when ADE_OP_RSB => t.src := exstg_src_add; t.add_issub := '1';  t.add_use := '1';
                         t.op1 := r.pctrl.data2;
                         t.op2 := r.pctrl.data1;
      when ADE_OP_ADD => t.src := exstg_src_add; t.add_use := '1';
                         t.op1 := r.pctrl.data1;
                         t.op2 := r.pctrl.data2;
      when ADE_OP_ADC => t.src := exstg_src_add; t.add_usecarry := '1'; t.add_use := '1';
                         t.op1 := r.pctrl.data1;
                         t.op2 := r.pctrl.data2;
      when ADE_OP_SBC => t.src := exstg_src_add; t.add_usecarry := '1'; t.add_issub := '1'; t.add_carry := not t.add_carry; t.add_use := '1';
                         t.op1 := r.pctrl.data1;
                         t.op2 := r.pctrl.data2;
      when ADE_OP_RSC => t.src := exstg_src_add; t.add_usecarry := '1'; t.add_issub := '1'; t.add_carry := not t.add_carry; t.add_use := '1';
                         t.op2 := r.pctrl.data1;
                         t.op1 := r.pctrl.data2;
      when ADE_OP_TST => t.src := exstg_src_log; t.src_log_data := t.log_AND;
      when ADE_OP_TEQ => t.src := exstg_src_log; t.src_log_data := t.log_EOR; 
      when ADE_OP_CMP => t.src := exstg_src_add; t.add_issub := '1'; t.add_use := '1';
                         t.op1 := r.pctrl.data1;
                         t.op2 := r.pctrl.data2;
      when ADE_OP_CMN => t.src := exstg_src_add; t.add_use := '1';
                         t.op1 := r.pctrl.data1;
                         t.op2 := r.pctrl.data2;
      when ADE_OP_ORR => t.src := exstg_src_log; t.src_log_data := t.log_ORR; 
      when ADE_OP_MOV => t.src := exstg_src_log; t.src_log_data := t.log_MOV;
      when ADE_OP_BIC => t.src := exstg_src_log; t.src_log_data := t.log_BIC;
      when ADE_OP_MVN => t.src := exstg_src_log; t.src_log_data := t.log_MVN;
      when others => null;
    end case;
    
    if t.add_usecarry = '0' then
      t.add_carry := '0';
    end if;
    
    if t.add_issub = '1' then
      t.op2 := not t.op2;
      t.add_carry := not t.add_carry;
    end if;
    
    -- the adder
    lin_adder( t.op1, t.op2, t.add_carry, '0', t.src_add_data );
    
    t.result := t.src_add_data;
    case t.src is
      when exstg_src_log => t.result := t.src_log_data;  -- logic cmd
      when exstg_src_add => t.result := t.src_add_data;  -- adder cmd
      when others =>
    end case;

    -- calc cpsr
    t.cpsr := r.cpsr;
    if t.add_issub = '1' then
      t.cpsr.ex.c :=                         ((not t.op1(31)) and t.op2(31)) or 	 -- Carry
                     (t.src_add_data(31) and ((not t.op1(31)) or  t.op2(31)));
      t.cpsr.ex.v := (     t.op1(31)  and (not t.op2(31)) and not t.src_add_data(31)) or -- Overflow
                     ((not t.op1(31)) and      t.op2(31)  and     t.src_add_data(31));
    else
      t.cpsr.ex.c :=                               (t.op1(31) and t.op2(31)) or 	 -- Carry
                     ((not t.src_add_data(31)) and (t.op1(31) or  t.op2(31)));
      t.cpsr.ex.v := (    t.op1(31)  and      t.op2(31) and not t.src_add_data(31)) or 	 -- Overflow
                    ((not t.op1(31)) and (not t.op2(31)) and    t.src_add_data(31));
    end if;
    if t.result = LIN_ZERO then 
      t.cpsr.ex.z := '1';
    else
      t.cpsr.ex.z := '0';
    end if;
    t.cpsr.ex.n := t.result(31);
    
    -- calc new cpsr
    t.newcpsr := r.cpsr;
    case r.pctrl.insn.decinsn is
      when type_arm_invalid => null;
      when type_arm_nop => null;
      when type_arm_mrs => null;
        if r.pctrl.insn.insn(ADE_MRS_R) = '0' then
          t.result := apm_cpsrtostd (r.cpsr);
        else
          t.result := apm_cpsrtostd (t.spsr);
        end if;
      when type_arm_msr =>
        if r.pctrl.insn.insn(ADE_MSR_R) = '0' then
          if apm_is_privmode(r.cpsr.wr.mode) then
            t.newcpsr := apm_msr ( r.pctrl.insn.insn, apm_stdtocpsr(r.pctrl.insn.insn) , r.cpsr);
          end if;
        end if;
      when type_arm_bx => null;
      when type_arm_mul => null;
      when type_arm_mla => null;
      when type_arm_swp => null;
      when type_arm_sumull => null;
      when type_arm_sumlal => null;
      when type_arm_teq =>

        -- Test Equivalence
        -- $(del)
        -- arm@4.1.53:
        -- if ConditionPassed(cond) then 
        --  alu_out = Rn EOR shifter_operand
        --  N Flag = alu_out[31]
        --  Z Flag = if alu_out == 0 then 1 else 0
        --  C Flag = shifter_carry_out
        --  V Flag = unaffected
        -- $(/del)
        
        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := r.pctrl.rs.rs_shieftcarryout;
                       
      when type_arm_tst =>
        
        -- Test
        -- $(del)
        -- arm@4.1.54:         
        --if ConditionPassed(cond) then 
        -- alu_out = Rn AND shifter_operand
        -- N Flag = alu_out[31]
        -- Z Flag = if alu_out == 0 then 1 else 0
        -- C Flag = shifter_carry_out
        -- V Flag = unaffected
        -- $(/del)
        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := r.pctrl.rs.rs_shieftcarryout;
        
      when type_arm_cmn =>

        -- Compare Negative
        -- $(del)
        -- arm@4.1.13:         
        -- if ConditionPassed(cond) then
        --  alu_out = Rn + shifter_operand
        --  N Flag = alu_out[31]
        --  Z Flag = if alu_out == 0 then 1 else 0
        --  C Flag = CarryFrom(Rn + shifter_operand)
        --  V Flag = OverflowFrom(Rn + shifter_operand)
        -- $(/del)
        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := t.cpsr.ex.c;
        t.newcpsr.ex.v := t.cpsr.ex.v;        
  
      when type_arm_cmp => 

        -- Compare
        -- $(del)
        -- arm@4.1.14:         
        --if ConditionPassed(cond) then
        -- alu_out = Rn - shifter_operand
        -- N Flag = alu_out[31]
        -- Z Flag = if alu_out == 0 then 1 else 0
        -- C Flag = NOT BorrowFrom(Rn - shifter_operand)
        -- V Flag = OverflowFrom(Rn - shifter_operand)
        -- $(/del)

        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := not t.cpsr.ex.c;
        t.newcpsr.ex.v := t.cpsr.ex.v;        
        
      when type_arm_and =>
        
        -- Logical And
        -- $(del)
        -- arm@4.1.4:         
        --if ConditionPassed(cond) then 
        -- Rd = Rn AND shifter_operand
        -- if S == 1 and Rd == R15 then
        --  CPSR = SPSR
        -- else if S == 1 then
        --  N Flag = Rd[31]
        --  Z Flag = if Rd == 0 then 1 else 0
        --  C Flag = shifter_carry_out
        --  V Flag = unaffected
        -- $(/del)
        
        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := r.pctrl.rs.rs_shieftcarryout;

      when type_arm_eor =>

        -- Logical Exclusive Or
        -- $(del)
        -- arm@4.1.15:         
        --if ConditionPassed(cond) then 
        -- Rd = Rn EOR shifter_operand
        -- if S == 1 and Rd == R15 then
        --  CPSR = SPSR
        -- else if S == 1 then 
        --  N Flag = Rd[31]
        --  Z Flag = if Rd == 0 then 1 else 0
        --  C Flag = shifter_carry_out
        --  V Flag = unaffected
        -- $(/del)
        
        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := r.pctrl.rs.rs_shieftcarryout;

      
      when type_arm_orr =>
        
        -- Logical Or
        -- $(del)
        -- arm@4.1.35:         
        --if ConditionPassed(cond) then 
        -- Rd = Rn OR shifter_operand
        -- if S == 1 and Rd == R15 then
        --  CPSR = SPSR
        -- else if S == 1 then
        --  N Flag = Rd[31]
        --  Z Flag = if Rd == 0 then 1 else 0
        --  C Flag = shifter_carry_out
        --  V Flag = unaffected
        -- $(/del)

        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := r.pctrl.rs.rs_shieftcarryout;

      when type_arm_bic => 

        -- Bit Clear
        -- $(del)
        -- arm@4.1.6:         
        --if ConditionPassed(cond) then 
        -- Rd = Rn AND NOT shifter_operand
        -- if S == 1 and Rd == R15 then
        --  CPSR = SPSR
        -- else if S == 1 then
        --  N Flag = Rd[31]
        --  Z Flag = if Rd == 0 then 1 else 0
        --  C Flag = shifter_carry_out
        --  V Flag = unaffected
        -- $(/del)
        
        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := r.pctrl.rs.rs_shieftcarryout;

      when type_arm_mov =>
        
        --
        -- $(del)
        -- arm@4.1.29:         
        --if ConditionPassed(cond) then
        -- Rd = shifter_operand
        -- if S == 1 and Rd == R15 then
        --  CPSR = SPSR
        -- else if S == 1 then
        --  N Flag = Rd[31]
        --  Z Flag = if Rd == 0 then 1 else 0
        --  C Flag = shifter_carry_out
        --  V Flag = unaffected
        -- $(/del)

        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := r.pctrl.rs.rs_shieftcarryout;
        
      when type_arm_mvn  =>
        
        -- Move Negative
        -- $(del)
        -- arm@4.1.34:         
        --if ConditionPassed(cond) then
        -- Rd = NOT shifter_operand
        -- if S == 1 and Rd == R15 then
        --  CPSR = SPSR
        -- else if S == 1 then
        --  N Flag = Rd[31]
        --  Z Flag = if Rd == 0 then 1 else 0
        --  C Flag = shifter_carry_out
        --  V Flag = unaffected
        -- $(/del)

        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := r.pctrl.rs.rs_shieftcarryout;
        
      when type_arm_sub =>

        --
        -- $(del)
        -- arm@4.1.49:         
        --if ConditionPassed(cond) then
        -- Rd = Rn - shifter_operand
        -- if S == 1 and Rd == R15 then
        --  CPSR = SPSR
        -- else if S == 1 then
        --  N Flag = Rd[31]
        --  Z Flag = if Rd == 0 then 1 else 0
        --  C Flag = NOT BorrowFrom(Rn - shifter_operand)
        --  V Flag = OverflowFrom(Rn - shifter_operand)
        -- $(/del)
        
        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := not t.cpsr.ex.c;
        t.newcpsr.ex.v := t.cpsr.ex.v;
        
      when type_arm_add =>
        
        --
        -- $(del)
        -- arm@4.1.3:         
        --if ConditionPassed(cond) then
        --  Rd = Rn + shifter_operand
        -- if S == 1 and Rd == R15 then
        --  CPSR = SPSR
        -- else if S == 1 then
        --  N Flag = Rd[31]
        --  Z Flag = if Rd == 0 then 1 else 0
        --  C Flag = CarryFrom(Rn + shifter_operand)
        --  V Flag = OverflowFrom(Rn + shifter_operand)
        -- $(/del)

        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := t.cpsr.ex.c;
        t.newcpsr.ex.v := t.cpsr.ex.v;        

      when type_arm_rsb =>
        
        -- Reverse Subtract
        -- $(del)
        -- arm@4.1.36:         
        --if ConditionPassed(cond) then
        -- Rd = shifter_operand - Rn
        -- if S == 1 and Rd == R15 then
        --  CPSR = SPSR
        -- else if S == 1 then
        --  N Flag = Rd[31]
        --  Z Flag = if Rd == 0 then 1 else 0
        --  C Flag = NOT BorrowFrom(shifter_operand - Rn)
        --  V Flag = OverflowFrom(shifter_operand - Rn)
        -- $(/del)

        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := not t.cpsr.ex.c;
        t.newcpsr.ex.v := t.cpsr.ex.v;
        
      when type_arm_adc =>

        -- Add with Carry
        -- $(del)
        -- arm@4.1.2:         
        --if ConditionPassed(cond) then
        -- Rd = Rn + shifter_operand + C Flag
        --if S == 1 and Rd == R15 then
        -- CPSR = SPSR
        --else if S == 1 then
        -- N Flag = Rd[31]
        -- Z Flag = if Rd == 0 then 1 else 0
        -- C Flag = CarryFrom(Rn + shifter_operand + C Flag) 
        -- V Flag = OverflowFrom(Rn + shifter_operand + C Flag)
        -- $(/del)

        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := t.cpsr.ex.c;
        t.newcpsr.ex.v := t.cpsr.ex.v;

      when type_arm_sbc =>

        -- Subtract with Carry
        -- $(del)
        -- arm@4.1.38:         
        --if ConditionPassed(cond) then
        -- Rd = Rn - shifter_operand - NOT(C Flag)
        -- if S == 1 and Rd == R15 then
        --  CPSR = SPSR
        -- else if S == 1 then
        --  N Flag = Rd[31]
        --  Z Flag = if Rd == 0 then 1 else 0
        --  C Flag = NOT BorrowFrom(Rn - shifter_operand - NOT(C Flag))
        --  V Flag = OverflowFrom(Rn - shifter_operand - NOT(C Flag))
        -- $(/del)

        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := not t.cpsr.ex.c;
        t.newcpsr.ex.v := t.cpsr.ex.v;
        
      when type_arm_rsc =>
        
        -- Reverse Subtract with Carry
        -- $(del)
        -- arm@4.1.37:         
        --if ConditionPassed(cond) then
        -- Rd = shifter_operand - Rn - NOT(C Flag)
        -- if S == 1 and Rd == R15 then
        --  CPSR = SPSR
        -- else if S == 1 then
        --  N Flag = Rd[31]
        --  Z Flag = if Rd == 0 then 1 else 0
        --  C Flag = NOT BorrowFrom(shifter_operand - Rn - NOT(C Flag))
        --  V Flag = OverflowFrom(shifter_operand - Rn - NOT(C Flag))
        -- $(/del)

        t.newcpsr.ex.n := t.cpsr.ex.n;
        t.newcpsr.ex.z := t.cpsr.ex.z;
        t.newcpsr.ex.c := not t.cpsr.ex.c;
        t.newcpsr.ex.v := t.cpsr.ex.v;
        
      when type_arm_strhb =>
      when type_arm_str1 |
           type_arm_str2 |
           type_arm_str3 =>
      when type_arm_ldrhb =>
      when type_arm_ldr1 => null; 
      when type_arm_undefined => null;
      when type_arm_stm => null; 
      when type_arm_ldm => null; 
      when type_arm_b => null;   
      when type_arm_swi => null; 
      when others => null;
    end case;
    

    -- reset
    if ( rst = '0' ) then
      v.cpsr.ex.n := '0';
      v.cpsr.ex.z := '0';
      v.cpsr.ex.c := '0';
      v.cpsr.ex.v := '0';

      v.cpsr.wr.i := '0';
      v.cpsr.wr.f := '0';
      v.cpsr.wr.t := '0';
      
      v.cpsr.wr.mode := APM_SVC;     -- change
    end if;
    
    -- pipeline propagation
    t.o.pctrl_r := r.pctrl;
    t.o.toDM_pctrl_v := v.pctrl;

    -- pipeline flush
    if not (t.commit = '1') then
      t.o.toDM_pctrl_v.valid := '0';
    end if;
    
    t.o.cpsr_r := r.cpsr;
    t.o.alures_v := t.result;
    t.o.toIM_branch_v := '0';
    t.o.flush_v := '0';
    
    case r.pctrl.ex.exop_data_src is
      when apc_datasrc_aluout => t.o.toDM_pctrl_v.data1 := t.result;
-- todo: check obsolete apd_datasrc_op1
      --when apc_datasrc_op1    => t.o.toDM_pctrl_v.data1 := r.pctrl.data1;
      when apc_datasrc_buf    => t.o.toDM_pctrl_v.data1 := r.buf;
      when apc_datasrc_none => 
      when others => null;
    end case;
    
    if apc_is_strdata(r.pctrl) then
      case r.pctrl.me.meop_param.size is
        when lmd_byte => t.o.toDM_pctrl_v.data2 := r.pctrl.data2(7 downto 0) & r.pctrl.data2(7 downto 0) & r.pctrl.data2(7 downto 0) & r.pctrl.data2(7 downto 0);
        when lmd_half => t.o.toDM_pctrl_v.data2 := r.pctrl.data2(15 downto 0) & r.pctrl.data2(15 downto 0);
        when others => 
      end case;
    end if;
    
    case r.pctrl.ex.exop_buf_src is
      when apc_exbufsrc_aluout => v.buf := t.result;
      when apc_exbufsrc_op1    => v.buf := r.pctrl.data1;
      when apc_exbufsrc_none => 
      when others => null;
    end case;

    -- branching
    if apc_is_valid(r.pctrl) then
      if apc_is_branch(r.pctrl) then
        t.o.flush_v := '1';
        if not apc_is_memload(r.pctrl) then
          if t.commit = '1' then
            t.o.toIM_branch_v := '1';
          end if;
        end if;
      end if;
    end if;

    if apc_is_valid(r.pctrl) then
      if r.pctrl.wr.wrop_trap.trap = '1' then
        t.o.flush_v := '1';
        case r.pctrl.wr.wrop_trap.traptype is
          when apm_trap_reset    =>
            
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

          
          when others            => 
        end case;
      end if;
    end if;

    
    t.o.toDM_pctrl_v.ex.ex_cpsr := r.cpsr;

    if i.pstate.hold_r.hold = '0' then
      v.pctrl := i.fromRS_pctrl_v;
      if apc_is_valid(r.pctrl) then
        if t.commit = '1' then
          v.cpsr := t.newcpsr;
        end if;
      end if;
      if i.fromWR_cpsrset_v = '1' then
        v.cpsr := i.fromWR_cpsr_v;
      end if;
    end if;

    t.o.cpsr_v := v.cpsr;

    c <= v;

    o <= t.o;
    
    -- pragma translate_off
    vdbg := rdbg;
    vdbg.dbg := t;
    vdbg.dbg.dbgaluop := adg_todbgaluop(r.pctrl.ex.exop_aluop);
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
