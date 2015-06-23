--------------------------------------------------------------------------------
-- Title      : 10/100/1G Ethernet FIFO
-- Version    : 1.2
-- Project    : Tri-Mode Ethernet MAC
--------------------------------------------------------------------------------
-- File       : ten_100_1g_eth_fifo.vhd
-- Author     : Xilinx Inc.
-- Project    : Virtex-6 Embedded Tri-Mode Ethernet MAC Wrapper
-- File       : ten_100_1g_eth_fifo.vhd
-- Version    : 2.1
-------------------------------------------------------------------------------
--
-- (c) Copyright 2004-2008 Xilinx, Inc. All rights reserved.
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
-- Description: This is the top level wrapper for the 10/100/1G Ethernet FIFO.
--              The top level wrapper consists of individual FIFOs on the
--              transmitter path and on the receiver path.
--
--              Each path consists of an 8 bit local link to 8 bit client
--              interface FIFO.
--------------------------------------------------------------------------------


library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


--------------------------------------------------------------------------------
-- The entity declaration for the FIFO
--------------------------------------------------------------------------------

entity ten_100_1g_eth_fifo is
   generic (
        FULL_DUPLEX_ONLY    : boolean := false);      -- If fifo is to be used only in full
                                              -- duplex set to true for optimised implementation

   port (
        tx_fifo_aclk                : in  std_logic;
        tx_fifo_resetn              : in  std_logic;
        tx_axis_fifo_tdata          : in  std_logic_vector(7 downto 0);
        tx_axis_fifo_tvalid         : in  std_logic;
        tx_axis_fifo_tlast          : in  std_logic;
        tx_axis_fifo_tready         : out std_logic;

        tx_mac_aclk                 : in  std_logic;
        tx_mac_resetn               : in  std_logic;
        tx_axis_mac_tdata           : out std_logic_vector(7 downto 0);
        tx_axis_mac_tvalid          : out std_logic;
        tx_axis_mac_tlast           : out std_logic;
        tx_axis_mac_tready          : in  std_logic;
        tx_axis_mac_tuser           : out std_logic;
        tx_fifo_overflow            : out std_logic;
        tx_fifo_status              : out std_logic_vector(3 downto 0);
        tx_collision                : in  std_logic;
        tx_retransmit               : in  std_logic;

        rx_fifo_aclk                : in  std_logic;
        rx_fifo_resetn              : in  std_logic;
        rx_axis_fifo_tdata          : out std_logic_vector(7 downto 0);
        rx_axis_fifo_tvalid         : out std_logic;
        rx_axis_fifo_tlast          : out std_logic;
        rx_axis_fifo_tready         : in  std_logic;

        rx_mac_aclk                 : in  std_logic;
        rx_mac_resetn               : in  std_logic;
        rx_axis_mac_tdata           : in  std_logic_vector(7 downto 0);
        rx_axis_mac_tvalid          : in  std_logic;
        rx_axis_mac_tlast           : in  std_logic;
        rx_axis_mac_tready          : out std_logic;
        rx_axis_mac_tuser           : in  std_logic;
        rx_fifo_status              : out std_logic_vector(3 downto 0);
        rx_fifo_overflow            : out std_logic
  );
end ten_100_1g_eth_fifo;

architecture RTL of ten_100_1g_eth_fifo is

component rx_client_fifo 
  port (
     -- User-side (read-side) AxiStream interface
     rx_fifo_aclk   : in  std_logic;
     rx_fifo_resetn : in  std_logic;
     rx_axis_fifo_tdata : out std_logic_vector(7 downto 0);
     rx_axis_fifo_tvalid : out std_logic;
     rx_axis_fifo_tlast : out std_logic;
     rx_axis_fifo_tready : in  std_logic;

     -- MAC-side (write-side) AxiStream interface
     rx_mac_aclk    : in  std_logic;
     rx_mac_resetn  : in  std_logic;
     rx_axis_mac_tdata : in  std_logic_vector(7 downto 0);
     rx_axis_mac_tvalid : in  std_logic;
     rx_axis_mac_tlast : in  std_logic;
     rx_axis_mac_tready : out std_logic;
     rx_axis_mac_tuser : in  std_logic;

     -- FIFO status and overflow indication,
     -- synchronous to write-side (rx_mac_aclk) interface
     fifo_status    : out std_logic_vector(3 downto 0);
     fifo_overflow  : out std_logic
     );
end component;

component tx_client_fifo 
   generic (
      FULL_DUPLEX_ONLY : boolean := false);
   port (
        -- User-side (write-side) AxiStream interface
        tx_fifo_aclk    : in  std_logic;
        tx_fifo_resetn  : in  std_logic;
        tx_axis_fifo_tdata : in  std_logic_vector(7 downto 0);
        tx_axis_fifo_tvalid : in  std_logic;
        tx_axis_fifo_tlast : in  std_logic;
        tx_axis_fifo_tready : out std_logic;

        -- MAC-side (read-side) AxiStream interface
        tx_mac_aclk     : in  std_logic;
        tx_mac_resetn   : in  std_logic;
        tx_axis_mac_tdata : out std_logic_vector(7 downto 0);
        tx_axis_mac_tvalid : out std_logic;
        tx_axis_mac_tlast : out std_logic;
        tx_axis_mac_tready : in  std_logic;
        tx_axis_mac_tuser : out std_logic;

        -- FIFO status and overflow indication,
        -- synchronous to write-side (tx_user_aclk) interface
        fifo_overflow   : out std_logic;
        fifo_status     : out std_logic_vector(3 downto 0);

        -- FIFO collision and retransmission requests from MAC
        tx_collision    : in  std_logic;
        tx_retransmit   : in  std_logic
        );
end component;

begin

  ------------------------------------------------------------------------------
  -- Instantiate the Transmitter FIFO
  ------------------------------------------------------------------------------
  tx_fifo_i : tx_client_fifo 
  generic map(
    FULL_DUPLEX_ONLY   => FULL_DUPLEX_ONLY
  )
  port map(
    tx_fifo_aclk       => tx_fifo_aclk,
    tx_fifo_resetn     => tx_fifo_resetn,
    tx_axis_fifo_tdata => tx_axis_fifo_tdata,
    tx_axis_fifo_tvalid => tx_axis_fifo_tvalid,
    tx_axis_fifo_tlast => tx_axis_fifo_tlast,
    tx_axis_fifo_tready => tx_axis_fifo_tready,

    tx_mac_aclk        => tx_mac_aclk,
    tx_mac_resetn      => tx_mac_resetn,
    tx_axis_mac_tdata  => tx_axis_mac_tdata,
    tx_axis_mac_tvalid => tx_axis_mac_tvalid,
    tx_axis_mac_tlast  => tx_axis_mac_tlast,
    tx_axis_mac_tready => tx_axis_mac_tready,
    tx_axis_mac_tuser  => tx_axis_mac_tuser,

    fifo_overflow      => tx_fifo_overflow,
    fifo_status        => tx_fifo_status,

    tx_collision       => tx_collision,
    tx_retransmit      => tx_retransmit
  );


  ------------------------------------------------------------------------------
  -- Instantiate the Receiver FIFO
  ------------------------------------------------------------------------------
  rx_fifo_i : rx_client_fifo 
  port map(

    rx_fifo_aclk       => rx_fifo_aclk,
    rx_fifo_resetn     => rx_fifo_resetn,
    rx_axis_fifo_tdata => rx_axis_fifo_tdata,
    rx_axis_fifo_tvalid => rx_axis_fifo_tvalid,
    rx_axis_fifo_tlast => rx_axis_fifo_tlast,
    rx_axis_fifo_tready => rx_axis_fifo_tready,

    rx_mac_aclk        => rx_mac_aclk,
    rx_mac_resetn      => rx_mac_resetn,
    rx_axis_mac_tdata  => rx_axis_mac_tdata,
    rx_axis_mac_tvalid => rx_axis_mac_tvalid,
    rx_axis_mac_tlast  => rx_axis_mac_tlast,
    rx_axis_mac_tready => rx_axis_mac_tready,
    rx_axis_mac_tuser  => rx_axis_mac_tuser,

    fifo_status        => rx_fifo_status,
    fifo_overflow      => rx_fifo_overflow
  );
  
  
end RTL;
