-- $(lic)
-- $(help_generic)
-- $(help_local)

library IEEE;
use IEEE.std_logic_1164.all;
use work.amba.all;
use work.corelib.all;
use work.bus_comp.all;
use work.cache_comp.all;
use work.ctrl_comp.all;
use work.armpctrl.all;
use work.armpmodel.all;
use work.armdecode.all;

package arm_comp is

type arm_proc_typ_in is record
   irqo : irq_iu_out_type;
end record;

type arm_proc_typ_out is record
   irqi : irq_iu_in_type;
end record;

component arm_proc
  generic (
    TEST_CACHE : boolean := false
  );
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    clkn   : in  std_logic;
    i      : in arm_proc_typ_in;
    o      : out arm_proc_typ_out;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type
  );
end component; 

component armcache 
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    hold   : in cli_hold;
    ici    : in genic_type_in;
    ico    : out genic_type_out;
    dci    : in gendc_type_in;
    dco    : out gendc_type_out;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type
  );
end component;  

type armiu_typ_in is record
   irqo : irq_iu_out_type;
end record;

type armiu_typ_out is record
   irqi : irq_iu_in_type;
end record;

component armiu 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    clkn    : in  std_logic;
    hold    : in cli_hold;
    ici     : out genic_type_in;
    ico     : in genic_type_out;
    dci     : out gendc_type_in;
    dco     : in gendc_type_out;
    i       : in  armiu_typ_in;
    o       : out armiu_typ_out
    );
end component;

component tbench_armcache 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    clkn    : in  std_logic;
    hold    : in cli_hold;
    ici     : out genic_type_in;
    ico     : in genic_type_out;
    dci     : out gendc_type_in;
    dco     : in gendc_type_out;
    i       : in  armiu_typ_in;
    o       : out armiu_typ_out
    );
end component;

-------------------------------------------------------------------------------

-- imstg inputs:
-- pstate          : [rrstg,wrstg] pctrls + hold + nextinsn

type armiu_imstg_typ_in is record
   pstate : apc_pstate;
   flush_v : std_logic;
   branch_v : std_logic;
   addrvir_v : std_logic_vector(31 downto 0);
end record;

-- imstg outputs:
-- toFE_addrphy_v   : translated physical address
-- toFE_addrvir_v   : current virtual address
-- toFE_addrvalid_v : addr valid ('0' after pflush until next branchaddr enters)
-- toFE_branch_v    : is branch
-- toFE_trap_v      : prefectch trap

type armiu_imstg_typ_out is record
   toFE_addrphy_v   : std_logic_vector(31 downto 0);
   toFE_addrvir_v   : std_logic_vector(31 downto 0);
   toFE_addrvalid_v : std_logic;
   toFE_branch_v    : std_logic;
   toFE_trap_v      : std_logic;
end record;

component armiu_imstg 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_imstg_typ_in;
    o       : out armiu_imstg_typ_out
    );
end component;

-------------------------------------------------------------------------------
-- festg inputs:
-- pstate          : [rrstg,wrstg] pctrls + hold + nextinsn
-- fromIM_addrphy_v   : translated physical address
-- fromIM_addrvir_v   : current virtual address
-- fromIM_addrvalid_v : addr valid ('0' after pflush until next branchaddr enters)
-- fromIM_branch_v    : is branch
-- fromIM_trap_v      : prefectch trap

type armiu_festg_typ_in is record
   pstate : apc_pstate;
   flush_v : std_logic;
   ico   : genic_type_out;
   fromIM_addrphy_v   : std_logic_vector(31 downto 0);
   fromIM_addrvir_v   : std_logic_vector(31 downto 0);
   fromIM_addrvalid_v : std_logic;
   fromIM_branch_v    : std_logic;
   fromIM_trap_v      : std_logic;
end record;

-- festg outputs:
-- toDE_insn_r    : fetched insn (drives destg)
-- toDE_insn_v    : next cycle fetched insn (sampled on pstate.hold and pstate.nextinsn)

type armiu_festg_typ_out is record
   ici   : genic_type_in;
   toDE_insn_r : ade_feinsn;
   toDE_insn_v : ade_feinsn;
end record;

component armiu_festg 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_festg_typ_in;
    o       : out armiu_festg_typ_out
    );
end component;

-------------------------------------------------------------------------------

-- destg inputs:
-- pstate          : [rrstg,wrstg] pctrls + hold + nextinsn
-- fromFE_insn_r   : fetched insn (drives destg)
-- fromFE_insn_v   : next cycle fetched insn (sampled in festg on pstate.hold and pstate.nextinsn)

type armiu_destg_typ_in is record
   pstate : apc_pstate;
   flush_v : std_logic;
   fromFE_insn_r : ade_feinsn;
   fromFE_insn_v : ade_feinsn;
end record;

-- destg outputs:
-- toDR_insn_r    : decoded insn (drives drstg)
-- toDR_insn_v    : next cycle decoded insn, (sampled on pstate.hold and pstate.nextinsn)

type armiu_destg_typ_out is record
   toDR_insn_r : ade_deinsn;
   toDR_insn_v : ade_deinsn;
end record;

component armiu_destg 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_destg_typ_in;
    o       : out armiu_destg_typ_out
    );
end component;

-------------------------------------------------------------------------------

-- drstg inputs:
-- fromDE_insn_r      : decoded insn (drives drstg)
-- fromDE_insn_v      : next cycle decoded insn, (sampled in destg on pstate.hold and pstate.nextinsn)
-- fromRR_nextmicro_v : register locking from rrstg
-- fromWR_dabort_v     : data abort in wrstg
-- fromCPDE_accept    : coprocessor accept cmd (for undef trap)
-- fromCPDE_busy      : coprocessor lock until ready
-- fromCPDE_last      : coprocessor (ldc,stc) last addr

type armiu_drstg_typ_in is record
   pstate : apc_pstate;
   flush_v : std_logic;
   
   fromDE_insn_r : ade_deinsn;
   fromDE_insn_v : ade_deinsn;
   fromRR_nextmicro_v : std_logic;
   fromWR_dabort_v : std_logic;

   fromCPDE_accept : std_logic;
   fromCPDE_busy : std_logic;
   fromCPDE_last : std_logic;

end record;

-- drstg outputs:
-- toRR_micro_v    : pctrl + src regs assemble next microcode to rrstg
-- id              : cmd id
type armiu_drstg_typ_out is record
   nextinsn_v : std_logic;
   toRR_micro_v : apc_micro;
   id : std_logic_vector(2 downto 0);
end record;

component armiu_drstg 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_drstg_typ_in;
    o       : out armiu_drstg_typ_out
    );
end component;

-------------------------------------------------------------------------------

-- rrstg inputs:
-- pstate            : [rrstg,wrstg] pctrls + hold
-- fromDR_micro_v    : pctrl + src regs assemble by drstg
-- fromEX_alures_v   : current aluresult of exstg for forwarding 
-- fromWR_rd_v       : wrstg write: write reg
-- fromWR_rd_valid_v : wrstg write: write enable
-- fromWR_rd_data_v  : wrstg write: write data
-- fromCPEX_data     : coprocessor cpreg->armreg, cpreg->mem (mrc,stc)
-- fromCPEX_lock     : coprocessor holds pipeline

type armiu_rrstg_typ_in is record
   pstate : apc_pstate;
   flush_v : std_logic;
   
   fromDR_micro_v : apc_micro;                           
   fromEX_alures_v : std_logic_vector(31 downto 0);
   
   fromWR_rd_v : std_logic_vector(APM_RREAL_U downto APM_RREAL_D);
   fromWR_rd_valid_v : std_logic;
   fromWR_rd_data_v : std_logic_vector(31 downto 0);
   
   fromCPEX_data : std_logic_vector(31 downto 0);
   fromCPEX_lock : std_logic;
end record;

-- rrstg outputs:
-- fromRR_nextmicro_v : register locking (also coprocessor registers)

type armiu_rrstg_typ_out is record
   pctrl_r : apc_pctrl;
   toRS_pctrl_v : apc_pctrl;
   
   toDR_nextmicro_v  : std_logic;
end record;

component armiu_rrstg 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    clkn    : in  std_logic;
    i       : in  armiu_rrstg_typ_in;
    o       : out armiu_rrstg_typ_out
    );
end component;

-------------------------------------------------------------------------------

-- rsstg inputs:
-- pstate          : [rrstg,wrstg] pctrls + hold
-- fromRR_pctrl_v  : next pctrl, sampled on pstate.hold = '0'
-- fromEX_alures_v : current aluresult of exstg for forwarding (rsop_op(1|2)_src = apc_opsrc_alures)
-- fromEX_cpsr_v   : exstg cpsr (carry for shiefter)

type armiu_rsstg_typ_in is record
   pstate : apc_pstate;
   flush_v : std_logic;
   
   fromRR_pctrl_v : apc_pctrl;
   fromEX_alures_v : std_logic_vector(31 downto 0);
   fromEX_cpsr_v : apm_cpsr;
end record;

type armiu_rsstg_typ_out is record
   pctrl_r : apc_pctrl;
   toEX_pctrl_v : apc_pctrl;
end record;

component armiu_rsstg 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_rsstg_typ_in;
    o       : out armiu_rsstg_typ_out
    );
end component;

-------------------------------------------------------------------------------

-- exstg inputs:
-- pstate           : [rrstg,wrstg] pctrls + hold
-- fromRS_pctrl_v   : next pctrl, sampled on pstate.hold = '0'
-- fromWR_spsr_r    : wrstg spsr (for mrs,msr)
-- fromWR_cpsr_v    : wrstg write cpsr 
-- fromWR_cpsrset_v : wrstg write cpsr enable
-- fromCP_active    : coprocessor active (for undef trap)

type armiu_exstg_typ_in is record
   pstate : apc_pstate;
   flush_v : std_logic;
   
   fromRS_pctrl_v : apc_pctrl;

   fromWR_spsr_r  : apm_spsr;
   fromWR_cpsr_v  : apm_cpsr;
   fromWR_cpsrset_v : std_logic;
  
   fromCP_active : std_logic;
end record;

-- exstg outputs:
-- cpsr_r   : exstg cpsr
-- cpsr_v   : exstg cpsr next cycle
-- alures_v : current aluresult
-- toIM_branch_v : alures_v into imstg as address
-- flush_v       : flush [imstg-rsstg]
type armiu_exstg_typ_out is record
   pctrl_r : apc_pctrl;
   toDM_pctrl_v : apc_pctrl;
   
   cpsr_r : apm_cpsr;
   cpsr_v : apm_cpsr;
   alures_v : std_logic_vector(31 downto 0);
   
   toIM_branch_v : std_logic;
   flush_v : std_logic;
   
end record;

component armiu_exstg 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_exstg_typ_in;
    o       : out armiu_exstg_typ_out
    );
end component;

-------------------------------------------------------------------------------

-- dmstg inputs:
-- pstate          : [rrstg,wrstg] pctrls + hold
-- fromEX_pctrl_v  : next pctrl, sampled on pstate.hold = '0'

type armiu_dmstg_typ_in is record
   pstate : apc_pstate;
   flush_v : std_logic;
   
   fromEX_pctrl_v : apc_pctrl;
end record;

type armiu_dmstg_typ_out is record
   pctrl_r : apc_pctrl;
   toME_pctrl_v : apc_pctrl;
end record;

component armiu_dmstg 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_dmstg_typ_in;
    o       : out armiu_dmstg_typ_out
    );
end component;

-------------------------------------------------------------------------------

-- mestg inputs:
-- pstate          : [rrstg,wrstg] pctrls + hold
-- fromDM_pctrl_v  : next pctrl, sampled on pstate.hold = '0'
-- dci             : dcache input
-- irqo            : irq ctrl output

-- mestg outputs:

type armiu_mestg_typ_in is record
   pstate : apc_pstate;
   flush_v : std_logic;
   
   irqo : irq_iu_out_type;
   fromDM_pctrl_v : apc_pctrl;
end record;

type armiu_mestg_typ_out is record
   pctrl_r : apc_pctrl;
   toWR_pctrl_v : apc_pctrl;
   dci   : gendc_type_in;
end record;

component armiu_mestg 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_mestg_typ_in;
    o       : out armiu_mestg_typ_out
    );
end component;

-------------------------------------------------------------------------------

-- wrstg inputs:
-- pstate            : [rrstg,wrstg] pctrls + hold
-- fromME_pctrl_v    : next pctrl, sampled on pstate.hold = '0'
-- dco               : dcache output
-- fromCP_data       : coprocessor armreg->cpreg (mcr)

type armiu_wrstg_typ_in is record
   pstate : apc_pstate;
   fromME_pctrl_v : apc_pctrl;
   dco   : gendc_type_out;
   
   fromCP_data : std_logic_vector(31 downto 0);
end record;

-- wrstg outputs:
-- spsr_r            : wrstg spsr;
-- toIM_branch_v     : branch on memload->pc or trap
-- toIM_branchaddr_v : branch addr
-- toDR_dabort_v     : signal dabort
-- toEX_cpsr_v       : set exstg cpsr
-- toEX_cpsrset_v    : set exstg cpsr enable
-- toRR_rd_v         : write rd reg
-- toRR_rd_valid_v   : write rd enable
-- toRR_rd_data_v    : write rd data
-- toCPWR_crd_data_v : coprocessor mem->cpreg data (ldc)
-- irqi              : irqctrl irq ack
type armiu_wrstg_typ_out is record
   pctrl_r : apc_pctrl;

   spsr_r : apm_spsr;

   irqi : irq_iu_in_type;
   
   toIM_branch_v : std_logic;
   toIM_branchaddr_v : std_logic_vector(31 downto 0);
   
   toDR_dabort_v : std_logic;

   toEX_cpsr_v : apm_cpsr;
   toEX_cpsrset_v : std_logic;

   toRR_rd_v : std_logic_vector(APM_RREAL_U downto APM_RREAL_D);
   toRR_rd_valid_v : std_logic;
   toRR_rd_data_v : std_logic_vector(31 downto 0);
   
   toCPWR_crd_data_v : std_logic_vector(31 downto 0);
end record;

component armiu_wrstg 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_wrstg_typ_in;
    o       : out armiu_wrstg_typ_out
    );
end component;

end arm_comp;
