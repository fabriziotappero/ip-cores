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
-- File       : cl_a7pcie_x4_axi_basic_tx_thrtl_ctl.vhd
-- Version    : 1.11
--
-- Description:
--    TX throttle controller. Anticipates back-pressure from PCIe block and
--      preemptively back-pressures user design (packet boundary throttling).
--
--      Notes:
--      Optional notes section.
--
--      Hierarchical:
--        axi_basic_top
--          axi_basic_tx
--            axi_basic_tx_thrtl_ctl
--------------------------------------------------------------------------------
-- Library Declarations
--------------------------------------------------------------------------------

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.std_logic_unsigned.all;


ENTITY cl_a7pcie_x4_axi_basic_tx_thrtl_ctl IS
  GENERIC (
    C_DATA_WIDTH              : INTEGER := 128;      -- RX/TX interface data width
    C_FAMILY                  : STRING := "X7";      -- Targeted FPGA family
    C_ROOT_PORT               : BOOLEAN := FALSE;   -- PCIe block is in root port mode
    TCQ                       : INTEGER := 1         -- Clock to Q time
  );
  PORT (
    -- AXI TX
    -------------
    S_AXIS_TX_TDATA           : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0)  := (OTHERS=>'0'); -- TX data from user
    S_AXIS_TX_TVALID          : IN STD_LOGIC                     := '0';    -- TX data is valid
    S_AXIS_TX_TUSER           : IN STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0000"; -- TX user signals
    S_AXIS_TX_TLAST           : IN STD_LOGIC                     := '0';    -- TX data is last

    -- User Misc.
    -------------
    USER_TURNOFF_OK           : IN STD_LOGIC                     := '0';    -- Turnoff OK from user
    USER_TCFG_GNT             : IN STD_LOGIC                     := '0';    -- Send cfg OK from user

    -- TRN TX
    -------------
    TRN_TBUF_AV               : IN STD_LOGIC_VECTOR(5 DOWNTO 0)  := "000000"; -- TX buffers available
    TRN_TDST_RDY              : IN STD_LOGIC                     := '0';     -- TX destination ready

    -- TRN Misc.
    -------------
    TRN_TCFG_REQ              : IN STD_LOGIC                     := '0';     -- TX config request
    TRN_TCFG_GNT              : OUT STD_LOGIC                    ;--:= '0';     -- TX config grant
    TRN_LNK_UP                : IN STD_LOGIC                     := '0';     -- PCIe link up

    -- 7 Series/Virtex6 PM
    -------------
    CFG_PCIE_LINK_STATE       : IN STD_LOGIC_VECTOR(2 DOWNTO 0)  := "000";    -- Encoded PCIe link state

    -- Virtex6 PM
    -------------
    CFG_PM_SEND_PME_TO        : IN STD_LOGIC                     := '0';              -- PM send PME turnoff msg
    CFG_PMCSR_POWERSTATE      : IN STD_LOGIC_VECTOR(1 DOWNTO 0)  := "00";             -- PMCSR power state
    TRN_RDLLP_DATA            : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";      -- RX DLLP data
    TRN_RDLLP_SRC_RDY         : IN STD_LOGIC                     := '0';              -- RX DLLP source ready

    -- Virtex6/Spartan6 PM
    -------------
    CFG_TO_TURNOFF            : IN STD_LOGIC                     := '0';    -- Turnoff request
    CFG_TURNOFF_OK            : OUT STD_LOGIC                    ;--:= '0';    -- Turnoff grant

    -- System
    -------------
    TREADY_THRTL              : OUT STD_LOGIC                    ;--:= '0';   -- TREADY to pipeline
    USER_CLK                  : IN STD_LOGIC                     := '0';   -- user clock from block
    USER_RST                  : IN STD_LOGIC                     := '0'    -- user reset from block
  );
END cl_a7pcie_x4_axi_basic_tx_thrtl_ctl;

ARCHITECTURE trans OF cl_a7pcie_x4_axi_basic_tx_thrtl_ctl IS

  function tbuf_av_min_fn (
    constant wdt   : integer)
    return integer is
    variable buf_min : integer := 1;
  begin  -- tbuf_av_min_fn
 
    if (wdt = 128) then
      buf_min := 5;
    elsif (wdt = 64) then
      buf_min := 1;
    else
      buf_min := 0;
    end if;
    return buf_min;
  end tbuf_av_min_fn;

  function tbuf_gap_time_fn (
    constant wdt   : integer)
    return integer is
    variable gap_time : integer := 1;
  begin  -- tbuf_gap_time_fn
 
    if (wdt = 128) then
      gap_time := 4;
    else
      gap_time := 1;
    end if;
    return gap_time;
  end tbuf_gap_time_fn;

  -- Thrtl user when TBUF hits this val
  CONSTANT TBUF_AV_MIN               : INTEGER :=  tbuf_av_min_fn(C_DATA_WIDTH);

  -- Pause user when TBUF hits this val
  CONSTANT TBUF_AV_GAP               : INTEGER :=  TBUF_AV_MIN + 1;

  -- GAP pause time - the latency from the time a packet is accepted on the TRN
  -- interface to the time trn_tbuf_av from the Block will decrement.
  CONSTANT TBUF_GAP_TIME             : INTEGER :=  tbuf_gap_time_fn(C_DATA_WIDTH);

  -- Latency time from when tcfg_gnt is asserted to when PCIe block will throttle
  CONSTANT TCFG_LATENCY_TIME         : INTEGER :=  2;

  -- Number of pipeline stages to delay trn_tcfg_gnt. For V6 128-bit only
  CONSTANT TCFG_GNT_PIPE_STAGES      : INTEGER :=  3;

  CONSTANT LINKSTATE_L0              : INTEGER := 0;
  CONSTANT LINKSTATE_PPM_L1          : INTEGER := 1;
  CONSTANT LINKSTATE_PPM_L1_TRANS    : INTEGER := 5;
  CONSTANT LINKSTATE_PPM_L23R_TRANS  : INTEGER := 6;
  CONSTANT PM_ENTER_L1               : INTEGER := 32;
  CONSTANT POWERSTATE_D0             : INTEGER := 0;

  SIGNAL lnk_up_thrtl           : STD_LOGIC:= '0';
  SIGNAL lnk_up_trig            : STD_LOGIC:= '0';
  SIGNAL lnk_up_exit            : STD_LOGIC:= '0';
  SIGNAL tbuf_av_min_thrtl      : STD_LOGIC:= '0';
  SIGNAL tbuf_av_min_trig       : STD_LOGIC:= '0';
  SIGNAL tbuf_av_gap_thrtl      : STD_LOGIC:= '0';
  SIGNAL tbuf_gap_cnt           : STD_LOGIC_VECTOR(2 DOWNTO 0):= (others => '0');
  SIGNAL tbuf_gap_cnt_t         : STD_LOGIC_VECTOR(2 DOWNTO 0):= (others => '0');
  SIGNAL tbuf_av_gap_trig       : STD_LOGIC:= '0';
  SIGNAL tbuf_av_gap_exit       : STD_LOGIC:= '0';
  SIGNAL gap_trig_tlast         : STD_LOGIC:= '0';
  SIGNAL gap_trig_tlast_1       : STD_LOGIC:= '0';
  SIGNAL gap_trig_decr          : STD_LOGIC:= '0';
  SIGNAL gap_trig_decr_1        : STD_LOGIC:= '0';
  SIGNAL gap_trig_decr_2        : STD_LOGIC:= '0';
  SIGNAL tbuf_av_d              : STD_LOGIC_VECTOR(5 DOWNTO 0):= (others => '0');
  SIGNAL tcfg_req_thrtl         : STD_LOGIC:= '0';
  SIGNAL tcfg_req_cnt           : STD_LOGIC_VECTOR(1 DOWNTO 0):= (others => '0');
  SIGNAL trn_tdst_rdy_d         : STD_LOGIC:= '0';
  SIGNAL tcfg_req_trig          : STD_LOGIC:= '0';
  SIGNAL tcfg_req_exit          : STD_LOGIC:= '0';
  SIGNAL tcfg_gnt_log           : STD_LOGIC:= '0';
  SIGNAL tcfg_gnt_pipe          : STD_LOGIC_VECTOR(TCFG_GNT_PIPE_STAGES-1 DOWNTO 0):= (others => '0');
  SIGNAL pre_throttle           : STD_LOGIC:= '0';
  SIGNAL reg_throttle           : STD_LOGIC:= '0';
  SIGNAL exit_crit              : STD_LOGIC:= '0';
  SIGNAL reg_tcfg_gnt           : STD_LOGIC:= '0';
  SIGNAL trn_tcfg_req_d         : STD_LOGIC:= '0';
  SIGNAL tcfg_gnt_pending       : STD_LOGIC:= '0';
  SIGNAL wire_to_turnoff        : STD_LOGIC:= '0';
  SIGNAL reg_turnoff_ok         : STD_LOGIC:= '0';
  SIGNAL tready_thrtl_mux       : STD_LOGIC:= '0';
  SIGNAL ppm_L1_thrtl           : STD_LOGIC:= '0';
  SIGNAL ppm_L1_trig            : STD_LOGIC:= '0';
  SIGNAL ppm_L1_exit            : STD_LOGIC:= '0';
  SIGNAL cfg_pcie_link_state_d  : STD_LOGIC_VECTOR(2 DOWNTO 0):= (others => '0');
  SIGNAL trn_rdllp_src_rdy_d    : STD_LOGIC:= '0';
  SIGNAL ppm_L23_thrtl          : STD_LOGIC:= '0';
  SIGNAL ppm_L23_trig           : STD_LOGIC:= '0';
  SIGNAL cfg_turnoff_ok_pending : STD_LOGIC:= '0';
  SIGNAL reg_tlast              : STD_LOGIC:= '0';
  SIGNAL cur_state              : STD_LOGIC:= '0';
  SIGNAL next_state             : STD_LOGIC:= '0';

  SIGNAL reg_axi_in_pkt         : STD_LOGIC:= '0';
  SIGNAL axi_in_pkt             : STD_LOGIC:= '0';
  SIGNAL axi_pkt_ending         : STD_LOGIC:= '0';
  SIGNAL axi_throttled          : STD_LOGIC:= '0';
  SIGNAL axi_thrtl_ok           : STD_LOGIC:= '0';
  SIGNAL tx_ecrc_pause          : STD_LOGIC:= '0';

  SIGNAL gap_trig_tcfg          : STD_LOGIC:= '0';
  SIGNAL reg_to_turnoff         : STD_LOGIC:= '0';
  SIGNAL reg_tx_ecrc_pkt        : STD_LOGIC:= '0';

  SIGNAL tx_ecrc_pkt            : STD_LOGIC:= '0';
  SIGNAL packet_fmt             : STD_LOGIC_VECTOR(1 DOWNTO 0):= (others => '0');
  SIGNAL packet_td              : STD_LOGIC:= '0';
  SIGNAL header_len             : STD_LOGIC_VECTOR(2 DOWNTO 0):= (others => '0');
  SIGNAL payload_len            : STD_LOGIC_VECTOR(9 DOWNTO 0):= (others => '0');
  SIGNAL packet_len             : STD_LOGIC_VECTOR(13 DOWNTO 0):= (others => '0');
  SIGNAL pause_needed           : STD_LOGIC:= '0';

  -- Declare intermediate signals for referenced outputs
  SIGNAL cfg_turnoff_ok_xhdl0   : STD_LOGIC:= '0';
  SIGNAL tready_thrtl_xhdl1     : STD_LOGIC:= '0';
--   TYPE T_STATE is  (IDLE_A,THROTTLE);
--   SIGNAL CUR_STATE_A, NEXT_STATE_A : T_STATE;
  SIGNAL CUR_STATE_A, NEXT_STATE_A : STD_LOGIC := '0';

  constant IDLE : std_logic := '0';
  constant THROTTLE : std_logic := '1';

BEGIN
  -- Drive referenced outputs
  CFG_TURNOFF_OK   <= cfg_turnoff_ok_xhdl0;
  TREADY_THRTL     <= tready_thrtl_xhdl1;
   --------------------------------------------------------------------------------
   -- THROTTLE REASON: PCIe link is down                                         --
   --   - When to throttle: trn_lnk_up deasserted                                --
   --   - When to stop: trn_tdst_rdy assesrted                                   --
   --------------------------------------------------------------------------------
  lnk_up_trig      <= NOT(TRN_LNK_UP);
  lnk_up_exit      <= TRN_TDST_RDY;

  PROCESS (USER_CLK)
  BEGIN
    IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
      IF (USER_RST = '1') THEN
        lnk_up_thrtl <= '1'  AFTER (TCQ)*1 ps;
      ELSE
        IF (lnk_up_trig = '1') THEN
          lnk_up_thrtl <= '1'   AFTER (TCQ)*1 ps;
        ELSIF (lnk_up_exit = '1') THEN
          lnk_up_thrtl <= '0'   AFTER (TCQ)*1 ps;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  --------------------------------------------------------------------------------
  -- THROTTLE REASON: Transmit buffers depleted                                 --
  --   - When to throttle: trn_tbuf_av falls to 0                               --
  --   - When to stop: trn_tbuf_av rises above 0 again                          --
  --------------------------------------------------------------------------------
  tbuf_av_min_trig <= '1' WHEN (TRN_TBUF_AV <= TBUF_AV_MIN) ELSE '0';

  PROCESS (USER_CLK)
  BEGIN
    IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
      IF (USER_RST = '1') THEN
        tbuf_av_min_thrtl <= '0'   AFTER (TCQ)*1 ps;
      ELSE
        IF (tbuf_av_min_trig = '1') THEN
          tbuf_av_min_thrtl <= '1'  AFTER (TCQ)*1 ps;
          -- The exit condition for tbuf_av_min_thrtl is !tbuf_av_min_trig
        ELSE
          tbuf_av_min_thrtl <= '0'  AFTER (TCQ)*1 ps;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  ------------------------------------------------------------------------------//
  -- THROTTLE REASON: Transmit buffers getting low                              //
  --   - When to throttle: trn_tbuf_av falls below "gap" threshold TBUF_AV_GAP  //
  --   - When to stop: after TBUF_GAP_TIME cycles elapse                        //
  --                                                                            //
  -- If we're about to run out of transmit buffers, throttle the user for a     //
  -- few clock cycles to give the PCIe block time to catch up. This is          //
  -- needed to compensate for latency in decrementing trn_tbuf_av in the PCIe   //
  -- Block transmit path.                                                       //
  ------------------------------------------------------------------------------//

  -- Detect two different scenarios for buffers getting low:
  -- 1) If we see a TLAST. a new packet has been inserted into the buffer, and
  --    we need to pause and let that packet "soak in"
  gap_trig_tlast_1 <=  '1' WHEN (TRN_TBUF_AV <= TBUF_AV_GAP) ELSE '0';
  gap_trig_tlast   <=  (gap_trig_tlast_1 AND S_AXIS_TX_TVALID AND tready_thrtl_xhdl1 AND S_AXIS_TX_TLAST );

  -- 2) Any time tbug_avail decrements to the TBUF_AV_GAP threshold, we need to
  --    pause and make sure no other packets are about to soak in and cause the
  --    buffer availability to drop further.
  gap_trig_decr_1    <=  '1' WHEN ( TRN_TBUF_AV = TBUF_AV_GAP) ELSE '0' ;
  gap_trig_decr_2  <=  '1' WHEN (tbuf_av_d = TBUF_AV_GAP + 1) ELSE '0' ;

  gap_trig_decr    <= ( gap_trig_decr_1 AND gap_trig_decr_2);

  gap_trig_tcfg    <= ((tcfg_req_thrtl AND tcfg_req_exit));
  tbuf_av_gap_trig <= (gap_trig_tlast OR gap_trig_decr OR gap_trig_tcfg) ;
  tbuf_av_gap_exit <= '1' WHEN (tbuf_gap_cnt = "000") ELSE '0' ;

  tbuf_gap_cnt_t   <= "100" WHEN (C_DATA_WIDTH = 128) ELSE "001";
  PROCESS (USER_CLK)
  BEGIN
    IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
      IF (USER_RST = '1') THEN
        tbuf_av_gap_thrtl <= '0'       AFTER (TCQ)*1 ps;
        tbuf_gap_cnt      <= "000"     AFTER (TCQ)*1 ps;
        tbuf_av_d         <= "000000"  AFTER (TCQ)*1 ps;
      ELSE
        IF (tbuf_av_gap_trig = '1') THEN
          tbuf_av_gap_thrtl <= '1'   AFTER (TCQ)*1 ps;
        ELSIF (tbuf_av_gap_exit = '1') THEN
          tbuf_av_gap_thrtl <= '0'   AFTER (TCQ)*1 ps;
        END IF;
        -- tbuf gap counter:
        -- This logic controls the length of the throttle condition when tbufs are
        -- getting low.
        IF (tbuf_av_gap_thrtl = '1' AND (CUR_STATE_A = THROTTLE)) THEN
          IF (tbuf_gap_cnt > "000") THEN
            tbuf_gap_cnt <= tbuf_gap_cnt - "001"  AFTER (TCQ)*1 ps;
          END IF;
        ELSE
          tbuf_gap_cnt <= tbuf_gap_cnt_t AFTER (TCQ)*1 ps;
        END IF;
        tbuf_av_d <= TRN_TBUF_AV  AFTER (TCQ)*1 ps;
      END IF;
    END IF;
  END PROCESS;

  ------------------------------------------------------------------------------
  -- THROTTLE REASON: Block needs to send a CFG response
  --   - When to throttle: trn_tcfg_req and user_tcfg_gnt asserted
  --   - When to stop: after trn_tdst_rdy transitions to unasserted
  --
  -- If the block needs to send a response to a CFG packet, this will cause
  -- the subsequent deassertion of trn_tdst_rdy. When the user design permits,
  -- grant permission to the block to service request and throttle the user.
  ------------------------------------------------------------------------------

  tcfg_req_trig <= (TRN_TCFG_REQ AND reg_tcfg_gnt);
  tcfg_req_exit <= '1' WHEN (tcfg_req_cnt = "00" AND trn_tdst_rdy_d = '0' AND  TRN_TDST_RDY ='1') ELSE '0';

  PROCESS (USER_CLK)
  BEGIN
    IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
      IF (USER_RST = '1') THEN
        tcfg_req_thrtl   <= '0'   AFTER (TCQ)*1 ps;
        trn_tcfg_req_d   <= '0'   AFTER (TCQ)*1 ps;
        trn_tdst_rdy_d   <= '1'   AFTER (TCQ)*1 ps;
        reg_tcfg_gnt     <= '0'   AFTER (TCQ)*1 ps;
        tcfg_req_cnt     <= "00"  AFTER (TCQ)*1 ps;
        tcfg_gnt_pending <= '0'   AFTER (TCQ)*1 ps;
      ELSE
        IF (tcfg_req_trig = '1') THEN
          tcfg_req_thrtl <= '1'  AFTER (TCQ)*1 ps;
        ELSIF (tcfg_req_exit = '1') THEN
          tcfg_req_thrtl <= '0'  AFTER (TCQ)*1 ps;
        END IF;
        -- We need to wait the appropriate amount of time for the tcfg_gnt to
        -- "sink in" to the PCIe block. After that, we know that the PCIe block will
        -- not reassert trn_tdst_rdy until the CFG request has been serviced. If a
        -- new request is being service (tcfg_gnt_log == 1), then reset the timer.
        IF ((NOT(trn_tcfg_req_d = '1' ) AND TRN_TCFG_REQ = '1' ) OR tcfg_gnt_pending = '1') THEN
          -- As TCFG_LATENCY_TIME value is 2
          tcfg_req_cnt <= "10"  AFTER (TCQ)*1 ps;
        ELSE
          IF (tcfg_req_cnt > "00") THEN
            tcfg_req_cnt <= tcfg_req_cnt - "01"  AFTER (TCQ)*1 ps;
          END IF;
        END IF;
        -- Make sure tcfg_gnt_log pulses once for one clock cycle for every
        -- cfg packet request.
        IF (TRN_TCFG_REQ = '1' AND NOT(trn_tcfg_req_d = '1' )) THEN
          tcfg_gnt_pending   <= '1' AFTER (TCQ)*1 ps;
        ELSIF (tcfg_gnt_log = '1') THEN
          tcfg_gnt_pending   <= '0' AFTER (TCQ)*1 ps;
        END IF;

        trn_tcfg_req_d   <= TRN_TCFG_REQ   AFTER (TCQ)*1 ps;
        trn_tdst_rdy_d   <= TRN_TDST_RDY   AFTER (TCQ)*1 ps;
        reg_tcfg_gnt     <= USER_TCFG_GNT  AFTER (TCQ)*1 ps;
      END IF;
    END IF;
  END PROCESS;

  ------------------------------------------------------------------------------
  -- THROTTLE REASON: Block needs to transition to low power state PPM L1
  --   - When to throttle: appropriate low power state signal asserted
  --     (architecture dependent)
  --   - When to stop: cfg_pcie_link_state goes to proper value (C_ROOT_PORT
  --     dependent)
  --
  -- If the block needs to transition to PM state PPM L1, we need to finish
  -- up what we're doing and throttle immediately.
  ------------------------------------------------------------------------------
  xhdl3 : IF ((C_FAMILY = "X7") AND (C_ROOT_PORT)) GENERATE
    -- PPM L1 signals for 7 Series in RC mode
    ppm_L1_trig <=  '1' WHEN ((cfg_pcie_link_state_d = "000") AND (CFG_PCIE_LINK_STATE = "101")) ELSE '0';
    ppm_L1_exit <= '1' WHEN (CFG_PCIE_LINK_STATE = "001") ELSE '0';
  END GENERATE;

  -- PPM L1 signals for 7 Series in EP mode
  xhdl4 : IF (NOT((C_FAMILY = ("X7")) AND (C_ROOT_PORT))) GENERATE
    xhdl5 : IF ((C_FAMILY = ("X7")) AND (NOT(C_ROOT_PORT))) GENERATE
      ppm_L1_trig <= '1' WHEN ((cfg_pcie_link_state_d = "000") AND (CFG_PCIE_LINK_STATE = "101")) ELSE '0';
      ppm_L1_exit <= '1' WHEN (CFG_PCIE_LINK_STATE = "000") ELSE '0';
    END GENERATE;
    -- PPM L1 signals for V6 in RC mode
    xhdl6 : IF (NOT((C_FAMILY = ("X7")) AND (NOT(C_ROOT_PORT)))) GENERATE
      xhdl7 : IF ((C_FAMILY = ("V6")) AND (C_ROOT_PORT)) GENERATE
        ppm_L1_trig <= '1' WHEN ((TRN_RDLLP_DATA(31 DOWNTO 24) = x"20") AND TRN_RDLLP_SRC_RDY = '1' AND trn_rdllp_src_rdy_d = '0')
                       ELSE '0';
        ppm_L1_exit <= '1' WHEN (CFG_PCIE_LINK_STATE = "001") ELSE '0';
      END GENERATE;
      -- PPM L1 signals for V6 in EP mode
      xhdl8 : IF (NOT((C_FAMILY = ("V6")) AND (C_ROOT_PORT))) GENERATE
        xhdl9 : IF ((C_FAMILY = ("V6")) AND (NOT(C_ROOT_PORT))) GENERATE
          ppm_L1_trig <= '1' WHEN (CFG_PMCSR_POWERSTATE /= "000") ELSE '0';
          ppm_L1_exit <= '1' WHEN (CFG_PCIE_LINK_STATE = "000") ELSE '0';
        END GENERATE;
        -- PPM L1 detection not supported for S6
        xhdl10 : IF (NOT((C_FAMILY = ("V6")) AND (NOT(C_ROOT_PORT)))) GENERATE
          ppm_L1_trig <= '0';
          ppm_L1_exit <= '1';
        END GENERATE;
      END GENERATE;
    END GENERATE;
  END GENERATE;

  PROCESS (USER_CLK)
  BEGIN
    IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
      IF (USER_RST = '1') THEN
        ppm_L1_thrtl          <= '0'   AFTER (TCQ)*1 ps;
        cfg_pcie_link_state_d <= "000" AFTER (TCQ)*1 ps;
        trn_rdllp_src_rdy_d   <= '0'   AFTER (TCQ)*1 ps;
      ELSE
        IF (ppm_L1_trig = '1') THEN
          ppm_L1_thrtl  <= '1'   AFTER (TCQ)*1 ps;
        ELSIF (ppm_L1_exit = '1') THEN
          ppm_L1_thrtl  <= '0'   AFTER (TCQ)*1 ps;
        END IF;
        cfg_pcie_link_state_d <= CFG_PCIE_LINK_STATE  AFTER (TCQ)*1 ps;
        trn_rdllp_src_rdy_d <= TRN_RDLLP_SRC_RDY      AFTER (TCQ)*1 ps;
      END IF;
    END IF;
  END PROCESS;

  ------------------------------------------------------------------------------
  -- THROTTLE REASON: Block needs to transition to low power state PPM L2/3
  --   - When to throttle: appropriate PM signal indicates a transition to
  --     L2/3 is pending or in progress (family and role dependent)
  --   - When to stop: never (the only path out of L2/3 is a full reset)
  --
  -- If the block needs to transition to PM state PPM L2/3, we need to finish
  -- up what we're doing and throttle when the user gives permission.
  ------------------------------------------------------------------------------
  -- PPM L2/3 signals for 7 Series in RC mode
  xhdl11 : IF ((C_FAMILY = ("X7")) AND (C_ROOT_PORT)) GENERATE
    ppm_L23_trig <= '1' WHEN (cfg_pcie_link_state_d = "110") ELSE '0';
    wire_to_turnoff <= '0';
  END GENERATE;

  -- PPM L2/3 signals for V6 in RC mode
  xhdl12 : IF (NOT((C_FAMILY = ("X7")) AND (C_ROOT_PORT))) GENERATE
    xhdl13 : IF ((C_FAMILY = ("V6")) AND (C_ROOT_PORT)) GENERATE
      ppm_L23_trig <= CFG_PM_SEND_PME_TO;
      wire_to_turnoff <= '0';
    END GENERATE;
     -- PPM L2/3 signals in EP mode
    xhdl14 : IF (NOT((C_FAMILY = ("V6")) AND (C_ROOT_PORT))) GENERATE
      ppm_L23_trig <= (wire_to_turnoff AND reg_turnoff_ok);
       -- PPM L2/3 signals for 7 Series in EP mode
       -- For 7 Series, cfg_to_turnoff pulses once when a turnoff request is
       -- outstanding, so we need a "sticky" register that grabs the request.
      xhdl15 : IF (C_FAMILY = ("X7")) GENERATE
        PROCESS (USER_CLK)
        BEGIN
          IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
            IF (USER_RST = '1') THEN
              reg_to_turnoff <= '0' AFTER (TCQ)*1 ps;
            ELSE
              IF (CFG_TO_TURNOFF = '1') THEN
                reg_to_turnoff <= '1' AFTER (TCQ)*1 ps;
              END IF;
            END IF;
          END IF;
        END PROCESS;
        wire_to_turnoff <= reg_to_turnoff;
      END GENERATE;
       -- PPM L2/3 signals for V6/S6 in EP mode
       -- In V6 and S6, the to_turnoff signal asserts and remains asserted until
       -- turnoff_ok is asserted, so a sticky reg is not necessary.
      xhdl16 : IF (NOT(C_FAMILY = ("X7"))) GENERATE
        wire_to_turnoff <= CFG_TO_TURNOFF;
      END GENERATE;

    PROCESS (USER_CLK)
    BEGIN
      IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
        IF (USER_RST = '1') THEN
          reg_turnoff_ok <= '0' AFTER (TCQ)*1 ps;
        ELSE
          reg_turnoff_ok <= USER_TURNOFF_OK AFTER (TCQ)*1 ps;
        END IF;
      END IF;
    END PROCESS;
    END GENERATE;
  END GENERATE;

   PROCESS (USER_CLK)
   BEGIN
    IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
      IF (USER_RST = '1') THEN
        ppm_L23_thrtl <= '0' AFTER (TCQ)*1 ps;
        cfg_turnoff_ok_pending <= '0' AFTER (TCQ)*1 ps;
      ELSE
        -- Make sure cfg_turnoff_ok pulses once for one clock cycle for every
        -- turnoff request.
        IF (ppm_L23_trig = '1') THEN
          ppm_L23_thrtl <= '1' AFTER (TCQ)*1 ps;
        END IF;
        IF (ppm_L23_trig = '1' AND (ppm_L23_thrtl = '0')) THEN
          cfg_turnoff_ok_pending <= '1' AFTER (TCQ)*1 ps;
        ELSIF (cfg_turnoff_ok_xhdl0 = '1') THEN
          cfg_turnoff_ok_pending <= '0' AFTER (TCQ)*1 ps;
        END IF;
      END IF;
    END IF;
   END PROCESS;

   --------------------------------------------------------------------------------
   -- Create axi_thrtl_ok. This signal determines if it's OK to throttle the     --
   -- user design on the AXI interface. Since TREADY is registered, this signal  --
   -- needs to assert on the cycle ~before~ we actually intend to throttle.      --
   -- The only time it's OK to throttle when TVALID is asserted is on the first  --
   -- beat of a new packet. Therefore, assert axi_thrtl_ok if one of the         --
   -- is true:                                                                   --
   --    1) The user is not in a packet and is not starting one                  --
   --    2) The user is just finishing a packet                                  --
   --    3) We're already throttled, so it's OK to continue throttling           --
   --------------------------------------------------------------------------------

  PROCESS (USER_CLK)
  BEGIN
    IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
      IF (USER_RST = '1') THEN
        reg_axi_in_pkt <= '0' AFTER (TCQ)*1 ps;
      ELSE
        IF (S_AXIS_TX_TVALID = '1' AND S_AXIS_TX_TLAST  = '1') THEN
          reg_axi_in_pkt <= '0' AFTER (TCQ)*1 ps;
        ELSIF (tready_thrtl_xhdl1  = '1'  AND S_AXIS_TX_TVALID  = '1') THEN
          reg_axi_in_pkt <= '1' AFTER (TCQ)*1 ps;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  axi_in_pkt     <= (S_AXIS_TX_TVALID OR reg_axi_in_pkt);
  axi_pkt_ending <= (S_AXIS_TX_TVALID AND S_AXIS_TX_TLAST);
  axi_throttled  <= NOT(tready_thrtl_xhdl1);
  axi_thrtl_ok   <= (NOT(axi_in_pkt) OR axi_pkt_ending OR axi_throttled);
  --------------------------------------------------------------------------------
  -- Throttle CTL State Machine:                                                --
  -- Throttle user design when a throttle trigger (or triggers) occur.          --
  -- Keep user throttled until all exit criteria have been met.                 --
  --------------------------------------------------------------------------------

  -- Immediate throttle signal. Used to "pounce" on a throttle opportunity when
  -- we're seeking one
  pre_throttle <= (tbuf_av_min_trig OR tbuf_av_gap_trig OR lnk_up_trig OR tcfg_req_trig OR ppm_L1_trig OR ppm_L23_trig);

  -- Registered throttle signals. Used to control throttle state machine
  reg_throttle <= (tbuf_av_min_thrtl OR tbuf_av_gap_thrtl OR lnk_up_thrtl OR tcfg_req_thrtl OR ppm_L1_thrtl OR ppm_L23_thrtl);
  exit_crit <= (NOT(tbuf_av_min_thrtl) AND NOT(tbuf_av_gap_thrtl) AND (NOT(lnk_up_thrtl)) AND (NOT(tcfg_req_thrtl)) and 
               (NOT(ppm_L1_thrtl)) AND (NOT(ppm_L23_thrtl)));

  PROCESS (CUR_STATE_A,reg_throttle, axi_thrtl_ok, tcfg_req_thrtl, tcfg_gnt_pending, cfg_turnoff_ok_pending, pre_throttle,
           exit_crit, ppm_L23_thrtl)
  BEGIN
    CASE CUR_STATE_A IS
      -- IDLE: in this state we're waiting for a trigger event to occur. As
      -- soon as an event occurs and the user isn't transmitting a packet, we
      -- throttle the PCIe block and the user and next state is THROTTLE.
      WHEN (IDLE) =>
              IF (reg_throttle = '1' AND axi_thrtl_ok = '1') THEN
                tready_thrtl_mux <= '0';
                NEXT_STATE_A   <= (THROTTLE);
                -- Assert appropriate grant signal depending on the throttle type.
                IF (tcfg_req_thrtl  = '1') THEN
                  tcfg_gnt_log          <= '1';   -- For cfg request, grant the request
                  cfg_turnoff_ok_xhdl0  <= '0'; --
                ELSIF (ppm_L23_thrtl = '1') THEN
                  tcfg_gnt_log          <= '0';    --
                  cfg_turnoff_ok_xhdl0  <= '1';  -- For PM request, permit transition
                ELSE
                  tcfg_gnt_log          <= '0';  -- Otherwise do nothing
                  cfg_turnoff_ok_xhdl0  <= '0';--
                END IF;
              ELSE
                -- If there's not throttle event, do nothing
                -- Throttle user as soon as possible
                tready_thrtl_mux <= (NOT((axi_thrtl_ok AND pre_throttle)));
                NEXT_STATE_A <= IDLE;
                tcfg_gnt_log         <= '0';
                cfg_turnoff_ok_xhdl0 <= '0';
              END IF;
      -- THROTTLE: in this state the user is throttle and we're waiting for
      -- exit criteria, which tells us that the throttle event is over. When
      -- the exit criteria is satisfied, de-throttle the user and next state
      WHEN (THROTTLE) =>
              IF (exit_crit = '1') THEN
                -- Dethrottle user
                tready_thrtl_mux <= (NOT(pre_throttle));
                NEXT_STATE_A   <= IDLE;
              ELSE
                -- Throttle user
                tready_thrtl_mux <= '0';
                NEXT_STATE_A   <= (THROTTLE);
              END IF;
               -- Assert appropriate grant signal depending on the throttle type.
              IF (tcfg_req_thrtl = '1' AND tcfg_gnt_pending = '1') THEN
                tcfg_gnt_log           <= '1';   -- For cfg request, grant the request
                cfg_turnoff_ok_xhdl0   <= '0'; --
              ELSIF (cfg_turnoff_ok_pending = '1') THEN
                tcfg_gnt_log           <= '0';   --
                cfg_turnoff_ok_xhdl0   <= '1'; -- For PM request, permit transition
              ELSE
                tcfg_gnt_log           <= '0';   -- Otherwise do nothing
                cfg_turnoff_ok_xhdl0   <= '0'; --
              END IF;
      WHEN OTHERS =>
              tready_thrtl_mux     <= '0';
              NEXT_STATE_A         <= (IDLE);
              tcfg_gnt_log         <= '0' ;
              cfg_turnoff_ok_xhdl0 <= '0';
    END CASE;
  END PROCESS;


  -- Synchronous logic
  PROCESS (USER_CLK)
  BEGIN
    IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
      IF (USER_RST = '1') THEN
        -- Throttle user by default until link comes up
        CUR_STATE_A        <= (THROTTLE) AFTER (TCQ)*1 ps;
        reg_tlast          <= '0' AFTER (TCQ)*1 ps;
        tready_thrtl_xhdl1 <= '0' AFTER (TCQ)*1 ps;
      ELSE
        CUR_STATE_A        <= NEXT_STATE_A AFTER (TCQ)*1 ps;
        tready_thrtl_xhdl1 <= (tready_thrtl_mux AND NOT(tx_ecrc_pause)) AFTER (TCQ)*1 ps;
        reg_tlast          <= S_AXIS_TX_TLAST AFTER (TCQ)*1 ps;
      END IF;
    END IF;
  END PROCESS;


  -- For X7, the PCIe block will generate the ECRC for a packet if trn_tecrc_gen
  -- is asserted at SOF. In this case, the Block needs an extra data beat to
  -- calculate the ECRC, but only if the following conditions are met:
  --  1) there is no empty DWORDS at the end of the packet
  --     (i.e. packet length % C_DATA_WIDTH == 0)
  --
  --  2) There isn't a ECRC in the TLP already, as indicated by the TD bit in the
  --     TLP header
  --
  -- If both conditions are met, the Block will stall the TRN interface for one
  -- data beat after EOF. We need to predict this stall and preemptively stall the
  -- User for one beat.
  xhdl17 : IF (C_FAMILY = ("X7")) GENERATE

    -- Grab necessary packet fields
    packet_fmt <= S_AXIS_TX_TDATA(30 DOWNTO 29);
    packet_td  <= S_AXIS_TX_TDATA(15);

    -- Calculate total packet length
    header_len <= "100" WHEN packet_fmt(0) = '1' ELSE "011";
    payload_len <= S_AXIS_TX_TDATA(9 DOWNTO 0) WHEN packet_fmt(1) = '1' ELSE "0000000000";
    packet_len  <= ("0000000000" & header_len) + ("0000" & payload_len);

    -- Determine if an ECRC pause is needed
    PACKET_LEN_CHECK_128 : IF (C_DATA_WIDTH = 128) GENERATE
      pause_needed <= '1' WHEN (packet_len(1 DOWNTO 0) = "00" AND packet_td = '0') ELSE '0';
    END GENERATE;

    PACKET_LEN_CHECK_64 : IF (C_DATA_WIDTH /= 128) GENERATE
      pause_needed <= '1' WHEN (packet_len(0) = '0' AND packet_td = '0') ELSE '0';
    END GENERATE;

    -- Create flag to alert TX pipeline to insert a stall
    tx_ecrc_pkt <= S_AXIS_TX_TUSER(0) AND pause_needed AND tready_thrtl_xhdl1 AND S_AXIS_TX_TVALID AND not(reg_axi_in_pkt);

    PROCESS (USER_CLK)
    BEGIN
      IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
        IF (USER_RST = '1') THEN
          reg_tx_ecrc_pkt <= '0' AFTER (TCQ)*1 ps;
        ELSE
          IF (tx_ecrc_pkt  = '1' AND S_AXIS_TX_TLAST = '0') THEN
            reg_tx_ecrc_pkt <= '1' AFTER (TCQ)*1 ps;
          ELSIF (tready_thrtl_xhdl1 = '1' AND S_AXIS_TX_TVALID = '1' AND S_AXIS_TX_TLAST = '1') THEN
            reg_tx_ecrc_pkt <= '0' AFTER (TCQ)*1 ps;
          END IF;
        END IF;
      END IF;
    END PROCESS;

--    tx_ecrc_pkt <= (S_AXIS_TX_TUSER(0) AND tready_thrtl_xhdl1 AND S_AXIS_TX_TVALID AND (NOT(reg_axi_in_pkt)));
    tx_ecrc_pause <= (((tx_ecrc_pkt OR reg_tx_ecrc_pkt) AND S_AXIS_TX_TLAST AND S_AXIS_TX_TVALID AND tready_thrtl_xhdl1));
  END GENERATE;

  xhdl18 : IF (NOT(C_FAMILY = ("X7"))) GENERATE
    tx_ecrc_pause <= '0';
  END GENERATE;

  -- Logic for 128-bit single cycle bug fix.
  -- This tcfg_gnt pipeline addresses an issue with 128-bit V6 designs where a
  -- single cycle packet transmitted simultaneously with an assertion of tcfg_gnt
  -- from AXI Basic causes the packet to be dropped. The packet drop occurs
  -- because the 128-bit shim doesn't know about the tcfg_req/gnt, and therefor
  -- isn't expecting trn_tdst_rdy to go low. Since the 128-bit shim does throttle
  -- prediction just as we do, it ignores the value of trn_tdst_rdy, and
  -- ultimately drops the packet when transmitting the packet to the block.


  TCFG_GNT_PIPELINE: if (C_DATA_WIDTH = 128 AND C_FAMILY = "V6") generate
    -- Create a configurable depth FF delay pipeline
    tcfg_gnt_pipeline_stage: for stage in 0 to TCFG_GNT_PIPE_STAGES -1 generate
      process (USER_CLK)
      begin  -- process
        if USER_CLK'event and USER_CLK = '1' then
          if USER_RST = '1' then
            tcfg_gnt_pipe(stage) <= '0' after (TCQ)*1 ps;
          else
            -- For stage 0, insert the actual tcfg_gnt signal from logic
           if stage = 0 then
             tcfg_gnt_pipe(stage) <= tcfg_gnt_log after (TCQ)*1 ps;
             -- For stages 1+, chain together
           else
             tcfg_gnt_pipe(stage) <= tcfg_gnt_pipe(stage - 1) after (TCQ)*1 ps;
           end if;
          end if;
        end if;
      end process;

      -- tcfg_gnt output to block assigned the last pipeline stage
      TRN_TCFG_GNT <= tcfg_gnt_pipe(TCFG_GNT_PIPE_STAGES - 1);
    end generate tcfg_gnt_pipeline_stage;
  end generate TCFG_GNT_PIPELINE;

  tcfg_gnt_no_pipeline: if (not(C_DATA_WIDTH = 128 AND C_FAMILY = "V6")) generate
    -- For all other architectures, no pipeline delay needed for tcfg_gnt

    TRN_TCFG_GNT <= tcfg_gnt_log;

  end generate tcfg_gnt_no_pipeline;

END trans;
