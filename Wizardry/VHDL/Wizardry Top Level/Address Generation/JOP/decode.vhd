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
--	decode.vhd
--
--	cpu decode of JOP3
--	
--	generate control for pc and stack
--
--
--	resources on ACEX1K30-3
--	
--		xxx LCs, 42.0 MHz	
--
--	todo:
--
--
--	2001-07-03	extracted from core.vhd
--	2001-10-28	ldjpc, stjpc
--	2001-10-31	stbc
--	2001-12-04	cp removed
--	2001-12-05	sel_rda, sel_wra: logic from ir (not registered)
--				sel_smux: logic from ir (not registered, no mix addr/rd-ex: nop befor stsp)
--	2001-12-06	moved ir from decode to fetch, jbr unregistered
--	2001-12-07	moved jbr decode to bcfetch, ldi loads consts from ram (addr > 31), jp removed
--	2001-12-08	instruction set changed to 8 bit
--	2002-03-24	new shift instructions
--	2002-12-02	wait instruction for memory
--	2003-02-12	added instruction ld_opd_8u/16u
--	2004-10-07	new alu selection with sel_sub, sel_amux and ena_a
--	2004-10-08	moved bsy/pcwait from decode to fetch
--	2006-01-12	new ar for local memory addressing: star, ldmi, stmi
--				stioa, stiod, ldiod removed
--	2007-08-31	use addr_width for signal dir
--	2007-09-01	use ram_width from jop_config instead of parameter
--


library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

use work.jop_config.all;
use work.jop_types.all;

entity decode is
generic (
	i_width		: integer		-- instruction width
);

port (
	clk, reset	: in std_logic;

	instr		: in std_logic_vector(i_width-1 downto 0);
	zf, nf		: in std_logic;		-- nf, eq and lt not used (only brz, brnz)
	eq, lt		: in std_logic;

	br			: out std_logic;
	jbr			: out std_logic;

	ext_addr	: out std_logic_vector(EXTA_WIDTH-1 downto 0);
	rd, wr		: out std_logic;

	dir			: out std_logic_vector(ram_width-1 downto 0);

	sel_sub		: out std_logic;						-- 0..add, 1..sub
	sel_amux	: out std_logic;						-- 0..sum, 1..lmux
	ena_a		: out std_logic;						-- 1..store new value
	sel_bmux	: out std_logic;						-- 0..a, 1..mem
	sel_log		: out std_logic_vector(1 downto 0);		-- pop/st, and, or, xor
	sel_shf		: out std_logic_vector(1 downto 0);		-- sr, sl, sra, (sr)
	sel_lmux	: out std_logic_vector(2 downto 0);		-- log, shift, mem, io, reg
	sel_imux	: out std_logic_vector(1 downto 0);		-- java opds
	sel_rmux	: out std_logic_vector(1 downto 0);		-- sp, vp, jpc
	sel_smux	: out std_logic_vector(1 downto 0);		-- sp, a, sp-1, sp+1

	sel_mmux	: out std_logic;						-- 0..a, 1..b
	sel_rda		: out std_logic_vector(2 downto 0);		-- 
	sel_wra		: out std_logic_vector(2 downto 0);		-- 

	wr_ena		: out std_logic;

	ena_b		: out std_logic;
	ena_vp		: out std_logic;
	ena_jpc		: out std_logic;
	ena_ar		: out std_logic
);
end decode;

architecture rtl of decode is

--
--	Signals
--

--
-- intruction register, shortcut
--
--	signal ir		: std_logic_vector(i_width-1 downto 0);		-- Xilinx does not like this... instruction register
	signal ir		: std_logic_vector(7 downto 0);		-- instruction register

begin

	ir <= instr;		-- registered in fetch

	ext_addr <= ir(EXTA_WIDTH-1 downto 0);	-- address for extension select

--
--	branch, jbranch
--

process(clk, reset, ir, zf)
begin
	if (reset='1') then
		br <= '0';
	elsif rising_edge(clk) then

		br <= '0';
		if((ir(7 downto 5)="010" and zf='1') or		-- bz
			(ir(7 downto 5)="011" and zf='0')) then	-- bnz
			br <= '1';
		end if;

	end if;
end process;

--	wait is decoded direct in fetch.vhd!

process(ir)
begin

	jbr <= '0';
	if (ir="10000010") then		-- jbr: goto and if_xxx
		jbr <= '1';
	end if;

end process;

--
--	addr, read stage:
--		decode from ir (only logic, no register)
--
process(ir)
begin

-- ram wraddress and wrena are registered

	wr_ena <= '0';
	if (ir(7 downto 5)="101" or			-- 'push' instructions
		ir(7 downto 5)="110" or
		ir(7 downto 5)="111" or
		ir(7 downto 5)="001" or			-- stm
		ir(7 downto 3)="00010") then	-- st, stn, stmi

		wr_ena <= '1';
	end if;

	rd <= '0';
	if ir(7 downto 3)="11100" then		-- ld memio
		rd <= '1';
	end if;
	wr <= '0';
	if ir(7 downto 0)="00000110"
		or ir(7 downto 0)="00000111"
		or ir(7 downto 3)="00001" then -- st memio
		wr <= '1';
	end if;

	sel_imux <= ir(1 downto 0);			-- ld opd_x

-- select for rd/wr address muxes

	dir <= std_logic_vector(to_unsigned(0, ram_width-5)) & ir(4 downto 0);

	sel_rda <= "110";					-- sp
	if (ir(7 downto 3)="11101") then	-- ld, ldn, ldmi
		sel_rda <= ir(2 downto 0);
	end if;
	if (ir(7 downto 5)="101") then		-- ldm
		sel_rda <= "111";
	end if;
	if (ir(7 downto 5)="110") then		-- ldi
		sel_rda <= "111";
		dir <= std_logic_vector(to_unsigned(1, ram_width-5)) & 
			ir(4 downto 0);	-- addr > 31 constants
	end if;

	sel_wra <= "110";					-- spp
	if ir(7 downto 3)="00010" then		-- st, stn, stmi
		sel_wra <= ir(2 downto 0);
	end if;
	if ir(7 downto 5)="001" then		-- stm
		sel_wra <= "111";
	end if;

-- select for sp update

	sel_smux <= "00";				-- sp = sp
	if(ir(7)='0') then			-- 'pop' instruction
		sel_smux <= "01";			-- --sp
	end if;
	if(ir(7 downto 5)="101" or	-- 'push' instruction
		ir(7 downto 5)="110" or
		ir(7 downto 5)="111") then
		sel_smux <= "10";			-- ++sp
	end if;
	if (ir="00011011") then			-- st sp
		sel_smux <= "11";			-- sp = a
	end if;
			
end process;

--
--	ex stage
--

process(clk, reset)
begin

	if (reset='1') then
		sel_sub <= '0';
		sel_amux <= '0';
		ena_a <= '0';
		sel_bmux <= '0';
		sel_log <= "00";
		sel_shf <= "00";
		sel_lmux <= "000";
		sel_rmux <= "00";
		sel_mmux <= '0';
		ena_b <= '0';
		ena_vp <= '0';
		ena_jpc <= '0';
		ena_ar <= '0';

	elsif rising_edge(clk) then

		sel_log <= "00";
		if (ir(7 downto 2)="000000") then		-- pop, and, or, xor
			sel_log <= ir(1 downto 0);
		end if;

		sel_shf <= ir(1 downto 0);

		sel_sub <= '1';			-- default is subtract for lt-flag
		sel_amux <= '1';			-- default is lmux
		ena_a <= '1';			-- default is enable
		ena_vp <= '0';
		ena_jpc <= '0';
		ena_ar <= '0';

		case ir is

			when "00000000" =>				-- pop
			when "00000001" =>				-- and
			when "00000010" =>				-- or
			when "00000011" =>				-- xor
			when "00000100" =>				-- add
					sel_sub <= '0';
					sel_amux <= '0';
			when "00000101" =>				-- sub
					sel_amux <= '0';
			when "00001010" =>				-- stmra
			when "00001011" =>				-- stmwa
			when "00001100" =>				-- stmwd
			when "00001101" =>				-- stopa
			when "00001110" =>				-- stopb
			when "00010000" =>				-- st0
			when "00010001" =>				-- st1
			when "00010010" =>				-- st2
			when "00010011" =>				-- st3
			when "00010100" =>				-- st
			when "00010101" =>				-- stmi
			when "00011000" =>				-- stvp
					ena_vp <= '1';
			when "00011001" =>				-- stjpc
					ena_jpc <= '1';
			when "00011010" =>				-- star
					ena_ar <= '1';
			when "00011011" =>				-- stsp
			when "00011100" =>				-- ushr
			when "00011101" =>				-- shl
			when "00011110" =>				-- shr
--			when "001-----" =>				-- stm
--			when "010-----" =>				-- bz
--			when "011-----" =>				-- bnz
			when "10000000" =>				-- nop
					ena_a <= '0';
			when "10000001" =>				-- wait
					ena_a <= '0';
			when "10000010" =>				-- jbr
					ena_a <= '0';
--			when "101-----" =>				-- ldm
--			when "110-----" =>				-- ldi
			when "11100010" =>				-- ldmrd
			when "11100011" =>				-- ldmbsy
			when "11100101" =>				-- ldmul
			when "11101000" =>				-- ld0
			when "11101001" =>				-- ld1
			when "11101010" =>				-- ld2
			when "11101011" =>				-- ld3
			when "11101100" =>				-- ld
			when "11101101" =>				-- ldmi
			when "11110000" =>				-- ldsp
			when "11110001" =>				-- ldvp
			when "11110010" =>				-- ldjpc
			when "11110100" =>				-- ld_opd_8u
			when "11110101" =>				-- ld_opd_8s
			when "11110110" =>				-- ld_opd_16u
			when "11110111" =>				-- ld_opd_16s
			when "11111000" =>				-- dup
					ena_a <= '0';

			when others =>
				null;
		end case;


		sel_lmux <= "000";		-- log

		if ir(7 downto 2)="000111" then				-- ushr, shl, shr
			sel_lmux <= "001";
		end if;

		if ir(7 downto 5)="101" then				-- ldm
			sel_lmux <= "010";
		end if;
		if ir(7 downto 5)="110" then				-- ldi
			sel_lmux <= "010";
		end if;

		if ir(7 downto 3)="11101" then				-- ld, ldn, ldmi
			sel_lmux <= "010";
		end if;

		if ir(7 downto 2)="111101" then				-- ld_opd_x
			sel_lmux <= "011";
		end if;

		if ir(7 downto 3)="11100" then				-- ld io
			sel_lmux <= "100";
		end if;

		if ir(7 downto 2)="111100" then				-- ldsp, ldvp, ldjpc
			sel_lmux <= "101";
		end if;

									-- default 'pop'
		sel_bmux <= '1';			-- mem
		sel_mmux <= '0';			-- a
		if (ir(7)='1') then		-- 'push' and 'no stack change'
			sel_bmux <= '0';		-- a
			sel_mmux <= '1';		-- b
		end if;

		ena_b <= '1';
		if (ir(7 downto 5)="100") then	-- 'no stack change' (nop, jbr)
			ena_b <= '0';
		end if;

		sel_rmux <= ir(1 downto 0);			-- ldsp, ldvp, ldjpc

	end if;
end process;

end rtl;
