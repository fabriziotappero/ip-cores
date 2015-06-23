library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package TinyXconfig is
  constant XLEN : integer := 32;
  subtype  cpuWord is std_logic_vector(XLEN -1 downto 0);
  constant ccModeLeft    : integer := XLEN - 1;
  constant ccModeRight   : integer := XLEN - 4;
  constant aluModeLeft   : integer := XLEN - 5;
  constant aluModeRight  : integer := XLEN - 8;
  constant memmuxBit     : integer := XLEN - 9;
  constant dstClkLeft    : integer := XLEN - 10;
  constant dstClkRight   : integer := XLEN - 12;
  constant writeCycleBit : integer := XLEN - 13;
  constant opamuxLeft    : integer := XLEN - 14;
  constant opamuxRight   : integer := XLEN - 16;
  constant valmuxBit     : integer := XLEN - 17;
  constant opbmuxLeft    : integer := XLEN - 18;
  constant opbmuxRight   : integer := XLEN - 20;
  constant flagUpdateBit : integer := XLEN - 21;
  constant carryUseBit   : integer := XLEN - 22;
  -- two bits unused
  constant immediateLeft : integer := XLEN - 25;

  function getStdLogicVectorZeroes(int : in integer) return std_logic_vector;
end TinyXconfig;

package body TinyXconfig is
  function getStdLogicVectorZeroes(int : in integer) return std_logic_vector is
    variable result : std_logic_vector(int -1 downto 0);
  begin
    for index in result'range loop
      result(index) := '0';
    end loop;
    return result;
  end getStdLogicVectorZeroes;
end TinyXconfig;