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
-- This defines the Program Memory needed by pAVR control-section tests.
-- The Program Memory is a trivial, single port, read-write RAM.
-- This is just a testing utility, NOT actually a test.
-- </File info>



-- <File body>
library work;
use work.std_util.all;
use work.pavr_util.all;
use work.pavr_constants.all;
use work.test_pavr_constants.all;
library ieee;
use ieee.std_logic_1164.all;



entity pavr_pm is
   port(
      pavr_pm_clk:  in  std_logic;
      pavr_pm_wr:   in  std_logic;
      pavr_pm_addr: in  std_logic_vector(21 downto 0);
      pavr_pm_di:   in  std_logic_vector(15 downto 0);
      pavr_pm_do:   out std_logic_vector(15 downto 0)
   );
end;



architecture pavr_pm_arch of pavr_pm is
   type tdata_array is array (0 to pavr_pm_len - 1) of std_logic_vector(15 downto 0);
   signal data_array: tdata_array;
begin
   process
   begin
      wait until pavr_pm_clk'event and pavr_pm_clk='1';
      if pavr_pm_wr='0' then
         pavr_pm_do <= data_array(std_logic_vector_to_nat(pavr_pm_addr));
      else
         data_array(std_logic_vector_to_int(pavr_pm_addr)) <= pavr_pm_di;
      end if;
   end process;
end;
-- </File body>
