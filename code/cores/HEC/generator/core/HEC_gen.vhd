-------------------------------------------------------------------------------
-- Title      :  HEC generator
-- Project    :  Bluetooth baseband core
-------------------------------------------------------------------------------
-- File        : hec_gen.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     : 2000/12/28
-- Last update : 2000/12/28
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: Leonardo/WindowsNT
-- Target      : 
-- Dependency  : ieee.std_logic_1164
-------------------------------------------------------------------------------
-- Description: HEC generator core
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
-- Known bugs      :   
-- To Optimze      :  
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity HECgen_ent is

  port (
    clk    : in  std_logic;                     -- system clock
    rst    : in  std_logic;                     -- system reset
    header : in  std_logic_vector(9 downto 0);  -- header data
    hec    : out std_logic_vector(7 downto 0);  -- HEC 8 bit value
    init   : in  std_logic_vector(7 downto 0);  -- init value
    load   : in  std_logic);                    -- load header

end HECgen_ent;

architecture HECgen_beh of HECgen_ent is

begin  -- HECgen_beh



  -- purpose: Generate HEC
  -- type   : sequential
  -- inputs : clk, rst
  -- outputs: 
  generate_proc : process (clk, rst)

    variable lfsr         : std_logic_vector(7 downto 0);  -- LFSR (HEC register)
    variable feedback_var : std_logic;  -- feed back variable

  begin  -- process generate_proc
    if rst = '0' then                   -- asynchronous reset (active low)

      lfsr := (others => '0');
      HEC  <= (others => '0');

    elsif clk'event and clk = '1' then  -- rising clock edge

      if load = '1' then

        lfsr := init;

      else

        for i in 9 downto 0 loop

          feedback_var := header(i) xor lfsr(7);

          lfsr(7) := feedback_var xor lfsr(6);
          lfsr(6) := lfsr(5);
          lfsr(5) := feedback_var xor lfsr(4);
          lfsr(4) := lfsr(3);
          lfsr(3) := lfsr(2);
          lfsr(2) := feedback_var xor lfsr(1);
          lfsr(1) := feedback_var xor lfsr(0);
          lfsr(0) := feedback_var;

        end loop;  -- i


      end if;

      HEC <= lfsr;

    end if;

  end process generate_proc;

end HECgen_beh;
