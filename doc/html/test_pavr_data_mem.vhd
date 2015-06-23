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
-- Test the Data Memory.
-- A trivial read-write test.
-- </File info>



-- <File body>
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.std_util.all;
use work.pavr_util.all;
use work.pavr_constants.all;


entity test_pavr_dm is
end;


architecture test_pavr_dm_arch of test_pavr_dm is
   signal clk, res: std_logic;

   -- Clock counter
   signal cnt: std_logic_vector(7 downto 0);

   -- DM connectivity
   signal pavr_dm_do    : std_logic_vector(7 downto 0);
   signal pavr_dm_wr    : std_logic;
   signal pavr_dm_addr  : std_logic_vector(pavr_dm_addr_w - 1 downto 0);
   signal pavr_dm_di    : std_logic_vector(7 downto 0);

   -- Declare the Data Memory
   component pavr_dm
   port(
      pavr_dm_clk:  in  std_logic;
      pavr_dm_wr:   in  std_logic;
      pavr_dm_addr: in  std_logic_vector(pavr_dm_addr_w - 1 downto 0);
      pavr_dm_di:   in  std_logic_vector(7 downto 0);
      pavr_dm_do:   out std_logic_vector(7 downto 0)
   );
   end component;
   for all: pavr_dm use entity work.pavr_dm(pavr_dm_arch);

begin

   -- Instantiate the Data Memory
   pavr_dm_instance1: pavr_dm
   port map(
      clk,
      pavr_dm_wr,
      pavr_dm_addr,
      pavr_dm_di,
      pavr_dm_do
   );

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


   test_main:
   process(clk, res,
           cnt,
           pavr_dm_addr, pavr_dm_di
          )
   begin
      if res='1' then
         -- Async reset
         cnt <= int_to_std_logic_vector(0, cnt'length);
      elsif clk'event and clk='1' then
         -- Clock counter
         cnt <= cnt+1;

         -- Initialize inputs.
         pavr_dm_wr <= '0';
         pavr_dm_addr <= int_to_std_logic_vector(0, pavr_dm_addr'length);
         pavr_dm_di <= int_to_std_logic_vector(0, pavr_dm_di'length);

         case std_logic_vector_to_nat(cnt) is
            -- TEST 1. Write DM.
            when 3 =>
               pavr_dm_wr <= '1';
               pavr_dm_addr <= int_to_std_logic_vector(24, pavr_dm_addr'length);
               pavr_dm_di <= int_to_std_logic_vector(16#A9#, pavr_dm_di'length);

            -- TEST 2. Read DM.
            when 4 =>
               pavr_dm_wr <= '0';
               pavr_dm_addr <= int_to_std_logic_vector(24, pavr_dm_addr'length);

            when others =>
               null;
         end case;
      end if;
   end process test_main;


end;
-- </File body>
