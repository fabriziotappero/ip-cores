-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- Description
-- Contains a testbench for the generic UART entity.
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
-- TestUart.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for TestUart.
-------------------------------------------------------------------------------
entity TestUart is
end entity;


-------------------------------------------------------------------------------
-- Architecture for TestUart.
-------------------------------------------------------------------------------
architecture TestUartImpl of TestUart is
  
  component Uart is
    generic(
      DIVISOR_WIDTH : natural;
      DATA_WIDTH : natural);
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      divisor_i : in std_logic_vector(DIVISOR_WIDTH-1 downto 0);
      
      serial_i : in std_logic;
      serial_o : out std_logic;
      
      empty_o : out std_logic;
      read_i : in std_logic;
      data_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
      
      full_o : out std_logic;
      write_i : in std_logic;
      data_i : in std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;

  signal clk : std_logic;
  signal areset_n : std_logic;
  
  signal rxSerial : std_logic;
  signal txSerial : std_logic;

  signal rxEmpty : std_logic;
  signal rxRead : std_logic;
  signal rxData : std_logic_vector(7 downto 0);
      
  signal txFull : std_logic;
  signal txWrite : std_logic;
  signal txData : std_logic_vector(7 downto 0);
  
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
  -- Serial port emulator.
  -----------------------------------------------------------------------------
  TestDriver: process
    
    procedure SerialSend(
      constant data : in std_logic_vector(7 downto 0)) is
      variable outgoing : std_logic_vector(9 downto 0);
    begin
      -- Create the complete transmission character.
      outgoing(0) := '0';
      for i in 0 to 7 loop
        outgoing(i+1) := data(i);
      end loop;
      outgoing(9) := '1';

      -- Send the character.
      for i in 0 to 9 loop
        txSerial <= outgoing(i);
        wait for 500 ns;
      end loop;
    end procedure;

    procedure SerialReceive(
      constant data : in std_logic_vector(7 downto 0)) is
      variable incomming : std_logic_vector(9 downto 0);
    begin
      -- Receive the character.
      wait until rxSerial = '0';
      incomming(0) := '0';
      for i in 1 to 9 loop
        wait for 500 ns;
        incomming(i) := rxSerial;
      end loop;

      -- Check if the received character is expected.
      assert (incomming(0) = '0') report "Start bit." severity error;
      assert (incomming(8 downto 1) = data) report "Data bit" severity error;
      assert (incomming(9) = '1') report "Stop bit." severity error;
    end procedure;

  begin
    txSerial <= '1';
    txWrite <= '0';
    rxRead <= '0';
    areset_n <= '0';

    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    areset_n <= '1';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    
    ---------------------------------------------------------------------------
    -- Send byte to uart.
    ---------------------------------------------------------------------------
    SerialSend(x"55");
    wait until rxEmpty = '0' and clk'event and clk = '1';
    rxRead <= '1';
    wait until clk'event and clk = '1';
    rxRead <= '0';
    wait until clk'event and clk = '1';
    assert rxData = x"55" report "rxData" severity error;

    SerialSend(x"62");
    wait until rxEmpty = '0' and clk'event and clk = '1';
    rxRead <= '1';
    wait until clk'event and clk = '1';
    rxRead <= '0';
    wait until clk'event and clk = '1';
    assert rxData = x"62" report "rxData" severity error;

    wait until txFull = '0' and clk'event and clk = '1';
    txWrite <= '1';
    txData <= x"55";
    wait until clk'event and clk = '1';
    txWrite <= '0';
    SerialReceive(x"55");

    wait until txFull = '0' and clk'event and clk = '1';
    txWrite <= '1';
    txData <= x"62";
    wait until clk'event and clk = '1';
    txWrite <= '0';
    SerialReceive(x"62");

    -- REMARK: Formalize the tests and write more testcases...

    ---------------------------------------------------------------------------
    -- Test completed.
    ---------------------------------------------------------------------------
    
    TestEnd;
  end process;

  
  -----------------------------------------------------------------------------
  -- Instantiate the uart.
  -----------------------------------------------------------------------------

  UartInst: Uart
    generic map(DIVISOR_WIDTH=>4, DATA_WIDTH=>8)
    port map(
      clk=>clk, areset_n=>areset_n,
      divisor_i=>"1011",
      serial_i=>txSerial, serial_o=>rxSerial,
      empty_o=>rxEmpty, read_i=>rxRead, data_o=>rxData,
      full_o=>txFull, write_i=>txWrite, data_i=>txData);

end architecture;
