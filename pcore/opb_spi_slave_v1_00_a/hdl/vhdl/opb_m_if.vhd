-------------------------------------------------------------------------------
--* 
--* @short OPB-Master Interface
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

entity opb_m_if is
  generic (
    C_BASEADDR        : std_logic_vector(0 to 31) := X"00000000";
    C_HIGHADDR        : std_logic_vector(0 to 31) := X"FFFFFFFF";
    C_USER_ID_CODE    : integer                   := 0;
    C_OPB_AWIDTH      : integer                   := 32;
    C_OPB_DWIDTH      : integer                   := 32;
    C_FAMILY          : string                    := "virtex-4";
    C_SR_WIDTH        : integer                   := 8;
    C_MSB_FIRST       : boolean                   := true;
    C_CPOL            : integer range 0 to 1      := 0;
    C_PHA             : integer range 0 to 1      := 0;
    C_FIFO_SIZE_WIDTH : integer range 4 to 7      := 7);

  port (
    -- opb master interface
    OPB_Clk           : in  std_logic;
    OPB_Rst           : in  std_logic;
    OPB_DBus          : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
    M_request         : out std_logic;
    MOPB_MGrant       : in  std_logic;
    M_busLock         : out std_logic;
    M_ABus            : out std_logic_vector(0 to C_OPB_AWIDTH-1);
    M_BE              : out std_logic_vector(0 to C_OPB_DWIDTH/8-1);
    M_DBus            : out std_logic_vector(0 to C_OPB_DWIDTH-1);
    M_RNW             : out std_logic;
    M_select          : out std_logic;
    M_seqAddr         : out std_logic;
    MOPB_errAck       : in  std_logic;
    MOPB_retry        : in  std_logic;
    MOPB_timeout      : in  std_logic;
    MOPB_xferAck      : in  std_logic;
    ---------------------------------------------------------------------------
    -- read transfer
    -- read data from memory and fill fifo
    opb_m_tx_req      : in  std_logic;
    opb_m_tx_en       : out std_logic;
    opb_m_tx_data     : out std_logic_vector(C_SR_WIDTH-1 downto 0);
    -- enable/disable dma transfer
    opb_tx_dma_ctl    : in  std_logic_vector(0 downto 0);
    -- base adress for transfer
    opb_tx_dma_addr   : in  std_logic_vector(C_OPB_DWIDTH-1 downto 0);
    opb_tx_dma_num    : in  std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
    opb_tx_dma_done   : out std_logic;
    ---------------------------------------------------------------------------
    -- write transfer
    -- read fifo an write to memory 
    opb_m_rx_req      : in  std_logic;
    opb_m_rx_en       : out std_logic;
    opb_m_rx_data     : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
    -- enable/disable dma transfer
    opb_rx_dma_ctl    : in  std_logic_vector(0 downto 0);
    -- base adress for transfer
    opb_rx_dma_addr   : in  std_logic_vector(C_OPB_DWIDTH-1 downto 0);
    opb_rx_dma_num    : in  std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
    opb_rx_dma_done   : out std_logic;
    ---------------------------------------------------------------------------
    opb_abort_flg     : out std_logic;
    opb_m_last_block : out std_logic);
end opb_m_if;

architecture behavior of opb_m_if is

  type state_t is (idle,
                   wait_grant,
                   transfer_write,
                   transfer_read,
                   done);


  signal state : state_t := idle;

  signal M_DBus_big_end   : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal M_ABus_big_end   : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal OPB_DBus_big_end : std_logic_vector(C_OPB_DWIDTH-1 downto 0);

  signal M_select_int  : std_logic;
  signal read_transfer : boolean;

  -- read transfer
  signal opb_tx_dma_addr_int : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal opb_tx_dma_en       : std_logic;
  signal opb_tx_dma_num_int  : std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
  signal opb_tx_dma_done_int : std_logic;

  -- write transfer
  signal opb_rx_dma_en       : std_logic;
  signal opb_rx_dma_addr_int : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal opb_rx_dma_num_int  : std_logic_vector(C_WIDTH_DMA_NUM-1 downto 0);
  signal opb_rx_dma_done_int : std_logic;


begin  -- behavior

  --* convert M_DBus_big_end to little endian
  process(M_DBus_big_end)
  begin
    for i in 0 to 31 loop
      M_DBus(31-i) <= M_DBus_big_end(i);
    end loop;  -- i  
  end process;

  --* convert M_ABus_big_end to little endian
  process(M_ABus_big_end)
  begin
    for i in 0 to 31 loop
      M_ABus(31-i) <= M_ABus_big_end(i);
    end loop;  -- i  
  end process;

  --* convert OPB_DBus to bi endian
  process(OPB_DBus)
  begin
    for i in 0 to 31 loop
      OPB_DBus_big_end(31-i) <= OPB_DBus(i);
    end loop;  -- i  
  end process;

  -- for both sides
  M_ABus_big_end <= opb_tx_dma_addr_int when (M_select_int = '1' and (read_transfer = true)) else
                    opb_rx_dma_addr_int when (M_select_int = '1' and (read_transfer = false)) else
                    (others => '0');
  M_select <= M_select_int;



  -- write transfer
  opb_m_rx_en <= MOPB_xferAck when (M_select_int = '1' and (read_transfer = false)) else
                 '0';

  M_DBus_big_end(C_SR_WIDTH-1 downto 0) <= opb_m_rx_data when (M_select_int = '1' and (read_transfer = false)) else
                                           (others => '0');
  M_DBus_big_end(C_OPB_DWIDTH-1 downto C_SR_WIDTH) <= (others => '0');

  opb_tx_dma_done <= opb_tx_dma_done_int;

  -- read transfer
  opb_m_tx_en <= MOPB_xferAck when (M_select_int = '1' and (read_transfer = true)) else
                 '0';
  opb_m_tx_data <= OPB_DBus_big_end(C_SR_WIDTH-1 downto 0);

  opb_rx_dma_done <= opb_rx_dma_done_int;



-------------------------------------------------------------------------------
  opb_masteer_proc : process(OPB_Rst, OPB_Clk)
  begin
    if (OPB_Rst = '1') then
      M_BE                <= (others => '0');
      M_busLock           <= '0';
      M_request           <= '0';
      M_RNW               <= '0';
      M_select_int        <= '0';
      M_seqAddr           <= '0';
      opb_tx_dma_done_int <= '0';
      opb_rx_dma_done_int <= '0';
      opb_abort_flg       <= '0';
      opb_m_last_block   <= '0';
      opb_tx_dma_num_int <= (others => '0');
      opb_rx_dma_num_int <= (others => '0');      
    elsif rising_edge(OPB_Clk) then
      case state is
        when idle =>
          opb_abort_flg <= '0';
          opb_tx_dma_en <= opb_tx_dma_ctl(0);
          opb_rx_dma_en <= opb_rx_dma_ctl(0);

          if (opb_tx_dma_ctl(0) = '1' and opb_tx_dma_en = '0') then
            opb_tx_dma_addr_int <= opb_tx_dma_addr;
            opb_tx_dma_num_int  <= opb_tx_dma_num;
            opb_tx_dma_done_int <= '0';

          end if;

          if (opb_rx_dma_ctl(0) = '1' and opb_rx_dma_en = '0') then
            opb_rx_dma_addr_int <= opb_rx_dma_addr;
            opb_rx_dma_num_int  <= opb_rx_dma_num;
            opb_rx_dma_done_int <= '0';
          end if;

          if (opb_tx_dma_en = '1' and opb_m_tx_req = '1' and opb_tx_dma_done_int = '0') then
            -- read from memory to fifo
            M_request     <= '1';
            read_transfer <= true;
            state         <= wait_grant;
          elsif (opb_rx_dma_en = '1' and opb_m_rx_req = '1'and opb_rx_dma_done_int = '0') then
            -- read from fifo and write memory
            M_request     <= '1';
            read_transfer <= false;
            state         <= wait_grant;
          else
            state <= idle;
          end if;

        when wait_grant =>
          if (MOPB_MGrant = '1') then
            M_request    <= '0';
            M_busLock    <= '1';
            M_select_int <= '1';
            M_seqAddr    <= '1';
            M_BE         <= "1111";
            if (read_transfer) then
              -- read
              M_RNW <= '1';
              if (conv_integer(opb_tx_dma_num_int) = 0) then
                opb_m_last_block <= '1';
              end if;
              state <= transfer_read;
            else
              -- write
              M_RNW <= '0';
              if (conv_integer(opb_rx_dma_num_int) = 0) then
                opb_m_last_block <= '1';
              end if;
              state <= transfer_write;
            end if;
          else
            state <= wait_grant;
          end if;

        when transfer_read =>
          if (MOPB_xferAck = '1') then
            opb_tx_dma_addr_int <= opb_tx_dma_addr_int +4;
            if (opb_tx_dma_addr_int(5 downto 2) = conv_std_logic_vector(14, 4)) then
              -- cycle 14
              -- deassert buslock and seq_address 1 cycle before transfer complete
              M_busLock <= '0';
              M_seqAddr <= '0';
            elsif (opb_tx_dma_addr_int(5 downto 2) = conv_std_logic_vector(15, 4)) then
              -- cycle 15
              M_RNW        <= '0';
              M_select_int <= '0';
              M_BE         <= (others => '0');
              if (conv_integer(opb_tx_dma_num_int) = 0) then
                opb_tx_dma_done_int <= '1';
                opb_m_last_block   <= '0';
              else
                opb_tx_dma_num_int <= opb_tx_dma_num_int-1;
              end if;
              state <= done;
            end if;
          elsif (MOPB_retry = '1' or MOPB_errAck = '1' or MOPB_timeout = '1') then
            -- cancel transfer
            M_busLock     <= '0';
            M_seqAddr     <= '0';
            M_RNW         <= '0';
            M_select_int  <= '0';
            M_BE          <= (others => '0');
            opb_abort_flg <= '1';
            state         <= done;
          else
            state <= transfer_read;
          end if;

        when transfer_write =>
          if (MOPB_xferAck = '1') then
            opb_rx_dma_addr_int <= opb_rx_dma_addr_int +4;
            if (opb_rx_dma_addr_int(5 downto 2) = conv_std_logic_vector(14, 4)) then
              -- cycle 14
              -- deassert buslock and seq_address 1 cycle before transfer complete
              M_busLock <= '0';
              M_seqAddr <= '0';
            elsif (opb_rx_dma_addr_int(5 downto 2) = conv_std_logic_vector(15, 4)) then
              -- cycle 15
              M_RNW        <= '0';
              M_select_int <= '0';
              M_BE         <= (others => '0');
              if (conv_integer(opb_rx_dma_num_int) = 0) then
                opb_rx_dma_done_int <= '1';
                opb_m_last_block   <= '0';
              else
                opb_rx_dma_num_int <= opb_rx_dma_num_int-1;
              end if;
              state <= done;
            end if;
          elsif (MOPB_retry = '1' or MOPB_errAck = '1' or MOPB_timeout = '1') then
            -- cancel transfer
            M_busLock     <= '0';
            M_seqAddr     <= '0';
            M_RNW         <= '0';
            M_select_int  <= '0';
            M_BE          <= (others => '0');
            opb_abort_flg <= '1';
            state         <= done;
          else
            state <= transfer_write;
          end if;

        when done =>

          state <= idle;
          
        when others =>
          state <= idle;
      end case;
    end if;
  end process opb_masteer_proc;
end behavior;
