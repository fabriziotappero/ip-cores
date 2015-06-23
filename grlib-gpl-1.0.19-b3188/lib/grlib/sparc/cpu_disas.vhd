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
-- Package: 	cpu_disas
-- File:	cpu_disas.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	SPARC disassembler according to SPARC V8 manual 
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
use grlib.sparc.all;
use grlib.sparc_disas.all;

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
  trap  : in std_ulogic;
  disas : in std_ulogic);
end;

architecture behav of cpu_disas is
begin

  dummy <= '1';

  trc : process(clk)
    variable valid : boolean;
    variable op : std_logic_vector(1 downto 0);
    variable op3 : std_logic_vector(5 downto 0);
    variable fpins, fpld : boolean;    
    variable iindex : integer;
  begin
      iindex := conv_integer(index);
      op := inst(31 downto 30); op3 := inst(24 downto 19);
      fpins := (op = FMT3) and ((op3 = FPOP1) or (op3 = FPOP2));
      fpld := (op = LDST) and ((op3 = LDF) or (op3 = LDDF) or (op3 = LDFSR));
      valid := (((not annul) and pv) = '1') and (not ((fpins or fpld) and (trap = '0')));
      valid := valid and (holdn = '1');
    if rising_edge(clk) and (rstn = '1') then
      print_insn (iindex, pc(31 downto 2) & "00", inst, 
                  result, valid, trap = '1', wreg = '1', false);
    end if;
  end process;

end;
  

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
use grlib.sparc.all;
use grlib.sparc_disas.all;

entity fpu_disas is
port (
  clk   : in std_ulogic;
  rstn  : in std_ulogic;
  dummy : out std_ulogic;
  wr2inst  : in std_logic_vector(31 downto 0);
  wr2pc    : in std_logic_vector(31 downto 2);
  divinst  : in std_logic_vector(31 downto 0);
  divpc    : in std_logic_vector(31 downto 2);
  dbg_wrdata: in std_logic_vector(63 downto 0);
  index : in std_logic_vector(3 downto 0);
  dbg_wren : in std_logic_vector(1 downto 0);
  resv  : in std_ulogic;
  ld    : in std_ulogic;
  rdwr  : in std_ulogic;
  ccwr  : in std_ulogic;
  rdd   : in std_ulogic;
  div_valid  : in std_ulogic;
  holdn : in std_ulogic;
  disas : in std_ulogic);
end;

architecture behav of fpu_disas is
begin

  dummy <= '1';

  trc : process(clk)
    variable valid : boolean;
    variable op : std_logic_vector(1 downto 0);
    variable op3 : std_logic_vector(5 downto 0);
    variable fpins, fpld : boolean;    
    variable iindex : integer;
  begin
    iindex := conv_integer(index);

    if rising_edge(clk) and (rstn = '1') then
         valid := ((((rdwr and not ld) or ccwr or (ld and resv)) and holdn) = '1');
         print_fpinsn(0, wr2pc(31 downto 2) & "00", wr2inst, dbg_wrdata,
                      (rdd = '1'), valid, false, (dbg_wren /= "00"));
         print_fpinsn(0, divpc(31 downto 2) & "00", divinst, dbg_wrdata,
                      (rdd = '1'), (div_valid and holdn) = '1', false, (dbg_wren /= "00"));
    end if;
  end process;

end;


-- pragma translate_on
