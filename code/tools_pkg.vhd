-------------------------------------------------------------------------------
-- Title      :  Tools Package
-- Project    :  Utility library
-------------------------------------------------------------------------------
-- File        : tools.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     : 2000/11/02
-- Last update : 2000/11/02
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--               ieee.std_logic_arith
--               ieee.std_logic_unsigned
--
-------------------------------------------------------------------------------
-- Description:  This package contains set of usefull functions and procedures
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
-- Date            :   2nd Nov 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
--
---------- Revisions  :
-- Revision Number :   2
-- Version         :   0.2
-- Date            :   14 Nov 2000
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Shift functions and int_2_slv are added
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


package tools_pkg is
-------------------------------------------------------------------------------
-- Types

-- Memory arraye type of std_logic_vector
--  type std_memory_array_typ is array (integer range <>) of std_logic_vector(5 downto 0);  --integer range <>);

-- Memory arraye type of std_ulogic_vector
--  type stdu_memory_array_typ is array (integer range <>) of std_ulogic_vector(integer range <>);

-- Sign magnitude numbers based on std_logic_vector (The msb represents the sign)
  type SIGN_MAG_typ is array (natural range <>) of std_logic;


-----------------------------------------------------------------------------  
-- Functions


  function Log2( input : integer ) return integer;  -- log2 functions

  function slv_2_int ( SLV : std_logic_vector) return integer;  --
                                                                --std_logic_vector
                                                                --to integer

  function "+"(A, B : SIGN_MAG_typ) return SIGN_MAG_typ;  -- sign_magnitude addition

  function "-"(A, B : SIGN_MAG_typ) return SIGN_MAG_typ;  -- sign_magnitude
                                                          -- subtraction (
                                                          -- based on
                                                          -- complement operations)
  function LeftShift (
    InReg           : std_logic_vector;                   -- Input Register
    ShSize          : std_logic_vector)                   -- Shift Size
    return std_logic_vector;


  function RightShift (
    InReg  : std_logic_vector;          -- Input register
    ShSize : std_logic_vector)          -- Shift Size  
    return std_logic_vector;

  function int_2_slv (val, SIZE : integer) return std_logic_vector;

-----------------------------------------------------------------------------  
end tools_pkg;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
package body tools_pkg is

-----------------------------------------------------------------------------
  function Log2(
    input              : integer )      -- input number 
    return integer is
    variable temp, log : integer;
  begin

    assert input /= 0
      report "Error : function missuse : log2(zero)"
      severity failure;
    temp   := input;
    log    := 0;
    while (temp /= 0) loop
      temp := temp/2;
      log  := log+1;
    end loop;
    return log;
  end log2;
-------------------------------------------------------------------------------

-- function LOG2(COUNT:INTEGER) return INTEGER is  -- COUNT should be >0 variable TEMP:INTEGER;
-- variable TEMP : integer;
-- variable cnt : integer;
--  begin
-- cnt := COUNT;
-- 
--    TEMP:=0;
--    while COUNT>1 loop
--      TEMP:=TEMP+1;
--      cnt:=cnt/2;
--    end loop;
--    return TEMP;
--  end log2;
-------------------------------------------------------------------------------
  function slv_2_int (
    SLV : std_logic_vector)             -- std_logic_vector to convert
    return integer is

    variable Result : integer := 0;     -- conversion result

  begin
    for i in SLV'range loop
      Result                     := Result * 2;  -- shift the variable to left
      case SLV(i) is
        when '1' | 'H' => Result := Result + 1;
        when '0' | 'L' => Result := Result + 0;
        when others    => null;
      end case;
    end loop;

    return Result;
  end;
-------------------------------------------------------------------------------
  function "+"(A, B     : SIGN_MAG_typ) return SIGN_MAG_typ is
    variable VA, VB, VR : unsigned(A'length - 1 downto 0);
-- include the overflow bit

    variable SA, SB, SR : std_logic;
    variable TMP, RES   : SIGN_MAG_typ(A'length - 1 downto 0);

    variable casevar : std_logic_vector(1 downto 0);
    variable std_tmp : std_logic_vector(A'length - 1 downto 0) := (others => '0');

  begin

    assert A'length = B'length
      report "Error : length mismatch"
      severity failure;


    TMP := A;
    SA  := TMP(A'length - 1);
    VA  := '0' & unsigned(TMP(A'length - 2 downto 0));
    TMP := B;
    SB  := TMP(B'length - 1);
    VB  := '0' & unsigned(TMP(B'length - 2 downto 0));

    casevar := SA & SB;
    case casevar is
      when "00" |"11" =>

        VR := VA + VB;
        SR := SA;

      when "01" =>

        VR := VA - VB;
        SR := VR(VR'length - 1);

        if SR = '1' then
          std_tmp(VR'length -2 downto 0) := std_logic_vector(VR(VR'length -2 downto 0));
          std_tmp                        := not std_tmp;

          VR(VR'length -2 downto 0) := unsigned(std_tmp(VR'length -2 downto 0));

          VR(VR'length -2 downto 0) := VR(VR'length -2 downto 0) +1;

        end if;


      when "10" =>
        VR := VB - VA;
        SR := VR(VR'length - 1);

        if SR = '1' then
          std_tmp(VR'length -2 downto 0) := std_logic_vector(VR(VR'length -2 downto 0));
          std_tmp                        := not std_tmp;

          VR(VR'length -2 downto 0) := unsigned(std_tmp(VR'length -2 downto 0));

          VR(VR'length -2 downto 0) := VR(VR'length -2 downto 0) +1;

        end if;

      when others => null;
    end case;


    RES := SIGN_MAG_typ(SR & VR(VR'length -2 downto 0));

    return RES;
  end "+";

-------------------------------------------------------------------------------
--  function "+"(A, B: SIGN_MAG) return SIGN_MAG is
--  variable VA, VB, VR: UNSIGNED(A'length - 2 downto 0);
--  variable SA, SB, SR: STD_LOGIC;
--  variable TMP, RES: SIGN_MAG(A'length - 1 downto 0);
--begin
--  assert A'length = B'length
--    report "Error"
--    severity FAILURE;
--  TMP := A;
--  SA := TMP(A'length - 1);
--  VA := UNSIGNED(TMP(A'length - 2 downto 0));
--  TMP := B;
--  SB := TMP(B'length - 1);
--  VB := UNSIGNED(TMP(B'length - 2 downto 0));
--  if (SA = SB) then
--    VR := VA + VB;
--    SR := SA;
--  elsif (VA >= VB) then
--    VR := VA - VB;
--    SR := SA;
--  else
--    VR := VB - VA;
--    SR := SB;
--  end if;
--  RES := SIGN_MAG(SR & VR);
--  return RES;
--end "+";
-------------------------------------------------------------------------------
  function "-"(A, B : SIGN_MAG_typ) return SIGN_MAG_typ is
    variable TMP    : SIGN_MAG_typ(A'length - 1 downto 0);
  begin
    assert A'length = B'length
      report "Error : length mismach"
      severity failure;
    TMP               := B;
    TMP(B'length - 1) := not TMP(B'length - 1);
    return A + TMP;
  end "-";

-------------------------------------------------------------------------------
  -- purpose: combinational left shift register
  function LeftShift (
    InReg  : std_logic_vector;          -- Input Register
    ShSize : std_logic_vector)          -- Shift Size
    return std_logic_vector is

    constant REGSIZE   : integer := InReg'length;        -- Register Size
    variable VarReg    : std_logic_vector(InReg'length -1 downto 0);
                                                         -- Local storage for shifter
    constant SHIFTSIZE : integer := log2(InReg'length);  -- Shift size
  begin

    VarReg := inReg;

    for i in 0 to SHIFTSIZE -2 loop


      if ShSize(i) = '1' then

        VarReg(REGSIZE -1 downto 0) := VarReg( (REGSIZE-(2**i)-1) downto 0) & ((2**i)-1 downto 0 => '0');

      end if;

    end loop;  -- i

    if ShSize(SHIFTSIZE-1) = '1' then
      VarReg := (others => '0');
    end if;

    return VarReg;

  end LeftShift;

-------------------------------------------------------------------------------
-- purpose: combinational Right shift register
  function RightShift (
    InReg  : std_logic_vector;          -- Input register
    ShSize : std_logic_vector)          -- Shift Size  
    return std_logic_vector is

    constant REGSIZE   : integer := InReg'length;        -- Register Size
    variable VarReg    : std_logic_vector(InReg'length -1 downto 0);
                                                         -- Local storage for shifter
    constant SHIFTSIZE : integer := log2(InReg'length);  -- Shift size

  begin  -- RightShift




    VarReg := inReg;

    for i in 0 to SHIFTSIZE -2 loop


      if ShSize(i) = '1' then

        VarReg(REGSIZE -1 downto 0) := (REGSIZE-1 downto REGSIZE-(2**i) => '0') & VarReg(REGSIZE -1 downto (2**i));

      end if;

    end loop;  -- i

    if ShSize(SHIFTSIZE-1) = '1' then
      VarReg := (others => '0');
    end if;

    return VarReg;


  end RightShift;
-------------------------------------------------------------------------------
-- purpose: Integer to Std_logic_vector conversion
  function int_2_slv (val, SIZE : integer) return std_logic_vector is
    variable result             : std_logic_vector(SIZE-1 downto 0);
    variable l_val              : integer := val;
  begin

    assert SIZE > 1
      report "Error : function missuse : in_2_slv(val, negative size)"
      severity failure;

    for i in 0 to result'length-1 loop

      if (l_val mod 2) = 0 then

        result(i) := '0';

      else
        result(i) := '1';

      end if;

      l_val := l_val/2;

    end loop;

    return result;

  end int_2_slv;
-------------------------------------------------------------------------------
end tools_pkg;
