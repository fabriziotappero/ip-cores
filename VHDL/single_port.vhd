----------------------------------------------------------------------
----                                                              ----
---- Single port asynchronous RAM simulation model                ----
----                                                              ----
---- This file is part of the single_port project                 ----
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
---- single_port_pkg.vhd.                                         ----
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
-- Revision 1.4  2005/11/19 15:18:54  mgeng
-- rnw replaced by nce, nwe and noe, tristate drivers added
--
-- Revision 1.3  2005/10/25 18:26:52  mgeng
-- PAGENUM constant removed because the address bus width provides this information
--
-- Revision 1.2  2005/10/12 19:39:27  mgeng
-- Buses unconstrained, LGPL header added
--
-- Revision 1.1.1.1  2003/01/14 21:48:11  rpaley_yid
-- initial checkin 
--
-- Revision 1.1  2003/01/14 17:48:31  Default
-- Initial revision
--
-- Revision 1.1  2002/12/24 18:09:05  Default
-- Initial revision
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.single_port_pkg.ALL;
USE WORK.linked_list_mem_pkg.ALL;

ENTITY single_port IS 
  GENERIC (
    rnwtQ : TIME := 1 NS);
  PORT (
    d           : IN  STD_LOGIC_VECTOR;   -- data bus input
    q           : OUT STD_LOGIC_VECTOR;   -- data bus output
    a           : IN  STD_LOGIC_VECTOR;   -- address bus
    nce         : IN  STD_LOGIC;          -- not chip enable
    nwe         : IN  STD_LOGIC;          -- not write enable
    noe         : IN  STD_LOGIC;          -- not output enable
    dealloc_mem : IN  BOOLEAN := FALSE);  -- control signal for deallocating memory,
                                          -- only used in the linked list implementation
END ENTITY single_port;

ARCHITECTURE ArrayMemNoFlag OF single_port IS
BEGIN
  
  mem_proc : PROCESS(d, a, nce, nwe, noe)
    TYPE mem_typ IS ARRAY ( 0 TO 2**a'length-1 ) OF STD_LOGIC_VECTOR(d'RANGE);
    VARIABLE mem : mem_typ;
  BEGIN
    IF ( nce = '0' ) AND ( nwe = '0' ) THEN   -- Write
      mem(TO_INTEGER(unsigned(a))) := d;
    END IF;

    IF ( nce = '0' ) AND ( noe = '0' ) THEN   -- Read
      q <= mem(TO_INTEGER(unsigned(a))) AFTER rnwtQ;
    ELSE
      q <= (q'RANGE => 'Z') AFTER rnwtQ;
    END IF;
  END PROCESS mem_proc;

END ArrayMemNoFlag;

ARCHITECTURE ArrayMem OF single_port IS
BEGIN
  
  mem_proc : PROCESS(d, a, nce, nwe, noe)
  TYPE mem_typ  IS ARRAY ( 0 TO 2**a'length-1 ) OF BIT_VECTOR(d'RANGE);
  TYPE flag_typ IS ARRAY ( 0 TO 2**a'length-1 ) OF BOOLEAN;
  VARIABLE mem  : mem_typ;
  VARIABLE flag : flag_typ;
  BEGIN
    IF ( nce = '0' ) AND ( nwe = '0' ) THEN   -- Write
      mem( TO_INTEGER(unsigned(a))) := TO_BITVECTOR(d);
      flag(TO_INTEGER(unsigned(a))) := true; -- set valid memory location flag
    END IF;

    IF ( nce = '0' ) AND ( noe = '0' ) THEN   -- Read
      IF ( flag(TO_INTEGER(unsigned(a))) = true ) THEN  -- read data, either valid or 'U'
        q <= TO_STDLOGICVECTOR(mem(TO_INTEGER(unsigned(a)))) AFTER rnwtQ;
      ELSE -- reading invalid memory location
        q <= (q'RANGE => 'U') AFTER rnwtQ;
      END IF;
    ELSE
      q <= (q'RANGE => 'Z') AFTER rnwtQ;
    END IF;
  END PROCESS mem_proc;
END ArrayMem;

ARCHITECTURE LinkedList OF single_port IS
  CONSTANT WRITE_MEM : BOOLEAN := true;
  CONSTANT READ_MEM  : BOOLEAN := false;
BEGIN
  
  mem_proc : PROCESS(d, a, nce, nwe, noe, dealloc_mem)
    VARIABLE mem_page_v : mem_page_ptr;
    VARIABLE d_v : STD_LOGIC_VECTOR(d'RANGE);
    VARIABLE a_v : addr_typ;
  BEGIN
    IF NOT dealloc_mem THEN
      d_v :=  d;
      if (nce = '0') then
         a_v := TO_INTEGER(unsigned(a));
      end if;
      IF ( nce = '0' ) AND ( nwe = '0' ) THEN   -- Write
        rw_mem( data       => d_v,
                addr       => a_v,
                next_cell  => mem_page_v,
                write_flag => WRITE_MEM); 
      END IF;

      IF ( nce = '0' ) AND ( noe = '0' ) THEN   -- Read
        rw_mem( data       => d_v,
                addr       => a_v,
                next_cell  => mem_page_v,
                write_flag => READ_MEM);
        q <= d_v AFTER rnwtQ; 
      ELSE
        q <= (q'RANGE => 'Z') AFTER rnwtQ;
      END IF;
    ELSE -- Deallocate memory from work station memory.
      deallocate_mem(mem_page_v);
    END IF; 
  END PROCESS mem_proc;
END LinkedList;
