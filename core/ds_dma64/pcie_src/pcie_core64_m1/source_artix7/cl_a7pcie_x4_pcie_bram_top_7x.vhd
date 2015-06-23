-------------------------------------------------------------------------------
--
-- (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
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
-- Project    : Series-7 Integrated Block for PCI Express
-- File       : cl_a7pcie_x4_pcie_bram_top_7x.vhd
-- Version    : 1.11
--  Description : bram wrapper for Tx and Rx
--                given the pcie block attributes calculate the number of brams
--                and pipeline stages and instantiate the brams
--
--  Hierarchy:
--            pcie_bram_top    top level
--              pcie_brams     pcie_bram instantiations,
--                             pipeline stages (if any) then,
--                             address decode logic (if any) then,
--                             datapath muxing (if any) then
--                pcie_bram    bram library cell wrapper
--                             the pcie_bram entity can have a paramter that
--                             specifies the family (V6, V5, V4) then
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

entity cl_a7pcie_x4_pcie_bram_top_7x is
generic(
   IMPL_TARGET                   : string := "HARD";        -- the implementation target : HARD, SOFT
   DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer := 0;            -- MPS Supported : 0 - 128 B, 1 - 256 B, 2 - 512 B, 3 - 1024 B
   LINK_CAP_MAX_LINK_SPEED       : integer:= 1;             -- PCIe Link Speed : 1 - 2.5 GT/s; 2 - 5.0 GT/s
   LINK_CAP_MAX_LINK_WIDTH       : integer:= 8;             -- PCIe Link Width : 1 / 2 / 4 / 8
                                 
   VC0_TX_LASTPACKET             : integer:= 31;            -- Number of Packets in Transmit
   TLM_TX_OVERHEAD               : integer:= 24;            -- Overhead Bytes for Packets (Transmit)
   TL_TX_RAM_RADDR_LATENCY       : integer:= 1;             -- BRAM Read Address Latency (Transmit)
   TL_TX_RAM_RDATA_LATENCY       : integer:= 2;             -- BRAM Read Data Latency (Transmit)
   TL_TX_RAM_WRITE_LATENCY       : integer:= 1;             -- BRAM Write Latency (Transmit)
                                 
   VC0_RX_RAM_LIMIT              : bit_vector := x"1FFF";   -- 'h1FFFF RAM Size (Receive)
   TL_RX_RAM_RADDR_LATENCY       : integer:= 1;             -- BRAM Read Address Latency (Receive)
   TL_RX_RAM_RDATA_LATENCY       : integer:= 2;             -- BRAM Read Data Latency (Receive)
   TL_RX_RAM_WRITE_LATENCY       : integer:= 1              -- BRAM Write Latency (Receive)
);
port (
   user_clk_i : in std_logic;                          --  Clock input
   reset_i : in std_logic;                             --  Reset input
   
   mim_tx_wen   : in std_logic;                        -- Write Enable for Transmit path BRAM
   mim_tx_waddr : in std_logic_vector(12 downto 0);    -- Write Address for Transmit path BRAM
   mim_tx_wdata : in std_logic_vector(71 downto 0);    -- Write Data for Transmit path BRAM
   mim_tx_ren   : in std_logic;                        -- Read Enable for Transmit path BRAM
   mim_tx_rce   : in std_logic;                        -- Read Output Register Clock Enable for Transmit path BRAM
   mim_tx_raddr : in std_logic_vector(12 downto 0);    -- Read Address for Transmit path BRAM
   mim_tx_rdata : out std_logic_vector(71 downto 0);   -- Read Data for Transmit path BRAM
   
   mim_rx_wen   : in std_logic;                        -- Write Enable for Receive path BRAM
   mim_rx_waddr : in std_logic_vector(12 downto 0);    -- Write Address for Receive path BRAM
   mim_rx_wdata : in std_logic_vector(71 downto 0);    -- Write Data for Receive path BRAM
   mim_rx_ren   : in std_logic;                        -- Read Enable for Receive path BRAM
   mim_rx_rce   : in std_logic;                        -- Read Output Register Clock Enable for Receive path BRAM
   mim_rx_raddr : in std_logic_vector(12 downto 0);    -- Read Address for Receive path BRAM
   mim_rx_rdata : out std_logic_vector(71 downto 0)    -- Read Data for Receive path BRAM
);

end cl_a7pcie_x4_pcie_bram_top_7x;


architecture pcie_7x of cl_a7pcie_x4_pcie_bram_top_7x is

  component cl_a7pcie_x4_pcie_brams_7x
   generic (
     LINK_CAP_MAX_LINK_SPEED : integer := 1;        -- PCIe Link Speed : 1 - 2.5 GT/s; 2 - 5.0 GT/s
     LINK_CAP_MAX_LINK_WIDTH : integer := 8;        -- PCIe Link Width : 1 / 2 / 4 / 8
     IMPL_TARGET             : string := "HARD";    -- the implementation target : HARD, SOFT
     NUM_BRAMS               : integer := 0;
     RAM_RADDR_LATENCY       : integer := 1;
     RAM_RDATA_LATENCY       :integer := 1;
     RAM_WRITE_LATENCY       :integer := 1      
   );
   port (
     user_clk_i : in std_logic;
     reset_i    : in std_logic;   
     wen        : in std_logic;
     waddr      : in std_logic_vector(12 downto 0);
     wdata      : in std_logic_vector(71 downto 0);
     ren        : in std_logic;
     rce        : in std_logic;
     raddr      : in std_logic_vector(12 downto 0);
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
    constant VC0_RX_RAM_LIMIT   : integer)
    return integer is
     variable COLS_RX : integer := 1;
  begin  -- cols_rx
    if (VC0_RX_RAM_LIMIT < 512) then        -- X"0200"
      COLS_RX := 1;
    elsif (VC0_RX_RAM_LIMIT < 1024) then    -- X"0400"
      COLS_RX := 2;
    elsif (VC0_RX_RAM_LIMIT < 2048) then    -- X"0800"
      COLS_RX := 4;
    elsif (VC0_RX_RAM_LIMIT < 4096) then    -- X"1000"
      COLS_RX := 8;
    else
      COLS_RX := 18;
    end if;
    return COLS_RX;
  end cols_rx;
   
   constant ROWS_TX                                : integer := 1;
   constant ROWS_RX                                : integer := 1;

--   process 
--   begin
--      -- $display("[%t] %m ROWS_TX %0d COLS_TX %0d", now, to_stdlogic(ROWS_TX), to_stdlogicvector(COLS_TX, 13));
--      -- $display("[%t] %m ROWS_RX %0d COLS_RX %0d", now, to_stdlogic(ROWS_RX), to_stdlogicvector(COLS_RX, 13));
--      wait;
--   end process;
  begin
  pcie_brams_tx: cl_a7pcie_x4_pcie_brams_7x
  generic map (
    LINK_CAP_MAX_LINK_WIDTH =>  LINK_CAP_MAX_LINK_WIDTH ,
    LINK_CAP_MAX_LINK_SPEED =>  LINK_CAP_MAX_LINK_SPEED ,
    IMPL_TARGET             =>  IMPL_TARGET ,
    NUM_BRAMS               =>  cols_tx(DEV_CAP_MAX_PAYLOAD_SUPPORTED, VC0_TX_LASTPACKET, TLM_TX_OVERHEAD) ,
    RAM_RADDR_LATENCY       =>  TL_TX_RAM_RADDR_LATENCY ,
    RAM_RDATA_LATENCY       =>  TL_TX_RAM_RDATA_LATENCY ,
    RAM_WRITE_LATENCY       =>  TL_TX_RAM_WRITE_LATENCY
  ) 
  port map (
    user_clk_i =>  user_clk_i ,
    reset_i    =>  reset_i ,
    waddr      =>  mim_tx_waddr ,
    wen        =>  mim_tx_wen ,
    ren        =>  mim_tx_ren ,
    rce        =>  mim_tx_rce ,
    wdata      =>  mim_tx_wdata ,
    raddr      =>  mim_tx_raddr ,
    rdata      =>  mim_tx_rdata
  );

 pcie_brams_rx: cl_a7pcie_x4_pcie_brams_7x 
  generic map(
    LINK_CAP_MAX_LINK_WIDTH =>  LINK_CAP_MAX_LINK_WIDTH ,
    LINK_CAP_MAX_LINK_SPEED =>  LINK_CAP_MAX_LINK_SPEED ,
    IMPL_TARGET             =>  IMPL_TARGET ,
    NUM_BRAMS               =>  cols_rx(to_integer(VC0_RX_RAM_LIMIT)) ,
    RAM_RADDR_LATENCY       =>  TL_RX_RAM_RADDR_LATENCY ,
    RAM_RDATA_LATENCY       =>  TL_RX_RAM_RDATA_LATENCY ,
    RAM_WRITE_LATENCY       =>  TL_RX_RAM_WRITE_LATENCY
  ) 
  port map (
    user_clk_i =>  user_clk_i ,
    reset_i    =>  reset_i ,
    waddr      =>  mim_rx_waddr ,
    wen        =>  mim_rx_wen ,
    ren        =>  mim_rx_ren ,
    rce        =>  mim_rx_rce ,
    wdata      =>  mim_rx_wdata ,
    raddr      =>  mim_rx_raddr ,
    rdata      =>  mim_rx_rdata
   );

end pcie_7x; -- pcie_bram_top

