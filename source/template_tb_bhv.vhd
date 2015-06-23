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
-- Description :  The the testbench template file.
--
------------------------------------------------------------------------------
--  This file is a template used to generate test bench _bhv.vhd  file.
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

architecture bhv of tb_Top is


  signal tb_clk            : std_logic;

-------------------------------------------------------------------------
-- Component defintion

-------------------------------------------------------------------------------
-- USER Component instantiations
--for all: Arbitor      use entity tb_objects.arbitor(bhv);


  begin

-------------------------------------------------------------------------------
-- clock driver process
-- the main clock generator
clock_driver:
  process
  begin
    tb_clk <=  '0';
    wait for 5 ns;
    tb_clk <=  '1';
    wait for 5 ns;
  end process clock_driver;

  --------------------------------------------------------------------------
  -- Read_file Process:
  --
  -- This process is the main process of the testbench.  This process reads
  -- the stumulus file, parses it, creates lists of records, then uses these
  -- lists to exicute user instructions.  There are two passes through the
  -- script.  Pass one reads in the stimulus text file, checks it, creates
  -- lists of valid instructions, valid list of variables and finialy a list
  -- of user instructions(the sequence).  The second pass through the file,
  -- records are drawn from the user instruction list, variables are converted
  -- to integers and put through the elsif structure for exicution.
  --------------------------------------------------------------------------
  Read_file: process
    variable current_line : text_line;  -- The current input line
    variable inst_list    : inst_def_ptr;  -- the instruction list
    variable defined_vars : var_field_ptr; -- defined variables
    variable inst_sequ    : stim_line_ptr; -- the instruction sequence
    variable file_list    : file_def_ptr;  -- pointer to the list of file names
    variable last_sequ_num: integer;
    variable last_sequ_ptr: stim_line_ptr;

    variable instruction  : text_field;   -- instruction field
    variable par1         : integer;      -- paramiter 1
    variable par2         : integer;      -- paramiter 2
    variable par3         : integer;      -- paramiter 3
    variable par4         : integer;      -- paramiter 4
    variable par5         : integer;      -- paramiter 5
    variable par6         : integer;      -- paramiter 6
    variable txt          : stm_text_ptr;
    variable nbase        : base;         -- the number base to use
    variable len          : integer;      -- length of the instruction field
    variable file_line    : integer;      -- Line number in the stimulus file
    variable file_name    : text_line;    -- the file name the line came from
    variable v_line       : integer := 0; -- sequence number
    variable stack        : stack_register; -- Call stack
    variable stack_ptr    : integer  := 0;  -- call stack pointer
    variable wh_stack     : stack_register; -- while stack
    variable wh_dpth      : integer := 0;   -- while depth
    variable wh_ptr       : integer  := 0;  -- while pointer
    variable loop_num         : integer := 0;
    variable curr_loop_count  : int_array := (others => 0);
    variable term_loop_count  : int_array := (others => 0);
    variable loop_line        : int_array := (others => 0);

    variable messages     : boolean  := TRUE;
    variable if_state     : boolean  := FALSE;
    variable wh_state     : boolean  := FALSE;
    variable wh_end       : boolean  := FALSE;
    variable rand         : std_logic_vector(31 downto 0);
    variable rand_back    : std_logic_vector(31 downto 0);
    variable valid        : integer;

    --  scratchpad variables
    variable temp_int     : integer;
    variable temp_index   : integer;
    variable temp_str     : text_field;
    variable v_temp_vec1  : std_logic_vector(31 downto 0);
    variable v_temp_vec2  : std_logic_vector(31 downto 0);

    --------------------------------------------------------------------------
    --  Area for Procedures which may be usefull to more than one instruction.
    --    By coding here commonly used  code sections ...
    --    you know the benifits.
    ---------------------------------------------------------------------
    -----------------------------------------------------------------
    -- This procedure writes to the arbitor model access port
--    procedure arb_write(add: in integer; .....
--    end arb_write;


  begin  -- process Read_file
-- parse_tb1 start input initialization
    -----------------------------------------------------------------------
    --           Stimulus file instruction definition
    --  This is where the instructions used in the stimulus file are defined.
    --  Syntax is
    --     define_instruction(inst_def_ptr, instruction, paramiters)
    --           inst_def_ptr: is a record pointer defined in tb_pkg_header
    --           instruction:  the text instruction name  ie. "ADD_VAR"
    --           paramiters:   the number of fields or paramiters passed
    --
    --  Some basic instruction are created here, the user should create new
    --  instructions below the standard ones.
    ------------------------------------------------------------------------
    define_instruction(inst_list, "DEFINE_VAR", 2);  -- Define a Variable
    define_instruction(inst_list, "EQU_VAR", 2);
    define_instruction(inst_list, "ADD_VAR", 2);
    define_instruction(inst_list, "SUB_VAR", 2);
    define_instruction(inst_list, "CALL", 1);
    define_instruction(inst_list, "RETURN_CALL", 0);
    define_instruction(inst_list, "JUMP", 1);
    define_instruction(inst_list, "LOOP", 1);
    define_instruction(inst_list, "END_LOOP", 0);
    define_instruction(inst_list, "IF", 3);
    define_instruction(inst_list, "ELSEIF", 3);
    define_instruction(inst_list, "ELSE", 0);
    define_instruction(inst_list, "END_IF", 0);
    define_instruction(inst_list, "WHILE", 3);
    define_instruction(inst_list, "END_WHILE", 0);
    define_instruction(inst_list, "MESSAGES_OFF", 0);
    define_instruction(inst_list, "MESSAGES_ON", 0);
    define_instruction(inst_list, "ABORT", 0);       -- Error exit from sim
    define_instruction(inst_list, "FINISH", 0);      -- Normal exit from sim
    define_instruction(inst_list, "INCLUDE", 1);     -- Include a script file
    --  Start User defined instructions

    --  End User defined instructions
    ------------------------------------------------------------------------
    -- Read, test, and load the stimulus file
    read_instruction_file(stimulus_file, inst_list, defined_vars, inst_sequ,
                          file_list);

    -- initialize last info
    last_sequ_num  := 0;
    last_sequ_ptr  := inst_sequ;
------------------------------------------------------------------------
-- Using the Instruction record list, get the instruction and implement
-- it as per the statements in the elsif tree.
  while(v_line < inst_sequ.num_of_lines) loop
    v_line := v_line + 1;
    access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
         par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
         last_sequ_num, last_sequ_ptr);

--------------------------------------------------------------------------
    --if(instruction(1 to len) = "DEFINE_VAR") then
    --  null;  -- This instruction was implemented while reading the file

--------------------------------------------------------------------------
    if(instruction(1 to len) = "INCLUDE") then
      null;  -- This instruction was implemented while reading the file

--------------------------------------------------------------------------
    elsif(instruction(1 to len) = "ABORT") then
      assert (false)
        report "The test has aborted due to an error!!"
      severity failure;

--------------------------------------------------------------------------
    elsif(instruction(1 to len) = "FINISH") then
      assert (false)
        report "Test Finished with NO errors!!"
      severity failure;

--------------------------------------------------------------------------
    elsif(instruction(1 to len) = "EQU_VAR") then
      update_variable(defined_vars, par1, par2, valid);

--------------------------------------------------------------------------
    elsif(instruction(1 to len) = "ADD_VAR") then
      index_variable(defined_vars, par1, temp_int, valid);
      if(valid /= 0) then
        temp_int  :=  temp_int + par2;
        update_variable(defined_vars, par1, temp_int, valid);
      else
        assert (false)
          report "ADD_VAR Error: Not a valid Variable??"
        severity failure;
      end if;

--------------------------------------------------------------------------
    elsif(instruction(1 to len) = "SUB_VAR") then
      index_variable(defined_vars, par1, temp_int, valid);
      if(valid /= 0) then
        temp_int  :=  temp_int - par2;
        update_variable(defined_vars, par1, temp_int, valid);
      else
        assert (false)
          report "SUB_VAR Error: Not a valid Variable??"
        severity failure;
      end if;

--------------------------------------------------------------------------
    elsif(instruction(1 to len) = "CALL") then
      if(stack_ptr >= 7) then
        assert (false)
          report "Call Error: Stack over run, calls to deeply nested!!"
        severity failure;
      end if;
      stack(stack_ptr)  :=  v_line;
      stack_ptr  :=  stack_ptr + 1;
      v_line       :=  par1 - 1;

--------------------------------------------------------------------------
    elsif(instruction(1 to len) = "RETURN_CALL") then
      if(stack_ptr <= 0) then
        assert (false)
          report "Call Error: Stack under run??"
        severity failure;
      end if;
      stack_ptr  :=  stack_ptr - 1;
      v_line  :=  stack(stack_ptr);

--------------------------------------------------------------------------
    elsif(instruction(1 to len) = "JUMP") then
      v_line    :=  par1 - 1;
      wh_state  :=  false;
      wh_stack  := (others => 0);
      wh_dpth   := 0;
      wh_ptr    := 0;
      stack     := (others => 0);
      stack_ptr := 0;

--------------------------------------------------------------------------------
     elsif (instruction(1 to len) = "LOOP") then
    loop_num := loop_num + 1;
        loop_line(loop_num) := v_line;
        curr_loop_count(loop_num) := 0;
        term_loop_count(loop_num) := par1;
    assert (messages)
          report LF & "Executing LOOP Command" &
                 LF & "  Nested Loop:" & HT & integer'image(loop_num) &
                 LF & "  Loop Length:" & HT & integer'image(par1)
          severity note;

--------------------------------------------------------------------------------
     elsif (instruction(1 to len) = "END_LOOP") then
        curr_loop_count(loop_num) := curr_loop_count(loop_num) + 1;
        if (curr_loop_count(loop_num) = term_loop_count(loop_num)) then
          loop_num := loop_num - 1;
        else
          v_line := loop_line(loop_num);
        end if;

--------------------------------------------------------------------------------
     elsif (instruction(1 to len) = "IF") then
       if_state  :=  false;
       case par2 is
         when 0 => if(par1 = par3) then if_state  :=  true; end if;
         when 1 => if(par1 > par3) then if_state  :=  true; end if;
         when 2 => if(par1 < par3) then if_state  :=  true; end if;
         when 3 => if(par1 /= par3) then if_state :=  true; end if;
         when 4 => if(par1 >= par3) then if_state :=  true; end if;
         when 5 => if(par1 <= par3) then if_state :=  true; end if;
         when others =>
           assert (false)
             report LF & "ERROR:  IF instruction got an unexpected value" &
                 LF & "  in parameter 2!" & LF &
                  "Found on line " & (ew_to_str(file_line,dec)) & " in file " & file_name
             severity failure;
       end case;

       if(if_state = false) then
         v_line := v_line + 1;
         access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
            par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
            last_sequ_num, last_sequ_ptr);
         while(instruction(1 to len) /= "ELSE" and
               instruction(1 to len) /= "ELSEIF" and
               instruction(1 to len) /= "END_IF") loop
           if(v_line < inst_sequ.num_of_lines) then
             v_line := v_line + 1;
             access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                 par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                 last_sequ_num, last_sequ_ptr);
           else
             assert (false)
              report LF & "ERROR:  IF instruction unable to find terminating" &
                     LF & "    ELSE, ELSEIF or END_IF statement."
              severity failure;
           end if;
         end loop;
         v_line := v_line - 1;  -- re-align so it will be operated on.
       end if;

--------------------------------------------------------------------------------
     elsif (instruction(1 to len) = "ELSEIF") then
       if(if_state = true) then  -- if the if_state is true then skip to the end
         v_line := v_line + 1;
         access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
             par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
             last_sequ_num, last_sequ_ptr);
         while(instruction(1 to len) /= "END_IF") loop
           if(v_line < inst_sequ.num_of_lines) then
             v_line := v_line + 1;
             access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                 par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                 last_sequ_num, last_sequ_ptr);
           else
             assert (false)
              report LF & "ERROR:  IF instruction unable to find terminating" &
                     LF & "    ELSE, ELSEIF or END_IF statement."
              severity failure;
           end if;
         end loop;
         v_line := v_line - 1;  -- re-align so it will be operated on.

       else
         case par2 is
           when 0 => if(par1 = par3) then if_state  :=  true; end if;
           when 1 => if(par1 > par3) then if_state  :=  true; end if;
           when 2 => if(par1 < par3) then if_state  :=  true; end if;
           when 3 => if(par1 /= par3) then if_state :=  true; end if;
           when 4 => if(par1 >= par3) then if_state :=  true; end if;
           when 5 => if(par1 <= par3) then if_state :=  true; end if;
           when others =>
             assert (false)
               report LF & "ERROR:  ELSEIF instruction got an unexpected value" &
                   LF & "  in parameter 2!" & LF &
                    "Found on line " & (ew_to_str(file_line,dec)) & " in file " & file_name
               severity failure;
         end case;

         if(if_state = false) then
           v_line := v_line + 1;
           access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
               par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
               last_sequ_num, last_sequ_ptr);
           while(instruction(1 to len) /= "ELSE" and
                 instruction(1 to len) /= "ELSEIF" and
                 instruction(1 to len) /= "END_IF") loop
             if(v_line < inst_sequ.num_of_lines) then
               v_line := v_line + 1;
               access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                   par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                   last_sequ_num, last_sequ_ptr);
             else
               assert (false)
                report LF & "ERROR:  ELSEIF instruction unable to find terminating" &
                       LF & "    ELSE, ELSEIF or END_IF statement."
                severity failure;
             end if;
           end loop;
           v_line := v_line - 1;  -- re-align so it will be operated on.
         end if;
       end if;

--------------------------------------------------------------------------------
     elsif (instruction(1 to len) = "ELSE") then
       if(if_state = true) then  -- if the if_state is true then skip the else
         v_line := v_line + 1;
         access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
             par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
             last_sequ_num, last_sequ_ptr);
         while(instruction(1 to len) /= "END_IF") loop
           if(v_line < inst_sequ.num_of_lines) then
             v_line := v_line + 1;
             access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                 par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                 last_sequ_num, last_sequ_ptr);
           else
             assert (false)
              report LF & "ERROR:  IF instruction unable to find terminating" &
                     LF & "    ELSE, ELSEIF or END_IF statement."
              severity failure;
           end if;
         end loop;
         v_line := v_line - 1;  -- re-align so it will be operated on.
       end if;

--------------------------------------------------------------------------------
     elsif (instruction(1 to len) = "END_IF") then
       null;  -- instruction is a place holder for finding the end of IF.

--------------------------------------------------------------------------------
     elsif (instruction(1 to len) = "WHILE") then
       wh_state  :=  false;
       case par2 is
         when 0 => if(par1 =  par3) then wh_state :=  true; end if;
         when 1 => if(par1 >  par3) then wh_state :=  true; end if;
         when 2 => if(par1 <  par3) then wh_state :=  true; end if;
         when 3 => if(par1 /= par3) then wh_state :=  true; end if;
         when 4 => if(par1 >= par3) then wh_state :=  true; end if;
         when 5 => if(par1 <= par3) then wh_state :=  true; end if;
         when others =>
           assert (false)
             report LF & "ERROR:  WHILE instruction got an unexpected value" &
                 LF & "  in parameter 2!" & LF &
                  "Found on line " & (ew_to_str(file_line,dec)) & " in file " & file_name
             severity failure;
       end case;

       if(wh_state = true) then
         wh_stack(wh_ptr) :=  v_line;
         wh_ptr  := wh_ptr + 1;
       else
         wh_end := false;
         while(wh_end /= true) loop
           if(v_line < inst_sequ.num_of_lines) then
             v_line := v_line + 1;
             access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                 par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                 last_sequ_num, last_sequ_ptr);
           else
             assert (false)
               report LF & "ERROR:  WHILE instruction unable to find terminating" &
                      LF & "    END_WHILE statement."
             severity failure;
           end if;

           -- if is a while need to escape it
           if(instruction(1 to len) = "WHILE") then
             wh_dpth := wh_dpth + 1;
           -- if is the end_while we are looking for
           elsif(instruction(1 to len) = "END_WHILE") then
             if(wh_dpth = 0) then
               wh_end := true;
             else
               wh_dpth := wh_dpth - 1;
             end if;
           end if;
         end loop;
       end if;

--------------------------------------------------------------------------------
     elsif (instruction(1 to len) = "END_WHILE") then
       if(wh_ptr > 0) then
         v_line  :=  wh_stack(wh_ptr - 1) - 1;
         wh_ptr  := wh_ptr - 1;
       end if;

--------------------------------------------------------------------------------
     elsif (instruction(1 to len) = "MESSAGES_OFF") then
       messages  := TRUE;
--------------------------------------------------------------------------------
     elsif (instruction(1 to len) = "MESSAGES_ON") then
       messages  := FALSE;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--  USER Istruction area.  Add all user instructions below this
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--    elsif (instruction(1 to len) = "RESET_SYS") then


--------------------------------------------------------------------------------
--  USER Istruction area.  Add all user instructions above this
--------------------------------------------------------------------------------
    --------------------------------------------------------------------------
    -- catch those little mistakes
    else
      assert (false)
        report LF & "ERROR:  Seems the command  " & instruction(1 to len) & " was defined but" & LF &
                    "was not found in the elsif chain, please check spelling."
        severity failure;
    end if;  -- else if structure end
    -- after the instruction is finished print out any txt and sub vars
    txt_print_wvar(defined_vars, txt, hex);
  end loop;  -- Main Loop end

  assert (false)
    report LF & "The end of the simulation! It was not terminated as expected." & LF
  severity failure;

  end process Read_file;


end bhv;
-------------------------------------------------------------------------------
-- Revision History:
--  version 1.4
-- $Log: not supported by cvs2svn $
-- Revision 1.3  2007/11/14 02:35:56  sckoarn
-- Fix to WHILE instruction: Change if_state typo to wh_state
--
-- Revision 1.2  2007/09/02 04:04:04  sckoarn
-- Update of version 1.2 tb_pkg
-- See documentation for details
--
-- Revision 1.1.1.1  2007/04/06 04:06:48  sckoarn
-- Import of the vhld_tb
--
--
-------------------------------------------------------------------------------
