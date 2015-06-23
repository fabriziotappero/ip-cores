-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.cache_config.all;
use work.target.all;
use work.device.all;
use work.kecs_libcmem.all;
use work.kehl_libint.all;

-- PREFIX: kcli_xxx
package kecs_libicache is

type kcli_ketyp_ctrl is record
  burst : std_logic;
end record;

-- icache tag layout
-- addr: |         tag         | (tag)addr | line | 00 |
--                                   |
--     +-----------------------------+
--     | +---------------------+---------+
--     +>|       CLTAG         | CLVALID |
--       +---------------------+---------+

-- addr to cmem-tag fields/access layout
constant KCLI_TTAG_D : integer  :=  2 + KCML_IC_TLINE_BSZ + KCML_IC_TADDR_BSZ;
constant KCLI_TTAG_U : integer  := (2 + KCML_IC_TLINE_BSZ + KCML_IC_TADDR_BSZ + KCML_IC_TTAG_BSZ) -1;
constant KCLI_TADDR_D : integer :=  2 + KCML_IC_TLINE_BSZ;
constant KCLI_TADDR_U : integer := (2 + KCML_IC_TLINE_BSZ + KCML_IC_TADDR_BSZ) -1;
constant KCLI_TLINE_D : integer :=  2;
constant KCLI_TLINE_U : integer := (2 + KCML_IC_TLINE_BSZ ) -1;

-- addr to cmem-data fields/access layout
constant KCLI_DADDR_D : integer :=  2 + KCML_IC_DLINE_BSZ;
constant KCLI_DADDR_U : integer := (2 + KCML_IC_DLINE_BSZ + KCML_IC_DADDR_BSZ) -1;
constant KCLI_DLINE_D : integer :=  2;
constant KCLI_DLINE_U : integer := (2 + KCML_IC_DLINE_BSZ ) -1;

function kcli_is_taghit (
  addr : std_logic_vector(31 downto 0);
  cline : kcml_ketyp_ic_tline
) return boolean;

function kcli_is_linevalid (
  addr : std_logic_vector(31 downto 0);
  cline : kcml_ketyp_ic_tline
) return boolean;

-- check weather next is last of line
function kcli_is_onetogo(
  addr : std_logic_vector(31 downto 0)
) return boolean;

end kecs_libicache;

package body kecs_libicache is

function kcli_is_taghit (
  addr : std_logic_vector(31 downto 0);
  cline : kcml_ketyp_ic_tline
) return boolean is
  variable tmp : boolean;
  variable tag : std_logic_vector(KCLI_TTAG_U downto KCLI_TTAG_D);
begin
  tmp := false;
  tag := addr(KCLI_TTAG_U downto KCLI_TTAG_D);
  if (tag = cline.tag) then
    tmp := true;
  end if;
  return tmp;
end;

function kcli_is_linevalid (
  addr : std_logic_vector(31 downto 0);
  cline : kcml_ketyp_ic_tline
) return boolean is
  variable tmp : boolean;
  variable line : std_logic_vector(KCLI_TLINE_U downto KCLI_TLINE_D);
begin
  tmp := false;
  line := addr(KCLI_TLINE_U downto KCLI_TLINE_D);
  if (cline.valid(khin_convint(line)) = '1')
  then
    tmp := true;
  end if;
  return tmp;
end;

constant lastaddr : std_logic_vector(KCML_IC_TLINE_BSZ-1 downto 0) := (others=>'1');

function kcli_is_onetogo (
  addr : std_logic_vector(31 downto 0)
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if addr(KCLI_TLINE_U downto KCLI_TLINE_D+1) = lastaddr(KCML_IC_TLINE_BSZ-1 downto 1) then
    tmp := true;
  end if;
  return tmp;
end;

end kecs_libicache;

