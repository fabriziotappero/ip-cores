--
-- AT90Sxxxx compatible microcontroller core
--
-- Version : 0221
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
--	http://www.opencores.org/cvsweb.shtml/t51/
--
-- Limitations :
--
-- File history :
--
--	0146	: First release
--	0221	: Removed tristate

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AX_TC8 is
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		T			: in std_logic;
		TCCR_Sel	: in std_logic;
		TCNT_Sel	: in std_logic;
		Wr			: in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		TCCR		: out std_logic_vector(2 downto 0);
		TCNT		: out std_logic_vector(7 downto 0);
		Int			: out std_logic
	);
end AX_TC8;

architecture rtl of AX_TC8 is

	signal	TCCR_i		: std_logic_vector(2 downto 0);	-- Control Register
	signal	TCNT_i		: std_logic_vector(7 downto 0);	-- Timer/Counter

	signal	Tick		: std_logic;

begin

	TCCR <= TCCR_i;
	TCNT <= TCNT_i;

	-- Registers and counter
	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			TCCR_i<= "000";
			TCNT_i <= "00000000";
			Int <= '0';
		elsif Clk'event and Clk = '1' then
			if TCCR_Sel = '1' and Wr = '1' then
				TCCR_i <= Data_In(2 downto 0);
			end if;
			Int <= '0';
			if Tick = '1' then
				TCNT_i <= std_logic_vector(unsigned(TCNT_i) + 1);
				if TCNT_i = "11111111" then
					Int <= '1';
				end if;
			end if;
			if TCNT_Sel = '1' and Wr = '1' then
				TCNT_i <= Data_In;
				Int <= '0';
			end if;
		end if;
	end process;

	-- Tick generator
	process (Clk, Reset_n)
		variable Prescaler : unsigned(9 downto 0);
		variable T_r : std_logic_vector(1 downto 0);
	begin
		if Reset_n = '0' then
			Prescaler := (others => '0');
			Tick <= '0';
			T_r := "00";
		elsif Clk'event and Clk='1' then
			Tick <= '0';
			case TCCR_i is
			when "000" =>
			when "001" =>
				Tick <= '1';
			when "010" =>
				if T_r(1) = '1' and T_r(0) = '0' then
					Tick <= '1';
				end if;
				T_r(1) := T_r(0);
				T_r(0) := Prescaler(2);
			when "011" =>
				if T_r(1) = '1' and T_r(0) = '0' then
					Tick <= '1';
				end if;
				T_r(1) := T_r(0);
				T_r(0) := Prescaler(5);
			when "100" =>
				if T_r(1) = '1' and T_r(0) = '0' then
					Tick <= '1';
				end if;
				T_r(1) := T_r(0);
				T_r(0) := Prescaler(7);
			when "101" =>
				if T_r(1) = '1' and T_r(0) = '0' then
					Tick <= '1';
				end if;
				T_r(1) := T_r(0);
				T_r(0) := Prescaler(9);
			when "110" =>
				if T_r(1) = '1' and T_r(0) = '0' then
					Tick <= '1';
				end if;
				T_r(1) := T_r(0);
				T_r(0) := T;
			when others =>
				if T_r(1) = '0' and T_r(0) = '1' then
					Tick <= '1';
				end if;
				T_r(1) := T_r(0);
				T_r(0) := T;
			end case;
			Prescaler := Prescaler + 1;
		end if;
	end process;

end;
