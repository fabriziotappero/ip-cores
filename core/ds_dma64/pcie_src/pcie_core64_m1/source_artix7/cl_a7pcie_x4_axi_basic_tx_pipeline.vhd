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
-- File       : cl_a7pcie_x4_axi_basic_tx_pipeline.vhd
-- Version    : 1.11
--
-- Description:
--AXI to TRN TX pipeline. Converts transmitted data from AXI protocol to
--  TRN.
--
--  Notes:
--  Optional notes section.
--
--  Hierarchical:
--    axi_basic_top
--      axi_basic_tx
--        axi_basic_tx_pipeline
--------------------------------------------------------------------------------
-- Library Declarations
--------------------------------------------------------------------------------

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.std_logic_unsigned.all;


ENTITY cl_a7pcie_x4_axi_basic_tx_pipeline IS
  GENERIC (
     C_DATA_WIDTH            : INTEGER := 128;     -- RX/TX interface data width
     C_PM_PRIORITY           : BOOLEAN := FALSE;  -- Disable TX packet boundary thrtl
     TCQ                     : INTEGER := 1;       -- Clock to Q time

     C_REM_WIDTH             : INTEGER :=  1       -- trem/rrem width
  );
  PORT (

    -----------------------------------------------
    -- User Design I/O
    -----------------------------------------------

    -- AXI TX
    -------------
    S_AXIS_TX_TDATA         : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0)  := (OTHERS=>'0'); -- TX data from user
    S_AXIS_TX_TVALID        : IN STD_LOGIC                                    := '0';           -- TX data is valid
    S_AXIS_TX_TREADY        : OUT STD_LOGIC                                   := '0';           -- TX ready for data
    s_axis_tx_tkeep         : IN STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0)  := (OTHERS=>'0'); -- TX strobe byte enables
    S_AXIS_TX_TLAST         : IN STD_LOGIC                                    := '0';           -- TX data is last
    S_AXIS_TX_TUSER         : IN STD_LOGIC_VECTOR(3 DOWNTO 0)                 := (OTHERS=>'0'); -- TX user signals

    -----------------------------------------------//
    -- PCIe Block I/O                              //
    -----------------------------------------------//

    -- TRN TX
    -------------
    TRN_TD                  : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS=>'0'); -- TX data from block
    TRN_TSOF                : OUT STD_LOGIC                                   := '0';           -- TX start of packet
    TRN_TEOF                : OUT STD_LOGIC                                   := '0';           -- TX end of packet
    TRN_TSRC_RDY            : OUT STD_LOGIC                                   := '0';           -- TX source ready
    TRN_TDST_RDY            : IN STD_LOGIC                                    := '0';           -- TX destination ready
    TRN_TSRC_DSC            : OUT STD_LOGIC                                   := '0';           -- TX source discontinue
    TRN_TREM                : OUT STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0)  := (OTHERS=>'0'); -- TX remainder
    TRN_TERRFWD             : OUT STD_LOGIC                                   := '0';           -- TX error forward
    TRN_TSTR                : OUT STD_LOGIC                                   := '0';           -- TX streaming enable
    TRN_TECRC_GEN           : OUT STD_LOGIC                                   := '0';           -- TX ECRC generate
    TRN_LNK_UP              : IN STD_LOGIC                                    := '0';           -- PCIe link up

    -- System
    -------------
    TREADY_THRTL            : IN STD_LOGIC                                    := '0';           -- TREADY from thrtl ctl
    USER_CLK                : IN STD_LOGIC                                    := '0';           -- user clock from block
    USER_RST                : IN STD_LOGIC                                    := '0'            -- user reset from block
  );
END cl_a7pcie_x4_axi_basic_tx_pipeline;

ARCHITECTURE trans OF cl_a7pcie_x4_axi_basic_tx_pipeline IS

  -- Input register stage
  SIGNAL reg_tdata              : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
  SIGNAL tdata_prev             : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
  SIGNAL tkeep_prev             : STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0);
  SIGNAL tvalid_prev            : STD_LOGIC;
  SIGNAL tlast_prev             : STD_LOGIC;
  SIGNAL reg_tdst_rdy           : STD_LOGIC;
  SIGNAL data_hold              : STD_LOGIC;
  SIGNAL data_prev              : STD_LOGIC;
  SIGNAL tuser_prev             : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL reg_tvalid             : STD_LOGIC;
  SIGNAL reg_tkeep              : STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0);
  SIGNAL reg_tuser              : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL reg_tlast              : STD_LOGIC;
  SIGNAL reg_tready             : STD_LOGIC;

  -- Pipeline utility signals
  SIGNAL trn_in_packet          : STD_LOGIC;
  SIGNAL axi_in_packet          : STD_LOGIC;
  SIGNAL flush_axi              : STD_LOGIC;
  SIGNAL disable_trn            : STD_LOGIC;
  SIGNAL reg_disable_trn        : STD_LOGIC;
  SIGNAL axi_beat_live          : STD_LOGIC;
  SIGNAL axi_end_packet         : STD_LOGIC;

  SIGNAL reg_tsrc_rdy           : STD_LOGIC;

  -- Declare intermediate signals for referenced outputs
  SIGNAL s_axis_tx_tready_xhdl0 : STD_LOGIC;
  SIGNAL trn_tsof_xhdl2         : STD_LOGIC;
  SIGNAL trn_teof_xhdl1         : STD_LOGIC;
  SIGNAL trn_tsrc_rdy_xhdl3     : STD_LOGIC;
  SIGNAL axi_DW_1               : STD_LOGIC;
  SIGNAL axi_DW_2               : STD_LOGIC;
  SIGNAL axi_DW_3               : STD_LOGIC;

BEGIN
  -- Drive referenced outputs
  S_AXIS_TX_TREADY <= s_axis_tx_tready_xhdl0;
  TRN_TSOF         <= trn_tsof_xhdl2;
  TRN_TEOF         <= trn_teof_xhdl1;
  TRN_TSRC_RDY     <= trn_tsrc_rdy_xhdl3;

  axi_beat_live  <= '1' WHEN (S_AXIS_TX_TVALID = '1' AND s_axis_tx_tready_xhdl0 = '1') ELSE '0';
  axi_end_packet <= '1' WHEN (axi_beat_live = '1' AND S_AXIS_TX_TLAST = '1') ELSE '0';

  ------------------------------------------------------------------------------
  -- Convert TRN data format to AXI data format. AXI is DWORD swapped from TRN.
  -- 128-bit:                 64-bit:                  32-bit:
  -- TRN DW0 maps to AXI DW3  TRN DW0 maps to AXI DW1  TNR DW0 maps to AXI DW0
  -- TRN DW1 maps to AXI DW2  TRN DW1 maps to AXI DW0
  -- TRN DW2 maps to AXI DW1
  -- TRN DW3 maps to AXI DW0
  ------------------------------------------------------------------------------

  xhdl4 : IF (C_DATA_WIDTH = 128) GENERATE
    TRN_TD <= (reg_tdata(31 DOWNTO 0) & reg_tdata(63 DOWNTO 32) & reg_tdata(95 DOWNTO 64) & reg_tdata(127 DOWNTO 96));
  END GENERATE;

  xhdl5 : IF (C_DATA_WIDTH = 64) GENERATE
    TRN_TD <= (reg_tdata(31 DOWNTO 0) & reg_tdata(63 DOWNTO 32));
  END GENERATE;

  xhdl6 : IF (NOT(C_DATA_WIDTH = 64) AND NOT(C_DATA_WIDTH = 128)) GENERATE
    TRN_TD <= reg_tdata;
  END GENERATE;

  ------------------------------------------------------------------------------//
  -- Create trn_tsof. If we're not currently in a packet and TVALID goes high,  //
  -- assert TSOF.                                                               //
  ------------------------------------------------------------------------------//
  trn_tsof_xhdl2 <= ((NOT(trn_in_packet)) AND reg_tvalid);

  ------------------------------------------------------------------------------//
  -- Create trn_in_packet. This signal tracks if the TRN interface is currently //
  -- in the middle of a packet, which is needed to generate trn_tsof            //
  ------------------------------------------------------------------------------//
  PROCESS (USER_CLK)
  BEGIN
    IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
      IF (USER_RST = '1') THEN
        trn_in_packet <= '0'  AFTER (TCQ)*1 ps;
      ELSE
        IF ((trn_teof_xhdl1 = '0') AND (trn_tsof_xhdl2 = '1') AND (trn_tsrc_rdy_xhdl3 = '1') AND (TRN_TDST_RDY = '1')) THEN
          trn_in_packet <= '1'  AFTER (TCQ)*1 ps;
        ELSIF (((trn_in_packet = '1') AND (trn_teof_xhdl1 = '1') AND (trn_tsrc_rdy_xhdl3 = '1')) OR (trn_lnk_up = '0')) THEN
          trn_in_packet <= '0'  AFTER (TCQ)*1 ps;
        END IF;
      END IF;
    END IF;
  END PROCESS;


  ------------------------------------------------------------------------------//
  -- Create axi_in_packet. This signal tracks if the AXI interface is currently //
  -- in the middle of a packet, which is needed in case the link goes down.     //
  ------------------------------------------------------------------------------//
  PROCESS (USER_CLK)
  BEGIN
    IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
      IF (USER_RST = '1') THEN
        axi_in_packet <= '0' AFTER (TCQ)*1 ps;
      ELSE
        IF (axi_beat_live = '1' AND S_AXIS_TX_TLAST = '0') THEN
          axi_in_packet <= '1' AFTER (TCQ)*1 ps;
        ELSIF (axi_beat_live = '1') THEN
          axi_in_packet <= '0' AFTER (TCQ)*1 ps;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  ------------------------------------------------------------------------------//
  -- Create disable_trn. This signal asserts when the link goes down and        //
  -- triggers the deassertiong of trn_tsrc_rdy. The deassertion of disable_trn  //
  -- depends on C_PM_PRIORITY, as described below.                              //
  ------------------------------------------------------------------------------//
  PM_PRIORITY_TRN_FLUSH : IF (C_PM_PRIORITY) GENERATE
    -- In the C_PM_PRIORITY pipeline, we disable the TRN interfacefrom the time
    -- the link goes down until the the AXI interface is ready to accept packets
    -- again (via assertion of TREADY). By waiting for TREADY, we allow the
    -- previous value buffer to fill, so we're ready for any throttling by the
    -- user or the block.

    PROCESS (USER_CLK)
    BEGIN
      IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
        IF (USER_RST = '1') THEN
          reg_disable_trn <= '0' AFTER (TCQ)*1 ps;
        ELSE
          IF (trn_lnk_up = '0') THEN
            reg_disable_trn <= '1' AFTER (TCQ)*1 ps;
          ELSIF (flush_axi = '0' AND s_axis_tx_tready_xhdl0 = '1') THEN
            reg_disable_trn <= '0' AFTER (TCQ)*1 ps;
          END IF;
        END IF;
      END IF;
    END PROCESS;

    disable_trn <= reg_disable_trn;
  END GENERATE;

  -- In the throttle-controlled pipeline, we don't have a previous value buffer.
  -- The throttle control mechanism handles TREADY, so all we need to do is
  -- detect when the link goes down and disable the TRN interface until the link
  -- comes back up and the AXI interface is finished flushing any packets.
  TNRTL_CTL_TRN_FLUSH : IF (NOT(C_PM_PRIORITY)) GENERATE
    PROCESS (USER_CLK)
    BEGIN
      IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
        IF (USER_RST = '1') THEN
          reg_disable_trn <= '0' AFTER (TCQ)*1 ps;
        ELSE
          IF (axi_in_packet = '1' AND trn_lnk_up = '0' AND axi_end_packet = '0') THEN
            reg_disable_trn <= '1' AFTER (TCQ)*1 ps;
          ELSIF (axi_end_packet = '1') THEN
            reg_disable_trn <= '0' AFTER (TCQ)*1 ps;
          END IF;
        END IF;
      END IF;
    END PROCESS;

    disable_trn <= '1' WHEN (reg_disable_trn = '1' OR trn_lnk_up = '0') ELSE '0';
  END GENERATE;


  ------------------------------------------------------------------------------//
  -- Convert STRB to RREM. Here, we are converting the encoding method for the  //
  -- location of the EOF from AXI (tkeep) to TRN flavor (rrem).                 //
  ------------------------------------------------------------------------------//
  xhdl8 : IF (C_DATA_WIDTH = 128) GENERATE
  -----------------------------------------
  -- Conversion table:
  -- trem    | tkeep
  -- [1] [0] | [15:12] [11:8] [7:4] [3:0]
  -- -------------------------------------
  --  1   1  |   D3      D2    D1    D0
  --  1   0  |   --      D2    D1    D0
  --  0   1  |   --      --    D1    D0
  --  0   0  |   --      --    --    D0
  -----------------------------------------
    axi_DW_1    <= reg_tkeep(7);
    axi_DW_2    <= reg_tkeep(11);
    axi_DW_3    <= reg_tkeep(15);
    TRN_TREM(1) <= axi_DW_2;
    TRN_TREM(0) <= (axi_DW_3 OR (axi_DW_1 AND NOT(axi_DW_2)));
  END GENERATE;

  xhdl9 : IF (NOT(C_DATA_WIDTH = 128)) GENERATE
    xhdl10 : IF (C_DATA_WIDTH = 64) GENERATE
      TRN_TREM(0) <= reg_tkeep(7);
    END GENERATE;
    xhdl11 : IF (NOT(C_DATA_WIDTH = 64)) GENERATE
      TRN_TREM <= x"0";
    END GENERATE;
  END GENERATE;

  ------------------------------------------------------------------------------
  -- Create remaining TRN signals
  ------------------------------------------------------------------------------
  trn_teof_xhdl1   <= reg_tlast;
  TRN_TECRC_GEN    <= reg_tuser(0);
  TRN_TERRFWD      <= reg_tuser(1);
  TRN_TSTR         <= reg_tuser(2);
  TRN_TSRC_DSC     <= reg_tuser(3);

  ------------------------------------------------------------------------------
  -- Pipeline stage
  ------------------------------------------------------------------------------
  -- We need one of two approaches for the pipeline stage depending on the
  -- C_PM_PRIORITY parameter.
  xhdl12 : IF (NOT(C_PM_PRIORITY)) GENERATE
    PROCESS (USER_CLK)
    BEGIN
      IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
        IF (USER_RST = '1') THEN
          reg_tdata      <= (others => '0') AFTER (TCQ)*1 ps;
          reg_tvalid     <= '0'  AFTER (TCQ)*1 ps;
          reg_tkeep      <= (others => '0') AFTER (TCQ)*1 ps;
          reg_tlast      <= '0'    AFTER (TCQ)*1 ps;
          reg_tuser      <= (others => '0') AFTER (TCQ)*1 ps;
          reg_tsrc_rdy   <= '0'    AFTER (TCQ)*1 ps;
        ELSE
          reg_tdata      <= S_AXIS_TX_TDATA   AFTER (TCQ)*1 ps;
          reg_tvalid     <= S_AXIS_TX_TVALID  AFTER (TCQ)*1 ps;
          reg_tkeep      <= s_axis_tx_tkeep   AFTER (TCQ)*1 ps;
          reg_tlast      <= S_AXIS_TX_TLAST   AFTER (TCQ)*1 ps;
          reg_tuser      <= S_AXIS_TX_TUSER   AFTER (TCQ)*1 ps;

          -- Hold trn_tsrc_rdy low when flushing a packet
          reg_tsrc_rdy   <= (axi_beat_live AND (NOT disable_trn)) AFTER (TCQ)*1 ps;
        END IF;
      END IF;
    END PROCESS;

    trn_tsrc_rdy_xhdl3     <= reg_tsrc_rdy;
    -- With TX packet boundary throttling, TREADY is pipelined in
    -- axi_basic_tx_thrtl_ctl and wired through here.
    s_axis_tx_tready_xhdl0 <= TREADY_THRTL;

  END GENERATE;

  --**************************************************************************--

  -- If C_PM_PRIORITY is set to TRUE, that means the user prefers to have all PM
  -- functionality intact isntead of TX packet boundary throttling. Now the
  -- Block could back-pressure at any time, which creates the standard problem
  -- of potential data loss due to the handshaking latency. Here we need a
  -- previous value buffer, just like the RX data path.
  xhdl13 : IF (C_PM_PRIORITY) GENERATE

    --------------------------------------------------------------------------
    -- Previous value buffer
    -- ---------------------
    -- We are inserting a pipeline stage in between AXI and TRN, which causes
    -- some issues with handshaking signals trn_tsrc_rdy/s_axis_tx_tready.
    -- The added cycle of latency in the path causes the Block to fall behind
    -- the AXI interface whenever it throttles.
    --
    -- To avoid loss of data, we must keep the previous value of all
    -- s_axis_tx_* signals in case the Block throttles.
    --------------------------------------------------------------------------
    PROCESS (USER_CLK)
      BEGIN
        IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
          IF (USER_RST = '1') THEN
            tdata_prev     <= (others =>'0' ) AFTER (TCQ)*1 ps;
            tvalid_prev    <= '0'             AFTER (TCQ)*1 ps;
            tkeep_prev     <= (others =>'0' ) AFTER (TCQ)*1 ps;
            tlast_prev     <= '0'             AFTER (TCQ)*1 ps;
            tuser_prev     <= "0000"          AFTER (TCQ)*1 ps;
          ELSE
            -- prev buffer works by checking s_axis_tx_tready. When s_axis_tx_tready is
            -- asserted, a new value is present on the interface.
            IF ((NOT(s_axis_tx_tready_xhdl0)) = '1') THEN
              tdata_prev  <= tdata_prev   AFTER (TCQ)*1 ps;
              tvalid_prev <= tvalid_prev  AFTER (TCQ)*1 ps;
              tkeep_prev  <= tkeep_prev   AFTER (TCQ)*1 ps;
              tlast_prev  <= tlast_prev   AFTER (TCQ)*1 ps;
              tuser_prev  <= tuser_prev   AFTER (TCQ)*1 ps;
            ELSE
              tdata_prev  <= S_AXIS_TX_TDATA   AFTER (TCQ)*1 ps;
              tvalid_prev <= S_AXIS_TX_TVALID  AFTER (TCQ)*1 ps;
              tkeep_prev  <= s_axis_tx_tkeep   AFTER (TCQ)*1 ps;
              tlast_prev  <= S_AXIS_TX_TLAST   AFTER (TCQ)*1 ps;
              tuser_prev  <= S_AXIS_TX_TUSER   AFTER (TCQ)*1 ps;
            END IF;
          END IF;
        END IF;
      END PROCESS;

      -- Create special buffer which locks in the propper value of TDATA depending
      -- on whether the user is throttling or not. This buffer has three states:
      --
      --       HOLD state: TDATA maintains its current value
      --                   - the Block has throttled the PCIe block
      --   PREVIOUS state: the buffer provides the previous value on TDATA
      --                   - the Block has finished throttling, and is a little
      --                     behind the PCIe user
      --    CURRENT state: the buffer passes the current value on TDATA
      --                   - the Block is caught up and ready to receive the latest
      --                     data from the PCIe user
      PROCESS (USER_CLK)
      BEGIN
        IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
          IF (USER_RST = '1') THEN
            reg_tdata <= (others => '0') AFTER (TCQ)*1 ps;
            reg_tvalid <= '0'  AFTER (TCQ)*1 ps;
            reg_tkeep <= (others => '0')  AFTER (TCQ)*1 ps;
            reg_tlast <= '0'  AFTER (TCQ)*1 ps;

            reg_tuser <= (others => '0') AFTER (TCQ)*1 ps;
            reg_tdst_rdy <= '0' AFTER (TCQ)*1 ps;
          ELSE

            reg_tdst_rdy <= trn_tdst_rdy AFTER (TCQ)*1 ps;
            IF ((NOT(data_hold)) = '1') THEN
              -- PREVIOUS state
              IF (data_prev = '1') THEN
                reg_tdata  <= tdata_prev   AFTER (TCQ)*1 ps;
                reg_tvalid <= tvalid_prev AFTER (TCQ)*1 ps;
                reg_tkeep  <= tkeep_prev   AFTER (TCQ)*1 ps;
                reg_tlast  <= tlast_prev   AFTER (TCQ)*1 ps;
                reg_tuser  <= tuser_prev   AFTER (TCQ)*1 ps;
              ELSE
                -- CURRENT state
                reg_tdata  <= S_AXIS_TX_TDATA   AFTER (TCQ)*1 ps;
                reg_tvalid <= S_AXIS_TX_TVALID  AFTER (TCQ)*1 ps;
                reg_tkeep  <= s_axis_tx_tkeep   AFTER (TCQ)*1 ps;
                reg_tlast  <= S_AXIS_TX_TLAST   AFTER (TCQ)*1 ps;
                reg_tuser  <= S_AXIS_TX_TUSER   AFTER (TCQ)*1 ps;
              END IF;
            END IF;
          -- else HOLD state
          END IF;
        END IF;
      END PROCESS;


      -- Logic to instruct pipeline to hold its value
      data_hold <= ((NOT(TRN_TDST_RDY) AND trn_tsrc_rdy_xhdl3));

    -- Logic to instruct pipeline to use previous bus values. Always use
    -- previous value after holding a value.
    PROCESS (USER_CLK)
    BEGIN
       IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
          IF (USER_RST = '1') THEN
             data_prev <= '0'  AFTER (TCQ)*1 ps;
          ELSE
             data_prev <= data_hold  AFTER (TCQ)*1 ps;
          END IF;
       END IF;
    END PROCESS;


      --------------------------------------------------------------------------
      --  Create trn_tsrc_rdy. If we're flushing the TRN hold trn_tsrc_rdy low.
      --------------------------------------------------------------------------
      trn_tsrc_rdy_xhdl3 <= reg_tvalid;

      --------------------------------------------------------------------------//
      -- Create TREADY                                                          //
      --------------------------------------------------------------------------//
      PROCESS (USER_CLK)
      BEGIN
        IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
          IF (USER_RST = '1') THEN
            reg_tready <= '0' AFTER (TCQ)*1 ps;
          ELSE
            -- If the link went down and we need to flush a packet in flight, hold
            -- TREADY high
            IF (flush_axi = '1' AND axi_end_packet = '0') THEN
              reg_tready <= '1' AFTER (TCQ)*1 ps;

              -- If the link is up, TREADY is as follows:
              --   TREADY = 1 when trn_tsrc_rdy == 0
              --      - While idle, keep the pipeline primed and ready for the next
              --        packet
              --
              --   TREADY = trn_tdst_rdy when trn_tsrc_rdy == 1
              --      - While in packet, throttle pipeline based on state of TRN
            ELSIF(trn_lnk_up = '1') THEN
              reg_tready <= TRN_TDST_RDY OR (NOT trn_tsrc_rdy_xhdl3) AFTER (TCQ)*1 ps;
            ELSE
              -- If the link is down and we're not flushing a packet, hold TREADY low
              -- wait for link to come back up
              reg_tready <= '0'  AFTER (TCQ)*1 ps;
            END IF;
          END IF;
        END IF;
      END PROCESS;

    s_axis_tx_tready_xhdl0 <= reg_tready;

    ----------------------------------------------------------------------------//
    -- Create flush_axi. This signal detects if the link goes down while the    //
    -- AXI interface is in packet. In this situation, we need to flush the      //
    -- packet through the AXI interface and discard it.                         //
    ----------------------------------------------------------------------------//
    PROCESS (USER_CLK)
    BEGIN
      IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
        IF (USER_RST = '1') THEN
          flush_axi <= '0' AFTER (TCQ)*1 ps;
        ELSE
          -- If the AXI interface is in packet and the link goes down, purge it.
          IF (axi_in_packet = '1' AND trn_lnk_up = '0' AND axi_end_packet = '0') THEN
            flush_axi <= '1' AFTER (TCQ)*1 ps;
          -- The packet is finished, so we're done flushing.
          ELSIF (axi_end_packet = '1') THEN
            flush_axi <= '0' AFTER (TCQ)*1 ps;
          END IF;
        END IF;
      END IF;
    END PROCESS;
  END GENERATE;
END trans;
