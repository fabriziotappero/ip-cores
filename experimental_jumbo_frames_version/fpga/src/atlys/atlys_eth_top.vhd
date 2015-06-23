-------------------------------------------------------------------------------
-- Title      : L3 FADE protocol demo for Digilent Atlys board
-- Project    : 
-------------------------------------------------------------------------------
-- File       : atlys_eth_top.vhd
-- Author     : Wojciech M. Zabolotny <wzab@ise.pw.edu.pl>
-- License    : BSD License
-- Company    : 
-- Created    : 2010-08-03
-- Last update: 2014-11-15
-- Platform   : 
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- This file implements the top entity, integrating all component
-------------------------------------------------------------------------------
-- Copyright (c) 2012
-- This is public domain code!!!
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-08-03  1.0      wzab    Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.pkt_ack_pkg.all;
use work.desc_mgr_pkg.all;

entity atlys_eth is

  port (
    cpu_reset : in std_logic;
--    -- DDR2 interface
--    ddr2_a : out std_logic_vector(12 downto 0);
--    ddr2_ba : out std_logic_vector(2 downto 0);
--    ddr2_cas_b : out std_logic;
--    ddr2_cke : out std_logic;
--    ddr2_clk_n : out std_logic;
--    ddr2_clk_p : out std_logic;
--    ddr2_dq : inout std_logic_vector(15 downto 0);
--    ddr2_ldm : out std_logic;
--    ddr2_ldqs_n : out std_logic;
--    ddr2_ldqs_p : out std_logic;
--    ddr2_odt : out std_logic;
--    ddr2_ras_b : out std_logic;
--    ddr2_udm : out std_logic;
--    ddr2_udqs_n : out std_logic;
--    ddr2_udqs_p : out std_logic;
--    ddr2_we_b : out std_logic;
--    -- FLASH interface
--    flash_a : out std_logic_vector(24 downto 0);
--    flash_ce_b   : out std_logic;
--    flash_d : inout std_logic_vector(7 downto 0);
--    flash_oe_b   : out std_logic;
--    flash_we_b   : out std_logic;
--    -- FMC interface
--    fmc_la28_n   : out std_logic;
--    fmc_la28_p   : out std_logic;
--    fmc_la29_n   : out std_logic;
--    fmc_la29_p   : out std_logic;
--    fmc_la30_n   : out std_logic;
--    fmc_la30_p   : out std_logic;
--    fmc_la31_n   : out std_logic;
--    fmc_la31_p   : out std_logic;
--    iic_scl_main : out std_logic;
--    iic_sda_main : out std_logic;

    --gpio_hdr : in std_logic_vector(7 downto 0);

--    fmc_clk0_m2c_n : out std_logic;
--    fmc_clk0_m2c_p : out std_logic;
--    fmc_clk1_m2c_n : out std_logic;
--    fmc_clk1_m2c_p : out std_logic;
--    fmc_la00_cc_n : out std_logic;    
--    fmc_la00_cc_p : out std_logic;    
--    fmc_la01_cc_n : out std_logic;    
--    fmc_la01_cc_p : out std_logic;    
--    fmc_la02_n : out std_logic;    
--    fmc_la02_p : out std_logic;    
--    fmc_la03_n : out std_logic;    
--    fmc_la03_p : out std_logic;    
--    fmc_la04_n : out std_logic;    
--    fmc_la04_p : out std_logic;    
--    led       : out std_logic_vector(3 downto 0);
    switches       : in    std_logic_vector(7 downto 0);
--    flash_oen : out std_logic;
--    flash_wen : out std_logic;
--    flash_cen : out std_logic;
    gpio_led       : out   std_logic_vector(7 downto 0);
    -- PHY interface
    phy_col        : in    std_logic;
    phy_crs        : in    std_logic;
    phy_int        : in    std_logic;
    phy_mdc        : out   std_logic;
    phy_mdio       : inout std_logic;
    phy_reset      : out   std_logic;
    phy_rxclk      : in    std_logic;
    phy_rxctl_rxdv : in    std_logic;
    phy_rxd        : in    std_logic_vector(7 downto 0);
    phy_rxer       : in    std_logic;
    phy_txclk      : in    std_logic;
    phy_txctl_txen : out   std_logic;
    phy_txc_gtxclk : out   std_logic;
    phy_txd        : out   std_logic_vector(7 downto 0);
    phy_txer       : out   std_logic;
    sysclk         : in    std_logic
    );

end atlys_eth;

architecture beh of atlys_eth is

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

  component dcm1
    port (
      CLK_IN1  : in  std_logic;
      CLK_OUT1 : out std_logic;
      CLK_OUT2 : out std_logic;
      CLK_OUT3 : out std_logic;
      RESET    : in  std_logic;
      LOCKED   : out std_logic);
  end component;

  component desc_manager is
    generic (
      LOG2_N_OF_PKTS : integer;
      N_OF_PKTS      : integer);
    port (
      dta              : in  std_logic_vector(63 downto 0);
      dta_we           : in  std_logic;
      dta_eod          : in  std_logic;
      dta_ready        : out std_logic;
      pkt_number       : out unsigned(31 downto 0);
      seq_number       : out unsigned(15 downto 0);
      cmd_response_out : out std_logic_vector(12*8-1 downto 0);
      snd_cmd_start    : out std_logic;
      snd_start        : out std_logic;
      flushed          : out std_logic;
      snd_ready        : in  std_logic;
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
      retr_count       : out std_logic_vector(31 downto 0);
      transmit_data    : in  std_logic;
      transm_delay     : out unsigned(31 downto 0);
      dbg              : out std_logic_vector(3 downto 0);
      clk              : in  std_logic;
      rst_n            : in  std_logic);
  end component desc_manager;

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
      Tx_En         : out std_logic;
      TxD           : out std_logic_vector(7 downto 0));
  end component eth_sender;

  component eth_receiver
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
      Rx_Clk         : in  std_logic;
      Rx_Er          : in  std_logic;
      Rx_Dv          : in  std_logic;
      RxD            : in  std_logic_vector(7 downto 0));
  end component;

  component jtag_bus_ctl
    generic (
      d_width : integer;
      a_width : integer);
    port (
      din  : in  std_logic_vector((d_width-1) downto 0);
      dout : out std_logic_vector((d_width-1) downto 0);
      addr : out std_logic_vector((a_width-1) downto 0);
      nwr  : out std_logic;
      nrd  : out std_logic);
  end component;


  signal my_mac          : std_logic_vector(47 downto 0);
  constant my_ether_type : std_logic_vector(15 downto 0) := x"fade";
  signal transm_delay    : unsigned(31 downto 0);
  signal restart         : std_logic;
  signal dta             : std_logic_vector(63 downto 0);
  signal dta_we          : std_logic                     := '0';
  signal dta_ready       : std_logic;
  signal snd_start       : std_logic;
  signal snd_ready       : std_logic;
  signal flushed         : std_logic                     := '0';
  signal dta_eod         : std_logic                     := '0';
  signal dmem_addr       : std_logic_vector(LOG2_NWRDS_IN_PKT+LOG2_N_OF_PKTS-1 downto 0);
  signal dmem_dta        : std_logic_vector(63 downto 0);
  signal dmem_we         : std_logic;
  signal addr_a, addr_b  : integer;
  signal test_dta        : unsigned(63 downto 0);
  signal tx_mem_addr     : std_logic_vector(LOG2_NWRDS_IN_PKT+LOG2_N_OF_PKTS-1 downto 0);
  signal tx_mem_data     : std_logic_vector(63 downto 0);

  signal arg1, arg2, res1                   : unsigned(7 downto 0);
  signal res2                               : unsigned(15 downto 0);
  signal sender                             : std_logic_vector(47 downto 0);
  signal peer_mac                           : std_logic_vector(47 downto 0);
  signal inputs, din, dout                  : std_logic_vector(7 downto 0);
  signal addr, leds                         : std_logic_vector(3 downto 0);
  signal nwr, nrd, rst_p, rst_n, dcm_locked : std_logic;
  signal not_cpu_reset, rst_del             : std_logic;

  signal set_number          : unsigned(15 downto 0);
  signal pkt_number          : unsigned(31 downto 0);
  signal seq_number          : unsigned(15 downto 0) := (others => '0');
  signal start_pkt, stop_pkt : unsigned(7 downto 0)  := (others => '0');


  signal ack_fifo_din, ack_fifo_dout                                   : std_logic_vector(pkt_ack_width-1 downto 0);
  signal ack_fifo_wr_en, ack_fifo_rd_en, ack_fifo_empty, ack_fifo_full : std_logic;
  signal transmit_data, td_del0, td_del1                               : std_logic := '0';

  signal read_addr                   : std_logic_vector(15 downto 0);
  signal read_data                   : std_logic_vector(15 downto 0);
  signal read_done, read_in_progress : std_logic;

  signal dbg : std_logic_vector(3 downto 0);

  signal led_counter        : integer                       := 0;
  signal tx_counter         : integer                       := 10000;
  signal Reset              : std_logic;
  signal Clk_125M           : std_logic;
  signal Clk_user           : std_logic;
  signal Clk_reg            : std_logic;
  signal Speed              : std_logic_vector(2 downto 0);
  signal Rx_mac_ra          : std_logic;
  signal Rx_mac_rd          : std_logic;
  signal Rx_mac_data        : std_logic_vector(31 downto 0);
  signal Rx_mac_BE          : std_logic_vector(1 downto 0);
  signal Rx_mac_pa          : std_logic;
  signal Rx_mac_sop         : std_logic;
  signal Rx_mac_eop         : std_logic;
  signal Tx_mac_wa          : std_logic;
  signal Tx_mac_wr          : std_logic;
  signal Tx_mac_data        : std_logic_vector(31 downto 0);
  signal Tx_mac_BE          : std_logic_vector(1 downto 0);
  signal Tx_mac_sop         : std_logic;
  signal Tx_mac_eop         : std_logic;
  signal Pkg_lgth_fifo_rd   : std_logic;
  signal Pkg_lgth_fifo_ra   : std_logic;
  signal Pkg_lgth_fifo_data : std_logic_vector(15 downto 0);
  signal Gtx_clk            : std_logic;
  signal Rx_clk             : std_logic;
  signal Tx_clk             : std_logic;
  signal Tx_er              : std_logic;
  signal Tx_en              : std_logic;
  signal Txd                : std_logic_vector(7 downto 0);
  signal Rx_er              : std_logic;
  signal Rx_dv              : std_logic;
  signal Rxd                : std_logic_vector(7 downto 0);
  signal Crs                : std_logic;
  signal Col                : std_logic;
  signal CSB                : std_logic                     := '1';
  signal WRB                : std_logic                     := '1';
  signal CD_in              : std_logic_vector(15 downto 0) := (others => '0');
  signal CD_out             : std_logic_vector(15 downto 0) := (others => '0');
  signal CA                 : std_logic_vector(7 downto 0)  := (others => '0');
  signal s_Mdo              : std_logic;
  signal s_MdoEn            : std_logic;
  signal s_Mdi              : std_logic;

  signal s_dta_we : std_logic;

  -- signals related to user commands handling
  signal cmd_response_in, cmd_response_out : std_logic_vector(12*8-1 downto 0) := (others => '0');
  signal cmd_start                         : std_logic                         := '0';
  signal cmd_run                           : std_logic                         := '0';
  signal cmd_retr_s                        : std_logic                         := '0';
  signal cmd_ack                           : std_logic                         := '0';
  signal cmd_code                          : std_logic_vector(15 downto 0)     := (others => '0');
  signal cmd_seq                           : std_logic_vector(15 downto 0)     := (others => '0');
  signal cmd_arg                           : std_logic_vector(31 downto 0)     := (others => '0');

  signal retr_count : std_logic_vector(31 downto 0);

begin  -- beh

  -- Allow selection of MAC with the DIP switch to allow testing
  -- with multiple boards!
  with switches(1 downto 0) select
    my_mac <=
    x"de_ad_ba_be_be_ef" when "00",
    x"de_ad_ba_be_be_e1" when "01",
    x"de_ad_ba_be_be_e2" when "10",
    x"de_ad_ba_be_be_e3" when "11";


--  iic_sda_main <= 'Z';
-- iic_scl_main <= 'Z';

  not_cpu_reset <= not cpu_reset;
  rst_p         <= not rst_n;

--  flash_oe_b <= '1';
--  flash_we_b <= '1';
--  flash_ce_b <= '1';

  tx_clk <= Clk_125M;
  rx_clk <= phy_rxclk;

  Pkg_lgth_fifo_rd <= Pkg_lgth_fifo_ra;

  addr_a <= to_integer(unsigned(dmem_addr));
  addr_b <= to_integer(unsigned(tx_mem_addr));

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
      clk_b  => Tx_clk,
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
      dta_ready        => dta_ready,
      pkt_number       => pkt_number,
      seq_number       => seq_number,
      cmd_response_out => cmd_response_out,
      snd_start        => snd_start,
      flushed          => flushed,
      snd_cmd_start    => cmd_start,
      snd_ready        => snd_ready,
      dta_eod          => dta_eod,
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
      retr_count       => retr_count,
      transmit_data    => transmit_data,
      transm_delay     => transm_delay,
      dbg              => dbg,
      clk              => clk_user,
      rst_n            => rst_n);

  cmd_proc_1 : cmd_proc
    port map (
      cmd_code     => cmd_code,
      cmd_seq      => cmd_seq,
      cmd_arg      => cmd_arg,
      cmd_run      => cmd_run,
      cmd_ack      => cmd_ack,
      cmd_response => cmd_response_in,
      clk          => clk_user,
      rst_p        => rst_p,
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
      rst_n         => rst_n,
      ready         => snd_ready,
      flushed       => flushed,
      start         => snd_start,
      cmd_start     => cmd_start,
      tx_mem_addr   => tx_mem_addr,
      tx_mem_data   => tx_mem_data,
      cmd_response  => cmd_response_out,
      Tx_Clk        => tx_clk,
      Tx_En         => phy_txctl_txen,
      TxD           => PHY_Txd);

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
      rst_n          => rst_n,
      dbg            => open,           --dbg,
      Rx_Clk         => rx_clk,
      Rx_Er          => PHY_Rxer,
      Rx_Dv          => phy_rxctl_rxdv,
      RxD            => PHY_Rxd);

  dcm1_1 : dcm1
    port map (
      CLK_IN1  => sysclk,
      CLK_OUT1 => Clk_125M,
      CLK_OUT2 => Clk_user,
      CLK_OUT3 => Clk_reg,
      RESET    => not_cpu_reset,
      LOCKED   => dcm_locked);

  process (Clk_user, not_cpu_reset)
  begin  -- process
    if not_cpu_reset = '1' then         -- asynchronous reset (active low)
      rst_n   <= '0';
      rst_del <= '0';
    elsif Clk_user'event and Clk_user = '1' then  -- rising clock edge
      if restart = '1' then
        rst_n   <= '0';
        rst_del <= '0';
      else
        if dcm_locked = '1' then
          rst_del <= '1';
          rst_n   <= rst_del;
        end if;
      end if;
    end if;
  end process;

  -- reset

  phy_reset <= rst_n;

  -- Connection of MDI
  --s_Mdi    <= PHY_MDIO;
  --PHY_MDIO <= 'Z' when s_MdoEn = '0' else s_Mdo;

  phy_txer <= '0';
  phy_mdio <= 'Z';
  phy_mdc  <= '0';

  phy_txc_gtxclk <= tx_clk;

  ack_fifo_1 : ack_fifo
    port map (
      rst    => rst_p,
      wr_clk => rx_clk,
      rd_clk => Clk_user,
      din    => ack_fifo_din,
      wr_en  => ack_fifo_wr_en,
      rd_en  => ack_fifo_rd_en,
      dout   => ack_fifo_dout,
      full   => ack_fifo_full,
      empty  => ack_fifo_empty);

  --E_TXD <= s_Txd(3 downto 0);
  --s_Rxd <= "0000" & E_RXD;

  -- signal generator                                                                                                                                                  

  dta      <= std_logic_vector(test_dta);
  s_dta_we <= '1' when dta_ready = '1' and transmit_data = '1' else '0';
  dta_we   <= s_dta_we;

  process (Clk_user, rst_n)
  begin  -- process

    if rst_n = '0' then                 -- asynchronous reset (active low)
      td_del0  <= '0';
      td_del1  <= '0';
      test_dta <= (others => '0');
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

  -- gpio_led(1 downto 0) <= std_logic_vector(to_unsigned(led_counter, 2));
  gpio_led(0)          <= snd_ready;
  gpio_led(1)          <= transmit_data;
  gpio_led(2)          <= flushed;
  gpio_led(3)          <= Tx_mac_wa;
  gpio_led(7 downto 4) <= dbg;
--gpio_led(6)          <= ack_fifo_full;
--gpio_led(7)          <= not ack_fifo_empty;
end beh;
