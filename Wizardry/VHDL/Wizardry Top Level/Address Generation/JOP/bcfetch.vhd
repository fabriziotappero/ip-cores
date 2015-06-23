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
--	bcfetch.vhd
--
--	Java bc fetch and address translation for JVM
--
--	resources on ACEX1K30-3
--
--		bytecode LCs, max ca. xx MHz
--
--	todo:
--
--	2001-11-16	split from fetch.vhd, register jpaddr instead of jinstr
--	2001-12-06	unregistered!!! jpaddr, jbr registered (moved from decode)
--	2001-12-07	removed mux befor jbc ram, jbr unregistered selects addr. for jpc
--				decode goto and if_bytecode from jinstr
--	2002-03-24	autoincrement of jpc on bc_wr
--	2002-10-21	added if(non)null
--	2003-02-22	registered jbc ram
--	2003-08-14	move wr-addr load and autoincrement to ajbc.vhd (now 32 bit interface)
--	2003-08-15	interrupt handling
--	2004-04-06	removed signal jfetch from interrupt mux (is in fetch allready)
--				different mux for jpc and jbc rdaddr, register jump address calculation
--	2004-09-11	move jbc to mem
--	2005-01-17	move interrupt mux to jtbl.vhd (mux after the table)
--	2007-12-01	move most interrupt processing to sc_sys
--
--	TODO:	use 'running' bit and generate jbr here!
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_types.all;

entity bcfetch is

generic (
	jpc_width	: integer;		-- address bits of java byte code pc
	pc_width	: integer		-- address bits of internal instruction rom
);
port (
	clk, reset	: in std_logic;

	jpc_out		: out std_logic_vector(jpc_width downto 0);	-- jpc read
	din			: in std_logic_vector(31 downto 0);			-- A from stack
	jpc_wr		: in std_logic;

--	connection to bytecode cache

	jbc_addr	: out std_logic_vector(jpc_width-1 downto 0);
	jbc_data	: in std_logic_vector(7 downto 0);

	jfetch		: in std_logic;
	jopdfetch	: in std_logic;

	zf, nf		: in std_logic;
	eq, lt		: in std_logic;

	jbr			: in std_logic;

	irq_in		: in irq_bcf_type;
	irq_out		: out irq_ack_type;

	jpaddr		: out std_logic_vector(pc_width-1 downto 0);	-- address for JVM
	opd			: out std_logic_vector(15 downto 0)				-- operands
);
end bcfetch;

architecture rtl of bcfetch is

--
--	jtbl component (generated vhdl file from Jopa!)
--
--	logic rom (unregistered)
--
component jtbl is
port (
	bcode	: in std_logic_vector(7 downto 0);
	int_pend	: in  std_logic;
	exc_pend	: in  std_logic;
	q		: out std_logic_vector(pc_width-1 downto 0)
);
end component;


	signal jbc_mux	: std_logic_vector(jpc_width downto 0);
	signal jbc_q	: std_logic_vector(7 downto 0);

	signal jpc		: std_logic_vector(jpc_width downto 0);
	signal jpc_br	: std_logic_vector(jpc_width downto 0);
	signal jmp_addr	: std_logic_vector(jpc_width downto 0);

	signal jinstr	: std_logic_vector(7 downto 0);
	signal tp		: std_logic_vector(3 downto 0);
	signal jmp		: std_logic;

	signal jopd		: std_logic_vector(15 downto 0);

--
--	signals for interrupt handling
--
	signal int_pend		: std_logic;
	signal int_req		: std_logic;
	signal int_taken	: std_logic;

	signal exc_pend		: std_logic;
	signal exc_taken	: std_logic;

	signal bytecode		: std_logic_vector(7 downto 0);

-- synthesis translate_off 
-- synthesis translate_on 

begin

--
--	interrupt processing at bytecode fetch level
--
process(clk, reset) begin

	if (reset='1') then
		int_pend <= '0';
		exc_pend <= '0';

	elsif rising_edge(clk) then

		if irq_in.irq='1' then
			int_pend <= '1';
		elsif int_taken='1' then
			int_pend <= '0';
		end if;

		if irq_in.exc='1' then
			exc_pend <= '1';
		elsif exc_taken='1' then
			exc_pend <= '0';
		end if;
	end if;

end process;

--
--	TODO: exception and int in the same cycle: int gets lost
--
	int_req <= int_pend and irq_in.ena;
	int_taken <= int_req and jfetch;
	exc_taken <= exc_pend and jfetch;

	irq_out.ack_irq <= int_taken;
	irq_out.ack_exc <= exc_taken;

--
--	bytecode mux on interrupt
--		jpc is one too high after generating int_taken
--		this is corrected in jvm.asm
--

--
--	java byte code fetch and branch
--		interrupt and exception mux are in jtbl
--

	bytecode <= jbc_q;		-- register this for an additional pipeline stage

	cmp_jtbl: jtbl port map(bytecode, int_req, exc_pend, jpaddr);

	jbc_addr <= jbc_mux(jpc_width-1 downto 0);
	jbc_q <= jbc_data;


--
--	decode if and goto byte codes
--
process(clk, jinstr) begin

	if rising_edge(clk) then
		case jinstr is

--			when "10011001" => tp <= "1001";	-- ifeq
--			when "10011010" => tp <= "1010";	-- ifne
--			when "10011011" => tp <= "1011";	-- iflt
--			when "10011100" => tp <= "1100";	-- ifge
--			when "10011101" => tp <= "1101";	-- ifgt
--			when "10011110" => tp <= "1110";	-- ifle

--			when "10011111" => tp <= "1111";	-- if_icmpeq
--			when "10100000" => tp <= "0000";	-- if_icmpne
--			when "10100001" => tp <= "0001";	-- if_icmplt
--			when "10100010" => tp <= "0010";	-- if_icmpge
--			when "10100011" => tp <= "0011";	-- if_icmpgt
--			when "10100100" => tp <= "0100";	-- if_icmple

			when "10100101" => tp <= "1111";	-- if_acmpeq
			when "10100110" => tp <= "0000";	-- if_acmpne
--			when "10100111" => tp <= "0111";	-- goto

			when "11000110" => tp <= "1001";	-- ifnull
			when "11000111" => tp <= "1010";	-- ifnonnull

			when others => tp <= jinstr(3 downto 0);
		end case;
	end if;

end process;

process(tp, jbr, zf, nf, eq, lt)
begin

	jmp <= '0';
	if (jbr='1') then
		case tp is
			when "1001" =>			-- ifeq, ifnull
				if (zf='1') then
					jmp <= '1';
				end if;
			when "1010" =>			-- ifne, ifnonnull
				if (zf='0') then
					jmp <= '1';
				end if;
			when "1011" =>			-- iflt
				if (nf='1') then
					jmp <= '1';
				end if;
			when "1100" =>			-- ifge
				if (nf='0') then
					jmp <= '1';
				end if;
			when "1101" =>			-- ifgt
				if (zf='0' and nf='0') then
					jmp <= '1';
				end if;
			when "1110" =>			-- ifle
				if (zf='1' or nf='1') then
					jmp <= '1';
				end if;

			when "1111" =>			-- if_icmpeq, if_acmpeq
				if (eq='1') then
					jmp <= '1';
				end if;
			when "0000" =>			-- if_icmpne, if_acmpne
				if (eq='0') then
					jmp <= '1';
				end if;
			when "0001" =>			-- if_icmplt
				if (lt='1') then
					jmp <= '1';
				end if;
			when "0010" =>			-- if_icmpge
				if (lt='0') then
					jmp <= '1';
				end if;
			when "0011" =>			-- if_icmpgt
				if (eq='0' and lt='0') then
					jmp <= '1';
				end if;
			when "0100" =>			-- if_icmple
				if (eq='1' or lt='1') then
					jmp <= '1';
				end if;

			when "0111" =>			-- goto
				jmp <= '1';

			when others =>
				null;
		end case;
	end if;

end process;

--
--	jbc read address mux (is registered in ram)
--		no write from din
--
process(din, jpc, jmp_addr, jopd, jfetch, jopdfetch, jmp)

begin

	if (jmp='1') then
		jbc_mux <= jmp_addr;
	elsif (jfetch='1' or jopdfetch='1') then
		jbc_mux <= std_logic_vector(unsigned(jpc) + 1);
	else
		jbc_mux <= jpc;
	end if;

end process;

--
--	jpc mux conatins also din
--
process(clk, reset)

begin
	if (reset='1') then

		jpc <= std_logic_vector(to_unsigned(0, jpc_width+1));

	elsif rising_edge(clk) then

		if (jpc_wr='1') then
			jpc <= din(jpc_width downto 0);
		elsif (jmp='1') then
			jpc <= jmp_addr;
		elsif (jfetch='1' or jopdfetch='1') then
			jpc <= std_logic_vector(unsigned(jpc) + 1);
		else
			jpc <= jpc;
		end if;

	end if;
end process;

	jpc_out <= jpc;


--
--	use this without register
--
--		jmp_addr <= std_logic_vector(unsigned(jpc_br) +
--			unsigned(jopd(jpc_width-1 downto 0)));

process(clk)
begin
	if rising_edge(clk) then

		-- from jbc_q + jopd low!
		jmp_addr <= std_logic_vector(unsigned(jpc_br) +
			unsigned(jopd(jpc_width-8 downto 0) & jbc_q));

		if (jfetch='1') then
			jpc_br <= jpc;		-- save start address of instruction for branch
			jinstr <= jbc_q;
		end if;

	end if;
end process;

process(clk, reset)

begin
	if (reset='1') then
		jopd <= (others => '0');
	elsif rising_edge(clk) then
		jopd(7 downto 0) <= jbc_q;
		if (jopdfetch='1') then
			jopd(15 downto 8) <= jopd(7 downto 0);
		end if;
	end if;
end process;

	opd <= jopd;

-- synthesis translate_off 
	-- show jinstr with bytecode mnemonic
	bc: entity work.bytecode port map(jinstr);
-- synthesis translate_on 

end rtl;

