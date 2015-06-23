



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
-- Entity: 	mul
-- File:	mul.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	This unit implemets integer multiply and optionally the
--		UMUL/SMUL/UMAC/SMAC instructions.
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.tech_map.all;

entity mul is
port (
    rst     : in  std_logic;
    clk     : in  clk_type;
    holdn   : in  std_logic;
    muli    : in  mul_in_type;
    mulo    : out mul_out_type
);
end;

architecture rtl of mul is

type mul_regtype is record
  acc    : std_logic_vector(63 downto 0);
  state  : std_logic_vector(1 downto 0);
  start  : std_logic;
  ready  : std_logic;
end record;

type mac_regtype is record
  mac    : std_logic;
  signed : std_logic;
end record;

signal rm, rmin : mul_regtype;
signal mm, mmin : mac_regtype;
signal ma, mb : std_logic_vector(32 downto 0);
signal prod : std_logic_vector(65 downto 0);
signal mreg : std_logic_vector(49 downto 0);

begin

  mulcomb : process(rst, rm, muli, mreg, prod, mm)
  variable mop1, mop2 : std_logic_vector(32 downto 0);
  variable acc, acc1, acc2 : std_logic_vector(48 downto 0);
  variable zero : std_logic;
  variable v : mul_regtype;
  variable w : mac_regtype;
  constant CZero: std_logic_vector(47 downto 0) := "000000000000000000000000000000000000000000000000";
  begin

    v := rm; w := mm; v.start := muli.start; v.ready := '0';
    mop1 := muli.op1; mop2 := muli.op2;
    acc1 := (others => '0'); acc2 := (others => '0');
    w.mac := muli.mac; w.signed := muli.signed; zero := '0';

-- select input 2 to accumulator
    case MULTIPLIER is
    when m16x16 => 
      acc2(32 downto 0) := mreg(32 downto 0);
    when m32x8  => 
      acc2(40 downto 0) := mreg(40 downto 0);
    when m32x16 => 
      acc2(48 downto 0) := mreg(48 downto 0);
    when others => null;
    end case;

-- state machine + inputs to multiplier and accumulator input 1
    case rm.state is
    when "00" =>
      case MULTIPLIER is
      when m16x16 =>
        mop1(16 downto 0) := '0' & muli.op1(15 downto 0);
        mop2(16 downto 0) := '0' & muli.op2(15 downto 0);
	if MULPIPE and (rm.ready = '1' ) then
	  acc1(32 downto 0) := rm.acc(48 downto 16);
        else acc1(32 downto 0) := '0' & rm.acc(63 downto 32); end if;
      when m32x8 =>
        mop1 := muli.op1;
        mop2(8 downto 0) := '0' & muli.op2(7 downto 0);
        acc1(40 downto 0) := '0' & rm.acc(63 downto 24); 
      when m32x16 =>
        mop1 := muli.op1;
        mop2(16 downto 0) := '0' & muli.op2(15 downto 0);
        acc1(48 downto 0) := '0' & rm.acc(63 downto 16); 
      when others => null;
      end case;
      if (rm.start = '1') then v.state := "01"; end if;
    when "01" =>
      case MULTIPLIER is
      when m16x16 =>
        mop1(16 downto 0) := muli.op1(32 downto 16); 
        mop2(16 downto 0) := '0' & muli.op2(15 downto 0);
        if MULPIPE then acc1(32 downto 0) := '0' & rm.acc(63 downto 32); end if;
        v.state := "10";
      when m32x8 =>
        mop1 := muli.op1; mop2(8 downto 0) := '0' & muli.op2(15 downto 8);
        v.state := "10";
      when m32x16 =>
        mop1 := muli.op1; mop2(16 downto 0) := muli.op2(32 downto 16);
        v.state := "00";
      when others => null;
      end case;
    when "10" =>
      case MULTIPLIER is
      when m16x16 =>
        mop1(16 downto 0) := '0' & muli.op1(15 downto 0);
        mop2(16 downto 0) := muli.op2(32 downto 16);
	if MULPIPE then acc1 := (others => '0'); acc2 := (others => '0');
        else acc1(32 downto 0) := rm.acc(48 downto 16); end if;
        v.state := "11";
      when m32x8 =>
        mop1 := muli.op1; mop2(8 downto 0) := '0' & muli.op2(23 downto 16);
        acc1(40 downto 0) := rm.acc(48 downto 8);
        v.state := "11";
      when others => null;
      end case;
    when others =>
      case MULTIPLIER is
      when m16x16 =>
        mop1(16 downto 0) := muli.op1(32 downto 16);
        mop2(16 downto 0) := muli.op2(32 downto 16);
        if MULPIPE then acc1(32 downto 0) := rm.acc(48 downto 16);
        else acc1(32 downto 0) := rm.acc(48 downto 16); end if;
        v.state := "00";
      when m32x8 =>
        mop1 := muli.op1; mop2(8 downto 0) := muli.op2(32 downto 24);
        acc1(40 downto 0) := rm.acc(56 downto 16);
        v.state := "00";
      when others => null;
      end case;
    end case;

-- optional UMAC/SMAC support

    if MACEN then
      if ((muli.mac and muli.signed) = '1') then 
        mop1(16) := muli.op1(15); mop2(16) := muli.op2(15);
      end if;
      if mm.mac = '1' then 
         acc1(32 downto 0) := muli.y(0) & muli.asr18;
         if mm.signed = '1' then acc2(39 downto 32) := (others => mreg(31));
         else acc2(39 downto 32) := (others => '0'); end if;
      end if;
       acc1(39 downto 33) := muli.y(7 downto 1);
    end if;
    

-- accumulator for iterative multiplication (and MAC)
-- pragma translate_off
    if not (is_x(acc1 & acc2)) then
-- pragma translate_on
    case MULTIPLIER is
    when m16x16 => 
      if MACEN then
        acc(39 downto 0) := acc1(39 downto 0) + acc2(39 downto 0);
      else
        acc(32 downto 0) := acc1(32 downto 0) + acc2(32 downto 0);
      end if;
    when m32x8 => 
      acc(40 downto 0) := acc1(40 downto 0) + acc2(40 downto 0);
    when m32x16 => 
      acc(48 downto 0) := acc1(48 downto 0) + acc2(48 downto 0);
    when m32x32 => 
      v.acc(31 downto 0) := prod(63 downto 32);
    when others => null; 
    end case;
-- pragma translate_off
    end if;
-- pragma translate_on

-- save intermediate result to accumulator
    case rm.state is
    when "00" =>
      case MULTIPLIER is
      when m16x16 => 
	if MULPIPE and (rm.ready = '1' ) then
          v.acc(48 downto 16) := acc(32 downto 0);
	  if muli.signed = '1' then 
	    v.acc(63 downto 49) := (others => acc(32));
	  end if;
	else
	  v.acc(63 downto 32) := acc(31 downto 0);
	end if;
      when m32x8  => v.acc(63 downto 24) := acc(39 downto 0);
      when m32x16 => v.acc(63 downto 16) := acc(47 downto 0);
      when others => null;
      end case;
    when "01" =>
      case MULTIPLIER is
      when m16x16 => 
	if MULPIPE then v.acc := (others => '0');
	else v.acc := CZero(31 downto 0) & mreg(31 downto 0); end if;
      when m32x8 => 
        v.acc := CZero(23 downto 0) & mreg(39 downto 0);
	if muli.signed = '1' then v.acc(48 downto 40) := (others => acc(40)); end if;
      when m32x16 => 
        v.acc := CZero(15 downto 0) & mreg(47 downto 0); v.ready := '1';
	if muli.signed = '1' then v.acc(63 downto 48) := (others => acc(48)); end if;
      when others => null;
      end case;
    when "10" =>
      case MULTIPLIER is
      when m16x16 => 
	if MULPIPE then
	  v.acc := CZero(31 downto 0) & mreg(31 downto 0);
	else
	  v.acc(48 downto 16) := acc(32 downto 0);
	end if;
      when m32x8 => v.acc(48 downto 8) := acc(40 downto 0);
	if muli.signed = '1' then v.acc(56 downto 49) := (others => acc(40)); end if;
      when others => null;
      end case;
    when others =>
      case MULTIPLIER is
      when m16x16 =>
	if MULPIPE then
	  v.acc(48 downto 16) := acc(32 downto 0);
	else
          v.acc(48 downto 16) := acc(32 downto 0);
	  if muli.signed = '1' then 
	    v.acc(63 downto 49) := (others => acc(32));
	  end if;
	end if;
        v.ready := '1';
      when m32x8 => v.acc(56 downto 16) := acc(40 downto 0); v.ready := '1';
	if muli.signed = '1' then v.acc(63 downto 57) := (others => acc(40)); end if;
      when others => null;
      end case;
    end case;

-- drive result and condition codes
    if (rst = '0') or (muli.flush = '1') then v.state := "00"; v.start := '0'; end if;
    rmin <= v; ma <= mop1; mb <= mop2; mmin <= w;
    if MULPIPE then mulo.ready <= rm.ready; else mulo.ready <= v.ready; end if;

    case MULTIPLIER is
    when m16x16 => 
      if rm.acc(31 downto 0) = CZero(31 downto 0) then zero := '1'; end if;
      if MACEN and (mm.mac = '1') then
        mulo.result(39 downto 0) <= acc(39 downto 0);
	if mm.signed = '1' then
          mulo.result(63 downto 40) <= (others => acc(39));
	else
          mulo.result(63 downto 40) <= (others => '0');
	end if;
      else
        mulo.result(39 downto 0) <= v.acc(39 downto 32) & rm.acc(31 downto 0);
        mulo.result(63 downto 40) <= v.acc(63 downto 40);
      end if;
      mulo.icc <= rm.acc(31) & zero & "00";
    when m32x8 => 
      if (rm.acc(23 downto 0) = CZero(23 downto 0)) and
         (v.acc(31 downto 24) = CZero(7 downto 0))
      then zero := '1'; end if;
      mulo.result <= v.acc(63 downto 24) & rm.acc(23 downto 0);
      mulo.icc <= v.acc(31) & zero & "00";
    when m32x16 => 
      if (rm.acc(15 downto 0) = CZero(15 downto 0)) and
         (v.acc(31 downto 16) = CZero(15 downto 0))
      then zero := '1'; end if;
      mulo.result <= v.acc(63 downto 16) & rm.acc(15 downto 0);
      mulo.icc <= v.acc(31) & zero & "00";
    when m32x32 => 
      mulo.result <= rm.acc(31 downto 0) & prod(31 downto 0);
      mulo.icc <= "0000";	-- icc set in iu.vhd
    when others => null;
      mulo.result <= (others => '-');
      mulo.icc <= (others => '-');
    end case;

  end process;
 
  xm1616 : if MULTIPLIER = m16x16 generate
    m0 : hw_smult generic map (17, 17) 
         port map (clk, holdn, ma(16 downto 0), mb(16 downto 0), prod(33 downto 0));

    reg : process(clk)
    begin
      if rising_edge(clk) then
        if (holdn = '1') then 
          if MACEN then mm <= mmin; end if;
          mreg(33 downto 0) <= prod(33 downto 0);
	end if;
      end if;
    end process;

  end generate;
  xm3208 : if MULTIPLIER = m32x8 generate
    m0 : hw_smult generic map (33, 9) 
         port map (clk, holdn, ma(32 downto 0), mb(8 downto 0), prod(41 downto 0));

    reg : process(clk)
    begin
      if rising_edge(clk) then
        if (holdn = '1') then 
          mreg(41 downto 0) <= prod(41 downto 0);
	end if;
      end if;
    end process;

  end generate;

  xm3216 : if MULTIPLIER = m32x16 generate
    m0 : hw_smult generic map (33, 17) 
         port map (clk, holdn, ma(32 downto 0), mb(16 downto 0), prod(49 downto 0));

    reg : process(clk)
    begin
      if rising_edge(clk) then
        if (holdn = '1') then 
          mreg(49 downto 0) <= prod(49 downto 0);
	end if;
      end if;
    end process;

  end generate;

  xm3232 : if MULTIPLIER = m32x32 generate
    m0 : hw_smult generic map (33, 33) 
         port map (clk, holdn, ma(32 downto 0), mb(32 downto 0), prod(65 downto 0));
  end generate;


  reg : process(clk)
  begin
    if rising_edge(clk) then
      if (holdn = '1') then rm <= rmin; end if;
    end if;
  end process;

end; 

