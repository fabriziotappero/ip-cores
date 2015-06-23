----------------------------------------------------------------------
----                                                              ----
---- Synchronous static RAM ("Zero Bus Turnaround" RAM, ZBT RAM)  ----
---- simulation model                                             ----
----                                                              ----
---- This file is part of the simu_mem project                    ----
----                                                              ----
---- Description                                                  ----
---- State definition and next state calculation function for     ----
---- the ZBT RAM model                                            ----
----                                                              ----
---- Authors:                                                     ----
---- - Michael Geng, vhdl@MichaelGeng.de                          ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2008 Authors                                   ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
--
LIBRARY IEEE;
  USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE ZBT_RAM_pkg IS 
  TYPE state_type IS (
    sleep,
    deselect,
    deselect_continue,
    read,
    read_continue,
    dummy_read,
    dummy_read_continue,
    write,
    write_continue,
    write_abort,
    write_abort_continue,
    invalid_state);

  FUNCTION calc_state (
    CS1_n : STD_LOGIC;
    CS2   : STD_LOGIC;
    CS2_n : STD_LOGIC;
    WE_n  : STD_LOGIC;
    BW_n  : STD_LOGIC_VECTOR;
    OE_n  : STD_LOGIC;
    ADV   : STD_LOGIC;
    ZZ    : STD_LOGIC;
    operation : state_type) RETURN state_type;

  FUNCTION calc_operation (
    state     : state_type;
    operation : state_type) RETURN state_type;
END PACKAGE ZBT_RAM_pkg;

PACKAGE BODY ZBT_RAM_pkg IS
  FUNCTION calc_state (
    CS1_n : STD_LOGIC;
    CS2   : STD_LOGIC;
    CS2_n : STD_LOGIC;
    WE_n  : STD_LOGIC;
    BW_n  : STD_LOGIC_VECTOR;
    OE_n  : STD_LOGIC;
    ADV   : STD_LOGIC;
    ZZ    : STD_LOGIC;
    operation : state_type) RETURN state_type IS
    VARIABLE selected : BOOLEAN;
  BEGIN
    selected := ((CS1_n = '0') AND (CS2 = '1') AND (CS2_n = '0'));

    IF (ZZ = '1') THEN
      RETURN sleep;
    ELSIF ((ADV = '0') AND (NOT selected)) THEN
      RETURN deselect;
    ELSIF ((ADV = '1') AND (operation = deselect)) THEN
      RETURN deselect_continue;
    ELSIF (selected AND (ADV = '0') AND (WE_n = '1') AND (OE_n = '0')) THEN
      RETURN read;
    ELSIF ((ADV = '1') AND (OE_n = '0') AND (operation = Read)) THEN
      RETURN read_continue;
    ELSIF (selected AND (ADV = '0') AND (WE_n = '1') AND (OE_n = '1')) THEN
      RETURN dummy_read;
    ELSIF ((ADV = '1') AND (OE_n = '1') AND (operation = Read)) THEN
      RETURN dummy_read_continue;
    ELSIF (selected AND (ADV = '0') AND (WE_n = '0') AND (BW_n /= (BW_n'range => '1'))) THEN
      RETURN write;
    ELSIF ((ADV = '1') AND (BW_n /= (BW_n'range => '1')) AND (operation = write)) THEN
      RETURN write_continue;
    ELSIF (selected AND (ADV = '0') AND (WE_n = '0') AND (BW_n = (BW_n'range => '1')) AND 
      (operation = Write)) THEN
      RETURN write_abort;
    ELSIF ((ADV = '1') AND (BW_n = (BW_n'range => '1')) AND (operation = write_abort)) THEN
      RETURN write_abort_continue;
    ELSE
      RETURN invalid_state;
    END IF;
  END FUNCTION calc_state;

  FUNCTION calc_operation (
    state     : state_type;
    operation : state_type) RETURN state_type IS
  BEGIN
    CASE state IS
      WHEN deselect | write | write_abort | read =>
        RETURN state;
      WHEN dummy_read =>
        RETURN read;
      WHEN OTHERS =>
        RETURN operation;
    END CASE;
  END FUNCTION calc_operation;
END PACKAGE BODY ZBT_RAM_pkg;
