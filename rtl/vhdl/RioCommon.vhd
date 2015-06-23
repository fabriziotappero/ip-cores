-------------------------------------------------------------------------------
-- 
-- RapidIO IP Library Core
-- 
-- This file is part of the RapidIO IP library project
-- http://www.opencores.org/cores/rio/
-- 
-- Description
-- Contains commonly used types, functions, procedures and entities used in
-- the RapidIO IP library project.
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
-- RioCommon library.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;


-------------------------------------------------------------------------------
-- RioCommon package description.
-------------------------------------------------------------------------------
package rio_common is
  -----------------------------------------------------------------------------
  -- Commonly used types.
  -----------------------------------------------------------------------------
  type Array1 is array (natural range <>) of
    std_logic;
  type Array2 is array (natural range <>) of
    std_logic_vector(1 downto 0);
  type Array3 is array (natural range <>) of
    std_logic_vector(2 downto 0);
  type Array4 is array (natural range <>) of
    std_logic_vector(3 downto 0);
  type Array5 is array (natural range <>) of
    std_logic_vector(4 downto 0);
  type Array8 is array (natural range <>) of
    std_logic_vector(7 downto 0);
  type Array9 is array (natural range <>) of
    std_logic_vector(8 downto 0);
  type Array10 is array (natural range <>) of
    std_logic_vector(9 downto 0);
  type Array16 is array (natural range <>) of
    std_logic_vector(15 downto 0);
  type Array32 is array (natural range <>) of
    std_logic_vector(31 downto 0);
  type Array34 is array (natural range <>) of
    std_logic_vector(33 downto 0);

  -----------------------------------------------------------------------------
  -- Commonly used constants.
  -----------------------------------------------------------------------------
  
  -- Symbol types between the serial and the PCS layer.
  constant SYMBOL_IDLE : std_logic_vector(1 downto 0) := "00";
  constant SYMBOL_CONTROL : std_logic_vector(1 downto 0) := "01";
  constant SYMBOL_ERROR : std_logic_vector(1 downto 0) := "10";
  constant SYMBOL_DATA : std_logic_vector(1 downto 0) := "11";
  
  -- STYPE0 constants.
  constant STYPE0_PACKET_ACCEPTED : std_logic_vector(2 downto 0) := "000";
  constant STYPE0_PACKET_RETRY : std_logic_vector(2 downto 0) := "001";
  constant STYPE0_PACKET_NOT_ACCEPTED : std_logic_vector(2 downto 0) := "010";
  constant STYPE0_RESERVED : std_logic_vector(2 downto 0) := "011";
  constant STYPE0_STATUS : std_logic_vector(2 downto 0) := "100";
  constant STYPE0_VC_STATUS : std_logic_vector(2 downto 0) := "101";
  constant STYPE0_LINK_RESPONSE : std_logic_vector(2 downto 0) := "110";
  constant STYPE0_IMPLEMENTATION_DEFINED : std_logic_vector(2 downto 0) := "111";

  -- STYPE1 constants.
  constant STYPE1_START_OF_PACKET : std_logic_vector(2 downto 0) := "000";
  constant STYPE1_STOMP : std_logic_vector(2 downto 0) := "001";
  constant STYPE1_END_OF_PACKET : std_logic_vector(2 downto 0) := "010";
  constant STYPE1_RESTART_FROM_RETRY : std_logic_vector(2 downto 0) := "011";
  constant STYPE1_LINK_REQUEST : std_logic_vector(2 downto 0) := "100";
  constant STYPE1_MULTICAST_EVENT : std_logic_vector(2 downto 0) := "101";
  constant STYPE1_RESERVED : std_logic_vector(2 downto 0) := "110";
  constant STYPE1_NOP : std_logic_vector(2 downto 0) := "111";

  -- FTYPE constants.
  constant FTYPE_REQUEST_CLASS : std_logic_vector(3 downto 0) := "0010";
  constant FTYPE_WRITE_CLASS : std_logic_vector(3 downto 0) := "0101";
  constant FTYPE_STREAMING_WRITE_CLASS : std_logic_vector(3 downto 0) := "0110";
  constant FTYPE_MAINTENANCE_CLASS : std_logic_vector(3 downto 0) := "1000";
  constant FTYPE_RESPONSE_CLASS : std_logic_vector(3 downto 0) := "1101";
  constant FTYPE_DOORBELL_CLASS : std_logic_vector(3 downto 0) := "1010";
  constant FTYPE_MESSAGE_CLASS : std_logic_vector(3 downto 0) := "1011";

  -- TTYPE Constants
  constant TTYPE_MAINTENANCE_READ_REQUEST : std_logic_vector(3 downto 0) := "0000";
  constant TTYPE_MAINTENANCE_WRITE_REQUEST : std_logic_vector(3 downto 0) := "0001";
  constant TTYPE_MAINTENANCE_READ_RESPONSE : std_logic_vector(3 downto 0) := "0010";
  constant TTYPE_MAINTENANCE_WRITE_RESPONSE : std_logic_vector(3 downto 0) := "0011";
  constant TTYPE_NREAD_TRANSACTION : std_logic_vector(3 downto 0) := "0100";
  constant TTYPE_NWRITE_TRANSACTION : std_logic_vector(3 downto 0) := "0100";

  constant LINK_REQUEST_CMD_RESET_DEVICE : std_logic_vector(2 downto 0) := "011";
  constant LINK_REQUEST_CMD_INPUT_STATUS : std_logic_vector(2 downto 0) := "100";

  constant PACKET_NOT_ACCEPTED_CAUSE_UNEXPECTED_ACKID : std_logic_vector(4 downto 0) := "00001";
  constant PACKET_NOT_ACCEPTED_CAUSE_CONTROL_CRC : std_logic_vector(4 downto 0) := "00010";
  constant PACKET_NOT_ACCEPTED_CAUSE_NON_MAINTENANCE_STOPPED : std_logic_vector(4 downto 0) := "00011";
  constant PACKET_NOT_ACCEPTED_CAUSE_PACKET_CRC : std_logic_vector(4 downto 0) := "00100";
  constant PACKET_NOT_ACCEPTED_CAUSE_INVALID_CHARACTER : std_logic_vector(4 downto 0) := "00101";
  constant PACKET_NOT_ACCEPTED_CAUSE_NO_RESOURCES : std_logic_vector(4 downto 0) := "00110";
  constant PACKET_NOT_ACCEPTED_CAUSE_LOSS_DESCRAMBLER : std_logic_vector(4 downto 0) := "00111";
  constant PACKET_NOT_ACCEPTED_CAUSE_GENERAL_ERROR : std_logic_vector(4 downto 0) := "11111";
  
  -----------------------------------------------------------------------------
  -- Types used in simulations.
  -----------------------------------------------------------------------------
  type ByteArray is array (natural range <>) of
    std_logic_vector(7 downto 0);
  type HalfwordArray is array (natural range <>) of
    std_logic_vector(15 downto 0);
  type WordArray is array (natural range <>) of
    std_logic_vector(31 downto 0);
  type DoublewordArray is array (natural range <>) of
    std_logic_vector(63 downto 0);

  -- Type defining a RapidIO frame.
  type RioFrame is record
    length : natural range 0 to 69;
    payload : WordArray(0 to 68);
  end record;
  type RioFrameArray is array (natural range <>) of RioFrame;

  -- Type defining a RapidIO payload.
  type RioPayload is record
    length : natural range 0 to 133;
    data : HalfwordArray(0 to 132);
  end record;

  -----------------------------------------------------------------------------
  -- Crc5 calculation function.
  -- ITU, polynom=0x15.
  -----------------------------------------------------------------------------
  function Crc5(constant data : in std_logic_vector(18 downto 0);
                constant crc : in std_logic_vector(4 downto 0))
    return std_logic_vector;
  
  ---------------------------------------------------------------------------
  -- Create a RapidIO physical layer control symbol.
  ---------------------------------------------------------------------------
  function RioControlSymbolCreate(
    constant stype0 : in std_logic_vector(2 downto 0);
    constant parameter0 : in std_logic_vector(4 downto 0);
    constant parameter1 : in std_logic_vector(4 downto 0);
    constant stype1 : in std_logic_vector(2 downto 0);
    constant cmd : in std_logic_vector(2 downto 0))
    return std_logic_vector;

  -----------------------------------------------------------------------------
  -- Crc16 calculation function.
  -- CITT, polynom=0x1021.
  -----------------------------------------------------------------------------
  function Crc16(constant data : in std_logic_vector(15 downto 0);
                 constant crc : in std_logic_vector(15 downto 0))
    return std_logic_vector;
  
  ---------------------------------------------------------------------------
  -- Create a randomly initialized data array.
  ---------------------------------------------------------------------------
  procedure CreateRandomPayload(
    variable payload : out HalfwordArray(0 to 132);
    variable seed1 : inout positive;
    variable seed2 : inout positive);
  procedure CreateRandomPayload(
    variable payload : out DoublewordArray(0 to 31);
    variable seed1 : inout positive;
    variable seed2 : inout positive);

  ---------------------------------------------------------------------------
  -- Create a generic RapidIO frame.
  ---------------------------------------------------------------------------
  function RioFrameCreate(
    constant ackId : in std_logic_vector(4 downto 0);
    constant vc : in std_logic;
    constant crf : in std_logic;
    constant prio : in std_logic_vector(1 downto 0);
    constant tt : in std_logic_vector(1 downto 0);
    constant ftype : in std_logic_vector(3 downto 0);
    constant sourceId : in std_logic_vector(15 downto 0);
    constant destId : in std_logic_vector(15 downto 0);
    constant payload : in RioPayload)
    return RioFrame;
  
  ---------------------------------------------------------------------------
  -- Create a NWRITE RapidIO frame.
  ---------------------------------------------------------------------------
  function RioNwrite(
    constant wrsize : in std_logic_vector(3 downto 0);
    constant tid : in std_logic_vector(7 downto 0);
    constant address : in std_logic_vector(28 downto 0);
    constant wdptr : in std_logic;
    constant xamsbs : in std_logic_vector(1 downto 0);
    constant dataLength : in natural range 1 to 32;
    constant data : in DoublewordArray(0 to 31))
    return RioPayload;
  
  ---------------------------------------------------------------------------
  -- Create a NREAD RapidIO frame.
  ---------------------------------------------------------------------------
  function RioNread(
    constant rdsize : in std_logic_vector(3 downto 0);
    constant tid : in std_logic_vector(7 downto 0);
    constant address : in std_logic_vector(28 downto 0);
    constant wdptr : in std_logic;
    constant xamsbs : in std_logic_vector(1 downto 0))
    return RioPayload;
  
  ---------------------------------------------------------------------------
  -- Create a RESPONSE RapidIO frame.
  ---------------------------------------------------------------------------
  function RioResponse(
    constant status : in std_logic_vector(3 downto 0);
    constant tid : in std_logic_vector(7 downto 0);
    constant dataLength : in natural range 0 to 32;
    constant data : in DoublewordArray(0 to 31))
    return RioPayload;
  
  ---------------------------------------------------------------------------
  -- Create a Maintenance RapidIO frame.
  ---------------------------------------------------------------------------
  function RioMaintenance(
    constant transaction : in std_logic_vector(3 downto 0);
    constant size : in std_logic_vector(3 downto 0);
    constant tid : in std_logic_vector(7 downto 0);
    constant hopCount : in std_logic_vector(7 downto 0);
    constant configOffset : in std_logic_vector(20 downto 0);
    constant wdptr : in std_logic;
    constant dataLength : in natural range 0 to 8;
    constant data : in DoublewordArray(0 to 7))
    return RioPayload;
  
  -----------------------------------------------------------------------------
  -- Function to convert a std_logic_vector to a string.
  -----------------------------------------------------------------------------
  function byteToString(constant byte : std_logic_vector(7 downto 0))
    return string;

  ---------------------------------------------------------------------------
  -- Procedure to print to report file and output
  ---------------------------------------------------------------------------
  procedure PrintR( constant str : string );

  ---------------------------------------------------------------------------
  -- Procedure to print to spec file
  ---------------------------------------------------------------------------
  procedure PrintS( constant str : string );

  ---------------------------------------------------------------------------
  -- Procedure to Assert Expression
  ---------------------------------------------------------------------------
  procedure AssertE( constant exp: boolean; constant str : string );

  ---------------------------------------------------------------------------
  -- Procedure to Print Error
  ---------------------------------------------------------------------------
  procedure PrintE( constant str : string );

  ---------------------------------------------------------------------------
  -- Procedure to end a test.
  ---------------------------------------------------------------------------
  procedure TestEnd;

end package;

-------------------------------------------------------------------------------
-- RioCommon package body description.
-------------------------------------------------------------------------------
package body rio_common is
  -----------------------------------------------------------------------------
  -- Crc5 calculation function.
  -- ITU, polynom=0x15.
  -----------------------------------------------------------------------------
  function Crc5(constant data : in std_logic_vector(18 downto 0);
                constant crc : in std_logic_vector(4 downto 0))
    return std_logic_vector is
    type crcTableType is array (0 to 31) of std_logic_vector(7 downto 0);
    constant crcTable : crcTableType := (
      x"00", x"15", x"1f", x"0a", x"0b", x"1e", x"14", x"01",
      x"16", x"03", x"09", x"1c", x"1d", x"08", x"02", x"17",
      x"19", x"0c", x"06", x"13", x"12", x"07", x"0d", x"18",
      x"0f", x"1a", x"10", x"05", x"04", x"11", x"1b", x"0e" );
    variable index : natural range 0 to 31;
    variable result : std_logic_vector(4 downto 0);
  begin
    result := crc;
    index := to_integer(unsigned(data(18 downto 14) xor result));
    result := crcTable(index)(4 downto 0);
    index := to_integer(unsigned(data(13 downto 9) xor result));
    result := crcTable(index)(4 downto 0);
    index := to_integer(unsigned(data(8 downto 4) xor result));
    result := crcTable(index)(4 downto 0);
    index := to_integer(unsigned((data(3 downto 0) & '0') xor result));
    return crcTable(index)(4 downto 0);
  end Crc5;

  ---------------------------------------------------------------------------
  -- Create a RapidIO physical layer control symbol.
  ---------------------------------------------------------------------------
  function RioControlSymbolCreate(
    constant stype0 : in std_logic_vector(2 downto 0);
    constant parameter0 : in std_logic_vector(4 downto 0);
    constant parameter1 : in std_logic_vector(4 downto 0);
    constant stype1 : in std_logic_vector(2 downto 0);
    constant cmd : in std_logic_vector(2 downto 0))
    return std_logic_vector is
    variable returnValue : std_logic_vector(31 downto 0);
    variable symbolData : std_logic_vector(18 downto 0);
  begin
    symbolData(18 downto 16) := stype0;
    symbolData(15 downto 11) := parameter0;
    symbolData(10 downto 6) := parameter1;
    symbolData(5 downto 3) := stype1;
    symbolData(2 downto 0) := cmd;

    returnValue(31 downto 13) := symbolData;
    returnValue(12 downto 8) := Crc5(symbolData, "11111");
    returnValue(7 downto 0) := x"00";

    return returnValue;
  end function;

  -----------------------------------------------------------------------------
  -- Crc16 calculation function.
  -- CITT, polynom=0x1021.
  -----------------------------------------------------------------------------
  function Crc16(constant data : in std_logic_vector(15 downto 0);
                 constant crc : in std_logic_vector(15 downto 0))
    return std_logic_vector is
    type crcTableType is array (0 to 255) of std_logic_vector(15 downto 0);
    constant crcTable : crcTableType := (
      x"0000", x"1021", x"2042", x"3063", x"4084", x"50a5", x"60c6", x"70e7",
      x"8108", x"9129", x"a14a", x"b16b", x"c18c", x"d1ad", x"e1ce", x"f1ef",
      x"1231", x"0210", x"3273", x"2252", x"52b5", x"4294", x"72f7", x"62d6",
      x"9339", x"8318", x"b37b", x"a35a", x"d3bd", x"c39c", x"f3ff", x"e3de",
      x"2462", x"3443", x"0420", x"1401", x"64e6", x"74c7", x"44a4", x"5485",
      x"a56a", x"b54b", x"8528", x"9509", x"e5ee", x"f5cf", x"c5ac", x"d58d",
      x"3653", x"2672", x"1611", x"0630", x"76d7", x"66f6", x"5695", x"46b4",
      x"b75b", x"a77a", x"9719", x"8738", x"f7df", x"e7fe", x"d79d", x"c7bc",
      x"48c4", x"58e5", x"6886", x"78a7", x"0840", x"1861", x"2802", x"3823",
      x"c9cc", x"d9ed", x"e98e", x"f9af", x"8948", x"9969", x"a90a", x"b92b",
      x"5af5", x"4ad4", x"7ab7", x"6a96", x"1a71", x"0a50", x"3a33", x"2a12",
      x"dbfd", x"cbdc", x"fbbf", x"eb9e", x"9b79", x"8b58", x"bb3b", x"ab1a",
      x"6ca6", x"7c87", x"4ce4", x"5cc5", x"2c22", x"3c03", x"0c60", x"1c41",
      x"edae", x"fd8f", x"cdec", x"ddcd", x"ad2a", x"bd0b", x"8d68", x"9d49",
      x"7e97", x"6eb6", x"5ed5", x"4ef4", x"3e13", x"2e32", x"1e51", x"0e70",
      x"ff9f", x"efbe", x"dfdd", x"cffc", x"bf1b", x"af3a", x"9f59", x"8f78",
      x"9188", x"81a9", x"b1ca", x"a1eb", x"d10c", x"c12d", x"f14e", x"e16f",
      x"1080", x"00a1", x"30c2", x"20e3", x"5004", x"4025", x"7046", x"6067",
      x"83b9", x"9398", x"a3fb", x"b3da", x"c33d", x"d31c", x"e37f", x"f35e",
      x"02b1", x"1290", x"22f3", x"32d2", x"4235", x"5214", x"6277", x"7256",
      x"b5ea", x"a5cb", x"95a8", x"8589", x"f56e", x"e54f", x"d52c", x"c50d",
      x"34e2", x"24c3", x"14a0", x"0481", x"7466", x"6447", x"5424", x"4405",
      x"a7db", x"b7fa", x"8799", x"97b8", x"e75f", x"f77e", x"c71d", x"d73c",
      x"26d3", x"36f2", x"0691", x"16b0", x"6657", x"7676", x"4615", x"5634",
      x"d94c", x"c96d", x"f90e", x"e92f", x"99c8", x"89e9", x"b98a", x"a9ab",
      x"5844", x"4865", x"7806", x"6827", x"18c0", x"08e1", x"3882", x"28a3",
      x"cb7d", x"db5c", x"eb3f", x"fb1e", x"8bf9", x"9bd8", x"abbb", x"bb9a",
      x"4a75", x"5a54", x"6a37", x"7a16", x"0af1", x"1ad0", x"2ab3", x"3a92",
      x"fd2e", x"ed0f", x"dd6c", x"cd4d", x"bdaa", x"ad8b", x"9de8", x"8dc9",
      x"7c26", x"6c07", x"5c64", x"4c45", x"3ca2", x"2c83", x"1ce0", x"0cc1",
      x"ef1f", x"ff3e", x"cf5d", x"df7c", x"af9b", x"bfba", x"8fd9", x"9ff8",
      x"6e17", x"7e36", x"4e55", x"5e74", x"2e93", x"3eb2", x"0ed1", x"1ef0" );
    variable index : natural range 0 to 255;
    variable result : std_logic_vector(15 downto 0);
  begin
    result := crc;
    index := to_integer(unsigned(data(15 downto 8) xor result(15 downto 8)));
    result := crcTable(index) xor (result(7 downto 0) & x"00");
    index := to_integer(unsigned(data(7 downto 0) xor result(15 downto 8)));
    result := crcTable(index) xor (result(7 downto 0) & x"00");
    return result;
  end Crc16;
  
  ---------------------------------------------------------------------------
  -- Create a randomly initialized data array.
  ---------------------------------------------------------------------------
  procedure CreateRandomPayload(
    variable payload : out HalfwordArray(0 to 132);
    variable seed1 : inout positive;
    variable seed2 : inout positive) is
    variable rand: real;
    variable int_rand: integer;
    variable stim: std_logic_vector(7 downto 0);
  begin
    for i in payload'range loop
      uniform(seed1, seed2, rand);
      int_rand := integer(trunc(rand*256.0));
      payload(i)(7 downto 0) := std_logic_vector(to_unsigned(int_rand, 8));
      uniform(seed1, seed2, rand);
      int_rand := integer(trunc(rand*256.0));
      payload(i)(15 downto 8) := std_logic_vector(to_unsigned(int_rand, 8));
    end loop;
  end procedure;

  procedure CreateRandomPayload(
    variable payload : out DoublewordArray(0 to 31);
    variable seed1 : inout positive;
    variable seed2 : inout positive) is
    variable rand: real;
    variable int_rand: integer;
    variable stim: std_logic_vector(7 downto 0);
  begin
    for i in payload'range loop
      uniform(seed1, seed2, rand);
      int_rand := integer(trunc(rand*256.0));
      payload(i)(7 downto 0) := std_logic_vector(to_unsigned(int_rand, 8));
      uniform(seed1, seed2, rand);
      int_rand := integer(trunc(rand*256.0));
      payload(i)(15 downto 8) := std_logic_vector(to_unsigned(int_rand, 8));
      uniform(seed1, seed2, rand);
      int_rand := integer(trunc(rand*256.0));
      payload(i)(23 downto 16) := std_logic_vector(to_unsigned(int_rand, 8));
      uniform(seed1, seed2, rand);
      int_rand := integer(trunc(rand*256.0));
      payload(i)(31 downto 24) := std_logic_vector(to_unsigned(int_rand, 8));
      uniform(seed1, seed2, rand);
      int_rand := integer(trunc(rand*256.0));
      payload(i)(39 downto 32) := std_logic_vector(to_unsigned(int_rand, 8));
      uniform(seed1, seed2, rand);
      int_rand := integer(trunc(rand*256.0));
      payload(i)(47 downto 40) := std_logic_vector(to_unsigned(int_rand, 8));
      uniform(seed1, seed2, rand);
      int_rand := integer(trunc(rand*256.0));
      payload(i)(55 downto 48) := std_logic_vector(to_unsigned(int_rand, 8));
      uniform(seed1, seed2, rand);
      int_rand := integer(trunc(rand*256.0));
      payload(i)(63 downto 56) := std_logic_vector(to_unsigned(int_rand, 8));
    end loop;
  end procedure;
  ---------------------------------------------------------------------------
  -- Create a generic RapidIO frame.
  ---------------------------------------------------------------------------
  function RioFrameCreate(
    constant ackId : in std_logic_vector(4 downto 0);
    constant vc : in std_logic;
    constant crf : in std_logic;
    constant prio : in std_logic_vector(1 downto 0);
    constant tt : in std_logic_vector(1 downto 0);
    constant ftype : in std_logic_vector(3 downto 0);
    constant sourceId : in std_logic_vector(15 downto 0);
    constant destId : in std_logic_vector(15 downto 0);
    constant payload : in RioPayload) return RioFrame is
    variable frame : RioFrame;
    variable result : HalfwordArray(0 to 137);
    variable crc : std_logic_vector(15 downto 0) := x"ffff";
  begin
    -- Add the header and addresses.
    result(0) := ackId & "0" & vc & crf & prio & tt & ftype;
    result(1) := destId;
    result(2) := sourceId;

    -- Update the calculated CRC with the header contents.
    crc := Crc16("00000" & result(0)(10 downto 0), crc);
    crc := Crc16(result(1), crc);
    crc := Crc16(result(2), crc);

    -- Check if a single CRC should be added or two.
    if (payload.length <= 37) then
      -- Single CRC.
      for i in 0 to payload.length-1 loop
        result(i+3) := payload.data(i);
        crc := Crc16(payload.data(i), crc);
      end loop;
      result(payload.length+3) := crc;

      -- Check if paddning is needed to make the payload even 32-bit.
      if ((payload.length mod 2) = 1) then
        result(payload.length+4) := x"0000";
        frame.length := (payload.length+5) / 2;
      else
        frame.length := (payload.length+4) / 2;
      end if;      
    else
      -- Double CRC.
      for i in 0 to 36 loop
        result(i+3) := payload.data(i);
        crc := Crc16(payload.data(i), crc);
      end loop;

      -- Add in-the-middle crc.
      result(40) := crc;
      crc := Crc16(crc, crc);
      
      for i in 37 to payload.length-1 loop
        result(i+4) := payload.data(i);
        crc := Crc16(payload.data(i), crc);
      end loop;
      result(payload.length+4) := crc;

      -- Check if paddning is needed to make the payload even 32-bit.
      if ((payload.length mod 2) = 0) then
        result(payload.length+5) := x"0000";
        frame.length := (payload.length+6) / 2;
      else
        frame.length := (payload.length+5) / 2;
      end if;      
    end if;
    
    -- Update the result length.
    for i in 0 to frame.length-1 loop
      frame.payload(i) := result(2*i) & result(2*i+1);
    end loop;

    return frame;
  end function;

  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------
  function RioNwrite(
    constant wrsize : in std_logic_vector(3 downto 0);
    constant tid : in std_logic_vector(7 downto 0);
    constant address : in std_logic_vector(28 downto 0);
    constant wdptr : in std_logic;
    constant xamsbs : in std_logic_vector(1 downto 0);
    constant dataLength : in natural range 1 to 32;
    constant data : in DoublewordArray(0 to 31))
    return RioPayload is
    variable payload : RioPayload;
  begin
    payload.data(0)(15 downto 12) := "0100";
    payload.data(0)(11 downto 8) := wrsize;
    payload.data(0)(7 downto 0) := tid;

    payload.data(1) := address(28 downto 13);
    
    payload.data(2)(15 downto 3) := address(12 downto 0);
    payload.data(2)(2) := wdptr;
    payload.data(2)(1 downto 0) := xamsbs;

    for i in 0 to dataLength-1 loop
      payload.data(3+4*i) := data(i)(63 downto 48);
      payload.data(4+4*i) := data(i)(47 downto 32);
      payload.data(5+4*i) := data(i)(31 downto 16);
      payload.data(6+4*i) := data(i)(15 downto 0);
    end loop;

    payload.length := 3 + 4*dataLength;
    
    return payload;
  end function;
  
  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------
  function RioNread(
    constant rdsize : in std_logic_vector(3 downto 0);
    constant tid : in std_logic_vector(7 downto 0);
    constant address : in std_logic_vector(28 downto 0);
    constant wdptr : in std_logic;
    constant xamsbs : in std_logic_vector(1 downto 0))
    return RioPayload is
    variable payload : RioPayload;
  begin
    payload.data(0)(15 downto 12) := "0100";
    payload.data(0)(11 downto 8) := rdsize;
    payload.data(0)(7 downto 0) := tid;

    payload.data(1) := address(28 downto 13);
    
    payload.data(2)(15 downto 3) := address(12 downto 0);
    payload.data(2)(2) := wdptr;
    payload.data(2)(1 downto 0) := xamsbs;

    payload.length := 3;

    return payload;
  end function;
  
  ---------------------------------------------------------------------------
  -- Create a RESPONSE RapidIO frame.
  ---------------------------------------------------------------------------
  function RioResponse(
    constant status : in std_logic_vector(3 downto 0);
    constant tid : in std_logic_vector(7 downto 0);
    constant dataLength : in natural range 0 to 32;
    constant data : in DoublewordArray(0 to 31))
    return RioPayload is
    variable payload : RioPayload;
  begin
    payload.data(0)(11 downto 8) := status;
    payload.data(0)(7 downto 0) := tid;

    if (dataLength = 0) then
      payload.data(0)(15 downto 12) := "0000";
      payload.length := 1;
    else
      payload.data(0)(15 downto 12) := "1000";
      
      for i in 0 to dataLength-1 loop
        payload.data(1+4*i) := data(i)(63 downto 48);
        payload.data(2+4*i) := data(i)(47 downto 32);
        payload.data(3+4*i) := data(i)(31 downto 16);
        payload.data(4+4*i) := data(i)(15 downto 0);
      end loop;

      payload.length := 1 + 4*dataLength;
    end if;

    return payload;
  end function;
  
  ---------------------------------------------------------------------------
  -- Create a Maintenance RapidIO frame.
  ---------------------------------------------------------------------------
  function RioMaintenance(
    constant transaction : in std_logic_vector(3 downto 0);
    constant size : in std_logic_vector(3 downto 0);
    constant tid : in std_logic_vector(7 downto 0);
    constant hopCount : in std_logic_vector(7 downto 0);
    constant configOffset : in std_logic_vector(20 downto 0);
    constant wdptr : in std_logic;
    constant dataLength : in natural range 0 to 8;
    constant data : in DoublewordArray(0 to 7))
    return RioPayload is
    variable payload : RioPayload;
  begin
    payload.data(0)(15 downto 12) := transaction;
    payload.data(0)(11 downto 8) := size;
    payload.data(0)(7 downto 0) := tid;

    payload.data(1)(15 downto 8) := hopCount;
    payload.data(1)(7 downto 0) := configOffset(20 downto 13);
    
    payload.data(2)(15 downto 3) := configOffset(12 downto 0);
    payload.data(2)(2) := wdptr;
    payload.data(2)(1 downto 0) := "00";

    if (dataLength = 0) then
      payload.length := 3;
    else
      for i in 0 to dataLength-1 loop
        payload.data(3+4*i) := data(i)(63 downto 48);
        payload.data(4+4*i) := data(i)(47 downto 32);
        payload.data(5+4*i) := data(i)(31 downto 16);
        payload.data(6+4*i) := data(i)(15 downto 0);
      end loop;

      payload.length := 3 + 4*dataLength;
    end if;

    return payload;
  end function;
  
  -----------------------------------------------------------------------------
  -- Function to convert a std_logic_vector to a string.
  -----------------------------------------------------------------------------
  function byteToString(constant byte : std_logic_vector(7 downto 0))
    return string is
    constant table : string(1 to 16) := "0123456789abcdef";
    variable returnValue : string(1 to 2);
  begin
    returnValue(1) := table(to_integer(unsigned(byte(7 downto 4))) + 1);
    returnValue(2) := table(to_integer(unsigned(byte(3 downto 0))) + 1);
    return returnValue;
  end function;
  
  ---------------------------------------------------------------------------
  -- Procedure to print test report
  ---------------------------------------------------------------------------
  procedure PrintR( constant str : string ) is
    file reportFile  : text;
    variable reportLine, outputLine : line;
    variable fStatus: FILE_OPEN_STATUS;
  begin
    --Write report note to wave/transcript window
    report str severity NOTE;
  end PrintR;

  ---------------------------------------------------------------------------
  -- Procedure to print test spec
  ---------------------------------------------------------------------------
  procedure PrintS( constant str : string ) is
    file specFile  : text;
    variable specLine, outputLine : line;
    variable fStatus: FILE_OPEN_STATUS;
  begin
    --Write to spec file
    file_open(fStatus, specFile, "testspec.txt", append_mode);
    write(specLine, string'(str));
    writeline (specFile, specLine);
    file_close(specFile);
  end PrintS;

  ---------------------------------------------------------------------------
  -- Procedure to Assert Expression
  ---------------------------------------------------------------------------
  procedure AssertE( constant exp: boolean; constant str : string ) is
    file reportFile  : text;
    variable reportLine, outputLine : line;
    variable fStatus: FILE_OPEN_STATUS;
  begin
    if (not exp) then
      --Write to STD_OUTPUT
      report(str) severity error;
    else
      PrintR("Status: Passed");
      PrintS("Status: Passed");
    end if;
  end AssertE;

  ---------------------------------------------------------------------------
  -- Procedure to Print Error
  ---------------------------------------------------------------------------
  procedure PrintE( constant str : string ) is
    file reportFile  : text;
    variable reportLine, outputLine : line;
    variable fStatus: FILE_OPEN_STATUS;
  begin
    --Write to STD_OUTPUT
    report str severity error;
  end PrintE;

  ---------------------------------------------------------------------------
  -- Procedure to end a test.
  ---------------------------------------------------------------------------
  procedure TestEnd is
  begin
    assert false report "Test complete." severity failure;
    wait;
  end TestEnd;
  
end rio_common;



-------------------------------------------------------------------------------
-- Crc16CITT
-- A CRC-16 calculator following the implementation proposed in the 2.2
-- standard.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


-------------------------------------------------------------------------------
-- Entity for Crc16CITT.
-------------------------------------------------------------------------------
entity Crc16CITT is
  port(
    d_i : in  std_logic_vector(15 downto 0);
    crc_i : in std_logic_vector(15 downto 0);
    crc_o : out std_logic_vector(15 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for Crc16CITT.
-------------------------------------------------------------------------------
architecture Crc16Impl of Crc16CITT is
  signal d : std_logic_vector(0 to 15);
  signal c : std_logic_vector(0 to 15);
  signal e : std_logic_vector(0 to 15);
  signal cc : std_logic_vector(0 to 15);
begin

  -- Reverse the bit vector indexes to make them the same as in the standard.
  d(15) <= d_i(0); d(14) <= d_i(1); d(13) <= d_i(2); d(12) <= d_i(3);
  d(11) <= d_i(4); d(10) <= d_i(5); d(9) <= d_i(6); d(8) <= d_i(7);
  d(7) <= d_i(8); d(6) <= d_i(9); d(5) <= d_i(10); d(4) <= d_i(11);
  d(3) <= d_i(12); d(2) <= d_i(13); d(1) <= d_i(14); d(0) <= d_i(15);
  
  -- Reverse the bit vector indexes to make them the same as in the standard.
  c(15) <= crc_i(0); c(14) <= crc_i(1); c(13) <= crc_i(2); c(12) <= crc_i(3);
  c(11) <= crc_i(4); c(10) <= crc_i(5); c(9) <= crc_i(6); c(8) <= crc_i(7);
  c(7) <= crc_i(8); c(6) <= crc_i(9); c(5) <= crc_i(10); c(4) <= crc_i(11);
  c(3) <= crc_i(12); c(2) <= crc_i(13); c(1) <= crc_i(14); c(0) <= crc_i(15);
  
  -- Calculate the resulting crc.
  e <= c xor d;
  cc(0) <= e(4) xor e(5) xor e(8) xor e(12);
  cc(1) <= e(5) xor e(6) xor e(9) xor e(13);
  cc(2) <= e(6) xor e(7) xor e(10) xor e(14);
  cc(3) <= e(0) xor e(7) xor e(8) xor e(11) xor e(15);
  cc(4) <= e(0) xor e(1) xor e(4) xor e(5) xor e(9);
  cc(5) <= e(1) xor e(2) xor e(5) xor e(6) xor e(10);
  cc(6) <= e(0) xor e(2) xor e(3) xor e(6) xor e(7) xor e(11);
  cc(7) <= e(0) xor e(1) xor e(3) xor e(4) xor e(7) xor e(8) xor e(12);
  cc(8) <= e(0) xor e(1) xor e(2) xor e(4) xor e(5) xor e(8) xor e(9) xor e(13);
  cc(9) <= e(1) xor e(2) xor e(3) xor e(5) xor e(6) xor e(9) xor e(10) xor e(14);
  cc(10) <= e(2) xor e(3) xor e(4) xor e(6) xor e(7) xor e(10) xor e(11) xor e(15);
  cc(11) <= e(0) xor e(3) xor e(7) xor e(11);
  cc(12) <= e(0) xor e(1) xor e(4) xor e(8) xor e(12);
  cc(13) <= e(1) xor e(2) xor e(5) xor e(9) xor e(13);
  cc(14) <= e(2) xor e(3) xor e(6) xor e(10) xor e(14);
  cc(15) <= e(3) xor e(4) xor e(7) xor e(11) xor e(15);

  -- Reverse the bit vector indexes to make them the same as in the standard.
  crc_o(15) <= cc(0); crc_o(14) <= cc(1); crc_o(13) <= cc(2); crc_o(12) <= cc(3);
  crc_o(11) <= cc(4); crc_o(10) <= cc(5); crc_o(9) <= cc(6); crc_o(8) <= cc(7);
  crc_o(7) <= cc(8); crc_o(6) <= cc(9); crc_o(5) <= cc(10); crc_o(4) <= cc(11);
  crc_o(3) <= cc(12); crc_o(2) <= cc(13); crc_o(1) <= cc(14); crc_o(0) <= cc(15);

end architecture;



-------------------------------------------------------------------------------
-- MemoryDualPort
-- Generic synchronous memory with one read/write port and one read port.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


-------------------------------------------------------------------------------
-- Entity for MemoryDualPort.
-------------------------------------------------------------------------------
entity MemoryDualPort is
  generic(
    ADDRESS_WIDTH : natural := 1;
    DATA_WIDTH : natural := 1);
  port(
    clkA_i : in std_logic;
    enableA_i : in std_logic;
    writeEnableA_i : in std_logic;
    addressA_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    dataA_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
    dataA_o : out std_logic_vector(DATA_WIDTH-1 downto 0);

    clkB_i : in std_logic;
    enableB_i : in std_logic;
    addressB_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    dataB_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for MemoryDualPort.
-------------------------------------------------------------------------------
architecture MemoryDualPortImpl of MemoryDualPort is
  type MemoryType is array (natural range <>) of
    std_logic_vector(DATA_WIDTH-1 downto 0);
  
  signal memory : MemoryType(0 to (2**ADDRESS_WIDTH)-1);
  
begin
  process(clkA_i)
  begin
    if (clkA_i'event and clkA_i = '1') then
      if (enableA_i = '1') then
        if (writeEnableA_i = '1') then
          memory(to_integer(unsigned(addressA_i))) <= dataA_i;
        end if;

        dataA_o <= memory(to_integer(unsigned(addressA_i)));
      end if;
    end if;
  end process;

  process(clkB_i)
  begin
    if (clkB_i'event and clkB_i = '1') then
      if (enableB_i = '1') then
        dataB_o <= memory(to_integer(unsigned(addressB_i)));
      end if;
    end if;
  end process;
  
end architecture;



-------------------------------------------------------------------------------
-- MemorySimpleDualPort
-- Generic synchronous memory with one write port and one read port.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


-------------------------------------------------------------------------------
-- Entity for MemorySimpleDualPort.
-------------------------------------------------------------------------------
entity MemorySimpleDualPort is
  generic(
    ADDRESS_WIDTH : natural := 1;
    DATA_WIDTH : natural := 1);
  port(
    clkA_i : in std_logic;
    enableA_i : in std_logic;
    addressA_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    dataA_i : in std_logic_vector(DATA_WIDTH-1 downto 0);

    clkB_i : in std_logic;
    enableB_i : in std_logic;
    addressB_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    dataB_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for MemorySimpleDualPort.
-------------------------------------------------------------------------------
architecture MemorySimpleDualPortImpl of MemorySimpleDualPort is
  type MemoryType is array (natural range <>) of
    std_logic_vector(DATA_WIDTH-1 downto 0);
  
  signal memory : MemoryType(0 to (2**ADDRESS_WIDTH)-1);
  
begin
  process(clkA_i)
  begin
    if (clkA_i'event and clkA_i = '1') then
      if (enableA_i = '1') then
        memory(to_integer(unsigned(addressA_i))) <= dataA_i;
      end if;
    end if;
  end process;

  process(clkB_i)
  begin
    if (clkB_i'event and clkB_i = '1') then
      if (enableB_i = '1') then
        dataB_o <= memory(to_integer(unsigned(addressB_i)));
      end if;
    end if;
  end process;
  
end architecture;



-------------------------------------------------------------------------------
-- MemorySinglePort
-- Generic synchronous memory with one read/write port.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


-------------------------------------------------------------------------------
-- Entity for MemorySinglePort.
-------------------------------------------------------------------------------
entity MemorySinglePort is
  generic(
    ADDRESS_WIDTH : natural := 1;
    DATA_WIDTH : natural := 1);
  port(
    clk_i : in std_logic;
    enable_i : in std_logic;
    writeEnable_i : in std_logic;
    address_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    data_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
    data_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for MemorySinglePort.
-------------------------------------------------------------------------------
architecture MemorySinglePortImpl of MemorySinglePort is
  type MemoryType is array (natural range <>) of
    std_logic_vector(DATA_WIDTH-1 downto 0);
  
  signal memory : MemoryType(0 to (2**ADDRESS_WIDTH)-1);
  
begin
  process(clk_i)
  begin
    if (clk_i'event and clk_i = '1') then
      if (enable_i = '1') then
        if (writeEnable_i = '1') then
          memory(to_integer(unsigned(address_i))) <= data_i;
        end if;

        data_o <= memory(to_integer(unsigned(address_i)));
      end if;
    end if;
  end process;

end architecture;




-------------------------------------------------------------------------------
-- MemorySimpleDualPortAsync
-- Generic memory with one synchronous write port and one asynchronous read port.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


-------------------------------------------------------------------------------
-- Entity for MemorySimpleDualPortAsync.
-------------------------------------------------------------------------------
entity MemorySimpleDualPortAsync is
  generic(
    ADDRESS_WIDTH : natural := 1;
    DATA_WIDTH : natural := 1;
    INIT_VALUE : std_logic := 'U');
  port(
    clkA_i : in std_logic;
    enableA_i : in std_logic;
    addressA_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    dataA_i : in std_logic_vector(DATA_WIDTH-1 downto 0);

    addressB_i : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    dataB_o : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity;


-------------------------------------------------------------------------------
-- Architecture for MemorySimpleDualPortAsync.
-------------------------------------------------------------------------------
architecture MemorySimpleDualPortAsyncImpl of MemorySimpleDualPortAsync is
  type MemoryType is array (natural range <>) of
    std_logic_vector(DATA_WIDTH-1 downto 0);
  
  signal memory : MemoryType(0 to (2**ADDRESS_WIDTH)-1) := (others=>(others=>INIT_VALUE));
  
begin
  process(clkA_i)
  begin
    if (clkA_i'event and clkA_i = '1') then
      if (enableA_i = '1') then
        memory(to_integer(unsigned(addressA_i))) <= dataA_i;
      end if;
    end if;
  end process;

  dataB_o <= memory(to_integer(unsigned(addressB_i)));
  
end architecture;



-------------------------------------------------------------------------------
-- RioFifo1
-- Simple fifo which is one entry deep.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


-------------------------------------------------------------------------------
-- Entity for RioFifo1.
-------------------------------------------------------------------------------
entity RioFifo1 is
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
end entity;
       

-------------------------------------------------------------------------------
-- Architecture for RioFifo1.
-------------------------------------------------------------------------------
architecture RioFifo1Impl of RioFifo1 is
  signal empty : std_logic;
  signal full : std_logic;
begin

  empty_o <= empty;
  full_o <= full;
  
  process(areset_n, clk)
  begin
    if (areset_n = '0') then
      empty <= '1';
      full <= '0';
      data_o <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (empty = '1') then
        if (write_i = '1') then
          empty <= '0';
          full <= '1';
          data_o <= data_i;
        end if;
      else
        if (read_i = '1') then
          empty <= '1';
          full <= '0';
        end if;
      end if;
    end if;
  end process;
  
end architecture;
