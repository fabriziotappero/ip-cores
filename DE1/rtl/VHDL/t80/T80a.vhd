--
-- Z80 compatible microprocessor core, asynchronous top level
--
-- Version : 0247
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--	http://www.opencores.org/cvsweb.shtml/t80/
--
-- Limitations :
--
-- File history :
--
--	0208 : First complete release
--
--	0211 : Fixed interrupt cycle
--
--	0235 : Updated for T80 interface change
--
--	0238 : Updated for T80 interface change
--
--	0240 : Updated for T80 interface change
--
--	0242 : Updated for T80 interface change
--
--	0247 : Fixed bus req/ack cycle
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.T80_Pack.all;

entity T80a is
	generic(
		Mode : integer := 0	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	);
	port(
		RESET_n		: in std_logic;
		CLK_n		: in std_logic;
		WAIT_n		: in std_logic;
		INT_n		: in std_logic;
		NMI_n		: in std_logic;
		BUSRQ_n		: in std_logic;
		M1_n		: out std_logic;
		MREQ_n		: out std_logic;
		IORQ_n		: out std_logic;
		RD_n		: out std_logic;
		WR_n		: out std_logic;
		RFSH_n		: out std_logic;
		HALT_n		: out std_logic;
		BUSAK_n		: out std_logic;
		A			: out std_logic_vector(15 downto 0);
		D			: inout std_logic_vector(7 downto 0)
	);
end T80a;

architecture rtl of T80a is

	signal CEN			: std_logic;
	signal Reset_s		: std_logic;
	signal IntCycle_n	: std_logic;
	signal IORQ			: std_logic;
	signal NoRead		: std_logic;
	signal Write		: std_logic;
	signal MREQ			: std_logic;
	signal MReq_Inhibit	: std_logic;
	signal Req_Inhibit	: std_logic;
	signal RD			: std_logic;
	signal MREQ_n_i		: std_logic;
	signal IORQ_n_i		: std_logic;
	signal RD_n_i		: std_logic;
	signal WR_n_i		: std_logic;
	signal RFSH_n_i		: std_logic;
	signal BUSAK_n_i	: std_logic;
	signal A_i			: std_logic_vector(15 downto 0);
	signal DO			: std_logic_vector(7 downto 0);
	signal DI_Reg		: std_logic_vector (7 downto 0);	-- Input synchroniser
	signal Wait_s		: std_logic;
	signal MCycle		: std_logic_vector(2 downto 0);
	signal TState		: std_logic_vector(2 downto 0);

begin

	CEN <= '1';

	BUSAK_n <= BUSAK_n_i;
	MREQ_n_i <= not MREQ or (Req_Inhibit and MReq_Inhibit);
	RD_n_i <= not RD or Req_Inhibit;

	MREQ_n <= MREQ_n_i when BUSAK_n_i = '1' else 'Z';
	IORQ_n <= IORQ_n_i when BUSAK_n_i = '1' else 'Z';
	RD_n <= RD_n_i when BUSAK_n_i = '1' else 'Z';
	WR_n <= WR_n_i when BUSAK_n_i = '1' else 'Z';
	RFSH_n <= RFSH_n_i when BUSAK_n_i = '1' else 'Z';
	A <= A_i when BUSAK_n_i = '1' else (others => 'Z');
	D <= DO when Write = '1' and BUSAK_n_i = '1' else (others => 'Z');

	process (RESET_n, CLK_n)
	begin
		if RESET_n = '0' then
			Reset_s <= '0';
		elsif CLK_n'event and CLK_n = '1' then
			Reset_s <= '1';
		end if;
	end process;

	u0 : T80
		generic map(
			Mode => Mode,
			IOWait => 1)
		port map(
			CEN => CEN,
			M1_n => M1_n,
			IORQ => IORQ,
			NoRead => NoRead,
			Write => Write,
			RFSH_n => RFSH_n_i,
			HALT_n => HALT_n,
			WAIT_n => Wait_s,
			INT_n => INT_n,
			NMI_n => NMI_n,
			RESET_n => Reset_s,
			BUSRQ_n => BUSRQ_n,
			BUSAK_n => BUSAK_n_i,
			CLK_n => CLK_n,
			A => A_i,
			DInst => D,
			DI => DI_Reg,
			DO => DO,
			MC => MCycle,
			TS => TState,
			IntCycle_n => IntCycle_n);

	process (CLK_n)
	begin
		if CLK_n'event and CLK_n = '0' then
			Wait_s <= WAIT_n;
			if TState = "011" and BUSAK_n_i = '1' then
				DI_Reg <= to_x01(D);
			end if;
		end if;
	end process;

	process (Reset_s,CLK_n)
	begin
		if Reset_s = '0' then
			WR_n_i <= '1';
		elsif CLK_n'event and CLK_n = '1' then
			WR_n_i <= '1';
			if TState = "001" then	-- To short for IO writes !!!!!!!!!!!!!!!!!!!
				WR_n_i <= not Write;
			end if;
		end if;
	end process;

	process (Reset_s,CLK_n)
	begin
		if Reset_s = '0' then
			Req_Inhibit <= '0';
		elsif CLK_n'event and CLK_n = '1' then
			if MCycle = "001" and TState = "010" then
				Req_Inhibit <= '1';
			else
				Req_Inhibit <= '0';
			end if;
		end if;
	end process;

	process (Reset_s,CLK_n)
	begin
		if Reset_s = '0' then
			MReq_Inhibit <= '0';
		elsif CLK_n'event and CLK_n = '0' then
			if MCycle = "001" and TState = "010" then
				MReq_Inhibit <= '1';
			else
				MReq_Inhibit <= '0';
			end if;
		end if;
	end process;

	process(Reset_s,CLK_n)
	begin
		if Reset_s = '0' then
			RD <= '0';
			IORQ_n_i <= '1';
			MREQ <= '0';
		elsif CLK_n'event and CLK_n = '0' then

			if MCycle = "001" then
				if TState = "001" then
					RD <= IntCycle_n;
					MREQ <= IntCycle_n;
					IORQ_n_i <= IntCycle_n;
				end if;
				if TState = "011" then
					RD <= '0';
					IORQ_n_i <= '1';
					MREQ <= '1';
				end if;
				if TState = "100" then
					MREQ <= '0';
				end if;
			else
				if TState = "001" and NoRead = '0' then
					RD <= not Write;
					IORQ_n_i <= not IORQ;
					MREQ <= not IORQ;
				end if;
				if TState = "011" then
					RD <= '0';
					IORQ_n_i <= '1';
					MREQ <= '0';
				end if;
			end if;
		end if;
	end process;

end;
