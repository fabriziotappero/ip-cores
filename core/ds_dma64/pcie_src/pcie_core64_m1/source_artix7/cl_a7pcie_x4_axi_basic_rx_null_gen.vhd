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
-- File       : cl_a7pcie_x4_axi_basic_rx_null_gen.vhd
-- Version    : 1.11
--
-- Description:
-- TRN to AXI RX null generator. Generates null packets for use in discontinue situations.
--
-- Notes:
--   Optional notes section.
--
--   Hierarchical:
--     axi_basic_top
--       axi_basic_rx
--         axi_basic_rx_null_gen
--------------------------------------------------------------------------------
-- Library Declarations
--------------------------------------------------------------------------------
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;

ENTITY cl_a7pcie_x4_axi_basic_rx_null_gen IS
  GENERIC (
    C_DATA_WIDTH              : INTEGER := 128; -- RX/TX interface data width
    TCQ                       : INTEGER := 1   --  Clock to Q time

  );
  PORT (
    -- AXI RX
    M_AXIS_RX_TDATA           : IN STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0) :=(OTHERS=>'0'); -- RX data to user
    M_AXIS_RX_TVALID          : IN STD_LOGIC                                   :='0';           -- RX data is valid
    M_AXIS_RX_TREADY          : IN STD_LOGIC                                   :='0';           -- RX ready for data
    M_AXIS_RX_TLAST           : IN STD_LOGIC                                   :='0';           -- RX data is last
    M_AXIS_RX_TUSER           : IN STD_LOGIC_VECTOR(21 DOWNTO 0)               :=(OTHERS=>'0'); -- RX user signals

    -- Null Inputs
    NULL_RX_TVALID            : OUT STD_LOGIC                                  ;           -- NULL generated tvalid
    NULL_RX_TLAST             : OUT STD_LOGIC                                  ;           -- NULL generated tlast
    NULL_RX_tkeep             : OUT STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0); -- NULL generated tkeep
    NULL_RDST_RDY             : OUT STD_LOGIC                                  ;           -- NULL generated rdst_rdy
    NULL_IS_EOF               : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)               ; -- NULL generated is_eof

    -- System
    USER_CLK                  : IN STD_LOGIC                                   :='0';
    USER_RST                  : IN STD_LOGIC                                   :='0'
  );
END cl_a7pcie_x4_axi_basic_rx_null_gen;

------------------------------------------------------------------------------//
-- NULL packet gnereator state machine                                        //
-- This state machine shadows the TRN RX interface, tracking each packet as   //
-- it's passed to the AXI user. When a disountine is detected, the rx data    //
-- pipeline switches to a NULL packet and clocks that out instead. It does so //
-- by asserting null_mux_sel, which the rx pipeline uses to mux in NULL vals. //
------------------------------------------------------------------------------//

ARCHITECTURE TRANS OF cl_a7pcie_x4_axi_basic_rx_null_gen IS

  --   INTERFACE_WIDTH_DWORDS = (C_DATA_WIDTH == 128) ? 11'd4 : (C_DATA_WIDTH == 64) ? 11'd2 : 11'd1;
  function if_wdt_dw (
    constant wdt   : integer)
    return integer is
     variable dw : integer := 1;
  begin  -- if_wdt_dw
 
    if (wdt = 128) then
      dw := 4;
    elsif (wdt = 64) then
      dw := 2;
    else
      dw := 1;
    end if;
    return dw;
  end if_wdt_dw;

  constant INTERFACE_WIDTH_DWORDS : integer := if_wdt_dw(C_DATA_WIDTH);
  constant IDLE : std_logic := '0';
  constant IN_PACKET : std_logic := '1';
     
  -- Signals for tracking a packet on the AXI interface
  SIGNAL reg_pkt_len_counter   : STD_LOGIC_VECTOR(11 DOWNTO 0):= (others => '0');
  SIGNAL pkt_len_counter       : STD_LOGIC_VECTOR(11 DOWNTO 0):= (others => '0');
  SIGNAL pkt_len_counter_dec   : STD_LOGIC_VECTOR(11 DOWNTO 0):= (others => '0');
  SIGNAL pkt_done              : STD_LOGIC:= '0';

  SIGNAL new_pkt_len           : STD_LOGIC_VECTOR(11 DOWNTO 0):= (others => '0');
  SIGNAL payload_len           : STD_LOGIC_VECTOR(9 DOWNTO 0):= (others => '0');
  SIGNAL payload_len_tmp       : STD_LOGIC_VECTOR(9 DOWNTO 0) := (others => '0');
  SIGNAL packet_fmt            : STD_LOGIC_VECTOR(1 DOWNTO 0):= (others => '0');
  SIGNAL packet_td             : STD_LOGIC:= '0';
  SIGNAL packet_overhead       : STD_LOGIC_VECTOR(3 DOWNTO 0):= (others => '0');
  -- X-HDL generated signals`

  SIGNAL xhdl2                 : STD_LOGIC_VECTOR(2 DOWNTO 0):= (others => '0');
  SIGNAL reg_is_eof            : STD_LOGIC_VECTOR(4 DOWNTO 0):= (others => '0');
  SIGNAL xhdl5                 : STD_LOGIC_VECTOR(1 DOWNTO 0):= (others => '0');
  SIGNAL xhdl7                 : STD_LOGIC_VECTOR(1 DOWNTO 0):= (others => '0');
  --State machine variables and states
  SIGNAL next_state            : STD_LOGIC:= '0';
  SIGNAL cur_state             : STD_LOGIC:= '0';

  -- Declare intermediate signals for referenced outputs
  SIGNAL null_rx_tlast_xhdl0   : STD_LOGIC:= '0';

  -- Misc.
  SIGNAL eof_tkeep             : STD_LOGIC_VECTOR((C_DATA_WIDTH/8)-1 DOWNTO 0):= (others => '0');
  SIGNAL straddle_sof          : STD_LOGIC:= '0';
  SIGNAL eof                   : STD_LOGIC:= '0';

BEGIN

  -- Create signals to detect sof and eof situations. These signals vary depending
  -- on the data width.
  eof <= M_AXIS_RX_TUSER(21);
  SOF_EOF_128 : IF (C_DATA_WIDTH = 128) GENERATE
    straddle_sof <= '1' WHEN (M_AXIS_RX_TUSER(14 DOWNTO 13) = "11") ELSE '0';
  END GENERATE;

  SOF_EOF_64_32 : IF (C_DATA_WIDTH /= 128) GENERATE
    straddle_sof <= '0';
  END GENERATE;

  ------------------------------------------------------------------------------//
  -- Calculate the length of the packet being presented on the RX interface. To //
  -- do so, we need the relevent packet fields that impact total packet length. //
  -- These are:                                                                 //
  --   - Header length: obtained from bit 1 of FMT field in 1st DWORD of header //
  --   - Payload length: obtained from LENGTH field in 1st DWORD of header      //
  --   - TLP digist: obtained from TD field in 1st DWORD of header              //
  --   - Current data: the number of bytes that have already been presented     //
  --                   on the data interface                                    //
  --                                                                            //
  -- packet length = header + payload + tlp digest - # of DWORDS already        //
  --                 transmitted                                                //
  --                                                                            //
  -- packet_overhead is where we calculate everything except payload.           //
  ------------------------------------------------------------------------------//

  -- Drive referenced outputs
  NULL_RX_TLAST <= null_rx_tlast_xhdl0;

  XHDL1 : IF (C_DATA_WIDTH = 128) GENERATE
    packet_fmt   <= M_AXIS_RX_TDATA(94 DOWNTO 93) WHEN ((straddle_sof) = '1') ELSE  M_AXIS_RX_TDATA(30 DOWNTO 29);
    packet_td    <= M_AXIS_RX_TDATA(79) WHEN (straddle_sof = '1') ELSE M_AXIS_RX_TDATA(15);
    payload_len_tmp  <= M_AXIS_RX_TDATA(73 DOWNTO 64) WHEN (straddle_sof = '1') ELSE M_AXIS_RX_TDATA(9 DOWNTO 0);
    payload_len  <= payload_len_tmp WHEN ((packet_fmt(1)) = '1') ELSE  (others => '0');

    xhdl2 <= packet_fmt(0) & packet_td & straddle_sof;
    -- In 128-bit mode, the amount of data currently on the interface
    -- depends on whether we're straddling or not. If so, 2 DWORDs have been
    -- seen. If not, 4 DWORDs.
    PROCESS (xhdl2)
    BEGIN
      CASE xhdl2 IS
        WHEN "000" =>
          packet_overhead <= "0011" + "0000" - "0100";
        WHEN "001" =>
          packet_overhead <= "0011" + "0000" - "0010";
        WHEN "010" =>
          packet_overhead <= "0011" + "0001" - "0100";
        WHEN "011" =>
          packet_overhead <= "0011" + "0001" - "0010";
        WHEN "100" =>
          packet_overhead <= "0100" + "0000" - "0100";
        WHEN "101" =>
          packet_overhead <= "0100" + "0000" - "0010";
        WHEN "110" =>
          packet_overhead <= "0100" + "0001" - "0100";
        WHEN "111" =>
          packet_overhead <= "0100" + "0001" - "0010";
        WHEN OTHERS =>
          packet_overhead <= "0000" + "0000" - "0000";
      END CASE;
    END PROCESS;
  END GENERATE;

  XHDL4 : IF (C_DATA_WIDTH = 64) GENERATE
    packet_fmt <= M_AXIS_RX_TDATA(30 DOWNTO 29);
    packet_td <= M_AXIS_RX_TDATA(15);
    payload_len <= M_AXIS_RX_TDATA(9 DOWNTO 0) WHEN ((packet_fmt(1)) = '1') ELSE  "0000000000";

    xhdl5 <= packet_fmt(0) & packet_td;
    --  64-bit mode: no straddling, so always 2 DWORDs
    PROCESS (packet_fmt, packet_td,xhdl5)
    BEGIN
      CASE xhdl5 IS
        -- Header +   TD   - Data currently on interface
        WHEN "00" =>
          packet_overhead <= "0011" + "0000" - "0010";
        WHEN "01" =>
          packet_overhead <= "0011" + "0001" - "0010";
        WHEN "10" =>
          packet_overhead <= "0100" + "0000" - "0010";
        WHEN "11" =>
          packet_overhead <= "0100" + "0001" - "0010";
        WHEN OTHERS =>
          packet_overhead <= "0000" + "0000" - "0000";
      END CASE;
    END PROCESS;
  END GENERATE;

  XHDL6 : IF (C_DATA_WIDTH = 32) GENERATE
    packet_fmt <= M_AXIS_RX_TDATA(30 DOWNTO 29);
    packet_td <= M_AXIS_RX_TDATA(15);
    payload_len <= M_AXIS_RX_TDATA(9 DOWNTO 0) WHEN ((packet_fmt(1)) = '1') ELSE "0000000000";

    xhdl7 <= packet_fmt(0) & packet_td;
    -- 32-bit mode: no straddling, so always 1 DWORD
    PROCESS (packet_fmt, packet_td,xhdl7)
    BEGIN
      CASE xhdl7 IS
        WHEN "00" =>
          packet_overhead <= "0011" + "0000" - "0001";
        WHEN "01" =>
          packet_overhead <= "0011" + "0001" - "0001";
        WHEN "10" =>
          packet_overhead <= "0100" + "0000" - "0001";
        WHEN "11" =>
          packet_overhead <= "0100" + "0001" - "0001";
        WHEN OTHERS =>
          packet_overhead <= "0000" + "0000" - "0000";
      END CASE;
    END PROCESS;
  END GENERATE;

  -- Now calculate actual packet length, adding the packet overhead and the
  -- payload length. This is signed math, so sign-extend packet_overhead.
  -- NOTE: a payload length of zero means 1024 DW in the PCIe spec, but this behavior isn't supported in our block.

    new_pkt_len <= (packet_overhead(3) & packet_overhead(3) & packet_overhead(3) & packet_overhead(3) & packet_overhead(3) &
                    packet_overhead(3) & packet_overhead(3) & packet_overhead(3) & packet_overhead(3) & packet_overhead(2 DOWNTO 0))
                   + ("00" & payload_len);


  -- Math signals needed in the state machine below. These are seperate wires to
  -- help ensure synthesis tools are smart about optimizing them.
  pkt_len_counter_dec <= reg_pkt_len_counter - INTERFACE_WIDTH_DWORDS;
  pkt_done <= '1' WHEN (reg_pkt_len_counter <= INTERFACE_WIDTH_DWORDS) ELSE '0';


  PROCESS (cur_state, M_AXIS_RX_TVALID, M_AXIS_RX_TREADY, eof, new_pkt_len, reg_pkt_len_counter,
           pkt_len_counter_dec, straddle_sof, pkt_done)
  BEGIN

    CASE cur_state IS
      -- IDLE state: the interface is IDLE and we're waiting for a packet to
      -- start. If a packet starts, move to state IN_PACKET and begin tracking it as long as it's NOT
      -- a signle cycle packet (indicated by assertion of eof at packet start)
      WHEN IDLE =>
        IF ((M_AXIS_RX_TVALID = '1') and (M_AXIS_RX_TREADY = '1') and (eof = '0')) THEN next_state <= IN_PACKET;
        ELSE
                next_state <= IDLE;
        END IF;
        pkt_len_counter <= new_pkt_len;
      -- IN_PACKET: a multi -cycle packet is in progress and we're tracking it. We are
      -- in lock-step with the AXI interface decrementing our packet length
      -- tracking reg, and waiting for the packet to finish.
      -- If packet finished and a new one starts, this is a straddle situation.
      -- Next state is IN_PACKET (128-bit only).
      -- If the current packet is done, next state is IDLE.
      -- Otherwise, next state is IN_PACKET.
      WHEN IN_PACKET =>
        -- Straddle packet
        IF ((C_DATA_WIDTH = 128) AND straddle_sof = '1' AND M_AXIS_RX_TVALID = '1') THEN
          pkt_len_counter <= new_pkt_len;
          next_state <= IN_PACKET;
        -- Current packet finished
        ELSIF (M_AXIS_RX_TREADY = '1' AND pkt_done = '1') THEN
          pkt_len_counter <= new_pkt_len;
          next_state <= IDLE ;

        ELSE
          IF (M_AXIS_RX_TREADY = '1') THEN
            -- Packet in progress
            pkt_len_counter <= pkt_len_counter_dec;
          ELSE
            -- Throttled
            pkt_len_counter <= reg_pkt_len_counter;
          END IF;

          next_state <= IN_PACKET;
        END IF;
      WHEN OTHERS =>
        pkt_len_counter <= reg_pkt_len_counter;
        next_state <= IDLE ;
    END CASE;
  END PROCESS;

  --Synchronous NULL packet generator state machine logic
  PROCESS (USER_CLK)
  BEGIN
    IF (USER_CLK'EVENT AND USER_CLK = '1') THEN
      IF (USER_RST = '1') THEN
        cur_state <= IDLE  AFTER (TCQ)*1 ps;
        reg_pkt_len_counter <= (others => '0')  AFTER (TCQ)*1 ps;
      ELSE
        cur_state <= next_state AFTER (TCQ)*1 ps;
        reg_pkt_len_counter <= pkt_len_counter  AFTER (TCQ)*1 ps;
      END IF;
    END IF;
  END PROCESS;

  --Generate tkeep/is_eof for an end-of-packet situation.
  XHDL8 : IF (C_DATA_WIDTH = 128) GENERATE
    -- Assign null_is_eof depending on how many DWORDs are left in the packet.
    PROCESS (pkt_len_counter)
    BEGIN
      CASE pkt_len_counter IS
        WHEN "000000000001" =>
          null_is_eof <= "10011";
        WHEN "000000000010" =>
          null_is_eof <= "10111";
        WHEN "000000000011" =>
          null_is_eof <= "11011";
        WHEN "000000000100" =>
          null_is_eof <= "11111";
        WHEN OTHERS =>
          null_is_eof <= "00011";
      END CASE;
    END PROCESS;

    --tkeep not used in 128-bit interface
    eof_tkeep <= (others => '0') ; --'0' & '0' & '0' & '0';
  END GENERATE;

  XHDL9 : IF (NOT(C_DATA_WIDTH = 128)) GENERATE
    XHDL10 : IF (C_DATA_WIDTH = 64) GENERATE
      -- Assign null_is_eof depending on how many DWORDs are left in the packet.
      PROCESS (pkt_len_counter)
      BEGIN
        CASE pkt_len_counter IS
          WHEN "000000000001" =>
            null_is_eof <= "10011";
          WHEN "000000000010" =>
            null_is_eof <= "10111";
          WHEN OTHERS =>
            null_is_eof <= "00011";
        END CASE;
      END PROCESS;

      -- Assign tkeep to 0xFF or 0x0F depending on how many DWORDs are left in the current packet.
      eof_tkeep <= X"FF" WHEN (pkt_len_counter = "000000000010") ELSE X"0F";
    END GENERATE;

    XHDL11 : IF (NOT(C_DATA_WIDTH = 64)) GENERATE
      PROCESS (pkt_len_counter)
      BEGIN
        --is_eof is either on or off in 32-bit interface
        IF (pkt_len_counter = "000000000001") THEN
          null_is_eof <= "10011";
        ELSE
          null_is_eof <= "10011";
        END IF;
      END PROCESS;

      --The entire DWORD is always valid in 32-bit mode, so tkeep is always 0xF
      eof_tkeep <= "1111";
    END GENERATE;
  END GENERATE;

  --Finally, use everything we've generated to calculate our NULL outputs
  NULL_RX_TVALID <= '1';
  null_rx_tlast_xhdl0 <= '1' WHEN (pkt_len_counter <= INTERFACE_WIDTH_DWORDS) ELSE '0' ;
  NULL_RX_tkeep <= eof_tkeep WHEN (null_rx_tlast_xhdl0 = '1') ELSE  (others => '1');
  NULL_RDST_RDY <= null_rx_tlast_xhdl0 ;
END TRANS;
