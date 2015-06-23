library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity memtest is
    port(
        FXCLK         : in std_logic;
        RESET_IN      : in std_logic;
        IFCLK         : in std_logic;

	-- FX2 FIFO
        FD            : out std_logic_vector(15 downto 0); 

        SLOE          : out std_logic;
        SLRD          : out std_logic;
        SLWR          : out std_logic;
        FIFOADR0      : out std_logic;
        FIFOADR1      : out std_logic;
        PKTEND        : out std_logic;

        FLAGB         : in std_logic;
        PA3           : in std_logic;

	-- errors ...
        PC            : out std_logic_vector(7 downto 0); 

	-- DDR-SDRAM
	mcb3_dram_dq    : inout std_logic_vector(15 downto 0);
        mcb3_rzq        : inout std_logic;
        mcb3_zio        : inout std_logic;
        mcb3_dram_udqs  : inout std_logic;
        mcb3_dram_dqs   : inout std_logic;
	mcb3_dram_a     : out std_logic_vector(12 downto 0);
	mcb3_dram_ba    : out std_logic_vector(1 downto 0);
        mcb3_dram_cke   : out std_logic;
        mcb3_dram_ras_n : out std_logic;
        mcb3_dram_cas_n : out std_logic;
        mcb3_dram_we_n  : out std_logic;
        mcb3_dram_dm    : out std_logic;
        mcb3_dram_udm   : out std_logic;
        mcb3_dram_ck    : out std_logic;
        mcb3_dram_ck_n  : out std_logic
    );
end memtest;

architecture RTL of memtest is

component dcm0
    port (
	-- Clock in ports
	CLK_IN1           : in     std_logic;
	-- Clock out ports
	CLK_OUT1          : out    std_logic;
	CLK_OUT2          : out    std_logic;
	-- Status and control signals
	RESET             : in     std_logic;
        LOCKED            : out    std_logic;
	CLK_VALID         : out    std_logic
    );
end component;

component mem0 
    generic (
	C3_P0_MASK_SIZE       : integer := 4;
	C3_P0_DATA_PORT_SIZE  : integer := 32;
	C3_P1_MASK_SIZE       : integer := 4;
	C3_P1_DATA_PORT_SIZE  : integer := 32;
	C3_MEMCLK_PERIOD      : integer := 5000;
        C3_INPUT_CLK_TYPE     : string := "SINGLE_ENDED";
	C3_RST_ACT_LOW        : integer := 0;
	C3_CALIB_SOFT_IP      : string := "FALSE";
	C3_MEM_ADDR_ORDER     : string := "ROW_BANK_COLUMN";
	C3_NUM_DQ_PINS        : integer := 16;
	C3_MEM_ADDR_WIDTH     : integer := 13;
	C3_MEM_BANKADDR_WIDTH : integer := 2
    );
	
   port (
	mcb3_dram_dq         : inout std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
	mcb3_dram_a          : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
	mcb3_dram_ba         : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
        mcb3_dram_cke        : out std_logic;
        mcb3_dram_ras_n      : out std_logic;
        mcb3_dram_cas_n      : out std_logic;
        mcb3_dram_we_n       : out std_logic;
        mcb3_dram_dm         : out std_logic;
        mcb3_dram_udqs       : inout std_logic;
        mcb3_rzq             : inout std_logic;
        mcb3_dram_udm        : out std_logic;
        mcb3_dram_dqs        : inout std_logic;
        mcb3_dram_ck         : out std_logic;
        mcb3_dram_ck_n       : out std_logic;

        c3_sys_clk           : in std_logic;
        c3_sys_rst_n         : in std_logic;

        c3_calib_done        : out std_logic;
        c3_clk0              : out std_logic;
        c3_rst0              : out std_logic;

        c3_p0_cmd_clk        : in std_logic;
        c3_p0_cmd_en         : in std_logic;
        c3_p0_cmd_instr      : in std_logic_vector(2 downto 0);
        c3_p0_cmd_bl         : in std_logic_vector(5 downto 0);
        c3_p0_cmd_byte_addr  : in std_logic_vector(29 downto 0);
        c3_p0_cmd_empty      : out std_logic;
        c3_p0_cmd_full       : out std_logic;
        c3_p0_wr_clk         : in std_logic;
        c3_p0_wr_en          : in std_logic;
        c3_p0_wr_mask        : in std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
        c3_p0_wr_data        : in std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
        c3_p0_wr_full        : out std_logic;
        c3_p0_wr_empty       : out std_logic;
        c3_p0_wr_count       : out std_logic_vector(6 downto 0);
        c3_p0_wr_underrun    : out std_logic;
        c3_p0_wr_error       : out std_logic;
        c3_p0_rd_clk         : in std_logic;
        c3_p0_rd_en          : in std_logic;
        c3_p0_rd_data        : out std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
        c3_p0_rd_full        : out std_logic;
        c3_p0_rd_empty       : out std_logic;
        c3_p0_rd_count       : out std_logic_vector(6 downto 0);
        c3_p0_rd_overflow    : out std_logic;
        c3_p0_rd_error       : out std_logic;

        c3_p1_cmd_clk        : in std_logic;
        c3_p1_cmd_en         : in std_logic;
        c3_p1_cmd_instr      : in std_logic_vector(2 downto 0);
        c3_p1_cmd_bl         : in std_logic_vector(5 downto 0);
        c3_p1_cmd_byte_addr  : in std_logic_vector(29 downto 0);
        c3_p1_cmd_empty      : out std_logic;
        c3_p1_cmd_full       : out std_logic;
        c3_p1_wr_clk         : in std_logic;
        c3_p1_wr_en          : in std_logic;
        c3_p1_wr_mask        : in std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
        c3_p1_wr_data        : in std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
        c3_p1_wr_full        : out std_logic;
        c3_p1_wr_empty       : out std_logic;
        c3_p1_wr_count       : out std_logic_vector(6 downto 0);
        c3_p1_wr_underrun    : out std_logic;
        c3_p1_wr_error       : out std_logic;
        c3_p1_rd_clk         : in std_logic;
        c3_p1_rd_en          : in std_logic;
        c3_p1_rd_data        : out std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
        c3_p1_rd_full        : out std_logic;
        c3_p1_rd_empty       : out std_logic;
        c3_p1_rd_count       : out std_logic_vector(6 downto 0);
        c3_p1_rd_overflow    : out std_logic;
        c3_p1_rd_error       : out std_logic;

        c3_p2_cmd_clk        : in std_logic;
        c3_p2_cmd_en         : in std_logic;
        c3_p2_cmd_instr      : in std_logic_vector(2 downto 0);
        c3_p2_cmd_bl         : in std_logic_vector(5 downto 0);
        c3_p2_cmd_byte_addr  : in std_logic_vector(29 downto 0);
        c3_p2_cmd_empty      : out std_logic;
        c3_p2_cmd_full       : out std_logic;
        c3_p2_wr_clk         : in std_logic;
        c3_p2_wr_en          : in std_logic;
        c3_p2_wr_mask        : in std_logic_vector(3 downto 0);
        c3_p2_wr_data        : in std_logic_vector(31 downto 0);
        c3_p2_wr_full        : out std_logic;
        c3_p2_wr_empty       : out std_logic;
        c3_p2_wr_count       : out std_logic_vector(6 downto 0);
        c3_p2_wr_underrun    : out std_logic;
        c3_p2_wr_error       : out std_logic;
        
        c3_p3_cmd_clk        : in std_logic;
        c3_p3_cmd_en         : in std_logic;
        c3_p3_cmd_instr      : in std_logic_vector(2 downto 0);
        c3_p3_cmd_bl         : in std_logic_vector(5 downto 0);
        c3_p3_cmd_byte_addr  : in std_logic_vector(29 downto 0);
        c3_p3_cmd_empty      : out std_logic;
        c3_p3_cmd_full       : out std_logic;
        c3_p3_rd_clk         : in std_logic;
        c3_p3_rd_en          : in std_logic;
        c3_p3_rd_data        : out std_logic_vector(31 downto 0);
        c3_p3_rd_full        : out std_logic;
        c3_p3_rd_empty       : out std_logic;
        c3_p3_rd_count       : out std_logic_vector(6 downto 0);
        c3_p3_rd_overflow    : out std_logic;
        c3_p3_rd_error       : out std_logic;
        
        c3_p4_cmd_clk        : in std_logic;
        c3_p4_cmd_en         : in std_logic;
        c3_p4_cmd_instr      : in std_logic_vector(2 downto 0);
        c3_p4_cmd_bl         : in std_logic_vector(5 downto 0);
        c3_p4_cmd_byte_addr  : in std_logic_vector(29 downto 0);
        c3_p4_cmd_empty      : out std_logic;
        c3_p4_cmd_full       : out std_logic;
        c3_p4_wr_clk         : in std_logic;
        c3_p4_wr_en          : in std_logic;
        c3_p4_wr_mask        : in std_logic_vector(3 downto 0);
        c3_p4_wr_data        : in std_logic_vector(31 downto 0);
        c3_p4_wr_full        : out std_logic;
        c3_p4_wr_empty       : out std_logic;
        c3_p4_wr_count       : out std_logic_vector(6 downto 0);
        c3_p4_wr_underrun    : out std_logic;
        c3_p4_wr_error       : out std_logic;
        
        c3_p5_cmd_clk        : in std_logic;
        c3_p5_cmd_en         : in std_logic;
        c3_p5_cmd_instr      : in std_logic_vector(2 downto 0);
        c3_p5_cmd_bl         : in std_logic_vector(5 downto 0);
        c3_p5_cmd_byte_addr  : in std_logic_vector(29 downto 0);
        c3_p5_cmd_empty      : out std_logic;
        c3_p5_cmd_full       : out std_logic;
        c3_p5_rd_clk         : in std_logic;
        c3_p5_rd_en          : in std_logic;
        c3_p5_rd_data        : out std_logic_vector(31 downto 0);
        c3_p5_rd_full        : out std_logic;
        c3_p5_rd_empty       : out std_logic;
        c3_p5_rd_count       : out std_logic_vector(6 downto 0);
        c3_p5_rd_overflow    : out std_logic;
        c3_p5_rd_error       : out std_logic
);
end component;

signal CLK : std_logic;
signal RESET0 : std_logic;	-- released after dcm0 is ready
signal RESET : std_logic;	-- released after MCB is ready

signal DCM0_LOCKED : std_logic;
signal DCM0_CLK_VALID : std_logic;

----------------------------
-- test pattern generator --
----------------------------
signal GEN_CNT : std_logic_vector(29 downto 0);
signal GEN_PATTERN : std_logic_vector(29 downto 0);

signal FIFO_WORD : std_logic;

-----------------------
-- memory controller --
-----------------------
signal MEM_CLK : std_logic;
signal C3_CALIB_DONE : std_logic;
signal C3_RST0 : std_logic;

---------------
-- DRAM FIFO --
---------------
signal WR_CLK       : std_logic;
signal WR_CMD_EN    : std_logic_vector(2 downto 0);
type WR_CMD_ADDR_ARRAY is array(2 downto 0) of std_logic_vector(29 downto 0);
signal WR_CMD_ADDR  : WR_CMD_ADDR_ARRAY;
signal WR_ADDR      : std_logic_vector(17 downto 0);   -- in 256 bytes burst blocks
signal WR_EN        : std_logic_vector(2 downto 0);
signal WR_EN_TMP    : std_logic_vector(2 downto 0);
signal WR_DATA      : std_logic_vector(31 downto 0);
signal WR_EMPTY     : std_logic_vector(2 downto 0);
signal WR_UNDERRUN  : std_logic_vector(2 downto 0);
signal WR_ERROR     : std_logic_vector(2 downto 0);
type WR_COUNT_ARRAY is array(2 downto 0) of std_logic_vector(6 downto 0);
signal WR_COUNT     : WR_COUNT_ARRAY;
signal WR_PORT      : std_logic_vector(1 downto 0);

signal RD_CLK       : std_logic;
signal RD_CMD_EN    : std_logic_vector(2 downto 0);
type RD_CMD_ADDR_ARRAY is array(2 downto 0) of std_logic_vector(29 downto 0);
signal RD_CMD_ADDR  : WR_CMD_ADDR_ARRAY;
signal RD_ADDR      : std_logic_vector(17 downto 0); -- in 256 bytes burst blocks
signal RD_EN        : std_logic_vector(2 downto 0);
type RD_DATA_ARRAY is array(2 downto 0) of std_logic_vector(31 downto 0);
signal RD_DATA      : RD_DATA_ARRAY;
signal RD_EMPTY     : std_logic_vector(2 downto 0);
signal RD_OVERFLOW  : std_logic_vector(2 downto 0);
signal RD_ERROR     : std_logic_vector(2 downto 0);
signal RD_PORT      : std_logic_vector(1 downto 0);
type RD_COUNT_ARRAY is array(2 downto 0) of std_logic_vector(6 downto 0);
signal RD_COUNT     : RD_COUNT_ARRAY;

signal FD_TMP        : std_logic_vector(15 downto 0);

signal RD_ADDR2	     : std_logic_vector(17 downto 0);   -- 256 bytes burst block currently beeing read
signal RD_ADDR2_BAK1 : std_logic_vector(17 downto 0);   -- backup for synchronization
signal RD_ADDR2_BAK2 : std_logic_vector(17 downto 0);   -- backup for synchronization
signal WR_ADDR2	     : std_logic_vector(17 downto 0);   -- 256 bytes burst block currently beeing written
signal WR_ADDR2_BAK1 : std_logic_vector(17 downto 0);   -- backup for synchronization
signal WR_ADDR2_BAK2 : std_logic_vector(17 downto 0);   -- backup for synchronization

signal RD_STOP       : std_logic;

begin

    inst_dcm0 : dcm0 port map(
	-- Clock in ports
	CLK_IN1            => FXCLK,
	-- Clock out ports
	CLK_OUT1           => MEM_CLK,
	CLK_OUT2           => CLK,
	-- Status and control signals
	RESET              => RESET_IN,
        LOCKED             => DCM0_LOCKED,
        CLK_VALID          => DCM0_CLK_VALID
    );

    inst_mem0 : mem0 port map (
	mcb3_dram_dq    =>  mcb3_dram_dq,  
	mcb3_dram_a     =>  mcb3_dram_a,  
	mcb3_dram_ba    =>  mcb3_dram_ba,
        mcb3_dram_ras_n =>  mcb3_dram_ras_n,                        
        mcb3_dram_cas_n =>  mcb3_dram_cas_n,                        
        mcb3_dram_we_n  =>  mcb3_dram_we_n,                          
        mcb3_dram_cke   =>  mcb3_dram_cke,                          
        mcb3_dram_ck    =>  mcb3_dram_ck,                          
        mcb3_dram_ck_n  =>  mcb3_dram_ck_n,       
        mcb3_dram_dqs   =>  mcb3_dram_dqs,                          
        mcb3_dram_udqs  =>  mcb3_dram_udqs,    -- for X16 parts           
	mcb3_dram_udm   =>  mcb3_dram_udm,     -- for X16 parts
        mcb3_dram_dm    =>  mcb3_dram_dm,
	mcb3_rzq        =>  mcb3_rzq,
        
	c3_sys_clk      =>  MEM_CLK,
	c3_sys_rst_n    =>  RESET0,

        c3_clk0	        =>  open,
        c3_rst0		=>  C3_RST0,
        c3_calib_done   =>  C3_CALIB_DONE,
  
        c3_p0_cmd_clk        =>  WR_CLK,
        c3_p0_cmd_en         =>  WR_CMD_EN(0),
        c3_p0_cmd_instr      =>  "000",
        c3_p0_cmd_bl         =>  ( others => '1' ),
        c3_p0_cmd_byte_addr  =>  WR_CMD_ADDR(0),
        c3_p0_cmd_empty      =>  open,
        c3_p0_cmd_full       =>  open,
        c3_p0_wr_clk         =>  WR_CLK,
        c3_p0_wr_en          =>  WR_EN(0),
        c3_p0_wr_mask        =>  ( others => '0' ),
        c3_p0_wr_data        =>  WR_DATA,
        c3_p0_wr_full        =>  open,
        c3_p0_wr_empty       =>  WR_EMPTY(0),
        c3_p0_wr_count       =>  open,
        c3_p0_wr_underrun    =>  WR_UNDERRUN(0),
        c3_p0_wr_error       =>  WR_ERROR(0),
        c3_p0_rd_clk         =>  WR_CLK,
        c3_p0_rd_en          =>  '0',
        c3_p0_rd_data        =>  open,
        c3_p0_rd_full        =>  open,
        c3_p0_rd_empty       =>  open,
        c3_p0_rd_count       =>  open,
        c3_p0_rd_overflow    =>  open,
        c3_p0_rd_error       =>  open,

        c3_p2_cmd_clk        =>  WR_CLK,
        c3_p2_cmd_en         =>  WR_CMD_EN(1),
        c3_p2_cmd_instr      =>  "000",
        c3_p2_cmd_bl         =>  ( others => '1' ),
        c3_p2_cmd_byte_addr  =>  WR_CMD_ADDR(1),
        c3_p2_cmd_empty      =>  open,
        c3_p2_cmd_full       =>  open,
        c3_p2_wr_clk         =>  WR_CLK,
        c3_p2_wr_en          =>  WR_EN(1),
        c3_p2_wr_mask        =>  ( others => '0' ),
        c3_p2_wr_data        =>  WR_DATA,
        c3_p2_wr_full        =>  open,
        c3_p2_wr_empty       =>  WR_EMPTY(1),
        c3_p2_wr_count       =>  open,
        c3_p2_wr_underrun    =>  WR_UNDERRUN(1),
        c3_p2_wr_error       =>  WR_ERROR(1),

        c3_p4_cmd_clk        =>  WR_CLK,
        c3_p4_cmd_en         =>  WR_CMD_EN(2),
        c3_p4_cmd_instr      =>  "000",
        c3_p4_cmd_bl         =>  ( others => '1' ),
        c3_p4_cmd_byte_addr  =>  WR_CMD_ADDR(2),
        c3_p4_cmd_empty      =>  open,
        c3_p4_cmd_full       =>  open,
        c3_p4_wr_clk         =>  WR_CLK,
        c3_p4_wr_en          =>  WR_EN(2),
        c3_p4_wr_mask        =>  ( others => '0' ),
        c3_p4_wr_data        =>  WR_DATA,
        c3_p4_wr_full        =>  open,
        c3_p4_wr_empty       =>  WR_EMPTY(2),
        c3_p4_wr_count       =>  open,
        c3_p4_wr_underrun    =>  WR_UNDERRUN(2),
        c3_p4_wr_error       =>  WR_ERROR(2),
        
        c3_p1_cmd_clk        =>  RD_CLK,
        c3_p1_cmd_en         =>  RD_CMD_EN(0),
        c3_p1_cmd_instr      =>  "001",
        c3_p1_cmd_bl         =>  ( others => '1' ),
        c3_p1_cmd_byte_addr  =>  RD_CMD_ADDR(0),
        c3_p1_cmd_empty      =>  open,
        c3_p1_cmd_full       =>  open,
        c3_p1_wr_clk         =>  RD_CLK,
        c3_p1_wr_en          =>  '0',
        c3_p1_wr_mask        =>  ( others => '0' ),
        c3_p1_wr_data        =>  ( others => '0' ),
        c3_p1_wr_full        =>  open,
        c3_p1_wr_empty       =>  open,
        c3_p1_wr_count       =>  open,
        c3_p1_wr_underrun    =>  open,
        c3_p1_wr_error       =>  open,
        c3_p1_rd_clk         =>  RD_CLK,
        c3_p1_rd_en          =>  RD_EN(0),
        c3_p1_rd_data        =>  RD_DATA(0),
        c3_p1_rd_full        =>  open,
        c3_p1_rd_empty       =>  RD_EMPTY(0),
        c3_p1_rd_count       =>  open,
        c3_p1_rd_overflow    =>  RD_OVERFLOW(0),
        c3_p1_rd_error       =>  RD_ERROR(0),

        c3_p3_cmd_clk        =>  RD_CLK,
        c3_p3_cmd_en         =>  RD_CMD_EN(1),
        c3_p3_cmd_instr      =>  "001",
        c3_p3_cmd_bl         =>  ( others => '1' ),
        c3_p3_cmd_byte_addr  =>  RD_CMD_ADDR(1),
        c3_p3_cmd_empty      =>  open,
        c3_p3_cmd_full       =>  open,
        c3_p3_rd_clk         =>  RD_CLK,
        c3_p3_rd_en          =>  RD_EN(1),
        c3_p3_rd_data        =>  RD_DATA(1),
        c3_p3_rd_full        =>  open,
        c3_p3_rd_empty       =>  RD_EMPTY(1),
        c3_p3_rd_count       =>  open,
        c3_p3_rd_overflow    =>  RD_OVERFLOW(1),
        c3_p3_rd_error       =>  RD_ERROR(1),

        c3_p5_cmd_clk        =>  RD_CLK,
        c3_p5_cmd_en         =>  RD_CMD_EN(2),
        c3_p5_cmd_instr      =>  "001",
        c3_p5_cmd_bl         =>  ( others => '1' ),
        c3_p5_cmd_byte_addr  =>  RD_CMD_ADDR(2),
        c3_p5_cmd_empty      =>  open,
        c3_p5_cmd_full       =>  open,
        c3_p5_rd_clk         =>  RD_CLK,
        c3_p5_rd_en          =>  RD_EN(2),
        c3_p5_rd_data        =>  RD_DATA(2),
        c3_p5_rd_full        =>  open,
        c3_p5_rd_empty       =>  RD_EMPTY(2),
        c3_p5_rd_count       =>  open,
        c3_p5_rd_overflow    =>  RD_OVERFLOW(2),
        c3_p5_rd_error       =>  RD_ERROR(2)
);
    
    SLOE <= '1';
    SLRD <= '1';
    FIFOADR0 <= '0';
    FIFOADR1 <= '0';
    PKTEND <= '1';
    
    WR_CLK <= CLK;
    RD_CLK <= IFCLK;
    
    RESET0 <= RESET_IN or (not DCM0_LOCKED) or (not DCM0_CLK_VALID);
    RESET <= RESET0 or (not C3_CALIB_DONE) or C3_RST0;
    
    PC(0) <= WR_UNDERRUN(0) or WR_UNDERRUN(1) or WR_UNDERRUN(2);
    PC(1) <= WR_ERROR(0) or WR_ERROR(1) or WR_ERROR(2);
    PC(2) <= RD_OVERFLOW(0) or RD_OVERFLOW(1) or RD_OVERFLOW(2);
    PC(3) <= RD_ERROR(0) or RD_ERROR(1) or RD_ERROR(2);
    PC(4) <= C3_CALIB_DONE;
    PC(5) <= C3_RST0;
    PC(6) <= RESET0;
    PC(7) <= RESET;

    dpCLK: process (CLK, RESET)
    begin
-- reset
        if RESET = '1' 
	then
	    GEN_CNT <= ( others => '0' );
	    GEN_PATTERN <= "100101010101010101010101010101";

	    WR_CMD_EN      <= ( others => '0' );
	    WR_CMD_ADDR(0) <= ( others => '0' );
	    WR_CMD_ADDR(1) <= ( others => '0' );
	    WR_CMD_ADDR(2) <= ( others => '0' );
	    WR_ADDR        <= conv_std_logic_vector(3,18);
	    WR_EN          <= ( others => '0' );
	    WR_COUNT(0)    <= ( others => '0' );
	    WR_COUNT(1)    <= ( others => '0' );
	    WR_COUNT(2)    <= ( others => '0' );
	    WR_PORT        <= ( others => '0' );
	    
	    WR_ADDR2       <= ( others => '0' );
	    RD_ADDR2_BAK1  <= ( others => '0' );
	    RD_ADDR2_BAK2  <= ( others => '0' );
	    
-- CLK
        elsif CLK'event and CLK = '1' 
	then
	    WR_CMD_EN <= ( others => '0' );
	    WR_EN <= ( others => '0' );
	    WR_CMD_ADDR(conv_integer(WR_PORT))(25 downto 8) <= WR_ADDR;
	    
	    if ( WR_COUNT(conv_integer(WR_PORT)) = conv_std_logic_vector(64,7) )
		then
		-- FF flag = 1
		if ( RD_ADDR2_BAK1 = RD_ADDR2_BAK2 ) and ( RD_ADDR2_BAK2 /= WR_ADDR )
		then
		    WR_CMD_EN(conv_integer(WR_PORT)) <= '1';
		    WR_COUNT(conv_integer(WR_PORT)) <= ( others => '0' );
	    	    if WR_PORT = "10"
	    	    then
	    		WR_PORT <= "00";
	    	    else
	    		WR_PORT <= WR_PORT + 1;
	    	    end if;
	    	    WR_ADDR <= WR_ADDR + 1;
	    	    WR_ADDR2 <= WR_ADDR2 + 1;
	    	end if;
	    elsif ( WR_COUNT(conv_integer(WR_PORT)) = conv_std_logic_vector(0,7)) and (WR_EMPTY(conv_integer(WR_PORT)) = '0' )  -- write port fifo not empty 
	    then
		-- FF flag = 1 
	    else
		WR_EN(conv_integer(WR_PORT)) <= '1';
    		WR_DATA(31) <= '1';
                WR_DATA(15) <= '0';
		if PA3 = '1'
		then
		    WR_DATA(30 downto 16) <= GEN_PATTERN(29 downto 15);
		    WR_DATA(14 downto 0) <= GEN_PATTERN(14 downto 0);
		else
		    WR_DATA(30 downto 16) <= GEN_CNT(29 downto 15);
		    WR_DATA(14 downto 0) <= GEN_CNT(14 downto 0);
		end if;    
		GEN_CNT <= GEN_CNT + 1;
		GEN_PATTERN(29) <= GEN_PATTERN(0);
		GEN_PATTERN(28 downto 0) <= GEN_PATTERN(29 downto 1);
--		if ( WR_COUNT(conv_integer(WR_PORT)) = conv_std_logic_vector(63,7) ) and ( RD_ADDR2_BAK1 = RD_ADDR2_BAK2 ) and ( RD_ADDR2_BAK2 /= WR_ADDR )
--		  Add code from above here. This saves one clock cylcle and is required for uninterrupred input.
--		then
--		else
		    WR_COUNT(conv_integer(WR_PORT)) <= WR_COUNT(conv_integer(WR_PORT)) + 1;
--		end if;
	    end if;
	    
	    RD_ADDR2_BAK1 <= RD_ADDR2;
	    RD_ADDR2_BAK2 <= RD_ADDR2_BAK1;

	end if;
    end process dpCLK;


    dpIFCLK: process (IFCLK, RESET)
    begin
-- reset
        if RESET = '1' 
	then
	    FIFO_WORD <= '0';
	    SLWR <= '1';

	    RD_CMD_EN      <= ( others => '0' );
	    RD_CMD_ADDR(0) <= ( others => '0' );
	    RD_CMD_ADDR(1) <= ( others => '0' );
	    RD_CMD_ADDR(2) <= ( others => '0' );
	    RD_ADDR        <= conv_std_logic_vector(3,18);
	    RD_EN          <= ( others => '0' );
	    RD_COUNT(0)    <= conv_std_logic_vector(64,7);
	    RD_COUNT(1)    <= conv_std_logic_vector(64,7);
	    RD_COUNT(2)    <= conv_std_logic_vector(64,7);
	    RD_PORT        <= ( others => '0' );
	    
	    RD_ADDR2       <= ( others => '0' );
	    WR_ADDR2_BAK1  <= ( others => '0' );
	    WR_ADDR2_BAK2  <= ( others => '0' );
	    
	    RD_STOP        <= '1';
	    
-- IFCLK
        elsif IFCLK'event and IFCLK = '1' 
	then
	    
	    RD_CMD_EN <= ( others => '0' );
	    RD_CMD_ADDR(conv_integer(RD_PORT))(25 downto 8) <= RD_ADDR;
	    RD_EN(conv_integer(RD_PORT)) <= '0';
	
  	    if FLAGB = '1'
  	    then
		if ( RD_EMPTY(conv_integer(RD_PORT)) = '1' ) or ( RD_COUNT(conv_integer(RD_PORT)) = conv_std_logic_vector(64,7) )
		then
	    	    SLWR <= '1';
	            if ( RD_COUNT(conv_integer(RD_PORT)) = conv_std_logic_vector(64,7) ) and ( RD_EMPTY(conv_integer(RD_PORT)) = '1' ) and ( WR_ADDR2_BAK2 = WR_ADDR2_BAK1 ) and ( WR_ADDR2_BAK2 /= RD_ADDR ) and ( RD_STOP = '0' )
	    	    then
	    		RD_CMD_EN(conv_integer(RD_PORT)) <= '1';
			RD_COUNT(conv_integer(RD_PORT)) <= ( others => '0' );
	    		if RD_PORT = "10"
	    		then
	    		    RD_PORT <= "00";
	    		else
	    		    RD_PORT <= RD_PORT + 1;
	    		end if;
	    		RD_ADDR <= RD_ADDR + 1;
	    		RD_ADDR2 <= RD_ADDR2 + 1;
	    	    end if;
		else
	    	    SLWR <= '0';
	       	    if FIFO_WORD = '0'
		    then
		        FD(15 downto 0) <= RD_DATA(conv_integer(RD_PORT))(15 downto 0);
		        FD_TMP <= RD_DATA(conv_integer(RD_PORT))(31 downto 16);
		        RD_EN(conv_integer(RD_PORT)) <= '1';
		    else
		        FD(15 downto 0) <= FD_TMP;
		    	RD_COUNT(conv_integer(RD_PORT)) <= RD_COUNT(conv_integer(RD_PORT)) + 1;
		    end if;
		    FIFO_WORD <= not FIFO_WORD;
		end if;
	    end if;

	    WR_ADDR2_BAK1 <= WR_ADDR2;
	    WR_ADDR2_BAK2 <= WR_ADDR2_BAK1;
	    
	    if ( WR_ADDR2_BAK1 = WR_ADDR2_BAK2 ) and ( WR_ADDR2_BAK2(3) = '1')
	    then
		RD_STOP <= '0';
	    end if;		

	end if;
    end process dpIFCLK;

end RTL;
