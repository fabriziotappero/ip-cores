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
USE IEEE.numeric_std.ALL;
USE work.components.ALL;
USE work.ram_parts.ALL;
USE work.mux_parts.ALL;
USE work.controllers.ALL;

-- LIBRARY unisim;
-- USE unisim.vcomponents.ALL;

ENTITY system IS
  PORT (
    clock     : IN  STD_LOGIC;
    reset     : IN  STD_LOGIC;
    led_out   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    switch_in : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    pushb_in  : IN  STD_LOGIC_VECTOR(4 DOWNTO 0));
END system;

ARCHITECTURE Structural OF system IS

  CONSTANT w_data : POSITIVE := 16;

  SIGNAL CLK     : STD_LOGIC;           -- System clock
  SIGNAL CLK_VAL : STD_LOGIC;           -- System clock valid
  SIGNAL RST     : STD_LOGIC;           -- System synchronous reset

  -- All signals for the instruction and data processing
  -- Ordered in proper bundles per pipeline stage

  -- First stage in the instruction pipeline is the program counter circuitry
  SIGNAL PC_SRC  : STD_LOGIC_VECTOR(2 DOWNTO 0)  := "000";
  SIGNAL LD_PC   : STD_LOGIC                     := '0';
  SIGNAL PC_INC  : STD_LOGIC_VECTOR(14 DOWNTO 0) := "000000000000000";
  SIGNAL PC_NEXT : STD_LOGIC_VECTOR(14 DOWNTO 0) := "000000000000000";

  -- The second stage in the instruction pipeline is the memory, followed by
  -- the instruction queue.
  SIGNAL LD_IR  : STD_LOGIC := '0';
  SIGNAL LD_DP  : STD_LOGIC := '0';
  SIGNAL LD_REG : STD_LOGIC := '0';

  SIGNAL RFA_A  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
  SIGNAL RFA_B  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
  SIGNAL ALU_OP : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";

  SIGNAL REG_SRC      : STD_LOGIC_VECTOR(2 DOWNTO 0)  := "111";
  SIGNAL DATABUS_READ : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
  SIGNAL INSTR_OUT    : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";

  SIGNAL REG_WR  : STD_LOGIC                     := '1';
  SIGNAL REG_BUS : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
  SIGNAL A_OUT   : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
  SIGNAL B_OUT   : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";

  SIGNAL LD_REG_A : STD_LOGIC;
  SIGNAL LD_REG_B : STD_LOGIC;
  SIGNAL LD_MAR   : STD_LOGIC;
  SIGNAL LD_MDR   : STD_LOGIC;

  SIGNAL QA      : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
  SIGNAL QB      : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
  SIGNAL ALU_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";

  SIGNAL DATA_ADDRESS  : STD_LOGIC_VECTOR(14 DOWNTO 0) := "000000000000000";
  SIGNAL DATABUS_WRITE : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";

  SIGNAL DOSEL : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
  SIGNAL EOUT1 : STD_LOGIC;
  SIGNAL EIN1  : STD_LOGIC;
  SIGNAL EIN2  : STD_LOGIC;

  SIGNAL MEM_WR    : STD_LOGIC                     := '1';
  SIGNAL PC_OUT    : STD_LOGIC_VECTOR(14 DOWNTO 0) := "000000000000000";
  SIGNAL PC_TO_REG : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";

  SIGNAL DO1   : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
  SIGNAL DO2   : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
  SIGNAL DO3   : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
  SIGNAL MEMO4 : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
  SIGNAL INSO4 : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
  SIGNAL INSTR : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
  SIGNAL IMMED : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";

  SIGNAL I_ZERO : STD_LOGIC;
  SIGNAL ZERO   : STD_LOGIC;
  SIGNAL INT    : STD_LOGIC;

BEGIN

  -- Clock generator with selectable speed and reset
  CLOCK1 : clock_gen
    PORT MAP (
      CLK_IN    => CLOCK,
      RESET     => RESET,
      CLK_VALID => CLK_VAL,
      CLK_OUT   => CLK);

  -- Synchronous reset
  RST1 : sync_reset
    PORT MAP (
      ASYNC_RST => RESET,
      CLK       => CLK,
      CLK_VALID => CLK_VAL,
      RST       => RST);

  PC_TO_REG <= '0' & PC_OUT;

  -- Input multiplexer to register file
  REG_MUX : mux8to1
    PORT MAP (
      SEL => REG_SRC,
      S0  => ALU_OUT,                   -- "000"
      S1  => DATABUS_READ,              -- "001"
      S2  => IMMED,                     -- "010"
      S3  => PC_TO_REG,                 -- "011"
      S4  => A_OUT,                     -- "100"
      S5  => STD_LOGIC_VECTOR(TO_UNSIGNED(0, w_data)),
      S6  => STD_LOGIC_VECTOR(TO_UNSIGNED(0, w_data)),
      S7  => STD_LOGIC_VECTOR(TO_UNSIGNED(0, w_data)),
      Y   => REG_BUS);

  -- True if A output of register file is zero
  Z1 : zerof
    PORT MAP (
      A    => A_OUT,
      zero => I_ZERO);

  PROCESS(CLK)
  BEGIN
    IF rising_edge(CLK) THEN
      ZERO <= I_ZERO;
    END IF;
  END PROCESS;

  -- 16-register register file
  RF1 : regf
    PORT MAP (
      CLK => CLK,
      we  => REG_WR,
      a1  => RFA_A,
      a2  => RFA_B,
      d   => REG_BUS,
      q1  => A_OUT,
      q2  => B_OUT);

  -- Register A output of register file
  REGA : data_reg
    PORT MAP (
      RST => RST,
      CLK => CLK,
      ENA => LD_REG_A,
      D   => A_OUT,
      Q   => QA);

  -- Register B output of register file
  REGB : data_reg
    PORT MAP (
      RST => RST,
      CLK => CLK,
      ENA => LD_REG_B,
      D   => B_OUT,
      Q   => QB);

  -- Memory address register from B output
  MAR : data_reg
    GENERIC MAP (
      w_data => 15)
    PORT MAP (
      RST => RST,
      CLK => CLK,
      ENA => LD_MAR,
      D   => B_OUT(14 DOWNTO Q),
      Q   => DATA_ADDRESS);

  -- Memory data register from A output
  MDR : data_reg
    PORT MAP (
      RST => RST,
      CLK => CLK,
      ENA => LD_MDR,
      D   => A_OUT,
      Q   => DATABUS_WRITE);

  -- 16 function A output
  ALU1 : alu
    PORT MAP (
      clk => CLK,
      op  => ALU_OP,
      A   => A_OUT,
      B   => B_OUT,
      Y   => ALU_OUT);

-- Multiplexer for program counter input
  PC_MUX : mux8to1
    GENERIC MAP (
      w_data => 15)
    PORT MAP (
      SEL => PC_SRC,
      S0  => A_OUT(14 DOWNTO 0),                           -- "000"
      S1  => PC_INC,                                       -- "001"
      S2  => IMMED(14 DOWNTO 0),                           -- "010"
      S3  => PC_OUT,                                       -- "011"
      S4  => STD_LOGIC_VECTOR(TO_UNSIGNED(16#7FF0#, 15)),  -- "100"
      S5  => STD_LOGIC_VECTOR(TO_UNSIGNED(16#0000#, 15)),  -- "101"
      S6  => STD_LOGIC_VECTOR(TO_UNSIGNED(16#0000#, 15)),  -- "110"
      S7  => INSO4(14 DOWNTO 0),                           -- "111"
      Y   => PC_NEXT);

-- Program counter
  PC : data_reg
    GENERIC MAP (
      w_data      => 15,
      reset_value => 16#0000#)
    PORT MAP (
      RST => RST,
      CLK => CLK,
      ENA => LD_PC,
      D   => PC_NEXT,
      Q   => PC_OUT);

-- Incrementer for program counter
  ADD1 : incr
    GENERIC MAP (
      w_data => 15)
    PORT MAP (
      A => PC_OUT,
      Y => PC_INC);

  CTRL1 : uctrl
    PORT MAP (
      CLK      => CLK,
      RST      => RST,
      PC_SRC   => PC_SRC,
      LD_PC    => LD_PC,
      LD_IR    => LD_IR,
      LD_DP    => LD_DP,
      REG_SRC  => REG_SRC,
      RFA_A    => RFA_A,
      RFA_B    => RFA_B,
      REG_WR   => REG_WR,
      LD_REG_A => LD_REG_A,
      LD_REG_B => LD_REG_B,
      LD_MAR   => LD_MAR,
      LD_MDR   => LD_MDR,
      MEM_WR   => MEM_WR,
      ALU_OP   => ALU_OP,
      INT      => INT,
      ZERO     => ZERO,
      IR_IN    => INSTR);

-- Decoder for IO
  DEC1 : decoder
    PORT MAP (
      clk     => CLK,
      ena     => LD_MAR,
      a1      => B_OUT(14 DOWNTO 0),
      gpio_1  => EOUT1,
      gpio_2  => EIN1,
      gpio_3  => EIN2,
      bus_sel => DOSEL);

-- Simple output register for LED output port
  OUT1 : gpio_out
    GENERIC MAP (
      w_port => 8)
    PORT MAP (
      RST      => RST,
      CLK      => CLK,
      ena      => EOUT1,
      we       => MEM_WR,
      D        => DATABUS_WRITE,
      Q        => DO1,
      port_out => led_out);

-- Simple input register for switches
  IN1 : gpio_in
    GENERIC MAP (
      w_port => 8)
    PORT MAP (
      RST     => RST,
      CLK     => CLK,
      ena     => EIN1,
      Q       => DO2,
      port_in => switch_in);

-- Simple input register for push buttons
  IN2 : gpio_in
    GENERIC MAP (
      w_port => 5)
    PORT MAP (
      RST     => RST,
      CLK     => CLK,
      ena     => EIN2,
      Q       => DO3,
      port_in => pushb_in);

-- 1kx16 two port RAM
  Mem1 : generic_ram
    GENERIC MAP (
      filename => "input_data.txt",
      w_addr   => 10)
    PORT MAP (
      CLK => CLK,
      we  => MEM_WR,
      a1  => B_OUT(9 DOWNTO 0),
      a2  => PC_NEXT(9 DOWNTO 0),
      d1  => A_OUT,
      q1  => MEMO4,                     -- Data memory output
      q2  => INSO4);                    -- Instruction memory output

  IR : data_reg
    PORT MAP (
      RST => RST,
      CLK => CLK,
      ENA => LD_IR,
      D   => INSO4,
      Q   => INSTR);

  DR : data_reg
    PORT MAP (
      RST => RST,
      CLK => CLK,
      ENA => LD_DP,
      D   => INSO4,
      Q   => IMMED);

-- RAM/input device READ multiplexer
  MUX3 : mux8to1
    PORT MAP (
      SEL => DOSEL,
      S0  => DO1,
      S1  => DO2,
      S2  => DO3,
      S3  => STD_LOGIC_VECTOR(TO_UNSIGNED(0, w_data)),
      S4  => STD_LOGIC_VECTOR(TO_UNSIGNED(0, w_data)),
      S5  => STD_LOGIC_VECTOR(TO_UNSIGNED(0, w_data)),
      S6  => STD_LOGIC_VECTOR(TO_UNSIGNED(0, w_data)),
      S7  => MEMO4,
      Y   => DATABUS_READ);


END Structural;
