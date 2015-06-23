-- <File header>
-- Project
--    pAVR (pipelined AVR) is an 8 bit RISC controller, compatible with Atmel's
--    AVR core, but about 3x faster in terms of both clock frequency and MIPS.
--    The increase in speed comes from a relatively deep pipeline. The original
--    AVR core has only two pipeline stages (fetch and execute), while pAVR has
--    6 pipeline stages:
--       1. PM    (read Program Memory)
--       2. INSTR (load Instruction)
--       3. RFRD  (decode Instruction and read Register File)
--       4. OPS   (load Operands)
--       5. ALU   (execute ALU opcode or access Unified Memory)
--       6. RFWR  (write Register File)
-- Version
--    0.32
-- Date
--    2002 August 07
-- Author
--    Doru Cuturela, doruu@yahoo.com
-- License
--    This program is free software; you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation; either version 2 of the License, or
--    (at your option) any later version.
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--    You should have received a copy of the GNU General Public License
--    along with this program; if not, write to the Free Software
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-- </File header>



-- <File info>
-- Test pAVR's ALU.
-- Note that the ALU is an asynchronous device.
-- Check ALU output and flags output for all ALU opcodes, one by one, for all of
--    these situations:
--    - carry in = 0
--    - carry in = 1
--    - additions generate overflow
--    - substractions generate overflow
-- There are 26 ALU opcodes to be checked for each situation.
-- </File info>



-- <File body>
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.std_util.all;
use work.pavr_util.all;
use work.pavr_constants.all;


entity test_alu is
end;


architecture test_alu_arch of test_alu is
   signal clk: std_logic;
   -- ALU inputs
   signal alu_op1: std_logic_vector(15 downto 0);
   signal alu_op2: std_logic_vector(7 downto 0);
   signal alu_opcode: std_logic_vector(pavr_alu_opcode_w - 1 downto 0);
   signal alu_flagsin: std_logic_vector(5 downto 0);
   -- ALU outputs
   signal alu_out: std_logic_vector(15 downto 0);
   signal alu_flagsout: std_logic_vector(5 downto 0);

   -- Declare the ALU.
   component pavr_alu
   port(
      pavr_alu_op1:      in  std_logic_vector(15 downto 0);
      pavr_alu_op2:      in  std_logic_vector(7 downto 0);
      pavr_alu_out:      out std_logic_vector(15 downto 0);
      pavr_alu_opcode:   in  std_logic_vector(pavr_alu_opcode_w - 1 downto 0);
      pavr_alu_flagsin:  in  std_logic_vector(5 downto 0);
      pavr_alu_flagsout: out std_logic_vector(5 downto 0)
   );
   end component;
   for all: pavr_alu use entity work.pavr_alu(pavr_alu_arch);

begin

   -- Instantiate the ALU.
   pavr_alu_instance1: pavr_alu
   port map(
      alu_op1,
      alu_op2,
      alu_out,
      alu_opcode,
      alu_flagsin,
      alu_flagsout
   );


   generate_clock:
   process
   begin
      clk <= '1';
      wait for 50 ns;
      clk <= '0';
      wait for 50 ns;
   end process generate_clock;


   test_main:
   process
   begin
      wait for 10 ns;

      -- For each of the following test patterns, check each of:
      --    - input 1, input 2, flags input
      --    - output, flags output

      -- Test ALU output, for all ALU opcodes; carry in = 1.
      for i in 0 to 25 loop
         alu_op1 <= int_to_std_logic_vector(16#44F9#, alu_op1'length);
         alu_op2 <= int_to_std_logic_vector(16#0A#, alu_op2'length);
         alu_opcode <= int_to_std_logic_vector(i, alu_opcode'length);
         alu_flagsin <= "000001";
         wait until clk'event and clk='1';
      end loop;

      -- Test ALU output, for all ALU opcodes; carry in = 0.
      for i in 0 to 25 loop
         alu_op1 <= int_to_std_logic_vector(16#44F5#, alu_op1'length);
         alu_op2 <= int_to_std_logic_vector(16#03#, alu_op2'length);
         alu_opcode <= int_to_std_logic_vector(i, alu_opcode'length);
         alu_flagsin <= "000000";
         wait until clk'event and clk='1';
      end loop;

      -- Test ALU output, for all ALU opcodes; carry in = 1. Additions (on both 8 bits and 16 bits) will generate carry out = 1.
      for i in 0 to 25 loop
         alu_op1 <= int_to_std_logic_vector(16#FFF8#, alu_op1'length);
         alu_op2 <= int_to_std_logic_vector(16#0C#, alu_op2'length);
         alu_opcode <= int_to_std_logic_vector(i, alu_opcode'length);
         alu_flagsin <= "000001";
         wait until clk'event and clk='1';
      end loop;

      -- Test ALU output, for all ALU opcodes; carry in = 1. Substractions (on both 8 bits and 16 bits) will generate carry out = 1.
      for i in 0 to 25 loop
         alu_op1 <= int_to_std_logic_vector(16#0005#, alu_op1'length);
         alu_op2 <= int_to_std_logic_vector(16#0C#, alu_op2'length);
         alu_opcode <= int_to_std_logic_vector(i, alu_opcode'length);
         alu_flagsin <= "000001";
         wait until clk'event and clk='1';
      end loop;

   end process test_main;

end;
-- </File body>
