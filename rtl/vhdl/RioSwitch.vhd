-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- Description
-- Containing RapidIO packet switching functionality contained in the top
-- entity RioSwitch.
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
-- RioSwitch
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.rio_common.all;

-------------------------------------------------------------------------------
-- Entity for RioSwitch.
-------------------------------------------------------------------------------
entity RioSwitch is
  generic(
    SWITCH_PORTS : natural range 3 to 255 := 4;
    DEVICE_IDENTITY : std_logic_vector(15 downto 0);
    DEVICE_VENDOR_IDENTITY : std_logic_vector(15 downto 0);
    DEVICE_REV : std_logic_vector(31 downto 0);
    ASSY_IDENTITY : std_logic_vector(15 downto 0);
    ASSY_VENDOR_IDENTITY : std_logic_vector(15 downto 0);
    ASSY_REV : std_logic_vector(15 downto 0));
  port(
    clk : in std_logic;
    areset_n : in std_logic;
    
    writeFrameFull_i : in Array1(SWITCH_PORTS-1 downto 0);
    writeFrame_o : out Array1(SWITCH_PORTS-1 downto 0);
    writeFrameAbort_o : out Array1(SWITCH_PORTS-1 downto 0);
    writeContent_o : out Array1(SWITCH_PORTS-1 downto 0);
    writeContentData_o : out Array32(SWITCH_PORTS-1 downto 0);

    readFrameEmpty_i : in Array1(SWITCH_PORTS-1 downto 0);
    readFrame_o : out Array1(SWITCH_PORTS-1 downto 0);
    readContent_o : out Array1(SWITCH_PORTS-1 downto 0);
    readContentEnd_i : in Array1(SWITCH_PORTS-1 downto 0);
    readContentData_i : in Array32(SWITCH_PORTS-1 downto 0);

    portLinkTimeout_o : out std_logic_vector(23 downto 0);
    
    linkInitialized_i : in Array1(SWITCH_PORTS-1 downto 0);
    outputPortEnable_o : out Array1(SWITCH_PORTS-1 downto 0);
    inputPortEnable_o : out Array1(SWITCH_PORTS-1 downto 0);

    localAckIdWrite_o : out Array1(SWITCH_PORTS-1 downto 0);
    clrOutstandingAckId_o : out Array1(SWITCH_PORTS-1 downto 0);
    inboundAckId_o : out Array5(SWITCH_PORTS-1 downto 0);
    outstandingAckId_o : out Array5(SWITCH_PORTS-1 downto 0);
    outboundAckId_o : out Array5(SWITCH_PORTS-1 downto 0);
    inboundAckId_i : in Array5(SWITCH_PORTS-1 downto 0);
    outstandingAckId_i : in Array5(SWITCH_PORTS-1 downto 0);
    outboundAckId_i : in Array5(SWITCH_PORTS-1 downto 0);
    
    configStb_o : out std_logic;
    configWe_o : out std_logic;
    configAddr_o : out std_logic_vector(23 downto 0);
    configData_o : out std_logic_vector(31 downto 0);
    configData_i : in std_logic_vector(31 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for RioSwitch.
-------------------------------------------------------------------------------
architecture RioSwitchImpl of RioSwitch is

  component RouteTableInterconnect is
    generic(
      WIDTH : natural range 1 to 256 := 8);
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      stb_i : in Array1(WIDTH-1 downto 0);
      addr_i : in Array16(WIDTH-1 downto 0);
      dataM_o : out Array8(WIDTH-1 downto 0);
      ack_o : out Array1(WIDTH-1 downto 0);

      stb_o : out std_logic;
      addr_o : out std_logic_vector(15 downto 0);
      dataS_i : in std_logic_vector(7 downto 0);
      ack_i : in std_logic);
  end component;
  
  component SwitchPortInterconnect is
    generic(
      WIDTH : natural range 1 to 256 := 8);
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      masterCyc_i : in Array1(WIDTH-1 downto 0);
      masterStb_i : in Array1(WIDTH-1 downto 0);
      masterWe_i : in Array1(WIDTH-1 downto 0);
      masterAddr_i : in Array10(WIDTH-1 downto 0);
      masterData_i : in Array32(WIDTH-1 downto 0);
      masterData_o : out Array1(WIDTH-1 downto 0);
      masterAck_o : out Array1(WIDTH-1 downto 0);

      slaveCyc_o : out Array1(WIDTH-1 downto 0);
      slaveStb_o : out Array1(WIDTH-1 downto 0);
      slaveWe_o : out Array1(WIDTH-1 downto 0);
      slaveAddr_o : out Array10(WIDTH-1 downto 0);
      slaveData_o : out Array32(WIDTH-1 downto 0);
      slaveData_i : in Array1(WIDTH-1 downto 0);
      slaveAck_i : in Array1(WIDTH-1 downto 0));
  end component;
  
  component SwitchPortMaintenance is
    generic(
      SWITCH_PORTS : natural range 0 to 255;
      DEVICE_IDENTITY : std_logic_vector(15 downto 0);
      DEVICE_VENDOR_IDENTITY : std_logic_vector(15 downto 0);
      DEVICE_REV : std_logic_vector(31 downto 0);
      ASSY_IDENTITY : std_logic_vector(15 downto 0);
      ASSY_VENDOR_IDENTITY : std_logic_vector(15 downto 0);
      ASSY_REV : std_logic_vector(15 downto 0));
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      lookupStb_i : in std_logic;
      lookupAddr_i : in std_logic_vector(15 downto 0);
      lookupData_o : out std_logic_vector(7 downto 0);
      lookupAck_o : out std_logic;
      
      masterCyc_o : out std_logic;
      masterStb_o : out std_logic;
      masterWe_o : out std_logic;
      masterAddr_o : out std_logic_vector(9 downto 0);
      masterData_o : out std_logic_vector(31 downto 0);
      masterData_i : in std_logic;
      masterAck_i : in std_logic;

      slaveCyc_i : in std_logic;
      slaveStb_i : in std_logic;
      slaveWe_i : in std_logic;
      slaveAddr_i : in std_logic_vector(9 downto 0);
      slaveData_i : in std_logic_vector(31 downto 0);
      slaveData_o : out std_logic;
      slaveAck_o : out std_logic;

      lookupStb_o : out std_logic;
      lookupAddr_o : out std_logic_vector(15 downto 0);
      lookupData_i : in std_logic_vector(7 downto 0);
      lookupAck_i : in std_logic;

      portLinkTimeout_o : out std_logic_vector(23 downto 0);
      
      linkInitialized_i : in Array1(SWITCH_PORTS-1 downto 0);
      outputPortEnable_o : out Array1(SWITCH_PORTS-1 downto 0);
      inputPortEnable_o : out Array1(SWITCH_PORTS-1 downto 0);
      localAckIdWrite_o : out Array1(SWITCH_PORTS-1 downto 0);
      clrOutstandingAckId_o : out Array1(SWITCH_PORTS-1 downto 0);
      inboundAckId_o : out Array5(SWITCH_PORTS-1 downto 0);
      outstandingAckId_o : out Array5(SWITCH_PORTS-1 downto 0);
      outboundAckId_o : out Array5(SWITCH_PORTS-1 downto 0);
      inboundAckId_i : in Array5(SWITCH_PORTS-1 downto 0);
      outstandingAckId_i : in Array5(SWITCH_PORTS-1 downto 0);
      outboundAckId_i : in Array5(SWITCH_PORTS-1 downto 0);
    
      configStb_o : out std_logic;
      configWe_o : out std_logic;
      configAddr_o : out std_logic_vector(23 downto 0);
      configData_o : out std_logic_vector(31 downto 0);
      configData_i : in std_logic_vector(31 downto 0));
  end component;
  
  component SwitchPort is
    generic(
      PORT_INDEX : natural);
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      masterCyc_o : out std_logic;
      masterStb_o : out std_logic;
      masterWe_o : out std_logic;
      masterAddr_o : out std_logic_vector(9 downto 0);
      masterData_o : out std_logic_vector(31 downto 0);
      masterData_i : in std_logic;
      masterAck_i : in std_logic;

      slaveCyc_i : in std_logic;
      slaveStb_i : in std_logic;
      slaveWe_i : in std_logic;
      slaveAddr_i : in std_logic_vector(9 downto 0);
      slaveData_i : in std_logic_vector(31 downto 0);
      slaveData_o : out std_logic;
      slaveAck_o : out std_logic;

      lookupStb_o : out std_logic;
      lookupAddr_o : out std_logic_vector(15 downto 0);
      lookupData_i : in std_logic_vector(7 downto 0);
      lookupAck_i : in std_logic;

      readFrameEmpty_i : in std_logic;
      readFrame_o : out std_logic;
      readContent_o : out std_logic;
      readContentEnd_i : in std_logic;
      readContentData_i : in std_logic_vector(31 downto 0);
      writeFrameFull_i : in std_logic;
      writeFrame_o : out std_logic;
      writeFrameAbort_o : out std_logic;
      writeContent_o : out std_logic;
      writeContentData_o : out std_logic_vector(31 downto 0));
  end component;

  signal masterLookupStb : Array1(SWITCH_PORTS downto 0);
  signal masterLookupAddr : Array16(SWITCH_PORTS downto 0);
  signal masterLookupData : Array8(SWITCH_PORTS downto 0);
  signal masterLookupAck : Array1(SWITCH_PORTS downto 0);

  signal slaveLookupStb : std_logic;
  signal slaveLookupAddr : std_logic_vector(15 downto 0);
  signal slaveLookupData : std_logic_vector(7 downto 0);
  signal slaveLookupAck : std_logic;
  
  signal masterCyc : Array1(SWITCH_PORTS downto 0);
  signal masterStb : Array1(SWITCH_PORTS downto 0);
  signal masterWe : Array1(SWITCH_PORTS downto 0);
  signal masterAddr : Array10(SWITCH_PORTS downto 0);
  signal masterDataWrite : Array32(SWITCH_PORTS downto 0);
  signal masterDataRead : Array1(SWITCH_PORTS downto 0);
  signal masterAck : Array1(SWITCH_PORTS downto 0);
  
  signal slaveCyc : Array1(SWITCH_PORTS downto 0);
  signal slaveStb : Array1(SWITCH_PORTS downto 0);
  signal slaveWe : Array1(SWITCH_PORTS downto 0);
  signal slaveAddr : Array10(SWITCH_PORTS downto 0);
  signal slaveDataWrite : Array32(SWITCH_PORTS downto 0);
  signal slaveDataRead : Array1(SWITCH_PORTS downto 0);
  signal slaveAck : Array1(SWITCH_PORTS downto 0);

begin

  -----------------------------------------------------------------------------
  -- The routing table interconnect.
  -----------------------------------------------------------------------------
  RouteInterconnect: RouteTableInterconnect
    generic map(
      WIDTH=>SWITCH_PORTS+1)
    port map(
      clk=>clk, areset_n=>areset_n, 
      stb_i=>masterLookupStb, addr_i=>masterLookupAddr, 
      dataM_o=>masterLookupData, ack_o=>masterLookupAck, 
      stb_o=>slaveLookupStb, addr_o=>slaveLookupAddr,
      dataS_i=>slaveLookupData, ack_i=>slaveLookupAck);
  
  -----------------------------------------------------------------------------
  -- The port interconnect.
  -----------------------------------------------------------------------------
  PortInterconnect: SwitchPortInterconnect
    generic map(
      WIDTH=>SWITCH_PORTS+1)
    port map(
      clk=>clk, areset_n=>areset_n, 
      masterCyc_i=>masterCyc, masterStb_i=>masterStb, masterWe_i=>masterWe, masterAddr_i=>masterAddr, 
      masterData_i=>masterDataWrite, masterData_o=>masterDataRead, masterAck_o=>masterAck, 
      slaveCyc_o=>slaveCyc, slaveStb_o=>slaveStb, slaveWe_o=>slaveWe, slaveAddr_o=>slaveAddr, 
      slaveData_o=>slaveDataWrite, slaveData_i=>slaveDataRead, slaveAck_i=>slaveAck);

  -----------------------------------------------------------------------------
  -- Data relaying port instantiation.
  -----------------------------------------------------------------------------
  PortGeneration: for portIndex in 0 to SWITCH_PORTS-1 generate
    PortInst: SwitchPort
      generic map(
        PORT_INDEX=>portIndex)
      port map(
        clk=>clk, areset_n=>areset_n,
        masterCyc_o=>masterCyc(portIndex), masterStb_o=>masterStb(portIndex),
        masterWe_o=>masterWe(portIndex), masterAddr_o=>masterAddr(portIndex),
        masterData_o=>masterDataWrite(portIndex),
        masterData_i=>masterDataRead(portIndex), masterAck_i=>masterAck(portIndex),
        slaveCyc_i=>slaveCyc(portIndex), slaveStb_i=>slaveStb(portIndex),
        slaveWe_i=>slaveWe(portIndex), slaveAddr_i=>slaveAddr(portIndex),
        slaveData_i=>slaveDataWrite(portIndex),
        slaveData_o=>slaveDataRead(portIndex), slaveAck_o=>slaveAck(portIndex),
        lookupStb_o=>masterLookupStb(portIndex),
        lookupAddr_o=>masterLookupAddr(portIndex), 
        lookupData_i=>masterLookupData(portIndex), lookupAck_i=>masterLookupAck(portIndex),
        readFrameEmpty_i=>readFrameEmpty_i(portIndex), readFrame_o=>readFrame_o(portIndex), 
        readContent_o=>readContent_o(portIndex), 
        readContentEnd_i=>readContentEnd_i(portIndex), readContentData_i=>readContentData_i(portIndex), 
        writeFrameFull_i=>writeFrameFull_i(portIndex), writeFrame_o=>writeFrame_o(portIndex), 
        writeFrameAbort_o=>writeFrameAbort_o(portIndex), writeContent_o=>writeContent_o(portIndex), 
        writeContentData_o=>writeContentData_o(portIndex));
  end generate;
  
  -----------------------------------------------------------------------------
  -- Maintenance port instantiation.
  -----------------------------------------------------------------------------
  MaintenancePort: SwitchPortMaintenance
    generic map(
      SWITCH_PORTS=>SWITCH_PORTS,
      DEVICE_IDENTITY=>DEVICE_IDENTITY,
      DEVICE_VENDOR_IDENTITY=>DEVICE_VENDOR_IDENTITY,
      DEVICE_REV=>DEVICE_REV,
      ASSY_IDENTITY=>ASSY_IDENTITY,
      ASSY_VENDOR_IDENTITY=>ASSY_VENDOR_IDENTITY,
      ASSY_REV=>ASSY_REV)
    port map(
      clk=>clk, areset_n=>areset_n, 
      lookupStb_i=>slaveLookupStb, lookupAddr_i=>slaveLookupAddr,
      lookupData_o=>slaveLookupData, lookupAck_o=>slaveLookupAck,
      masterCyc_o=>masterCyc(SWITCH_PORTS), masterStb_o=>masterStb(SWITCH_PORTS),
      masterWe_o=>masterWe(SWITCH_PORTS), masterAddr_o=>masterAddr(SWITCH_PORTS),
      masterData_o=>masterDataWrite(SWITCH_PORTS),
      masterData_i=>masterDataRead(SWITCH_PORTS), masterAck_i=>masterAck(SWITCH_PORTS),
      slaveCyc_i=>slaveCyc(SWITCH_PORTS), slaveStb_i=>slaveStb(SWITCH_PORTS),
      slaveWe_i=>slaveWe(SWITCH_PORTS), slaveAddr_i=>slaveAddr(SWITCH_PORTS),
      slaveData_i=>slaveDataWrite(SWITCH_PORTS),
      slaveData_o=>slaveDataRead(SWITCH_PORTS), slaveAck_o=>slaveAck(SWITCH_PORTS),
      lookupStb_o=>masterLookupStb(SWITCH_PORTS),
      lookupAddr_o=>masterLookupAddr(SWITCH_PORTS),
      lookupData_i=>masterLookupData(SWITCH_PORTS), lookupAck_i=>masterLookupAck(SWITCH_PORTS),
      portLinkTimeout_o=>portLinkTimeout_o,
      linkInitialized_i=>linkInitialized_i,
      outputPortEnable_o=>outputPortEnable_o, inputPortEnable_o=>inputPortEnable_o,
      localAckIdWrite_o=>localAckIdWrite_o, clrOutstandingAckId_o=>clrOutstandingAckId_o, 
      inboundAckId_o=>inboundAckId_o, outstandingAckId_o=>outstandingAckId_o, 
      outboundAckId_o=>outboundAckId_o, inboundAckId_i=>inboundAckId_i, 
      outstandingAckId_i=>outstandingAckId_i, outboundAckId_i=>outboundAckId_i, 
      configStb_o=>configStb_o, configWe_o=>configWe_o, configAddr_o=>configAddr_o,
      configData_o=>configData_o, configData_i=>configData_i);

end architecture;



-------------------------------------------------------------------------------
-- SwitchPort
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for SwitchPort.
-------------------------------------------------------------------------------
entity SwitchPort is
  generic(
    PORT_INDEX : natural);
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    -- Master port signals.
    -- Write frames to other ports.
    masterCyc_o : out std_logic;
    masterStb_o : out std_logic;
    masterWe_o : out std_logic;
    masterAddr_o : out std_logic_vector(9 downto 0);
    masterData_o : out std_logic_vector(31 downto 0);
    masterData_i : in std_logic;
    masterAck_i : in std_logic;

    -- Slave port signals.
    -- Receives frames from other ports.
    slaveCyc_i : in std_logic;
    slaveStb_i : in std_logic;
    slaveWe_i : in std_logic;
    slaveAddr_i : in std_logic_vector(9 downto 0);
    slaveData_i : in std_logic_vector(31 downto 0);
    slaveData_o : out std_logic;
    slaveAck_o : out std_logic;

    -- Address-lookup interface.
    lookupStb_o : out std_logic;
    lookupAddr_o : out std_logic_vector(15 downto 0);
    lookupData_i : in std_logic_vector(7 downto 0);
    lookupAck_i : in std_logic;

    -- Physical port frame buffer interface.
    readFrameEmpty_i : in std_logic;
    readFrame_o : out std_logic;
    readContent_o : out std_logic;
    readContentEnd_i : in std_logic;
    readContentData_i : in std_logic_vector(31 downto 0);
    writeFrameFull_i : in std_logic;
    writeFrame_o : out std_logic;
    writeFrameAbort_o : out std_logic;
    writeContent_o : out std_logic;
    writeContentData_o : out std_logic_vector(31 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for SwitchPort.
-------------------------------------------------------------------------------
architecture SwitchPortImpl of SwitchPort is

  type MasterStateType is (STATE_IDLE,
                           STATE_ERROR,
                           STATE_WAIT_HEADER_0,
                           STATE_READ_HEADER_0,
                           STATE_READ_PORT_LOOKUP,
                           STATE_READ_TARGET_PORT,
                           STATE_WAIT_TARGET_PORT,
                           STATE_WAIT_TARGET_WRITE,
                           STATE_WAIT_COMPLETE);
  signal masterState : MasterStateType;

  type SlaveStateType is (STATE_IDLE, STATE_SEND_ACK);
  signal slaveState : SlaveStateType;
  
  alias ftype : std_logic_vector(3 downto 0) is readContentData_i(19 downto 16);
  alias tt : std_logic_vector(1 downto 0) is readContentData_i(21 downto 20);
  
begin

  -----------------------------------------------------------------------------
  -- Master interface process.
  -----------------------------------------------------------------------------
  Master: process(clk, areset_n)
  begin
    if (areset_n = '0') then
      masterState <= STATE_IDLE;

      lookupStb_o <= '0';
      lookupAddr_o <= (others => '0');
      
      masterCyc_o <= '0';
      masterStb_o <= '0';
      masterWe_o <= '0';
      masterAddr_o <= (others => '0');
      masterData_o <= (others => '0');
      
      readContent_o <= '0';
      readFrame_o <= '0';
    elsif (clk'event and clk = '1') then
      readContent_o <= '0';
      readFrame_o <= '0';

      case masterState is

        when STATE_IDLE =>
          ---------------------------------------------------------------------
          -- Wait for a new packet or content of a new packet.
          ---------------------------------------------------------------------

          -- Reset bus signals.
          masterCyc_o <= '0';
          masterStb_o <= '0';
          
          -- Wait for frame content to be available.
          -- Use different signals to trigger the forwarding of packets depending
          -- on the switch philosofy.
          if (readFrameEmpty_i = '0') then
            readContent_o <= '1';
            masterState <= STATE_WAIT_HEADER_0;
          end if;

        when STATE_WAIT_HEADER_0 =>
          ---------------------------------------------------------------------
          -- Wait for the frame buffer output to be updated.
          ---------------------------------------------------------------------

          -- Wait for frame buffer output to be updated.
          masterState <= STATE_READ_HEADER_0;
          
        when STATE_READ_HEADER_0 =>
          ---------------------------------------------------------------------
          -- Check the FTYPE and forward it to the maintenance port if it is a
          -- maintenance packet. Otherwise, initiate an address lookup and wait
          -- for the result.
          ---------------------------------------------------------------------

          -- Check if the frame has ended.
          if (readContentEnd_i = '0') then
            -- The frame has not ended.
            -- This word contains the header and the source id.

            -- Read the tt-field to check the source and destination id size.
            if (tt = "01") then
              -- This frame contains 16-bit addresses.
              
              -- Read the new content.
              readContent_o <= '1';

              -- Save the content of the header and destination.
              masterData_o <= readContentData_i;

              -- Check if this is a maintenance frame.
              if (ftype = FTYPE_MAINTENANCE_CLASS) then
                -- This is a maintenance frame.

                -- Always route these frames to the maintenance module in the
                -- switch by setting the MSB bit of the port address.
                masterAddr_o <= '1' & std_logic_vector(to_unsigned(PORT_INDEX, 8)) & '0';

                -- Start an access to the maintenance port.
                masterState <= STATE_READ_TARGET_PORT;
              else
                -- This is not a maintenance frame.
                
                -- Lookup the destination address and proceed to wait for the
                -- result.
                lookupStb_o <= '1';
                lookupAddr_o <= readContentData_i(15 downto 0);

                -- Wait for the port lookup to return a result.
                masterState <= STATE_READ_PORT_LOOKUP;
              end if;
            else
              -- Unsupported tt-value, discard the frame.
              readFrame_o <= '1';
              masterState <= STATE_ERROR;
            end if;
          else
            -- End of frame.
            -- The frame is too short to contain a valid frame. Discard it.
            readFrame_o <= '1';
            masterState <= STATE_ERROR;
          end if;

        when STATE_ERROR =>
          ---------------------------------------------------------------------
          -- Wait one tick for the packet buffer to update its outputs. Then
          -- start waiting for a new packet.
          ---------------------------------------------------------------------
          
          masterState <= STATE_IDLE;
          
        when STATE_READ_PORT_LOOKUP =>
          ---------------------------------------------------------------------
          -- Wait for the address lookup to be complete.
          ---------------------------------------------------------------------

          -- Wait for the routing table to complete the request.
          if (lookupAck_i = '1') then
            -- The address lookup is complete.
            
            -- Terminate the lookup cycle.
            lookupStb_o <= '0';

            -- Proceed to read the target port.
            masterAddr_o <= '0' & lookupData_i & '0';
            masterState <= STATE_READ_TARGET_PORT;
          else
            -- Wait until the address lookup is complete.
            -- REMARK: Timeout here???
          end if;

        when STATE_READ_TARGET_PORT =>
          ---------------------------------------------------------------------
          -- Initiate an access to the target port.
          ---------------------------------------------------------------------

          -- Read the status of the target port using the result from the
          -- lookup in the routing table.
          masterCyc_o <= '1';
          masterStb_o <= '1';
          masterWe_o <= '0';
          masterState <= STATE_WAIT_TARGET_PORT;

        when STATE_WAIT_TARGET_PORT =>
          ---------------------------------------------------------------------
          -- Wait to get access to the target port. When the port is ready
          -- check if it is ready to accept a new frame. If it cannot accept a
          -- new frame, terminate the access and go back and start a new one.
          -- This is to free the interconnect to let other ports access it if
          -- it is a shared bus. If the port is ready, initiate a write access
          -- to the selected port.
          ---------------------------------------------------------------------

          -- Wait for the target port to complete the request.
          if (masterAck_i = '1') then
            -- Target port has completed the request.

            -- Check the status of the target port.
            if (masterData_i = '0') then
              -- The target port has empty buffers to receive the frame.

              -- Hold the bus with cyc until the cycle is complete.
              -- Write the first word of the frame to the target port.
              -- The masterData_o has already been assigned.
              masterCyc_o <= '1';
              masterStb_o <= '1';
              masterWe_o <= '1';
              masterAddr_o(0) <= '1';

              -- Change state to transfer the frame.
              masterState <= STATE_WAIT_TARGET_WRITE;
            else
              -- The target port has no empty buffer to receive the frame.
              -- Terminate the cycle and retry later.
              masterCyc_o <= '0';
              masterStb_o <= '0';
              masterState <= STATE_READ_TARGET_PORT;
            end if;
          else
            -- Target port has not completed the request.
            -- Dont to anything.
          end if;

        when STATE_WAIT_TARGET_WRITE =>
          ---------------------------------------------------------------------
          -- Wait for the write access to complete. When complete, write the
          -- next content and update the content to the next. If the frame does
          -- not have any more data ready, terminate the access but keep the
          -- cycle active and proceed to wait for new data.
          ---------------------------------------------------------------------

          -- Wait for the target port to complete the request.
          -- REMARK: Remove the ack-condition, we know that the write takes one
          -- cycle...
          if (masterAck_i = '1') then
            -- The target port is ready.

            -- Check if the frame has ended.
            if (readContentEnd_i = '0') then
              -- The frame has not ended.
              
              -- There are more data to transfer.
              masterData_o <= readContentData_i;
              readContent_o <= '1';
            else
              -- There are no more data to transfer.
              
              -- Update to the next frame.
              readFrame_o <= '1';
              
              -- Tell the target port that the frame is complete.
              masterWe_o <= '1';
              masterAddr_o(0) <= '0';
              masterData_o <= x"00000001";
              
              -- Change state to wait for the target port to finalize the write
              -- of the full frame.
              masterState <= STATE_WAIT_COMPLETE;
            end if;
          else
            -- Wait for the target port to reply.
            -- Dont do anything.
          end if;

        when STATE_WAIT_COMPLETE =>
          ---------------------------------------------------------------------
          -- Wait for the target port to signal that the frame has been
          -- completed.
          ---------------------------------------------------------------------

          -- Wait for the target port to complete the final request.
          if (masterAck_i = '1') then
            -- The target port has finalized the write of the frame.

            -- Reset master bus signals.
            masterCyc_o <= '0';
            masterStb_o <= '0';
            masterState <= STATE_IDLE;
          else
            -- Wait for the target port to reply.
            -- REMARK: Timeout here???
          end if;

        when others =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------
      end case;
    end if;
  end process;


  -----------------------------------------------------------------------------
  -- Slave interface process.
  -----------------------------------------------------------------------------
  -- Addr |  Read  | Write
  --    0 |  full  | abort & complete
  --    1 |  full  | frameData
  writeContentData_o <= slaveData_i;
  Slave: process(clk, areset_n)
  begin
    if (areset_n = '0') then
      slaveState <= STATE_IDLE;

      slaveData_o <= '0';

      writeFrame_o <= '0';
      writeFrameAbort_o <= '0';
      writeContent_o <= '0';
    elsif (clk'event and clk = '1') then
      writeFrame_o <= '0';
      writeFrameAbort_o <= '0';
      writeContent_o <= '0';

      case slaveState is

        when STATE_IDLE =>
          ---------------------------------------------------------------------
          -- Wait for an access from a master.
          ---------------------------------------------------------------------

          -- Check if any cycle is active.
          if ((slaveCyc_i = '1') and (slaveStb_i = '1')) then
            -- Cycle is active.

            -- Check if the cycle is accessing the status- or data address.
            if (slaveAddr_i(0) = '0') then
              -- Accessing port status address.

              -- Check if writing.
              if (slaveWe_i = '1') then
                -- Writing the status address.
                -- Update the buffering output signals according to the input
                -- data.
                writeFrame_o <= slaveData_i(0);
                writeFrameAbort_o <= slaveData_i(1);
              else
                -- Reading the status address.
                slaveData_o <= writeFrameFull_i;
              end if;
            else
              -- Accessing port data address.

              -- Check if writing.
              if (slaveWe_i = '1') then
                -- Write frame content into the frame buffer.
                writeContent_o <= '1';
              else
                slaveData_o <= writeFrameFull_i;
              end if;
            end if;

            -- Change state to send an ack to the master.
            slaveState <= STATE_SEND_ACK;
          end if;

        when STATE_SEND_ACK =>
          ---------------------------------------------------------------------
          -- Wait for acknowledge to be received by the master.
          ---------------------------------------------------------------------

          -- Go back to the idle state and wait for a new cycle.
          slaveState <= STATE_IDLE;
          
        when others =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------
          null;
          
      end case;
    end if;
  end process;

  -- Assign the acknowledge depending on the current slave state.
  slaveAck_o <= '1' when (slaveState = STATE_SEND_ACK) else '0';
  
end architecture;



-------------------------------------------------------------------------------
-- SwitchPortMaintenance
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for SwitchPortMaintenance.
-------------------------------------------------------------------------------
entity SwitchPortMaintenance is
  generic(
    SWITCH_PORTS : natural range 0 to 255;
    DEVICE_IDENTITY : std_logic_vector(15 downto 0);
    DEVICE_VENDOR_IDENTITY : std_logic_vector(15 downto 0);
    DEVICE_REV : std_logic_vector(31 downto 0);
    ASSY_IDENTITY : std_logic_vector(15 downto 0);
    ASSY_VENDOR_IDENTITY : std_logic_vector(15 downto 0);
    ASSY_REV : std_logic_vector(15 downto 0));
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    -- Routing table port lookup signals.
    lookupStb_i : in std_logic;
    lookupAddr_i : in std_logic_vector(15 downto 0);
    lookupData_o : out std_logic_vector(7 downto 0);
    lookupAck_o : out std_logic;
  
    -- Master port signals.
    -- Write frames to other ports.
    masterCyc_o : out std_logic;
    masterStb_o : out std_logic;
    masterWe_o : out std_logic;
    masterAddr_o : out std_logic_vector(9 downto 0);
    masterData_o : out std_logic_vector(31 downto 0);
    masterData_i : in std_logic;
    masterAck_i : in std_logic;

    -- Slave port signals.
    -- Receives frames from other ports.
    slaveCyc_i : in std_logic;
    slaveStb_i : in std_logic;
    slaveWe_i : in std_logic;
    slaveAddr_i : in std_logic_vector(9 downto 0);
    slaveData_i : in std_logic_vector(31 downto 0);
    slaveData_o : out std_logic;
    slaveAck_o : out std_logic;

    -- Address-lookup interface.
    lookupStb_o : out std_logic;
    lookupAddr_o : out std_logic_vector(15 downto 0);
    lookupData_i : in std_logic_vector(7 downto 0);
    lookupAck_i : in std_logic;

    -- Port common access interface.
    portLinkTimeout_o : out std_logic_vector(23 downto 0);

    -- Port specific access interface.
    linkInitialized_i : in Array1(SWITCH_PORTS-1 downto 0);
    outputPortEnable_o : out Array1(SWITCH_PORTS-1 downto 0);
    inputPortEnable_o : out Array1(SWITCH_PORTS-1 downto 0);
    localAckIdWrite_o : out Array1(SWITCH_PORTS-1 downto 0);
    clrOutstandingAckId_o : out Array1(SWITCH_PORTS-1 downto 0);
    inboundAckId_o : out Array5(SWITCH_PORTS-1 downto 0);
    outstandingAckId_o : out Array5(SWITCH_PORTS-1 downto 0);
    outboundAckId_o : out Array5(SWITCH_PORTS-1 downto 0);
    inboundAckId_i : in Array5(SWITCH_PORTS-1 downto 0);
    outstandingAckId_i : in Array5(SWITCH_PORTS-1 downto 0);
    outboundAckId_i : in Array5(SWITCH_PORTS-1 downto 0);
    
    -- Configuration space for implementation-defined space.
    configStb_o : out std_logic;
    configWe_o : out std_logic;
    configAddr_o : out std_logic_vector(23 downto 0);
    configData_o : out std_logic_vector(31 downto 0);
    configData_i : in std_logic_vector(31 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for SwitchPort.
-------------------------------------------------------------------------------
architecture SwitchPortMaintenanceImpl of SwitchPortMaintenance is

  component MemoryDualPort is
    generic(
      ADDRESS_WIDTH : natural := 1;
      DATA_WIDTH : natural := 1);
    port(
      clkA_i : in std_logic;
      enableA_i : in std_logic;
      writeEnableA_i : in std_logic;
      addressA_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      dataA_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
      dataA_o : out std_logic_vector(DATA_WIDTH-1 downto 0);

      clkB_i : in std_logic;
      enableB_i : in std_logic;
      addressB_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      dataB_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;
  
  component MemorySinglePort is
    generic(
      ADDRESS_WIDTH : natural := 1;
      DATA_WIDTH : natural := 1);
    port(
      clk_i : in std_logic;
      enable_i : in std_logic;
      writeEnable_i : in std_logic;
      address_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      data_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
      data_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;

  component Crc16CITT is
    port(
      d_i : in std_logic_vector(15 downto 0);
      crc_i : in std_logic_vector(15 downto 0);
      crc_o : out std_logic_vector(15 downto 0));
  end component;

  type MasterStateType is (STATE_IDLE,
                           STATE_CHECK_FRAME,
                           STATE_RELAY_READ_RESPONSE,
                           STATE_RELAY_WRITE_RESPONSE,
                           STATE_SEND_READ_REQUEST,
                           STATE_SEND_WRITE_REQUEST,
                           STATE_SEND_READ_RESPONSE,
                           STATE_SEND_WRITE_RESPONSE,
                           STATE_START_PORT_LOOKUP,
                           STATE_READ_PORT_LOOKUP,
                           STATE_READ_TARGET_PORT,
                           STATE_WAIT_TARGET_PORT,
                           STATE_WAIT_TARGET_WRITE,
                           STATE_WAIT_COMPLETE,
                           STATE_WAIT_SLAVE);
  signal masterState : MasterStateType;

  signal crc16Data : std_logic_vector(31 downto 0);
  signal crc16Current : std_logic_vector(15 downto 0);
  signal crc16Temp : std_logic_vector(15 downto 0);
  signal crc16Next : std_logic_vector(15 downto 0);

  signal configEnable : std_logic;
  signal configWrite : std_logic;
  signal configAddress : std_logic_vector(23 downto 0);
  signal configDataWrite : std_logic_vector(31 downto 0);
  signal configDataRead, configDataReadInternal : std_logic_vector(31 downto 0);

  signal outboundFrameEnable : std_logic;
  signal outboundFrameWrite : std_logic;
  signal outboundFrameAddress : std_logic_vector(2 downto 0);
  signal outboundFrameDataWrite : std_logic_vector(31 downto 0);
  signal outboundFrameDataRead : std_logic_vector(31 downto 0);
  signal outboundFrameLength : std_logic_vector(2 downto 0);

  type SlaveStateType is (STATE_READY,
                          STATE_BUSY);
  signal slaveState : SlaveStateType;
  signal slaveAck : std_logic;
  
  signal inboundFrameReady : std_logic;
  signal inboundFramePort : std_logic_vector(7 downto 0);
  signal inboundFrameLength : natural range 0 to 7;
  signal inboundFrameComplete : std_logic;
  
  signal vc : std_logic;
  signal crf : std_logic;
  signal prio : std_logic_vector(1 downto 0);
  signal tt : std_logic_vector(1 downto 0);
  signal ftype : std_logic_vector(3 downto 0);
  signal destinationId : std_logic_vector(15 downto 0);
  signal sourceId : std_logic_vector(15 downto 0);
  signal transaction : std_logic_vector(3 downto 0);
  signal size : std_logic_vector(3 downto 0);
  signal srcTid : std_logic_vector(7 downto 0);
  signal hopCount : std_logic_vector(7 downto 0);
  signal configOffset : std_logic_vector(20 downto 0);
  signal wdptr : std_logic;
  signal content : std_logic_vector(63 downto 0);

  -----------------------------------------------------------------------------
  -- Route table access signals.
  -----------------------------------------------------------------------------

  signal lookupEnable : std_logic;
  signal lookupAddress : std_logic_vector(10 downto 0);
  signal lookupData : std_logic_vector(7 downto 0);
  signal lookupAck : std_logic;

  signal routeTableEnable : std_logic;
  signal routeTableWrite : std_logic;
  signal routeTableAddress : std_logic_vector(10 downto 0);
  signal routeTablePortWrite : std_logic_vector(7 downto 0);
  signal routeTablePortRead : std_logic_vector(7 downto 0);
  
  signal routeTablePortDefault : std_logic_vector(7 downto 0);

  -----------------------------------------------------------------------------
  -- Configuration space signals.
  -----------------------------------------------------------------------------
  
  signal discovered : std_logic;
  
  signal hostBaseDeviceIdLocked : std_logic;
  signal hostBaseDeviceId : std_logic_vector(15 downto 0);
  signal componentTag : std_logic_vector(31 downto 0);

  signal portLinkTimeout : std_logic_vector(23 downto 0);
  
  signal outputPortEnable : Array1(SWITCH_PORTS-1 downto 0);
  signal inputPortEnable : Array1(SWITCH_PORTS-1 downto 0);
  
begin

  -----------------------------------------------------------------------------
  -- Memory to contain the outbound frame.
  -----------------------------------------------------------------------------
  
  OutboundFrameMemory: MemorySinglePort
    generic map(
      ADDRESS_WIDTH=>3, DATA_WIDTH=>32)
    port map(
      clk_i=>clk,
      enable_i=>outboundFrameEnable, writeEnable_i=>outboundFrameWrite,
      address_i=>outboundFrameAddress,
      data_i=>outboundFrameDataWrite, data_o=>outboundFrameDataRead);
  
  -----------------------------------------------------------------------------
  -- CRC generation for outbound frames.
  -----------------------------------------------------------------------------

  crc16Data <= outboundFrameDataWrite;
  
  -- REMARK: Insert FFs here to make the critical path shorter...
  Crc16High: Crc16CITT
    port map(
      d_i=>crc16Data(31 downto 16), crc_i=>crc16Current, crc_o=>crc16Temp);
  Crc16Low: Crc16CITT
    port map(
      d_i=>crc16Data(15 downto 0), crc_i=>crc16Temp, crc_o=>crc16Next);
  
  -----------------------------------------------------------------------------
  -- Master interface process.
  -----------------------------------------------------------------------------
  Master: process(clk, areset_n)
  begin
    if (areset_n = '0') then
      masterState <= STATE_IDLE;

      lookupStb_o <= '0';
      lookupAddr_o <= (others => '0');
      
      masterCyc_o <= '0';
      masterStb_o <= '0';
      masterWe_o <= '0';
      masterAddr_o <= (others => '0');
      masterData_o <= (others => '0');

      configEnable <= '0';
      configWrite <= '0';
      configAddress <= (others => '0');
      configDataWrite <= (others => '0');

      outboundFrameEnable <= '0';
      outboundFrameWrite <= '0';
      outboundFrameAddress <= (others=>'0');
      outboundFrameDataWrite <= (others=>'0');
      outboundFrameLength <= (others=>'0');

      inboundFrameComplete <= '0';
    elsif (clk'event and clk = '1') then
      configEnable <= '0';
      configWrite <= '0';
      inboundFrameComplete <= '0';

      case masterState is

        when STATE_IDLE =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------
          
          -- Wait for a full frame to be available.
          if (inboundFrameReady = '1') then
            if (inboundFrameLength > 3) then
              masterState <= STATE_CHECK_FRAME;
            else
              -- Frame is too short.
              -- REMARK: Discard the frame.
            end if;
          end if;
          
        when STATE_CHECK_FRAME =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------

          -- Check if the frame has 16-bit addresses and is a maintenance frame.
          if (tt = "01") and (ftype = FTYPE_MAINTENANCE_CLASS) then
            -- Maintenance class frame and 16-bit addresses.

            -- Check the frame type.
            case transaction is
              
              when "0000" =>
                ---------------------------------------------------------------
                -- Maintenance read request.
                ---------------------------------------------------------------

                -- Check if the frame is for us.
                if (hopCount = x"00") then
                  -- This frame is for us.
                  configEnable <= '1';
                  configWrite <= '0';
                  configAddress <= configOffset & wdptr & "00";
                  
                  outboundFrameEnable <= '1';
                  outboundFrameWrite <= '1';
                  outboundFrameAddress <= (others=>'0');
                  outboundFrameDataWrite <= "000000" & vc & crf & prio & tt & ftype & sourceId;
                  crc16Current <= x"ffff";
                  
                  masterState <= STATE_SEND_READ_RESPONSE;
                else
                  -- This frame is not for us.
                  -- Decrement hop_count and relay.
                  outboundFrameEnable <= '1';
                  outboundFrameWrite <= '1';
                  outboundFrameAddress <= (others=>'0');
                  outboundFrameDataWrite <= "000000" & vc & crf & prio & tt & ftype & destinationId;
                  crc16Current <= x"ffff";

                  masterState <= STATE_SEND_READ_REQUEST;
                end if;
                
              when "0001" =>
                ---------------------------------------------------------------
                -- Maintenance write request.
                ---------------------------------------------------------------

                -- Check if the frame is for us.
                if (hopCount = x"00") then
                  -- This frame is for us.
                  configEnable <= '1';
                  configWrite <= '1';
                  configAddress <= configOffset & wdptr & "00";
                  
                  if (wdptr = '0') then
                    configDataWrite <= content(63 downto 32);
                  else
                    configDataWrite <= content(31 downto 0);
                  end if;
                  
                  outboundFrameEnable <= '1';
                  outboundFrameWrite <= '1';
                  outboundFrameAddress <= (others=>'0');
                  outboundFrameDataWrite <= "000000" & vc & crf & prio & tt & ftype & sourceId;
                  crc16Current <= x"ffff";
                  
                  masterState <= STATE_SEND_WRITE_RESPONSE;
                else
                  -- This frame is not for us.
                  -- Decrement hop_count and relay.
                  outboundFrameEnable <= '1';
                  outboundFrameWrite <= '1';
                  outboundFrameAddress <= (others=>'0');
                  outboundFrameDataWrite <= "000000" & vc & crf & prio & tt & ftype & destinationId;
                  crc16Current <= x"ffff";

                  masterState <= STATE_SEND_WRITE_REQUEST;
                end if;
              
              when "0010" =>
                ---------------------------------------------------------------
                -- Maintenance read response frame.
                ---------------------------------------------------------------

                outboundFrameEnable <= '1';
                outboundFrameWrite <= '1';
                outboundFrameAddress <= (others=>'0');
                outboundFrameDataWrite <= "000000" & vc & crf & prio & tt & ftype & destinationId;
                crc16Current <= x"ffff";
                
                -- Relay frame.
                masterState <= STATE_RELAY_READ_RESPONSE;
                
              when "0011" =>
                ---------------------------------------------------------------
                -- Maintenance write response frame.
                ---------------------------------------------------------------

                outboundFrameEnable <= '1';
                outboundFrameWrite <= '1';
                outboundFrameAddress <= (others=>'0');
                outboundFrameDataWrite <= "000000" & vc & crf & prio & tt & ftype & destinationId;
                crc16Current <= x"ffff";
                
                -- Relay frame.
                masterState <= STATE_RELAY_WRITE_RESPONSE;
                
              when "0100" =>
                ---------------------------------------------------------------
                -- Maintenance port write frame.
                ---------------------------------------------------------------

                -- REMARK: Support these???
                
              when others =>
                ---------------------------------------------------------------
                -- Unsupported frame type.
                ---------------------------------------------------------------
                
                -- REMARK: Support these???
            end case;
          else
            -- Non-maintenance class frame or unsupported address type.
            -- REMARK: These should not end up here... discard them???
          end if;

        when STATE_RELAY_READ_RESPONSE =>
          ---------------------------------------------------------------------
          -- A maintenance response has been received. It should be relayed as
          -- is using the destinationId. 
          ---------------------------------------------------------------------
          
          case to_integer(unsigned(outboundFrameAddress)) is
            when 0 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= sourceId & transaction & size & srcTid;
              crc16Current <= crc16Next;
            when 1 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= hopCount & configOffset & wdptr & "00";
              crc16Current <= crc16Next;
            when 2 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= content(63 downto 32);
              crc16Current <= crc16Next;
            when 3 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= content(31 downto 0);
              crc16Current <= crc16Next;
            when 4 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite(31 downto 16) <= crc16Next;
              outboundFrameDataWrite(15 downto 0) <= x"0000";
            when others =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '0';
              outboundFrameAddress <= (others=>'0');
              outboundFrameLength <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              masterState <= STATE_START_PORT_LOOKUP;
          end case;
          
        when STATE_RELAY_WRITE_RESPONSE =>
          ---------------------------------------------------------------------
          -- A maintenance response has been received. It should be relayed as
          -- is using the destinationId. 
          ---------------------------------------------------------------------

          case to_integer(unsigned(outboundFrameAddress)) is
            when 0 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= sourceId & transaction & size & srcTid;
              crc16Current <= crc16Next;
            when 1 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= hopCount & configOffset & wdptr & "00";
              crc16Current <= crc16Next;
            when 2 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite(31 downto 16) <= crc16Next;
              outboundFrameDataWrite(15 downto 0) <= x"0000";
            when others =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '0';
              outboundFrameAddress <= (others=>'0');
              outboundFrameLength <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              masterState <= STATE_START_PORT_LOOKUP;
          end case;          

        when STATE_SEND_READ_REQUEST =>
          ---------------------------------------------------------------------
          -- A read request has been received but the hopcount is larger than
          -- zero. Decrement the hopcount, recalculate the crc and relay the
          -- frame using the destinationId. 
          ---------------------------------------------------------------------
          
          case to_integer(unsigned(outboundFrameAddress)) is
            when 0 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= sourceId & transaction & size & srcTid;
              crc16Current <= crc16Next;
            when 1 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= std_logic_vector(unsigned(hopCount) - 1) & configOffset & wdptr & "00";
              crc16Current <= crc16Next;
            when 2 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite(31 downto 16) <= crc16Next;
              outboundFrameDataWrite(15 downto 0) <= x"0000";
            when others =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '0';
              outboundFrameAddress <= (others=>'0');
              outboundFrameLength <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              masterState <= STATE_START_PORT_LOOKUP;
          end case;
          
        when STATE_SEND_WRITE_REQUEST =>
          ---------------------------------------------------------------------
          -- A write request has been received but the hopcount is larger than
          -- zero. Decrement the hopcount, recalculate the crc and relay the
          -- frame using the destinationId. 
          ---------------------------------------------------------------------
          
          case to_integer(unsigned(outboundFrameAddress)) is
            when 0 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= sourceId & transaction & size & srcTid;
              crc16Current <= crc16Next;
            when 1 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= std_logic_vector(unsigned(hopCount) - 1) & configOffset & wdptr & "00";
              crc16Current <= crc16Next;
            when 2 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= content(63 downto 32);
              crc16Current <= crc16Next;
            when 3 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= content(31 downto 0);
              crc16Current <= crc16Next;
            when 4 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite(31 downto 16) <= crc16Next;
              outboundFrameDataWrite(15 downto 0) <= x"0000";
            when others =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '0';
              outboundFrameAddress <= (others=>'0');
              outboundFrameLength <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              masterState <= STATE_START_PORT_LOOKUP;
          end case;
          
        when STATE_SEND_READ_RESPONSE =>
          ---------------------------------------------------------------------
          -- A read request has been received with a hopcount that are zero.
          -- Create a read response, calculate crc and write it to the port it
          -- came from.
          ---------------------------------------------------------------------
          
          case to_integer(unsigned(outboundFrameAddress)) is
            when 0 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= destinationId & "0010" & "0000" & srcTid;
              crc16Current <= crc16Next;
            when 1 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= x"ff" & x"000000";
              crc16Current <= crc16Next;
            when 2 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              if (wdptr = '1') then
                outboundFrameDataWrite <= (others => '0');
              else
                outboundFrameDataWrite <= configDataRead(31 downto 0);
              end if;
              crc16Current <= crc16Next;
            when 3 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              if (wdptr = '1') then
                outboundFrameDataWrite <= configDataRead(31 downto 0);
              else
                outboundFrameDataWrite <= (others => '0');
              end if;
              crc16Current <= crc16Next;
            when 4 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite(31 downto 16) <= crc16Next;
              outboundFrameDataWrite(15 downto 0) <= x"0000";
            when others =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '0';
              outboundFrameAddress <= (others=>'0');
              outboundFrameLength <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              masterAddr_o <= '0' & inboundFramePort & '0';
              masterState <= STATE_READ_TARGET_PORT;
          end case;
          
        when STATE_SEND_WRITE_RESPONSE =>
          ---------------------------------------------------------------------
          -- A write request has been received with a hopcount that are zero.
          -- Create a write response, calculate crc and write it to the port it
          -- came from.
          ---------------------------------------------------------------------

          case to_integer(unsigned(outboundFrameAddress)) is
            when 0 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= destinationId & "0011" & "0000" & srcTid;
              crc16Current <= crc16Next;
            when 1 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite <= x"ff" & x"000000";
              crc16Current <= crc16Next;
            when 2 =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '1';
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              outboundFrameDataWrite(31 downto 16) <= crc16Next;
              outboundFrameDataWrite(15 downto 0) <= x"0000";
            when others =>
              outboundFrameEnable <= '1';
              outboundFrameWrite <= '0';
              outboundFrameAddress <= (others=>'0');
              outboundFrameLength <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              masterAddr_o <= '0' & inboundFramePort & '0';
              masterState <= STATE_READ_TARGET_PORT;
          end case;

        when STATE_START_PORT_LOOKUP =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------

          -- Initiate a port-lookup of the destination address.
          lookupStb_o <= '1';
          lookupAddr_o <= destinationId;
          masterState <= STATE_READ_PORT_LOOKUP;

        when STATE_READ_PORT_LOOKUP =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------
          
          -- Wait for the routing table to complete the request.
          if (lookupAck_i = '1') then
            -- The address lookup is complete.
            
            -- Terminate the lookup cycle.
            lookupStb_o <= '0';

            -- Wait for the target port to reply.
            masterAddr_o <= '0' & lookupData_i & '0';
            masterState <= STATE_READ_TARGET_PORT;
          else
            -- Wait until the address lookup is complete.
            -- REMARK: Timeout here???
          end if;

        when STATE_READ_TARGET_PORT =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------

          -- Read the status of the target port using the result from the
          -- lookup in the routing table.
          masterCyc_o <= '1';
          masterStb_o <= '1';
          masterWe_o <= '0';
          masterState <= STATE_WAIT_TARGET_PORT;

        when STATE_WAIT_TARGET_PORT =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------

          -- Wait for the target port to complete the request.
          if (masterAck_i = '1') then
            if (masterData_i = '0') then
              -- The target port has empty buffers to receive the frame.

              -- Write the first word of the frame to the target port.
              -- The masterData_o has already been assigned.
              masterCyc_o <= '1';
              masterStb_o <= '1';
              masterWe_o <= '1';
              masterAddr_o(0) <= '1';

              -- Read the first word in the frame and update the frame address.
              masterData_o <= outboundFrameDataRead;
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
              
              -- Change state to transfer the frame.
              masterState <= STATE_WAIT_TARGET_WRITE;
            else
              -- The target port has no empty buffer to receive the frame.
              -- Terminate the cycle and retry later.
              masterCyc_o <= '0';
              masterStb_o <= '0';
              masterState <= STATE_READ_TARGET_PORT;
            end if;
          else
            -- Wait for the target port to reply.
            -- REMARK: Timeout here???
          end if;

        when STATE_WAIT_TARGET_WRITE =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------

          -- Wait for the target port to complete the request.
          if (masterAck_i = '1') then
            -- The target port is ready.

            -- Check if the frame has ended.
            if (outboundFrameLength /= outboundFrameAddress) then
              -- The frame has not ended.
              
              -- There are more data to transfer.
              masterData_o <= outboundFrameDataRead;
              outboundFrameAddress <= std_logic_vector(unsigned(outboundFrameAddress) + 1);
            else
              -- There are no more data to transfer.
              
              -- Tell the target port that the frame is complete.
              masterWe_o <= '1';
              masterAddr_o(0) <= '0';
              masterData_o <= x"00000001";
              outboundFrameAddress <= (others=>'0');
              
              -- Change state to wait for the target port to finalize the write
              -- of the full frame.
              masterState <= STATE_WAIT_COMPLETE;
            end if;
          else
            -- Wait for the target port to reply.
            -- REMARK: Timeout here???
          end if;
          
        when STATE_WAIT_COMPLETE =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------

          -- Wait for the target port to complete the final request.
          if (masterAck_i = '1') then
            -- The target port has finalized the write of the frame.
            masterCyc_o <= '0';
            masterStb_o <= '0';
            masterState <= STATE_WAIT_SLAVE;

            -- Indicate the frame has been read.
            inboundFrameComplete <= '1';
          else
            -- Wait for the target port to reply.
            -- REMARK: Timeout here???
          end if;

        when STATE_WAIT_SLAVE =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------
          masterState <= STATE_IDLE;
          
        when others =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------
      end case;
    end if;
  end process;

  
  -----------------------------------------------------------------------------
  -- Slave interface process.
  -----------------------------------------------------------------------------
  -- Addr |  Read  | Write
  --    0 |  full  | abort & complete
  --    1 |  full  | frameData
  Slave: process(clk, areset_n)
  begin
    if (areset_n = '0') then
      slaveState <= STATE_READY;
      slaveData_o <= '0';
      slaveAck <= '0';

      vc <= '0';
      crf <= '0';
      prio <= (others=>'0');
      tt <= (others=>'0');
      ftype <= (others=>'0');
      destinationId <= (others=>'0');
      sourceId <= (others=>'0');
      transaction <= (others=>'0');
      size <= (others=>'0');
      srcTid <= (others=>'0');
      hopCount <= (others=>'0');
      configOffset <= (others=>'0');
      wdptr <= '0';
      content <= (others=>'0');
      
      inboundFrameReady <= '0';
      inboundFramePort <= (others => '0');
      inboundFrameLength <= 0;
    elsif (clk'event and clk = '1') then
      slaveAck <= '0';

      case slaveState is
        when STATE_READY =>
          ---------------------------------------------------------------------
          -- Ready to receive a new frame.
          ---------------------------------------------------------------------
          
          -- Check if any cycle is active.
          if ((slaveCyc_i = '1') and (slaveStb_i = '1') and (slaveAck = '0')) then
            -- Cycle is active.

            -- Check if writing.
            if (slaveWe_i = '1') then
              -- Writing request.
              
              -- Check if the cycle is accessing the status- or data address.
              if (slaveAddr_i(0) = '0') then
                -- Writing to port status address.

                if (slaveData_i(0) = '1') and (slaveData_i(1) = '0') then
                  -- A frame has been written.

                  -- Indicate the frame is ready for processing.
                  -- The slave address contains the number of the accessing port.
                  inboundFrameReady <= '1';
                  inboundFramePort <= slaveAddr_i(8 downto 1);

                  -- Change state until the frame has been processed.
                  slaveState <= STATE_BUSY;
                else
                  -- The frame has been aborted.
                  -- Reset the received frame length.
                  inboundFrameLength <= 0;
                end if;
              else
                -- Write frame content into the frame buffer.

                -- Check which frame index that is written.
                case inboundFrameLength is
                  when 0 =>
                    vc <= slaveData_i(25);
                    crf <= slaveData_i(24);
                    prio <= slaveData_i(23 downto 22);
                    tt <= slaveData_i(21 downto 20);
                    ftype <= slaveData_i(19 downto 16);
                    destinationId <= slaveData_i(15 downto 0);
                    inboundFrameLength <= inboundFrameLength + 1;
                  when 1 =>
                    sourceId <= slaveData_i(31 downto 16);
                    transaction <= slaveData_i(15 downto 12);
                    size <= slaveData_i(11 downto 8);
                    srcTid <= slaveData_i(7 downto 0);
                    inboundFrameLength <= inboundFrameLength + 1;
                  when 2 =>
                    hopCount <= slaveData_i(31 downto 24);
                    configOffset <= slaveData_i(23 downto 3);
                    wdptr <= slaveData_i(2);
                    inboundFrameLength <= inboundFrameLength + 1;
                  when 3 =>
                    -- Note that crc will be assigned here if there are no
                    -- content in the frame.
                    content(63 downto 32) <= slaveData_i;
                    inboundFrameLength <= inboundFrameLength + 1;
                  when 4 =>
                    content(31 downto 0) <= slaveData_i;
                    inboundFrameLength <= inboundFrameLength + 1;
                  when others =>                
                    -- Dont support longer frames.
                    -- REMARK: Add support for longer frames??? Especially
                    -- received frames that only should be routed...
                end case;
              end if;

              -- Send acknowledge.
              slaveAck <= '1';
            else
              -- Reading request.

              -- Reading the status address.
              -- Always indicate that we are ready to accept a new frame.
              slaveData_o <= '0';

              -- Send acknowledge.
              slaveAck <= '1';
            end if;
          else
            -- No cycle is active.
          end if;

        when STATE_BUSY =>
          ---------------------------------------------------------------------
          -- Waiting for a received frame to be processed.
          ---------------------------------------------------------------------
          
          -- Check if any cycle is active.
          if ((slaveCyc_i = '1') and (slaveStb_i = '1') and (slaveAck = '0')) then
            -- Cycle is active.

            -- Check if writing.
            if (slaveWe_i = '1') then
              -- Writing.
              -- Dont do anything.

              -- Send acknowledge.
              slaveAck <= '1';
            else
              -- Read port data address.

              -- Reading the status address.
              -- Always indicate that we are busy.
              slaveData_o <= '1';

              -- Send acknowledge.
              slaveAck <= '1';
            end if;
          else
            -- No cycle is active.
            -- Dont do anything.
          end if;

          -- Check if the master process has processed the received frame.
          if (inboundFrameComplete = '1') then
            -- The master has processed the frame.
            inboundFrameReady <= '0';
            inboundFrameLength <= 0;
            slaveState <= STATE_READY;
          else
            -- The master is not ready yet.
            -- Dont do anything.
          end if;
          
        when others =>
          ---------------------------------------------------------------------
          -- 
          ---------------------------------------------------------------------
          null;
          
      end case;
    end if;
  end process;
  
  slaveAck_o <= slaveAck;

  -----------------------------------------------------------------------------
  -- Logic implementing the routing table access.
  -----------------------------------------------------------------------------

  -- Lookup interface port memory signals.
  lookupEnable <= '1' when (lookupStb_i = '1') and (lookupAddr_i(15 downto 11) = "00000") else '0';
  lookupAddress <= lookupAddr_i(10 downto 0);
  lookupData_o <= lookupData when (lookupEnable = '1') else routeTablePortDefault;
  lookupAck_o <= lookupAck;
  LookupProcess: process(clk, areset_n)
  begin
    if (areset_n = '0') then
      lookupAck <= '0';
    elsif (clk'event and clk = '1') then
      if (lookupAck = '0') then
        if (lookupStb_i = '1') then
          lookupAck <= '1';
        end if;
      else
        lookupAck <= '0';
      end if;
    end if;
  end process;

  -- Dual port memory containing the routing table.
  RoutingTable: MemoryDualPort
    generic map(
      ADDRESS_WIDTH=>11, DATA_WIDTH=>8)
    port map(
      clkA_i=>clk, enableA_i=>routeTableEnable, writeEnableA_i=>routeTableWrite,
      addressA_i=>routeTableAddress,
      dataA_i=>routeTablePortWrite, dataA_o=>routeTablePortRead,
      clkB_i=>clk, enableB_i=>lookupEnable,
      addressB_i=>lookupAddress, dataB_o=>lookupData);
  
  -----------------------------------------------------------------------------
  -- Configuration memory.
  -----------------------------------------------------------------------------

  portLinkTimeout_o <= portLinkTimeout;
  outputPortEnable_o <= outputPortEnable;
  inputPortEnable_o <= inputPortEnable;
  
  configStb_o <= '1' when ((configEnable = '1') and (configAddress(23 downto 16) /= x"00")) else '0';
  configWe_o <= configWrite;
  configAddr_o <= configAddress;
  configData_o <= configDataWrite;
  configDataRead <= configData_i when (configAddress(23 downto 16) /= x"00") else
                    configDataReadInternal;
  
  ConfigMemory: process(areset_n, clk)
  begin
    if (areset_n = '0') then
      configDataReadInternal <= (others => '0');

      routeTableEnable <= '1';
      routeTableWrite <= '0';
      routeTableAddress <= (others => '0');
      routeTablePortWrite <= (others => '0');
      routeTablePortDefault <= (others => '0');

      discovered <= '0';
      
      hostBaseDeviceIdLocked <= '0';
      hostBaseDeviceId <= (others => '1');
      componentTag <= (others => '0');

      portLinkTimeout <= (others => '1');

      -- REMARK: These should be set to zero when a port gets initialized...
      outputPortEnable <= (others => '0');
      inputPortEnable <= (others => '0');

      localAckIdWrite_o <= (others => '0');
    elsif (clk'event and clk = '1') then
      routeTableWrite <= '0';
      localAckIdWrite_o <= (others => '0');
      
      if (configEnable = '1') then
        -- Check if the access is into implementation defined space or if the
        -- access should be handled here.
        if (configAddress(23 downto 16) /= x"00") then
          -- Accessing implementation defined space.
          -- Make an external access and return the resonse.
          configDataReadInternal <= (others=>'0');
        else
          -- Access should be handled here.
          
          case (configAddress) is
            when x"000000" =>
              -----------------------------------------------------------------
              -- Device Identity CAR. Read-only.
              -----------------------------------------------------------------

              configDataReadInternal(31 downto 16) <= DEVICE_IDENTITY;
              configDataReadInternal(15 downto 0) <= DEVICE_VENDOR_IDENTITY;
              
            when x"000004" =>
              -----------------------------------------------------------------
              -- Device Information CAR. Read-only.
              -----------------------------------------------------------------

              configDataReadInternal(31 downto 0) <= DEVICE_REV;
              
            when x"000008" =>
              -----------------------------------------------------------------
              -- Assembly Identity CAR. Read-only.
              -----------------------------------------------------------------

              configDataReadInternal(31 downto 16) <= ASSY_IDENTITY;
              configDataReadInternal(15 downto 0) <= ASSY_VENDOR_IDENTITY;
              
            when x"00000c" =>
              -----------------------------------------------------------------
              -- Assembly Informaiton CAR. Read-only.
              -----------------------------------------------------------------

              configDataReadInternal(31 downto 16) <= ASSY_REV;
              configDataReadInternal(15 downto 0) <= x"0100";
              
            when x"000010" =>
              -----------------------------------------------------------------
              -- Processing Element Features CAR. Read-only.
              -----------------------------------------------------------------
              
              -- Bridge.
              configDataReadInternal(31) <= '0';
              
              -- Memory.
              configDataReadInternal(30) <= '0';
              
              -- Processor.
              configDataReadInternal(29) <= '0';
              
              -- Switch.
              configDataReadInternal(28) <= '1';
              
              -- Reserved.
              configDataReadInternal(27 downto 10) <= (others => '0');
              
              -- Extended route table configuration support.
              configDataReadInternal(9) <= '0';
              
              -- Standard route table configuration support.
              configDataReadInternal(8) <= '1';
              
              -- Reserved.
              configDataReadInternal(7 downto 5) <= (others => '0');
              
              -- Common transport large system support.
              configDataReadInternal(4) <= '1';
              
              -- Extended features.
              configDataReadInternal(3) <= '1';
              
              -- Extended addressing support.
              -- Not a processing element.
              configDataReadInternal(2 downto 0) <= "000";
              
            when x"000014" =>
              -----------------------------------------------------------------
              -- Switch Port Information CAR. Read-only.
              -----------------------------------------------------------------

              -- Reserved.
              configDataReadInternal(31 downto 16) <= (others => '0');

              -- PortTotal.
              configDataReadInternal(15 downto 8) <=
                std_logic_vector(to_unsigned(SWITCH_PORTS, 8));

              -- PortNumber.
              configDataReadInternal(7 downto 0) <= inboundFramePort;
              
            when x"000034" =>
              -----------------------------------------------------------------
              -- Switch Route Table Destination ID Limit CAR.
              -----------------------------------------------------------------

              -- Max_destId.
              -- Support 2048 addresses.
              configDataReadInternal(15 downto 0) <= x"0800";
              
            when x"000068" =>
              -----------------------------------------------------------------
              -- Host Base Device ID Lock CSR.
              -----------------------------------------------------------------

              if (configWrite = '1') then
                -- Check if this field has been written before.
                if (hostBaseDeviceIdLocked = '0') then
                  -- The field has not been written.
                  -- Lock the field and set the host base device id.
                  hostBaseDeviceIdLocked <= '1';
                  hostBaseDeviceId <= configDataWrite(15 downto 0);
                else
                  -- The field has been written.
                  -- Check if the written data is the same as the stored.
                  if (hostBaseDeviceId = configDataWrite(15 downto 0)) then
                    -- Same as stored, reset the value to its initial value.
                    hostBaseDeviceIdLocked <= '0';
                    hostBaseDeviceId <= (others => '1');
                  else
                    -- Not writing the same as the stored value.
                    -- Ignore the write.
                  end if;
                end if;
              end if;
              
              configDataReadInternal(31 downto 16) <= (others => '0');
              configDataReadInternal(15 downto 0) <= hostBaseDeviceId;
              
            when x"00006c" =>
              -----------------------------------------------------------------
              -- Component TAG CSR.
              -----------------------------------------------------------------

              if (configWrite = '1') then
                componentTag <= configDataWrite;
              end if;
              
              configDataReadInternal <= componentTag;
              
            when x"000070" =>
              -----------------------------------------------------------------
              -- Standard Route Configuration Destination ID Select CSR.
              -----------------------------------------------------------------             

              if (configWrite = '1') then
                -- Write the address to access the routing table.
                routeTableAddress <= configDataWrite(10 downto 0);
              end if;
              
              configDataReadInternal(31 downto 11) <= (others => '0');
              configDataReadInternal(10 downto 0) <= routeTableAddress;
              
            when x"000074" =>
              -----------------------------------------------------------------
              -- Standard Route Configuration Port Select CSR.
              -----------------------------------------------------------------

              if (configWrite = '1') then
                -- Write the port information for the address selected by the
                -- above register.
                routeTableWrite <= '1';
                routeTablePortWrite <= configDataWrite(7 downto 0);
              end if;

              configDataReadInternal(31 downto 8) <= (others => '0');
              configDataReadInternal(7 downto 0) <= routeTablePortRead;
              
            when x"000078" =>
              -----------------------------------------------------------------
              -- Standard Route Default Port CSR.
              -----------------------------------------------------------------

              if (configWrite = '1') then
                -- Write the default route device id.
                routeTablePortDefault <= configDataWrite(7 downto 0);
              end if;
              
              configDataReadInternal(31 downto 8) <= (others => '0');
              configDataReadInternal(7 downto 0) <= routeTablePortDefault;
              
            when x"000100" =>
              -----------------------------------------------------------------
              -- Extended features. LP-Serial Register Block Header.
              -----------------------------------------------------------------

              -- One feature only, 0x0003=Generic End Point Free Device.
              configDataReadInternal(31 downto 16) <= x"0000";
              configDataReadInternal(15 downto 0) <= x"0003";
              
            when x"000120" =>
              -----------------------------------------------------------------
              -- Port Link Timeout Control CSR.
              -----------------------------------------------------------------

              if (configWrite = '1') then
                portLinkTimeout <= configDataWrite(31 downto 8);
              end if;
              
              configDataReadInternal(31 downto 8) <= portLinkTimeout;
              configDataReadInternal(7 downto 0) <= x"00";
              
            when x"00013c" =>
              -----------------------------------------------------------------
              -- Port General Control CSR.
              -----------------------------------------------------------------

              if (configWrite = '1') then
                discovered <= configDataWrite(29);
              end if;
              
              configDataReadInternal(31 downto 30) <= "00";
              configDataReadInternal(29) <= discovered;
              configDataReadInternal(28 downto 0) <= (others => '0');

            when others =>
              -----------------------------------------------------------------
              -- Other port specific registers.
              -----------------------------------------------------------------
              
              -- Make sure the output is always set to something.
              configDataReadInternal <= (others=>'0');

              -- Iterate through all active ports.
              for portIndex in 0 to SWITCH_PORTS-1 loop
                
                if(unsigned(configAddress) = (x"000148" + (x"000020"*portIndex))) then
                  -----------------------------------------------------------------
                  -- Port N Local ackID CSR.
                  -----------------------------------------------------------------
                  if (configWrite = '1') then
                    localAckIdWrite_o(portIndex) <= '1';
                    clrOutstandingAckId_o(portIndex) <= configDataWrite(31);
                    inboundAckId_o(portIndex) <= configDataWrite(28 downto 24);
                    outstandingAckId_o(portIndex) <= configDataWrite(12 downto 8);
                    outboundAckId_o(portIndex) <= configDataWrite(4 downto 0);
                  end if;
                  configDataReadInternal(31 downto 29) <= (others => '0');
                  configDataReadInternal(28 downto 24) <= inboundAckId_i(portIndex);
                  configDataReadInternal(23 downto 13) <= (others => '0');
                  configDataReadInternal(12 downto 8) <= outstandingAckId_i(portIndex);
                  configDataReadInternal(7 downto 5) <= (others => '0');
                  configDataReadInternal(4 downto 0) <= outboundAckId_i(portIndex);
                  
                elsif(unsigned(configAddress) = (x"000154" + (x"000020"*portIndex))) then
                  -----------------------------------------------------------------
                  -- Port N Control 2 CSR.
                  -----------------------------------------------------------------
                  configDataReadInternal <= (others => '0');
                  
                elsif(unsigned(configAddress) = (x"000158" + (x"000020"*portIndex))) then
                  -----------------------------------------------------------------
                  -- Port N Error and Status CSR.
                  -----------------------------------------------------------------
                  -- Idle Sequence 2 Support.
                  configDataReadInternal(31) <= '0';
                  
                  -- Idle Sequence 2 Enable.
                  configDataReadInternal(30) <= '0';
                  
                  -- Idle Sequence.
                  configDataReadInternal(29) <= '0';
                  
                  -- Reserved.
                  configDataReadInternal(28) <= '0';
                  
                  -- Flow Control Mode.
                  configDataReadInternal(27) <= '0';
                  
                  -- Reserved.
                  configDataReadInternal(26 downto 21) <= (others => '0');
                  
                  -- Output retry-encountered.
                  configDataReadInternal(20) <= '0';
                  
                  -- Output retried.
                  configDataReadInternal(19) <= '0';
                  
                  -- Output retried-stopped.
                  configDataReadInternal(18) <= '0';
                  
                  -- Output error-encountered.
                  configDataReadInternal(17) <= '0';
                  
                  -- Output error-stopped.
                  configDataReadInternal(16) <= '0';
                  
                  -- Reserved.
                  configDataReadInternal(15 downto 11) <= (others => '0');
                  
                  -- Input retry-stopped.
                  configDataReadInternal(10) <= '0';
                  
                  -- Input error-encountered.
                  configDataReadInternal(9) <= '0';
                  
                  -- Input error-stopped.
                  configDataReadInternal(8) <= '0'; 

                  -- Reserved.
                  configDataReadInternal(7 downto 5) <= (others => '0');

                  -- Port-write pending.
                  configDataReadInternal(4) <= '0';
                  
                  -- Port unavailable.
                  configDataReadInternal(3) <= '0';
                  
                  -- Port error.
                  configDataReadInternal(2) <= '0';
                  
                  -- Port OK.
                  configDataReadInternal(1) <= linkInitialized_i(portIndex);
                  
                  -- Port uninitialized.
                  configDataReadInternal(0) <= not linkInitialized_i(portIndex);
                  
                elsif(unsigned(configAddress) = (x"00015c" + (x"000020"*portIndex))) then
                  -----------------------------------------------------------------
                  -- Port N Control CSR.
                  -----------------------------------------------------------------
                  
                  -- Port Width Support.
                  configDataReadInternal(31 downto 30) <= (others=>'0');

                  -- Initialized Port Width.
                  configDataReadInternal(29 downto 27) <= (others=>'0');

                  -- Port Width Override.
                  configDataReadInternal(26 downto 24) <= (others=>'0');

                  -- Port disable.
                  configDataReadInternal(23) <= '0';
                  
                  -- Output Port Enable.
                  if (configWrite = '1') then
                    outputPortEnable(portIndex) <= configDataWrite(22);
                  end if;
                  configDataReadInternal(22) <= outputPortEnable(portIndex);
                  
                  -- Input Port Enable.
                  if (configWrite = '1') then
                    inputPortEnable(portIndex) <= configDataWrite(21);
                  end if;
                  configDataReadInternal(21) <= inputPortEnable(portIndex);

                  -- Error Checking Disabled.
                  configDataReadInternal(20) <= '0';
                  
                  -- Multicast-event Participant.
                  configDataReadInternal(19) <= '0';
                  
                  -- Reserved.
                  configDataReadInternal(18) <= '0';
                  
                  -- Enumeration Boundry.
                  configDataReadInternal(17) <= '0';

                  -- Reserved.
                  configDataReadInternal(16) <= '0';

                  -- Extended Port Width Override.
                  configDataReadInternal(15 downto 14) <= (others=>'0');

                  -- Extended Port Width Support.
                  configDataReadInternal(13 downto 12) <= (others=>'0');
                  
                  -- Implementation defined.
                  configDataReadInternal(11 downto 4) <= (others=>'0');

                  -- Reserved.
                  configDataReadInternal(3 downto 1) <= (others=>'0');

                  -- Port Type.
                  configDataReadInternal(0) <= '1';
                end if;
              end loop;

          end case;
        end if;
      else
        -- Config memory not enabled.
      end if;
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
entity RouteTableInterconnect is
  generic(
    WIDTH : natural range 1 to 256 := 8);
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    stb_i : in Array1(WIDTH-1 downto 0);
    addr_i : in Array16(WIDTH-1 downto 0);
    dataM_o : out Array8(WIDTH-1 downto 0);
    ack_o : out Array1(WIDTH-1 downto 0);

    stb_o : out std_logic;
    addr_o : out std_logic_vector(15 downto 0);
    dataS_i : in std_logic_vector(7 downto 0);
    ack_i : in std_logic);
end entity;


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
architecture RouteTableInterconnectImpl of RouteTableInterconnect is
  signal activeCycle : std_logic;
  signal selectedMaster : natural range 0 to WIDTH-1;
begin
  
  -----------------------------------------------------------------------------
  -- Arbitration.
  -----------------------------------------------------------------------------
  Arbiter: process(areset_n, clk)
  begin
    if (areset_n = '0') then
      activeCycle <= '0';
      selectedMaster <= 0;
    elsif (clk'event and clk = '1') then
      if (activeCycle = '0') then
        for i in 0 to WIDTH-1 loop
          if (stb_i(i) = '1') then
            activeCycle <= '1';
            selectedMaster <= i;
          end if;
        end loop;
      else  
        if (stb_i(selectedMaster) = '0') then
          activeCycle <= '0';
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Interconnection.
  -----------------------------------------------------------------------------
  stb_o <= stb_i(selectedMaster) and activeCycle;
  addr_o <= addr_i(selectedMaster);

  Interconnect: for i in 0 to WIDTH-1 generate
    dataM_o(i) <= dataS_i;
    ack_o(i) <= ack_i when (selectedMaster = i) else '0';
  end generate;

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
entity SwitchPortInterconnect is
  generic(
    WIDTH : natural range 1 to 256 := 8);
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    masterCyc_i : in Array1(WIDTH-1 downto 0);
    masterStb_i : in Array1(WIDTH-1 downto 0);
    masterWe_i : in Array1(WIDTH-1 downto 0);
    masterAddr_i : in Array10(WIDTH-1 downto 0);
    masterData_i : in Array32(WIDTH-1 downto 0);
    masterData_o : out Array1(WIDTH-1 downto 0);
    masterAck_o : out Array1(WIDTH-1 downto 0);

    slaveCyc_o : out Array1(WIDTH-1 downto 0);
    slaveStb_o : out Array1(WIDTH-1 downto 0);
    slaveWe_o : out Array1(WIDTH-1 downto 0);
    slaveAddr_o : out Array10(WIDTH-1 downto 0);
    slaveData_o : out Array32(WIDTH-1 downto 0);
    slaveData_i : in Array1(WIDTH-1 downto 0);
    slaveAck_i : in Array1(WIDTH-1 downto 0));
end entity;


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
architecture SwitchPortInterconnectImpl of SwitchPortInterconnect is
  signal activeCycle : std_logic;
  signal selectedMaster : natural range 0 to WIDTH-1;
  signal selectedSlave : natural range 0 to WIDTH-1;
 
begin

  -----------------------------------------------------------------------------
  -- Arbitration process.
  -----------------------------------------------------------------------------
  
  RoundRobinArbiter: process(areset_n, clk)
    variable index : natural range 0 to WIDTH-1 := 0;
  begin
    if (areset_n = '0') then
      activeCycle <= '0';
      selectedMaster <= 0;
    elsif (clk'event and clk = '1') then
      -- Check if a cycle is ongoing.
      if (activeCycle = '0') then
        -- No ongoing cycles.
        
        -- Iterate through all ports and check if any new cycle has started.
        for i in 0 to WIDTH-1 loop
          if ((selectedMaster+i) >= WIDTH) then
            index := (selectedMaster+i) - WIDTH;
          else
            index := (selectedMaster+i);
          end if;
          
          if (masterCyc_i(index) = '1') then
            activeCycle <= '1';
            selectedMaster <= index;
          end if;
        end loop;
      else
        -- Ongoing cycle.
        
        -- Check if the cycle has ended.
        if (masterCyc_i(selectedMaster) = '0') then
          -- Cycle has ended.
          activeCycle <= '0';

          -- Check if a new cycle has started from another master.
          -- Start to check from the one that ended its cycle, this way, the
          -- ports will be scheduled like round-robin.
          for i in 0 to WIDTH-1 loop
            if ((selectedMaster+i) >= WIDTH) then
              index := (selectedMaster+i) - WIDTH;
            else
              index := (selectedMaster+i);
            end if;
              
            if (masterCyc_i(index) = '1') then
              activeCycle <= '1';
              selectedMaster <= index;
            end if;
          end loop;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Address decoding.
  -----------------------------------------------------------------------------

  -- Select the last port when the top bit is set.
  -- The last port must be the maintenance slave port.
  selectedSlave <= WIDTH-1 when masterAddr_i(selectedMaster)(9) = '1' else
                   to_integer(unsigned(masterAddr_i(selectedMaster)(8 downto 1)));
  
  -----------------------------------------------------------------------------
  -- Interconnection matrix.
  -----------------------------------------------------------------------------
  Interconnect: for i in 0 to WIDTH-1 generate
    slaveCyc_o(i) <= masterCyc_i(selectedMaster) when ((activeCycle = '1') and (selectedSlave = i)) else '0';
    slaveStb_o(i) <= masterStb_i(selectedMaster) when ((activeCycle = '1') and (selectedSlave = i)) else '0';
    slaveWe_o(i) <= masterWe_i(selectedMaster);
    slaveAddr_o(i) <= masterAddr_i(selectedMaster);
    slaveData_o(i) <= masterData_i(selectedMaster);
    masterData_o(i) <= slaveData_i(selectedSlave);
    masterAck_o(i) <= slaveAck_i(selectedSlave) when (selectedMaster = i) else '0';
  end generate;

end architecture;
