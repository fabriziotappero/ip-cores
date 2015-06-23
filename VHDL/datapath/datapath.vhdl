-- Copyright 2015, Jürgen Defurne
--
-- This file is part of the Experimental Unstable CPU System.
--
-- The Experimental Unstable CPU System Is free software: you can redistribute
-- it and/or modify it under the terms of the GNU Lesser General Public License
-- as published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- The Experimental Unstable CPU System is distributed in the hope that it will
-- be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
-- General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with Experimental Unstable CPU System. If not, see
-- http://www.gnu.org/licenses/lgpl.txt.


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.components.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY dp IS
  GENERIC (
    w_data : NATURAL := 16;
    w_regn : NATURAL := 5);
  PORT (reset     : IN  STD_LOGIC;
        clock     : IN  STD_LOGIC;
        reg_a     : IN  STD_LOGIC_VECTOR(w_regn - 1 DOWNTO 0);
        reg_b     : IN  STD_LOGIC_VECTOR(w_regn - 1 DOWNTO 0);
        reg_input : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        op_sel    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        we        : IN  STD_LOGIC;
        pc_input  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        pc_load   : IN  STD_LOGIC;
        dr_load   : IN  STD_LOGIC;
        ar_load   : IN  STD_LOGIC;
        aa_load   : IN  STD_LOGIC;
        ab_load   : IN  STD_LOGIC;
        addr_sel  : IN  STD_LOGIC;
        zero      : OUT STD_LOGIC;
        n_zero    : OUT STD_LOGIC;
        data_in   : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
        data_out  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
        addr_out  : OUT STD_LOGIC_VECTOR(w_data - 2 DOWNTO 0));
END dp;

ARCHITECTURE Behavioral OF dp IS

  CONSTANT zero_reg : UNSIGNED(w_data - 1 DOWNTO 0) := (OTHERS => '0');
  CONSTANT zero_add : UNSIGNED(w_data - 2 DOWNTO 0) := (OTHERS => '0');
  CONSTANT zero_pc  : UNSIGNED(63 DOWNTO 0)         := X"0000000000007FFE";

  TYPE register_array IS ARRAY(0 TO (2**w_regn) - 1) OF UNSIGNED(w_data - 1 DOWNTO 0);

  SIGNAL reg_data      : UNSIGNED(w_data - 1 DOWNTO 0);
  SIGNAL register_file : register_array;
  SIGNAL a_out, b_out  : UNSIGNED(w_data - 1 DOWNTO 0);
  SIGNAL y             : UNSIGNED(w_data - 1 DOWNTO 0);

  SIGNAL pc           : UNSIGNED(w_data - 2 DOWNTO 0);
  SIGNAL addr_out_reg : UNSIGNED(w_data - 2 DOWNTO 0);
  SIGNAL data_out_reg : UNSIGNED(w_data - 1 DOWNTO 0);
  SIGNAL a, b         : UNSIGNED(w_data - 1 DOWNTO 0);
  SIGNAL pc_sum       : UNSIGNED(w_data - 2 DOWNTO 0);
  SIGNAL pc_data      : UNSIGNED(w_data - 2 DOWNTO 0);

BEGIN

  -----------------------------------------------------------------------------
  -- Register input multiplexer
  -----------------------------------------------------------------------------
  -- The last bit of the multiplexer must be generated so that
  -- I1 => '0', because addresses are 15 bit.
  reg_mux :
  FOR i IN w_data - 1 DOWNTO 0 GENERATE
    cond_1 : IF i < (w_data - 1) GENERATE
      MUX : LUT6
        GENERIC MAP (INIT => X"FF00F0F0CCCCAAAA")
        PORT MAP(I0 => data_in(i),
                 I1 => pc(i),
                 I2 => y(i),
                 I3 => b_out(i),
                 I4 => reg_input(0),
                 I5 => reg_input(1),
                 O  => reg_data(i));
    END GENERATE cond_1;
    cond_2 : IF i = (w_data - 1) GENERATE
      MUX : LUT6
        GENERIC MAP (INIT => X"FF00F0F0CCCCAAAA")
        PORT MAP(I0 => data_in(i),
                 I1 => '0',
                 I2 => y(i),
                 I3 => b_out(i),
                 I4 => reg_input(0),
                 I5 => reg_input(1),
                 O  => reg_data(i));
    END GENERATE cond_2;
  END GENERATE reg_mux;

  -------------------------------------------------------------------------------
  ---- Data register processes
  -------------------------------------------------------------------------------

  -- purpose: This is the writing to the register file
  -- type   : sequential
  -- inputs : clock, reg_c
  -- outputs: register_file
  reg : PROCESS (clock)
  BEGIN  -- PROCESS reg
    IF rising_edge(clock) THEN          -- rising clock edge

      IF we = '1' THEN
        register_file(to_integer(UNSIGNED(reg_a))) <= reg_data;
      ELSE
        register_file(to_integer(UNSIGNED(reg_a))) <= register_file(to_integer(UNSIGNED(reg_a)));
      END IF;

    END IF;
  END PROCESS reg;

  -- purpose: Get contents of registers onto intermediate buses
  -- type   : combinational
  -- inputs : reg_a,reg_b
  -- outputs: a_out,b_bout
  reg_outputs : PROCESS (reg_a, reg_b, register_file)
  BEGIN  -- PROCESS reg_outputs
    a_out <= register_file(to_integer(UNSIGNED(reg_a)));
    b_out <= register_file(to_integer(UNSIGNED(reg_b)));
  END PROCESS reg_outputs;

  --REG1 : registers PORT MAP (
  --  reset    => reset,
  --  clock    => clock,
  --  reg_a    => reg_a,
  --  reg_b    => reg_b,
  --  we       => we,
  --  reg_data => reg_data,
  --  a_out    => a_out,
  --  b_out    => b_out);

  -- purpose: Put outputs of register into pipeline registers
  -- type   : sequential
  -- inputs : clock,reset,a_out,b_out,aa_load,ab_load,dr_load,ar_load
  -- outputs: a,b
  pipeline_to_alu : PROCESS (clock, reset)
  BEGIN  -- PROCESS pipeline_to_alu
    IF reset = '0' THEN
      a            <= zero_reg;
      b            <= zero_reg;
      data_out_reg <= zero_reg;
      addr_out_reg <= zero_add;
    ELSIF rising_edge(clock) THEN       -- rising clock edge

      IF a_out = zero_reg THEN
        zero   <= '1';
        n_zero <= '0';
      ELSE
        zero   <= '0';
        n_zero <= '1';
      END IF;

      IF aa_load = '1' THEN
        a <= a_out;
      ELSE
        a <= a;
      END IF;

      IF ab_load = '1' THEN
        b <= b_out;
      ELSE
        b <= b;
      END IF;

      IF dr_load = '1' THEN
        data_out_reg <= a_out;
      ELSE
        data_out_reg <= data_out_reg;
      END IF;

      IF ar_load = '1' THEN
        addr_out_reg <= b_out(w_data - 2 DOWNTO 0);
      ELSE
        addr_out_reg <= addr_out_reg;
      END IF;
    END IF;
  END PROCESS pipeline_to_alu;

  data_out <= STD_LOGIC_VECTOR(data_out_reg);

  -- purpose: simple ALU
  -- type   : combinational
  -- inputs : clock, reset, a, b, op_sel
  -- outputs: y
  alu : PROCESS (clock, reset)
  BEGIN  -- PROCESS alu

    IF reset = '0' THEN
      y <= X"0000";
    ELSIF rising_edge(clock) THEN
      CASE op_sel IS
        WHEN "0000" =>                  -- increment
          y <= a + 1;
        WHEN "0001" =>                  -- decrement
          y <= a - 1;
        WHEN "0010" =>                  -- test for zero
          y <= a;
        WHEN "0111" =>                  -- addition
          y <= a + b;
        WHEN "1000" =>                  -- subtract, compare
          y <= a - b;
        WHEN "1010" =>                  -- logical and
          y <= a AND b;
        WHEN "1011" =>                  -- logical or
          y <= a OR b;
        WHEN "1100" =>                  -- logical xor
          y <= a XOR b;
        WHEN "1101" =>                  -- logical not
          y <= NOT a;
        WHEN "1110" =>                  -- shift left logical
          y <= a SLL 1;
        WHEN "1111" =>                  -- shift right logical
          y <= a SRL 1;
        WHEN OTHERS =>
          y <= y;
      END CASE;
    END IF;
  END PROCESS alu;

  -----------------------------------------------------------------------------
  -- Program counter input multiplexer
  -----------------------------------------------------------------------------
  pc_mux :
  FOR i IN w_data - 2 DOWNTO 0 GENERATE
    MUX : LUT6
      GENERIC MAP (INIT => X"FF00F0F0CCCCAAAA")
      PORT MAP(I0 => pc_sum(i),
               I1 => data_in(i),
               I2 => a_out(i),
               I3 => '0',
               I4 => pc_input(0),
               I5 => pc_input(1),
               O  => pc_data(i));
  END GENERATE pc_mux;

  -----------------------------------------------------------------------------
  -- Address path processes
  -----------------------------------------------------------------------------

  pc_register : PROCESS (clock, reset)
  BEGIN  -- PROCESS adder_based
    IF reset = '0' THEN
      pc <= zero_pc(w_data - 2 DOWNTO 0);
    ELSIF rising_edge(clock) THEN
      IF pc_load = '1' THEN
        pc <= pc_data;
      ELSE
        pc <= pc;
      END IF;
    END IF;
  END PROCESS pc_register;

  -- purpose: Add 1 to address output
  -- type   : combinational
  -- inputs : pc
  -- outputs: address_sum
  adder : PROCESS (pc)
  BEGIN  -- PROCESS adder
    pc_sum <= pc + 1;
  END PROCESS adder;

  -----------------------------------------------------------------------------
  -- Address selection logic
  -----------------------------------------------------------------------------

  addr_mux :
  FOR i IN w_data - 2 DOWNTO 0 GENERATE
    MUX : LUT6
      GENERIC MAP (INIT => X"FF00F0F0CCCCAAAA")
      PORT MAP(I0 => pc(i),
               I1 => addr_out_reg(i),
               I2 => '0',
               I3 => '0',
               I4 => addr_sel,
               I5 => '0',
               O  => addr_out(i));
  END GENERATE addr_mux;

END Behavioral;

