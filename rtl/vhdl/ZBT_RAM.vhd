----------------------------------------------------------------------
----                                                              ----
---- Synchronous static RAM ("Zero Bus Turnaround" RAM, ZBT RAM)  ----
---- simulation model                                             ----
----                                                              ----
---- This file is part of the simu_mem project.                   ----
----                                                              ----
---- Description                                                  ----
---- This is a functional simulation model for single port        ----
---- synchronous static RAMs. Examples for applicable devices:    ----
----                                                              ----
---- Manufacturer   Device                                        ----
---- Samsung        K7N643645M                                    ----
---- ISSI           IS61NLP51236                                  ----
----                                                              ----
---- Advantages of this model:                                    ----
---- 1. Consumes few simulator memory if only few memory          ----
----    locations are accessed because it internally uses a       ----
----    linked list.                                              ----
---- 2. Simulates quickly because it does not contain timing      ----
----    information. Fast simulator startup time because of the   ----
----    linked list.                                              ----
---- 3. Usable for any data and address bus width.                ----
---- 4. Works at any clock frequency.                             ----
---- 5. Programmed in VHDL.                                       ----
----                                                              ----
---- When this model will not be useful:                          ----
---- 1. When it has to be synthesized.                            ----
---- 2. When a timing model is required. Ask your RAM vendor for  ----
----    a timing model.                                           ----
---- 3. When all memory locations have to be accessed in one      ----
----    single simulation run. The linked list model will not     ----
----    be well suited then.                                      ----
---- 4. When your design is in Verilog.                           ----
----                                                              ----
---- For above reasons a typical application is a functional      ----
---- simulation of a design which uses external synchronous       ----
---- static RAMs.                                                 ----
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
---- from http://www.gnu.org/licenses/lgpl.html                   ----
----                                                              ----
----------------------------------------------------------------------
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
--
LIBRARY IEEE;
  USE IEEE.STD_LOGIC_1164.ALL;
  USE IEEE.NUMERIC_STD.ALL;

  USE work.ZBT_RAM_pkg.ALL;
  USE work.linked_list_mem_pkg.ALL;

ENTITY ZBT_RAM IS
  GENERIC (
    debug : INTEGER := 0);  -- >= 1: print      write operations
                            -- >= 2: print also read  operations
  PORT (
    Clk   : IN  STD_LOGIC;
    D     : IN  STD_LOGIC_VECTOR;
    Q     : OUT STD_LOGIC_VECTOR;
    A     : IN  STD_LOGIC_VECTOR;
    CKE_n : IN  STD_LOGIC;
    CS1_n : IN  STD_LOGIC;
    CS2   : IN  STD_LOGIC;
    CS2_n : IN  STD_LOGIC;
    WE_n  : IN  STD_LOGIC;
    BW_n  : IN  STD_LOGIC_VECTOR;
    OE_n  : IN  STD_LOGIC;
    ADV   : IN  STD_LOGIC;
    ZZ    : IN  STD_LOGIC;
    LBO_n : IN  STD_LOGIC;
    dealloc_mem : IN BOOLEAN := FALSE);  -- control SIGNAL for deallocating memory
END ENTITY ZBT_RAM;

ARCHITECTURE LinkedList OF ZBT_RAM IS
  CONSTANT D_width : INTEGER := D'LENGTH;
  CONSTANT A_width : INTEGER := A'LENGTH;

  TYPE mem_page_ptr_array IS ARRAY (0 TO D_width / 9 - 1) of mem_page_ptr;

  SIGNAL state, last_state : state_type := Deselect;
  SIGNAL operation         : state_type := Deselect;
  SIGNAL DOut              : STD_LOGIC_VECTOR (D_width - 1 DOWNTO 0) := (OTHERS => 'Z');
  SIGNAL A_delayed_1       : NATURAL;
  SIGNAL A_delayed_2       : NATURAL;
  SIGNAL BW_n_delayed_1    : STD_LOGIC_VECTOR (D_width / 9 - 1 DOWNTO 0);
  SIGNAL BW_n_delayed_2    : STD_LOGIC_VECTOR (D_width / 9 - 1 DOWNTO 0);
  SIGNAL ADV_delayed       : STD_LOGIC;
  SIGNAL sleep_count       : INTEGER RANGE 4 DOWNTO 0 := 0;
BEGIN
  ASSERT BW_n'LENGTH = D'LENGTH / 9
    REPORT "Error: BW_n'length must be equal to D'length / 9"
    SEVERITY FAILURE;

  mem_proc : PROCESS (Clk, dealloc_mem) IS
    VARIABLE state_v    : state_type;
    VARIABLE mem_page_v : mem_page_ptr_array;
    VARIABLE D_v        : STD_LOGIC_VECTOR (8 DOWNTO 0);
  BEGIN
    IF dealloc_mem THEN
      FOR i IN 0 TO D_width / 9 - 1 LOOP
        deallocate_mem (mem_page_v (i));
      END LOOP;
    ELSIF rising_edge (Clk) THEN
      IF (CKE_n = '0') THEN
        state_v   := calc_state (CS1_n, CS2, CS2_n, WE_n, BW_n, OE_n, ADV, ZZ, operation);
        operation <= calc_operation (state_v, operation);

        IF ((state_v = read) OR (state_v = dummy_read) OR (state_v = write)) THEN
          A_delayed_1 <= to_INTEGER (UNSIGNED (A));
        END IF;

        IF ((state_v = write) OR (state_v = write_continue)) THEN
          BW_n_delayed_1 <= BW_n;
        END IF;

        IF (state_v = invalid_state) THEN
          REPORT "Invalid state" SEVERITY ERROR;
        END IF;

        state          <= state_v;
        last_state     <= state;
        ADV_delayed    <= ADV;
        BW_n_delayed_2 <= BW_n_delayed_1;
      END IF;

      IF (ZZ = '1') THEN
        sleep_count <= 4;
      ELSIF (sleep_count > 0) THEN
        sleep_count <= sleep_count - 1;
      END IF;

      IF (sleep_count = 0) THEN
        IF (((state = write)      OR
             (state = read)       OR
             (state = dummy_read) OR
             (state = write_abort)) AND (CKE_n = '0')) THEN
          A_delayed_2 <= A_delayed_1;
        ELSIF (ADV_delayed = '1') AND (CKE_n = '0') THEN
          IF (A_delayed_2 MOD 4 < 3) THEN
            A_delayed_2 <= A_delayed_2 + 1;
          ELSE
            A_delayed_2 <= A_delayed_1;
          END IF;
        END IF;

        IF ((CKE_n = '0') AND (BW_n_delayed_2 /= (D_width / 9 - 1 DOWNTO 0 => '1')) AND 
            ((last_state = write) OR (last_state = write_continue))) THEN
          FOR i IN 0 TO D_width / 9 - 1 LOOP
            IF (BW_n_delayed_2 (i) = '0') THEN
              D_v := D (9 * (i + 1) - 1 DOWNTO 9 * i);
              rw_mem (data      => D_v,
                      addr      => A_delayed_2,
                      next_cell => mem_page_v (i),
                      operation => write);
              IF (Debug >= 1) THEN
                 REPORT ("DBG, " & TIME'IMAGE (now) & ": Write " & 
                   INTEGER'IMAGE (to_INTEGER (UNSIGNED (D_v))) & " to address=" &
                   INTEGER'IMAGE (A_delayed_2) & ", bank=" & INTEGER'IMAGE (i));
              END IF;
            END IF;
          END LOOP;
        END IF;
      ELSIF (sleep_count = 3) THEN
        A_delayed_2 <= 0;
      END IF;
    END IF;

    IF falling_edge (Clk) THEN
      IF (sleep_count = 0) THEN
        IF (CKE_n = '0') THEN
          IF ((last_state = read)      OR (last_state = read_continue) OR 
              (last_state = dummy_read) OR (last_state = dummy_read_continue)) THEN
            FOR i IN 0 TO D_width / 9 - 1 LOOP
              rw_mem (data      => D_v,
                      addr      => A_delayed_2,
                      next_cell => mem_page_v (i),
                      operation => read);
              DOut (9 * (i + 1) - 1 DOWNTO 9 * i) <= D_v;
              IF (Debug >= 2) THEN
                REPORT ("DBG, " & TIME'IMAGE (now) & ": Read " & 
                  INTEGER'IMAGE (to_INTEGER (UNSIGNED (D_v))) & " from address=" &
                  INTEGER'IMAGE (A_delayed_2) & ", bank=" & INTEGER'IMAGE (i));
              END IF;
            END LOOP;
          ELSE
             DOut <= (OTHERS => 'Z');
          END IF;
        END IF;
      ELSE
        DOut <= (OTHERS => 'Z');
      END IF;
    END IF;
  END PROCESS mem_proc;

  Q <= (Q'RANGE => 'Z') WHEN (OE_n = '1') ELSE DOut;
END LinkedList;
