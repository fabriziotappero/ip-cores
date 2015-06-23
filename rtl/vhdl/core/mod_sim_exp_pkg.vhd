----------------------------------------------------------------------  
----  mod_sim_exp_pkg                                             ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    Package for the Modular Simultaneous Exponentiation Core  ----
----    Project. Contains the component declarations and used     ----
----    constants.                                                ----
----                                                              ---- 
----  Dependencies: none                                          ---- 
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

library mod_sim_exp;
use mod_sim_exp.std_functions.all;

package mod_sim_exp_pkg is
  --------------------------------------------------------------------
  ---------------------- COMPONENT DECLARATIONS ----------------------
  --------------------------------------------------------------------
  
  --------------------------- MULTIPLIER -----------------------------
  
  --------------------------------------------------------------------
  -- d_flip_flop
  --------------------------------------------------------------------
  --    1-bit D flip-flop with asynchronous active high reset
  -- 
  component d_flip_flop is
    port(
      core_clk : in  std_logic; -- clock signal
      reset    : in  std_logic; -- active high reset
      din      : in  std_logic; -- data in
      dout     : out std_logic  -- data out
    );
  end component d_flip_flop;
  
  --------------------------------------------------------------------
  -- register_1b
  --------------------------------------------------------------------
  --    1-bit register with asynchronous reset and clock enable
  -- 
  component register_1b is
    port(
      core_clk : in  std_logic; -- clock input
      ce       : in  std_logic; -- clock enable (active high)
      reset    : in  std_logic; -- reset (active high)
      din      : in  std_logic; -- data in
      dout     : out std_logic  -- data out
    );
  end component register_1b;
  
  --------------------------------------------------------------------
  -- register_n
  --------------------------------------------------------------------
  --    n-bit register with asynchronous reset and clock enable
  -- 
  component register_n is
    generic(
      width : integer := 4
    );
    port(
      core_clk : in  std_logic; -- clock input
      ce       : in  std_logic; -- clock enable (active high)
      reset    : in  std_logic; -- reset (active high)
      din      : in  std_logic_vector((width-1) downto 0);  -- data in (width)-bit
      dout     : out std_logic_vector((width-1) downto 0)   -- data out (width)-bit
    );
  end component register_n;
  
  --------------------------------------------------------------------
  -- cell_1b_adder
  --------------------------------------------------------------------
  --    1-bit full adder cell using combinatorial logic
  --    
  component cell_1b_adder is
    port (
      -- input operands a, b
      a    : in  std_logic;
      b    : in  std_logic;
      -- carry in, out
      cin  : in  std_logic;
      cout : out  std_logic;
      -- result out
      r    : out  std_logic
    );
  end component cell_1b_adder;
  
  --------------------------------------------------------------------
  -- cell_1b_mux
  --------------------------------------------------------------------
  --    1-bit mux for a standard cell in the montgommery multiplier 
  --    systolic array
  -- 
  component cell_1b_mux is
    port (
      -- input bits
      my     : in  std_logic; 
      y      : in  std_logic;
      m      : in  std_logic;
      -- selection bits
      x      : in  std_logic;
      q      : in  std_logic;
      -- mux out
      result : out std_logic
    );
  end component cell_1b_mux;
  
  --------------------------------------------------------------------
  -- cell_1b
  --------------------------------------------------------------------
  --    1-bit cell for the systolic array
  -- 
  component cell_1b is
    port (
      -- operand input bits (m+y, y and m)
      my   : in  std_logic;
      y    : in  std_logic;
      m    : in  std_logic;
      -- operand x input bit and q
      x    : in  std_logic;
      q    : in  std_logic;
      -- previous result input bit
      a    : in  std_logic;
      -- carry's
      cin  : in  std_logic;
      cout : out std_logic;
      -- cell result out
      r    : out std_logic
    );
  end component cell_1b;
  
  --------------------------------------------------------------------
  -- adder_block
  --------------------------------------------------------------------
  --    (width)-bit full adder block using cell_1b_adders with buffered
  --    carry out
  -- 
  component adder_block is
    generic (
      width : integer := 32 --adder operand widths
    );
    port (
      -- clock input
      core_clk : in std_logic; 
      -- adder input operands a, b (width)-bit
      a : in std_logic_vector((width-1) downto 0);
      b : in std_logic_vector((width-1) downto 0);
      -- carry in, out
      cin   : in std_logic;
      cout  : out std_logic;
      -- adder result out (width)-bit
      r : out std_logic_vector((width-1) downto 0) 
    );
  end component adder_block;
  
  --------------------------------------------------------------------
  -- standard_cell_block
  --------------------------------------------------------------------
  --    a standard cell block of (width)-bit for the montgommery multiplier 
  --    systolic array
  -- 
  component standard_cell_block is
    generic (
      width : integer := 16
    );
    port (
      -- modulus and y operand input (width)-bit
      my   : in  std_logic_vector((width-1) downto 0);
      y    : in  std_logic_vector((width-1) downto 0);
      m    : in  std_logic_vector((width-1) downto 0);
      -- q and x operand input (serial input)
      x    : in  std_logic;
      q    : in  std_logic;
      -- previous result in (width)-bit
      a    : in  std_logic_vector((width-1) downto 0);
      -- carry in and out
      cin  : in std_logic;
      cout : out std_logic;
      -- result out (width)-bit
      r    : out  std_logic_vector((width-1) downto 0)
    );
  end component standard_cell_block;
  
  --------------------------------------------------------------------
  -- counter_sync
  --------------------------------------------------------------------
  --    counter with synchronous count enable. It generates an
  --    overflow when max_value is reached
  -- 
  component counter_sync is
    generic(
      max_value : integer := 1024 -- maximum value (constraints the nr bits for counter)
    );
    port(
      reset_value : in integer;   -- value the counter counts to
      core_clk    : in std_logic; -- clock input
      ce          : in std_logic; -- count enable
      reset       : in std_logic; -- reset input
      overflow    : out std_logic -- gets high when counter reaches reset_value
    );
  end component counter_sync;
  
  --------------------------------------------------------------------
  -- stepping_logic
  --------------------------------------------------------------------
  --    stepping logic for the pipeline, generates the start pulses for the
  --    first stage and keeps track of when the last stages are done
  -- 
  component stepping_logic is
    generic(
      n : integer := 1536;  -- max nr of steps required to complete a multiplication
      t : integer := 192    -- total nr of steps in the pipeline
    );
    port(
      core_clk          : in  std_logic;  -- clock input
      start             : in  std_logic;  -- start signal for pipeline (one multiplication)
      reset             : in  std_logic;  -- reset signal
      t_sel             : in integer range 0 to t; -- nr of stages in the pipeline piece
      n_sel             : in integer range 0 to n; -- nr of steps(bits in operands) required for a complete multiplication
      start_first_stage : out std_logic;  -- start pulse output for first stage
      stepping_done     : out std_logic   -- done signal
    );
  end component stepping_logic;

  --------------------------------------------------------------------
  -- x_shift_reg
  --------------------------------------------------------------------
  --    shift register for the x operand of the multiplier
  --    outputs the lsb of the register or bit at offset according to the
  --    selected pipeline part 
  -- 
  component x_shift_reg is
    generic(
      n  : integer := 1536; -- width of the operands (# bits)
      t  : integer := 48;   -- total number of stages
      tl : integer := 16    -- lower number of stages
    );
    port(
      -- clock input
      clk    : in  std_logic;
      -- x operand in (n-bit)
      x_in   : in  std_logic_vector((n-1) downto 0);
      -- control signals
      reset  : in  std_logic; -- reset, clears register
      load_x : in  std_logic; -- load operand into shift register   
      next_x : in  std_logic; -- next bit of x
      p_sel  : in  std_logic_vector(1 downto 0);  -- pipeline selection
      -- x operand bit out (serial)
      xi     : out std_logic  
    );
  end component x_shift_reg;
  
  component autorun_cntrl is
    port (
      clk              : in  std_logic;
      reset            : in  std_logic;
      start            : in  std_logic;
      done             : out  std_logic;
      op_sel           : out  std_logic_vector (1 downto 0);
      start_multiplier : out  std_logic;
      multiplier_done  : in  std_logic;
      read_buffer      : out  std_logic;
      buffer_din       : in  std_logic_vector (31 downto 0);
      buffer_empty     : in  std_logic
    );
  end component autorun_cntrl;
  
  --------------------------------------------------------------------
  -- mont_ctrl
  --------------------------------------------------------------------
  --    This module controls the montgommery mutliplier and controls traffic between
  --    RAM and multiplier. Also contains the autorun logic for exponentiations.
  -- 
  component mont_ctrl is
    port (
      clk   : in std_logic;
      reset : in std_logic;
        -- bus side
      start           : in std_logic;
      x_sel_single    : in std_logic_vector(1 downto 0);
      y_sel_single    : in std_logic_vector(1 downto 0);
      run_auto        : in std_logic;
      op_buffer_empty : in std_logic;
      op_sel_buffer   : in std_logic_vector(31 downto 0);
      read_buffer     : out std_logic;
      done            : out std_logic;
      calc_time       : out std_logic;
        -- multiplier side
      op_sel           : out std_logic_vector(1 downto 0);
      load_x           : out std_logic;
      load_result      : out std_logic;
      start_multiplier : out std_logic;
      multiplier_ready : in std_logic
    );
  end component mont_ctrl;
  
  component sys_stage is
    generic(
      width : integer := 32 -- width of the stage
    );
    port(
      -- clock input
      core_clk : in  std_logic;
      -- modulus and y operand input (width)-bit
      y        : in  std_logic_vector((width-1) downto 0);
      m        : in  std_logic_vector((width) downto 0);
      my_cin   : in  std_logic;
      my_cout  : out std_logic;
      -- q and x operand input (serial input)
      xin      : in  std_logic;
      qin      : in  std_logic;
      -- q and x operand output (serial output)
      xout     : out std_logic;
      qout     : out std_logic;
      -- msb input (lsb from next stage, for shift right operation)
      a_msb    : in  std_logic;
      a_0      : out std_logic;
      -- carry out(clocked) and in
      cin      : in  std_logic;
      cout     : out std_logic;
      -- reduction adder carry's
      red_cin  : in std_logic;
      red_cout : out std_logic;
      -- control singals
      start    : in  std_logic;
      reset    : in  std_logic;
      done     : out std_logic;
      -- result out
      r_sel    : in  std_logic; -- result selection: 0 -> pipeline result, 1 -> reducted result
      r        : out std_logic_vector((width-1) downto 0)
    );
  end component sys_stage;

  --------------------------------------------------------------------
  -- sys_last_cell_logic
  --------------------------------------------------------------------   
  --    logic needed as the last piece in the systolic array pipeline
  --    calculates the last 2 bits of the cell_result and finishes the reduction
  --    also generates the result selection signal
  -- 
  component sys_last_cell_logic is
    port  (
      core_clk : in std_logic;    -- clock input
      reset    : in std_logic;    
      a_0      : out std_logic;   -- a_msb for last stage
      cin      : in std_logic;    -- cout from last stage
      red_cin  : in std_logic;    -- red_cout from last stage
      r_sel    : out std_logic;   -- result selection bit
      start    : in std_logic     -- done signal from last stage
    );
  end component sys_last_cell_logic;
  
  --------------------------------------------------------------------
  -- sys_first_cell_logic
  --------------------------------------------------------------------     
  --    logic needed as the first piece in the systolic array pipeline
  --    calculates the first my_cout and generates q signal
  -- 
  component sys_first_cell_logic is
    port  (
      m0       : in std_logic;    -- lsb from m operand
      y0       : in std_logic;    -- lsb from y operand
      my_cout  : out std_logic;   -- my_cin for first stage
      xi       : in std_logic;    -- xi operand input
      xout     : out std_logic;   -- xin for first stage
      qout     : out std_logic;   -- qin for first stage
      cout     : out std_logic;   -- cin for first stage
      a_0      : in std_logic;    -- a_0 from first stage
      red_cout : out std_logic    -- red_cin for first stage
    );
  end component sys_first_cell_logic;

  --------------------------------------------------------------------
  -- sys_pipeline
  -------------------------------------------------------------------- 
  --    the pipelined systolic array for a montgommery multiplier
  --    contains a structural description of the pipeline using the systolic stages
  -- 
  component sys_pipeline is
    generic(
      n  : integer := 1536; -- width of the operands (# bits)
      t  : integer := 192;  -- total number of stages (minimum 2)
      tl : integer := 64;   -- lower number of stages (minimum 1)
      split : boolean := true -- if true the pipeline wil be split in 2 parts,
                              -- if false there are no lower stages, only t counts
    );
    port(
      -- clock input
      core_clk : in  std_logic;
      -- modulus and y opperand input (n)-bit
      y        : in  std_logic_vector((n-1) downto 0);
      m        : in  std_logic_vector((n-1) downto 0);
      -- x operand input (serial)
      xi       : in  std_logic;
      next_x   : out std_logic; -- next x operand bit
      -- control signals
      start    : in  std_logic; -- start multiplier
      reset    : in  std_logic;
      p_sel    : in  std_logic_vector(1 downto 0); -- select which piece of the pipeline will be used
      -- result out
      r        : out std_logic_vector((n-1) downto 0)
    );
  end component sys_pipeline;
  
  component mont_multiplier is
  generic (
    n     : integer := 1536;  -- width of the operands
    t     : integer := 96;    -- total number of stages (minimum 2)
    tl    : integer := 32;    -- lower number of stages (minimum 1)
    split : boolean := true   -- if true the pipeline wil be split in 2 parts,
                              -- if false there are no lower stages, only t counts
  );
  port (
    -- clock input
    core_clk : in std_logic;
    -- operand inputs
    xy       : in std_logic_vector((n-1) downto 0); -- bus for x or y operand
    m        : in std_logic_vector((n-1) downto 0); -- modulus
    -- result output
    r        : out std_logic_vector((n-1) downto 0);  -- result
    -- control signals
    start    : in std_logic;
    reset    : in std_logic;
    p_sel    : in std_logic_vector(1 downto 0);
    load_x   : in std_logic;
    ready    : out std_logic
  );
  end component mont_multiplier;


  ------------------------------ MEMORY ------------------------------
  
  -------------------------- xil_prim specific -----------------------
  --------------------------------------------------------------------
  -- operand_dp
  --------------------------------------------------------------------
  --    true dual port RAM 512x4, uses xilinx primitives
  --
  component operand_dp is
    port (
      clka  : in std_logic;
      wea   : in std_logic_vector(0 downto 0);
      addra : in std_logic_vector(5 downto 0);
      dina  : in std_logic_vector(31 downto 0);
      douta : out std_logic_vector(31 downto 0);
      clkb  : in std_logic;
      web   : in std_logic_vector(0 downto 0);
      addrb : in std_logic_vector(1 downto 0);
      dinb  : in std_logic_vector(511 downto 0);
      doutb : out std_logic_vector(511 downto 0)
    );
  end component operand_dp;
  
  --------------------------------------------------------------------
  -- operand_sp
  --------------------------------------------------------------------
  --    dual port RAM 512x2, uses xilinx primitives
  --
  component operands_sp is
    port (
      clka  : in std_logic;
      wea   : in std_logic_vector(0 downto 0);
      addra : in std_logic_vector(4 downto 0);
      dina  : in std_logic_vector(31 downto 0);
      douta : out std_logic_vector(511 downto 0)
    );
  end component operands_sp;
  
  --------------------------------------------------------------------
  -- fifo_primitive
  --------------------------------------------------------------------
  --    a xilinx fifo primitive wrapper
  -- 
  component fifo_primitive is
    port (
      pop_clk  : in  std_logic;
      push_clk : in  std_logic;
      din      : in  std_logic_vector (31 downto 0);
      dout     : out  std_logic_vector (31 downto 0);
      empty    : out  std_logic;
      full     : out  std_logic;
      push     : in  std_logic;
      pop      : in  std_logic;
      reset    : in std_logic;
      nopop    : out std_logic;
      nopush   : out std_logic
    );
  end component fifo_primitive;
  
  --------------------------------------------------------------------
  -- operand_ram
  --------------------------------------------------------------------
  --    RAM for the operands, fixed width of 1536-bit and depth of 4
  --    uses xilinx primitives
  --
  component operand_ram is
    port(
      -- global ports
      collision : out std_logic;
      -- bus side connections (32-bit serial)
      bus_clk       : in std_logic;
      operand_addr   : in std_logic_vector(5 downto 0);
      operand_in     : in std_logic_vector(31 downto 0);
      operand_in_sel : in std_logic_vector(1 downto 0);
      result_out     : out std_logic_vector(31 downto 0);
      write_operand  : in std_logic;
      -- multiplier side connections (1536 bit parallel)
      core_clk       : in std_logic;
      result_dest_op  : in std_logic_vector(1 downto 0);
      operand_out     : out std_logic_vector(1535 downto 0);
      operand_out_sel : in std_logic_vector(1 downto 0); -- controlled by bus side
      write_result    : in std_logic;
      result_in       : in std_logic_vector(1535 downto 0)
    );
  end component operand_ram;
  
  --------------------------------------------------------------------
  -- modulus_ram
  --------------------------------------------------------------------
  --    RAM for the modulus, fixed width of 1536-bit, uses xilinx primitives
  --
  component modulus_ram is
    port(
      clk           : in std_logic;
      modulus_addr  : in std_logic_vector(5 downto 0);
      write_modulus : in std_logic;
      modulus_in    : in std_logic_vector(31 downto 0);
      modulus_out   : out std_logic_vector(1535 downto 0)
    );
  end component modulus_ram;
  
  
  ------------------------- generic modules --------------------------
  
  --------------------------------------------------------------------
  -- dpram_generic
  --------------------------------------------------------------------
  --    behavorial description of a dual port ram with one 32-bit
  --    write port and one 32-bit read port
  -- 
  component dpram_generic is
    generic (
      depth : integer := 2
    );
    port  (
      -- write port A
      clkA   : in std_logic;
      waddrA : in std_logic_vector(log2(depth)-1 downto 0);
      weA    : in std_logic;
      dinA   : in std_logic_vector(31 downto 0);
      -- read port B
      clkB   : in std_logic;
      raddrB : in std_logic_vector(log2(depth)-1 downto 0);
      doutB  : out std_logic_vector(31 downto 0)
    );
  end component dpram_generic;
  
  --------------------------------------------------------------------
  -- tdpram_generic
  --------------------------------------------------------------------
  --    behavorial description of a true dual port ram with 2
  --    32-bit write/read ports
  -- 
  component tdpram_generic is
    generic (
      depth : integer := 9
    );
    port (
      -- port A
      clkA  : in std_logic;
      addrA : in std_logic_vector(log2(depth)-1 downto 0);
      weA   : in std_logic;
      dinA  : in std_logic_vector(31 downto 0);
      doutA : out std_logic_vector(31 downto 0);
      -- port B
      clkB  : in std_logic;
      addrB : in std_logic_vector(log2(depth)-1 downto 0);
      weB   : in std_logic;
      dinB  : in std_logic_vector(31 downto 0);
      doutB : out std_logic_vector(31 downto 0)
    );
  end component tdpram_generic;
  
  --------------------------------------------------------------------
  -- fifo_generic
  --------------------------------------------------------------------
  --    a behavorial implementation of a fifo that is designed to 
  --    infer blockram
  -- 
  component fifo_generic is
    generic (
      depth : integer := 32
    );
    port  (
      clk    : in  std_logic; -- clock input
      din    : in  std_logic_vector (31 downto 0); -- 32 bit input data for push
      dout   : out  std_logic_vector (31 downto 0); -- 32 bit output data for pop
      empty  : out  std_logic; -- empty flag, 1 when FIFO is empty
      full   : out  std_logic; -- full flag, 1 when FIFO is full
      push   : in  std_logic;  
      pop    : in  std_logic;
      reset  : in std_logic;
      nopop  : out std_logic;
      nopush : out std_logic
    );
  end component fifo_generic;
  
  --------------------------------------------------------------------
  -- modulus_ram_gen
  --------------------------------------------------------------------
  --    structural description of a RAM to hold the modulus, with 
  --    adjustable width and depth(nr of moduluses)
  --
  component modulus_ram_gen is
    generic(
      width : integer := 1536;  -- must be a multiple of 32
      depth : integer := 2      -- nr of moduluses
    );
    port(
        -- bus side
      bus_clk        : in std_logic;
      write_modulus  : in std_logic; -- write enable
      modulus_in_sel : in std_logic_vector(log2(depth)-1 downto 0); -- modulus operand to write to
      modulus_addr   : in std_logic_vector(log2((width)/32)-1 downto 0); -- modulus word(32-bit) address
      modulus_in     : in std_logic_vector(31 downto 0); -- modulus word data in
      modulus_sel    : in std_logic_vector(log2(depth)-1 downto 0); -- selects the modulus to use for multiplications
        -- multiplier side
      core_clk       : in std_logic;
      modulus_out    : out std_logic_vector(width-1 downto 0)
    );
  end component modulus_ram_gen;
  
  --------------------------------------------------------------------
  -- operand_ram_gen
  --------------------------------------------------------------------
  --    behavorial description of a RAM to hold the operands, with 
  --    adjustable width and depth(nr of operands)
  --
  component operand_ram_gen is
    generic(
      width : integer := 1536; -- width of the operands
      depth : integer := 4     -- nr of operands
    );
    port(
        -- global ports
      collision : out std_logic; -- 1 if simultaneous write on RAM
        -- bus side connections (32-bit serial)
      bus_clk        : in std_logic;
      write_operand  : in std_logic; -- write_enable
      operand_in_sel : in std_logic_vector(log2(depth)-1 downto 0); -- operand to write to
      operand_addr   : in std_logic_vector(log2(width/32)-1 downto 0); -- address of operand word to write
      operand_in     : in std_logic_vector(31 downto 0);  -- operand word(32-bit) to write
      result_out     : out std_logic_vector(31 downto 0); -- operand out, reading is always result operand
      operand_out_sel : in std_logic_vector(log2(depth)-1 downto 0); -- operand to give to multiplier
        -- multiplier side connections (width-bit parallel)
      core_clk        : in std_logic;
      result_dest_op  : in std_logic_vector(log2(depth)-1 downto 0); -- operand select for result
      operand_out     : out std_logic_vector(width-1 downto 0); -- operand out to multiplier
      write_result    : in std_logic; -- write enable for multiplier side
      result_in       : in std_logic_vector(width-1 downto 0) -- result to write from multiplier
    );
  end component operand_ram_gen;
  
  
  
  ------------------------ asymmetric modules ------------------------
  
  --------------------------------------------------------------------
  -- dpram_asym
  --------------------------------------------------------------------
  --    behavorial description of an asymmetric dual port ram
  --    with one (wrwidth)-bit write port and one 32-bit read
  --    port. Made using the templates of xilinx and altera for
  --    asymmetric ram.
  --
  component dpram_asym is
    generic (
      rddepth : integer := 4; -- nr of 32-bit words
      wrwidth : integer := 2; -- write width, must be smaller than or equal to 32
      device  : string  := "xilinx"  -- device template to use
    );
    port (
      -- write port
      clkA   : in std_logic;
      waddrA : in std_logic_vector(log2((rddepth*32)/wrwidth)-1 downto 0);
      weA    : in std_logic;
      dinA   : in std_logic_vector(wrwidth-1 downto 0);
      -- read port
      clkB   : in std_logic;
      raddrB : in std_logic_vector(log2(rddepth)-1 downto 0);
      doutB  : out std_logic_vector(31 downto 0)
    );
  end component dpram_asym;
  
  --------------------------------------------------------------------
  -- dpramblock_asym
  --------------------------------------------------------------------
  --    structural description of an asymmetric dual port ram
  --    with one 32-bit write port and one (width)-bit read
  --    port.
  -- 
  component dpramblock_asym is
    generic (
      width  : integer := 256;  -- read width
      depth  : integer := 2;    -- nr of (width)-bit words
      device : string  := "xilinx"
    );
    port (
      -- write port A
      clkA   : in std_logic;
      waddrA : in std_logic_vector(log2((width*depth)/32)-1 downto 0);
      weA    : in std_logic;
      dinA   : in std_logic_vector(31 downto 0);
      -- read port B
      clkB   : in std_logic;
      raddrB : in std_logic_vector(log2(depth)-1 downto 0);
      doutB  : out std_logic_vector(width-1 downto 0)
    );
  end component dpramblock_asym;
  
  --------------------------------------------------------------------
  -- tdpram_asym
  --------------------------------------------------------------------
  --    behavorial description of an asymmetric true dual port
  --    ram with one (widthA)-bit read/write port and one 32-bit
  --    read/write port. Made using the templates of xilinx and
  --    altera for asymmetric ram.
  --
  component tdpram_asym is
    generic (
      depthB : integer := 4; -- nr of 32-bit words
      widthA : integer := 2;  -- port A width, must be smaller than or equal to 32
      device : string  := "xilinx"
    );
    port  (
      -- port A (widthA)-bit
      clkA  : in std_logic;
      addrA : in std_logic_vector(log2((depthB*32)/widthA)-1 downto 0);
      weA   : in std_logic;
      dinA  : in std_logic_vector(widthA-1 downto 0);
      doutA : out std_logic_vector(widthA-1 downto 0);
      -- port B 32-bit
      clkB  : in std_logic;
      addrB : in std_logic_vector(log2(depthB)-1 downto 0);
      weB   : in std_logic;
      dinB  : in std_logic_vector(31 downto 0);
      doutB : out std_logic_vector(31 downto 0)
    );
  end component tdpram_asym;
  
  --------------------------------------------------------------------
  -- tdpramblock_asym
  --------------------------------------------------------------------
  --    structural description of an asymmetric true dual port
  --    ram with one 32-bit read/write port and one (width)-bit
  --    read/write port.
  --
  component tdpramblock_asym is
    generic (
      depth  : integer := 4;    -- nr of (width)-bit words
      width  : integer := 512;  -- width of portB
      device : string  := "xilinx"
    );
    port (
      -- port A 32-bit
      clkA  : in std_logic;
      addrA : in std_logic_vector(log2((width*depth)/32)-1 downto 0);
      weA   : in std_logic;
      dinA  : in std_logic_vector(31 downto 0);
      doutA : out std_logic_vector(31 downto 0);
      -- port B (width)-bit
      clkB  : in std_logic;
      addrB : in std_logic_vector(log2(depth)-1 downto 0);
      weB   : in std_logic;
      dinB  : in std_logic_vector(width-1 downto 0);
      doutB : out std_logic_vector(width-1 downto 0)
    );
  end component tdpramblock_asym;
  
  --------------------------------------------------------------------
  -- modulus_ram_asym
  --------------------------------------------------------------------
  --    BRAM memory and logic to store the modulus, due to the
  --    achitecture, a minimum depth of 2 is needed for this
  --    module to be inferred into blockram, this version is
  --    slightly more performant than modulus_ram_gen and uses
  --    less resources. but does not work on every fpga, only
  --    the ones that support asymmetric rams.
  --
  component modulus_ram_asym is
    generic(
      width : integer := 1536;  -- must be a multiple of 32
      depth : integer := 2;     -- nr of moduluses
      device : string := "xilinx"
    );
    port(
        -- bus side
      bus_clk        : in std_logic;
      write_modulus  : in std_logic; -- write enable
      modulus_in_sel : in std_logic_vector(log2(depth)-1 downto 0); -- modulus operand to write to
      modulus_addr   : in std_logic_vector(log2((width)/32)-1 downto 0); -- modulus word(32-bit) address
      modulus_in     : in std_logic_vector(31 downto 0); -- modulus word data in
      modulus_sel    : in std_logic_vector(log2(depth)-1 downto 0); -- selects the modulus to use for multiplications
        -- multiplier side
      core_clk       : in std_logic;
      modulus_out    : out std_logic_vector(width-1 downto 0)
    );
  end component modulus_ram_asym;
  
  --------------------------------------------------------------------
  -- operand_ram_asym
  --------------------------------------------------------------------
  --    BRAM memory and logic to store the operands, due to the
  --    achitecture, a minimum depth of 2 is needed for this
  --    module to be inferred into blockram, this version is
  --    slightly more performant than operand_ram_gen and uses
  --    less resources. but does not work on every fpga, only
  --    the ones that support asymmetric rams. 
  --
  component operand_ram_asym is
    generic(
      width  : integer := 1536; -- width of the operands
      depth  : integer := 4;    -- nr of operands
      device : string  := "xilinx"
    );
    port(
        -- global ports
      collision : out std_logic; -- 1 if simultaneous write on RAM
        -- bus side connections (32-bit serial)
      bus_clk        : in std_logic;
      write_operand  : in std_logic; -- write_enable
      operand_in_sel : in std_logic_vector(log2(depth)-1 downto 0); -- operand to write to
      operand_addr   : in std_logic_vector(log2(width/32)-1 downto 0); -- address of operand word to write
      operand_in     : in std_logic_vector(31 downto 0);  -- operand word(32-bit) to write
      result_out     : out std_logic_vector(31 downto 0); -- operand out, reading is always result operand
      operand_out_sel : in std_logic_vector(log2(depth)-1 downto 0); -- operand to give to multiplier
        -- multiplier side connections (width-bit parallel)
      core_clk        : in std_logic;
      result_dest_op  : in std_logic_vector(log2(depth)-1 downto 0); -- operand select for result
      operand_out     : out std_logic_vector(width-1 downto 0); -- operand out to multiplier
      write_result    : in std_logic; -- write enable for multiplier side
      result_in       : in std_logic_vector(width-1 downto 0) -- result to write from multiplier
    );
  end component operand_ram_asym;
  
  --------------------------------------------------------------------
  -- operand_mem
  --------------------------------------------------------------------
  --    RAM memory and logic to the store operands and the
  --    modulus for the montgomery multiplier, the user has a
  --    choise between 3 memory styles, more detail in the
  --    documentation.
  --
  --    address structure:
  --    bit: highest   ->  '1': modulus
  --                       '0': operands
  --    bits: (highest-1)-log2(width/32) -> operand_in_sel in case of highest bit = '0'
  --                                        modulus_in_sel in case of highest bit = '1'
  --    bits: (log2(width/32)-1)-0 -> modulus_addr / operand_addr resp.
  -- 
  component operand_mem is
    generic(
      width     : integer := 1536; -- width of the operands
      nr_op     : integer := 4; -- nr of operand storages, has to be greater than nr_m
      nr_m      : integer := 2; -- nr of modulus storages
      mem_style : string  := "asym"; -- xil_prim, generic, asym are valid options
      device    : string  := "altera"   -- xilinx, altera are valid options
    );
    port(
      -- data interface (plb side)
      bus_clk      : in std_logic;
      data_in      : in std_logic_vector(31 downto 0);
      data_out     : out std_logic_vector(31 downto 0);
      rw_address   : in std_logic_vector(8 downto 0);
      write_enable : in std_logic;
      -- operand interface (multiplier side)
      core_clk  : in std_logic;
      op_sel    : in std_logic_vector(log2(nr_op)-1 downto 0);
      xy_out    : out std_logic_vector((width-1) downto 0);
      m         : out std_logic_vector((width-1) downto 0);
      result_in : in std_logic_vector((width-1) downto 0);
      -- control signals
      load_result    : in std_logic;
      result_dest_op : in std_logic_vector(log2(nr_op)-1 downto 0);
      collision      : out std_logic;
      modulus_sel    : in std_logic_vector(log2(nr_m)-1 downto 0)
    );
  end component operand_mem;
  
  
  ---------------------- CLOCK DOMAIN CROSSING  ----------------------
  
  --------------------------------------------------------------------
  -- pulse_cdc
  --------------------------------------------------------------------
  --    transfers a pulse (1clk wide) from clock domain A to clock domain B
  --    by using a toggling signal. This design avoids metastable states
  -- 
  component pulse_cdc is
    port (
      reset  : in std_logic;
      clkA   : in std_logic;
      pulseA : in std_logic;
      clkB   : in std_logic;
      pulseB : out std_logic
    );
  end component pulse_cdc;
  
  --------------------------------------------------------------------
  -- clk_sync
  --------------------------------------------------------------------
  --    transfers a signal from clock domain A to clock domain B. 
  --    This design avoids metastable states
  -- 
  component clk_sync is
    port (
      sigA : in std_logic;
      clkB : in std_logic;
      sigB : out std_logic
    );
  end component clk_sync;
  
  
  ---------------------------- TOP LEVEL -----------------------------
  
  --------------------------------------------------------------------
  -- mod_sim_exp_core
  --------------------------------------------------------------------
  --    toplevel of the modular simultaneous exponentiation core
  --    contains an operand and modulus ram, multiplier, an exponent fifo
  --    and control logic
  -- 
  component mod_sim_exp_core is
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
      modulus_sel    : in  std_logic   -- selects which modulus to use for multiplications
    );
  end component mod_sim_exp_core;

  
end package mod_sim_exp_pkg;