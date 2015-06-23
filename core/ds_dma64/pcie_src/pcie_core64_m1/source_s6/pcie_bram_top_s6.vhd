-------------------------------------------------------------------------------
--
-- (c) Copyright 2008, 2009 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------
-- Project    : Spartan-6 Integrated Block for PCI Express
-- File       : pcie_bram_top_s6.vhd
-- Description: BlockRAM top level module for Spartan-6 PCIe Block
--
--              Given the selected core configuration, calculate the number of
--              BRAMs and pipeline stages and instantiate the BRAMS.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pcie_bram_top_s6 is
  generic (
    DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer    := 0;

    VC0_TX_LASTPACKET             : integer    := 31;
    TLM_TX_OVERHEAD               : integer    := 20;
    TL_TX_RAM_RADDR_LATENCY       : integer    := 1;
    TL_TX_RAM_RDATA_LATENCY       : integer    := 2;
    TL_TX_RAM_WRITE_LATENCY       : integer    := 1;

    VC0_RX_LIMIT                  : integer    := 16#1FFF#;
    TL_RX_RAM_RADDR_LATENCY       : integer    := 1;
    TL_RX_RAM_RDATA_LATENCY       : integer    := 2;
    TL_RX_RAM_WRITE_LATENCY       : integer    := 1
  );
  port (
    user_clk_i         : in  std_logic;
    reset_i            : in  std_logic;

    mim_tx_wen         : in  std_logic;
    mim_tx_waddr       : in  std_logic_vector(11 downto 0);
    mim_tx_wdata       : in  std_logic_vector(35 downto 0);
    mim_tx_ren         : in  std_logic;
    mim_tx_rce         : in  std_logic;
    mim_tx_raddr       : in  std_logic_vector(11 downto 0);
    mim_tx_rdata       : out std_logic_vector(35 downto 0);

    mim_rx_wen         : in  std_logic;
    mim_rx_waddr       : in  std_logic_vector(11 downto 0);
    mim_rx_wdata       : in  std_logic_vector(35 downto 0);
    mim_rx_ren         : in  std_logic;
    mim_rx_rce         : in  std_logic;
    mim_rx_raddr       : in  std_logic_vector(11 downto 0);
    mim_rx_rdata       : out std_logic_vector(35 downto 0)
  );
end pcie_bram_top_s6;

architecture rtl of pcie_bram_top_s6 is

  component pcie_brams_s6
    generic (
      NUM_BRAMS         : integer;
      RAM_RADDR_LATENCY : integer;
      RAM_RDATA_LATENCY : integer;
      RAM_WRITE_LATENCY : integer
    );
    port (
      user_clk_i  : in std_logic;
      reset_i     : in std_logic;
      wen         : in std_logic;
      waddr       : in std_logic_vector(11 downto 0);
      wdata       : in std_logic_vector(35 downto 0);
      ren         : in std_logic;
      rce         : in std_logic;
      raddr       : in std_logic_vector(11 downto 0);
      rdata       : out std_logic_vector(35 downto 0)
    );
  end component;

  function CALC_TX_COLS(constant MPS        : in integer;
                        constant LASTPACKET : in integer;
                        constant OVERHEAD   : in integer
                       ) return integer is
    variable MPS_BYTES : integer;
    variable BYTES_TX  : integer;
    variable COLS_TX   : integer;
  begin
    -- Decode MPS value
    if    (MPS = 0) then MPS_BYTES := 128;
    elsif (MPS = 1) then MPS_BYTES := 256;
    else                 MPS_BYTES := 512; -- MPS = 2
    end if;

    -- Calculate total bytes from MPS, number of packets, and overhead
    BYTES_TX := (LASTPACKET + 1) * (MPS_BYTES + OVERHEAD);

    -- Determine number of BRAM columns from total bytes
    if    (BYTES_TX <= 2048) then COLS_TX := 1;
    elsif (BYTES_TX <= 4096) then COLS_TX := 2;
    else                          COLS_TX := 4; -- BYTES_TX <= 8192
    end if;
    return COLS_TX;
  end function CALC_TX_COLS;

  function CALC_RX_COLS(constant LIMIT : in integer) return integer is
    variable COLS_RX   : integer;
  begin
    -- Determine number of BRAM columns from total RAM size
    if    (LIMIT <=  512) then COLS_RX := 1;
    elsif (LIMIT <= 1024) then COLS_RX := 2;
    else                       COLS_RX := 4; -- LIMIT <= 2048
    end if;
    return COLS_RX;
  end function CALC_RX_COLS;

begin

   pcie_brams_tx : pcie_brams_s6
   generic map(
     NUM_BRAMS         => CALC_TX_COLS(DEV_CAP_MAX_PAYLOAD_SUPPORTED, VC0_TX_LASTPACKET, TLM_TX_OVERHEAD),
     RAM_RADDR_LATENCY => TL_TX_RAM_RADDR_LATENCY,
     RAM_RDATA_LATENCY => TL_TX_RAM_RDATA_LATENCY,
     RAM_WRITE_LATENCY => TL_TX_RAM_WRITE_LATENCY
   )
   port map (
     user_clk_i => user_clk_i,
     reset_i    => reset_i,

     waddr      => mim_tx_waddr,
     wen        => mim_tx_wen,
     ren        => mim_tx_ren,
     rce        => mim_tx_rce,
     wdata      => mim_tx_wdata,
     raddr      => mim_tx_raddr,
     rdata      => mim_tx_rdata
   );

   pcie_brams_rx : pcie_brams_s6
   generic map(
     NUM_BRAMS         => CALC_RX_COLS(VC0_RX_LIMIT),
     RAM_RADDR_LATENCY => TL_RX_RAM_RADDR_LATENCY,
     RAM_RDATA_LATENCY => TL_RX_RAM_RDATA_LATENCY,
     RAM_WRITE_LATENCY => TL_RX_RAM_WRITE_LATENCY
   )
   port map (
     user_clk_i => user_clk_i,
     reset_i    => reset_i,

     waddr      => mim_rx_waddr,
     wen        => mim_rx_wen,
     ren        => mim_rx_ren,
     rce        => mim_rx_rce,
     wdata      => mim_rx_wdata,
     raddr      => mim_rx_raddr,
     rdata      => mim_rx_rdata
   );

end rtl;
