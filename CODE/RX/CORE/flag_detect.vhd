-------------------------------------------------------------------------------
-- Title      :  HDLC flag detection
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : flag_detect.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     : 2000/12/28
-- Last update: 2001/01/12
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--
-------------------------------------------------------------------------------
-- Description:  Flag detection
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
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   2
-- Version         :   0.2
-- Date            :   10 Jan 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Code clean
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   3
-- Version         :   0.3
-- Date            :   12 Jan 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   RXEN bug fixed
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity FlagDetect_ent is

  port (
    Rxclk      : in  std_logic;         -- Rx clock
    rst        : in  std_logic;         -- system reset
    FlagDetect : out std_logic;         -- Flag detected
    Abort      : out std_logic;         -- Abort signal detected
    RxEn       : in  std_logic;         -- RX enable
    RXEn_O     : out std_logic;         -- RXEN output signal
    RXD        : out std_logic;         -- RXD output
    RX         : in  std_logic);        -- RX signal

end FlagDetect_ent;

architecture FlagDetect_beh of FlagDetect_ent is

  signal ShiftReg : std_logic_vector(7 downto 0);  -- Shift Register

begin  -- FlagDetect_beh

  -- purpose: Flag detection
  -- type   : sequential
  -- inputs : RXclk, rst
  -- outputs: 
  bitstreem_proc : process (RXclk, rst)

    variable FlagVar    : std_logic;    -- Flag detected variable
    variable Enable_Reg : std_logic_vector(7 downto 0);  -- Enable Register

  begin  -- process bitstreem_proc
    if rst = '0' then                   -- asynchronous reset (active low)

      FlagDetect <= '0';
      Abort      <= '0';

      RXD <= '0';

      FlagVar := '0';

      ShiftReg <= (others => '0');

      RXEN_O     <= '1';
      Enable_Reg := (others => '1');

    elsif RXclk'event and RXclk = '1' then  -- rising clock edge

      FlagVar := not ShiftReg(0) and ShiftReg(1) and ShiftReg(2) and ShiftReg(3) and ShiftReg(4) and ShiftReg(5) and ShiftReg(6) and not ShiftReg(7);

      FlagDetect <= FlagVar;

      Abort <= not ShiftReg(0) and ShiftReg(1) and ShiftReg(2) and ShiftReg(3) and ShiftReg(4) and ShiftReg(5) and ShiftReg(6) and ShiftReg(7);


      ShiftReg(7 downto 0) <= RX & ShiftReg(7 downto 1);
      RXD                  <= ShiftReg(0);

      RXEN_O <= Enable_Reg(0);

      Enable_Reg(7 downto 0) := RXEN & Enable_Reg(7 downto 1);

    end if;
  end process bitstreem_proc;

end FlagDetect_beh;
