-------------------------------------------------------------------------------
-- Title      :  Tx Channel test bench
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : tx_tb.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     :2001/01/16
-- Last update: 2001/01/26
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--
-------------------------------------------------------------------------------
-- Description:  Transmit Channel test bench
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
-- Date            :   16 Jan 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :
-- Bugs            :   
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library hdlc;
use hdlc.hdlc_components_pkg.all;

entity tx_tb_ent is

end tx_tb_ent;

architecture tx_tb_beh of tx_tb_ent is
  type streem is array (0 to 3) of std_logic_vector(7 downto 0);
  constant dataStreem : streem := ("10010110", "11111111", "01101101", "10010011");

  signal TxClk        : std_logic := '0';  -- System clock
  signal rst_n        : std_logic := '0';  -- system reset
  signal TXEN         : std_logic;      -- TX enable
  signal TX           : std_logic;      -- Transmit serial data
  signal ValidFrame   : std_logic := '0';  -- ValidFrame
  signal AbortFrame   : std_logic;      -- Abort Frame
  signal AbortedTrans : std_logic;      -- Aborted transmission
  signal WriteByte    : std_logic := '0';  -- Backend Write byte
  signal rdy          : std_logic;      -- Backend Ready
  signal TxData       : std_logic_vector(7 downto 0);  -- Backend data bus

begin  -- tx_tb_beh

  uut : TxChannel_ent
    port map (
      TxClk        => TxClk,
      rst_n        => rst_n,
      TXEN         => TXEN,
      Tx           => Tx,
      ValidFrame   => ValidFrame,
      AbortFrame   => AbortFrame,
      AbortedTrans => AbortedTrans,
      WriteByte    => WriteByte,
      rdy          => rdy,
      TxData       => TxData);

-------------------------------------------------------------------------------

  Txclk <= not Txclk after 20 ns;

  rst_n <= '0',
           '1' after 30 ns;

  TxEn <= '1';                          --,
--          '0' after 960 ns,
--          '1' after 1280 ns;

  AbortFrame <= '0';

-------------------------------------------------------------------------------
  -- purpose: Serial Interface
  -- type   : sequential
  -- inputs : TxClk, rst
  -- outputs: 
  Serial_Interface   : process (TxClk, rst_n)
    variable output  : std_logic_vector(7 downto 0) := "00000000";
                                                           -- Output regieter
    variable counter : integer                      := 0;  -- Counter

  begin  -- process Serial Interface
    if rst_n = '0' then                 -- asynchronous reset (active low)

      output  := (others => '0');
      Counter := 0;

    elsif TxClk'event and TxClk = '1' then  -- rising clock edge

      output  := TX & output(7 downto 1);
      Counter := Counter +1;

      if counter = 7 then
        counter := 0;
      end if;

    end if;
  end process Serial_Interface;
-----------------------------------------------------------------------------

-- purpose: Backend process
-- type   : combinational
-- inputs : 
-- outputs: 
  backend_proc       : process
    variable counter : integer := 6;    -- counter

  begin  -- process backend_proc

    for i in 0 to dataStreem'length-1 loop

      if counter = 6 then
        ValidFrame <= '0' after 330 ns,
                      '1' after 640 ns;
        counter    := 0;
      end if;

      wait until rdy = '1';

      WriteByte <= '1' after 30 ns;

      TxData <= dataStreem(i);

      counter := counter +1;

      wait until rdy = '0';
      WriteByte <= '0' after 10 ns;

    end loop;  -- i

  end process backend_proc;
--Used to check the Abort Condition
--  WriteByte <= '1' after 730 ns,
--               '0' after 750 ns,
--               '1' after 1310 ns,
--               '0' after 1340 ns,
--               '1' after 1980 ns,
--               '0' after 2000 ns;
end tx_tb_beh;
