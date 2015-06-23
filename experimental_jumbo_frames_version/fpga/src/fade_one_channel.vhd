library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkt_ack_pkg.all;
use work.desc_mgr_pkg.all;
library unisim;
use unisim.vcomponents.all;

entity fade_one_channel is
  generic (
    my_mac : std_logic_vector(47 downto 0));
  port (
    xgmii_txd     : out  std_logic_vector(63 downto 0);
    xgmii_txc     : out  std_logic_vector(7 downto 0);
    xgmii_rxd     : in std_logic_vector(63 downto 0);
    xgmii_rxc     : in std_logic_vector(7 downto 0);
    rst_n : in std_logic;
    clk_user         : in  std_logic
    );

end fade_one_channel;

architecture beh1 of fade_one_channel is

  --signal heart_bit : integer := 0;

  --signal refclk_p                 : std_logic := '0';
  --signal refclk_n                 : std_logic := '0';
  --signal reset                    : std_logic := '0';
  --signal clk_rst_buf, clk_rst_156 : std_logic := '1';  -- generated reset
  --signal rst_p                    : std_logic := '1';  -- generated reset
  --signal rst_cnt                  : integer   := 200000000;


  --signal s_resetdone                   : std_logic                      := '0';
  --signal core_clk156_out               : std_logic                      := '0';
  --signal txp                           : std_logic                      := '0';
  --signal txn                           : std_logic                      := '0';
  --signal rxp                           : std_logic                      := '0';
  --signal rxn                           : std_logic                      := '0';
  --signal dclk_out                      : std_logic                      := '0';
  --signal s_txusrclk_out                : std_logic                      := '0';
  --signal s_txusrclk2_out               : std_logic                      := '0';
  --signal areset_clk156_out             : std_logic                      := '0';
  --signal gttxreset_out                 : std_logic                      := '0';
  --signal gtrxreset_out                 : std_logic                      := '0';
  --signal txuserrdy_out                 : std_logic                      := '0';
  --signal reset_counter_done_out        : std_logic                      := '0';
  --signal qplllock_out                  : std_logic                      := '0';
  --signal qplloutclk_out                : std_logic                      := '0';
  --signal qplloutrefclk_out             : std_logic                      := '0';
  --signal xgmii_txd, xgmii_txd1         : std_logic_vector(63 downto 0)  := (others => '0');
  --signal xgmii_txc, xgmii_txc1         : std_logic_vector(7 downto 0)   := (others => '0');
  --signal xgmii_rxd, xgmii_rxd1         : std_logic_vector(63 downto 0)  := (others => '0');
  --signal xgmii_rxc, xgmii_rxc1         : std_logic_vector(7 downto 0)   := (others => '0');
  --signal configuration_vector          : std_logic_vector(535 downto 0) := (others => '0');
  --signal status_vector, status_vector1 : std_logic_vector(447 downto 0) := (others => '0');
  --signal core_status, core_status1     : std_logic_vector(7 downto 0)   := (others => '0');
  --signal signal_detect, signal_detect1 : std_logic                      := '0';
  --signal tx_fault, tx_fault1           : std_logic                      := '0';
  --signal drp_req, drp_req1             : std_logic                      := '0';
  --signal drp_gnt, drp_gnt1             : std_logic                      := '0';
  --signal drp_den_o, drp_den1_o         : std_logic                      := '0';
  --signal drp_dwe_o, drp_dwe1_o         : std_logic                      := '0';
  --signal drp_daddr_o, drp_daddr1_o     : std_logic_vector(15 downto 0)  := (others => '0');
  --signal drp_di_o, drp_di1_o           : std_logic_vector(15 downto 0)  := (others => '0');
  --signal drp_drdy_o, drp_drdy1_o       : std_logic                      := '0';
  --signal drp_drpdo_o, drp_drpdo1_o     : std_logic_vector(15 downto 0)  := (others => '0');
  --signal drp_den_i, drp_den1_i         : std_logic                      := '0';
  --signal drp_dwe_i, drp_dwe1_i         : std_logic                      := '0';
  --signal drp_daddr_i, drp_daddr1_i     : std_logic_vector(15 downto 0)  := (others => '0');
  --signal drp_di_i, drp_di1_i           : std_logic_vector(15 downto 0)  := (others => '0');
  --signal drp_drdy_i, drp_drdy1_i       : std_logic                      := '0';
  --signal drp_drpdo_i, drp_drpdo1_i     : std_logic_vector(15 downto 0)  := (others => '0');
  --signal tx_disable, tx_disable1       : std_logic                      := '0';

  --signal counter              : integer   := 0;
  --signal probe2               : std_logic_vector(2 downto 0);
  --signal trig_in, trig_in_ack : std_logic := '0';
  --signal rst_n, rst1, clk1    : std_logic := '0';
  signal clk1    : std_logic := '0';
  --signal hb_led               : std_logic := '0';
  --signal s_led5               : std_logic := '0';

  ---- Signals associated with the FADE core
  ----signal my_mac                   : std_logic_vector(47 downto 0);
  --signal sender                   : std_logic_vector(47 downto 0);
  signal peer_mac                 : std_logic_vector(47 downto 0);
  constant my_ether_type          : std_logic_vector(15 downto 0) := x"fade";
  signal transm_delay             : unsigned(31 downto 0);
  signal retr_count               : std_logic_vector(31 downto 0);
  signal restart                  : std_logic;
  signal fade_rst_n, fade_rst_del : std_logic                     := '0';
  signal fade_rst_p               : std_logic;

  signal test_dta                          : unsigned(63 downto 0);
  signal dta                               : std_logic_vector(63 downto 0);
  signal s_dta_we, dta_we                  : std_logic                         := '0';
  signal dta_ready                         : std_logic;
  signal snd_start                         : std_logic;
  signal flushed                           : std_logic                         := '0';
  signal dta_eod                           : std_logic                         := '0';
  signal snd_ready                         : std_logic;
  --signal clk_user                          : std_logic;
  signal dmem_we                           : std_logic;
  signal dmem_addr                         : std_logic_vector(LOG2_N_OF_PKTS+LOG2_NWRDS_IN_PKT-1 downto 0);
  signal dmem_dta                          : std_logic_vector(63 downto 0);
  signal tx_mem_addr                       : std_logic_vector(LOG2_N_OF_PKTS+LOG2_NWRDS_IN_PKT-1 downto 0);
  signal tx_mem_data                       : std_logic_vector(63 downto 0);
  signal pkt_number                        : unsigned(31 downto 0);
  signal seq_number                        : unsigned(15 downto 0)             := (others => '0');
  --signal start_pkt, stop_pkt               : unsigned(7 downto 0)              := (others => '0');
  ---- signals related to user commands handling
  signal cmd_response_in, cmd_response_out : std_logic_vector(12*8-1 downto 0) := (others => '0');
  signal cmd_start                         : std_logic                         := '0';
  signal cmd_run                           : std_logic                         := '0';
  signal cmd_retr_s                        : std_logic                         := '0';
  signal cmd_ack                           : std_logic                         := '0';
  signal cmd_code                          : std_logic_vector(15 downto 0)     := (others => '0');
  signal cmd_seq                           : std_logic_vector(15 downto 0)     := (others => '0');
  signal cmd_arg                           : std_logic_vector(31 downto 0)     := (others => '0');


  ---- debug signals
  signal dbg    : std_logic_vector(3 downto 0);
  signal rx_cmd : std_logic_vector(31 downto 0);
  signal rx_arg : std_logic_vector(31 downto 0);

  signal ack_fifo_din, ack_fifo_dout                                   : std_logic_vector(pkt_ack_width-1 downto 0);
  signal ack_fifo_wr_en, ack_fifo_rd_en, ack_fifo_empty, ack_fifo_full : std_logic;
  --signal ack_fifo_dbg                                                  : pkt_ack;
  signal transmit_data, td_del0, td_del1                               : std_logic := '0';

  component eth_receiver is
    port (
      peer_mac       : out std_logic_vector(47 downto 0);
      my_mac         : in  std_logic_vector(47 downto 0);
      my_ether_type  : in  std_logic_vector(15 downto 0);
      transmit_data  : out std_logic;
      restart        : out std_logic;
      ack_fifo_full  : in  std_logic;
      ack_fifo_wr_en : out std_logic;
      ack_fifo_din   : out std_logic_vector(pkt_ack_width-1 downto 0);
      clk            : in  std_logic;
      rst_n          : in  std_logic;
      dbg            : out std_logic_vector(3 downto 0);
      crc            : out std_logic_vector(31 downto 0);
      cmd            : out std_logic_vector(31 downto 0);
      arg            : out std_logic_vector(31 downto 0);
      Rx_Clk         : in  std_logic;
      RxC            : in  std_logic_vector(7 downto 0);
      RxD            : in  std_logic_vector(63 downto 0));
  end component eth_receiver;

  component eth_sender is
    port (
      peer_mac      : in  std_logic_vector(47 downto 0);
      my_mac        : in  std_logic_vector(47 downto 0);
      my_ether_type : in  std_logic_vector(15 downto 0);
      pkt_number    : in  unsigned(31 downto 0);
      seq_number    : in  unsigned(15 downto 0);
      transm_delay  : in  unsigned(31 downto 0);
      clk           : in  std_logic;
      rst_n         : in  std_logic;
      ready         : out std_logic;
      flushed       : in  std_logic;
      start         : in  std_logic;
      cmd_start     : in  std_logic;
      tx_mem_addr   : out std_logic_vector(LOG2_N_OF_PKTS+LOG2_NWRDS_IN_PKT-1 downto 0);
      tx_mem_data   : in  std_logic_vector(63 downto 0);
      cmd_response  : in  std_logic_vector(12*8-1 downto 0);
      Tx_Clk        : in  std_logic;
      TxC           : out std_logic_vector(7 downto 0);
      TxD           : out std_logic_vector(63 downto 0));
  end component eth_sender;

  component dp_ram_scl
    generic (
      DATA_WIDTH : integer;
      ADDR_WIDTH : integer);
    port (
      clk_a  : in  std_logic;
      we_a   : in  std_logic;
      addr_a : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_a : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      q_a    : out std_logic_vector(DATA_WIDTH-1 downto 0);
      clk_b  : in  std_logic;
      we_b   : in  std_logic;
      addr_b : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_b : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      q_b    : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;

  component ack_fifo
    port (
      rst    : in  std_logic;
      wr_clk : in  std_logic;
      rd_clk : in  std_logic;
      din    : in  std_logic_vector(pkt_ack_width-1 downto 0);
      wr_en  : in  std_logic;
      rd_en  : in  std_logic;
      dout   : out std_logic_vector(pkt_ack_width-1 downto 0);
      full   : out std_logic;
      empty  : out std_logic);
  end component;

  component cmd_proc is
    port (
      cmd_code     : in  std_logic_vector(15 downto 0);
      cmd_seq      : in  std_logic_vector(15 downto 0);
      cmd_arg      : in  std_logic_vector(31 downto 0);
      cmd_run      : in  std_logic;
      cmd_ack      : out std_logic;
      cmd_response : out std_logic_vector(8*12-1 downto 0);
      clk          : in  std_logic;
      rst_p        : in  std_logic;
      retr_count   : in  std_logic_vector(31 downto 0)
      );
  end component cmd_proc;

  component desc_manager is
    generic (
      LOG2_N_OF_PKTS : integer;
      N_OF_PKTS      : integer);
    port (
      dta              : in  std_logic_vector(63 downto 0);
      dta_we           : in  std_logic;
      dta_ready        : out std_logic;
      dta_eod          : in  std_logic;
      pkt_number       : out unsigned(31 downto 0);
      seq_number       : out unsigned(15 downto 0);
      cmd_response_out : out std_logic_vector(12*8-1 downto 0);
      snd_cmd_start    : out std_logic;
      snd_start        : out std_logic;
      snd_ready        : in  std_logic;
      flushed          : out std_logic;
      dmem_addr        : out std_logic_vector(LOG2_NWRDS_IN_PKT+LOG2_N_OF_PKTS-1 downto 0);
      dmem_dta         : out std_logic_vector(63 downto 0);
      dmem_we          : out std_logic;
      ack_fifo_empty   : in  std_logic;
      ack_fifo_rd_en   : out std_logic;
      ack_fifo_dout    : in  std_logic_vector(pkt_ack_width-1 downto 0);
      cmd_code         : out std_logic_vector(15 downto 0);
      cmd_seq          : out std_logic_vector(15 downto 0);
      cmd_arg          : out std_logic_vector(31 downto 0);
      cmd_run          : out std_logic;
      cmd_retr_s       : out std_logic;
      cmd_ack          : in  std_logic;
      cmd_response_in  : in  std_logic_vector(8*12-1 downto 0);
      transmit_data    : in  std_logic;
      transm_delay     : out unsigned(31 downto 0);
      retr_count       : out std_logic_vector(31 downto 0);
      dbg              : out std_logic_vector(3 downto 0);
      clk              : in  std_logic;
      rst_n            : in  std_logic);
  end component desc_manager;

begin  -- beh1

  
  clk1     <= clk_user;


  --addr_b <= to_integer(unsigned(tx_mem_addr));

  dp_ram_scl_1 : dp_ram_scl
    generic map (
      DATA_WIDTH => 64,
      ADDR_WIDTH => LOG2_N_OF_PKTS+LOG2_NWRDS_IN_PKT)
    port map (
      clk_a  => clk_user,
      we_a   => dmem_we,
      addr_a => dmem_addr,
      data_a => dmem_dta,
      q_a    => open,
      clk_b  => clk1,
      we_b   => '0',
      addr_b => tx_mem_addr,
      data_b => (others => '0'),
      q_b    => tx_mem_data);

  desc_manager_1 : desc_manager
    generic map (
      LOG2_N_OF_PKTS => LOG2_N_OF_PKTS,
      N_OF_PKTS      => N_OF_PKTS)
    port map (
      dta              => dta,
      dta_we           => dta_we,
      dta_eod          => dta_eod,
      dta_ready        => dta_ready,
      pkt_number       => pkt_number,
      seq_number       => seq_number,
      cmd_response_out => cmd_response_out,
      snd_cmd_start    => cmd_start,
      snd_start        => snd_start,
      flushed          => flushed,
      snd_ready        => snd_ready,
      dmem_addr        => dmem_addr,
      dmem_dta         => dmem_dta,
      dmem_we          => dmem_we,
      ack_fifo_empty   => ack_fifo_empty,
      ack_fifo_rd_en   => ack_fifo_rd_en,
      ack_fifo_dout    => ack_fifo_dout,
      cmd_code         => cmd_code,
      cmd_seq          => cmd_seq,
      cmd_arg          => cmd_arg,
      cmd_run          => cmd_run,
      cmd_retr_s       => cmd_retr_s,
      cmd_ack          => cmd_ack,
      cmd_response_in  => cmd_response_in,
      transmit_data    => transmit_data,
      transm_delay     => transm_delay,
      retr_count       => retr_count,
      dbg              => dbg,
      clk              => clk_user,
      rst_n            => fade_rst_n);

  cmd_proc_1 : cmd_proc
    port map (
      cmd_code     => cmd_code,
      cmd_seq      => cmd_seq,
      cmd_arg      => cmd_arg,
      cmd_run      => cmd_run,
      cmd_ack      => cmd_ack,
      cmd_response => cmd_response_in,
      clk          => clk_user,
      rst_p        => fade_rst_p,
      retr_count   => retr_count
      );

  eth_sender_1 : eth_sender
    port map (
      peer_mac      => peer_mac,
      my_mac        => my_mac,
      my_ether_type => my_ether_type,
      pkt_number    => pkt_number,
      seq_number    => seq_number,
      transm_delay  => transm_delay,
      clk           => clk_user,
      rst_n         => fade_rst_n,
      ready         => snd_ready,
      flushed       => flushed,
      start         => snd_start,
      cmd_start     => cmd_start,
      tx_mem_addr   => tx_mem_addr,
      tx_mem_data   => tx_mem_data,
      cmd_response  => cmd_response_out,
      Tx_Clk        => clk1,
      TxC           => xgmii_txc,
      TxD           => xgmii_txd);

  eth_receiver_2 : eth_receiver
    port map (
      peer_mac       => peer_mac,
      my_mac         => my_mac,
      my_ether_type  => my_ether_type,
      transmit_data  => transmit_data,
      restart        => restart,
      ack_fifo_full  => ack_fifo_full,
      ack_fifo_wr_en => ack_fifo_wr_en,
      ack_fifo_din   => ack_fifo_din,
      clk            => clk_user,
      rst_n          => fade_rst_n,
      dbg            => open,
      cmd            => rx_cmd,
      arg            => rx_arg,
      Rx_Clk         => clk1,
      RxC            => xgmii_rxc,
      RxD            => xgmii_rxd);

  ack_fifo_1 : ack_fifo
    port map (
      rst    => fade_rst_p,
      wr_clk => clk1,
      rd_clk => Clk_user,
      din    => ack_fifo_din,
      wr_en  => ack_fifo_wr_en,
      rd_en  => ack_fifo_rd_en,
      dout   => ack_fifo_dout,
      full   => ack_fifo_full,
      empty  => ack_fifo_empty);


  -- signal generator

  s_dta_we <= '1' when dta_ready = '1' and transmit_data = '1' else '0';

  dta_we <= s_dta_we;

  dta <= std_logic_vector(test_dta);

  process (Clk_user, rst_n)
  begin  -- process
    if fade_rst_n = '0' then            -- asynchronous reset (active low)
      test_dta <= (others => '0');
      td_del0  <= '0';
      td_del1  <= '0';
    elsif Clk_user'event and Clk_user = '1' then  -- rising clock edge
      if s_dta_we = '1' then
        test_dta <= test_dta + x"1234567809abcdef";
      end if;
      -- Generate the dta_eod pulse after transmit_data
      -- goes low
      td_del0 <= transmit_data;
      td_del1 <= td_del0;
      if (td_del1 = '1') and (td_del0 = '0') then
        dta_eod <= '1';
      else
        dta_eod <= '0';
      end if;
    end if;
  end process;

  process (Clk_user, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      fade_rst_n   <= '0';
      fade_rst_del <= '0';
    elsif Clk_user'event and Clk_user = '1' then  -- rising clock edge
      if restart = '1' then
        fade_rst_n   <= '0';
        fade_rst_del <= '0';
      else
        fade_rst_del <= '1';
        fade_rst_n   <= fade_rst_del;
      end if;
    end if;
  end process;

  fade_rst_p <= not fade_rst_n;

end beh1;
