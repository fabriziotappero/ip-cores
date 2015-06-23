-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- Description
-- Contains automatic simulation test code to verify a RioSwitch implementation.
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
-- TestRioSwitch.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library std;
use std.textio.all;
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for TestRioSwitch.
-------------------------------------------------------------------------------
entity TestRioSwitch is
end entity;


-------------------------------------------------------------------------------
-- Architecture for TestRioSwitch.
-------------------------------------------------------------------------------
architecture TestRioSwitchImpl of TestRioSwitch is
  
  component RioSwitch is
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
  end component;

  component TestPort is
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      frameValid_i : in std_logic;
      frameWrite_i : in RioFrame;
      frameComplete_o : out std_logic;
      
      frameExpected_i : in std_logic;
      frameRead_i : in RioFrame;
      frameReceived_o : out std_logic;

      readFrameEmpty_o : out std_logic;
      readFrame_i : in std_logic;
      readContent_i : in std_logic;
      readContentEnd_o : out std_logic;
      readContentData_o : out std_logic_vector(31 downto 0);
      writeFrameFull_o : out std_logic;
      writeFrame_i : in std_logic;
      writeFrameAbort_i : in std_logic;
      writeContent_i : in std_logic;
      writeContentData_i : in std_logic_vector(31 downto 0));
  end component;

  constant PORTS : natural := 7;
  constant SWITCH_IDENTITY : std_logic_vector(15 downto 0) := x"0123";
  constant SWITCH_VENDOR_IDENTITY : std_logic_vector(15 downto 0) := x"4567";
  constant SWITCH_REV : std_logic_vector(31 downto 0) := x"89abcdef";
  constant SWITCH_ASSY_IDENTITY : std_logic_vector(15 downto 0) := x"0011";
  constant SWITCH_ASSY_VENDOR_IDENTITY : std_logic_vector(15 downto 0) := x"2233";
  constant SWITCH_ASSY_REV : std_logic_vector(15 downto 0) := x"4455";
  
  signal clk : std_logic;
  signal areset_n : std_logic;

  signal frameValid : Array1(PORTS-1 downto 0);
  signal frameWrite : RioFrameArray(PORTS-1 downto 0);
  signal frameComplete : Array1(PORTS-1 downto 0);
      
  signal frameExpected : Array1(PORTS-1 downto 0);
  signal frameRead : RioFrameArray(PORTS-1 downto 0);
  signal frameReceived : Array1(PORTS-1 downto 0);
  
  signal writeFrameFull : Array1(PORTS-1 downto 0);
  signal writeFrame : Array1(PORTS-1 downto 0);
  signal writeFrameAbort : Array1(PORTS-1 downto 0);
  signal writeContent : Array1(PORTS-1 downto 0);
  signal writeContentData : Array32(PORTS-1 downto 0);

  signal readFrameEmpty : Array1(PORTS-1 downto 0);
  signal readFrame : Array1(PORTS-1 downto 0);
  signal readContent : Array1(PORTS-1 downto 0);
  signal readContentEnd : Array1(PORTS-1 downto 0);
  signal readContentData : Array32(PORTS-1 downto 0);
  
  signal portLinkTimeout : std_logic_vector(23 downto 0);
  
  signal linkInitialized : Array1(PORTS-1 downto 0);
  signal outputPortEnable : Array1(PORTS-1 downto 0);
  signal inputPortEnable : Array1(PORTS-1 downto 0);
      
  signal localAckIdWrite : Array1(PORTS-1 downto 0);
  signal clrOutstandingAckId : Array1(PORTS-1 downto 0);
  signal inboundAckIdWrite : Array5(PORTS-1 downto 0);
  signal outstandingAckIdWrite : Array5(PORTS-1 downto 0);
  signal outboundAckIdWrite : Array5(PORTS-1 downto 0);
  signal inboundAckIdRead : Array5(PORTS-1 downto 0);
  signal outstandingAckIdRead : Array5(PORTS-1 downto 0);
  signal outboundAckIdRead : Array5(PORTS-1 downto 0);
        
  signal configStb, configStbExpected : std_logic;
  signal configWe, configWeExpected : std_logic;
  signal configAddr, configAddrExpected : std_logic_vector(23 downto 0);
  signal configDataWrite, configDataWriteExpected : std_logic_vector(31 downto 0);
  signal configDataRead, configDataReadExpected : std_logic_vector(31 downto 0);
  
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
  -- Serial port emulator.
  -----------------------------------------------------------------------------
  TestDriver: process

    ---------------------------------------------------------------------------
    -- Place a new ingress frame on a port.
    ---------------------------------------------------------------------------
    procedure SendFrame(constant portIndex : natural range 0 to 7;
                        constant frame : RioFrame) is
    begin
      frameValid(portIndex) <= '1';
      frameWrite(portIndex) <= frame;
      wait until frameComplete(portIndex) = '1';
      frameValid(portIndex) <= '0';
    end procedure;

    procedure SendFrame(constant portIndex : natural range 0 to 7;
                        constant sourceId : std_logic_vector(15 downto 0);
                        constant destinationId : std_logic_vector(15 downto 0);
                        constant payload : RioPayload) is
      variable frame : RioFrame;
    begin
      frame := RioFrameCreate(ackId=>"00000", vc=>'0', crf=>'0', prio=>"00",
                              tt=>"01", ftype=>"0000", 
                              sourceId=>sourceId, destId=>destinationId,
                              payload=>payload);
      
      frameValid(portIndex) <= '1';
      frameWrite(portIndex) <= frame;
    end procedure;
    
    ---------------------------------------------------------------------------
    -- Expect a new egress frame on a port.
    ---------------------------------------------------------------------------
    procedure ReceiveFrame(constant portIndex : natural range 0 to 7;
                           constant frame : RioFrame) is
    begin
      frameExpected(portIndex) <= '1';
      frameRead(portIndex) <= frame;
      wait until frameReceived(portIndex) = '1';
      frameExpected(portIndex) <= '0';
    end procedure;

    procedure ReceiveFrame(constant portIndex : natural range 0 to 7;
                           constant sourceId : std_logic_vector(15 downto 0);
                           constant destinationId : std_logic_vector(15 downto 0);
                           constant payload : RioPayload) is
      variable frame : RioFrame;
    begin
      frame := RioFrameCreate(ackId=>"00000", vc=>'0', crf=>'0', prio=>"00",
                              tt=>"01", ftype=>"0000", 
                              sourceId=>sourceId, destId=>destinationId,
                              payload=>payload);
      
      frameExpected(portIndex) <= '1';
      frameRead(portIndex) <= frame;
    end procedure;
    
    ---------------------------------------------------------------------------
    -- Read a configuration-space register.
    ---------------------------------------------------------------------------
    procedure ReadConfig32(constant portIndex : natural range 0 to 7;
                           constant destinationId : std_logic_vector(15 downto 0);
                           constant sourceId : std_logic_vector(15 downto 0);
                           constant hop : std_logic_vector(7 downto 0);
                           constant tid : std_logic_vector(7 downto 0);
                           constant address : std_logic_vector(23 downto 0);
                           constant data : std_logic_vector(31 downto 0)) is
      variable maintData : DoubleWordArray(0 to 7);
    begin
      SendFrame(portIndex, RioFrameCreate(ackId=>"00000", vc=>'0', crf=>'0', prio=>"00",
                                          tt=>"01", ftype=>FTYPE_MAINTENANCE_CLASS, 
                                          sourceId=>sourceId, destId=>destinationId,
                                          payload=>RioMaintenance(transaction=>"0000",
                                                                  size=>"1000",
                                                                  tid=>tid,
                                                                  hopCount=>hop,
                                                                  configOffset=>address(23 downto 3),
                                                                  wdptr=>address(2),
                                                                  dataLength=>0,
                                                                  data=>maintData)));
      if (address(2) = '0') then
        maintData(0) := data & x"00000000";
      else
        maintData(0) := x"00000000" & data ;
      end if;
      
      ReceiveFrame(portIndex, RioFrameCreate(ackId=>"00000", vc=>'0', crf=>'0', prio=>"00",
                                             tt=>"01", ftype=>FTYPE_MAINTENANCE_CLASS, 
                                             sourceId=>destinationId, destId=>sourceId,
                                             payload=>RioMaintenance(transaction=>"0010",
                                                                     size=>"0000",
                                                                     tid=>tid,
                                                                     hopCount=>x"ff",
                                                                     configOffset=>"000000000000000000000",
                                                                     wdptr=>'0',
                                                                     dataLength=>1,
                                                                     data=>maintData)));
    end procedure;

    ---------------------------------------------------------------------------
    -- Write a configuration-space register.
    ---------------------------------------------------------------------------
    procedure WriteConfig32(constant portIndex : natural range 0 to 7;
                            constant destinationId : std_logic_vector(15 downto 0);
                            constant sourceId : std_logic_vector(15 downto 0);
                            constant hop : std_logic_vector(7 downto 0);
                            constant tid : std_logic_vector(7 downto 0);
                            constant address : std_logic_vector(23 downto 0);
                            constant data : std_logic_vector(31 downto 0)) is
      variable maintData : DoubleWordArray(0 to 7);
    begin
      if (address(2) = '0') then
        maintData(0) := data & x"00000000";
      else
        maintData(0) := x"00000000" & data ;
      end if;

      SendFrame(portIndex, RioFrameCreate(ackId=>"00000", vc=>'0', crf=>'0', prio=>"00",
                                          tt=>"01", ftype=>FTYPE_MAINTENANCE_CLASS, 
                                          sourceId=>sourceId, destId=>destinationId,
                                          payload=>RioMaintenance(transaction=>"0001",
                                                                  size=>"1000",
                                                                  tid=>tid,
                                                                  hopCount=>hop,
                                                                  configOffset=>address(23 downto 3),
                                                                  wdptr=>address(2),
                                                                  dataLength=>1,
                                                                  data=>maintData)));
      
      ReceiveFrame(portIndex, RioFrameCreate(ackId=>"00000", vc=>'0', crf=>'0', prio=>"00",
                                             tt=>"01", ftype=>FTYPE_MAINTENANCE_CLASS, 
                                             sourceId=>destinationId, destId=>sourceId,
                                             payload=>RioMaintenance(transaction=>"0011",
                                                                     size=>"0000",
                                                                     tid=>tid,
                                                                     hopCount=>x"ff",
                                                                     configOffset=>"000000000000000000000",
                                                                     wdptr=>'0',
                                                                     dataLength=>0,
                                                                     data=>maintData)));
    end procedure;

    ---------------------------------------------------------------------------
    -- Set a route table entry.
    ---------------------------------------------------------------------------
    procedure RouteSet(constant deviceId : std_logic_vector(15 downto 0);
                       constant portIndex : std_logic_vector(7 downto 0)) is
      variable frame : RioFrame;
    begin
      WriteConfig32(portIndex=>0, destinationId=>x"ffff", sourceId=>x"ffff", hop=>x"00",
                    tid=>x"de", address=>x"000070", data=>(x"0000" & deviceId));
      WriteConfig32(portIndex=>0, destinationId=>x"ffff", sourceId=>x"ffff", hop=>x"00",
                    tid=>x"ad", address=>x"000074", data=>(x"000000" & portIndex));
    end procedure;
    
    ---------------------------------------------------------------------------
    -- Set the default route table entry.
    ---------------------------------------------------------------------------
    procedure RouteSetDefault(constant portIndex : std_logic_vector(7 downto 0)) is
      variable frame : RioFrame;
    begin
      WriteConfig32(portIndex=>0, destinationId=>x"ffff", sourceId=>x"ffff", hop=>x"00",
                    tid=>x"ad", address=>x"000078", data=>(x"000000" & portIndex));
    end procedure;
    
    ---------------------------------------------------------------------------
    -- Send a frame on an ingress port and expect it at an egress port.
    ---------------------------------------------------------------------------
    procedure RouteFrame(constant sourcePortIndex : natural range 0 to 7;
                         constant destinationPortIndex : natural range 0 to 7;
                         constant sourceId : std_logic_vector(15 downto 0);
                         constant destinationId : std_logic_vector(15 downto 0);
                         constant payload : RioPayload) is
      variable frame : RioFrame;
    begin
      frame := RioFrameCreate(ackId=>"00000", vc=>'0', crf=>'0', prio=>"00",
                              tt=>"01", ftype=>"0000", 
                              sourceId=>sourceId, destId=>destinationId,
                              payload=>payload);
      
      frameExpected(destinationPortIndex) <= '1';
      frameRead(destinationPortIndex) <= frame;

      frameValid(sourcePortIndex) <= '1';
      frameWrite(sourcePortIndex) <= frame;
      wait until frameComplete(sourcePortIndex) = '1';
      frameValid(sourcePortIndex) <= '0';
      
      wait until frameReceived(destinationPortIndex) = '1';
      frameExpected(destinationPortIndex) <= '0';
      
    end procedure;

    ---------------------------------------------------------------------------
    -- Variable definitions.
    ---------------------------------------------------------------------------
    
    -- These variabels are needed for the random number generation.
    variable seed1 : positive := 1;
    variable seed2: positive := 1;

    variable data : DoubleWordArray(0 to 31);
    variable randomPayload : RioPayload;
    variable randomPayload1 : RioPayload;
    variable randomPayload2 : RioPayload;
    variable frame : RioFrameArray(0 to PORTS-1);
    
  begin
    areset_n <= '0';

    linkInitialized <= (others=>'0');
      
    for portIndex in 0 to PORTS-1 loop
      frameValid(portIndex) <= '0';
      frameExpected(portIndex) <= '0';
      localAckIdWrite(portIndex) <= '0';
      clrOutstandingAckId(portIndex) <= '0';
      inboundAckIdWrite(portIndex) <= (others=>'0');
      outstandingAckIdWrite(portIndex) <= (others=>'0');
      outboundAckIdWrite(portIndex) <= (others=>'0');
    end loop;
    
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    areset_n <= '1';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioSwitch");
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioSwitch-TC1");
    PrintS("Description: Test switch maintenance accesses on different ports.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: Send maintenance read request packets to read switch identity.");
    PrintS("Result: The switch should answer with its configured identitiy.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC1-Step1");
    ---------------------------------------------------------------------------
    
    ReadConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"00", address=>x"000000", data=>(SWITCH_IDENTITY & SWITCH_VENDOR_IDENTITY));
    ReadConfig32(portIndex=>1, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"01", address=>x"000004", data=>SWITCH_REV);
    ReadConfig32(portIndex=>2, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"02", address=>x"000008", data=>(SWITCH_ASSY_IDENTITY & SWITCH_ASSY_VENDOR_IDENTITY));
    ReadConfig32(portIndex=>3, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"03", address=>x"00000c", data=>(SWITCH_ASSY_REV & x"0100"));

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 2:");
    PrintS("Action: Check the switch Processing Element Features.");
    PrintS("Result: The expected switch features should be returned. ");
    PrintS("        Switch with extended features pointer valid. Common ");
    PrintS("        transport large system support and standard route table ");
    PrintS("        configuration support.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC1-Step2");
    ---------------------------------------------------------------------------

    ReadConfig32(portIndex=>4, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"04", address=>x"000010", data=>x"10000118");

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 3:");
    PrintS("Action: Check the switch port information.");
    PrintS("Result: The expected port and number of ports should be returned.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC1-Step3");
    ---------------------------------------------------------------------------

    ReadConfig32(portIndex=>5, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"05", address=>x"000014", data=>x"00000705");

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 4:");
    PrintS("Action: Check the switch number of supported routes.");
    PrintS("Result: The expected number of supported routes should be returned.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC1-Step4");
    ---------------------------------------------------------------------------

    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"000034", data=>x"00000800");

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 5:");
    PrintS("Action: Test host base device id lock by reading it, then hold it ");
    PrintS("        and try to grab it from another address.");
    PrintS("Result: The value should follow the specification.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC1-Step5");
    ---------------------------------------------------------------------------

    -- Check that the lock is released.
    ReadConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"00", address=>x"000068", data=>x"0000ffff");

    -- Try to accuire the lock.
    WriteConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"00", address=>x"000068", data=>x"00000002");

    -- Check that the lock has been accuired.
    ReadConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"00", address=>x"000068", data=>x"00000002");

    -- Try to accuire the lock from another source.
    WriteConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"00", address=>x"000068", data=>x"00000003");

    -- Check that the lock refuses the new access.
    ReadConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"00", address=>x"000068", data=>x"00000002");

    -- Release the lock.
    WriteConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"00", address=>x"000068", data=>x"00000002");

    -- Check that the lock is released.
    ReadConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"00", address=>x"000068", data=>x"0000ffff");
    
    -- Check that the lock can be accuired from another source once unlocked.
    WriteConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"00", address=>x"000068", data=>x"00000003");
    
    -- Check that the lock is released.
    ReadConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"00", address=>x"000068", data=>x"00000003");
    
    -- Release the lock again.
    WriteConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"00", address=>x"000068", data=>x"00000003");
    
    -- Check that the lock is released.
    ReadConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"00", address=>x"000068", data=>x"0000ffff");
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 6");
    PrintS("Action: Check the component tag register.");
    PrintS("Result: The written value in the component tag should be saved.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC1-Step6");
    ---------------------------------------------------------------------------

    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00006c", data=>x"00000000");

    WriteConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"06", address=>x"00006c", data=>x"ffffffff");

    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00006c", data=>x"ffffffff");

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 7");
    PrintS("Action: Read and write to the port link timeout.");
    PrintS("Result: Check that the portLinkTimeout output from the switch changes.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC1-Step7");
    ---------------------------------------------------------------------------

    assert portLinkTimeout = x"ffffff" report "Unexpected portLinkTimeout." severity error;
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"000120", data=>x"ffffff00");

    WriteConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"06", address=>x"000120", data=>x"00000100");

    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"000120", data=>x"00000100");

    assert portLinkTimeout = x"000001" report "Unexpected portLinkTimeout." severity error;

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 8");
    PrintS("Action: Read from the port general control.");
    PrintS("Result: Check the discovered bit.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC1-Step8");
    ---------------------------------------------------------------------------

    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00013c", data=>x"00000000");

    WriteConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"06", address=>x"00013c", data=>x"20000000");

    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00013c", data=>x"20000000");

    WriteConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"06", address=>x"00013c", data=>x"00000000");

    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00013c", data=>x"00000000");

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 9");
    PrintS("Action: Read from the port N error and status.");
    PrintS("Result: Check the port ok and port uninitialized bits.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC1-Step9");
    ---------------------------------------------------------------------------

    linkInitialized(0) <= '0';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"000158", data=>x"00000001");
    linkInitialized(0) <= '1';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"000158", data=>x"00000002");

    linkInitialized(1) <= '0';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"000178", data=>x"00000001");
    linkInitialized(1) <= '1';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"000178", data=>x"00000002");

    linkInitialized(2) <= '0';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"000198", data=>x"00000001");
    linkInitialized(2) <= '1';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"000198", data=>x"00000002");

    linkInitialized(3) <= '0';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"0001b8", data=>x"00000001");
    linkInitialized(3) <= '1';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"0001b8", data=>x"00000002");

    linkInitialized(4) <= '0';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"0001d8", data=>x"00000001");
    linkInitialized(4) <= '1';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"0001d8", data=>x"00000002");

    linkInitialized(5) <= '0';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"0001f8", data=>x"00000001");
    linkInitialized(5) <= '1';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"0001f8", data=>x"00000002");

    linkInitialized(6) <= '0';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"000218", data=>x"00000001");
    linkInitialized(6) <= '1';
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"000218", data=>x"00000002");

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 10");
    PrintS("Action: Read and write to/from the port N control.");
    PrintS("Result: Check the output/input port enable.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC1-Step10");
    ---------------------------------------------------------------------------

    assert outputPortEnable(0) = '0' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(0) = '0' report "Unexpected inputPortEnable." severity error;
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00015c", data=>x"00000001");

    WriteConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"06", address=>x"00015c", data=>x"00600001");
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00015c", data=>x"00600001");

    assert outputPortEnable(0) = '1' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(0) = '1' report "Unexpected inputPortEnable." severity error;

    ---------------------------------------------------------------------------
    
    assert outputPortEnable(1) = '0' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(1) = '0' report "Unexpected inputPortEnable." severity error;
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00017c", data=>x"00000001");

    WriteConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"06", address=>x"00017c", data=>x"00600001");
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00017c", data=>x"00600001");

    assert outputPortEnable(1) = '1' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(1) = '1' report "Unexpected inputPortEnable." severity error;

    ---------------------------------------------------------------------------
    
    assert outputPortEnable(2) = '0' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(2) = '0' report "Unexpected inputPortEnable." severity error;
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00019c", data=>x"00000001");

    WriteConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"06", address=>x"00019c", data=>x"00600001");
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00019c", data=>x"00600001");

    assert outputPortEnable(2) = '1' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(2) = '1' report "Unexpected inputPortEnable." severity error;

    ---------------------------------------------------------------------------
    
    assert outputPortEnable(3) = '0' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(3) = '0' report "Unexpected inputPortEnable." severity error;
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"0001bc", data=>x"00000001");

    WriteConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"06", address=>x"0001bc", data=>x"00600001");
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"0001bc", data=>x"00600001");

    assert outputPortEnable(3) = '1' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(3) = '1' report "Unexpected inputPortEnable." severity error;

    ---------------------------------------------------------------------------
    
    assert outputPortEnable(4) = '0' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(4) = '0' report "Unexpected inputPortEnable." severity error;
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"0001dc", data=>x"00000001");

    WriteConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"06", address=>x"0001dc", data=>x"00600001");
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"0001dc", data=>x"00600001");

    assert outputPortEnable(4) = '1' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(4) = '1' report "Unexpected inputPortEnable." severity error;

    ---------------------------------------------------------------------------
    
    assert outputPortEnable(5) = '0' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(5) = '0' report "Unexpected inputPortEnable." severity error;
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"0001fc", data=>x"00000001");

    WriteConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"06", address=>x"0001fc", data=>x"00600001");
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"0001fc", data=>x"00600001");

    assert outputPortEnable(5) = '1' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(5) = '1' report "Unexpected inputPortEnable." severity error;

    ---------------------------------------------------------------------------
    
    assert outputPortEnable(6) = '0' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(6) = '0' report "Unexpected inputPortEnable." severity error;
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00021c", data=>x"00000001");

    WriteConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"06", address=>x"00021c", data=>x"00600001");
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"00021c", data=>x"00600001");

    assert outputPortEnable(6) = '1' report "Unexpected outputPortEnable." severity error;
    assert inputPortEnable(6) = '1' report "Unexpected inputPortEnable." severity error;
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 11");
    PrintS("Action: Read and write to/from the implementation defined space.");
    PrintS("Result: Check the accesses on the external configuration port.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC1-Step11");
    ---------------------------------------------------------------------------

    configStbExpected <= '1';
    configWeExpected <= '0';
    configAddrExpected <= x"010000";
    configDataReadExpected <= x"deadbeef";
    
    ReadConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"06", address=>x"010000", data=>x"deadbeef");

    configStbExpected <= '1';
    configWeExpected <= '1';
    configAddrExpected <= x"010004";
    configDataWriteExpected <= x"c0debabe";
    
    WriteConfig32(portIndex=>6, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"06", address=>x"010004", data=>x"c0debabe");

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioSwitch-TC2");
    PrintS("Description: Test the configuration of the routing table and the ");
    PrintS("             routing of packets.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: Configure the routing table for address 0->port 1.");
    PrintS("Result: A packet to address 0 should be forwarded to port 1.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC2-Step1");
    ---------------------------------------------------------------------------

    ReadConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"07", address=>x"000070", data=>x"00000000");
    WriteConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"08", address=>x"000074", data=>x"00000001");
    ReadConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"09", address=>x"000074", data=>x"00000001");

    -- Send a frame from a port and check if it is correctly routed.
    randomPayload.length := 3;
    CreateRandomPayload(randomPayload.data, seed1, seed2);
    RouteFrame(sourcePortIndex=>0, destinationPortIndex=>1,
               sourceId=>x"ffff", destinationId=>x"0000", payload=>randomPayload);
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 2:");
    PrintS("Action: Test the configuration of the default route->port 6.");
    PrintS("Result: An unknown address should be routed to port 6.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC2-Step2");
    ---------------------------------------------------------------------------

    ReadConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"0a", address=>x"000078", data=>x"00000000");
    WriteConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                  tid=>x"0b", address=>x"000078", data=>x"00000006");
    ReadConfig32(portIndex=>0, destinationId=>x"0000", sourceId=>x"0002", hop=>x"00",
                 tid=>x"0c", address=>x"000078", data=>x"00000006");
    
    -- Send a frame from a port and check if it is correctly routed.
    randomPayload.length := 4;
    CreateRandomPayload(randomPayload.data, seed1, seed2);
    RouteFrame(sourcePortIndex=>1, destinationPortIndex=>6,
               sourceId=>x"0000", destinationId=>x"ffff", payload=>randomPayload);
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioSwitch-TC3");
    PrintS("Description: Test the routing of normal packets.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: Send two packets but not at the same time.");
    PrintS("Result: Both packets should be received at the expected ports.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC3-Step1");
    ---------------------------------------------------------------------------

    -- Setup the routing table for the following steps.
    RouteSet(x"0000", x"00");
    RouteSet(x"0001", x"00");
    RouteSet(x"0002", x"00");
    RouteSet(x"0003", x"00");
    RouteSet(x"0004", x"01");
    RouteSet(x"0005", x"02");
    RouteSet(x"0006", x"03");
    RouteSetDefault(x"06");
    
    -- Frame on port 0 to port 1.
    randomPayload.length := 3;
    CreateRandomPayload(randomPayload.data, seed1, seed2);
    SendFrame(portIndex=>0,
              sourceId=>x"ffff", destinationId=>x"0004", payload=>randomPayload);
    ReceiveFrame(portIndex=>1,
                 sourceId=>x"ffff", destinationId=>x"0004", payload=>randomPayload);

    -- Frame on port 1 to port 6.
    randomPayload.length := 4;
    CreateRandomPayload(randomPayload.data, seed1, seed2);
    SendFrame(portIndex=>1,
              sourceId=>x"0000", destinationId=>x"ffff", payload=>randomPayload);
    ReceiveFrame(portIndex=>6,
                 sourceId=>x"0000", destinationId=>x"ffff", payload=>randomPayload);

    wait until frameComplete(1) = '1';
    frameValid(1) <= '0';
    wait until frameReceived(6) = '1';
    frameExpected(6) <= '0';

    wait until frameComplete(0) = '1';
    frameValid(0) <= '0';
    wait until frameReceived(1) = '1';
    frameExpected(1) <= '0';
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 2:");
    PrintS("Action: Send two packets to the same port that is full and one to");
    PrintS("        another that is also full. Then receive the packets one at");
    PrintS("        a time.");
    PrintS("Result: The packet to the port that is ready should go though.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioSwitch-TC3-Step2");
    ---------------------------------------------------------------------------

    -- Frame on port 0 to port 1.
    randomPayload.length := 5;
    CreateRandomPayload(randomPayload.data, seed1, seed2);
    SendFrame(portIndex=>0,
              sourceId=>x"ffff", destinationId=>x"0004", payload=>randomPayload);

    -- Frame on port 1 to port 2.
    randomPayload1.length := 6;
    CreateRandomPayload(randomPayload1.data, seed1, seed2);
    SendFrame(portIndex=>1,
              sourceId=>x"0000", destinationId=>x"0005", payload=>randomPayload1);

    -- Frame on port 2 to port 2.
    randomPayload2.length := 7;
    CreateRandomPayload(randomPayload2.data, seed1, seed2);
    SendFrame(portIndex=>2,
              sourceId=>x"0000", destinationId=>x"0005", payload=>randomPayload2);

    wait for 10 us;

    ReceiveFrame(portIndex=>1,
                 sourceId=>x"ffff", destinationId=>x"0004", payload=>randomPayload);
    wait until frameComplete(0) = '1';
    frameValid(0) <= '0';
    wait until frameReceived(1) = '1';
    frameExpected(1) <= '0';
    
    wait for 10 us;
    
    ReceiveFrame(portIndex=>2,
                 sourceId=>x"0000", destinationId=>x"0005", payload=>randomPayload1);
    wait until frameComplete(1) = '1';
    frameValid(1) <= '0';
    wait until frameReceived(2) = '1';
    frameExpected(2) <= '0';
    
    wait for 10 us;
    
    ReceiveFrame(portIndex=>2,
                 sourceId=>x"0000", destinationId=>x"0005", payload=>randomPayload2);
    wait until frameComplete(2) = '1';
    frameValid(2) <= '0';
    wait until frameReceived(2) = '1';
    frameExpected(2) <= '0';
    
    ---------------------------------------------------------------------------
    -- Test completed.
    ---------------------------------------------------------------------------
    
    wait for 10 us;

    assert readFrameEmpty = "1111111"
      report "Pending frames exist." severity error;

    TestEnd;
  end process;

  -----------------------------------------------------------------------------
  -- Instantiate a process receiving the configuration accesses to the
  -- implementation defined space.
  -----------------------------------------------------------------------------
  process
  begin
    loop
      wait until configStb = '1' and clk'event and clk = '1';
      assert configStb = configStbExpected report "Unexpected configStb." severity error;
      assert configWe = configWeExpected report "Unexpected configWe." severity error;
      assert configAddr = configAddrExpected report "Unexpected configAddr." severity error;
      if (configWe = '1') then
        assert configDataWrite = configDataWriteExpected report "Unexpected configDataWrite." severity error;
      else
        configDataRead <= configDataReadExpected;
      end if;
    end loop;
  end process;
  
  -----------------------------------------------------------------------------
  -- Instantiate the test port array.
  -----------------------------------------------------------------------------
  
  TestPortGeneration: for portIndex in 0 to PORTS-1 generate
    TestPortInst: TestPort
      port map(
        clk=>clk, areset_n=>areset_n, 
        frameValid_i=>frameValid(portIndex),
        frameWrite_i=>frameWrite(portIndex), 
        frameComplete_o=>frameComplete(portIndex), 
        frameExpected_i=>frameExpected(portIndex), 
        frameRead_i=>frameRead(portIndex), 
        frameReceived_o=>frameReceived(portIndex), 
        readFrameEmpty_o=>readFrameEmpty(portIndex), 
        readFrame_i=>readFrame(portIndex), 
        readContent_i=>readContent(portIndex), 
        readContentEnd_o=>readContentEnd(portIndex), 
        readContentData_o=>readContentData(portIndex), 
        writeFrameFull_o=>writeFrameFull(portIndex), 
        writeFrame_i=>writeFrame(portIndex), 
        writeFrameAbort_i=>writeFrameAbort(portIndex), 
        writeContent_i=>writeContent(portIndex), 
        writeContentData_i=>writeContentData(portIndex));
  end generate;

  -----------------------------------------------------------------------------
  -- Instantiate the switch.
  -----------------------------------------------------------------------------

  TestSwitch: RioSwitch
    generic map(
      SWITCH_PORTS=>7,
      DEVICE_IDENTITY=>SWITCH_IDENTITY,
      DEVICE_VENDOR_IDENTITY=>SWITCH_VENDOR_IDENTITY,
      DEVICE_REV=>SWITCH_REV,
      ASSY_IDENTITY=>SWITCH_ASSY_IDENTITY,
      ASSY_VENDOR_IDENTITY=>SWITCH_ASSY_VENDOR_IDENTITY,
      ASSY_REV=>SWITCH_ASSY_REV)
    port map(
      clk=>clk, areset_n=>areset_n, 
      writeFrameFull_i=>writeFrameFull,
      writeFrame_o=>writeFrame,
      writeFrameAbort_o=>writeFrameAbort, 
      writeContent_o=>writeContent,
      writeContentData_o=>writeContentData, 
      readFrameEmpty_i=>readFrameEmpty, 
      readFrame_o=>readFrame,
      readContent_o=>readContent,
      readContentEnd_i=>readContentEnd,
      readContentData_i=>readContentData,
      portLinkTimeout_o=>portLinkTimeout,
      linkInitialized_i=>linkInitialized,
      outputPortEnable_o=>outputPortEnable,
      inputPortEnable_o=>inputPortEnable,
      localAckIdWrite_o=>localAckIdWrite, 
      clrOutstandingAckId_o=>clrOutstandingAckId, 
      inboundAckId_o=>inboundAckIdWrite, 
      outstandingAckId_o=>outstandingAckIdWrite, 
      outboundAckId_o=>outboundAckIdWrite, 
      inboundAckId_i=>inboundAckIdRead, 
      outstandingAckId_i=>outstandingAckIdRead, 
      outboundAckId_i=>outboundAckIdRead, 
      configStb_o=>configStb, configWe_o=>configWe, configAddr_o=>configAddr,
      configData_o=>configDataWrite, configData_i=>configDataRead);
  
  
end architecture;



-------------------------------------------------------------------------------
-- Switch port test stub.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
use work.rio_common.all;
 

-------------------------------------------------------------------------------
-- Entity for TestPort.
-------------------------------------------------------------------------------
entity TestPort is
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    frameValid_i : in std_logic;
    frameWrite_i : in RioFrame;
    frameComplete_o : out std_logic;
    
    frameExpected_i : in std_logic;
    frameRead_i : in RioFrame;
    frameReceived_o : out std_logic;

    readFrameEmpty_o : out std_logic;
    readFrame_i : in std_logic;
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
-- Architecture for TestPort.
-------------------------------------------------------------------------------
architecture TestPortImpl of TestPort is
begin
  
  -----------------------------------------------------------------------------
  -- Egress frame receiver.
  -----------------------------------------------------------------------------
  FrameReader: process
    type StateType is (STATE_IDLE, STATE_WRITE);
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
            writeFrameFull_o <= '0';
            state := STATE_WRITE;
            frameIndex := 0;
          else
            writeFrameFull_o <= '1';
          end if;
          assert writeFrame_i = '0' report "Unexpected frame." severity error;
          assert writeFrameAbort_i = '0' report "Unexpected frame abort." severity error;
          assert writeContent_i = '0' report "Unexpected data." severity error;
          
        when STATE_WRITE =>
          if (writeContent_i = '1') then
            -- Writing content.
            if (frameIndex < frameRead_i.length) then
              assert writeContentData_i = frameRead_i.payload(frameIndex)
                report "Unexpected frame content received:" &
                " index=" & integer'image(frameIndex) &
                " expected=" & integer'image(to_integer(unsigned(frameRead_i.payload(frameIndex)))) &
                " got=" & integer'image(to_integer(unsigned(writeContentData_i)))
                severity error;
              
              frameIndex := frameIndex + 1;
            else
              report "Unexpected frame content received:" &
                " index=" & integer'image(frameIndex) &
                " expected=" & integer'image(to_integer(unsigned(frameRead_i.payload(frameIndex)))) &
                " got=" & integer'image(to_integer(unsigned(writeContentData_i)))
                severity error;
              
              frameIndex := frameIndex + 1;
            end if;
          else
            -- Not writing any content.
          end if;
          
          if (writeFrame_i = '1') then
            -- Writing a complete frame.
            assert frameIndex = frameRead_i.length report "Unexpected frame length received." severity error;
            state := STATE_IDLE;
            frameReceived_o <= '1';
            writeFrameFull_o <= '1';
          else
            -- Not writing any frame.
          end if;

          if (writeFrameAbort_i = '1') then
            -- The frame should be aborted.
            frameIndex := 0;
          else
            -- Not aborting any frame.
          end if;
      end case;
    end loop;    
  end process;

  -----------------------------------------------------------------------------
  -- Ingress frame sender.
  -----------------------------------------------------------------------------
  FrameSender: process
    type StateType is (STATE_IDLE, STATE_READ);
    variable state : StateType;
    variable frameIndex : natural range 0 to 69;
  begin
    readFrameEmpty_o <= '1';
    readContentEnd_o <= '1';
    readContentData_o <= (others => 'U');
    frameComplete_o <= '0';
    wait until areset_n = '1';

    state := STATE_IDLE;

    loop
      wait until clk'event and clk = '1';
    
      case state is

        when STATE_IDLE =>
          frameComplete_o <= '0';
          if (frameValid_i = '1') then
            state := STATE_READ;
            frameIndex := 0;
            readFrameEmpty_o <= '0';
          end if;
          
        when STATE_READ =>
          if (readContent_i = '1') then
            if (frameIndex < frameWrite_i.length) then
              readContentData_o <= frameWrite_i.payload(frameIndex);
              readContentEnd_o <= '0';
              frameIndex := frameIndex + 1;
            elsif (frameIndex = frameWrite_i.length) then
              readContentEnd_o <= '1';
            else
              report "Reading empty frame." severity error;
            end if;
          else
            -- Not reading data.
          end if;

          if (readFrame_i = '1') then
            state := STATE_IDLE;
            assert frameIndex = frameWrite_i.length report "Unread frame data discarded." severity error;
            frameComplete_o <= '1';
            readFrameEmpty_o <= '1';
            readContentData_o <= (others => 'U');
          else
            -- Not reading a frame.
          end if;

      end case;
    end loop;
  end process;

end architecture;
