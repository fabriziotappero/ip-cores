--
-- file: p2r_CordicPipe.vhd
-- author: Richard Herveille
-- rev. 1.0 initial release
--

--
-- This file is come from WWW.OPENCORES.ORG

---------------------------------------------------------------------------------------------------
--
-- Title       : p2r_CordicPipe
-- Design      : cfft
--
---------------------------------------------------------------------------------------------------
--
-- File        : p2r_CordicPipe.vhd
--
---------------------------------------------------------------------------------------------------
--
-- Description : Cordic arith pilepline 
--
---------------------------------------------------------------------------------------------------
--
-- Revisions       :	0
-- Revision Number : 	1
-- Version         :	1
-- Date            :	Oct 17 2002
-- Modifier        :   	ZHAO Ming <sradio@opencores.org>
-- Desccription    :    Data width configurable	
--
---------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity p2r_CordicPipe is 
	generic(
		WIDTH 	: natural := 16;
		PIPEID	: natural := 1
	);
	port(
		clk		: in std_logic;
		ena		: in std_logic;

		Xi		: in signed(WIDTH -1 downto 0); 
		Yi		: in signed(WIDTH -1 downto 0);
		Zi		: in signed(19 downto 0);

		Xo		: out signed(WIDTH -1 downto 0);
		Yo		: out signed(WIDTH -1 downto 0);
		Zo		: out signed(19 downto 0)
	);
end entity p2r_CordicPipe;

architecture dataflow of p2r_CordicPipe is

	--
	-- functions
	--

	-- Function CATAN (constante arc-tangent).
	-- This is a lookup table containing pre-calculated arc-tangents.
	-- 'n' is the number of the pipe, returned is a 20bit arc-tangent value.
	-- The numbers are calculated as follows: Z(n) = atan(1/2^n)
	-- examples:
	-- 20bit values => 2^20 = 2pi(rad)
	--                 1(rad) = 2^20/2pi = 166886.053....
	-- n:0, atan(1/1) = 0.7853...(rad)
	--      0.7853... * 166886.053... = 131072(dec) = 20000(hex)
	-- n:1, atan(1/2) = 0.4636...(rad)
	--      0.4636... * 166886.053... = 77376.32(dec) = 12E40(hex)
	-- n:2, atan(1/4) = 0.2449...(rad)
	--      0.2449... * 166886.053... = 40883.52(dec) = 9FB3(hex)
	-- n:3, atan(1/8) = 0.1243...(rad)
	--      0.1243... * 166886.053... = 20753.11(dec) = 5111(hex)
	--
	function CATAN(n :natural) return integer is
	variable result	:integer;
	begin
		case n is
			when 0 => result := 16#020000#;
			when 1 => result := 16#012E40#;
			when 2 => result := 16#09FB4#;
			when 3 => result := 16#05111#;
			when 4 => result := 16#028B1#;
			when 5 => result := 16#0145D#;
			when 6 => result := 16#0A2F#;
			when 7 => result := 16#0518#;
			when 8 => result := 16#028C#;
			when 9 => result := 16#0146#;
			when 10 => result := 16#0A3#;
			when 11 => result := 16#051#;
			when 12 => result := 16#029#;
			when 13 => result := 16#014#;
			when 14 => result := 16#0A#;
			when 15 => result := 16#05#;
			when 16 => result := 16#03#;
			when 17 => result := 16#01#;
			when others => result := 16#0#;
		end case;
		return result;
	end CATAN;

	-- function Delta is actually an arithmatic shift right
	-- This strange construction is needed for compatibility with Xilinx WebPack
	function Delta(Arg : signed; Cnt : natural) return signed is
		variable tmp : signed(Arg'range);
		constant lo : integer := Arg'high -cnt +1;
	begin
		for n in Arg'high downto lo loop
			tmp(n) := Arg(Arg'high);
		end loop;
		for n in Arg'high -cnt downto 0 loop
			tmp(n) := Arg(n +cnt);
		end loop;
		return tmp;
	end function Delta;

	function AddSub(dataa, datab : in signed; add_sub : in std_logic) return signed is
	begin
		if (add_sub = '1') then
			return dataa + datab;
		else
			return dataa - datab;
		end if;
	end;

	--
	--	ARCHITECTURE BODY
	--
	signal dX, Xresult	: signed(WIDTH -1 downto 0);
	signal dY, Yresult	: signed(WIDTH -1 downto 0);
	signal atan, Zresult	: signed(19 downto 0);

	signal Zneg, Zpos	: std_logic;
	
begin

	dX <= Delta(Xi, PIPEID);
	dY <= Delta(Yi, PIPEID);
	atan <= conv_signed( catan(PIPEID), 20);

	-- generate adder structures
	Zneg <= Zi(19);
	Zpos <= not Zi(19);

	-- xadd
  Xresult <= AddSub(Xi, dY, Zneg);

	-- yadd 
	Yresult <= AddSub(Yi, dX, Zpos);

	-- zadd
	Zresult <= AddSub(Zi, atan, Zneg);

	gen_regs: process(clk)
	begin
		if(clk'event and clk='1') then
			if (ena = '1') then
				Xo <= Xresult;
				Yo <= Yresult;
				Zo <= Zresult;
			end if;
		end if;
	end process;

end architecture dataflow;
