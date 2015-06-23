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
-- File       : axi_basic_top.vhd
-- Version    : 2.3
--
-- Description:
--  TRN/AXI4-S Bridge top level module. Instantiates RX and TX modules.
--
--  Notes:
--  Optional notes section.
--
--  Hierarchical:
--    axi_basic_top
--------------------------------------------------------------------------------
-- Library Declarations
--------------------------------------------------------------------------------

LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;


ENTITY axi_basic_top IS
   GENERIC (
      C_DATA_WIDTH              : INTEGER := 128;     -- RX/TX interface data width
      C_FAMILY                  : STRING := "X7";    -- Targeted FPGA family
      C_ROOT_PORT               : BOOLEAN := FALSE; -- PCIe block is in root port mode
      C_PM_PRIORITY             : BOOLEAN := FALSE; -- Disable TX packet boundary thrtl
      TCQ                       : INTEGER := 1;      -- Clock to Q time

      C_REM_WIDTH               : INTEGER := 1;      -- trem/rrem width
      C_STRB_WIDTH              : INTEGER := 4       -- TSTRB width
   );
   PORT (
      -----------------------------------------------
      -- User Design I/O
      -----------------------------------------------

      -- AXI TX
      -------------
      s_axis_tx_tdata         : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
      s_axis_tx_tvalid        : IN STD_LOGIC                                   := '0';
      s_axis_tx_tready        : OUT STD_LOGIC                                  := '0';
      s_axis_tx_tstrb         : IN STD_LOGIC_VECTOR(C_STRB_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
      s_axis_tx_tlast         : IN STD_LOGIC                                   := '0';
      s_axis_tx_tuser         : IN STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS=>'0');

      -- AXI RX
      -------------
      m_axis_rx_tdata         : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
      m_axis_rx_tvalid        : OUT STD_LOGIC                                   := '0';
      m_axis_rx_tready        : IN STD_LOGIC                                    := '0';
      m_axis_rx_tstrb         : OUT STD_LOGIC_VECTOR(C_STRB_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
      m_axis_rx_tlast         : OUT STD_LOGIC                                   := '0';
      m_axis_rx_tuser         : OUT STD_LOGIC_VECTOR(21 DOWNTO 0) := (OTHERS=>'0');

      -- User Misc.
      -------------
      user_turnoff_ok         : IN STD_LOGIC                                   := '0';
      user_tcfg_gnt           : IN STD_LOGIC                                   := '0';

      -----------------------------------------------
      -- PCIe Block I/O
      -----------------------------------------------

      -- TRN TX
      -------------
      trn_td                  : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
      trn_tsof                : OUT STD_LOGIC                                   := '0';
      trn_teof                : OUT STD_LOGIC                                   := '0';
      trn_tsrc_rdy            : OUT STD_LOGIC                                   := '0';
      trn_tdst_rdy            : IN STD_LOGIC                                    := '0';
      trn_tsrc_dsc            : OUT STD_LOGIC                                   := '0';
      trn_trem                : OUT STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0)  := (OTHERS=>'0');
      trn_terrfwd             : OUT STD_LOGIC                                   := '0';
      trn_tstr                : OUT STD_LOGIC                                   := '0';
      trn_tbuf_av             : IN STD_LOGIC_VECTOR(5 DOWNTO 0)                 := (OTHERS=>'0');
      trn_tecrc_gen           : OUT STD_LOGIC                                   := '0';

      -- TRN RX
      -------------
      trn_rd                  : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
      trn_rsof                : IN STD_LOGIC                                   := '0';
      trn_reof                : IN STD_LOGIC                                   := '0';
      trn_rsrc_rdy            : IN STD_LOGIC                                   := '0';
      trn_rdst_rdy            : OUT STD_LOGIC                                  := '0';
      trn_rsrc_dsc            : IN STD_LOGIC                                   := '0';
      trn_rrem                : IN STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0)  := (OTHERS=>'0');
      trn_rerrfwd             : IN STD_LOGIC                                   := '0';
      trn_rbar_hit            : IN STD_LOGIC_VECTOR(6 DOWNTO 0)                := (OTHERS=>'0');
      trn_recrc_err           : IN STD_LOGIC                                   := '0';

      -- TRN Misc.
      -------------
      trn_tcfg_req            : IN STD_LOGIC                                   := '0';
      trn_tcfg_gnt            : OUT STD_LOGIC                                  := '0';
      trn_lnk_up              : IN STD_LOGIC                                   := '0';

      -- 7 Series/Virtex6 PM
      -------------
      cfg_pcie_link_state     : IN STD_LOGIC_VECTOR(2 DOWNTO 0)                := (OTHERS=>'0');

      -- Virtex6 PM
      -------------
      cfg_pm_send_pme_to      : IN STD_LOGIC                                   := '0';
      cfg_pmcsr_powerstate    : IN STD_LOGIC_VECTOR(1 DOWNTO 0)                := (OTHERS=>'0');
      trn_rdllp_data          : IN STD_LOGIC_VECTOR(31 DOWNTO 0)               := (OTHERS=>'0');
      trn_rdllp_src_rdy       : IN STD_LOGIC                                   := '0';

      -- Virtex6/Spartan6 PM
      -------------
      cfg_to_turnoff          : IN STD_LOGIC                                   := '0';
      cfg_turnoff_ok          : OUT STD_LOGIC                                  := '0';

      np_counter              : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)               := (OTHERS=>'0');
      user_clk                : IN STD_LOGIC                                   := '0';
      user_rst                : IN STD_LOGIC                                   := '0'
   );
END axi_basic_top;


-----------------------------------------------
-- RX Data Pipeline
-----------------------------------------------

ARCHITECTURE trans OF axi_basic_top IS
   COMPONENT axi_basic_rx IS
      GENERIC (
         C_DATA_WIDTH              : INTEGER := 128;
         C_FAMILY                  : STRING := "X7";
         C_ROOT_PORT               : BOOLEAN := FALSE;
         C_PM_PRIORITY             : BOOLEAN := FALSE;
         TCQ                       : INTEGER := 1;
         C_REM_WIDTH               : INTEGER := 1;
         C_STRB_WIDTH              : INTEGER := 4
      );
      PORT (

         -- Outgoing AXI TX
         -------------
         M_AXIS_RX_TDATA         : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
         M_AXIS_RX_TVALID        : OUT STD_LOGIC                                   := '0';
         M_AXIS_RX_TREADY        : IN STD_LOGIC                                    := '0';
         M_AXIS_RX_TSTRB         : OUT STD_LOGIC_VECTOR(C_STRB_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
         M_AXIS_RX_TLAST         : OUT STD_LOGIC                                   := '0';
         M_AXIS_RX_TUSER         : OUT STD_LOGIC_VECTOR(21 DOWNTO 0) := (OTHERS=>'0');

         -- Incoming TRN RX
        -------------
         TRN_RD                  : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
         TRN_RSOF                : IN STD_LOGIC                                   := '0';
         TRN_REOF                : IN STD_LOGIC                                   := '0';
         TRN_RSRC_RDY            : IN STD_LOGIC                                   := '0';
         TRN_RDST_RDY            : OUT STD_LOGIC                                  := '0';
         TRN_RSRC_DSC            : IN STD_LOGIC                                   := '0';
         TRN_RREM                : IN STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0)  := (OTHERS=>'0');
         TRN_RERRFWD             : IN STD_LOGIC                                   := '0';
         TRN_RBAR_HIT            : IN STD_LOGIC_VECTOR(6 DOWNTO 0)                := (OTHERS=>'0');
         TRN_RECRC_ERR           : IN STD_LOGIC                                   := '0';

         -- System
         -------------
         NP_COUNTER              : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)               := (OTHERS=>'0');
         USER_CLK                : IN STD_LOGIC                                   := '0';
         USER_RST                : IN STD_LOGIC                                   := '0'
      );
   END COMPONENT;

    -----------------------------------------------
    -- TX Data Pipeline
    -----------------------------------------------
   COMPONENT axi_basic_tx IS
   GENERIC (
      C_DATA_WIDTH            : INTEGER := 128;
      C_FAMILY                : STRING := "X7";
      C_ROOT_PORT             : BOOLEAN := FALSE;
      C_PM_PRIORITY           : BOOLEAN := FALSE;
      TCQ                     : INTEGER := 1;

      C_REM_WIDTH               : INTEGER :=  1;
      C_STRB_WIDTH              : INTEGER :=  4
   );
   PORT (
      -- Incoming AXI RX
      -------------
      S_AXIS_TX_TDATA         : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
      S_AXIS_TX_TVALID        : IN STD_LOGIC                                   := '0';
      S_AXIS_TX_TREADY        : OUT STD_LOGIC                                  := '0';
      S_AXIS_TX_TSTRB         : IN STD_LOGIC_VECTOR(C_STRB_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
      S_AXIS_TX_TLAST         : IN STD_LOGIC                                   := '0';
      S_AXIS_TX_TUSER         : IN STD_LOGIC_VECTOR(3 DOWNTO 0)                := (OTHERS=>'0');

      -- User Misc.
      -------------
      USER_TURNOFF_OK         : IN STD_LOGIC                                   := '0';
      USER_TCFG_GNT           : IN STD_LOGIC                                   := '0';

      -- Outgoing TRN TX
      -------------
      TRN_TD                  : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
      TRN_TSOF                : OUT STD_LOGIC                                   := '0';
      TRN_TEOF                : OUT STD_LOGIC                                   := '0';
      TRN_TSRC_RDY            : OUT STD_LOGIC                                   := '0';
      TRN_TDST_RDY            : IN STD_LOGIC                                    := '0';
      TRN_TSRC_DSC            : OUT STD_LOGIC;
      TRN_TREM                : OUT STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0');
      TRN_TERRFWD             : OUT STD_LOGIC                                   := '0';
      TRN_TSTR                : OUT STD_LOGIC                                   := '0';
      TRN_TBUF_AV             : IN STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS=>'0');
      TRN_TECRC_GEN           : OUT STD_LOGIC                                   := '0';

      -- TRN Misc.
      -------------
      TRN_TCFG_REQ            : IN STD_LOGIC                                   := '0';
      TRN_TCFG_GNT            : OUT STD_LOGIC                                  := '0';
      TRN_LNK_UP              : IN STD_LOGIC                                   := '0';

      -- 7 Series/Virtex6 PM
      -------------
      CFG_PCIE_LINK_STATE     : IN STD_LOGIC_VECTOR(2 DOWNTO 0)                := (OTHERS=>'0');

      -- Virtex6 PM
      -------------
      CFG_PM_SEND_PME_TO      : IN STD_LOGIC                                   := '0';
      CFG_PMCSR_POWERSTATE    : IN STD_LOGIC_VECTOR(1 DOWNTO 0)                := (OTHERS=>'0');
      TRN_RDLLP_DATA          : IN STD_LOGIC_VECTOR(31 DOWNTO 0)               := (OTHERS=>'0');
      TRN_RDLLP_SRC_RDY       : IN STD_LOGIC;

      -- Spartan6 PM
      -------------
      CFG_TO_TURNOFF          : IN STD_LOGIC                                    := '0';
      CFG_TURNOFF_OK          : OUT STD_LOGIC                                   := '0';

      -- System
      -------------
      USER_CLK                : IN STD_LOGIC                                    := '0';
      USER_RST                : IN STD_LOGIC                                    := '0'
   );
END COMPONENT axi_basic_tx;


BEGIN

   rx_inst : axi_basic_rx
      GENERIC MAP (
         C_DATA_WIDTH  => C_DATA_WIDTH,
         TCQ           => TCQ,
         C_FAMILY      => C_FAMILY,
         C_REM_WIDTH   => C_REM_WIDTH,
         C_STRB_WIDTH  => C_STRB_WIDTH
      )
      PORT MAP (

         M_AXIS_RX_TDATA   => m_axis_rx_tdata,
         M_AXIS_RX_TVALID  => m_axis_rx_tvalid,
         M_AXIS_RX_TREADY  => m_axis_rx_tready,
         M_AXIS_RX_TSTRB   => m_axis_rx_tstrb,
         M_AXIS_RX_TLAST   => m_axis_rx_tlast,
         M_AXIS_RX_TUSER   => m_axis_rx_tuser,

         TRN_RD            => trn_rd,
         TRN_RSOF          => trn_rsof,
         TRN_REOF          => trn_reof,
         TRN_RSRC_RDY      => trn_rsrc_rdy,
         TRN_RDST_RDY      => trn_rdst_rdy,
         TRN_RSRC_DSC      => trn_rsrc_dsc,
         TRN_RREM          => trn_rrem,
         TRN_RERRFWD       => trn_rerrfwd,
         TRN_RBAR_HIT      => trn_rbar_hit,
         TRN_RECRC_ERR     => trn_recrc_err,

         NP_COUNTER        => np_counter,
         USER_CLK          => user_clk,
         USER_RST          => user_rst
      );

   tx_inst : axi_basic_tx
      GENERIC MAP (
         C_DATA_WIDTH      => C_DATA_WIDTH,
         C_FAMILY          => C_FAMILY,
         C_ROOT_PORT       => C_ROOT_PORT,
         C_PM_PRIORITY     => C_PM_PRIORITY,
         TCQ               => TCQ,
         C_REM_WIDTH       => C_REM_WIDTH,
         C_STRB_WIDTH      => C_STRB_WIDTH
      )
      PORT MAP (

         S_AXIS_TX_TDATA       => s_axis_tx_tdata,
         S_AXIS_TX_TVALID      => s_axis_tx_tvalid,
         S_AXIS_TX_TREADY      => s_axis_tx_tready,
         S_AXIS_TX_TSTRB       => s_axis_tx_tstrb,
         S_AXIS_TX_TLAST       => s_axis_tx_tlast,
         S_AXIS_TX_TUSER       => s_axis_tx_tuser,

         USER_TURNOFF_OK       => user_turnoff_ok,
         USER_TCFG_GNT         => user_tcfg_gnt,

         TRN_TD                => trn_td,
         TRN_TSOF              => trn_tsof,
         TRN_TEOF              => trn_teof,
         TRN_TSRC_RDY          => trn_tsrc_rdy,
         TRN_TDST_RDY          => trn_tdst_rdy,
         TRN_TSRC_DSC          => trn_tsrc_dsc,
         TRN_TREM              => trn_trem,
         TRN_TERRFWD           => trn_terrfwd,
         TRN_TSTR              => trn_tstr,
         TRN_TBUF_AV           => trn_tbuf_av,
         TRN_TECRC_GEN         => trn_tecrc_gen,

         TRN_TCFG_REQ          => trn_tcfg_req,
         TRN_TCFG_GNT          => trn_tcfg_gnt,
         TRN_LNK_UP            => trn_lnk_up,

         CFG_PCIE_LINK_STATE   => cfg_pcie_link_state,

         CFG_PM_SEND_PME_TO    => cfg_pm_send_pme_to,
         CFG_PMCSR_POWERSTATe  => cfg_pmcsr_powerstate,
         TRN_RDLLP_DATA        => trn_rdllp_data,
         TRN_RDLLP_SRC_RDY     => trn_rdllp_src_rdy,

         CFG_TO_TURNOFF        => cfg_to_turnoff,
         CFG_TURNOFF_OK        => cfg_turnoff_ok,

         USER_CLK              => user_clk,
         USER_RST              => user_rst
      );

END trans;


