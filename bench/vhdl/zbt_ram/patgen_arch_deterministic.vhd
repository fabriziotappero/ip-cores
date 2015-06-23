----------------------------------------------------------------------
----                                                              ----
---- Test pattern generator for the                               ----
---- Synchronous static RAM ("Zero Bus Turnaround" RAM, ZBT RAM)  ----
---- simulation model.                                            ----
----                                                              ----
---- This file is part of the simu_mem project.                   ----
----                                                              ----
---- Description                                                  ----
---- This architecture generates test patterns according to       ----
---- K7N643645M, 72Mb NtRAM Specification, Samsung, Rev. 1.3      ----
---- September 2008                                               ----
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
ARCHITECTURE deterministic OF patgen IS
  -- Patterns according to K7N643645M, 72Mb NtRAM Specification, Samsung, Rev. 1.3 September 2008

  CONSTANT D_width : INTEGER := D'LENGTH;
  CONSTANT A_width : INTEGER := A'LENGTH;
BEGIN
  pPatternGenerator : PROCESS IS
    VARIABLE random    : NATURAL;
    VARIABLE FirstTime : BOOLEAN := TRUE;
    VARIABLE WE_n_v    : STD_LOGIC;
  BEGIN
    -- initialisations
    random := 1;
    D      <= (D_width - 1 DOWNTO 0 => '0');
    A      <= (A_width - 1 DOWNTO 0 => '0');
    ADV    <= '0';
    WE_n   <= '0';
    CKE_n  <= '0';
    CS1_n  <= '0';
    CS2    <= '0';
    CS2_n  <= '0';
    CKE_n  <= '0';
    OE_n   <= '0';
    ZZ     <= '0';
    LBO_n  <= '0';
    BW_n   <= (D_width / 9 - 1 DOWNTO 0 => '0');

    IF FirstTime THEN
      WAIT UNTIL (Rst = '0');
      FirstTime := FALSE;
    END IF;

    ---------------------------------------------------------------------------------------------
    -- Pattern according to "Timing waveform of write cycle", page 20
    ---------------------------------------------------------------------------------------------
    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A10#, A_width));
    CS2    <= '1';
    D      <= (D_width - 1 DOWNTO 0 => 'Z');

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    CS1_n  <= '1';
    random := lcg (random);
    CS2    <= TO_UNSIGNED (random, 32)(0);
    CS2_n  <= TO_UNSIGNED (random, 32)(1);
    WE_n   <= TO_UNSIGNED (random, 32)(2);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));

    OE_n   <= '1' AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A20#, A_width));
    WE_n   <= '0';
    BW_n   <= (D_width / 9 - 1 DOWNTO 0 => '0');
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D11#, D_width));

    random := lcg (random);
    OE_n   <= TO_UNSIGNED (random, 32)(0) AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    ADV    <= '1';
    random_vector (D, random);

    random := lcg (random);
    OE_n   <= TO_UNSIGNED (random, 32)(0) AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D21#, D_width));

    random := lcg (random);
    OE_n   <= TO_UNSIGNED (random, 32)(0) AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D22#, D_width));

    random := lcg (random);
    OE_n   <= TO_UNSIGNED (random, 32)(0) AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '1';
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    ADV    <= TO_UNSIGNED (random, 32)(3);
    WE_n   <= TO_UNSIGNED (random, 32)(4);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 4 DOWNTO 5));
    random_vector (D, random);

    random := lcg (random);
    OE_n   <= TO_UNSIGNED (random, 32)(0) AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '0';
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A30#, A_width));
    WE_n   <= '0';
    BW_n   <= (D_width / 9 - 1 DOWNTO 0 => '0');
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    ADV    <= '0';
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D23#, D_width));

    random := lcg (random);
    OE_n   <= TO_UNSIGNED (random, 32)(0) AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    ADV    <= '1';
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D24#, D_width));

    random := lcg (random);
    OE_n   <= TO_UNSIGNED (random, 32)(0) AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D31#, D_width));

    random := lcg (random);
    OE_n   <= TO_UNSIGNED (random, 32)(0) AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D32#, D_width));

    random := lcg (random);
    OE_n   <= TO_UNSIGNED (random, 32)(0) AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    ADV    <= TO_UNSIGNED (random, 32)(3);
    WE_n   <= TO_UNSIGNED (random, 32)(4);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 4 DOWNTO 5));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D33#, D_width));

    random := lcg (random);
    OE_n   <= TO_UNSIGNED (random, 32)(0) AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    ADV    <= TO_UNSIGNED (random, 32)(3);
    WE_n   <= TO_UNSIGNED (random, 32)(4);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 4 DOWNTO 5));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D34#, D_width));

    ---------------------------------------------------------------------------------------------
    -- Pattern according to "Timing waveform of read cycle", page 19
    ---------------------------------------------------------------------------------------------
    OE_n   <= '1' AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '0';
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A10#, A_width));
    WE_n   <= '1';
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    ADV    <= '0';
    random_vector (D, random);

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    CS1_n  <= '1';
    random := lcg (random);
    CS2    <= TO_UNSIGNED (random, 32)(0);
    CS2_n  <= TO_UNSIGNED (random, 32)(1);
    WE_n   <= TO_UNSIGNED (random, 32)(2);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));
    D      <= (D_width - 1 DOWNTO 0 => 'Z');

    OE_n   <= '0' AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A20#, A_width));
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    WE_n   <= '1';
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));

    OE_n   <= '1' AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    WE_n   <= TO_UNSIGNED (random, 32)(3);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 3 DOWNTO 4));
    ADV    <= '1';

    OE_n   <= '0' AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    WE_n   <= TO_UNSIGNED (random, 32)(3);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 3 DOWNTO 4));

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    WE_n   <= TO_UNSIGNED (random, 32)(3);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 3 DOWNTO 4));

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '1';
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    ADV    <= TO_UNSIGNED (random, 32)(3);
    WE_n   <= TO_UNSIGNED (random, 32)(4);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 4 DOWNTO 5));

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '0';
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A30#, A_width));
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    ADV    <= '0';
    random := lcg (random);
    WE_n   <= '1';
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    WE_n   <= TO_UNSIGNED (random, 32)(3);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 3 DOWNTO 4));
    ADV    <= '1';

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    WE_n   <= TO_UNSIGNED (random, 32)(3);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 3 DOWNTO 4));

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    WE_n   <= TO_UNSIGNED (random, 32)(3);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 3 DOWNTO 4));

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    CS1_n  <= '1';
    random := lcg (random);
    CS2    <= TO_UNSIGNED (random, 32)(0);
    CS2_n  <= TO_UNSIGNED (random, 32)(1);
    WE_n   <= TO_UNSIGNED (random, 32)(2);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));
    ADV    <= '0';

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(1);
    CS2    <= TO_UNSIGNED (random, 32)(2);
    CS2_n  <= TO_UNSIGNED (random, 32)(3);
    ADV    <= TO_UNSIGNED (random, 32)(4);
    WE_n   <= TO_UNSIGNED (random, 32)(5);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 5 DOWNTO 6));

    ---------------------------------------------------------------------------------------------
    -- write values to 0xA40, 0xA50, 0xA60, 0xA70, 0xA80 and 0xA90
    ---------------------------------------------------------------------------------------------
    OE_n   <= '1' AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A40#, A_width));
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    WE_n   <= '0';
    BW_n   <= (D_width / 9 - 1 DOWNTO 0 => '0');
    ADV    <= '0';

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A50#, A_width));

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A60#, A_width));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D4#, D_width));

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A70#, A_width));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D5#, D_width));

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A80#, A_width));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D6#, D_width));

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A90#, A_width));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D7#, D_width));

    WAIT UNTIL FALLING_EDGE (Clk);
    random := lcg (random);
    WE_n   <= '1';
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D8#, D_width));

    WAIT UNTIL FALLING_EDGE (Clk);
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D9#, D_width));

    ---------------------------------------------------------------------------------------------
    -- Pattern according to "Timing waveform of single read/write", page 21
    ---------------------------------------------------------------------------------------------
    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A10#, A_width));
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    ADV    <= '0';
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A20#, A_width));
    WE_n   <= '0';
    BW_n   <= (D_width / 9 - 1 DOWNTO 0 => '0');

    OE_n   <= '0' AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A30#, A_width));
    WE_n   <= '1';
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    CS1_n  <= '1';
    random := lcg (random);
    CS2    <= TO_UNSIGNED (random, 32)(0);
    CS2_n  <= TO_UNSIGNED (random, 32)(1);
    WE_n   <= TO_UNSIGNED (random, 32)(2);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D2#, D_width));

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A40#, A_width));
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    WE_n   <= '1';
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));
    D      <= (D_width - 1 DOWNTO 0 => 'Z');

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A50#, A_width));
    WE_n   <= '0';
    BW_n   <= (D_width / 9 - 1 DOWNTO 0 => '0');

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A60#, A_width));
    WE_n   <= '1';
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A70#, A_width));
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D5#, D_width));

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '1';
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    ADV    <= TO_UNSIGNED (random, 32)(3);
    WE_n   <= TO_UNSIGNED (random, 32)(4);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 4 DOWNTO 5));
    D      <= (D_width - 1 DOWNTO 0 => 'Z');

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '0';
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A80#, A_width));
    WE_n   <= '0';
    BW_n   <= (D_width / 9 - 1 DOWNTO 0 => '0');
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    ADV    <= '0';

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A90#, A_width));

    ---------------------------------------------------------------------------------------------
    -- Pattern according to "Timing waveform of CKE_n operation", page 22
    ---------------------------------------------------------------------------------------------
    OE_n   <= '1' AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A10#, A_width));
    WE_n   <= '1';
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));

    OE_n   <= '0' AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '1';
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    ADV    <= TO_UNSIGNED (random, 32)(3);
    WE_n   <= TO_UNSIGNED (random, 32)(4);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 4 DOWNTO 5));

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '0';
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A20#, A_width));
    WE_n   <= '0';
    BW_n   <= (D_width / 9 - 1 DOWNTO 0 => '0');
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    ADV    <= '0';

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '1';
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    ADV    <= TO_UNSIGNED (random, 32)(3);
    WE_n   <= TO_UNSIGNED (random, 32)(4);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 4 DOWNTO 5));

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '0';
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A30#, A_width));
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    ADV    <= '0';
    WE_n   <= '1';
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '1';
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    ADV    <= TO_UNSIGNED (random, 32)(3);
    WE_n   <= TO_UNSIGNED (random, 32)(4);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 4 DOWNTO 5));

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '1';
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    ADV    <= TO_UNSIGNED (random, 32)(3);
    WE_n   <= TO_UNSIGNED (random, 32)(4);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 4 DOWNTO 5));

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '0';
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A40#, A_width));
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    ADV    <= '0';
    WE_n   <= '1';
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D2#, D_width));

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '1';
    random_vector (A, random);
    random := lcg (random);
    CS1_n  <= TO_UNSIGNED (random, 32)(0);
    CS2    <= TO_UNSIGNED (random, 32)(1);
    CS2_n  <= TO_UNSIGNED (random, 32)(2);
    ADV    <= TO_UNSIGNED (random, 32)(3);
    WE_n   <= TO_UNSIGNED (random, 32)(4);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 4 DOWNTO 5));
    D      <= (D_width - 1 DOWNTO 0 => 'Z');

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '0';
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A50#, A_width));
    WE_n   <= '0';
    BW_n   <= (D_width / 9 - 1 DOWNTO 0 => '0');
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    ADV    <= '0';

    WAIT UNTIL FALLING_EDGE (Clk);
    CKE_n  <= '0';
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A60#, A_width));
    BW_n   <= (D_width / 9 - 1 DOWNTO 0 => '0');

    ---------------------------------------------------------------------------------------------
    -- Pattern according to "Timing waveform of nCS operation", page 23
    ---------------------------------------------------------------------------------------------
    OE_n   <= '1' AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A10#, A_width));
    WE_n   <= '1';
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A20#, A_width));
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));

    OE_n   <= '0' AFTER clk_periode * 1.5 - tOE;
    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    CS1_n  <= '1';
    random := lcg (random);
    CS2    <= TO_UNSIGNED (random, 32)(0);
    CS2_n  <= TO_UNSIGNED (random, 32)(1);
    WE_n   <= TO_UNSIGNED (random, 32)(2);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A30#, A_width));
    WE_n   <= '0';
    BW_n   <= (D_width / 9 - 1 DOWNTO 0 => '0');
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    CS1_n  <= '1';
    random := lcg (random);
    CS2    <= TO_UNSIGNED (random, 32)(0);
    CS2_n  <= TO_UNSIGNED (random, 32)(1);
    WE_n   <= TO_UNSIGNED (random, 32)(2);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));

    WAIT UNTIL RISING_EDGE (Clk);
    WE_n   <= '1' AFTER tWH;
    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A40#, A_width));
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';
    random := lcg (random);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 - 1 DOWNTO 0));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D3#, D_width));

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    CS1_n  <= '1';
    random := lcg (random);
    CS2    <= TO_UNSIGNED (random, 32)(0);
    CS2_n  <= TO_UNSIGNED (random, 32)(1);
    WE_n   <= TO_UNSIGNED (random, 32)(2);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));
    D      <= (D_width - 1 DOWNTO 0 => 'Z');

    WAIT UNTIL FALLING_EDGE (Clk);
    A      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#A50#, A_width));
    WE_n   <= '0';
    BW_n   <= (D_width / 9 - 1 DOWNTO 0 => '0');
    CS1_n  <= '0';
    CS2    <= '1';
    CS2_n  <= '0';

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    CS1_n  <= '1';
    random := lcg (random);
    CS2    <= TO_UNSIGNED (random, 32)(0);
    CS2_n  <= TO_UNSIGNED (random, 32)(1);
    WE_n   <= TO_UNSIGNED (random, 32)(2);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS2    <= TO_UNSIGNED (random, 32)(0);
    CS2_n  <= TO_UNSIGNED (random, 32)(1);
    WE_n   <= TO_UNSIGNED (random, 32)(2);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));
    D      <= STD_LOGIC_VECTOR (TO_UNSIGNED (16#D5#, D_width));

    WAIT UNTIL FALLING_EDGE (Clk);
    random_vector (A, random);
    random := lcg (random);
    CS2    <= TO_UNSIGNED (random, 32)(0);
    CS2_n  <= TO_UNSIGNED (random, 32)(1);
    WE_n   <= TO_UNSIGNED (random, 32)(2);
    BW_n   <= STD_LOGIC_VECTOR (TO_UNSIGNED (random, 32)(D_width / 9 + 2 DOWNTO 3));
    D      <= (D_width - 1 DOWNTO 0 => 'Z');

    WAIT UNTIL FALLING_EDGE (Clk);
  END PROCESS pPatternGenerator;
END ARCHITECTURE deterministic;
