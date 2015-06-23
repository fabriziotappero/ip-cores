--------------------------------------------------------------------------------
-- Wishbone Interface                                                         --
--------------------------------------------------------------------------------
-- The WB interface specification types and some convinience functions.       --
-- This definition lacks the CYC and the tag signals.                         --
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

package iwb is

   -- WB MASTER
   type master_out_t is record
      dat : std_logic_vector(31 downto 0);   -- DAT_O
      sel : std_logic_vector(3 downto 0);    -- SEL_O
      adr : std_logic_vector(31 downto 0);   -- ADR_O
      stb : std_logic;                       -- STB_O
      we  : std_logic;                       -- WE_O
   end record;

   type master_in_t is record
      clk : std_logic;                       -- CLK_I
      rst : std_logic;                       -- RST_I
      dat : std_logic_vector(31 downto 0);   -- DAT_I
      ack : std_logic;                       -- ACK_I
   end record;

   -- WB SLAVE
   type slave_out_t is record
      dat : std_logic_vector(31 downto 0);   -- DAT_O
      ack : std_logic;                       -- ACK_O
   end record;

   type slave_in_t is record
      clk : std_logic;                       -- CLK_I
      rst : std_logic;                       -- RST_I
      dat : std_logic_vector(31 downto 0);   -- DAT_I
      sel : std_logic_vector(3 downto 0);    -- SEL_I
      adr : std_logic_vector(31 downto 0);   -- ADR_I
      stb : std_logic;                       -- STB_I
      we  : std_logic;                       -- WE_I
   end record;

   -- Indicates a Wb read or Wb write respectivly.
   function wb_read(si : slave_in_t) return boolean;
   function wb_write(si : slave_in_t) return boolean;
end iwb;

package body iwb is

   function wb_read(si : slave_in_t) return boolean is
   begin
      return (si.stb = '1') and (si.we = '0');
   end wb_read;

   function wb_write(si : slave_in_t) return boolean is
   begin
      return (si.stb = '1') and (si.we = '1');
   end wb_write;

end iwb;
