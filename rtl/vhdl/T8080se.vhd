--
-- 8080 compatible microprocessor core, synchronous top level with clock enable
-- Different timing than the original 8080
-- Inputs needs to be synchronous and outputs may glitch
--
-- Version : 0242
--
-- Copyright (c) 2002 Daniel Wallner (jesus@opencores.org)
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
--	STACK status output not supported
--
-- File history :
--
--	0237 : First version
--
--	0238 : Updated for T80 interface change
--
--	0240 : Updated for T80 interface change
--
--	0242 : Updated for T80 interface change
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.T80_Pack.all;

entity T8080se is
	generic(
		Mode : integer := 2;	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write : integer := 0	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
	);
	port(
		RESET_n		: in std_logic;
		CLK			: in std_logic;
		CLKEN		: in std_logic;
		READY		: in std_logic;
		HOLD		: in std_logic;
		INT			: in std_logic;
		INTE		: out std_logic;
		DBIN		: out std_logic;
		SYNC		: out std_logic;
		VAIT		: out std_logic;
		HLDA		: out std_logic;
		WR_n		: out std_logic;
		A			: out std_logic_vector(15 downto 0);
		DI			: in std_logic_vector(7 downto 0);
		DO			: out std_logic_vector(7 downto 0)
	);
end T8080se;

architecture rtl of T8080se is

	signal IntCycle_n	: std_logic;
	signal NoRead		: std_logic;
	signal Write		: std_logic;
	signal IORQ			: std_logic;
	signal INT_n		: std_logic;
	signal HALT_n		: std_logic;
	signal BUSRQ_n		: std_logic;
	signal BUSAK_n		: std_logic;
	signal DO_i			: std_logic_vector(7 downto 0);
	signal DI_Reg		: std_logic_vector(7 downto 0);
	signal MCycle		: std_logic_vector(2 downto 0);
	signal TState		: std_logic_vector(2 downto 0);
	signal One			: std_logic;

begin

	INT_n <= not INT;
	BUSRQ_n <= HOLD;
	HLDA <= not BUSAK_n;
	SYNC <= '1' when TState = "001" else '0';
	VAIT <= '1' when TState = "010" else '0';
	One <= '1';

	DO(0) <= not IntCycle_n when TState = "001" else DO_i(0);	-- INTA
	DO(1) <= Write when TState = "001" else DO_i(1);	-- WO_n
	DO(2) <= DO_i(2);	-- STACK not supported !!!!!!!!!!
	DO(3) <= not HALT_n when TState = "001" else DO_i(3);	-- HLTA
	DO(4) <= IORQ and Write when TState = "001" else DO_i(4);	-- OUT
	DO(5) <= DO_i(5) when TState /= "001" else '1' when MCycle = "001" else '0';	-- M1
	DO(6) <= IORQ and not Write when TState = "001" else DO_i(6);	-- INP
	DO(7) <= not IORQ and not Write and IntCycle_n when TState = "001" else DO_i(7);	-- MEMR

	u0 : T80
		generic map(
			Mode => Mode,
			IOWait => 0)
		port map(
			CEN => CLKEN,
			M1_n => open,
			IORQ => IORQ,
			NoRead => NoRead,
			Write => Write,
			RFSH_n => open,
			HALT_n => HALT_n,
			WAIT_n => READY,
			INT_n => INT_n,
			NMI_n => One,
			RESET_n => RESET_n,
			BUSRQ_n => One,
			BUSAK_n => BUSAK_n,
			CLK_n => CLK,
			A => A,
			DInst => DI,
			DI => DI_Reg,
			DO => DO_i,
			MC => MCycle,
			TS => TState,
			IntCycle_n => IntCycle_n,
			IntE => INTE);

	process (RESET_n, CLK)
	begin
		if RESET_n = '0' then
			DBIN <= '0';
			WR_n <= '1';
			DI_Reg <= "00000000";
		elsif CLK'event and CLK = '1' then
			if CLKEN = '1' then
				DBIN <= '0';
				WR_n <= '1';
				if MCycle = "001" then
					if TState = "001" or (TState = "010" and READY = '0') then
						DBIN <= IntCycle_n;
					end if;
				else
					if (TState = "001" or (TState = "010" and READY = '0')) and NoRead = '0' and Write = '0' then
						DBIN <= '1';
					end if;
					if T2Write = 0 then
						if TState = "010" and Write = '1' then
							WR_n <= '0';
						end if;
					else
						if (TState = "001" or (TState = "010" and READY = '0')) and Write = '1' then
							WR_n <= '0';
						end if;
					end if;
				end if;
				if TState = "010" and READY = '1' then
					DI_Reg <= DI;
				end if;
			end if;
		end if;
	end process;

end;
