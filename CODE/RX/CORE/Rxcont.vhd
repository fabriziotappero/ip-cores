-------------------------------------------------------------------------------
-- Title      :  Rx Controller
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : Rxcont.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     : 2000/12/30
-- Last update: 2001/04/27
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--
-------------------------------------------------------------------------------
-- Description:  receive Controller
-------------------------------------------------------------------------------
-- Copyright (c) 2000 Jamil Khatib
-- 
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it after contacting the author
-- You can check the draft license at
-- http://www.opencores.org/OIPC/license.shtml

-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   1
-- Version         :   0.1
-- Date            :   30 Dec 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :
-- Bugs            :   
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   2
-- Version         :   0.2
-- Date            :   27 April 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Enable and Available Bugs fixed
-- ToOptimize      :
-- Bugs            :   
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity rxcont_ent is

  port (
    RxClk        : in  std_logic;       -- Rx Clcok
    rst          : in  std_logic;       -- system Reset
    RxEn         : in  std_logic;       -- Rx Enable
    AbortedFrame : out std_logic;       -- Aborted frame
    Abort        : in  std_logic;       -- Abort detected
    FlagDetect   : in  std_logic;       -- Flag Detect
    ValidFrame   : out std_logic;       -- Valid Frame
    FrameError   : out std_logic;       -- Frame Error (Indicates error in the
                                        -- next byte at the backend
    aval         : in  std_logic;       -- Can accept more data
    initzero     : out std_logic;       -- init Zero detect block
    enable       : out std_logic);      -- Enable

end rxcont_ent;

architecture rxcont_beh of rxcont_ent is

--  signal validFrame_i : std_logic;    -- Internal Valid Frame signal

begin  -- rxcont_beh
-- purpose: Enable controller
-- type   : sequential
-- inputs : Rxclk, rst
-- outputs: 
  enable_proc               : process (Rxclk, rst)
    variable counter        : integer range 0 to 7;  -- Counter
    variable FlagCounter    : integer range 0 to 7;  -- Flag bits counter
    variable FrameStatus    : std_logic;  -- Frame Status
    variable FlagInit       : std_logic;  -- Init flag counter
    variable FrameStatusReg : std_logic_vector(7 downto 0);
                                        -- Delay for Frame Status
  begin  -- process enable_proc
    if rst = '0' then                   -- asynchronous reset (active low)

      enable         <= '0';
      FrameStatus    := '0';
      ValidFrame     <= '0';
      AbortedFrame   <= '0';
      Counter        := 0;
      FlagInit       := '0';
      initzero       <= '0';
      FrameStatusReg := (others => '0');
		FrameError <= '0';
	  FlagCounter := 0;

    elsif Rxclk'event and Rxclk = '1' then  -- rising clock edge
-------------------------------------------------------------------------------
-- This is the Valid frame machine
      if FlagDetect = '1' then
        FlagInit     := '1';
        FrameStatus  := '0';
        FlagCounter  := 0;
        AbortedFrame <= '0';
      end if;

      if FlagInit = '1' then

        if FlagCounter = 7 then
          FrameStatus := '1';
          FlagCounter := 0;
          initzero    <= '1';
          FlagInit    := '0';
        else
          FlagCounter := FlagCounter + 1;
          initzero    <= '0';
        end if;
      else
        initzero      <= '0';
      end if;

      if Abort = '1' then
        FrameStatus  := '0';
        AbortedFrame <= '1';
      end if;
      ValidFrame     <= FrameStatusReg(0);

      FrameStatusReg(7 downto 0) := FrameStatus & FrameStatusReg(7 downto 1);






-------------------------------------------------------------------------------
-- This is the enable machine
      if RxEn = '1' then

        if FrameStatus = '1' then

          if aval = '1' then

            enable     <= '1';
            Counter    := 0;
            FrameError <= '0';
          else

            if counter = 5 then

              enable <= '0';
              counter := 0;
              FrameError <= '1';

            else

              enable <= '1';

              Counter    := Counter +1;
              FrameError <= '0';
            end if;  -- counter

          end if;  -- aval
        else
          FrameError <= '0';
          enable     <= '0';
--        Counter := 0;

        end if;  -- validframe
      else
        FrameError <= '0';
        enable     <= '0';
--      Counter := 0;

      end if;  -- rxen

    end if;  -- clock
  end process enable_proc;

-------------------------------------------------------------------------------
end rxcont_beh;
