----------------------------------------------------------------------
----                                                              ----
---- Single port asynchronous static RAM simulation model         ----
----                                                              ----
---- This file is part of the simu_mem project                    ----
----                                                              ----
---- Description                                                  ----
---- This is a single port asynchronous memory. This files        ----
---- describes three architectures. Two architectures are         ----
---- traditional array based memories. One describes the memory   ----
---- as an array of  STD_LOGIC_VECTOR, and the other describes    ----
---- the ARRAY as BIT_VECTOR.                                     ----
---- The third architecture describes the memory arranged as a    ----
---- linked list in order to conserve computer memory usage. The  ----
---- memory is organized as a linked list of BIT_VECTOR arrays    ----
---- whose size is defined by the constant PAGEDEPTH in           ----
---- single_port_pkg.vhd. Example for an applicable device:       ----
----                                                              ----
---- Manufacturer   Device                                        ----
---- IDT            IDT71V424                                     ----
----                                                              ----
---- Advantages of this model:                                    ----
---- 1. User can choose between an array implementation (for      ----
----    applications which access almost all memory locations in  ----
----    on single simulation) or a linked list implementation     ----
----    which consumes only few simulator memory otherwise.       ----
---- 2. Simulates quickly because it does not contain timing      ----
----    information. Fast simulator startup time of the linked    ----
----    list model.                                               ----
---- 3. Usable for any data and address bus width.                ----
---- 4. Works at any clock frequency.                             ----
---- 5. Programmed in VHDL.                                       ----
----                                                              ----
---- When this model will not be useful:                          ----
---- 1. When it has to be synthesized.                            ----
---- 2. When a timing model is required. Ask your RAM vendor for  ----
----    a timing model.                                           ----
---- 3. When your design is in Verilog.                           ----
----                                                              ----
---- Authors:                                                     ----
---- - Robert Paley, rpaley_yid@yahoo.com                         ----
---- - Michael Geng, vhdl@MichaelGeng.de                          ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2005 Authors                                   ----
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
--
LIBRARY IEEE;
  USE IEEE.STD_LOGIC_1164.ALL;
  USE IEEE.NUMERIC_STD.ALL;

  USE work.linked_list_mem_pkg.ALL;

ENTITY ASRAM IS 
  PORT (
    D           : IN    STD_LOGIC_VECTOR;   -- data in
    Q           : OUT   STD_LOGIC_VECTOR;   -- data out
    A           : IN    STD_LOGIC_VECTOR;   -- address bus
    CE_n        : IN    STD_LOGIC;          -- not chip enable
    WE_n        : IN    STD_LOGIC;          -- not write enable
    OE_n        : IN    STD_LOGIC;          -- not output enable
    dealloc_mem : IN    BOOLEAN := FALSE);  -- control signal for deallocating memory,
END ENTITY ASRAM;

ARCHITECTURE array_mem_no_flag OF ASRAM IS
BEGIN
  ASSERT D'LENGTH = Q'LENGTH
    REPORT "D and Q must have same the length"
    SEVERITY FAILURE;

  mem_proc : PROCESS (D, A, CE_n, WE_n, OE_n)
    TYPE mem_typ IS ARRAY (0 TO 2 ** A'length - 1) OF STD_LOGIC_VECTOR (D'RANGE);
    VARIABLE mem : mem_typ;
  BEGIN
    IF (CE_n = '0') AND (WE_n = '0') THEN   -- Write
      mem (TO_INTEGER (unsigned (A))) := D;
    END IF;

    IF (CE_n = '0') AND (OE_n = '0') THEN   -- Read
      Q <= mem (TO_INTEGER (unsigned (A)));
    ELSE
      Q <= (Q'RANGE => 'Z');
    END IF;
  END PROCESS mem_proc;

END array_mem_no_flag;

ARCHITECTURE array_mem OF ASRAM IS
BEGIN
  ASSERT D'LENGTH = Q'LENGTH
    REPORT "D and Q must have same the length"
    SEVERITY FAILURE;

  mem_proc : PROCESS (D, A, CE_n, WE_n, OE_n)
  TYPE mem_typ  IS ARRAY (0 TO 2 ** A'length - 1) OF BIT_VECTOR (D'RANGE);
  TYPE flag_typ IS ARRAY (0 TO 2 ** A'length - 1) OF BOOLEAN;
  VARIABLE mem  : mem_typ;
  VARIABLE flag : flag_typ;
  BEGIN
    IF (CE_n = '0') AND (WE_n = '0') THEN   -- Write
      mem (TO_INTEGER (unsigned (A))) := TO_BITVECTOR (D);
      flag (TO_INTEGER (unsigned (A))) := TRUE; -- set valid memory location flag
    END IF;

    IF (CE_n = '0') AND (OE_n = '0') THEN   -- Read
      IF (flag (TO_INTEGER (unsigned (A))) = TRUE) THEN  -- read data, either valid or 'U'
        Q <= TO_STDLOGICVECTOR (mem (TO_INTEGER (unsigned (A))));
      ELSE -- reading invalid memory location
        Q <= (Q'RANGE => 'U');
      END IF;
    ELSE
      Q <= (Q'RANGE => 'Z');
    END IF;
  END PROCESS mem_proc;
END array_mem;

ARCHITECTURE linked_list OF ASRAM IS
BEGIN
  ASSERT D'LENGTH = Q'LENGTH
    REPORT "D and Q must have same the length"
    SEVERITY FAILURE;

  mem_proc : PROCESS (D, A, CE_n, WE_n, OE_n, dealloc_mem)
    VARIABLE mem_page_v : mem_page_ptr;
    VARIABLE D_v : STD_LOGIC_VECTOR (D'RANGE);
    VARIABLE A_v : NATURAL;
  BEGIN
    IF dealloc_mem THEN
       -- deallocate simulator memory
      deallocate_mem (mem_page_v);
    ELSE
      D_v :=  D;
      if (CE_n = '0') then
         A_v := TO_INTEGER (unsigned (A));
      end if;
      IF (CE_n = '0') AND (WE_n = '0') THEN   -- Write
        rw_mem (data      => D_v,
                addr      => A_v,
                next_cell => mem_page_v,
                operation => write);
      END IF;

      IF (CE_n = '0') AND (OE_n = '0') THEN   -- Read
        rw_mem (data      => D_v,
                addr      => A_v,
                next_cell => mem_page_v,
                operation => read);
        Q <= D_v; 
      ELSE
        Q <= (D'RANGE => 'Z');
      END IF;
    END IF; 
  END PROCESS mem_proc;
END linked_list;
