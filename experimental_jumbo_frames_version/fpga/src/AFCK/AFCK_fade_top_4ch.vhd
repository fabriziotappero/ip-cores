library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkt_ack_pkg.all;
use work.desc_mgr_pkg.all;
library unisim;
use unisim.vcomponents.all;

entity afck_10g_2 is

  port (
    gtx10g_txn      : out std_logic_vector(3 downto 0);
    gtx10g_txp      : out std_logic_vector(3 downto 0);
    gtx10g_rxn      : in  std_logic_vector(3 downto 0);
    gtx10g_rxp      : in  std_logic_vector(3 downto 0);
    gtx_refclk_n    : in  std_logic;
    gtx_refclk_p    : in  std_logic;
    gtx_sfp_disable : out std_logic_vector(3 downto 0);
    gtx_rate_sel    : out std_logic_vector(3 downto 0);
    si570_oe        : out   std_logic;
    clk_2_n         : in  std_logic;
    clk_2_p         : in  std_logic
    );

end afck_10g_2;

architecture beh1 of afck_10g_2 is

  constant N_OF_LINKS : integer := 4;
  
  signal heart_bit : integer := 0;

  signal refclk_p                 : std_logic := '0';
  signal refclk_n                 : std_logic := '0';
  signal reset                    : std_logic := '0';
  signal clk_rst_buf, clk_rst_156 : std_logic := '1';  -- generated reset
  signal rst_p                    : std_logic := '1';  -- generated reset
  signal rst_cnt                  : integer   := 200000000;


  signal s_resetdone     : std_logic := '0';
  signal core_clk156_out : std_logic := '0';


  type T_MAC_TABLE is array (0 to N_OF_LINKS-1) of std_logic_vector(47 downto 0);
  constant mac_table : T_MAC_TABLE := (
    0 => x"de_ad_fa_de_00_e2",
    1 => x"de_ad_fa_de_01_e2",
    2 => x"de_ad_fa_de_02_e2",
    3 => x"de_ad_fa_de_03_e2"
    );

  signal s_txusrclk_out         : std_logic                               := '0';
  signal s_txusrclk2_out        : std_logic                               := '0';
  signal areset_clk156_out      : std_logic                               := '0';
  signal gttxreset_out          : std_logic                               := '0';
  signal gtrxreset_out          : std_logic                               := '0';
  signal txuserrdy_out          : std_logic                               := '0';
  signal reset_counter_done_out : std_logic                               := '0';
  signal qplllock_out           : std_logic                               := '0';
  signal qplloutclk_out         : std_logic                               := '0';
  signal qplloutrefclk_out      : std_logic                               := '0';
  type T_XGMII_XD is array (0 to N_OF_LINKS-1) of std_logic_vector(63 downto 0);
  signal xgmii_txd              : T_XGMII_XD                              := (others => (others => '0'));
  type T_XGMII_XC is array (0 to N_OF_LINKS-1) of std_logic_vector(7 downto 0);
  signal xgmii_txc              : T_XGMII_XC                              := (others => (others => '0'));
  signal xgmii_rxd              : T_XGMII_XD                              := (others => (others => '0'));
  signal xgmii_rxc              : T_XGMII_XC                              := (others => (others => '0'));
  signal configuration_vector   : std_logic_vector(535 downto 0)          := (others => '0');
  type T_STATUS_VEC is array (0 to N_OF_LINKS-1) of std_logic_vector(447 downto 0);
  signal status_vector          : T_STATUS_VEC                            := (others => (others => '0'));
  type T_CORE_STATUS is array (0 to N_OF_LINKS-1) of std_logic_vector(7 downto 0);
  signal core_status            : T_CORE_STATUS                           := (others => (others => '0'));
  signal signal_detect          : std_logic_vector(N_OF_LINKS-1 downto 0) := (others => '0');
  signal tx_fault               : std_logic_vector(N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_req                : std_logic_vector(N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_gnt                : std_logic_vector(N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_den_o              : std_logic_vector(N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_dwe_o              : std_logic_vector(N_OF_LINKS-1 downto 0) := (others => '0');
  type T_DRP_V16 is array (0 to N_OF_LINKS-1) of std_logic_vector(15 downto 0);
  signal drp_daddr_o            : T_DRP_V16                               := (others => (others => '0'));
  signal drp_di_o               : T_DRP_V16                               := (others => (others => '0'));
  signal drp_drdy_o             : std_logic_vector(N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_drpdo_o            : T_DRP_V16                               := (others => (others => '0'));
  signal drp_den_i              : std_logic_vector(N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_dwe_i              : std_logic_vector(N_OF_LINKS-1 downto 0) := (others => '0');

  signal drp_daddr_i : T_DRP_V16                               := (others => (others => '0'));
  signal drp_di_i    : T_DRP_V16                               := (others => (others => '0'));
  signal drp_drdy_i  : std_logic_vector(N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_drpdo_i : T_DRP_V16                               := (others => (others => '0'));
  signal tx_disable  : std_logic_vector(N_OF_LINKS-1 downto 0) := (others => '0');

  --signal counter              : integer   := 0;
  --signal probe2               : std_logic_vector(2 downto 0);
  --signal trig_in, trig_in_ack : std_logic := '0';
  signal rst_n      : std_logic := '0';
  signal rst1, clk1 : std_logic := '0';
  signal hb_led     : std_logic := '0';
  signal clk_user   : std_logic;

  component ten_gig_eth_pcs_pma_0 is
    port (
      dclk                   : in  std_logic;
      refclk_p               : in  std_logic;
      refclk_n               : in  std_logic;
      sim_speedup_control    : in  std_logic;
      core_clk156_out        : out std_logic;
      qplloutclk_out         : out std_logic;
      qplloutrefclk_out      : out std_logic;
      qplllock_out           : out std_logic;
      txusrclk_out           : out std_logic;
      txusrclk2_out          : out std_logic;
      areset_clk156_out      : out std_logic;
      gttxreset_out          : out std_logic;
      gtrxreset_out          : out std_logic;
      txuserrdy_out          : out std_logic;
      reset_counter_done_out : out std_logic;
      reset                  : in  std_logic;
      gt0_eyescanreset       : in  std_logic;
      gt0_eyescantrigger     : in  std_logic;
      gt0_rxcdrhold          : in  std_logic;
      gt0_txprbsforceerr     : in  std_logic;
      gt0_txpolarity         : in  std_logic;
      gt0_rxpolarity         : in  std_logic;
      gt0_rxrate             : in  std_logic_vector (2 downto 0);
      gt0_txpmareset         : in  std_logic;
      gt0_rxpmareset         : in  std_logic;
      gt0_rxdfelpmreset      : in  std_logic;
      gt0_txprecursor        : in  std_logic_vector (4 downto 0);
      gt0_txpostcursor       : in  std_logic_vector (4 downto 0);
      gt0_txdiffctrl         : in  std_logic_vector (3 downto 0);
      gt0_rxlpmen            : in  std_logic;
      gt0_eyescandataerror   : out std_logic;
      gt0_txbufstatus        : out std_logic_vector (1 downto 0);
      gt0_txresetdone        : out std_logic;
      gt0_rxresetdone        : out std_logic;
      gt0_rxbufstatus        : out std_logic_vector (2 downto 0);
      gt0_rxprbserr          : out std_logic;
      gt0_dmonitorout        : out std_logic_vector (7 downto 0);
      xgmii_txd              : in  std_logic_vector (63 downto 0);
      xgmii_txc              : in  std_logic_vector (7 downto 0);
      xgmii_rxd              : out std_logic_vector (63 downto 0);
      xgmii_rxc              : out std_logic_vector (7 downto 0);
      txp                    : out std_logic;
      txn                    : out std_logic;
      rxp                    : in  std_logic;
      rxn                    : in  std_logic;
      configuration_vector   : in  std_logic_vector (535 downto 0);
      status_vector          : out std_logic_vector (447 downto 0);
      core_status            : out std_logic_vector (7 downto 0);
      resetdone              : out std_logic;
      signal_detect          : in  std_logic;
      tx_fault               : in  std_logic;
      drp_req                : out std_logic;
      drp_gnt                : in  std_logic;
      drp_den_o              : out std_logic;
      drp_dwe_o              : out std_logic;
      drp_daddr_o            : out std_logic_vector (15 downto 0);
      drp_di_o               : out std_logic_vector (15 downto 0);
      drp_drdy_i             : in  std_logic;
      drp_drpdo_i            : in  std_logic_vector (15 downto 0);
      drp_den_i              : in  std_logic;
      drp_dwe_i              : in  std_logic;
      drp_daddr_i            : in  std_logic_vector (15 downto 0);
      drp_di_i               : in  std_logic_vector (15 downto 0);
      drp_drdy_o             : out std_logic;
      drp_drpdo_o            : out std_logic_vector (15 downto 0);
      pma_pmd_type           : in  std_logic_vector (2 downto 0);
      tx_disable             : out std_logic);
  end component ten_gig_eth_pcs_pma_0;

  component ten_gig_eth_pcs_pma_1 is
    port (
      dclk                 : in  std_logic;
      clk156               : in  std_logic;
      txusrclk             : in  std_logic;
      txusrclk2            : in  std_logic;
      txclk322             : out std_logic;
      areset               : in  std_logic;
      areset_clk156        : in  std_logic;
      gttxreset            : in  std_logic;
      gtrxreset            : in  std_logic;
      sim_speedup_control  : in  std_logic;
      txuserrdy            : in  std_logic;
      qplllock             : in  std_logic;
      qplloutclk           : in  std_logic;
      qplloutrefclk        : in  std_logic;
      reset_counter_done   : in  std_logic;
      gt0_eyescanreset     : in  std_logic;
      gt0_eyescantrigger   : in  std_logic;
      gt0_rxcdrhold        : in  std_logic;
      gt0_txprbsforceerr   : in  std_logic;
      gt0_txpolarity       : in  std_logic;
      gt0_rxpolarity       : in  std_logic;
      gt0_rxrate           : in  std_logic_vector (2 downto 0);
      gt0_txpmareset       : in  std_logic;
      gt0_rxpmareset       : in  std_logic;
      gt0_rxdfelpmreset    : in  std_logic;
      gt0_txprecursor      : in  std_logic_vector (4 downto 0);
      gt0_txpostcursor     : in  std_logic_vector (4 downto 0);
      gt0_txdiffctrl       : in  std_logic_vector (3 downto 0);
      gt0_rxlpmen          : in  std_logic;
      gt0_eyescandataerror : out std_logic;
      gt0_txbufstatus      : out std_logic_vector (1 downto 0);
      gt0_txresetdone      : out std_logic;
      gt0_rxresetdone      : out std_logic;
      gt0_rxbufstatus      : out std_logic_vector (2 downto 0);
      gt0_rxprbserr        : out std_logic;
      gt0_dmonitorout      : out std_logic_vector (7 downto 0);
      xgmii_txd            : in  std_logic_vector (63 downto 0);
      xgmii_txc            : in  std_logic_vector (7 downto 0);
      xgmii_rxd            : out std_logic_vector (63 downto 0);
      xgmii_rxc            : out std_logic_vector (7 downto 0);
      txp                  : out std_logic;
      txn                  : out std_logic;
      rxp                  : in  std_logic;
      rxn                  : in  std_logic;
      configuration_vector : in  std_logic_vector (535 downto 0);
      status_vector        : out std_logic_vector (447 downto 0);
      core_status          : out std_logic_vector (7 downto 0);
      tx_resetdone         : out std_logic;
      rx_resetdone         : out std_logic;
      signal_detect        : in  std_logic;
      tx_fault             : in  std_logic;
      drp_req              : out std_logic;
      drp_gnt              : in  std_logic;
      drp_den_o            : out std_logic;
      drp_dwe_o            : out std_logic;
      drp_daddr_o          : out std_logic_vector (15 downto 0);
      drp_di_o             : out std_logic_vector (15 downto 0);
      drp_drdy_i           : in  std_logic;
      drp_drpdo_i          : in  std_logic_vector (15 downto 0);
      drp_den_i            : in  std_logic;
      drp_dwe_i            : in  std_logic;
      drp_daddr_i          : in  std_logic_vector (15 downto 0);
      drp_di_i             : in  std_logic_vector (15 downto 0);
      drp_drdy_o           : out std_logic;
      drp_drpdo_o          : out std_logic_vector (15 downto 0);
      pma_pmd_type         : in  std_logic_vector (2 downto 0);
      tx_disable           : out std_logic);
  end component ten_gig_eth_pcs_pma_1;

  component fade_one_channel is
    generic (
      my_mac : std_logic_vector(47 downto 0));
    port (
      xgmii_txd : out std_logic_vector(63 downto 0);
      xgmii_txc : out std_logic_vector(7 downto 0);
      xgmii_rxd : in  std_logic_vector(63 downto 0);
      xgmii_rxc : in  std_logic_vector(7 downto 0);
      rst_n     : in  std_logic;
      clk_user  : in  std_logic);
  end component fade_one_channel;

begin  -- beh1
  si570_oe <= '1';
  -- Initialization vector
  configuration_vector(33)  <= '1';     -- training
  configuration_vector(284) <= '1';     -- auto negotiation

  gtx_rate_sel <= (others => '1');
  signal_detect   <= (others => '1');   -- allow transmission!
  gtx_sfp_disable <= (others => '0');

  -- Reset generator
  process (clk_rst_156) is
  begin  -- process
    if clk_rst_156'event and clk_rst_156 = '1' then  -- rising clock edge
      if rst_cnt > 0 then
        rst_cnt <= rst_cnt - 1;
      else
        rst_p <= '0';
      end if;
    end if;
  end process;

  cmp_gtp_dedicated_clk_buf : IBUFDS_GTE2
    -- generic map(
    -- DIFF_TERM    => true,
    -- IBUF_LOW_PWR => true,
    -- IOSTANDARD   => "DEFAULT")
    port map (
      O     => clk_rst_buf,
      ODIV2 => open,
      CEB   => '0',
      I     => clk_2_p,
      IB    => clk_2_n
      );

  cmp_clk_ref_buf : BUFG
    port map (
      O => clk_rst_156,
      I => clk_rst_buf);

  rst_n    <= not rst_p;
  refclk_n <= gtx_refclk_n;
  refclk_p <= gtx_refclk_p;
  reset    <= not rst_n;

  --trig_in <= '1' when xgmii_rxc /= x"ff" else '0';
  gl1 : for n in 0 to N_OF_LINKS-1 generate

    il1 : if n = 0 generate
      ten_gig_eth_pcs_pma_0_1 : ten_gig_eth_pcs_pma_0
        port map (
          dclk                   => clk_user,
          sim_speedup_control    => '0',
          refclk_p               => refclk_p,
          refclk_n               => refclk_n,
          reset                  => reset,
          resetdone              => s_resetdone,
          core_clk156_out        => core_clk156_out,
          txp                    => gtx10g_txp(n),
          txn                    => gtx10g_txn(n),
          rxp                    => gtx10g_rxp(n),
          rxn                    => gtx10g_rxn(n),
          txusrclk_out           => s_txusrclk_out,
          txusrclk2_out          => s_txusrclk2_out,
          areset_clk156_out      => areset_clk156_out,
          gttxreset_out          => gttxreset_out,
          gtrxreset_out          => gtrxreset_out,
          txuserrdy_out          => txuserrdy_out,
          reset_counter_done_out => reset_counter_done_out,
          qplllock_out           => qplllock_out,
          qplloutclk_out         => qplloutclk_out,
          qplloutrefclk_out      => qplloutrefclk_out,
          xgmii_txd              => xgmii_txd(n),
          xgmii_txc              => xgmii_txc(n),
          xgmii_rxd              => xgmii_rxd(n),
          xgmii_rxc              => xgmii_rxc(n),
          configuration_vector   => configuration_vector,
          status_vector          => status_vector(n),
          core_status            => core_status(n),
          signal_detect          => signal_detect(n),
          tx_fault               => tx_fault(n),
          drp_req                => drp_req(n),
          drp_gnt                => drp_gnt(n),
          drp_den_o              => drp_den_o(n),
          drp_dwe_o              => drp_dwe_o(n),
          drp_daddr_o            => drp_daddr_o(n),
          drp_di_o               => drp_di_o(n),
          drp_drdy_o             => drp_drdy_o(n),
          drp_drpdo_o            => drp_drpdo_o(n),
          drp_den_i              => drp_den_i(n),
          drp_dwe_i              => drp_dwe_i(n),
          drp_daddr_i            => drp_daddr_i(n),
          drp_di_i               => drp_di_i(n),
          drp_drdy_i             => drp_drdy_i(n),
          drp_drpdo_i            => drp_drpdo_i(n),
          tx_disable             => tx_disable(n),
          pma_pmd_type           => "111",
          gt0_eyescanreset       => '0',
          gt0_eyescandataerror   => open,
          gt0_txbufstatus        => open,
          gt0_rxbufstatus        => open,
          gt0_eyescantrigger     => '0',
          gt0_rxcdrhold          => '0',
          gt0_txprbsforceerr     => '0',
          gt0_txpolarity         => '0',
          gt0_rxpolarity         => '0',
          gt0_rxprbserr          => open,
          gt0_txpmareset         => '0',
          gt0_rxpmareset         => '0',
          gt0_txresetdone        => open,
          gt0_rxresetdone        => open,
          gt0_rxdfelpmreset      => '0',
          gt0_rxlpmen            => '0',
          gt0_dmonitorout        => open,
          gt0_rxrate             => (others => '0'),
          gt0_txprecursor        => (others => '0'),
          gt0_txpostcursor       => (others => '0'),
          gt0_txdiffctrl         => "1110"

          );

    end generate il1;
    il2 : if n /= 0 generate
      ten_gig_eth_pcs_pma_1_1 : entity work.ten_gig_eth_pcs_pma_1
        port map (
          dclk                 => clk_user,
          clk156               => core_clk156_out,
          txusrclk             => s_txusrclk_out,
          txusrclk2            => s_txusrclk2_out,
          txclk322             => open,
          areset               => reset,
          areset_clk156        => areset_clk156_out,
          gttxreset            => gttxreset_out,
          gtrxreset            => gtrxreset_out,
          sim_speedup_control  => '0',
          txuserrdy            => txuserrdy_out,
          qplllock             => qplllock_out,
          qplloutclk           => qplloutclk_out,
          qplloutrefclk        => qplloutrefclk_out,
          reset_counter_done   => reset_counter_done_out,
          gt0_eyescanreset     => '0',
          gt0_eyescantrigger   => '0',
          gt0_rxcdrhold        => '0',
          gt0_txprbsforceerr   => '0',
          gt0_txpolarity       => '0',
          gt0_rxpolarity       => '0',
          gt0_rxrate           => (others => '0'),
          gt0_txpmareset       => '0',
          gt0_rxpmareset       => '0',
          gt0_rxdfelpmreset    => '0',
          gt0_txprecursor      => (others => '0'),
          gt0_txpostcursor     => (others => '0'),
          gt0_txdiffctrl       => "1110",
          gt0_rxlpmen          => '0',
          gt0_eyescandataerror => open,
          gt0_txbufstatus      => open,
          gt0_txresetdone      => open,
          gt0_rxresetdone      => open,
          gt0_rxbufstatus      => open,
          gt0_rxprbserr        => open,
          gt0_dmonitorout      => open,
          xgmii_txd            => xgmii_txd(n),
          xgmii_txc            => xgmii_txc(n),
          xgmii_rxd            => xgmii_rxd(n),
          xgmii_rxc            => xgmii_rxc(n),
          txp                  => gtx10g_txp(n),
          txn                  => gtx10g_txn(n),
          rxp                  => gtx10g_rxp(n),
          rxn                  => gtx10g_rxn(n),
          configuration_vector => configuration_vector,
          status_vector        => status_vector(n),
          core_status          => core_status(n),
          tx_resetdone         => open,
          rx_resetdone         => open,
          signal_detect        => signal_detect(n),
          tx_fault             => tx_fault(n),
          drp_req              => drp_req(n),
          drp_gnt              => drp_gnt(n),
          drp_den_o            => drp_den_o(n),
          drp_dwe_o            => drp_dwe_o(n),
          drp_daddr_o          => drp_daddr_o(n),
          drp_di_o             => drp_di_o(n),
          drp_drdy_i           => drp_drdy_i(n),
          drp_drpdo_i          => drp_drpdo_i(n),
          drp_den_i            => drp_den_i(n),
          drp_dwe_i            => drp_dwe_i(n),
          drp_daddr_i          => drp_daddr_i(n),
          drp_di_i             => drp_di_i(n),
          drp_drdy_o           => drp_drdy_o(n),
          drp_drpdo_o          => drp_drpdo_o(n),
          pma_pmd_type         => "111",
          tx_disable           => tx_disable(n));
    end generate il2;

    drp_gnt(n)     <= drp_req(n);
    drp_den_i(n)   <= drp_den_o(n);
    drp_dwe_i(n)   <= drp_dwe_o(n);
    drp_daddr_i(n) <= drp_daddr_o(n);
    drp_di_i(n)    <= drp_di_o(n);
    drp_drpdo_i(n) <= drp_drpdo_o(n);

    fade_one_channel_1 : entity work.fade_one_channel
      generic map (
        my_mac => mac_table(n))
      port map (
        xgmii_txd => xgmii_txd(n),
        xgmii_txc => xgmii_txc(n),
        xgmii_rxd => xgmii_rxd(n),
        xgmii_rxc => xgmii_rxc(n),
        rst_n     => rst_n,
        clk_user  => clk_user);



  end generate gl1;

  rst1     <= core_status(0)(0);
  --core_ready <= core_status(0);
  clk1     <= core_clk156_out;
  clk_user <= core_clk156_out;

  p1 : process (clk1, rst_n)
  begin  -- process p1
    if rst_n = '0' then                   -- asynchronous reset (active low)
      heart_bit <= 0;
    elsif clk1'event and clk1 = '1' then  -- rising clock edge
      if heart_bit < 80000000 then
        heart_bit <= heart_bit + 1;
      else
        heart_bit <= 0;
        hb_led    <= not hb_led;
      end if;
    end if;
  end process p1;


end beh1;
