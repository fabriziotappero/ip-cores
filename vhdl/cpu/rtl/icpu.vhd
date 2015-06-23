--------------------------------------------------------------------------------
-- MIPS™ I CPU                                                                --
--------------------------------------------------------------------------------
--                                                                            --
-- REFERENCES                                                                 --
--                                                                            --
--  [1] David A. Patterson, John L. Hennessy,                                 --
--      Computer Organization and Design, The Hardware/Software Interface,    --
--      Morgan Kaufmann; 4 edition (November 10, 2008),                       --
--      ISBN 978-0123744937                                                   --
--                                                                            --
--  [2] IDT R30xx Family Software Reference Manual                            --
--      Revision 1.0, ©1994 Integrated Device Technology, Inc.                --
--  [3] Ion - MIPS(tm) compatible CPU                                         --
--      <http://opencores.org/project,ion>                                    --
--  [4] Plasma - most MIPS I(TM) opcodes                                      --
--      <http://opencores.org/project,plasma>                                 --
--                                                                            --
--------------------------------------------------------------------------------
-- Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.comt>         --
--                                                                            --
-- This program is free software: you can redistribute it and/or modify       --
-- it under the terms of the GNU General Public License as published by       --
-- the Free Software Foundation, either version 3 of the License, or          --
-- (at your option) any later version.                                        --
--                                                                            --
-- This program is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              --
-- GNU General Public License for more details.                               --
--                                                                            --
-- You should have received a copy of the GNU General Public License          --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.      --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mips1.all;
use work.tcpu.all;

package icpu is

   type cpu_in_t is record
      clk : std_logic;
      rst : std_logic;
      hld : std_logic;
      irq : std_logic_vector(7 downto 0);
      ins : std_logic_vector(31 downto 0);
      dat : std_logic_vector(31 downto 0);
   end record;

   type cpu_out_t is record
      iadr : std_logic_vector(31 downto 0);
      dadr : std_logic_vector(31 downto 0);
      we   : std_logic;
      sel  : std_logic_vector(3 downto 0);
      dat  : std_logic_vector(31 downto 0);
      -- synthesis translate_off
         op   : op_t;
         alu  : alu_op_t;
         rimm : rimm_op_t;
         cp0op : cp0_op_t;
         cp0reg : cp0_reg_t;
      -- synthesis translate_on
   end record;

   component cpu is
      port(
         ci : in  cpu_in_t;
         co : out cpu_out_t
      );
   end component;

end icpu;