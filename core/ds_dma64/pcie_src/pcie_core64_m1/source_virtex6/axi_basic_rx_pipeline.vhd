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
-- File       : axi_basic_rx_pipeline.vhd
-- Version    : 2.3
--
-- Description:
--  TRN to AXI RX pipeline. Converts received data from TRN protocol to AXI.
--
--  Notes:
--  Optional notes section.
--
--  Hierarchical:
--    axi_basic_top
--      axi_basic_rx
--        axi_basic_rx_pipeline
--
-------------------------------------------------------------------------------
-- Library Declarations
--------------------------------------------------------------------------------

LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;


ENTITY axi_basic_rx_pipeline IS
   GENERIC (
      C_DATA_WIDTH            : INTEGER := 128;           -- RX/TX interface data width
      C_FAMILY                : STRING := "X7";           -- Targeted FPGA family
      TCQ                     : INTEGER := 1;             -- Clock to Q time

      C_REM_WIDTH             : INTEGER := 1;             -- trem/rrem width
      C_STRB_WIDTH            : INTEGER := 4              -- TSTRB width
   );
   PORT (

      -- AXI RX
      -------------
      M_AXIS_RX_TDATA         : OUT STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) ;       -- RX data to user
      M_AXIS_RX_TVALID        : OUT STD_LOGIC                                   ;       -- RX data is valid
      M_AXIS_RX_TREADY        : IN STD_LOGIC                                    ;       -- RX ready for data
      M_AXIS_RX_TSTRB         : OUT STD_LOGIC_VECTOR(C_STRB_WIDTH - 1 DOWNTO 0) ;       -- RX strobe byte enables
      M_AXIS_RX_TLAST         : OUT STD_LOGIC                                   ;       -- RX data is last
      M_AXIS_RX_TUSER         : OUT STD_LOGIC_VECTOR(21 DOWNTO 0)               ;       -- RX user signals

       -- TRN RX
       -------------
      TRN_RD                  : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0)  ;       -- RX data from block
      TRN_RSOF                : IN STD_LOGIC                                    ;       -- RX start of packet
      TRN_REOF                : IN STD_LOGIC                                    ;       -- RX end of packet
      TRN_RSRC_RDY            : IN STD_LOGIC                                    ;       -- RX source ready
      TRN_RDST_RDY            : OUT STD_LOGIC                                   ;       -- RX destination ready
      TRN_RSRC_DSC            : IN STD_LOGIC                                    ;       -- RX source discontinue
      TRN_RREM                : IN STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0)   ;       -- RX remainder
      TRN_RERRFWD             : IN STD_LOGIC                                    ;       -- RX error forward
      TRN_RBAR_HIT            : IN STD_LOGIC_VECTOR(6 DOWNTO 0)                 ;       -- RX BAR hit
      TRN_RECRC_ERR           : IN STD_LOGIC                                    ;       -- RX ECRC error

      -- Null Inputs
      -------------
      NULL_RX_TVALID          : IN STD_LOGIC                                    ;       -- NULL generated tvalid
      NULL_RX_TLAST           : IN STD_LOGIC                                    ;       -- NULL generated tlast
      NULL_RX_TSTRB           : IN STD_LOGIC_VECTOR(C_STRB_WIDTH - 1 DOWNTO 0)  ;       -- NULL generated tstrb
      NULL_RDST_RDY           : IN STD_LOGIC                                    ;       -- NULL generated rdst_rdy
      NULL_IS_EOF             : IN STD_LOGIC_VECTOR(4 DOWNTO 0)                 ;       -- NULL generated is_eof

      -- System
      -------------
      NP_COUNTER              : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)                ;       -- Non-posted counter
      USER_CLK                : IN STD_LOGIC                                    ;       -- user clock from block
      USER_RST                : IN STD_LOGIC                                            -- user reset from block
   );
END axi_basic_rx_pipeline;

ARCHITECTURE trans OF axi_basic_rx_pipeline IS

   SIGNAL is_sof                 : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL is_sof_prev            : STD_LOGIC_VECTOR(4 DOWNTO 0);

   SIGNAL is_eof                 : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL is_eof_prev            : STD_LOGIC_VECTOR(4 DOWNTO 0);

   SIGNAL reg_tstrb              : STD_LOGIC_VECTOR(C_STRB_WIDTH - 1 DOWNTO 0);
   SIGNAL tstrb                  : STD_LOGIC_VECTOR(C_STRB_WIDTH - 1 DOWNTO 0);
   SIGNAL tstrb_prev             : STD_LOGIC_VECTOR(C_STRB_WIDTH - 1 DOWNTO 0);

   SIGNAL reg_tlast              : STD_LOGIC;
   SIGNAL rsrc_rdy_filtered      : STD_LOGIC;

   SIGNAL trn_rd_DW_swapped      : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
   SIGNAL trn_rd_prev            : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);

   SIGNAL data_hold              : STD_LOGIC;
   SIGNAL data_prev              : STD_LOGIC;

   SIGNAL trn_reof_prev          : STD_LOGIC;
   SIGNAL trn_rrem_prev          : STD_LOGIC_VECTOR(C_REM_WIDTH - 1 DOWNTO 0);
   SIGNAL trn_rsrc_rdy_prev      : STD_LOGIC;
   SIGNAL trn_rsrc_dsc_prev      : STD_LOGIC;
   SIGNAL trn_rsof_prev          : STD_LOGIC;
   SIGNAL trn_rbar_hit_prev      : STD_LOGIC_VECTOR(6 DOWNTO 0);
   SIGNAL trn_rerrfwd_prev       : STD_LOGIC;
   SIGNAL trn_recrc_err_prev     : STD_LOGIC;

   -- Null packet handling signals
   SIGNAL null_mux_sel           : STD_LOGIC;
   SIGNAL trn_in_packet          : STD_LOGIC;
   SIGNAL dsc_flag               : STD_LOGIC;
   SIGNAL dsc_detect             : STD_LOGIC;
   SIGNAL reg_dsc_detect         : STD_LOGIC;
   SIGNAL trn_rsrc_dsc_d         : STD_LOGIC;

   -- Declare intermediate signals for referenced outputs
   SIGNAL m_axis_rx_tdata_xhdl0  : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
   SIGNAL m_axis_rx_tvalid_xhdl2 : STD_LOGIC;
   SIGNAL m_axis_rx_tuser_xhdl1  : STD_LOGIC_VECTOR(21 DOWNTO 0);
   SIGNAL trn_rdst_rdy_xhdl4     : STD_LOGIC;
   SIGNAL mrd_lower              : STD_LOGIC;
   SIGNAL mrd_lk_lower           : STD_LOGIC;
   SIGNAL io_rdwr_lower          : STD_LOGIC;
   SIGNAL cfg_rdwr_lower         : STD_LOGIC;
   SIGNAL atomic_lower           : STD_LOGIC;
   SIGNAL np_pkt_lower           : STD_LOGIC;
   SIGNAL mrd_upper              : STD_LOGIC;
   SIGNAL mrd_lk_upper           : STD_LOGIC;
   SIGNAL io_rdwr_upper          : STD_LOGIC;
   SIGNAL cfg_rdwr_upper         : STD_LOGIC;
   SIGNAL atomic_upper           : STD_LOGIC;
   SIGNAL np_pkt_upper           : STD_LOGIC;
   SIGNAL pkt_accepted           : STD_LOGIC;
   SIGNAL reg_np_counter         : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN
   -- Drive referenced outputs
   M_AXIS_RX_TDATA     <= m_axis_rx_tdata_xhdl0;
   M_AXIS_RX_TVALID    <= m_axis_rx_tvalid_xhdl2;
   M_AXIS_RX_TUSER     <= m_axis_rx_tuser_xhdl1;
   TRN_RDST_RDY        <= trn_rdst_rdy_xhdl4;

   -- Create "filtered" version of rsrc_rdy, where discontinued SOFs are removed
   rsrc_rdy_filtered <= trn_rsrc_rdy AND (trn_in_packet OR (trn_rsof AND NOT trn_rsrc_dsc));

   --------------------------------------------------------------------------------
   -- Previous value buffer                                                      --
   -- ---------------------                                                      --
   -- We are inserting a pipeline stage in between TRN and AXI, which causes     --
   -- some issues with handshaking signals m_axis_rx_tready/trn_rdst_rdy. The    --
   -- added cycle of latency in the path causes the user design to fall behind   --
   -- the TRN interface whenever it throttles.                                   --
   --                                                                            --
   -- To avoid loss of data, we must keep the previous value of all trn_r*       --
   -- signals in case the user throttles.                                        --
   --------------------------------------------------------------------------------
   PROCESS (USER_CLK)
   BEGIN
      IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
         IF (USER_RST = '1') THEN
            trn_rd_prev        <=  (others => '0')AFTER 1 ps;
            trn_rsof_prev      <=  '0'  AFTER (TCQ)*1 ps;
            trn_rrem_prev      <=  (others => '0') AFTER (TCQ)*1 ps;
            trn_rsrc_rdy_prev  <=  '0' AFTER 1 ps;
            trn_rbar_hit_prev  <=  (others => '0') AFTER 1 ps;
            trn_rerrfwd_prev   <=  '0' AFTER 1 ps;
            trn_recrc_err_prev <=  '0' AFTER 1 ps;
            trn_reof_prev      <=  '0' AFTER 1 ps;
            trn_rsrc_dsc_prev  <=  '0' AFTER 1 ps;
         ELSE
                  -- prev buffer works by checking trn_rdst_rdy. When trn_rdst_rdy is
                  -- asserted, a new value is present on the interface.

            IF (trn_rdst_rdy_xhdl4 = '1') THEN
               trn_rd_prev        <= trn_rd_DW_swapped  AFTER (TCQ)*1 ps;
               trn_rsof_prev      <= TRN_RSOF           AFTER (TCQ)*1 ps;
               trn_rrem_prev      <= TRN_RREM           AFTER (TCQ)*1 ps;
               trn_rbar_hit_prev  <= TRN_RBAR_HIT       AFTER (TCQ)*1 ps;
               trn_rerrfwd_prev   <= TRN_RERRFWD        AFTER (TCQ)*1 ps;
               trn_recrc_err_prev <= TRN_RECRC_ERR      AFTER (TCQ)*1 ps;
               trn_rsrc_rdy_prev  <= rsrc_rdy_filtered  AFTER (TCQ)*1 ps;
               trn_reof_prev      <= trn_reof           AFTER (TCQ)*1 ps;
               trn_rsrc_dsc_prev  <= TRN_RSRC_DSC OR dsc_flag AFTER (TCQ)*1 ps;
            END IF;
         END IF;
      END IF;
   END PROCESS;

  --------------------------------------------------------------------------------
  -- Create TDATA
  ------------------------------------------------------------------------------
  -- Convert TRN data format to AXI data format. AXI is DWORD swapped from TRN
  -- 128-bit:                 64-bit:                  32-bit:
  -- TRN DW0 maps to AXI DW3  TRN DW0 maps to AXI DW1  TNR DW0 maps to AXI DW0
  -- TRN DW1 maps to AXI DW2  TRN DW1 maps to AXI DW0
  -- TRN DW2 maps to AXI DW1
  -- TRN DW3 maps to AXI DW0

   xhdl7 : IF (C_DATA_WIDTH = 128) GENERATE
      trn_rd_DW_swapped <= (TRN_RD(31 DOWNTO 0) & TRN_RD(63 DOWNTO 32) & TRN_RD(95 DOWNTO 64) & TRN_RD(127 DOWNTO 96));
   END GENERATE;
   --xhdl8 : IF (NOT(C_DATA_WIDTH = 128)) GENERATE
   xhdl9 : IF (C_DATA_WIDTH = 64) GENERATE
           trn_rd_DW_swapped <= (TRN_RD(31 DOWNTO 0) & TRN_RD(63 DOWNTO 32));
   END GENERATE;

   xhdl10 : IF (NOT(C_DATA_WIDTH = 64) AND NOT(C_DATA_WIDTH = 128)) GENERATE
           trn_rd_DW_swapped <= TRN_RD;
   END GENERATE;
   --END GENERATE;

   -- Create special buffer which locks in the proper value of TDATA depending
   -- on whether the user is throttling or not. This buffer has three states:
   --
   --   HOLD state: TDATA maintains its current value
   --                   - the user has throttled the PCIe block
   --   PREVIOUS state: the buffer provides the previous value on trn_rd
   --                   - the user has finished throttling, and is a little behind
   --                     the PCIe block
   --   CURRENT state: the buffer passes the current value on trn_rd
   --                   - the user is caught up and ready to receive the latest
   --                     data from the PCIe block

   PROCESS (USER_CLK)
   BEGIN
           IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
                   IF (USER_RST = '1') THEN
                           m_axis_rx_tdata_xhdl0 <= (OTHERS=>'0') AFTER (TCQ)*1 ps;
                   ELSE
                           IF ((NOT(data_hold)) = '1') THEN
                                    -- PREVIOUS state
                                   IF (data_prev = '1') THEN
                                           m_axis_rx_tdata_xhdl0 <= trn_rd_prev  AFTER (TCQ)*1 ps;
                                   -- CURRENT state
                                   ELSE
                                           m_axis_rx_tdata_xhdl0 <= trn_rd_DW_swapped  AFTER (TCQ)*1 ps;
                                   END IF;
                           END IF;
                           -- else HOLD state
                   END IF;
           END IF;
   END PROCESS;

   -- Logic to instruct pipeline to hold its value
   data_hold <= (NOT(M_AXIS_RX_TREADY) AND m_axis_rx_tvalid_xhdl2);

   -- Logic to instruct pipeline to use previous bus values. Always use previous value after holding a value.
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

   ------------------------------------------------------------------------------
   -- Create TVALID, TLAST, TSTRB, TUSER
   -- -----------------------------------
   -- Use the same strategy for these signals as for TDATA, except here we need
   -- an extra provision for null packets.
   ------------------------------------------------------------------------------
   PROCESS (USER_CLK)
   BEGIN
      IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
              IF (USER_RST = '1') THEN
                      m_axis_rx_tvalid_xhdl2 <= '0'  AFTER (TCQ)*1 ps;
                      reg_tlast <= '0' AFTER (TCQ)*1 ps;
                      reg_tstrb <= (others => '1') AFTER (TCQ)*1 ps;
                      m_axis_rx_tuser_xhdl1 <= (others => '0')  AFTER (TCQ)*1 ps;
              ELSE
                 IF (data_hold = '0') THEN
                      -- If in a null packet, use null generated value
                      IF (null_mux_sel = '1') THEN
                              m_axis_rx_tvalid_xhdl2 <= NULL_RX_TVALID  AFTER (TCQ)*1 ps;
                              reg_tlast <= NULL_RX_TLAST AFTER (TCQ)*1 ps;
                              reg_tstrb <= NULL_RX_TSTRB AFTER (TCQ)*1 ps;
                              m_axis_rx_tuser_xhdl1 <= (NULL_IS_EOF & "00000000000000000") AFTER (TCQ)*1 ps;

                      -- PREVIOUS state
                      ELSIF (data_prev = '1') THEN
                              m_axis_rx_tvalid_xhdl2 <= (trn_rsrc_rdy_prev  OR dsc_flag) AFTER (TCQ)*1 ps;
                              reg_tlast <= trn_reof_prev AFTER (TCQ)*1 ps;
                              reg_tstrb <= tstrb_prev AFTER (TCQ)*1 ps;
                              m_axis_rx_tuser_xhdl1 <= (is_eof_prev & "00" & is_sof_prev & '0' & trn_rbar_hit_prev & trn_rerrfwd_prev & trn_recrc_err_prev) AFTER (TCQ)*1 ps;
                                              -- TUSER bits [21:17] & TUSER bits [16:15] & TUSER bits [14:10] & TUSER bits [9] & TUSER bits [8:2] & TUSER bit  [1] & TUSER bit  [0]

                      -- CURRENT state
                      ELSE

                              m_axis_rx_tvalid_xhdl2 <= (rsrc_rdy_filtered OR dsc_flag) AFTER (TCQ)*1 ps;
                              reg_tlast <= TRN_REOF AFTER (TCQ)*1 ps;
                              reg_tstrb <= tstrb AFTER (TCQ)*1 ps;
                              m_axis_rx_tuser_xhdl1 <= (is_eof & "00" & is_sof & '0' & trn_rbar_hit & TRN_RERRFWD & TRN_RECRC_ERR) AFTER (TCQ)*1 ps;
                                                  -- TUSER bits [21:17] & TUSER bits [16:15] & TUSER bits [14:10] & TUSER bits [9] & TUSER bits [8:2] & TUSER bit  [1] & TUSER bit  [0]
                       END IF;
                 END IF;
                 -- else HOLD state
              END IF;
      END IF;
   END PROCESS;

-- Hook up TLAST and TSTRB depending on interface width
   xhdl11 : IF (C_DATA_WIDTH = 128) GENERATE
            -- For 128-bit interface, don't pass TLAST and TSTRB to user (is_eof and is_data passed to user instead). reg_tlast is still used internally.
           M_AXIS_RX_TLAST <= '0';
           M_AXIS_RX_TSTRB <= (others => '1');
   END GENERATE;


 -- For 64/32-bit interface, pass TLAST to user.
   xhdl12 : IF (NOT(C_DATA_WIDTH = 128)) GENERATE
           M_AXIS_RX_TLAST <= reg_tlast;
           M_AXIS_RX_TSTRB <= reg_tstrb;
   END GENERATE;

   --------------------------------------------------------------------------------
   -- Create TSTRB                                                              ---
   -- ------------                                                              ---
   -- Convert RREM to STRB. Here, we are converting the encoding method for the ---
   -- location of the EOF from TRN flavor (rrem) to AXI (TSTRB).                ---
   --                                                                           ---
   -- NOTE: for each configuration, we need two values of TSTRB, the current and---
   --       previous values. The need for these two values is described below.  ---
   --------------------------------------------------------------------------------
   xhdl13 : IF (C_DATA_WIDTH = 128) GENERATE
           -- TLAST and TSTRB not used in 128-bit interface. is_sof and is_eof used instead.
           tstrb <= x"0000";
           tstrb_prev <= x"0000";
   END GENERATE;

   xhdl14 : IF (C_DATA_WIDTH /= 128) GENERATE
           xhdl15 : IF (C_DATA_WIDTH = 64) GENERATE
                   -- 64-bit interface: contains 2 DWORDs per cycle, for a total of 8 bytes
                   -- TSTRB has only two possible values here, 0xFF or 0x0F
                   tstrb      <= x"FF" WHEN (TRN_RREM = "11") ELSE x"0F";
                   tstrb_prev <= x"FF" WHEN (trn_rrem_prev = "11" ) ELSE x"0F";
           END GENERATE;
           xhdl16 : IF (C_DATA_WIDTH /= 64) GENERATE
                   -- 32-bit interface: contains 1 DWORD per cycle, for a total of 4 bytes
                   -- TSTRB is always 0xF in this case, due to the nature of the PCIe block
                   tstrb      <= "1111";
                   tstrb_prev <= "1111";
           END GENERATE;
   END GENERATE;

   ------------------------------------------------------------------------------//
   -- Create is_sof                                                              //
   -- -------------                                                              //
   -- is_sof is a signal to the user indicating the location of SOF in TDATA   . //
   -- Due to inherent 64-bit alignment of packets from the block, the only       //
   -- possible values are:                                                       //
   --                      Value                      Valid data widths          //
   --                      5'b11000 (sof @ byte 8)    128                        //
   --                      5'b10000 (sof @ byte 0)    128, 64, 32                //
   --                      5'b00000 (sof not present) 128, 64, 32                //
   ------------------------------------------------------------------------------//
   xhdl17 : IF (C_DATA_WIDTH = 128) GENERATE
           is_sof <= (((NOT(TRN_RSRC_DSC)) AND TRN_RSOF) & ((NOT(TRN_RREM(1))) AND TRN_RSOF ) & "000");
           is_sof_prev <= (((trn_rsof_prev AND (NOT(trn_rsrc_dsc_prev)))) & (trn_rsof_prev AND (NOT(trn_rrem_prev(1)))) & "000");
                          -- bit 4:   enable bit 3:   sof @ byte 8? bit 2-0: hardwired 0
   END GENERATE;

   xhdl18 : IF (NOT(C_DATA_WIDTH = 128)) GENERATE
           is_sof      <= ((TRN_RSOF AND (NOT TRN_RSRC_DSC)) & "0000"); -- bit 4: enable, bits 3-0: hardwired 0
           is_sof_prev <= ((trn_rsof_prev AND (NOT trn_rsrc_dsc_prev)) & "0000");
   END GENERATE;

   ------------------------------------------------------------------------------//
   -- Create is_eof                                                              //
   -- -------------                                                              //
   -- is_eof is a signal to the user indicating the location of EOF in TDATA   . //
   -- Due to DWORD granularity of packets from the block, the only               //
   -- possible values are:                                                       //
   --                      Value                      Valid data widths          //
   --                      5'b11111 (eof @ byte 15)   128                        //
   --                      5'b11011 (eof @ byte 11)   128                        //
   --                      5'b10111 (eof @ byte 7)    128, 64                    //
   --                      5'b10011 (eof @ byte 3)`   128, 64, 32                //
   --                      5'b00011 (eof not present) 128, 64, 32                //
   ------------------------------------------------------------------------------//
   xhdl19 : IF (C_DATA_WIDTH = 128) GENERATE
           is_eof       <= (TRN_REOF & TRN_RREM & "11");
           is_eof_prev  <= (trn_reof_prev & trn_rrem_prev & "11");
           -- bit 4:   enable bit 3-2: encoded eof loc from block  bit 1-0: hardwired 1
   END GENERATE;

   xhdl20 : IF (C_DATA_WIDTH = 64) GENERATE
           is_eof       <= (TRN_REOF & '0' & TRN_RREM & "11");
           is_eof_prev  <= (trn_reof_prev & '0' & trn_rrem_prev & "11");
           -- bit 4: enable, bit 3: hardwired 0, bit 2: encoded eof loc from  block, bit 1-0: hardwired 1
   END GENERATE;

   --------------------------------------------------------------------------------
   xhdl20A : IF (C_DATA_WIDTH = 32) GENERATE
           is_eof       <= (TRN_REOF & "0011");
           is_eof_prev  <= (trn_reof_prev & "0011");
           -- bit 4: enable, bit 3: hardwired 0, bit 2: encoded eof loc from  block, bit 1-0: hardwired 1
   END GENERATE;


   -- Create trn_rdst_rdy                                                        --
   --------------------------------------------------------------------------------
   PROCESS (USER_CLK)
   BEGIN
      IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
              IF (USER_RST = '1') THEN
                      trn_rdst_rdy_xhdl4 <= '0' AFTER (TCQ)*1 ps;
              ELSE
                      -- If in a null packet, use null generated value
                      IF (null_mux_sel = '1' AND M_AXIS_RX_TREADY = '1') THEN
                              trn_rdst_rdy_xhdl4 <= NULL_RDST_RDY AFTER (TCQ)*1 ps;
                      -- If a discontinue needs to be serviced, throttle the block until we are
                      -- ready to pad out the packet
                      ELSIF (dsc_flag = '1') THEN
                              trn_rdst_rdy_xhdl4 <= '0' AFTER (TCQ)*1 ps;
                      -- If in a packet, pass user back-pressure directly to block
                      ELSIF (m_axis_rx_tvalid_xhdl2 = '1') THEN
                              trn_rdst_rdy_xhdl4 <= M_AXIS_RX_TREADY AFTER (TCQ)*1 ps;
                      -- If idle, default to no back-pressure. We need to default to the
                      -- "ready to accept data" state to make sure we catch the first
                      -- clock of data of a new packet.
                      ELSE
                              trn_rdst_rdy_xhdl4 <= '1' AFTER (TCQ)*1 ps;
                      END IF;
              END IF;
      END IF;
   END PROCESS;

   ------------------------------------------------------------------------------//
   -- Create null_mux_sel                                                        //
   -- null_mux_sel is the signal used to detect a discontinue situation and      //
   -- mux in the null packet generated in rx_null_gen. Only mux in null data     //
   -- when not at the beginningof a packet. SOF discontinues do not require      //
   -- padding, as the whole packet is simply squashed instead.                   //
   ------------------------------------------------------------------------------//
   PROCESS (USER_CLK)
   BEGIN
      IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
              IF (USER_RST = '1') THEN
                      null_mux_sel <= '0' AFTER (TCQ)*1 ps;
              ELSE
                      -- NULL packet done
                      IF (null_mux_sel = '1' AND NULL_RX_TLAST = '1' AND M_AXIS_RX_TREADY = '1') THEN
                              null_mux_sel <= '0' AFTER (TCQ)*1 ps;
                      -- Discontinue detected and we're in packet, so switch to NULL packet
                      ELSIF (dsc_flag = '1' AND data_hold = '0') THEN
                              null_mux_sel <= '1' AFTER (TCQ)*1 ps;
                      END IF;
              END IF;
      END IF;
   END PROCESS;

   ------------------------------------------------------------------------------//
   -- Create discontinue tracking signals                                        //
   ------------------------------------------------------------------------------//
   -- Create signal trn_in_packet, which is needed to validate trn_rsrc_dsc. We
   -- should ignore trn_rsrc_dsc when it's asserted out-of-packet.
   PROCESS (USER_CLK)
   BEGIN
      IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
              IF (USER_RST = '1') THEN
                      trn_in_packet <= '0' AFTER (TCQ)*1 ps;
              ELSE
                      IF ((TRN_RSOF = '1') AND (NOT(TRN_REOF = '1')) AND rsrc_rdy_filtered = '1' AND trn_rdst_rdy_xhdl4 = '1') THEN
                              trn_in_packet <= '1' AFTER (TCQ)*1 ps;
                      ELSIF (TRN_RSRC_DSC = '1') THEN
                              trn_in_packet <= '0' AFTER (TCQ)*1 ps;
                      ELSIF (TRN_REOF= '1' AND (NOT(TRN_RSOF= '1')) AND TRN_RSRC_RDY = '1' AND trn_rdst_rdy_xhdl4 = '1') THEN
                              trn_in_packet <= '0';
                      END IF;
              END IF;
      END IF;
   END PROCESS;

   -- Create dsc_flag, which identifies and stores mid-packet discontinues that
   -- require null packet padding. This signal is edge sensitive to trn_rsrc_dsc,
   -- to make sure we don't service the same dsc twice in the event that
   -- trn_rsrc_dsc stays asserted for longer than it takes to pad out the packet.

   dsc_detect <= TRN_RSRC_DSC and (not(trn_rsrc_dsc_d)) and trn_in_packet and ((not(TRN_RSOF)) or TRN_REOF) and (not(trn_rdst_rdy_xhdl4 and TRN_REOF));

   PROCESS (USER_CLK,USER_RST)
   BEGIN
           IF (USER_CLk'EVENT AND USER_CLK = '1') THEN
                   IF (USER_RST = '1') THEN
                           reg_dsc_detect <= '0' AFTER (TCQ)*1 ps;
                           trn_rsrc_dsc_d <= '0' AFTER (TCQ)*1 ps;
                   ELSE
                           IF (dsc_detect = '1') THEN
                                   reg_dsc_detect <= '1' AFTER (TCQ)*1 ps;
                           ELSIF (null_mux_sel = '1') THEN
                                   reg_dsc_detect <= '0' AFTER (TCQ)*1 ps;
                           END IF;

                           trn_rsrc_dsc_d <= TRN_RSRC_DSC AFTER (TCQ)*1 ps;
                   END IF;
           END IF;
   END PROCESS;

   dsc_flag <= dsc_detect OR reg_dsc_detect;

   --------------------------------------------------------------------------------
   -- Create np_counter (V6 128-bit only). This counter tells the V6 128-bit     --
   -- interface core how many NP packets have left the RX pipeline. The V6       --
   -- 128-bit interface uses this count to perform rnp_ok modulation.            --
   --------------------------------------------------------------------------------

   xhdl21 : IF ((C_FAMILY = "V6") AND (C_DATA_WIDTH = 128)) GENERATE
      -- Look for NP packets beginning on lower (i.e. unaligned) start
      mrd_lower      <= '1' WHEN (m_axis_rx_tdata_xhdl0(92 DOWNTO 88) = "00000" AND m_axis_rx_tdata_xhdl0(94) = '0') ELSE '0';
      mrd_lk_lower   <= '1' WHEN (m_axis_rx_tdata_xhdl0(92 DOWNTO 88) = "00001") ELSE '0';
      io_rdwr_lower  <= '1' WHEN (m_axis_rx_tdata_xhdl0(92 DOWNTO 88) = "00010") ELSE '0';
      cfg_rdwr_lower <= '1' WHEN (m_axis_rx_tdata_xhdl0(92 DOWNTO 89) = "0010") ELSE '0';
      atomic_lower   <= '1' WHEN (m_axis_rx_tdata_xhdl0(91 DOWNTO 90) = "11" AND m_axis_rx_tdata_xhdl0(94) = '1') ELSE '0';

      np_pkt_lower <= '1' WHEN ((mrd_lower = '1'      OR
                                 mrd_lk_lower = '1'   OR
                                 io_rdwr_lower = '1'  OR
                                 cfg_rdwr_lower = '1' OR
                                 atomic_lower = '1') AND m_axis_rx_tuser_xhdl1(13) = '1') ELSE '0';

      -- Look for NP packets beginning on upper (i.e. aligned) start
      mrd_upper      <= '1' WHEN (m_axis_rx_tdata_xhdl0(28 DOWNTO 24) = "00000" AND m_axis_rx_tdata_xhdl0(30) = '0') ELSE '0';
      mrd_lk_upper   <= '1' WHEN (m_axis_rx_tdata_xhdl0(28 DOWNTO 24) = "00001") ELSE '0';
      io_rdwr_upper  <= '1' WHEN (m_axis_rx_tdata_xhdl0(28 DOWNTO 24) = "00010") ELSE '0';
      cfg_rdwr_upper <= '1' WHEN (m_axis_rx_tdata_xhdl0(28 DOWNTO 25) = "0010") ELSE '0';
      atomic_upper   <= '1' WHEN (m_axis_rx_tdata_xhdl0(27 DOWNTO 26) = "11" AND m_axis_rx_tdata_xhdl0(30) = '1') ELSE '0';

      np_pkt_upper <= '1' WHEN ((mrd_upper = '1'      OR
                                 mrd_lk_upper = '1'   OR
                                 io_rdwr_upper = '1'  OR
                                 cfg_rdwr_upper = '1' OR
                                 atomic_upper = '1') AND m_axis_rx_tuser_xhdl1(13) = '0') ELSE '0';

      pkt_accepted <= '1' WHEN (m_axis_rx_tuser_xhdl1(14) = '1' AND M_AXIS_RX_TREADY = '1' AND m_axis_rx_tvalid_xhdl2 = '1') ELSE '0';

      -- Increment counter whenever an NP packet leaves the RX pipeline
      PROCESS (USER_CLK)
      BEGIN
              IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
                      IF (USER_RST = '1') THEN
                              reg_np_counter <= "000" AFTER (TCQ)*1 ps;
                      ELSE
                              IF ((np_pkt_lower = '1' OR np_pkt_upper = '1') AND pkt_accepted = '1') THEN
                                      reg_np_counter <= reg_np_counter + "001" AFTER (TCQ)*1 ps;
                              END IF;
                      END IF;
              END IF;
      END PROCESS;

      NP_COUNTER <= reg_np_counter;
   END GENERATE;

   xhdl22 : IF (NOT(C_FAMILY = "V6" AND C_DATA_WIDTH = 128)) GENERATE
           NP_COUNTER <= "000";
   END GENERATE;
END trans;


