----------------------------------------------------------------------  
----  mod_sim_exp_core                                            ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    toplevel of a modular simultaneous exponentiation core    ----
----    using a pipelined montgommery multiplier with split       ----
----    pipeline and auto-run support                             ----
----                                                              ----
----  Dependencies:                                               ----
----    - mont_mult_sys_pipeline                                  ----
----    - operand_mem                                             ----
----    - fifo_primitive                                          ----
----    - mont_ctrl                                               ----
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library mod_sim_exp;
use mod_sim_exp.mod_sim_exp_pkg.all;
use mod_sim_exp.std_functions.all;

-- toplevel of the modular simultaneous exponentiation core
-- contains an operand and modulus ram, multiplier, an exponent fifo
-- and control logic
entity mod_sim_exp_core is
  generic(
    C_NR_BITS_TOTAL   : integer := 1536;
    C_NR_STAGES_TOTAL : integer := 96;
    C_NR_STAGES_LOW   : integer := 32;
    C_SPLIT_PIPELINE  : boolean := true;
    C_FIFO_AW         : integer := 7;      -- Address width for FIFO pointers
    C_MEM_STYLE       : string  := "asym"; -- xil_prim, generic, asym are valid options
    C_FPGA_MAN        : string  := "xilinx"   -- xilinx, altera are valid options
  );
  port(
    core_clk : in  std_logic;
    reset    : in  std_logic;
      -- operand memory interface (plb shared memory)
    bus_clk      : in  std_logic;
    write_enable : in  std_logic; -- write data to operand ram
    data_in      : in  std_logic_vector (31 downto 0);  -- operand ram data in
    rw_address   : in  std_logic_vector (8 downto 0); -- operand ram address bus
    data_out     : out std_logic_vector (31 downto 0);  -- operand ram data out
    collision    : out std_logic; -- write collision
      -- op_sel fifo interface
    fifo_din    : in  std_logic_vector (31 downto 0); -- exponent fifo data in
    fifo_push   : in  std_logic;  -- push data in exponent fifo
    fifo_full   : out std_logic;  -- high if fifo is full
    fifo_nopush : out std_logic;  -- high if error during push
      -- control signals
    start          : in  std_logic; -- start multiplication/exponentiation
    exp_m          : in  std_logic; -- single multiplication if low, exponentiation if high
    ready          : out std_logic; -- calculations done
    x_sel_single   : in  std_logic_vector (1 downto 0); -- single multiplication x operand selection
    y_sel_single   : in  std_logic_vector (1 downto 0); -- single multiplication y operand selection
    dest_op_single : in  std_logic_vector (1 downto 0); -- result destination operand selection
    p_sel          : in  std_logic_vector (1 downto 0); -- pipeline part selection
    calc_time      : out std_logic;
    modulus_sel	   : in  std_logic   -- selects which modulus to use for multiplications
  );
end mod_sim_exp_core;


architecture Structural of mod_sim_exp_core is
  -- constants
  constant nr_op : integer := 4;
  constant nr_m  : integer := 2;

  -- data busses
  signal xy : std_logic_vector(C_NR_BITS_TOTAL-1 downto 0);  -- x and y operand data bus RAM -> multiplier
  signal m  : std_logic_vector(C_NR_BITS_TOTAL-1 downto 0);  -- modulus data bus RAM -> multiplier
  signal r  : std_logic_vector(C_NR_BITS_TOTAL-1 downto 0);  -- result data bus RAM <- multiplier

  -- control signals
  signal op_sel         : std_logic_vector(1 downto 0); -- operand selection
  signal result_dest_op : std_logic_vector(1 downto 0); -- result destination operand
  signal mult_ready     : std_logic;
  signal start_mult     : std_logic;
  signal load_x         : std_logic;
  signal load_result    : std_logic;
  signal modulus_sel_i  : std_logic_vector(0 downto 0);
  signal core_ready     : std_logic;
  signal core_calc_time : std_logic;
  signal core_collision : std_logic;
  signal core_start     : std_logic;

  -- fifo signals
  signal fifo_empty : std_logic;
  signal fifo_pop   : std_logic;
  signal fifo_nopop : std_logic;
  signal fifo_dout  : std_logic_vector(31 downto 0);
begin
  -- check the parameters
  assert (C_MEM_STYLE="xil_prim" or C_MEM_STYLE="generic" or C_MEM_STYLE="asym") 
    report "C_MEM_STYLE incorrect!, it must be one of these: xil_prim, generic or asym" severity failure;
  assert (C_FPGA_MAN="xilinx" or C_FPGA_MAN="altera") 
    report "C_FPGA_MAN incorrect!, it must be one of these: xilinx or altera" severity failure;

  -- Block ram memory for storing the operands and the modulus
  the_memory : operand_mem
  generic map(
    width     => C_NR_BITS_TOTAL,
    nr_op     => nr_op,
    nr_m      => nr_m,
    mem_style => C_MEM_STYLE,
    device    => C_FPGA_MAN
  )
  port map(
    bus_clk        => bus_clk,
    data_in        => data_in,
    data_out       => data_out,
    rw_address     => rw_address,
    write_enable   => write_enable,
    op_sel         => op_sel,
    xy_out         => xy,
    m              => m,
    core_clk       => core_clk,
    result_in      => r,
    load_result    => load_result,
    result_dest_op => result_dest_op,
    collision      => core_collision,
    modulus_sel    => modulus_sel_i
  );
  
  modulus_sel_i(0) <= modulus_sel;
	result_dest_op <= dest_op_single when exp_m = '0' else "11"; -- in autorun mode we always store the result in operand3
	
  -- A fifo for exponentiation mode
  xil_prim_fifo : if C_MEM_STYLE="xil_prim" generate
    the_exponent_fifo : fifo_primitive
    port map(
      push_clk => bus_clk,
      pop_clk => core_clk,
      din    => fifo_din,
      dout   => fifo_dout,
      empty  => fifo_empty,
      full   => fifo_full,
      push   => fifo_push,
      pop    => fifo_pop,
      reset  => reset,
      nopop  => fifo_nopop,
      nopush => fifo_nopush
    );
  end generate;
  gen_fifo : if (C_MEM_STYLE = "generic") or (C_MEM_STYLE = "asym") generate
    the_exponent_fifo : entity mod_sim_exp.generic_fifo_dc_gray
    generic map(
      dw => 32,
      aw => C_FIFO_AW
    )
    port map(
      wr_clk => bus_clk,
      rd_clk => core_clk,
      din    => fifo_din,
      dout   => fifo_dout,
      empty  => fifo_empty,
      full   => fifo_full,
      we     => fifo_push,
      re     => fifo_pop,
      clr    => reset,
      nopop  => fifo_nopop,
      nopush => fifo_nopush
    );
  end generate;
  
  -- The actual multiplier
  the_multiplier : mont_multiplier
  generic map(
    n     => C_NR_BITS_TOTAL,
    t     => C_NR_STAGES_TOTAL,
    tl    => C_NR_STAGES_LOW,
    split => C_SPLIT_PIPELINE
  )
  port map(
    core_clk => core_clk,
    xy       => xy,
    m        => m,
    r        => r,
    start    => start_mult,
    reset    => reset,  -- asynchronious reset
    p_sel    => p_sel,
    load_x   => load_x,
    ready    => mult_ready
  );
  
  -- The control logic for the core
  the_control_unit : mont_ctrl 
  port map(
    clk              => core_clk,
    reset            => reset, -- asynchronious reset
    start            => core_start,
    x_sel_single     => x_sel_single,
    y_sel_single     => y_sel_single,
    run_auto         => exp_m,
    op_buffer_empty  => fifo_empty,
    op_sel_buffer    => fifo_dout,
    read_buffer      => fifo_pop,
    done             => core_ready,
    calc_time        => core_calc_time,
    op_sel           => op_sel,
    load_x           => load_x,
    load_result      => load_result,
    start_multiplier => start_mult,
    multiplier_ready => mult_ready
  );
  
  -- go from bus clock domain to core clock domain
  start_pulse : pulse_cdc
  port map(
    reset  => reset,
    clkA   => bus_clk,
    pulseA => start,
    clkB   => core_clk,
    pulseB => core_start
  );
  
  -- go from core clock domain to bus clock domain
  ready_pulse : pulse_cdc
  port map(
    reset  => reset,
    clkA   => core_clk,
    pulseA => core_ready,
    clkB   => bus_clk,
    pulseB => ready
  );
  
  sync_to_bus_clk : clk_sync
  port map(
    sigA => core_calc_time,
    clkB => bus_clk,
    sigB => calc_time
  );
  
  collision_pulse : pulse_cdc
  port map(
    reset  => reset,
    clkA   => core_clk,
    pulseA => core_collision,
    clkB   => bus_clk,
    pulseB => collision
  );

end Structural;
