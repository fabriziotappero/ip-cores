-------------------------------------------------------------------------------
--
-- (c) Copyright 2008, 2009 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information of Xilinx, Inc.
-- and is protected under U.S. and international copyright and other
-- intellectual property laws.
--
-- DISCLAIMER
--
-- This disclaimer is not a license and does not grant any rights to the
-- materials distributed herewith. Except as otherwise provided in a valid
-- license issued to you by Xilinx, and to the maximum extent permitted by
-- applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
-- FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
-- IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
-- MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
-- and (2) Xilinx shall not be liable (whether in contract or tort, including
-- negligence, or under any other theory of liability) for any loss or damage
-- of any kind or nature related to, arising under or in connection with these
-- materials, including for any direct, or any indirect, special, incidental,
-- or consequential loss or damage (including loss of data, profits, goodwill,
-- or any type of loss or damage suffered as a result of any action brought by
-- a third party) even if such damage or loss was reasonably foreseeable or
-- Xilinx had been advised of the possibility of the same.
--
-- CRITICAL APPLICATIONS
--
-- Xilinx products are not designed or intended to be fail-safe, or for use in
-- any application requiring fail-safe performance, such as life-support or
-- safety devices or systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any other
-- applications that could lead to death, personal injury, or severe property
-- or environmental damage (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and liability of any use of
-- Xilinx products in Critical Applications, subject only to applicable laws
-- and regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
-- AT ALL TIMES.
--
-------------------------------------------------------------------------------
-- Project    : Spartan-6 Integrated Block for PCI Express
-- File       : gtpa1_dual_wrapper_top.vhd
-- Description: PCI Express Wrapper for GTPA1_DUAL
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_bit.all;
library unisim;
use unisim.vcomponents.all;
--synthesis translate_off
use unisim.vpkg.all;
library secureip;
use secureip.all;
--synthesis translate_on

entity gtpa1_dual_wrapper_top is
  generic (
    SIMULATION   : boolean := FALSE
  );
  port (
    -- Clock and reset
    sys_rst_n         : in  std_logic;
    sys_clk           : in  std_logic;
    gt_usrclk         : in  std_logic;
    gt_usrclk2x       : in  std_logic;
    gt_refclk_out     : out std_logic;
    gt_reset_done     : out std_logic;
    rxreset           : in  std_logic;

    -- RX and TX path GTP <-> PCIe
    rx_char_is_k      : out std_logic_vector(1 downto 0);
    rx_data           : out std_logic_vector(15 downto 0);
    rx_enter_elecidle : out std_logic;
    rx_status         : out std_logic_vector(2 downto 0);
    rx_polarity       : in  std_logic;
    tx_char_disp_mode : in  std_logic_vector(1 downto 0);
    tx_char_is_k      : in  std_logic_vector(1 downto 0);
    tx_rcvr_det       : in  std_logic;
    tx_data           : in  std_logic_vector(15 downto 0);

    -- Status and control path GTP <-> PCIe
    phystatus         : out  std_logic;
    gt_rx_valid       : out std_logic;
    gt_plllkdet_out   : out std_logic;
    gt_tx_elec_idle   : in  std_logic;
    gt_power_down     : in  std_logic_vector(1 downto 0);

    -- PCIe serial datapath
    arp_txp           : out std_logic;
    arp_txn           : out std_logic;
    arp_rxp           : in  std_logic;
    arp_rxn           : in  std_logic
  );
end gtpa1_dual_wrapper_top;

architecture rtl of gtpa1_dual_wrapper_top is

  ------------------------
  -- Function Declarations
  ------------------------
  function SIM_INT(SIMULATION : boolean) return integer is
  begin
    if SIMULATION then
      return 1;
    else
      return 0;
    end if;
  end SIM_INT;

  component GTPA1_DUAL_WRAPPER is
  generic
  (
    -- Simulation attributes
    WRAPPER_SIM_GTPRESET_SPEEDUP    : integer   := 0; -- Set to 1 to speed up sim reset
    WRAPPER_SIMULATION              : integer   := 0  -- Set to 1 for simulation
  );
  port
  (

    --_________________________________________________________________________
    --_________________________________________________________________________
    --TILE0  (X0_Y0)

    ------------------------ Loopback and Powerdown Ports ----------------------
    TILE0_RXPOWERDOWN0_IN                   : in   std_logic_vector(1 downto 0);
    TILE0_RXPOWERDOWN1_IN                   : in   std_logic_vector(1 downto 0);
    TILE0_TXPOWERDOWN0_IN                   : in   std_logic_vector(1 downto 0);
    TILE0_TXPOWERDOWN1_IN                   : in   std_logic_vector(1 downto 0);
    --------------------------------- PLL Ports --------------------------------
    TILE0_CLK00_IN                          : in   std_logic;
    TILE0_CLK01_IN                          : in   std_logic;
    TILE0_GTPRESET0_IN                      : in   std_logic;
    TILE0_GTPRESET1_IN                      : in   std_logic;
    TILE0_PLLLKDET0_OUT                     : out  std_logic;
    TILE0_PLLLKDET1_OUT                     : out  std_logic;
    TILE0_RESETDONE0_OUT                    : out  std_logic;
    TILE0_RESETDONE1_OUT                    : out  std_logic;
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    TILE0_RXCHARISK0_OUT                    : out  std_logic_vector(1 downto 0);
    TILE0_RXCHARISK1_OUT                    : out  std_logic_vector(1 downto 0);
    TILE0_RXDISPERR0_OUT                    : out  std_logic_vector(1 downto 0);
    TILE0_RXDISPERR1_OUT                    : out  std_logic_vector(1 downto 0);
    TILE0_RXNOTINTABLE0_OUT                 : out  std_logic_vector(1 downto 0);
    TILE0_RXNOTINTABLE1_OUT                 : out  std_logic_vector(1 downto 0);
    ---------------------- Receive Ports - Clock Correction --------------------
    TILE0_RXCLKCORCNT0_OUT                  : out  std_logic_vector(2 downto 0);
    TILE0_RXCLKCORCNT1_OUT                  : out  std_logic_vector(2 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    TILE0_RXENMCOMMAALIGN0_IN               : in   std_logic;
    TILE0_RXENMCOMMAALIGN1_IN               : in   std_logic;
    TILE0_RXENPCOMMAALIGN0_IN               : in   std_logic;
    TILE0_RXENPCOMMAALIGN1_IN               : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    TILE0_RXDATA0_OUT                       : out  std_logic_vector(15 downto 0);
    TILE0_RXDATA1_OUT                       : out  std_logic_vector(15 downto 0);
    TILE0_RXRESET0_IN                       : in   std_logic;
    TILE0_RXRESET1_IN                       : in   std_logic;
    TILE0_RXUSRCLK0_IN                      : in   std_logic;
    TILE0_RXUSRCLK1_IN                      : in   std_logic;
    TILE0_RXUSRCLK20_IN                     : in   std_logic;
    TILE0_RXUSRCLK21_IN                     : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    TILE0_GATERXELECIDLE0_IN                : in   std_logic;
    TILE0_GATERXELECIDLE1_IN                : in   std_logic;
    TILE0_IGNORESIGDET0_IN                  : in   std_logic;
    TILE0_IGNORESIGDET1_IN                  : in   std_logic;
    TILE0_RXELECIDLE0_OUT                   : out  std_logic;
    TILE0_RXELECIDLE1_OUT                   : out  std_logic;
    TILE0_RXN0_IN                           : in   std_logic;
    TILE0_RXN1_IN                           : in   std_logic;
    TILE0_RXP0_IN                           : in   std_logic;
    TILE0_RXP1_IN                           : in   std_logic;
    ----------- Receive Ports - RX Elastic Buffer and Phase Alignment ----------
    TILE0_RXSTATUS0_OUT                     : out  std_logic_vector(2 downto 0);
    TILE0_RXSTATUS1_OUT                     : out  std_logic_vector(2 downto 0);
    -------------- Receive Ports - RX Pipe Control for PCI Express -------------
    TILE0_PHYSTATUS0_OUT                    : out  std_logic;
    TILE0_PHYSTATUS1_OUT                    : out  std_logic;
    TILE0_RXVALID0_OUT                      : out  std_logic;
    TILE0_RXVALID1_OUT                      : out  std_logic;
    -------------------- Receive Ports - RX Polarity Control -------------------
    TILE0_RXPOLARITY0_IN                    : in   std_logic;
    TILE0_RXPOLARITY1_IN                    : in   std_logic;
    ---------------------------- TX/RX Datapath Ports --------------------------
    TILE0_GTPCLKOUT0_OUT                    : out  std_logic_vector(1 downto 0);
    TILE0_GTPCLKOUT1_OUT                    : out  std_logic_vector(1 downto 0);
    ------------------- Transmit Ports - 8b10b Encoder Control -----------------
    TILE0_TXCHARDISPMODE0_IN                : in   std_logic_vector(1 downto 0);
    TILE0_TXCHARDISPMODE1_IN                : in   std_logic_vector(1 downto 0);
    TILE0_TXCHARISK0_IN                     : in   std_logic_vector(1 downto 0);
    TILE0_TXCHARISK1_IN                     : in   std_logic_vector(1 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TILE0_TXDATA0_IN                        : in   std_logic_vector(15 downto 0);
    TILE0_TXDATA1_IN                        : in   std_logic_vector(15 downto 0);
    TILE0_TXUSRCLK0_IN                      : in   std_logic;
    TILE0_TXUSRCLK1_IN                      : in   std_logic;
    TILE0_TXUSRCLK20_IN                     : in   std_logic;
    TILE0_TXUSRCLK21_IN                     : in   std_logic;
    --------------- Transmit Ports - TX Driver and OOB signalling --------------
    TILE0_TXN0_OUT                          : out  std_logic;
    TILE0_TXN1_OUT                          : out  std_logic;
    TILE0_TXP0_OUT                          : out  std_logic;
    TILE0_TXP1_OUT                          : out  std_logic;
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    TILE0_TXDETECTRX0_IN                    : in   std_logic;
    TILE0_TXDETECTRX1_IN                    : in   std_logic;
    TILE0_TXELECIDLE0_IN                    : in   std_logic;
    TILE0_TXELECIDLE1_IN                    : in   std_logic
  );
  end component GTPA1_DUAL_WRAPPER;

  -------------------------------------
  -- Local signals
  -------------------------------------

  signal gt_refclk : std_logic_vector(1 downto 0);
  signal sys_rst   : std_logic;

begin

  GT_i : GTPA1_DUAL_WRAPPER
  generic map (
    -- Simulation attributes
    WRAPPER_SIM_GTPRESET_SPEEDUP => 1,
    WRAPPER_SIMULATION           => SIM_INT(SIMULATION)
  )
  port map (

    ------------------------ Loopback and Powerdown Ports ----------------------
    TILE0_RXPOWERDOWN0_IN => gt_power_down,
    TILE0_RXPOWERDOWN1_IN => "10",
    TILE0_TXPOWERDOWN0_IN => gt_power_down,
    TILE0_TXPOWERDOWN1_IN => "10",
    --------------------------------- PLL Ports --------------------------------
    TILE0_CLK00_IN       => sys_clk,
    TILE0_CLK01_IN       => '0',
    TILE0_GTPRESET0_IN   => sys_rst,
    TILE0_GTPRESET1_IN   => '1',
    TILE0_PLLLKDET0_OUT  => gt_plllkdet_out,
    TILE0_PLLLKDET1_OUT  => OPEN,
    TILE0_RESETDONE0_OUT => gt_reset_done,
    TILE0_RESETDONE1_OUT => OPEN,
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    TILE0_RXCHARISK0_OUT(1) => rx_char_is_k(0),
    TILE0_RXCHARISK0_OUT(0) => rx_char_is_k(1),
    TILE0_RXCHARISK1_OUT    => OPEN,
    TILE0_RXDISPERR0_OUT    => OPEN,
    TILE0_RXDISPERR1_OUT    => OPEN,
    TILE0_RXNOTINTABLE0_OUT => OPEN,
    TILE0_RXNOTINTABLE1_OUT => OPEN,
    ---------------------- Receive Ports - Clock Correction --------------------
    TILE0_RXCLKCORCNT0_OUT => OPEN,
    TILE0_RXCLKCORCNT1_OUT => OPEN,
    --------------- Receive Ports - Comma Detection and Alignment --------------
    TILE0_RXENMCOMMAALIGN0_IN => '1',
    TILE0_RXENMCOMMAALIGN1_IN => '1',
    TILE0_RXENPCOMMAALIGN0_IN => '1',
    TILE0_RXENPCOMMAALIGN1_IN => '1',
    ------------------- Receive Ports - RX Data Path interface -----------------
    TILE0_RXDATA0_OUT(15 downto 8) => rx_data(7 downto 0),
    TILE0_RXDATA0_OUT(7 downto 0)  => rx_data(15 downto 8),
    TILE0_RXDATA1_OUT              => OPEN,
    TILE0_RXRESET0_IN              => rxreset,
    TILE0_RXRESET1_IN              => '1',
    TILE0_RXUSRCLK0_IN             => gt_usrclk2x,
    TILE0_RXUSRCLK1_IN             => '0',
    TILE0_RXUSRCLK20_IN            => gt_usrclk,
    TILE0_RXUSRCLK21_IN            => '0',
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    TILE0_GATERXELECIDLE0_IN => '0',
    TILE0_GATERXELECIDLE1_IN => '0',
    TILE0_IGNORESIGDET0_IN   => '0',
    TILE0_IGNORESIGDET1_IN   => '0',
    TILE0_RXELECIDLE0_OUT    => rx_enter_elecidle,
    TILE0_RXELECIDLE1_OUT    => OPEN,
    TILE0_RXN0_IN            => arp_rxn,
    TILE0_RXN1_IN            => '0',
    TILE0_RXP0_IN            => arp_rxp,
    TILE0_RXP1_IN            => '0',
    ----------- Receive Ports - RX Elastic Buffer and Phase Alignment ----------
    TILE0_RXSTATUS0_OUT => rx_status,
    TILE0_RXSTATUS1_OUT => OPEN,
    -------------- Receive Ports - RX Pipe Control for PCI Express -------------
    TILE0_PHYSTATUS0_OUT => phystatus,
    TILE0_PHYSTATUS1_OUT => OPEN,
    TILE0_RXVALID0_OUT   => gt_rx_valid,
    TILE0_RXVALID1_OUT   => OPEN,
    -------------------- Receive Ports - RX Polarity Control -------------------
    TILE0_RXPOLARITY0_IN => rx_polarity,
    TILE0_RXPOLARITY1_IN => '0',
    ---------------------------- TX/RX Datapath Ports --------------------------
    TILE0_GTPCLKOUT0_OUT => gt_refclk,
    TILE0_GTPCLKOUT1_OUT => OPEN,
    ------------------- Transmit Ports - 8b10b Encoder Control -----------------
    TILE0_TXCHARDISPMODE0_IN(1) => tx_char_disp_mode(0),
    TILE0_TXCHARDISPMODE0_IN(0) => tx_char_disp_mode(1),
    TILE0_TXCHARDISPMODE1_IN(1) => '0',
    TILE0_TXCHARDISPMODE1_IN(0) => '0',
    TILE0_TXCHARISK0_IN(1)   => tx_char_is_k(0),
    TILE0_TXCHARISK0_IN(0)   => tx_char_is_k(1),
    TILE0_TXCHARISK1_IN(1)   => '0',
    TILE0_TXCHARISK1_IN(0)   => '0',
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TILE0_TXDATA0_IN(15 downto 8) => tx_data(7 downto 0),
    TILE0_TXDATA0_IN(7 downto 0)  => tx_data(15 downto 8),
    TILE0_TXDATA1_IN(15 downto 8) => x"00",
    TILE0_TXDATA1_IN(7 downto 0)  => x"00",
    TILE0_TXUSRCLK0_IN            => gt_usrclk2x,
    TILE0_TXUSRCLK1_IN            => '0',
    TILE0_TXUSRCLK20_IN           => gt_usrclk,
    TILE0_TXUSRCLK21_IN           => '0',
    --------------- Transmit Ports - TX Driver and OOB signalling --------------
    TILE0_TXN0_OUT => arp_txn,
    TILE0_TXN1_OUT => OPEN,
    TILE0_TXP0_OUT => arp_txp,
    TILE0_TXP1_OUT => OPEN,
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    TILE0_TXDETECTRX0_IN => tx_rcvr_det,
    TILE0_TXDETECTRX1_IN => '0',
    TILE0_TXELECIDLE0_IN => gt_tx_elec_idle,
    TILE0_TXELECIDLE1_IN => '0'  );

  sys_rst       <= not sys_rst_n;
  gt_refclk_out <= gt_refclk(0);

end rtl;

