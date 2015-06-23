-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.cache_config.all;
use work.gencmem_lib.all;
use work.int.all;
use work.memdef.all;

-- PREFIX: gdcl_xxx
package gendc_lib is

type gdcl_ctrl is record
  writeback : std_logic;
  allocateonstore : std_logic;
end record;

-- dcache tag layout
-- addr: |         tag         | (tag)addr | line | 00 |
--                                   |
--     +-----------------------------+
--     | +-------+---------------------+---------+
--     +>| DIRTY |       CLTAG         | CLVALID |
--       +-------+---------------------+---------+

-- addr to cmem-tag fields/access layout
constant GDCL_TTAG_D : integer  :=  2 + GCML_DC_TLINE_BSZ + GCML_DC_TADDR_BSZ;
constant GDCL_TTAG_U : integer  := (2 + GCML_DC_TLINE_BSZ + GCML_DC_TADDR_BSZ + GCML_DC_TTAG_BSZ) -1;
constant GDCL_TADDR_D : integer :=  2 + GCML_DC_TLINE_BSZ;
constant GDCL_TADDR_U : integer := (2 + GCML_DC_TLINE_BSZ + GCML_DC_TADDR_BSZ) -1;
constant GDCL_TLINE_D : integer :=  2;
constant GDCL_TLINE_U : integer := (2 + GCML_DC_TLINE_BSZ ) -1;

-- addr to cmem-data fields/access layout
constant GDCL_DADDR_D : integer :=  2 + GCML_DC_DLINE_BSZ;
constant GDCL_DADDR_U : integer := (2 + GCML_DC_DLINE_BSZ + GCML_DC_DADDR_BSZ) -1;
constant GDCL_DLINE_D : integer :=  2;
constant GDCL_DLINE_U : integer := (2 + GCML_DC_DLINE_BSZ ) -1;

type gdcl_param is record
  size      : lmd_memsize;
  read      : std_logic;
  lock      : std_logic;
  writedata : std_logic;
  addrin    : std_logic;
  signed    : std_logic;
end record;

function gdcl_is_taghit (
  addr : std_logic_vector(31 downto 0);
  cline : gcml_dc_tline
) return boolean;

function gdcl_is_linevalid (
  addr : std_logic_vector(31 downto 0);
  cline : gcml_dc_tline
) return boolean;

function gdcl_is_linedirty (
  addr : std_logic_vector(31 downto 0);
  cline : gcml_dc_tline
) return boolean;

function gdcl_is_free (
  cline : gcml_dc_tline
) return boolean;

function gdcl_is_dirty (
  cline : gcml_dc_tline
) return boolean;

function gdcl_getpos (
  addr : std_logic_vector(GCML_DC_TLINE_BSZ-1 downto 0)
) return integer;

function gdcl_readdata (
  addrlo : std_logic_vector(1 downto 0);
  data : std_logic_vector(31 downto 0);
  bo   : lmd_byteorder;
  sign : std_logic;
  size : lmd_memsize
) return std_logic_vector;

function gdcl_writedata (
  addrlo : std_logic_vector(1 downto 0);
  base : std_logic_vector(31 downto 0);
  data : std_logic_vector(31 downto 0);
  bo   : lmd_byteorder;
  size : lmd_memsize
) return std_logic_vector;

constant GDCL_ZERO_C  : std_logic_vector(CFG_DC_TLINE_SZ-1 downto 0) := (others => '0');
constant GDCL_LAST_C  : std_logic_vector(CFG_DC_TLINE_SZ-1 downto 0) := (others => '1');
constant GDCL_NLAST_C : std_logic_vector(CFG_DC_TLINE_SZ-2 downto 0) := (others => '1');

end gendc_lib;

package body gendc_lib is

function gdcl_writedata (
  addrlo : std_logic_vector(1 downto 0);
  base : std_logic_vector(31 downto 0);
  data : std_logic_vector(31 downto 0);
  bo   : lmd_byteorder;
  size : lmd_memsize
) return std_logic_vector is
  variable tmp  : std_logic_vector(31 downto 0);
begin
  tmp := base;
  if bo = lmd_little then
    -- lmd_little: byte[3 2 1 0], hw[1 0]
    case size is
      when lmd_byte => 
        case addrlo(1 downto 0) is
          when "00" => tmp( 7 downto  0) := data( 7 downto  0);
          when "01" => tmp(15 downto  8) := data( 7 downto  0);
          when "10" => tmp(23 downto 16) := data( 7 downto  0);
          when "11" => tmp(31 downto 24) := data( 7 downto  0);
          when others => null;
        end case;
      when lmd_half => 
        case addrlo(1 downto 1) is
          when "0"  => tmp(15 downto  0) := data(15 downto  0);
          when "1"  => tmp(31 downto 16) := data(15 downto  0);
          when others => null;
        end case;
      when others => tmp := data;
    end case;
  else
    -- lmd_big:    byte[0 1 2 3], hw[0 1]
    case size is
      when lmd_byte => 
        case addrlo(1 downto 0) is
          when "00" => tmp(31 downto 24) := data( 7 downto  0);
          when "01" => tmp(23 downto 16) := data( 7 downto  0);
          when "10" => tmp(15 downto  8) := data( 7 downto  0);
          when "11" => tmp( 7 downto  0) := data( 7 downto  0);
          when others => null;
        end case;
      when lmd_half => 
        case addrlo(1 downto 1) is
          when "0"  => tmp(31 downto 16) := data(15 downto  0);
          when "1"  => tmp(15 downto  0) := data(15 downto  0);
          when others => null;
        end case;
      when others => tmp := data;
    end case;
  end if;
  return tmp;
end;

function gdcl_readdata (
  addrlo : std_logic_vector(1 downto 0);
  data : std_logic_vector(31 downto 0);
  bo   : lmd_byteorder;
  sign : std_logic;
  size : lmd_memsize
) return std_logic_vector is
  variable tmp  : std_logic_vector(31 downto 0);
begin
  tmp := (others => '0');
  if bo = lmd_little then
    -- lmd_little: byte[3 2 1 0], hw[1 0]
    case size is
      when lmd_byte => 
        case addrlo(1 downto 0) is
          when "00" => tmp( 7 downto 0) := data( 7 downto  0);
                       if sign='1' then
                         tmp(31 downto 8) := (others => data( 7));
                       end if;
          when "01" => tmp( 7 downto 0) := data(15 downto  8);
                       if sign='1' then
                         tmp(31 downto 8) := (others => data(15));
                       end if;
          when "10" => tmp( 7 downto 0) := data(23 downto 16);
                       if sign='1' then
                         tmp(31 downto 8) := (others => data(23));
                       end if;
          when "11" => tmp( 7 downto 0) := data(31 downto 24);
                       if sign='1' then
                         tmp(31 downto 8) := (others => data(31));
                       end if;
          when others => null;
        end case;
      when lmd_half => 
        case addrlo(1 downto 1) is
          when "0"  => tmp(15 downto 0) := data(15 downto  0);
                       if sign='1' then
                         tmp(31 downto 16) := (others => data( 15));
                       end if;
          when "1"  => tmp(15 downto 0) := data(31 downto  16);
                       if sign='1' then
                         tmp(31 downto 16) := (others => data(31));
                       end if;
          when others => null;
        end case;
      when others => tmp := data;
    end case;
  else
    -- lmd_big:    byte[0 1 2 3], hw[0 1]
    case size is
      when lmd_byte => 
        case addrlo(1 downto 0) is
          when "00" => tmp( 7 downto 0) := data(31 downto  24);
                       if sign='1' then
                         tmp(31 downto 8) := (others => data(31));
                       end if;
          when "01" => tmp( 7 downto 0) := data(23 downto 16);
                       if sign='1' then
                         tmp(31 downto 8) := (others => data(23));
                       end if;
          when "10" => tmp( 7 downto 0) := data(15 downto  8);
                       if sign='1' then
                         tmp(31 downto 8) := (others => data(16));
                       end if;
          when "11" => tmp( 7 downto 0) := data( 7 downto  0);
                       if sign='1' then
                         tmp(31 downto 8) := (others => data(7));
                       end if;
          when others => null;
        end case;
      when lmd_half => 
        case addrlo(1 downto 1) is
          when "0"  => tmp(15 downto 0) := data(31 downto  16);
                       if sign='1' then
                         tmp(31 downto 16) := (others => data(31));
                       end if;
          when "1"  => tmp(15 downto 0) := data(15 downto  0);
                       if sign='1' then
                         tmp(31 downto 16) := (others => data( 15));
                       end if;
          when others => null;
        end case;
      when others => tmp := data;
    end case;
  end if;
  return tmp;
end;

function gdcl_getpos (
  addr : std_logic_vector(GCML_DC_TLINE_BSZ-1 downto 0)
) return integer is
  variable tmp : integer;
begin
  tmp := 0;
  if CFG_DC_DLINE_SZ > 1 then
    tmp := lin_convint(addr(GCML_DC_DLINE_BSZ-1 downto 0));
  end if;
  return tmp;
end;
  
function gdcl_is_taghit (
  addr : std_logic_vector(31 downto 0);
  cline : gcml_dc_tline
) return boolean is
  variable tmp : boolean;
  variable tag : std_logic_vector(GDCL_TTAG_U downto GDCL_TTAG_D);
begin
  tmp := false;
  tag := addr(GDCL_TTAG_U downto GDCL_TTAG_D);
  if (tag = cline.tag) then
    tmp := true;
  end if;
  return tmp;
end;

function gdcl_is_linevalid (
  addr : std_logic_vector(31 downto 0);
  cline : gcml_dc_tline
) return boolean is
  variable tmp : boolean;
  variable line : std_logic_vector(GDCL_TLINE_U downto GDCL_TLINE_D);
begin
  tmp := false;
  line := addr(GDCL_TLINE_U downto GDCL_TLINE_D);
  if (cline.valid(lin_convint(line)) = '1')
  then
    tmp := true;
  end if;
  return tmp;
end;

function gdcl_is_linedirty (
  addr : std_logic_vector(31 downto 0);
  cline : gcml_dc_tline
) return boolean is
  variable tmp : boolean;
  variable line : std_logic_vector(GDCL_TLINE_U downto GDCL_TLINE_D);
begin
  tmp := false;
  line := addr(GDCL_TLINE_U downto GDCL_TLINE_D);
  if (cline.dirty(lin_convint(line)) = '1')
  then
    tmp := true;
  end if;
  return tmp;
end;

function gdcl_is_free (
  cline : gcml_dc_tline
) return boolean is
  variable tmp : boolean;
begin
  tmp := true;
  for i in CFG_DC_TLINE_SZ-1 downto 0 loop
    if cline.valid(i) = '1' then
      tmp := false;
    end if;
  end loop;  -- i
  return tmp;
end;

function gdcl_is_dirty (
  cline : gcml_dc_tline
) return boolean is
  variable tmp : boolean;
begin
  tmp := false;
  for i in CFG_DC_TLINE_SZ-1 downto 0 loop
    if cline.dirty(i) = '1' then
      tmp := true;
    end if;
  end loop;  -- i
  return tmp;
end;
  
end gendc_lib;

