-------------------------------------------------------------------------------
--             Copyright 2011 Ken Campbell
--                        All Rights Reserved
-------------------------------------------------------------------------------
-- $Author: ken $
--
-- $date:  $
--
-- $Id:  $
--
-- $Source:  $
--
-- Description :
--          Code snipets from / for various VHDL Test Bench Facilities.
--
--   Contents:
--     Section 1:  Code from Usage Tips: Interrupts and Waiting.
--     Section 2:  Code from CPU emulation: some starter commands
--     Section 3:  Code for internal test bench implementation
--     Section 4:  Code for Verify commands
--
------------------------------------------------------------------------------
--  Redistribution and use in source and binary forms, with or without
--  modification, in whole or part, are permitted:
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
-------------------------------------------------------------------------------------
--###################################################################################
--  Section 1:  Interrupts and Waiting.
architecture bhv of tb_xxx is
--  ...
constant MAX_TIME : integer  :=  60000;
--  ...

Read_file : process
--  ...
    define_instruction(inst_list, "WAIT_IRQ", 0);
--  ...
--------------------------------------------------
     elsif (instruction(1 to len) = "WAIT_IRQ") then
        temp_int := 0;                               -- initialize counter
        while(dut_irq /= '1') then              -- while IRQ not asserted
           wait for clk'event and clk = '1';  -- wait for clock cycle
            temp_int := temp_int + 1;         --  add one to clock counter
            assert (temp_int /= MAX_TIME)  -- if count = max time  quit.
              report "Error:  Time out while waiting for IRQ!!"
            severity failure;
        end loop;

-------------------------------------------------------------------------------------------
    define_instruction(inst_list, "MAX_WAIT_SET", 1);
--  ...
--------------------------------------------------------
     elsif (instruction(1 to len) = "MAX_WAIT_SET") then
        MAX_TIME  <= par1;                               -- set the max
        wait for 0 ps;

architecture bhv of tb_xxx is
--  ...
  signal irq_expect :  boolean := false;
--  ...
Read_file : process
--  ...
    define_instruction(inst_list, "EXPECT_IRQ", 1);
--  ...
--------------------------------------------------------------------------------
     elsif (instruction(1 to len) = "EXPECT_IRQ") then
       if(par1 = 0) then
         irq_expect <= false;
       else
         irq_expect <= true;
       end if;
        wait for 0 ps;
--  ...
  end process Read_file;

------------------------
irq_mon:
  process(clk, dut_irq)
  begin
    -- on the falling edge, assume rising edge assertion, one clock wide
    if(clk'event and clk = '0') then
      if(dut_irq = '1') then
        if(irq_expect = true) then
            assert (false)
              report "NOTE:  An expected IRQ occurred."
            severity note;
        else
            assert (false)
              report "ERROR:  An unexpected IRQ occurred."
            severity failure;
        end if;
      end if;
    end if;
end process irq_mon;
--  END  Section 1:
--###################################################################################


-------------------------------------------------------------------------------------
--###################################################################################
--  Section 2:  CPU Emulation Commands
-- starting from the top of the bhv architecture
architecture bhv of xxx_tb is
  -- create type for cpu array of registers
  --  Type needed for CPU registers, it can be resized if needed
  type cpu_reg_array is array(0 to 7) of std_logic_vector(31 downto 0);
  -- optional constant to help test for zero
  constant zeros   : std_logic_vector(31 downto 0) := (others => '0');
--  ...
--  ...
  --------------------------------------------------------------------------
  Read_file: process
--  ...  variable definitions
  -------------------
  --  CCR def
  --   bit 0   zero, will be set when results are zero
  --   bit 1   equal, will be set when compared values are equal
  --   bit 2   greater than, will be set when source1 is > source2
  --   bit 3   less than, will be set when source1 is < source2
  --   others undefined
    variable v_reg_ccr    : std_logic_vector(7 downto 0);  -- condition code register
    variable v_regs       : cpu_reg_array;                 -- Create variable of cpu regs
    variable v_tmp_bit    : std_logic;                     -- nice place to store a bit temp
    variable v_read_data  : std_logic_vector(31 downto 0);
--  ...
  begin  -- process Read_file
--  ...
    define_instruction(inst_list, "READ_TO_REG", 2);
    define_instruction(inst_list, "REG_TO_VAR", 2);
    define_instruction(inst_list, "MOV", 2);
    define_instruction(inst_list, "MOVI", 2);
    define_instruction(inst_list, "AND", 3);
    define_instruction(inst_list, "ANDI", 3);
    define_instruction(inst_list, "OR", 3);
    define_instruction(inst_list, "NOT", 2);
    define_instruction(inst_list, "XOR", 3);
    define_instruction(inst_list, "SLL", 2);
    define_instruction(inst_list, "SLR", 2);
    define_instruction(inst_list, "CMP", 2);
    define_instruction(inst_list, "BE", 1);
    define_instruction(inst_list, "BZ", 1);
    define_instruction(inst_list, "BB", 4);

    ------------------------------------------------------------------------
    -- Read, test, and load the stimulus file
    read_instruction_file(stimulus_file, inst_list, defined_vars, inst_sequ,
                          file_list);
    -- initialize last info
    last_sequ_num  := 0;
    last_sequ_ptr  := inst_sequ;
    -- initialize  registers  -- this is the zering of the registers and CCR
    v_regs           := (others => (others => '0'));
    v_reg_ccr        := (others => '0');
--  ...
--------------------------------------------------------------------------
-- READ_TO_REG
--   Read a addressed location to the local register array
--     par1   address
--     par2   target reg (index)
    elsif(instruction(1 to len) = "READ_TO_REG") then
      v_temp_vec1     :=  std_logic_vector(conv_unsigned(par1, 32));
      STM_ADD   <=  v_temp_vec1;
      STM_DAT   <=  (others => 'Z');
      STM_RWN   <=  '1';
      wait for 1 ps;
      STM_REQ_N  <=  '0';
      wait until STM_ACK_N'event and STM_ACK_N = '0';
      STM_REQ_N  <=  '1';
      STM_ADD   <=  (others => 'Z');
      v_read_data  :=  STM_DAT;
      v_regs(par2)   :=  STM_DAT;
      STM_RWN   <=  '1';
      wait for 1 ps;

--------------------------------------------------------------------------
-- REG_TO_VAR
--  Write a register array value to a Variable.
--     par1   target reg (index)
--     par2   Variable to update with value from target reg
    elsif(instruction(1 to len) = "REG_TO_VAR") then
      temp_int  :=  to_uninteger(v_regs(par1));            --<< NEW to_uninteger conversion function
      update_variable(defined_vars, par2, temp_int, valid);
-- the to_uninteger function was added because to add the function through
--   std_developerskit overflowed my PE student simulator.  I am tired of
--   conversion and created my own function, tb_pkg contained.  see additional
--   code at the bottom of this section.  You can replace this with functions
--   you usually use, or use std_developerskit if you are on real tools.
--------------------------------------------------------------------------
-- MOV
--   Move one register contents to another register.  Source contents maintained
--     par1   reg1 index
--     par2   reg2 index
    elsif(instruction(1 to len) = "MOV") then
      v_regs(par2)  :=  v_regs(par1);

--------------------------------------------------------------------------
-- MOVI
--   Move value passed to destination register
--     par1   value
--     par2   reg index
    elsif(instruction(1 to len) = "MOVI") then
      v_regs(par2)  :=  std_logic_vector(conv_unsigned(par1, 32));

--------------------------------------------------------------------------
-- AND
--   AND two registers and write results to target register
--     par1   reg1 index
--     par2   reg2 index
--     par3   target results reg index
    elsif(instruction(1 to len) = "AND") then
      v_regs(par3)  :=  v_regs(par1) and v_regs(par2);
      if(v_regs(par3) = zeros) then
        v_reg_ccr(0) := '1';
      else
        v_reg_ccr(0) := '0';
      end if;

--------------------------------------------------------------------------
-- ANDI
--   AND the passed value with the indexed register and store in register index
--     par1   value
--     par2   reg index
--     par3   target results reg index
    elsif(instruction(1 to len) = "ANDI") then
      v_regs(par3)  :=  std_logic_vector(conv_unsigned(par1, 32)) and v_regs(par2);
      if(v_regs(par3) = zeros) then
        v_reg_ccr(0) := '1';
      else
        v_reg_ccr(0) := '0';
      end if;

--------------------------------------------------------------------------
-- OR
--   OR two registers and write results to target register
--     par1   reg1 index
--     par2   reg2 index
--     par3   target results reg index
    elsif(instruction(1 to len) = "OR") then
      v_regs(par3)  :=  v_regs(par1) or v_regs(par2);
      if(v_regs(par3) = zeros) then
        v_reg_ccr(0) := '1';
      else
        v_reg_ccr(0) := '0';
      end if;

--------------------------------------------------------------------------
-- XOR
--   XOR two registers and write results to target register
--     par1   reg1 index
--     par2   reg2 index
--     par3   target results reg index
    elsif(instruction(1 to len) = "XOR") then
      v_regs(par3)  :=  v_regs(par1) xor v_regs(par2);
      if(v_regs(par3) = zeros) then
        v_reg_ccr(0) := '1';
      else
        v_reg_ccr(0) := '0';
      end if;

--------------------------------------------------------------------------
-- NOT
--   NOT a register and write results to target register
--     par1   reg1 index
--     par2   target results reg index
    elsif(instruction(1 to len) = "NOT") then
      v_regs(par2)  :=  not v_regs(par1);
      if(v_regs(par2) = zeros) then
        v_reg_ccr(0) := '1';
      else
        v_reg_ccr(0) := '0';
      end if;

--------------------------------------------------------------------------
-- SLL
--   Shift the register left rotate the upper bits into the lower bits
--     par1   reg1 index
--     par2   bit positions to Left
    elsif(instruction(1 to len) = "SLL") then
      v_temp_vec1  :=  v_regs(par1);
      temp_int  := par2 - 1;
      v_regs(par1) :=  v_temp_vec1(31-par2 downto 0) & v_temp_vec1(31 downto 31 - temp_int);

--------------------------------------------------------------------------
-- SLR
--   Shift the register right rotate the lower bits into the upper bits
--     par1   reg1 index
--     par2   bit positions to Right
    elsif(instruction(1 to len) = "SLR") then
      v_temp_vec1  :=  v_regs(par1);
      temp_int  := par2 - 1;
      v_regs(par1) :=  v_temp_vec1(temp_int downto 0) & v_temp_vec1(31 downto par2);

--------------------------------------------------------------------------
-- CMP
--   Compare one register against another and set CCR bits, no effect on registers
--     par1   reg1 index source1
--     par2   reg2 index source2
    elsif(instruction(1 to len) = "CMP") then
      v_reg_ccr  :=  (others => '0');
      if(v_regs(par1) = v_regs(par2)) then
        v_reg_ccr(1)  :=  '1';
      elsif(v_regs(par1) > v_regs(par2)) then
        v_reg_ccr(2)  :=  '1';
      elsif(v_regs(par1) < v_regs(par2)) then
        v_reg_ccr(3)  :=  '1';
      end if;

      if(v_regs(par1) = zeros) then
        v_reg_ccr(1)  :=  '0';
      end if;

--------------------------------------------------------------------------
-- BE
--   Branch if equal
--     par1   jump location
    elsif(instruction(1 to len) = "BE") then
      if(v_reg_ccr(1) = '1') then
        v_line    :=  par1 - 1;
        wh_state  :=  false;
        wh_stack  := (others => 0);
        wh_dpth   := 0;
        wh_ptr    := 0;
        --stack     := (others => 0);
        --stack_ptr := 0;
      end if;

--------------------------------------------------------------------------
-- BZ
--   Branch if Zero
--     par1   jump location
    elsif(instruction(1 to len) = "BZ") then
      if(v_reg_ccr(0) = '1') then
        v_line    :=  par1 - 1;
        wh_state  :=  false;
        wh_stack  := (others => 0);
        wh_dpth   := 0;
        wh_ptr    := 0;
        --stack     := (others => 0);
        --stack_ptr := 0;
      end if;

--------------------------------------------------------------------------
-- BB
--   Branch if bit in register is set/clear
--     par1   register
--     par2   register bit index
--     par3   compare value : 0/1
--     par4   jump location
    elsif(instruction(1 to len) = "BB") then
      v_temp_vec1  :=  v_regs(par1);
      if(par3 = 0) then
        v_tmp_bit  := '0';
      else
        v_tmp_bit  := '1';
      end if;
      if(v_temp_vec1(par2) = v_tmp_bit) then
        v_line    :=  par4 - 1;
        wh_state  :=  false;
        wh_stack  := (others => 0);
        wh_dpth   := 0;
        wh_ptr    := 0;
        --stack     := (others => 0);
        --stack_ptr := 0;
      end if;
--  ...
  end process Read_file;
end bhv;
--  Stimulus_file commands used for testing.  I used no VERIFY command
--    as I watched the functionality in single stepping through code.
DEFINE_VAR dat x01
EQU_VAR dat x12345678
MASTR_WRITE 3 $dat
READ_TO_REG 3 0
OR 0 1 2
AND 0 2 1
MOV 1 3
XOR 0 1 4
NOT 4 5
SLL 0 1
SLL 1 2
SLL 2 3
SLL 3 4
SLR 0 1
SLR 1 2
SLR 2 3
SLR 3 4
MOVI x87654321 7

ANDI 0 0 0
BZ $B1
MOVI x1234678 0

B1:
CMP 1 2
BE $B2
MOVI 0 1

B2:
BB 0 0 1 $B3
BB 0 0 0 $B3  "Didnt jup as expected
MOVI 0 1

B3:

FINISH

--------------------------------------------------------------------------------
-- tb_pkg function
---   header section
-------------------------------------------------------------------------
--  convert a std_logic_vector to an unsigned integer
    function to_uninteger  ( constant vect     : in std_logic_vector
                         ) return integer;
--  body section
---------------------------------------------------------------------------------------
  function to_uninteger ( constant vect     : in std_logic_vector
                        ) return integer is
    variable result   : integer := 0;
    variable len      : integer := vect'length;
    variable idx      : integer;
    variable tmp_str  : text_field;
    variable file_name: text_line;
  begin
    -- point to start of string
    idx  :=  1;
    -- convert std_logic_vector to text_field
    for i in len - 1 downto 0 loop
      if(vect(i) = '1') then
        tmp_str(idx) := '1';
      elsif(vect(i) = '0') then
        tmp_str(idx) := '0';
      else
        assert(false)
          report LF & "ERROR:  Non 0/1 value found in std_logic_vector passed to to_uninteger function!!" & LF &
                "Returning 0."
        severity note;
        return result;
      end if;
      idx := idx + 1;
    end loop;
    -- call bin txt to int fuction with dummy fn and sequ idx
    result := bin2integer(tmp_str, file_name, idx);
    return result;

  end to_uninteger;



--  Section 2:  END
--###################################################################################

--
--###################################################################################
-- Section 3: Begin
--   This section presents the code needed to make an internal test bench
--     an optional compile item through the use of VHDL generics and generate
--     statements.

-- this is the top enity or at the level where you can assign the
--    en_bfm generic and it makes sense
entity my_top_dut is
  generic (
           g_en_bfm  :  integer :=  0
          );
  port (
     --  top port definitions
       );
end enity my_top_dut;


architecture struct of my_top_dut is
-- this is the component of an internal block of my_top_dut
component rtl_block
  port (
        reset_n  : in      std_logic;
        clk_in   : in      std_logic;
        -- ...
       );
end component;
-- bhv_block has the same pin out as rtl_block, except for the generic
component bhv_block
  generic (
           stimulus_file: in string
          );
  port (
        reset_n  : in      std_logic;
        clk_in   : in      std_logic;
        -- ...
       );
end component;
--....
begin
  -- if generic is default value, include rtl
  if(g_en_bfm = 0) generate
  begin
    rtl_b1: rtl_block
      port map(
            reset_n  =>  reset_n,
            clk_in   =>  clk,
            -- ...
           );
  end generate;
  -- if generic is set for bhv, include it
  if(g_en_bfm = 1) generate
  begin
    bfm: bhv_block
      generic map(
                  stimulus_file => "stm/stimulus_file.stm"
                 )
      port map(
            reset_n  =>  reset_n,
            clk_in   =>  clk,
            -- ...
           );
  end generate;
-- ...
end struct;

--  Section 3 End:
--###################################################################

--####################################################################
--  Section 4 Start:
--    This section provides some example VERIFY commands.
  --------------------------------------------------------------------------
  Read_file: process
  --  ...
    variable v_tmp_bit    : std_logic;
    variable v_upb        : integer := 31;  -- upper bounds
    variable v_lob        : integer := 0;  -- lower bounds
    variable v_temp_read  : std_logic_vector(31 downto 0);
  --  ...
    define_instruction(inst_list, "SLICE_SET", 2);
    define_instruction(inst_list, "VERIFY", 1);
    define_instruction(inst_list, "VERIFY_BIT", 2);
    define_instruction(inst_list, "VERIFY_SLICE", 1);
  --  ...


-----------------------------------------------------------------------------
--  SLICE_SET     set the slice of the data for testing
--     par1       upper bound value  -  must be larger than par2 and less than 32
--     par2       lower bound value
   elsif (instruction(1 to len) = "SLICE_SET") then
     -- test user input.
     assert (par1 < 32 and par1 >= 1)
       report LF & "ERROR:  Par1 in SLICE_SET command input range is out of bounds" & LF &
        "Found on line " & (integer'image(file_line)) & " in file " & file_name
     severity failure;
     assert (par2 < 31 and par2 >= 0)
       report LF & "ERROR:  Par2 in SLICE_SET command input range is out of bounds" & LF &
        "Found on line " & (integer'image(file_line)) & " in file " & file_name
     severity failure;
     assert (par1 > par2)
       report LF & "ERROR: SLICE_SET command bounds incorrectly defined. Par1 must be greater than Par2." & LF &
        "Found on line " & (integer'image(file_line)) & " in file " & file_name
     severity failure;
     -- update variables
     v_upb  :=  par1;
     v_lob  :=  par2;

-----------------------------------------------------------------------------
--  VERIFY    test that the data in temp_read is the passed value.
--      par1  value to test against.
   elsif (instruction(1 to len) = "VERIFY") then
     v_temp_vec1     :=  std_logic_vector(conv_unsigned(par1, 32));

     assert (v_temp_vec1 = v_temp_read)
       report LF & "ERROR: VERIFY command compare value was not as expected!!" &
         LF & "Got " & (to_hstring(v_temp_read)) &
         LF & "Expected " & (to_hstring(v_temp_vec1)) & LF &
        "Found on line " & (integer'image(file_line)) & " in file " & file_name
      severity failure;

-----------------------------------------------------------------------------
--  VERIFY_BIT    test that the data bit in temp_read is the passed value.
--      par1  index into 32 bit temp_read
--      par2  bit value
   elsif (instruction(1 to len) = "VERIFY_BIT") then
     assert (par1 >= 0 and par1 < 32)
       report LF & "ERROR: VERIFY_BIT command bit index is out of range. Valid is 0 - 31." & LF &
        "Found on line " & (integer'image(file_line)) & " in file " & file_name
     severity failure;
     if(par2 = 0) then
         v_tmp_bit := '0';
     else
         v_tmp_bit := '1';
     end if;
     assert (v_temp_read(par1) = v_tmp_bit)
       report LF & "ERROR: VERIFY_BIT command miss-compare!" & LF &
        "We tested for " & (integer'image(par2)) & LF &
        "Found on line " & (integer'image(file_line)) & " in file " & file_name
     severity failure;

-----------------------------------------------------------------------------
--  VERIFY_SLICE    test that the data in temp_read is the passed value.
--      par1   value
   elsif (instruction(1 to len) = "VERIFY_SLICE") then
     v_temp_vec1  :=  (others => '0');
     temp_int   :=  v_upb - v_lob + 1;
     v_temp_vec1(v_upb downto v_lob)     :=  std_logic_vector(conv_unsigned(par1, temp_int));
     -- no need to test ranges here
     assert (v_temp_vec1(v_upb downto v_lob) = v_temp_read(v_upb downto v_lob))
       report LF & "ERROR: VERIFY_SLICE Compare Value was not as expected!!" &
         LF & "Got " & (to_hstring(v_temp_read(v_upb downto v_lob))) &
         LF & "Expected " & (to_hstring(v_temp_vec1(v_upb downto v_lob))) & LF &
        "Found on line " & (integer'image(file_line)) & " in file " & file_name
      severity failure;

--  END Section 4
--#######################################################################################
