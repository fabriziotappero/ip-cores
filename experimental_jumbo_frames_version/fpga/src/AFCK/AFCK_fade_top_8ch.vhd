library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkt_ack_pkg.all;
use work.desc_mgr_pkg.all;
library unisim;
use unisim.vcomponents.all;

entity afck_10g_2 is

  port (
    gtx10g_txn      : out   std_logic_vector(7 downto 0);
    gtx10g_txp      : out   std_logic_vector(7 downto 0);
    gtx10g_rxn      : in    std_logic_vector(7 downto 0);
    gtx10g_rxp      : in    std_logic_vector(7 downto 0);
    gtx_refclk_n    : in    std_logic_vector(1 downto 0);
    gtx_refclk_p    : in    std_logic_vector(1 downto 0);
    gtx_sfp_disable : out   std_logic_vector(7 downto 0);
    gtx_rate_sel    : out   std_logic_vector(7 downto 0);
    -- Heartbit LED
    hb_led          : out   std_logic_vector(2 downto 0);
    -- Pin needed to enable switch matrix
    clk_updaten     : out   std_logic;
    si570_oe        : out   std_logic;
    -- I2C interface t control FM-S14 board
    scl             : inout std_logic;
    sda             : inout std_logic;
    boot_clk        : in    std_logic
    );

end afck_10g_2;

architecture beh1 of afck_10g_2 is

  constant N_OF_LINKS : integer := 4;
  constant N_OF_QUADS : integer := 2;

  type T_HB is array (0 to 2) of integer;
  signal heart_bit : T_HB                         := (0, 0, 0);
  signal s_hb_led  : std_logic_vector(2 downto 0) := "000";

  signal refclk_p : std_logic_vector(N_OF_QUADS-1 downto 0) := "00";
  signal refclk_n : std_logic_vector(N_OF_QUADS-1 downto 0) := "00";
  signal reset    : std_logic                               := '0';
  signal rst_p    : std_logic                               := '1';  -- generated reset
  signal rst_cnt  : integer                                 := 20000000;

  type T_FRQ_CNT is array (0 to 1) of std_logic_vector(31 downto 0);
  signal frq_user : T_FRQ_CNT := (others => (others => '0'));
  signal clk0_frq, clk1_frq : std_logic_vector(31 downto 0) := (others=>'0');

  signal s_resetdone     : std_logic_vector(N_OF_QUADS-1 downto 0) := "00";
  signal core_clk156_out : std_logic_vector(N_OF_QUADS-1 downto 0) := "00";


  type T_MAC_TABLE is array (0 to N_OF_QUADS*N_OF_LINKS-1) of std_logic_vector(47 downto 0);
  constant mac_table : T_MAC_TABLE := (
    0 => x"de_ad_fa_de_00_e2",
    1 => x"de_ad_fa_de_01_e2",
    2 => x"de_ad_fa_de_02_e2",
    3 => x"de_ad_fa_de_03_e2",
    4 => x"de_ad_fa_de_04_e2",
    5 => x"de_ad_fa_de_05_e2",
    6 => x"de_ad_fa_de_06_e2",
    7 => x"de_ad_fa_de_07_e2"
    );

  signal s_txusrclk_out         : std_logic_vector(N_OF_QUADS-1 downto 0)            := "00";
  signal s_txusrclk2_out        : std_logic_vector(N_OF_QUADS-1 downto 0)            := "00";
  signal areset_clk156_out      : std_logic_vector(N_OF_QUADS-1 downto 0)            := "00";
  signal gttxreset_out          : std_logic_vector(N_OF_QUADS-1 downto 0)            := "00";
  signal gtrxreset_out          : std_logic_vector(N_OF_QUADS-1 downto 0)            := "00";
  signal txuserrdy_out          : std_logic_vector(N_OF_QUADS-1 downto 0)            := "00";
  signal reset_counter_done_out : std_logic_vector(N_OF_QUADS-1 downto 0)            := "00";
  signal qplllock_out           : std_logic_vector(N_OF_QUADS-1 downto 0)            := "00";
  signal qplloutclk_out         : std_logic_vector(N_OF_QUADS-1 downto 0)            := "00";
  signal qplloutrefclk_out      : std_logic_vector(N_OF_QUADS-1 downto 0)            := "00";
  type T_XGMII_XD is array (0 to N_OF_QUADS*N_OF_LINKS-1) of std_logic_vector(63 downto 0);
  signal xgmii_txd              : T_XGMII_XD                                         := (others => (others => '0'));
  type T_XGMII_XC is array (0 to N_OF_QUADS*N_OF_LINKS-1) of std_logic_vector(7 downto 0);
  signal xgmii_txc              : T_XGMII_XC                                         := (others => (others => '0'));
  signal xgmii_rxd              : T_XGMII_XD                                         := (others => (others => '0'));
  signal xgmii_rxc              : T_XGMII_XC                                         := (others => (others => '0'));
  signal configuration_vector   : std_logic_vector(535 downto 0)                     := (others => '0');
  type T_STATUS_VEC is array (0 to N_OF_QUADS*N_OF_LINKS-1) of std_logic_vector(447 downto 0);
  signal status_vector          : T_STATUS_VEC                                       := (others => (others => '0'));
  type T_CORE_STATUS is array (0 to N_OF_QUADS*N_OF_LINKS-1) of std_logic_vector(7 downto 0);
  signal core_status            : T_CORE_STATUS                                      := (others => (others => '0'));
  signal signal_detect          : std_logic_vector(N_OF_QUADS*N_OF_LINKS-1 downto 0) := (others => '0');
  signal tx_fault               : std_logic_vector(N_OF_QUADS*N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_req                : std_logic_vector(N_OF_QUADS*N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_gnt                : std_logic_vector(N_OF_QUADS*N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_den_o              : std_logic_vector(N_OF_QUADS*N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_dwe_o              : std_logic_vector(N_OF_QUADS*N_OF_LINKS-1 downto 0) := (others => '0');
  type T_DRP_V16 is array (0 to N_OF_QUADS*N_OF_LINKS-1) of std_logic_vector(15 downto 0);
  signal drp_daddr_o            : T_DRP_V16                                          := (others => (others => '0'));
  signal drp_di_o               : T_DRP_V16                                          := (others => (others => '0'));
  signal drp_drdy_o             : std_logic_vector(N_OF_QUADS*N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_drpdo_o            : T_DRP_V16                                          := (others => (others => '0'));
  signal drp_den_i              : std_logic_vector(N_OF_QUADS*N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_dwe_i              : std_logic_vector(N_OF_QUADS*N_OF_LINKS-1 downto 0) := (others => '0');

  signal drp_daddr_i : T_DRP_V16                                          := (others => (others => '0'));
  signal drp_di_i    : T_DRP_V16                                          := (others => (others => '0'));
  signal drp_drdy_i  : std_logic_vector(N_OF_QUADS*N_OF_LINKS-1 downto 0) := (others => '0');
  signal drp_drpdo_i : T_DRP_V16                                          := (others => (others => '0'));
  signal tx_disable  : std_logic_vector(N_OF_QUADS*N_OF_LINKS-1 downto 0) := (others => '0');

  --signal counter              : integer   := 0;
  --signal probe2               : std_logic_vector(2 downto 0);
  --signal trig_in, trig_in_ack : std_logic := '0';
  signal rst_n      : std_logic := '0';
  signal rst1, clk1 : std_logic := '0';
  signal clk_user   : std_logic_vector(N_OF_QUADS-1 downto 0);

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

  component frq_counter is
    generic (
      CNT_TIME   : integer;
      CNT_LENGTH : integer);
    port (
      ref_clk : in  std_logic;
      rst_p   : in  std_logic;
      frq_in  : in  std_logic;
      frq_out : out std_logic_vector(CNT_LENGTH-1 downto 0));
  end component frq_counter;
  
  component vio_stat is
    port (
      clk       : in std_logic;
      probe_in0 : in std_logic_vector(7 downto 0);
      probe_in1 : in std_logic_vector(7 downto 0);
      probe_in2 : in std_logic_vector(7 downto 0);
      probe_in3 : in std_logic_vector(7 downto 0);
      probe_in4 : in std_logic_vector(7 downto 0);
      probe_in5 : in std_logic_vector(7 downto 0);
      probe_in6 : in std_logic_vector(7 downto 0);
      probe_in7 : in std_logic_vector(7 downto 0)
      );
  end component;

begin  -- beh1
  si570_oe <= '1';
  clk_updaten <= '1';
  -- Initialization vector
  --configuration_vector(0) <= '1';     -- PMA loopback  
  --configuration_vector(110) <= '1';     -- PCS loopback
  configuration_vector(33)  <= '1';     -- training
  configuration_vector(284) <= '1';     -- auto negotiation

  signal_detect   <= (others => '1');   -- allow transmission!
  gtx_sfp_disable <= (others => '0');
  gtx_rate_sel <= (others => '1');

  -- Reset generator
  process (boot_clk) is
  begin  -- process
    if boot_clk'event and boot_clk = '1' then  -- rising clock edge
      if rst_cnt > 0 then
        rst_cnt <= rst_cnt - 1;
      else
        rst_p <= '0';
      end if;
    end if;
  end process;


  rst_n    <= not rst_p;
  refclk_n <= gtx_refclk_n;
  refclk_p <= gtx_refclk_p;
  reset    <= not rst_n;

  --trig_in <= '1' when xgmii_rxc /= x"ff" else '0';

  gl1 : for q in 0 to N_OF_QUADS-1 generate
    gl2 : for n in 0 to N_OF_LINKS-1 generate

      il1 : if n = 0 generate
        ten_gig_eth_pcs_pma_0_1 : ten_gig_eth_pcs_pma_0
          port map (
            dclk                   => core_clk156_out(q),
            sim_speedup_control    => '0',
            refclk_p               => refclk_p(q),
            refclk_n               => refclk_n(q),
            reset                  => reset,
            resetdone              => s_resetdone(q),
            core_clk156_out        => core_clk156_out(q),
            txp                    => gtx10g_txp(q*N_OF_LINKS+n),
            txn                    => gtx10g_txn(q*N_OF_LINKS+n),
            rxp                    => gtx10g_rxp(q*N_OF_LINKS+n),
            rxn                    => gtx10g_rxn(q*N_OF_LINKS+n),
            txusrclk_out           => s_txusrclk_out(q),
            txusrclk2_out          => s_txusrclk2_out(q),
            areset_clk156_out      => areset_clk156_out(q),
            gttxreset_out          => gttxreset_out(q),
            gtrxreset_out          => gtrxreset_out(q),
            txuserrdy_out          => txuserrdy_out(q),
            reset_counter_done_out => reset_counter_done_out(q),
            qplllock_out           => qplllock_out(q),
            qplloutclk_out         => qplloutclk_out(q),
            qplloutrefclk_out      => qplloutrefclk_out(q),
            xgmii_txd              => xgmii_txd(q*N_OF_LINKS+n),
            xgmii_txc              => xgmii_txc(q*N_OF_LINKS+n),
            xgmii_rxd              => xgmii_rxd(q*N_OF_LINKS+n),
            xgmii_rxc              => xgmii_rxc(q*N_OF_LINKS+n),
            configuration_vector   => configuration_vector,
            status_vector          => status_vector(q*N_OF_LINKS+n),
            core_status            => core_status(q*N_OF_LINKS+n),
            signal_detect          => signal_detect(q*N_OF_LINKS+n),
            tx_fault               => tx_fault(q*N_OF_LINKS+n),
            drp_req                => drp_req(q*N_OF_LINKS+n),
            drp_gnt                => drp_gnt(q*N_OF_LINKS+n),
            drp_den_o              => drp_den_o(q*N_OF_LINKS+n),
            drp_dwe_o              => drp_dwe_o(q*N_OF_LINKS+n),
            drp_daddr_o            => drp_daddr_o(q*N_OF_LINKS+n),
            drp_di_o               => drp_di_o(q*N_OF_LINKS+n),
            drp_drdy_o             => drp_drdy_o(q*N_OF_LINKS+n),
            drp_drpdo_o            => drp_drpdo_o(q*N_OF_LINKS+n),
            drp_den_i              => drp_den_i(q*N_OF_LINKS+n),
            drp_dwe_i              => drp_dwe_i(q*N_OF_LINKS+n),
            drp_daddr_i            => drp_daddr_i(q*N_OF_LINKS+n),
            drp_di_i               => drp_di_i(q*N_OF_LINKS+n),
            drp_drdy_i             => drp_drdy_i(q*N_OF_LINKS+n),
            drp_drpdo_i            => drp_drpdo_i(q*N_OF_LINKS+n),
            tx_disable             => tx_disable(q*N_OF_LINKS+n),
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
            dclk                 => core_clk156_out(q),
            clk156               => core_clk156_out(q),
            txusrclk             => s_txusrclk_out(q),
            txusrclk2            => s_txusrclk2_out(q),
            txclk322             => open,
            areset               => reset,
            areset_clk156        => areset_clk156_out(q),
            gttxreset            => gttxreset_out(q),
            gtrxreset            => gtrxreset_out(q),
            sim_speedup_control  => '0',
            txuserrdy            => txuserrdy_out(q),
            qplllock             => qplllock_out(q),
            qplloutclk           => qplloutclk_out(q),
            qplloutrefclk        => qplloutrefclk_out(q),
            reset_counter_done   => reset_counter_done_out(q),
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
            xgmii_txd            => xgmii_txd(q*N_OF_LINKS+n),
            xgmii_txc            => xgmii_txc(q*N_OF_LINKS+n),
            xgmii_rxd            => xgmii_rxd(q*N_OF_LINKS+n),
            xgmii_rxc            => xgmii_rxc(q*N_OF_LINKS+n),
            txp                  => gtx10g_txp(q*N_OF_LINKS+n),
            txn                  => gtx10g_txn(q*N_OF_LINKS+n),
            rxp                  => gtx10g_rxp(q*N_OF_LINKS+n),
            rxn                  => gtx10g_rxn(q*N_OF_LINKS+n),
            configuration_vector => configuration_vector,
            status_vector        => status_vector(q*N_OF_LINKS+n),
            core_status          => core_status(q*N_OF_LINKS+n),
            tx_resetdone         => open,
            rx_resetdone         => open,
            signal_detect        => signal_detect(q*N_OF_LINKS+n),
            tx_fault             => tx_fault(q*N_OF_LINKS+n),
            drp_req              => drp_req(q*N_OF_LINKS+n),
            drp_gnt              => drp_gnt(q*N_OF_LINKS+n),
            drp_den_o            => drp_den_o(q*N_OF_LINKS+n),
            drp_dwe_o            => drp_dwe_o(q*N_OF_LINKS+n),
            drp_daddr_o          => drp_daddr_o(q*N_OF_LINKS+n),
            drp_di_o             => drp_di_o(q*N_OF_LINKS+n),
            drp_drdy_i           => drp_drdy_i(q*N_OF_LINKS+n),
            drp_drpdo_i          => drp_drpdo_i(q*N_OF_LINKS+n),
            drp_den_i            => drp_den_i(q*N_OF_LINKS+n),
            drp_dwe_i            => drp_dwe_i(q*N_OF_LINKS+n),
            drp_daddr_i          => drp_daddr_i(q*N_OF_LINKS+n),
            drp_di_i             => drp_di_i(q*N_OF_LINKS+n),
            drp_drdy_o           => drp_drdy_o(q*N_OF_LINKS+n),
            drp_drpdo_o          => drp_drpdo_o(q*N_OF_LINKS+n),
            pma_pmd_type         => "111",
            tx_disable           => tx_disable(q*N_OF_LINKS+n));
      end generate il2;

      drp_gnt(q*N_OF_LINKS+n)     <= drp_req(q*N_OF_LINKS+n);
      drp_den_i(q*N_OF_LINKS+n)   <= drp_den_o(q*N_OF_LINKS+n);
      drp_dwe_i(q*N_OF_LINKS+n)   <= drp_dwe_o(q*N_OF_LINKS+n);
      drp_daddr_i(q*N_OF_LINKS+n) <= drp_daddr_o(q*N_OF_LINKS+n);
      drp_di_i(q*N_OF_LINKS+n)    <= drp_di_o(q*N_OF_LINKS+n);
      drp_drpdo_i(q*N_OF_LINKS+n) <= drp_drpdo_o(q*N_OF_LINKS+n);

      fade_one_channel_1 : entity work.fade_one_channel
        generic map (
          my_mac => mac_table(q*N_OF_LINKS+n))
        port map (
          xgmii_txd => xgmii_txd(q*N_OF_LINKS+n),
          xgmii_txc => xgmii_txc(q*N_OF_LINKS+n),
          xgmii_rxd => xgmii_rxd(q*N_OF_LINKS+n),
          xgmii_rxc => xgmii_rxc(q*N_OF_LINKS+n),
          rst_n     => rst_n,
          clk_user  => clk_user(q));

      
    end generate gl2;

    frq_counter_1: entity work.frq_counter
        generic map (
          CNT_TIME   => 20000000,
          CNT_LENGTH => 32)
        port map (
          ref_clk => boot_clk,
          rst_p   => rst_p,
          frq_in  => clk_user(q),
          frq_out => frq_user(q));


  end generate gl1;

  clk0_frq <= frq_user(0);
  clk1_frq <= frq_user(1);
  
  rst1     <= core_status(0)(0);
  --core_ready <= core_status(0);
  clk1     <= boot_clk;
  clk_user <= core_clk156_out;

  -- Frequency meters
  vio_frq_1 : entity work.vio_frq
    port map (
      clk       => boot_clk,
      probe_in0 => clk0_frq,
      probe_in1 => clk1_frq);

  -- Vio Link statuses
  vio_stat_1 : entity work.vio_stat
    port map (
      clk       => boot_clk,
      probe_in0 => core_status(0),
      probe_in1 => core_status(1),
      probe_in2 => core_status(2),
      probe_in3 => core_status(3),
      probe_in4 => core_status(4),
      probe_in5 => core_status(5),
      probe_in6 => core_status(6),
      probe_in7 => core_status(7));

  -- JTAG<->I2C part for clock-crossbar
  i2c_vio_ctrl_1 : entity work.i2c_vio_ctrl
    port map (
      clk => boot_clk,
      scl => scl,
      sda => sda);

  gld1 : for i in 0 to 1 generate
    p1 : process (clk_user(i), rst_n)
    begin  -- process p1
      if rst_n = '0' then               -- asynchronous reset (active low)
        heart_bit(i) <= 0;
      elsif clk_user(i)'event and clk_user(i) = '1' then  -- rising clock edge
        if heart_bit(i) < 80000000 then
          heart_bit(i) <= heart_bit(i) + 1;
        else
          heart_bit(i) <= 0;
          s_hb_led(i)  <= not s_hb_led(i);
        end if;
      end if;
    end process p1;

  end generate gld1;

  p2 : process (boot_clk, rst_n)
  begin  -- process p1
    if rst_n = '0' then                 -- asynchronous reset (active low)
      heart_bit(2) <= 0;
    elsif boot_clk'event and boot_clk = '1' then  -- rising clock edge
      if heart_bit(2) < 10000000 then
        heart_bit(2) <= heart_bit(2) + 1;
      else
        heart_bit(2) <= 0;
        s_hb_led(2)  <= not s_hb_led(2);
      end if;
    end if;
  end process p2;

  hb_led <= s_hb_led;

end beh1;
