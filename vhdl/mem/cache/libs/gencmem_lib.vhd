-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.int.all;
use work.config.all;
use work.cache_config.all;

-- PREFIX: gcml_xxx
package gencmem_lib is

-- ICACHE:
--
--                      +---------------------+---------------+-------+----+
-- addr as data-access: |          xxx        |   DADDR       | DLINE | 00 |
--                      +---------------------+---------------+-------+----+
--                      
--                      +---------------------+-----------+-----------+----+
-- addr as tag-access : |        TTAG         |   TADDR   | TLINE     | 00 |   |
--                      +---------------------+-----------+-----------+----+
--
--                  ICACHE TAG                                          ICACHE DATA
--        .                    .        .                  .                    .                    . 
--  TADDR |                    |        |            DADDR |                    |                    | 
--    |   +--------------------+--------+              |   +--------------------+--------------------+..
--    +-->|       CTAG         | CVALID |              +-->|       data         |       data         |
--        +--------------------+--------+                  +--------------------+--------------------+..
--        |                    |        |                  |                    |                    |
--        .                    .        .                  .                    .                    .

-- addr as icache tag-access (sizes only)
constant GCML_IC_TTAG_BSZ : integer := CFG_IC_ADDR_SZ - (2 + (8 +lin_log2(CFG_IC_SET_SZ)));
constant GCML_IC_TADDR_BSZ : integer := ((8 +lin_log2(CFG_IC_SET_SZ))-lin_log2(CFG_IC_TLINE_SZ)); -- (lin_log(1k)-2) + lin_log2(cachesize) - lin_log2(cacheline)
constant GCML_IC_TLINE_BSZ : integer := lin_log2(CFG_IC_TLINE_SZ);

-- addr to icache data-access (sizes only)
constant GCML_IC_DADDR_BSZ : integer := ((8 +lin_log2(CFG_IC_SET_SZ))-lin_log2(CFG_IC_DLINE_SZ)); -- (lin_log(1k)-2) + lin_log2(cachesize) - lin_log2(cacheline)
constant GCML_IC_DLINE_BSZ : integer := lin_log2(CFG_IC_DLINE_SZ);

-- icache cmem-data layout
constant GCML_IC_DL_BSZ : integer := CFG_IC_DLINE_SZ*32;

-- icache cmem-tag layout
constant GCML_IC_CLOCK_C : integer := (CFG_IC_TLINE_SZ+(CFG_IC_ADDR_SZ-(2+(8+lin_log2(CFG_IC_SET_SZ)))));
constant GCML_IC_CTAG_D : integer := CFG_IC_TLINE_SZ;  -- tag to compare addr to
constant GCML_IC_CTAG_U : integer := (CFG_IC_TLINE_SZ+(CFG_IC_ADDR_SZ-(2+(8+lin_log2(CFG_IC_SET_SZ)))))-1;
constant GCML_IC_CVALID_D : integer := 0;  -- valid bit of line entry
constant GCML_IC_CVALID_U : integer := (CFG_IC_TLINE_SZ)-1;
constant GCML_IC_TL_BSZ : integer := (CFG_IC_TLINE_SZ+(CFG_IC_ADDR_SZ-(2+(8+lin_log2(CFG_IC_SET_SZ)))))+1; -- complete tag line size

-- icache tag line 
type gcml_ic_tline is record
  tag   : std_logic_vector(GCML_IC_TTAG_BSZ-1 downto 0);
  valid : std_logic_vector(CFG_IC_TLINE_SZ-1 downto 0);
  lock : std_logic;
end record;
type gcml_ic_tline_a is array (natural range <>) of gcml_ic_tline;

-- icache data line 
type std_logic_vector_a is array (natural range <>) of std_logic_vector(31 downto 0);
type gcml_ic_dline is record
  data : std_logic_vector_a(CFG_IC_DLINE_SZ-1 downto 0);
end record;
type gcml_ic_dline_a is array (natural range <>) of gcml_ic_dline;


function gcml_icttostd (
  line : gcml_ic_tline
) return std_logic_vector;
  
procedure gcml_stdtoict (
  data : in std_logic_vector(GCML_IC_TL_BSZ-1 downto 0);
  line : inout gcml_ic_tline
);

function gcml_icdtostd (
  line : gcml_ic_dline
) return std_logic_vector;
  
procedure gcml_stdtoicd (
  data : in std_logic_vector(GCML_IC_DL_BSZ-1 downto 0);
  line : inout gcml_ic_dline
);



-- DCACHE:
--
--                      +---------------------+---------------+-------+----+
-- addr as data-access: |          xxx        |   DADDR       | DLINE | 00 |
--                      +---------------------+---------------+-------+----+
--                      
--                      +---------------------+-----------+-----------+----+
-- addr as tag-access : |        TTAG         |   TADDR   | TLINE     | 00 |   |
--                      +---------------------+-----------+-----------+----+
--
--                  ICACHE TAG                                          ICACHE DATA
--        .                    .        .                  .                    .                    . 
--  TADDR |                    |        |            DADDR |                    |                    | 
--    |   +--------------------+--------+              |   +--------------------+--------------------+..
--    +-->|       CTAG         | CVALID |              +-->|       data         |       data         |
--        +--------------------+--------+                  +--------------------+--------------------+..
--        |                    |        |                  |                    |                    |
--        .                    .        .                  .                    .                    .

-- addr as dcache tag-access (sizes only)
constant GCML_DC_TDIRTY_BSZ : integer := lin_log2(CFG_DC_TLINE_SZ); 
constant GCML_DC_TTAG_BSZ   : integer := CFG_DC_ADDR_SZ - (2 + (8 +lin_log2(CFG_DC_SET_SZ)));
constant GCML_DC_TADDR_BSZ  : integer := ((8 +lin_log2(CFG_DC_SET_SZ))-lin_log2(CFG_DC_TLINE_SZ)); -- (lin_log(1k)-2) + lin_log2(cachesize) - lin_log2(cacheline)
constant GCML_DC_TLINE_BSZ  : integer := lin_log2(CFG_DC_TLINE_SZ); 

-- addr as dcache data-access (sizes only)
constant GCML_DC_DADDR_BSZ : integer := ((8 +lin_log2(CFG_DC_SET_SZ))-lin_log2(CFG_DC_DLINE_SZ)); -- (lin_log(1k)-2) + lin_log2(cachesize) - lin_log2(cacheline)
constant GCML_DC_DLINE_BSZ : integer := lin_log2(CFG_DC_DLINE_SZ); 

-- writeback to writebuffer
constant GCML_DC_DLINEperTLINE_SZ : integer := CFG_DC_TLINE_SZ/CFG_DC_DLINE_SZ; 

-- dcache cmem-data layout
constant GCML_DC_DL_BSZ   : integer := CFG_DC_DLINE_SZ*32;

-- dcache cmem-tag layout
constant GCML_DC_CLOCK_C  : integer := ((CFG_DC_TLINE_SZ*2)+(CFG_DC_ADDR_SZ-(2+(8+lin_log2(CFG_DC_SET_SZ)))));
constant GCML_DC_CDIRTY_D : integer :=  (CFG_DC_TLINE_SZ   +(CFG_DC_ADDR_SZ-(2+(8+lin_log2(CFG_DC_SET_SZ)))));
constant GCML_DC_CDIRTY_U : integer := ((CFG_DC_TLINE_SZ*2)+(CFG_DC_ADDR_SZ-(2+(8+lin_log2(CFG_DC_SET_SZ)))))-1;
constant GCML_DC_CTAG_D   : integer :=   CFG_DC_TLINE_SZ;
constant GCML_DC_CTAG_U   : integer :=  (CFG_DC_TLINE_SZ   +(CFG_DC_ADDR_SZ-(2+(8+lin_log2(CFG_DC_SET_SZ)))))-1;
constant GCML_DC_CVALID_D : integer :=   0;
constant GCML_DC_CVALID_U : integer :=  (CFG_DC_TLINE_SZ)-1;
constant GCML_DC_TL_BSZ   : integer := ((CFG_DC_TLINE_SZ*2)+(CFG_DC_ADDR_SZ-(2+(8+lin_log2(CFG_DC_SET_SZ)))))+1;


-- dcache tag line 
type gcml_dc_tline is record
  tag   : std_logic_vector(GCML_DC_TTAG_BSZ-1 downto 0);
  valid : std_logic_vector(CFG_DC_TLINE_SZ-1 downto 0);
  dirty : std_logic_vector(CFG_DC_TLINE_SZ-1 downto 0);
  lock : std_logic;
end record;
type gcml_dc_tline_a is array (natural range <>) of gcml_dc_tline;

-- dcache data line 
type gcml_dc_dline is record
  data : std_logic_vector_a(CFG_DC_DLINE_SZ-1 downto 0);
end record;
type gcml_dc_dline_a is array (natural range <>) of gcml_dc_dline;


function gcml_dcttostd (
  line : gcml_dc_tline
) return std_logic_vector;
  
procedure gcml_stdtodct (
  data : in std_logic_vector(GCML_DC_TL_BSZ-1 downto 0);
  line : inout gcml_dc_tline
);

function gcml_dcdtostd (
  line : gcml_dc_dline
) return std_logic_vector;
  
procedure gcml_stdtodcd (
  data : in std_logic_vector(GCML_DC_DL_BSZ-1 downto 0);
  line : inout gcml_dc_dline
);



end gencmem_lib;

package body gencmem_lib is

-- icache conversions
function gcml_icttostd (
  line : gcml_ic_tline
) return std_logic_vector is
  variable tmp : std_logic_vector(GCML_IC_TL_BSZ-1 downto 0);
begin
  tmp(GCML_IC_CTAG_U downto GCML_IC_CTAG_D) := line.tag;
  tmp(GCML_IC_CVALID_U downto GCML_IC_CVALID_D) := line.valid;
  tmp(GCML_IC_CLOCK_C) := line.lock;
  return tmp;
end;

procedure gcml_stdtoict (
  data : in std_logic_vector(GCML_IC_TL_BSZ-1 downto 0);
  line : inout gcml_ic_tline
) is
begin
  line.tag := data(GCML_IC_CTAG_U downto GCML_IC_CTAG_D);
  line.valid := data(GCML_IC_CVALID_U downto GCML_IC_CVALID_D);
  line.lock := data(GCML_IC_CLOCK_C);
end;

function gcml_icdtostd (
  line : gcml_ic_dline
) return std_logic_vector is
  variable tmp : std_logic_vector(GCML_IC_DL_BSZ-1 downto 0);
begin
  for i in CFG_IC_DLINE_SZ-1 downto 0 loop
    tmp((i*32)+31 downto (i*32)) := line.data(i);
  end loop;
  return tmp;
end;

procedure gcml_stdtoicd (
  data : in std_logic_vector(GCML_IC_DL_BSZ-1 downto 0);
  line : inout gcml_ic_dline
) is
begin
  for i in CFG_IC_DLINE_SZ-1 downto 0 loop
    line.data(i) := data((i*32)+31 downto (i*32));
  end loop;
end;

-- dcache conversions
function gcml_dcttostd (
  line : gcml_dc_tline
) return std_logic_vector is
  variable tmp : std_logic_vector(GCML_DC_TL_BSZ-1 downto 0);
begin
  tmp(GCML_DC_CTAG_U downto GCML_DC_CTAG_D) := line.tag;
  tmp(GCML_DC_CVALID_U downto GCML_DC_CVALID_D) := line.valid;
  tmp(GCML_DC_CDIRTY_U downto GCML_DC_CDIRTY_D) := line.dirty;
  tmp(GCML_DC_CLOCK_C) := line.lock;
  return tmp;
end;
  
procedure gcml_stdtodct (
  data : in std_logic_vector(GCML_DC_TL_BSZ-1 downto 0);
  line : inout gcml_dc_tline
) is
begin
  line.tag := data(GCML_DC_CTAG_U downto GCML_DC_CTAG_D);
  line.valid := data(GCML_DC_CVALID_U downto GCML_DC_CVALID_D);
  line.dirty := data(GCML_DC_CDIRTY_U downto GCML_DC_CDIRTY_D);
  line.lock := data(GCML_DC_CLOCK_C);
end;
  
function gcml_dcdtostd (
  line : gcml_dc_dline
) return std_logic_vector is
  variable tmp : std_logic_vector(GCML_DC_DL_BSZ-1 downto 0);
begin
  for i in CFG_DC_DLINE_SZ-1 downto 0 loop
    tmp((i*32)+31 downto (i*32)) := line.data(i);
  end loop;
  return tmp;
end;
  
procedure gcml_stdtodcd (
  data : in std_logic_vector(GCML_DC_DL_BSZ-1 downto 0);
  line : inout gcml_dc_dline
) is
begin
  for i in CFG_DC_DLINE_SZ-1 downto 0 loop
    line.data(i) := data((i*32)+31 downto (i*32));
  end loop;
end;
  
end gencmem_lib;
