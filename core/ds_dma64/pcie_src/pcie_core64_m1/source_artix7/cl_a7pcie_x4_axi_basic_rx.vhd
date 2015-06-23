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
-- File       : cl_a7pcie_x4_axi_basic_rx.vhd
-- Version    : 1.11
-- Description:
--  TRN to AXI RX module. Instantiates pipeline and null generator RX
--  submodules.
--
--  Notes:
--  Optional notes section.
--
--  Hierarchical:
--    axi_basic_top
--      axi_basic_rx
--------------------------------------------------------------------------------
-- Library Declarations
--------------------------------------------------------------------------------

LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;


ENTITY cl_a7pcie_x4_axi_basic_rx IS
   GENERIC (
      C_DATA_WIDTH      : INTEGER := 128;           -- RX/TX interface data width
      C_FAMILY          : STRING  := "X7";          -- Targeted FPGA family
      C_ROOT_PORT       : BOOLEAN := FALSE;       -- PCIe block is in root port mode
      C_PM_PRIORITY     : BOOLEAN := FALSE;       -- Disable TX packet boundary thrtl
      TCQ               : INTEGER := 1;             -- Clock to Q time

      C_REM_WIDTH       : INTEGER := 1             -- trem/rrem width

   );
   PORT (
      -------------------------------------------------
      -- User Design I/O                             --
      -------------------------------------------------
      -- AXI RX
      -------------

      M_AXIS_RX_TDATA   : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0):=(OTHERS=>'0'); -- RX data to user
      M_AXIS_RX_TVALID  : OUT STD_LOGIC                                  :='0';           -- RX data is valid
      M_AXIS_RX_TREADY  : IN STD_LOGIC                                   :='0';           -- RX ready for data
      m_axis_rx_tkeep   : OUT STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0):=(OTHERS=>'0'); -- RX strobe byte enables
      M_AXIS_RX_TLAST   : OUT STD_LOGIC                                  :='0';           -- RX data is last
      M_AXIS_RX_TUSER   : OUT STD_LOGIC_VECTOR(21 DOWNTO 0)              :=(OTHERS=>'0'); -- RX user signals
      -------------------------------------------------
      -- PCIe Block I/O                              --
      -------------------------------------------------
      -- TRN RX
      -------------
      TRN_RD            : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) :=(OTHERS=>'0');   -- RX data from block
      TRN_RSOF          : IN STD_LOGIC                                   :='0';             -- RX start of packet
      TRN_REOF          : IN STD_LOGIC                                   :='0';             -- RX end of packet
      TRN_RSRC_RDY      : IN STD_LOGIC                                   :='0';             -- RX source ready
      TRN_RDST_RDY      : OUT STD_LOGIC                                  :='0';             -- RX destination ready
      TRN_RSRC_DSC      : IN STD_LOGIC                                   :='0';             -- RX source discontinue
      TRN_RREM          : IN STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0)  :=(OTHERS=>'0');   -- RX remainder
      TRN_RERRFWD       : IN STD_LOGIC                                   :='0';             -- RX error forward
      TRN_RBAR_HIT      : IN STD_LOGIC_VECTOR(6 DOWNTO 0) :=(OTHERS=>'0');   -- RX BAR hit
      TRN_RECRC_ERR     : IN STD_LOGIC                                   :='0';             -- RX ECRC error

      -- System
      -------------
      NP_COUNTER        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)               :=(OTHERS=>'0');   -- Non-posted counter
      USER_CLK          : IN STD_LOGIC                                   :='0';             -- user clock from block
      USER_RST          : IN STD_LOGIC                                   :='0'              -- user reset from block
   );
END cl_a7pcie_x4_axi_basic_rx;

-------------------------------------------------
  -- RX Data Pipeline                            --
  -------------------------------------------------


ARCHITECTURE TRANS OF cl_a7pcie_x4_axi_basic_rx IS

   SIGNAL null_rx_tvalid         : STD_LOGIC:= '0';
   SIGNAL null_rx_tlast          : STD_LOGIC:= '0';
   SIGNAL null_rx_tkeep          : STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1  DOWNTO 0):= (others => '0');
   SIGNAL null_rdst_rdy          : STD_LOGIC:= '0';
   SIGNAL null_is_eof            : STD_LOGIC_VECTOR(4 DOWNTO 0):= (others => '0');

   -- Declare intermediate signals for referenced outputs
   SIGNAL m_axis_rx_tdata_xhdl0  : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0):= (others => '0');
   SIGNAL m_axis_rx_tvalid_xhdl4 : STD_LOGIC:= '0';
   SIGNAL m_axis_rx_tkeep_xhdl2  : STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0):= (others => '0');
   SIGNAL m_axis_rx_tlast_xhdl1  : STD_LOGIC:= '0';
   SIGNAL m_axis_rx_tuser_xhdl3  : STD_LOGIC_VECTOR(21 DOWNTO 0):= (others => '0');
   SIGNAL trn_rdst_rdy_xhdl6     : STD_LOGIC:= '0';
   SIGNAL np_counter_xhdl5       : STD_LOGIC_VECTOR(2 DOWNTO 0):= (others => '0');

   COMPONENT cl_a7pcie_x4_axi_basic_rx_null_gen IS
   GENERIC (
      C_DATA_WIDTH            : INTEGER := 128;
      TCQ                     : INTEGER := 1
   );
   PORT (
      M_AXIS_RX_TDATA         : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0)  := (OTHERS=>'0');
      M_AXIS_RX_TVALID        : IN STD_LOGIC                                    := '0';
      M_AXIS_RX_TREADY        : IN STD_LOGIC                                    := '0';
      M_AXIS_RX_TLAST         : IN STD_LOGIC                                    := '0';
      M_AXIS_RX_TUSER         : IN STD_LOGIC_VECTOR(21 DOWNTO 0)                := (OTHERS=>'0');

      NULL_RX_TVALID          : OUT STD_LOGIC                                   := '0';
      NULL_RX_TLAST           : OUT STD_LOGIC                                   := '0';
      NULL_RX_tkeep           : OUT STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0) := (OTHERS=>'0');
      NULL_RDST_RDY           : OUT STD_LOGIC                                   := '0';
      NULL_IS_EOF             : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)                := (OTHERS=>'0');

      USER_CLK                : IN STD_LOGIC                                    := '0';
      USER_RST                : IN STD_LOGIC                                    := '0'
   );
END COMPONENT cl_a7pcie_x4_axi_basic_rx_null_gen;

  -------------------------------------------------
  -- RX Data Pipeline                            --
  -------------------------------------------------
   COMPONENT cl_a7pcie_x4_axi_basic_rx_pipeline IS
   GENERIC (
      C_DATA_WIDTH            : INTEGER := 128;
      C_FAMILY                : STRING := "X7";
      TCQ                     : INTEGER := 1;

      C_REM_WIDTH             : INTEGER := 1
   );
   PORT (

      M_AXIS_RX_TDATA         : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0)   := (OTHERS=>'0');
      M_AXIS_RX_TVALID        : OUT STD_LOGIC                                     := '0';
      M_AXIS_RX_TREADY        : IN STD_LOGIC                                      := '0';
      m_axis_rx_tkeep         : OUT STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0)   := (OTHERS=>'0');
      M_AXIS_RX_TLAST         : OUT STD_LOGIC                                     := '0';
      M_AXIS_RX_TUSER         : OUT STD_LOGIC_VECTOR(21 DOWNTO 0)                 := (OTHERS=>'0');

      TRN_RD                  : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0)    := (OTHERS=>'0');
      TRN_RSOF                : IN STD_LOGIC                                      := '0';
      TRN_REOF                : IN STD_LOGIC                                      := '0';
      TRN_RSRC_RDY            : IN STD_LOGIC                                      := '0';
      TRN_RDST_RDY            : OUT STD_LOGIC                                     := '0';
      TRN_RSRC_DSC            : IN STD_LOGIC                                      := '0';
      TRN_RREM                : IN STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0)     := (OTHERS=>'0');
      TRN_RERRFWD             : IN STD_LOGIC                                      := '0';
      TRN_RBAR_HIT            : IN STD_LOGIC_VECTOR(6 DOWNTO 0)                   := (OTHERS=>'0');
      TRN_RECRC_ERR           : IN STD_LOGIC                                      := '0';

      NULL_RX_TVALID          : IN STD_LOGIC                                      := '0';
      NULL_RX_TLAST           : IN STD_LOGIC                                      := '0';
      NULL_RX_tkeep           : IN STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0)    := (OTHERS=>'0') ;
      NULL_RDST_RDY           : IN STD_LOGIC                                      := '0';
      NULL_IS_EOF             : IN STD_LOGIC_VECTOR(4 DOWNTO 0)                   := (OTHERS=>'0');

      NP_COUNTER              : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)                  :=(OTHERS=>'0');
      USER_CLK                : IN STD_LOGIC                                      :='0';
      USER_RST                : IN STD_LOGIC                                      :='0'
   );
END COMPONENT cl_a7pcie_x4_axi_basic_rx_pipeline;
BEGIN
   -- Drive referenced outputs
   M_AXIS_RX_TDATA     <= m_axis_rx_tdata_xhdl0;
   M_AXIS_RX_TVALID    <= m_axis_rx_tvalid_xhdl4;
   m_axis_rx_tkeep     <= m_axis_rx_tkeep_xhdl2;
   M_AXIS_RX_TLAST     <= m_axis_rx_tlast_xhdl1;
   M_AXIS_RX_TUSER     <= m_axis_rx_tuser_xhdl3;
   TRN_RDST_RDY        <= trn_rdst_rdy_xhdl6;
   NP_COUNTER          <= np_counter_xhdl5;


   rx_pipeline_inst : cl_a7pcie_x4_axi_basic_rx_pipeline
      GENERIC MAP (
         C_DATA_WIDTH    => C_DATA_WIDTH,
         C_FAMILY        => C_FAMILY,
         TCQ             => TCQ,
         C_REM_WIDTH     => C_REM_WIDTH
      )
      PORT MAP (

         ----------------------
         -- Outgoing AXI TX
         ----------------------
         M_AXIS_RX_TDATA   => m_axis_rx_tdata_xhdl0,
         M_AXIS_RX_TVALID  => m_axis_rx_tvalid_xhdl4,
         M_AXIS_RX_TREADY  => M_AXIS_RX_TREADY,
         m_axis_rx_tkeep   => m_axis_rx_tkeep_xhdl2,
         M_AXIS_RX_TLAST   => m_axis_rx_tlast_xhdl1,
         M_AXIS_RX_TUSER   => m_axis_rx_tuser_xhdl3,

         ----------------------
          -- Incoming TRN RX
         ----------------------
         TRN_RD            => TRN_RD,
         TRN_RSOF          => TRN_RSOF,
         TRN_REOF          => TRN_REOF,
         TRN_RSRC_RDY      => TRN_RSRC_RDY,
         TRN_RDST_RDY      => trn_rdst_rdy_xhdl6,
         TRN_RSRC_DSC      => TRN_RSRC_DSC,
         TRN_RREM          => TRN_RREM,
         TRN_RERRFWD       => TRN_RERRFWD,
         TRN_RBAR_HIT      => TRN_RBAR_HIT,
         TRN_RECRC_ERR     => TRN_RECRC_ERR,

         ----------------------
          -- Null Inputs
         ----------------------
         NULL_RX_TVALID    => null_rx_tvalid,
         NULL_RX_TLAST     => null_rx_tlast,
         NULL_RX_tkeep     => null_rx_tkeep,
         NULL_RDST_RDY     => null_rdst_rdy,
         NULL_IS_EOF       => null_is_eof,

         ----------------------
         -- System
         ----------------------
         NP_COUNTER        => np_counter_xhdl5,
         USER_CLK          => USER_CLK,
         USER_RST          => USER_RST
      );



   rx_null_gen_inst : cl_a7pcie_x4_axi_basic_rx_null_gen
      GENERIC MAP (
         C_DATA_WIDTH      => C_DATA_WIDTH,
         TCQ               => TCQ
      )
      PORT MAP (
         ----------------------
         -- Inputs
         ----------------------
         M_AXIS_RX_TDATA   => m_axis_rx_tdata_xhdl0,
         M_AXIS_RX_TVALID  => m_axis_rx_tvalid_xhdl4,
         M_AXIS_RX_TREADY  => M_AXIS_RX_TREADY,
         M_AXIS_RX_TLAST   => m_axis_rx_tlast_xhdl1,
         M_AXIS_RX_TUSER   => m_axis_rx_tuser_xhdl3,

         ----------------------
          -- Null Outputs
         ----------------------
         NULL_RX_TVALID    => null_rx_tvalid,
         NULL_RX_TLAST     => null_rx_tlast,
         NULL_RX_tkeep     => null_rx_tkeep,
         NULL_RDST_RDY     => null_rdst_rdy,
         NULL_IS_EOF       => null_is_eof,

         ----------------------
         -- System
         ----------------------
         USER_CLK          => USER_CLK,
         USER_RST          => USER_RST
      );

END TRANS;
