



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	div
-- File:	div.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	This unit implemets a divide unit to execute the
--		UDIV/SDIV instructions. Divide leaves Y
--		register intact but does not produce a remainder.
--		Overflow detection is performed according to the
--		SPARC V8 manual, method B (page 116)
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use work.leon_config.all;
use work.leon_iface.all;

entity div is
port (
    rst     : in  std_logic;
    clk     : in  clk_type;
    holdn   : in  std_logic;
    divi    : in  div_in_type;
    divo    : out div_out_type
);
end;

architecture rtl of div is

type div_regtype is record
  x      : std_logic_vector(64 downto 0);
  state  : std_logic_vector(2 downto 0);
  zero   : std_logic;
  zero2  : std_logic;
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
  variable vready : std_logic;
  variable vaddin1, vaddin2, vaddout: std_logic_vector(32 downto 0);
  variable vaddsub, ymsb, remsign : std_logic;
  constant Zero: std_logic_vector(32 downto 0) := "000000000000000000000000000000000";
  begin

    vready := '0'; v := r;
    if addout = Zero then v.zero := '1'; else v.zero := '0'; end if;
    v.zero2 := r.zero;
    remsign := '0';

    vaddin1 := r.x(63 downto 31); vaddin2 := divi.op2; 
    vaddsub := not (divi.op2(32) xor r.x(64));

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
      if ((divi.signed and r.neg and r.zero) = '1') and (divi.op1 = Zero) then v.ovf := '0'; end if;
      v.qmsb := vaddsub; v.qzero := '1';
      v.x(64 downto 32) := addout;
      v.x(31 downto 0) := r.x(30 downto 0) & vaddsub;
      v.state := "011"; 
-- pragma translate_off
      if not is_x(r.cnt) then
-- pragma translate_on
        v.cnt := r.cnt + 1;
-- pragma translate_off
      end if;
-- pragma translate_on
    when "011" =>
      v.qzero := r.qzero and (vaddsub xor r.qmsb);
      v.x(64 downto 32) := addout;
      v.x(31 downto 0) := r.x(30 downto 0) & vaddsub;
      if (r.cnt = "11111") then v.state := "100"; else 
-- pragma translate_off
        if not is_x(r.cnt) then
-- pragma translate_on
          v.cnt := r.cnt + 1;
-- pragma translate_off
        end if;
-- pragma translate_on
      end if;
    when others =>
      vaddin1 := ((not r.x(31)) & r.x(30 downto 0) & '1');
      vaddsub := r.x(31); vaddin2 := (others => '0'); vaddin2(0) := '1';
      remsign := r.x(64) xor divi.op2(32);
      if (r.zero = '0') and ( ((divi.signed = '0') and (r.x(64) /= r.neg)) or
	((divi.signed = '1') and (remsign /= r.neg)) or (r.zero2 = '1'))
      then 
        v.x(64 downto 32) := addout;
      else
        v.x(64 downto 32) := vaddin1; v.qzero := '0';
      end if;
      if (r.ovf = '1') then
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
    if (rst = '0') or (divi.flush = '1') then v.state := "000"; end if;
    rin <= v;
    divo.ready <= vready;
    divo.result(31 downto 0) <= r.x(63 downto 32);
    addin1 <= vaddin1; addin2 <= vaddin2; addsub <= vaddsub;

  end process;

  divadd : process(addin1, addin2, addsub)
  variable b : std_logic_vector(32 downto 0);
  begin
    if addsub = '1' then b := not addin2; else b := addin2; end if;
-- pragma translate_off
    if not (is_x(addin1 & b & addsub)) then
-- pragma translate_on
      addout <= addin1 + b + addsub;
-- pragma translate_off
    else
      addout <= (others => 'X');
    end if;
-- pragma translate_on
  end process;


  reg : process(clk)
  begin 
    if rising_edge(clk) then 
      if (holdn = '1') then r <= rin; end if;
    end if;
  end process;

end; 

