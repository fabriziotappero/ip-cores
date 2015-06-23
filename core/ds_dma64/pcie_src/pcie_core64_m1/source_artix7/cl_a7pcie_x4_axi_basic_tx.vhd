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
-- File       : cl_a7pcie_x4_axi_basic_tx.vhd
-- Version    : 1.11
--
-- Description:
-- AXI to TRN TX module. Instantiates pipeline and throttle control TX
--  submodules.
--
--  Notes:
--  Optional notes section.
--
--  Hierarchical:
--    axi_basic_top
--      axi_basic_tx
--
--------------------------------------------------------------------------------
-- Library Declarations
--------------------------------------------------------------------------------

LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;


ENTITY   cl_a7pcie_x4_axi_basic_tx IS
   GENERIC (
      C_DATA_WIDTH            : INTEGER := 128;          -- RX/TX interface data width
      C_FAMILY                : STRING  := "X7";         -- Targeted FPGA family
      C_ROOT_PORT             : BOOLEAN := FALSE;        -- PCIe block is in root port mode
      C_PM_PRIORITY           : BOOLEAN := FALSE;        -- Disable TX packet boundary thrtl
      TCQ                     : INTEGER := 1;            -- Clock to Q time

      C_REM_WIDTH             : INTEGER :=  1            -- trem/rrem width
   );
   PORT (

     -----------------------------------------------
     -- User Design I/O
     -----------------------------------------------

     -- AXI TX
     -------------
      S_AXIS_TX_TDATA         : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
      S_AXIS_TX_TVALID        : IN STD_LOGIC;
      S_AXIS_TX_TREADY        : OUT STD_LOGIC;
      s_axis_tx_tkeep         : IN STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0);
      S_AXIS_TX_TLAST         : IN STD_LOGIC;
      S_AXIS_TX_TUSER         : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

     -- User Misc.
     -------------
      USER_TURNOFF_OK         : IN STD_LOGIC;
      USER_TCFG_GNT           : IN STD_LOGIC;

      -----------------------------------------------
      -- PCIe Block I/O
      -----------------------------------------------

      -- TRN TX
      -------------
      TRN_TD                  : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
      TRN_TSOF                : OUT STD_LOGIC;
      TRN_TEOF                : OUT STD_LOGIC;
      TRN_TSRC_RDY            : OUT STD_LOGIC;
      TRN_TDST_RDY            : IN STD_LOGIC;
      TRN_TSRC_DSC            : OUT STD_LOGIC;
      TRN_TREM                : OUT STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0);
      TRN_TERRFWD             : OUT STD_LOGIC;
      TRN_TSTR                : OUT STD_LOGIC;
      TRN_TBUF_AV             : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      TRN_TECRC_GEN           : OUT STD_LOGIC;

     -- TRN Misc.
     -----------
       TRN_TCFG_REQ            : IN STD_LOGIC;
       TRN_TCFG_GNT            : OUT STD_LOGIC;
       TRN_LNK_UP              : IN STD_LOGIC;

     -- 7 Series/Virtex6 PM
     -----------
       CFG_PCIE_LINK_STATE     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

     -- Virtex6 PM
     -----------
       CFG_PM_SEND_PME_TO      : IN STD_LOGIC;
       CFG_PMCSR_POWERSTATE    : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       TRN_RDLLP_DATA          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       TRN_RDLLP_SRC_RDY       : IN STD_LOGIC;

     -- Virtex6/Spartan6 PM
     -----------
       CFG_TO_TURNOFF          : IN STD_LOGIC;
       CFG_TURNOFF_OK          : OUT STD_LOGIC;

     -- System
     -----------
      USER_CLK                : IN STD_LOGIC;
      USER_RST                : IN STD_LOGIC
   );
END cl_a7pcie_x4_axi_basic_tx;

ARCHITECTURE trans OF cl_a7pcie_x4_axi_basic_tx IS

   SIGNAL tready_thrtl           : STD_LOGIC;

   -- Declare intermediate signals for referenced outputs
   SIGNAL s_axis_tx_tready_xhdl1 : STD_LOGIC;
   SIGNAL trn_td_xhdl3           : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
   SIGNAL trn_tsof_xhdl8         : STD_LOGIC;
   SIGNAL trn_teof_xhdl5         : STD_LOGIC;
   SIGNAL trn_tsrc_rdy_xhdl10    : STD_LOGIC;
   SIGNAL trn_tsrc_dsc_xhdl9     : STD_LOGIC;
   SIGNAL trn_trem_xhdl7         : STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0);
   SIGNAL trn_terrfwd_xhdl6      : STD_LOGIC;
   SIGNAL trn_tstr_xhdl11        : STD_LOGIC;
   SIGNAL trn_tecrc_gen_xhdl4    : STD_LOGIC;
   SIGNAL trn_tcfg_gnt_xhdl2     : STD_LOGIC;
   SIGNAL cfg_turnoff_ok_xhdl0   : STD_LOGIC;

   COMPONENT   cl_a7pcie_x4_axi_basic_tx_thrtl_ctl IS
   GENERIC (
      C_DATA_WIDTH              : INTEGER := 128;
      C_FAMILY                  : STRING  := "X7";
      C_ROOT_PORT               : BOOLEAN := FALSE;
      TCQ                       : INTEGER := 1
   );
   PORT (
      S_AXIS_TX_TDATA         : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
      S_AXIS_TX_TVALID          : IN STD_LOGIC;
      S_AXIS_TX_TUSER           : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      S_AXIS_TX_TLAST           : IN STD_LOGIC;
      USER_TURNOFF_OK           : IN STD_LOGIC;
      USER_TCFG_GNT             : IN STD_LOGIC;
      TRN_TBUF_AV               : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      TRN_TDST_RDY              : IN STD_LOGIC;
      TRN_TCFG_REQ              : IN STD_LOGIC;
      TRN_TCFG_GNT              : OUT STD_LOGIC;
      TRN_LNK_UP                : IN STD_LOGIC;
      CFG_PCIE_LINK_STATE       : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      CFG_PM_SEND_PME_TO        : IN STD_LOGIC;
      CFG_PMCSR_POWERSTATE      : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      TRN_RDLLP_DATA            : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      TRN_RDLLP_SRC_RDY         : IN STD_LOGIC;
      CFG_TO_TURNOFF            : IN STD_LOGIC;
      CFG_TURNOFF_OK            : OUT STD_LOGIC;
      TREADY_THRTL              : OUT STD_LOGIC;
      USER_CLK                  : IN STD_LOGIC;
      USER_RST                  : IN STD_LOGIC
   );
   END COMPONENT cl_a7pcie_x4_axi_basic_tx_thrtl_ctl;

  -----------------------------------------------
  -- TX Data Pipeline
  -----------------------------------------------
   COMPONENT   cl_a7pcie_x4_axi_basic_tx_pipeline IS
   GENERIC (
      C_DATA_WIDTH              : INTEGER := 128;
      C_PM_PRIORITY             : BOOLEAN := FALSE;
      TCQ                       : INTEGER := 1;

      C_REM_WIDTH               : INTEGER :=  1
   );
   PORT (

    -- Incoming AXI RX
    -------------
      S_AXIS_TX_TDATA         : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
      S_AXIS_TX_TVALID        : IN STD_LOGIC;
      S_AXIS_TX_TREADY        : OUT STD_LOGIC;
      s_axis_tx_tkeep         : IN STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0);
      S_AXIS_TX_TLAST         : IN STD_LOGIC;
      S_AXIS_TX_TUSER         : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- Outgoing TRN TX
    -------------
      TRN_TD                  : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
      TRN_TSOF                : OUT STD_LOGIC;
      TRN_TEOF                : OUT STD_LOGIC;
      TRN_TSRC_RDY            : OUT STD_LOGIC;
      TRN_TDST_RDY            : IN STD_LOGIC;
      TRN_TSRC_DSC            : OUT STD_LOGIC;
      TRN_TREM                : OUT STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0);
      TRN_TERRFWD             : OUT STD_LOGIC;
      TRN_TSTR                : OUT STD_LOGIC;
      TRN_TECRC_GEN           : OUT STD_LOGIC;
      TRN_LNK_UP              : IN  STD_LOGIC;

    -- System
    -------------
      TREADY_THRTL            : IN STD_LOGIC;
      USER_CLK                : IN STD_LOGIC;
      USER_RST                : IN STD_LOGIC
   );
END COMPONENT cl_a7pcie_x4_axi_basic_tx_pipeline;

BEGIN
   -- Drive referenced outputs
   S_AXIS_TX_TREADY      <= s_axis_tx_tready_xhdl1;
   TRN_TD                <= trn_td_xhdl3;
   TRN_TSOF              <= trn_tsof_xhdl8;
   TRN_TEOF              <= trn_teof_xhdl5;
   TRN_TSRC_RDY          <= trn_tsrc_rdy_xhdl10;
   TRN_TSRC_DSC          <= trn_tsrc_dsc_xhdl9;
   TRN_TREM              <= trn_trem_xhdl7;
   TRN_TERRFWD           <= trn_terrfwd_xhdl6;
   TRN_TSTR              <= trn_tstr_xhdl11;
   TRN_TECRC_GEN         <= trn_tecrc_gen_xhdl4;
   TRN_TCFG_GNT          <= trn_tcfg_gnt_xhdl2;
   CFG_TURNOFF_OK        <= cfg_turnoff_ok_xhdl0;



   tx_pipeline_inst :   cl_a7pcie_x4_axi_basic_tx_pipeline
      GENERIC MAP (
         C_DATA_WIDTH     => C_DATA_WIDTH,
         C_PM_PRIORITY    => C_PM_PRIORITY,
         TCQ              => TCQ,
         C_REM_WIDTH      => C_REM_WIDTH
      )
      PORT MAP (

         S_AXIS_TX_TDATA   => S_AXIS_TX_TDATA,
         S_AXIS_TX_TREADY  => s_axis_tx_tready_xhdl1,
         S_AXIS_TX_TVALID  => S_AXIS_TX_TVALID,
         s_axis_tx_tkeep   => s_axis_tx_tkeep,
         S_AXIS_TX_TLAST   => S_AXIS_TX_TLAST,
         S_AXIS_TX_TUSER   => S_AXIS_TX_TUSER,

         TRN_TD            => trn_td_xhdl3,
         TRN_TSOF          => trn_tsof_xhdl8,
         TRN_TEOF          => trn_teof_xhdl5,
         TRN_TSRC_RDY      => trn_tsrc_rdy_xhdl10,
         TRN_TDST_RDY      => TRN_TDST_RDY,
         TRN_TSRC_DSC      => trn_tsrc_dsc_xhdl9,
         TRN_TREM          => trn_trem_xhdl7,
         TRN_TERRFWD       => trn_terrfwd_xhdl6,
         TRN_TSTR          => trn_tstr_xhdl11,
         TRN_TECRC_GEN     => trn_tecrc_gen_xhdl4,
         TRN_LNK_UP        => trn_lnk_up,

         TREADY_THRTL      => TREADY_THRTL,
         USER_CLK          => USER_CLK,
         USER_RST          => USER_RST
      );

  -------------------------------------------------
  -- TX Throttle Controller
  -------------------------------------------------
   xhdl12 : IF (NOT(C_PM_PRIORITY)) GENERATE
           tx_thrl_ctl_inst :   cl_a7pcie_x4_axi_basic_tx_thrtl_ctl
           GENERIC MAP (
                               C_DATA_WIDTH    => C_DATA_WIDTH,
                               C_FAMILY        => C_FAMILY,
                               C_ROOT_PORT     => C_ROOT_PORT,
                               TCQ             => TCQ
                       )
           PORT MAP (
                            -- Outgoing AXI TX
                            -------------
                            S_AXIS_TX_TDATA       => S_AXIS_TX_TDATA,
                            S_AXIS_TX_TVALID      => S_AXIS_TX_TVALID,
                            S_AXIS_TX_TUSER       => S_AXIS_TX_TUSER,
                            S_AXIS_TX_TLAST       => S_AXIS_TX_TLAST,

                            -- User Misc.
                            -------------
                            USER_TURNOFF_OK       => USER_TURNOFF_OK,
                            USER_TCFG_GNT         => USER_TCFG_GNT,

                            -- Incoming TRN RX
                            -------------
                            TRN_TBUF_AV           => TRN_TBUF_AV,
                            TRN_TDST_RDY          => TRN_TDST_RDY,

                            -- TRN Misc.
                            -------------
                            TRN_TCFG_REQ          => TRN_TCFG_REQ,
                            TRN_TCFG_GNT          => trn_tcfg_gnt_xhdl2,
                            TRN_LNK_UP            => trn_lnk_up,

                            -- 7 Seriesq/Virtex6 PM
                            -------------
                            CFG_PCIE_LINK_STATE   => CFG_PCIE_LINK_STATE,

                            -- Virtex6 PM
                            -------------
                            CFG_PM_SEND_PME_TO    => CFG_PM_SEND_PME_TO,
                            CFG_PMCSR_POWERSTATE  => CFG_PMCSR_POWERSTATE,
                            TRN_RDLLP_DATA        => TRN_RDLLP_DATA,
                            TRN_RDLLP_SRC_RDY     => TRN_RDLLP_SRC_RDY,

                            -- Spartan6 PM
                            -------------
                            CFG_TO_TURNOFF        => CFG_TO_TURNOFF,
                            CFG_TURNOFF_OK        => cfg_turnoff_ok_xhdl0,

                            -- System
                            -------------
                            TREADY_THRTL          => TREADY_THRTL,
                            USER_CLK              => USER_CLK,
                            USER_RST              => USER_RST
     );
     END GENERATE;
   xhdl13 : IF (C_PM_PRIORITY) GENERATE
      TREADY_THRTL         <= '0';
      cfg_turnoff_ok_xhdl0 <= USER_TURNOFF_OK;
      trn_tcfg_gnt_xhdl2   <= USER_TCFG_GNT;
   END GENERATE;
END trans;
