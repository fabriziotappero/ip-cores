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
-- Entity: 	div32
-- File:	div32.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	This unit implemets a divide unit to execute 64-bit by 32-bit
--		division. The divider leaves no remainder.
--		Overflow detection is performed according to the
--		SPARC V8 manual, method B (page 116)
--		Division is made using the non-restoring algorithm,
--		and takes 36 clocks. The operands must be stable during
--		the calculations. The result is available one clock after
--		the ready signal is asserted.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library gaisler;
use gaisler.arith.all;

entity div32 is
port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    holdn   : in  std_ulogic;
    divi    : in  div32_in_type;
    divo    : out div32_out_type
);
end;

architecture rtl of div32 is

type div_regtype is record
  x      : std_logic_vector(64 downto 0);
  state  : std_logic_vector(2 downto 0);
  zero   : std_logic;
  zero2  : std_logic;
  qcorr  : std_logic;
  zcorr  : std_logic;
  qzero  : std_logic;
  qmsb   : std_logic;
  ovf    : std_logic;
  neg    : std_logic;
  cnt    : std_logic_vector(4 downto 0);
end record;

signal r, rin : div_regtype;
signal addin1, addin2, addout: std_logic_vector(32 downto 0);
signal addsub : std_logic;

begin

  divcomb : process (r, rst, divi, addout)
  variable v : div_regtype;
  variable vready, vnready : std_logic;
  variable vaddin1, vaddin2 : std_logic_vector(32 downto 0);
  variable vaddsub, ymsb : std_logic;
  constant zero33: std_logic_vector(32 downto 0) := "000000000000000000000000000000000";
  begin

    vready := '0'; vnready := '0'; v := r;
    if addout = zero33 then v.zero := '1'; else v.zero := '0'; end if;

    vaddin1 := r.x(63 downto 31); vaddin2 := divi.op2; 
    vaddsub := not (divi.op2(32) xor r.x(64));
    v.zero2 := r.zero;

    case r.state is
    when "000" =>
      v.cnt := "00000";
      if (divi.start = '1') then 
	v.x(64) := divi.y(32); v.state := "001";
      end if;
    when "001" =>
      v.x := divi.y & divi.op1(31 downto 0);
      v.neg := divi.op2(32) xor divi.y(32);
      if divi.signed = '1' then
        vaddin1 := divi.y(31 downto 0) & divi.op1(31);
        v.ovf := not (addout(32) xor divi.y(32));
      else
        vaddin1 := divi.y; vaddsub := '1';
        v.ovf := not addout(32);
      end if;
      v.state := "010";
    when "010" =>
      if ((divi.signed and r.neg and r.zero) = '1') and (divi.op1 = zero33) then v.ovf := '0'; end if;
      v.qmsb := vaddsub; v.qzero := '1';
      v.x(64 downto 32) := addout;
      v.x(31 downto 0) := r.x(30 downto 0) & vaddsub;
      v.state := "011"; v.zcorr := v.zero;
      v.cnt := r.cnt + 1;
    when "011" =>
      v.qzero := r.qzero and (vaddsub xor r.qmsb);
      v.zcorr := r.zcorr or v.zero;
      v.x(64 downto 32) := addout;
      v.x(31 downto 0) := r.x(30 downto 0) & vaddsub;
      if (r.cnt = "11111") then v.state := "100"; vnready := '1';
      else v.cnt := r.cnt + 1; end if;
      v.qcorr := v.x(64) xor divi.y(32);
    when "100" =>
      vaddin1 := r.x(64 downto 32);
      v.state := "101";
    when others =>
      vaddin1 := ((not r.x(31)) & r.x(30 downto 0) & '1');
      vaddin2 := (others => '0'); vaddin2(0) := '1';
      vaddsub := (not r.neg);-- or (r.zcorr and not r.qcorr); 
      if ((r.qcorr = '1')  or (r.zero = '1')) and (r.zero2 = '0') then 
        if (r.zero = '1') and ((r.qcorr = '0') and (r.zcorr = '1')) then 
	   vaddsub := r.neg; v.qzero := '0';
	end if;
        v.x(64 downto 32) := addout; 
      else
        v.x(64 downto 32) := vaddin1; v.qzero := '0';
      end if;
      if (r.ovf = '1') then
	v.qzero := '0';
        v.x(63 downto 32) := (others => '1');
        if divi.signed = '1' then
          if r.neg = '1' then v.x(62 downto 32) := (others => '0');
	  else v.x(63) := '0'; end if;
	end if;
      end if;
      vready := '1';
      v.state := "000";
    end case;

    divo.icc <= r.x(63) & r.qzero & r.ovf & '0';
    if (divi.flush = '1') then v.state := "000"; end if;
    if (rst = '0') then 
      v.state := "000"; v.cnt := (others => '0');
    end if;
    rin <= v;
    divo.ready <= vready; divo.nready <= vnready;
    divo.result(31 downto 0) <= r.x(63 downto 32);
    addin1 <= vaddin1; addin2 <= vaddin2; addsub <= vaddsub;

  end process;

  divadd : process(addin1, addin2, addsub)
  variable b : std_logic_vector(32 downto 0);
  begin
    if addsub = '1' then b := not addin2; else b := addin2; end if;
    addout <= addin1 + b + addsub;
  end process;

  reg : process(clk)
  begin 
    if rising_edge(clk) then 
      if (holdn = '1') then r <= rin; end if;
      if (rst = '0') then r.state <= "000"; r.cnt <= (others => '0'); end if;
    end if;
  end process;

end; 

