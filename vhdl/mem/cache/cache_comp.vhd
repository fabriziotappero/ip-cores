-- $(lic)
-- $(help_generic)
-- $(help_local)

library IEEE;
use IEEE.std_logic_1164.all;
use work.amba.all;
use work.config.all;
use work.cache_config.all;
use work.corelib.all;
use work.gencmem_lib.all;
use work.gendc_lib.all;
use work.genic_lib.all;
use work.genwb_lib.all;
use work.bus_comp.all;

package cache_comp is


--cachemen
type gencmem_type_ic_in is record
  addr  : std_logic_vector(31 downto 0);
  -- # write tag in
  tag_line  : gcml_ic_tline;
  tag_write : std_logic_vector(CFG_IC_SETS-1 downto 0);
  -- # write data in
  dat_line  : gcml_ic_dline;
  dat_write : std_logic_vector(CFG_IC_SETS-1 downto 0);
end record;

type std_logic_vector_a is array (natural range <>) of std_logic_vector(31 downto 0);

type gencmem_type_ic_out is record
  -- # read tag out
  tag_line  : gcml_ic_tline_a(CFG_IC_SETS-1 downto 0);
  -- # read data out
  dat_line  : gcml_ic_dline_a(CFG_IC_SETS-1 downto 0);
end record;


type gencmem_type_dc_in is record
  addr  : std_logic_vector(31 downto 0);
  -- # write tag in
  tag_line  : gcml_dc_tline;
  tag_write : std_logic_vector(CFG_DC_SETS-1 downto 0);
  -- # write data in
  --dat_addr  : std_logic_vector(GCML_DC_DADDR_BSZ-1 downto 0);
  dat_line  : gcml_dc_dline;
  dat_write : std_logic_vector(CFG_DC_SETS-1 downto 0);
end record;

type gencmem_type_dc_out is record
  -- # read tag out
  tag_line  : gcml_dc_tline_a(CFG_DC_SETS-1 downto 0);
  -- # read data out
  dat_line  : gcml_dc_dline_a(CFG_DC_SETS-1 downto 0);
end record;


type gencmem_type_in is record
  ic : gencmem_type_ic_in;
  dc : gencmem_type_dc_in;
end record;

type gencmem_type_out is record
  ic : gencmem_type_ic_out;
  dc : gencmem_type_dc_out;
end record;

component gencmem 
  port ( 
    rst    : in  std_logic; 
    clk    : in  std_logic;
    i  : in  gencmem_type_in;
    o  : out gencmem_type_out
    );
end component;

-- icache
type genic_type_in is record
  pc_r : std_logic_vector(31 downto 0);
  pc_v : std_logic_vector(31 downto 0);
  bra_r : std_logic;
  bra_v : std_logic;
  annul : std_logic;
  flush : std_logic;
end record;

type genic_type_out is record
  dat_line_v  : gcml_ic_dline;
  mstrobe : std_logic;
  hold : std_logic;
end record;

component genic
  port ( 
    rst     : in  std_logic; 
    clk     : in  std_logic;
    hold : in cli_hold;
    i    : in  genic_type_in;
    o    : out genic_type_out;
    ctrl : in gicl_ctrl;
    icmo : in gencmem_type_ic_out;
    icmi : out gencmem_type_ic_in;
    mcio : in ahbmst_mp_out;
    mcii : out ahbmst_mp_in
    );
end component;


-- wb
type genwb_type_in is record
  fifo_write : std_logic;
  fifo_entry : gwbl_entry;
end record;

type genwb_type_out is record
  fifo_stored_v : std_logic;
  empty_v : std_logic;

  read_finish_v : std_logic;
  read_mexc : std_logic;
  read_data : std_logic_vector(31 downto 0);
end record;

component genwb
  port ( 
    rst     : in  std_logic; 
    clk     : in  std_logic;
    i  : in  genwb_type_in;
    o  : out genwb_type_out;
    mcwbo : in ahbmst_mp_out;
    mcwbi : out ahbmst_mp_in
  );
end component;


-- wbfifo
type genwbfifo_type_in is record
  fifo_entry : gwbl_entry;
  fifo_read, fifo_write : std_logic;
end record;

type genwbfifo_type_out is record
  fifo_entry : gwbl_entry;
  fifo_stored_v : std_logic;
  fifo_empty_r : std_logic;
end record;

component genwbfifo
  generic (
    WBBUF_SZ : integer := 2
  );
  port ( 
    rst : in  std_logic; 
    clk : in  std_logic;
    i : in  genwbfifo_type_in;
    o : out genwbfifo_type_out
  );
end component;

-- dcache
type gendc_type_in is record
  addr_in : std_logic_vector(31 downto 0);  -- incoming
  data_in : std_logic_vector(31 downto 0);
  addr_re : std_logic_vector(31 downto 0);  -- registered
  data_re : std_logic_vector(31 downto 0);
  addrin_re : std_logic;

  -- todo: locking on atomic load store does not work yet
  -- until no multiprocessor system is implemented it's defered to the future

  atomic_readwrite : std_logic;
  
  forcewrite : std_logic;
  forceread : std_logic;
  
  param_r : gdcl_param;
  annul : std_logic;
end record;

type gendc_type_out is record
  wr_data : std_logic_vector(31 downto 0);
  me_mexc : std_logic;
  wr_mexc : std_logic;
  hold : std_logic;
end record;

component gendc 
  port ( 
    rst     : in  std_logic; 
    clk     : in  std_logic;
    hold : in cli_hold;
    i  : in  gendc_type_in;
    o  : out gendc_type_out;
    ctrl : in gdcl_ctrl;
    dcmo : in gencmem_type_dc_out;
    dcmi : out gencmem_type_dc_in;
    wbi  : out genwb_type_in;
    wbo  : in genwb_type_out
    );
end component;


component setrepl
  generic (
    SETSIZE      : integer := 1;
    SETSIZE_logx : integer := 1;
    SETREPL_TYPE : cfg_repl_type := cfg_repl_rnd 
  );
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    setfree : in std_logic_vector(SETSIZE-1 downto 0);
    setlock : in std_logic_vector(SETSIZE-1 downto 0);
    useset : in std_logic;
    locked : out std_logic;
    free   : out std_logic;
    setrep_free : out std_logic_vector(SETSIZE_logx-1 downto 0);
    setrep_repl : out std_logic_vector(SETSIZE_logx-1 downto 0)
    );
end component;

end cache_comp;
