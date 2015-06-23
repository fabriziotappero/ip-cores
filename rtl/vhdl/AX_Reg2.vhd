--
-- AT90Sxxxx compatible microcontroller core
--
-- Version : 0146
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.AX_Pack.all;

entity AX_Reg is
	generic(
		BigISet : boolean
	);
	port (
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		Wr			: in std_logic;
		Rd_Addr		: in std_logic_vector(4 downto 0);
		Rr_Addr		: in std_logic_vector(4 downto 0);
		Data_In		: in std_logic_vector(7 downto 0);
		Rd_Data		: out std_logic_vector(7 downto 0);
		Rr_Data		: out std_logic_vector(7 downto 0);
		Add			: in std_logic;
		Sub			: in std_logic;
		AS_Offset	: in std_logic_vector(5 downto 0);
		AS_Reg		: in std_logic_vector(1 downto 0);
		Dec_X		: in std_logic;
		Dec_Y		: in std_logic;
		Dec_Z		: in std_logic;
		Inc_X		: in std_logic;
		Inc_Y		: in std_logic;
		Inc_Z		: in std_logic;
		X			: out unsigned(15 downto 0);
		Y			: out unsigned(15 downto 0);
		Z			: out unsigned(15 downto 0);
		Status_D	: out std_logic_vector(4 downto 0)	-- S,V,N,Z,C
	);
end AX_Reg;

architecture rtl of AX_Reg is

	type Reg_Image is array (31 downto 0) of std_logic_vector(7 downto 0);
	signal	RegD		: Reg_Image;
	signal	RegR		: Reg_Image;
	signal	Rd_Addr_r	: std_logic_vector(4 downto 0);

	signal	Op1			: std_logic_vector(15 downto 0);
	signal	Op2			: std_logic_vector(15 downto 0);
	signal	ASR			: std_logic_vector(15 downto 0);
	signal	AS_A		: std_logic;
	signal	AS_S		: std_logic;
	signal	Carry_v		: std_logic;
	signal	Carry15_v	: std_logic;
	signal	W_i			: unsigned(15 downto 0);
	signal	X_i			: unsigned(15 downto 0);
	signal	Y_i			: unsigned(15 downto 0);
	signal	Z_i			: unsigned(15 downto 0);

begin

	X <= X_i;
	Y <= Y_i;
	Z <= Z_i;

	g1 : if BigISet generate
		Op2(15 downto 6) <= "0000000000";
		AddSub(Op1(14 downto 0), Op2(14 downto 0), AS_S, AS_S, ASR(14 downto 0), Carry15_v);
		AddSub(Op1(15 downto 15), Op2(15 downto 15), AS_S, Carry15_v, ASR(15 downto 15), Carry_v);
		Status_D(0) <= Carry_v xor AS_S;			-- C
		Status_D(1) <= '1' when ASR = "0000000000000000" else '0';	-- Z
		Status_D(2) <= ASR(15);					-- N
		Status_D(3) <= Carry_v xor Carry15_v;	-- V
		Status_D(4) <= ASR(15) xor Carry_v xor Carry15_v;	-- S
	end generate;

	process (Reset_n, Clk)
	begin
-- pragma translate_off
		if Reset_n = '0' then
			RegD <= (others => "00000000");
			RegR <= (others => "00000000");
			if BigISet then
				W_i <= (others => '0');
				X_i <= (others => '0');
				Y_i <= (others => '0');
				AS_A <= '0';
				AS_S <= '0';
				Op2(5 downto 0) <= (others => '0');
			end if;
			Z_i <= (others => '0');
			Rd_Data <= (others => '0');
			Rr_Data <= (others => '0');
			Rd_Addr_r <= (others => '0');
		else
-- pragma translate_on
		if Clk'event and Clk = '1' then
			Rd_Addr_r <= Rd_Addr;
-- pragma translate_off
			if not is_x(Rd_Addr) then
-- pragma translate_on
				Rd_Data <= RegD(to_integer(unsigned(Rd_Addr)));
-- pragma translate_off
			end if;
			if not is_x(Rr_Addr) then
-- pragma translate_on
				Rr_Data <= RegR(to_integer(unsigned(Rr_Addr)));
-- pragma translate_off
			end if;
-- pragma translate_on
			if Rd_Addr(4 downto 3) = "11" and (BigISet or Rd_Addr(2 downto 1) = "11") then
				case Rd_Addr(2 downto 0) is
				when "000" =>
					Rd_Data <= std_logic_vector(W_i(7 downto 0));
				when "001" =>
					Rd_Data <= std_logic_vector(W_i(15 downto 8));
				when "010" =>
					Rd_Data <= std_logic_vector(X_i(7 downto 0));
				when "011" =>
					Rd_Data <= std_logic_vector(X_i(15 downto 8));
				when "100" =>
					Rd_Data <= std_logic_vector(Y_i(7 downto 0));
				when "101" =>
					Rd_Data <= std_logic_vector(Y_i(15 downto 8));
				when "110" =>
					Rd_Data <= std_logic_vector(Z_i(7 downto 0));
				when others =>
					Rd_Data <= std_logic_vector(Z_i(15 downto 8));
				end case;
			end if;
			if Rr_Addr(4 downto 3) = "11" and (BigISet or Rr_Addr(2 downto 1) = "11") then
				case Rr_Addr(2 downto 0) is
				when "000" =>
					Rr_Data <= std_logic_vector(W_i(7 downto 0));
				when "001" =>
					Rr_Data <= std_logic_vector(W_i(15 downto 8));
				when "010" =>
					Rr_Data <= std_logic_vector(X_i(7 downto 0));
				when "011" =>
					Rr_Data <= std_logic_vector(X_i(15 downto 8));
				when "100" =>
					Rr_Data <= std_logic_vector(Y_i(7 downto 0));
				when "101" =>
					Rr_Data <= std_logic_vector(Y_i(15 downto 8));
				when "110" =>
					Rr_Data <= std_logic_vector(Z_i(7 downto 0));
				when others =>
					Rr_Data <= std_logic_vector(Z_i(15 downto 8));
				end case;
			end if;
			if Wr = '1' then
				RegD(to_integer(unsigned(Rd_Addr_r))) <= Data_In;
				RegR(to_integer(unsigned(Rd_Addr_r))) <= Data_In;
				if Rd_Addr_r = Rd_Addr then
					Rd_Data <= Data_In;
				end if;
				if Rd_Addr_r = Rr_Addr then
					Rr_Data <= Data_In;
				end if;
				if BigISet then
					if Rd_Addr_r = "11000" then
						W_i(7 downto 0) <= unsigned(Data_In);
					end if;
					if Rd_Addr_r = "11001" then
						W_i(15 downto 8) <= unsigned(Data_In);
					end if;
					if Rd_Addr_r = "11010" then
						X_i(7 downto 0) <= unsigned(Data_In);
					end if;
					if Rd_Addr_r = "11011" then
						X_i(15 downto 8) <= unsigned(Data_In);
					end if;
					if Rd_Addr_r = "11100" then
						Y_i(7 downto 0) <= unsigned(Data_In);
					end if;
					if Rd_Addr_r = "11101" then
						Y_i(15 downto 8) <= unsigned(Data_In);
					end if;
				end if;
				if Rd_Addr_r = "11110" then
					Z_i(7 downto 0) <= unsigned(Data_In);
				end if;
				if Rd_Addr_r = "11111" then
					Z_i(15 downto 8) <= unsigned(Data_In);
				end if;
			end if;
			if BigIset then
				AS_A <= Add;
				AS_S <= Sub;
				case AS_Reg is
				when "00" =>
					Op1 <= std_logic_vector(W_i);
				when "01" =>
					Op1 <= std_logic_vector(X_i);
				when "10" =>
					Op1 <= std_logic_vector(Y_i);
				when others =>
					Op1 <= std_logic_vector(Z_i);
				end case;
				Op2(5 downto 0) <= AS_Offset;
				if AS_A = '1' or AS_S = '1' then
					case AS_Reg is
					when "00" =>
						W_i <= unsigned(ASR);
					when "01" =>
						X_i <= unsigned(ASR);
					when "10" =>
						Y_i <= unsigned(ASR);
					when others =>
						Z_i <= unsigned(ASR);
					end case;
				end if;
				if Dec_X = '1' then
					X_i <= X_i - 1;
				end if;
				if Dec_Y = '1' then
					Y_i <= Y_i - 1;
				end if;
				if Dec_Z = '1' then
					Z_i <= Z_i - 1;
				end if;
				if Inc_X = '1' then
					X_i <= X_i + 1;
				end if;
				if Inc_Y = '1' then
					Y_i <= Y_i + 1;
				end if;
				if Inc_Z = '1' then
					Z_i <= Z_i + 1;
				end if;
			end if;
		end if;
-- pragma translate_off
		end if;
-- pragma translate_on
	end process;
end;
