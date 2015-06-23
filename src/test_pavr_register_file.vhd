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
-- This tests pAVR's Register File.
-- The following tests are done:
--    - read all ports, one at a time
--       - read port 1 (RFRD1)
--       - read port 2 (RFRD2)
--       - write port (RFWR)
--       - write pointer register X (RFXWR)
--       - write pointer register Y (RFYWR)
--       - write pointer register Z (RFZWR)
--    - combined RFRD1, RFRD2, RFWR
--       They should work simultaneousely.
--    - combined RFXWR, RFYWR, RFZWR
--       They should work simultaneousely.
--    - combined RFRD1, RFRD2, RFWR, RFXWR, RFYWR, RFZWR
--       That is, all RF ports are accessed simultaneousely. They should work do
--       their job.
--       However, note that the pointer registers are accessible for writting by
--       their own ports but also by the RF write port. Writing them via pointer
--       register write ports overwrites writing via general write port.
--       Even though concurrent writing could happen in a perfectly legal AVR
--       implementation, AVR's behavior is unpredictible (what write port has
--       priority). We have chosen for pAVR the priority as mentioned above.
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

   -- RF read port 1
   signal pavr_rf_rd1_addr : std_logic_vector(4 downto 0);
   signal pavr_rf_rd1_rd   : std_logic;
   signal pavr_rf_rd1_do   : std_logic_vector(7 downto 0);

   -- RF read port 2
   signal pavr_rf_rd2_addr : std_logic_vector(4 downto 0);
   signal pavr_rf_rd2_rd   : std_logic;
   signal pavr_rf_rd2_do   : std_logic_vector(7 downto 0);

   -- RF write port
   signal pavr_rf_wr_addr  : std_logic_vector(4 downto 0);
   signal pavr_rf_wr_wr    : std_logic;
   signal pavr_rf_wr_di    : std_logic_vector(7 downto 0);

   -- X pointer port
   signal pavr_rf_x     : std_logic_vector(15 downto 0);
   signal pavr_rf_x_wr  : std_logic;
   signal pavr_rf_x_di  : std_logic_vector(15 downto 0);

   -- Y pointer port
   signal pavr_rf_y     : std_logic_vector(15 downto 0);
   signal pavr_rf_y_wr  : std_logic;
   signal pavr_rf_y_di  : std_logic_vector(15 downto 0);

   -- Z pointer port
   signal pavr_rf_z     : std_logic_vector(15 downto 0);
   signal pavr_rf_z_wr  : std_logic;
   signal pavr_rf_z_di  : std_logic_vector(15 downto 0);

   -- Declare the Register File.
   component pavr_rf
   port(
      pavr_rf_clk:     in std_logic;
      pavr_rf_res:     in std_logic;
      pavr_rf_syncres: in std_logic;

      -- Read port #1
      pavr_rf_rd1_addr: in  std_logic_vector(4 downto 0);
      pavr_rf_rd1_rd:   in  std_logic;
      pavr_rf_rd1_do:   out std_logic_vector(7 downto 0);

      -- Read port #2
      pavr_rf_rd2_addr: in  std_logic_vector(4 downto 0);
      pavr_rf_rd2_rd:   in  std_logic;
      pavr_rf_rd2_do:   out std_logic_vector(7 downto 0);

      -- Write port
      pavr_rf_wr_addr: in std_logic_vector(4 downto 0);
      pavr_rf_wr_wr:   in std_logic;
      pavr_rf_wr_di:   in std_logic_vector(7 downto 0);

      -- Pointer registers
      pavr_rf_x:    out std_logic_vector(15 downto 0);
      pavr_rf_x_wr: in  std_logic;
      pavr_rf_x_di: in  std_logic_vector(15 downto 0);

      pavr_rf_y:    out std_logic_vector(15 downto 0);
      pavr_rf_y_wr: in  std_logic;
      pavr_rf_y_di: in  std_logic_vector(15 downto 0);

      pavr_rf_z:    out std_logic_vector(15 downto 0);
      pavr_rf_z_wr: in  std_logic;
      pavr_rf_z_di: in  std_logic_vector(15 downto 0)
   );
   end component;
   for all: pavr_rf use entity work.pavr_rf(pavr_rf_arch);

begin

   -- Instantiate a the Register File.
   pavr_rf_instance1: pavr_rf
   port map(
      clk,
      res,
      syncres,

      -- Read port #1
      pavr_rf_rd1_addr,
      pavr_rf_rd1_rd,
      pavr_rf_rd1_do,

      -- Read port #2
      pavr_rf_rd2_addr,
      pavr_rf_rd2_rd,
      pavr_rf_rd2_do,

      -- Write port
      pavr_rf_wr_addr,
      pavr_rf_wr_wr,
      pavr_rf_wr_di,

      -- Pointer registers
      pavr_rf_x,
      pavr_rf_x_wr,
      pavr_rf_x_di,

      pavr_rf_y,
      pavr_rf_y_wr,
      pavr_rf_y_di,

      pavr_rf_z,
      pavr_rf_z_wr,
      pavr_rf_z_di
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
         -- The Register File should take care of reseting its registers. Check
         --    this too.
         cnt <= int_to_std_logic_vector(0, cnt'length);
      elsif clk'event and clk='1' then
         -- Clock counter
         cnt <= cnt+1;

         -- Initialize inputs.
         pavr_rf_rd1_addr  <= int_to_std_logic_vector(3, pavr_rf_rd1_addr'length);
         pavr_rf_rd1_rd    <= '0';
         pavr_rf_rd2_addr  <= int_to_std_logic_vector(4, pavr_rf_rd2_addr'length);
         pavr_rf_rd2_rd    <= '0';
         pavr_rf_wr_addr   <= int_to_std_logic_vector(5, pavr_rf_wr_addr'length);
         pavr_rf_wr_wr     <= '0';
         pavr_rf_wr_di     <= int_to_std_logic_vector(6, pavr_rf_wr_di'length);

         pavr_rf_x_wr   <= '0';
         pavr_rf_x_di   <= int_to_std_logic_vector(7, pavr_rf_x_di'length);
         pavr_rf_y_wr   <= '0';
         pavr_rf_y_di   <= int_to_std_logic_vector(8, pavr_rf_y_di'length);
         pavr_rf_z_wr   <= '0';
         pavr_rf_z_di   <= int_to_std_logic_vector(9, pavr_rf_z_di'length);

         case std_logic_vector_to_nat(cnt) is

            -- TEST 1
            -- Test RFWR, RFRD1 and RFRD1, one port at a time. Access RF registers
            --    others than pointer registers.
            -- RFWR
            when 5 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(10, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(50, pavr_rf_wr_di'length);
            -- RFWR
            when 6 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(11, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(51, pavr_rf_wr_di'length);
            -- RFRD1
            when 7 =>
               pavr_rf_rd1_addr  <= int_to_std_logic_vector(10, pavr_rf_rd1_addr'length);
               pavr_rf_rd1_rd    <= '1';
            -- RFRD2
            when 8 =>
               pavr_rf_rd2_addr  <= int_to_std_logic_vector(11, pavr_rf_rd2_addr'length);
               pavr_rf_rd2_rd    <= '1';



            -- TEST 2
            -- Test RFWR, RFRD1 and RFRD1, one port at a time. Access RF pointer
            --    registers.
            -- RFWR
            when 12 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(26, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(60, pavr_rf_wr_di'length);
            when 13 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(27, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(61, pavr_rf_wr_di'length);
            when 14 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(28, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(62, pavr_rf_wr_di'length);
            when 15 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(29, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(63, pavr_rf_wr_di'length);
            when 16 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(30, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(64, pavr_rf_wr_di'length);
            when 17 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(31, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(65, pavr_rf_wr_di'length);
            -- RFRD1
            when 18 =>
               pavr_rf_rd1_addr  <= int_to_std_logic_vector(26, pavr_rf_rd1_addr'length);
               pavr_rf_rd1_rd    <= '1';
            -- RFRD2
            when 19 =>
               pavr_rf_rd2_addr  <= int_to_std_logic_vector(27, pavr_rf_rd2_addr'length);
               pavr_rf_rd2_rd    <= '1';
            -- RFRD1
            when 20 =>
               pavr_rf_rd1_addr  <= int_to_std_logic_vector(28, pavr_rf_rd1_addr'length);
               pavr_rf_rd1_rd    <= '1';
            -- RFRD1
            when 21 =>
               pavr_rf_rd1_addr  <= int_to_std_logic_vector(29, pavr_rf_rd1_addr'length);
               pavr_rf_rd1_rd    <= '1';
            -- RFRD2
            when 22 =>
               pavr_rf_rd2_addr  <= int_to_std_logic_vector(30, pavr_rf_rd2_addr'length);
               pavr_rf_rd2_rd    <= '1';
            -- RFRD2
            when 23 =>
               pavr_rf_rd2_addr  <= int_to_std_logic_vector(31, pavr_rf_rd2_addr'length);
               pavr_rf_rd2_rd    <= '1';



            -- TEST 3
            -- Test RFWR, RFRD1 and RFRD1, combined accesses. Write RF registers
            --    others than pointer registers.
            -- Note: RFWR and RFRD1 access the same location.
            when 26 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(10, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(70, pavr_rf_wr_di'length);
               pavr_rf_rd1_addr  <= int_to_std_logic_vector(10, pavr_rf_rd1_addr'length);
               pavr_rf_rd1_rd    <= '1';
               pavr_rf_rd2_addr  <= int_to_std_logic_vector(11, pavr_rf_rd2_addr'length);
               pavr_rf_rd2_rd    <= '1';



            -- TEST 4
            -- Test RFWR, RFRD1 and RFRD1, combined accesses. Write RF pointer
            --    registers.
            -- Note: RFWR, RFRD1 and RFRD2 access the same location.
            when 29 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(26, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(80, pavr_rf_wr_di'length);
               pavr_rf_rd1_addr  <= int_to_std_logic_vector(26, pavr_rf_rd1_addr'length);
               pavr_rf_rd1_rd    <= '1';
               pavr_rf_rd2_addr  <= int_to_std_logic_vector(26, pavr_rf_rd2_addr'length);
               pavr_rf_rd2_rd    <= '1';



            -- TEST 5
            -- Test RFWR, RFRD1 and RFRD1, combined accesses. Write RF pointer
            --    registers.
            -- Note: RFWR, RFRD1 and RFRD2 each access a different location.
            -- RFWR
            when 32 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(27, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(90, pavr_rf_wr_di'length);
               pavr_rf_rd1_addr  <= int_to_std_logic_vector(28, pavr_rf_rd1_addr'length);
               pavr_rf_rd1_rd    <= '1';
               pavr_rf_rd2_addr  <= int_to_std_logic_vector(31, pavr_rf_rd2_addr'length);
               pavr_rf_rd2_rd    <= '1';



            -- TEST 6
            -- Test pointer register write ports.
            when 35 =>
               pavr_rf_x_wr   <= '1';
               pavr_rf_x_di   <= int_to_std_logic_vector(16#1111#, pavr_rf_x_di'length);
               pavr_rf_y_wr   <= '1';
               pavr_rf_y_di   <= int_to_std_logic_vector(16#2222#, pavr_rf_y_di'length);
               pavr_rf_z_wr   <= '1';
               pavr_rf_z_di   <= int_to_std_logic_vector(16#3333#, pavr_rf_z_di'length);



            -- TEST 7
            -- Test RFWR, RFRD1, RFRD2 and pointer register write ports, all at
            --    the same time. No writes compete for the same location.
            when 38 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(10, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(110, pavr_rf_wr_di'length);
               pavr_rf_rd1_addr  <= int_to_std_logic_vector(10, pavr_rf_rd1_addr'length);
               pavr_rf_rd1_rd    <= '1';
               pavr_rf_rd2_addr  <= int_to_std_logic_vector(11, pavr_rf_rd2_addr'length);
               pavr_rf_rd2_rd    <= '1';
               pavr_rf_x_wr   <= '1';
               pavr_rf_x_di   <= int_to_std_logic_vector(111, pavr_rf_x_di'length);
               pavr_rf_y_wr   <= '1';
               pavr_rf_y_di   <= int_to_std_logic_vector(112, pavr_rf_y_di'length);
               pavr_rf_z_wr   <= '1';
               pavr_rf_z_di   <= int_to_std_logic_vector(113, pavr_rf_z_di'length);



            -- TEST 8
            -- Test RFWR, RFRD1, RFRD2 and pointer register write ports, all at
            --    the same time. RFWR and RFZWR try to write the same location.
            --    RFZWR should win.
            when 41 =>
               pavr_rf_wr_addr   <= int_to_std_logic_vector(31, pavr_rf_wr_addr'length);
               pavr_rf_wr_wr     <= '1';
               pavr_rf_wr_di     <= int_to_std_logic_vector(120, pavr_rf_wr_di'length);
               pavr_rf_rd1_addr  <= int_to_std_logic_vector(30, pavr_rf_rd1_addr'length);
               pavr_rf_rd1_rd    <= '1';
               pavr_rf_rd2_addr  <= int_to_std_logic_vector(31, pavr_rf_rd2_addr'length);
               pavr_rf_rd2_rd    <= '1';
               pavr_rf_x_wr   <= '1';
               pavr_rf_x_di   <= int_to_std_logic_vector(121, pavr_rf_x_di'length);
               pavr_rf_y_wr   <= '1';
               pavr_rf_y_di   <= int_to_std_logic_vector(122, pavr_rf_y_di'length);
               pavr_rf_z_wr   <= '1';
               pavr_rf_z_di   <= int_to_std_logic_vector(123, pavr_rf_z_di'length);



            when others =>
               null;
         end case;

         if syncres='1' then
            -- Sync reset
            -- The Register File should take care of reseting its registers. Check
            --    this too.
            cnt <= int_to_std_logic_vector(0, cnt'length);
         end if;
      end if;
   end process test_main;


end;
-- </File body>
