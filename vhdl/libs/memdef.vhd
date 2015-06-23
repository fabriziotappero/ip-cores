-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;

-- PREFIX: lmd_xxx
package memdef is

-- memsizes
type lmd_memsize is (
  lmd_word,
  lmd_byte,
  lmd_half,
  lmd_dbl
);

-- lmd_big:    byte[0 1 2 3], hw[0 1]
-- lmd_little: byte[3 2 1 0], hw[1 0]
type lmd_byteorder is (lmd_big, lmd_little);

-- return amba size constant
function lmd_toamba (
  size : lmd_memsize
) return Std_Logic_Vector;
   
-- endianess converter
function lmd_convert (
  data : std_logic_vector(31 downto 0);
  intype : lmd_byteorder;
  outtype : lmd_byteorder
) return std_logic_vector;

end memdef;

package body memdef is

function lmd_toamba (
  size : lmd_memsize
) return Std_Logic_Vector is
 variable tmp : std_logic_vector(2 downto 0);
begin
  tmp := HSIZE_WORD;
  case size is
    when lmd_byte => tmp := HSIZE_BYTE;
    when lmd_half => tmp := HSIZE_HWORD;
    when lmd_word => tmp := HSIZE_WORD;
    when others => null;
  end case;
  return tmp;
end;

function lmd_convert (
  data : std_logic_vector(31 downto 0);
  intype : lmd_byteorder;
  outtype : lmd_byteorder
) return std_logic_vector is
variable tmp : std_logic_vector(31 downto 0);
begin
  tmp := data;
  if intype /= outtype then
    tmp := tmp(7 downto 0) & tmp(15 downto 8) & tmp(23 downto 16) & tmp(31 downto 24);
  end if;
  return tmp;
end;

end memdef;
