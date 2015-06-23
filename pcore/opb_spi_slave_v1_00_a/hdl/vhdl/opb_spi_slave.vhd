-------------------------------------------------------------------------------
-------------------------------------------------------
--! @file
--! @brief 2:1 Mux using with-select
-------------------------------------------------------

--* 
--* @short Top entity of the project opi_spi_slave
--* 
--* @generic C_FAMILY virtex-4 and generic supported
--*    @author: Daniel Köthe
--*   @version: 1.1
--* @date: 2007-11-19
--/
-- Version 1.1
-- Bugfix
-- IRQ-Flag RX_Overflow shows prog_empty insteed rx_overflow
-- opb_irq_flg(5) <= opb_fifo_flg(9); to opb_irq_flg(5) <= opb_fifo_flg(8); 

-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.opb_spi_slave_pack.all;


entity opb_spi_slave is

  generic (
    C_BASEADDR     : std_logic_vector(0 to 31) := X"00000000";
    C_HIGHADDR     : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_USER_ID_CODE : integer                   := 0;
    C_OPB_AWIDTH   : integer                   := 32;
    C_OPB_DWIDTH   : integer                   := 32;

    C_FAMILY          : string               := "virtex4";
    -- user ports
    C_SR_WIDTH        : integer              := 8;
    C_MSB_FIRST       : boolean              := true;
    C_CPOL            : integer range 0 to 1 := 0;
    C_PHA             : integer range 0 to 1 := 0;
    C_FIFO_SIZE_WIDTH : integer range 4 to 7 := 5;  -- depth 32
    C_DMA_EN          : boolean              := false;
    C_CRC_EN          : boolean              := false);

  port (
    -- OPB signals (Slave Side)
    OPB_ABus    : in  std_logic_vector(0 to C_OPB_AWIDTH-1);
    OPB_BE      : in  std_logic_vector(0 to C_OPB_DWIDTH/8-1);
    OPB_Clk     : in  std_logic;
    OPB_DBus    : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
    OPB_RNW     : in  std_logic;
    OPB_Rst     : in  std_logic;
    OPB_select  : in  std_logic;
    OPB_seqAddr : in  std_logic;
    Sln_DBus    : out std_logic_vector(0 to C_OPB_DWIDTH-1);
    Sln_errAck  : out std_logic;
    Sln_retry   : out std_logic;
    Sln_toutSup : out std_logic;
    Sln_xferAck : out std_logic;

    -- OPB signals (Master Side)
    -- Arbitration
    M_request    : out std_logic;
    MOPB_MGrant  : in  std_logic;
    M_busLock    : out std_logic;
    -- 
    M_ABus       : out std_logic_vector(0 to C_OPB_AWIDTH-1);
    M_BE         : out std_logic_vector(0 to C_OPB_DWIDTH/8-1);
    M_DBus       : out std_logic_vector(0 to C_OPB_DWIDTH-1);
    M_RNW        : out std_logic;
    M_select     : out std_logic;
    M_seqAddr    : out std_logic;
    MOPB_errAck  : in  std_logic;
    MOPB_retry   : in  std_logic;
    MOPB_timeout : in  std_logic;
    MOPB_xferAck : in  std_logic;
    -- spi ports
    sclk         : in  std_logic;
    ss_n         : in  std_logic;
    mosi         : in  std_logic;
    miso_o       : out std_logic;
    miso_i       : in  std_logic;
    miso_t       : out std_logic;
    -- irq output
    opb_irq      : out std_logic);

end opb_spi_slave;

architecture behavior of opb_spi_slave is

  component opb_if
    generic (
      C_BASEADDR        : std_logic_vector(0 to 31);
      C_HIGHADDR        : std_logic_vector(0 to 31);
      C_USER_ID_CODE    : integer;
      C_OPB_AWIDTH      : integer;
      C_OPB_DWIDTH      : integer;
      C_FAMILY          : string;
      C_SR_WIDTH        : integer;
      C_FIFO_SIZE_WIDTH : integer;
      C_DMA_EN          : boolean;
      C_CRC_EN          : boolean);
    port (
      OPB_ABus         : in  std_logic_vector(0 to C_OPB_AWIDTH-1);
      OPB_BE           : in  std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      OPB_Clk          : in  std_logic;
      OPB_DBus         : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
      OPB_RNW          : in  std_logic;
      OPB_Rst          : in  std_logic;
      OPB_select       : in  std_logic;
      OPB_seqAddr      : in  std_logic;
      Sln_DBus         : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      Sln_errAck       : out std_logic;
      Sln_retry        : out std_logic;
      Sln_toutSup      : out std_logic;
      Sln_xferAck      : out std_logic;
      opb_s_tx_en      : out std_logic;
      opb_s_tx_data    : out std_logic_vector(C_SR_WIDTH-1 downto 0);
      opb_s_rx_en      : out std_logic;
      opb_s_rx_data    : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      opb_ctl_reg      : out std_logic_vector(C_OPB_CTL_REG_WIDTH-1 downto 0);
      tx_thresh        : out std_logic_vector((2*C_FIFO_SIZE_WIDTH)-1 downto 0);
      rx_thresh        : out std_logic_vector((2*C_FIFO_SIZE_WIDTH)-1 downto 0);
      opb_fifo_flg     : in  std_logic_vector(C_NUM_FLG-1 downto 0);
      opb_dgie         : out std_logic;
      opb_ier          : out std_logic_vector(C_NUM_INT-1 downto 0);
      opb_isr          : in  std_logic_vector(C_NUM_INT-1 downto 0);
      opb_isr_clr      : out std_logic_vector(C_NUM_INT-1 downto 0);
      opb_tx_dma_addr  : out std_logic_vector(C_OPB_DWIDTH-1 downto 0);
      opb_tx_dma_ctl   : out std_logic_vector(0 downto 0);
      opb_tx_dma_num   : out std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
      opb_rx_dma_addr  : out std_logic_vector(C_OPB_DWIDTH-1 downto 0);
      opb_rx_dma_ctl   : out std_logic_vector(0 downto 0);
      opb_rx_dma_num   : out std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
      opb_rx_crc_value : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      opb_tx_crc_value : in  std_logic_vector(C_SR_WIDTH-1 downto 0));

  end component;


  component opb_m_if
    generic (
      C_BASEADDR        : std_logic_vector(0 to 31);
      C_HIGHADDR        : std_logic_vector(0 to 31);
      C_USER_ID_CODE    : integer;
      C_OPB_AWIDTH      : integer;
      C_OPB_DWIDTH      : integer;
      C_FAMILY          : string;
      C_SR_WIDTH        : integer;
      C_MSB_FIRST       : boolean;
      C_CPOL            : integer range 0 to 1;
      C_PHA             : integer range 0 to 1;
      C_FIFO_SIZE_WIDTH : integer range 4 to 7);
    port (
      OPB_Clk          : in  std_logic;
      OPB_Rst          : in  std_logic;
      OPB_DBus         : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
      M_request        : out std_logic;
      MOPB_MGrant      : in  std_logic;
      M_busLock        : out std_logic;
      M_ABus           : out std_logic_vector(0 to C_OPB_AWIDTH-1);
      M_BE             : out std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      M_DBus           : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      M_RNW            : out std_logic;
      M_select         : out std_logic;
      M_seqAddr        : out std_logic;
      MOPB_errAck      : in  std_logic;
      MOPB_retry       : in  std_logic;
      MOPB_timeout     : in  std_logic;
      MOPB_xferAck     : in  std_logic;
      opb_m_tx_req     : in  std_logic;
      opb_m_tx_en      : out std_logic;
      opb_m_tx_data    : out std_logic_vector(C_SR_WIDTH-1 downto 0);
      opb_tx_dma_ctl   : in  std_logic_vector(0 downto 0);
      opb_tx_dma_addr  : in  std_logic_vector(C_OPB_DWIDTH-1 downto 0);
      opb_tx_dma_num   : in  std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
      opb_tx_dma_done  : out std_logic;
      opb_m_rx_req     : in  std_logic;
      opb_m_rx_en      : out std_logic;
      opb_m_rx_data    : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      opb_rx_dma_ctl   : in  std_logic_vector(0 downto 0);
      opb_rx_dma_addr  : in  std_logic_vector(C_OPB_DWIDTH-1 downto 0);
      opb_rx_dma_num   : in  std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
      opb_rx_dma_done  : out std_logic;
      opb_abort_flg    : out std_logic;
      opb_m_last_block : out std_logic);
  end component;

  component shift_register
    generic (
      C_SR_WIDTH  : integer;
      C_MSB_FIRST : boolean;
      C_CPOL      : integer range 0 to 1;
      C_PHA       : integer range 0 to 1);
    port (
      rst         : in  std_logic;
      opb_ctl_reg : in  std_logic_vector(C_OPB_CTL_REG_WIDTH-1 downto 0);
      sclk        : in  std_logic;
      ss_n        : in  std_logic;
      mosi        : in  std_logic;
      miso_o      : out std_logic;
      miso_i      : in  std_logic;
      miso_t      : out std_logic;
      sr_tx_clk   : out std_logic;
      sr_tx_en    : out std_logic;
      sr_tx_data  : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      sr_rx_clk   : out std_logic;
      sr_rx_en    : out std_logic;
      sr_rx_data  : out std_logic_vector(C_SR_WIDTH-1 downto 0));
  end component;

  component fifo
    generic (
      C_FIFO_WIDTH      : integer;
      C_FIFO_SIZE_WIDTH : integer;
      C_SYNC_TO         : string);
    port (
      rst               : in  std_logic;
      wr_clk            : in  std_logic;
      wr_en             : in  std_logic;
      din               : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      rd_clk            : in  std_logic;
      rd_en             : in  std_logic;
      dout              : out std_logic_vector(C_SR_WIDTH-1 downto 0);
      empty             : out std_logic;
      full              : out std_logic;
      overflow          : out std_logic;
      underflow         : out std_logic;
      prog_empty_thresh : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
      prog_full_thresh  : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
      prog_empty        : out std_logic;
      prog_full         : out std_logic);
  end component;

  component irq_ctl
    generic (
      C_ACTIVE_EDGE : std_logic);
    port (
      rst          : in  std_logic;
      clk          : in  std_logic;
      opb_fifo_flg : in  std_logic;
      opb_ier      : in  std_logic;
      opb_isr      : out std_logic;
      opb_isr_clr  : in  std_logic);
  end component;

  component crc_core
    generic (
      C_SR_WIDTH : integer);
    port (
      rst              : in  std_logic;
      opb_clk          : in  std_logic;
      crc_en           : in  std_logic;
      crc_clr          : in  std_logic;
      opb_m_last_block : in  std_logic;
      fifo_rx_en       : in  std_logic;
      fifo_rx_data     : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      opb_rx_crc_value : out std_logic_vector(C_SR_WIDTH-1 downto 0);
      fifo_tx_en       : in  std_logic;
      fifo_tx_data     : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      tx_crc_insert    : out std_logic;
      opb_tx_crc_value : out std_logic_vector(C_SR_WIDTH-1 downto 0));
  end component;

-- opb_if
  signal opb_ctl_reg : std_logic_vector(C_OPB_CTL_REG_WIDTH-1 downto 0);

  signal opb_s_tx_en   : std_logic;
  signal opb_s_tx_data : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal opb_s_rx_en   : std_logic;
  signal opb_s_rx_data : std_logic_vector(C_SR_WIDTH-1 downto 0);

  signal tx_thresh : std_logic_vector((2*C_FIFO_SIZE_WIDTH)-1 downto 0);
  signal rx_thresh : std_logic_vector((2*C_FIFO_SIZE_WIDTH)-1 downto 0);

  signal opb_tx_dma_addr : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal opb_tx_dma_ctl  : std_logic_vector(0 downto 0);
  signal opb_tx_dma_num  : std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
  signal opb_rx_dma_addr : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal opb_rx_dma_ctl  : std_logic_vector(0 downto 0);
  signal opb_rx_dma_num  : std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);

  signal opb_rx_crc_value : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal opb_tx_crc_value : std_logic_vector(C_SR_WIDTH-1 downto 0);

  -- opb_m_if
  signal opb_m_tx_en      : std_logic;
  signal opb_m_tx_data    : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal opb_m_rx_en      : std_logic;
  signal opb_m_rx_data    : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal opb_abort_flg    : std_logic;
  signal opb_m_last_block : std_logic;

-- shift_register
  signal sr_tx_clk  : std_logic;
  signal sr_tx_en   : std_logic;
  signal sr_tx_data : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal sr_rx_clk  : std_logic;
  signal sr_rx_en   : std_logic;
  signal sr_rx_data : std_logic_vector(C_SR_WIDTH-1 downto 0);

  signal sclk_ibuf : std_logic;
  signal sclk_bufr : std_logic;

  signal opb_fifo_flg : std_logic_vector(C_NUM_FLG-1 downto 0);
  signal opb_irq_flg  : std_logic_vector(C_NUM_INT-1 downto 0) := (others => '0');
  signal rst          : std_logic;


  signal opb_dgie    : std_logic;
  signal opb_ier     : std_logic_vector(C_NUM_INT-1 downto 0);
  signal opb_isr     : std_logic_vector(C_NUM_INT-1 downto 0);
  signal opb_isr_clr : std_logic_vector(C_NUM_INT-1 downto 0);

  -- opb_spi_slave
  signal fifo_tx_en   : std_logic;
  signal fifo_tx_data : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal fifo_rx_en   : std_logic;
  signal fifo_rx_data : std_logic_vector(C_SR_WIDTH-1 downto 0);

  -- rx crc_core
  signal crc_clr       : std_logic;
  signal crc_en        : std_logic;
  signal tx_crc_insert : std_logic;

begin  -- behavior

  --* 
  virtex4_slk_buf : if C_FAMILY = "virtex4" generate
    --* If C_FAMILY=Virtex-4 use "IBUF"
    IBUF_1 : IBUF
      port map (
        I => sclk,
        O => sclk_ibuf);

--* If C_FAMILY=Virtex-4 use "BUFR"
    BUFR_1 : BUFR
      generic map (
        BUFR_DIVIDE => "BYPASS",
        SIM_DEVICE  => "VIRTEX4") 
      port map (
        O   => sclk_bufr,
        CE  => '0',
        CLR => '0',
        I   => sclk_ibuf);
  end generate virtex4_slk_buf;

  generic_sclk_buf : if C_FAMILY /= "virtex4" generate
    sclk_bufr <= sclk;
  end generate generic_sclk_buf;

  --* OPB-Slave Interface(Register-Interface)
  opb_if_2 : opb_if
    generic map (
      C_BASEADDR        => C_BASEADDR,
      C_HIGHADDR        => C_HIGHADDR,
      C_USER_ID_CODE    => C_USER_ID_CODE,
      C_OPB_AWIDTH      => C_OPB_AWIDTH,
      C_OPB_DWIDTH      => C_OPB_DWIDTH,
      C_FAMILY          => C_FAMILY,
      C_SR_WIDTH        => C_SR_WIDTH,
      C_FIFO_SIZE_WIDTH => C_FIFO_SIZE_WIDTH,
      C_DMA_EN          => C_DMA_EN,
      C_CRC_EN          => C_CRC_EN)
    port map (
      OPB_ABus         => OPB_ABus,
      OPB_BE           => OPB_BE,
      OPB_Clk          => OPB_Clk,
      OPB_DBus         => OPB_DBus,
      OPB_RNW          => OPB_RNW,
      OPB_Rst          => OPB_Rst,
      OPB_select       => OPB_select,
      OPB_seqAddr      => OPB_seqAddr,
      Sln_DBus         => Sln_DBus,
      Sln_errAck       => Sln_errAck,
      Sln_retry        => Sln_retry,
      Sln_toutSup      => Sln_toutSup,
      Sln_xferAck      => Sln_xferAck,
      opb_s_tx_en      => opb_s_tx_en,
      opb_s_tx_data    => opb_s_tx_data,
      opb_s_rx_en      => opb_s_rx_en,
      opb_s_rx_data    => opb_s_rx_data,
      opb_ctl_reg      => opb_ctl_reg,
      tx_thresh        => tx_thresh,
      rx_thresh        => rx_thresh,
      opb_fifo_flg     => opb_fifo_flg,
      opb_dgie         => opb_dgie,
      opb_ier          => opb_ier,
      opb_isr          => opb_isr,
      opb_isr_clr      => opb_isr_clr,
      opb_tx_dma_addr  => opb_tx_dma_addr,
      opb_tx_dma_ctl   => opb_tx_dma_ctl,
      opb_tx_dma_num   => opb_tx_dma_num,
      opb_rx_dma_addr  => opb_rx_dma_addr,
      opb_rx_dma_ctl   => opb_rx_dma_ctl,
      opb_rx_dma_num   => opb_rx_dma_num,
      opb_rx_crc_value => opb_rx_crc_value,
      opb_tx_crc_value => opb_tx_crc_value);

  --* OPB-Master-Interface
  --*
  --* (DMA Read/Write Transfers to TX/RX-FIFO)

  dma_enable : if (C_DMA_EN = true) generate
    opb_m_if_1 : opb_m_if
      generic map (
        C_BASEADDR        => C_BASEADDR,
        C_HIGHADDR        => C_HIGHADDR,
        C_USER_ID_CODE    => C_USER_ID_CODE,
        C_OPB_AWIDTH      => C_OPB_AWIDTH,
        C_OPB_DWIDTH      => C_OPB_DWIDTH,
        C_FAMILY          => C_FAMILY,
        C_SR_WIDTH        => C_SR_WIDTH,
        C_MSB_FIRST       => C_MSB_FIRST,
        C_CPOL            => C_CPOL,
        C_PHA             => C_PHA,
        C_FIFO_SIZE_WIDTH => C_FIFO_SIZE_WIDTH)
      port map (
        OPB_Clk          => OPB_Clk,
        OPB_Rst          => OPB_Rst,
        OPB_DBus         => OPB_DBus,
        M_request        => M_request,
        MOPB_MGrant      => MOPB_MGrant,
        M_busLock        => M_busLock,
        M_ABus           => M_ABus,
        M_BE             => M_BE,
        M_DBus           => M_DBus,
        M_RNW            => M_RNW,
        M_select         => M_select,
        M_seqAddr        => M_seqAddr,
        MOPB_errAck      => MOPB_errAck,
        MOPB_retry       => MOPB_retry,
        MOPB_timeout     => MOPB_timeout,
        MOPB_xferAck     => MOPB_xferAck,
        opb_m_tx_req     => opb_fifo_flg(3),
        opb_m_tx_en      => opb_m_tx_en,
        opb_m_tx_data    => opb_m_tx_data,
        opb_tx_dma_ctl   => opb_tx_dma_ctl,
        opb_tx_dma_addr  => opb_tx_dma_addr,
        opb_tx_dma_num   => opb_tx_dma_num,
        opb_tx_dma_done  => opb_fifo_flg(13),
        opb_m_rx_req     => opb_fifo_flg(6),
        opb_m_rx_en      => opb_m_rx_en,
        opb_m_rx_data    => opb_m_rx_data,
        opb_rx_dma_ctl   => opb_rx_dma_ctl,
        opb_rx_dma_addr  => opb_rx_dma_addr,
        opb_rx_dma_num   => opb_rx_dma_num,
        opb_rx_dma_done  => opb_fifo_flg(14),
        opb_abort_flg    => opb_abort_flg,
        opb_m_last_block => opb_m_last_block);
  end generate dma_enable;

  dma_disable : if (C_DMA_EN = false) generate
    M_request        <= '0';
    M_busLock        <= '0';
    M_ABus           <= (others => '0');
    M_BE             <= (others => '0');
    M_DBus           <= (others => '0');
    M_RNW            <= '0';
    M_select         <= '0';
    M_seqAddr        <= '0';
    opb_m_tx_en      <= '0';
    opb_m_tx_data    <= (others => '0');
    opb_fifo_flg(13) <= '0';
    opb_m_rx_en      <= '0';
    opb_fifo_flg(14) <= '0';
  end generate dma_disable;

  --* Shift-Register 
  shift_register_1 : shift_register
    generic map (
      C_SR_WIDTH  => C_SR_WIDTH,
      C_MSB_FIRST => C_MSB_FIRST,
      C_CPOL      => C_CPOL,
      C_PHA       => C_PHA)
    port map (
      rst         => rst,
      opb_ctl_reg => opb_ctl_reg,
      sclk        => sclk_bufr,
      ss_n        => ss_n,
      mosi        => mosi,
      miso_o      => miso_o,
      miso_i      => miso_i,
      miso_t      => miso_t,
      sr_tx_clk   => sr_tx_clk,
      sr_tx_en    => sr_tx_en,
      sr_tx_data  => sr_tx_data,
      sr_rx_clk   => sr_rx_clk,
      sr_rx_en    => sr_rx_en,
      sr_rx_data  => sr_rx_data);

  --* Transmit FIFO
  tx_fifo_1 : fifo
    generic map (
      C_FIFO_WIDTH      => C_SR_WIDTH,
      C_FIFO_SIZE_WIDTH => C_FIFO_SIZE_WIDTH,
      C_SYNC_TO         => "WR")
    port map (
      -- global
      rst               => rst,
      prog_full_thresh  => tx_thresh(C_FIFO_SIZE_WIDTH-1 downto 0),
      prog_empty_thresh => tx_thresh((2*C_FIFO_SIZE_WIDTH)-1 downto C_FIFO_SIZE_WIDTH),
      -- write port
      wr_clk            => OPB_Clk,
      wr_en             => fifo_tx_en,
      din               => fifo_tx_data,
      -- flags
      prog_full         => opb_fifo_flg(0),
      full              => opb_fifo_flg(1),
      overflow          => opb_fifo_flg(2),
      -- read port
      rd_clk            => sr_tx_clk,
      rd_en             => sr_tx_en,
      dout              => sr_tx_data,
      -- flags
      prog_empty        => opb_fifo_flg(3),
      empty             => opb_fifo_flg(4),
      underflow         => opb_fifo_flg(5));

  fifo_tx_en   <= opb_s_tx_en or opb_m_tx_en;
  fifo_tx_data <= opb_tx_crc_value when (C_CRC_EN and tx_crc_insert = '1') else
                  opb_m_tx_data when (opb_tx_dma_ctl(0) = '1') else
                  opb_s_tx_data;

  --* Receive FIFO
  rx_fifo_1 : fifo
    generic map (
      C_FIFO_WIDTH      => C_SR_WIDTH,
      C_FIFO_SIZE_WIDTH => C_FIFO_SIZE_WIDTH,
      C_SYNC_TO         => "RD")
    port map (
      -- global
      rst               => rst,
      prog_full_thresh  => rx_thresh(C_FIFO_SIZE_WIDTH-1 downto 0),
      prog_empty_thresh => rx_thresh((2*C_FIFO_SIZE_WIDTH)-1 downto C_FIFO_SIZE_WIDTH),
      -- write port
      wr_clk            => sr_rx_clk,
      wr_en             => sr_rx_en,
      din               => sr_rx_data,
      -- flags
      prog_full         => opb_fifo_flg(6),
      full              => opb_fifo_flg(7),
      overflow          => opb_fifo_flg(8),
      -- read port
      rd_clk            => opb_clk,
      rd_en             => fifo_rx_en,
      dout              => fifo_rx_data,
      -- flags
      prog_empty        => opb_fifo_flg(9),
      empty             => opb_fifo_flg(10),
      underflow         => opb_fifo_flg(11));

  fifo_rx_en    <= opb_s_rx_en or opb_m_rx_en;
  opb_s_rx_data <= fifo_rx_data;
  opb_m_rx_data <= fifo_rx_data;

  rst <= OPB_Rst or opb_ctl_reg(C_OPB_CTL_REG_RST);

  opb_fifo_flg(12) <= ss_n;
  opb_fifo_flg(15) <= opb_abort_flg;



  -- Bit 0 : TX_PROG_EMPTY
  opb_irq_flg(0)  <= opb_fifo_flg(3);
  -- Bit 1 : TX_EMPTY
  opb_irq_flg(1)  <= opb_fifo_flg(4);
  -- Bit 2 : TX_Underflow
  opb_irq_flg(2)  <= opb_fifo_flg(5);
  -- Bit 3 : RX_PROG_FULL
  opb_irq_flg(3)  <= opb_fifo_flg(6);
  -- Bit 4 : RX_FULL
  opb_irq_flg(4)  <= opb_fifo_flg(7);
  -- Bit 5 : RX_Overflow
  opb_irq_flg(5)  <= opb_fifo_flg(8);
  -- Bit 6:  CS_H_TO_L
  opb_irq_flg(6)  <= not opb_fifo_flg(12);
  -- Bit 7:  CS_L_TO_H
  opb_irq_flg(7)  <= opb_fifo_flg(12);
  -- Bit 8: TX DMA Done
  opb_irq_flg(8)  <= opb_fifo_flg(13);
  -- Bit 9: RX DMA Done
  opb_irq_flg(9)  <= opb_fifo_flg(14);
  -- Bit 10: DMA Transfer Abort
  opb_irq_flg(10) <= opb_abort_flg;

  --* IRQ Enable, Detection and Flags Control
  irq_gen : for i in 0 to C_NUM_INT-1 generate
    irq_ctl_1 : irq_ctl
      generic map (
        C_ACTIVE_EDGE => '1')
      port map (
        rst          => rst,
        clk          => OPB_Clk,
        opb_fifo_flg => opb_irq_flg(i),
        opb_ier      => opb_ier(i),
        opb_isr      => opb_isr(i),
        opb_isr_clr  => opb_isr_clr(i));
  end generate irq_gen;

  -- assert irq if one Interupt Status bit set
  opb_irq <= '1' when (conv_integer(opb_isr) /= 0 and opb_dgie = '1') else
             '0';


  -----------------------------------------------------------------------------

  -- clear start_value at power up and soft_reset
  crc_en  <= opb_ctl_reg(C_OPB_CTL_REG_CRC_EN);
  crc_clr <= opb_ctl_reg(C_OPB_CTL_REG_CRC_CLR) or rst;

  crc_gen : if (C_CRC_EN) generate
    crc_core_1 : crc_core
      generic map (
        C_SR_WIDTH => C_SR_WIDTH)
      port map (
        rst              => rst,
        opb_clk          => opb_clk,
        crc_en           => crc_en,
        crc_clr          => crc_clr,
        opb_m_last_block => opb_m_last_block,
        fifo_rx_en       => fifo_rx_en,
        fifo_rx_data     => fifo_rx_data,
        opb_rx_crc_value => opb_rx_crc_value,
        fifo_tx_en       => fifo_tx_en,
        fifo_tx_data     => fifo_tx_data,
        tx_crc_insert    => tx_crc_insert,
        opb_tx_crc_value => opb_tx_crc_value);
  end generate crc_gen;


end behavior;
