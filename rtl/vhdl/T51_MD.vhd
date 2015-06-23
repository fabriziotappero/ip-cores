--
-- 8051 compatible microcontroller core
--
-- Version : 0300
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
--           (c) 2004-2005 Andreas Voggeneder (andreas.voggeneder@fh-hagenberg.at)
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.T51_Pack.all;

entity T51_MD is
	port(
		Clk			: in std_logic;
		ACC			: in std_logic_vector(7 downto 0);
		B			: in std_logic_vector(7 downto 0);
		Mul_Q		: out std_logic_vector(15 downto 0);
		Mul_OV		: out std_logic;
		Div_Q		: out std_logic_vector(15 downto 0);
		Div_OV		: out std_logic;
		Div_Rdy		: out std_logic
	);
end T51_MD;

architecture rtl of T51_MD is

	signal Old_ACC	: std_logic_vector(7 downto 0);
	signal Old_B	: std_logic_vector(7 downto 0);

begin

	process (ACC, B)
		variable Tmp : unsigned(15 downto 0);
	begin
		Tmp := unsigned(ACC) * unsigned(B);
		Mul_Q <= std_logic_vector(Tmp);
		if Tmp(15 downto 8) = "00000000" then
			Mul_OV <= '0';
		else
			Mul_OV <= '1';
		end if;
	end process;

	process (Clk)
		variable Tmp1	: unsigned(15 downto 0);
		variable Tmp2	: unsigned(8 downto 0);
		variable Tmp3	: unsigned(7 downto 0);
		variable Cnt	: unsigned(3 downto 0);
	begin
		if Clk'event and Clk = '1' then
			Old_ACC <= ACC;
			Old_B <= B;
			Div_Rdy <= '0';
			Div_OV <= '0';

			if Cnt(3) = '1' then
				Div_Rdy <= '1';
			end if;

			if B = "00000000" then
				Div_Q <= (others => '-');
				Div_OV <= '1';
				Div_Rdy <= '1';
			elsif ACC = B then
				Div_Q(7 downto 0) <= "00000001";
				Div_Q(15 downto 8) <= "00000000";
			elsif ACC < B then
				Div_Q(7 downto 0) <= "00000000";
				Div_Q(15 downto 8) <= std_logic_vector(ACC);
				Div_Rdy <= '1';
			elsif Cnt(3) = '0' then
				Tmp1(15 downto 1) := Tmp1(14 downto 0);
				Tmp1(0) := '0';
				Tmp2 := ("1" & Tmp1(15 downto 8)) - ("0" & Tmp3);
				if Tmp2(8) = '1' then
					Tmp1(0) := '1';
					Tmp1(15 downto 8) := Tmp2(7 downto 0);
				end if;
				Div_Q <= std_logic_Vector(Tmp1);
			end if;

			if Old_ACC /= ACC or Old_B /= B then
				Tmp1(7 downto 0) := unsigned(ACC);
				Tmp1(15 downto 8) := "00000000";
				Tmp3 := unsigned(B);
				Cnt := "0000";
				Div_Rdy <= '0';
			else
				cnt := cnt + 1;
			end if;

		end if;
	end process;

end;
