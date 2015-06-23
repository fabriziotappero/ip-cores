
-------------------------------------------------------------------------------
--
-- (c) Copyright 2009-2011 Xilinx, Inc. All rights reserved.
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
-- Project    : Virtex-6 Integrated Block for PCI Express
-- File       : pcie_bram_top_v6.vhd
-- Version    : 2.3
---- Description: BlockRAM top level module for Virtex6 PCIe Block
----
----
----
----------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

entity pcie_bram_top_v6 is
   generic (
      DEV_CAP_MAX_PAYLOAD_SUPPORTED                : integer := 0;
      
      VC0_TX_LASTPACKET                            : integer := 31;
      TLM_TX_OVERHEAD                              : integer := 24;
      TL_TX_RAM_RADDR_LATENCY                      : integer := 1;
      TL_TX_RAM_RDATA_LATENCY                      : integer := 2;
      TL_TX_RAM_WRITE_LATENCY                      : integer := 1;
      
      VC0_RX_LIMIT                                 : bit_vector := x"1FFF";
      TL_RX_RAM_RADDR_LATENCY                      : integer := 1;
      TL_RX_RAM_RDATA_LATENCY                      : integer := 2;
      TL_RX_RAM_WRITE_LATENCY                      : integer := 1
      
   );
   port (
      user_clk_i                                   : in std_logic;
      reset_i                                      : in std_logic;
      mim_tx_wen                                   : in std_logic;
      mim_tx_waddr                                 : in std_logic_vector(12 downto 0);
      mim_tx_wdata                                 : in std_logic_vector(71 downto 0);
      mim_tx_ren                                   : in std_logic;
      mim_tx_rce                                   : in std_logic;
      mim_tx_raddr                                 : in std_logic_vector(12 downto 0);
      mim_tx_rdata                                 : out std_logic_vector(71 downto 0);
      mim_rx_wen                                   : in std_logic;
      mim_rx_waddr                                 : in std_logic_vector(12 downto 0);
      mim_rx_wdata                                 : in std_logic_vector(71 downto 0);
      mim_rx_ren                                   : in std_logic;
      mim_rx_rce                                   : in std_logic;
      mim_rx_raddr                                 : in std_logic_vector(12 downto 0);
      mim_rx_rdata                                 : out std_logic_vector(71 downto 0)
   );
end pcie_bram_top_v6;

architecture v6_pcie of pcie_bram_top_v6 is

  component pcie_brams_v6
    generic (
      NUM_BRAMS         : integer;
      RAM_RADDR_LATENCY : integer;
      RAM_RDATA_LATENCY : integer;
      RAM_WRITE_LATENCY : integer);
    port (
      user_clk_i : in  std_logic;
      reset_i    : in  std_logic;
      wen        : in  std_logic;
      waddr      : in  std_logic_vector(12 downto 0);
      wdata      : in  std_logic_vector(71 downto 0);
      ren        : in  std_logic;
      rce        : in  std_logic;
      raddr      : in  std_logic_vector(12 downto 0);
      rdata      : out std_logic_vector(71 downto 0));
  end component;

  -- TX calculations
  function cols_tx (
    constant CMPS                : integer;
    constant VC0_TX_LASTPACKET   : integer;
    constant TLM_TX_OVERHEAD     : integer)
    return integer is
     variable MPS_BYTES : integer := 128;
     variable BYTES_TX : integer := 0;
     variable COLS_TX : integer := 1;
  begin  -- cols_tx

    if (cmps = 0) then
      MPS_BYTES := 128;
    elsif (cmps = 1) then
      MPS_BYTES := 256;
    elsif (cmps = 2) then
      MPS_BYTES := 512;
    else
      MPS_BYTES := 1024;
    end if;
    BYTES_TX := ((VC0_TX_LASTPACKET + 1) * (MPS_BYTES + TLM_TX_OVERHEAD));
    if (BYTES_TX <= 4096) then
      COLS_TX := 1;
    elsif (BYTES_TX <= 8192) then
      COLS_TX := 2;
    elsif (BYTES_TX <= 16384) then
      COLS_TX := 4;
    elsif (BYTES_TX <= 32768) then
      COLS_TX := 8;
    else
      COLS_TX := 18;
    end if;
    return COLS_TX;
  end cols_tx;

  FUNCTION to_integer (
      val_in    : bit_vector) RETURN integer IS
      
      CONSTANT vctr   : bit_vector(val_in'high-val_in'low DOWNTO 0) := val_in;
      VARIABLE ret    : integer := 0;
   BEGIN
      FOR index IN vctr'RANGE LOOP
         IF (vctr(index) = '1') THEN
            ret := ret + (2**index);
         END IF;
      END LOOP;
      RETURN(ret);
   END to_integer;

  -- RX calculations
  function cols_rx (
    constant VC0_RX_LIMIT   : integer)
    return integer is
     variable COLS_RX : integer := 1;
  begin  -- cols_rx

    if (VC0_RX_LIMIT < 512) then        -- X"0200"
      COLS_RX := 1;
    elsif (VC0_RX_LIMIT < 1024) then    -- X"0400"
      COLS_RX := 2;
    elsif (VC0_RX_LIMIT < 2048) then    -- X"0800"
      COLS_RX := 4;
    elsif (VC0_RX_LIMIT < 4096) then    -- X"1000"
      COLS_RX := 8;
    else
      COLS_RX := 18;
    end if;
    return COLS_RX;
  end cols_rx;

      
   constant ROWS_TX                                : integer := 1;

   constant ROWS_RX                                : integer := 1;
      
   -- Declare intermediate signals for referenced outputs
   signal mim_tx_rdata_v6pcie1                     : std_logic_vector(71 downto 0);
   signal mim_rx_rdata_v6pcie0                     : std_logic_vector(71 downto 0);

begin
   -- Drive referenced outputs
   mim_tx_rdata <= mim_tx_rdata_v6pcie1;
   mim_rx_rdata <= mim_rx_rdata_v6pcie0;
   
--   process 
--   begin
--      -- $display("[%t] %m ROWS_TX %0d COLS_TX %0d", now, to_stdlogic(ROWS_TX), to_stdlogicvector(COLS_TX, 13));
--      -- $display("[%t] %m ROWS_RX %0d COLS_RX %0d", now, to_stdlogic(ROWS_RX), to_stdlogicvector(COLS_RX, 13));
--      wait;
--   end process;
   
   
   pcie_brams_tx : pcie_brams_v6
      generic map (
         NUM_BRAMS          => cols_tx(DEV_CAP_MAX_PAYLOAD_SUPPORTED, VC0_TX_LASTPACKET, TLM_TX_OVERHEAD),
         RAM_RADDR_LATENCY  => TL_TX_RAM_RADDR_LATENCY,
         RAM_RDATA_LATENCY  => TL_TX_RAM_RDATA_LATENCY,
         RAM_WRITE_LATENCY  => TL_TX_RAM_WRITE_LATENCY
      )
      port map (
         user_clk_i  => user_clk_i,
         reset_i     => reset_i,
         
         waddr       => mim_tx_waddr,
         wen         => mim_tx_wen,
         ren         => mim_tx_ren,
         rce         => mim_tx_rce,
         wdata       => mim_tx_wdata,
         raddr       => mim_tx_raddr,
         rdata       => mim_tx_rdata_v6pcie1
      );
   
   
   
   pcie_brams_rx : pcie_brams_v6
      generic map (
         NUM_BRAMS          => cols_rx(to_integer(VC0_RX_LIMIT)),
         RAM_RADDR_LATENCY  => TL_RX_RAM_RADDR_LATENCY,
         RAM_RDATA_LATENCY  => TL_RX_RAM_RDATA_LATENCY,
         RAM_WRITE_LATENCY  => TL_RX_RAM_WRITE_LATENCY
      )
      port map (
         user_clk_i  => user_clk_i,
         reset_i     => reset_i,
         
         waddr       => mim_rx_waddr,
         wen         => mim_rx_wen,
         ren         => mim_rx_ren,
         rce         => mim_rx_rce,
         wdata       => mim_rx_wdata,
         raddr       => mim_rx_raddr,
         rdata       => mim_rx_rdata_v6pcie0
      );
   
end v6_pcie;



-- pcie_bram_top
