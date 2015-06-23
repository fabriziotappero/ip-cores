----------------------------------------------------------------------
----                                                              ----
---- Single port asynchronous RAM simulation model                ----
----                                                              ----
---- This file is part of the single_port project                 ----
----                                                              ----
---- Description                                                  ----
---- This package implements functions to allocate, write, read   ----
---- and deallocate a linked list based memory.                   ----
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
-- Revision 1.2  2005/10/12 19:39:27  mgeng
-- Buses unconstrained, LGPL header added
--
-- Revision 1.1.1.1  2003/01/14 21:48:10  rpaley_yid
-- initial checkin 
--
-- Revision 1.1  2003/01/14 17:47:32  Default
-- Initial revision
--
-- Revision 1.1  2002/12/24 18:03:50  Default
-- Initial revision
--
LIBRARY IEEE;
LIBRARY WORK;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.single_port_pkg.all;

PACKAGE linked_list_mem_pkg IS
  CONSTANT PAGEDEPTH : INTEGER := 256; -- memory page depth
  -- pointer to one data word in the memory
  -- The reason for using a pointer here is that it seems to be the only way to keep the model
  -- independent of the data width
  TYPE data_ptr IS ACCESS BIT_VECTOR;
  -- data memory array type definition
  TYPE mem_array_typ IS ARRAY (0 TO PAGEDEPTH-1) OF data_ptr;
  -- Define memory page linked list cell. This cell contains
  -- the mem_array, starting page address, valid data array and 
  -- the pointer to the next element in the linked list.
  TYPE mem_page_typ;
  -- pointer to next item in the linked list.
  TYPE mem_page_ptr IS ACCESS mem_page_typ;
  TYPE mem_page_typ IS RECORD
    mem_array    : mem_array_typ; -- data memory
    page_address : addr_typ;
    next_cell    : mem_page_ptr;
  END RECORD mem_page_typ;
  PROCEDURE rw_mem (
    VARIABLE data       : INOUT STD_LOGIC_VECTOR;
    VARIABLE addr       : IN    addr_typ;
    VARIABLE next_cell  : INOUT mem_page_ptr;
    CONSTANT write_flag : IN    BOOLEAN);
  PROCEDURE deallocate_mem (
    VARIABLE next_cell : INOUT mem_page_ptr);

END PACKAGE linked_list_mem_pkg;

PACKAGE BODY linked_list_mem_pkg IS
  -- --------------------------------------------------
  -- The purpose of this procedure is to write a memory location from 
  -- the linked list, if the particular page does not exist, create it.
  -- --------------------------------------------------  
  PROCEDURE rw_mem (
    VARIABLE data       : INOUT STD_LOGIC_VECTOR;
    VARIABLE addr       : IN    addr_typ;
    VARIABLE next_cell  : INOUT mem_page_ptr;
    CONSTANT write_flag : IN    BOOLEAN) IS
    VARIABLE current_cell_v : mem_page_ptr; -- current page pointer
    VARIABLE page_address_v : addr_typ;     -- calculated page address
    VARIABLE index_v        : INTEGER;      -- address within the memory page
    VARIABLE mem_array_v    : mem_array_typ;
  BEGIN
    -- Copy the top of the linked list pointer to a working pointer
    current_cell_v := next_cell; 
    -- Calculate the index within the page from the given address
    index_v := addr MOD PAGEDEPTH; 
    -- Calculate the page address from the given address
    page_address_v := addr - index_v; 
    -- Search through the memory to determine if the calculated
    -- memory page exists. Stop searching when reach the end of
    -- the linked list.
    WHILE ( current_cell_v /= NULL AND 
            current_cell_v.page_address /= page_address_v) LOOP
      current_cell_v := current_cell_v.next_cell;
    END LOOP; 
    
    IF write_flag THEN 
      IF ( current_cell_v /= NULL AND -- Check if address exists in memory.
           current_cell_v.page_address = page_address_v ) THEN
        -- Found the memory page the particular address belongs to
        IF ( current_cell_v.mem_array(index_v) /= NULL ) THEN
          current_cell_v.mem_array(index_v).ALL := TO_BITVECTOR(data);
        ELSE
          current_cell_v.mem_array(index_v) := NEW BIT_VECTOR'(TO_BITVECTOR(data));
        END IF;
      ELSE 
        -- The memory page the address belongs to was not allocated in memory.
        -- Allocate page here and assign data.
        mem_array_v(index_v) := NEW BIT_VECTOR'(TO_BITVECTOR(data));
        next_cell := NEW mem_page_typ'( mem_array => mem_array_v,
                                  page_address => page_address_v,
                                  next_cell => next_cell); 
      END IF;
    ELSE -- Read memory
      IF ( current_cell_v /= NULL AND -- Check if address exists in memory.
           current_cell_v.page_address = page_address_v AND 
           current_cell_v.mem_array(index_v) /= NULL ) THEN
        -- Found the memory page the particular address belongs to,
        -- and the memory location has valid data.
        data := TO_STDLOGICVECTOR(current_cell_v.mem_array(index_v).ALL);
      ELSE 
        -- Trying to read from unwritten or unallocated 
        -- memory location, return 'U';
        data := (data'RANGE => 'U');
      END IF;
    END IF;  
  END PROCEDURE rw_mem; 
 
  PROCEDURE deallocate_mem (
    VARIABLE next_cell : INOUT mem_page_ptr) IS
    VARIABLE delete_cell_v : mem_page_ptr;
  BEGIN 
    -- Deallocate the linked link memory from work station memory.
    WHILE next_cell /= NULL LOOP -- while not reached the end of the LL
      delete_cell_v := next_cell; -- Copy pointer to record for deleting
      FOR i IN 0 TO PAGEDEPTH-1 LOOP
        IF delete_cell_v.mem_array(i) /= NULL THEN
          deallocate(delete_cell_v.mem_array(i));
        END IF;
      END LOOP;
      next_cell := next_cell.next_cell; -- set pointer to next cell in LL
      deallocate(delete_cell_v); -- Deallocate current cell from memory.
    END LOOP;
  END PROCEDURE deallocate_mem;
END PACKAGE BODY linked_list_mem_pkg;
