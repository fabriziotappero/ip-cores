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
-- This tests pAVR's interrupts.
-- NOT DONE YET.
-- </File info>



-- <File body>
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.std_util.all;
use work.pavr_util.all;
use work.pavr_constants.all;


entity test_pavr_rf is
end;


architecture test_pavr_rf_arch of test_pavr_rf is
   signal clk, res, syncres: std_logic;

   -- Clock counter
   signal cnt: std_logic_vector(7 downto 0);

begin

   generate_clock:
   process
   begin
      clk <= '1';
      wait for 50 ns;
      clk <= '0';
      wait for 50 ns;
   end process generate_clock;


   generate_reset:
   process
   begin
      res <= '0';
      wait for 100 ns;
      res <= '1';
      wait for 110 ns;
      res <= '0';
      wait for 1 ms;
   end process generate_reset;


   generate_sync_reset:
   process
   begin
      syncres <= '0';
      wait for 300 ns;
      syncres <= '1';
      wait for 110 ns;
      syncres <= '0';
      wait for 1 ms;
   end process generate_sync_reset;


   test_main:
   process(clk, res, syncres,
           cnt,
           pavr_rf_rd1_addr,
           pavr_rf_rd2_addr,
           pavr_rf_wr_addr, pavr_rf_wr_di,
           pavr_rf_x_di,
           pavr_rf_y_di,
           pavr_rf_z_di
          )
   begin
      if res='1' then
         -- Async reset

         cnt <= int_to_std_logic_vector(0, cnt'length);
      elsif clk'event and clk='1' then
         -- Clock counter
         cnt <= cnt+1;

         -- Initialize inputs.

         case std_logic_vector_to_nat(cnt) is

            -- TEST 1


            when others =>
               null;
         end case;

         if syncres='1' then
            -- Sync reset

            cnt <= int_to_std_logic_vector(0, cnt'length);
         end if;
      end if;
   end process test_main;


end;
-- </File body>
