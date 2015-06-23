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

entity T51_TC01 is
	generic(
		FastCount	: integer := 0;
		tristate  : integer := 1
	);
	port(
		Clk			: in std_logic;
		Rst_n		: in std_logic;
		T0			: in std_logic;
		T1			: in std_logic;
		INT0		: in std_logic;
		INT1		: in std_logic;
		M_Sel		: in std_logic;
		H0_Sel		: in std_logic;
		L0_Sel		: in std_logic;
		H1_Sel		: in std_logic;
		L1_Sel		: in std_logic;
		R0			: in std_logic;
		R1			: in std_logic;
		M_Wr		: in std_logic;
		H0_Wr		: in std_logic;
		L0_Wr		: in std_logic;
		H1_Wr		: in std_logic;
		L1_Wr		: in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		Data_Out	: out std_logic_vector(7 downto 0);
		OF0			: out std_logic;
		OF1			: out std_logic
	);
end T51_TC01;

architecture rtl of T51_TC01 is

	signal	TMOD		: std_logic_vector(7 downto 0);
	signal	Cnt0		: std_logic_vector(15 downto 0);
	signal	Cnt1		: std_logic_vector(15 downto 0);

	signal	Tick0		: std_logic;
	signal	Tick1		: std_logic;
	signal	Tick12		: std_logic;

begin

	-- Registers and counter
	tristate_mux: if tristate/=0 generate
  	Data_Out <= Cnt0(15 downto 8) when H0_Sel = '1' else "ZZZZZZZZ";
  	Data_Out <= Cnt0(7 downto 0) when L0_Sel = '1' else "ZZZZZZZZ";
  	Data_Out <= Cnt1(15 downto 8) when H1_Sel = '1' else "ZZZZZZZZ";
  	Data_Out <= Cnt1(7 downto 0) when L1_Sel = '1' else "ZZZZZZZZ";
  	Data_Out <= TMOD when M_Sel = '1' else "ZZZZZZZZ";
  end generate;
	
	std_mux: if tristate=0 generate
  	Data_Out <= Cnt0(15 downto 8) when H0_Sel = '1' else
  	            Cnt0(7 downto 0) when L0_Sel = '1' else
  	            Cnt1(15 downto 8) when H1_Sel = '1' else
  	            Cnt1(7 downto 0) when L1_Sel = '1' else
  	            TMOD when M_Sel = '1' else 
  	            (others =>'-');
	end generate;
	
	process (Rst_n, Clk)
	begin
		if Rst_n = '0' then
			TMOD <= (others => '0');
			Cnt0 <= (others => '0');
			Cnt1 <= (others => '0');
			OF0 <= '0';
			OF1 <= '0';
		elsif Clk'event and Clk = '1' then
			OF0 <= '0';
			OF1 <= '0';
			if TMOD(1 downto 0) = "00" then
				if Tick0 = '1' then
					Cnt0(12 downto 0) <= std_logic_vector(unsigned(Cnt0(12 downto 0)) + 1);
					if Cnt0(12 downto 0) = "1111111111111" then
						OF0 <= '1';
					end if;
				end if;
			end if;
			if TMOD(5 downto 4) = "00" then
				if Tick1 = '1' then
					Cnt1(12 downto 0) <= std_logic_vector(unsigned(Cnt1(12 downto 0)) + 1);
					if Cnt1(12 downto 0) = "1111111111111" then
						OF1 <= '1';
					end if;
				end if;
			end if;
			if TMOD(1 downto 0) = "01" then
				if Tick0 = '1' then
					Cnt0 <= std_logic_vector(unsigned(Cnt0) + 1);
					if Cnt0 = "1111111111111111" then
						OF0 <= '1';
					end if;
				end if;
			end if;
			if TMOD(5 downto 4) = "01" then
				if Tick1 = '1' then
					Cnt1 <= std_logic_vector(unsigned(Cnt1) + 1);
					if Cnt1 = "1111111111111111" then
						OF1 <= '1';
					end if;
				end if;
			end if;
			if TMOD(1 downto 0) = "10" then
				if Tick0 = '1' then
					Cnt0(7 downto 0) <= std_logic_vector(unsigned(Cnt0(7 downto 0)) + 1);
					if Cnt0(7 downto 0) = "11111111" then
						Cnt0(7 downto 0) <= Cnt0(15 downto 8);
						OF0 <= '1';
					end if;
				end if;
			end if;
			if TMOD(5 downto 4) = "10" then
				if Tick1 = '1' then
					Cnt1(7 downto 0) <= std_logic_vector(unsigned(Cnt1(7 downto 0)) + 1);
					if Cnt1(7 downto 0) = "11111111" then
						Cnt1(7 downto 0) <= Cnt1(15 downto 8);
						OF1 <= '1';
					end if;
				end if;
			end if;
			if TMOD(1 downto 0) = "11" then
				if Tick0 = '1' then
					Cnt0(7 downto 0) <= std_logic_vector(unsigned(Cnt0(7 downto 0)) + 1);
					if Cnt0(7 downto 0) = "11111111" then
						OF0 <= '1';
					end if;
				end if;
				OF1 <= '0';
				if R1 = '1' and Tick12 = '1' then
					Cnt0(15 downto 8) <= std_logic_vector(unsigned(Cnt0(15 downto 8)) + 1);
					if Cnt1(15 downto 8) = "11111111" then
						OF1 <= '1';
					end if;
				end if;
			end if;

			-- Register write
			if M_Wr = '1' then
				TMOD <= Data_In;
			end if;
			if H0_Wr = '1' then
				Cnt0(15 downto 8) <= Data_In;
			end if;
			if L0_Wr = '1' then
				Cnt0(7 downto 0) <= Data_In;
			end if;
			if H1_Wr = '1' then
				Cnt1(15 downto 8) <= Data_In;
			end if;
			if L1_Wr = '1' then
				Cnt1(7 downto 0) <= Data_In;
			end if;
		end if;
	end process;

	-- Tick generator
	process (Clk, Rst_n)
		variable Prescaler : unsigned(3 downto 0);
		variable T0_r : std_logic_vector(1 downto 0);
		variable T1_r : std_logic_vector(1 downto 0);
		variable I0_r : std_logic_vector(1 downto 0);
		variable I1_r : std_logic_vector(1 downto 0);
	begin
		if Rst_n = '0' then
			Prescaler := (others => '0');
			Tick0 <= '0';
			Tick1 <= '0';
			Tick12 <= '0';
			T0_r := "00";
			T1_r := "00";
			I0_r := "00";
			I1_r := "00";
		elsif Clk'event and Clk='1' then
			Tick0 <= '0';
			Tick1 <= '0';
			Tick12 <= '0';

			if R0 = '1' and (I0_r(1) = '1' or TMOD(3) = '0') then
				if TMOD(2) = '1' then
					Tick0 <= T0_r(0) and not T0_r(1);
				else
					Tick0 <= Tick12;
				end if;
			end if;

			if R1 = '1' and (I1_r(1) = '1' or TMOD(7) = '0') then
				if TMOD(6) = '1' then
					Tick1 <= T1_r(0) and not T1_r(1);
				else
					Tick1 <= Tick12;
				end if;
			end if;

			T0_r(1) := T0_r(0);
			T1_r(1) := T1_r(0);
			T0_r(0) := T0;
			T1_r(0) := T1;

			I0_r(1) := I0_r(0);
			I1_r(1) := I1_r(0);
			I0_r(0) := INT0;
			I1_r(0) := INT1;

			if Prescaler = "1011" then
				Prescaler := "0000";
				Tick12 <= '1';
			else
				Prescaler := Prescaler + 1;
			end if;
			if FastCount/=0 then
				Tick12 <= '1';
			end if;
		end if;
	end process;

end;
