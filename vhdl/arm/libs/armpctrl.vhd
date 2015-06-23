library ieee;
use ieee.std_logic_1164.all;
use work.corelib.all;
use work.armpmodel.all;
use work.armshiefter.all;
use work.armdecode.all;
use work.gendc_lib.all;

-- PREFIX: apc_xxx
package armpctrl is
  
--   pctrl.
-- data1 data2
--  +---+---+-----------------------------------------------+
--  |   |   | ######## Register Read Stage (rrstg) ######## |
--  |   |   | record apc_micro:                             |
--  |   |   | r1       : src register 1                     |
--  |   |   | r1_valid : src register 1 enable              |
--  |   |   | r2       : src register 2                     |
--  |   |   | r2_valid : src register 2 enable              |
--  +---+---+-----------------------------------------------+
--  |   |   |          pstate                               |
--  |   |   | r1+--------V---------+    +---------+         |
--  | +-+---+---+ Forwarding Logic +----+ regfile +<--------+< wrstg
--  | | | +-+---+                  |    +---------+         |
--  | V | V | r2+------------------+                        |
--  |   |   |                                               | 
--  |   |   |  Note: if (rsop_op1_src,rsop_op2_src) == none | 
--  |   |   |        then pctrl.data(1,2) are imidiate and  | 
--  |   |   |        pctrl.data(1,2) are not written        |
--  +---+---+-----------------------------------------------+ 
--    VVVVV    lock on register/coprocessor stall           
--  +---+---+-----------------------------------------------+
--  |   |   | ####### Register Shieft Stage (rsstg) ####### |
--  |   |   | record apc_rsstg:                             |
--  |   |   | rsop_op1_src : pctrl.data1 src                |
--  |   |   | rsop_op2_src : pctrl.data2 src                |
--  |   |   | rsop_buf1_src: rsstg.buf1 src                 |
--  |   |   | rsop_buf2_src: rsstg.buf2 src                 |
--  |   |   | rsop_styp    : shieft type                    |
--  |   |   | rsop_sdir    : shieft dir                     |
--  +---+---+-----------------------------------------------+
--  |   |   |                                               | 
--  |   |   |  rsop_buf2_src:                  +----+      <+-exstg.<aluresult>
--  |   |   |       "trough": pctrl.data1 -+-> |buf1|       |    
--  |   |   |       "alures": <aluresult> -+   +----+       |    
--  |   |   |       "none"  : ~~                            |    
--  |   |   |                                               |
--  |   |   |  rsop_buf2_src:                  +----+       |    
--  |   |   |       "trough": pctrl.data2 -+-> |buf2|       |    
--  |   |   |       "alures": <aluresult> -+   +----+       |    
--  |   |   |       "none"  : ~~                            |    
--  |   |   |                                               |
--  |   |   |  rsop_op1_src :                               |    
--  | +-^---^---+-  "trough": pctrl.data1                   |    
--  | V |   |   +-  "none"  : ~~                            |    
--  |   |   |   +-  "alures": <aluresult>                   |    
--  |   |   |   +-  "buf"   : buf1                          |    
--  |   |   |                        pctrl.data1 pctrl.data2|
--  |   |   |                                V    V         |
--  |   |   |  rsop_op2_src :              +-+----+-+       |    
--  |   | +-^---+-  "trough": <------------|shiefter|       |    
--  |   | V |   +-  "none"  : ~~           +----+---+       |    
--  |   |   |   +-  "alures": <aluresult>       |           |    
--  |   |   |   +-  "buf"   : buf2              V           |    
--  |   |   |                          rs_shieftcarryout    |     
--  +---+---+-----------------------------------------------+
--  +---+---+-----------------------------------------------+
--  |   |   | ########### Execute Stage (exstg) ########### |
--  +---+---+-----------------------------------------------+
--  |   |   | record apc_exstg:                             |
--  |   |   | exop_aluop    : alu operation type            |
--  |   |   | exop_data_src : pctrl.data1 source            | 
--  |   |   | exop_buf_src  : exstg.buf source              |
--  |   |   | exop_setcpsr  : update cpsr                   |
--  +---+---+-----------------------------------------------+
--  |   |   |                                               |
--  | o-+-o=+======+------+                                 |
--  |   |   |   +--+------+--+                              |
--  |   |   |   | exop_aluop |                              |
--  |   |   |   +-----+------+                              |
--  |   |   |         |                                     |
--  |   |   |     <aluresult>                               |
--  |   |   |                                               |
--  |   |   |  exop_buf_src:                  +----+       <+--
--  |   |   |       "aluout": <aluresult> -+->|buf1|        |
--  |   |   |       "op1"   : pctrl.data1 -+  +----+        |
--  |   |   |       "none"  : ~~                            |
--  |   |   |                                               |
--  |   |   |  exop_op1_src :                 exop_setcpsr  |
--  | +-^---^---+-  "aluout": <aluresult>      +-------+    |
--  | V |   |   +-  "buf"   : buf1             |  cpsr |    |
--  |   |   |                                  +---+---+    |
--  |   |   |                                      V        |
--  |   |   |                                   ex_cpsr     |
--  +---+---+-----------------------------------------------+
--  +---+---+-----------------------------------------------+
--  |   |   | ############ DMMU Stage (dmstg) ############# |
--  +---+---+-----------------------------------------------+
--  |   |   |                                               |
--  |   | o-+-+                                             |
--  +---+---+-)---------------------------------------------+
--  +---+---+-)---------------------------------------------+
--  |   |   | |########## Memory Stage (dmstg) ############ |
--  |   |   | |record apc_mestg:                            |
--  |   |   | | meop_param  : dcache params                 |
--  |   |   | | meop_enable : load/store                    |
--  +---+---+-)---------------------------------------------+
--  |   |   | |       Store :                               |
--  |   |   | +> dmstg.pctrl.data2 : store data             +
--  | o-+---+-->pctrl.data1 : memory address                |
--  |   |   |                                              -+-> dcache in
--  |   |   |          Load :                               |
--  | o-+---+-> pctrl.data1 : memory address                |
--  |   |   |                                               |
--  |   |   |                                               |
--  |   |   |                                               |
--  |   |   |                                               |
--  +---+---+-----------------------------------------------+
--  +---+---+-----------------------------------------------+
--  |   |   | ############ Write Stage (dmstg) ############ |
--  |   |   | record apc_mestg:                             |
--  |   |   |  wrop_rd      : write register                |
--  |   |   |  wrop_rdvalid : write enable                  |
--  |   |   |  wrop_trap    : trap ctrl                     | 
--  |   |   |  wrop_setspsr : set spsr                      |
--  +---+---+-----------------------------------------------+
--  |   |   |                                               |
--  |   |   |                                          <-+-<+- dcache out
--  |   |   |                                            |  |
--  |   |   |                                            +->+- rrstg write
--  |   |   |                                               |
--  +---+---+-----------------------------------------------+

  
-- RSSTG operation: EXSTG operand source
type apc_rsop_opsrc is (
  apc_opsrc_through,
  apc_opsrc_buf,
  apc_opsrc_alures,
  apc_opsrc_none
);

-- RSSTG operation: RSSTG buffer source
type apc_rsop_bufsrc is (
  apc_bufsrc_none,
  apc_bufsrc_through,
  apc_bufsrc_alures
);

-- EXSTG operation: pctrl.data source
type apc_exop_datasrc is (
  apc_datasrc_aluout,
  apc_datasrc_buf,
  apc_datasrc_none
);

-- EXSTG operation: exstg.buf source
type apc_exop_bufsrc is (
  apc_exbufsrc_none,
  apc_exbufsrc_aluout,
  apc_exbufsrc_op1
);

type apc_rrstg is record
  -- operations
  dummy : std_logic;
end record;

type apc_rsstg is record
  -- operations
  rsop_op1_src  : apc_rsop_opsrc;  -- EXSTG operand1 source
  rsop_op2_src  : apc_rsop_opsrc;  -- EXSTG operand1 source
  rsop_buf1_src : apc_rsop_bufsrc; -- RSSTG buffer1 source
  rsop_buf2_src : apc_rsop_bufsrc; -- RSSTG buffer2 source
  rsop_styp     : ash_styp;        -- RSSTG shieft op
  rsop_sdir     : ash_sdir;        -- RSSTG shieft dir
  -- data
  rs_shieftcarryout : std_logic;   -- RSSTG shiefter carry out
end record;

type apc_exstg is record
  -- operations
  exop_aluop    : std_logic_vector(3 downto 0);  -- EXSTG alu operation
  exop_data_src : apc_exop_datasrc;  -- EXSTG pctrl.data1 source
  exop_buf_src  : apc_exop_bufsrc;   -- ESSTG buffer source
  exop_setcpsr  : std_logic;         -- EXSTG set cpsr
  -- data                                   
  ex_cpsr : apm_cpsr;           -- EXSTG store old cpsr
end record;

type apc_dmstg is record
  dummy : std_logic;
end record;

type apc_mestg is record
  -- operation
  meop_enable : std_logic;
  meop_param  : gdcl_param;
  -- data
  mexc   : std_logic;
end record;

type apc_wrstg is record
  -- operation
  wrop_rd      : std_logic_vector(APM_RREAL_U downto APM_RREAL_D);
  wrop_rdvalid : std_logic;
  wrop_setspsr : std_logic;
  wrop_trap    : apm_trapctrl;
end record;

type apc_pctrl is record
  insn : ade_insn;
  valid : std_logic;
  rr : apc_rrstg;
  rs : apc_rsstg;
  ex : apc_exstg;
  dm : apc_dmstg;
  me : apc_mestg;
  wr : apc_wrstg;
  data1 : std_logic_vector(31 downto 0);
  data2 : std_logic_vector(31 downto 0);
end record;

type apc_pstate is record
  hold_r    : cli_hold;
  nextinsn_v : std_logic;
  dabort_v : std_logic;
  -- active cpsr
  fromEX_cpsr_r : apm_cpsr;
  -- pctrls of all stages from rrstg on 
  fromRR_pctrl_r : apc_pctrl;
  fromRS_pctrl_r : apc_pctrl;
  fromEX_pctrl_r : apc_pctrl;
  fromDM_pctrl_r : apc_pctrl;
  fromME_pctrl_r : apc_pctrl;
  fromWR_pctrl_r : apc_pctrl;
end record;

type apc_micro is record
  pctrl : apc_pctrl;
  valid : std_logic;
  r1, r2 : std_logic_vector(APM_RREAL_U downto APM_RREAL_D);
  r1_valid, r2_valid : std_logic;
end record;

-------------------------------------------------------------------------------
-- pctrl predicate: ctrl

-- check weather pctrl is valid
function apc_is_valid (
  pctrl : apc_pctrl
) return boolean;

-- check weather branch (reg/mem)
function apc_is_branch(
  pctrl   : apc_pctrl
) return boolean;

-------------------------------------------------------------------------------
-- pctrl predicate: mem op 

-- check weather mestg active
function apc_is_mem(
  pctrl   : apc_pctrl
) return boolean;

-- check weather mestg load
function apc_is_memload(
  pctrl   : apc_pctrl
) return boolean;

-- check weather str addr (next pctrl will be store data) 
function apc_is_straddr(
  pctrl   : apc_pctrl
) return boolean;

-- check weather str data (prev pctrl was be store addr) 
function apc_is_strdata(
  pctrl   : apc_pctrl
) return boolean;

-------------------------------------------------------------------------------
-- pctrl predicate: register locking 

-- check weather it is a mem ldr
function apc_is_rdlocked(
  pctrl   : apc_pctrl
) return boolean;

-- check weather app_is_rdlocked() + rd compare
function apc_is_rdlocked_by (
  rd    : std_logic_vector(APM_RREAL_U downto APM_RREAL_D);
  pctrl : apc_pctrl
) return boolean;

-- check weather wrstg rd data come from alu
function apc_is_rdfromalu(
  pctrl   : apc_pctrl
) return boolean;

-------------------------------------------------------------------------------
-- pctrl predicate: cpsr locking 

-- check weather rsstg is used
function apc_is_rswillshieft(
  pctrl   : apc_pctrl
) return boolean;

-- check weather cpsr will be modified 
function apc_is_exwillsetcpsr(
  pctrl   : apc_pctrl
) return boolean;

-- check weather cpsr is used 
function apc_is_usecpsr(
  pctrl   : apc_pctrl
) return boolean;

-------------------------------------------------------------------------------

-- check weather stg should flush
function apc_is_flush(
  stgid : std_logic_vector(2 downto 0);
  flushid : std_logic_vector(2 downto 0)
) return boolean;

end armpctrl;

package body armpctrl is

function apc_is_valid (
  pctrl : apc_pctrl
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if pctrl.valid = '1' then
    tmp := true;
  end if;
  return tmp;
end;

function apc_is_branch(
  pctrl   : apc_pctrl
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if apc_is_valid(pctrl) then
    if (pctrl.wr.wrop_rdvalid = '1') and
       (pctrl.wr.wrop_rd = APM_RREAL_PC) then
      tmp := true;
    end if;
  end if;
  return tmp;
end;

function apc_is_rdlocked(
  pctrl   : apc_pctrl
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if apc_is_valid(pctrl) and
     (pctrl.me.meop_enable = '1') and
     (pctrl.me.meop_param.read = '1') and
     (pctrl.wr.wrop_rdvalid = '1') then
    tmp := true;
  end if;
  return tmp;
end;

function apc_is_rdlocked_by (
  rd    : std_logic_vector(APM_RREAL_U downto APM_RREAL_D);
  pctrl : apc_pctrl
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if (pctrl.wr.wrop_rd = rd) and apc_is_rdlocked(pctrl) then
    tmp := true;
  end if;
  return tmp;
end;

function apc_is_rdfromalu(
  pctrl   : apc_pctrl
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if  apc_is_valid(pctrl) and
     (not apc_is_memload(pctrl)) and 
     (pctrl.wr.wrop_rdvalid = '1') then
    tmp := true;
  end if;
  return tmp;
end;

function apc_is_mem(
  pctrl   : apc_pctrl
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if apc_is_valid(pctrl) then
    if pctrl.me.meop_enable = '1' then
      tmp := true;
    end if;
  end if;
  return tmp;
end;

function apc_is_memload(
  pctrl   : apc_pctrl
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if apc_is_mem(pctrl) then
    if pctrl.me.meop_param.read = '1' then
      tmp := true;
    end if;
  end if;
  return tmp;
end;

function apc_is_straddr(
  pctrl   : apc_pctrl
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if apc_is_valid(pctrl) then
    if (pctrl.me.meop_enable = '1') and
       (pctrl.me.meop_param.read = '0') and
       (pctrl.me.meop_param.addrin = '1') then
      tmp := true;
    end if;
  end if;
  return tmp;
end;

function apc_is_strdata(
  pctrl   : apc_pctrl
) return boolean  is
  variable tmp : boolean;
begin
  tmp := false;
  if apc_is_valid(pctrl) then
    if (pctrl.me.meop_enable = '1') and
       (pctrl.me.meop_param.read = '0') and
       (pctrl.me.meop_param.writedata = '1') then
      tmp := true;
    end if;
  end if;
  return tmp;
end;

function apc_is_rswillshieft(
  pctrl   : apc_pctrl
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if apc_is_valid(pctrl) then
    -- shiefter output used
    if pctrl.rs.rsop_op2_src = apc_opsrc_through or
       pctrl.rs.rsop_buf2_src = apc_bufsrc_through then
      -- shiefter does something
      if (pctrl.rs.rsop_styp = ash_styp_simm) or
         (pctrl.rs.rsop_styp = ash_styp_sreg) then
        if not (pctrl.rs.rsop_sdir = ash_sdir_snone) then
          tmp := true;
        end if;
      end if;
    end if;
  end if;
  return tmp;
end;

function apc_is_exwillsetcpsr(
  pctrl   : apc_pctrl
) return boolean is
  variable tmp : boolean;
begin
  tmp := apc_is_valid(pctrl) and
        (pctrl.ex.exop_setcpsr = '1') ;
  return tmp;
end;

function apc_is_usecpsr(
  pctrl   : apc_pctrl
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if apc_is_valid(pctrl) then
    if apc_is_rswillshieft(pctrl) then
      tmp := true;
    end if;
  end if;
  return tmp;
end;

function apc_is_flush(
  stgid : std_logic_vector(2 downto 0);
  flushid : std_logic_vector(2 downto 0)
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if not (stgid = flushid) then
    tmp := true;
  end if;
  return tmp;
end;

end armpctrl;
