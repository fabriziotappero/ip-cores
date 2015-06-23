-------------------------------------------------------------------------------
-- Title      :  Flag insertion block
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : flag_ins.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     :2001/01/11
-- Last update: 2001/01/26
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--
-------------------------------------------------------------------------------
-- Description:  Transmit and insert flag and idle patterns
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
-- Date            :   11 Jan 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :
-- Bugs            :   
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity flag_ins_ent is

  port (
    TXclk      : in  std_logic;         -- TX clock
    rst_n      : in  std_logic;         -- system reset
    TX         : out std_logic;         -- TX data
    TXEN       : in  std_logic;         -- TX enable
    TXD        : in  std_logic;         -- TX input data
    AbortFrame : in  std_logic;         -- Abort Current Frame
    Frame      : in  std_logic);        -- Valid Frame

end flag_ins_ent;


architecture flag_ins_beh of flag_ins_ent is

begin  -- flag_ins_beh

  -- purpose: Tranmit process
  -- type   : sequential
  -- inputs : TXclk, rst_n
  -- outputs: 
  process (TXclk, rst_n)

    variable transmit_reg : std_logic_vector(7 downto 0);  -- Transmit Register
    variable state        : std_logic;                     -- Internal state

  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)

      transmit_reg := (others => '1');
      state        := '0';
      TX           <= '1';

    elsif TXclk'event and TXclk = '1' then  -- rising clock edge

      if TXEN = '1' then

        case state is
          -- idle state
          when '0' =>

            TX <= transmit_reg(0);

            transmit_reg(7 downto 0) := '1' & transmit_reg(7 downto 1);

            if Frame = '1' and AbortFrame = '0' then
              state        := '1';
              transmit_reg := "01111110";
            end if;

            -- Normal operation
          when '1' =>

            TX <= transmit_reg(0);

            transmit_reg(7 downto 0) := TXD & transmit_reg(7 downto 1);

            if AbortFrame = '1' then

              transmit_reg := "11111110";
              state        := '0';

            elsif Frame = '0' then

              transmit_reg := "01111110";
              state        := '0';

            end if;

          when others => null;

        end case;

      else

        TX <= '1';

      end if;  -- end TXEN
    end if;  -- end TXclk
  end process;

end flag_ins_beh;
