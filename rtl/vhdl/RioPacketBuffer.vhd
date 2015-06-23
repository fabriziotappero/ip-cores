-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- Description
-- Containing RapidIO packet buffering functionallity. Two different entities
-- are implemented, one with transmission window support and one without.
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
-- RioPacketBuffer
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for RioPacketBuffer.
--
-- Generic variables
-- -----------------
-- SIZE_ADDRESS_WIDTH - The number of frames in powers of two.
-- CONTENT_ADDRESS_WIDTH - The total number of entries in the memory that can
-- be used to store packet data.
-- CONTENT_WIDTH - The width of the data to store as packet content in the memory.
-- MAX_PACKET_SIZE - The number of entries that must be available for a new
-- complete full sized packet to be received. This option is present to ensure
-- that it is always possible to move a packet to the storage without being
-- surprised that the storage is suddenly empty.
-------------------------------------------------------------------------------
entity RioPacketBuffer is
  generic(
    SIZE_ADDRESS_WIDTH : natural := 6;
    CONTENT_ADDRESS_WIDTH : natural := 8;
    CONTENT_WIDTH : natural := 32;
    MAX_PACKET_SIZE : natural := 69);
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    inboundWriteFrameFull_o : out std_logic;
    inboundWriteFrame_i : in std_logic;
    inboundWriteFrameAbort_i : in std_logic;
    inboundWriteContent_i : in std_logic;
    inboundWriteContentData_i : in std_logic_vector(CONTENT_WIDTH-1 downto 0);
    inboundReadFrameEmpty_o : out std_logic;
    inboundReadFrame_i : in std_logic;
    inboundReadFrameRestart_i : in std_logic;
    inboundReadFrameAborted_o : out std_logic;
    inboundReadFrameSize_o : out std_logic_vector(CONTENT_ADDRESS_WIDTH-1 downto 0);
    inboundReadContentEmpty_o : out std_logic;
    inboundReadContent_i : in std_logic;
    inboundReadContentEnd_o : out std_logic;
    inboundReadContentData_o : out std_logic_vector(CONTENT_WIDTH-1 downto 0);
    
    outboundWriteFrameFull_o : out std_logic;
    outboundWriteFrame_i : in std_logic;
    outboundWriteFrameAbort_i : in std_logic;
    outboundWriteContent_i : in std_logic;
    outboundWriteContentData_i : in std_logic_vector(CONTENT_WIDTH-1 downto 0);
    outboundReadFrameEmpty_o : out std_logic;
    outboundReadFrame_i : in std_logic;
    outboundReadFrameRestart_i : in std_logic;
    outboundReadFrameAborted_o : out std_logic;
    outboundReadFrameSize_o : out std_logic_vector(CONTENT_ADDRESS_WIDTH-1 downto 0);
    outboundReadContentEmpty_o : out std_logic;
    outboundReadContent_i : in std_logic;
    outboundReadContentEnd_o : out std_logic;
    outboundReadContentData_o : out std_logic_vector(CONTENT_WIDTH-1 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for RioPacketBuffer.
-------------------------------------------------------------------------------
architecture RioPacketBufferImpl of RioPacketBuffer is
  
  component PacketBufferContinous is
    generic(
      SIZE_ADDRESS_WIDTH : natural;
      CONTENT_ADDRESS_WIDTH : natural;
      CONTENT_WIDTH : natural;
      MAX_PACKET_SIZE : natural);
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      writeFrameFull_o : out std_logic;
      writeFrame_i : in std_logic;
      writeFrameAbort_i : in std_logic;
      writeContent_i : in std_logic;
      writeContentData_i : in std_logic_vector(CONTENT_WIDTH-1 downto 0);

      readFrameEmpty_o : out std_logic;
      readFrame_i : in std_logic;
      readFrameRestart_i : in std_logic;
      readFrameAborted_o : out std_logic;
      readFrameSize_o : out std_logic_vector(CONTENT_ADDRESS_WIDTH-1 downto 0);
      readContentEmpty_o : out std_logic;
      readContent_i : in std_logic;
      readContentEnd_o : out std_logic;
      readContentData_o : out std_logic_vector(CONTENT_WIDTH-1 downto 0));
  end component;
  
begin

  -----------------------------------------------------------------------------
  -- Outbound frame buffers.
  -----------------------------------------------------------------------------
  OutboundPacketBuffer: PacketBufferContinous
    generic map(
      SIZE_ADDRESS_WIDTH=>SIZE_ADDRESS_WIDTH,
      CONTENT_ADDRESS_WIDTH=>CONTENT_ADDRESS_WIDTH,
      CONTENT_WIDTH=>CONTENT_WIDTH,
      MAX_PACKET_SIZE=>MAX_PACKET_SIZE)
    port map(
      clk=>clk, 
      areset_n=>areset_n, 
      writeFrameFull_o=>outboundWriteFrameFull_o,
      writeFrame_i=>outboundWriteFrame_i, writeFrameAbort_i=>outboundWriteFrameAbort_i, 
      writeContent_i=>outboundWriteContent_i, writeContentData_i=>outboundWriteContentData_i, 

      readFrameEmpty_o=>outboundReadFrameEmpty_o, 
      readFrame_i=>outboundReadFrame_i, readFrameRestart_i=>outboundReadFrameRestart_i, 
      readFrameAborted_o=>outboundReadFrameAborted_o,
      readFrameSize_o=>outboundReadFrameSize_o,
      readContentEmpty_o=>outboundReadContentEmpty_o,
      readContent_i=>outboundReadContent_i, readContentEnd_o=>outboundReadContentEnd_o, 
      readContentData_o=>outboundReadContentData_o);

  -----------------------------------------------------------------------------
  -- Inbound frame buffers.
  -----------------------------------------------------------------------------
  InboundPacketBuffer: PacketBufferContinous
    generic map(
      SIZE_ADDRESS_WIDTH=>SIZE_ADDRESS_WIDTH,
      CONTENT_ADDRESS_WIDTH=>CONTENT_ADDRESS_WIDTH,
      CONTENT_WIDTH=>CONTENT_WIDTH,
      MAX_PACKET_SIZE=>MAX_PACKET_SIZE)
    port map(
      clk=>clk, 
      areset_n=>areset_n, 
      writeFrameFull_o=>inboundWriteFrameFull_o,
      writeFrame_i=>inboundWriteFrame_i, writeFrameAbort_i=>inboundWriteFrameAbort_i, 
      writeContent_i=>inboundWriteContent_i, writeContentData_i=>inboundWriteContentData_i, 

      readFrameEmpty_o=>inboundReadFrameEmpty_o, 
      readFrame_i=>inboundReadFrame_i, readFrameRestart_i=>inboundReadFrameRestart_i, 
      readFrameAborted_o=>inboundReadFrameAborted_o,
      readFrameSize_o=>inboundReadFrameSize_o,
      readContentEmpty_o=>inboundReadContentEmpty_o,
      readContent_i=>inboundReadContent_i, readContentEnd_o=>inboundReadContentEnd_o, 
      readContentData_o=>inboundReadContentData_o);
  
end architecture;




-------------------------------------------------------------------------------
-- RioPacketBufferWindow
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for RioPacketBufferWindow.
-------------------------------------------------------------------------------
entity RioPacketBufferWindow is
  generic(
    SIZE_ADDRESS_WIDTH : natural := 6;
    CONTENT_ADDRESS_WIDTH : natural := 8;
    CONTENT_WIDTH : natural := 32;
    MAX_PACKET_SIZE : natural := 69);
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    inboundWriteFrameFull_o : out std_logic;
    inboundWriteFrame_i : in std_logic;
    inboundWriteFrameAbort_i : in std_logic;
    inboundWriteContent_i : in std_logic;
    inboundWriteContentData_i : in std_logic_vector(CONTENT_WIDTH-1 downto 0);
    inboundReadFrameEmpty_o : out std_logic;
    inboundReadFrame_i : in std_logic;
    inboundReadFrameRestart_i : in std_logic;
    inboundReadFrameAborted_o : out std_logic;
    inboundReadContentEmpty_o : out std_logic;
    inboundReadContent_i : in std_logic;
    inboundReadContentEnd_o : out std_logic;
    inboundReadContentData_o : out std_logic_vector(CONTENT_WIDTH-1 downto 0);
    
    outboundWriteFrameFull_o : out std_logic;
    outboundWriteFrame_i : in std_logic;
    outboundWriteFrameAbort_i : in std_logic;
    outboundWriteContent_i : in std_logic;
    outboundWriteContentData_i : in std_logic_vector(CONTENT_WIDTH-1 downto 0);
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
    outboundReadContentData_o : out std_logic_vector(CONTENT_WIDTH-1 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for RioPacketBufferWindow.
-------------------------------------------------------------------------------
architecture RioPacketBufferWindowImpl of RioPacketBufferWindow is
  
  component PacketBufferContinous is
    generic(
      SIZE_ADDRESS_WIDTH : natural;
      CONTENT_ADDRESS_WIDTH : natural;
      CONTENT_WIDTH : natural;
      MAX_PACKET_SIZE : natural);
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      writeFrameFull_o : out std_logic;
      writeFrame_i : in std_logic;
      writeFrameAbort_i : in std_logic;
      writeContent_i : in std_logic;
      writeContentData_i : in std_logic_vector(CONTENT_WIDTH-1 downto 0);

      readFrameEmpty_o : out std_logic;
      readFrame_i : in std_logic;
      readFrameRestart_i : in std_logic;
      readFrameAborted_o : out std_logic;
      readFrameSize_o : out std_logic_vector(CONTENT_ADDRESS_WIDTH-1 downto 0);
      
      readContentEmpty_o : out std_logic;
      readContent_i : in std_logic;
      readContentEnd_o : out std_logic;
      readContentData_o : out std_logic_vector(CONTENT_WIDTH-1 downto 0));
  end component;
  
  component PacketBufferContinousWindow is
    generic(
      SIZE_ADDRESS_WIDTH : natural;
      CONTENT_ADDRESS_WIDTH : natural;
      CONTENT_WIDTH : natural;
      MAX_PACKET_SIZE : natural);
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      writeFrameFull_o : out std_logic;
      writeFrame_i : in std_logic;
      writeFrameAbort_i : in std_logic;
      writeContent_i : in std_logic;
      writeContentData_i : in std_logic_vector(CONTENT_WIDTH-1 downto 0);

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
      readContentData_o : out std_logic_vector(CONTENT_WIDTH-1 downto 0));
  end component;
  
begin

  -----------------------------------------------------------------------------
  -- Outbound frame buffers.
  -----------------------------------------------------------------------------
  OutboundPacketBuffer: PacketBufferContinousWindow
    generic map(
      SIZE_ADDRESS_WIDTH=>SIZE_ADDRESS_WIDTH,
      CONTENT_ADDRESS_WIDTH=>CONTENT_ADDRESS_WIDTH,
      CONTENT_WIDTH=>CONTENT_WIDTH,
      MAX_PACKET_SIZE=>MAX_PACKET_SIZE)
    port map(
      clk=>clk, 
      areset_n=>areset_n, 
      writeFrameFull_o=>outboundWriteFrameFull_o,
      writeFrame_i=>outboundWriteFrame_i, writeFrameAbort_i=>outboundWriteFrameAbort_i, 
      writeContent_i=>outboundWriteContent_i, writeContentData_i=>outboundWriteContentData_i, 

      readFrameEmpty_o=>outboundReadFrameEmpty_o, 
      readFrame_i=>outboundReadFrame_i, readFrameRestart_i=>outboundReadFrameRestart_i, 
      readFrameAborted_o=>outboundReadFrameAborted_o,
      readWindowEmpty_o=>outboundReadWindowEmpty_o,
      readWindowReset_i=>outboundReadWindowReset_i,
      readWindowNext_i=>outboundReadWindowNext_i,
      readContentEmpty_o=>outboundReadContentEmpty_o,
      readContent_i=>outboundReadContent_i, readContentEnd_o=>outboundReadContentEnd_o, 
      readContentData_o=>outboundReadContentData_o);

  -----------------------------------------------------------------------------
  -- Inbound frame buffers.
  -----------------------------------------------------------------------------
  InboundPacketBuffer: PacketBufferContinous
    generic map(
      SIZE_ADDRESS_WIDTH=>SIZE_ADDRESS_WIDTH,
      CONTENT_ADDRESS_WIDTH=>CONTENT_ADDRESS_WIDTH,
      CONTENT_WIDTH=>CONTENT_WIDTH,
      MAX_PACKET_SIZE=>MAX_PACKET_SIZE)
    port map(
      clk=>clk, 
      areset_n=>areset_n, 
      writeFrameFull_o=>inboundWriteFrameFull_o,
      writeFrame_i=>inboundWriteFrame_i, writeFrameAbort_i=>inboundWriteFrameAbort_i, 
      writeContent_i=>inboundWriteContent_i, writeContentData_i=>inboundWriteContentData_i, 

      readFrameEmpty_o=>inboundReadFrameEmpty_o, 
      readFrame_i=>inboundReadFrame_i, readFrameRestart_i=>inboundReadFrameRestart_i, 
      readFrameAborted_o=>inboundReadFrameAborted_o,
      readFrameSize_o=>open,
      readContentEmpty_o=>inboundReadContentEmpty_o,
      readContent_i=>inboundReadContent_i, readContentEnd_o=>inboundReadContentEnd_o, 
      readContentData_o=>inboundReadContentData_o);
  
end architecture;




-------------------------------------------------------------------------------
-- PacketBufferContinous
-- This component stores data in chuncks and stores the size of them. The full
-- memory can be used, except for one word, or a specified (using generic)
-- maximum number of frames.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


-------------------------------------------------------------------------------
-- Entity for PacketBufferContinous.
-------------------------------------------------------------------------------
entity PacketBufferContinous is
  generic(
    SIZE_ADDRESS_WIDTH : natural;
    CONTENT_ADDRESS_WIDTH : natural;
    CONTENT_WIDTH : natural;
    MAX_PACKET_SIZE : natural);
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    writeFrameFull_o : out std_logic;
    writeFrame_i : in std_logic;
    writeFrameAbort_i : in std_logic;
    writeContent_i : in std_logic;
    writeContentData_i : in std_logic_vector(CONTENT_WIDTH-1 downto 0);

    readFrameEmpty_o : out std_logic;
    readFrame_i : in std_logic;
    readFrameRestart_i : in std_logic;
    readFrameAborted_o : out std_logic;
    readFrameSize_o : out std_logic_vector(CONTENT_ADDRESS_WIDTH-1 downto 0);
    
    readContentEmpty_o : out std_logic;
    readContent_i : in std_logic;
    readContentEnd_o : out std_logic;
    readContentData_o : out std_logic_vector(CONTENT_WIDTH-1 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for PacketBufferContinous.
-------------------------------------------------------------------------------
architecture PacketBufferContinousImpl of PacketBufferContinous is

  component MemorySimpleDualPortAsync is
    generic(
      ADDRESS_WIDTH : natural := 1;
      DATA_WIDTH : natural := 1);
    port(
      clkA_i : in std_logic;
      enableA_i : in std_logic;
      addressA_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      dataA_i : in std_logic_vector(DATA_WIDTH-1 downto 0);

      addressB_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      dataB_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;
  
  component MemorySimpleDualPort is
    generic(
      ADDRESS_WIDTH : natural := 1;
      DATA_WIDTH : natural := 1);
    port(
      clkA_i : in std_logic;
      enableA_i : in std_logic;
      addressA_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      dataA_i : in std_logic_vector(DATA_WIDTH-1 downto 0);

      clkB_i : in std_logic;
      enableB_i : in std_logic;
      addressB_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      dataB_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;

  -- The number of available word positions left in the memory.
  signal available : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');
  
  -- The position to place new frames.
  signal backIndex, backIndexNext : unsigned(SIZE_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  -- The position to remove old frames.
  signal frontIndex, frontIndexNext : unsigned(SIZE_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  -- The size of the current frame.
  signal readFrameEnd_p : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  -- The start of unread content.
  signal memoryStart_p : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  -- The current reading position.
  signal memoryRead_p, memoryReadNext_p : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  -- The end of unread content.
  signal memoryEnd_p : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  -- The current writing position.
  signal memoryWrite_p, memoryWriteNext_p : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  -- Memory output signal containing the position of a frame.
  signal framePositionReadData : std_logic_vector(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');
begin

  -----------------------------------------------------------------------------
  -- Internal signal assignments.
  -----------------------------------------------------------------------------

  available <= not (memoryEnd_p - memoryStart_p);
  
  backIndexNext <= backIndex + 1;
  frontIndexNext <= frontIndex + 1;

  memoryWriteNext_p <= memoryWrite_p + 1;
  memoryReadNext_p <= memoryRead_p + 1;
  
  -----------------------------------------------------------------------------
  -- Writer logic.
  -----------------------------------------------------------------------------
  
  writeFrameFull_o <= '1' when ((backIndexNext = frontIndex) or
                                (available < MAX_PACKET_SIZE)) else '0';
                                    
  Writer: process(clk, areset_n)
  begin
    if (areset_n = '0') then
      backIndex <= (others=>'0');
      
      memoryEnd_p <= (others=>'0');
      memoryWrite_p <= (others=>'0');
    elsif (clk'event and clk = '1') then
      
      if (writeFrameAbort_i = '1') then
        memoryWrite_p <= memoryEnd_p;
      elsif (writeContent_i = '1') then
        memoryWrite_p <= memoryWriteNext_p;
      end if;
      
      if(writeFrame_i = '1') then
        memoryEnd_p <= memoryWrite_p;
        backIndex <= backIndexNext;
      end if;
      
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Frame cancellation logic.
  -----------------------------------------------------------------------------
  
  process(clk, areset_n)
  begin
    if (areset_n = '0') then
      readFrameAborted_o <= '0';
    elsif (clk'event and clk = '1') then

      if ((frontIndex = backIndex) and
          ((writeFrameAbort_i = '1') and (readFrameRestart_i = '0'))) then
        readFrameAborted_o <= '1';
      elsif ((writeFrameAbort_i = '0') and (readFrameRestart_i = '1')) then
        readFrameAborted_o <= '0';
      end if;
      
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Reader logic.
  -----------------------------------------------------------------------------
  
  readFrameEmpty_o <= '1' when (frontIndex = backIndex) else '0';
  readContentEmpty_o <= '1' when ((frontIndex = backIndex) and
                                  (memoryWrite_p = memoryRead_p)) else '0';
  readFrameSize_o <= std_logic_vector(readFrameEnd_p - memoryStart_p);
  
  Reader: process(clk, areset_n)
  begin
    if (areset_n = '0') then
      frontIndex <= (others=>'0');
      
      memoryStart_p <= (others=>'0');
      memoryRead_p <= (others=>'0');
      
      readContentEnd_o <= '0';
    elsif (clk'event and clk = '1') then

      -- REMARK: Break apart into registers to avoid priority ladder???
      if(readFrameRestart_i = '1') then
        memoryRead_p <= memoryStart_p;
      elsif(readContent_i = '1') then
        if(memoryRead_p = readFrameEnd_p) then
          readContentEnd_o <= '1';
        else
          readContentEnd_o <= '0';
          memoryRead_p <= memoryReadNext_p;
        end if;
      elsif(readFrame_i = '1') then
        memoryStart_p <= readFrameEnd_p;
        frontIndex <= frontIndexNext;
        memoryRead_p <= readFrameEnd_p;
      end if;
      
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Frame positioning memory signals.
  -----------------------------------------------------------------------------

  readFrameEnd_p <= unsigned(framePositionReadData);

  -- Memory to keep frame starting/ending positions in.
  FramePosition: MemorySimpleDualPortAsync
    generic map(ADDRESS_WIDTH=>SIZE_ADDRESS_WIDTH, DATA_WIDTH=>CONTENT_ADDRESS_WIDTH)
    port map(
      clkA_i=>clk, enableA_i=>writeFrame_i,
      addressA_i=>std_logic_vector(backIndex), dataA_i=>std_logic_vector(memoryWrite_p),
      addressB_i=>std_logic_vector(frontIndex), dataB_o=>framePositionReadData);

  -----------------------------------------------------------------------------
  -- Frame content memory signals.
  -----------------------------------------------------------------------------

  -- Memory to keep frame content in.
  -- REMARK: Use paritybits here as well to make sure the frame data does not
  -- become corrupt???
  FrameContent: MemorySimpleDualPort
    generic map(ADDRESS_WIDTH=>CONTENT_ADDRESS_WIDTH, DATA_WIDTH=>CONTENT_WIDTH)
    port map(
      clkA_i=>clk, enableA_i=>writeContent_i,
      addressA_i=>std_logic_vector(memoryWrite_p), dataA_i=>writeContentData_i,
      clkB_i=>clk, enableB_i=>readContent_i,
      addressB_i=>std_logic_vector(memoryRead_p), dataB_o=>readContentData_o);

end architecture;



-------------------------------------------------------------------------------
-- PacketBufferContinousWindow
-- This component stores data in chuncks and stores the size of them. The full
-- memory can be used, except for one word, or a specified (using generic)
-- maximum number of frames.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


-------------------------------------------------------------------------------
-- Entity for PacketBufferContinousWindow.
-------------------------------------------------------------------------------
entity PacketBufferContinousWindow is
  generic(
    SIZE_ADDRESS_WIDTH : natural;
    CONTENT_ADDRESS_WIDTH : natural;
    CONTENT_WIDTH : natural;
    MAX_PACKET_SIZE : natural);
  port(
    clk : in std_logic;
    areset_n : in std_logic;

    writeFrameFull_o : out std_logic;
    writeFrame_i : in std_logic;
    writeFrameAbort_i : in std_logic;
    writeContent_i : in std_logic;
    writeContentData_i : in std_logic_vector(CONTENT_WIDTH-1 downto 0);

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
    readContentData_o : out std_logic_vector(CONTENT_WIDTH-1 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for PacketBufferContinousWindow.
-------------------------------------------------------------------------------
architecture PacketBufferContinousWindowImpl of PacketBufferContinousWindow is

  component MemorySimpleDualPortAsync is
    generic(
      ADDRESS_WIDTH : natural := 1;
      DATA_WIDTH : natural := 1);
    port(
      clkA_i : in std_logic;
      enableA_i : in std_logic;
      addressA_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      dataA_i : in std_logic_vector(DATA_WIDTH-1 downto 0);

      addressB_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      dataB_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;
  
  component MemorySimpleDualPort is
    generic(
      ADDRESS_WIDTH : natural := 1;
      DATA_WIDTH : natural := 1);
    port(
      clkA_i : in std_logic;
      enableA_i : in std_logic;
      addressA_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      dataA_i : in std_logic_vector(DATA_WIDTH-1 downto 0);

      clkB_i : in std_logic;
      enableB_i : in std_logic;
      addressB_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
      dataB_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;

  -- The number of available word positions left in the memory.
  signal available : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');
  
  signal backIndex, backIndexNext : unsigned(SIZE_ADDRESS_WIDTH-1 downto 0) := (others=>'0');
  signal frontIndex, frontIndexNext : unsigned(SIZE_ADDRESS_WIDTH-1 downto 0) := (others=>'0');
  signal windowIndex, windowIndexNext : unsigned(SIZE_ADDRESS_WIDTH-1 downto 0) := (others=>'0');  

  -- The size of the current frame.
  signal readFrameEnd_p : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  -- The start of unread content.
  signal memoryStart_p : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  -- The start of unread window content.
  signal memoryStartWindow_p : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  -- The current reading position.
  signal memoryRead_p, memoryReadNext_p : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  -- The end of unread content.
  signal memoryEnd_p : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  -- The current writing position.
  signal memoryWrite_p, memoryWriteNext_p : unsigned(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');

  signal framePositionReadAddress : std_logic_vector(SIZE_ADDRESS_WIDTH-1 downto 0) := (others=>'0');
  signal framePositionReadData : std_logic_vector(CONTENT_ADDRESS_WIDTH-1 downto 0) := (others=>'0');
begin

  -----------------------------------------------------------------------------
  -- Internal signal assignments.
  -----------------------------------------------------------------------------

  available <= not (memoryEnd_p - memoryStart_p);
  
  backIndexNext <= backIndex + 1;
  frontIndexNext <= frontIndex + 1;
  windowIndexNext <= windowIndex + 1;

  memoryWriteNext_p <= memoryWrite_p + 1;
  memoryReadNext_p <= memoryRead_p + 1;
  
  -----------------------------------------------------------------------------
  -- Writer logic.
  -----------------------------------------------------------------------------
  
  writeFrameFull_o <= '1' when ((backIndexNext = frontIndex) or
                                (available < MAX_PACKET_SIZE)) else '0';
                                    
  Writer: process(clk, areset_n)
  begin
    if (areset_n = '0') then
      backIndex <= (others=>'0');
      
      memoryEnd_p <= (others=>'0');
      memoryWrite_p <= (others=>'0');
    elsif (clk'event and clk = '1') then
      
      if (writeFrameAbort_i = '1') then
        memoryWrite_p <= memoryEnd_p;
      elsif (writeContent_i = '1') then
        memoryWrite_p <= memoryWriteNext_p;
      end if;
      
      if(writeFrame_i = '1') then
        memoryEnd_p <= memoryWrite_p;
        backIndex <= backIndexNext;
      end if;
      
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Frame cancellation logic.
  -----------------------------------------------------------------------------
  
  process(clk, areset_n)
  begin
    if (areset_n = '0') then
      readFrameAborted_o <= '0';
    elsif (clk'event and clk = '1') then

      if ((windowIndex = backIndex) and
          ((writeFrameAbort_i = '1') and (readFrameRestart_i = '0'))) then
        readFrameAborted_o <= '1';
      elsif ((writeFrameAbort_i = '0') and (readFrameRestart_i = '1')) then
        readFrameAborted_o <= '0';
      end if;
      
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Reader logic.
  -----------------------------------------------------------------------------
  
  readFrameEmpty_o <= '1' when (frontIndex = backIndex) else '0';
  readWindowEmpty_o <= '1' when (windowIndex = backIndex) else '0';
  readContentEmpty_o <= '1' when ((windowIndex = backIndex) and
                                  (memoryWrite_p = memoryRead_p)) else '0';
  
  Reader: process(clk, areset_n)
  begin
    if (areset_n = '0') then
      frontIndex <= (others=>'0');
      windowIndex <= (others=>'0');
      
      memoryStart_p <= (others=>'0');
      memoryStartWindow_p <= (others=>'0');
      memoryRead_p <= (others=>'0');
      
      readContentEnd_o <= '0';
    elsif (clk'event and clk = '1') then

      -- REMARK: Break apart into registers to avoid priority ladder???
      if(readFrameRestart_i = '1') then
        memoryRead_p <= memoryStartWindow_p;
      elsif(readContent_i = '1') then
        if(memoryRead_p = readFrameEnd_p) then
          readContentEnd_o <= '1';
        else
          readContentEnd_o <= '0';
          memoryRead_p <= memoryReadNext_p;
        end if;
      elsif(readFrame_i = '1') then
        memoryStart_p <= readFrameEnd_p;
        frontIndex <= frontIndexNext;
      elsif(readWindowReset_i = '1') then
        memoryStartWindow_p <= memoryStart_p;
        windowIndex <= frontIndex;
        memoryRead_p <= memoryStart_p;
      elsif(readWindowNext_i = '1') then
        memoryStartWindow_p <= readFrameEnd_p;
        windowIndex <= windowIndexNext;
        memoryRead_p <= readFrameEnd_p;
      end if;
      
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Frame positioning memory signals.
  -----------------------------------------------------------------------------

  -- Assign the address from both frontIndex and windowIndex to be able to
  -- share the memory between the two different types of accesses. This assumes
  -- that the window is not accessed at the same time as the other signal.
  framePositionReadAddress <= std_logic_vector(frontIndex) when (readFrame_i = '1') else
                              std_logic_vector(windowIndex);
  readFrameEnd_p <= unsigned(framePositionReadData);

  -- Memory to keep frame starting/ending positions in.
  FramePosition: MemorySimpleDualPortAsync
    generic map(ADDRESS_WIDTH=>SIZE_ADDRESS_WIDTH, DATA_WIDTH=>CONTENT_ADDRESS_WIDTH)
    port map(
      clkA_i=>clk, enableA_i=>writeFrame_i,
      addressA_i=>std_logic_vector(backIndex), dataA_i=>std_logic_vector(memoryWrite_p),
      addressB_i=>framePositionReadAddress, dataB_o=>framePositionReadData);

  -----------------------------------------------------------------------------
  -- Frame content memory signals.
  -----------------------------------------------------------------------------

  -- Memory to keep frame content in.
  -- REMARK: Use paritybits here as well to make sure the frame data does not
  -- become corrupt???
  FrameContent: MemorySimpleDualPort
    generic map(ADDRESS_WIDTH=>CONTENT_ADDRESS_WIDTH, DATA_WIDTH=>CONTENT_WIDTH)
    port map(
      clkA_i=>clk, enableA_i=>writeContent_i,
      addressA_i=>std_logic_vector(memoryWrite_p), dataA_i=>writeContentData_i,
      clkB_i=>clk, enableB_i=>readContent_i,
      addressB_i=>std_logic_vector(memoryRead_p), dataB_o=>readContentData_o);

end architecture;
