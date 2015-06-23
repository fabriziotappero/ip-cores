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


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

PACKAGE ram_parts IS

  COMPONENT generic_ram IS

    GENERIC (
      filename : STRING                := "";
      w_data   : NATURAL RANGE 1 TO 32 := 16;
      w_addr   : NATURAL RANGE 8 TO 14 := 10);
    PORT (
      clk : IN  STD_LOGIC;
      we  : IN  STD_LOGIC;
      a1  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);  -- Data port address
      a2  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);  -- Instruction port address
      d1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);  -- Data port input
      q1  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);  -- Data port output
      q2  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));  -- Instruction port output

  END COMPONENT generic_ram;

  COMPONENT RAM32K IS

    GENERIC (
      w_data : NATURAL RANGE 1 TO 32 := 16;
      file_1 : STRING                := "";
      file_2 : STRING                := "";
      file_3 : STRING                := "";
      file_4 : STRING                := "");
    PORT (
      clk : IN  STD_LOGIC;
      we  : IN  STD_LOGIC;
      a1  : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);  -- Data port address
      a2  : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);  -- Instruction port address
      d1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);   -- Data port input
      q1  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);   -- Data port output
      q2  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));  -- Instruction port output

  END COMPONENT RAM32K;

END PACKAGE ram_parts;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE work.arrayio.ALL;

ENTITY generic_ram IS

  -- Memory component based upon Xilinx Spartan-6 block RAM
  -- Maximum capacity is 16k words
  -- This component can be initialised by passing a file name as a generic
  -- parameter.

  GENERIC (
    filename : STRING                := "";
    w_data   : NATURAL RANGE 1 TO 32 := 16;
    w_addr   : NATURAL RANGE 8 TO 14 := 10);
  PORT (
    clk : IN  STD_LOGIC;
    we  : IN  STD_LOGIC;
    a1  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);  -- Data port address
    a2  : IN  STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);  -- Instruction port address
    d1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);  -- Data port input
    q1  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);  -- Data port output
    q2  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));  -- Instruction port output

END generic_ram;

ARCHITECTURE Behavioral OF generic_ram IS

  SIGNAL mem : cstr_array_type(0 TO (2**w_addr) - 1) := init_cstr(2**w_addr, filename);

  SIGNAL address_reg_1 : STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);
  SIGNAL address_reg_2 : STD_LOGIC_VECTOR(w_addr - 1 DOWNTO 0);

BEGIN  -- Behavioral

  -- purpose: Try to describe a proper block ram without needing to instantiate a BRAM
  -- type   : sequential
  -- inputs : clk, we, a1, a2, d1
  -- outputs: q1, q2
  MP1 : PROCESS (clk, address_reg_1, address_reg_2, mem)
  BEGIN  -- PROCESS MP1

    -- Reading
    q1 <= STD_LOGIC_VECTOR(to_unsigned(mem(to_integer(UNSIGNED(address_reg_1))), w_data));
    q2 <= STD_LOGIC_VECTOR(to_unsigned(mem(to_integer(UNSIGNED(address_reg_2))), w_data));

    IF rising_edge(clk) THEN            -- rising clock edge

      -- These work like the block RAM registers
      address_reg_1 <= a1;
      address_reg_2 <= a2;

      -- Writing
      IF we = '1' THEN
        mem(to_integer(UNSIGNED(a1))) <= to_integer(UNSIGNED(d1));
      END IF;

    END IF;
    
  END PROCESS MP1;


END Behavioral;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.mux_parts.ALL;
USE work.ram_parts.ALL;

ENTITY RAM32K IS

  -- This component is based upon the above defined generic_ram
  -- It is constructed using a 4-to-1 multiplexer and 4 8k word
  -- generic_rams.
  -- In order to initialise it, a filename can be passed, which is then
  -- used to generate the names of four files which should have been
  -- prepared previously: filename_{0|1|2|3}.txt
  -- These will be used to initialise the four RAM components.

  GENERIC (
    w_data : NATURAL RANGE 1 TO 32 := 16;
    file_1 : STRING                := "";
    file_2 : STRING                := "";
    file_3 : STRING                := "";
    file_4 : STRING                := "");
  PORT (
    clk : IN  STD_LOGIC;
    we  : IN  STD_LOGIC;
    a1  : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);  -- Data port address
    a2  : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);  -- Instruction port address
    d1  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);   -- Data port input
    q1  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);   -- Data port output
    q2  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));  -- Instruction port output

END RAM32K;

ARCHITECTURE Structural OF RAM32K IS

  SIGNAL data_address  : STD_LOGIC_VECTOR(12 DOWNTO 0);
  SIGNAL data_select   : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL instr_address : STD_LOGIC_VECTOR(12 DOWNTO 0);
  SIGNAL instr_select  : STD_LOGIC_VECTOR(1 DOWNTO 0);

  SIGNAL wr_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);

  TYPE bus_array_t IS ARRAY(0 TO 3) OF STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);

  SIGNAL data : bus_array_t;
  SIGNAL inst : bus_array_t;

  TYPE file_array IS ARRAY(INTEGER RANGE <>) OF STRING(1 TO 100);

  CONSTANT i_file : file_array(0 TO 3) := (file_1, file_2, file_3, file_4);

BEGIN  -- Structural

  data_address <= a1(12 DOWNTO 0);
  data_select  <= a1(14 DOWNTO 13);

  instr_address <= a2(12 DOWNTO 0);
  instr_select  <= a2(14 DOWNTO 13);

  wr_sel <= "0001" WHEN data_select = "00" AND we = '1' ELSE
            "0010" WHEN data_select = "01" AND we = '1' ELSE
            "0100" WHEN data_select = "10" AND we = '1' ELSE
            "1000" WHEN data_select = "11" AND we = '1' ELSE
            "0000";

  M1 : mux4to1
    PORT MAP (
      SEL => data_select,
      S0  => data(0),
      S1  => data(1),
      S2  => data(2),
      S3  => data(3),
      Y   => q1);

  M2 : mux4to1
    PORT MAP (
      SEL => instr_select,
      S0  => inst(0),
      S1  => inst(1),
      S2  => inst(2),
      S3  => inst(3),
      Y   => q2);

  RAM : FOR i IN 0 TO 3 GENERATE

    R0 : generic_ram
      GENERIC MAP (
        filename => i_file(i),
        w_data   => w_data,
        w_addr   => 13)
      PORT MAP (
        clk => clk,
        we  => wr_sel(i),
        a1  => data_address,
        a2  => instr_address,
        d1  => d1,
        q1  => data(i),
        q2  => inst(i));

  END GENERATE RAM;

END Structural;

