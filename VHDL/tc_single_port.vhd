----------------------------------------------------------------------
----                                                              ----
---- Single port asynchronous RAM simulation model                ----
----                                                              ----
---- This file is part of the single_port project                 ----
----                                                              ----
---- Description                                                  ----
---- This file specifies test cases for the single_port Memory.   ----
----                                                              ----
---- Authors:                                                     ----
---- - Robert Paley, rpaley_yid@yahoo.com                         ----
---- - Michael Geng, vhdl@MichaelGeng.de                          ----
----                                                              ----
---- References:                                                  ----
----   1. The Designer's Guide to VHDL by Peter Ashenden          ----
----      ISBN: 1-55860-270-4 (pbk.)                              ----
----   2. Writing Testbenches - Functional Verification of HDL    ----
----      models by Janick Bergeron | ISBN: 0-7923-7766-4         ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2005 Authors and OPENCORES.ORG                 ----
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
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
-- Revision 1.1.1.1  2003/01/14 21:48:11  rpaley_yid
-- initial checkin 
--
-- Revision 1.1  2003/01/14 17:49:04  Default
-- Initial revision
--
-- Revision 1.2  2002/12/31 19:19:43  Default
-- Updated 'transaction statements for fixed simulator.
--
-- Revision 1.1  2002/12/24 18:13:50  Default
-- Initial revision
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.SINGLE_PORT_PKG.ALL;
USE WORK.PKG_IMAGE.ALL;
 
ENTITY tc_single_port IS
PORT  (
  to_srv  : OUT to_srv_typ;
  frm_srv : IN  STD_LOGIC_VECTOR);
END ENTITY tc_single_port;

-- --------------------------------------------------
-- Test Case TC0
-- This test case is to check two pages of memory 
-- Starting at physical address 0x0 , 
-- Write a '1' to bit position 0, leaving all other bits 0.
-- Increment the address, 
-- Write a '1' to bit position 1, leaving all other bits 0.
-- Increment the address.
-- Write a '1' to bit position 2, leaving all other bits 0.
-- Continue in this fasion, until write a 1 to the MSB.
-- increment the address,
-- Write a '1' to bit position 0, leaving all other bits 0.
-- Continue until the entire page is written to.
-- Read back all addresses in the page, ensuring the
-- correct data is read back.
-- --------------------------------------------------


ARCHITECTURE TC0 OF tc_single_port IS
BEGIN
  MAIN : PROCESS
    VARIABLE to_srv_v  : to_srv_typ;
    VARIABLE frm_srv_v : STD_LOGIC_VECTOR(frm_srv'RANGE);
    VARIABLE dv        : STD_LOGIC_VECTOR(frm_srv'RANGE) := 
                         STD_LOGIC_VECTOR(TO_UNSIGNED(1, frm_srv'length));
    VARIABLE offset_v  : INTEGER;
  BEGIN
    offset_v := 0;
    -- Run this write/read test 10 times for benchmark
    -- purposes.
    FOR i IN 0 to 9 LOOP 
      FOR index IN 0 to 2*PAGEDEPTH-1 LOOP
        -- Specify to testbench server to perform write operation;
        to_srv_v.do := write;
        to_srv_v.data := TO_INTEGER(SIGNED(dv)); -- specify data to write
        dv := To_StdLogicVector(TO_BitVector(dv) ROL 1); -- ROL 1 for next write
        -- Specify physical address.
        to_srv_v.addr := index+offset_v;
        to_srv <= to_srv_v;
        WAIT ON frm_srv'TRANSACTION;
      END LOOP;
      -- Reset data to 1.
      dv := STD_LOGIC_VECTOR(TO_UNSIGNED(1,frm_srv'length));
      FOR index IN 0 to 2*PAGEDEPTH-1 LOOP  
        -- Perform read operation. 
        to_srv_v.do := read;
        -- Specify physical address.
        to_srv_v.addr := index+offset_v;
        to_srv <= to_srv_v;
        WAIT ON frm_srv'TRANSACTION;
        -- Compare actual with expected read back data, if the
        -- the expected and actual to not compare, print the 
        -- expected and actual values.
        ASSERT frm_srv = dv
          REPORT "Expected: " & HexImage(frm_srv) &
                 " did not equal Actual: " & HexImage(dv)
          SEVERITY ERROR; 
        -- Set expected data for next read.
        dv := TO_STDLOGICVECTOR(TO_BITVECTOR(dv) ROL 1);
      END LOOP;
    END LOOP;
    to_srv_v.do := dealloc; -- Deallocate memory
    --  
    to_srv <= to_srv_v;
    -- Tell test bench server process test completed.
    to_srv_v.do := end_test;
    to_srv <= to_srv_v; 
    ASSERT FALSE
      REPORT "Completed Test TC0"
      SEVERITY NOTE;
    WAIT;
  END PROCESS main;
END TC0;

-- --------------------------------------------------
-- Test Case TC1
-- This test case is to check if the test bench will
-- return 'U' for invalid memory locations for 
-- single_port architectures ArrayMem and LinkedList
-- --------------------------------------------------
ARCHITECTURE TC1 OF tc_single_port IS
BEGIN
  MAIN : PROCESS
    VARIABLE to_srv_v  : to_srv_typ;
    VARIABLE frm_srv_v : STD_LOGIC_VECTOR(frm_srv'RANGE);
    VARIABLE dv        : STD_LOGIC_VECTOR(frm_srv'RANGE) := (OTHERS => 'U');
  BEGIN
    -- Perform read operation. 
    to_srv_v.do := read;
    -- Specify physical address.
    to_srv_v.addr := 0;
    to_srv <= to_srv_v;
    WAIT ON frm_srv'TRANSACTION;
    -- Compare actual with expected read back data, if the
    -- the expected and actual to not compare, print the 
    -- expected and actual values.
    ASSERT frm_srv = dv
      REPORT "Expected: " & HexImage(frm_srv) &
             " did not equal Actual: " & HexImage(dv)
      SEVERITY ERROR; 

    -- Write and read back from same address.

    -- Specify to testbench server to perform write operation;
    to_srv_v.do := write;
    dv := X"a5a5a5a5";
    to_srv_v.data := TO_INTEGER(SIGNED(dv)); -- specify data to write
    -- Specify physical address.
    to_srv_v.addr := 0;
    to_srv <= to_srv_v;
    -- Wait until the test bench server finished with the write.
    -- WAIT UNTIL frm_srv.event = true; 
    WAIT ON frm_srv'TRANSACTION;
    
    to_srv_v.do := read;
    -- Specify physical address.
    to_srv_v.addr := 0;
    to_srv <= to_srv_v;
    WAIT ON frm_srv'TRANSACTION;
    
    -- Compare actual with expected read back data, if the
    -- the expected and actual to not compare, print the 
    -- expected and actual values.
    ASSERT frm_srv = dv
      REPORT "Expected: " & HexImage(frm_srv) &
             " did not equal Actual: " & HexImage(dv)
      SEVERITY ERROR; 

    to_srv_v.do := dealloc; -- Deallocate memory
    --  
    to_srv <= to_srv_v;
    -- Tell test bench server process test completed.
    to_srv_v.do := end_test;
    to_srv <= to_srv_v;
    
    ASSERT FALSE
      REPORT "Completed Test TC1"
      SEVERITY NOTE;
    WAIT;
  END PROCESS main;
END TC1;
