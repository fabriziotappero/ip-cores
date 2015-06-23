library ieee;
use ieee.std_logic_1164.all;
use work.armdecode.all;
use work.armpmodel.all;

-- PREFIX: adg_xxx
package armdebug is

-- pragma translate_off

-------------------------------------------------------------------------------

-- dbg: readable processor modes
type adg_dbgpmode is (
  adg_usr,
  adg_sys,
  adg_svc,
  adg_abt,
  adg_und,
  adg_irq,
  adg_fiq,
  adg_invalid
);

-- Convert to readable pmode enum
function adg_todbgpmode (
  mode : std_logic_vector(4 downto 0)
) return adg_dbgpmode;

-------------------------------------------------------------------------------

-- dbg: readable aluop 
type adg_dbgaluop is (
  adg_opand,
  adg_opeor,
  adg_opsub,
  adg_oprsb,
  adg_opadd,
  adg_opadc,
  adg_opsbc,
  adg_oprsc,
  adg_optst,
  adg_opteq,
  adg_opcmp,
  adg_opcmn,
  adg_oporr,
  adg_opmov,
  adg_opbic,
  adg_opmvn,
  adg_opinvalid
);

-- Convert to readable aluop enum
function adg_todbgaluop (
  mode : std_logic_vector(3 downto 0)
) return adg_dbgaluop;

-- pragma translate_on

end armdebug;

package body armdebug is

-- pragma translate_off
  
function adg_todbgpmode (
  mode : std_logic_vector(4 downto 0)
) return adg_dbgpmode is
  variable tmp : adg_dbgpmode;
begin

  tmp := adg_invalid;

  case mode is
    when APM_USR => tmp := adg_usr;
    when APM_SYS => tmp := adg_sys;
    when APM_SVC => tmp := adg_svc;
    when APM_ABT => tmp := adg_abt;
    when APM_UND => tmp := adg_und;
    when APM_IRQ => tmp := adg_irq;
    when APM_FIQ => tmp := adg_fiq;
    when others => null;
  end case;
  return tmp;
end;

function adg_todbgaluop (
  mode : std_logic_vector(3 downto 0)
) return adg_dbgaluop is
  variable tmp : adg_dbgaluop;
begin

  tmp := adg_opinvalid;

  case mode is
    when ADE_OP_AND => tmp := adg_opand;
    when ADE_OP_EOR => tmp := adg_opeor;
    when ADE_OP_SUB => tmp := adg_opsub;
    when ADE_OP_RSB => tmp := adg_oprsb;
    when ADE_OP_ADD => tmp := adg_opadd;
    when ADE_OP_ADC => tmp := adg_opadc;
    when ADE_OP_SBC => tmp := adg_opsbc;
    when ADE_OP_RSC => tmp := adg_oprsc;
    when ADE_OP_TST => tmp := adg_optst;
    when ADE_OP_TEQ => tmp := adg_opteq;
    when ADE_OP_CMP => tmp := adg_opcmp;
    when ADE_OP_CMN => tmp := adg_opcmn;
    when ADE_OP_ORR => tmp := adg_oporr;
    when ADE_OP_MOV => tmp := adg_opmov;
    when ADE_OP_BIC => tmp := adg_opbic;
    when ADE_OP_MVN => tmp := adg_opmvn;
    when others => 
  end case;
  return tmp;
end;

-- pragma translate_on

end armdebug;
