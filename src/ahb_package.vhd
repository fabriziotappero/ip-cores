library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package ahb_package is

-----------------------------------------------------------------------------
-- Generic contants 
-----------------------------------------------------------------------------
--***************************************************************
constant dump_no: integer := 0;--no dump on memory write
constant dump_end: integer := 1;--memory dump at end of test
constant dump_all: integer := 2;--continuous memory dump
--***************************************************************
constant zeroes: std_logic_vector(31 downto 0):= (others => '0');
constant tie_zero: std_logic:= '0';
constant ones: std_logic_vector(31 downto 0):= (others => '1');
constant tie_one: std_logic:= '1';
--***************************************************************

-----------------------------------------------------------------------------
-- AHB system: for every slave define LOW and HIGH address 
-----------------------------------------------------------------------------
type addr_t is
  record
    high: integer;
    low: integer;
  end record;

-----------------------------------------------------------------------------
-- AHB Master
-----------------------------------------------------------------------------
-- AHB master inputs
type mst_in_t is
  record
    hgrant: std_logic; 
    hready: std_logic; 
    hresp: std_logic_vector(1 downto 0);
    hrdata: std_logic_vector(31 downto 0);
  end record;

-- AHB master outputs
type mst_out_t is
  record
    hbusreq: std_logic; 
    hlock: std_logic;
    htrans: std_logic_vector(1 downto 0);
    haddr: std_logic_vector(31 downto 0);
    hwrite: std_logic;
    hsize: std_logic_vector(2 downto 0);
    hburst: std_logic_vector(2 downto 0);
    hprot: std_logic_vector(3 downto 0);
    hwdata: std_logic_vector(31 downto 0);
  end record;

-----------------------------------------------------------------------------
-- AHB Slave
-----------------------------------------------------------------------------
-- AHB slave inputs
type slv_in_t is
  record
    hsel: std_logic;
    haddr: std_logic_vector(31 downto 0);
    hwrite: std_logic;
    htrans: std_logic_vector(1 downto 0);
    hsize: std_logic_vector(2 downto 0);
    hburst: std_logic_vector(2 downto 0);
    hwdata: std_logic_vector(31 downto 0);
    hprot: std_logic_vector(3 downto 0);
    hready: std_logic; 
    hmaster: std_logic_vector(3 downto 0);
    hmastlock: std_logic; 
  end record;

-- AHB slave outputs
type slv_out_t is
  record
    hready: std_logic;  
    hresp: std_logic_vector(1 downto 0);
    hrdata: std_logic_vector(31 downto 0); 
    hsplit: std_logic_vector(15 downto 0);
  end record;

-----------------------------------------------------------------------------
-- Definitions for AMBA APB Slaves constants and types
-----------------------------------------------------------------------------
constant apb_addr: integer range 8 to 32 := 32;-- address width
constant apb_data: integer range 8 to 32 := 32;-- data width

-- APB slave inputs
type apb_in_t is
  record
    psel: std_logic;
    penable: std_logic;
    paddr: std_logic_vector(apb_addr-1 downto 0);
    pwrite: std_logic;
    pwdata: std_logic_vector(apb_data-1 downto 0);
  end record;

-- APB slave outputs
type apb_out_t is
  record
    prdata: std_logic_vector(apb_addr-1 downto 0);
  end record;
  
-----------------------------------------------------------------------------
-- Definitions for AMBA AHB Arbiter/Decoder/Bridges
-----------------------------------------------------------------------------
-- supporting array types

type addr_in_v_t  is array (15 downto 0) of addr_t;
type addr_matrix_t is array (natural range <> ) of addr_in_v_t;
  
type mst_in_v_t  is array (natural Range <> ) of mst_in_t;
type mst_out_v_t is array (natural Range <> ) of mst_out_t;

type slv_in_v_t  is array (natural Range <> ) of slv_in_t;
type slv_out_v_t is array (natural Range <> ) of slv_out_t;

type apb_in_v_t  is array (natural range <> ) of apb_in_t;
type apb_out_v_t is array (natural range <> ) of apb_out_t;


--***************************************************************
-- definition of amba AHB protocol constants
--***************************************************************

--***************************************************************
--configuration register space addresses
--***************************************************************
constant dma_extadd_addr:       std_logic_vector(3 downto 0):= "0000";
constant dma_intadd_addr:       std_logic_vector(3 downto 0):= "0001";
constant dma_intmod_addr:       std_logic_vector(3 downto 0):= "0010";
constant dma_type_addr:         std_logic_vector(3 downto 0):= "0011";
constant dma_count_addr:        std_logic_vector(3 downto 0):= "0100";
constant dma_go_addr:           std_logic_vector(3 downto 0):= "0101";

--***************************************************************
-- hprot values
--***************************************************************
--constant opcode_fetch: 	std_logic_vector(3 downto 0):= "---0";
--constant data_access:  	std_logic_vector(3 downto 0):= "---1";
--constant user_access: 	std_logic_vector(3 downto 0):= "--0-";
--constant privileged_access:   std_logic_vector(3 downto 0):= "--1-";
--constant not_bufferable: 	std_logic_vector(3 downto 0):= "-0--";
--constant bufferable: 		std_logic_vector(3 downto 0):= "-1--";
--constant not_cacheable: 	std_logic_vector(3 downto 0):= "0---";
--constant cacheable: 		std_logic_vector(3 downto 0):= "1---";

--***************************************************************
-- hburst values
--***************************************************************
constant single:        std_logic_vector(2 downto 0):= "000";
constant incr:          std_logic_vector(2 downto 0):= "001";
constant wrap4:         std_logic_vector(2 downto 0):= "010";
constant incr4:         std_logic_vector(2 downto 0):= "011";
constant wrap8:         std_logic_vector(2 downto 0):= "100";
constant incr8:         std_logic_vector(2 downto 0):= "101";
constant wrap16:        std_logic_vector(2 downto 0):= "110";
constant incr16:        std_logic_vector(2 downto 0):= "111";

--***************************************************************
-- hsize values
--***************************************************************
constant bits8:         std_logic_vector(2 downto 0):= "000";
constant bits16:        std_logic_vector(2 downto 0):= "001";
constant bits32:        std_logic_vector(2 downto 0):= "010";
constant bits64:        std_logic_vector(2 downto 0):= "011";
constant bits128:       std_logic_vector(2 downto 0):= "100";
constant bits256:       std_logic_vector(2 downto 0):= "101";
constant bits512:       std_logic_vector(2 downto 0):= "110";
constant bits1024:      std_logic_vector(2 downto 0):= "111";

--***************************************************************
-- htrans values
--***************************************************************
constant idle:        std_logic_vector(1 downto 0):= "00";
constant busy:        std_logic_vector(1 downto 0):= "01";
constant nonseq:      std_logic_vector(1 downto 0):= "10";
constant seq:         std_logic_vector(1 downto 0):= "11";

--***************************************************************
-- hresp values
--***************************************************************
constant ok_resp:     std_logic_vector(1 downto 0):= "00";
constant error_resp:  std_logic_vector(1 downto 0):= "01";
constant retry_resp:  std_logic_vector(1 downto 0):= "10";
constant split_resp:  std_logic_vector(1 downto 0):= "11";

-----------------------------------------------------------------------------
-- AHB system constants 
-----------------------------------------------------------------------------

--***************************************************************
-- priority values
--***************************************************************
constant master:      std_logic:= '1';
constant slave:       std_logic:= '0';

--***************************************************************
-- split retry programmable slave response values
--***************************************************************
constant retry:      std_logic:= '0';
constant split:      std_logic:= '1';

--***************************************************************
-- locked/non locked ahb bus request programmable
--***************************************************************
constant nonlocked:			std_logic:='0';
constant locked:			std_logic:='1';

--***************************************************************
-- burst capability for masters and slaves
--***************************************************************
constant burst_support:	   integer:= 1;
constant no_burst_support:   integer:= 0;

--***************************************************************
-- hprot values
--***************************************************************
constant hprot_posted:    std_logic_vector(3 downto 0):= "1111";
constant hprot_nonposted: std_logic_vector(3 downto 0):= "0000";

-----------------------------------------------------------------------------
-- Definitions for test ports
-----------------------------------------------------------------------------
type conf_type_t is
  record
    write: std_logic; 
    addr: std_logic_vector(3 downto 0);
    wdata: std_logic_vector(31 downto 0);
  end record;

-----------------------------------------------------------------------------
-- Definitions for ahb master dma parameters passing
-----------------------------------------------------------------------------
type start_type_t is
  record
    start: std_logic; 
    extaddr: std_logic_vector(31 downto 0);
    intaddr: std_logic_vector(15 downto 0);
    intmod: std_logic_vector(15 downto 0);
    count: std_logic_vector(15 downto 0);
    hparams: std_logic_vector(15 downto 0);
  end record;

-----------------------------------------------------------------------------
-- Handshake signals and data between master/slave and internal memories/registers
-----------------------------------------------------------------------------
type wrap_out_t is
  record
    addr: std_logic_vector(31 downto 0);
    take: std_logic; 
    wdata: std_logic_vector(31 downto 0);
    ask: std_logic; 
  end record;
  
type wrap_in_t is
  record
    take_ok: std_logic; 
    ask_ok: std_logic; 
    rdata: std_logic_vector(31 downto 0);
  end record;

-----------------------------------------------------------------------------
-- Parameters for defining AHB STIMULATOR behaviour
-----------------------------------------------------------------------------
type uut_params_t is
  record
    hsize_tb: std_logic_vector(2 downto 0);
    split_tb: std_logic;
    prior_tb: std_logic;
    hburst_cycle: std_logic;
    hburst_tb: std_logic_vector(2 downto 0);
--    high_addr_tb:std_logic_vector(19 downto 0); 
    ext_addr_incr_tb: integer;
    intmod_tb: integer;
    hprot_tb: std_logic_vector(3 downto 0);
    base_tb: integer;
    int_addr_incr_tb: integer;
    int_base_tb: integer;
    locked_request: std_logic;
  end record;

-----------------------------------------------------------------------------
-- Vector types (aggregates) of previous types
-----------------------------------------------------------------------------
type conf_type_v is array (Natural Range <> ) of conf_type_t;

type start_type_v is array (Natural Range <> ) of start_type_t;

type wrap_out_v is array (Natural Range <> ) of wrap_out_t;
type wrap_in_v is array (Natural Range <> ) of wrap_in_t;

type uut_params_v_t is array (Natural Range <> ) of uut_params_t; 

--***************************************************************
  

--***************************************************************
--***************************************************************
--uut#0
--signal stim_0: uut_params_t:= (bits32,retry,master,'0',wrap4,"00000000000000000000",2,4,hprot_nonposted,2048,1,0,'1');
--uut#1
--signal stim_1: uut_params_t:= (bits32,retry,slave,'0',wrap4,"00000000000000000000",2,4,hprot_posted,2048+128,1,0,'1');
--uut#2
--signal stim_2: uut_params_t:= (bits32,retry,master,'0',wrap4,"00000000000000000000",2,4,hprot_posted,2048+256,1,0,'0');
--uut#3
--signal stim_3: uut_params_t:= (bits32,retry,master,'0',wrap4,"00010000001000000000",2,4,hprot_posted,2048,1,0,'0');

--signal stim_v: uut_params_v_t(3 downto 0) := (stim_3, stim_2, stim_1, stim_0);
--***************************************************************
--***************************************************************
end;

package body ahb_package is
end;



