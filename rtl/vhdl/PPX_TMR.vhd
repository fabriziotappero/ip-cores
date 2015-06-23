--
-- PIC16xx compatible microcontroller core
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
--	Registers implemented in this entity are INDF, PCL, STATUS, FSR, (PCLATH)
--	other registers must be implemented externally including GPR
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PPX_TMR is
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		CKI			: in std_logic;
		SE			: in std_logic;
		CS			: in std_logic;
		PS			: in std_logic_vector(2 downto 0);
		PSA			: in std_logic;
		TMR_Sel		: in std_logic;
		Wr			: in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		Data_Out	: out std_logic_vector(7 downto 0);
		TOF			: out std_logic
	);
end PPX_TMR;

architecture rtl of PPX_TMR is

	signal	TMR		: std_logic_vector(7 downto 0);

	signal	Tick	: std_logic;

begin

	Data_Out <= TMR;

	-- Registers and counter
	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			TMR <= "00000000";
			TOF <= '0';
		elsif Clk'event and Clk = '1' then
			TOF <= '0';
			if Tick = '1' then
				TMR <= std_logic_vector(unsigned(TMR) + 1);
				if TMR = "11111111" then
					TOF <= '1';
				end if;
			end if;
			if TMR_Sel = '1' and Wr = '1' then
				TMR <= Data_In;
				TOF <= '0';
			end if;
		end if;
	end process;

	-- Tick generator
	process (Clk, Reset_n)
		variable Prescaler : unsigned(7 downto 0);
		variable CKI_r : std_logic_vector(1 downto 0);
		variable P_r : std_logic_vector(1 downto 0);
		variable Tick0 : std_logic;
	begin
		if Reset_n = '0' then
			Prescaler := (others => '0');
			Tick <= '0';
			Tick0 := '0';
			CKI_r := "00";
			P_r := "00";
		elsif Clk'event and Clk='1' then
			P_r(1) := P_r(0);
			case PS is
			when "000" => P_r(0) := Prescaler(0);
			when "001" => P_r(0) := Prescaler(1);
			when "010" => P_r(0) := Prescaler(2);
			when "011" => P_r(0) := Prescaler(3);
			when "100" => P_r(0) := Prescaler(4);
			when "101" => P_r(0) := Prescaler(5);
			when "110" => P_r(0) := Prescaler(6);
			when others => P_r(0) := Prescaler(7);
			end case;

			Tick0 := '0';
			if SE = '0' then -- low-to-high
				if CKI_r(1) = '1' and CKI_r(0) = '0' then
					Tick0 := '1';
				end if;
			else
				if CKI_r(1) = '0' and CKI_r(0) = '1' then
					Tick0 := '1';
				end if;
			end if;
			if CS = '0' then
				Tick0 := '1';
			end if;
			CKI_r(1) := CKI_r(0);
			CKI_r(0) := CKI;

			Tick <= '0';
			if PSA = '1' then
				Tick <= Tick0;
			elsif P_r(1) = '1' and P_r(0) = '0' then
				Tick <= '1';
			end if;

			if Tick0 = '1' then
				Prescaler := Prescaler + 1;
			end if;
		end if;
	end process;

end;
