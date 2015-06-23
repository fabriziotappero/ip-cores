library ieee;
use ieee.std_logic_1164.all;

-- PREFIX: apm_xxx
package armpmodel is

-------------------------------------------------------------------------------

-- Processor Modes
constant APM_USR : std_logic_vector(4 downto 0) := "10000";        -- 1oooo
constant APM_SYS : std_logic_vector(4 downto 0) := "11111";        -- 11111
constant APM_SVC : std_logic_vector(4 downto 0) := "10011";        -- 1oo11
constant APM_ABT : std_logic_vector(4 downto 0) := "10111";        -- 1o111
constant APM_UND : std_logic_vector(4 downto 0) := "11011";        -- 11o11
constant APM_IRQ : std_logic_vector(4 downto 0) := "10010";        -- 1oo1o
constant APM_FIQ : std_logic_vector(4 downto 0) := "10001";        -- 1ooo1

-- check weather privileged mode
function apm_is_privmode (
  mode : std_logic_vector(4 downto 0)
) return boolean;

-------------------------------------------------------------------------------

-- Trap types
type apm_trap is (
  apm_trap_reset,   -- reset
  apm_trap_undef,   -- undefined (EXSTG)
  apm_trap_swi,     -- software interrupt (DRSTG)
  apm_trap_prefch,  -- prefetch error (IMSTG)
  apm_trap_dabort,  -- data abort error (MESTG)
  apm_trap_irq,     -- interrupt
  apm_trap_fiq      -- fast interrupt
);

-- Trap jump vectors
constant APM_RESET_VEC  : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
constant APM_UNDEF_VEC  : std_logic_vector(31 downto 0) := "00000000000000000000000000000100";
constant APM_SWI_VEC    : std_logic_vector(31 downto 0) := "00000000000000000000000000001000";
constant APM_PREFCH_VEC : std_logic_vector(31 downto 0) := "00000000000000000000000000001100";
constant APM_DABORT_VEC : std_logic_vector(31 downto 0) := "00000000000000000000000000010000";
constant APM_IRQ_VEC    : std_logic_vector(31 downto 0) := "00000000000000000000000000011000";
constant APM_FIQ_VEC    : std_logic_vector(31 downto 0) := "00000000000000000000000000011100";

-- Trap ctrl
type apm_trapctrl is record
  traptype : apm_trap;
  trap     : std_logic;
end record;

-------------------------------------------------------------------------------

-- Current Program Status Register (CPSR)
-- +---+---+---+---+---+------------+---+---+---+------+
-- | n | z | c | v | q |   dnm(raz) | i | f | t | mode |
-- +---+---+---+---+---+------------+---+---+---+------+
-- exstg controlled part of CPSR
type apm_excpsr is record
   n      : std_logic;                  -- negative
   z      : std_logic;                  -- zero
   c      : std_logic;                  -- carry
   v      : std_logic;                  -- overflow
   -- extensions
   -- fext   : std_logic_vector(3 downto 0);  -- cpsr(27:24)
   -- xext   : std_logic_vector(7 downto 0);  -- cpsr(15:8)
   -- sext   : std_logic_vector(7 downto 0);  -- cpsr(23:16)
end record;
-- wrstg controlled part of CPSR
type apm_wrcpsr is record
   i      : std_logic;                  -- [7] irq
   f      : std_logic;                  -- [6] fiq
   t      : std_logic;                  -- [5] thumb
   mode   : std_logic_vector(4 downto 0);
-- pragma translate_off
--   dbgmode  : aba_atyp_dbgpmode;       -- readable pmode for dbg
-- pragma translate_on
end record;
-- complete CPSR
type apm_cpsr is record
   ex : apm_excpsr;
   wr : apm_wrcpsr;
end record;

-- Banked SPSR
type apm_spsr is record
    svc_spsr : apm_cpsr;    
    abt_spsr : apm_cpsr;  
    und_spsr : apm_cpsr;   
    irq_spsr : apm_cpsr;   
    fiq_spsr : apm_cpsr;
end record;

-- convert from stdlogic to spm_cpsr
function apm_stdtocpsr (
  data : std_logic_vector
) return apm_cpsr;

-- convert from spm_cpsr to stdlogic
function apm_cpsrtostd (
  cpsr : apm_cpsr
) return std_logic_vector;

-- assemble new cpsr for msr cmd
function apm_msr (
  insn : std_logic_vector(31 downto 0);
  newcpsr : apm_cpsr;
  oldcpsr : apm_cpsr
) return apm_cpsr;

constant APM_MSR_C : integer := 16;
constant APM_MSR_X : integer := 17;
constant APM_MSR_S : integer := 18;
constant APM_MSR_F : integer := 19;

-------------------------------------------------------------------------------
  
constant APM_RREAL_U : integer := 4; -- banked register range
constant APM_RREAL_D : integer := 0;
constant APM_REG_U : integer := 3;   -- logical register range
constant APM_REG_D : integer := 0;
constant APM_REG_LINK   : std_logic_vector(3 downto 0) := "1110";   -- link register
constant APM_REG_PC     : std_logic_vector(3 downto 0) := "1111";   -- programm counter
constant APM_RREAL_PC : std_logic_vector(4 downto 0) := "01111";  -- banked program counter

constant APM_REGLIST_SZ : integer := 16;
constant APM_REGLIST_pc : integer := 15;

-------------------------------------------------------------------------------

-- map to banked register of <mode>
function apm_bankreg(
  mode : in std_logic_vector(4 downto 0);
  addr : in std_logic_vector
) return std_logic_vector;

-- retrieve the banked spsr for <mode> 
function apm_bankspsr(
  mode : in  std_logic_vector(4 downto 0);
  spsr : in  apm_spsr
) return apm_cpsr;

-- set bank spsr
procedure apm_setspsr(
  mode : in  std_logic_vector(4 downto 0);
  spsr : inout  apm_spsr;
  cpsr : in  apm_cpsr
);

-- check weather <mode> has a spsr
function apm_is_hasspsr (
  mode : std_logic_vector(4 downto 0)
) return boolean;

end armpmodel;

package body armpmodel is

-------------------------------------------------------------------------------
  
function apm_is_privmode (
  mode : std_logic_vector(4 downto 0)
) return boolean is
  variable tmp : boolean;
begin
  tmp := true;
  if mode = APM_USR then
    tmp := false;
  end if;
  return tmp;
end;

-------------------------------------------------------------------------------

constant APM_N_C : integer := 31;
constant APM_Z_C : integer := 30;
constant APM_C_C : integer := 29;
constant APM_V_C : integer := 28;
constant APM_Q_C : integer := 27;

constant APM_I_C : integer := 7;
constant APM_F_C : integer := 6;
constant APM_T_C : integer := 5;
constant APM_MODE_U : integer := 4;
constant APM_MODE_D : integer := 0;

-- extensions
-- constant APM_FEXT_U : integer := 27;
-- constant APM_FEXT_D : integer := 24;
-- constant APM_XEXT_U : integer := 15;
-- constant APM_XEXT_D : integer := 8;
-- constant APM_SEXT_U : integer := 23;
-- constant APM_SEXT_D : integer := 16;

function apm_stdtocpsr (
  data : std_logic_vector
) return apm_cpsr is
  variable tmp : apm_cpsr;
begin
  
  tmp.ex.n := data(APM_N_C);
  tmp.ex.z := data(APM_Z_C);
  tmp.ex.c := data(APM_C_C);
  tmp.ex.v := data(APM_V_C);

  tmp.wr.i := data(APM_I_C);
  tmp.wr.f := data(APM_F_C);
  tmp.wr.t := data(APM_T_C);
  tmp.wr.mode := data(APM_MODE_U downto APM_MODE_D);

  -- extensions
  -- tmp.fext := data(ACP_FEXT_U downto ACP_FEXT_D);
  -- tmp.xext := data(ACP_XEXT_U downto ACP_XEXT_D);
  -- tmp.sext := data(ACP_SEXT_U downto ACP_SEXT_D);
  
  return tmp;
end;

function apm_cpsrtostd (
  cpsr : apm_cpsr
) return std_logic_vector is
  variable tmp : std_logic_vector(31 downto 0);
begin
  tmp := (others => '0');
  
  tmp(APM_N_C) := cpsr.ex.n;
  tmp(APM_Z_C) := cpsr.ex.z;
  tmp(APM_C_C) := cpsr.ex.c;
  tmp(APM_V_C) := cpsr.ex.v;
  tmp(APM_Q_C) := '0';

  tmp(APM_I_C) := cpsr.wr.i;
  tmp(APM_F_C) := cpsr.wr.f;
  tmp(APM_T_C) := cpsr.wr.t;
  
  tmp(APM_MODE_U downto APM_MODE_D) := cpsr.wr.mode;        

  -- extensions
  -- tmp(ACP_FEXT_U downto ACP_FEXT_D) := cpsr.fext;
  -- tmp(ACP_XEXT_U downto ACP_XEXT_D) := cpsr.xext;
  -- tmp(ACP_SEXT_U downto ACP_SEXT_D) := cpsr.sext;
  
  return tmp;
end;

function apm_msr (
  insn : std_logic_vector(31 downto 0);
  newcpsr : apm_cpsr;
  oldcpsr : apm_cpsr
) return apm_cpsr is
  variable tmp : apm_cpsr;
begin
  tmp := oldcpsr;

  -- +---+---+---+---+---+------------+---+---+---+------+
  -- | n | z | c | v | q |   dnm(raz) | i | f | t | mode |
  -- +---+---+---+---+---+------------+---+---+---+------+

  -- $(del)
  -- if opcode[25] == 1
  --   operand = 8_bit_immediate Rotate_Right (rotate_imm * 2)
  -- else /* opcode[25] == 0 */
  --   operand = Rm
  --
  -- if R == 0 then
  --   if field_mask[0] == 1 and InAPrivilegedMode() then
  --   CPSR[7:0] = operand[7:0]
  --   if field_mask[1] == 1 and InAPrivilegedMode() then
  --   CPSR[15:8] = operand[15:8]
  --   if field_mask[2] == 1 and InAPrivilegedMode() then
  --   CPSR[23:16] = operand[23:16]
  --   if field_mask[3] == 1 then
  --   CPSR[31:24] = operand[31:24]
  -- else /* R == 1 */
  --   if field_mask[0] == 1 and CurrentModeHasSPSR() then
  --   SPSR[7:0] = operand[7:0]
  --   if field_mask[1] == 1 and CurrentModeHasSPSR() then
  --   SPSR[15:8] = operand[15:8]
  --   if field_mask[2] == 1 and CurrentModeHasSPSR() then
  --   SPSR[23:16] = operand[23:16]
  --   if field_mask[3] == 1 and CurrentModeHasSPSR() then
  --   SPSR[31:24] = operand[31:24]
  -- $(/del)

  
  if insn(APM_MSR_C) = '1' then
    tmp.wr.i := newcpsr.wr.i;
    tmp.wr.f := newcpsr.wr.f;
    tmp.wr.t := newcpsr.wr.t;
    tmp.wr.mode := newcpsr.wr.mode;
  end if;
  if insn(APM_MSR_X) = '1' then
    -- extensions
    -- tmp.xext := newcpsr.xext;
  end if;
  if insn(APM_MSR_S) = '1' then
    -- extensions
    -- tmp.sext := newcpsr.sext;
  end if;
  if insn(APM_MSR_F) = '1' then
    tmp.ex.n := newcpsr.ex.n;
    tmp.ex.z := newcpsr.ex.z;
    tmp.ex.c := newcpsr.ex.c;
    tmp.ex.v := newcpsr.ex.v;
    -- extensions
    -- tmp.ex.fext := newcpsr.fext;
  end if;
  
  return tmp;
end;

-------------------------------------------------------------------------------

-- banked register mapping:
-- 
--          USR     SYS     SVC     ABT     UND     IRQ     FIQ  
--       +-------+-------+-------+-------+-------+-------+-------+
--R0-R7  |      
--       +-------+---------------------------------------+-------+
--R8-R12 |                                                R16-R20
--       +-------+---------------------------------------+-------+
--R13    |                   R24    R26     R28    R30      R21 
--       +-------+---------------------------------------+-------+
--R14    |                   R25    R27     R29    R31      R22
--       +-------+---------------------------------------+-------+

function apm_bankreg(
  mode : in std_logic_vector(4 downto 0);
  addr : in std_logic_vector
) return std_logic_vector is
variable tmp  : std_logic_vector(addr'high+1 downto 0);  -- +1: return is 5bits
variable bank : std_logic_vector(addr'high+1 downto 0);  
begin
  tmp := "0"&addr(addr'high downto 0);
  bank := "0"&addr(addr'high downto 0);
  case mode is
    when APM_USR => 
    when APM_SYS => 
    when APM_SVC =>
      bank := "1100" & not addr(0);
    when APM_ABT => 
      bank := "1101" & not addr(0);
    when APM_UND => 
      bank := "1110" & not addr(0);
    when APM_FIQ => 
      if addr(3) = '1' then
        bank(4 downto 3) := "10";
        tmp(4 downto 3) := "10";
      end if;
    when APM_IRQ => 
      bank := "1111" & not addr(0);
    when others => 
  end case;
  case addr(3 downto 0) is
    when "1101"|"1110" => tmp := bank;
    when others => 
  end case;
  return tmp;
end;

procedure apm_setspsr(
  mode : in  std_logic_vector(4 downto 0);
  spsr : inout  apm_spsr;
  cpsr : in  apm_cpsr
) is
begin
  case mode is
    when APM_SVC =>
      spsr.svc_SPSR := cpsr;
    when APM_ABT => 
      spsr.abt_SPSR := cpsr;
    when APM_UND => 
      spsr.und_SPSR := cpsr;
    when APM_IRQ => 
      spsr.irq_SPSR := cpsr;
    when APM_FIQ => 
      spsr.fiq_SPSR := cpsr;
    when others => 
  end case;
end;

function apm_bankspsr(
  mode : in  std_logic_vector(4 downto 0);
  spsr : in  apm_spsr
) return apm_cpsr is
variable tmp : apm_cpsr;
begin
  tmp := spsr.svc_spsr;
  case mode is
    when APM_SVC =>
      tmp := spsr.svc_spsr;
    when APM_ABT => 
      tmp := spsr.abt_spsr;
    when APM_UND => 
      tmp := spsr.und_spsr;
    when APM_IRQ => 
      tmp := spsr.irq_spsr;
    when APM_FIQ => 
      tmp := spsr.fiq_spsr;
    when others => 
  end case;
  return tmp;
end;

function apm_is_hasspsr (
  mode : std_logic_vector(4 downto 0)
) return boolean is
  variable tmp : boolean;
begin
  tmp := true;
  if mode = APM_USR or
     mode = APM_SYS then
    tmp := false;
  end if;
  return tmp;
end;

end armpmodel;
