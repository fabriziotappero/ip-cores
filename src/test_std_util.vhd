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
-- This tests the utilities defined in `std_util.vhd':
--    - cmp_std_logic_vector  (asynchronous function)
--    - sign_extend           (asynchronous function)
--    - zero_extend           (asynchronous function)
-- </File info>



-- <File body>
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.std_util.all;


entity test_std_util is
end;


architecture arch_test_std_util of test_std_util is
   signal clk: std_logic;
   -- Comparision output
   signal flag1: std_logic;
   -- Candidates to sign/zero extension and comparision
   signal v2_1,  v2_2,  v2_3:  std_logic_vector( 1 downto 0);
   signal v50_1, v50_2, v50_3: std_logic_vector(49 downto 0);
begin

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
      -- Set up default inputs.
      v2_1  <= "10";
      v2_2  <= "01";
      for i in 0 to 49 loop
         v50_1(i) <= '0';
         v50_2(i) <= '0';
      end loop;
      v50_1(49) <= '1';
      v50_1(3 downto 0) <= "1001";
      v50_2(3 downto 0) <= "1010";
      wait for 110 ns;

      -- TEST 1
      -- Test function `cmp_std_logic_vector'
      -- Try to compare 2 vectors with different lengths; this should assert the dedicated error.
      --flag1 <= cmp_std_logic_vector(v2_1, v50_1);
      --wait until clk'event and clk='1';
      -- Typical situations
      -- Shouldn't match
      flag1 <= cmp_std_logic_vector(v50_1, v50_2);
      wait until clk'event and clk='1';
      -- Should match
      flag1 <= cmp_std_logic_vector(v50_1, v50_1);
      wait until clk'event and clk='1';
      -- Shouldn't match
      flag1 <= cmp_std_logic_vector(sign_extend(v2_1, v50_1'length), zero_extend(v2_1, v50_1'length));
      wait until clk'event and clk='1';
      -- Should match
      flag1 <= cmp_std_logic_vector(sign_extend(v2_2, v50_1'length), zero_extend(v2_2, v50_1'length));
      wait until clk'event and clk='1';

      -- TEST 2
      -- Test function `sign_extend' and `zero_extend', negative input.
      -- Extremal case that should work. For length 2, typical case = extremal case.
      v2_3 <= sign_extend(v2_1, v2_3'length);
      wait until clk'event and clk='1';
      v2_3 <= zero_extend(v2_1, v2_3'length);
      wait until clk'event and clk='1';
      -- Some stupid length that should generate an error
      --v2_3 <= sign_extend(v2_1, 7);
      --wait until clk'event and clk='1';
      --v2_3 <= zero_extend(v2_1, 7);
      --wait until clk'event and clk='1';
      -- The same with width 50
      -- Typical case
      v50_3 <= sign_extend(v2_1, v50_3'length);
      wait until clk'event and clk='1';
      v50_3 <= zero_extend(v2_1, v50_3'length);
      wait until clk'event and clk='1';
      -- Extremal case that should work
      v50_3 <= sign_extend(v50_1, v50_3'length);
      wait until clk'event and clk='1';
      v50_3 <= zero_extend(v50_1, v50_3'length);
      wait until clk'event and clk='1';
      -- Some stupid length that should generate an error
      --v50_3 <= sign_extend(v50_1, 7);
      --wait until clk'event and clk='1';
      --v50_3 <= zero_extend(v50_1, 7);
      --wait until clk'event and clk='1';

      -- TEST 1
      -- Test function `sign_extend' and `zero_extend', positive input.
      -- Extremal case that should work. For length 2, typical case = extremal case.
      v2_3 <= sign_extend(v2_2, v2_3'length);
      wait until clk'event and clk='1';
      v2_3 <= zero_extend(v2_2, v2_3'length);
      wait until clk'event and clk='1';
      -- Some stupid length that should generate an error
      --v2_3 <= sign_extend(v2_2, 7);
      --wait until clk'event and clk='1';
      --v2_3 <= zero_extend(v2_2, 7);
      --wait until clk'event and clk='1';
      -- The same with width 50
      -- Typical case
      v50_3 <= sign_extend(v2_2, v50_3'length);
      wait until clk'event and clk='1';
      v50_3 <= zero_extend(v2_2, v50_3'length);
      wait until clk'event and clk='1';
      -- Extremal case that should work
      v50_3 <= sign_extend(v50_2, v50_3'length);
      wait until clk'event and clk='1';
      v50_3 <= zero_extend(v50_2, v50_3'length);
      wait until clk'event and clk='1';
      -- Some stupid length that should generate an error
      --v50_3 <= sign_extend(v50_2, 7);
      --wait until clk'event and clk='1';
      --v50_3 <= zero_extend(v50_2, 7);
      --wait until clk'event and clk='1';
   end process test_main;

end;
-- </File body>
