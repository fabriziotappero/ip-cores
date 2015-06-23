-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- Description
-- Contains automatic simulation test code to verify a RioPacketBufferWindow
-- implementation.
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
-- TestRioPacketBuffer.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library std;
use std.textio.all;
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for TestRioPacketBuffer.
-------------------------------------------------------------------------------
entity TestRioPacketBuffer is
end entity;


-------------------------------------------------------------------------------
-- Architecture for TestRioPacketBuffer.
-------------------------------------------------------------------------------
architecture TestRioPacketBufferImpl of TestRioPacketBuffer is
  
  component RioPacketBufferWindow is
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      inboundWriteFrameFull_o : out std_logic;
      inboundWriteFrame_i : in std_logic;
      inboundWriteFrameAbort_i : in std_logic;
      inboundWriteContent_i : in std_logic;
      inboundWriteContentData_i : in std_logic_vector(31 downto 0);
      inboundReadFrameEmpty_o : out std_logic;
      inboundReadFrame_i : in std_logic;
      inboundReadFrameRestart_i : in std_logic;
      inboundReadFrameAborted_o : out std_logic;
      inboundReadContentEmpty_o : out std_logic;
      inboundReadContent_i : in std_logic;
      inboundReadContentEnd_o : out std_logic;
      inboundReadContentData_o : out std_logic_vector(31 downto 0);
      
      outboundWriteFrameFull_o : out std_logic;
      outboundWriteFrame_i : in std_logic;
      outboundWriteFrameAbort_i : in std_logic;
      outboundWriteContent_i : in std_logic;
      outboundWriteContentData_i : in std_logic_vector(31 downto 0);
      outboundReadFrameEmpty_o : out std_logic;
      outboundReadFrame_i : in std_logic;
      outboundReadFrameRestart_i : in std_logic;
      outboundReadFrameAborted_o : out std_logic;
      outboundReadWindowEmpty_o : out std_logic;
      outboundReadWindowReset_i : in std_logic;
      outboundReadWindowNext_i : in std_logic;
      outboundReadContentEmpty_o : out std_logic;
      outboundReadContent_i : in std_logic;
      outboundReadContentEnd_o : out std_logic;
      outboundReadContentData_o : out std_logic_vector(31 downto 0));
  end component;

  signal clk : std_logic;
  signal areset_n : std_logic;

  signal inboundWriteFrameFull : std_logic;
  signal inboundWriteFrame : std_logic;
  signal inboundWriteFrameAbort : std_logic;
  signal inboundWriteContent : std_logic;
  signal inboundWriteContentData : std_logic_vector(31 downto 0);
  signal inboundReadFrameEmpty : std_logic;
  signal inboundReadFrame : std_logic;
  signal inboundReadFrameRestart : std_logic;
  signal inboundReadFrameAborted : std_logic;
  signal inboundReadContentEmpty : std_logic;
  signal inboundReadContent : std_logic;
  signal inboundReadContentEnd : std_logic;
  signal inboundReadContentData : std_logic_vector(31 downto 0);
      
  signal outboundWriteFrameFull : std_logic;
  signal outboundWriteFrame : std_logic;
  signal outboundWriteFrameAbort : std_logic;
  signal outboundWriteContent : std_logic;
  signal outboundWriteContentData : std_logic_vector(31 downto 0);
  signal outboundReadFrameEmpty : std_logic;
  signal outboundReadFrame : std_logic;
  signal outboundReadFrameRestart : std_logic;
  signal outboundReadFrameAborted : std_logic;
  signal outboundReadWindowEmpty : std_logic;
  signal outboundReadWindowReset : std_logic;
  signal outboundReadWindowNext : std_logic;
  signal outboundReadContentEmpty : std_logic;
  signal outboundReadContent : std_logic;
  signal outboundReadContentEnd : std_logic;
  signal outboundReadContentData : std_logic_vector(31 downto 0);
  
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
  -- Test case driver.
  -----------------------------------------------------------------------------
  TestDriver: process
    ---------------------------------------------------------------------------
    -- Inbound procedures.
    ---------------------------------------------------------------------------
    
    procedure SetInboundWriteContent(
      constant content : in std_logic_vector(31 downto 0)) is
    begin
      assert inboundWriteFrameFull = '0'
        report "Inbound frame cannot be accepted." severity error;
      
      inboundWriteContent <= '1';
      inboundWriteContentData <= content;
      wait until clk'event and clk = '1';
      wait for 1 ns;
      inboundWriteContent <= '0';
      inboundWriteContentData <= (others=>'U');
    end procedure;

    procedure SetInboundWriteFrame is
    begin
      inboundWriteFrame <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      inboundWriteFrame <= '0';
    end procedure;
    
    procedure SetInboundWriteFrameAbort is
    begin
      inboundWriteFrameAbort <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      inboundWriteFrameAbort <= '0';
    end procedure;
    
    procedure SetInboundReadContent(
      constant content : in std_logic_vector(31 downto 0)) is
    begin
      inboundReadContent <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      assert (inboundReadContentData = content)
        report "Unexpected content read." severity error;
      assert (inboundReadContentEnd = '0')
        report "Unexpected content end." severity error;
      
      inboundReadContent <= '0';
    end procedure;

    procedure SetInboundReadContentEnd is
    begin
      inboundReadContent <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      assert (inboundReadContentEnd = '1')
        report "Unexpected content end." severity error;
      
      inboundReadContent <= '0';
    end procedure;

    procedure SetInboundReadFrame is
    begin
      assert inboundReadFrameEmpty = '0'
        report "No pending inbound frame to be read." severity error;
      
      inboundReadFrame <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      inboundReadFrame <= '0';
    end procedure;
    
    procedure SetInboundReadFrameRestart is
    begin
      inboundReadFrameRestart <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      inboundReadFrameRestart <= '0';
    end procedure;

    ---------------------------------------------------------------------------
    -- Outbound procedures.
    ---------------------------------------------------------------------------
    
    procedure SetOutboundWriteContent(
      constant content : in std_logic_vector(31 downto 0)) is
    begin
      assert outboundWriteFrameFull = '0'
        report "Outbound frame cannot be accepted." severity error;
      
      outboundWriteContent <= '1';
      outboundWriteContentData <= content;
      wait until clk'event and clk = '1';
      wait for 1 ns;
      outboundWriteContent <= '0';
      outboundWriteContentData <= (others=>'U');
    end procedure;

    procedure SetOutboundWriteFrame is
    begin
      assert outboundWriteFrameFull = '0'
        report "Outbound frame cannot be accepted." severity error;
      
      outboundWriteFrame <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      outboundWriteFrame <= '0';
    end procedure;
    
    procedure SetOutboundWriteFrameAbort is
    begin
      outboundWriteFrameAbort <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      outboundWriteFrameAbort <= '0';
    end procedure;
    
    procedure SetOutboundReadContent(
      constant content : in std_logic_vector(31 downto 0)) is
    begin
      outboundReadContent <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      assert (outboundReadContentData = content)
        report "Unexpected content read." severity error;
      assert (outboundReadContentEnd = '0')
        report "Unexpected content end." severity error;
      
      outboundReadContent <= '0';
    end procedure;

    procedure SetOutboundReadContentEnd is
    begin
      outboundReadContent <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      assert (outboundReadContentEnd = '1')
        report "Unexpected content end." severity error;
      
      outboundReadContent <= '0';
    end procedure;

    procedure SetOutboundReadFrame is
    begin
      assert outboundReadFrameEmpty = '0'
        report "No pending outbound frame to be read." severity error;
      
      outboundReadFrame <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      outboundReadFrame <= '0';
    end procedure;
    
    procedure SetOutboundReadFrameRestart is
    begin
      outboundReadFrameRestart <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      outboundReadFrameRestart <= '0';
    end procedure;
    
    procedure SetOutboundReadWindowReset is
    begin
      outboundReadWindowReset <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      outboundReadWindowReset <= '0';
    end procedure;
    
    procedure SetOutboundReadWindowNext is
    begin
      assert outboundReadWindowEmpty = '0'
        report "No pending outbound window frame to be read." severity error;
      
      outboundReadWindowNext <= '1';
      wait until clk'event and clk = '1';
      wait for 1 ns;
      
      outboundReadWindowNext <= '0';
    end procedure;
    
  begin
    inboundWriteFrame <= '0';
    inboundWriteFrameAbort <= '0';
    inboundWriteContent <= '0';
    inboundWriteContentData <= (others=>'U');
    inboundReadFrame <= '0';
    inboundReadFrameRestart <= '0';
    inboundReadContent <= '0';
    
    outboundWriteFrame <= '0';
    outboundWriteFrameAbort <= '0';
    outboundWriteContent <= '0';
    outboundWriteContentData <= (others=>'U');
    outboundReadFrame <= '0';
    outboundReadFrameRestart <= '0';
    outboundReadWindowReset <= '0';
    outboundReadWindowNext <= '0';
    outboundReadContent <= '0';
    
    areset_n <= '0';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    areset_n <= '1';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioPacketBuffer");
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioPacketBuffer-TC1");
    PrintS("Description: Test normal operation without using the window. Only");
    PrintS("             full frames are tested.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: Complete a small frame and read it.");
    PrintS("Result: The read frame should be equal to the one written.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC1-Step1");
    ---------------------------------------------------------------------------
    -- REMARK: Update testcases for inbound and outbound...

    assert (inboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;

    SetInboundWriteContent(x"deadbeef");

    assert (inboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;

    SetInboundWriteFrame;

    assert (inboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;

    SetInboundReadContent(x"deadbeef");

    assert (inboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    
    SetInboundReadContentEnd;

    assert (inboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
        
    SetInboundReadFrame;
    
    assert (inboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
        
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 2:");
    PrintS("Action: Write a rio maximum size frame and read it.");
    PrintS("Result: The read frame should be equal to the one written.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC1-Step2");
    ---------------------------------------------------------------------------

    for i in 0 to 68 loop
      SetInboundWriteContent(std_logic_vector(to_unsigned(i, 32)));
      
      assert (inboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (inboundReadFrameEmpty = '1')
        report "Unexpected readFrameEmpty." severity error;
    end loop;
    
    SetInboundWriteFrame;

    assert (inboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    
    for i in 0 to 68 loop
      SetInboundReadContent(std_logic_vector(to_unsigned(i, 32)));
      
      assert (inboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (inboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
    end loop;
    
    SetInboundReadContentEnd;

    assert (inboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    
    SetInboundReadFrame;
    
    assert (inboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 3:");
    PrintS("Action: Fill the maximum number of small frames without filling ");
    PrintS("        the memory.");
    PrintS("Result: The frame buffer should accept 63 frames.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC1-Step3");
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Write maximum number of frames.
    ---------------------------------------------------------------------------
    
    for i in 0 to 2 loop
      SetInboundWriteContent(std_logic_vector(to_unsigned(i, 32)));
      assert (inboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (inboundReadFrameEmpty = '1')
        report "Unexpected readFrameEmpty." severity error;
    end loop;

    for j in 1 to 62 loop
      SetInboundWriteFrame;
      assert (inboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (inboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      
      for i in 0 to 2 loop
        SetInboundWriteContent(std_logic_vector(to_unsigned(j+i, 32)));
        
        assert (inboundWriteFrameFull = '0')
          report "Unexpected writeFrameFull." severity error;
        assert (inboundReadFrameEmpty = '0')
          report "Unexpected readFrameEmpty." severity error;
      end loop;
    end loop;

    SetInboundWriteFrame;
    assert (inboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Read the frames written in the above steps.
    ---------------------------------------------------------------------------
    
    for i in 0 to 2 loop
      SetInboundReadContent(std_logic_vector(to_unsigned(i, 32)));

      assert (inboundWriteFrameFull = '1')
        report "Unexpected writeFrameFull." severity error;
      assert (inboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
    end loop;
    
    SetInboundReadContentEnd;
    assert (inboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    
    for j in 1 to 62 loop
      SetInboundReadFrame;
      assert (inboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (inboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      
      for i in 0 to 2 loop
        SetInboundReadContent(std_logic_vector(to_unsigned(j+i, 32)));

        assert (inboundWriteFrameFull = '0')
          report "Unexpected writeFrameFull." severity error;
        assert (inboundReadFrameEmpty = '0')
          report "Unexpected readFrameEmpty." severity error;
      end loop;
      
      SetInboundReadContentEnd;
      assert (inboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (inboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
    end loop;
    
    SetInboundReadFrame;
    assert (inboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 4:");
    PrintS("Action: Fill the memory to its limit.");
    PrintS("Result: The frame buffer should accept 255-69 words.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC1-Step4");
    ---------------------------------------------------------------------------

    for i in 0 to 186 loop
      SetInboundWriteContent(std_logic_vector(to_unsigned(i, 32)));
      assert (inboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (inboundReadFrameEmpty = '1')
        report "Unexpected readFrameEmpty." severity error;
    end loop;

    SetInboundWriteFrame;
    assert (inboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    
    ---------------------------------------------------------------------------
    
    for i in 0 to 186 loop
      SetInboundReadContent(std_logic_vector(to_unsigned(i, 32)));
      
      assert (inboundWriteFrameFull = '1')
        report "Unexpected writeFrameFull." severity error;
      assert (inboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
    end loop;

    SetInboundReadContentEnd;
    assert (inboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;

    SetInboundReadFrame;
    assert (inboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (inboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioPacketBuffer-TC2");
    PrintS("Description: Test operation when using the window.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: Add one frame and update the window.");
    PrintS("Result: The window empty flag and the read frame empty flag should");
    PrintS("        be updated and it should be possible to read the frame again.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC2-Step1");
    ---------------------------------------------------------------------------

    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    for i in 0 to 2 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '1')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '1')
        report "Unexpected readWindowEmpty." severity error;
    end loop;
    
    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    
    for i in 0 to 2 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowReset;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 2 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;
    
    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 2:");
    PrintS("Action: Add two frames and test the window accesses.");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC2-Step2");
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Write two frames.
    ---------------------------------------------------------------------------
    
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    for i in 0 to 2 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(1+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '1')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '1')
        report "Unexpected readWindowEmpty." severity error;
    end loop;
    
    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 2 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(2+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;
    
    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Read the frames using the window mechanism.
    ---------------------------------------------------------------------------
    
    for i in 0 to 2 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(1+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;
    
    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    for i in 0 to 2 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(2+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Reset the window and read the frames again.
    ---------------------------------------------------------------------------
    
    SetOutboundReadWindowReset;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    for i in 0 to 2 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(1+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 2 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(2+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Remove one frame and access the remaining frame.
    ---------------------------------------------------------------------------
    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadWindowReset;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    for i in 0 to 2 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(2+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Remove the remaining frame.
    ---------------------------------------------------------------------------

    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadWindowReset;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 3:");
    PrintS("Action: Add maximum number of frames and test the window accesses.");
    PrintS("Result: The buffer should be full and not accept more frames.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC2-Step3");
    ---------------------------------------------------------------------------

    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Write 3*63 frames => maximum number of frames.  
    ---------------------------------------------------------------------------
    
    for i in 0 to 2 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '1')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '1')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    for j in 1 to 62 loop
      SetOutboundWriteFrame;
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;

      for i in 0 to 2 loop
        SetOutboundWriteContent(std_logic_vector(to_unsigned(j+i, 32)));
        assert (outboundWriteFrameFull = '0')
          report "Unexpected writeFrameFull." severity error;
        assert (outboundReadFrameEmpty = '0')
          report "Unexpected readFrameEmpty." severity error;
        assert (outboundReadWindowEmpty = '0')
          report "Unexpected readWindowEmpty." severity error;
      end loop;
    end loop;
      
    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Read the whole window until it is empty.
    ---------------------------------------------------------------------------

    for j in 0 to 61 loop
      for i in 0 to 2 loop
        SetOutboundReadContent(std_logic_vector(to_unsigned(j+i, 32)));
        assert (outboundWriteFrameFull = '1')
          report "Unexpected writeFrameFull." severity error;
        assert (outboundReadFrameEmpty = '0')
          report "Unexpected readFrameEmpty." severity error;
        assert (outboundReadWindowEmpty = '0')
          report "Unexpected readWindowEmpty." severity error;
      end loop;

      SetOutboundReadContentEnd;
      assert (outboundWriteFrameFull = '1')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;

      SetOutboundReadWindowNext;
      assert (outboundWriteFrameFull = '1')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;
      
    for i in 0 to 2 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(62+i, 32)));
      assert (outboundWriteFrameFull = '1')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Reset the window and remove all frames.
    ---------------------------------------------------------------------------

    SetOutboundReadWindowReset;
    assert (outboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for j in 0 to 61 loop
      SetOutboundReadFrame;
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadWindowReset;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 2 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(62+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 4:");
    PrintS("Action: Add maximum number of words and test the window accesses.");
    PrintS("Result: The content memory should be full.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC2-Step4");
    ---------------------------------------------------------------------------

    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Write 6*31+69=255 words and 7 frames => full content.  
    ---------------------------------------------------------------------------
    
    for i in 0 to 30 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '1')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '1')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    for j in 1 to 5 loop
      SetOutboundWriteFrame;
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;

      for i in 0 to 30 loop
        SetOutboundWriteContent(std_logic_vector(to_unsigned(j+i, 32)));
        assert (outboundWriteFrameFull = '0')
          report "Unexpected writeFrameFull." severity error;
        assert (outboundReadFrameEmpty = '0')
          report "Unexpected readFrameEmpty." severity error;
        assert (outboundReadWindowEmpty = '0')
          report "Unexpected readWindowEmpty." severity error;
      end loop;
    end loop;
      
    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 68 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(1024+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Read the whole window until it is empty.
    ---------------------------------------------------------------------------

    for j in 0 to 5 loop
      for i in 0 to 30 loop
        SetOutboundReadContent(std_logic_vector(to_unsigned(j+i, 32)));
        assert (outboundWriteFrameFull = '1')
          report "Unexpected writeFrameFull." severity error;
        assert (outboundReadFrameEmpty = '0')
          report "Unexpected readFrameEmpty." severity error;
        assert (outboundReadWindowEmpty = '0')
          report "Unexpected readWindowEmpty." severity error;
      end loop;

      SetOutboundReadContentEnd;
      assert (outboundWriteFrameFull = '1')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;

      SetOutboundReadWindowNext;
      assert (outboundWriteFrameFull = '1')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;
      
    for i in 0 to 68 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(1024+i, 32)));
      assert (outboundWriteFrameFull = '1')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Reset the window and remove all frames.
    ---------------------------------------------------------------------------
    
    SetOutboundReadWindowReset;
    assert (outboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for j in 0 to 1 loop
      SetOutboundReadFrame;
      assert (outboundWriteFrameFull = '1')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;
    
    for j in 2 to 5 loop
      SetOutboundReadFrame;
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;
    
    SetOutboundReadWindowReset;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 68 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(1024+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 5:");
    PrintS("Action: Add maximum number of words -1 and test the window accesses.");
    PrintS("Result: The content memory should not accept more frames.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC2-Step5");
    ---------------------------------------------------------------------------

    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Write 11*17=187 (one full frame will not fit).
    ---------------------------------------------------------------------------
    
    for i in 0 to 16 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '1')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '1')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    for j in 1 to 10 loop
      SetOutboundWriteFrame;
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;

      for i in 0 to 16 loop
        SetOutboundWriteContent(std_logic_vector(to_unsigned(j+i, 32)));
        assert (outboundWriteFrameFull = '0')
          report "Unexpected writeFrameFull." severity error;
        assert (outboundReadFrameEmpty = '0')
          report "Unexpected readFrameEmpty." severity error;
        assert (outboundReadWindowEmpty = '0')
          report "Unexpected readWindowEmpty." severity error;
      end loop;
    end loop;
      
    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- Reset the window and remove all frames.
    ---------------------------------------------------------------------------
    
    SetOutboundReadWindowReset;
    assert (outboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '1')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    for j in 1 to 9 loop
      SetOutboundReadWindowNext;
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
      
      SetOutboundReadFrame;
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;
    
    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 6:");
    PrintS("Action: Add two frames and start reading the second, then remove");
    PrintS("        the first.");
    PrintS("Result: The readContentEnd flag should not be changed when frames");
    PrintS("        are removed.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC2-Step6");
    ---------------------------------------------------------------------------

    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------
    
    for i in 0 to 3 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '1')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '1')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 3 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(i+1, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------

    for i in 0 to 3 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadContent(std_logic_vector(to_unsigned(1, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadContent(std_logic_vector(to_unsigned(2, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadContent(std_logic_vector(to_unsigned(3, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadContent(std_logic_vector(to_unsigned(4, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioPacketBuffer");
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioPacketBuffer-TC3");
    PrintS("Description: Test operation when restarting and aborting frames.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: Write one frame and abort it.");
    PrintS("Result: The aborted frame should be discarded.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC3-Step1");
    ---------------------------------------------------------------------------

    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 3 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '1')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '1')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundWriteFrameAbort;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 2:");
    PrintS("Action: Write one full frame then one more that is aborted.");
    PrintS("Result: The first frame should remain and the aborted should be ");
    PrintS("        discarded.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC3-Step2");
    ---------------------------------------------------------------------------

    for i in 0 to 3 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(1+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '1')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '1')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 3 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(2+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundWriteFrameAbort;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 3 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(3+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 3 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(1+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 3 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(3+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 3:");
    PrintS("Action: Write one full frame then read one that is restarted.");
    PrintS("Result: The content of the first frame should be read twice. ");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC3-Step3");
    ---------------------------------------------------------------------------

    for i in 0 to 3 loop
      SetOutboundWriteContent(std_logic_vector(to_unsigned(1+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '1')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '1')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 3 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(1+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadFrameRestart;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    for i in 0 to 3 loop
      SetOutboundReadContent(std_logic_vector(to_unsigned(1+i, 32)));
      assert (outboundWriteFrameFull = '0')
        report "Unexpected writeFrameFull." severity error;
      assert (outboundReadFrameEmpty = '0')
        report "Unexpected readFrameEmpty." severity error;
      assert (outboundReadWindowEmpty = '0')
        report "Unexpected readWindowEmpty." severity error;
    end loop;

    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioPacketBuffer");
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioPacketBuffer-TC4");
    PrintS("Description: Test operation when partial frames are read.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: Write a one word frame and read it before it is completed.");
    PrintS("Result: Empty signals should reflect the status of the frame.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC4-Step1");
    ---------------------------------------------------------------------------

    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '1')
      report "Unexpected readContentEmpty." severity error;

    SetOutboundWriteContent(std_logic_vector(to_unsigned(1, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;

    SetOutboundReadContent(std_logic_vector(to_unsigned(1, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '1')
      report "Unexpected readContentEmpty." severity error;

    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;
    
    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '1')
      report "Unexpected readContentEmpty." severity error;

    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '1')
      report "Unexpected readContentEmpty." severity error;

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 2:");
    PrintS("Action: Write content to a frame and read it, then abort the frame.");
    PrintS("Result: The reader should be notified about the aborted frame. The");
    PrintS("        notification should be reset when the frame has been ");
    PrintS("        restarted.");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC4-Step2");
    ---------------------------------------------------------------------------

    SetOutboundWriteContent(std_logic_vector(to_unsigned(1, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;
    
    SetOutboundReadContent(std_logic_vector(to_unsigned(1, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '1')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;

    SetOutboundWriteFrameAbort;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '1')
      report "Unexpected readFrameAborted." severity error;
    
    SetOutboundWriteContent(std_logic_vector(to_unsigned(2, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '1')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '1')
      report "Unexpected readFrameAborted." severity error;
    
    SetOutboundReadFrameRestart;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;

    SetOutboundReadContent(std_logic_vector(to_unsigned(2, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '1')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;

    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;
    
    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '1')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;

    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '1')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 3:");
    PrintS("Action: Write one complete frame then abort a second.");
    PrintS("Result: The reader should not notice the aborted frame. ");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPacketBuffer-TC4-Step3");
    ---------------------------------------------------------------------------

    SetOutboundWriteContent(std_logic_vector(to_unsigned(1, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;
    
    SetOutboundReadContent(std_logic_vector(to_unsigned(1, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '1')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;

    SetOutboundWriteFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;
    
    SetOutboundWriteContent(std_logic_vector(to_unsigned(2, 32)));
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;
    
    SetOutboundWriteFrameAbort;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;
    
    SetOutboundReadContentEnd;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '0')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '0')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;

    SetOutboundReadWindowNext;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '0')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '1')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;

    SetOutboundReadFrame;
    assert (outboundWriteFrameFull = '0')
      report "Unexpected writeFrameFull." severity error;
    assert (outboundReadFrameEmpty = '1')
      report "Unexpected readFrameEmpty." severity error;
    assert (outboundReadWindowEmpty = '1')
      report "Unexpected readWindowEmpty." severity error;
    assert (outboundReadContentEmpty = '1')
      report "Unexpected readContentEmpty." severity error;
    assert (outboundReadFrameAborted = '0')
      report "Unexpected readFrameAborted." severity error;

    ---------------------------------------------------------------------------
    -- Test completed.
    ---------------------------------------------------------------------------
    
    TestEnd;
  end process;

  -----------------------------------------------------------------------------
  -- Instantiate the testobject.
  -----------------------------------------------------------------------------

  TestPacketBuffer: RioPacketBufferWindow
    port map(
      clk=>clk, areset_n=>areset_n, 
      inboundWriteFrameFull_o=>inboundWriteFrameFull,
      inboundWriteFrame_i=>inboundWriteFrame,
      inboundWriteFrameAbort_i=>inboundWriteFrameAbort,
      inboundWriteContent_i=>inboundWriteContent,
      inboundWriteContentData_i=>inboundWriteContentData,
      inboundReadFrameEmpty_o=>inboundReadFrameEmpty,
      inboundReadFrame_i=>inboundReadFrame,
      inboundReadFrameRestart_i=>inboundReadFrameRestart,
      inboundReadFrameAborted_o=>inboundReadFrameAborted,
      inboundReadContentEmpty_o=>inboundReadContentEmpty,
      inboundReadContent_i=>inboundReadContent,
      inboundReadContentEnd_o=>inboundReadContentEnd,
      inboundReadContentData_o=>inboundReadContentData,
      outboundWriteFrameFull_o=>outboundWriteFrameFull,
      outboundWriteFrame_i=>outboundWriteFrame,
      outboundWriteFrameAbort_i=>outboundWriteFrameAbort,
      outboundWriteContent_i=>outboundWriteContent,
      outboundWriteContentData_i=>outboundWriteContentData,
      outboundReadFrameEmpty_o=>outboundReadFrameEmpty,
      outboundReadFrame_i=>outboundReadFrame,
      outboundReadFrameRestart_i=>outboundReadFrameRestart,
      outboundReadFrameAborted_o=>outboundReadFrameAborted,
      outboundReadWindowEmpty_o=>outboundReadWindowEmpty,
      outboundReadWindowReset_i=>outboundReadWindowReset,
      outboundReadWindowNext_i=>outboundReadWindowNext,
      outboundReadContentEmpty_o=>outboundReadContentEmpty,
      outboundReadContent_i=>outboundReadContent,
      outboundReadContentEnd_o=>outboundReadContentEnd,
      outboundReadContentData_o=>outboundReadContentData);

end architecture;
