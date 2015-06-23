--------------------------------------------------------------------------------
--  File name: gen_utils.vhd
--------------------------------------------------------------------------------
--  Copyright (C) 1996, 1998, 2001  Free Model Foundry; http://eda.org/fmf/
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License version 2 as
--  published by the Free Software Foundation.
--
--  MODIFICATION HISTORY:
--
--  version: |  author:  | mod date: | changes made:
--    V1.0     R. Steele   96 SEP 26   Initial release
--    V1.1     REV3        97 Feb 27   Added Xon and MsgOn generics
--    V1.2     R. Steele   97 APR 16   Changed wired-or to wired-and
--    V1.3     R. Steele   97 APR 16   Added diff. receiver table
--    V1.4     R. Munden   98 APR 13   Added GenParity and CheckParity
--    V1.5     R. Munden   01 NOV 24   Added UnitDelay01ZX
--
--------------------------------------------------------------------------------
LIBRARY IEEE;   USE IEEE.std_Logic_1164.ALL;
                USE IEEE.VITAL_primitives.ALL;
                USE IEEE.VITAL_timing.ALL;

PACKAGE gen_utils IS

    ----------------------------------------------------------------------------
    -- Result map for Wired-and output values (open collector)
    ----------------------------------------------------------------------------
    CONSTANT STD_wired_and_rmap : VitalResultMapType := ('U','X','0','Z');

    ----------------------------------------------------------------------------
    -- Table for computing a single signal from a differential receiver input
    -- pair.
    ----------------------------------------------------------------------------
    CONSTANT diff_rec_tab : VitalStateTableType  := (

    ------INPUTS--|-PREV-|-OUTPUT----
    --   A   ANeg | Aint |  Aint'  --
    --------------|------|-----------
      ( 'X', '-',    '-',   'X'), -- A unknown
      ( '-', 'X',    '-',   'X'), -- A unknown
      ( '1', '-',    'X',   '1'), -- Recover from 'X'
      ( '0', '-',    'X',   '0'), -- Recover from 'X'
      ( '/', '0',    '0',   '1'), -- valid diff. rising edge
      ( '1', '\',    '0',   '1'), -- valid diff. rising edge
      ( '\', '1',    '1',   '0'), -- valid diff. falling edge
      ( '0', '/',    '1',   '0'), -- valid diff. falling edge
      ( '-', '-',    '-',   'S')  -- default
    ); -- end of VitalStateTableType definition


    ----------------------------------------------------------------------------
    -- Default Constants
    ----------------------------------------------------------------------------
    CONSTANT UnitDelay     : VitalDelayType     := 1 ns;
    CONSTANT UnitDelay01   : VitalDelayType01   := (1 ns, 1 ns);
    CONSTANT UnitDelay01Z  : VitalDelayType01Z  := (others => 1 ns);
    CONSTANT UnitDelay01ZX : VitalDelayType01ZX := (others => 1 ns);

    CONSTANT DefaultInstancePath : STRING  := "*";
    CONSTANT DefaultTimingChecks : BOOLEAN := FALSE;
    CONSTANT DefaultTimingModel  : STRING  := "UNIT";
    CONSTANT DefaultXon          : BOOLEAN := TRUE;
    CONSTANT DefaultMsgOn        : BOOLEAN := TRUE;

    -- Older VITAL generic being phased out
    CONSTANT DefaultXGeneration  : BOOLEAN := TRUE;

    -------------------------------------------------------------------
    -- Generate Parity for each 8-bit in 9th bit
    -------------------------------------------------------------------
    FUNCTION GenParity
        (Data    : in std_logic_vector;     -- Data
         ODDEVEN : in std_logic;        -- ODD (1) / EVEN(0)
         SIZE    : in POSITIVE)         -- Bit Size
         RETURN  std_logic_vector;
  
    -------------------------------------------------------------------
    -- Check Parity for each 8-bit in 9th bit
    -------------------------------------------------------------------
    FUNCTION CheckParity
        (Data    : in std_logic_vector;     -- Data
         ODDEVEN : in std_logic;        -- ODD (1) / EVEN(0)
         SIZE    : in POSITIVE)         -- Bit Size
         RETURN  std_logic;         -- '0' - Parity Error

END gen_utils;

PACKAGE BODY gen_utils IS

    function XOR_REDUCE(ARG: STD_LOGIC_VECTOR) return UX01 is
    -- pragma subpgm_id 403
    variable result: STD_LOGIC;
    begin
    result := '0';
    for i in ARG'range loop
        result := result xor ARG(i);
    end loop;
        return result;
    end;
    -------------------------------------------------------------------
    -- Generate Parity for each 8-bit in 9th bit
    -------------------------------------------------------------------
    FUNCTION GenParity
        (Data    : in std_logic_vector;     -- Data
         ODDEVEN : in std_logic;        -- ODD (1) / EVEN(0)
         SIZE    : in POSITIVE)         -- Bit Size
         RETURN  std_logic_vector
    IS
        VARIABLE I: NATURAL;
        VARIABLE Result: std_logic_vector (Data'Length - 1 DOWNTO 0);
    BEGIN
        I := 0;
        WHILE (I < SIZE) LOOP
          Result(I+7 DOWNTO I) := Data(I+7 downto I);
          Result(I+8) := XOR_REDUCE( Data(I+7 downto I) ) XOR ODDEVEN;
          I := I + 9;
        END LOOP;
        RETURN Result;
    END GenParity;

    -------------------------------------------------------------------
    -- Check Parity for each 8-bit in 9th bit
    -------------------------------------------------------------------
    FUNCTION CheckParity
        (Data    : in std_logic_vector;     -- Data
         ODDEVEN : in std_logic;        -- ODD (1) / EVEN(0)
         SIZE    : in POSITIVE)         -- Bit Size
         RETURN  std_logic          -- '0' - Parity Error
    IS
        VARIABLE I: NATURAL;
        VARIABLE Result: std_logic;
    BEGIN
        I := 0; Result := '1';
        WHILE (I < SIZE) LOOP
          Result := Result AND
                    NOT (XOR_REDUCE( Data(I+8 downto I) ) XOR ODDEVEN);
          I := I + 9;
        END LOOP;
        RETURN Result;
    END CheckParity;

END gen_utils;
