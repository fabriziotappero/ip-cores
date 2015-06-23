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


--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:52:44 08/10/2013
-- Design Name:   
-- Module Name:   /home/jurgen/Projects/lisp/projects/datapath/tb_1.vhdl
-- Project Name:  datapath
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dp
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY tb_1 IS
END tb_1;

ARCHITECTURE behavior OF tb_1 IS

  -- Component Declaration for the Unit Under Test (UUT)
  
  COMPONENT dp
    PORT(
      reset     : IN  STD_LOGIC;
      clock     : IN  STD_LOGIC;
      reg_a     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      reg_b     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      reg_c     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      data_in   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
      reg_input : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
      op_sel    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      we        : IN  STD_LOGIC;
      pc_input  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
      addr_sel  : IN  STD_LOGIC;
      data_out  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      addr_out  : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
      zero      : OUT STD_LOGIC;
      n_zero    : OUT STD_LOGIC
      );
  END COMPONENT;


  --Inputs
  SIGNAL reset     : STD_LOGIC                     := '0';
  SIGNAL clock     : STD_LOGIC                     := '0';
  SIGNAL reg_a     : STD_LOGIC_VECTOR(3 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL reg_b     : STD_LOGIC_VECTOR(3 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL reg_c     : STD_LOGIC_VECTOR(3 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL data_in   : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL reg_input : STD_LOGIC_VECTOR(1 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL op_sel    : STD_LOGIC_VECTOR(3 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL we        : STD_LOGIC                     := '0';
  SIGNAL pc_input  : STD_LOGIC_VECTOR(1 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL addr_sel  : STD_LOGIC                     := '0';

  --Outputs
  SIGNAL data_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL addr_out : STD_LOGIC_VECTOR(14 DOWNTO 0);
  SIGNAL zero     : STD_LOGIC;
  SIGNAL n_zero   : STD_LOGIC;

  -- Clock period definitions
  CONSTANT clock_period : TIME := 10 ns;
  
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : dp PORT MAP (
    reset     => reset,
    clock     => clock,
    reg_a     => reg_a,
    reg_b     => reg_b,
    reg_c     => reg_c,
    data_in   => data_in,
    reg_input => reg_input,
    op_sel    => op_sel,
    we        => we,
    pc_input  => pc_input,
    addr_sel  => addr_sel,
    data_out  => data_out,
    addr_out  => addr_out,
    zero      => zero,
    n_zero    => n_zero
    );

  -- Clock process definitions
  clock_process : PROCESS
  BEGIN
    clock <= '0';
    WAIT FOR clock_period/2;
    clock <= '1';
    WAIT FOR clock_period/2;
  END PROCESS;


  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- hold reset state for 100 ns.
    WAIT FOR 100 ns;

    WAIT FOR clock_period*10;

    -- insert stimulus here 

    WAIT;
  END PROCESS;

END;
