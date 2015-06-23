------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity: 	cpu_disas
-- File:	cpu_disas.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Module for disassembly
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- pragma translate_off
library grlib;
use grlib.stdlib.all;
use grlib.sparc.all;
use std.textio.all;
use grlib.sparc_disas.all;
-- pragma translate_on
entity cpu_disas is
port (
  clk   : in std_ulogic;
  rstn  : in std_ulogic;
  dummy : out std_ulogic;
  inst  : in std_logic_vector(31 downto 0);
  pc    : in std_logic_vector(31 downto 2);
  result: in std_logic_vector(31 downto 0);
  index : in std_logic_vector(3 downto 0);
  wreg  : in std_ulogic;
  annul : in std_ulogic;
  holdn : in std_ulogic;
  pv    : in std_ulogic;
  trap  : in std_ulogic);
end;

architecture behav of cpu_disas is
begin

  dummy <= '1';
-- pragma translate_off
  trc : process(clk)
    variable valid : boolean;
    variable op : std_logic_vector(1 downto 0);
    variable op3 : std_logic_vector(5 downto 0);
    variable fpins, fpld : boolean;    
  begin
      op := inst(31 downto 30); op3 := inst(24 downto 19);
      fpins := (op = FMT3) and ((op3 = FPOP1) or (op3 = FPOP2));
      fpld := (op = LDST) and ((op3 = LDF) or (op3 = LDDF) or (op3 = LDFSR));
      valid := (((not annul) and pv) = '1') and (not ((fpins or fpld) and (trap = '0')));
      valid := valid and (holdn = '1');
    if rising_edge(clk) and (rstn = '1') then
      print_insn (conv_integer(index), pc(31 downto 2) & "00", inst, 
                  result, valid, trap = '1', wreg = '1', false);
    end if;
  end process;
-- pragma translate_on

end;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- pragma translate_off
library grlib;
use grlib.stdlib.all;
use grlib.sparc.all;
use std.textio.all;
use grlib.sparc_disas.all;
-- pragma translate_on
entity gaisler_cpu_disas is
port (
  clk   : in std_ulogic;
  rstn  : in std_ulogic;
  dummy : out std_ulogic;
  inst  : in std_logic_vector(31 downto 0);
  pc    : in std_logic_vector(31 downto 2);
  result: in std_logic_vector(31 downto 0);
  index : in std_logic_vector(3 downto 0);
  wreg  : in std_ulogic;
  annul : in std_ulogic;
  holdn : in std_ulogic;
  pv    : in std_ulogic;
  trap  : in std_ulogic);
end;

architecture behav of gaisler_cpu_disas is
begin

  dummy <= '1';
-- pragma translate_off
  trc : process(clk)
    variable valid : boolean;
    variable op : std_logic_vector(1 downto 0);
    variable op3 : std_logic_vector(5 downto 0);
    variable fpins, fpld : boolean;    
  begin
      op := inst(31 downto 30); op3 := inst(24 downto 19);
      fpins := (op = FMT3) and ((op3 = FPOP1) or (op3 = FPOP2));
      fpld := (op = LDST) and ((op3 = LDF) or (op3 = LDDF) or (op3 = LDFSR));
      valid := (((not annul) and pv) = '1') and (not ((fpins or fpld) and (trap = '0')));
      valid := valid and (holdn = '1');
    if rising_edge(clk) and (rstn = '1') then
      print_insn (conv_integer(index), pc(31 downto 2) & "00", inst, 
                  result, valid, trap = '1', wreg = '1', false);
    end if;
  end process;
-- pragma translate_on

end;


