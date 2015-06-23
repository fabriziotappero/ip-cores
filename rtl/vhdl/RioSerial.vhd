-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- Description
-- Containing the transmission channel independent parts of the LP-Serial
-- Physical Layer Specification (RapidIO 2.2, part 6).
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
-- RioSerial
--
-- clk - System clock.
-- areset_n - System reset. Asynchronous, active low. 
--
-- portLinkTimeout_i - The number of ticks to wait for a packet-accepted before
--   a timeout occurrs.
-- linkInitialized_o - Indicates if a link partner is answering with valid
--   status-control-symbols. 
-- inputPortEnable_i - Activate the input port for non-maintenance packets. If
--   deasserted, only non-maintenance packets are allowed.
-- outputPortEnable_i - Activate the output port for non-maintenance packets.
--   If deasserted, only non-maintenance packets are allowed.
--
-- This interface makes it possible to read and write ackId in both outbound
-- and inbound directions. All input signals are validated by localAckIdWrite.
-- localAckIdWrite_i - Indicate if a localAckId write operation is ongoing.
--   Usually this signal is high one tick. 
-- clrOutstandingAckId_i - Clear outstanding ackId, i.e. reset the transmission
--   window. The signal is only read if localAckIdWrite_i is high.
-- inboundAckId_i - The value to set the inbound ackId (the ackId that the
--  next inbound packet should have) to. This signal is only read if localAckIdWrite
--  is high.
-- outstandingAckId_i - The value to set the outstanding ackId (the ackId
--   transmitted but not acknowledged) to. This signal is only read if localAckIdWrite
--   is high.
-- outboundAckId_i - The value to set the outbound ackId (the ackId that the
--   next outbound packet will have) to. This signal is only read if localAckIdWrite
--   is high.
-- inboundAckId_o - The current inbound ackId.
-- outstandingAckId_o - The current outstanding ackId.
-- outboundAckId_o - The current outbound ackId.
--
-- This is the interface to the packet buffering sublayer. 
-- The window signals are used to send packets without removing them from the
-- memory storage. This way, many packet can be sent without awaiting
-- packet-accepted symbols and if a packet-accepted gets lost, it is possible
-- to revert and resend a packet. This is achived by reading readWindowEmpty
-- for new packet and asserting readWindowNext when a packet has been sent.
-- When the packet-accepted is received, readFrame should be asserted to remove the
-- packet from the storage. If a packet-accepted is missing, readWindowReset is
-- asserted to set the current packet to read to the one that has not received
-- a packet-accepted.
-- readFrameEmpty_i - Indicate if a packet is ready in the outbound direction.
--   Once deasserted, it is possible to read the packet content using
--   readContent_o to update readContentData and readContentEnd.
-- readFrame_o - Assert this signal for one tick to discard the oldest packet.
--   It should be used when a packet has been fully read, a linkpartner has
--   accepted it and the resources occupied by it should be returned to be
--   used for new packets.
-- readFrameRestart_o - Assert this signal to restart the reading of the
--   current packet. readContentData and readContentEnd will be reset to the
--   first content of the packet. 
-- readFrameAborted_i - This signal is asserted if the current packet was
--   aborted while it was written. It is used when a transmitter starts to send a
--   packet before it has been fully received and it is cancelled before it is
--   completed. A one tick asserted readFrameRestart signal resets this signal.
-- readWindowEmpty_i - Indicate if there are more packets to send.
-- readWindowReset_o - Reset the current packet to the oldest stored in the memory.
-- readWindowNext_o - Indicate that a new packet should be read. Must only be
--   asserted if readWindowEmpty is deasserted. It should be high for one tick.
-- readContentEmpty_i - Indicate if there are any packet content to be read.
--   This signal is updated directly when packet content is written making it
--   possible to read packet content before the full packet has been written to
--   the memory storage.
-- readContent_o - Update readContentData and readContentEnd.
-- readContentEnd_i - Indicate if the end of the current packet has been
--   reached. When asserted, readContentData is not valid.
-- readContentData_i - The content of the current packet.
-- writeFrameFull_i - Indicate if the inbound packet storage is ready to accept
--   a new packet.
-- writeFrame_o - Indicate that a new complete inbound packet has been written.
-- writeFrameAbort_o - Indicate that the current packet is aborted and that all
--   data written for this packet should be discarded. 
-- writeContent_o - Indicate that writeContentData is valid and should be
--   written into the packet content storage. 
-- writeContentData_o - The content to write to the packet content storage.
--
-- This is the interface to the PCS (Physical Control Sublayer). Four types of
-- symbols exist, idle, control, data and error.
-- Idle symbols are transmitted when nothing else can be transmitted. They are
-- mainly intended to enforce a timing on the transmitted symbols. This is
-- needed to be able to guarantee that a status-control-symbol is transmitted
-- at least once every 256 symbol.
-- Control symbols contain control-symbols as described by the standard.
-- Data symbols contains a 32-bit fragment of a RapidIO packet.
-- Error symbols indicate that a corrupted symbol was received. This could be
-- used by a PCS layer to indicate that a transmission error was detected and
-- that the above layers should send link-requests to ensure the synchronism
-- between the link-partners.
-- The signals in this interface are:
-- portInitialized_i - An asserted signal on this pin indicates that the PCS
--   layer has established synchronization with the link and is ready to accept
--   symbols. 
-- outboundSymbolEmpty_o - An asserted signal indicates that there are no
--   outbound symbols to read. Once deasserted, outboundSymbol_o will be
--   already be valid. This signal will be updated one tick after
--   outboundSymbolRead_i has been asserted.
-- outboundSymbolRead_i - Indicate that outboundSymbol_o has been read and a
--   new value could be accepted. It should be active for one tick. 
-- outboundSymbol_o - The outbound symbol. The two MSB bits are the type of the
--   symbol.
--   bit 34-33 
--   00=IDLE, the rest of the bits are not used.
--   01=CONTROL, the control symbols payload (24 bits) are placed in the MSB
--     part of the symbol data.
--   10=ERROR, the rest of the bits are not used.
--   11=DATA, all the remaining bits contain the data-symbol payload.
-- inboundSymbolFull_o - An asserted signal indicates that no more inbound
--   symbols can be accepted.
-- inboundSymbolWrite_i - Indicate that inboundSymbol_i contains valid
-- information that should be forwarded. Should be active for one tick.
-- inboundSymbol_i - The inbound symbol. See outboundSymbol_o for formating.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for RioSerial.
-------------------------------------------------------------------------------
entity RioSerial is
  generic(
    TIMEOUT_WIDTH : natural);
  port(
    -- System signals.
    clk : in std_logic;
    areset_n : in std_logic;

    -- Status signals for maintenance operations.
    portLinkTimeout_i : in std_logic_vector(TIMEOUT_WIDTH-1 downto 0);
    linkInitialized_o : out std_logic;
    inputPortEnable_i : in std_logic;
    outputPortEnable_i : in std_logic;

    -- Support for portLocalAckIdCSR.
    localAckIdWrite_i : in std_logic;
    clrOutstandingAckId_i : in std_logic;
    inboundAckId_i : in std_logic_vector(4 downto 0);
    outstandingAckId_i : in std_logic_vector(4 downto 0);
    outboundAckId_i : in std_logic_vector(4 downto 0);
    inboundAckId_o : out std_logic_vector(4 downto 0);
    outstandingAckId_o : out std_logic_vector(4 downto 0);
    outboundAckId_o : out std_logic_vector(4 downto 0);
    
    -- Outbound frame interface.
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

    -- Inbound frame interface.
    writeFrameFull_i : in std_logic;
    writeFrame_o : out std_logic;
    writeFrameAbort_o : out std_logic;
    writeContent_o : out std_logic;
    writeContentData_o : out std_logic_vector(31 downto 0);

    -- PCS layer signals.
    portInitialized_i : in std_logic;
    outboundSymbolEmpty_o : out std_logic;
    outboundSymbolRead_i : in std_logic;
    outboundSymbol_o : out std_logic_vector(33 downto 0);
    inboundSymbolFull_o : out std_logic;
    inboundSymbolWrite_i : in std_logic;
    inboundSymbol_i : in std_logic_vector(33 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for RioSerial.
-------------------------------------------------------------------------------
architecture RioSerialImpl of RioSerial is

  component RioFifo1 is
    generic(
      WIDTH : natural);
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      empty_o : out std_logic;
      read_i : in std_logic;
      data_o : out std_logic_vector(WIDTH-1 downto 0);

      full_o : out std_logic;
      write_i : in std_logic;
      data_i : in std_logic_vector(WIDTH-1 downto 0));
  end component;
  
  component RioTransmitter is
    generic(
      TIMEOUT_WIDTH : natural);
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      portLinkTimeout_i : in std_logic_vector(TIMEOUT_WIDTH-1 downto 0);
      portEnable_i : in std_logic;
      
      localAckIdWrite_i : in std_logic;
      clrOutstandingAckId_i : in std_logic;
      outstandingAckId_i : in std_logic_vector(4 downto 0);
      outboundAckId_i : in std_logic_vector(4 downto 0);
      outstandingAckId_o : out std_logic_vector(4 downto 0);
      outboundAckId_o : out std_logic_vector(4 downto 0);
    
      portInitialized_i : in std_logic;
      txFull_i : in std_logic;
      txWrite_o : out std_logic;
      txControl_o : out std_logic_vector(1 downto 0);
      txData_o : out std_logic_vector(31 downto 0);

      txControlEmpty_i : in std_logic;
      txControlSymbol_i : in std_logic_vector(12 downto 0);
      txControlUpdate_o : out std_logic;
      rxControlEmpty_i : in std_logic;
      rxControlSymbol_i : in std_logic_vector(12 downto 0);
      rxControlUpdate_o : out std_logic;

      linkInitialized_i : in std_logic;
      linkInitialized_o : out std_logic;
      ackIdStatus_i : in std_logic_vector(4 downto 0);

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
      readContentData_i : in std_logic_vector(31 downto 0));
  end component;

  component RioReceiver is
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      portEnable_i : in std_logic;
      
      localAckIdWrite_i : in std_logic;
      inboundAckId_i : in std_logic_vector(4 downto 0);
      inboundAckId_o : out std_logic_vector(4 downto 0);
      
      portInitialized_i : in std_logic;
      rxEmpty_i : in std_logic;
      rxRead_o : out std_logic;
      rxControl_i : in std_logic_vector(1 downto 0);
      rxData_i : in std_logic_vector(31 downto 0);

      txControlWrite_o : out std_logic;
      txControlSymbol_o : out std_logic_vector(12 downto 0);
      rxControlWrite_o : out std_logic;
      rxControlSymbol_o : out std_logic_vector(12 downto 0);

      ackIdStatus_o : out std_logic_vector(4 downto 0);
      linkInitialized_o : out std_logic;
      
      writeFrameFull_i : in std_logic;
      writeFrame_o : out std_logic;
      writeFrameAbort_o : out std_logic;
      writeContent_o : out std_logic;
      writeContentData_o : out std_logic_vector(31 downto 0));
  end component;

  signal linkInitializedRx : std_logic;
  signal linkInitializedTx : std_logic;
  signal ackIdStatus : std_logic_vector(4 downto 0);
  
  signal txControlWrite : std_logic;
  signal txControlWriteSymbol : std_logic_vector(12 downto 0);
  signal txControlReadEmpty : std_logic;
  signal txControlRead : std_logic;
  signal txControlReadSymbol : std_logic_vector(12 downto 0);

  signal rxControlWrite : std_logic;
  signal rxControlWriteSymbol : std_logic_vector(12 downto 0);
  signal rxControlReadEmpty : std_logic;
  signal rxControlRead : std_logic;
  signal rxControlReadSymbol : std_logic_vector(12 downto 0);

  signal outboundFull : std_logic;
  signal outboundWrite : std_logic;
  signal outboundControl : std_logic_vector(1 downto 0);
  signal outboundData : std_logic_vector(31 downto 0);
  signal outboundSymbol : std_logic_vector(33 downto 0);

  signal inboundEmpty : std_logic;
  signal inboundRead : std_logic;
  signal inboundControl : std_logic_vector(1 downto 0);
  signal inboundData : std_logic_vector(31 downto 0);
  signal inboundSymbol : std_logic_vector(33 downto 0);

begin

  linkInitialized_o <=
    '1' when ((linkInitializedRx = '1') and (linkInitializedTx = '1')) else '0';
  
  -----------------------------------------------------------------------------
  -- Serial layer modules.
  -----------------------------------------------------------------------------
  
  Transmitter: RioTransmitter
    generic map(
      TIMEOUT_WIDTH=>TIMEOUT_WIDTH)
    port map(
      clk=>clk, areset_n=>areset_n,
      portLinkTimeout_i=>portLinkTimeout_i,
      portEnable_i=>outputPortEnable_i,
      localAckIdWrite_i=>localAckIdWrite_i, 
      clrOutstandingAckId_i=>clrOutstandingAckId_i, 
      outstandingAckId_i=>outstandingAckId_i, 
      outboundAckId_i=>outboundAckId_i, 
      outstandingAckId_o=>outstandingAckId_o, 
      outboundAckId_o=>outboundAckId_o, 
      portInitialized_i=>portInitialized_i,
      txFull_i=>outboundFull, txWrite_o=>outboundWrite,
      txControl_o=>outboundControl, txData_o=>outboundData, 
      txControlEmpty_i=>txControlReadEmpty, txControlSymbol_i=>txControlReadSymbol,
      txControlUpdate_o=>txControlRead, 
      rxControlEmpty_i=>rxControlReadEmpty, rxControlSymbol_i=>rxControlReadSymbol,
      rxControlUpdate_o=>rxControlRead,
      linkInitialized_o=>linkInitializedTx,
      linkInitialized_i=>linkInitializedRx, ackIdStatus_i=>ackIdStatus, 
      readFrameEmpty_i=>readFrameEmpty_i, readFrame_o=>readFrame_o, 
      readFrameRestart_o=>readFrameRestart_o, readFrameAborted_i=>readFrameAborted_i,
      readWindowEmpty_i=>readWindowEmpty_i,
      readWindowReset_o=>readWindowReset_o, readWindowNext_o=>readWindowNext_o,
      readContentEmpty_i=>readContentEmpty_i, readContent_o=>readContent_o, 
      readContentEnd_i=>readContentEnd_i, readContentData_i=>readContentData_i);

  TxSymbolFifo: RioFifo1
    generic map(WIDTH=>13)
    port map(
      clk=>clk, areset_n=>areset_n,
      empty_o=>txControlReadEmpty, read_i=>txControlRead, data_o=>txControlReadSymbol,
      full_o=>open, write_i=>txControlWrite, data_i=>txControlWriteSymbol);

  RxSymbolFifo: RioFifo1
    generic map(WIDTH=>13)
    port map(
      clk=>clk, areset_n=>areset_n,
      empty_o=>rxControlReadEmpty, read_i=>rxControlRead, data_o=>rxControlReadSymbol,
      full_o=>open, write_i=>rxControlWrite, data_i=>rxControlWriteSymbol);

  Receiver: RioReceiver
    port map(
      clk=>clk, areset_n=>areset_n, 
      portEnable_i=>inputPortEnable_i,
      localAckIdWrite_i=>localAckIdWrite_i, 
      inboundAckId_i=>inboundAckId_i, 
      inboundAckId_o=>inboundAckId_o, 
      portInitialized_i=>portInitialized_i,
      rxEmpty_i=>inboundEmpty, rxRead_o=>inboundRead,
      rxControl_i=>inboundControl, rxData_i=>inboundData, 
      txControlWrite_o=>txControlWrite, txControlSymbol_o=>txControlWriteSymbol, 
      rxControlWrite_o=>rxControlWrite, rxControlSymbol_o=>rxControlWriteSymbol, 
      ackIdStatus_o=>ackIdStatus, 
      linkInitialized_o=>linkInitializedRx,
      writeFrameFull_i=>writeFrameFull_i,
      writeFrame_o=>writeFrame_o, writeFrameAbort_o=>writeFrameAbort_o, 
      writeContent_o=>writeContent_o, writeContentData_o=>writeContentData_o);

  -----------------------------------------------------------------------------
  -- PCS layer FIFO interface.
  -----------------------------------------------------------------------------
  
  outboundSymbol <= outboundControl & outboundData;
  OutboundSymbolFifo: RioFifo1
    generic map(WIDTH=>34)
    port map(
      clk=>clk, areset_n=>areset_n,
      empty_o=>outboundSymbolEmpty_o, read_i=>outboundSymbolRead_i, data_o=>outboundSymbol_o,
      full_o=>outboundFull, write_i=>outboundWrite, data_i=>outboundSymbol);
  
  inboundControl <= inboundSymbol(33 downto 32);
  inboundData <= inboundSymbol(31 downto 0);
  InboundSymbolFifo: RioFifo1
    generic map(WIDTH=>34)
    port map(
      clk=>clk, areset_n=>areset_n,
      empty_o=>inboundEmpty, read_i=>inboundRead, data_o=>inboundSymbol,
      full_o=>inboundSymbolFull_o, write_i=>inboundSymbolWrite_i, data_i=>inboundSymbol_i);
        
end architecture;



-------------------------------------------------------------------------------
-- RioTransmitter
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for RioTransmitter.
-------------------------------------------------------------------------------
entity RioTransmitter is
  generic(
    TIMEOUT_WIDTH : natural);
  port(
    -- System signals.
    clk : in std_logic;
    areset_n : in std_logic;

    -- Status signals used for maintenance.
    portLinkTimeout_i : in std_logic_vector(TIMEOUT_WIDTH-1 downto 0);
    portEnable_i : in std_logic;

    -- Support for localAckIdCSR.
    localAckIdWrite_i : in std_logic;
    clrOutstandingAckId_i : in std_logic;
    outstandingAckId_i : in std_logic_vector(4 downto 0);
    outboundAckId_i : in std_logic_vector(4 downto 0);
    outstandingAckId_o : out std_logic_vector(4 downto 0);
    outboundAckId_o : out std_logic_vector(4 downto 0);
    
    -- Port output interface.
    portInitialized_i : in std_logic;
    txFull_i : in std_logic;
    txWrite_o : out std_logic;
    txControl_o : out std_logic_vector(1 downto 0);
    txData_o : out std_logic_vector(31 downto 0);

    -- Control symbols aimed to the transmitter.
    txControlEmpty_i : in std_logic;
    txControlSymbol_i : in std_logic_vector(12 downto 0);
    txControlUpdate_o : out std_logic;

    -- Control symbols from the receiver to send.
    rxControlEmpty_i : in std_logic;
    rxControlSymbol_i : in std_logic_vector(12 downto 0);
    rxControlUpdate_o : out std_logic;

    -- Internal signalling from the receiver part.
    linkInitialized_o : out std_logic;
    linkInitialized_i : in std_logic;
    ackIdStatus_i : in std_logic_vector(4 downto 0);

    -- Frame buffer interface.
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
    readContentData_i : in std_logic_vector(31 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for RioTransmitter.
-------------------------------------------------------------------------------
architecture RioTransmitterImpl of RioTransmitter is

  constant NUMBER_STATUS_TRANSMIT : natural := 15;
  constant NUMBER_LINK_RESPONSE_RETRIES : natural := 2;
  
  component MemorySimpleDualPortAsync is
    generic(
      ADDRESS_WIDTH : natural := 1;
      DATA_WIDTH : natural := 1;
      INIT_VALUE : std_logic := 'U');
    port(
      clkA_i : in std_logic;
      enableA_i : in std_logic;
      addressA_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      dataA_i : in std_logic_vector(DATA_WIDTH-1 downto 0);

      addressB_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      dataB_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;
  
  component Crc5ITU is
    port(
      d_i : in  std_logic_vector(18 downto 0);
      crc_o : out std_logic_vector(4 downto 0));
  end component;

  type StateType is (STATE_UNINITIALIZED, STATE_PORT_INITIALIZED,
                     STATE_NORMAL,
                     STATE_OUTPUT_RETRY_STOPPED,
                     STATE_SEND_LINK_REQUEST, STATE_OUTPUT_ERROR_STOPPED,
                     STATE_RECOVER, STATE_FATAL_ERROR);
  signal stateCurrent, stateNext : StateType;

  signal statusReceivedCurrent, statusReceivedNext : std_logic;
  signal counterCurrent, counterNext : natural range 0 to 15;
  signal symbolsTransmittedCurrent, symbolsTransmittedNext : natural range 0 to 255;
  
  type FrameStateType is (FRAME_START, FRAME_CHECK, FRAME_ACKID, FRAME_BODY, FRAME_END);
  signal frameStateCurrent, frameStateNext : FrameStateType;
  signal ackIdCurrent, ackIdNext : unsigned(4 downto 0) := (others=>'0');
  signal ackIdWindowCurrent, ackIdWindowNext : unsigned(4 downto 0) := (others=>'0');
  signal bufferStatusCurrent, bufferStatusNext : std_logic_vector(4 downto 0);
  
  signal stype0 : std_logic_vector(2 downto 0);
  signal parameter0 : std_logic_vector(4 downto 0);
  signal parameter1 : std_logic_vector(4 downto 0);
  signal stype1 : std_logic_vector(2 downto 0);
  signal cmd : std_logic_vector(2 downto 0);
  
  signal txControlStype0 : std_logic_vector(2 downto 0);
  signal txControlParameter0 : std_logic_vector(4 downto 0);
  signal txControlParameter1 : std_logic_vector(4 downto 0);

  signal rxControlStype0 : std_logic_vector(2 downto 0);
  signal rxControlParameter0 : std_logic_vector(4 downto 0);
  signal rxControlParameter1 : std_logic_vector(4 downto 0);

  signal symbolWrite : std_logic;
  signal symbolType : std_logic_vector(1 downto 0);
  signal symbolControl : std_logic_vector(31 downto 0);
  signal symbolData : std_logic_vector(31 downto 0);
  signal crcCalculated : std_logic_vector(4 downto 0);

  signal timeoutWrite : std_logic;
  signal timeoutCounter : unsigned(TIMEOUT_WIDTH downto 0);
  signal timeoutFrame : unsigned(TIMEOUT_WIDTH downto 0);
  signal timeoutElapsed : unsigned(TIMEOUT_WIDTH downto 0);
  signal timeoutDelta : unsigned(TIMEOUT_WIDTH downto 0);
  signal timeoutExpired : std_logic;

  signal timeoutAddress : std_logic_vector(4 downto 0);
  signal timeoutMemoryOut : std_logic_vector(TIMEOUT_WIDTH downto 0);
  
begin

  linkInitialized_o <= '0' when ((stateCurrent = STATE_UNINITIALIZED) or
                                 (stateCurrent = STATE_PORT_INITIALIZED)) else '1';
  
  -----------------------------------------------------------------------------
  -- Assign control symbol from fifo signals.
  -----------------------------------------------------------------------------
  
  txControlStype0 <= txControlSymbol_i(12 downto 10);
  txControlParameter0 <= txControlSymbol_i(9 downto 5);
  txControlParameter1 <= txControlSymbol_i(4 downto 0);

  rxControlStype0 <= rxControlSymbol_i(12 downto 10);
  rxControlParameter0 <= rxControlSymbol_i(9 downto 5);
  rxControlParameter1 <= rxControlSymbol_i(4 downto 0);

  -----------------------------------------------------------------------------
  -- Outbound symbol creation logic.
  -----------------------------------------------------------------------------

  symbolControl(31 downto 29) <= stype0;
  symbolControl(28 downto 24) <= parameter0;
  symbolControl(23 downto 19) <= parameter1;
  symbolControl(18 downto 16) <= stype1;
  symbolControl(15 downto 13) <= cmd;
  symbolControl(12 downto 8) <= crcCalculated;
  symbolControl(7 downto 0) <= x"00";

  Crc5Calculator: Crc5ITU 
    port map(
      d_i=>symbolControl(31 downto 13), crc_o=>crcCalculated);

  txWrite_o <= symbolWrite;
  txControl_o <= symbolType;
  txData_o <= symbolControl when (symbolType = SYMBOL_CONTROL) else symbolData;
  
  -----------------------------------------------------------------------------
  -- Packet timeout logic.
  -----------------------------------------------------------------------------

  -- Note that the timer is one bit larger to be able to detect a timeout on a
  -- free-running counter.
  process(areset_n, clk)
  begin
    if (areset_n = '0') then
      timeoutCounter <= (others=>'0');
    elsif (clk'event and clk = '1') then
      timeoutCounter <= timeoutCounter + 1;
    end if;
  end process;

  timeoutElapsed <= timeoutCounter - timeoutFrame;
  timeoutDelta <= unsigned('0' & portLinkTimeout_i) - timeoutElapsed;
  timeoutExpired <= timeoutDelta(TIMEOUT_WIDTH);
  
  timeoutFrame <= unsigned(timeoutMemoryOut);
  TimeoutMemory: MemorySimpleDualPortAsync
    generic map(ADDRESS_WIDTH=>5, DATA_WIDTH=>TIMEOUT_WIDTH+1, INIT_VALUE=>'0')
    port map(
      clkA_i=>clk, enableA_i=>timeoutWrite,
      addressA_i=>timeoutAddress, dataA_i=>std_logic_vector(timeoutCounter),
      addressB_i=>std_logic_vector(ackIdCurrent), dataB_o=>timeoutMemoryOut);
    
  -----------------------------------------------------------------------------
  -- Main outbound symbol handler, synchronous part.
  -----------------------------------------------------------------------------
  process(areset_n, clk)
  begin
    if (areset_n = '0') then
      stateCurrent <= STATE_UNINITIALIZED;

      statusReceivedCurrent <= '0';
      counterCurrent <= 0;
      symbolsTransmittedCurrent <= 0;
      
      frameStateCurrent <= FRAME_START;
      ackIdCurrent <= (others => '0');
      ackIdWindowCurrent <= (others => '0');
      bufferStatusCurrent <= (others => '0');
    elsif (clk'event and clk = '1') then
      stateCurrent <= stateNext;

      statusReceivedCurrent <= statusReceivedNext;
      counterCurrent <= counterNext;
      symbolsTransmittedCurrent <= symbolsTransmittedNext;
      
      frameStateCurrent <= frameStateNext;
      ackIdCurrent <= ackIdNext;
      ackIdWindowCurrent <= ackIdWindowNext;
      bufferStatusCurrent <= bufferStatusNext;
    end if;
  end process;
    
  -----------------------------------------------------------------------------
  -- Main outbound symbol handler, combinatorial part.
  -----------------------------------------------------------------------------
  process(stateCurrent,
          statusReceivedCurrent, counterCurrent,
          symbolsTransmittedCurrent,
          frameStateCurrent, ackIdCurrent, ackIdWindowCurrent, bufferStatusCurrent,
          txControlStype0, txControlParameter0, txControlParameter1,
          rxControlStype0, rxControlParameter0, rxControlParameter1,
          portEnable_i,
          localAckIdWrite_i, clrOutstandingAckId_i,
          outstandingAckId_i, outboundAckId_i,
          txFull_i,
          txControlEmpty_i, txControlSymbol_i,
          rxControlEmpty_i, rxControlSymbol_i,
          portInitialized_i, linkInitialized_i, ackIdStatus_i,
          readFrameEmpty_i, readFrameAborted_i,
          readWindowEmpty_i,
          readContentEmpty_i, readContentEnd_i, readContentData_i,
          timeoutExpired)
  begin
    stateNext <= stateCurrent;
    statusReceivedNext <= statusReceivedCurrent;
    counterNext <= counterCurrent;
    symbolsTransmittedNext <= symbolsTransmittedCurrent;
    
    frameStateNext <= frameStateCurrent;
    ackIdNext <= ackIdCurrent;
    ackIdWindowNext <= ackIdWindowCurrent;
    bufferStatusNext <= bufferStatusCurrent;
    
    txControlUpdate_o <= '0';
    rxControlUpdate_o <= '0';

    readFrame_o <= '0';
    readFrameRestart_o <= '0';
    readWindowReset_o <= '0';
    readWindowNext_o <= '0';
    readContent_o <= '0';

    symbolWrite <= '0';
    symbolType <= (others=>'U');
    stype0 <= (others=>'U');
    parameter0 <= (others=>'U');
    parameter1 <= (others=>'U');
    stype1 <= (others=>'U');
    cmd <= (others=>'U');
    symbolData <= (others=>'U');
    
    timeoutWrite <= '0';
    timeoutAddress <= (others=>'U');

    outstandingAckId_o <= std_logic_vector(ackIdCurrent);
    outboundAckId_o <= std_logic_vector(ackIdWindowCurrent);
    
    -- Check if a localAckIdWrite is active.
    if (localAckIdWrite_i = '1') then
      -- A localAckIdWrite is active.

      -- Check if all outstanding packets should be discarded.
      if (clrOutstandingAckId_i = '1') then
        -- Delete all outbound packets.
        -- REMARK: Remove all packets in another way... what if uninitialized???
        stateNext <= STATE_RECOVER;
      end if;

      -- Set ackIds.
      ackIdNext <= unsigned(outstandingAckId_i);
      ackIdWindowNext <= unsigned(outboundAckId_i);
    else
      -- A localAckIdWrite is not active.

      -- Act on the current state.
      case (stateCurrent) is

        when STATE_UNINITIALIZED =>
          -----------------------------------------------------------------------
          -- This state is entered at startup. A port that is not initialized
          -- should only transmit idle sequences.
          -----------------------------------------------------------------------
          
          -- Check if the port is initialized.
          if (portInitialized_i = '0') then
            -- Port not initialized.

            -- Check if any new symbols from the link partner has been received.
            if (txControlEmpty_i = '0') then
              -- New symbols have been received.
              -- Discard all new symbols in this state.
              txControlUpdate_o <= '1';
            else
              -- No new symbols from the link partner.
              -- Dont do anything.
            end if;

            -- Check if any new symbols should be transmitted to the link partner.
            if (rxControlEmpty_i = '0') then
              -- New symbols should be transmitted.
              -- Do not forward any symbols in this state.
              rxControlUpdate_o <= '1';
            else
              -- No new symbols to transmit.
              -- Dont do anything.
            end if;

            -- Check if a new symbol should be transmitted.
            if (txFull_i = '0') then
              -- A new symbol should be transmitted.

              -- Send idle sequence.
              symbolWrite <= '1';
              symbolType <= SYMBOL_IDLE;
            else
              -- The outbound fifo is full.
              -- Dont do anything.
            end if;

            -- Check if a new full packet is ready.
            if (readFrameEmpty_i = '0') then
              -- A new full packet is ready.
              -- It is not possible to send the packet now. If the packet is not
              -- discarded it might congest the full system if the link does not
              -- go initialized. To avoid a congested switch, the packet is
              -- discarded and will have to be resent by the source when the link
              -- is up and running.
              readFrame_o <= '1';
            else
              -- No new full packets are ready.
              -- Dont do anything.
            end if;
          else
            -- Port is initialized.
            
            -- Go to the initialized state and reset the counters.
            statusReceivedNext <= '0';
            counterNext <= NUMBER_STATUS_TRANSMIT;
            symbolsTransmittedNext <= 0;
            stateNext <= STATE_PORT_INITIALIZED;
          end if;
          
        when STATE_PORT_INITIALIZED =>
          -----------------------------------------------------------------------
          -- The specification requires a status control symbol being sent at
          -- least every 1024 code word until an error-free status has been
          -- received. This implies that at most 256 idle sequences should be
          -- sent in between status control symbols. Once an error-free status has
          -- been received, status symbols may be sent more rapidly. At least 15
          -- statuses has to be transmitted once an error-free status has been
          -- received.
          ---------------------------------------------------------------------

          -- Check if the port is initialized.
          if (portInitialized_i = '1') then
            -- Port is initialized.

            -- Check if we are ready to change state to linkInitialized.
            if ((linkInitialized_i = '1') and (counterCurrent = 0)) then
              -- Receiver has received enough error free status symbols and we have
              -- transmitted enough.

              -- Initialize framing before entering the normal state.
              ackIdWindowNext <= ackIdCurrent;
              frameStateNext <= FRAME_START;
              readWindowReset_o <= '1';
              
              -- Considder the link initialized.
              stateNext <= STATE_NORMAL;
            else
              -- Not ready to change state to linkInitialized.
              -- Dont do anything.
            end if;
            
            -- Check if any new symbols from the link partner has been received.
            if (txControlEmpty_i = '0') then
              -- New symbols have been received.

              -- Check if the new symbol is a status.
              if (txControlStype0 = STYPE0_STATUS) then
                -- A new status control symbol has been received.
                statusReceivedNext <= '1';
                
                -- Set the ackId and the linkpartner buffer status to what is indicated
                -- in the received control symbol.
                ackIdNext <= unsigned(txControlParameter0);
                bufferStatusNext <= txControlParameter1;
              else
                -- Did not receive a status control symbol.
                -- Discard it.
              end if;

              -- Update to the next control symbol received by the receiver.
              txControlUpdate_o <= '1';
            else
              -- No new symbols from the link partner.
              -- Dont do anything.
            end if;

            -- Check if any new symbols should be transmitted to the link partner.
            if (rxControlEmpty_i = '0') then
              -- New symbols should be transmitted.
              -- Do not forward any symbols in this state.
              rxControlUpdate_o <= '1';
            else
              -- No new symbols to transmit.
              -- Dont do anything.
            end if;

            -- Check if a new symbol may be transmitted.
            if (txFull_i = '0') then
              -- A new symbol can be transmitted.

              -- Check if idle sequence or a status symbol should be transmitted.
              if (((statusReceivedCurrent = '0') and (symbolsTransmittedCurrent = 255)) or
                  ((statusReceivedCurrent = '1') and (symbolsTransmittedCurrent > 15))) then
                -- A status symbol should be transmitted.
                
                -- Send a status control symbol to the link partner.
                symbolWrite <= '1';
                symbolType <= SYMBOL_CONTROL;
                stype0 <= STYPE0_STATUS;
                parameter0 <= ackIdStatus_i;
                parameter1 <= "11111";
                stype1 <= STYPE1_NOP;
                cmd <= "000";

                -- Reset idle sequence transmission counter.
                symbolsTransmittedNext <= 0;

                -- Check if the number of transmitted statuses should be updated.
                if (statusReceivedCurrent = '1') and (counterCurrent /= 0) then
                  counterNext <= counterCurrent - 1;
                end if;
              else
                -- A idle sequence should be transmitted.
                symbolWrite <= '1';
                symbolType <= SYMBOL_IDLE;

                -- Increment the idle sequence transmission counter.
                symbolsTransmittedNext <= symbolsTransmittedCurrent + 1;
              end if;
            else
              -- Cannot send a new symbol.
              -- Dont do anything.
            end if;
          else
            -- Go back to the uninitialized state.
            stateNext <= STATE_UNINITIALIZED;
          end if;
          
        when STATE_NORMAL =>
          -------------------------------------------------------------------
          -- This state is the normal state. It relays frames and handle flow
          -- control.
          -------------------------------------------------------------------
          
          -- Check that both the port and link is initialized.
          if (portInitialized_i = '1') and (linkInitialized_i = '1') then
            -- The port and link is initialized.
            
            -- Check if any control symbol has been received from the link
            -- partner.
            if (txControlEmpty_i = '0') then
              -- A control symbol has been received.

              -- Check the received control symbol.
              case txControlStype0 is
                
                when STYPE0_STATUS =>
                  -- Save the number of buffers in the link partner.
                  bufferStatusNext <= txControlParameter1;
                  
                when STYPE0_PACKET_ACCEPTED =>
                  -- The link partner is accepting a frame.

                  -- Save the number of buffers in the link partner.
                  bufferStatusNext <= txControlParameter1;
                  
                  -- Check if expecting this type of reply and that the ackId is
                  -- expected.
                  if ((ackIdCurrent /= ackIdWindowCurrent) and
                      (ackIdCurrent = unsigned(txControlParameter0))) then
                    -- The packet-accepted is expected and the ackId is the expected.
                    -- The frame has been accepted by the link partner.

                    -- Update to a new buffer and increment the ackId.
                    readFrame_o <= '1';
                    ackIdNext <= ackIdCurrent + 1;
                  else
                    -- Unexpected packet-accepted or packet-accepted for
                    -- unexpected ackId.
                    counterNext <= NUMBER_LINK_RESPONSE_RETRIES;
                    stateNext <= STATE_SEND_LINK_REQUEST;
                  end if;
                  
                when STYPE0_PACKET_RETRY =>
                  -- The link partner has asked for a frame retransmission.

                  -- Save the number of buffers in the link partner.
                  bufferStatusNext <= txControlParameter1;

                  -- Check if the ackId is the one expected.
                  if (ackIdCurrent = unsigned(txControlParameter0)) then
                    -- The ackId to retry is expected.
                    -- Go to the output-retry-stopped state.
                    stateNext <= STATE_OUTPUT_RETRY_STOPPED;
                  else
                    -- Unexpected ackId to retry.
                    counterNext <= NUMBER_LINK_RESPONSE_RETRIES;
                    stateNext <= STATE_SEND_LINK_REQUEST;
                  end if;

                when STYPE0_PACKET_NOT_ACCEPTED =>
                  -- Packet was rejected by the link-partner.
                  -- REMARK: Indicate that this has happened to the outside...
                  counterNext <= NUMBER_LINK_RESPONSE_RETRIES;
                  stateNext <= STATE_SEND_LINK_REQUEST;
                  
                when STYPE0_LINK_RESPONSE =>
                  -- Dont expect or need a link-response in this state.
                  -- Discard it.
                  
                when STYPE0_VC_STATUS =>
                  -- Not supported.
                  -- Discard it.
                  
                when STYPE0_RESERVED =>
                  -- Not supported.
                  -- Discard it.

                when STYPE0_IMPLEMENTATION_DEFINED =>
                  -- Not supported.
                  -- Discard it.
                  
                when others =>
                  null;
              end case;

              -- Indicate the control symbol has been processed.
              txControlUpdate_o <= '1';          
            else
              -- No control symbol has been received.
              
              -- Check if the oldest frame timeout has expired.
              if ((ackIdCurrent /= ackIdWindowCurrent) and
                  (timeoutExpired = '1')) then
                -- There has been a timeout on a transmitted frame.
                
                -- Send link-request.
                counterNext <= NUMBER_LINK_RESPONSE_RETRIES;
                stateNext <= STATE_SEND_LINK_REQUEST;
              else
                -- There has been no timeout.
                
                -- Check if the outbound fifo needs new data.
                if (txFull_i = '0') then
                  -- There is room available in the outbound FIFO.

                  -- Check if there are any events from the receiver.
                  if (rxControlEmpty_i = '0') then
                    -- A symbol from the receiver should be transmitted.

                    -- Send the receiver symbol and a NOP.
                    -- REMARK: Combine this symbol with an STYPE1 to more effectivly
                    -- utilize the link.
                    symbolWrite <= '1';
                    symbolType <= SYMBOL_CONTROL;
                    stype0 <= rxControlStype0;
                    parameter0 <= rxControlParameter0;
                    parameter1 <= rxControlParameter1;
                    stype1 <= STYPE1_NOP;
                    cmd <= "000";

                    -- Remove the symbol from the fifo.
                    rxControlUpdate_o <= '1';

                    -- Check if the transmitted symbol contains status about
                    -- available buffers.
                    if ((rxControlStype0 = STYPE0_PACKET_ACCEPTED) or
                        (rxControlStype0 = STYPE0_PACKET_RETRY)) then
                      -- A symbol containing the bufferStatus has been sent.
                      symbolsTransmittedNext <= 0;
                    else
                      -- A symbol not containing the bufferStatus has been sent.
                      -- REMARK: symbolsTransmitted might overflow...
                      symbolsTransmittedNext <= symbolsTransmittedCurrent + 1;
                    end if;
                  else
                    -- No events from the receiver.

                    -- Check if a status symbol must be sent.
                    if (symbolsTransmittedCurrent = 255) then
                      -- A status symbol must be sent.
                      
                      -- Reset the number of transmitted symbols between statuses.
                      symbolsTransmittedNext <= 0;
                      
                      -- Send status.
                      symbolWrite <= '1';
                      symbolType <= SYMBOL_CONTROL;
                      stype0 <= STYPE0_STATUS;
                      parameter0 <= ackIdStatus_i;
                      parameter1 <= "11111";
                      stype1 <= STYPE1_NOP;
                      cmd <= "000";
                    else
                      -- A status symbol does not have to be sent.
                      
                      -- Check if a frame transfer is in progress.
                      case frameStateCurrent is
                        
                        when FRAME_START =>
                          ---------------------------------------------------------------
                          -- No frame has been started.
                          ---------------------------------------------------------------

                          -- Wait for a new frame to arrive from the frame buffer,
                          -- for new buffers to be available at the link-partner
                          -- and also check that a maximum 31 frames are outstanding.
                          if ((readWindowEmpty_i = '0') and (bufferStatusCurrent /= "00000") and
                              ((ackIdWindowCurrent - ackIdCurrent) /= 31)) then
                            -- New data is available for transmission and there
                            -- is room to receive it at the other side.
                            
                            -- Indicate that a control symbol has been sent to start the
                            -- transmission of the frame.
                            frameStateNext <= FRAME_CHECK;

                            -- Update the output from the frame buffer to contain the
                            -- data when it is read later.
                            readContent_o <= '1';
                          else
                            -- There are no frame data to send or the link partner has
                            -- no available buffers.
                            
                            -- Send idle-sequence.
                            symbolWrite <= '1';
                            symbolType <= SYMBOL_IDLE;

                            -- A symbol not containing the buffer status has been sent.
                            symbolsTransmittedNext <= symbolsTransmittedCurrent + 1;
                          end if;

                        when FRAME_CHECK =>
                          -------------------------------------------------------
                          -- Check if we are allowed to transmit this packet.
                          -------------------------------------------------------
                          
                          -- Check if this packet is allowed to be transmitted.
                          if ((portEnable_i = '1') or (readContentData_i(19 downto 16) = FTYPE_MAINTENANCE_CLASS)) then
                            -- The packet may be transmitted.
                            
                            -- Indicate that a control symbol has been sent to start the
                            -- transmission of the frame.
                            frameStateNext <= FRAME_ACKID;
                            
                            -- Send a control symbol to start the packet and a status to complete
                            -- the symbol.
                            symbolWrite <= '1';
                            symbolType <= SYMBOL_CONTROL;
                            stype0 <= STYPE0_STATUS;
                            parameter0 <= ackIdStatus_i;
                            parameter1 <= "11111";
                            stype1 <= STYPE1_START_OF_PACKET;
                            cmd <= "000";

                            -- A symbol containing the bufferStatus has been sent.
                            symbolsTransmittedNext <= 0;
                          else
                            -- The packet should be discarded.

                            -- Check that there are no outstanding packets that
                            -- has not been acknowledged.
                            if(ackIdWindowCurrent /= ackIdCurrent) then
                              -- There are packets that has not been acknowledged.
                              
                              -- Send idle-sequence.
                              symbolWrite <= '1';
                              symbolType <= SYMBOL_IDLE;

                              -- A symbol not containing the buffer status has been sent.
                              symbolsTransmittedNext <= symbolsTransmittedCurrent + 1;
                            else
                              -- No unacknowledged packets.
                              -- It is now safe to remove the unallowed frame.
                              readFrame_o <= '1';

                              -- Go back and send a new frame.
                              frameStateNext <= FRAME_START;
                            end if;
                          end if;
                          
                        when FRAME_ACKID =>
                          ---------------------------------------------------------------
                          -- Send the first packet content containing our current
                          -- ackId.
                          ---------------------------------------------------------------

                          -- Write a new data symbol and fill in our ackId on the
                          -- packet.
                          symbolWrite <= '1';
                          symbolType <= SYMBOL_DATA;
                          symbolData <= std_logic_vector(ackIdWindowCurrent) & "0" & readContentData_i(25 downto 0);

                          -- Continue to send the rest of the body of the packet.
                          readContent_o <= '1';
                          frameStateNext <= FRAME_BODY;
                          
                          -- A symbol not containing the buffer status has been sent.
                          symbolsTransmittedNext <= symbolsTransmittedCurrent + 1;
                          
                        when FRAME_BODY =>
                          ---------------------------------------------------------------
                          -- The frame has not been fully sent.
                          -- Send a data symbol.
                          ---------------------------------------------------------------
                          -- REMARK: Add support for partial frames...
                          
                          -- Check if the frame is ending.
                          if (readContentEnd_i = '0') then
                            -- The frame is not ending.

                            -- Write a new data symbol.
                            symbolWrite <= '1';
                            symbolType <= SYMBOL_DATA;
                            symbolData <= readContentData_i;

                            -- Continue to send the rest of the body of the packet.
                            readContent_o <= '1';

                            -- A symbol not containing the buffer status has been sent.
                            symbolsTransmittedNext <= symbolsTransmittedCurrent + 1;
                          else
                            -- The frame is ending.

                            -- Update the window to the next frame.
                            -- It takes one tick for the output from the frame
                            -- buffer to get updated.
                            readWindowNext_o <= '1';

                            -- Proceed to check if there is another frame to start
                            -- with directly.
                            frameStateNext <= FRAME_END;                        
                          end if;
                          
                        when FRAME_END =>
                          ---------------------------------------------------------------
                          -- A frame has ended and the window has been updated.
                          -- Check if the next symbol should end the frame or if a
                          -- new one should be started.
                          ---------------------------------------------------------------

                          -- Check if there is a new frame pending.
                          if (readWindowEmpty_i = '1') then
                            -- No new frame is pending.
                            
                            -- Send a control symbol to end the packet.
                            symbolWrite <= '1';
                            symbolType <= SYMBOL_CONTROL;
                            stype0 <= STYPE0_STATUS;
                            parameter0 <= ackIdStatus_i;
                            parameter1 <= "11111";
                            stype1 <= STYPE1_END_OF_PACKET;
                            cmd <= "000";
                            
                            -- A symbol containing the bufferStatus has been sent.
                            symbolsTransmittedNext <= 0;
                          end if;                        

                          -- Update the window ackId.
                          ackIdWindowNext <= ackIdWindowCurrent + 1;

                          -- Start timeout supervision for transmitted frame.
                          timeoutWrite <= '1';
                          timeoutAddress <= std_logic_vector(ackIdWindowCurrent);

                          -- Start a new frame the next time.
                          frameStateNext <= FRAME_START;
                          
                        when others =>
                          ---------------------------------------------------------------
                          -- 
                          ---------------------------------------------------------------
                          null;
                          
                      end case;
                    end if;
                  end if;
                else
                  -- Wait for new storage in the transmission FIFO to become
                  -- available.
                  -- Dont do anything.
                end if;
              end if;
            end if;
          else
            -- The port or the link has become uninitialized.
            -- Go back to the uninitialized state.
            stateNext <= STATE_UNINITIALIZED;
          end if;

        when STATE_OUTPUT_RETRY_STOPPED =>
          -----------------------------------------------------------------------
          -- This is the output-retry-stopped state described in 5.9.1.5.
          -----------------------------------------------------------------------

          -- Check if the outbound fifo needs new data.
          if (txFull_i = '0') then
            -- There is room available in the outbound FIFO.

            -- Send a restart-from-retry control symbol to acknowledge the restart
            -- of the frame.
            symbolWrite <= '1';
            symbolType <= SYMBOL_CONTROL;
            stype0 <= STYPE0_STATUS;
            parameter0 <= ackIdStatus_i;
            parameter1 <= "11111";
            stype1 <= STYPE1_RESTART_FROM_RETRY;
            cmd <= "000";

            -- Make sure there wont be any timeout before the frame is
            -- starting to be retransmitted.
            timeoutWrite <= '1';
            timeoutAddress <= std_logic_vector(ackIdCurrent);

            -- Restart the frame transmission.
            ackIdWindowNext <= ackIdCurrent;
            frameStateNext <= FRAME_START;
            readWindowReset_o <= '1';

            -- Proceed back to the normal state.
            stateNext <= STATE_NORMAL;
            
            -- A symbol containing the bufferStatus has been sent.
            symbolsTransmittedNext <= 0;
          end if;        
          
        when STATE_SEND_LINK_REQUEST =>
          -----------------------------------------------------------------------
          -- Send a link-request symbol when the transmission fifo is ready. Then
          -- always proceed to the output-error-state.
          -----------------------------------------------------------------------
          
          -- Check if the outbound fifo needs new data.
          if (txFull_i = '0') then
            -- There is room available in the outbound FIFO.

            -- Send a link-request symbol.
            symbolWrite <= '1';
            symbolType <= SYMBOL_CONTROL;
            stype0 <= STYPE0_STATUS;
            parameter0 <= ackIdStatus_i;
            parameter1 <= "11111";
            stype1 <= STYPE1_LINK_REQUEST;
            cmd <= LINK_REQUEST_CMD_INPUT_STATUS;

            -- Write the current timer value.
            timeoutWrite <= '1';
            timeoutAddress <= std_logic_vector(ackIdCurrent);
            
            -- Proceed to the output-error-stopped state.
            stateNext <= STATE_OUTPUT_ERROR_STOPPED;
            
            -- A symbol containing the bufferStatus has been sent.
            symbolsTransmittedNext <= 0;
          end if;
          
        when STATE_OUTPUT_ERROR_STOPPED =>
          -------------------------------------------------------------------
          -- This state is the error stopped state described in 5.13.2.7.
          -------------------------------------------------------------------
          
          -- Check that both the port and link is initialized.
          if (portInitialized_i = '1') and (linkInitialized_i = '1') then
            -- The port and link is initialized.
            
            -- Check if any control symbol has been received from the link
            -- partner.
            if (txControlEmpty_i = '0') then
              -- A control symbol has been received.

              -- Check the received control symbol.
              case txControlStype0 is
                
                when STYPE0_PACKET_ACCEPTED =>
                  -- Wait for a link-response.
                  -- Discard these.

                when STYPE0_PACKET_RETRY =>
                  -- Wait for a link-response.
                  -- Discard these.
                  
                when STYPE0_PACKET_NOT_ACCEPTED =>
                  -- Wait for a link-response.
                  -- Discard these.

                when STYPE0_STATUS =>
                  -- Wait for a link-response.
                  -- Discard these.
                  
                when STYPE0_LINK_RESPONSE =>
                  -- Check if the link partner return value is acceptable.
                  if ((unsigned(txControlParameter0) - ackIdCurrent) <=
                      (ackIdWindowCurrent - ackIdCurrent)) then
                    -- Recoverable error.
                    -- Use the received ackId and recover by removing packets
                    -- that were received by the link-partner.
                    ackIdWindowNext <= unsigned(txControlParameter0);
                    stateNext <= STATE_RECOVER;
                  else
                    -- Totally out of sync.
                    stateNext <= STATE_FATAL_ERROR;
                  end if;
                  
                when STYPE0_VC_STATUS =>
                  -- Not supported.
                  
                when STYPE0_RESERVED =>
                  -- Not supported.

                when STYPE0_IMPLEMENTATION_DEFINED =>
                  -- Not supported.
                  
                when others =>
                  null;
              end case;

              -- Indicate the control symbol has been processed.
              txControlUpdate_o <= '1';          
            else
              -- No control symbol has been received.
              
              -- Check if the timeout for a link-response has expired.
              if (timeoutExpired = '1') then
                -- There was no reply on the link-request.
                
                -- Count the number of retransmissions and abort if
                -- no reply has been received for too many times.
                if (counterCurrent /= 0) then
                  -- Not sent link-request too many times.
                  
                  -- Send another link-request.
                  counterNext <= counterCurrent - 1;
                  stateNext <= STATE_SEND_LINK_REQUEST;
                else
                  -- No response for too many times.
                  stateNext <= STATE_FATAL_ERROR;
                end if;
              else
                -- There has been no timeout.
                
                -- Check if the outbound fifo needs new data.
                if (txFull_i = '0') then
                  -- There is room available in the outbound FIFO.

                  -- Check if there are any events from the receiver.
                  if (rxControlEmpty_i = '0') then
                    -- A symbol from the receiver should be transmitted.

                    -- Send the receiver symbol and a NOP.
                    symbolWrite <= '1';
                    symbolType <= SYMBOL_CONTROL;
                    stype0 <= rxControlStype0;
                    parameter0 <= rxControlParameter0;
                    parameter1 <= rxControlParameter1;
                    stype1 <= STYPE1_NOP;
                    cmd <= "000";

                    -- Remove the symbol from the fifo.
                    rxControlUpdate_o <= '1';

                    -- Check if the transmitted symbol contains status about
                    -- available buffers.
                    -- The receiver never send any status so that does not have
                    -- to be checked.
                    if ((rxControlStype0 = STYPE0_PACKET_ACCEPTED) or
                        (rxControlStype0 = STYPE0_PACKET_RETRY)) then
                      -- A symbol containing the bufferStatus has been sent.
                      symbolsTransmittedNext <= 0;
                    else
                      -- A symbol not containing the buffer status has been sent.
                      symbolsTransmittedNext <= symbolsTransmittedCurrent + 1;
                    end if;
                  else
                    -- No events from the receiver.
                    -- There are no frame data to send or the link partner has
                    -- no available buffers.

                    -- Check if a status symbol must be sent.
                    if (symbolsTransmittedCurrent = 255) then
                      -- A status symbol must be sent.
                      
                      -- Reset the number of transmitted symbols between statuses.
                      symbolsTransmittedNext <= 0;
                      
                      -- Send status.
                      symbolWrite <= '1';
                      symbolType <= SYMBOL_CONTROL;
                      stype0 <= STYPE0_STATUS;
                      parameter0 <= ackIdStatus_i;
                      parameter1 <= "11111";
                      stype1 <= STYPE1_NOP;
                      cmd <= "000";
                    else
                      -- A status symbol does not have to be sent.
                      
                      -- Send idle-sequence.
                      symbolWrite <= '1';
                      symbolType <= SYMBOL_IDLE;
                      
                      -- A symbol not containing the buffer status has been sent.
                      symbolsTransmittedNext <= symbolsTransmittedCurrent + 1;
                    end if;
                  end if;
                else
                  -- Wait for new storage in the transmission FIFO to become
                  -- available.
                  -- Dont do anything.
                end if;
              end if;
            end if;
          else
            -- The port or the link has become uninitialized.
            -- Go back to the uninitialized state.
            stateNext <= STATE_UNINITIALIZED;
          end if;

        when STATE_RECOVER =>
          -----------------------------------------------------------------------
          -- A recoverable error condition has occurred.
          -- When this state is entered, ackIdWindow should contain the ackId to
          -- proceed with.
          -----------------------------------------------------------------------

          -- Check if the expected ackId has incremented enough.
          if (ackIdCurrent /= ackIdWindowCurrent) then
            -- Remove this frame. It has been received by the link-partner.
            readFrame_o <= '1';
            ackIdNext <= ackIdCurrent + 1;
          else
            -- Keep this frame.
            -- Restart the window and the frame transmission.
            frameStateNext <= FRAME_START;
            readWindowReset_o <= '1';
            stateNext <= STATE_NORMAL;
          end if;

        when STATE_FATAL_ERROR =>
          -----------------------------------------------------------------------
          -- A fatal error condition has occurred.
          -----------------------------------------------------------------------

          -- Reset the window and resynchronize the link.
          -- REMARK: Count these situations...
          -- REMARK: Do something else here???
          readWindowReset_o <= '1';
          stateNext <= STATE_UNINITIALIZED;
          
        when others =>
          -------------------------------------------------------------------
          --
          -------------------------------------------------------------------
          null;
      end case;
    end if;
  end process;  

end architecture;



-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rio_common.all;


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
entity RioReceiver is
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    -- Status signals used for maintenance.
    portEnable_i : in std_logic;

    -- Support for localAckIdCSR.
    localAckIdWrite_i : in std_logic;
    inboundAckId_i : in std_logic_vector(4 downto 0);
    inboundAckId_o : out std_logic_vector(4 downto 0);
    
    -- Port input interface.
    portInitialized_i : in std_logic;
    rxEmpty_i : in std_logic;
    rxRead_o : out std_logic;
    rxControl_i : in std_logic_vector(1 downto 0);
    rxData_i : in std_logic_vector(31 downto 0);

    -- Receiver has received a control symbol containing:
    -- packet-accepted, packet-retry, packet-not-accepted, 
    -- status, VC_status, link-response
    txControlWrite_o : out std_logic;
    txControlSymbol_o : out std_logic_vector(12 downto 0);

    -- Reciever wants to signal the link partner:
    -- a new frame has been accepted => packet-accepted(rxAckId, bufferStatus)
    -- a frame needs to be retransmitted due to buffering =>
    -- packet-retry(rxAckId, bufferStatus)
    -- a frame is rejected due to errors => packet-not-accepted
    -- a link-request should be answered => link-response
    rxControlWrite_o : out std_logic;
    rxControlSymbol_o : out std_logic_vector(12 downto 0);

    -- Status signals used internally.
    ackIdStatus_o : out std_logic_vector(4 downto 0);
    linkInitialized_o : out std_logic;

    -- Frame buffering interface.
    writeFrameFull_i : in std_logic;
    writeFrame_o : out std_logic;
    writeFrameAbort_o : out std_logic;
    writeContent_o : out std_logic;
    writeContentData_o : out std_logic_vector(31 downto 0));
end entity;


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
architecture RioReceiverImpl of RioReceiver is

  component Crc5ITU is
    port(
      d_i : in  std_logic_vector(18 downto 0);
      crc_o : out std_logic_vector(4 downto 0));
  end component;

  component Crc16CITT is
    port(
      d_i : in  std_logic_vector(15 downto 0);
      crc_i : in  std_logic_vector(15 downto 0);
      crc_o : out std_logic_vector(15 downto 0));
  end component;

  type StateType is (STATE_UNINITIALIZED, STATE_PORT_INITIALIZED,
                     STATE_NORMAL,
                     STATE_INPUT_RETRY_STOPPED, STATE_INPUT_ERROR_STOPPED);
  signal state : StateType;
  
  signal statusCounter : natural range 0 to 8;

  signal ackId : unsigned(4 downto 0);
  signal frameIndex : natural range 0 to 70;

  signal stype0 : std_logic_vector(2 downto 0);
  signal parameter0 : std_logic_vector(4 downto 0);
  signal parameter1 : std_logic_vector(4 downto 0);
  signal stype1 : std_logic_vector(2 downto 0);
  signal cmd : std_logic_vector(2 downto 0);

  signal crc5 : std_logic_vector(4 downto 0);
  signal crc5Calculated : std_logic_vector(4 downto 0);

  signal crc16Valid : std_logic;
  signal crc16Data : std_logic_vector(31 downto 0);
  signal crc16Current : std_logic_vector(15 downto 0);
  signal crc16Temp : std_logic_vector(15 downto 0);
  signal crc16Next : std_logic_vector(15 downto 0);
  
  signal rxRead : std_logic;
  
begin

  linkInitialized_o <= '0' when ((state = STATE_UNINITIALIZED) or
                                 (state = STATE_PORT_INITIALIZED)) else '1';
  ackIdStatus_o <= std_logic_vector(ackId);
  
  -----------------------------------------------------------------------------
  -- Get the entries in a control symbol.
  -----------------------------------------------------------------------------

  stype0 <= rxData_i(31 downto 29);
  parameter0 <= rxData_i(28 downto 24);
  parameter1 <= rxData_i(23 downto 19);
  stype1 <= rxData_i(18 downto 16);
  cmd <= rxData_i(15 downto 13);
  crc5 <= rxData_i(12 downto 8);

  -----------------------------------------------------------------------------
  -- Entity for CRC-5 calculation on control symbols according to the standard.
  -----------------------------------------------------------------------------

  Crc5Calculator: Crc5ITU 
    port map(
      d_i=>rxData_i(31 downto 13), crc_o=>crc5Calculated);

  -----------------------------------------------------------------------------
  -- Entities for CRC-16 calculation on 32-bit data in frames according to the
  -- standard.
  -----------------------------------------------------------------------------

  -- If the CRC is correct, there is either zero in crc16Next if no pad exists
  -- or zero in crc16Temp and crc16Data(15 downto 0). This means that crc16Next
  -- will always be zero here if the CRC is correct.
  crc16Valid <= '1' when (crc16Next = x"0000") else '0';

  Crc16High: Crc16CITT
    port map(
      d_i=>crc16Data(31 downto 16), crc_i=>crc16Current, crc_o=>crc16Temp);
  Crc16Low: Crc16CITT
    port map(
      d_i=>crc16Data(15 downto 0), crc_i=>crc16Temp, crc_o=>crc16Next);

  -----------------------------------------------------------------------------
  -- Main inbound symbol handler.
  -----------------------------------------------------------------------------
  rxRead_o <= rxRead;
  inboundAckId_o <= std_logic_vector(ackId);
  process(areset_n, clk)
  begin
    if (areset_n = '0') then
      state <= STATE_UNINITIALIZED;
      
      rxRead <= '0';
      txControlWrite_o <= '0';
      txControlSymbol_o <= (others => '0');
      rxControlWrite_o <= '0';
      rxControlSymbol_o <= (others => '0');

      writeFrame_o <= '0';
      writeFrameAbort_o <= '0';
      writeContent_o <= '0';
      writeContentData_o <= (others => '0');

      -- REMARK: Use frameIndex instead of this...
      statusCounter <= 0;
      
      frameIndex <= 0;
      ackId <= (others => '0');

      crc16Current <= (others => '0');
      crc16Data <= (others => '0');
    elsif (clk'event and clk = '1') then
      rxRead <= '0';
      
      txControlWrite_o <= '0';
      rxControlWrite_o <= '0';
      
      writeFrame_o <= '0';
      writeFrameAbort_o <= '0';
      writeContent_o <= '0';

      -- Check if a locakAckIdWrite is active.
      if (localAckIdWrite_i = '1') then
        -- A localAckIdWrite is active.
        -- Set ackId.
        ackId <= unsigned(inboundAckId_i);
      else
        -- A localAckIdWrite is not active.

        -- Act on the current state.
        case state is
          
          when STATE_UNINITIALIZED =>
            -----------------------------------------------------------------------
            -- This state is entered at startup. A port that is not initialized
            -- should discard all received symbols.
            -----------------------------------------------------------------------
            
            -- Check if the port is initialized.
            if (portInitialized_i = '0') then
              -- Port not initialized.

              -- Check if a new symbol is ready to be read.
              if (rxRead = '0') and (rxEmpty_i = '0') then
                -- New symbol ready.
                -- Discard all received symbols in this state.
                rxRead <= '1';
              else
                -- No new symbol ready to be read.
                -- Dont do anything.
              end if;
            else
              -- Port is initialized.
              
              -- Go to the initialized state and reset the counters.
              state <= STATE_PORT_INITIALIZED;
              statusCounter <= 0;
            end if;

          when STATE_PORT_INITIALIZED =>
            ---------------------------------------------------------------------
            -- The port has been initialized and status control symbols are being
            -- received on the link to check if it is working. Count the number
            -- of error-free status symbols and considder the link initialized
            -- when enough of them has been received. Frames are not allowed
            -- here.
            ---------------------------------------------------------------------
            
            -- Check if the port is initialized.
            if (portInitialized_i = '1') then
              -- Port is initialized.
              
              -- Check if a new symbol is ready to be read.
              if (rxRead = '0') and (rxEmpty_i = '0') then
                -- There is a new symbol to read.

                -- Check the type of symbol.
                if (rxControl_i = SYMBOL_CONTROL) then
                  -- This is a control symbol that is not a packet delimiter.
                  
                  -- Check if the control symbol has a valid checksum.
                  if (crc5Calculated = crc5) then
                    -- The control symbol has a valid checksum.

                    -- Forward the stype0 part of the symbol to the transmitter.
                    txControlWrite_o <= '1';
                    txControlSymbol_o <= stype0 & parameter0 & parameter1;
                    
                    -- Check the stype0 part if we should count the number of
                    -- error-free status symbols.
                    if (stype0 = STYPE0_STATUS) then
                      -- The symbol is a status.

                      -- Check if enough status symbols have been received.
                      if (statusCounter = 7) then
                        -- Enough status symbols have been received.

                        -- Reset all packets.
                        frameIndex <= 0;
                        writeFrameAbort_o <= '1';

                        -- Set the link as initialized.
                        state <= STATE_NORMAL;
                      else
                        -- Increase the number of error-free status symbols that
                        -- has been received.
                        statusCounter <= statusCounter + 1;
                      end if;
                    else
                      -- The symbol is not a status.
                      -- Dont do anything.
                    end if;
                  else
                    -- A control symbol with CRC5 error was recevied.
                    statusCounter <= 0;
                  end if;
                else
                  -- Symbol that is not allowed in this state have been received.
                  -- Discard it.
                end if;
                
                -- Update to the next symbol.
                rxRead <= '1';
              else
                -- No new symbol ready to be read.
                -- Dont do anything.
              end if;
            else
              -- Go back to the uninitialized state.
              state <= STATE_UNINITIALIZED;
            end if;

          when STATE_NORMAL =>
            ---------------------------------------------------------------------
            -- The port has been initialized and enough error free status symbols
            -- have been received. Forward data frames to the frame buffer
            -- interface. This is the normal operational state.
            ---------------------------------------------------------------------
            
            -- Check that the port is initialized.
            if (portInitialized_i = '1') then
              -- The port and link is initialized.
              
              -- Check if a new symbol is ready to be read.
              if (rxRead = '0') and (rxEmpty_i = '0') then
                -- There is a new symbol to read.

                -- Check the type of symbol.
                if (rxControl_i = SYMBOL_CONTROL) then
                  -- This is a control symbol with or without a packet delimiter.
                  
                  -- Check if the control symbol has a valid CRC-5.
                  if (crc5Calculated = crc5) then
                    -- The control symbol is correct.

                    -- Forward the stype0 part of the symbol to the transmitter.
                    txControlWrite_o <= '1';
                    txControlSymbol_o <= stype0 & parameter0 & parameter1;
                    
                    -- Check the stype1 part.
                    case stype1 is
                      
                      when STYPE1_START_OF_PACKET =>
                        -------------------------------------------------------------
                        -- Start the reception of a new frame or end a currently
                        -- ongoing frame.
                        -------------------------------------------------------------
                        
                        -- Check if a frame has already been started.
                        if (frameIndex /= 0) then
                          -- A frame is already started.
                          -- Complete the last frame and start to ackumulate a new one
                          -- and update the ackId.

                          -- Check the CRC-16 and the length of the received frame.
                          if (crc16Valid = '1') and (frameIndex > 3) then
                            -- The CRC-16 is ok.

                            -- Reset the frame index to indicate the frame is started.
                            frameIndex <= 1;
                            
                            -- Update the frame buffer to indicate that the frame has
                            -- been completly received.
                            writeFrame_o <= '1';

                            -- Update ackId.
                            ackId <= ackId + 1;

                            -- Send packet-accepted.
                            -- The buffer status is appended by the transmitter
                            -- when sent to get the latest number.
                            rxControlWrite_o <= '1';
                            rxControlSymbol_o <= STYPE0_PACKET_ACCEPTED & std_logic_vector(ackId) & "11111";
                          else
                            -- The CRC-16 is not ok.

                            -- Make the transmitter send a packet-not-accepted to indicate
                            -- that the received packet contained a CRC error.
                            rxControlWrite_o <= '1';
                            rxControlSymbol_o <= STYPE0_PACKET_NOT_ACCEPTED &
                                                 "00000" &
                                                 PACKET_NOT_ACCEPTED_CAUSE_PACKET_CRC;
                            state <= STATE_INPUT_ERROR_STOPPED;
                          end if;
                        else
                          -- No frame has been started.

                          -- Reset the frame index to indicate the frame is started.
                          frameIndex <= 1;
                        end if;
                        
                      when STYPE1_END_OF_PACKET =>
                        -------------------------------------------------------------
                        -- End the reception of an old frame.
                        -------------------------------------------------------------

                        -- Check the CRC-16 and the length of the received frame.
                        if (crc16Valid = '1') and (frameIndex > 3) then
                          -- The CRC-16 is ok.
                          
                          -- Reset frame reception to indicate that no frame is ongoing.
                          frameIndex <= 0;
                          
                          -- Update the frame buffer to indicate that the frame has
                          -- been completly received.
                          writeFrame_o <= '1';

                          -- Update ackId.
                          ackId <= ackId + 1;

                          -- Send packet-accepted.
                          -- The buffer status is appended by the transmitter
                          -- when sent to get the latest number.
                          rxControlWrite_o <= '1';
                          rxControlSymbol_o <= STYPE0_PACKET_ACCEPTED & std_logic_vector(ackId) & "11111";
                        else
                          -- The CRC-16 is not ok.

                          -- Make the transmitter send a packet-not-accepted to indicate
                          -- that the received packet contained a CRC error.
                          rxControlWrite_o <= '1';
                          rxControlSymbol_o <= STYPE0_PACKET_NOT_ACCEPTED &
                                               "00000" &
                                               PACKET_NOT_ACCEPTED_CAUSE_PACKET_CRC;
                          state <= STATE_INPUT_ERROR_STOPPED;
                        end if;
                        
                      when STYPE1_STOMP =>
                        -------------------------------------------------------------
                        -- Restart the reception of an old frame.
                        -------------------------------------------------------------
                        -- See 5.10 in the standard.
                        
                        -- Make the transmitter send a packet-retry to indicate
                        -- that the packet cannot be accepted.
                        rxControlWrite_o <= '1';
                        rxControlSymbol_o <= STYPE0_PACKET_RETRY & std_logic_vector(ackId) & "11111";

                        -- Enter the input retry-stopped state.
                        state <= STATE_INPUT_RETRY_STOPPED;
                        
                      when STYPE1_RESTART_FROM_RETRY =>
                        -------------------------------------------------------------
                        -- The receiver indicates a restart from a retry sent
                        -- from us.
                        -------------------------------------------------------------
                        -- See 5.10 in the standard.
                        -- Protocol error, this symbol should not be received here since
                        -- we should have been in input-retry-stopped. 
                        
                        -- Send a packet-not-accepted to indicate that a protocol
                        -- error has occurred.
                        rxControlWrite_o <= '1';
                        rxControlSymbol_o <= STYPE0_PACKET_NOT_ACCEPTED &
                                             "00000" &
                                             PACKET_NOT_ACCEPTED_CAUSE_GENERAL_ERROR;
                        state <= STATE_INPUT_ERROR_STOPPED;
                        
                      when STYPE1_LINK_REQUEST =>
                        -------------------------------------------------------------
                        -- Reply to a LINK-REQUEST.
                        -------------------------------------------------------------

                        -- Check the command part.
                        if (cmd = "100") then
                          -- Return input port status command.
                          -- This functions as a link-request(restart-from-error)
                          -- control symbol under error situations.
                          
                          -- Send a link response containing an ok reply.
                          rxControlWrite_o <= '1';
                          rxControlSymbol_o <= STYPE0_LINK_RESPONSE & std_logic_vector(ackId) & "10000";
                        elsif (cmd = "011") then
                          -- Reset device command.
                          -- Discard this.
                        else
                          -- Unsupported command.
                          -- Discard this.
                        end if;
                        
                        -- Abort the frame and reset frame reception.
                        frameIndex <= 0;
                        writeFrameAbort_o <= '1';
                        
                      when STYPE1_MULTICAST_EVENT =>
                        -------------------------------------------------------------
                        -- Multicast symbol.
                        -------------------------------------------------------------
                        -- Discard the symbol.
                        
                      when STYPE1_RESERVED =>
                        -------------------------------------------------------------
                        -- Reserved.
                        -------------------------------------------------------------
                        -- Not supported, dont do anything.
                        
                      when STYPE1_NOP =>
                        -------------------------------------------------------------
                        -- NOP, no operation.
                        -------------------------------------------------------------
                        -- Dont do anything.

                      when others =>
                        -------------------------------------------------------------
                        -- 
                        -------------------------------------------------------------
                        -- NOP, no operation, dont do anything.
                        null;
                        
                    end case;
                  else
                    -- The control symbol contains a crc error.

                    -- Send a packet-not-accepted to indicate that a corrupted
                    -- control-symbol has been received and change state.
                    rxControlWrite_o <= '1';
                    rxControlSymbol_o <= STYPE0_PACKET_NOT_ACCEPTED &
                                         "00000" &
                                         PACKET_NOT_ACCEPTED_CAUSE_CONTROL_CRC;
                    state <= STATE_INPUT_ERROR_STOPPED;
                  end if;
                elsif (rxControl_i = SYMBOL_DATA) then
                  -- This is a data symbol.
                  -- REMARK: Add check for in-the-middle-crc here...
                  
                  -- Check if a frame has been started.
                  -- Index=0 not started
                  -- index=1 started and expecting to receive the first data.
                  -- index=others, the index of the received data.
                  if (frameIndex /= 0) and (frameIndex /= 70) then
                    -- A frame has been started and is not too long.

                    -- Check if the ackId is correct.
                    if (((frameIndex = 1) and (unsigned(rxData_i(31 downto 27)) = ackId)) or
                        (frameIndex /= 1)) then
                      -- This is the first data symbol containing the ackId which
                      -- is matching or receiving the rest of the frame.

                      -- Check if the packet ftype is allowed.
                      -- If the portEnable is deasserted only maintenance
                      -- packets are allowed.
                      if (((frameIndex = 1) and
                           ((portEnable_i = '1') or (rxData_i(19 downto 16) = FTYPE_MAINTENANCE_CLASS))) or
                          (frameIndex /= 1)) then
                        -- The packet is allowed.

                        -- Check if there is buffers available to store the new packet.
                        if(writeFrameFull_i = '0') then
                          -- There is buffering space available to store the new data.
                          
                          -- Write the data to the frame FIFO.
                          writeContent_o <= '1';
                          writeContentData_o <= rxData_i;

                          -- Increment the number of received data symbols.
                          frameIndex <= frameIndex + 1;
                          
                          -- Update the saved crc result with the output from the CRC calculation.
                          if (frameIndex = 1) then
                            -- Note that the ackId should not be included when the CRC
                            -- is calculated.
                            crc16Data <= "000000" & rxData_i(25 downto 0);
                            crc16Current <= (others => '1');
                          else
                            crc16Data <= rxData_i;
                            crc16Current <= crc16Next;
                          end if;
                        else
                          -- The packet buffer is full.
                          -- Let the link-partner resend the packet.
                          rxControlWrite_o <= '1';
                          rxControlSymbol_o <= STYPE0_PACKET_RETRY & std_logic_vector(ackId) & "11111";
                          state <= STATE_INPUT_RETRY_STOPPED;
                        end if;
                      else
                        -- The non-maintenance packets are not allowed.
                        -- Send packet-not-accepted.
                        rxControlWrite_o <= '1';
                        rxControlSymbol_o <=
                          STYPE0_PACKET_NOT_ACCEPTED & "00000" & PACKET_NOT_ACCEPTED_CAUSE_NON_MAINTENANCE_STOPPED;
                        state <= STATE_INPUT_ERROR_STOPPED;
                      end if;
                    else
                      -- The ackId is unexpected.
                      -- Send packet-not-accepted.
                      rxControlWrite_o <= '1';
                      rxControlSymbol_o <=
                        STYPE0_PACKET_NOT_ACCEPTED & "00000" & PACKET_NOT_ACCEPTED_CAUSE_UNEXPECTED_ACKID;
                      state <= STATE_INPUT_ERROR_STOPPED;
                    end if;
                  else
                    -- A frame has not been started or is too long.
                    -- Send packet-not-accepted.
                    rxControlWrite_o <= '1';
                    rxControlSymbol_o <= STYPE0_PACKET_NOT_ACCEPTED & "00000" & PACKET_NOT_ACCEPTED_CAUSE_GENERAL_ERROR;
                    state <= STATE_INPUT_ERROR_STOPPED;
                  end if;
                else
                  -- Idle sequence received.
                  -- Discard these.
                end if;

                -- Update to the next symbol.
                rxRead <= '1';
              else
                -- No new symbol received.
                -- Dont do anything.
              end if;
            else
              -- The port has become uninitialized.
              -- Go back to the uninitialized state.
              state <= STATE_UNINITIALIZED;
            end if;

          when STATE_INPUT_RETRY_STOPPED =>
            ---------------------------------------------------------------------
            -- This state is entered when a frame could not be accepted. All
            -- symbols except restart-from-retry and link-request are discarded.
            -- A restart-from-retry triggers a state change into the normal
            -- link-initialized state.
            ---------------------------------------------------------------------
            
            -- Check that the port is initialized.
            if (portInitialized_i = '1') then
              -- The port and link is initialized.
              
              -- Check if a new symbol is ready to be read.
              if (rxRead = '0') and (rxEmpty_i = '0') then
                -- There is a new symbol to read.

                -- Check the type of symbol.
                if (rxControl_i = SYMBOL_CONTROL) then
                  -- This is a control symbol with or without a packet delimiter.
                  
                  -- Check if the control symbol has a valid CRC-5.
                  if (crc5Calculated = crc5) then
                    -- The control symbol is correct.

                    -- Forward the stype0 part of the symbol to the transmitter.
                    txControlWrite_o <= '1';
                    txControlSymbol_o <= stype0 & parameter0 & parameter1;
                    
                    -- Check the stype1 part.
                    case stype1 is
                      
                      when STYPE1_RESTART_FROM_RETRY =>
                        -------------------------------------------------------------
                        -- The receiver indicates a restart from a retry sent
                        -- from us.
                        -------------------------------------------------------------

                        -- Abort the frame and reset frame reception.
                        frameIndex <= 0;
                        writeFrameAbort_o <= '1';
                        
                        -- Go back to the normal operational state.
                        state <= STATE_NORMAL;
                        
                      when STYPE1_LINK_REQUEST =>
                        -------------------------------------------------------------
                        -- Received a link-request.
                        -------------------------------------------------------------

                        -- Check the command part.
                        if (cmd = "100") then
                          -- Return input port status command.
                          -- This functions as a link-request(restart-from-error)
                          -- control symbol under error situations.
                          
                          -- Send a link response containing an ok reply.
                          rxControlWrite_o <= '1';
                          rxControlSymbol_o <= STYPE0_LINK_RESPONSE & std_logic_vector(ackId) & "00100";
                        elsif (cmd = "011") then
                          -- Reset device command.
                          -- Discard this.
                        else
                          -- Unsupported command.
                          -- Discard this.
                        end if;
                        
                        -- Abort the frame and reset frame reception.
                        frameIndex <= 0;
                        writeFrameAbort_o <= '1';
                        
                        -- Go back to the normal operational state.
                        state <= STATE_NORMAL;
                        
                      when others =>
                        -------------------------------------------------------------
                        -- 
                        -------------------------------------------------------------
                        -- Discard other control symbols.
                        null;
                        
                    end case;
                  else
                    -- The control symbol contains a crc error.

                    -- Send a packet-not-accepted to indicate that a corrupted
                    -- control-symbol has been received and change state.
                    rxControlWrite_o <= '1';
                    rxControlSymbol_o <= STYPE0_PACKET_NOT_ACCEPTED &
                                         "00000" &
                                         PACKET_NOT_ACCEPTED_CAUSE_CONTROL_CRC;
                    state <= STATE_INPUT_ERROR_STOPPED;
                  end if;
                elsif (rxControl_i = SYMBOL_DATA) then
                  -- This is a data symbol.
                  -- Discard all data symbols in this state.
                else
                  -- Idle sequence received.
                  -- Discard other symbols.
                end if;

                -- Update to the next symbol.
                rxRead <= '1';
              else
                -- No new symbol received.
                -- Dont do anything.
              end if;
            else
              -- The port has become uninitialized.
              -- Go back to the uninitialized state.
              state <= STATE_UNINITIALIZED;
            end if;
            
          when STATE_INPUT_ERROR_STOPPED =>
            ---------------------------------------------------------------------
            -- This state is entered when an error situation has occurred. When in this 
            -- state, all symbols should be discarded until a link-request-symbols has 
            -- been received. See section 5.13.2.6 in part 6 of the standard.
            -- Note that it is only the input side of the port that are affected, not the 
            -- output side. Packets may still be transmitted and acknowledges should be 
            -- accepted.
            ---------------------------------------------------------------------
            
            -- Check that the port is initialized.
            if (portInitialized_i = '1') then
              -- The port and link is initialized.
              
              -- Check if a new symbol is ready to be read.
              if (rxRead = '0') and (rxEmpty_i = '0') then
                -- There is a new symbol to read.

                -- Check the type of symbol.
                if (rxControl_i = SYMBOL_CONTROL) then
                  -- This is a control symbol with or without a packet delimiter.
                  
                  -- Check if the control symbol has a valid CRC-5.
                  if (crc5Calculated = crc5) then
                    -- The control symbol is correct.

                    -- Forward the stype0 part of the symbol to the transmitter.
                    txControlWrite_o <= '1';
                    txControlSymbol_o <= stype0 & parameter0 & parameter1;
                    
                    -- Check the stype1 part.
                    case stype1 is
                      
                      when STYPE1_LINK_REQUEST =>
                        -------------------------------------------------------------
                        -- Received a link-request.
                        -------------------------------------------------------------

                        -- Check the command part.
                        -- REMARK: Should also send a status-control-symbol
                        -- directly following this symbol...
                        if (cmd = "100") then
                          -- Return input port status command.
                          -- This functions as a link-request(restart-from-error)
                          -- control symbol under error situations.
                          
                          -- Send a link response containing an ok reply.
                          rxControlWrite_o <= '1';
                          rxControlSymbol_o <= STYPE0_LINK_RESPONSE & std_logic_vector(ackId) & "00101";
                        elsif (cmd = "011") then
                          -- Reset device command.
                          -- Discard this.
                        else
                          -- Unsupported command.
                          -- Discard this.
                        end if;
                        
                        -- Abort the frame and reset frame reception.
                        frameIndex <= 0;
                        writeFrameAbort_o <= '1';
                        
                        -- Go back to the normal operational state.
                        state <= STATE_NORMAL;
                        
                      when others =>
                        -------------------------------------------------------------
                        -- 
                        -------------------------------------------------------------
                        -- Discard other control symbols.
                        null;
                        
                    end case;
                  else
                    -- The control symbol contains a crc error.
                    -- Error is ignored in this state.
                  end if;
                else
                  -- Other symbol received.
                  -- All other symbols are discarded in this state.
                end if;

                -- Update to the next symbol.
                rxRead <= '1';
              else
                -- No new symbol received.
                -- Dont do anything.
              end if;
            else
              -- The port has become uninitialized.
              -- Go back to the uninitialized state.
              state <= STATE_UNINITIALIZED;
            end if;

          when others =>
            ---------------------------------------------------------------------
            -- 
            ---------------------------------------------------------------------
            null;
        end case;
      end if;
    end if;
  end process;

end architecture;



-------------------------------------------------------------------------------
-- A CRC-5 calculator following the implementation proposed in the 2.2
-- standard.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
entity Crc5ITU is
  port(
    d_i : in  std_logic_vector(18 downto 0);
    crc_o : out std_logic_vector(4 downto 0));
end entity;


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
architecture Crc5Impl of Crc5ITU is
  signal d : std_logic_vector(0 to 18);
  signal c : std_logic_vector(0 to 4);

begin
  -- Reverse the bit vector indexes to make them the same as in the standard.
  d(18) <= d_i(0); d(17) <= d_i(1); d(16) <= d_i(2); d(15) <= d_i(3);
  d(14) <= d_i(4); d(13) <= d_i(5); d(12) <= d_i(6); d(11) <= d_i(7);
  d(10) <= d_i(8); d(9) <= d_i(9); d(8) <= d_i(10); d(7) <= d_i(11);
  d(6) <= d_i(12); d(5) <= d_i(13); d(4) <= d_i(14); d(3) <= d_i(15);
  d(2) <= d_i(16); d(1) <= d_i(17); d(0) <= d_i(18);

  -- Calculate the resulting crc.
  c(0) <= d(18) xor d(16) xor d(15) xor d(12) xor
          d(10) xor d(5) xor d(4) xor d(3) xor
          d(1) xor d(0);
  c(1) <= (not d(18)) xor d(17) xor d(15) xor d(13) xor
          d(12) xor d(11) xor d(10) xor d(6) xor
          d(3) xor d(2) xor d(0);
  c(2) <= (not d(18)) xor d(16) xor d(14) xor d(13) xor
          d(12) xor d(11) xor d(7) xor d(4) xor
          d(3) xor d(1);
  c(3) <= (not d(18)) xor d(17) xor d(16) xor d(14) xor
          d(13) xor d(10) xor d(8) xor d(3) xor
          d(2) xor d(1);
  c(4) <= d(18) xor d(17) xor d(15) xor d(14) xor
          d(11) xor d(9) xor d(4) xor d(3) xor
          d(2) xor d(0);

  -- Reverse the bit vector indexes to make them the same as in the standard.
  crc_o(4) <= c(0); crc_o(3) <= c(1); crc_o(2) <= c(2); crc_o(1) <= c(3);
  crc_o(0) <= c(4);
end architecture;
