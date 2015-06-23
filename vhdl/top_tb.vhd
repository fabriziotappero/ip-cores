library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity top is
	generic (
		constant DATA_SIZE_PIF : integer := 32;  -- this value specifies the data bus PIF parallelism
		constant DATA_SIZE_WB  : integer := 32;  -- this value specifies the data bus Wishbone parallelism    
		constant ADRS_SIZE     : integer := 32;  -- this value specifies the address bus length
		constant CNTL_PIF      : integer := 8;   -- The PIF CNTL vector size
		constant MSB_PIF       : integer := 31;  -- The PIF most significant bit
		constant LSB_PIF       : integer := 0;   -- The PIF least significant bit 
		constant MSB_WB        : integer := 31;  -- The Wishbone most significant bit
		constant LSB_WB        : integer := 0;   -- The Wishbone least significant bit
		constant ADRS_BITS	   : integer := 4;
		constant ADRS_RANGE    : integer := 8
		);
	port (
		SCLK 	 		: in	STD_LOGIC;
		CLKETH		: in  STD_LOGIC;
		SReset 		: in	STD_LOGIC;
		
		PIReqVALID  : in  std_logic; 
		PIReqCNTL   : in  std_logic_vector(CNTL_PIF-1 downto 0);
		PIReqADRS   : in  std_logic_vector(ADRS_SIZE-1 downto 0);
		PIReqDATA   : in  std_logic_vector(DATA_SIZE_PIF-1 downto 0);
		PIReqDataBE : in  std_logic_vector(DATA_SIZE_PIF/8-1 downto 0);
		PIRespRDY   : in  std_logic;
		
      probe_mtxd_pad_o 	 : out std_logic_vector (3 downto 0);
      probe_mtxen_pad_o  : out std_logic;
      mtxerr_pad_o	    : out std_logic;

      probe_mrxd_pad_i	 : in std_logic_vector (3 downto 0);
      probe_mrxdv_pad_i  : in std_logic;
      probe_mrxerr_pad_i : in std_logic;
      probe_mcoll_pad_i  : in std_logic;
      probe_mcrs_pad_i   : in std_logic;

      probe_mdc_pad_o	 : out std_logic;
      probe_md_pad_i	    : in std_logic;
      probe_md_pad_o	    : out std_logic;
      probe_md_padoe_o	 : out std_logic;
      interrupt		    : out std_logic
	);
end top;

architecture Structural of top is
     
     -- Pif signals
     signal PIRespValid_t : std_logic ; 
     signal PIRespCntl_t : std_logic_vector (7 DOWNTO 0); 
     signal PIRespData_t : std_logic_vector (31 DOWNTO 0); 
     signal PIRespPriority_t : std_logic_vector (1 DOWNTO 0); 
     signal PIRespId_t : std_logic_vector (5 DOWNTO 0); 
     signal PIReqRdy_t : std_logic ;

     -- Wishbone signals
     signal		data_i : std_logic_vector (31 downto 0);
     signal 	data_o : std_logic_vector (31 downto 0);
     signal 	addr : std_logic_vector (31 downto 0);
     signal 	sel : std_logic_vector (3 downto 0);
     signal 	we : std_logic;
     signal 	cyc : std_logic;
     signal 	stb : std_logic;
     signal 	ack : std_logic;
     signal 	err : std_logic;
	  signal    cti : std_logic_vector (2 downto 0);
	  signal    bte : std_logic_vector (1 downto 0);
	  signal 	m_addr : std_logic_vector (31 downto 0);
     signal 	m_sel : std_logic_vector (3 downto 0);
     signal 	m_we : std_logic;
     signal 	m_data_o : std_logic_vector (31 downto 0);
     signal 	m_data_i : std_logic_vector (31 downto 0);
     signal 	m_cyc : std_logic;
     signal 	m_stb : std_logic;
     signal 	m_ack : std_logic;
     signal    m_err : std_logic;

   COMPONENT PIF2WB
		generic (
		constant DATA_SIZE_PIF : integer := 32;  -- this value specifies the data bus PIF parallelism
		constant DATA_SIZE_WB  : integer := 32;  -- this value specifies the data bus Wishbone parallelism    
		constant ADRS_SIZE     : integer := 32;  -- this value specifies the address bus length
		constant CNTL_PIF      : integer := 8;   -- The PIF CNTL vector size
		constant MSB_PIF       : integer := 31;  -- The PIF most significant bit
		constant LSB_PIF       : integer := 0;   -- The PIF least significant bit 
		constant MSB_WB        : integer := 31;  -- The Wishbone most significant bit
		constant LSB_WB        : integer := 0;   -- The Wishbone least significant bit
		constant ADRS_BITS	   : integer := 4;
		constant ADRS_RANGE    : integer := 8
		);

		port (
		CLK     : in std_logic;
		RST     : in std_logic; 

		PIReqVALID  : in  std_logic; 
		PIReqCNTL   : in  std_logic_vector(CNTL_PIF-1 downto 0);
		PIReqADRS   : in  std_logic_vector(ADRS_SIZE-1 downto 0);
		PIReqDATA   : in  std_logic_vector(DATA_SIZE_PIF-1 downto 0);
		PIReqDataBE : in  std_logic_vector(DATA_SIZE_PIF/8-1 downto 0);
		POReqRDY    : out std_logic;
		PORespVALID : out std_logic;
		PORespCNTL  : out std_logic_vector(CNTL_PIF-1 downto 0);
		PORespDATA  : out std_logic_vector(DATA_SIZE_PIF-1 downto 0);
		PIRespRDY   : in  std_logic;

		ACK_I : in  std_logic;              -- The acknowledge input
		DAT_I : in  std_logic_vector(DATA_SIZE_WB-1 downto 0);
		ERR_I : in  std_logic;              -- Incates address or data error in transaction
		ADR_O : out std_logic_vector(ADRS_SIZE-1 downto 0);
		DAT_O : out std_logic_vector(DATA_SIZE_WB-1 downto 0);
		CYC_O : out std_logic;              -- The cycle output
		SEL_O : out std_logic_vector(DATA_SIZE_WB/8-1 downto 0);
		STB_O : out std_logic;              -- The strobe output
		WE_O  : out std_logic;              -- The write enable output
		BTE_O : out std_logic_vector(1 downto 0);
		CTI_O : out std_logic_vector(2 downto 0) 
		);
	END COMPONENT;
	
	COMPONENT eth_top
    port(
      --WISHBONE common
      wb_clk_i      : in  std_logic;
      wb_rst_i      : in  std_logic;
      wb_dat_i      : in  std_logic_vector(31 downto 0);
      wb_dat_o      : out std_logic_vector(31 downto 0);
      --WISHBONE slave
      wb_adr_i      : in  std_logic_vector(11 downto 2);
      wb_sel_i      : in  std_logic_vector(3 downto 0);
      wb_we_i       : in  std_logic;
      wb_cyc_i      : in  std_logic;
      wb_stb_i      : in  std_logic;
      wb_ack_o      : out std_logic;
      wb_err_o      : out std_logic;
      --WISHBONE master
      m_wb_adr_o    : out std_logic_vector(31 downto 0);
      m_wb_sel_o    : out std_logic_vector(3 downto 0);
      m_wb_we_o     : out std_logic;
      m_wb_dat_o    : out std_logic_vector(31 downto 0);
      m_wb_dat_i    : in  std_logic_vector(31 downto 0);
      m_wb_cyc_o    : out std_logic;
      m_wb_stb_o    : out std_logic;
      m_wb_ack_i    : in  std_logic;
      m_wb_err_i    : in  std_logic;
      --TX
      mtx_clk_pad_i : in  std_logic;
      mtxd_pad_o    : out std_logic_vector(3 downto 0);
      mtxen_pad_o   : out std_logic;
      mtxerr_pad_o  : out std_logic;
      --RX
      mrx_clk_pad_i : in  std_logic;
      mrxd_pad_i    : in  std_logic_vector(3 downto 0);
      mrxdv_pad_i   : in  std_logic;
      mrxerr_pad_i  : in  std_logic;
      mcoll_pad_i   : in  std_logic;
      mcrs_pad_i    : in  std_logic;
      --MIIM
      mdc_pad_o     : out std_logic;
      md_pad_i      : in  std_logic;
      md_pad_o      : out std_logic;
      md_padoe_o    : out std_logic;
      int_o         : out std_logic
      );
  end COMPONENT;

begin

	pif2wsb:PIF2WB
    port map(
		CLK     => SCLK,
    	RST     => SReset,
		
    	PIReqVALID  => PIReqVALID,
    	PIReqCNTL   => PIReqCNTL,
    	PIReqADRS   => PIReqADRS,
    	PIReqDATA   => PIReqDATA,
    	PIReqDataBE => PIReqDataBE,
    	POReqRDY    => PIReqRDY_t,
    	PORespVALID => PIRespVALID_t,
    	PORespCNTL  => PIRespCNTL_t,
    	PORespDATA  => PIRespDATA_t,
    	PIRespRDY   => PIRespRDY,
  
    	ACK_I => ack,
    	DAT_I => data_i,
    	ERR_I => err,
    	ADR_O => addr,
    	DAT_O => data_o,
    	CYC_O => cyc,
    	SEL_O => sel,
    	STB_O => stb,
    	WE_O  => we,
    	BTE_O => bte,
    	CTI_O => cti
		);

	eth0 : eth_top
    port map(
      --WISHBONE common
      wb_clk_i      => SCLK,
      wb_rst_i      => SReset,
      wb_dat_i      => data_o,
      wb_dat_o      => data_i,
      --WISHBONE slave
      wb_adr_i      => addr (9 downto 0),
      wb_sel_i      => sel,
      wb_we_i       => we,
      wb_cyc_i      => cyc,
      wb_stb_i      => stb,
      wb_ack_o      => ack,
      wb_err_o      => err,
      --WISHBONE master
      m_wb_adr_o    => m_addr,
      m_wb_sel_o    => m_sel,
      m_wb_we_o     => m_we,
      m_wb_dat_o    => m_data_o,
      m_wb_dat_i    => m_data_i,
      m_wb_cyc_o    => m_cyc,
      m_wb_stb_o    => m_stb,
      m_wb_ack_i    => m_ack,
      m_wb_err_i    => m_err,
      --TX
      mtx_clk_pad_i => CLKETH,
      mtxd_pad_o    => probe_mtxd_pad_o,
      mtxen_pad_o   => probe_mtxen_pad_o,
      mtxerr_pad_o  => mtxerr_pad_o,
      --RX
      mrx_clk_pad_i => CLKETH,
      mrxd_pad_i    => probe_mrxd_pad_i,
      mrxdv_pad_i   => probe_mrxdv_pad_i,
      mrxerr_pad_i  => probe_mrxerr_pad_i,
      mcoll_pad_i   => probe_mcoll_pad_i,
      mcrs_pad_i    => probe_mcrs_pad_i,
      --MIIM
      mdc_pad_o     => probe_mdc_pad_o,
      md_pad_i      => probe_md_pad_i,
      md_pad_o      => probe_md_pad_o,
      md_padoe_o    => probe_md_padoe_o,
      int_o         => interrupt
      );

end Structural;

