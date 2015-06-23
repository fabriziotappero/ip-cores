-- Constant (K) Coded Programmable State Machine for Spartan-II and Virtex-E Devices
--
-- Version : 1.00c
-- Version Date : 14th August 2002
--
-- Start of design entry : 2nd July 2002
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
------------------------------------------------------------------------------------
--
-- NOTICE:
--
-- Copyright Xilinx, Inc. 2002.   This code may be contain portions patented by other 
-- third parites.  By providing this core as one possible implementation of a standard,
-- Xilinx is making no representation that the provided implementation of this standard 
-- is free from any claims of infringement by any third party.  Xilinx expressly 
-- disclaims any warranty with respect to the adequacy of the implementation, including 
-- but not limited to any warranty or representation that the implementation is free 
-- from claims of any third party.  Futhermore, Xilinx is providing this core as a 
-- courtesy to you and suggests that you contact all third parties to obtain the 
-- necessary rights to use this implementation.
--
------------------------------------------------------------------------------------
--
-- Format of this file.
--
-- This file contains the definition of KCPSM and all the submodules which it 
-- required. The definition of KCPSM is placed at the end of this file as the order 
-- in which each entity is read is important for some simulation and synthesis tools.
-- Hence the first entity to be seen below is that of a submodule.
--
--
-- The submodules define the implementation of the logic using Xilinx primitives.
-- These ensure predictable synthesis results and maximise the density of the implementation. 
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
-- It is only specified in sub modules which contain primitive components.
-- 
-- library unisim;
-- use unisim.vcomponents.all;
--
------------------------------------------------------------------------------------
--
-- Description of sub-modules and further low level modules.
--
------------------------------------------------------------------------------------
--
-- Definition of an 8-bit bus 4 to 1 multiplexer with embeded select signal decoding.
-- 
-- sel1  sel0a  sel0b   Y_bus 
--  
--  0      0      x     D0_bus
--  0      1      x     D1_bus
--  1      x      0     D2_bus
--  1      x      1     D3_bus
--
-- sel1 is the pipelined decode of instruction12, instruction13, and instruction15.
-- sel0a is code2 after pipeline delay.
-- sel0b is instruction14 after pipeline delay.
--
-- Requires 17 LUTs and 3 flip-flops.
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity data_bus_mux4 is
    Port (         D3_bus : in std_logic_vector(7 downto 0);
                   D2_bus : in std_logic_vector(7 downto 0);    
                   D1_bus : in std_logic_vector(7 downto 0);
                   D0_bus : in std_logic_vector(7 downto 0);
            instruction15 : in std_logic;
            instruction14 : in std_logic;
            instruction13 : in std_logic;
            instruction12 : in std_logic;
                    code2 : in std_logic;
                    Y_bus : out std_logic_vector(7 downto 0);
                      clk : in std_logic );
    end data_bus_mux4;
--
architecture low_level_definition of data_bus_mux4 is
--
-- Internal signals
--
signal upper_selection : std_logic_vector(7 downto 0);
signal lower_selection : std_logic_vector(7 downto 0);
signal decode_sel1     : std_logic;
signal sel1            : std_logic;
signal sel0a           : std_logic;
signal sel0b           : std_logic;
--
-- Attribute to define LUT contents during implementation 
-- The information is repeated in the generic map for functional simulation
attribute INIT : string; 
attribute INIT of decode_lut : label is "E0";
--
begin

  -- Forming decode signals

  decode_lut: LUT3
  --translate_off
    generic map (INIT => X"E0")
  --translate_on
  port map( I0 => instruction12,
            I1 => instruction13,
            I2 => instruction15,
             O => decode_sel1 );

  sel1_pipe: FD
  port map ( D => decode_sel1,
             Q => sel1,
             C => clk);

  sel0a_pipe: FD
  port map ( D => code2,
             Q => sel0a,
             C => clk);

  sel0b_pipe: FD
  port map ( D => instruction14,
             Q => sel0b,
             C => clk);

  bus_width_loop: for i in 0 to 7 generate
  --
  -- Attribute to define LUT contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  attribute INIT : string; 
  attribute INIT of high_mux_lut : label is "E4";
  attribute INIT of low_mux_lut  : label is "E4";
 
  --
  begin

    high_mux_lut: LUT3
    --translate_off
      generic map (INIT => X"E4")
    --translate_on
    port map( I0 => sel0b,
              I1 => D2_bus(i),
              I2 => D3_bus(i),
               O => upper_selection(i) );

    low_mux_lut: LUT3
    --translate_off
      generic map (INIT => X"E4")
    --translate_on
    port map( I0 => sel0a,
              I1 => D0_bus(i),
              I2 => D1_bus(i),
               O => lower_selection(i) );

    final_mux: MUXF5
    port map(  I1 => upper_selection(i),
               I0 => lower_selection(i),
                S => sel1,
                O => Y_bus(i) );

  end generate bus_width_loop;
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- Definition of an 8-bit shift/rotate process
--	
-- This function uses 11 LUTs.
-- The function contains an output pipeline register using 9 FDs.
--
-- Operation
--
-- The input operand is shifted by one bit left or right.
-- The bit which falls out of the end is passed to the carry_out.
-- The bit shifted in is determined by the select bits
--
--     code1    code0         Bit injected
--
--       0        0          carry_in           
--       0        1          msb of input_operand 
--       1        0          lsb of operand 
--       1        1          inject_bit 
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity shift_rotate_process is
    Port    (    operand : in std_logic_vector(7 downto 0);
                carry_in : in std_logic;
              inject_bit : in std_logic;
             shift_right : in std_logic;
                   code1 : in std_logic;
                   code0 : in std_logic;
                       Y : out std_logic_vector(7 downto 0);
               carry_out : out std_logic;
                     clk : in std_logic);
    end shift_rotate_process;
--
architecture low_level_definition of shift_rotate_process is
--
-- Attribute to define LUT contents during implementation 
-- The information is repeated in the generic map for functional simulation
attribute INIT : string; 
attribute INIT of high_mux_lut       : label is "E4";
attribute INIT of low_mux_lut        : label is "E4";
attribute INIT of carry_out_mux_lut  : label is "E4";
--
-- Internal signals
--
signal upper_selection : std_logic;
signal lower_selection : std_logic;
signal mux_output      : std_logic_vector(7 downto 0);
signal shift_in_bit    : std_logic;
signal carry_bit       : std_logic;
--
begin
  --
  -- 4 to 1 mux selection of the bit to be shifted in
  --

    high_mux_lut: LUT3
    --translate_off
      generic map (INIT => X"E4")
    --translate_on
    port map( I0 => code0,
              I1 => operand(0),
              I2 => inject_bit,
               O => upper_selection );

    low_mux_lut: LUT3
    --translate_off
      generic map (INIT => X"E4")
    --translate_on
    port map( I0 => code0,
              I1 => carry_in,
              I2 => operand(7),
               O => lower_selection );

    final_mux: MUXF5
    port map(  I1 => upper_selection,
               I0 => lower_selection,
                S => code1,
                O => shift_in_bit );

  --
  -- shift left or right of operand
  --
  bus_width_loop: for i in 0 to 7 generate
  --
  begin

     lsb_shift: if i=0 generate
        --
        -- Attribute to define LUT contents during implementation 
        -- The information is repeated in the generic map for functional simulation
        attribute INIT : string; 
        attribute INIT of mux_lut : label is "E4";
        --
        begin

          mux_lut: LUT3
          --translate_off
            generic map (INIT => X"E4")
          --translate_on
          port map( I0 => shift_right,
                    I1 => shift_in_bit,
                    I2 => operand(i+1),
                     O => mux_output(i) );
					   
        end generate lsb_shift;

     mid_shift: if i>0 and i<7 generate
        --
        -- Attribute to define LUT contents during implementation 
        -- The information is repeated in the generic map for functional simulation
        attribute INIT : string; 
        attribute INIT of mux_lut : label is "E4";
        --
        begin

          mux_lut: LUT3
          --translate_off
            generic map (INIT => X"E4")
          --translate_on
          port map( I0 => shift_right,
                    I1 => operand(i-1),
                    I2 => operand(i+1),
                     O => mux_output(i) );
					   
	  end generate mid_shift;

     msb_shift: if i=7 generate
        --
        -- Attribute to define LUT contents during implementation 
        -- The information is repeated in the generic map for functional simulation
        attribute INIT : string; 
        attribute INIT of mux_lut : label is "E4";
        --
        begin

          mux_lut: LUT3
          --translate_off
            generic map (INIT => X"E4")
          --translate_on
          port map( I0 => shift_right,
                    I1 => operand(i-1),
                    I2 => shift_in_bit,
                     O => mux_output(i) );
					   
	  end generate msb_shift;

     pipeline_bit: FD
     port map ( D => mux_output(i),
                Q => Y(i),
                C => clk);

  end generate bus_width_loop;
  --
  -- Selection of carry output
  --

  carry_out_mux_lut: LUT3
  --translate_off
    generic map (INIT => X"E4")
  --translate_on
  port map( I0 => shift_right,
            I1 => operand(7),
            I2 => operand(0),
             O => carry_bit );
					   
  pipeline_bit: FD
  port map ( D => carry_bit,
             Q => carry_out,
             C => clk);
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- Definition of an 8-bit logical processing unit
--	
-- This function uses 8 LUTs (4 slices) to provide the logical bit operations.
-- The function contains an output pipeline register using 8 FDs.
--
--     Code1    Code0       Bit Operation
--
--       0        0            LOAD      Y <= second_operand 
--       0        1            AND       Y <= first_operand and second_operand
--       1        0            OR        Y <= first_operand or second_operand 
--       1        1            XOR       Y <= first_operand xor second_operand
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity logical_bus_processing is
    Port (  first_operand : in std_logic_vector(7 downto 0);
           second_operand : in std_logic_vector(7 downto 0);
                    code1 : in std_logic;
                    code0 : in std_logic;
                        Y : out std_logic_vector(7 downto 0);
                      clk : in std_logic);
    end logical_bus_processing;
--
architecture low_level_definition of logical_bus_processing is
--
-- Internal signals
--
signal combinatorial_logical_processing : std_logic_vector(7 downto 0);
--
begin
 
  bus_width_loop: for i in 0 to 7 generate
  --
  -- Attribute to define LUT contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  attribute INIT : string; 
  attribute INIT of logical_lut : label is "6E8A"; 
  --
  begin

     logical_lut: LUT4
     --translate_off
     generic map (INIT => X"6E8A")
     --translate_on
     port map( I0 => second_operand(i),
               I1 => first_operand(i),
               I2 => code0,
               I3 => code1,
                O => combinatorial_logical_processing(i));

     pipeline_bit: FD
     port map ( D => combinatorial_logical_processing(i),
                Q => Y(i),
                C => clk);

  end generate bus_width_loop;
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
--
-- Definition of an 8-bit arithmetic process
--	
-- This function uses 10 LUTs and associated carry logic.
-- The function contains an output pipeline register using 9 FDs.
--
-- Operation
--
-- Two input operands are added or subtracted.
-- An input carry bit can be included in the calculation.
-- An output carry is always generated.
-- Carry signals work in the positive sense at all times.
--
--     code1     code0         Bit injected
--
--       0        0            ADD           
--       0        1            ADD with carry 
--       1        0            SUB  
--       1        1            SUB with carry 
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity arithmetic_process is
    Port (  first_operand : in std_logic_vector(7 downto 0);
           second_operand : in std_logic_vector(7 downto 0);
                 carry_in : in std_logic;
                    code1 : in std_logic;
                    code0 : in std_logic;
                        Y : out std_logic_vector(7 downto 0);
                carry_out : out std_logic;
                      clk : in std_logic);
    end arithmetic_process;
--
architecture low_level_definition of arithmetic_process is
--
-- Internal signals
--
signal carry_in_bit       : std_logic;
signal carry_out_bit      : std_logic;
signal modified_carry_out : std_logic;
signal half_addsub        : std_logic_vector(7 downto 0);
signal full_addsub        : std_logic_vector(7 downto 0);
signal carry_chain        : std_logic_vector(6 downto 0);
--
--
-- Attributes to define LUT contents during implementation 
-- The information is repeated in the generic map for functional simulation
attribute INIT : string; 
attribute INIT of carry_input_lut : label is "78"; 
attribute INIT of carry_output_lut : label is "6"; 
--
begin
  --
  -- Selection of the carry input to add/sub
  --
  carry_input_lut: LUT3
  --translate_off
    generic map (INIT => X"78")
  --translate_on
  port map( I0 => carry_in,
            I1 => code0,
            I2 => code1,
             O => carry_in_bit );
  --
  -- Main add/sub
  --	
  --    code1    Operation
  --
  --      0          ADD          Y <= first_operand + second_operand
  --      1          SUB          Y <= first_operand - second_operand
  --		    
  bus_width_loop: for i in 0 to 7 generate
  --
  -- Attribute to define LUT contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  attribute INIT : string; 
  attribute INIT of arithmetic_lut : label is "96"; 
  --
  begin

     lsb_carry: if i=0 generate
        begin

          arithmetic_carry: MUXCY
          port map( DI => first_operand(i),
                    CI => carry_in_bit,
                     S => half_addsub(i),
                     O => carry_chain(i));

          arithmetic_xor: XORCY
          port map( LI => half_addsub(i),
                    CI => carry_in_bit,
                     O => full_addsub(i));
					   
	  end generate lsb_carry;

     mid_carry: if i>0 and i<7 generate
        begin

          arithmetic_carry: MUXCY
          port map( DI => first_operand(i),
                    CI => carry_chain(i-1),
                     S => half_addsub(i),
                     O => carry_chain(i));

          arithmetic_xor: XORCY
          port map( LI => half_addsub(i),
                    CI => carry_chain(i-1),
                     O => full_addsub(i));

	  end generate mid_carry;

     msb_carry: if i=7 generate
        begin

          arithmetic_carry: MUXCY
          port map( DI => first_operand(i),
                    CI => carry_chain(i-1),
                     S => half_addsub(i),
                     O => carry_out_bit);

          arithmetic_xor: XORCY
          port map( LI => half_addsub(i),
                    CI => carry_chain(i-1),
                     O => full_addsub(i));

	  end generate msb_carry;

     arithmetic_lut: LUT3
     --translate_off
     generic map (INIT => X"96")
     --translate_on
     port map( I0 => first_operand(i),
               I1 => second_operand(i),
               I2 => code1,
                O => half_addsub(i));

     pipeline_bit: FD
     port map ( D => full_addsub(i),
                Q => Y(i),
                C => clk);

  end generate bus_width_loop;

  --
  -- Modification to carry output and pipeline
  --
  carry_output_lut: LUT2
  --translate_off
    generic map (INIT => X"6")
  --translate_on
  port map( I0 => carry_out_bit,
            I1 => code1,
             O => modified_carry_out );

  pipeline_bit: FD

  port map ( D => modified_carry_out,
             Q => carry_out,
             C => clk);
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- Definition of the Zero and Carry Flags including decoding logic.
--	
-- The ZERO value is detected using 2 LUTs and associated carry logic to 
-- form a wired NOR gate. A further LUT selects the source for the ZERO flag
-- which is stored in an FDRE.
--
-- Definition of the Carry Flag 
--
-- 3 LUTs and a pipeline flip-flop are used to select the source for the 
-- CARRY flag which is stored in an FDRE.
--
-- Total size 11 LUTs and 5 flip-flops.
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity flag_logic is
    Port (                data : in std_logic_vector(7 downto 0);
                 instruction15 : in std_logic;
                 instruction14 : in std_logic;
                 instruction13 : in std_logic;
                 instruction12 : in std_logic;
                  instruction8 : in std_logic;
                  instruction6 : in std_logic;
                          code : in std_logic_vector(2 downto 0);
                   shadow_zero : in std_logic;
                  shadow_carry : in std_logic;
            shift_rotate_carry : in std_logic;
                 add_sub_carry : in std_logic;
                         reset : in std_logic;
                       T_state : in std_logic;
                     zero_flag : out std_logic;
                    carry_flag : out std_logic;
                           clk : in std_logic);
    end flag_logic;
--
architecture low_level_definition of flag_logic is
--
-- Internal signals
--

signal enable1a                 : std_logic;
signal enable1a_carry           : std_logic;
signal enable1b                 : std_logic;
signal enable1b_carry           : std_logic;
signal flag_en_op_sx_or_returni : std_logic;
signal enable2a                 : std_logic;
signal enable2a_carry           : std_logic;
signal enable2b                 : std_logic;
signal enable2b_carry           : std_logic;
signal flag_en_op_sx_sy_or_kk   : std_logic;
signal flag_enable              : std_logic;
signal lower_zero               : std_logic;
signal upper_zero               : std_logic;
signal lower_zero_carry         : std_logic;
signal data_zero                : std_logic;
signal next_zero_flag           : std_logic;
signal carry_status             : std_logic;
signal next_carry_flag          : std_logic;
signal sX_op_decode             : std_logic;
signal sX_operation             : std_logic;
--
-- Attributes to define LUT contents during implementation 
-- The information is repeated in the generic map for functional simulation
attribute INIT : string; 
attribute INIT of en1a_lut         : label is "F002";
attribute INIT of en1b_lut         : label is "4";
attribute INIT of en2a_lut         : label is "10FF";
attribute INIT of en2b_lut         : label is "FE";
attribute INIT of flag_enable_lut  : label is "A8";
attribute INIT of lower_zero_lut   : label is "0001"; 
attribute INIT of upper_zero_lut   : label is "0001"; 
attribute INIT of zero_select_lut  : label is "F4B0";
attribute INIT of operation_lut    : label is "2000"; 
attribute INIT of carry_status_lut : label is "EC20"; 
attribute INIT of carry_select_lut : label is "F4B0"; 
--
begin

  --
  -- Decode instructions requiring flags to be enabled
  --

  en1a_lut: LUT4
  --translate_off
    generic map (INIT => X"F002")
  --translate_on
  port map( I0 => instruction6,
            I1 => instruction8,
            I2 => instruction12,
            I3 => instruction14,
             O => enable1a );

  en1b_lut: LUT2
  --translate_off
    generic map (INIT => X"4")
  --translate_on
  port map( I0 => instruction13,
            I1 => instruction15,
             O => enable1b );

  en1a_muxcy: MUXCY
  port map( DI => '0',
            CI => '1',
             S => enable1a,
             O => enable1a_carry );

  en1b_cymux: MUXCY
  port map( DI => '0',
            CI => enable1a_carry,
             S => enable1b,
             O => enable1b_carry );

  enable1_flop: FD
  port map ( D => enable1b_carry,
             Q => flag_en_op_sx_or_returni,
             C => clk);

  en2a_lut: LUT4
  --translate_off
    generic map (INIT => X"10FF")
  --translate_on
  port map( I0 => instruction12,
            I1 => instruction13,
            I2 => instruction14,
            I3 => instruction15,
             O => enable2a );

  en2b_lut: LUT3
  --translate_off
    generic map (INIT => X"FE")
  --translate_on
  port map( I0 => code(0),
            I1 => code(1),
            I2 => code(2),
             O => enable2b );

  en2a_muxcy: MUXCY
  port map( DI => '0',
            CI => '1',
             S => enable2a,
             O => enable2a_carry );

  en2b_cymux: MUXCY
  port map( DI => '0',
            CI => enable2a_carry,
             S => enable2b,
             O => enable2b_carry );

  enable2_flop: FD
  port map ( D => enable2b_carry,
             Q => flag_en_op_sx_sy_or_kk,
             C => clk);

  flag_enable_lut: LUT3
  --translate_off
    generic map (INIT => X"A8")
  --translate_on
  port map( I0 => T_state,
            I1 => flag_en_op_sx_sy_or_kk,
            I2 => flag_en_op_sx_or_returni,
             O => flag_enable );

  --
  -- Detect all bits in data are zero using wired NOR gate
  --
  lower_zero_lut: LUT4
  --translate_off
    generic map (INIT => X"0001")
  --translate_on
  port map( I0 => data(0),
            I1 => data(1),
            I2 => data(2),
            I3 => data(3),
             O => lower_zero );

  upper_zero_lut: LUT4
  --translate_off
    generic map (INIT => X"0001")
  --translate_on
  port map( I0 => data(4),
            I1 => data(5),
            I2 => data(6),
            I3 => data(7),
             O => upper_zero );

  lower_zero_muxcy: MUXCY
  port map( DI => '0',
            CI => '1',
             S => lower_zero,
             O => lower_zero_carry );

  upper_zero_cymux: MUXCY
  port map( DI => '0',
            CI => lower_zero_carry,
             S => upper_zero,
             O => data_zero );
  --
  -- Select new zero status or the shaddow flag for a RETURNI
  --
  zero_select_lut: LUT4
  --translate_off
    generic map (INIT => X"F4B0")
  --translate_on
  port map( I0 => instruction14,
            I1 => instruction15,
            I2 => data_zero,
            I3 => shadow_zero,
             O => next_zero_flag );

  zero_flag_flop: FDRE
  port map ( D => next_zero_flag,
             Q => zero_flag,
            CE => flag_enable,
             R => reset,
             C => clk);
  --
  -- Select new carry status based on operation
  --

  operation_lut: LUT4
  --translate_off
    generic map (INIT => X"2000")
  --translate_on
  port map( I0 => instruction12,
            I1 => instruction13,
            I2 => instruction14,
            I3 => instruction15,
             O => sX_op_decode );

  operation_pipe: FD
  port map ( D => sX_op_decode,
             Q => sX_operation,
             C => clk);

  carry_status_lut: LUT4
  --translate_off
    generic map (INIT => X"EC20")
  --translate_on
  port map( I0 => code(2),
            I1 => sX_operation,
            I2 => add_sub_carry,
            I3 => shift_rotate_carry,
             O => carry_status );

  --
  -- Select new carry status based on operationor the shaddow flag for a RETURNI
  --

  carry_select_lut: LUT4
  --translate_off
    generic map (INIT => X"F4B0")
  --translate_on
  port map( I0 => instruction14,
            I1 => instruction15,
            I2 => carry_status,
            I3 => shadow_carry,
             O => next_carry_flag );

  carry_flag_flop: FDRE
  port map ( D => next_carry_flag,
             Q => carry_flag,
            CE => flag_enable,
             R => reset,
             C => clk);

--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- Definition of an 8-bit bus 2 to 1 multiplexer with built in select decode
--
-- Requires 9 LUTs.
--	 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity data_bus_mux2 is
    Port (         D1_bus : in std_logic_vector(7 downto 0);
                   D0_bus : in std_logic_vector(7 downto 0);
            instruction15 : in std_logic;
            instruction14 : in std_logic;
            instruction13 : in std_logic;
            instruction12 : in std_logic;
                    Y_bus : out std_logic_vector(7 downto 0));
    end data_bus_mux2;
--
architecture low_level_definition of data_bus_mux2 is
--
-- Internal signals
--
signal constant_sy_sel  : std_logic;
--
-- Attribute to define LUT contents during implementation 
-- The information is repeated in the generic map for functional simulation
attribute INIT : string; 
attribute INIT of decode_lut : label is "9800";
--
begin

  -- Forming decode signal

  decode_lut: LUT4
  --translate_off
    generic map (INIT => X"9800")
  --translate_on
  port map( I0 => instruction12,
            I1 => instruction13,
            I2 => instruction14,
            I3 => instruction15,
             O => constant_sy_sel );

  -- 2 to 1 bus multiplexer
 
  bus_width_loop: for i in 0 to 7 generate
  --
  -- Attribute to define LUT contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  attribute INIT : string; 
  attribute INIT of mux_lut : label is "E4";
  --
  begin

    mux_lut: LUT3
    --translate_off
      generic map (INIT => X"E4")
    --translate_on
    port map( I0 => constant_sy_sel,
              I1 => D0_bus(i),
              I2 => D1_bus(i),
               O => Y_bus(i) );

  end generate bus_width_loop;
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- Definition of an 3-bit bus 2 to 1 multiplexer
--
-- Requires 3 LUTs.
--	 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity ALU_control_mux2 is
    Port (         D1_bus : in std_logic_vector(2 downto 0);
                   D0_bus : in std_logic_vector(2 downto 0);
            instruction15 : in std_logic;
                    Y_bus : out std_logic_vector(2 downto 0));
    end ALU_control_mux2;
--
architecture low_level_definition of ALU_control_mux2 is
--
begin

  -- 2 to 1 bus multiplexer
 
  bus_width_loop: for i in 0 to 2 generate
  --
  -- Attribute to define LUT contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  attribute INIT : string; 
  attribute INIT of mux_lut : label is "E4";
  --
  begin

    mux_lut: LUT3
    --translate_off
      generic map (INIT => X"E4")
    --translate_on
    port map( I0 => instruction15,
              I1 => D0_bus(i),
              I2 => D1_bus(i),
               O => Y_bus(i) );

  end generate bus_width_loop;
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- Definition of an 8-bit dual port RAM with 16 locations
-- including write enable decode.
--	
-- This mode of distributed RAM requires 1 'slice' (2 LUTs)per bit.
-- Total for module 18 LUTs and 1 flip-flop.
-- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity data_register_bank is
    Port (         address_A : in std_logic_vector(3 downto 0);
                   Din_A_bus : in std_logic_vector(7 downto 0);
                  Dout_A_bus : out std_logic_vector(7 downto 0);    
                   address_B : in std_logic_vector(3 downto 0);
                  Dout_B_bus : out std_logic_vector(7 downto 0);
               instruction15 : in std_logic; 
               instruction14 : in std_logic; 
               instruction13 : in std_logic; 
            active_interrupt : in std_logic; 
                     T_state : in std_logic; 
                         clk : in std_logic);
    end data_register_bank;
--
architecture low_level_definition of data_register_bank is
--
-- Internal signals
--
signal write_decode     : std_logic;
signal register_write   : std_logic;
signal register_enable  : std_logic;
--
-- Attribute to define LUT contents during implementation 
-- The information is repeated in the generic map for functional simulation
attribute INIT : string; 
attribute INIT of decode_lut : label is "1455";
attribute INIT of gating_lut : label is "8";
--
begin

  -- Forming decode signal

  decode_lut: LUT4
  --translate_off
    generic map (INIT => X"1455")
  --translate_on
  port map( I0 => active_interrupt,
            I1 => instruction13,
            I2 => instruction14,
            I3 => instruction15,
             O => write_decode );

  decode_pipe: FD
  port map ( D => write_decode,
             Q => register_write,
             C => clk);

  gating_lut: LUT2
  --translate_off
    generic map (INIT => X"8")
  --translate_on
  port map( I0 => T_state,
            I1 => register_write,
             O => register_enable );

  bus_width_loop: for i in 0 to 7 generate
  --
  -- Attribute to define RAM contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  attribute INIT : string; 
  attribute INIT of data_register_bit : label is "0000"; 
  --
  begin

     data_register_bit: RAM16X1D
     -- translate_off
     generic map(INIT => X"0000")
     -- translate_on
     port map (       D => Din_A_bus(i),
                     WE => register_enable,
                   WCLK => clk,
                     A0 => address_A(0),
                     A1 => address_A(1),
                     A2 => address_A(2),
                     A3 => address_A(3),
                  DPRA0 => address_B(0),
                  DPRA1 => address_B(1),
                  DPRA2 => address_B(2),
                  DPRA3 => address_B(3),
                    SPO => Dout_A_bus(i),
                    DPO => Dout_B_bus(i));

  end generate bus_width_loop;
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- Definition of basic time T-state and clean reset
--	
-- This function forms the basic 2 cycle T-state control used by the processor.
-- It also forms a clean synchronous reset pulse that is long enough to ensure 
-- correct operation at start up and following a reset input.
-- It uses 1 LUT 3 flip-flops.
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity T_state_and_Reset is
    Port (    reset_input : in std_logic;
           internal_reset : out std_logic;
                  T_state : out std_logic;
                      clk : in std_logic);
    end T_state_and_Reset;
--
architecture low_level_definition of T_state_and_Reset is
--
-- Internal signals
--
signal reset_delay1     : std_logic;
signal reset_delay2     : std_logic;
signal not_T_state      : std_logic;
signal internal_T_state : std_logic;
--
--
-- Attributes to define LUT contents during implementation 
-- The information is repeated in the generic map for functional simulation
attribute INIT : string; 
attribute INIT of invert_lut : label is "1"; 
--
begin
  --
  delay_flop1: FDS
  port map ( D => '0',
             Q => reset_delay1,
             S => reset_input,
             C => clk);

  delay_flop2: FDS
  port map ( D => reset_delay1,
             Q => reset_delay2,
             S => reset_input,
             C => clk);
    
  invert_lut: LUT1
  --translate_off
    generic map (INIT => X"1")
  --translate_on
  port map( I0 => internal_T_state,
             O => not_T_state );

  toggle_flop: FDR
  port map ( D => not_T_state,
             Q => internal_T_state,
             R => reset_delay2,
             C => clk);

  T_state <= internal_T_state;
  internal_reset <= reset_delay2;
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- Definition Interrupt logic and shadow Flags.
--	
-- Decodes instructions which set and reset the interrupt enable flip-flop. 
-- Captures interrupt input and enables shadow flags
--
-- Total size 4 LUTs and 5 flip-flops.
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity interrupt_logic is
    Port (           interrupt : in std_logic;
                 instruction15 : in std_logic;
                 instruction14 : in std_logic;
                 instruction13 : in std_logic;
                  instruction8 : in std_logic;
                  instruction5 : in std_logic;
                  instruction4 : in std_logic;
                     zero_flag : in std_logic;
                    carry_flag : in std_logic;
                   shadow_zero : out std_logic;
                  shadow_carry : out std_logic;
              active_interrupt : out std_logic;
                         reset : in std_logic;
                       T_state : in std_logic;
                           clk : in std_logic);
    end interrupt_logic;

--
architecture low_level_definition of interrupt_logic is
--
-- Internal signals
--
signal clean_INT                 : std_logic;
signal interrupt_pulse           : std_logic;
signal active_interrupt_internal : std_logic;
signal enable_a                  : std_logic;
signal enable_a_carry            : std_logic;
signal enable_b                  : std_logic;
signal update_enable             : std_logic;
signal INT_enable_value          : std_logic;
signal INT_enable                : std_logic;
--
-- Attributes to define LUT contents during implementation 
-- The information is repeated in the generic map for functional simulation
attribute INIT : string; 
attribute INIT of pulse_lut        : label is "0080";
attribute INIT of en_b_lut         : label is "ABAA";
attribute INIT of en_a_lut         : label is "AE";
attribute INIT of value_lut        : label is "4";
--
begin

  -- assignment of output signal

  active_interrupt <= active_interrupt_internal;

  --
  -- Decode instructions that set or reset interrupt enable
  --

  en_a_lut: LUT3
  --translate_off
    generic map (INIT => X"AE")
  --translate_on
  port map( I0 => active_interrupt_internal,
            I1 => instruction4,
            I2 => instruction8,
             O => enable_a );

  en_b_lut: LUT4
  --translate_off
    generic map (INIT => X"ABAA")
  --translate_on
  port map( I0 => active_interrupt_internal,
            I1 => instruction13,
            I2 => instruction14,
            I3 => instruction15,
             O => enable_b );

  en_a_muxcy: MUXCY
  port map( DI => '0',
            CI => '1',
             S => enable_a,
             O => enable_a_carry );

  en_b_cymux: MUXCY
  port map( DI => '0',
            CI => enable_a_carry,
             S => enable_b,
             O => update_enable );

  value_lut: LUT2
  --translate_off
    generic map (INIT => X"4")
  --translate_on
  port map( I0 => active_interrupt_internal,
            I1 => instruction5,
             O => INT_enable_value );

  enable_flop: FDRE
  port map ( D => INT_enable_value,
             Q => INT_enable,
            CE => update_enable,
             R => reset,
             C => clk);

  -- Capture interrupt signal and generate internal pulse if enabled

  capture_flop: FDR
  port map ( D => interrupt,
             Q => clean_INT,
             R => reset,
             C => clk);

  pulse_lut: LUT4
  --translate_off
    generic map (INIT => X"0080")
  --translate_on
  port map( I0 => T_state,
            I1 => clean_INT,
            I2 => INT_enable,
            I3 => active_interrupt_internal,
             O => interrupt_pulse );

  active_flop: FDR
  port map ( D => interrupt_pulse,
             Q => active_interrupt_internal,
             R => reset,
             C => clk);

  -- Shadow flags

  shadow_carry_flop: FDE
  port map ( D => carry_flag,
             Q => shadow_carry,
            CE => active_interrupt_internal,
             C => clk);

  shadow_zero_flop: FDE
  port map ( D => zero_flag,
             Q => shadow_zero,
            CE => active_interrupt_internal,
             C => clk);
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- Definition of the Input and Output Strobes 
--	
-- Uses 3 LUTs and 2 flip-flops
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity IO_strobe_logic is
    Port (    instruction15 : in std_logic;
              instruction14 : in std_logic;
              instruction13 : in std_logic;
           active_interrupt : in std_logic;
                    T_state : in std_logic;
                      reset : in std_logic;
               write_strobe : out std_logic;
                read_strobe : out std_logic;
                        clk : in std_logic);
    end IO_strobe_logic;
--
architecture low_level_definition of IO_strobe_logic is
--
-- Internal signals
--
signal IO_type     : std_logic;
signal write_event : std_logic;
signal read_event  : std_logic;
--
-- Attributes to define LUT contents during implementation 
-- The information is repeated in the generic map for functional simulation
attribute INIT : string; 
attribute INIT of IO_type_lut : label is "8"; 
attribute INIT of write_lut   : label is "1000"; 
attribute INIT of read_lut    : label is "0100"; 
--
begin
  --
  IO_type_lut: LUT2
  --translate_off
    generic map (INIT => X"8")
  --translate_on
  port map( I0 => instruction13,
            I1 => instruction15,
             O => IO_type );

  write_lut: LUT4
  --translate_off
    generic map (INIT => X"1000")
  --translate_on
  port map( I0 => active_interrupt,
            I1 => T_state,
            I2 => instruction14,
            I3 => IO_type,
             O => write_event );

  write_flop: FDR
  port map ( D => write_event,
             Q => write_strobe,
             R => reset,
             C => clk);

  read_lut: LUT4
  --translate_off
    generic map (INIT => X"0100")
  --translate_on
  port map( I0 => active_interrupt,
            I1 => T_state,
            I2 => instruction14,
            I3 => IO_type,
             O => read_event );

  read_flop: FDR
  port map ( D => read_event,
             Q => read_strobe,
             R => reset,
             C => clk);
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- Definition of RAM for stack
--	 
-- This is a 16 location single port RAM of 8-bits to support the address range
-- of the program counter. The ouput is registered and the write enable is active low.
--
-- Total size 8 LUTs and 8 flip-flops.
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity stack_ram is
    Port (        Din : in std_logic_vector(7 downto 0);
                 Dout : out std_logic_vector(7 downto 0);
                 addr : in std_logic_vector(3 downto 0);
            write_bar : in std_logic;
                  clk : in std_logic);
    end stack_ram;
--
architecture low_level_definition of stack_ram is
--
-- Internal signals
--
signal ram_out      : std_logic_vector(7 downto 0);
signal write_enable : std_logic;
--
begin

  invert_enable: INV   -- Inverter should be implemented in the WE to RAM
  port map(  I => write_bar,
             O => write_enable);  
 
  bus_width_loop: for i in 0 to 7 generate
  --
  -- Attribute to define RAM contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  --
  attribute INIT : string; 
  attribute INIT of stack_ram_bit : label is "0000"; 
  --
  begin

     stack_ram_bit: RAM16X1S
     -- translate_off
     generic map(INIT => X"0000")
     -- translate_on
     port map (    D => Din(i),
                  WE => write_enable,
                WCLK => clk,
                  A0 => addr(0),
                  A1 => addr(1),
                  A2 => addr(2),
                  A3 => addr(3),
                   O => ram_out(i));

     stack_ram_flop: FD
     port map ( D => ram_out(i),
                Q => Dout(i),
                C => clk);

  end generate bus_width_loop;
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- Definition of a 4-bit special counter for stack pointer
-- including instruction decoding.	
--
-- Total size 8 LUTs and 4 flip-flops.
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity stack_counter is
    Port (        instruction15 : in std_logic;
                  instruction14 : in std_logic;
                  instruction13 : in std_logic;
                  instruction12 : in std_logic;
                   instruction9 : in std_logic;
                   instruction8 : in std_logic;
                   instruction7 : in std_logic;
                        T_state : in std_logic;
             flag_condition_met : in std_logic;
               active_interrupt : in std_logic;
                          reset : in std_logic;
                    stack_count : out std_logic_vector(3 downto 0);
                            clk : in std_logic);
    end stack_counter;
--
architecture low_level_definition of stack_counter is
--
-- Internal signals
--
signal not_interrupt     : std_logic;
signal count_value       : std_logic_vector(3 downto 0);
signal next_count        : std_logic_vector(3 downto 0);
signal count_carry       : std_logic_vector(2 downto 0);
signal half_count        : std_logic_vector(3 downto 0);
signal call_type         : std_logic;
signal valid_to_move     : std_logic;
signal pp_decode_a       : std_logic;
signal pp_decode_a_carry : std_logic;
signal pp_decode_b       : std_logic;
signal push_or_pop_type  : std_logic;
--
-- Attributes to define LUT contents during implementation 
-- The information is repeated in the generic map for functional simulation
attribute INIT : string; 
attribute INIT of valid_move_lut : label is "D"; 
attribute INIT of call_lut       : label is "0200"; 
attribute INIT of pp_a_lut       : label is "F2"; 
attribute INIT of pp_b_lut       : label is "10"; 
--
begin

  invert_interrupt: INV   -- Inverter should be implemented in the CE to flip flops
  port map(  I => active_interrupt,
             O => not_interrupt);  
  --
  -- Control logic decoding
  --
  valid_move_lut: LUT2
  --translate_off
    generic map (INIT => X"D")
  --translate_on
  port map( I0 => instruction12,
            I1 => flag_condition_met,
             O => valid_to_move );

  call_lut: LUT4
  --translate_off
    generic map (INIT => X"0200")
  --translate_on
  port map( I0 => instruction9,
            I1 => instruction13,
            I2 => instruction14,
            I3 => instruction15,
             O => call_type );


  pp_a_lut: LUT3
  --translate_off
    generic map (INIT => X"F2")
  --translate_on
  port map( I0 => instruction7,
            I1 => instruction8,
            I2 => instruction9,
             O => pp_decode_a );

  pp_b_lut: LUT3
  --translate_off
    generic map (INIT => X"10")
  --translate_on
  port map( I0 => instruction13,
            I1 => instruction14,
            I2 => instruction15,
             O => pp_decode_b );

  pp_a_muxcy: MUXCY
  port map( DI => '0',
            CI => '1',
             S => pp_decode_a,
             O => pp_decode_a_carry );

  en_b_cymux: MUXCY
  port map( DI => '0',
            CI => pp_decode_a_carry,
             S => pp_decode_b,
             O => push_or_pop_type  );

  count_width_loop: for i in 0 to 3 generate
  --
  -- The counter
  --
  begin

     register_bit: FDRE
     port map ( D => next_count(i),
                Q => count_value(i),
                R => reset,
               CE => not_interrupt,
                C => clk);

     lsb_count: if i=0 generate
	--
      -- Attribute to define LUT contents during implementation 
      -- The information is repeated in the generic map for functional simulation
      --
      attribute INIT : string; 
      attribute INIT of count_lut : label is "6555"; 
      --
	begin

       count_lut: LUT4
       --translate_off
       generic map (INIT => X"6555")
       --translate_on
       port map( I0 => count_value(i),
                 I1 => T_state,
                 I2 => valid_to_move,
                 I3 => push_or_pop_type,
                  O => half_count(i) );

       count_muxcy: MUXCY
       port map( DI => count_value(i),
                 CI => '0',
                  S => half_count(i),
                  O => count_carry(i));

       count_xor: XORCY
       port map( LI => half_count(i),
                 CI => '0',
                  O => next_count(i));
					   					   
	  end generate lsb_count;

     mid_count: if i>0 and i<3 generate
     --
     -- Attribute to define LUT contents during implementation 
     -- The information is repeated in the generic map for functional simulation
     --
     attribute INIT : string; 
     attribute INIT of count_lut : label is "A999"; 
     --
     begin

       count_lut: LUT4
       --translate_off
       generic map (INIT => X"A999")
       --translate_on
       port map( I0 => count_value(i),
                 I1 => T_state,
                 I2 => valid_to_move,
                 I3 => call_type,
                  O => half_count(i) );

       count_muxcy: MUXCY
       port map( DI => count_value(i),
                 CI => count_carry(i-1),
                  S => half_count(i),
                  O => count_carry(i));

       count_xor: XORCY
       port map( LI => half_count(i),
                 CI => count_carry(i-1),
                  O => next_count(i));

     end generate mid_count;

     msb_count: if i=3 generate
     --
     -- Attribute to define LUT contents during implementation 
     -- The information is repeated in the generic map for functional simulation
     --
     attribute INIT : string; 
     attribute INIT of count_lut : label is "A999"; 
     --
     begin

       count_lut: LUT4
       --translate_off
       generic map (INIT => X"A999")
       --translate_on
       port map( I0 => count_value(i),
                 I1 => T_state,
                 I2 => valid_to_move,
                 I3 => call_type,
                  O => half_count(i) );

       count_xor: XORCY
       port map( LI => half_count(i),
                 CI => count_carry(i-1),
                  O => next_count(i));

     end generate msb_count;

  end generate count_width_loop;

  stack_count <= count_value;
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- Definition of an 8-bit program counter
--	
-- This function provides the program counter and all decode logic.
--
-- Total size 21 LUTs and 8 flip-flops.
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
entity program_counter is
    Port (       instruction15 : in std_logic;
                 instruction14 : in std_logic;
                 instruction13 : in std_logic;
                 instruction12 : in std_logic;
                 instruction11 : in std_logic;
                 instruction10 : in std_logic;
                  instruction8 : in std_logic;
                  instruction7 : in std_logic;
                  instruction6 : in std_logic;
                constant_value : in std_logic_vector(7 downto 0);
                   stack_value : in std_logic_vector(7 downto 0);
                       T_state : in std_logic;
              active_interrupt : in std_logic;
                    carry_flag : in std_logic;
                     zero_flag : in std_logic;
                         reset : in std_logic;
            flag_condition_met : out std_logic;
                 program_count : out std_logic_vector(7 downto 0);
                           clk : in std_logic);
    end program_counter;
--
architecture low_level_definition of program_counter is
--
-- Internal signals
--
signal decode_a               : std_logic;
signal decode_a_carry         : std_logic;
signal decode_b               : std_logic;
signal move_group             : std_logic;
signal condition_met_internal : std_logic;
signal normal_count           : std_logic;
signal increment_load_value   : std_logic;
signal not_enable             : std_logic;
signal selected_load_value    : std_logic_vector(7 downto 0);
signal inc_load_value_carry   : std_logic_vector(6 downto 0);
signal inc_load_value         : std_logic_vector(7 downto 0);
signal selected_count_value   : std_logic_vector(7 downto 0);
signal inc_count_value_carry  : std_logic_vector(6 downto 0);
signal inc_count_value        : std_logic_vector(7 downto 0);
signal count_value            : std_logic_vector(7 downto 0);
--
-- Attributes to define LUT contents during implementation 
-- The information is repeated in the generic map for functional simulation
attribute INIT : string;
attribute INIT of decode_a_lut  : label is "E"; 
attribute INIT of decode_b_lut  : label is "10"; 
attribute INIT of condition_lut : label is "5A3C"; 
attribute INIT of count_lut     : label is "2F"; 
attribute INIT of increment_lut : label is "1"; 
--
begin

  --
  -- decode instructions
  --

  condition_lut: LUT4
  --translate_off
    generic map (INIT => X"5A3C")
  --translate_on
  port map( I0 => carry_flag,
            I1 => zero_flag,
            I2 => instruction10,
            I3 => instruction11,
             O => condition_met_internal );

  flag_condition_met <= condition_met_internal;

  decode_a_lut: LUT2
  --translate_off
    generic map (INIT => X"E")
  --translate_on
  port map( I0 => instruction7,
            I1 => instruction8,
             O => decode_a );

  decode_b_lut: LUT3
  --translate_off
    generic map (INIT => X"10")
  --translate_on
  port map( I0 => instruction13,
            I1 => instruction14,
            I2 => instruction15,
             O => decode_b );

  decode_a_muxcy: MUXCY
  port map( DI => '0',
            CI => '1',
             S => decode_a,
             O => decode_a_carry );

  decode_b_cymux: MUXCY
  port map( DI => '0',
            CI => decode_a_carry,
             S => decode_b,
             O => move_group  );

  count_lut: LUT3
  --translate_off
    generic map (INIT => X"2F")
  --translate_on
  port map( I0 => instruction12,
            I1 => condition_met_internal,
            I2 => move_group,
             O => normal_count );

  increment_lut: LUT2
  --translate_off
    generic map (INIT => X"1")
  --translate_on
  port map( I0 => instruction6,
            I1 => instruction8,
             O => increment_load_value );

  -- Dual loadable counter with increment on load vector


  invert_enable: INV   -- Inverter should be implemented in the CE to flip flops
  port map(  I => T_state,
             O => not_enable);  
 
  count_width_loop: for i in 0 to 7 generate
  --
  -- Attribute to define LUT contents during implementation 
  -- The information is repeated in the generic map for functional simulation
  attribute INIT : string; 
  attribute INIT of value_select_mux : label is "E4";
  attribute INIT of count_select_mux : label is "E4";
  --
  begin

    value_select_mux: LUT3
    --translate_off
      generic map (INIT => X"E4")
    --translate_on
    port map( I0 => instruction8,
              I1 => stack_value(i),
              I2 => constant_value(i),
               O => selected_load_value(i) );

    count_select_mux: LUT3
    --translate_off
      generic map (INIT => X"E4")
    --translate_on
    port map( I0 => normal_count,
              I1 => inc_load_value(i),
              I2 => count_value(i),
               O => selected_count_value(i) );

     register_bit: FDRSE
     port map ( D => inc_count_value(i),
                Q => count_value(i),
                R => reset,
                S => active_interrupt,
               CE => not_enable,
                C => clk);

     lsb_carry: if i=0 generate
      begin

       load_inc_carry: MUXCY
       port map( DI => '0',
                 CI => increment_load_value,
                  S => selected_load_value(i),
                  O => inc_load_value_carry(i));

       load_inc_xor: XORCY
       port map( LI => selected_load_value(i),
                 CI => increment_load_value,
                  O => inc_load_value(i));

       count_inc_carry: MUXCY
       port map( DI => '0',
                 CI => normal_count,
                  S => selected_count_value(i),
                  O => inc_count_value_carry(i));

       count_inc_xor: XORCY
       port map( LI => selected_count_value(i),
                 CI => normal_count,
                  O => inc_count_value(i));
					   					   
     end generate lsb_carry;

     mid_carry: if i>0 and i<7 generate
	begin

       load_inc_carry: MUXCY
       port map( DI => '0',
                 CI => inc_load_value_carry(i-1),
                  S => selected_load_value(i),
                  O => inc_load_value_carry(i));

       load_inc_xor: XORCY
       port map( LI => selected_load_value(i),
                 CI => inc_load_value_carry(i-1),
                  O => inc_load_value(i));

       count_inc_carry: MUXCY
       port map( DI => '0',
                 CI => inc_count_value_carry(i-1),
                  S => selected_count_value(i),
                  O => inc_count_value_carry(i));

       count_inc_xor: XORCY
       port map( LI => selected_count_value(i),
                 CI => inc_count_value_carry(i-1),
                  O => inc_count_value(i));

     end generate mid_carry;

     msb_carry: if i=7 generate
      begin

       load_inc_xor: XORCY
       port map( LI => selected_load_value(i),
                 CI => inc_load_value_carry(i-1),
                  O => inc_load_value(i));

       count_inc_xor: XORCY
       port map( LI => selected_count_value(i),
                 CI => inc_count_value_carry(i-1),
                  O => inc_count_value(i));

     end generate msb_carry;

  end generate count_width_loop;

  program_count <= count_value;

--
end low_level_definition;
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
--
------------------------------------------------------------------------------------
--
-- Main Entity for KCPSM
--
entity kcpsm is
    Port (      address : out std_logic_vector(7 downto 0);
            instruction : in std_logic_vector(15 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end kcpsm;
--
------------------------------------------------------------------------------------
--
-- Start of Main Architecture for KCPSM
--	 
architecture macro_level_definition of kcpsm is
--
------------------------------------------------------------------------------------
--
-- Components used in KCPSM and defined in subsequent entities.
--	
------------------------------------------------------------------------------------

component data_bus_mux4
    Port (         D3_bus : in std_logic_vector(7 downto 0);
                   D2_bus : in std_logic_vector(7 downto 0);    
                   D1_bus : in std_logic_vector(7 downto 0);
                   D0_bus : in std_logic_vector(7 downto 0);
            instruction15 : in std_logic;
            instruction14 : in std_logic;
            instruction13 : in std_logic;
            instruction12 : in std_logic;
                    code2 : in std_logic;
                    Y_bus : out std_logic_vector(7 downto 0);
                      clk : in std_logic );
    end component;

component shift_rotate_process 
    Port    (    operand : in std_logic_vector(7 downto 0);
                carry_in : in std_logic;
              inject_bit : in std_logic;
             shift_right : in std_logic;
                   code1 : in std_logic;
                   code0 : in std_logic;
                       Y : out std_logic_vector(7 downto 0);
               carry_out : out std_logic;
                     clk : in std_logic);
    end component;

component logical_bus_processing 
    Port (  first_operand : in std_logic_vector(7 downto 0);
           second_operand : in std_logic_vector(7 downto 0);
                    code1 : in std_logic;
                    code0 : in std_logic;
                        Y : out std_logic_vector(7 downto 0);
                      clk : in std_logic);
    end component;

component arithmetic_process 
    Port (  first_operand : in std_logic_vector(7 downto 0);
           second_operand : in std_logic_vector(7 downto 0);
                 carry_in : in std_logic;
                    code1 : in std_logic;
                    code0 : in std_logic;
                        Y : out std_logic_vector(7 downto 0);
                carry_out : out std_logic;
                      clk : in std_logic);
    end component;

component flag_logic
    Port (                data : in std_logic_vector(7 downto 0);
                 instruction15 : in std_logic;
                 instruction14 : in std_logic;
                 instruction13 : in std_logic;
                 instruction12 : in std_logic;
                  instruction8 : in std_logic;
                  instruction6 : in std_logic;
                          code : in std_logic_vector(2 downto 0);
                   shadow_zero : in std_logic;
                  shadow_carry : in std_logic;
            shift_rotate_carry : in std_logic;
                 add_sub_carry : in std_logic;
                         reset : in std_logic;
                       T_state : in std_logic;
                     zero_flag : out std_logic;
                    carry_flag : out std_logic;
                           clk : in std_logic);
    end component;

component data_bus_mux2
    Port (         D1_bus : in std_logic_vector(7 downto 0);
                   D0_bus : in std_logic_vector(7 downto 0);
            instruction15 : in std_logic;
            instruction14 : in std_logic;
            instruction13 : in std_logic;
            instruction12 : in std_logic;
                    Y_bus : out std_logic_vector(7 downto 0));
    end component;

component ALU_control_mux2 
    Port (         D1_bus : in std_logic_vector(2 downto 0);
                   D0_bus : in std_logic_vector(2 downto 0);
            instruction15 : in std_logic;
                    Y_bus : out std_logic_vector(2 downto 0));
    end component;

component data_register_bank 
    Port (         address_A : in std_logic_vector(3 downto 0);
                   Din_A_bus : in std_logic_vector(7 downto 0);
                  Dout_A_bus : out std_logic_vector(7 downto 0);    
                   address_B : in std_logic_vector(3 downto 0);
                  Dout_B_bus : out std_logic_vector(7 downto 0);
               instruction15 : in std_logic; 
               instruction14 : in std_logic; 
               instruction13 : in std_logic; 
            active_interrupt : in std_logic; 
                     T_state : in std_logic; 
                         clk : in std_logic);
    end component;

component T_state_and_Reset 
    Port (    reset_input : in std_logic;
           internal_reset : out std_logic;
                  T_state : out std_logic;
                      clk : in std_logic);
    end component;

component interrupt_logic
    Port (           interrupt : in std_logic;
                 instruction15 : in std_logic;
                 instruction14 : in std_logic;
                 instruction13 : in std_logic;
                  instruction8 : in std_logic;
                  instruction5 : in std_logic;
                  instruction4 : in std_logic;
                     zero_flag : in std_logic;
                    carry_flag : in std_logic;
                   shadow_zero : out std_logic;
                  shadow_carry : out std_logic;
              active_interrupt : out std_logic;
                         reset : in std_logic;
                       T_state : in std_logic;
                           clk : in std_logic);
    end component;

component IO_strobe_logic
    Port (    instruction15 : in std_logic;
              instruction14 : in std_logic;
              instruction13 : in std_logic;
           active_interrupt : in std_logic;
                    T_state : in std_logic;
                      reset : in std_logic;
               write_strobe : out std_logic;
                read_strobe : out std_logic;
                        clk : in std_logic);
    end component;

component stack_ram
    Port (        Din : in std_logic_vector(7 downto 0);
                 Dout : out std_logic_vector(7 downto 0);
                 addr : in std_logic_vector(3 downto 0);
            write_bar : in std_logic;
                  clk : in std_logic);
    end component;

component stack_counter
    Port (        instruction15 : in std_logic;
                  instruction14 : in std_logic;
                  instruction13 : in std_logic;
                  instruction12 : in std_logic;
                   instruction9 : in std_logic;
                   instruction8 : in std_logic;
                   instruction7 : in std_logic;
                        T_state : in std_logic;
             flag_condition_met : in std_logic;
               active_interrupt : in std_logic;
                          reset : in std_logic;
                    stack_count : out std_logic_vector(3 downto 0);
                            clk : in std_logic);
    end component;

component program_counter
    Port (       instruction15 : in std_logic;
                 instruction14 : in std_logic;
                 instruction13 : in std_logic;
                 instruction12 : in std_logic;
                 instruction11 : in std_logic;
                 instruction10 : in std_logic;
                  instruction8 : in std_logic;
                  instruction7 : in std_logic;
                  instruction6 : in std_logic;
                constant_value : in std_logic_vector(7 downto 0);
                   stack_value : in std_logic_vector(7 downto 0);
                       T_state : in std_logic;
              active_interrupt : in std_logic;
                    carry_flag : in std_logic;
                     zero_flag : in std_logic;
                         reset : in std_logic;
            flag_condition_met : out std_logic;
                 program_count : out std_logic_vector(7 downto 0);
                           clk : in std_logic);
    end component;



--
------------------------------------------------------------------------------------
--
-- Signals used in KCPSM
--
------------------------------------------------------------------------------------
--

--
-- Fundamental control signals
--	
signal T_state        : std_logic;
signal internal_reset : std_logic;
--
-- Register bank signals
--	
signal sX_register           : std_logic_vector(7 downto 0);
signal sY_register           : std_logic_vector(7 downto 0);
--
-- ALU signals
--
signal ALU_control             : std_logic_vector(2 downto 0);
signal second_operand          : std_logic_vector(7 downto 0);
signal logical_result          : std_logic_vector(7 downto 0);
signal shift_and_rotate_result : std_logic_vector(7 downto 0);
signal shift_and_rotate_carry  : std_logic;
signal arithmetic_result       : std_logic_vector(7 downto 0);
signal arithmetic_carry        : std_logic;
signal ALU_result              : std_logic_vector(7 downto 0);
--
-- Flag signals
-- 
signal carry_flag         : std_logic;
signal zero_flag          : std_logic;
--
-- Interrupt signals
-- 
signal shadow_carry_flag  : std_logic;
signal shadow_zero_flag   : std_logic;
signal active_interrupt   : std_logic;
--
-- Program Counter and Stack signals
--
signal program_count      : std_logic_vector(7 downto 0);
signal stack_pop_data     : std_logic_vector(7 downto 0);
signal stack_pointer      : std_logic_vector(3 downto 0);
signal flag_condition_met : std_logic;
--
------------------------------------------------------------------------------------
--
-- Start of KCPSM circuit description
--
------------------------------------------------------------------------------------
--	
begin

  --
  -- Connections to port_id, out_port, and address ports.
  --

  out_port <= sX_register;
  port_id <= second_operand;
  address <= program_count;

  --
  -- Reset conditioning and T-state generation
  --	

  basic_control: T_state_and_Reset
  port map (    reset_input => reset,
             internal_reset => internal_reset,
                    T_state => T_state,
                        clk => clk  );

  --
  -- Interrupt logic and shadow flags
  --	

  interrupt_group: interrupt_logic
  port map (           interrupt => interrupt,
                   instruction15 => instruction(15),
                   instruction14 => instruction(14),
                   instruction13 => instruction(13),
                    instruction8 => instruction(8),
                    instruction5 => instruction(5),
                    instruction4 => instruction(4),
                       zero_flag => zero_flag,
                      carry_flag => carry_flag,
                     shadow_zero => shadow_zero_flag,
                    shadow_carry => shadow_carry_flag,
                active_interrupt => active_interrupt,
                           reset => internal_reset,
                         T_state => T_state,
                             clk => clk  );
 
  --
  -- I/O strobes
  --	

  strobes: IO_strobe_logic
  port map (    instruction15 => instruction(15),
                instruction14 => instruction(14),
                instruction13 => instruction(13),
             active_interrupt => active_interrupt,
                      T_state => T_state,
                        reset => internal_reset,
                 write_strobe => write_strobe,
                  read_strobe => read_strobe,
                          clk => clk  );

  --
  -- Data registers and ALU
  --	

  registers: data_register_bank 
  port map (         address_A => instruction(11 downto 8),
                     Din_A_bus => ALU_result,
                    Dout_A_bus => sX_register,
                     address_B => instruction(7 downto 4),
                    Dout_B_bus => sY_register,
                 instruction15 => instruction(15), 
                 instruction14 => instruction(14), 
                 instruction13 => instruction(13),
              active_interrupt => active_interrupt, 
                       T_state => T_state, 
                           clk => clk  );

  operand_select: data_bus_mux2
  port map (         D1_bus => sY_register,
                     D0_bus => instruction(7 downto 0),
              instruction15 => instruction(15),
              instruction14 => instruction(14),
              instruction13 => instruction(13),
              instruction12 => instruction(12),
                      Y_bus => second_operand );

  ALU_control_select: ALU_control_mux2 
  port map (         D1_bus => instruction(2 downto 0),
                     D0_bus => instruction(14 downto 12),
              instruction15 => instruction(15),
                      Y_bus => ALU_control );

  logic_group: logical_bus_processing 
  port map (  first_operand => sX_register,
             second_operand => second_operand,
                      code1 => ALU_control(1),
                      code0 => ALU_control(0),
                          Y => logical_result,
                        clk => clk );

  arthimetic_group: arithmetic_process 
  port map (  first_operand => sX_register,
             second_operand => second_operand,
                   carry_in => carry_flag,
                      code1 => ALU_control(1),
                      code0 => ALU_control(0),
                          Y => arithmetic_result,
                  carry_out => arithmetic_carry,
                        clk => clk );

  shift_group: shift_rotate_process 
  port map    (    operand => sX_register,
                  carry_in => carry_flag,
                inject_bit => instruction(0),
               shift_right => instruction(3),
                     code1 => instruction(2),
                     code0 => instruction(1),
                         Y => shift_and_rotate_result,
                 carry_out => shift_and_rotate_carry,
                       clk => clk );

  ALU_final_mux: data_bus_mux4
  port map (         D3_bus => shift_and_rotate_result,
                     D2_bus => in_port,    
                     D1_bus => arithmetic_result,
                     D0_bus => logical_result,
              instruction15 => instruction(15),
              instruction14 => instruction(14),
              instruction13 => instruction(13),
              instruction12 => instruction(12),
                      code2 => ALU_control(2),
                      Y_bus => ALU_result,
                        clk => clk );

  flags: flag_logic
  port map (                data => ALU_result,
                   instruction15 => instruction(15),
                   instruction14 => instruction(14),
                   instruction13 => instruction(13),
                   instruction12 => instruction(12),
                    instruction8 => instruction(8),
                    instruction6 => instruction(6),
                            code => ALU_control,
                     shadow_zero => shadow_zero_flag,
                    shadow_carry => shadow_carry_flag,
              shift_rotate_carry => shift_and_rotate_carry,
                   add_sub_carry => arithmetic_carry,
                           reset => internal_reset,
                         T_state => T_state,
                       zero_flag => zero_flag,
                      carry_flag => carry_flag,
                             clk => clk );

  --
  -- Program stack
  --	 

  stack_memory: stack_ram 
  port map (       Din => program_count,
                  Dout => stack_pop_data,
                  addr => stack_pointer,
             write_bar => T_state,
                   clk => clk );
    

  stack_control: stack_counter
  port map (        instruction15 => instruction(15),
                    instruction14 => instruction(14),
                    instruction13 => instruction(13),
                    instruction12 => instruction(12),
                     instruction9 => instruction(9),
                     instruction8 => instruction(8),
                     instruction7 => instruction(7),
                          T_state => T_state,
               flag_condition_met => flag_condition_met,
                 active_interrupt => active_interrupt,
                            reset => internal_reset,
                      stack_count => stack_pointer,
                              clk => clk );

  --
  -- Program Counter
  --	

  address_counter: program_counter
  port map (       instruction15 => instruction(15),
                   instruction14 => instruction(14),
                   instruction13 => instruction(13),
                   instruction12 => instruction(12),
                   instruction11 => instruction(11),
                   instruction10 => instruction(10),
                    instruction8 => instruction(8),
                    instruction7 => instruction(7),
                    instruction6 => instruction(6),
                  constant_value => instruction(7 downto 0),
                     stack_value => stack_pop_data,
                         T_state => T_state,
                active_interrupt => active_interrupt,
                      carry_flag => carry_flag,
                       zero_flag => zero_flag,
                           reset => internal_reset,
              flag_condition_met => flag_condition_met,
                   program_count => program_count,
                             clk => clk );

--
end macro_level_definition;
--
------------------------------------------------------------------------------------
--
-- End of top level description for KCPSM.
--
------------------------------------------------------------------------------------
--
-- END OF FILE KCPSM.VHD
--
------------------------------------------------------------------------------------





































