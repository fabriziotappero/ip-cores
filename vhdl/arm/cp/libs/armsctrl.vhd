library ieee;
use ieee.std_logic_1164.all;

-- PREFIX: acpsc_xxx
package armsctrl is

constant ACPSC_R0_OP0 : std_logic_vector(31 downto 0) := (others => '0');  -- id
constant ACPSC_R0_OP1 : std_logic_vector(31 downto 0) := (others => '0');  -- cache

type acpsc_r1 is record
  mmu    : std_logic;
end record;
function acpsc_r1tostd (
  r1 : acpsc_r1
) return std_logic_vector;
procedure acpsc_stdtor1 (
  data : in std_logic_vector(31 downto 0);
  r1   : inout acpsc_r1
);

type acpsc_regs is record
  r1 : acpsc_r1;
  r2 : std_logic_vector(31 downto 0);   -- mmu_base
end record;


end armsctrl;

package body armsctrl is

constant ACPS_R1_M_C : integer := 0;
-- sysctrl register 1
function acpsc_r1tostd (
  r1 : acpsc_r1
) return std_logic_vector is
  variable tmp : std_logic_vector(31 downto 0);
begin
  tmp := (others => '0');
  tmp(ACPS_R1_M_C) := r1.mmu;
  return tmp;
end;
 
procedure acpsc_stdtor1 (
  data : in std_logic_vector(31 downto 0);
  r1   : inout acpsc_r1
) is
begin
  r1.mmu := data(ACPS_R1_M_C);
end;


end armsctrl;
