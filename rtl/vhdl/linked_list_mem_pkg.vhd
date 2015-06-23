----------------------------------------------------------------------
----                                                              ----
---- Linked list based RAM simulation model                       ----
----                                                              ----
---- This file is part of the simu_mem project.                   ----
----                                                              ----
---- Description                                                  ----
---- This package implements functions to allocate, write, read   ----
---- and deallocate a linked list based memory.                   ----
----                                                              ----
---- Authors:                                                     ----
---- - Robert Paley, rpaley_yid@yahoo.com                         ----
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
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
--
LIBRARY IEEE;
  USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE linked_list_mem_pkg IS
  -- pointer to one data word in the memory
  -- The reason for using a pointer here is that it seems to be the only way to keep the model
  -- independent of the data width
  CONSTANT PAGEDEPTH : INTEGER := 256; -- memory page depth

  TYPE operation_type is (read, write);

  -- data memory array type definition
  TYPE data_ptr IS ACCESS BIT_VECTOR;

  -- Define memory page linked list cell. This cell contains
  -- the mem_array, starting page address, valid data array and 
  -- the pointer to the next element in the linked list.
  TYPE mem_array_type IS ARRAY (0 TO PAGEDEPTH-1) OF data_ptr;

  -- pointer to next item in the linked list.
  TYPE mem_page_type;

  TYPE mem_page_ptr IS ACCESS mem_page_type;

  TYPE mem_page_type IS RECORD
    mem_array    : mem_array_type; -- data memory
    page_address : NATURAL;
    next_cell    : mem_page_ptr;
  END RECORD mem_page_type;

  PROCEDURE rw_mem (
    data               : INOUT STD_LOGIC_VECTOR;
    addr               : IN    NATURAL;
    next_cell          : INOUT mem_page_ptr;
    CONSTANT operation : IN    operation_type);

  PROCEDURE deallocate_mem (
    VARIABLE next_cell : INOUT mem_page_ptr);
END PACKAGE linked_list_mem_pkg;

PACKAGE BODY linked_list_mem_pkg IS
  -- --------------------------------------------------
  -- The purpose of this procedure is to read or write a memory location from 
  -- the linked list, if the particular page does not exist, create it.
  -- --------------------------------------------------  
  PROCEDURE rw_mem (
    data               : INOUT STD_LOGIC_VECTOR;
    addr               : IN    NATURAL;
    next_cell          : INOUT mem_page_ptr;
    CONSTANT operation : IN    operation_type) IS
    VARIABLE current_cell_v : mem_page_ptr; -- current page pointer
    VARIABLE page_address_v : NATURAL;      -- calculated page address
    VARIABLE index_v        : INTEGER;      -- address within the memory page
    VARIABLE mem_array_v    : mem_array_type;
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
    WHILE (current_cell_v /= NULL AND
           current_cell_v.page_address /= page_address_v) LOOP
      current_cell_v := current_cell_v.next_cell;
    END LOOP;
    
    IF (operation = write) THEN
      IF (current_cell_v /= NULL AND -- Check if address exists in memory.
          current_cell_v.page_address = page_address_v) THEN
        -- Found the memory page the particular address belongs to
        IF (current_cell_v.mem_array (index_v) /= NULL) THEN
          current_cell_v.mem_array (index_v).ALL := TO_BITVECTOR(data);
        ELSE
          current_cell_v.mem_array (index_v) := NEW BIT_VECTOR'(TO_BITVECTOR (data));
        END IF;
      ELSE
        -- The memory page the address belongs to was not allocated in memory.
        -- Allocate page here and assign data.
        mem_array_v (index_v) := NEW BIT_VECTOR'(TO_BITVECTOR (data));
        next_cell := NEW mem_page_type'(mem_array => mem_array_v,
                                        page_address => page_address_v,
                                        next_cell => next_cell);
      END IF;
    ELSE -- Read memory
      IF (current_cell_v /= NULL AND -- Check if address exists in memory.
          current_cell_v.page_address = page_address_v AND
          current_cell_v.mem_array (index_v) /= NULL) THEN
        -- Found the memory page the particular address belongs to,
        -- and the memory location has valid data.
        data := TO_STDLOGICVECTOR (current_cell_v.mem_array (index_v).ALL);
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
        IF delete_cell_v.mem_array (i) /= NULL THEN
          deallocate (delete_cell_v.mem_array (i));
        END IF;
      END LOOP;
      next_cell := next_cell.next_cell; -- set pointer to next cell in linked list
      deallocate (delete_cell_v); -- Deallocate current cell from memory.
    END LOOP;
  END PROCEDURE deallocate_mem;
END PACKAGE BODY linked_list_mem_pkg;
