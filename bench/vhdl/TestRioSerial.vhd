-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- Description
-- Contains automatic simulation test code to verify a RioSerial implementation.
-- 
-- To Do:
-- -
-- 
-- Author(s): 
-- - Magnus Rosenius, magro732@opencores.org 
-- 
-------------------------------------------------------------------------------
-- 
-- Copyright (C) 2013 Authors and OPENCORES.ORG 
-- 
-- This source file may be used and distributed without 
-- restriction provided that this copyright statement is not 
-- removed from the file and that any derivative work contains 
-- the original copyright notice and the associated disclaimer. 
-- 
-- This source file is free software; you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General 
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any 
-- later version. 
-- 
-- This source is distributed in the hope that it will be 
-- useful, but WITHOUT ANY WARRANTY; without even the implied 
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE. See the GNU Lesser General Public License for more 
-- details. 
-- 
-- You should have received a copy of the GNU Lesser General 
-- Public License along with this source; if not, download it 
-- from http://www.opencores.org/lgpl.shtml 
-- 
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- TestRioSerial.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for TestRioSerial.
-------------------------------------------------------------------------------
entity TestRioSerial is
end entity;


-------------------------------------------------------------------------------
-- Architecture for TestUart.
-------------------------------------------------------------------------------
architecture TestRioSerialImpl of TestRioSerial is
  
  component TestSwitchPort is
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      frameValid_i : in std_logic_vector(0 to 63);
      frameWrite_i : in RioFrameArray(0 to 63);
      frameComplete_o : out std_logic;
      
      frameExpected_i : in std_logic;
      frameRead_i : in RioFrame;
      frameReceived_o : out std_logic;

      readFrameEmpty_o : out std_logic;
      readFrame_i : in std_logic;
      readFrameRestart_i : in std_logic;
      readFrameAborted_o : out std_logic;

      readWindowEmpty_o : out std_logic;
      readWindowReset_i : in std_logic;
      readWindowNext_i : in std_logic;
      
      readContentEmpty_o : out std_logic;
      readContent_i : in std_logic;
      readContentEnd_o : out std_logic;
      readContentData_o : out std_logic_vector(31 downto 0);
      
      writeFrameFull_o : out std_logic;
      writeFrame_i : in std_logic;
      writeFrameAbort_i : in std_logic;
      writeContent_i : in std_logic;
      writeContentData_i : in std_logic_vector(31 downto 0));
  end component;

  component RioSerial is
    generic(
      TIMEOUT_WIDTH : natural);
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      portLinkTimeout_i : in std_logic_vector(TIMEOUT_WIDTH-1 downto 0);
      linkInitialized_o : out std_logic;
      inputPortEnable_i : in std_logic;
      outputPortEnable_i : in std_logic;
    
      localAckIdWrite_i : in std_logic;
      clrOutstandingAckId_i : in std_logic;
      inboundAckId_i : in std_logic_vector(4 downto 0);
      outstandingAckId_i : in std_logic_vector(4 downto 0);
      outboundAckId_i : in std_logic_vector(4 downto 0);
      inboundAckId_o : out std_logic_vector(4 downto 0);
      outstandingAckId_o : out std_logic_vector(4 downto 0);
      outboundAckId_o : out std_logic_vector(4 downto 0);
    
      readFrameEmpty_i : in std_logic;
      readFrame_o : out std_logic;
      readFrameRestart_o : out std_logic;
      readFrameAborted_i : in std_logic;

      readWindowEmpty_i : in std_logic;
      readWindowReset_o : out std_logic;
      readWindowNext_o : out std_logic;
      
      readContentEmpty_i : in std_logic;
      readContent_o : out std_logic;
      readContentEnd_i : in std_logic;
      readContentData_i : in std_logic_vector(31 downto 0);

      writeFrameFull_i : in std_logic;
      writeFrame_o : out std_logic;
      writeFrameAbort_o : out std_logic;
      writeContent_o : out std_logic;
      writeContentData_o : out std_logic_vector(31 downto 0);

      portInitialized_i : in std_logic;
      outboundSymbolEmpty_o : out std_logic;
      outboundSymbolRead_i : in std_logic;
      outboundSymbol_o : out std_logic_vector(33 downto 0);
      inboundSymbolFull_o : out std_logic;
      inboundSymbolWrite_i : in std_logic;
      inboundSymbol_i : in std_logic_vector(33 downto 0));
  end component;

  signal clk : std_logic;
  signal areset_n : std_logic;

  signal uartInbound : std_logic;
  signal uartOutbound : std_logic;

  signal portLinkTimeout : std_logic_vector(10 downto 0);
  signal linkInitialized : std_logic;
  signal inputPortEnable : std_logic;
  signal outputPortEnable : std_logic;
  
  signal localAckIdWrite : std_logic;
  signal clrOutstandingAckId : std_logic;
  signal inboundAckIdWrite : std_logic_vector(4 downto 0);
  signal outstandingAckIdWrite : std_logic_vector(4 downto 0);
  signal outboundAckIdWrite : std_logic_vector(4 downto 0);
  signal inboundAckIdRead : std_logic_vector(4 downto 0);
  signal outstandingAckIdRead : std_logic_vector(4 downto 0);
  signal outboundAckIdRead : std_logic_vector(4 downto 0);
  
  signal portInitialized : std_logic;
  signal outboundSymbolEmpty : std_logic;
  signal outboundSymbolRead : std_logic;
  signal outboundSymbol : std_logic_vector(33 downto 0);
  signal inboundSymbolFull : std_logic;
  signal inboundSymbolWrite : std_logic;
  signal inboundSymbol : std_logic_vector(33 downto 0);

  signal readFrameEmpty : std_logic;
  signal readFrame : std_logic;
  signal readFrameRestart : std_logic;
  signal readFrameAborted : std_logic;
  signal readWindowEmpty : std_logic;
  signal readWindowReset : std_logic;
  signal readWindowNext : std_logic;
  signal readContentEmpty : std_logic;
  signal readContent : std_logic;
  signal readContentEnd : std_logic;
  signal readContentData : std_logic_vector(31 downto 0);

  signal writeFrameFull : std_logic;
  signal writeFrame : std_logic;
  signal writeFrameAbort : std_logic;
  signal writeContent : std_logic;
  signal writeContentData : std_logic_vector(31 downto 0);

  signal frameValid : std_logic_vector(0 to 63);
  signal frameWrite : RioFrameArray(0 to 63);
  signal frameComplete : std_logic;
  signal frameExpected : std_logic;
  signal frameRead : RioFrame;
  signal frameReceived : std_logic;
  
begin
  
  -----------------------------------------------------------------------------
  -- Clock generation.
  -----------------------------------------------------------------------------
  ClockGenerator: process
  begin
    clk <= '0';
    wait for 20 ns;
    clk <= '1';
    wait for 20 ns;
  end process;


  -----------------------------------------------------------------------------
  -- Serial protocol test driver.
  -----------------------------------------------------------------------------
  TestDriver: process

    ---------------------------------------------------------------------------
    -- Procedure to receive a symbol.
    ---------------------------------------------------------------------------
    procedure ReceiveSymbol(
      constant symbolType : in std_logic_vector(1 downto 0);
      constant symbolContent : in std_logic_vector(31 downto 0) := x"00000000") is
    begin
      wait until outboundSymbolEmpty = '0' and clk'event and clk = '1';

      assert symbolType = outboundSymbol(33 downto 32)
        report "Missmatching symbol type:expected=" &
        integer'image(to_integer(unsigned(symbolType))) &
        " got=" &
        integer'image(to_integer(unsigned(outboundSymbol(33 downto 32))))
        severity error;
      
      if ((outboundSymbol(33 downto 32) = SYMBOL_CONTROL) or
          (outboundSymbol(33 downto 32) = SYMBOL_CONTROL)) then
        assert symbolContent(31 downto 8) = outboundSymbol(31 downto 8)
          report "Missmatching symbol content:expected=" &
          integer'image(to_integer(unsigned(symbolContent(31 downto 8)))) &
          " got=" &
          integer'image(to_integer(unsigned(outboundSymbol(31 downto 8))))
          severity error;
      elsif (outboundSymbol(33 downto 32) = SYMBOL_DATA) then
        assert symbolContent(31 downto 0) = outboundSymbol(31 downto 0)
          report "Missmatching symbol content:expected=" &
          integer'image(to_integer(unsigned(symbolContent(31 downto 0)))) &
          " got=" &
          integer'image(to_integer(unsigned(outboundSymbol(31 downto 0))))
          severity error;
      end if;

      outboundSymbolRead <= '1';
      wait until clk'event and clk = '1';
      outboundSymbolRead <= '0';
    end procedure;

    ---------------------------------------------------------------------------
    -- Procedure to send a symbol.
    ---------------------------------------------------------------------------
    procedure SendSymbol(
      constant symbolType : in std_logic_vector(1 downto 0);
      constant symbolContent : in std_logic_vector(31 downto 0) := x"00000000") is
    begin
      wait until inboundSymbolFull = '0' and clk'event and clk = '1';

      inboundSymbolWrite <= '1';
      inboundSymbol <= symbolType & symbolContent;

      wait until clk'event and clk = '1';
      inboundSymbolWrite <= '0';
    end procedure;

    ---------------------------------------------------------------------------
    -- Process variables.
    ---------------------------------------------------------------------------
    variable seed1 : positive := 1;
    variable seed2 : positive := 1;
    variable payload : RioPayload;
    
    variable frame : RioFrame;

  begin
    ---------------------------------------------------------------------------
    -- Test case initialization.
    ---------------------------------------------------------------------------

    frameValid <= (others=>'0');
    frameExpected <= '0';

    portLinkTimeout <= (others=>'1');
    inputPortEnable <= '1';
    outputPortEnable <= '1';
    
    portInitialized <= '0';
    outboundSymbolRead <= '0';
    inboundSymbolWrite <= '0';
    inboundSymbol <= (others => '0');

    localAckIdWrite <= '0';
    clrOutstandingAckId <= '0';
    inboundAckIdWrite <= (others=>'0');
    outstandingAckIdWrite <= (others=>'0');
    outboundAckIdWrite <= (others=>'0');
    
    -- Generate a startup reset pulse.
    areset_n <= '0';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    areset_n <= '1';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioSerial");
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioSerial-TC1");
    PrintS("Description: Test idle-sequence transmission at startup.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: Read transmission port.");
    PrintS("Result: Idle sequence symbols should be read.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC1-Step1");
    ---------------------------------------------------------------------------
    
    -- Make sure only idle-sequences are transmitted at startup.
    for i in 0 to 1024 loop
      ReceiveSymbol(SYMBOL_IDLE);
    end loop;

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioSerial-TC2");
    PrintS("Description: Test idle-sequence and status symbol transmission");
    PrintS("             when the port has been initialized.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: Set port initialized and read transmission port.");
    PrintS("Result: Idle sequence and status symbols should be read.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC2-Step1");
    ---------------------------------------------------------------------------

    -- Initialize the port to trigger a change of state.
    portInitialized <= '1';
    
    -- The transmitter should send idle sequences at startup and a status once
    -- in a while.
    for i in 0 to 254 loop
      ReceiveSymbol(SYMBOL_IDLE);
    end loop;
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                         STYPE1_NOP, "000"));
    for i in 0 to 254 loop
      ReceiveSymbol(SYMBOL_IDLE);
    end loop;
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                         STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 2:");
    PrintS("Action: Toggle port initialized pin and check that no status ");
    PrintS("        symbols are transmitted when uninitialized.");
    PrintS("Result: Only idle sequences should be read when uninitialized.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC2-Step2");
    ---------------------------------------------------------------------------

    -- Deassert the port initialized flag.
    portInitialized <= '0';
    
    -- Make sure only idle-sequences are transmitted at startup.
    for i in 0 to 1024 loop
      ReceiveSymbol(SYMBOL_IDLE);
    end loop;

    -- Initialize the port to trigger a change of state.
    portInitialized <= '1';
    
    -- The transmitter should send idle sequences at startup and a status once
    -- in a while.
    for i in 0 to 254 loop
      ReceiveSymbol(SYMBOL_IDLE);
    end loop;
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                         STYPE1_NOP, "000"));
    for i in 0 to 254 loop
      ReceiveSymbol(SYMBOL_IDLE);
    end loop;
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                         STYPE1_NOP, "000"));
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 3:");
    PrintS("Action: Send one error free status symbol to trigger the ");
    PrintS("        transmission of status symbols with a higher frequency.");
    PrintS("Result: Idle sequence and status symbols should be read but ");
    PrintS("        status symbols should be recived more often.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC2-Step3");
    ---------------------------------------------------------------------------

    -- A received error-free status triggers transmission of status symbols in
    -- a more rapid past.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_NOP, "000"));

    -- The transmitter should send at least 15 additional statuses after
    -- receiving an error free status.
    for j in 0 to 15 loop
      for i in 0 to 15 loop
        ReceiveSymbol(SYMBOL_IDLE);
      end loop;
      
      ReceiveSymbol(SYMBOL_CONTROL,
                    RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                           STYPE1_NOP, "000"));
    end loop;

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 4:");
    PrintS("Action: Send one errornous status symbol to restart the status ");
    PrintS("        counting.");
    PrintS("Result: Idle sequence and status symbols should be read but ");
    PrintS("        status symbols should still be received more often.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC2-Step4");
    ---------------------------------------------------------------------------
    
    -- REMARK: Add this...
    PrintR("Not implemented.");
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 5:");
    PrintS("Action: Send one errornous status symbol to restart the status ");
    PrintS("        counting.");
    PrintS("Result: Idle sequence and status symbols should be read but ");
    PrintS("        status symbols should still be received more often.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC2-Step5");
    ---------------------------------------------------------------------------
    
    -- Make the link fully initialized by sending 7 additional statuses.
    for i in 0 to 6 loop
      SendSymbol(SYMBOL_CONTROL,
                 RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                        STYPE1_NOP, "000"));
    end loop;

    wait until linkInitialized = '1';
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioSerial-TC3");
    PrintS("Description: Test port reception.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: Send an inbound frame with pad after the CRC.");
    PrintS("Result: The frame should end up in a frame buffer.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step1");
    ---------------------------------------------------------------------------

    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 1;
    frame := RioFrameCreate(ackId=>"00000", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;
    
    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Send the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    
    -- End the reception of the frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));

    -- Check that the frame has been received in the frame buffer.
    wait until frameReceived = '1';
    frameExpected <= '0';
    
    -- Receive an idle symbol left in the FIFO before the ack was generated.
    ReceiveSymbol(SYMBOL_IDLE);
    
    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00000", "11111",
                                         STYPE1_NOP, "000"));
    
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 2:");
    PrintS("Action: Send an inbound frame without a pad after the CRC.");
    PrintS("Result: The frame should end up in a frame buffer.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step2");
    ---------------------------------------------------------------------------
    
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 2;
    frame := RioFrameCreate(ackId=>"00001", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;
    
    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Send the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    
    -- End the reception of the frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));

    -- Check that the frame has been received in the frame buffer.
    wait until frameReceived = '1';
    frameExpected <= '0';
    
    -- Receive an idle symbol left in the FIFO before the ack was generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive acknowledge for the transmited frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00001", "11111",
                                         STYPE1_NOP, "000"));
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 3:");
    PrintS("Action: Send an inbound frame with maximum size.");
    PrintS("Result: The frame should end up in a frame buffer.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step3");
    ---------------------------------------------------------------------------
    
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 133;
    frame := RioFrameCreate(ackId=>"00010", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;
    
    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Send the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    
    -- End the reception of the frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));

    -- Check that the frame has been received in the frame buffer.
    wait until frameReceived = '1';
    frameExpected <= '0';
    
    -- Receive an idle symbol left in the FIFO before the ack was generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00010", "11111",
                                         STYPE1_NOP, "000"));

    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 4:");
    PrintS("Action: Send two packets without end-of-packet in between.");
    PrintS("Result: Both packets should be accepted.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step4");
    ---------------------------------------------------------------------------
    
    -- Create the first frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 10;
    frame := RioFrameCreate(ackId=>"00011", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;
    
    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Send the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    
    -- Start the reception of a frame, implicitly ending the previous.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Check that the frame has been received in the frame buffer.
    wait until frameReceived = '1';
    frameExpected <= '0';
    wait until clk'event and clk = '1';
    
    -- Receive an idle symbol left in the FIFO before the ack was generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00011", "11111",
                                         STYPE1_NOP, "000"));

    -- Create the second frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 13;
    frame := RioFrameCreate(ackId=>"00100", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;
    
    -- Send the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    
    -- End the reception of the frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));

    -- Check that the frame has been received in the frame buffer.
    wait until frameReceived = '1';
    frameExpected <= '0';
    
    -- Receive an idle symbol left in the FIFO before the ack was generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00100", "11111",
                                         STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 5:");
    PrintS("Action: Start to send a packet. Abort it with stomp. Then send ");
    PrintS("        another packet.");
    PrintS("Result: The first packet should be discarded and the second should");
    PrintS("        be accepted. The retried packet should be acknowledged.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step5");
    ---------------------------------------------------------------------------
    
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 7;
    frame := RioFrameCreate(ackId=>"00101", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;
    
    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Send the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    
    -- Abort the reception of the frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_STOMP, "000"));

    -- Dont expect the aborted frame anymore.
    frameExpected <= '0';
    
    -- Receive an idle symbol left in the FIFO before the retry was generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_RETRY, "00101", "11111",
                                         STYPE1_NOP, "000"));

    -- Acknowledge the canceled packet.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_RESTART_FROM_RETRY, "000"));

    -- Create a new frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 8;
    frame := RioFrameCreate(ackId=>"00101", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;
    
    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Send the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    
    -- Abort the reception of the frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));
    
    -- Check that the frame has been received in the frame buffer.
    wait until frameReceived = '1';
    frameExpected <= '0';
    
    -- Receive an idle symbol left in the FIFO before the ack was generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00101", "11111",
                                         STYPE1_NOP, "000"));
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 6:");
    PrintS("Action: Start to send a packet but dont send any payload. Abort it");
    PrintS("        with stomp. Then send another packet.");
    PrintS("Result: The first packet should be discarded and the second should");
    PrintS("        be accepted. The retried packet should be acknowledged.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step6");
    ---------------------------------------------------------------------------
    
    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Abort the reception of the frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_STOMP, "000"));

    -- Receive an idle symbol left in the FIFO before the retry was generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_RETRY, "00110", "11111",
                                         STYPE1_NOP, "000"));

    -- Acknowledge the canceled packet.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_RESTART_FROM_RETRY, "000"));

    -- Create a new frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 8;
    frame := RioFrameCreate(ackId=>"00110", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;

    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Send the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    
    -- Abort the reception of the frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));
    
    -- Check that the frame has been received in the frame buffer.
    wait until frameReceived = '1';
    frameExpected <= '0';
    
    -- Receive an idle symbol left in the FIFO before the ack was generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00110", "11111",
                                         STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 7:");
    PrintS("Action: Start to send a packet with payload, then send a ");
    PrintS("        link-request. Then send another packet.");
    PrintS("Result: The first packet should be canceled without any ");
    PrintS("        confirmation and a link-response should be returned. The");
    PrintS("        second packet should be accepted.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step7");
    ---------------------------------------------------------------------------
    
    -- Create a new frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 9;
    frame := RioFrameCreate(ackId=>"00111", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;

    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Send the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    
    -- Send a link-request/input-status to abort the current packet.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_LINK_REQUEST, "100"));

    -- Receive an idle symbol left in the FIFO before the ack was generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- The frame should be canceled by the link-request, dont expect it anymore.
    frameExpected <= '0';
    
    -- Receive link-response indicating normal operation and expected ackId.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "00111", "10000",
                                         STYPE1_NOP, "000"));

    -- Create a new frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 10;
    frame := RioFrameCreate(ackId=>"00111", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;

    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Send the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    
    -- Abort the reception of the frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));
    
    -- Check that the frame has been received in the frame buffer.
    wait until frameReceived = '1';
    frameExpected <= '0';

    -- Receive an idle symbol left in the FIFO before the ack was generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00111", "11111",
                                         STYPE1_NOP, "000"));
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 8:");
    PrintS("Action: Start to send a packet, no payload, then send a ");
    PrintS("        link-request. Then send another packet.");
    PrintS("Result: The first packet should be canceled without any ");
    PrintS("        confirmation and a link-response should be returned. The");
    PrintS("        second packet should be accepted.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step8");
    ---------------------------------------------------------------------------

    -- Expect an empty packet to be aborted.
    frameExpected <= '1';
    
    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Send a link-request/input-status to abort the current packet.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_LINK_REQUEST, "100"));

    -- Receive an idle symbol left in the FIFO before the ack was generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Dont expect any frames anymore.
    frameExpected <= '0';
    
    -- Receive link-response indicating normal operation and expected ackId.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "01000", "10000",
                                         STYPE1_NOP, "000"));

    -- Create a new frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 11;
    frame := RioFrameCreate(ackId=>"01000", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;

    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));

    -- Send the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    
    -- Abort the reception of the frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));
    
    -- Check that the frame has been received in the frame buffer.
    wait until frameReceived = '1';
    frameExpected <= '0';
    
    -- Receive an idle symbol left in the FIFO before the ack was generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "01000", "11111",
                                         STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 9:");
    PrintS("Action: Send a packet when no buffers is available. Reset receiver");
    PrintS("        with link-request.");
    PrintS("Result: A packet-retry should be transmitted and receiver should");
    PrintS("        enter input-retry-stopped.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step9");
    ---------------------------------------------------------------------------

    -- Create a new frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 11;
    frame := RioFrameCreate(ackId=>"01001", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    
    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));
    SendSymbol(SYMBOL_DATA, frame.payload(0));

    -- Receive notification about that the packet needs to be retried.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_RETRY, "01001", "11111",
                                         STYPE1_NOP, "000"));

    -- Check the status of the input port and verify the input-retry-stopped state.
    -- This should also set the receiver into normal operation.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_LINK_REQUEST, "100"));
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "01001", "00100",
                                         STYPE1_NOP, "000"));

    -- Check the status of the input port and verify the input-retry-stopped state.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_LINK_REQUEST, "100"));
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "01001", "10000",
                                         STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 10:");
    PrintS("Action: Send a packet when no buffers is available. Reset receiver");
    PrintS("        with restart-from-retry.");
    PrintS("Result: A packet-retry should be transmitted and receiver should");
    PrintS("        enter input-retry-stopped.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step10");
    ---------------------------------------------------------------------------

    -- Create a new frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 11;
    frame := RioFrameCreate(ackId=>"01001", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    
    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));
    SendSymbol(SYMBOL_DATA, frame.payload(0));

    -- Receive notification about that the packet needs to be retried.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_RETRY, "01001", "11111",
                                         STYPE1_NOP, "000"));

    -- Acknowledge the retried packet.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_RESTART_FROM_RETRY, "000"));

    -- Check the status of the input port and verify the input-retry-stopped state.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_LINK_REQUEST, "100"));
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "01001", "10000",
                                         STYPE1_NOP, "000"));

    -- Always receive a status after a link response when leaving input-error-stopped.
--    ReceiveSymbol(SYMBOL_CONTROL,
--                  RioControlSymbolCreate(STYPE0_STATUS, "01001", "11111",
--                                         STYPE1_NOP, "000"));    

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 11:");
    PrintS("Action: Start a new packet when in input-retry-stopped state.");
    PrintS("Result: The packet should be discarded.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step11");
    ---------------------------------------------------------------------------

    -- Create a new frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 11;
    frame := RioFrameCreate(ackId=>"01001", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    
    -- Start the reception of a frame.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));
    SendSymbol(SYMBOL_DATA, frame.payload(0));

    -- Receive notification about that the packet needs to be retried.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_RETRY, "01001", "11111",
                                         STYPE1_NOP, "000"));

    -- Create a packet and send it. It should be discarded.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 12;
    frame := RioFrameCreate(ackId=>"01001", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));
    
    -- Acknowledge the retried packet.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_RESTART_FROM_RETRY, "000"));

    -- Create a packet and send it.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 13;
    frame := RioFrameCreate(ackId=>"01001", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));
    wait until frameReceived = '1';
    frameExpected <= '0';

    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "01001", "11111",
                                         STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 12:");
    PrintS("Action: Send an erronous control-symbol. Then restore with");
    PrintS("        link-request.");
    PrintS("Result: Receiver should enter input-error-stopped and return to");
    PrintS("        normal operation after the link-request was receiver.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step12");
    ---------------------------------------------------------------------------

    -- Create, corrupt and send a control symbol.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000") xor x"00100000");

    -- Receive a packet-not-accepted indicating error in control-symbol crc.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_NOT_ACCEPTED, "00000", "00010",
                                         STYPE1_NOP, "000"));

    -- Create a packet and send it. It should be discarded.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 14;
    frame := RioFrameCreate(ackId=>"01010", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));
    
    -- Make the receiver go back to normal operation by sending a link-request.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_LINK_REQUEST, "100"));

    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "01010", "00101",
                                         STYPE1_NOP, "000"));

    -- Always receive a status after a link response when leaving input-error-stopped.
--    ReceiveSymbol(SYMBOL_CONTROL,
--                  RioControlSymbolCreate(STYPE0_STATUS, "01010", "11111",
--                                         STYPE1_NOP, "000"));
    
    -- Create a packet and send it.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 15;
    frame := RioFrameCreate(ackId=>"01010", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));
    wait until frameReceived = '1';
    frameExpected <= '0';

    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "01010", "11111",
                                         STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 13:");
    PrintS("Action: Send an erronous packet. Then restore with link-request.");
    PrintS("Result: Receiver should enter input-error-stopped and return to");
    PrintS("        normal operation after the link-request was receiver.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC3-Step13");
    ---------------------------------------------------------------------------

    -- Create a packet and send it with a bit error. It should be discarded.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 15;
    frame := RioFrameCreate(ackId=>"01011", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frame.payload(0) := frame.payload(0) xor x"00000010";
    frameExpected <= '1';
    frameRead <= frame;
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));
    
    -- Receive a packet-not-accepted indicating error in control-symbol crc.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_NOT_ACCEPTED, "00000", "00100",
                                         STYPE1_NOP, "000"));

    -- Dont expect any frame anymore.
    frameExpected <= '0';

    -- Make the receiver go back to normal operation by sending a link-request.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_LINK_REQUEST, "100"));

    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "01011", "00101",
                                         STYPE1_NOP, "000"));

    -- Send a new frame without error.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 16;
    frame := RioFrameCreate(ackId=>"01011", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameExpected <= '1';
    frameRead <= frame;
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      SendSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00000", "11111",
                                      STYPE1_END_OF_PACKET, "000"));
    wait until frameReceived = '1';
    frameExpected <= '0';

    -- Receive acknowledge for the transmitted frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "01011", "11111",
                                         STYPE1_NOP, "000"));

    -- REMARK: Complete with some more error situations: invalid ackId, too
    -- short packet, too long packet, etc...
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioSerial-TC4");
    PrintS("Description: Test port transmission.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: Send an outbound frame.");
    PrintS("Result: The frame should be read from the frame buffer and ");
    PrintS("        received as symbols.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step1");
    ---------------------------------------------------------------------------
    
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 3;
    frame := RioFrameCreate(ackId=>"00000", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(0) <= '1';
    frameWrite(0) <= frame;

    -- Make sure the transmitter fills in the correct ackId and dont use the
    -- one in the input packet.
    frameWrite(0).payload(0)(31 downto 27) <= "UUUUU";

    -- Receive an idle symbol left in the FIFO before the start of the frame was
    -- generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive the start of the frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));

    -- Receive the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    -- Wait for the frame to complete.
    wait until frameComplete = '1';
    frameValid(0) <= '0';
    
    -- Receive the end of the frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));

    -- Send acknowledge that the frame was received.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00000", "11111",
                                      STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 2:");
    PrintS("Action: Send an outbound packet with maximum length.");
    PrintS("Result: The packet should be fragmented and received in symbols.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step2");
    ---------------------------------------------------------------------------
    
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 133;
    frame := RioFrameCreate(ackId=>"00001", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(1) <= '1';
    frameWrite(1) <= frame;

    -- Receive an idle symbol left in the FIFO before the start of the frame was
    -- generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive the start of the frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));

    -- Receive the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    -- Wait for the frame to complete.
    wait until frameComplete = '1';
    frameValid(1) <= '0';
    
    -- Receive the end of the frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));

    -- Send acknowledge that the frame was received.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00001", "11111",
                                      STYPE1_NOP, "000"));

     ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 3:");
    PrintS("Action: Send a packet and confirm it with packet-retry.");
    PrintS("Result: A restart-from-retry should be transmitted and the packet");
    PrintS("        should be retransmitted.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step3");
    ---------------------------------------------------------------------------
    
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 4;
    frame := RioFrameCreate(ackId=>"00010", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(2) <= '1';
    frameWrite(2) <= frame;

    -- Receive an idle symbol left in the FIFO before the start of the frame was
    -- generated.
    ReceiveSymbol(SYMBOL_IDLE);

    -- Receive the start of the frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));

    -- Receive the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    -- Receive the end of the frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));

    -- Send packet-retry that the frame should be retransmitted.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_RETRY, "00010", "11111",
                                      STYPE1_NOP, "000"));

    -- Receive the acknowledgement for the retransmission.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_RESTART_FROM_RETRY, "000"));

    -- Receive the start of the retransmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));

    -- Receive the data symbols of the retransmitted frame.
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    -- Wait for the frame to complete.
    wait until frameComplete = '1' and clk'event and clk = '1';
    frameValid(2) <= '0';
    
    -- Receive the end of the retransmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));

    -- Send acknowledge that the frame was received.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00010", "11111",
                                      STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 4:");
    PrintS("Action: Send a packet and confirm it with packet-not-accepted. ");
    PrintS("Result: A link-request should be transmitted and the packet should");
    PrintS("        be retransmitted.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step4");
    ---------------------------------------------------------------------------
    
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 5;
    frame := RioFrameCreate(ackId=>"00011", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(3) <= '1';
    frameWrite(3) <= frame;

    -- Receive the start of the frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));

    -- Receive the data symbols of the frame.
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    -- Receive the end of the frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));

    -- Send packet-retry that the frame should be retransmitted.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_NOT_ACCEPTED, "00000", "11111",
                                      STYPE1_NOP, "000"));

    -- Receive the acknowledgement for the retransmission.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_LINK_REQUEST, "100"));
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "00011", "11111",
                                      STYPE1_NOP, "000"));

    -- Receive the start of the retransmitted frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));

    -- Receive the data symbols of the retransmitted frame.
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    -- Wait for the frame to complete.
    wait until frameComplete = '1';
    frameValid(3) <= '0';
    
    -- Receive the end of the retransmitted frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));

    -- Send acknowledge that the frame was received.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00011", "11111",
                                      STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 5:");
    PrintS("Action: Let a packet timeout expire. Then answer with link-response.");
    PrintS("Result: A link-request should be transmitted and the packet should");
    PrintS("        be retransmitted.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step5");
    ---------------------------------------------------------------------------
    
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 5;
    frame := RioFrameCreate(ackId=>"00100", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(4) <= '1';
    frameWrite(4) <= frame;

    -- Receive the frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));

    -- Wait a while to let the timer expire and receive the link-request.
    for i in 0 to 2048 loop
      wait until clk'event and clk = '1';
    end loop;
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_LINK_REQUEST, "100"));

    -- Send a link-response to make the transmitter to back to normal mode.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "00100", "11111",
                                      STYPE1_NOP, "000"));
    
    -- Receive the retransmitted frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));
    
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    -- Wait for the frame to complete.
    wait until frameComplete = '1';
    frameValid(4) <= '0';
    
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));

    -- Send acknowledge that the frame was received.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00100", "11111",
                                      STYPE1_NOP, "000"));
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 6:");
    PrintS("Action: Let a packet timeout expire. Then answer with link-response");
    Prints("        that indicates that the packet was received.");
    PrintS("Result: A link-request should be transmitted and the packet should");
    PrintS("        not be retransmitted.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step6");
    ---------------------------------------------------------------------------
    
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 6;
    frame := RioFrameCreate(ackId=>"00101", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(5) <= '1';
    frameWrite(5) <= frame;

    -- Receive the frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    wait until frameComplete = '1';
    frameValid(5) <= '0';
    
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));

    -- Wait a while to let the timer expire and receive the link-request.
    for i in 0 to 2048 loop
      wait until clk'event and clk = '1';
    end loop;
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_LINK_REQUEST, "100"));

    -- Send a link-response that indicates that the frame was received to make
    -- the transmitter to back to normal mode.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "00110", "11111",
                                      STYPE1_NOP, "000"));
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 7:");
    PrintS("Action: Let a packet timeout expire. No more replies.");
    PrintS("Result: Three link-requests should be transmitted. When the third");
    PrintS("        times out the link will be restarted.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step7");
    ---------------------------------------------------------------------------
    
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 7;
    frame := RioFrameCreate(ackId=>"00110", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(6) <= '1';
    frameWrite(6) <= frame;

    -- Receive the frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));

    -- Wait a while to let the timer expire and receive the link-request.
    for i in 0 to 2048 loop
      wait until clk'event and clk = '1';
    end loop;
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_LINK_REQUEST, "100"));

    -- Wait a while to let the timer expire and receive the link-request.
    for i in 0 to 2048 loop
      wait until clk'event and clk = '1';
    end loop;
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_LINK_REQUEST, "100"));

    -- Wait a while to let the timer expire and receive the link-request.
    for i in 0 to 2048 loop
      wait until clk'event and clk = '1';
    end loop;
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_LINK_REQUEST, "100"));

    -- Wait a while to let the timer expire and receive the link-request.
    for i in 0 to 2048 loop
      wait until clk'event and clk = '1';
    end loop;

    -- Reinitialize the transmitter.
    for i in 0 to 255 loop
      ReceiveSymbol(SYMBOL_IDLE);
    end loop;
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_NOP, "000"));
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00110", "11111",
                                      STYPE1_NOP, "000"));
    for j in 0 to 14 loop
      for i in 0 to 15 loop
        ReceiveSymbol(SYMBOL_IDLE);
      end loop;
      ReceiveSymbol(SYMBOL_CONTROL,
                    RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                           STYPE1_NOP, "000"));
    end loop;

    -- Receive the frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    wait until frameComplete = '1';
    frameValid(6) <= '0';
    
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00110", "11111",
                                      STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 8:");
    PrintS("Action: Let a packet timeout expire. Then answer with totally ");
    PrintS("        unexpected ackId.");
    PrintS("Result: A link request should be transmitted and the link should ");
    PrintS("        be restarted.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step8");
    ---------------------------------------------------------------------------
    
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 8;
    frame := RioFrameCreate(ackId=>"00111", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(7) <= '1';
    frameWrite(7) <= frame;

    -- Receive the frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));

    -- Wait a while to let the timer expire and receive the link-request.
    for i in 0 to 2048 loop
      wait until clk'event and clk = '1';
    end loop;
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_LINK_REQUEST, "100"));

    -- Send a link-response with unexpected ackId.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "10000", "11111",
                                      STYPE1_NOP, "000"));
    
    -- Reinitialize the transmitter.
    for i in 0 to 255 loop
      ReceiveSymbol(SYMBOL_IDLE);
    end loop;
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_NOP, "000"));
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "00111", "11111",
                                      STYPE1_NOP, "000"));
    for j in 0 to 14 loop
      for i in 0 to 15 loop
        ReceiveSymbol(SYMBOL_IDLE);
      end loop;
      ReceiveSymbol(SYMBOL_CONTROL,
                    RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                           STYPE1_NOP, "000"));
    end loop;

    -- Receive the frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    wait until frameComplete = '1';
    frameValid(7) <= '0';
    
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "00111", "11111",
                                      STYPE1_NOP, "000"));
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 9:");
    PrintS("Action: Send status with unexpected ackId in normal operation.");
    PrintS("Result: The transmitter should disregard the error.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step9");
    ---------------------------------------------------------------------------

    -- Send a status with unexpected ackId.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_STATUS, "10000", "11111",
                                      STYPE1_NOP, "000"));

    -- Receive no change.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_IDLE);

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 10:");
    PrintS("Action: Send packet-retry with unexpected ackId in normal operation.");
    PrintS("Result: The transmitter should enter output-error-stopped.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step10");
    ---------------------------------------------------------------------------
    
    -- Send a packet-retry with unexpected ackId.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_RETRY, "10000", "11111",
                                      STYPE1_NOP, "000"));

    -- Receive link-request.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_LINK_REQUEST, "100"));

    -- Send a link-response with unexpected ackId.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "01000", "11111",
                                      STYPE1_NOP, "000"));
        
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 10;
    frame := RioFrameCreate(ackId=>"01000", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(8) <= '1';
    frameWrite(8) <= frame;

    -- Receive the frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    wait until frameComplete = '1';
    frameValid(8) <= '0';

    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "01000", "11111",
                                      STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 11:");
    PrintS("Action: Send packet-accepted with unexpected ackId in normal ");
    PrintS("        operation.");
    PrintS("Result: The transmitter should enter output-error-stopped.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step11");
    ---------------------------------------------------------------------------
    
    -- Send a packet-accepted with unexpected ackId.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "10000", "11111",
                                      STYPE1_NOP, "000"));

    -- Receive link-request.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_LINK_REQUEST, "100"));

    -- Send a link-response with unexpected ackId.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "01001", "11111",
                                      STYPE1_NOP, "000"));
        
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 11;
    frame := RioFrameCreate(ackId=>"01001", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(9) <= '1';
    frameWrite(9) <= frame;

    -- Receive the frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    wait until frameComplete = '1';
    frameValid(9) <= '0';

    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "01001", "11111",
                                      STYPE1_NOP, "000"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 12:");
    PrintS("Action: Send a packet and then accept it with unexpected ackId.");
    PrintS("Result: The transmitter should enter output-error-stopped.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step12");
    ---------------------------------------------------------------------------
    
    -- Create the frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 12;
    frame := RioFrameCreate(ackId=>"01010", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(10) <= '1';
    frameWrite(10) <= frame;

    -- Receive the frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frame.length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frame.payload(i));
    end loop;

    wait until frameComplete = '1';
    frameValid(10) <= '0';

    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));
    
    -- Send unexpected ackId in packet-accepted.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "10000", "11111",
                                      STYPE1_NOP, "000"));

    -- Receive link-request.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_LINK_REQUEST, "100"));

    -- Send a link-response with expected ackId.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_LINK_RESPONSE, "01011", "11111",
                                      STYPE1_NOP, "000"));        

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 13:");
    PrintS("Action: Set two valid packets.");
    PrintS("Result: The two packet should be sent without waiting for ");
    PrintS("        packet-accepted.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step13");
    ---------------------------------------------------------------------------

    -- Create the first frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 13;
    frame := RioFrameCreate(ackId=>"01011", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(11) <= '1';
    frameWrite(11) <= frame;

    -- Create the second frame.
    CreateRandomPayload(payload.data, seed1, seed2);
    payload.length := 14;
    frame := RioFrameCreate(ackId=>"01100", vc=>'0', crf=>'0', prio=>"00",
                            tt=>"01", ftype=>"0000",
                            sourceId=>x"0000", destId=>x"0000",
                            payload=>payload);
    frameValid(12) <= '1';
    frameWrite(12) <= frame;

    -- Receive the frame.
    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frameWrite(11).length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frameWrite(11).payload(i));
    end loop;

    wait until frameComplete = '1';
    frameValid(11) <= '0';

    -- Receive the frame.
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_START_OF_PACKET, "000"));
    for i in 0 to frameWrite(12).length-1 loop
      ReceiveSymbol(SYMBOL_DATA, frameWrite(12).payload(i));
    end loop;

    wait until frameComplete = '1';
    frameValid(12) <= '0';
    
    ReceiveSymbol(SYMBOL_CONTROL,
                  RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                         STYPE1_END_OF_PACKET, "000"));
    
    
    -- Send packet-accepted for both packets.
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "01011", "11111",
                                      STYPE1_NOP, "000"));
    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "01100", "11111",
                                      STYPE1_NOP, "000"));

    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_IDLE);
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 14:");
    PrintS("Action: Set maximum number of valid packets.");
    PrintS("Result: Maximum 31 packets should be sent without waiting for ");
    PrintS("        packet-accepted.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-Step14");
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Create the frames.
    ---------------------------------------------------------------------------

    for j in 0 to 47 loop
      CreateRandomPayload(payload.data, seed1, seed2);
      payload.length := j+13;
      frame := RioFrameCreate(ackId=>std_logic_vector(to_unsigned((j+13) mod 32, 5)), vc=>'0', crf=>'0', prio=>"00",
                              tt=>"01", ftype=>"0000",
                              sourceId=>x"0000", destId=>x"0000",
                              payload=>payload);
      frameValid(j+13) <= '1';
      frameWrite(j+13) <= frame;
    end loop;

    ---------------------------------------------------------------------------
    -- Receive the frames.
    ---------------------------------------------------------------------------

    ReceiveSymbol(SYMBOL_IDLE);
    
    for j in 0 to 30 loop
      ReceiveSymbol(SYMBOL_CONTROL,
                    RioControlSymbolCreate(STYPE0_STATUS, "01100", "11111",
                                           STYPE1_START_OF_PACKET, "000"));
      for i in 0 to frameWrite(j+13).length-1 loop
        ReceiveSymbol(SYMBOL_DATA, frameWrite(j+13).payload(i));
      end loop;

      wait until frameComplete = '1';
      frameValid(j+13) <= '0';
    end loop;

    ReceiveSymbol(SYMBOL_IDLE);
    ReceiveSymbol(SYMBOL_IDLE);
    

    SendSymbol(SYMBOL_CONTROL,
               RioControlSymbolCreate(STYPE0_PACKET_ACCEPTED, "01101", "11111",
                                      STYPE1_NOP, "000"));

    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step X:");
    PrintS("Action: Start sending an outbound packet and while in transmission, ");
    PrintS("        start and complete an inbound packet.");
    PrintS("Result: The ack for the inbound packet should be inserted into the");
    PrintS("        outbound packet.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-StepX");
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step X:");
    PrintS("Action: Send a packet but not all content is available yet.");
    PrintS("Result: Idle symbols should be inserted into the packet.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSerial-TC4-StepX");
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- REMARK: Send long frames with a CRC in the middle...
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- Test completed.
    ---------------------------------------------------------------------------

    TestEnd;
  end process;

  
  -----------------------------------------------------------------------------
  -- Instantiate the uart.
  -----------------------------------------------------------------------------

  TestPort: TestSwitchPort
    port map(
      clk=>clk, areset_n=>areset_n,
      frameValid_i=>frameValid, frameWrite_i=>frameWrite, frameComplete_o=>frameComplete,
      frameExpected_i=>frameExpected, frameRead_i=>frameRead, frameReceived_o=>frameReceived,
      readFrameEmpty_o=>readFrameEmpty, readFrame_i=>readFrame,
      readFrameRestart_i=>readFrameRestart, readFrameAborted_o=>readFrameAborted,
      readWindowEmpty_o=>readWindowEmpty,
      readWindowReset_i=>readWindowReset, readWindowNext_i=>readWindowNext,
      readContentEmpty_o=>readContentEmpty, readContent_i=>readContent,
      readContentEnd_o=>readContentEnd, readContentData_o=>readContentData,
      writeFrameFull_o=>writeFrameFull, writeFrame_i=>writeFrame, writeFrameAbort_i=>writeFrameAbort,
      writeContent_i=>writeContent, writeContentData_i=>writeContentData);

  TestPhy: RioSerial
    generic map(
      TIMEOUT_WIDTH=>11)
    port map(
      clk=>clk, areset_n=>areset_n,
      portLinkTimeout_i=>portLinkTimeout,
      linkInitialized_o=>linkInitialized,
      inputPortEnable_i=>inputPortEnable,
      outputPortEnable_i=>outputPortEnable,
      localAckIdWrite_i=>localAckIdWrite, 
      clrOutstandingAckId_i=>clrOutstandingAckId, 
      inboundAckId_i=>inboundAckIdWrite, 
      outstandingAckId_i=>outstandingAckIdWrite, 
      outboundAckId_i=>outboundAckIdWrite, 
      inboundAckId_o=>inboundAckIdRead, 
      outstandingAckId_o=>outstandingAckIdRead, 
      outboundAckId_o=>outboundAckIdRead, 
      readFrameEmpty_i=>readFrameEmpty, readFrame_o=>readFrame, readFrameRestart_o=>readFrameRestart, 
      readFrameAborted_i=>readFrameAborted,
      readWindowEmpty_i=>readWindowEmpty,
      readWindowReset_o=>readWindowReset, readWindowNext_o=>readWindowNext,
      readContentEmpty_i=>readContentEmpty,
      readContent_o=>readContent, readContentEnd_i=>readContentEnd, readContentData_i=>readContentData,
      writeFrameFull_i=>writeFrameFull, writeFrame_o=>writeFrame, writeFrameAbort_o=>writeFrameAbort,
      writeContent_o=>writeContent, writeContentData_o=>writeContentData,
      portInitialized_i=>portInitialized,
      outboundSymbolEmpty_o=>outboundSymbolEmpty, outboundSymbolRead_i=>outboundSymbolRead,
      outboundSymbol_o=>outboundSymbol,
      inboundSymbolFull_o=>inboundSymbolFull, inboundSymbolWrite_i=>inboundSymbolWrite,
      inboundSymbol_i=>inboundSymbol);

end architecture;



-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
use work.rio_common.all;
 

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
entity TestSwitchPort is
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    frameValid_i : in std_logic_vector(0 to 63);
    frameWrite_i : in RioFrameArray(0 to 63);
    frameComplete_o : out std_logic;
    
    frameExpected_i : in std_logic;
    frameRead_i : in RioFrame;
    frameReceived_o : out std_logic;

    readFrameEmpty_o : out std_logic;
    readFrame_i : in std_logic;
    readFrameRestart_i : in std_logic;
    readFrameAborted_o : out std_logic;

    readWindowEmpty_o : out std_logic;
    readWindowReset_i : in std_logic;
    readWindowNext_i : in std_logic;
      
    readContentEmpty_o : out std_logic;
    readContent_i : in std_logic;
    readContentEnd_o : out std_logic;
    readContentData_o : out std_logic_vector(31 downto 0);
    
    writeFrameFull_o : out std_logic;
    writeFrame_i : in std_logic;
    writeFrameAbort_i : in std_logic;
    writeContent_i : in std_logic;
    writeContentData_i : in std_logic_vector(31 downto 0));
end entity;


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
architecture TestSwitchPortImpl of TestSwitchPort is
begin
  
  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------
  FrameSender: process
    variable frameIndex : natural range 0 to 70;
    variable backIndex, frontIndex : natural range 0 to 63;
  begin
    readFrameEmpty_o <= '1';
    readFrameAborted_o <= '0';
    readWindowEmpty_o <= '1';
    readContentEmpty_o <= '1';
    readContentEnd_o <= '0';
    readContentData_o <= (others=>'U');
    frameComplete_o <= '0';
    backIndex := 0;
    frontIndex := 0;
    wait until areset_n = '1';

    loop
      wait until clk'event and clk = '1';

      if (readFrame_i = '1') then
        assert (frontIndex - backIndex) >= 0 report "Unexpected readFrame." severity error;
        if(backIndex < 63) then
          backIndex := backIndex + 1;
        else
          backIndex := 0;
        end if;
      end if;
      
      if (readWindowReset_i = '1') then
        frameIndex := 0;
        frontIndex := backIndex;
        readContentEnd_o <= '0';
        readContentData_o <= (others=>'U');
      end if;

      if (readWindowNext_i = '1') then
        assert frameIndex = frameWrite_i(frontIndex).length report "Did not read all frame content." severity error;
        frameComplete_o <= '1';
        readContentEnd_o <= '0';
        readContentData_o <= (others=>'U');
        frameIndex := 0;
        if(frontIndex < 63) then
          frontIndex := frontIndex + 1;
        else
          frontIndex := 0;
        end if;
      else
        frameComplete_o <= '0';
      end if;
      
      if (readFrameRestart_i = '1') then
        frameIndex := 0;
        readContentEnd_o <= '0';
        readContentData_o <= (others=>'U');
      end if;
      
      if (readContent_i = '1') then
        assert frameValid_i(frontIndex) = '1' report "Unexpected content read." severity error;
        if (frameIndex /= frameWrite_i(frontIndex).length) then
          readContentEnd_o <= '0';
          readContentData_o <= frameWrite_i(frontIndex).payload(frameIndex);
          frameIndex := frameIndex + 1;
        else
          readContentEnd_o <= '1';
          readContentData_o <= (others=>'U');
        end if;
      end if;
      
      if(frameValid_i(frontIndex) = '1') then
        readFrameEmpty_o <= '0';
        readWindowEmpty_o <= '0';
        readContentEmpty_o <= '0';
      else
        readFrameEmpty_o <= '1';
        readWindowEmpty_o <= '1';
        readContentEmpty_o <= '1';
      end if;
      
    end loop;    
  end process;

  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------
  FrameReader: process
    type StateType is (STATE_IDLE, STATE_READ, STATE_UPDATE);
    variable state : StateType;
    variable frameIndex : natural range 0 to 69;
  begin
    writeFrameFull_o <= '1';
    frameReceived_o <= '0';
    wait until areset_n = '1';

    state := STATE_IDLE;

    loop
      wait until clk'event and clk = '1';
    
      case state is
        when STATE_IDLE =>
          frameReceived_o <= '0';
          if (frameExpected_i = '1') then
            state := STATE_READ;
            frameIndex := 0;
            writeFrameFull_o <= '0';
          end if;
          assert writeFrame_i = '0' report "Unexpected frame received." severity error;
          --assert writeFrameAbort_i = '0' report "Unexpected frame aborted received." severity error;
          assert writeContent_i = '0' report "Unexpected content received." severity error;
          
        when STATE_READ =>
          if (writeFrame_i = '1') then
            state := STATE_UPDATE;
            frameReceived_o <= '1';
            writeFrameFull_o <= '1';
            assert frameIndex = frameRead_i.length report "Did not finish the expected frame." severity error;
          end if;
          if (writeFrameAbort_i = '1') then
            frameIndex := 0;
          end if;
          if (writeContent_i = '1') then
            assert writeContentData_i = frameRead_i.payload(frameIndex)
              report "Unexpected frame content received." severity error;
            frameIndex := frameIndex + 1;
          end if;
          if (frameExpected_i = '0') then
            state := STATE_IDLE;
          end if;

        when STATE_UPDATE =>
          if (frameExpected_i = '0') then
            state := STATE_IDLE;
          end if;
          
      end case;
    end loop;
  end process;

end architecture;
