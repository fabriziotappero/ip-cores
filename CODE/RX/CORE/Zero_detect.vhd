-------------------------------------------------------------------------------
-- Title      :  Zero Detection
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : zero_detect.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     : 2000/12/28
-- Last update: 2001/04/27
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: FPGA express 3
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--
-------------------------------------------------------------------------------
-- Description:  Zero Detection
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
-- Date            :   28 Dec 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :   Needs large external buffer (1 byte internal buffer)
--                     for low speed backend interface 
--                     (flow control is used to manage this problem)
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   2
-- Version         :   0.2
-- Date            :   12 Jan 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Enable bug fixed
-- ToOptimize      :   Needs large external buffer (1 byte internal buffer)
--                     for low speed backend interface 
--                     (flow control is used to manage this problem)
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   3
-- Version         :   0.3
-- Date            :   27 April 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Available and enable bugs fixed
-- ToOptimize      :  
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ZeroDetect_ent is

  port (
    ValidFrame : in  std_logic;         -- Valid Frame strobe
    Readbyte   : in  std_logic;         -- Back end read byte
    aval       : out std_logic;         -- can get more data (connected to flow
                                        -- controller
    enable     : in  std_logic;         -- enable (Driven by flow controller)

    rdy          : out std_logic;                      -- data ready
    rst          : in  std_logic;                      -- system reset
    StartofFrame : in  std_logic;                      -- start of Frame
    RxClk        : in  std_logic;                      -- RX clock
    RxD          : in  std_logic;                      -- RX data
    RxData       : out std_logic_vector(7 downto 0));  -- Receive Data bus

end ZeroDetect_ent;

architecture ZeroDetect_beh of ZeroDetect_ent is
  signal DataRegister : std_logic_vector(7 downto 0);
                                        -- Data register
  signal flag         : std_logic;      -- 8 Bits data ready

begin  -- ZeroDetect_beh

-- purpose: Detect zero
-- type   : sequential
-- inputs : RxClk, rst
-- outputs: 
  detect_proc : process (RxClk, rst)

    variable ZeroDetected : std_logic;                     -- Zero Detected
    variable tempRegister : std_logic_vector(7 downto 0);  -- Data Register
    variable counter      : integer range 0 to 7;          -- Counter

    variable checkreg : std_logic_vector(5 downto 0);  -- Check register

  begin  -- process detect
    if rst = '0' then                   -- asynchronous reset (active low)

      counter      := 0;
      tempRegister := (others => '0');

      DataRegister <= (others => '0');

      flag         <= '0';
      ZeroDetected := '0';

      checkreg := (others => '0');

    elsif RxClk'event and RxClk = '1' then  -- rising clock edge
      if enable = '1' then                  -- No overflow on the backend

        -- add new bit to the register
--        tempRegister(counter) := RxD;

        if StartofFrame = '0' then

          -- add new bit to the check register
          checkreg              := RxD & checkreg(5 downto 1);
          tempRegister(counter) := RxD;
        else
          -- reset the check register
          checkreg              := (RxD, others => '0');
          counter               := 0;
          tempRegister(counter) := RxD;
        end if;

        -- check if we got 5 ones
        ZeroDetected := not checkreg(5) and checkreg(4) and checkreg(3) and checkreg(2) and checkreg(1) and checkreg(0);


        if ZeroDetected = '1' then

          flag <= '0';

        else

          if counter = 7 then

            DataRegister <= tempRegister;

            counter := 0;

            flag <= '1';


          else

            counter := counter + 1;

            flag <= '0';

          end if;

        end if;

      end if;

    end if;
  end process detect_proc;
-------------------------------------------------------------------------------
  -- purpose: Backend process
  -- type   : sequential
  -- inputs : Rxclk, rst
  -- outputs: 
  backend_proc : process (Rxclk, rst)

    variable status  : std_logic;       -- Status
    variable rdy_var : std_logic;       -- temp variable for Rdy

  begin  -- process backend_proc
    if rst = '0' then                   -- asynchronous reset (active low)


      RxData <= (others => '0');

      status := '0';
      aval   <= '1';

      rdy_var := '0';

      rdy <= '0';

    elsif Rxclk'event and Rxclk = '1' then  -- rising clock edge
      if enable = '1' then

        if flag = '1' then

          status := '1';                -- Can not take more

          RxData  <= DataRegister;
          rdy_var := '1';

        end if;  -- flag

      end if;  -- enable
      if readbyte = '1' then

        status := '0';                  -- can take more data

        rdy_var := '0';

      end if;  -- readbyte

      rdy <= rdy_var;

      if ValidFrame = '0' then
        aval <= '1';
      else

        aval <= not status;
      end if;


    end if;  -- clk


  end process backend_proc;

-------------------------------------------------------------------------------

end ZeroDetect_beh;
