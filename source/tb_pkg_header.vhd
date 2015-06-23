-------------------------------------------------------------------------------
--             Copyright 2014  Ken Campbell
--               All rights reserved.
-------------------------------------------------------------------------------
-- $Author: sckoarn $
--
-- $Date:  $
--
-- $Id:  $
--
-- $Source:  $
--
-- Description :  The the testbench package header file.
--
------------------------------------------------------------------------------
--  This file is part of The VHDL Test Bench Package.
--
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions are met:
--
--  1. Redistributions of source code must retain the above copyright notice,
--     this list of conditions and the following disclaimer.
--
--  2. Redistributions in binary form must reproduce the above copyright notice,
--     this list of conditions and the following disclaimer in the documentation
--     and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use std.textio.all;
--library ieee_proposed;
--use ieee_proposed.STD_LOGIC_1164_additions.all;

package tb_pkg is

  -- Constants
  constant max_str_len   : integer := 256;
  constant max_field_len : integer := 48;
  constant c_stm_text_len  : integer := 200;
  -- file handles
  file stimulus     : text;             -- file main file
  file include_file : text;             -- file declaration for includes

  -- Type Def's
  type base is (bin, oct, hex, dec);
--  subtype stack_element is integer range 0 to 8192;
  type stack_register is array(7 downto 0) of integer;
  type state_register is array(7 downto 0) of boolean;
  type int_array      is array(1 to 16) of integer;

  subtype text_line  is string(1 to max_str_len);
  subtype text_field is string(1 to max_field_len);
  subtype stm_text is string(1 to c_stm_text_len);
  type stm_text_ptr is access stm_text;
  -- define the stimulus line record and access
  type stim_line;
  type stim_line_ptr is access stim_line;     -- Pointer to stim_line record
  type stim_line is record
    instruction:   text_field;
    inst_field_1:  text_field;
    inst_field_2:  text_field;
    inst_field_3:  text_field;
    inst_field_4:  text_field;
    inst_field_5:  text_field;
    inst_field_6:  text_field;
    txt:           stm_text_ptr;
    line_number:   integer;      -- sequence line
    num_of_lines:  integer;      -- total number of lines
    file_line:     integer;      -- file line number
    file_idx:      integer;
    next_rec:      stim_line_ptr;
  end record;
  -- define the variables field and pointer
  type var_field;
  type var_field_ptr is access var_field;  -- pointer to var_field
  type var_field is record
    var_name:     text_field;
    var_index:    integer;
    var_value:    integer;
    next_rec:     var_field_ptr;
  end record;
  -- define the instruction structure
  type inst_def;
  type inst_def_ptr is access inst_def;
  type inst_def is record
    instruction:     text_field;
    instruction_l:   integer;
    params:          integer;
    next_rec:        inst_def_ptr;
  end record;
  -- define the file handle record
  type file_def;
  type file_def_ptr is access file_def;
  type file_def is record
    rec_idx:         integer;
    file_name:       text_line;
    next_rec:        file_def_ptr;
  end record;

  -- define the stimulus slave control record types
  type stm_sctl is record
    rst_n       : std_logic;
    addr        : std_logic_vector(31 downto 0);
    wdat        : std_logic_vector(31 downto 0);
    rwn         : std_logic;
    req_n       : std_logic;
  end record;
  type stm_sack is record
    rdat        : std_logic_vector(31 downto 0);
    ack_n       : std_logic;
    rdy_n       : std_logic;
    irq_n       : std_logic;
  end record;
  -- define the stimulus master control record types
  type stm_mctl is record
    addr        : std_logic_vector(31 downto 0);
    wdat        : std_logic_vector(31 downto 0);
    rwn         : std_logic;
    req_n       : std_logic;
    breq        : std_logic;
  end record;
  type stm_mack is record
    rdat        : std_logic_vector(31 downto 0);
    slv_rdy     : std_logic_vector(15 downto 0);
    slv_irq     : std_logic_vector(15 downto 0);
    ack_n       : std_logic;
    bgrant      : std_logic;
  end record;

-----
--  stm interface neutral functions
  function stm_neut return stm_sctl;
  function stm_neut return stm_sack;
  --function stm_neut() return stm_mctl;
  --function stm_neut() return stm_mack;

---*****************************************************************************
  -- Function Declaration
--  function str_len(variable line: text_line) return text_field;
--  function fld_len(s : in text_field) integer;

    function c2std_vec(c: in character) return std_logic_vector;

--------------------------------------------------------------------------------
  -- Procedure declarations
--------------------------------------------------------------------------
-- define_instruction
--    inputs     file_name  the file to be read from
--
--    output     file_line  a line of text from the file
  procedure define_instruction(variable inst_set: inout inst_def_ptr;
                               constant inst:     in    string;
                               constant args:     in    integer);

--------------------------------------------------------------------------------
--  index_variable
--     inputs:
--               index:  the index of the variable being accessed
--     outputs:
--               Variable Value
--               valid  is 1 if valid 0 if not
  procedure index_variable(variable var_list : in  var_field_ptr;
                           variable index    : in  integer;
                           variable value    : out integer;
                           variable valid    : out integer);

--------------------------------------------------------------------------------
--  update_variable
--     inputs:
--               index:  the index of the variable being accessed
--     outputs:
--               Variable Value
--               valid  is 1 if valid 0 if not
  procedure update_variable(variable var_list : in  var_field_ptr;
                            variable index    : in  integer;
                            variable value    : in  integer;
                            variable valid    : out integer);

-------------------------------------------------------------------------------
-- read_instruction_file
--  This procedure reads the instruction file, name passed throught file_name.
--  Pointers to records are passed in and out.  A table of variables is created
--  with variable name and value (converted to integer).  The instructions are
--  parsesed into the inst_sequ list.  Instructions are validated against the
--  inst_set which must have been set up prior to loading the instruction file.
  procedure read_instruction_file(constant file_name:  string;
                                  variable inst_set:   inout inst_def_ptr;
                                  variable var_list:   inout var_field_ptr;
                                  variable inst_sequ:  inout stim_line_ptr;
                                  variable file_list:  inout file_def_ptr);

------------------------------------------------------------------------------
-- access_inst_sequ
--   This procedure retreeves an instruction from the sequence of instructions.
--   Based on the line number you pass to it, it returns the instruction with
--   any variables substituted as integers.
  procedure access_inst_sequ(variable inst_sequ  :  in  stim_line_ptr;
                             variable var_list   :  in  var_field_ptr;
                             variable file_list  :  in  file_def_ptr;
                             variable sequ_num   :  in  integer;
                             variable inst       :  out text_field;
                             variable p1         :  out integer;
                             variable p2         :  out integer;
                             variable p3         :  out integer;
                             variable p4         :  out integer;
                             variable p5         :  out integer;
                             variable p6         :  out integer;
                             variable txt        :  out stm_text_ptr;
                             variable inst_len   :  out integer;
                             variable fname      :  out text_line;
                             variable file_line  :  out integer;
                             variable last_num   :  inout integer;
                             variable last_ptr   :  inout stim_line_ptr
                             );
------------------------------------------------------------------------
--  tokenize_line
--    This procedure takes a type text_line in and returns up to 6
--    tokens and the count in integer valid, as well if text string
--    is found the pointer to that is returned.
  procedure tokenize_line(variable text_line:   in  text_line;
                          variable token1:      out text_field;
                          variable token2:      out text_field;
                          variable token3:      out text_field;
                          variable token4:      out text_field;
                          variable token5:      out text_field;
                          variable token6:      out text_field;
                          variable token7:      out text_field;
                          variable txt_ptr:     out stm_text_ptr;
                          variable valid:       out integer);
-------------------------------------------------------------------------
-- string convertion
  function ew_to_str(int: integer; b: base) return text_field;
  function to_str(int: integer) return string;

-------------------------------------------------------------------------
--  Procedre print
--    print to stdout  string
  procedure print(s: in string);
-------------------------------------------------------------------------
--  Procedure print stim txt
  procedure txt_print(variable ptr: in stm_text_ptr);
-------------------------------------------------------------------------
--  Procedure print stim txt sub variables found
  procedure txt_print_wvar(variable var_list   :  in  var_field_ptr;
                           variable ptr        :  in  stm_text_ptr;
                           constant b          :  in  base);

-------------------------------------------------------------------------
--  convert a std_logic_vector to an unsigned integer
    function to_uninteger  ( constant vect     : in std_logic_vector
                         ) return integer;

end tb_pkg;
-------------------------------------------------------------------------------
--  new version 1.4
-- Revision History:
-- $Log: not supported by cvs2svn $
-- Revision 1.3  2007/09/02 04:04:04  sckoarn
-- Update of version 1.2 tb_pkg
-- See documentation for details
--
-- Revision 1.2  2007/08/21 02:43:14  sckoarn
-- Fix package definition to match with body
--
-- Revision 1.1.1.1  2007/04/06 04:06:48  sckoarn
-- Import of the vhld_tb
-------------------------------------------------------------------------------
