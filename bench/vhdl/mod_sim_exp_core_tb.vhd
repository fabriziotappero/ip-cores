----------------------------------------------------------------------  
----  mod_sim_exp_core_tb                                               ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    testbench for the modular simultaneous exponentiation     ----
----    core. Performs some exponentiations to verify the design  ----
----    Takes input parameters from sim_input.txt en writes       ----
----    result and output to sim_output.txt                       ----
----                                                              ----
----  Dependencies:                                               ----
----    - multiplier_core                                         ----
----                                                              ----
----  Authors:                                                    ----
----      - Geoffrey Ottoy, DraMCo research group                 ----
----      - Jonas De Craene, JonasDC@opencores.org                ---- 
----                                                              ---- 
---------------------------------------------------------------------- 
----                                                              ---- 
---- Copyright (C) 2011 DraMCo research group and OPENCORES.ORG   ---- 
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
---- PURPOSE.  See the GNU Lesser General Public License for more ---- 
---- details.                                                     ---- 
----                                                              ---- 
---- You should have received a copy of the GNU Lesser General    ---- 
---- Public License along with this source; if not, download it   ---- 
---- from http://www.opencores.org/lgpl.shtml                     ---- 
----                                                              ---- 
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_textio.all;

library mod_sim_exp;
use mod_sim_exp.mod_sim_exp_pkg.all;

entity mod_sim_exp_core_tb is
end mod_sim_exp_core_tb;

architecture test of mod_sim_exp_core_tb is
  constant CLK_PERIOD : time := 10 ns;
  signal clk          : std_logic := '0';
  constant CORE_CLK_PERIOD : time := 4 ns;
  signal core_clk     : std_logic := '0';
  signal reset        : std_logic := '1';
  file input          : text open read_mode is "src/sim_input.txt";
  file output         : text open write_mode is "out/sim_output.txt";
  
  ------------------------------------------------------------------
  -- Core parameters
  ------------------------------------------------------------------
  constant C_NR_BITS_TOTAL   : integer := 1536;
  constant C_NR_STAGES_TOTAL : integer := 96;
  constant C_NR_STAGES_LOW   : integer := 32;
  constant C_SPLIT_PIPELINE  : boolean := true; 
  constant C_FIFO_AW         : integer := 7; -- set to log2( (maximum exponent width)/16 )
  constant C_MEM_STYLE       : string  := "asym"; -- xil_prim, generic, asym are valid options
  constant C_FPGA_MAN        : string  := "xilinx";  -- xilinx, altera are valid options
  
  -- extra calculated constants
  constant NR_BITS_LOW : integer := (C_NR_BITS_TOTAL/C_NR_STAGES_TOTAL)*C_NR_STAGES_LOW;
  constant NR_BITS_HIGH : integer := C_NR_BITS_TOTAL-NR_BITS_LOW;
  
  ------------------------------------------------------------------
  -- Signals for multiplier core memory space
  ------------------------------------------------------------------
  signal core_rw_address   : std_logic_vector (8 downto 0);
  signal core_data_in      : std_logic_vector(31 downto 0);
  signal core_fifo_din     : std_logic_vector(31 downto 0);
  signal core_data_out     : std_logic_vector(31 downto 0);
  signal core_write_enable : std_logic;
  signal core_fifo_push    : std_logic;
  ------------------------------------------------------------------
  -- Signals for multiplier core control
  ------------------------------------------------------------------
  signal core_start          : std_logic;
  signal core_exp_m          : std_logic;
  signal core_p_sel          : std_logic_vector(1 downto 0);
  signal core_dest_op_single : std_logic_vector(1 downto 0);
  signal core_x_sel_single   : std_logic_vector(1 downto 0);
  signal core_y_sel_single   : std_logic_vector(1 downto 0);
  signal calc_time           : std_logic;
  ------------------------------------------------------------------
  -- Signals for multiplier core interrupt
  ------------------------------------------------------------------
  signal core_fifo_full   : std_logic;
  signal core_fifo_nopush : std_logic;
  signal core_ready       : std_logic;
  signal core_mem_collision : std_logic;

begin

------------------------------------------
-- Generate clk
------------------------------------------
clk_process : process
begin
  while (true) loop
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
  end loop;
end process;

core_clk_process : process
begin
  while (true) loop
    core_clk <= '0';
    wait for CORE_CLK_PERIOD/2;
    core_clk <= '1';
    wait for CORE_CLK_PERIOD/2;
  end loop;
end process;

------------------------------------------
-- Stimulus Process
------------------------------------------
stim_proc : process
  procedure waitclk(n : natural := 1) is
  begin
    for i in 1 to n loop
      wait until rising_edge(clk);
    end loop;
  end waitclk;
  
  procedure loadOp(constant op_sel : std_logic_vector(2 downto 0);
               variable op_data : std_logic_vector(2047 downto 0)) is
  begin
    wait until rising_edge(clk);
    core_rw_address <= op_sel & "000000";
    wait until rising_edge(clk);
    core_write_enable <= '1';
    for i in 0 to (1536/32)-1 loop
      assert (core_mem_collision='0') 
        report "collision detected while writing operand!!" severity failure;
      case (core_p_sel) is
        when "11" =>
          core_data_in <= op_data(((i+1)*32)-1 downto (i*32));
        when "01" =>
          if (i < 16) then core_data_in <= op_data(((i+1)*32)-1 downto (i*32));
          else core_data_in <= x"00000000"; end if;
        when "10" =>
          if (i >= 16) then core_data_in <= op_data(((i-15)*32)-1 downto ((i-16)*32));
          else core_data_in <= x"00000000"; end if;
        when others =>
          core_data_in <= x"00000000";
      end case;
      
      wait until rising_edge(clk);
      core_rw_address <= core_rw_address+"000000001";
    end loop;
    core_write_enable <= '0';
    wait until rising_edge(clk);
  end loadOp;
  
  procedure readOp(constant op_sel : std_logic_vector(2 downto 0);
                  variable op_data  : out std_logic_vector(2047 downto 0);
                  variable op_width : integer) is
  begin
      wait until rising_edge(clk);
      core_dest_op_single <= op_sel(1 downto 0);
      if (core_p_sel = "10") then
        core_rw_address <= op_sel & "010000";
      else
        core_rw_address <= op_sel & "000000";
      end if;
      waitclk(2);
      
      for i in 0 to (op_width/32)-2 loop
          op_data(((i+1)*32)-1 downto (i*32)) := core_data_out;
          core_rw_address <= core_rw_address+"000000001";
          waitclk(2);
      end loop;
      op_data(op_width-1 downto op_width-32) := core_data_out;
      wait until rising_edge(clk);
  end readOp;

  function ToString(constant Timeval : time) return string is
    variable StrPtr : line;
  begin
    write(StrPtr,Timeval);
    return StrPtr.all;
  end ToString;

  -- variables to read file
  variable L : line;
  variable Lw : line;
  variable base_width : integer;
  variable exponent_width : integer;
  variable g0 : std_logic_vector(2047 downto 0) := (others=>'0');
  variable g1 : std_logic_vector(2047 downto 0) := (others=>'0');
  variable e0 : std_logic_vector(2047 downto 0) := (others=>'0');
  variable e1 : std_logic_vector(2047 downto 0) := (others=>'0');
  variable m : std_logic_vector(2047 downto 0) := (others=>'0');
  variable R2 : std_logic_vector(2047 downto 0) := (others=>'0');
  variable R : std_logic_vector(2047 downto 0) := (others=>'0');
  variable gt0 : std_logic_vector(2047 downto 0) := (others=>'0');
  variable gt1 : std_logic_vector(2047 downto 0) := (others=>'0');
  variable gt01 : std_logic_vector(2047 downto 0) := (others=>'0');
  variable one : std_logic_vector(2047 downto 0) := std_logic_vector(conv_unsigned(1, 2048));
  variable result : std_logic_vector(2047 downto 0) := (others=>'0');
  variable data_read : std_logic_vector(2047 downto 0) := (others=>'0');
  variable good_value : boolean;
  variable param_count : integer := 0;
  
  -- constants for operand selection
  constant op_modulus : std_logic_vector(2 downto 0) := "100";
  constant op_0 : std_logic_vector(2 downto 0) := "000";
  constant op_1 : std_logic_vector(2 downto 0) := "001";
  constant op_2 : std_logic_vector(2 downto 0) := "010";
  constant op_3 : std_logic_vector(2 downto 0) := "011";
  
  variable timer : time;
begin
  -- initialisation
  -- memory
  core_write_enable <= '0';
  core_data_in <= x"00000000";
  core_rw_address <= "000000000";
  -- fifo
  core_fifo_din <= x"00000000";
  core_fifo_push <= '0';
  -- control
  core_start <= '0';
  core_exp_m <= '0';
  core_x_sel_single <= "00";
  core_y_sel_single <= "01";
  core_dest_op_single <= "01";
  core_p_sel <= "11";
  
  -- Generate active high reset signal
  reset <= '1';
  waitclk(100);
  reset <= '0';
  waitclk(100);
  
  while not endfile(input) loop
    readline(input, L); -- read next line
    next when L(1)='-'; -- skip comment lines
    -- read input values
    case param_count is
      when 0 => -- base width
        read(L, base_width, good_value);
        assert good_value report "Can not read base width" severity failure;
        assert false report "Simulating exponentiation" severity note;
        write(Lw, string'("----------------------------------------------"));
        writeline(output, Lw);
        write(Lw, string'("--              EXPONENTIATION              --"));
        writeline(output, Lw);
        write(Lw, string'("----------------------------------------------"));
        writeline(output, Lw);
        write(Lw, string'("----- Variables used:"));
        writeline(output, Lw);
        write(Lw, string'("base width: "));
        write(Lw, base_width);
        writeline(output, Lw);
        case (base_width) is
          when C_NR_BITS_TOTAL => when NR_BITS_HIGH => when NR_BITS_LOW =>
          when others => 
            write(Lw, string'("=> incompatible base width!!!")); writeline(output, Lw);
            assert false report "incompatible base width!!!" severity failure;
        end case;
        
      when 1 => -- exponent width
        read(L, exponent_width, good_value);
        assert good_value report "Can not read exponent width" severity failure;
        write(Lw, string'("exponent width: "));
        write(Lw, exponent_width);
        writeline(output, Lw);
        
      when 2 => -- g0
        hread(L, g0(base_width-1 downto 0), good_value);
        assert good_value report "Can not read g0! (wrong lenght?)" severity failure;
        write(Lw, string'("g0: "));
        hwrite(Lw, g0(base_width-1 downto 0));
        writeline(output, Lw);
        
      when 3 => -- g1
        hread(L, g1(base_width-1 downto 0), good_value);
        assert good_value report "Can not read g1! (wrong lenght?)" severity failure;
        write(Lw, string'("g1: "));
        hwrite(Lw, g1(base_width-1 downto 0));
        writeline(output, Lw);
        
      when 4 => -- e0
        hread(L, e0(exponent_width-1 downto 0), good_value);
        assert good_value report "Can not read e0! (wrong lenght?)" severity failure;
        write(Lw, string'("e0: "));
        hwrite(Lw, e0(exponent_width-1 downto 0));
        writeline(output, Lw);
        
      when 5 => -- e1
        hread(L, e1(exponent_width-1 downto 0), good_value);
        assert good_value report "Can not read e1! (wrong lenght?)" severity failure;
        write(Lw, string'("e1: "));
        hwrite(Lw, e1(exponent_width-1 downto 0));
        writeline(output, Lw);
        
      when 6 => -- m
        hread(L, m(base_width-1 downto 0), good_value);
        assert good_value report "Can not read m! (wrong lenght?)" severity failure;
        write(Lw, string'("m:  "));
        hwrite(Lw, m(base_width-1 downto 0));
        writeline(output, Lw);
        
      when 7 => -- R^2
        hread(L, R2(base_width-1 downto 0), good_value);
        assert good_value report "Can not read R2! (wrong lenght?)" severity failure;
        write(Lw, string'("R2: "));
        hwrite(Lw, R2(base_width-1 downto 0));
        writeline(output, Lw);
        
      when 8 => -- R
        hread(L, R(base_width-1 downto 0), good_value);
        assert good_value report "Can not read R! (wrong lenght?)" severity failure;
      
      when 9 => -- gt0
        hread(L, gt0(base_width-1 downto 0), good_value);
        assert good_value report "Can not read gt0! (wrong lenght?)" severity failure;
      
      when 10 => -- gt1
        hread(L, gt1(base_width-1 downto 0), good_value);
        assert good_value report "Can not read gt1! (wrong lenght?)" severity failure;
      
      when 11 => -- gt01
        hread(L, gt01(base_width-1 downto 0), good_value);
        assert good_value report "Can not read gt01! (wrong lenght?)" severity failure;
        
        -- select pipeline for all computations
        ----------------------------------------
        writeline(output, Lw);
        write(Lw, string'("----- Selecting pipeline: "));
        writeline(output, Lw);
        case (base_width) is
          when C_NR_BITS_TOTAL =>  core_p_sel <= "11"; write(Lw, string'("  Full pipeline selected"));
          when NR_BITS_HIGH =>  core_p_sel <= "10"; write(Lw, string'("  Upper pipeline selected"));
          when NR_BITS_LOW  =>  core_p_sel <= "01"; write(Lw, string'("  Lower pipeline selected"));
          when others =>
            write(Lw, string'("  Invallid bitwidth for design"));
            assert false report "impossible basewidth!" severity failure;
        end case;
        writeline(output, Lw);
        
        writeline(output, Lw);
        write(Lw, string'("----- Writing operands:"));
        writeline(output, Lw);
        
        -- load the modulus
        --------------------
        loadOp(op_modulus, m); -- visual check needed
        write(Lw, string'("  m written"));
        writeline(output, Lw);
        
        -- load g0
        -----------
        loadOp(op_0, g0);
        -- verify
        readOp(op_0, data_read, base_width);
        if (g0(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
          write(Lw, string'("  g0 written in operand_0")); writeline(output, Lw);
        else
          write(Lw, string'("  failed to write g0 to operand_0!")); writeline(output, Lw);
          assert false report "Load g0 to op0 data verify failed!!" severity failure;
        end if;
        
        -- load g1
        -----------
        loadOp(op_1, g1);
        -- verify
        readOp(op_1, data_read, base_width);
        if (g1(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
          write(Lw, string'("  g1 written in operand_1")); writeline(output, Lw);
        else
          write(Lw, string'("  failed to write g1 to operand_1!")); writeline(output, Lw);
          assert false report "Load g1 to op1 data verify failed!!" severity failure;
        end if;
        
        -- load R2
        -----------
        loadOp(op_2, R2);
        -- verify
        readOp(op_2, data_read, base_width);
        if (R2(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
          write(Lw, string'("  R^2 written in operand_2")); writeline(output, Lw);
        else
          write(Lw, string'("  failed to write R^2 to operand_2!")); writeline(output, Lw);
          assert false report "Load R2 to op2 data verify failed!!" severity failure;
        end if;
        
        -- load a=1
        ------------
        loadOp(op_3, one);
        -- verify
        readOp(op_3, data_read, base_width);
        if (one(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
          write(Lw, string'("  1 written in operand_3")); writeline(output, Lw);
        else
          write(Lw, string'("  failed to write 1 to operand_3!")); writeline(output, Lw);
          assert false report "Load 1 to op3 data verify failed!!" severity failure;
        end if;
        
        writeline(output, Lw);
        write(Lw, string'("----- Pre-computations: "));
        writeline(output, Lw);
        
        -- compute gt0
        ---------------
        core_x_sel_single <= "00"; -- g0
        core_y_sel_single <= "10"; -- R^2
        core_dest_op_single <= "00"; -- op_0 = (g0 * R) mod m
        wait until rising_edge(clk);
        timer := NOW;
        core_start <= '1';
        wait until rising_edge(clk);
        core_start <= '0';
        wait until core_ready = '1';
        timer := NOW-timer;
        waitclk(10);
        readOp(op_0, data_read, base_width);
        write(Lw, string'("  Computed gt0: "));
        hwrite(Lw, data_read(base_width-1 downto 0));
        writeline(output, Lw);
        write(Lw, string'("  Read gt0:     "));
        hwrite(Lw, gt0(base_width-1 downto 0));
        writeline(output, Lw);
        write(Lw, string'("  => calc time is "));
        write(Lw, string'(ToString(timer)));
        writeline(output, Lw);
        write(Lw, string'("  => expected time is "));
        write(Lw, (C_NR_STAGES_TOTAL+(2*(base_width-1)))*CLK_PERIOD);
        writeline(output, Lw);
        if (gt0(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
          write(Lw, string'("  => gt0 is correct!")); writeline(output, Lw);
        else
          write(Lw, string'("  => Error: gt0 is incorrect!!!")); writeline(output, Lw);
          assert false report "gt0 is incorrect!!!" severity failure;
        end if;
        
        -- compute gt1
        ---------------
        core_x_sel_single <= "01"; -- g1
        core_y_sel_single <= "10"; -- R^2
        core_dest_op_single <= "01"; -- op_1 = (g1 * R) mod m
        wait until rising_edge(clk);
        timer := NOW;
        core_start <= '1';
        wait until rising_edge(clk);
        core_start <= '0';
        wait until core_ready = '1';
        timer := NOW-timer;
        waitclk(10);
        readOp(op_1, data_read, base_width);
        write(Lw, string'("  Computed gt1: "));
        hwrite(Lw, data_read(base_width-1 downto 0));
        writeline(output, Lw);
        write(Lw, string'("  Read gt1:     "));
        hwrite(Lw, gt1(base_width-1 downto 0));
        writeline(output, Lw);
        write(Lw, string'("  => calc time is "));
        write(Lw, string'(ToString(timer)));
        writeline(output, Lw);
        write(Lw, string'("  => expected time is "));
        write(Lw, (C_NR_STAGES_TOTAL+(2*(base_width-1)))*CLK_PERIOD);
        writeline(output, Lw);
        if (gt1(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
          write(Lw, string'("  => gt1 is correct!")); writeline(output, Lw);
        else
          write(Lw, string'("  => Error: gt1 is incorrect!!!")); writeline(output, Lw);
          assert false report "gt1 is incorrect!!!" severity failure;
        end if;
        
        -- compute a
        -------------
        core_x_sel_single <= "10"; -- R^2
        core_y_sel_single <= "11"; -- 1
        core_dest_op_single <= "11"; -- op_3 = (R) mod m
        wait until rising_edge(clk);
        core_start <= '1';
        timer := NOW;
        wait until rising_edge(clk);
        core_start <= '0';
        wait until core_ready = '1';
        timer := NOW-timer;
        waitclk(10);
        readOp(op_3, data_read, base_width);
        write(Lw, string'("  Computed a=(R)mod m: "));
        hwrite(Lw, data_read(base_width-1 downto 0));
        writeline(output, Lw);
        write(Lw, string'("  Read (R)mod m:       "));
        hwrite(Lw, R(base_width-1 downto 0));
        writeline(output, Lw);
        write(Lw, string'("  => calc time is "));
        write(Lw, string'(ToString(timer)));
        writeline(output, Lw);
        write(Lw, string'("  => expected time is "));
        write(Lw, (C_NR_STAGES_TOTAL+(2*(base_width-1)))*CLK_PERIOD);
        writeline(output, Lw);
        if (R(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
          write(Lw, string'("  => (R)mod m is correct!")); writeline(output, Lw);
        else
          write(Lw, string'("  => Error: (R)mod m is incorrect!!!")); writeline(output, Lw);
          assert false report "(R)mod m is incorrect!!!" severity failure;
        end if;
        
        -- compute gt01
        ---------------
        core_x_sel_single <= "00"; -- gt0
        core_y_sel_single <= "01"; -- gt1
        core_dest_op_single <= "10"; -- op_2 = (gt0 * gt1) mod m
        wait until rising_edge(clk);
        core_start <= '1';
        timer := NOW;
        wait until rising_edge(clk);
        core_start <= '0';
        wait until core_ready = '1';
        timer := NOW-timer;
        waitclk(10);
        readOp(op_2, data_read, base_width);
        write(Lw, string'("  Computed gt01: "));
        hwrite(Lw, data_read(base_width-1 downto 0));
        writeline(output, Lw);
        write(Lw, string'("  Read gt01:     "));
        hwrite(Lw, gt01(base_width-1 downto 0));
        writeline(output, Lw);
        write(Lw, string'("  => calc time is "));
        write(Lw, string'(ToString(timer)));
        writeline(output, Lw);
        write(Lw, string'("  => expected time is "));
        write(Lw, (C_NR_STAGES_TOTAL+(2*(base_width-1)))*CLK_PERIOD);
        writeline(output, Lw);
        if (gt01(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
          write(Lw, string'("  => gt01 is correct!")); writeline(output, Lw);
        else
          write(Lw, string'("  => Error: gt01 is incorrect!!!")); writeline(output, Lw);
          assert false report "gt01 is incorrect!!!" severity failure;
        end if;
        
        -- load exponent fifo
        ----------------------
        writeline(output, Lw);
        write(Lw, string'("----- Loading exponent fifo: "));
        writeline(output, Lw);
        for i in (exponent_width/16)-1 downto 0 loop
          core_fifo_din <= e1((i*16)+15 downto (i*16)) & e0((i*16)+15 downto (i*16));
          wait until rising_edge(clk);
          assert (core_fifo_full='0') 
            report "Fifo error, fifo full" severity failure;
          core_fifo_push <= '1';
          wait until rising_edge(clk);
          assert (core_fifo_full='0' and core_fifo_nopush='0') 
            report "Fifo error, fifo nopush" severity failure;
          core_fifo_push <= '0';
          wait until rising_edge(clk);
        end loop;
        waitclk(10);
        write(Lw, string'("  => Done"));
        writeline(output, Lw);
        
        -- start exponentiation
        ------------------------
        writeline(output, Lw);
        write(Lw, string'("----- Starting exponentiation: "));
        writeline(output, Lw);
        core_exp_m <= '1';
        wait until rising_edge(clk);
        timer := NOW;
        core_start <= '1';
        wait until rising_edge(clk);
        core_start <= '0';
        wait until core_ready='1';
        timer := NOW-timer;
        waitclk(10);
        write(Lw, string'("  => calc time is "));
        write(Lw, string'(ToString(timer)));
        writeline(output, Lw);
        write(Lw, string'("  => expected time is "));
        write(Lw, ((C_NR_STAGES_TOTAL+(2*(base_width-1)))*CLK_PERIOD*7*exponent_width)/4);
        writeline(output, Lw);
        write(Lw, string'("  => Done"));
        core_exp_m <= '0';
        writeline(output, Lw);
        
        -- post-computations
        ---------------------
        writeline(output, Lw);
        write(Lw, string'("----- Post-computations: "));
        writeline(output, Lw);
        -- load in 1 to operand 2
        loadOp(op_2, one);
        -- verify
        readOp(op_2, data_read, base_width);
        if (one(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
          write(Lw, string'("  1 written in operand_2")); writeline(output, Lw);
        else
          write(Lw, string'("  failed to write 1 to operand_2!")); writeline(output, Lw);
          assert false report "Load 1 to op2 data verify failed!!" severity failure;
        end if;
        -- compute result
        core_x_sel_single <= "11"; -- a
        core_y_sel_single <= "10"; -- 1
        core_dest_op_single <= "11"; -- op_3 = (a) mod m
        wait until rising_edge(clk);
        timer := NOW;
        core_start <= '1';
        wait until rising_edge(clk);
        core_start <= '0';
        wait until core_ready = '1';
        timer := NOW-timer;
        waitclk(10);
        readOp(op_3, data_read, base_width);
        write(Lw, string'("  Computed result: "));
        hwrite(Lw, data_read(base_width-1 downto 0));
        writeline(output, Lw);
        write(Lw, string'("  => calc time is "));
        write(Lw, string'(ToString(timer)));
        writeline(output, Lw);
        write(Lw, string'("  => expected time is "));
        write(Lw, (C_NR_STAGES_TOTAL+(2*(base_width-1)))*CLK_PERIOD);
        writeline(output, Lw);
        
      when 12 => -- check with result
        hread(L, result(base_width-1 downto 0), good_value);
        assert good_value report "Can not read result! (wrong lenght?)" severity failure;
        writeline(output, Lw);
        write(Lw, string'("----- verifying result: "));
        writeline(output, Lw);
        write(Lw, string'("  Read result:     "));
        hwrite(Lw, result(base_width-1 downto 0));
        writeline(output, Lw);
        write(Lw, string'("  Computed result: "));
        hwrite(Lw, data_read(base_width-1 downto 0));
        writeline(output, Lw);
        if (result(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
          write(Lw, string'("  => Result is correct!")); writeline(output, Lw);
        else
          write(Lw, string'("  Error: result is incorrect!!!")); writeline(output, Lw);
          assert false report "result is incorrect!!!" severity failure;
        end if;
        writeline(output, Lw);

      when others => 
        assert false report "undefined state!" severity failure;
    end case;
    
    if (param_count = 12) then
      param_count := 0;
    else
      param_count := param_count+1;
    end if;
  end loop;
  
  wait for 1 us;
  assert false report "End of simulation" severity failure;

end process;

------------------------------------------
-- Multiplier core instance
------------------------------------------
the_multiplier : mod_sim_exp.mod_sim_exp_pkg.mod_sim_exp_core
generic map(
  C_NR_BITS_TOTAL   => C_NR_BITS_TOTAL,
  C_NR_STAGES_TOTAL => C_NR_STAGES_TOTAL,
  C_NR_STAGES_LOW   => C_NR_STAGES_LOW,
  C_SPLIT_PIPELINE  => C_SPLIT_PIPELINE,
  C_FIFO_AW         => C_FIFO_AW,
  C_MEM_STYLE       => C_MEM_STYLE, -- xil_prim, generic, asym are valid options
  C_FPGA_MAN        => C_FPGA_MAN   -- xilinx, altera are valid options
)
port map(
  bus_clk   => clk,
  core_clk  => core_clk,
  reset     => reset,
-- operand memory interface (plb shared memory)
  write_enable => core_write_enable,
  data_in      => core_data_in,
  rw_address   => core_rw_address,
  data_out     => core_data_out,
  collision    => core_mem_collision,
-- op_sel fifo interface
  fifo_din    => core_fifo_din,
  fifo_push   => core_fifo_push,
  fifo_full   => core_fifo_full,
  fifo_nopush => core_fifo_nopush,
-- ctrl signals
  start          => core_start,
  exp_m          => core_exp_m,
  ready          => core_ready,
  x_sel_single   => core_x_sel_single,
  y_sel_single   => core_y_sel_single,
  dest_op_single => core_dest_op_single,
  p_sel          => core_p_sel,
  calc_time      => calc_time,
  modulus_sel    => '0'
);

end test;
