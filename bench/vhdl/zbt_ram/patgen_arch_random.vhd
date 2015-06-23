----------------------------------------------------------------------
----                                                              ----
---- Test pattern generator for the                               ----
---- Synchronous static RAM ("Zero Bus Turnaround" RAM, ZBT RAM)  ----
---- simulation model.                                            ----
----                                                              ----
---- This file is part of the simu_mem project.                   ----
----                                                              ----
---- Description                                                  ----
---- This architecture generates a random pattern.                ----
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
ARCHITECTURE random OF patgen IS
  CONSTANT D_width : INTEGER := D'LENGTH;
  CONSTANT A_width : INTEGER := A'LENGTH;

  SIGNAL next_state           : state_type;
  SIGNAL state                : state_type;
  SIGNAL last_state           : state_type;
  SIGNAL next_operation       : state_type;
  SIGNAL operation            : state_type;
  SIGNAL want_sleep           : STD_LOGIC;
  SIGNAL want_sleep_delayed_1 : STD_LOGIC;
  SIGNAL want_sleep_delayed_2 : STD_LOGIC;
  SIGNAL ZZ_delayed_1         : STD_LOGIC;
BEGIN
  ASSERT A_width >= 5
    REPORT "Error: Address widths < 5 bits not supported by the test pattern generator"
    SEVERITY FAILURE;

  D <= (D_width - 1 DOWNTO 0 => 'L');

  next_state     <= calc_state (CS1_n, CS2, CS2_n, WE_n, BW_n, OE_n, ADV, ZZ, operation) WHEN (CKE_n = '0');
  next_operation <= calc_operation (next_state, operation);

  pPatternGenerator : PROCESS (Clk, Rst) IS
    VARIABLE random   : NATURAL;
    VARIABLE random_u : unsigned (31 DOWNTO 0);
    VARIABLE OE_n_v   : STD_LOGIC;
    VARIABLE WE_n_v   : STD_LOGIC;
    VARIABLE nWE_next_rising_edge : STD_LOGIC;
    VARIABLE ADV_v    : STD_LOGIC;
    VARIABLE CKE_n_v  : STD_LOGIC;
    VARIABLE nBW_v    : STD_LOGIC_VECTOR (D_width / 9 - 1 DOWNTO 0);
    VARIABLE nCS1_v   : STD_LOGIC;
    VARIABLE CS2_v    : STD_LOGIC;
    VARIABLE nCS2_v   : STD_LOGIC;
    VARIABLE ZZ_v     : STD_LOGIC;
    VARIABLE State_v  : state_type;
  BEGIN
    IF (Rst = '1') THEN
      random       := 1;
      WE_n_v       := '0';
      D            <= (D_width - 1 DOWNTO 0 => '0');
      A            <= (A_width - 1 DOWNTO 0 => '0');
      ADV          <= '0';
      WE_n         <= '0';
      CKE_n        <= '0';
      CS1_n        <= '0';
      CS2          <= '0';
      CS2_n        <= '0';
      CKE_n        <= '0';
      OE_n         <= '0';
      ZZ           <= '0';
      ZZ_delayed_1 <= '0';
      LBO_n        <= '0';
      BW_n         <= (D_width / 9 - 1 DOWNTO 0 => '0');
      last_state   <= Deselect;
      want_sleep   <= '0';
      want_sleep_delayed_1 <= '0';
      want_sleep_delayed_2 <= '0';
    ELSIF RISING_EDGE (Clk) THEN
      state     <= next_state;
      operation <= next_operation;

      IF ((WE_n_v = '1') OR (next_state = sleep) OR (state = sleep)) THEN
        WE_n <= '1' AFTER tWH;
      END IF;

      IF ((state = write) OR (state = write_continue)) THEN
        OE_n_v := '1';
      ELSE
        random := lcg (random);
        OE_n_v := TO_UNSIGNED (random, 32)(0);
      END IF;
      OE_n <= OE_n_v AFTER clk_periode - tOE;
    ELSIF FALLING_EDGE (Clk) THEN
      IF (Ena = '1') THEN
        random := lcg (random);
        IF ((state = sleep) OR (last_state = sleep)) THEN
          ADV_v := '0';
        ELSE
          ADV_v := TO_UNSIGNED (random, 32)(0);
        END IF;
        WE_n_v  := TO_UNSIGNED (random, 32)(1);
        CKE_n_v := TO_UNSIGNED (random, 32)(2);
        LBO_n   <= TO_UNSIGNED (random, 32)(3);
        nBW_v   := STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 3 DOWNTO 4));
        A       <= TO_UNSIGNED (random, 32)(8) & (A_width - 5 DOWNTO 0 => '0') & 
                   TO_UNSIGNED (random, 32)(9) & "00";

        IF (last_state = write) OR (last_state = write_continue) THEN
          random_vector (D, random);
        ELSE
          D <= (D_width - 1 DOWNTO 0 => 'Z');
        END IF;

        -- disable clock only about every 1024 cycles
        random   := lcg (random);
        random_u := TO_UNSIGNED (random, 32);
        CKE_n_v := random_u (0) AND random_u (1) AND random_u (2) AND random_u (3) AND random_u (4) AND 
                   random_u (5) AND random_u (6) AND random_u (7) AND random_u (8) AND random_u (9);

        -- deassert CS1_n only about every 1024 cycles
        random   := lcg (random);
        random_u := TO_UNSIGNED (random, 32);
        nCS1_v := random_u (0) AND random_u (1) AND random_u (2) AND random_u (3) AND random_u (4) AND 
                  random_u (5) AND random_u (6) AND random_u (7) AND random_u (8) AND random_u (9);

        -- deassert CS2 only about every 1024 cycles
        random   := lcg (random);
        random_u := TO_UNSIGNED (random, 32);
        CS2_v := random_u (0) OR random_u (1) OR random_u (2) OR random_u (3) OR random_u (4) OR 
                 random_u (5) OR random_u (6) OR random_u (7) OR random_u (8) OR random_u (9);

        -- deassert CS2_n only about every 1024 cycles
        random   := lcg (random);
        random_u := TO_UNSIGNED (random, 32);
        nCS2_v := random_u (0) AND random_u (1) AND random_u (2) AND random_u (3) AND random_u (4) AND 
                  random_u (5) AND random_u (6) AND random_u (7) AND random_u (8) AND random_u (9);

        -- put RAM in sleep mode only about every 1024 cycles
        random   := lcg (random);
        random_u := TO_UNSIGNED (random, 32);
        want_sleep <= random_u (0) AND random_u (1) AND random_u (2) AND random_u (3) AND random_u (4) AND 
                      random_u (5) AND random_u (6) AND random_u (7) AND random_u (8) AND random_u (9);
        want_sleep_delayed_1 <= want_sleep;
        want_sleep_delayed_2 <= want_sleep_delayed_1;
        ZZ_v := want_sleep_delayed_2;
        ZZ_delayed_1 <= ZZ;

        IF (WE_n = '0') AND (WE_n_v = '1') THEN
          nWE_next_rising_edge := '0';
        ELSE
          nWE_next_rising_edge := WE_n_v;
        END IF;

        State_v := calc_state (nCS1_v, CS2_v, nCS2_v, nWE_next_rising_edge, nBW_v, OE_n, ADV_v, 
          ZZ_v, operation);
        IF (State_v = invalid_state) THEN
          ADV_v := '0';
        END IF;

        State_v := calc_state (nCS1_v, CS2_v, nCS2_v, nWE_next_rising_edge, nBW_v, OE_n, ADV_v, 
          ZZ_v, operation);
        IF (State_v = invalid_state) THEN
          nBW_v (0) := '0';
        END IF;

        State_v := calc_state (nCS1_v, CS2_v, nCS2_v, nWE_next_rising_edge, nBW_v, OE_n, ADV_v, 
          ZZ_v, operation);
        IF (((want_sleep = '1') OR (want_sleep_delayed_1 = '1') OR (want_sleep_delayed_2 = '1')) AND 
            ((State_v = write) OR (State_v = write_continue))) THEN
          nCS1_v := '1';
          ADV_v  := '0';
        END IF;

        IF (((ZZ = '1') OR (ZZ_delayed_1 = '1')) AND 
            ((State_v = write))) THEN
          nCS1_v  := '0';
          CS2_v   := '1';
          nCS2_v  := '0';
          WE_n_v  := '1';
          ADV_v   := '0';
          OE_n_v  := '0';
          CKE_n_v := '0';
        END IF;

        ADV   <= ADV_v;
        CKE_n <= CKE_n_v;
        BW_n  <= nBW_v;
        CKE_n <= CKE_n_v;
        CS1_n <= nCS1_v;
        CS2   <= CS2_v;
        CS2_n <= nCS2_v;
        ZZ    <= ZZ_v;

        IF (WE_n_v = '0') THEN
          WE_n <= '0' AFTER clk_periode * 0.5 - tWS;
        END IF;

        IF (CKE_n = '0') THEN
          last_state <= state;
        END IF;
      END IF;
    END IF;
  END PROCESS pPatternGenerator;
END ARCHITECTURE random;
