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
-- Package: 	arith
-- File:	arith.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Declaration of mul/div components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package arith is

type div32_in_type is record
  y                : std_logic_vector(32 downto 0); -- Y (MSB divident)
  op1              : std_logic_vector(32 downto 0); -- operand 1 (LSB divident)
  op2              : std_logic_vector(32 downto 0); -- operand 2 (divisor)
  flush            : std_logic;
  signed           : std_logic;
  start            : std_logic;
end record;

type div32_out_type is record
  ready           : std_logic;
  nready          : std_logic;
  icc             : std_logic_vector(3 downto 0); -- ICC
  result          : std_logic_vector(31 downto 0); -- div result
end record;

type mul32_in_type is record
  op1              : std_logic_vector(32 downto 0); -- operand 1
  op2              : std_logic_vector(32 downto 0); -- operand 2
  flush            : std_logic;
  signed           : std_logic;
  start            : std_logic;
  mac              : std_logic;
  acc              : std_logic_vector(39 downto 0);
  --y                : std_logic_vector(7 downto 0); -- Y (MSB MAC register)
  --asr18           : std_logic_vector(31 downto 0); -- LSB MAC register
end record;

type mul32_out_type is record
  ready           : std_logic;
  nready          : std_logic;
  icc             : std_logic_vector(3 downto 0); -- ICC
  result          : std_logic_vector(63 downto 0); -- mul result
end record;

component div32 
port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    holdn   : in  std_ulogic;
    divi    : in  div32_in_type;
    divo    : out div32_out_type
);
end component;

component mul32
generic (
    infer   : integer := 1;
    multype : integer := 0;
    pipe    : integer := 0;
    mac     : integer := 0
);
port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    holdn   : in  std_ulogic;
    muli    : in  mul32_in_type;
    mulo    : out mul32_out_type
);
end component;

function smult ( a, b  : in  std_logic_vector) return std_logic_vector;

end;

package body arith is

function smult ( a, b  : in  std_logic_vector) return std_logic_vector is
  variable sa : signed (a'length-1 downto 0);
  variable sb : signed (b'length-1 downto 0);
  variable sc : signed ((a'length + b'length) -1 downto 0);
  variable res : std_logic_vector ((a'length + b'length) -1 downto 0);
begin 

  sa := signed(a); sb := signed(b);
-- pragma translate_off
  if is_x(a) or is_x(b) then
    sc := (others => 'X');
  else
-- pragma translate_on
    sc := sa * sb; 
-- pragma translate_off
  end if;
-- pragma translate_on
  res := std_logic_vector(sc);
  return(res);
end;

end;
