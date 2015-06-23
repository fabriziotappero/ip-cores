
library ieee;
use ieee.std_logic_1164.all;

entity crc_core is
  
  generic (
    C_SR_WIDTH : integer := 32);
  port (
    rst              : in  std_logic;
    opb_clk          : in  std_logic;
    crc_en           : in  std_logic;
    crc_clr          : in  std_logic;
    opb_m_last_block : in  std_logic;
    -- RX
    fifo_rx_en       : in  std_logic;
    fifo_rx_data     : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
    opb_rx_crc_value : out std_logic_vector(C_SR_WIDTH-1 downto 0);
    -- TX
    fifo_tx_en       : in  std_logic;
    fifo_tx_data     : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
    tx_crc_insert    : out std_logic;
    opb_tx_crc_value : out std_logic_vector(C_SR_WIDTH-1 downto 0));
end crc_core;


architecture behavior of crc_core is
  component crc_gen
    generic (
      C_SR_WIDTH      : integer;
      crc_start_value : std_logic_vector(31 downto 0));
    port (
      clk          : in  std_logic;
      crc_clear    : in  std_logic;
      crc_en       : in  std_logic;
      crc_data_in  : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      crc_data_out : out std_logic_vector(C_SR_WIDTH-1 downto 0));
  end component;

  signal rx_crc_en : std_logic;
  signal tx_crc_en : std_logic;


  type state_define is (idle,
                        tx_insert_crc,
                        wait_done);
  signal state : state_define;

begin  -- behavior

  --* RX CRC_GEN
  crc_gen_rx : crc_gen
    generic map (
      C_SR_WIDTH      => C_SR_WIDTH,
      crc_start_value => (others => '1'))
    port map (
      clk          => OPB_Clk,
      crc_clear    => crc_clr,
      crc_en       => rx_crc_en,
      crc_data_in  => fifo_rx_data,
      crc_data_out => opb_rx_crc_value);    

  -- disable crc_generation for last data block
  rx_crc_en <= '1' when (crc_en = '1' and fifo_rx_en = '1' and opb_m_last_block = '0') else
               '0';

  -----------------------------------------------------------------------------
  --* TX CRC_GEN
  crc_gen_tx : crc_gen
    generic map (
      C_SR_WIDTH      => C_SR_WIDTH,
      crc_start_value => (others => '1'))
    port map (
      clk          => OPB_Clk,
      crc_clear    => crc_clr,
      crc_en       => tx_crc_en,
      crc_data_in  => fifo_tx_data,
      crc_data_out => opb_tx_crc_value);    

  -- disable crc_generation for last data block
  tx_crc_en <= '1' when (crc_en = '1' and fifo_tx_en = '1' and opb_m_last_block = '0') else
               '0';

  process(rst, OPB_Clk)
  begin
    if (rst = '1') then
      tx_crc_insert <= '0';
      state <= idle;
    elsif rising_edge(OPB_Clk) then
      case state is
        when idle =>
          if (opb_m_last_block = '1') then
            tx_crc_insert <= '1';
            state         <= tx_insert_crc;
          else
            tx_crc_insert <= '0';            
            state <= idle;
          end if;

        when tx_insert_crc =>
          if (opb_m_last_block = '0') then
            -- abort
            tx_crc_insert <= '0';
            state         <= idle;
          elsif (fifo_tx_en = '1') then
            tx_crc_insert <= '0';
            state         <= wait_done;
          else
            state <= tx_insert_crc;
          end if;

        when wait_done =>
          if (opb_m_last_block = '0') then
            tx_crc_insert <= '0';
            state         <= idle;
            
          else
            state <= wait_done;
          end if;

        when others =>
          state <= idle;
      end case;

    end if;
  end process;
end behavior;
