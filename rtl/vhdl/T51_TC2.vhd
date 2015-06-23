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

entity T51_TC2 is
	generic(
		FastCount	: integer := 0;
		tristate  : integer := 1
	);
	port(
		Clk			: in std_logic;
		Rst_n		: in std_logic;
		T2			: in std_logic;
		T2EX		: in std_logic;
		C_Sel		: in std_logic;
		CH_Sel		: in std_logic;
		CL_Sel		: in std_logic;
		H_Sel		: in std_logic;
		L_Sel		: in std_logic;
		C_Wr		: in std_logic;
		CH_Wr		: in std_logic;
		CL_Wr		: in std_logic;
		H_Wr		: in std_logic;
		L_Wr		: in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		Data_Out	: out std_logic_vector(7 downto 0);
		UseR2		: out std_logic;
		UseT2		: out std_logic;
		UART_Clk	: out std_logic;
		F			: out std_logic
	);
end T51_TC2;

architecture rtl of T51_TC2 is

	signal	TCON		: std_logic_vector(7 downto 0);
	signal	Cnt			: std_logic_vector(15 downto 0);
	signal	Cpt			: std_logic_vector(15 downto 0);

	signal	Tick		: std_logic;
	signal	Tick12		: std_logic;
	signal	Capture		: std_logic;

begin

	F     <= TCON(6) or TCON(7);
	UseR2 <= TCON(5);
	UseT2 <= TCON(4);

	-- Registers and counter
	tristate_mux: if tristate/=0 generate
  	Data_Out <= Cnt(15 downto 8) when H_Sel = '1' else "ZZZZZZZZ";
  	Data_Out <= Cnt(7 downto 0) when L_Sel = '1' else "ZZZZZZZZ";
  	Data_Out <= Cpt(15 downto 8) when CH_Sel = '1' else "ZZZZZZZZ";
  	Data_Out <= Cpt(7 downto 0) when CL_Sel = '1' else "ZZZZZZZZ";
  	Data_Out <= TCON when C_Sel = '1' else "ZZZZZZZZ";
	end generate;
	
	std_mux: if tristate=0 generate
	Data_Out <= Cnt(15 downto 8) when H_Sel = '1' else 
	            Cnt(7 downto 0) when L_Sel = '1' else 
	            Cpt(15 downto 8) when CH_Sel = '1' else
	            Cpt(7 downto 0) when CL_Sel = '1' else
	            TCON when C_Sel = '1' else 
	            (others =>'-');
	end generate;
	
	process (Rst_n, Clk)
	begin
		if Rst_n = '0' then
			TCON <= (others => '0');
			Cnt <= (others => '0');
			Cpt <= (others => '0');
			UART_Clk <= '0';
		elsif Clk'event and Clk = '1' then
--			TCON(7) <= '0';
			UART_Clk <= '0';
			if Tick = '1' then
				Cnt <= std_logic_vector(unsigned(Cnt) + 1);
				if Cnt = "1111111111111111" then
					if TCON(4) = '0' and TCON(5) = '0' then
						TCON(7) <= '1';
					end if;
					if TCON(0) = '0' or TCON(4) = '1' or TCON(5) = '1' then
						Cnt <= Cpt;
					end if;
					UART_Clk <= '1';
				end if;
			end if;
			if Capture = '1' and TCON(0) = '0' and TCON(4) = '0' and TCON(5) = '0' then
				Cnt <= Cpt;
				TCON(6) <= '1';
			end if;
			if Capture = '1' and TCON(0) = '1' and TCON(4) = '0' and TCON(5) = '0' then
				Cpt <= Cnt;
				TCON(6) <= '1';
			end if;

			-- Register write
			if C_Wr = '1' then
				TCON <= Data_In;
			end if;
			if H_Wr = '1' then
				Cnt(15 downto 8) <= Data_In;
			end if;
			if L_Wr = '1' then
				Cnt(7 downto 0) <= Data_In;
			end if;
			if CH_Wr = '1' then
				Cpt(15 downto 8) <= Data_In;
			end if;
			if CL_Wr = '1' then
				Cpt(7 downto 0) <= Data_In;
			end if;
		end if;
	end process;

	-- Tick generator
	process (Clk, Rst_n)
		variable Prescaler : unsigned(3 downto 0);
		variable T_r : std_logic_vector(1 downto 0);
		variable E_r : std_logic_vector(1 downto 0);
	begin
		if Rst_n = '0' then
			Prescaler := (others => '0');
			Tick <= '0';
			Tick12 <= '0';
			Capture <= '0';
			T_r := "00";
		elsif Clk'event and Clk='1' then
			Tick <= '0';
			Tick12 <= '0';
			Capture <= '0';

			if TCON(2) = '1' then
				if TCON(1) = '1' then
					Tick <= T_r(0) and not T_r(1);
				else
					Tick <= Tick12;
				end if;
			end if;

			if TCON(3) = '1' then
				Capture <= E_r(1) and not E_r(0);
			end if;

			T_r(1) := T_r(0);
			T_r(0) := T2;

			E_r(1) := E_r(0);
			E_r(0) := T2EX;

			if (Prescaler(0) = '1' and (TCON(4) = '1' or TCON(5) = '1')) or Prescaler = "1011" then
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
