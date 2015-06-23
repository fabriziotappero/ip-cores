-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- Description
-- Containing a bridge between a RapidIO network and a Wishbone bus. Packets
-- NWRITE and NREAD are currently supported.
-- 
-- To Do:
-- -
-- 
-- Author(s): 
-- - Nader Kardouni, nader.kardouni@se.transport.bombardier.com 
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

library ieee;
use ieee.numeric_std.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.rio_common.all;

-------------------------------------------------------------------------------
-- entity for RioWbBridge.
-------------------------------------------------------------------------------
Entity RioWbBridge is
  generic(
    DEVICE_IDENTITY : std_logic_vector(15 downto 0);
    DEVICE_VENDOR_IDENTITY : std_logic_vector(15 downto 0);
    DEVICE_REV : std_logic_vector(31 downto 0);
    ASSY_IDENTITY : std_logic_vector(15 downto 0);
    ASSY_VENDOR_IDENTITY : std_logic_vector(15 downto 0);
    ASSY_REV : std_logic_vector(15 downto 0);
    DEFAULT_BASE_DEVICE_ID : std_logic_vector(15 downto 0) := x"ffff");
  port(
    clk : in std_logic;                         -- Main clock 25MHz
    areset_n : in std_logic;                    -- Asynchronous reset, active low

    readFrameEmpty_i : in std_logic;
    readFrame_o : out std_logic;
    readContent_o : out std_logic;
    readContentEnd_i : in std_logic;
    readContentData_i : in std_logic_vector(31 downto 0);

    writeFrameFull_i : in std_logic;
    writeFrame_o : out std_logic;
    writeFrameAbort_o : out std_logic;
    writeContent_o : out std_logic;
    writeContentData_o : out std_logic_vector(31 downto 0);

    -- interface to the peripherals module
    wbStb_o : out std_logic;                     -- strob signal, active high
    wbWe_o : out std_logic;                      -- write signal, active high
    wbData_o : out std_logic_vector(7 downto 0); -- master data bus    
    wbAdr_o : out std_logic_vector(25 downto 0); -- master address bus 
    wbErr_i : in std_logic;                     -- error signal, high active
    wbAck_i : in std_logic;                     -- slave acknowledge
    wbData_i : in std_logic_vector(7 downto 0)  -- slave data bus
    );
end;

-------------------------------------------------------------------------------
-- Architecture for RioWbBridge.
-------------------------------------------------------------------------------
architecture rtl of RioWbBridge is

  component Crc16CITT is
    port(
      d_i : in  std_logic_vector(15 downto 0);
      crc_i : in  std_logic_vector(15 downto 0);
      crc_o : out std_logic_vector(15 downto 0));
  end component;

  constant RST_LVL	  : std_logic := '0';
  constant BERR_UNKNOWN_DATA    : std_logic_vector(7 downto 0) := X"08"; -- not valid data
  constant BERR_FRAME_SIZE      : std_logic_vector(7 downto 0) := X"81"; -- Frame code size error
  constant BERR_FRAME_CODE      : std_logic_vector(7 downto 0) := X"80"; -- Frame code type error
  constant BERR_NOT_RESPONSE    : std_logic_vector(7 downto 0) := X"86"; -- Not response from the device
  
  type state_type_RioBrige is (IDLE, WAIT_HEADER_0, HEADER_0, HEADER_1, CHECK_OPERATION,
                               READ_ADDRESS, READ_FROM_FIFO, CHECK_ERROR, WRITE_DATA, 
                               WRITE_TO_WB, WAIT_IDLE, SEND_DONE_0, SEND_DONE_1,
                               SEND_DONE_2, READ_FROM_WB, APPEND_CRC,
                               SEND_TO_FIFO, SEND_ERROR, SEND_FRAME, APPEND_CRC_AND_SEND,
                               SEND_MAINTENANCE_READ_RESPONSE_0, SEND_MAINTENANCE_READ_RESPONSE_1,
                               SEND_MAINTENANCE_WRITE_RESPONSE_0, SEND_MAINTENANCE_WRITE_RESPONSE_1);
  signal stateRB, nextStateRB : state_type_RioBrige;
  type byteArray8 is array (0 to 7) of std_logic_vector(7 downto 0);
  signal dataLane : byteArray8;
--  type byteArray4 is array (0 to 3) of std_logic_vector(7 downto 0);
--  signal dataLaneS : byteArray4;
  signal pos, byteOffset : integer range 0 to 7; 
  signal numberOfByte, byteCnt, headLen : integer range 0 to 256;  
  signal endianMsb, reserved, ready : std_logic;
  signal start : std_logic;
  signal wdptr : std_logic;
  signal wbStb : std_logic;
  signal xamsbs : std_logic_vector(1 downto 0);
  signal ftype : std_logic_vector(3 downto 0);
  signal ttype : std_logic_vector(3 downto 0);
  signal size : std_logic_vector(3 downto 0);
  signal tid : std_logic_vector(7 downto 0);
  signal tt : std_logic_vector(1 downto 0);
  signal errorCode : std_logic_vector(7 downto 0);
  signal sourceId : std_logic_vector(15 downto 0);
  signal destinationId : std_logic_vector(15 downto 0);
  signal writeContentData : std_logic_vector(31 downto 0);
  signal crc16Current, crc16Temp, crc16Next: std_logic_vector(15 downto 0);
  signal tempAddr : std_logic_vector(25 downto 0);
  signal timeOutCnt : std_logic_vector(14 downto 0);

  -- Configuration memory signal declaration.
  signal configEnable : std_logic;
  signal configWrite : std_logic;
  signal configAddress : std_logic_vector(23 downto 0);
  signal configDataWrite : std_logic_vector(31 downto 0);
  signal configDataRead : std_logic_vector(31 downto 0);
  signal componentTag : std_logic_vector(31 downto 0);
  signal baseDeviceId : std_logic_vector(15 downto 0) := DEFAULT_BASE_DEVICE_ID;
  signal hostBaseDeviceIdLocked : std_logic;
  signal hostBaseDeviceId : std_logic_vector(15 downto 0) := (others => '1');

begin
  wbStb_o <= wbStb;
  writeContentData_o <= writeContentData;

  Crc16High: Crc16CITT
    port map(
      d_i=>writeContentData(31 downto 16), crc_i=>crc16Current, crc_o=>crc16Temp);
  Crc16Low: Crc16CITT
    port map(
      d_i=>writeContentData(15 downto 0), crc_i=>crc16Temp, crc_o=>crc16Next);


  
  -----------------------------------------------------------------------------
  -- wbInterfaceCtrl
  -- This process handle the Wishbone interface to the RioWbBridge module.
  -----------------------------------------------------------------------------
  wbInterfaceCtrl: process(clk, areset_n)
  variable Temp : std_logic_vector(2 downto 0);
  begin
    if areset_n = RST_LVL then
      start <= '0';
      wdptr <= '0';
      wbStb <= '0';
      wbWe_o <= '0';
      byteCnt <= 0;
      headLen <= 0;
      byteOffset <= 0;
      readFrame_o <= '0';
      readContent_o <= '0';
      writeFrame_o <= '0';
      writeContent_o <= '0';
      writeFrameAbort_o <= '0';
      configWrite <= '0';
      configEnable <= '0';
      ready <= '0';
      endianMsb <= '0';
      stateRB <= IDLE;
      nextStateRB <= IDLE;
      tt <= (others => '0');
      tid <= (others => '0');
      size <= (others => '0');
      ttype <= (others => '0');
      ftype <= (others => '0');
      xamsbs <= (others => '0');
      sourceId <= (others => '0');
      configDataWrite <= (others => '0');
      destinationId <= (others => '0');
      errorCode <= (others => '0');
      tempAddr <= (others => '0');
      wbAdr_o <= (others => '0');
      wbData_o <= (others => '0');
      writeContentData <= (others => '0');
      dataLane <= (others =>(others => '0')); 
--      dataLaneS <= (others =>(others => '0')); 
      crc16Current <= (others => '0');
      timeOutCnt <= (others => '0');
      Temp := (others => '0');
    elsif clk'event and clk ='1' then

      case stateRB is
        when IDLE =>
          if (readFrameEmpty_i = '0') and (writeFrameFull_i = '0') then
            readContent_o <= '1';
            byteCnt <= 0;
            ready <= '0';
            endianMsb <= '1';
            timeOutCnt <= (others => '0');
            crc16Current <= (others => '1');
            stateRB <= WAIT_HEADER_0;
          else
            start <= '0';
            readFrame_o <= '0';
            readContent_o <= '0';
            writeFrame_o <= '0';
            writeContent_o <= '0';
            writeFrameAbort_o <= '0';
            errorCode <= (others => '0');
            writeContentData <= (others => '0');
            dataLane <= (others =>(others => '0')); 
--            dataLaneS <= (others =>(others => '0')); 
            Temp := (others => '0');
          end if;

        when WAIT_HEADER_0 =>
          stateRB <= HEADER_0;

        when HEADER_0 =>
          readContent_o <= '1';                          -- read the header (frame 0)
          tt <= readContentData_i(21 downto 20); 
          ftype <= readContentData_i(19 downto 16);
          destinationId <= readContentData_i(15 downto 0);
          stateRB <= HEADER_1;
          
        when HEADER_1 =>                                 -- read the header (frame 1)
          readContent_o <= '1';
          ttype <= readContentData_i(15 downto 12);
          size <= readContentData_i(11 downto 8);
          tid <= readContentData_i(7 downto 0);
          sourceId <= readContentData_i(31 downto 16);
          stateRB <= READ_ADDRESS;

        when READ_ADDRESS =>
          readContent_o <= '0';
          wdptr <= readContentData_i(2);
          xamsbs <= readContentData_i(1 downto 0);
          tempAddr <= readContentData_i(25 downto 3) & "000";  -- Wishbone address bus is 26 bits width
          configAddress <= readContentData_i(23 downto 0);     -- this line is in case of maintenance pakage (config-offset(21-bits)+wdptr(1-bit)+rsv(2-bits))
          stateRB <= CHECK_ERROR;

        when CHECK_ERROR =>
          byteOffset <= pos;               -- first byte position in the first payload
          tempAddr <= tempAddr + pos;      -- first address
          if readContentEnd_i = '1' then   -- check if data not valid i the switch buffer
            wbStb <= '0';
            wbWe_o <= '0';
            byteOffset <= 0;
            writeFrameAbort_o <= '1';               -- over write the frame with an error frame
            errorCode <= BERR_UNKNOWN_DATA;         -- not valid data
            stateRB <= SEND_ERROR;

          -- check if error in the frame size for write pakage
          elsif (reserved = '1') and (ftype = FTYPE_WRITE_CLASS) then
            wbStb <= '0';
            wbWe_o <= '0';
            byteOffset <= 0;
            writeFrameAbort_o <= '1';               -- over write the frame with an error frame
            errorCode <= BERR_FRAME_SIZE;           -- Frame code size error
            stateRB <= SEND_ERROR;

          -- type 5 pakage formate, NWRITE transaction (write to peripherals) read payload from the buffer
          elsif (ftype = FTYPE_WRITE_CLASS) and (ttype = "0100") and (tt = "01") then
            readContent_o <= '1';
            stateRB <= READ_FROM_FIFO;          -- read the payload
            nextStateRB <= SEND_ERROR;     -- this is in case not valid data in switch buffer
            headLen <= 12;

          -- Type 2 pakage formate, NREAD transaction, (read from peripherals) write payload to the buffer
          elsif (ftype = FTYPE_REQUEST_CLASS) and (ttype = "0100") and (tt = "01") then 
            writeContent_o <= '1';  -- write the header-0 of the Read Response pakage
            writeContentData(15 downto 0) <= sourceId;      -- write to the source address
            writeContentData(19 downto 16) <= "1101";       -- Response pakage type 13, ftype Response
            writeContentData(21 downto 20) <= "01";         -- tt
            writeContentData(31 downto 22) <= "0000000000"; -- acckId, vc, cfr, prio           
            stateRB <= SEND_DONE_0; --
            headLen <= 8; 

          -- Type 8 pakage formate, maintenance Read request
          elsif (ftype = FTYPE_MAINTENANCE_CLASS) and (ttype = TTYPE_MAINTENANCE_READ_REQUEST) and (tt = "01") then
            configWrite <= '0';                                        -- read config operation
            configEnable <= '1';                                       -- enable signal to the memoryConfig process
            writeContent_o <= '1';
            -- write the header-0 of the Read Response pakage
            writeContentData(15 downto 0) <= sourceId;                 -- write to the source address, this is a response pakage
            writeContentData(19 downto 16) <= FTYPE_MAINTENANCE_CLASS; -- ftype, maintenance
            writeContentData(21 downto 20) <= "01";                    -- tt
            writeContentData(31 downto 22) <= "0000000000";            -- acckId, vc, cfr, prio           
            stateRB <= SEND_MAINTENANCE_READ_RESPONSE_0; 

          -- Type 8 pakage formate, maintenance Write request
          elsif (ftype = FTYPE_MAINTENANCE_CLASS) and (ttype = TTYPE_MAINTENANCE_WRITE_REQUEST) and (tt = "01") then
            configWrite <= '1';                                        -- write config operation
            writeContent_o <= '1';                                     -- write the header-0
            writeContentData(15 downto 0) <= sourceId;                 -- write to the source address, this is a response pakage
            writeContentData(19 downto 16) <= FTYPE_MAINTENANCE_CLASS; -- ftype, maintenance
            writeContentData(21 downto 20) <= "01";                    -- tt
            writeContentData(31 downto 22) <= "0000000000";            -- acckId, vc, cfr, prio           
            stateRB <= SEND_MAINTENANCE_WRITE_RESPONSE_0;

          -- Error: unexpected ftype or ttype
          else
            wbStb <= '0';
            wbWe_o <= '0';
            byteOffset <= 0;
            writeFrameAbort_o <= '1';               -- over write the frame with an error frame
            errorCode <= BERR_FRAME_CODE;
            stateRB <= SEND_ERROR;     -- next state after the dataLane is stored in the switch buffer
          end if;

        when SEND_MAINTENANCE_READ_RESPONSE_0 =>
          byteCnt <= 0;
          configEnable <= '0';                             -- disable signal to the memoryConfig process
          -- write the header-1 of the Read Response pakage
          writeContentData(7 downto 0) <= tid;
          writeContentData(11 downto 8) <= "0000";         -- size/status
          writeContentData(15 downto 12) <= TTYPE_MAINTENANCE_READ_RESPONSE; -- transaction type, Maintenance Read Response 
          writeContentData(31 downto 16) <= baseDeviceId; -- destination address, because this is a response pakage
          crc16Current <= crc16Next;                      -- first frame's CRC
          stateRB <= SEND_MAINTENANCE_READ_RESPONSE_1; 

        when SEND_MAINTENANCE_READ_RESPONSE_1 =>
          byteCnt <= byteCnt + 1;                         -- using byteCnt as a counter
          if byteCnt = 0 then
            writeContentData <= X"FF" & X"000000";        -- write the filed with HOP + reserved
            crc16Current <= crc16Next;                    -- second frame's CRC
          elsif byteCnt = 1 then 
            if configAddress(2) = '0' then                -- check the wdptr bit in the config offset field
              writeContentData <= configDataRead;         -- write payload-0 with data if wdptr='0'
            else
              writeContentData <= (others => '0');        -- write zeros 
            end if;
            crc16Current <= crc16Next;                    -- third frame's CRC
          elsif byteCnt = 2 then
            if configAddress(2) = '0' then                -- check the wdptr bit in the config offset field
              writeContentData <= (others => '0');        -- write zeros
            else
              writeContentData <= configDataRead;         -- write payload-1 with data if wdptr='1'
            end if;
            crc16Current <= crc16Next;                    -- forth frame's CRC
          elsif byteCnt = 3 then
            writeContentData <= crc16Next & X"0000";      -- write the CRC field
          else
            writeContent_o <= '0';
            stateRB <= SEND_FRAME;
          end if;

        when SEND_MAINTENANCE_WRITE_RESPONSE_0 =>
          byteCnt <= 0;
          readContent_o <= '1';                           -- read the config offset
          if configAddress(2) = '0' then                  -- check the wdptr bit in the config offset field
            configDataWrite <= readContentData_i;         -- copy payload-0 if wdptr='0'
          else
            configDataWrite <= configDataWrite;           -- do nothing
          end if;
          writeContentData(7 downto 0) <= tid;
          writeContentData(11 downto 8) <= "0000";        -- size/status
          writeContentData(15 downto 12) <= TTYPE_MAINTENANCE_WRITE_RESPONSE; -- transaction type, Maintenance Write Response 
          writeContentData(31 downto 16) <= baseDeviceId; -- destination address, because this is a response pakage
          crc16Current <= crc16Next;                      -- first frame's CRC
          stateRB <= SEND_MAINTENANCE_WRITE_RESPONSE_1; 

        when SEND_MAINTENANCE_WRITE_RESPONSE_1 =>
          byteCnt <= byteCnt + 1;                         -- using byteCnt as a counter
          if byteCnt = 0 then
            writeContentData <= X"FF" & X"000000";        -- write the filed with HOP + reserved
            crc16Current <= crc16Next;                    -- second frame's CRC
          elsif byteCnt = 1 then 
            configEnable <= '1';                          -- enable signal to the memoryConfig process
            writeContentData <= crc16Next & X"0000";      -- write the CRC field
            if configAddress(2) = '0' then                -- check the wdptr bit in the config offset field
              configDataWrite <= configDataWrite;         -- do nothing
            else
              configDataWrite <= readContentData_i;       -- copy payload-1 if wdptr='1'
            end if;
          else 
            configEnable <= '0';                          -- disable signal to the memoryConfig process
            readContent_o <= '0';                         -- at this point even the frame's CRC is read from the buffer
            writeContent_o <= '0';
            stateRB <= SEND_FRAME;
          end if;

        when SEND_DONE_0 =>
          writeContent_o <= '1';
          writeContentData(7 downto 0) <= tid;
          writeContentData(11 downto 8) <= "0000";        -- size/status
          writeContentData(15 downto 12) <= "1000";       -- ttype
          writeContentData(31 downto 16) <= baseDeviceId;
          crc16Current <= crc16Next;                      -- first frame's CRC
          stateRB <= SEND_DONE_1; 

        when SEND_DONE_1 =>
          byteCnt <= 0;
          dataLane <= (others =>(others => '0'));
          writeContent_o <= '0';  -- this line is to make sure that the CRC is complete read
          crc16Current <= crc16Next;                      -- second frame's CRC
          wbAdr_o <= tempAddr;
          tempAddr <= tempAddr + 1;
          wbStb <= '1';
          wbWe_o <= '0';
          byteOffset <= pos;
          stateRB <= READ_FROM_WB;

        when READ_FROM_WB =>
          if wbAck_i = '1' then          
            timeOutCnt <= (others => '0');          -- reset the time out conter
            if wbErr_i = '0' then                   -- check if no error occur
              if (byteCnt < numberOfByte - 1) then  -- check if reach the last data byte
                byteCnt <= byteCnt + 1;
                if (byteCnt + headLen = 80) then    -- when current position in payload is a CRC position 
                  dataLane(0) <= crc16Current(15 downto 8);
                  dataLane(1) <= crc16Current(7 downto 0);
                  dataLane(2) <= wbData_i;
                  byteOffset <= 3;
                elsif byteOffset < 7 then
                  dataLane(byteOffset) <= wbData_i;
                  byteOffset <= byteOffset + 1;
                else                                 -- dataLane vector is ready to send to fifo
                  dataLane(7) <= wbData_i;
                  byteOffset <= 0;                   -- Here, sets byteOffset for other response
                  stateRB <= SEND_TO_FIFO;
                  nextStateRB <= READ_FROM_WB;       -- 
                end if;
              else                                   -- get last data from Wishbone
                wbStb <= '0';
                byteCnt <= 0;                        -- Here, using byteCnt and reset it for other response
                dataLane(byteOffset) <= wbData_i;                
                stateRB <= APPEND_CRC_AND_SEND;
                if byteOffset < 7 then               -- checking for CRC appending position
                  byteOffset <= byteOffset + 1;
                else
                  byteOffset <= 0;
                end if;
              end if;

            -- when Wishbone error occur
            else
              wbStb <= '0';
              wbWe_o <= '0';
              byteOffset <= 0;
              writeFrameAbort_o <= '1';               -- over write the frame with an error frame
              errorCode <= wbData_i;
              stateRB <= SEND_ERROR;
            end if;
          else                                       -- when no acknowledge received
            if timeOutCnt(13) = '1' then  -- when waiting more than 1 ms for response from the device
              wbStb <= '0';
              wbWe_o <= '0';
              byteOffset <= 0;
              writeFrameAbort_o <= '1';              -- over write the frame with an error frame
              errorCode <= BERR_NOT_RESPONSE;
              stateRB <= SEND_ERROR;
            else
              timeOutCnt <= timeOutCnt + 1;
            end if;
          end if;

        -- appending CRC and write to the fifo when frame is shorter then 80 bytes
        when APPEND_CRC_AND_SEND =>
          writeContent_o <= '0';
          byteCnt <= byteCnt + 1;
          -- check if frame is shorter than 80 bytes
          if (numberOfByte < 65) then
            -- Yes, frame is shorter then 80 bytes
            if byteCnt = 0 then
              -- first write the current double word to the fifo
              -- then put the CRC in the next double word
              byteOffset <= 0;
              stateRB <= SEND_TO_FIFO;
              nextStateRB <= APPEND_CRC_AND_SEND;
            elsif byteCnt = 1 then  
              -- append the CRC
              writeContent_o <= '1';
              writeContentData <= crc16Current & X"0000";
            else 
              stateRB <= SEND_FRAME;      -- store in the switch buffer
            end if;
          else
            --No, appending CRC and write to the fifo when frame is longer then 80 bytes
            if byteCnt = 0 then
              -- check if the last byte was placed in the second half of the double word,
              -- in that case write the first word to the fifo.
              writeContentData <= dataLane(0) & dataLane(1) & dataLane(2) & dataLane(3);
            elsif byteCnt = 1 then
              crc16Current <= crc16Temp; -- calcylate the crc for the 16 most significant bits 
            elsif byteCnt = 2 then 
              writeContent_o <= '1';
              writeContentData <= dataLane(0) & dataLane(1) & crc16Current;
            else
              stateRB <= SEND_FRAME;      -- store in the switch buffer
            end if;
          end if;


        when SEND_TO_FIFO =>
          if byteOffset = 0 then       -- using byteOffset as a counter
            byteOffset <= 1;
            writeContent_o <= '1';
            writeContentData <= dataLane(0) & dataLane(1) & dataLane(2) & dataLane(3);
          elsif byteOffset = 1 then    -- using byteOffset as a counter
            byteOffset <= 2;
            writeContent_o <= '0';
            crc16Current <= crc16Next; -- calcylate the crc
          elsif byteOffset = 2 then
            byteOffset <= 3;
            writeContent_o <= '1';
            writeContentData <= dataLane(4) & dataLane(5) & dataLane(6) & dataLane(7);
          elsif byteOffset = 3 then
            crc16Current <= crc16Next; -- calcylate the crc
            writeContent_o <= '0';
            byteOffset <= 0;
            stateRB <= nextStateRB;
            dataLane <= (others =>(others => '0'));
          end if;
          
        when READ_FROM_FIFO =>
          if (endianMsb = '1') then
            if (readContentEnd_i = '0') then
            endianMsb <= '0';
            dataLane(0 to 3) <= (readContentData_i(31 downto 24), readContentData_i(23 downto 16),
                                 readContentData_i(15 downto 8), readContentData_i(7 downto 0));
            else
              wbStb <= '0';
              wbWe_o <= '0';
              byteOffset <= 0;
              readContent_o <= '0';
              writeFrameAbort_o <= '1';               -- over write the frame with an error frame
              errorCode <= BERR_FRAME_SIZE;
              stateRB <= SEND_ERROR; 
--              stateRB <= IDLE;         
            end if;
          else
            endianMsb <= '1';
            readContent_o <= '0';
            dataLane(4 to 7) <= (readContentData_i(31 downto 24), readContentData_i(23 downto 16),
                                 readContentData_i(15 downto 8), readContentData_i(7 downto 0));
            if ready = '1' then
              stateRB <= nextStateRB;
            else
              stateRB <= WRITE_TO_WB;
            end if;
          end if;

        when WRITE_TO_WB =>
          if wbStb = '0' then
            wbStb <= '1';
            wbWe_o <= '1';
            byteCnt <= 1;
            byteOffset <= byteOffset + 1;   -- increase number of counted byte
            tempAddr <= tempAddr + 1;       -- increase the memory sddress address
            wbAdr_o <= tempAddr;
            wbData_o <= dataLane(byteOffset);
          else
            if wbAck_i = '1' then
              timeOutCnt <= (others => '0');   -- reset the time out conter
              if wbErr_i = '0' then            -- check the peripherals error signal
                if byteCnt < numberOfByte then
                  tempAddr <= tempAddr + 1; -- increase the memory sddress address 
                  wbAdr_o <= tempAddr;
                  wbData_o <= dataLane(byteOffset);
                  byteCnt <= byteCnt + 1;   -- increase number of counted byte 
                  if byteOffset < 7 then
                    if (byteCnt + headLen = 79) then  -- check for the CRC-byte position 80 in the frame  
                      byteOffset <= byteOffset + 3;
                    else
                      byteOffset <= byteOffset + 1;
                    end if;
                  else
                    if (byteCnt + headLen = 79) then  -- check for the CRC-byte position 80 in the frame  
                      byteOffset <= 2;
                    else
                      byteOffset <= 0;
                    end if;
                    if byteCnt < numberOfByte - 1 then 
                      readContent_o <= '1';
                      stateRB <= READ_FROM_FIFO;
                    end if;
                  end if;
                else                        -- no more data to send to the peripherals
                  wbStb <= '0';
                  wbWe_o <= '0';
                  ready <= '1';
                  stateRB <= SEND_FRAME;
                end if;
              else                          -- if the peripheral generates an error, send an error Response
                wbStb <= '0';
                wbWe_o <= '0';
                byteOffset <= 0;
                writeFrameAbort_o <= '1';               -- over write the frame with an error frame
                errorCode <= wbData_i;
                stateRB <= SEND_ERROR;                
              end if;
            else
--              if readContentEnd_i = '1' then  -- when unvalid data in the switch buffer
--                wbStb <= '0';
--                wbWe_o <= '0';
--                readFrame_o <= '1';
--                byteOffset <= 0;
--                writeFrameAbort_o <= '1';               -- over write the frame with an error frame
--                errorCode <= BERR_FRAME_SIZE; -- more data content is expected, Frame size error
--                stateRB <= SEND_ERROR;
--              else
                if timeOutCnt(13) = '1' then  -- when waiting more than 1 ms for response from the device
                  wbStb <= '0';
                  wbWe_o <= '0';
                  readFrame_o <= '1';
                  byteOffset <= 0;
                  writeFrameAbort_o <= '1';               -- over write the frame with an error frame
                  errorCode <= BERR_NOT_RESPONSE;
                  stateRB <= SEND_ERROR;
                else
                  timeOutCnt <= timeOutCnt + 1;
                end if;
--              end if;                  
            end if;
          end if;

        when SEND_ERROR =>  -- Generate a Response Class, an error pakage ftype=13, ttype=8, status="1111"
          readFrame_o <= '0';
          writeFrameAbort_o <= '0';
          byteOffset <= byteOffset + 1;
          if byteOffset = 0 then
            writeContent_o <= '1';                   -- start write to the buffer
            crc16Current <= (others => '1');
            writeContentData <= "00000000" & "00" & "01" & "1101" & sourceId;
          elsif byteOffset = 1 then
            writeContentData <= baseDeviceId & "1000" & "1111" & tid;
            crc16Current <= crc16Next;               -- first frame's CRC
          elsif byteOffset = 2 then
            writeContentData <= errorCode & x"000000";
            crc16Current <= crc16Next;               -- second frame's CRC
          elsif byteOffset = 3 then
            writeContentData <= x"00000000";
            crc16Current <= crc16Next;               -- third frame's CRC
          elsif byteOffset = 4 then
            writeContentData <= crc16Next & X"0000"; -- write the CRC field
          else
            writeContent_o <= '0';
            writeFrame_o <= '1';
            readFrame_o <= '1';
            stateRB <= WAIT_IDLE;
          end if;

        when SEND_FRAME =>
          if (ftype = FTYPE_WRITE_CLASS) and (ttype = TTYPE_NWRITE_TRANSACTION) and (tt = "01") then    -- check what type of pakage we got
            readFrame_o <= '1';
          elsif (ftype = FTYPE_REQUEST_CLASS) and (ttype = TTYPE_NREAD_TRANSACTION) and (tt = "01") then -- write payload to the buffer is done
            readFrame_o <= '1';
            writeFrame_o <= '1';
          else                         -- the operation was not valid 
            readFrame_o <= '1';
            writeFrame_o <= '1';
          end if;
            stateRB <= WAIT_IDLE;
          
        when WAIT_IDLE =>
          readFrame_o <= '0';
          writeFrame_o <= '0';
          readContent_o <= '0';   -- this line is to make sure that the CRC is complete read
          stateRB <= IDLE;

        when others =>
          stateRB <= IDLE;

      end case;

    end if;

  end process;  

  -----------------------------------------------------------------------------
  -- Configuration memory.
  -----------------------------------------------------------------------------
  memoryConfig : process(clk, areset_n)
  begin
    if (areset_n = '0') then
      configDataRead <= (others => '0');
      baseDeviceId <= DEFAULT_BASE_DEVICE_ID;
      componentTag <= (others => '0');
      hostBaseDeviceIdLocked <= '0';
      hostBaseDeviceId <= (others => '1');
    elsif (clk'event and clk = '1') then

      if (configEnable = '1') then
        case (configAddress) is
          when x"000000" =>
            -- Device Identity CAR. Read-only.
            configDataRead(31 downto 16) <= DEVICE_IDENTITY;
            configDataRead(15 downto 0) <= DEVICE_VENDOR_IDENTITY;
          when x"000004" =>
            -- Device Information CAR. Read-only.
            configDataRead(31 downto 0) <= DEVICE_REV;
          when x"000008" =>
            -- Assembly Identity CAR. Read-only.
            configDataRead(31 downto 16) <= ASSY_IDENTITY;
            configDataRead(15 downto 0) <= ASSY_VENDOR_IDENTITY;
          when x"00000c" =>
            -- Assembly Informaiton CAR. Read-only.
            -- Extended features pointer to "0000".
            configDataRead(31 downto 16) <= ASSY_REV;
            configDataRead(15 downto 0) <= x"0000";
          when x"000010" =>
            -- Processing Element Features CAR. Read-only.
            -- Bridge(31), Memory(30), Processor(29), Switch(28).
            configDataRead(31) <= '1';
            configDataRead(30 downto 4) <= (others => '0');
            configDataRead(3) <= '1';            -- support 16 bits common transport large system
            configDataRead(2 downto 0) <= "001"; -- support 34 bits address
          when x"000018" =>
            -- Source Operations CAR. Read-only.
            configDataRead(31 downto 0) <= (others => '0');
          when x"00001C" =>
            -- Destination Operations CAR. Read-only.
            configDataRead(31 downto 16) <= (others => '0');
            configDataRead(15) <= '1';
            configDataRead(14) <= '1';
            configDataRead(13 downto 0) <= (others => '0');
          when x"00004C" =>
            -- Processing Element Logical Layer Control CSR.
            configDataRead(31 downto 3) <= (others => '0');
            configDataRead(2 downto 0) <= "001"; -- support 34 bits address
          when x"000060" =>
            -- Base Device ID CSR.
            -- Only valid for end point devices.
            if (configWrite = '1') then
              baseDeviceId <= configDataWrite(15 downto 0);
            else
              configDataRead(15 downto 0) <= baseDeviceId;
            end if;
          when x"000068" =>
            -- Host Base Device ID Lock CSR.
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
            else
              configDataRead(31 downto 16) <= (others => '0');
              configDataRead(15 downto 0) <= hostBaseDeviceId;
            end if;
          when x"00006C" =>
            -- Component TAG CSR.
            if (configWrite = '1') then
              componentTag <= configDataWrite;
            else
              configDataRead <= componentTag;
            end if;

          when others =>
            configDataRead <= (others => '0');
        end case;
      else
        -- Config memory not enabled.
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- findInPayload
  -- find out number of the bytes and first byte's position in the payload.
  -----------------------------------------------------------------------------
  findInPayload: process(wdptr, size)
  begin
    case size is 
      when "0000" =>
        reserved <= '0';
        numberOfByte <= 1;
        if wdptr = '1' then
          pos <= 4;
        else
          pos <= 0;
        end if;
      when "0001" =>
        reserved <= '0';
        numberOfByte <= 1;
        if wdptr = '1' then
          pos <= 5;
        else
          pos <= 1;
        end if;
      when "0010" =>
        reserved <= '0';
        numberOfByte <= 1;
        if wdptr = '1' then
          pos <= 6;
        else
          pos <= 2;
        end if;
      when "0011" =>
        reserved <= '0';
        numberOfByte <= 1;
        if wdptr = '1' then
          pos <= 7;
        else
          pos <= 3;
        end if;
      when "0100" =>
        reserved <= '0';
        numberOfByte <= 2;
        if wdptr = '1' then
          pos <= 4;
        else
          pos <= 0;
        end if;
      when "0101" =>
        reserved <= '0';
        numberOfByte <= 3;
        if wdptr = '1' then
          pos <= 5;
        else
          pos <= 0;
        end if;
      when "0110" =>
        reserved <= '0';
        numberOfByte <= 2;
        if wdptr = '1' then
          pos <= 6;
        else
          pos <= 2;
        end if;
      when "0111" =>
        reserved <= '0';
        numberOfByte <= 5;
        if wdptr = '1' then
          pos <= 3;
        else
          pos <= 0;
        end if;
      when "1000" =>
        reserved <= '0';
        numberOfByte <= 4;
        if wdptr = '1' then
          pos <= 4;
        else
          pos <= 0;
        end if;
      when "1001" =>
        reserved <= '0';
        numberOfByte <= 6;
        if wdptr = '1' then
          pos <= 2;
        else
          pos <= 0;
        end if;
      when "1010" =>
        reserved <= '0';
        numberOfByte <= 7;
        if wdptr = '1' then
          pos <= 1;
        else
          pos <= 0;
        end if;
      when "1011" =>
        reserved <= '0';
        if wdptr = '1' then
          numberOfByte <= 16;
        else
          numberOfByte <= 8;
        end if;
        pos <= 0;
      when "1100" =>
        reserved <= '0';
        if wdptr = '1' then
          numberOfByte <= 64;
        else
          numberOfByte <= 32;
        end if;
        pos <= 0;
      when "1101" =>
        if wdptr = '1' then
          reserved <= '0';
          numberOfByte <= 128;
        else
          reserved <= '1';
          numberOfByte <= 96;
        end if;
        pos <= 0;
      when "1110" =>
        if wdptr = '1' then
          numberOfByte <= 192;
        else
          numberOfByte <= 160;
        end if;
        reserved <= '1';
        pos <= 0;
      when "1111" =>
        if wdptr = '1' then
          reserved <= '0';
          numberOfByte <= 256;
        else
          reserved <= '1';
          numberOfByte <= 224;
        end if;
        pos <= 0;
      when others =>
        reserved <= '1';
        numberOfByte <= 0;
        pos <= 0;
    end case;
  end process;

end architecture;
