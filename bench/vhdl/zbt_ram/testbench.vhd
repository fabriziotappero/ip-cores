----------------------------------------------------------------------
----                                                              ----
---- Testbench for the ZBT_RAM simulation model                   ----
----                                                              ----
---- This file is part of the simu_mem project                    ----
----                                                              ----
---- Description                                                  ----
---- This testbench checks if the output of the simulation model  ----
---- matches the output of the reference model. Every mismatch    ----
---- prints an error message.                                     ----
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
LIBRARY ieee, RAM, samsung;
USE ieee.std_logic_1164.ALL; 
USE work.patgen_pkg.ALL;

ENTITY testbench IS
  GENERIC (
    -- Address bus width
    A_width : POSITIVE := 21;
    -- Data bus width
    D_width : POSITIVE := 36;

    -- How many clock cycles shall be simulated?
    N_simulation_cycles : POSITIVE := 100000);
END ENTITY testbench;

ARCHITECTURE arch OF testbench IS
  CONSTANT clk_periode : TIME :=   4 ns;
  CONSTANT reset_time  : TIME := 100 ns;

  SIGNAL Clk, Rst : STD_LOGIC;
  SIGNAL clk_ena  : STD_LOGIC := '1';
  SIGNAL Count    : INTEGER;

  SIGNAL A            : STD_LOGIC_VECTOR (A_width - 1 DOWNTO 0);
  SIGNAL D_DUT        : STD_LOGIC_VECTOR (D_width - 1 DOWNTO 0);
  SIGNAL D_Reference  : STD_LOGIC_VECTOR (D_width - 1 DOWNTO 0);
  SIGNAL D_Patgen     : STD_LOGIC_VECTOR (D_width - 1 DOWNTO 0);
  SIGNAL ADV          : STD_LOGIC;
  SIGNAL WE_n         : STD_LOGIC;
  SIGNAL CKE_n        : STD_LOGIC;
  SIGNAL CS1_n        : STD_LOGIC;
  SIGNAL CS2          : STD_LOGIC;
  SIGNAL CS2_n        : STD_LOGIC;
  SIGNAL BW_n         : STD_LOGIC_VECTOR (D_width / 9 - 1 DOWNTO 0);
  SIGNAL OE_n         : STD_LOGIC;
  SIGNAL ZZ           : STD_LOGIC;
  SIGNAL LBO_n        : STD_LOGIC;
  SIGNAL ZZ_delayed_1 : STD_LOGIC;
  SIGNAL ZZ_delayed_2 : STD_LOGIC;
BEGIN
  ASSERT D_width mod 9 = 0
    REPORT "Error: D_width must be a multiple of 9"
    SEVERITY FAILURE;

  iDUT : ENTITY RAM.ZBT_RAM
    GENERIC MAP (
      Debug => 0)
    PORT MAP (
      Clk   => Clk,
      D     => D_DUT,
      Q     => D_DUT,
      A     => A,
      CKE_n => CKE_n,
      CS1_n => CS1_n,
      CS2   => CS2,
      CS2_n => CS2_n,
      WE_n  => WE_n,
      BW_n  => BW_n,
      OE_n  => OE_n,
      ADV   => ADV,
      ZZ    => ZZ,
      LBO_n => LBO_n);

  iReference : ENTITY Samsung.K7N643645M
    PORT MAP (
      Dq    => D_Reference,
      Addr  => A,
      K     => Clk,
      CKEb  => CKE_n,
      Bwa_n => BW_n (0),
      Bwb_n => BW_n (1),
      Bwc_n => BW_n (2),
      Bwd_n => BW_n (3),
      WEb   => WE_n,
      ADV   => ADV,
      OEb   => OE_n,
      CS1b  => CS1_n,
      CS2   => CS2,
      CS2b  => CS2_n,
      LBOb  => LBO_n,
      ZZ    => ZZ);

  pCheck : PROCESS (Rst, Clk) IS
  BEGIN
    IF (Rst = '0') AND rising_edge (Clk) THEN
      FOR BankNoMinus1 in 0 to D_width / 9 - 1 LOOP
        IF (ZZ_delayed_2 = '0') THEN
          IF ((D_DUT (      9 * (BankNoMinus1 + 1) - 1 DOWNTO 9 * BankNoMinus1) /= (8 DOWNTO 0 => 'U')) OR
              (D_Reference (9 * (BankNoMinus1 + 1) - 1 DOWNTO 9 * BankNoMinus1) /= (8 DOWNTO 0 => 'X'))) THEN
            ASSERT D_DUT (      9 * (BankNoMinus1 + 1) - 1 DOWNTO 9 * BankNoMinus1) = 
                   D_Reference (9 * (BankNoMinus1 + 1) - 1 DOWNTO 9 * BankNoMinus1)
              REPORT "Error: DUT and reference model mismatch in Bank no " & 
                INTEGER'IMAGE (BankNoMinus1)
              SEVERITY ERROR;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END PROCESS pCheck;

  iPatgen : patgen
    GENERIC MAP (
      clk_periode => clk_periode)
    PORT MAP (
      Clk   => Clk,
      Rst   => Rst,
      Ena   => clk_ena,
      A     => A,
      D     => D_Patgen,
      CKE_n => CKE_n,
      CS1_n => CS1_n,
      CS2   => CS2,
      CS2_n => CS2_n,
      WE_n  => WE_n,
      BW_n  => BW_n,
      OE_n  => OE_n,
      ADV   => ADV,
      ZZ    => ZZ,
      LBO_n => LBO_n);

  D_DUT       <= D_Patgen;
  D_Reference <= D_Patgen;

  pClk : PROCESS IS
  BEGIN
    Rst <= '1';
    Clk <= '1';
    WAIT FOR reset_time;
    Rst <= '0';

    WHILE (clk_ena = '1') LOOP
      WAIT FOR clk_periode / 2;
      Clk <= NOT Clk;
    END LOOP;

    WAIT;
  END PROCESS pClk;

  pCounter : PROCESS (Clk, Rst) IS
  BEGIN
    IF (Rst = '1') THEN
      Count  <= 0;
      clk_ena <= '1';
      ZZ_delayed_1   <= '0';
      ZZ_delayed_2   <= '0';
    ELSIF rising_edge (Clk) THEN
      IF (Count < N_simulation_cycles) THEN
        Count <= Count + 1;
      ELSE
        clk_ena <= '0';
      END IF;

      ZZ_delayed_1 <= ZZ;
      ZZ_delayed_2 <= ZZ_delayed_1;
    END IF;
  END PROCESS pCounter;
END ARCHITECTURE;
