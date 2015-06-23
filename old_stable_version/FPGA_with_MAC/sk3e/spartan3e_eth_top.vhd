-------------------------------------------------------------------------------
-- Title      : L3 FADE protocol demo for Spartan-3E Starter Kit board
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spartan3e_eth_top.vhd
-- Author     : Wojciech M. Zabolotny <wzab@ise.pw.edu.pl>
-- Company    : 
-- Created    : 2007-12-31
-- Last update: 2012-08-29
-- Platform   : 
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- This file implements a simple entity with JTAG driven internal bus
-- allowing to control LEDs, read buttons, set two registers
-- and to read results of simple arithmetical operations
-------------------------------------------------------------------------------
-- Copyright (c) 2010
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

library unisim;
use unisim.vcomponents.all;

entity spart3e_sk_eth is
  port(CLK_50MHZ     : in  std_logic;
       RS232_DCE_RXD : in  std_logic;
       RS232_DCE_TXD : out std_logic;

       SD_CK_P : out std_logic;         --DDR SDRAM clock_positive
       SD_CK_N : out std_logic;         --clock_negative
       SD_CKE  : out std_logic;         --clock_enable

       SD_BA  : out std_logic_vector(1 downto 0);   --bank_address
       SD_A   : out std_logic_vector(12 downto 0);  --address(row or col)
       SD_CS  : out std_logic;                      --chip_select
       SD_RAS : out std_logic;                      --row_address_strobe
       SD_CAS : out std_logic;                      --column_address_strobe
       SD_WE  : out std_logic;                      --write_enable

       SD_DQ   : inout std_logic_vector(15 downto 0);  --data
       SD_UDM  : out   std_logic;                      --upper_byte_enable
       SD_UDQS : inout std_logic;                      --upper_data_strobe
       SD_LDM  : out   std_logic;                      --low_byte_enable
       SD_LDQS : inout std_logic;                      --low_data_strobe

       E_MDC    : out   std_logic;      --Ethernet PHY
       E_MDIO   : inout std_logic;      --management data in/out
       E_COL    : in    std_logic;
       E_CRS    : in    std_logic;
       E_RX_CLK : in    std_logic;      --receive clock
       E_RX_ER  : in    std_logic;      --receive error
       E_RX_DV  : in    std_logic;      --data valid
       E_RXD    : in    std_logic_vector(3 downto 0);
       E_TX_CLK : in    std_logic;      --transmit clock
       E_TX_EN  : out   std_logic;      --data valid
       E_TX_ER  : out   std_logic;      --transmit error
       E_TXD    : out   std_logic_vector(3 downto 0);

       SF_CE0   : out   std_logic;      --NOR flash
       SF_OE    : out   std_logic;
       SF_WE    : out   std_logic;
       SF_BYTE  : out   std_logic;
       SF_STS   : in    std_logic;      --status
       SF_A     : out   std_logic_vector(24 downto 0);
       SF_D     : inout std_logic_vector(15 downto 1);
       SPI_MISO : inout std_logic;

       CDC_MCK        : out std_logic;
       CDC_CSn        : out std_logic;
       CDC_SDIN       : out std_logic;
       CDC_SCLK       : out std_logic;
       CDC_DIN        : out std_logic;
       CDC_BCLK       : out std_logic;
       --CDC_CLKOUT                : in  std_logic;
       CDC_DOUT       : in  std_logic;
       CDC_LRC_IN_OUT : out std_logic;

       VGA_VSYNC : out std_logic;       --VGA port
       VGA_HSYNC : out std_logic;
       VGA_RED   : out std_logic;
       VGA_GREEN : out std_logic;
       VGA_BLUE  : out std_logic;

       PS2_CLK  : in std_logic;         --Keyboard
       PS2_DATA : in std_logic;

       LED        : out std_logic_vector(7 downto 0);
       ROT_CENTER : in  std_logic;
       ROT_A      : in  std_logic;
       ROT_B      : in  std_logic;
       BTN_EAST   : in  std_logic;
       BTN_NORTH  : in  std_logic;
       BTN_SOUTH  : in  std_logic;
       BTN_WEST   : in  std_logic;
       SW         : in  std_logic_vector(3 downto 0));

end spart3e_sk_eth;

architecture beh of spart3e_sk_eth is

  component dp_ram_scl
    generic (
      DATA_WIDTH : integer;
      ADDR_WIDTH : integer);
    port (
      clk    : in  std_logic;
      we_a   : in  std_logic;
      addr_a : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_a : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      q_a    : out std_logic_vector(DATA_WIDTH-1 downto 0);
      we_b   : in  std_logic;
      addr_b : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_b : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      q_b    : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;

  component ack_fifo
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      din   : in  std_logic_vector(pkt_ack_width-1 downto 0);
      wr_en : in  std_logic;
      rd_en : in  std_logic;
      dout  : out std_logic_vector(pkt_ack_width-1 downto 0);
      full  : out std_logic;
      empty : out std_logic);
  end component;

  component dcm1
    port(
      CLKIN_IN        : in  std_logic;
      RST_IN          : in  std_logic;
      CLKFX_OUT       : out std_logic;
      CLKIN_IBUFG_OUT : out std_logic;
      CLK0_OUT        : out std_logic;
      LOCKED_OUT      : out std_logic
      );
  end component;

  component desc_manager
    generic (
      N_OF_PKTS : integer);
    port (
      dta            : in  std_logic_vector(31 downto 0);
      dta_we         : in  std_logic;
      dta_ready      : out std_logic;
      set_number     : out unsigned(15 downto 0);
      pkt_number     : out unsigned(15 downto 0);
      snd_start      : out std_logic;
      snd_ready      : in  std_logic;
      dmem_addr      : out std_logic_vector(13 downto 0);
      dmem_dta       : out std_logic_vector(31 downto 0);
      dmem_we        : out std_logic;
      ack_fifo_empty : in  std_logic;
      ack_fifo_rd_en : out std_logic;
      ack_fifo_dout  : in  std_logic_vector(pkt_ack_width-1 downto 0);
      transmit_data  : in  std_logic;
      transm_delay   : out unsigned(31 downto 0);
      clk            : in  std_logic;
      rst_n          : in  std_logic);
  end component;

  component eth_sender
    port (
      peer_mac      : in  std_logic_vector(47 downto 0);
      my_mac        : in  std_logic_vector(47 downto 0);
      my_ether_type : in  std_logic_vector(15 downto 0);
      set_number    : in  unsigned(15 downto 0);
      pkt_number    : in  unsigned(15 downto 0);
      retry_number  : in  unsigned(15 downto 0);
      transm_delay  : in  unsigned(31 downto 0);
      clk           : in  std_logic;
      rst_n         : in  std_logic;
      ready         : out std_logic;
      start         : in  std_logic;
      tx_mem_addr   : out std_logic_vector(13 downto 0);
      tx_mem_data   : in  std_logic_vector(31 downto 0);
      Tx_mac_wa     : in  std_logic;
      Tx_mac_wr     : out std_logic;
      Tx_mac_data   : out std_logic_vector(31 downto 0);
      Tx_mac_BE     : out std_logic_vector(1 downto 0);
      Tx_mac_sop    : out std_logic;
      Tx_mac_eop    : out std_logic);
  end component;

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
      Rx_mac_pa      : in  std_logic;
      Rx_mac_ra      : in  std_logic;
      Rx_mac_rd      : out std_logic;
      Rx_mac_data    : in  std_logic_vector(31 downto 0);
      Rx_mac_BE      : in  std_logic_vector(1 downto 0);
      Rx_mac_sop     : in  std_logic;
      Rx_mac_eop     : in  std_logic);
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

  component MAC_top
    port (
      --system signals
      Reset              : in  std_logic;
      Clk_125M           : in  std_logic;
      Clk_user           : in  std_logic;
      Clk_reg            : in  std_logic;
      Speed              : out std_logic_vector(2 downto 0);
      --user interface 
      Rx_mac_ra          : out std_logic;
      Rx_mac_rd          : in  std_logic;
      Rx_mac_data        : out std_logic_vector(31 downto 0);
      Rx_mac_BE          : out std_logic_vector(1 downto 0);
      Rx_mac_pa          : out std_logic;
      Rx_mac_sop         : out std_logic;
      Rx_mac_eop         : out std_logic;
      --user interface 
      Tx_mac_wa          : out std_logic;
      Tx_mac_wr          : in  std_logic;
      Tx_mac_data        : in  std_logic_vector(31 downto 0);
      Tx_mac_BE          : in  std_logic_vector(1 downto 0);
      Tx_mac_sop         : in  std_logic;
      Tx_mac_eop         : in  std_logic;
      -- pkg_lgth fifo
      Pkg_lgth_fifo_rd   : in  std_logic;
      Pkg_lgth_fifo_ra   : out std_logic;
      Pkg_lgth_fifo_data : out std_logic_vector(15 downto 0);
      --Phy interface          
      Gtx_clk            : out std_logic;  -- used only in GMII mode
      Rx_clk             : in  std_logic;
      Tx_clk             : in  std_logic;  -- used only in MII mode
      Tx_er              : out std_logic;
      Tx_en              : out std_logic;
      Txd                : out std_logic_vector(7 downto 0);
      Rx_er              : in  std_logic;
      Rx_dv              : in  std_logic;
      Rxd                : in  std_logic_vector(7 downto 0);
      Crs                : in  std_logic;
      Col                : in  std_logic;
      -- host interface
      CSB                : in  std_logic;
      WRB                : in  std_logic;
      CD_in              : in  std_logic_vector(15 downto 0);
      CD_out             : out std_logic_vector(15 downto 0);
      CA                 : in  std_logic_vector(7 downto 0);
      -- mdx
      Mdo                : out std_logic;  -- MII Management Data Output
      MdoEn              : out std_logic;  -- MII Management Data Output Enable
      Mdi                : in  std_logic;
      Mdc                : out std_logic   -- MII Management Data Clock       
      );
  end component;

  signal my_mac          : std_logic_vector(47 downto 0);
  constant my_ether_type : std_logic_vector(15 downto 0) := x"fade";
  signal transm_delay    : unsigned(31 downto 0);
  signal restart         : std_logic;
  signal dta             : std_logic_vector(31 downto 0);
  signal dta_we          : std_logic                     := '0';
  signal dta_ready       : std_logic;
  signal snd_start       : std_logic;
  signal snd_ready       : std_logic;
  signal dmem_addr       : std_logic_vector(13 downto 0);
  signal dmem_dta        : std_logic_vector(31 downto 0);
  signal dmem_we         : std_logic;
  signal addr_a, addr_b  : integer;
  signal test_dta        : unsigned(31 downto 0);
  signal tx_mem_addr     : std_logic_vector(13 downto 0);
  signal tx_mem_data     : std_logic_vector(31 downto 0);

  signal arg1, arg2, res1                   : unsigned(7 downto 0);
  signal res2                               : unsigned(15 downto 0);
  signal sender                             : std_logic_vector(47 downto 0);
  signal peer_mac                           : std_logic_vector(47 downto 0);
  signal inputs, din, dout                  : std_logic_vector(7 downto 0);
  signal addr                               : std_logic_vector(3 downto 0);
  signal leds                               : std_logic_vector(7 downto 0);
  signal nwr, nrd, rst_p, rst_n, dcm_locked : std_logic;
  signal cpu_reset, not_cpu_reset, rst_del  : std_logic;

  signal set_number          : unsigned(15 downto 0);
  signal pkt_number          : unsigned(15 downto 0);
  signal retry_number        : unsigned(15 downto 0) := (others => '0');
  signal start_pkt, stop_pkt : unsigned(7 downto 0)  := (others => '0');


  signal ack_fifo_din, ack_fifo_dout                                   : std_logic_vector(pkt_ack_width-1 downto 0);
  signal ack_fifo_wr_en, ack_fifo_rd_en, ack_fifo_empty, ack_fifo_full : std_logic;
  signal transmit_data                                                 : std_logic := '0';

  signal read_addr                   : std_logic_vector(15 downto 0);
  signal read_data                   : std_logic_vector(15 downto 0);
  signal read_done, read_in_progress : std_logic;


  signal led_counter        : integer                       := 0;
  signal tx_counter         : integer                       := 10000;
  signal Reset              : std_logic;
  signal s_gtx_clk          : std_logic;
  signal sysclk             : std_logic;
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
  signal s_Txd              : std_logic_vector(7 downto 0);
  signal Rx_er              : std_logic;
  signal Rx_dv              : std_logic;
  signal s_Rxd              : std_logic_vector(7 downto 0);
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

  signal s_dta_we    : std_logic;
  constant zeroes_32 : std_logic_vector(31 downto 0) := (others => '0');
  
begin  -- beh

  cpu_reset <= not ROT_CENTER;
  -- Different not used signals
  sysclk    <= clk_50mhz;
  sd_dq     <= (others => 'Z');
  sf_oe     <= '1';
  sf_we     <= '1';
  sf_d      <= (others => 'Z');

  sd_cs  <= '1';
  sd_we  <= '1';
  sd_ras <= '1';
  sd_cas <= '1';

  SD_CK_P <= '0';
  SD_CK_N <= '1';
  SD_CKE  <= '0';

  SD_BA <= (others => '0');
  SD_A  <= (others => '0');

  SD_UDM  <= 'Z';
  SD_UDQS <= 'Z';
  SD_LDM  <= 'Z';
  SD_LDQS <= 'Z';

  --E_MDC   <= '1';
  --E_MDIO  <= 'Z';
  --E_TX_ER <= '0';
  --E_TXD   <= (others => '0');

  SF_CE0   <= '0';
  SF_BYTE  <= '0';
  SF_A     <= (others => '0');
  SPI_MISO <= 'Z';

  VGA_VSYNC <= '0';
  VGA_HSYNC <= '0';
  VGA_RED   <= '0';
  VGA_GREEN <= '0';
  VGA_BLUE  <= '0';

  -- Codec is not connected
  CDC_DIN        <= '0';
  CDC_LRC_IN_OUT <= '0';
  CDC_BCLK       <= '0';
  CDC_MCK        <= '0';
  CDC_SCLK       <= '0';
  CDC_SDIN       <= '0';
  CDC_CSn        <= '0';

  -- LEDs are not used
  LED <= LEDs;

  -- RS not used
  RS232_DCE_TXD <= '1';

  -- Allow selection of MAC with the DIP switch to allow testing
  -- with multiple boards!
  with SW(1 downto 0) select
    my_mac <=
    x"de_ad_ba_be_be_ef" when "00",
    x"de_ad_ba_be_be_e1" when "01",
    x"de_ad_ba_be_be_e2" when "10",
    x"de_ad_ba_be_be_e3" when "11",
    x"de_ad_ba_be_be_e4" when others;

--  iic_sda_main <= 'Z';
-- iic_scl_main <= 'Z';

  not_cpu_reset <= not cpu_reset;
  rst_p         <= not rst_n;

--  flash_oe_b <= '1';
--  flash_we_b <= '1';
--  flash_ce_b <= '1';

  MAC_top_1 : MAC_top
    port map (
      Reset              => rst_p,
      Clk_125M           => Clk_125M,
      Clk_user           => Clk_user,
      Clk_reg            => Clk_user,   -- was Clk_reg
      Speed              => Speed,
      Rx_mac_ra          => Rx_mac_ra,
      Rx_mac_rd          => Rx_mac_rd,
      Rx_mac_data        => Rx_mac_data,
      Rx_mac_BE          => Rx_mac_BE,
      Rx_mac_pa          => Rx_mac_pa,
      Rx_mac_sop         => Rx_mac_sop,
      Rx_mac_eop         => Rx_mac_eop,
      Tx_mac_wa          => Tx_mac_wa,
      Tx_mac_wr          => Tx_mac_wr,
      Tx_mac_data        => Tx_mac_data,
      Tx_mac_BE          => Tx_mac_BE,
      Tx_mac_sop         => Tx_mac_sop,
      Tx_mac_eop         => Tx_mac_eop,
      Pkg_lgth_fifo_rd   => Pkg_lgth_fifo_rd,
      Pkg_lgth_fifo_ra   => Pkg_lgth_fifo_ra,
      Pkg_lgth_fifo_data => Pkg_lgth_fifo_data,
      Gtx_clk            => s_gtx_clk,  -- not used
      Rx_clk             => E_RX_CLK,
      Tx_clk             => E_TX_CLK,
      Tx_er              => E_TX_ER,
      Tx_en              => E_TX_EN,
      Txd                => s_TXD,
      Rx_er              => E_RX_ER,
      Rx_dv              => E_RX_DV,
      Rxd                => s_RXD,
      Crs                => E_CRS,
      Col                => E_COL,
      -- Host interface
      CSB                => CSB,
      WRB                => WRB,
      CD_in              => CD_in,
      CD_out             => CD_out,
      CA                 => CA,
      -- MDI interface
      Mdo                => s_Mdo,
      MdoEn              => s_MdoEn,
      Mdi                => s_Mdi,
      Mdc                => E_MDC);

  s_RXD(3 downto 0) <= E_RXD;
  s_RXD(7 downto 4) <= (others => '0');
  E_TXD             <= s_TXD(3 downto 0);

  Pkg_lgth_fifo_rd <= Pkg_lgth_fifo_ra;

  addr_a <= to_integer(unsigned(dmem_addr));
  addr_b <= to_integer(unsigned(tx_mem_addr));

  dp_ram_scl_1 : dp_ram_scl
    generic map (
      DATA_WIDTH => 32,
      ADDR_WIDTH => 13)
    port map (
      clk    => clk_user,
      we_a   => dmem_we,
      addr_a => dmem_addr(12 downto 0),
      data_a => dmem_dta,
      q_a    => open,
      we_b   => '0',
      addr_b => tx_mem_addr(12 downto 0),
      data_b => zeroes_32,
      q_b    => tx_mem_data);

  desc_manager_1 : desc_manager
    generic map (
      N_OF_PKTS => N_OF_PKTS)
    port map (
      dta            => dta,
      dta_we         => dta_we,
      dta_ready      => dta_ready,
      set_number     => set_number,
      pkt_number     => pkt_number,
      snd_start      => snd_start,
      snd_ready      => snd_ready,
      dmem_addr      => dmem_addr,
      dmem_dta       => dmem_dta,
      dmem_we        => dmem_we,
      ack_fifo_empty => ack_fifo_empty,
      ack_fifo_rd_en => ack_fifo_rd_en,
      ack_fifo_dout  => ack_fifo_dout,
      transmit_data  => transmit_data,
      transm_delay   => transm_delay,
      clk            => clk_user,
      rst_n          => rst_n);

  eth_sender_1 : eth_sender
    port map (
      peer_mac      => peer_mac,
      my_mac        => my_mac,
      my_ether_type => my_ether_type,
      transm_delay  => transm_delay,
      set_number    => set_number,
      pkt_number    => pkt_number,
      retry_number  => retry_number,
      clk           => clk_user,
      rst_n         => rst_n,
      ready         => snd_ready,
      start         => snd_start,
      tx_mem_addr   => tx_mem_addr,
      tx_mem_data   => tx_mem_data,
      Tx_mac_wa     => Tx_mac_wa,
      Tx_mac_wr     => Tx_mac_wr,
      Tx_mac_data   => Tx_mac_data,
      Tx_mac_BE     => Tx_mac_BE,
      Tx_mac_sop    => Tx_mac_sop,
      Tx_mac_eop    => Tx_mac_eop);

  eth_receiver_1 : eth_receiver
    port map (
      peer_mac       => peer_mac,
      my_mac         => my_mac,
      my_ether_type  => my_ether_type,
      restart        => restart,
      transmit_data  => transmit_data,
      ack_fifo_full  => ack_fifo_full,
      ack_fifo_wr_en => ack_fifo_wr_en,
      ack_fifo_din   => ack_fifo_din,
      clk            => clk_user,
      rst_n          => rst_n,
      Rx_mac_pa      => Rx_mac_pa,
      Rx_mac_ra      => Rx_mac_ra,
      Rx_mac_rd      => Rx_mac_rd,
      Rx_mac_data    => Rx_mac_data,
      Rx_mac_BE      => Rx_mac_BE,
      Rx_mac_sop     => Rx_mac_sop,
      Rx_mac_eop     => Rx_mac_eop);

  -- We don't use 125MHz clock!
  s_gtx_clk <= '0';
  dcm1_1 : dcm1
    port map (
      CLKIN_IN        => sysclk,
      RST_IN          => not_cpu_reset,
      CLKFX_OUT       => clk_user,
      CLKIN_IBUFG_OUT => open,
      CLK0_OUT        => open,
      LOCKED_OUT      => dcm_locked);

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

  --phy_reset <= rst_n;

  -- Connection of MDI
  s_Mdi  <= E_MDIO;
  E_MDIO <= 'Z' when s_MdoEn = '0' else s_Mdo;

  ack_fifo_1 : ack_fifo
    port map (
      clk   => Clk_user,
      rst   => rst_p,
      din   => ack_fifo_din,
      wr_en => ack_fifo_wr_en,
      rd_en => ack_fifo_rd_en,
      dout  => ack_fifo_dout,
      full  => ack_fifo_full,
      empty => ack_fifo_empty);

  --E_TXD <= s_Txd(3 downto 0);
  --s_Rxd <= "0000" & E_RXD;

  -- signal generator                                                                                                                                                  

  dta      <= std_logic_vector(test_dta);
  s_dta_we <= '1' when dta_ready = '1' and transmit_data = '1' else '0';
  dta_we   <= s_dta_we;

  process (Clk_user, rst_n)
  begin  -- process                                                                                                                                                    
    if rst_n = '0' then  -- asynchronous reset (active low)                                                                                             
      test_dta <= (others => '0');
    elsif Clk_user'event and Clk_user = '1' then  -- rising clock edge                                                                                                           
      if s_dta_we = '1' then
        test_dta <= test_dta + 1;
      end if;
    end if;
  end process;

  -- gpio_led(1 downto 0) <= std_logic_vector(to_unsigned(led_counter, 2));
  LEDs(0) <= snd_ready;
  LEDs(1) <= transmit_data;
  LEDs(2) <= not_cpu_reset;
  LEDs(3) <= Tx_mac_wa;


end beh;
