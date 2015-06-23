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
-- This is the Data Memory.
-- DM is a single port RAM, accessible for read and write.
-- </File info>



-- <File body>
library work;
use work.std_util.all;
use work.pavr_util.all;
use work.pavr_constants.all;
library ieee;
use ieee.std_logic_1164.all;



entity pavr_dm is
   port(
      pavr_dm_clk:  in  std_logic;
      pavr_dm_wr:   in  std_logic;
      pavr_dm_addr: in  std_logic_vector(pavr_dm_addr_w - 1 downto 0);
      pavr_dm_di:   in  std_logic_vector(7 downto 0);
      pavr_dm_do:   out std_logic_vector(7 downto 0)
   );
end;



architecture pavr_dm_arch of pavr_dm is
   type tdata_array is array (0 to pavr_dm_len - 1) of std_logic_vector(7 downto 0);
   signal data_array: tdata_array;
begin
   process
   begin
      wait until pavr_dm_clk'event and pavr_dm_clk='1';
      if (pavr_dm_wr = '0') then
         pavr_dm_do <= data_array(std_logic_vector_to_nat(pavr_dm_addr));
      else
         data_array(std_logic_vector_to_nat(pavr_dm_addr)) <= pavr_dm_di;
      end if;
   end process;
end;
-- </File body>
