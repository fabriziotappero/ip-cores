library ieee;
use ieee.std_logic_1164.all;
use work.armpmodel.all;
use work.armdecode.all;

-- PREFIX: act_xxx
package armctrl is

-- Check insn condition
function act_checkcond(
  cpsr  : in  apm_cpsr;
  cond  : in std_logic_vector(3 downto 0)
) return std_logic;


end armctrl;

package body armctrl is

function act_checkcond(
  cpsr  : in  apm_cpsr;
  cond  : in std_logic_vector(3 downto 0)
) return std_logic is
variable tmp    : std_logic;
begin
  tmp := '0';
  case cond is
    when ADE_COND_EQ => tmp := cpsr.ex.z;
    when ADE_COND_NE => tmp := not cpsr.ex.z;
    when ADE_COND_CS => tmp := cpsr.ex.c;
    when ADE_COND_CC => tmp := not cpsr.ex.c;
    when ADE_COND_MI => tmp := cpsr.ex.n;
    when ADE_COND_PL => tmp := not cpsr.ex.n;
    when ADE_COND_VS => tmp := cpsr.ex.v;
    when ADE_COND_VC => tmp := not cpsr.ex.v;
    when ADE_COND_HI => tmp := cpsr.ex.c and (not cpsr.ex.z);
    when ADE_COND_LS => tmp := (not cpsr.ex.c) and cpsr.ex.z;
    when ADE_COND_GE => tmp := not (cpsr.ex.n xor cpsr.ex.v);
    when ADE_COND_LT => tmp := (cpsr.ex.n xor cpsr.ex.v);
    when ADE_COND_GT => tmp := (not cpsr.ex.z) and not (cpsr.ex.n xor cpsr.ex.v);
    when ADE_COND_LE => tmp := cpsr.ex.z or (cpsr.ex.n xor cpsr.ex.v);
    when ADE_COND_AL => tmp := '1';
    when ADE_COND_NV => tmp := '0';
    when others      => null;
  end case;
  return tmp;
end;

end armctrl;
