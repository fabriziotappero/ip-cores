-- PicoBlaze
--
-- Constant (K) Coded Programmable State Machine for Spartan-3 Devices.
-- Also suitable for use with Virtex-II(PRO) and Virtex-4 devices.
--
-- Includes additional code for enhanced VHDL simulation. 
--
-- Version : 1.30 
-- Version Date : 14th June 2004
-- Reasons : Avoid issue caused when ENABLE INTERRUPT is used when interrupts are
--           already enabled when an an interrupt input is applied.
--           Improved design for faster ZERO and CARRY flag logic   
--
--
-- Previous Version : 1.20 
-- Version Date : 9th July 2003
--
-- Start of design entry : 19th May 2003
--
-- Ken Chapman
-- Xilinx Ltd
-- Benchmark House
-- 203 Brooklands Road
-- Weybridge
-- Surrey KT13 ORH
-- United Kingdom
--
-- chapman@xilinx.com
--
-- Instruction disassembly concept inspired by the work of Prof. Dr.-Ing. Bernhard Lang.
-- University of Applied Sciences, Osnabrueck, Germany.
--
------------------------------------------------------------------------------------
--
-- NOTICE:
--
-- Copyright Xilinx, Inc. 2003.   This code may be contain portions patented by other 
-- third parties.  By providing this core as one possible implementation of a standard,
-- Xilinx is making no representation that the provided implementation of this standard 
-- is free from any claims of infringement by any third party.  Xilinx expressly 
-- disclaims any warranty with respect to the adequacy of the implementation, including 
-- but not limited to any warranty or representation that the implementation is free 
-- from claims of any third party.  Furthermore, Xilinx is providing this core as a 
-- courtesy to you and suggests that you contact all third parties to obtain the 
-- necessary rights to use this implementation.
--
------------------------------------------------------------------------------------
--
-- Format of this file.
--
-- This file contains the definition of KCPSM3 as one complete module with sections 
-- created using generate loops. This 'flat' approach has been adopted to decrease 
-- the time taken to load the module into simulators and the synthesis process.
--
-- The module defines the implementation of the logic using Xilinx primitives.
-- These ensure predictable synthesis results and maximise the density of the implementation. 
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
-- 
------------------------------------------------------------------------------------
--
-- Library declarations
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
------------------------------------------------------------------------------------
--
-- Main Entity for KCPSM3
--
entity kcpsm3 is
    Port (      address : out std_logic_vector(9 downto 0);
            instruction : in std_logic_vector(17 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end kcpsm3;
--
------------------------------------------------------------------------------------
--
-- Start of Main Architecture for KCPSM3
--	 
architecture low_level_definition of kcpsm3 is
--
------------------------------------------------------------------------------------
--
-- Signals used in KCPSM3
--
------------------------------------------------------------------------------------
--
-- Fundamental control and decode signals
--	 
signal t_state                : std_logic;
signal not_t_state            : std_logic;
signal internal_reset         : std_logic;
signal reset_delay            : std_logic;
signal move_group             : std_logic;
signal condition_met          : std_logic;
signal normal_count           : std_logic;
signal call_type              : std_logic;
signal push_or_pop_type       : std_logic;
signal valid_to_move          : std_logic;
--
-- Flag signals
-- 
signal flag_type              : std_logic;
signal flag_write             : std_logic;
signal flag_enable            : std_logic;
signal zero_flag              : std_logic;
signal sel_shadow_zero        : std_logic;
signal low_zero               : std_logic;
signal high_zero              : std_logic;
signal low_zero_carry         : std_logic;
signal high_zero_carry        : std_logic;
signal zero_carry             : std_logic;
signal zero_fast_route        : std_logic;
signal low_parity             : std_logic;
signal high_parity            : std_logic;
signal parity_carry           : std_logic;
signal parity                 : std_logic;
signal carry_flag             : std_logic;
signal sel_parity             : std_logic;
signal sel_arith_carry        : std_logic;
signal sel_shift_carry        : std_logic;
signal sel_shadow_carry       : std_logic;
signal sel_carry              : std_logic_vector(3 downto 0);
signal carry_fast_route       : std_logic;
--
-- Interrupt signals
-- 
signal active_interrupt       : std_logic;
signal int_pulse              : std_logic;
signal clean_int              : std_logic;
signal shadow_carry           : std_logic;
signal shadow_zero            : std_logic;
signal int_enable             : std_logic;
signal int_update_enable      : std_logic;
signal int_enable_value       : std_logic;
signal interrupt_ack_internal : std_logic;
--
-- Program Counter signals
--
signal pc                     : std_logic_vector(9 downto 0);
signal pc_vector              : std_logic_vector(9 downto 0);
signal pc_vector_carry        : std_logic_vector(8 downto 0);
signal inc_pc_vector          : std_logic_vector(9 downto 0);
signal pc_value               : std_logic_vector(9 downto 0);
signal pc_value_carry         : std_logic_vector(8 downto 0);
signal inc_pc_value           : std_logic_vector(9 downto 0);
signal pc_enable              : std_logic;
--
-- Data Register signals
--
signal sx                     : std_logic_vector(7 downto 0);
signal sy                     : std_logic_vector(7 downto 0);
signal register_type          : std_logic;
signal register_write         : std_logic;
signal register_enable        : std_logic;
signal second_operand         : std_logic_vector(7 downto 0);
--
-- Scratch Pad Memory signals
--
signal memory_data            : std_logic_vector(7 downto 0);
signal store_data             : std_logic_vector(7 downto 0);
signal memory_type            : std_logic;
signal memory_write           : std_logic;
signal memory_enable          : std_logic;
--
-- Stack signals
--
signal stack_pop_data         : std_logic_vector(9 downto 0);
signal stack_ram_data         : std_logic_vector(9 downto 0);
signal stack_address          : std_logic_vector(4 downto 0);
signal half_stack_address     : std_logic_vector(4 downto 0);
signal stack_address_carry    : std_logic_vector(3 downto 0);
signal next_stack_address     : std_logic_vector(4 downto 0);
signal stack_write_enable     : std_logic;
signal not_active_interrupt   : std_logic;
--
-- ALU signals
--
signal logical_result         : std_logic_vector(7 downto 0);
signal logical_value          : std_logic_vector(7 downto 0);
signal sel_logical            : std_logic;
signal shift_result           : std_logic_vector(7 downto 0);
signal shift_value            : std_logic_vector(7 downto 0);
signal sel_shift              : std_logic;
signal high_shift_in          : std_logic;
signal low_shift_in           : std_logic;
signal shift_in               : std_logic;
signal shift_carry            : std_logic;
signal shift_carry_value      : std_logic;
signal arith_result           : std_logic_vector(7 downto 0);
signal arith_value            : std_logic_vector(7 downto 0);
signal half_arith             : std_logic_vector(7 downto 0);
signal arith_internal_carry   : std_logic_vector(7 downto 0);
signal sel_arith_carry_in     : std_logic;
signal arith_carry_in         : std_logic;
signal invert_arith_carry     : std_logic;
signal arith_carry_out        : std_logic;
signal sel_arith              : std_logic;
signal arith_carry            : std_logic;
--
-- ALU multiplexer signals
--
signal input_fetch_type       : std_logic;
signal sel_group              : std_logic;
signal alu_group              : std_logic_vector(7 downto 0);
signal input_group            : std_logic_vector(7 downto 0);
signal alu_result             : std_logic_vector(7 downto 0);
--
-- read and write strobes 
--
signal io_initial_decode      : std_logic;
signal write_active           : std_logic;
signal read_active            : std_logic;
--
--
------------------------------------------------------------------------------------
--
-- Attributes to define LUT contents during implementation for primitives not 
-- contained within generate loops. In each case the information is repeated
-- in the generic map for functional simulation
--
attribute INIT : string; 
attribute INIT of t_state_lut           : label is "1"; 
attribute INIT of int_pulse_lut         : label is "0080";
attribute INIT of int_update_lut        : label is "EAAA";
attribute INIT of int_value_lut         : label is "04";
attribute INIT of move_group_lut        : label is "7400";
attribute INIT of condition_met_lut     : label is "5A3C";
attribute INIT of normal_count_lut      : label is "2F";
attribute INIT of call_type_lut         : label is "1000";
attribute INIT of push_pop_lut          : label is "5400";
attribute INIT of valid_move_lut        : label is "D";
attribute INIT of flag_type_lut         : label is "41FC";
attribute INIT of flag_enable_lut       : label is "8";
attribute INIT of low_zero_lut          : label is "0001";
attribute INIT of high_zero_lut         : label is "0001";
attribute INIT of sel_shadow_zero_lut   : label is "3F";
attribute INIT of low_parity_lut        : label is "6996";
attribute INIT of high_parity_lut       : label is "6996";
attribute INIT of sel_parity_lut        : label is "F3FF";
attribute INIT of sel_arith_carry_lut   : label is "F3";
attribute INIT of sel_shift_carry_lut   : label is "C";
attribute INIT of sel_shadow_carry_lut  : label is "3";
attribute INIT of register_type_lut     : label is "0145";
attribute INIT of register_enable_lut   : label is "8";
attribute INIT of memory_type_lut       : label is "0400";
attribute INIT of memory_enable_lut     : label is "8000";
attribute INIT of sel_logical_lut       : label is "FFE2";
attribute INIT of low_shift_in_lut      : label is "E4";
attribute INIT of high_shift_in_lut     : label is "E4";
attribute INIT of shift_carry_lut       : label is "E4";
attribute INIT of sel_arith_lut         : label is "1F";
attribute INIT of input_fetch_type_lut  : label is "0002";
attribute INIT of io_decode_lut         : label is "0010";
attribute INIT of write_active_lut      : label is "4000";
attribute INIT of read_active_lut       : label is "0100";
--
------------------------------------------------------------------------------------
--
-- Start of KCPSM3 circuit description
--
------------------------------------------------------------------------------------
--	
begin
--
------------------------------------------------------------------------------------
--
-- Fundamental Control
--
-- Definition of T-state and internal reset
--
------------------------------------------------------------------------------------
--
  t_state_lut: LUT1
  --synthesis translate_off
    generic map (INIT => X"1")
  --synthesis translate_on
  port map( I0 => t_state,
             O => not_t_state );

  toggle_flop: FDR
  port map ( D => not_t_state,
             Q => t_state,
             R => internal_reset,
             C => clk);

  reset_flop1: FDS
  port map ( D => '0',
             Q => reset_delay,
             S => reset,
             C => clk);

  reset_flop2: FDS
  port map ( D => reset_delay,
             Q => internal_reset,
             S => reset,
             C => clk);
--
------------------------------------------------------------------------------------
--
-- Interrupt input logic, Interrupt enable and shadow Flags.
--	
-- Captures interrupt input and enables the shadow flags.
-- Decodes instructions which set and reset the interrupt enable flip-flop. 
--
------------------------------------------------------------------------------------
--

  -- Interrupt capture

  int_capture_flop: FDR
  port map ( D => interrupt,
             Q => clean_int,
             R => internal_reset,
             C => clk);

  int_pulse_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"0080")
  --synthesis translate_on
  port map( I0 => t_state,
            I1 => clean_int,
            I2 => int_enable,
            I3 => active_interrupt,
             O => int_pulse );

  int_flop: FDR
  port map ( D => int_pulse,
             Q => active_interrupt,
             R => internal_reset,
             C => clk);

  ack_flop: FD
  port map ( D => active_interrupt,
             Q => interrupt_ack_internal,
             C => clk);

  interrupt_ack <= interrupt_ack_internal;

  -- Shadow flags

  shadow_carry_flop: FDE
  port map ( D => carry_flag,
             Q => shadow_carry,
            CE => active_interrupt,
             C => clk);

  shadow_zero_flop: FDE
  port map ( D => zero_flag,
             Q => shadow_zero,
            CE => active_interrupt,
             C => clk);

  -- Decode instructions that set or reset interrupt enable

  int_update_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"EAAA")
  --synthesis translate_on
  port map( I0 => active_interrupt,
            I1 => instruction(15),
            I2 => instruction(16),
            I3 => instruction(17),
             O => int_update_enable );

  int_value_lut: LUT3
  --synthesis translate_off
    generic map (INIT => X"04")
  --synthesis translate_on
  port map( I0 => active_interrupt,
            I1 => instruction(0),
            I2 => interrupt_ack_internal,
             O => int_enable_value );

  int_enable_flop: FDRE
  port map ( D => int_enable_value,
             Q => int_enable,
            CE => int_update_enable,
             R => internal_reset,
             C => clk);
--
------------------------------------------------------------------------------------
--
-- Decodes for the control of the program counter and CALL/RETURN stack
--
------------------------------------------------------------------------------------
--
  move_group_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"7400")
  --synthesis translate_on
  port map( I0 => instruction(14),
            I1 => instruction(15),
            I2 => instruction(16),
            I3 => instruction(17),
             O => move_group );

  condition_met_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"5A3C")
  --synthesis translate_on
  port map( I0 => carry_flag,
            I1 => zero_flag,
            I2 => instruction(10),
            I3 => instruction(11),
             O => condition_met );

  normal_count_lut: LUT3
  --synthesis translate_off
    generic map (INIT => X"2F")
  --synthesis translate_on
  port map( I0 => instruction(12),
            I1 => condition_met,
            I2 => move_group,
             O => normal_count );

  call_type_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"1000")
  --synthesis translate_on
  port map( I0 => instruction(14),
            I1 => instruction(15),
            I2 => instruction(16),
            I3 => instruction(17),
             O => call_type );

  push_pop_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"5400")
  --synthesis translate_on
  port map( I0 => instruction(14),
            I1 => instruction(15),
            I2 => instruction(16),
            I3 => instruction(17),
             O => push_or_pop_type );

  valid_move_lut: LUT2
  --synthesis translate_off
    generic map (INIT => X"D")
  --synthesis translate_on
  port map( I0 => instruction(12),
            I1 => condition_met,
             O => valid_to_move );
--
------------------------------------------------------------------------------------
--
-- The ZERO and CARRY Flags
--
------------------------------------------------------------------------------------
--
  -- Enable for flags

  flag_type_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"41FC")
  --synthesis translate_on
  port map( I0 => instruction(14),
            I1 => instruction(15),
            I2 => instruction(16),
            I3 => instruction(17),
             O => flag_type );

  flag_write_flop: FD
  port map ( D => flag_type,
             Q => flag_write,
             C => clk);

  flag_enable_lut: LUT2
  --synthesis translate_off
    generic map (INIT => X"8")
  --synthesis translate_on
  port map( I0 => t_state,
            I1 => flag_write,
             O => flag_enable );

  -- Zero Flag

  low_zero_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"0001")
  --synthesis translate_on
  port map( I0 => alu_result(0),
            I1 => alu_result(1),
            I2 => alu_result(2),
            I3 => alu_result(3),
             O => low_zero );

  high_zero_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"0001")
  --synthesis translate_on
  port map( I0 => alu_result(4),
            I1 => alu_result(5),
            I2 => alu_result(6),
            I3 => alu_result(7),
             O => high_zero );

  low_zero_muxcy: MUXCY
  port map( DI => '0',
            CI => '1',
             S => low_zero,
             O => low_zero_carry );

  high_zero_cymux: MUXCY
  port map( DI => '0',
            CI => low_zero_carry,
             S => high_zero,
             O => high_zero_carry );

  sel_shadow_zero_lut: LUT3
  --synthesis translate_off
    generic map (INIT => X"3F")
  --synthesis translate_on
  port map( I0 => shadow_zero,
            I1 => instruction(16),
            I2 => instruction(17),
             O => sel_shadow_zero );

  zero_cymux: MUXCY
  port map( DI => shadow_zero,
            CI => high_zero_carry,
             S => sel_shadow_zero,
             O => zero_carry );

  zero_xor: XORCY
  port map( LI => '0',
            CI => zero_carry,
             O => zero_fast_route);

  zero_flag_flop: FDRE
  port map ( D => zero_fast_route,
             Q => zero_flag,
            CE => flag_enable,
             R => internal_reset,
             C => clk);

  -- Parity detection

  low_parity_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"6996")
  --synthesis translate_on
  port map( I0 => logical_result(0),
            I1 => logical_result(1),
            I2 => logical_result(2),
            I3 => logical_result(3),
             O => low_parity );

  high_parity_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"6996")
  --synthesis translate_on
  port map( I0 => logical_result(4),
            I1 => logical_result(5),
            I2 => logical_result(6),
            I3 => logical_result(7),
             O => high_parity );

  parity_muxcy: MUXCY
  port map( DI => '0',
            CI => '1',
             S => low_parity,
             O => parity_carry );

  parity_xor: XORCY
  port map( LI => high_parity,
            CI => parity_carry,
             O => parity);

  -- CARRY flag selection

  sel_parity_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"F3FF")
  --synthesis translate_on
  port map( I0 => parity,
            I1 => instruction(13),
            I2 => instruction(15),
            I3 => instruction(16),
             O => sel_parity );

  sel_arith_carry_lut: LUT3
  --synthesis translate_off
    generic map (INIT => X"F3")
  --synthesis translate_on
  port map( I0 => arith_carry,
            I1 => instruction(16),
            I2 => instruction(17),
             O => sel_arith_carry );

  sel_shift_carry_lut: LUT2
  --synthesis translate_off
    generic map (INIT => X"C")
  --synthesis translate_on
  port map( I0 => shift_carry,
            I1 => instruction(15),
             O => sel_shift_carry );

  sel_shadow_carry_lut: LUT2
  --synthesis translate_off
    generic map (INIT => X"3")
  --synthesis translate_on
  port map( I0 => shadow_carry,
            I1 => instruction(17),
             O => sel_shadow_carry );

  sel_shadow_muxcy: MUXCY
  port map( DI => shadow_carry,
            CI => '0',
             S => sel_shadow_carry,
             O => sel_carry(0) );

  sel_shift_muxcy: MUXCY
  port map( DI => shift_carry,
            CI => sel_carry(0),
             S => sel_shift_carry,
             O => sel_carry(1) );

  sel_arith_muxcy: MUXCY
  port map( DI => arith_carry,
            CI => sel_carry(1),
             S => sel_arith_carry,
             O => sel_carry(2) );

  sel_parity_muxcy: MUXCY
  port map( DI => parity,
            CI => sel_carry(2),
             S => sel_parity,
             O => sel_carry(3) );

  carry_xor: XORCY
  port map( LI => '0',
            CI => sel_carry(3),
             O => carry_fast_route);

  carry_flag_flop: FDRE
  port map ( D => carry_fast_route,
             Q => carry_flag,
            CE => flag_enable,
             R => internal_reset,
             C => clk);
--
------------------------------------------------------------------------------------
--
-- The Program Counter
--
-- Definition of a 10-bit counter which can be loaded from two sources
--
------------------------------------------------------------------------------------
--	

  invert_enable: INV   -- Inverter should be implemented in the CE to flip flops
  port map(  I => t_state,
             O => pc_enable);  
 
  pc_loop: for i in 0 to 9 generate
  --
  -- Attribute to define LUT contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  --
  attribute INIT : string; 
  attribute INIT of vector_select_mux : label is "E4";
  attribute INIT of value_select_mux  : label is "E4";
  --
  begin

    vector_select_mux: LUT3
    --synthesis translate_off
      generic map (INIT => X"E4")
    --synthesis translate_on
    port map( I0 => instruction(15),
              I1 => instruction(i),
              I2 => stack_pop_data(i), 
               O => pc_vector(i) );

    value_select_mux: LUT3
    --synthesis translate_off
      generic map (INIT => X"E4")
    --synthesis translate_on
    port map( I0 => normal_count,
              I1 => inc_pc_vector(i),
              I2 => pc(i),
               O => pc_value(i) );

     register_bit: FDRSE
     port map ( D => inc_pc_value(i),
                Q => pc(i),
                R => internal_reset,
                S => active_interrupt,
               CE => pc_enable,
                C => clk);

     pc_lsb_carry: if i=0 generate
       begin

         pc_vector_muxcy: MUXCY
         port map( DI => '0',
                   CI => instruction(13),
                    S => pc_vector(i),
                    O => pc_vector_carry(i));

         pc_vector_xor: XORCY
         port map( LI => pc_vector(i),
                   CI => instruction(13),
                    O => inc_pc_vector(i));

         pc_value_muxcy: MUXCY
         port map( DI => '0',
                   CI => normal_count,
                    S => pc_value(i),
                    O => pc_value_carry(i));

         pc_value_xor: XORCY
         port map( LI => pc_value(i),
                   CI => normal_count,
                    O => inc_pc_value(i));
					   					   
       end generate pc_lsb_carry;

     pc_mid_carry: if i>0 and i<9 generate
	 begin

         pc_vector_muxcy: MUXCY
         port map( DI => '0',
                   CI => pc_vector_carry(i-1),
                    S => pc_vector(i),
                    O => pc_vector_carry(i));

         pc_vector_xor: XORCY
         port map( LI => pc_vector(i),
                   CI => pc_vector_carry(i-1),
                    O => inc_pc_vector(i));

         pc_value_muxcy: MUXCY
         port map( DI => '0',
                   CI => pc_value_carry(i-1),
                    S => pc_value(i),
                    O => pc_value_carry(i));

         pc_value_xor: XORCY
         port map( LI => pc_value(i),
                   CI => pc_value_carry(i-1),
                    O => inc_pc_value(i));

       end generate pc_mid_carry;

     pc_msb_carry: if i=9 generate
       begin

         pc_vector_xor: XORCY
         port map( LI => pc_vector(i),
                   CI => pc_vector_carry(i-1),
                    O => inc_pc_vector(i));

          pc_value_xor: XORCY
         port map( LI => pc_value(i),
                   CI => pc_value_carry(i-1),
                    O => inc_pc_value(i));

       end generate pc_msb_carry;

  end generate pc_loop;

  address <= pc;
--
------------------------------------------------------------------------------------
--
-- Register Bank and second operand selection.
--
-- Definition of an 8-bit dual port RAM with 16 locations 
-- including write enable decode.
--
-- Outputs are assigned to PORT_ID and OUT_PORT.
--
------------------------------------------------------------------------------------
--	
  -- Forming decode signal

  register_type_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"0145")
  --synthesis translate_on
  port map( I0 => active_interrupt,
            I1 => instruction(15),
            I2 => instruction(16),
            I3 => instruction(17),
             O => register_type );

  register_write_flop: FD
  port map ( D => register_type,
             Q => register_write,
             C => clk);

  register_enable_lut: LUT2
  --synthesis translate_off
    generic map (INIT => X"8")
  --synthesis translate_on
  port map( I0 => t_state,
            I1 => register_write,
             O => register_enable );

  reg_loop: for i in 0 to 7 generate
  --
  -- Attribute to define RAM contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  --
  attribute INIT : string; 
  attribute INIT of register_bit       : label is "0000"; 
  attribute INIT of operand_select_mux : label is "E4"; 
  --
  begin

    register_bit: RAM16X1D
    --synthesis translate_off
    generic map(INIT => X"0000")
    --synthesis translate_on
    port map (       D => alu_result(i),
                    WE => register_enable,
                  WCLK => clk,
                    A0 => instruction(8),
                    A1 => instruction(9),
                    A2 => instruction(10),
                    A3 => instruction(11),
                 DPRA0 => instruction(4),
                 DPRA1 => instruction(5),
                 DPRA2 => instruction(6),
                 DPRA3 => instruction(7),
                   SPO => sx(i),
                   DPO => sy(i));

    operand_select_mux: LUT3
    --synthesis translate_off
      generic map (INIT => X"E4")
    --synthesis translate_on
    port map( I0 => instruction(12),
              I1 => instruction(i),
              I2 => sy(i),
               O => second_operand(i) );

  end generate reg_loop;

  out_port <= sx;
  port_id <= second_operand;
--
------------------------------------------------------------------------------------
--
-- Store Memory
--
-- Definition of an 8-bit single port RAM with 64 locations 
-- including write enable decode.
--
------------------------------------------------------------------------------------
--	
  -- Forming decode signal

  memory_type_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"0400")
  --synthesis translate_on
  port map( I0 => active_interrupt,
            I1 => instruction(15),
            I2 => instruction(16),
            I3 => instruction(17),
             O => memory_type );

  memory_write_flop: FD
  port map ( D => memory_type,
             Q => memory_write,
             C => clk);

  memory_enable_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"8000")
  --synthesis translate_on
  port map( I0 => t_state,
            I1 => instruction(13),
            I2 => instruction(14),
            I3 => memory_write,
             O => memory_enable );

  store_loop: for i in 0 to 7 generate
  --
  -- Attribute to define RAM contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  --
  attribute INIT : string; 
  attribute INIT of memory_bit : label is "0000000000000000"; 
  --
  begin

    memory_bit: RAM64X1S
    --synthesis translate_off
    generic map(INIT => X"0000000000000000")
    --synthesis translate_on
    port map (       D => sx(i),
                    WE => memory_enable,
                  WCLK => clk,
                    A0 => second_operand(0),
                    A1 => second_operand(1),
                    A2 => second_operand(2),
                    A3 => second_operand(3),
                    A4 => second_operand(4),
                    A5 => second_operand(5),
                     O => memory_data(i));

    store_flop: FD
    port map ( D => memory_data(i),
               Q => store_data(i),
               C => clk);

  end generate store_loop;
--
------------------------------------------------------------------------------------
--
-- Logical operations
--
-- Definition of AND, OR, XOR and LOAD functions which also provides TEST.
-- Includes pipeline stage used to form ALU multiplexer including decode.
--
------------------------------------------------------------------------------------
--
  sel_logical_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"FFE2")
  --synthesis translate_on
  port map( I0 => instruction(14),
            I1 => instruction(15),
            I2 => instruction(16),
            I3 => instruction(17),
             O => sel_logical );

  logical_loop: for i in 0 to 7 generate
  --
  -- Attribute to define LUT contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  attribute INIT : string; 
  attribute INIT of logical_lut : label is "6E8A"; 
  --
  begin

    logical_lut: LUT4
    --synthesis translate_off
    generic map (INIT => X"6E8A")
    --synthesis translate_on
    port map( I0 => second_operand(i),
              I1 => sx(i),
              I2 => instruction(13),
              I3 => instruction(14),
               O => logical_value(i));

    logical_flop: FDR
    port map ( D => logical_value(i),
               Q => logical_result(i),
               R => sel_logical,
               C => clk);

  end generate logical_loop;
--
--
------------------------------------------------------------------------------------
--
-- Shift and Rotate operations
--
-- Includes pipeline stage used to form ALU multiplexer including decode.
--
------------------------------------------------------------------------------------
--
  sel_shift_inv: INV   -- Inverter should be implemented in the reset to flip flops
  port map(  I => instruction(17),
             O => sel_shift); 

  -- Bit to input to shift register

  high_shift_in_lut: LUT3
  --synthesis translate_off
    generic map (INIT => X"E4")
  --synthesis translate_on
  port map( I0 => instruction(1),
            I1 => sx(0),
            I2 => instruction(0),
             O => high_shift_in );

  low_shift_in_lut: LUT3
  --synthesis translate_off
    generic map (INIT => X"E4")
  --synthesis translate_on
  port map( I0 => instruction(1),
            I1 => carry_flag,
            I2 => sx(7),
             O => low_shift_in );

  shift_in_muxf5: MUXF5
  port map(  I1 => high_shift_in,
             I0 => low_shift_in,
              S => instruction(2),
              O => shift_in ); 

  -- Forming shift carry signal

  shift_carry_lut: LUT3
  --synthesis translate_off
    generic map (INIT => X"E4")
  --synthesis translate_on
  port map( I0 => instruction(3),
            I1 => sx(7),
            I2 => sx(0),
             O => shift_carry_value );
					   
  pipeline_bit: FD
  port map ( D => shift_carry_value,
             Q => shift_carry,
             C => clk);

  shift_loop: for i in 0 to 7 generate
  begin

    lsb_shift: if i=0 generate
    --
    -- Attribute to define LUT contents during implementation 
    -- The information is repeated in the generic map for functional simulation
    attribute INIT : string; 
    attribute INIT of shift_mux_lut : label is "E4";
    --
    begin

      shift_mux_lut: LUT3
      --synthesis translate_off
        generic map (INIT => X"E4")
      --synthesis translate_on
      port map( I0 => instruction(3),
                I1 => shift_in,
                I2 => sx(i+1),
                 O => shift_value(i) );
	   
    end generate lsb_shift;

    mid_shift: if i>0 and i<7 generate
    --
    -- Attribute to define LUT contents during implementation 
    -- The information is repeated in the generic map for functional simulation
    attribute INIT : string; 
    attribute INIT of shift_mux_lut : label is "E4";
    --
    begin

      shift_mux_lut: LUT3
      --synthesis translate_off
        generic map (INIT => X"E4")
      --synthesis translate_on
      port map( I0 => instruction(3),
                I1 => sx(i-1),
                I2 => sx(i+1),
                 O => shift_value(i) );
	   
    end generate mid_shift;

    msb_shift: if i=7 generate
    --
    -- Attribute to define LUT contents during implementation 
    -- The information is repeated in the generic map for functional simulation
    attribute INIT : string; 
    attribute INIT of shift_mux_lut : label is "E4";
    --
    begin

      shift_mux_lut: LUT3
      --synthesis translate_off
        generic map (INIT => X"E4")
      --synthesis translate_on
      port map( I0 => instruction(3),
                I1 => sx(i-1),
                I2 => shift_in,
                 O => shift_value(i) );
	   
    end generate msb_shift;

    shift_flop: FDR
    port map ( D => shift_value(i),
               Q => shift_result(i),
               R => sel_shift,
               C => clk);

  end generate shift_loop;
--
------------------------------------------------------------------------------------
--
-- Arithmetic operations
--
-- Definition of ADD, ADDCY, SUB and SUBCY functions which also provides COMPARE.
-- Includes pipeline stage used to form ALU multiplexer including decode.
--
------------------------------------------------------------------------------------
--
  sel_arith_lut: LUT3
  --synthesis translate_off
    generic map (INIT => X"1F")
  --synthesis translate_on
  port map( I0 => instruction(14),
            I1 => instruction(15),
            I2 => instruction(16),
             O => sel_arith );

  arith_loop: for i in 0 to 7 generate
  --
  -- Attribute to define LUT contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  attribute INIT : string; 
  attribute INIT of arith_lut : label is "96"; 
  --
  begin

    lsb_arith: if i=0 generate
    --
    -- Attribute to define LUT contents during implementation 
    -- The information is repeated in the generic map for functional simulation
    attribute INIT : string; 
    attribute INIT of arith_carry_in_lut : label is "6C";
    --
    begin

      arith_carry_in_lut: LUT3
      --synthesis translate_off
        generic map (INIT => X"6C")
      --synthesis translate_on
      port map( I0 => instruction(13),
                I1 => instruction(14),
                I2 => carry_flag,
                 O => sel_arith_carry_in );

      arith_carry_in_muxcy: MUXCY
      port map( DI => '0',
                CI => '1',
                 S => sel_arith_carry_in,
                 O => arith_carry_in);

      arith_muxcy: MUXCY
      port map( DI => sx(i),
                CI => arith_carry_in,
                 S => half_arith(i),
                 O => arith_internal_carry(i));

      arith_xor: XORCY
      port map( LI => half_arith(i),
                CI => arith_carry_in,
                 O => arith_value(i));
	   
    end generate lsb_arith;

    mid_arith: if i>0 and i<7 generate
    begin

      arith_muxcy: MUXCY
      port map( DI => sx(i),
                CI => arith_internal_carry(i-1),
                 S => half_arith(i),
                 O => arith_internal_carry(i));

      arith_xor: XORCY
      port map( LI => half_arith(i),
                CI => arith_internal_carry(i-1),
                 O => arith_value(i));
	   
    end generate mid_arith;

    msb_arith: if i=7 generate
    --
    -- Attribute to define LUT contents during implementation 
    -- The information is repeated in the generic map for functional simulation
    attribute INIT : string; 
    attribute INIT of arith_carry_out_lut : label is "2";
    --
    begin

      arith_muxcy: MUXCY
      port map( DI => sx(i),
                CI => arith_internal_carry(i-1),
                 S => half_arith(i),
                 O => arith_internal_carry(i));

      arith_xor: XORCY
      port map( LI => half_arith(i),
                CI => arith_internal_carry(i-1),
                 O => arith_value(i));

      arith_carry_out_lut: LUT1
      --synthesis translate_off
        generic map (INIT => X"2")
      --synthesis translate_on
      port map( I0 => instruction(14),
                 O => invert_arith_carry );

      arith_carry_out_xor: XORCY
      port map( LI => invert_arith_carry,
                CI => arith_internal_carry(i),
                 O => arith_carry_out);

      arith_carry_flop: FDR
      port map ( D => arith_carry_out,
                 Q => arith_carry,
                 R => sel_arith,
                 C => clk);

    end generate msb_arith;

    arith_lut: LUT3
    --synthesis translate_off
    generic map (INIT => X"96")
    --synthesis translate_on
    port map( I0 => sx(i),
              I1 => second_operand(i),
              I2 => instruction(14),
               O => half_arith(i));

    arith_flop: FDR
    port map ( D => arith_value(i),
               Q => arith_result(i),
               R => sel_arith,
               C => clk);

  end generate arith_loop;
--
--
------------------------------------------------------------------------------------
--
-- ALU multiplexer
--
------------------------------------------------------------------------------------
--
  input_fetch_type_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"0002")
  --synthesis translate_on
  port map( I0 => instruction(14),
            I1 => instruction(15),
            I2 => instruction(16),
            I3 => instruction(17),
             O => input_fetch_type );

  sel_group_flop: FD
  port map ( D => input_fetch_type,
             Q => sel_group,
             C => clk);

  alu_mux_loop: for i in 0 to 7 generate
  --
  -- Attribute to define LUT contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  attribute INIT : string; 
  attribute INIT of or_lut  : label is "FE"; 
  attribute INIT of mux_lut : label is "E4"; 
  --
  begin

    or_lut: LUT3
    --synthesis translate_off
    generic map (INIT => X"FE")
    --synthesis translate_on
    port map( I0 => logical_result(i),
              I1 => arith_result(i),
              I2 => shift_result(i),
               O => alu_group(i));

    mux_lut: LUT3
    --synthesis translate_off
    generic map (INIT => X"E4")
    --synthesis translate_on
    port map( I0 => instruction(13),
              I1 => in_port(i),
              I2 => store_data(i),
               O => input_group(i));

    shift_in_muxf5: MUXF5
    port map(  I1 => input_group(i),
               I0 => alu_group(i),
                S => sel_group,
                O => alu_result(i) ); 

  end generate alu_mux_loop;
--
------------------------------------------------------------------------------------
--
-- Read and Write Strobes
--
------------------------------------------------------------------------------------
--
  io_decode_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"0010")
  --synthesis translate_on
  port map( I0 => active_interrupt,
            I1 => instruction(13),
            I2 => instruction(14),
            I3 => instruction(16),
             O => io_initial_decode );

  write_active_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"4000")
  --synthesis translate_on
  port map( I0 => t_state,
            I1 => instruction(15),
            I2 => instruction(17),
            I3 => io_initial_decode,
             O => write_active );

  write_strobe_flop: FDR
  port map ( D => write_active,
             Q => write_strobe,
             R => internal_reset,
             C => clk);

  read_active_lut: LUT4
  --synthesis translate_off
    generic map (INIT => X"0100")
  --synthesis translate_on
  port map( I0 => t_state,
            I1 => instruction(15),
            I2 => instruction(17),
            I3 => io_initial_decode,
             O => read_active );

  read_strobe_flop: FDR
  port map ( D => read_active,
             Q => read_strobe,
             R => internal_reset,
             C => clk);
--
------------------------------------------------------------------------------------
--
-- Program CALL/RETURN stack
--
-- Provided the counter and memory for a 32 deep stack supporting nested 
-- subroutine calls to a depth of 31 levels.
--
------------------------------------------------------------------------------------
--
  -- Stack memory is 32 locations of 10-bit single port.
  
  stack_ram_inv: INV   -- Inverter should be implemented in the WE to RAM
  port map(  I => t_state,
             O => stack_write_enable); 

  stack_ram_loop: for i in 0 to 9 generate
  --
  -- Attribute to define RAM contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  --
  attribute INIT : string; 
  attribute INIT of stack_bit : label is "00000000"; 
  --
  begin

    stack_bit: RAM32X1S
    --synthesis translate_off
    generic map(INIT => X"00000000")
    --synthesis translate_on
    port map (       D => pc(i),
                    WE => stack_write_enable,
                  WCLK => clk,
                    A0 => stack_address(0),
                    A1 => stack_address(1),
                    A2 => stack_address(2),
                    A3 => stack_address(3),
                    A4 => stack_address(4),
                     O => stack_ram_data(i));

    stack_flop: FD
    port map ( D => stack_ram_data(i),
               Q => stack_pop_data(i),
               C => clk);

  end generate stack_ram_loop;

  -- Stack address pointer is a 5-bit counter

  stack_count_inv: INV   -- Inverter should be implemented in the CE to the flip-flops
  port map(  I => active_interrupt,
             O => not_active_interrupt); 

  stack_count_loop: for i in 0 to 4 generate
  begin
  
    register_bit: FDRE
    port map ( D => next_stack_address(i),
               Q => stack_address(i),
               R => internal_reset,
              CE => not_active_interrupt,
               C => clk);

    lsb_stack_count: if i=0 generate
    --
    -- Attribute to define LUT contents during implementation 
    -- The information is repeated in the generic map for functional simulation
    --
    attribute INIT : string; 
    attribute INIT of count_lut : label is "6555"; 
    --
    begin
    
      count_lut: LUT4
      --synthesis translate_off
      generic map (INIT => X"6555")
      --synthesis translate_on
      port map( I0 => stack_address(i),
                I1 => t_state,
                I2 => valid_to_move,
                I3 => push_or_pop_type,
                 O => half_stack_address(i) );
    
      count_muxcy: MUXCY
      port map( DI => stack_address(i),
                CI => '0',
                 S => half_stack_address(i),
                 O => stack_address_carry(i));
    
      count_xor: XORCY
      port map( LI => half_stack_address(i),
                CI => '0',
                 O => next_stack_address(i));
    				   					   
    end generate lsb_stack_count;

    mid_stack_count: if i>0 and i<4 generate
    --
    -- Attribute to define LUT contents during implementation 
    -- The information is repeated in the generic map for functional simulation
    --
    attribute INIT : string; 
    attribute INIT of count_lut : label is "A999"; 
    --
    begin
    
      count_lut: LUT4
      --synthesis translate_off
      generic map (INIT => X"A999")
      --synthesis translate_on
      port map( I0 => stack_address(i),
                I1 => t_state,
                I2 => valid_to_move,
                I3 => call_type,
                 O => half_stack_address(i) );
    
      count_muxcy: MUXCY
      port map( DI => stack_address(i),
                CI => stack_address_carry(i-1),
                 S => half_stack_address(i),
                 O => stack_address_carry(i));
    
      count_xor: XORCY
      port map( LI => half_stack_address(i),
                CI => stack_address_carry(i-1),
                 O => next_stack_address(i));
    				   					   
    end generate mid_stack_count;


    msb_stack_count: if i=4 generate
    --
    -- Attribute to define LUT contents during implementation 
    -- The information is repeated in the generic map for functional simulation
    --
    attribute INIT : string; 
    attribute INIT of count_lut : label is "A999"; 
    --
    begin
    
      count_lut: LUT4
      --synthesis translate_off
      generic map (INIT => X"A999")
      --synthesis translate_on
      port map( I0 => stack_address(i),
                I1 => t_state,
                I2 => valid_to_move,
                I3 => call_type,
                 O => half_stack_address(i) );
    
      count_xor: XORCY
      port map( LI => half_stack_address(i),
                CI => stack_address_carry(i-1),
                 O => next_stack_address(i));
    				   					   
    end generate msb_stack_count;

  end generate stack_count_loop;

--
------------------------------------------------------------------------------------
--
-- End of description for KCPSM3 macro.
--
------------------------------------------------------------------------------------
--
--**********************************************************************************
-- Code for simulation purposes only after this line
--**********************************************************************************
--
------------------------------------------------------------------------------------
--
-- Code for simulation.
--
-- Disassemble the instruction codes to form a text string variable for display.
-- Determine status of reset and flags and present in the form of a text string.
-- Provide a local variables to simulate the contents of each register and scratch 
-- pad memory location.
--
------------------------------------------------------------------------------------
--
  --All of this section is ignored during synthesis.
  --synthesis translate off

  simulation: process (clk, instruction)
  --
  --complete instruction decode
  --
  variable kcpsm3_opcode : string(1 to 19);
  --
  --Status of flags and processor
  --
  variable kcpsm3_status : string(1 to 13):= "NZ, NC, Reset";

  --
  --contents of each register
  --
  variable s0_contents : std_logic_vector(7 downto 0):=X"00";
  variable s1_contents : std_logic_vector(7 downto 0):=X"00";
  variable s2_contents : std_logic_vector(7 downto 0):=X"00";
  variable s3_contents : std_logic_vector(7 downto 0):=X"00";
  variable s4_contents : std_logic_vector(7 downto 0):=X"00";
  variable s5_contents : std_logic_vector(7 downto 0):=X"00";
  variable s6_contents : std_logic_vector(7 downto 0):=X"00";
  variable s7_contents : std_logic_vector(7 downto 0):=X"00";
  variable s8_contents : std_logic_vector(7 downto 0):=X"00";
  variable s9_contents : std_logic_vector(7 downto 0):=X"00";
  variable sa_contents : std_logic_vector(7 downto 0):=X"00";
  variable sb_contents : std_logic_vector(7 downto 0):=X"00";
  variable sc_contents : std_logic_vector(7 downto 0):=X"00";
  variable sd_contents : std_logic_vector(7 downto 0):=X"00";
  variable se_contents : std_logic_vector(7 downto 0):=X"00";
  variable sf_contents : std_logic_vector(7 downto 0):=X"00";
  --
  --contents of each scratch pad memory location
  --
  variable spm00_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm01_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm02_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm03_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm04_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm05_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm06_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm07_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm08_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm09_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm0a_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm0b_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm0c_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm0d_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm0e_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm0f_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm10_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm11_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm12_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm13_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm14_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm15_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm16_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm17_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm18_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm19_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm1a_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm1b_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm1c_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm1d_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm1e_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm1f_contents : std_logic_vector(7 downto 0):=X"00";  
  variable spm20_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm21_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm22_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm23_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm24_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm25_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm26_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm27_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm28_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm29_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm2a_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm2b_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm2c_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm2d_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm2e_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm2f_contents : std_logic_vector(7 downto 0):=X"00";  
  variable spm30_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm31_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm32_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm33_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm34_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm35_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm36_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm37_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm38_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm39_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm3a_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm3b_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm3c_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm3d_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm3e_contents : std_logic_vector(7 downto 0):=X"00";
  variable spm3f_contents : std_logic_vector(7 downto 0):=X"00";
  --
  --temporary variables
  --
  variable     sx_decode : string(1 to 2);                     --sX register specification
  variable     sy_decode : string(1 to 2);                     --sY register specification
  variable     kk_decode : string(1 to 2);                     --constant value specification
  variable    aaa_decode : string(1 to 3);                     --address specification
  --
  --------------------------------------------------------------------------------
  --
  -- Function to convert 4-bit binary nibble to hexadecimal character
  --
  --------------------------------------------------------------------------------
  --
  function hexcharacter (nibble: std_logic_vector(3 downto 0))
  return character is
  variable hex: character;
  begin
    case nibble is
      when "0000" => hex := '0';
      when "0001" => hex := '1';
      when "0010" => hex := '2';
      when "0011" => hex := '3';
      when "0100" => hex := '4';
      when "0101" => hex := '5';
      when "0110" => hex := '6';
      when "0111" => hex := '7';
      when "1000" => hex := '8';
      when "1001" => hex := '9';
      when "1010" => hex := 'A';
      when "1011" => hex := 'B';
      when "1100" => hex := 'C';
      when "1101" => hex := 'D';
      when "1110" => hex := 'E';
      when "1111" => hex := 'F';
      when others => hex := 'x';
    end case;
    return hex;
  end hexcharacter;
  --
  --------------------------------------------------------------------------------
  --
  begin
     
    -- decode first register
    sx_decode(1) := 's';
    sx_decode(2) := hexcharacter(instruction(11 downto 8));             

    -- decode second register
    sy_decode(1) := 's';
    sy_decode(2) := hexcharacter(instruction(7 downto 4));  

    -- decode constant value
    kk_decode(1) := hexcharacter(instruction(7 downto 4));
    kk_decode(2) := hexcharacter(instruction(3 downto 0));

    -- address value
    aaa_decode(1) := hexcharacter("00" & instruction(9 downto 8));
    aaa_decode(2) := hexcharacter(instruction(7 downto 4));
    aaa_decode(3) := hexcharacter(instruction(3 downto 0));

    -- decode instruction
    case instruction(17 downto 12) is
      when "000000" => kcpsm3_opcode := "LOAD " & sx_decode & ',' & kk_decode & "         ";
      when "000001" => kcpsm3_opcode := "LOAD " & sx_decode & ',' & sy_decode & "         ";
      when "001010" => kcpsm3_opcode := "AND " & sx_decode & ',' & kk_decode & "          ";
      when "001011" => kcpsm3_opcode := "AND " & sx_decode & ',' & sy_decode & "          ";
      when "001100" => kcpsm3_opcode := "OR " & sx_decode & ',' & kk_decode & "           ";
      when "001101" => kcpsm3_opcode := "OR " & sx_decode & ',' & sy_decode & "           ";
      when "001110" => kcpsm3_opcode := "XOR " & sx_decode & ',' & kk_decode & "          ";
      when "001111" => kcpsm3_opcode := "XOR " & sx_decode & ',' & sy_decode & "          ";
      when "010010" => kcpsm3_opcode := "TEST " & sx_decode & ',' & kk_decode & "         ";
      when "010011" => kcpsm3_opcode := "TEST " & sx_decode & ',' & sy_decode & "         ";
      when "011000" => kcpsm3_opcode := "ADD " & sx_decode & ',' & kk_decode & "          ";
      when "011001" => kcpsm3_opcode := "ADD " & sx_decode & ',' & sy_decode & "          ";
      when "011010" => kcpsm3_opcode := "ADDCY " & sx_decode & ',' & kk_decode & "        ";
      when "011011" => kcpsm3_opcode := "ADDCY " & sx_decode & ',' & sy_decode & "        ";
      when "011100" => kcpsm3_opcode := "SUB " & sx_decode & ',' & kk_decode & "          ";
      when "011101" => kcpsm3_opcode := "SUB " & sx_decode & ',' & sy_decode & "          ";
      when "011110" => kcpsm3_opcode := "SUBCY " & sx_decode & ',' & kk_decode & "        ";
      when "011111" => kcpsm3_opcode := "SUBCY " & sx_decode & ',' & sy_decode & "        ";
      when "010100" => kcpsm3_opcode := "COMPARE " & sx_decode & ',' & kk_decode & "      ";
      when "010101" => kcpsm3_opcode := "COMPARE " & sx_decode & ',' & sy_decode & "      ";
      when "100000" => 
        case instruction(3 downto 0) is
          when "0110" => kcpsm3_opcode := "SL0 " & sx_decode & "             ";
          when "0111" => kcpsm3_opcode := "SL1 " & sx_decode & "             ";
          when "0100" => kcpsm3_opcode := "SLX " & sx_decode & "             ";
          when "0000" => kcpsm3_opcode := "SLA " & sx_decode & "             ";
          when "0010" => kcpsm3_opcode := "RL " & sx_decode & "              ";
          when "1110" => kcpsm3_opcode := "SR0 " & sx_decode & "             ";
          when "1111" => kcpsm3_opcode := "SR1 " & sx_decode & "             ";
          when "1010" => kcpsm3_opcode := "SRX " & sx_decode & "             ";
          when "1000" => kcpsm3_opcode := "SRA " & sx_decode & "             ";
          when "1100" => kcpsm3_opcode := "RR " & sx_decode & "              ";
          when others => kcpsm3_opcode := "Invalid Instruction";
        end case;
      when "101100" => kcpsm3_opcode := "OUTPUT " & sx_decode & ',' & kk_decode & "       ";
      when "101101" => kcpsm3_opcode := "OUTPUT " & sx_decode & ",(" & sy_decode & ")     ";
      when "000100" => kcpsm3_opcode := "INPUT " & sx_decode & ',' & kk_decode & "        ";
      when "000101" => kcpsm3_opcode := "INPUT " & sx_decode & ",(" & sy_decode & ")      ";
      when "101110" => kcpsm3_opcode := "STORE " & sx_decode & ',' & kk_decode & "        ";
      when "101111" => kcpsm3_opcode := "STORE " & sx_decode & ",(" & sy_decode & ")      ";
      when "000110" => kcpsm3_opcode := "FETCH " & sx_decode & ',' & kk_decode & "        ";
      when "000111" => kcpsm3_opcode := "FETCH " & sx_decode & ",(" & sy_decode & ")      ";
      when "110100" => kcpsm3_opcode := "JUMP " & aaa_decode & "           ";
      when "110101" =>
        case instruction(11 downto 10) is
          when "00" => kcpsm3_opcode := "JUMP Z," & aaa_decode & "         ";
          when "01" => kcpsm3_opcode := "JUMP NZ," & aaa_decode & "        ";
          when "10" => kcpsm3_opcode := "JUMP C," & aaa_decode & "         ";
          when "11" => kcpsm3_opcode := "JUMP NC," & aaa_decode & "        ";
          when others => kcpsm3_opcode := "Invalid Instruction";
        end case;
      when "110000" => kcpsm3_opcode := "CALL " & aaa_decode & "           ";
      when "110001" =>
        case instruction(11 downto 10) is
          when "00" => kcpsm3_opcode := "CALL Z," & aaa_decode & "         ";
          when "01" => kcpsm3_opcode := "CALL NZ," & aaa_decode & "        ";
          when "10" => kcpsm3_opcode := "CALL C," & aaa_decode & "         ";
          when "11" => kcpsm3_opcode := "CALL NC," & aaa_decode & "        ";
          when others => kcpsm3_opcode := "Invalid Instruction";
        end case;
      when "101010" => kcpsm3_opcode := "RETURN             ";
      when "101011" =>
        case instruction(11 downto 10) is
          when "00" => kcpsm3_opcode := "RETURN Z           ";
          when "01" => kcpsm3_opcode := "RETURN NZ          ";
          when "10" => kcpsm3_opcode := "RETURN C           ";
          when "11" => kcpsm3_opcode := "RETURN NC          ";
          when others => kcpsm3_opcode := "Invalid Instruction";
        end case;
      when "111000" =>
        case instruction(0) is
          when '0' => kcpsm3_opcode := "RETURNI DISABLE    ";
          when '1' => kcpsm3_opcode := "RETURNI ENABLE     ";
          when others => kcpsm3_opcode := "Invalid Instruction";
        end case;
      when "111100" =>
        case instruction(0) is
          when '0' => kcpsm3_opcode := "DISABLE INTERRUPT  ";
          when '1' => kcpsm3_opcode := "ENABLE INTERRUPT   ";
          when others => kcpsm3_opcode := "Invalid Instruction";
        end case;
      when others => kcpsm3_opcode := "Invalid Instruction";
    end case;

    if clk'event and clk='1' then 

      --reset and flag status information
      if reset='1' or reset_delay='1' then
        kcpsm3_status := "NZ, NC, Reset";
       else
        kcpsm3_status(7 to 13) := "       ";
        if flag_enable='1' then
          if zero_carry='1' then
            kcpsm3_status(1 to 4) := " Z, ";
           else
            kcpsm3_status(1 to 4) := "NZ, ";
          end if;
          if sel_carry(3)='1' then
            kcpsm3_status(5 to 6) := " C";
           else
            kcpsm3_status(5 to 6) := "NC";
          end if;
        end if;
      end if;

      --simulation of register contents
      if register_enable='1' then
        case instruction(11 downto 8) is
          when "0000" => s0_contents := alu_result;
          when "0001" => s1_contents := alu_result;
          when "0010" => s2_contents := alu_result;
          when "0011" => s3_contents := alu_result;
          when "0100" => s4_contents := alu_result;
          when "0101" => s5_contents := alu_result;
          when "0110" => s6_contents := alu_result;
          when "0111" => s7_contents := alu_result;
          when "1000" => s8_contents := alu_result;
          when "1001" => s9_contents := alu_result;
          when "1010" => sa_contents := alu_result;
          when "1011" => sb_contents := alu_result;
          when "1100" => sc_contents := alu_result;
          when "1101" => sd_contents := alu_result;
          when "1110" => se_contents := alu_result;
          when "1111" => sf_contents := alu_result;
          when others => null;
        end case;
      end if;

      --simulation of scratch pad memory contents
      if memory_enable='1' then
        case second_operand(5 downto 0) is
          when "000000" => spm00_contents := sx;
          when "000001" => spm01_contents := sx;
          when "000010" => spm02_contents := sx;
          when "000011" => spm03_contents := sx;
          when "000100" => spm04_contents := sx;
          when "000101" => spm05_contents := sx;
          when "000110" => spm06_contents := sx;
          when "000111" => spm07_contents := sx;
          when "001000" => spm08_contents := sx;
          when "001001" => spm09_contents := sx;
          when "001010" => spm0a_contents := sx;
          when "001011" => spm0b_contents := sx;
          when "001100" => spm0c_contents := sx;
          when "001101" => spm0d_contents := sx;
          when "001110" => spm0e_contents := sx;
          when "001111" => spm0f_contents := sx;
          when "010000" => spm10_contents := sx;
          when "010001" => spm11_contents := sx;
          when "010010" => spm12_contents := sx;
          when "010011" => spm13_contents := sx;
          when "010100" => spm14_contents := sx;
          when "010101" => spm15_contents := sx;
          when "010110" => spm16_contents := sx;
          when "010111" => spm17_contents := sx;
          when "011000" => spm18_contents := sx;
          when "011001" => spm19_contents := sx;
          when "011010" => spm1a_contents := sx;
          when "011011" => spm1b_contents := sx;
          when "011100" => spm1c_contents := sx;
          when "011101" => spm1d_contents := sx;
          when "011110" => spm1e_contents := sx;
          when "011111" => spm1f_contents := sx;
          when "100000" => spm20_contents := sx;
          when "100001" => spm21_contents := sx;
          when "100010" => spm22_contents := sx;
          when "100011" => spm23_contents := sx;
          when "100100" => spm24_contents := sx;
          when "100101" => spm25_contents := sx;
          when "100110" => spm26_contents := sx;
          when "100111" => spm27_contents := sx;
          when "101000" => spm28_contents := sx;
          when "101001" => spm29_contents := sx;
          when "101010" => spm2a_contents := sx;
          when "101011" => spm2b_contents := sx;
          when "101100" => spm2c_contents := sx;
          when "101101" => spm2d_contents := sx;
          when "101110" => spm2e_contents := sx;
          when "101111" => spm2f_contents := sx;
          when "110000" => spm30_contents := sx;
          when "110001" => spm31_contents := sx;
          when "110010" => spm32_contents := sx;
          when "110011" => spm33_contents := sx;
          when "110100" => spm34_contents := sx;
          when "110101" => spm35_contents := sx;
          when "110110" => spm36_contents := sx;
          when "110111" => spm37_contents := sx;
          when "111000" => spm38_contents := sx;
          when "111001" => spm39_contents := sx;
          when "111010" => spm3a_contents := sx;
          when "111011" => spm3b_contents := sx;
          when "111100" => spm3c_contents := sx;
          when "111101" => spm3d_contents := sx;
          when "111110" => spm3e_contents := sx;
          when "111111" => spm3f_contents := sx;
          when others => null;
        end case;
      end if;

    end if;

  end process simulation;
  
  --synthesis translate on
--
--**********************************************************************************
-- End of simulation code.
--**********************************************************************************
--
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- END OF FILE KCPSM3.VHD
--
------------------------------------------------------------------------------------
