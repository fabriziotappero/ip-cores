-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.cache_config.all;
use work.int.all;
use work.gencmem_lib.all;

-- PREFIX: kicl_xxx
package genic_lib is

type gicl_ctrl is record
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
constant GICL_TTAG_D : integer  :=  2 + GCML_IC_TLINE_BSZ + GCML_IC_TADDR_BSZ;
constant GICL_TTAG_U : integer  := (2 + GCML_IC_TLINE_BSZ + GCML_IC_TADDR_BSZ + GCML_IC_TTAG_BSZ) -1;
constant GICL_TADDR_D : integer :=  2 + GCML_IC_TLINE_BSZ;
constant GICL_TADDR_U : integer := (2 + GCML_IC_TLINE_BSZ + GCML_IC_TADDR_BSZ) -1;
constant GICL_TLINE_D : integer :=  2;
constant GICL_TLINE_U : integer := (2 + GCML_IC_TLINE_BSZ ) -1;

-- addr to cmem-data fields/access layout
constant GICL_DADDR_D : integer :=  2 + GCML_IC_DLINE_BSZ;
constant GICL_DADDR_U : integer := (2 + GCML_IC_DLINE_BSZ + GCML_IC_DADDR_BSZ) -1;
constant GICL_DLINE_D : integer :=  2;
constant GICL_DLINE_U : integer := (2 + GCML_IC_DLINE_BSZ ) -1;

function gicl_is_taghit (
  addr : std_logic_vector(31 downto 0);
  cline : gcml_ic_tline
) return boolean;

function gicl_is_linevalid (
  addr : std_logic_vector(31 downto 0);
  cline : gcml_ic_tline
) return boolean;

-- check weather next is last of line
function gicl_is_onetogo(
  addr : std_logic_vector(31 downto 0)
) return boolean;

end genic_lib;

package body genic_lib is

function gicl_is_taghit (
  addr : std_logic_vector(31 downto 0);
  cline : gcml_ic_tline
) return boolean is
  variable tmp : boolean;
  variable tag : std_logic_vector(GICL_TTAG_U downto GICL_TTAG_D);
begin
  tmp := false;
  tag := addr(GICL_TTAG_U downto GICL_TTAG_D);
  if (tag = cline.tag) then
    tmp := true;
  end if;
  return tmp;
end;

function gicl_is_linevalid (
  addr : std_logic_vector(31 downto 0);
  cline : gcml_ic_tline
) return boolean is
  variable tmp : boolean;
  variable line : std_logic_vector(GICL_TLINE_U downto GICL_TLINE_D);
begin
  tmp := false;
  line := addr(GICL_TLINE_U downto GICL_TLINE_D);
  if (cline.valid(lin_convint(line)) = '1')
  then
    tmp := true;
  end if;
  return tmp;
end;

constant lastaddr : std_logic_vector(GCML_IC_TLINE_BSZ-1 downto 0) := (others=>'1');

function gicl_is_onetogo (
  addr : std_logic_vector(31 downto 0)
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  if addr(GICL_TLINE_U downto GICL_TLINE_D+1) = lastaddr(GCML_IC_TLINE_BSZ-1 downto 1) then
    tmp := true;
  end if;
  return tmp;
end;

end genic_lib;

