--
--
--  This file is a part of JOP, the Java Optimized Processor
--
--  Copyright (C) 2001-2008, Martin Schoeberl (martin@jopdesign.com)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--


--
--	stack.vhd
--
--	Stack/Alu for JOP3
--
--	resources on ACEX1K30-3
--
--
--	2001-06-30	first version (adapted from alu.vhd)
--	2001-07-18	components add, sub in own file for Xilinx
--	2001-10-28	ldjpc, stjpc
--	2001-10-31	init cp and vp with 0
--	2001-12-04	cp removed
--	2001-12-06	sp is 0 after reset, must be set in sw
--	2001-12-07	removed imm. values
--	2002-03-24	barrel shifter
--	2003-02-12	added mux for 8 and 16 bit unsigned bytecode operand
--	2004-10-07	new alu selection with sel_sub, sel_amux and ena_a
--	2006-01-12	new ar for local memory addressing, sp and vp MSB fix at '1'
--	2007-08-31	change stack addressing without wrapping, generate sp_ov on max_stack-8
--	2007-09-01	use ram_width from jop_config instead of parameter
--	2007-11-21	use 33 bit for the comparison (compare bug for diff > 2^31 corrected)
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_config.all;

entity stack is

generic (
	width		: integer := 32;	-- one data word
	jpc_width	: integer := 10		-- address bits of java byte code pc
);
port (
	clk, reset	: in std_logic;

	din			: in std_logic_vector(width-1 downto 0);
	dir			: in std_logic_vector(ram_width-1 downto 0);
	opd			: in std_logic_vector(15 downto 0);		-- index for vp load opd
	jpc			: in std_logic_vector(jpc_width downto 0);	-- jpc read

	sel_sub		: in std_logic;							-- 0..add, 1..sub
	sel_amux	: in std_logic;							-- 0..sum, 1..lmux
	ena_a		: in std_logic;							-- 1..store new value
	sel_bmux	: in std_logic;							-- 0..a, 1..mem
	sel_log		: in std_logic_vector(1 downto 0);		-- pop/st, and, or, xor
	sel_shf		: in std_logic_vector(1 downto 0);		-- sr, sl, sra, (sr)
	sel_lmux	: in std_logic_vector(2 downto 0);		-- log, shift, mem, din, reg
	sel_imux	: in std_logic_vector(1 downto 0);		-- java opds
	sel_rmux	: in std_logic_vector(1 downto 0);		-- sp, vp, jpc
	sel_smux	: in std_logic_vector(1 downto 0);		-- sp, a, sp-1, sp+1

	sel_mmux	: in std_logic;							-- 0..a, 1..b
	sel_rda		: in std_logic_vector(2 downto 0);		-- 
	sel_wra		: in std_logic_vector(2 downto 0);		-- 

	wr_ena		: in std_logic;

	ena_b		: in std_logic;
	ena_vp		: in std_logic;
	ena_ar		: in std_logic;

	sp_ov		: out std_logic;

	zf			: out std_logic;
	nf			: out std_logic;
	eq			: out std_logic;
	lt			: out std_logic;
	aout		: out std_logic_vector(width-1 downto 0);
	bout		: out std_logic_vector(width-1 downto 0)
);
end stack;

architecture rtl of stack is

component shift is
generic (width : integer);
port (
	din			: in std_logic_vector(width-1 downto 0);
	off			: in std_logic_vector(4 downto 0);
	shtyp		: in std_logic_vector(1 downto 0);
	dout		: out std_logic_vector(width-1 downto 0)
);
end component shift;

--
--	ram component (use technology specific vhdl-file (aram/xram))
--
--	registered  and delayed wraddress, wren
--	registered din
--	registered rdaddress
--	unregistered dout
--
--		=> read during write on same address
--
component ram is
generic (width : integer; addr_width : integer);
port (
	data		: in std_logic_vector(width-1 downto 0);
	wraddress	: in std_logic_vector(ram_width-1 downto 0);
	rdaddress	: in std_logic_vector(ram_width-1 downto 0);
	wren		: in std_logic;
	clock		: in std_logic;
        reset           : in std_logic;
        
	q			: out std_logic_vector(width-1 downto 0)
);
end component;

	signal a, b			: std_logic_vector(width-1 downto 0);
	signal ram_dout		: std_logic_vector(width-1 downto 0);

	signal sp, spp, spm	: std_logic_vector(ram_width-1 downto 0);
	signal vp0, vp1, vp2, vp3
						: std_logic_vector(ram_width-1 downto 0);
	signal ar			: std_logic_vector(ram_width-1 downto 0);

	signal sum			: std_logic_vector(32 downto 0);
	signal sout			: std_logic_vector(width-1 downto 0);
	signal log			: std_logic_vector(width-1 downto 0);
	signal immval		: std_logic_vector(width-1 downto 0);
	signal opddly		: std_logic_vector(15 downto 0);

	signal amux		: std_logic_vector(width-1 downto 0);
	signal lmux		: std_logic_vector(width-1 downto 0);
	signal imux		: std_logic_vector(width-1 downto 0);
	signal mmux		: std_logic_vector(width-1 downto 0);

	signal rmux		: std_logic_vector(jpc_width downto 0);
	signal smux		: std_logic_vector(ram_width-1 downto 0);
	signal vpadd	: std_logic_vector(ram_width-1 downto 0);
	signal wraddr	: std_logic_vector(ram_width-1 downto 0);
	signal rdaddr	: std_logic_vector(ram_width-1 downto 0);
	signal ci : std_logic_vector(width-1 downto 0);
begin

	cmp_shf: shift generic map (width) port map (b, a(4 downto 0), sel_shf, sout);

	cmp_ram: ram generic map(width, ram_width)
			port map(mmux, wraddr, rdaddr, wr_ena, clk, reset, ram_dout);


-- a version that 'could' be better in Spartan
--process(a, b, sel_sub)
--begin
--
--	if sel_sub='0' then
--		temp <= a;
--		ci <= X"00000000";
--	else
--		temp <= not a;
--		ci <= X"00000001";
--	end if;
--	sum <= std_logic_vector(signed(b) + signed(temp)+ signed(ci));
--
--end process;


-- this add/sub, the sum/lmux mux and the enable should fit into
-- a single LE.
-- But it doesn't! A synthesizer problem in Quartus.
--
process(a, b, sel_sub)
begin

	-- subtract with 33 bits to get the correct carry
	if sel_sub='1' then
		sum <= std_logic_vector(signed(b(31) & b) - signed(a(31) & a));
	else
		sum <= std_logic_vector(signed(b(31) & b) + signed(a(31) & a));
	end if;

end process;

	lt <= sum(32);		-- default is subtract

-- shift version from Flavius?

--
--	mux for stack register, alu
--
process(ram_dout, opddly, immval, sout, din, lmux, rmux, sp, vp0, jpc, sum, log, a, b,
		sel_log, sel_shf, sel_rmux, sel_lmux, sel_imux, sel_mmux, sel_amux)

begin

	case sel_log is
		when "00" =>
			log <= b;
		when "01" =>
			log <= a and b;
		when "10" =>
			log <= a or b;
		when "11" =>
			log <= a xor b;
		when others =>
			null;
	end case;

	case sel_rmux is
		when "00" =>
--			rmux <= "00" & sp;
			rmux <= std_logic_vector(to_signed(to_integer(unsigned(sp)), jpc_width+1));
		when "01" =>
--			rmux <= "00" & vp0;
			rmux <= std_logic_vector(to_signed(to_integer(unsigned(vp0)), jpc_width+1));
		when others =>
			rmux <= jpc;
	end case;

--
--	this is worse than the shift component
--
--	case sel_shf is
--		when "00" =>
--			sout <= std_logic_vector(shift_right(unsigned(b),to_integer(unsigned(a(4 downto 0)))));
--		when "01" =>
--			sout <= std_logic_vector(shift_left(signed(b),to_integer(unsigned(a(4 downto 0)))));
--		when "10" =>
--			sout <= std_logic_vector(shift_right(signed(b),to_integer(unsigned(a(4 downto 0)))));
--		when "11" =>
--			sout <= std_logic_vector(shift_right(unsigned(b),to_integer(unsigned(a(4 downto 0)))));
--		when others =>
--			null;
--	end case;

	case sel_lmux(2 downto 0) is
		when "000" =>
			lmux <= log;
		when "001" =>
			lmux <= sout;
		when "010" =>
			lmux <= ram_dout;
		when "011" =>
			lmux <= immval;
		when "100" =>
			lmux <= din;
		when others =>
			lmux <= std_logic_vector(to_signed(to_integer(unsigned(rmux)), width));
	end case;

	case sel_imux is
		when "00" =>
			imux <= "000000000000000000000000" & opddly(7 downto 0);
		when "01" =>
			imux <= std_logic_vector(to_signed(to_integer(signed(opddly(7 downto 0))), width));
		when "10" =>
			imux <= "0000000000000000" & opddly;
		when others =>
			imux <= std_logic_vector(to_signed(to_integer(signed(opddly)), width));
	end case;

	if sel_mmux='0' then
		mmux <= a;
	else
		mmux <= b;
	end if;

	if sel_amux='0' then
		amux <= sum(31 downto 0);
	else
		amux <= lmux;
	end if;

--	if (a = (a'range => '0'))  then		-- Xilinx ISE has problems
	if (a=std_logic_vector(to_unsigned(0, width))) then
		zf <= '1';
	else
		zf <= '0';
	end if;
	nf <= a(width-1);
	if (a=b) then
		eq <= '1';
	else
		eq <= '0';
	end if;

end process;

process(clk, reset) begin

	if (reset='1') then
		a <= (others => '0');
		b <= (others => '0');
	elsif rising_edge(clk) then

		if ena_a='1' then
			a <= amux;
		end if;

		if ena_b = '1' then
			if sel_bmux = '0' then
				b <= a;
			else
				b <= ram_dout;
			end if;
		end if;

	end if;
end process;

	aout <= a;
	bout <= b;

--
--	stack pointer and vp register
--
process(a, sp, spm, spp, sel_smux)

begin

	case sel_smux is
		when "00" =>
			smux <= sp;
		when "01" =>
			smux <= spm;
		when "10" =>
			smux <= spp;
		when "11" =>
			smux <= a(ram_width-1 downto 0);
		when others =>
			null;
	end case;

end process;


--
--	address mux for ram
--
process(sp, spp, vp0, vp1, vp2, vp3, vpadd, ar, dir, sel_rda, sel_wra)

begin


	case sel_rda is
		when "000" =>
			rdaddr <= vp0;
		when "001" =>
			rdaddr <= vp1;
		when "010" =>
			rdaddr <= vp2;
		when "011" =>
			rdaddr <= vp3;
		when "100" =>
			rdaddr <= vpadd;
		when "101" =>
			rdaddr <= ar;
		when "110" =>
			rdaddr <= sp;
		when others =>
			rdaddr <= dir;
	end case;

	case sel_wra is
		when "000" =>
			wraddr <= vp0;
		when "001" =>
			wraddr <= vp1;
		when "010" =>
			wraddr <= vp2;
		when "011" =>
			wraddr <= vp3;
		when "100" =>
			wraddr <= vpadd;
		when "101" =>
			wraddr <= ar;
		when "110" =>
			wraddr <= spp;
		when others =>
			wraddr <= dir;
	end case;

end process;

process(clk, reset)

begin
	if (reset='1') then
		-- a reasonable start value for the stack addressing
		-- will be overwritten by the first microcode instructions
		sp <= std_logic_vector(to_unsigned(128, ram_width));		
		spp <= std_logic_vector(to_unsigned(129, ram_width));
		spm <= std_logic_vector(to_unsigned(127, ram_width));
		sp_ov <= '0';
		vp0 <= std_logic_vector(to_unsigned(0, ram_width));
		vp1 <= std_logic_vector(to_unsigned(0, ram_width));
		vp2 <= std_logic_vector(to_unsigned(0, ram_width));
		vp3 <= std_logic_vector(to_unsigned(0, ram_width));
		ar <= (others => '0');
		vpadd <= std_logic_vector(to_unsigned(0, ram_width));
		immval <= std_logic_vector(to_unsigned(0, width));
		opddly <= std_logic_vector(to_unsigned(0, 16));
	elsif rising_edge(clk) then
		spp <= std_logic_vector(unsigned(smux) + 1);
		spm <= std_logic_vector(unsigned(smux) - 1);
		sp <= smux;
		-- Value depends on code in JVMHelp.exception() and how much
		-- usefull information can be printed out
		-- -8 was ok with just a plain print...
		-- -10 (or -12) should be ok for a stack trace?
		if sp=std_logic_vector(to_unsigned(2**ram_width-1-16, ram_width)) then
			sp_ov <= '1';
		end if;
		if (ena_vp = '1') then
			vp0 <= a(ram_width-1 downto 0);
			vp1 <= std_logic_vector(unsigned(a(ram_width-1 downto 0)) + 1);
			vp2 <= std_logic_vector(unsigned(a(ram_width-1 downto 0)) + 2);
			vp3 <= std_logic_vector(unsigned(a(ram_width-1 downto 0)) + 3);
		end if;
		if ena_ar = '1' then
			ar <= a(ram_width-1 downto 0);
		end if;
		vpadd <= std_logic_vector(unsigned(vp0(ram_width-1 downto 0)) + unsigned(opd(6 downto 0)));
		opddly <= opd;
		immval <= imux;
	end if;
end process;

end rtl;
