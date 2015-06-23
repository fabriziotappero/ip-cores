-------------------------------------------------------------------------------
-- Title      :  Data scrambler
-- Project    :  Bluetooth baseband core
-------------------------------------------------------------------------------
-- File        : scrambler.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     : 2000/12/18
-- Last update : 2000/12/18
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: Leonardo/WindowsNT
-- Target      : 
-- Dependency  : ieee.std_logic_1164
-------------------------------------------------------------------------------
-- Description: Data scrambler core (data whitening)
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
-- Date            :   18 Dec 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- Known bugs      :   
-- To Optimze      :   Needs one clock cycle to load new init value before it
--                     accepts new data
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity scrambler_ent is
  
  port (
    clk   : in  std_logic;                     -- system clock
    rst_n : in  std_logic;                     -- system reset
    Din   : in  std_logic;                     -- Data in
    Dout  : out std_logic;                     -- Data out
    init  : in  std_logic_vector(6 downto 0);  -- LFSR init value
    load  : in  std_logic);                    -- Load new packet and init LFSR

end scrambler_ent;

architecture scrambler_beh of scrambler_ent is
	 signal lfsr : std_logic_vector(6 downto 0);  -- LFSR register
begin  -- scrambler_beh

-- purpose: Scrmbler core
-- type   : sequential
-- inputs : clk, rst_n
-- outputs: 
scrambler_proc: process (clk, rst_n)
  
  
  
begin  -- process scrambler_proc
  if rst_n = '0' then                   -- asynchronous reset (active low)
    
    Dout <= '0';
    lfsr <= (others => '0');
    
  elsif clk'event and clk = '1' then    -- rising clock edge
    if load = '1' then
      lfsr <= init;
      Dout <= '0';
    else
        Dout <= Din xor lfsr(6);
        lfsr(6 downto 5) <= lfsr(5 downto 4);
        lfsr(4) <= lfsr(3) xor lfsr(6);
        lfsr(3 downto 0) <=  lfsr(2 downto 0) & lfsr(6);
    end if;
  end if;
end process scrambler_proc;
  

end scrambler_beh;
