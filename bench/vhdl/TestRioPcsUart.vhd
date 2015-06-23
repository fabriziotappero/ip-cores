-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- Description
-- This file contains a testbench for RioPcsUart.
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
-- TestRioPcsUart.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
use work.rio_common.all;


-------------------------------------------------------------------------------
-- Entity for TestRioPcsUart.
-------------------------------------------------------------------------------
entity TestRioPcsUart is
end entity;


-------------------------------------------------------------------------------
-- Architecture for TestUart.
-------------------------------------------------------------------------------
architecture TestRioPcsUartImpl of TestRioPcsUart is
  
  component RioFifo1 is
    generic(
      WIDTH : natural);
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      empty_o : out std_logic;
      read_i : in std_logic;
      data_o : out std_logic_vector(WIDTH-1 downto 0);

      full_o : out std_logic;
      write_i : in std_logic;
      data_i : in std_logic_vector(WIDTH-1 downto 0));
  end component;
  
  component RioSymbolConverter is
    port(
      clk : in std_logic;
      areset_n : in std_logic;

      portInitialized_o : out std_logic;
      outboundSymbolEmpty_i : in std_logic;
      outboundSymbolRead_o : out std_logic;
      outboundSymbol_i : in std_logic_vector(33 downto 0);
      inboundSymbolFull_i : in std_logic;
      inboundSymbolWrite_o : out std_logic;
      inboundSymbol_o : out std_logic_vector(33 downto 0);

      uartEmpty_i : in std_logic;
      uartRead_o : out std_logic;
      uartData_i : in std_logic_vector(7 downto 0);
      uartFull_i : in std_logic;
      uartWrite_o : out std_logic;
      uartData_o : out std_logic_vector(7 downto 0));
  end component;

  signal clk : std_logic;
  signal areset_n : std_logic;

  signal portInitialized : std_logic;

  signal outboundSymbolEmpty : std_logic;
  signal outboundSymbolRead : std_logic;
  signal outboundSymbolReadData : std_logic_vector(33 downto 0);
  signal outboundSymbolFull : std_logic;
  signal outboundSymbolWrite : std_logic;
  signal outboundSymbolWriteData : std_logic_vector(33 downto 0);

  signal inboundSymbolFull : std_logic;
  signal inboundSymbolWrite : std_logic;
  signal inboundSymbolWriteData : std_logic_vector(33 downto 0);

  signal uartInboundEmpty : std_logic;
  signal uartInboundRead : std_logic;
  signal uartInboundReadData : std_logic_vector(7 downto 0);
  signal uartInboundFull : std_logic;
  signal uartInboundWrite : std_logic;
  signal uartInboundWriteData : std_logic_vector(7 downto 0);

  signal uartOutboundFull : std_logic;
  signal uartOutboundWrite : std_logic;
  signal uartOutboundWriteData : std_logic_vector(7 downto 0);
  
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
  -- Serial protocol test driver.
  -----------------------------------------------------------------------------
  TestDriver: process

    ---------------------------------------------------------------------------
    -- Procedure to read a symbol.
    ---------------------------------------------------------------------------
    procedure ReadSymbol(
      constant symbolType : in std_logic_vector(1 downto 0);
      constant symbolContent : in std_logic_vector(31 downto 0) := x"00000000") is
    begin
      inboundSymbolFull <= '0';
      wait until inboundSymbolWrite = '1' and clk'event and clk = '1';
      inboundSymbolFull <= '1';

      assert symbolType = inboundSymbolWriteData(33 downto 32)
        report "Missmatching symbol type:expected=" &
        integer'image(to_integer(unsigned(symbolType))) &
        " got=" &
        integer'image(to_integer(unsigned(outboundSymbolWriteData(33 downto 32))))
        severity error;

      if (symbolType = SYMBOL_CONTROL) then
        assert symbolContent(31 downto 8) = inboundSymbolWriteData(31 downto 8)
          report "Missmatching symbol content:expected=" &
          integer'image(to_integer(unsigned(symbolContent(31 downto 8)))) &
          " got=" &
          integer'image(to_integer(unsigned(inboundSymbolWriteData(31 downto 8))))
          severity error;
      elsif (symbolType = SYMBOL_DATA) then
        assert symbolContent(31 downto 0) = inboundSymbolWriteData(31 downto 0)
          report "Missmatching symbol content:expected=" &
          integer'image(to_integer(unsigned(symbolContent(31 downto 0)))) &
          " got=" &
          integer'image(to_integer(unsigned(inboundSymbolWriteData(31 downto 0))))
          severity error;
      end if;
    end procedure;

    ---------------------------------------------------------------------------
    -- Procedure to write a symbol.
    ---------------------------------------------------------------------------
    procedure WriteSymbol(
      constant symbolType : in std_logic_vector(1 downto 0);
      constant symbolContent : in std_logic_vector(31 downto 0) := x"00000000") is
    begin
      wait until outboundSymbolFull = '0' and clk'event and clk = '1';
      outboundSymbolWrite <= '1';
      outboundSymbolWriteData <= symbolType & symbolContent;
      wait until clk'event and clk = '1';
      outboundSymbolWrite <= '0';
    end procedure;

    ---------------------------------------------------------------------------
    -- Procedure to read an octet.
    ---------------------------------------------------------------------------
    procedure ReadOctet(
      constant octet : in std_logic_vector(7 downto 0) := x"00") is
    begin
      uartOutboundFull <= '0';
      wait until uartOutboundWrite = '1' and clk'event and clk = '1';
      uartOutboundFull <= '1';

      assert uartOutboundWriteData = octet
        report "Missmatching octet content:expected=" &
        integer'image(to_integer(unsigned(octet))) &
        " got=" &
        integer'image(to_integer(unsigned(uartOutboundWriteData)))
        severity error;
    end procedure;

    ---------------------------------------------------------------------------
    -- Procedure to send a symbol.
    ---------------------------------------------------------------------------
    procedure WriteOctet(
      constant octet : in std_logic_vector(7 downto 0) := x"00") is
    begin
      wait until uartInboundFull = '0' and clk'event and clk = '1';
      uartInboundWrite <= '1';
      uartInboundWriteData <= octet;
      wait until clk'event and clk = '1';
      uartInboundWrite <= '0';
    end procedure;

    ---------------------------------------------------------------------------
    -- Process variables.
    ---------------------------------------------------------------------------

  begin
    ---------------------------------------------------------------------------
    -- Test case initialization.
    ---------------------------------------------------------------------------
    
    uartOutboundFull <= '1';
    uartInboundWrite <= '0';

    inboundSymbolFull <= '1';
    outboundSymbolWrite <= '0';

    -- Generate a startup reset pulse.
    areset_n <= '0';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    areset_n <= '1';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioPcsUart");
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioPcsUart-TC1");
    PrintS("Description: Check initial silence time.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC1-Step1");
    ---------------------------------------------------------------------------

    WriteSymbol(SYMBOL_IDLE);
    
    uartOutboundFull <= '0';
    for i in 0 to 4095 loop
      wait until clk'event and clk = '1';      
      assert uartOutboundWrite = '0' report "Sending during silence time."
        severity error;
    end loop;

    ReadOctet(x"7e");
    
    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioPcsUart-TC2");
    PrintS("Description: Check outbound symbol generation.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC2-Step1");
    ---------------------------------------------------------------------------
    
    WriteSymbol(SYMBOL_IDLE);
    ReadOctet(x"7e");
    WriteSymbol(SYMBOL_IDLE);
    ReadOctet(x"7e");
    WriteSymbol(SYMBOL_IDLE);
    ReadOctet(x"7e");

    ---------------------------------------------------------------------------
    PrintS("Step 2:");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC2-Step2");
    ---------------------------------------------------------------------------

    WriteSymbol(SYMBOL_CONTROL, x"123456" & "XXXXXXXX");
    ReadOctet(x"12");
    ReadOctet(x"34");
    ReadOctet(x"56");
    ReadOctet(x"7e");
    
    ---------------------------------------------------------------------------
    PrintS("Step 3:");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC2-Step3");
    ---------------------------------------------------------------------------

    WriteSymbol(SYMBOL_CONTROL, x"7d7d7d" & "XXXXXXXX");
    ReadOctet(x"7d");
    ReadOctet(x"5d");
    ReadOctet(x"7d");
    ReadOctet(x"5d");
    ReadOctet(x"7d");
    ReadOctet(x"5d");
    ReadOctet(x"7e");
    
    ---------------------------------------------------------------------------
    PrintS("Step 4:");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC2-Step4");
    ---------------------------------------------------------------------------

    WriteSymbol(SYMBOL_CONTROL, x"7e7e7e" & "XXXXXXXX");
    ReadOctet(x"7d");
    ReadOctet(x"5e");
    ReadOctet(x"7d");
    ReadOctet(x"5e");
    ReadOctet(x"7d");
    ReadOctet(x"5e");
    ReadOctet(x"7e");
    
    ---------------------------------------------------------------------------
    PrintS("Step 5:");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC2-Step5");
    ---------------------------------------------------------------------------

    WriteSymbol(SYMBOL_CONTROL, x"7d7f7e" & "XXXXXXXX");
    ReadOctet(x"7d");
    ReadOctet(x"5d");
    ReadOctet(x"7f");
    ReadOctet(x"7d");
    ReadOctet(x"5e");
    ReadOctet(x"7e");

    ---------------------------------------------------------------------------
    PrintS("Step 6:");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC2-Step6");
    ---------------------------------------------------------------------------

    WriteSymbol(SYMBOL_DATA, x"12345678");
    ReadOctet(x"12");
    ReadOctet(x"34");
    ReadOctet(x"56");
    ReadOctet(x"78");
    
    ---------------------------------------------------------------------------
    PrintS("Step 7:");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC2-Step7");
    ---------------------------------------------------------------------------

    WriteSymbol(SYMBOL_DATA, x"7d7d7d7d");
    ReadOctet(x"7d");
    ReadOctet(x"5d");
    ReadOctet(x"7d");
    ReadOctet(x"5d");
    ReadOctet(x"7d");
    ReadOctet(x"5d");
    ReadOctet(x"7d");
    ReadOctet(x"5d");

    ---------------------------------------------------------------------------
    PrintS("Step 8:");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC2-Step8");
    ---------------------------------------------------------------------------

    WriteSymbol(SYMBOL_DATA, x"7e7e7e7e");
    ReadOctet(x"7d");
    ReadOctet(x"5e");
    ReadOctet(x"7d");
    ReadOctet(x"5e");
    ReadOctet(x"7d");
    ReadOctet(x"5e");
    ReadOctet(x"7d");
    ReadOctet(x"5e");

    ---------------------------------------------------------------------------
    PrintS("Step 9:");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC2-Step9");
    ---------------------------------------------------------------------------

    WriteSymbol(SYMBOL_DATA, x"7d7f7e7f");
    ReadOctet(x"7d");
    ReadOctet(x"5d");
    ReadOctet(x"7f");
    ReadOctet(x"7d");
    ReadOctet(x"5e");
    ReadOctet(x"7f");

    ---------------------------------------------------------------------------
    PrintS("Step 10:");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC2-Step10");
    ---------------------------------------------------------------------------

    WriteSymbol(SYMBOL_IDLE);
    ReadOctet(x"7e");
    WriteSymbol(SYMBOL_CONTROL, x"123456" & "XXXXXXXX");
    ReadOctet(x"12");
    ReadOctet(x"34");
    ReadOctet(x"56");
    ReadOctet(x"7e");
    WriteSymbol(SYMBOL_DATA, x"789abcde");    
    ReadOctet(x"78");
    ReadOctet(x"9a");
    ReadOctet(x"bc");
    ReadOctet(x"de");
    WriteSymbol(SYMBOL_CONTROL, x"123456" & "XXXXXXXX");
    ReadOctet(x"12");
    ReadOctet(x"34");
    ReadOctet(x"56");
    ReadOctet(x"7e");
    WriteSymbol(SYMBOL_DATA, x"789abcde");    
    ReadOctet(x"78");
    ReadOctet(x"9a");
    ReadOctet(x"bc");
    ReadOctet(x"de");
    WriteSymbol(SYMBOL_DATA, x"789abcde");    
    ReadOctet(x"78");
    ReadOctet(x"9a");
    ReadOctet(x"bc");
    ReadOctet(x"de");

    ---------------------------------------------------------------------------
    PrintS("-----------------------------------------------------------------");
    PrintS("TG_RioPcsUart-TC3");
    PrintS("Description: Check inbound symbol generation.");
    PrintS("Requirement: XXXXX");
    PrintS("-----------------------------------------------------------------");
    PrintS("Step 1:");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC3-Step1");
    ---------------------------------------------------------------------------

    WriteOctet(x"7e");
    WriteOctet(x"7e");
    ReadSymbol(SYMBOL_IDLE);

    ---------------------------------------------------------------------------
    PrintS("Step :");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC3-Step");
    ---------------------------------------------------------------------------

    WriteOctet(x"12");
    WriteOctet(x"7e");
    ReadSymbol(SYMBOL_IDLE);
    
    ---------------------------------------------------------------------------
    PrintS("Step :");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC3-Step");
    ---------------------------------------------------------------------------

    WriteOctet(x"34");
    WriteOctet(x"56");
    WriteOctet(x"7e");
    ReadSymbol(SYMBOL_IDLE);
     
    ---------------------------------------------------------------------------
    PrintS("Step :");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC3-Step");
    ---------------------------------------------------------------------------

    WriteOctet(x"78");
    WriteOctet(x"9a");
    WriteOctet(x"bc");
    WriteOctet(x"7e");
    ReadSymbol(SYMBOL_CONTROL, x"789abc" & "XXXXXXXX");

    ---------------------------------------------------------------------------
    PrintS("Step :");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC3-Step");
    ---------------------------------------------------------------------------

    WriteOctet(x"7d");
    WriteOctet(x"5d");
    WriteOctet(x"7d");
    WriteOctet(x"5d");
    WriteOctet(x"7d");
    WriteOctet(x"5d");
    WriteOctet(x"7e");
    ReadSymbol(SYMBOL_CONTROL, x"7d7d7d" & "XXXXXXXX");
    
    ---------------------------------------------------------------------------
    PrintS("Step :");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC3-Step");
    ---------------------------------------------------------------------------

    WriteOctet(x"7d");
    WriteOctet(x"5e");
    WriteOctet(x"7d");
    WriteOctet(x"5e");
    WriteOctet(x"7d");
    WriteOctet(x"5e");
    WriteOctet(x"7e");
    ReadSymbol(SYMBOL_CONTROL, x"7e7e7e" & "XXXXXXXX");
    
    ---------------------------------------------------------------------------
    PrintS("Step :");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC3-Step");
    ---------------------------------------------------------------------------

    WriteOctet(x"f1");
    WriteOctet(x"11");
    WriteOctet(x"22");
    WriteOctet(x"33");
    ReadSymbol(SYMBOL_DATA, x"f1112233");

    ---------------------------------------------------------------------------
    PrintS("Step :");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC3-Step");
    ---------------------------------------------------------------------------

    WriteOctet(x"7e");
    ReadSymbol(SYMBOL_IDLE);
    
    ---------------------------------------------------------------------------
    PrintS("Step :");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC3-Step");
    ---------------------------------------------------------------------------

    WriteOctet(x"7d");
    WriteOctet(x"5d");
    WriteOctet(x"7d");
    WriteOctet(x"5d");
    WriteOctet(x"7d");
    WriteOctet(x"5d");
    WriteOctet(x"7d");
    WriteOctet(x"5d");
    ReadSymbol(SYMBOL_DATA, x"7d7d7d7d");
    
    ---------------------------------------------------------------------------
    PrintS("Step :");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC3-Step");
    ---------------------------------------------------------------------------

    WriteOctet(x"7d");
    WriteOctet(x"5e");
    WriteOctet(x"7d");
    WriteOctet(x"5e");
    WriteOctet(x"7d");
    WriteOctet(x"5e");
    WriteOctet(x"7d");
    WriteOctet(x"5e");
    ReadSymbol(SYMBOL_DATA, x"7e7e7e7e");
    
    ---------------------------------------------------------------------------
    PrintS("Step :");
    PrintS("Action: .");
    PrintS("Result: .");
    ---------------------------------------------------------------------------
    PrintR("TG_RioPcsUart-TC3-Step");
    ---------------------------------------------------------------------------

    WriteOctet(x"44");
    WriteOctet(x"55");
    WriteOctet(x"66");
    WriteOctet(x"77");
    ReadSymbol(SYMBOL_DATA, x"44556677");
    WriteOctet(x"88");
    WriteOctet(x"99");
    WriteOctet(x"aa");
    WriteOctet(x"bb");
    ReadSymbol(SYMBOL_DATA, x"8899aabb");
    
    ---------------------------------------------------------------------------
    -- Test completed.
    ---------------------------------------------------------------------------

    TestEnd;
  end process;


  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------
  
  OutboundSymbolFifo: RioFifo1
    generic map(WIDTH=>34)
    port map(
      clk=>clk, areset_n=>areset_n,
      empty_o=>outboundSymbolEmpty, read_i=>outboundSymbolRead, data_o=>outboundSymbolReadData,
      full_o=>outboundSymbolFull, write_i=>outboundSymbolWrite, data_i=>outboundSymbolWriteData);

  InboundOctetFifo: RioFifo1
    generic map(WIDTH=>8)
    port map(
      clk=>clk, areset_n=>areset_n,
      empty_o=>uartInboundEmpty, read_i=>uartInboundRead, data_o=>uartInboundReadData,
      full_o=>uartInboundFull, write_i=>uartInboundWrite, data_i=>uartInboundWriteData);

  TestSymbolConverter: RioSymbolConverter
    port map(
      clk=>clk, areset_n=>areset_n, 
      portInitialized_o=>portInitialized,
      outboundSymbolEmpty_i=>outboundSymbolEmpty,
      outboundSymbolRead_o=>outboundSymbolRead, outboundSymbol_i=>outboundSymbolReadData, 
      inboundSymbolFull_i=>inboundSymbolFull,
      inboundSymbolWrite_o=>inboundSymbolWrite, inboundSymbol_o=>inboundSymbolWriteData, 
      uartEmpty_i=>uartInboundEmpty, uartRead_o=>uartInboundRead, uartData_i=>uartInboundReadData, 
      uartFull_i=>uartOutboundFull, uartWrite_o=>uartOutboundWrite, uartData_o=>uartOutboundWriteData);
  
end architecture;
