-------------------------------------------------------------------------------
--* 
--* @short OPB-Slave Interface
--* 
--* Generics described in top entity.
--*
--* @see opb_spi_slave
--*    @author: Daniel Köthe
--*   @version: 1.0 
--* @date: 2007-11-11
--/
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;               -- conv_integer()

library work;
use work.opb_spi_slave_pack.all;

entity opb_if is

  generic (
    C_BASEADDR        : std_logic_vector(0 to 31) := X"00000000";
    C_HIGHADDR        : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_USER_ID_CODE    : integer                   := 3;
    C_OPB_AWIDTH      : integer                   := 32;
    C_OPB_DWIDTH      : integer                   := 32;
    C_FAMILY          : string                    := "virtex-4";
    C_SR_WIDTH        : integer                   := 8;
    C_FIFO_SIZE_WIDTH : integer                   := 4;
    C_DMA_EN          : boolean                   := false;
    C_CRC_EN          : boolean                   := false);
  port (
    -- OPB-Bus Signals
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
    -- fifo ports
    opb_s_tx_en      : out std_logic;
    opb_s_tx_data    : out std_logic_vector(C_SR_WIDTH-1 downto 0);
    opb_s_rx_en      : out std_logic;
    opb_s_rx_data    : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
    -- control register
    opb_ctl_reg      : out std_logic_vector(C_OPB_CTL_REG_WIDTH-1 downto 0);
    -- Fifo almost full/empty thresholds
    tx_thresh        : out std_logic_vector((2*C_FIFO_SIZE_WIDTH)-1 downto 0);
    rx_thresh        : out std_logic_vector((2*C_FIFO_SIZE_WIDTH)-1 downto 0);
    opb_fifo_flg     : in  std_logic_vector(C_NUM_FLG-1 downto 0);
    -- interrupts
    opb_dgie         : out std_logic;
    opb_ier          : out std_logic_vector(C_NUM_INT-1 downto 0);
    opb_isr          : in  std_logic_vector(C_NUM_INT-1 downto 0);
    opb_isr_clr      : out std_logic_vector(C_NUM_INT-1 downto 0);
    -- dma register
    opb_tx_dma_addr  : out std_logic_vector(C_OPB_DWIDTH-1 downto 0);
    opb_tx_dma_ctl   : out std_logic_vector(0 downto 0);
    opb_tx_dma_num   : out std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
    opb_rx_dma_addr  : out std_logic_vector(C_OPB_DWIDTH-1 downto 0);
    opb_rx_dma_ctl   : out std_logic_vector(0 downto 0);
    opb_rx_dma_num   : out std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
    -- rx crc
    opb_rx_crc_value : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
    opb_tx_crc_value : in  std_logic_vector(C_SR_WIDTH-1 downto 0));
end opb_if;

architecture behavior of opb_if is


  signal Sln_DBus_big_end : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal OPB_ABus_big_end : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal OPB_DBus_big_end : std_logic_vector(C_OPB_DWIDTH-1 downto 0);


  type state_t is (idle,
                   done);
  signal state : state_t := idle;

  -- internal signals to enable readback

  signal tx_thresh_int : std_logic_vector((2*C_FIFO_SIZE_WIDTH)-1 downto 0);
  signal rx_thresh_int : std_logic_vector((2*C_FIFO_SIZE_WIDTH)-1 downto 0);
  signal opb_ier_int   : std_logic_vector(C_NUM_INT-1 downto 0);
  signal opb_dgie_int  : std_logic;

  signal opb_ctl_reg_int : std_logic_vector(C_OPB_CTL_REG_WIDTH-1 downto 0);


  -- only used if C_DMA_EN=true
  signal opb_tx_dma_addr_int : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal opb_tx_dma_ctl_int  : std_logic_vector(0 downto 0);
  signal opb_tx_dma_num_int  : std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
  signal opb_rx_dma_addr_int : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal opb_rx_dma_ctl_int  : std_logic_vector(0 downto 0);
  signal opb_rx_dma_num_int  : std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
  
begin  -- behavior

  tx_thresh <= tx_thresh_int;
  rx_thresh <= rx_thresh_int;
  opb_ier   <= opb_ier_int;
  opb_dgie  <= opb_dgie_int;

  opb_ctl_reg <= opb_ctl_reg_int;

  --* Signals for DMA-Engine control
  u1 : if C_DMA_EN generate
    opb_tx_dma_ctl  <= opb_tx_dma_ctl_int;
    opb_tx_dma_addr <= opb_tx_dma_addr_int;
    opb_tx_dma_num  <= opb_tx_dma_num_int;
    opb_rx_dma_ctl  <= opb_rx_dma_ctl_int;
    opb_rx_dma_addr <= opb_rx_dma_addr_int;
    opb_rx_dma_num  <= opb_rx_dma_num_int;
  end generate u1;


-- unused outputs
  Sln_errAck  <= '0';
  Sln_retry   <= '0';
  Sln_toutSup <= '0';

  --* convert Sln_DBus_big_end  to little mode
  conv_big_Sln_DBus_proc : process(Sln_DBus_big_end)
  begin
    for i in 0 to 31 loop
      Sln_DBus(31-i) <= Sln_DBus_big_end(i);
    end loop;  -- i  
  end process conv_big_Sln_DBus_proc;

  --* convert OPB_ABus to big endian
  conv_big_OPB_ABus_proc : process(OPB_ABus)
  begin
    for i in 0 to 31 loop
      OPB_ABus_big_end(31-i) <= OPB_ABus(i);
    end loop;  -- i  
  end process conv_big_OPB_ABus_proc;

  --* convert OPB_DBus  to little mode
  conv_big_OPB_DBus_proc : process(OPB_DBus)
  begin
    for i in 0 to 31 loop
      OPB_DBus_big_end(31-i) <= OPB_DBus(i);
    end loop;  -- i  
  end process conv_big_OPB_DBus_proc;

  --* control OPB requests
  --*
  --* handles OPB-read and -write request
  opb_slave_proc : process (OPB_Rst, OPB_Clk)
  begin
    if (OPB_Rst = '1') then
      -- OPB
      Sln_xferAck      <= '0';
      Sln_DBus_big_end <= (others => '0');
      -- FIFO
      opb_s_rx_en      <= '0';
      opb_s_tx_en      <= '0';
      -- 
      state            <= idle;
      -- Register
      tx_thresh_int    <= (others => '0');
      rx_thresh_int    <= (others => '0');
      opb_ier_int      <= (others => '0');
      opb_dgie_int     <= '0';
      opb_ctl_reg_int  <= (others => '0');

      if C_DMA_EN then
        opb_tx_dma_ctl_int  <= (others => '0');
        opb_tx_dma_addr_int <= (others => '0');
        opb_tx_dma_num_int  <= (others => '0');
        opb_rx_dma_ctl_int  <= (others => '0');
        opb_rx_dma_addr_int <= (others => '0');
        opb_rx_dma_num_int  <= (others => '0');
      end if;


    elsif (OPB_Clk'event and OPB_Clk = '1') then
      case state is
        when idle =>
          if (OPB_select = '1' and
              ((OPB_ABus >= C_BASEADDR) and (OPB_ABus <= C_HIGHADDR))) then
            -- *device selected
            Sln_xferAck <= '1';
            state       <= done;
            if (OPB_RNW = '1') then
              -- read acess
              case OPB_ABus_big_end(7 downto 2) is
                when C_ADR_CTL =>
                  Sln_DBus_big_end(C_OPB_CTL_REG_WIDTH-1 downto 0) <= opb_ctl_reg_int;

                when C_ADR_RX_DATA =>
                  opb_s_rx_en                             <= '1';
                  Sln_DBus_big_end(C_SR_WIDTH-1 downto 0) <= opb_s_rx_data;

                when C_ADR_STATUS =>
                  Sln_DBus_big_end(C_NUM_FLG-1 downto 0) <= opb_fifo_flg;

                when C_ADR_TX_THRESH =>
                  Sln_DBus_big_end(C_FIFO_SIZE_WIDTH-1 downto 0)     <= tx_thresh_int(C_FIFO_SIZE_WIDTH-1 downto 0);
                  Sln_DBus_big_end(16+C_FIFO_SIZE_WIDTH-1 downto 16) <= tx_thresh_int((2*C_FIFO_SIZE_WIDTH)-1 downto C_FIFO_SIZE_WIDTH);
                  
                when C_ADR_RX_THRESH =>
                  Sln_DBus_big_end(C_FIFO_SIZE_WIDTH-1 downto 0)     <= rx_thresh_int(C_FIFO_SIZE_WIDTH-1 downto 0);
                  Sln_DBus_big_end(16+C_FIFO_SIZE_WIDTH-1 downto 16) <= rx_thresh_int((2*C_FIFO_SIZE_WIDTH)-1 downto C_FIFO_SIZE_WIDTH);
                  
                when C_ADR_DGIE =>
                  Sln_DBus_big_end(0) <= opb_dgie_int;
                when C_ADR_IER =>
                  Sln_DBus_big_end(C_NUM_INT-1 downto 0) <= opb_ier_int;

                when C_ADR_ISR =>
                  Sln_DBus_big_end(C_NUM_INT-1 downto 0) <= opb_isr;

                when C_ADR_TX_DMA_CTL =>
                  if C_DMA_EN then
                    Sln_DBus_big_end(0 downto 0) <= opb_tx_dma_ctl_int;
                  end if;

                when C_ADR_TX_DMA_ADDR =>
                  if C_DMA_EN then
                    Sln_DBus_big_end(C_OPB_DWIDTH-1 downto 0) <= opb_tx_dma_addr_int;
                  end if;

                when C_ADR_TX_DMA_NUM =>
                  if C_DMA_EN then
                    Sln_DBus_big_end(C_WIDTH_DMA_NUM-1 downto 0) <= opb_tx_dma_num_int;
                  end if;
                  

                when C_ADR_RX_DMA_CTL =>
                  if C_DMA_EN then
                    Sln_DBus_big_end(0 downto 0) <= opb_rx_dma_ctl_int;
                  end if;

                when C_ADR_RX_DMA_ADDR =>
                  if C_DMA_EN then
                    Sln_DBus_big_end(C_OPB_DWIDTH-1 downto 0) <= opb_rx_dma_addr_int;
                  end if;

                when C_ADR_RX_DMA_NUM =>
                  if C_DMA_EN then
                    Sln_DBus_big_end(C_WIDTH_DMA_NUM-1 downto 0) <= opb_rx_dma_num_int;
                  end if;

                when C_ADR_RX_CRC =>
                  if C_CRC_EN then
                    Sln_DBus_big_end(C_OPB_DWIDTH-1 downto C_SR_WIDTH) <= (others => '0');
                    Sln_DBus_big_end(C_SR_WIDTH-1 downto 0)            <= opb_rx_crc_value;
                  end if;
                  
                when C_ADR_TX_CRC =>
                  if C_CRC_EN then
                    Sln_DBus_big_end(C_OPB_DWIDTH-1 downto C_SR_WIDTH) <= (others => '0');
                    Sln_DBus_big_end(C_SR_WIDTH-1 downto 0)            <= opb_tx_crc_value;
                  end if;
                when others =>
                  null;
              end case;
            else
              -- write acess
              case OPB_ABus_big_end(7 downto 2) is
                when C_ADR_CTL =>
                  opb_ctl_reg_int <= OPB_DBus_big_end(C_OPB_CTL_REG_WIDTH-1 downto 0);
                  
                when C_ADR_TX_DATA =>
                  opb_s_tx_en   <= '1';
                  opb_s_tx_data <= OPB_DBus_big_end(C_SR_WIDTH-1 downto 0);

                when C_ADR_TX_THRESH =>
                  tx_thresh_int(C_FIFO_SIZE_WIDTH-1 downto 0)                     <= OPB_DBus_big_end(C_FIFO_SIZE_WIDTH-1 downto 0);
                  tx_thresh_int((2*C_FIFO_SIZE_WIDTH)-1 downto C_FIFO_SIZE_WIDTH) <= OPB_DBus_big_end(16+C_FIFO_SIZE_WIDTH-1 downto 16);

                when C_ADR_RX_THRESH =>
                  rx_thresh_int(C_FIFO_SIZE_WIDTH-1 downto 0)                     <= OPB_DBus_big_end(C_FIFO_SIZE_WIDTH-1 downto 0);
                  rx_thresh_int((2*C_FIFO_SIZE_WIDTH)-1 downto C_FIFO_SIZE_WIDTH) <= OPB_DBus_big_end(16+C_FIFO_SIZE_WIDTH-1 downto 16);

                when C_ADR_DGIE =>
                  opb_dgie_int <= OPB_DBus_big_end(0);
                  
                when C_ADR_IER =>
                  opb_ier_int <= OPB_DBus_big_end(C_NUM_INT-1 downto 0);

                when C_ADR_ISR =>
                  opb_isr_clr <= OPB_DBus_big_end(C_NUM_INT-1 downto 0);

                when C_ADR_TX_DMA_CTL =>
                  if C_DMA_EN then
                    opb_tx_dma_ctl_int <= OPB_DBus_big_end(0 downto 0);
                  end if;

                when C_ADR_TX_DMA_ADDR =>
                  if C_DMA_EN then
                    opb_tx_dma_addr_int <= OPB_DBus_big_end(C_OPB_DWIDTH-1 downto 0);
                  end if;

                when C_ADR_TX_DMA_NUM =>
                  if C_DMA_EN then
                    opb_tx_dma_num_int <= OPB_DBus_big_end(C_WIDTH_DMA_NUM-1 downto 0);
                  end if;

                when C_ADR_RX_DMA_CTL =>
                  if C_DMA_EN then
                    opb_rx_dma_ctl_int <= OPB_DBus_big_end(0 downto 0);
                  end if;

                when C_ADR_RX_DMA_ADDR =>
                  if C_DMA_EN then
                    opb_rx_dma_addr_int <= OPB_DBus_big_end(C_OPB_DWIDTH-1 downto 0);
                  end if;

                when C_ADR_RX_DMA_NUM =>
                  if C_DMA_EN then
                    opb_rx_dma_num_int <= OPB_DBus_big_end(C_WIDTH_DMA_NUM-1 downto 0);
                  end if;
                  
                when others =>
                  null;
              end case;
            end if;  -- OPB_RNW
          else
            -- not selected
            state <= idle;
          end if;
        when done =>
          opb_ctl_reg_int(3) <= '0';
          opb_isr_clr        <= (others => '0');
          opb_s_rx_en        <= '0';
          opb_s_tx_en        <= '0';
          Sln_xferAck        <= '0';
          Sln_DBus_big_end   <= (others => '0');
          state              <= idle;
          
        when others =>
          state <= idle;
      end case;
    end if;
  end process opb_slave_proc;
end behavior;
