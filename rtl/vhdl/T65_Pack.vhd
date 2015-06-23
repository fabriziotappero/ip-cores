--
-- 65xx compatible microprocessor core
--
-- Version : 0246
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
--	http://www.opencores.org/cvsweb.shtml/t65/
--
-- Limitations :
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;

package T65_Pack is

	constant Flag_C : integer := 0;
	constant Flag_Z : integer := 1;
	constant Flag_I : integer := 2;
	constant Flag_D : integer := 3;
	constant Flag_B : integer := 4;
	constant Flag_1 : integer := 5;
	constant Flag_V : integer := 6;
	constant Flag_N : integer := 7;

	component T65
	port(
		Mode	: in std_logic_vector(1 downto 0);	-- "00" => 6502, "01" => 65C02, "10" => 65816
		Res_n	: in std_logic;
		Clk		: in std_logic;
		Rdy		: in std_logic;
		Abort_n	: in std_logic;
		IRQ_n	: in std_logic;
		NMI_n	: in std_logic;
		SO_n	: in std_logic;
		R_W_n	: out std_logic;
		Sync	: out std_logic;
		EF		: out std_logic;
		MF		: out std_logic;
		XF		: out std_logic;
		ML_n	: out std_logic;
		VP_n	: out std_logic;
		VDA		: out std_logic;
		VPA		: out std_logic;
		A		: out std_logic_vector(23 downto 0);
		DI		: in std_logic_vector(7 downto 0);
		DO		: out std_logic_vector(7 downto 0)
	);
	end component;

	component T65_MCode
	port(
		Mode			: in std_logic_vector(1 downto 0);	-- "00" => 6502, "01" => 65C02, "10" => 65816
		IR				: in std_logic_vector(7 downto 0);
		MCycle			: in std_logic_vector(2 downto 0);
		P				: in std_logic_vector(7 downto 0);
		LCycle			: out std_logic_vector(2 downto 0);
		ALU_Op			: out std_logic_vector(3 downto 0);
		Set_BusA_To		: out std_logic_vector(2 downto 0); -- DI,A,X,Y,S,P
		Set_Addr_To		: out std_logic_vector(1 downto 0); -- PC Adder,S,AD,BA
		Write_Data		: out std_logic_vector(2 downto 0); -- DL,A,X,Y,S,P,PCL,PCH
		Jump			: out std_logic_vector(1 downto 0); -- PC,++,DIDL,Rel
		BAAdd			: out std_logic_vector(1 downto 0);	-- None,DB Inc,BA Add,BA Adj
		BreakAtNA		: out std_logic;
		ADAdd			: out std_logic;
		PCAdd			: out std_logic;
		Inc_S			: out std_logic;
		Dec_S			: out std_logic;
		LDA				: out std_logic;
		LDP				: out std_logic;
		LDX				: out std_logic;
		LDY				: out std_logic;
		LDS				: out std_logic;
		LDDI			: out std_logic;
		LDALU			: out std_logic;
		LDAD			: out std_logic;
		LDBAL			: out std_logic;
		LDBAH			: out std_logic;
		SaveP			: out std_logic;
		Write			: out std_logic
	);
	end component;

	component T65_ALU
	port(
		Mode	: in std_logic_vector(1 downto 0);	-- "00" => 6502, "01" => 65C02, "10" => 65C816
		Op		: in std_logic_vector(3 downto 0);
		BusA	: in std_logic_vector(7 downto 0);
		BusB	: in std_logic_vector(7 downto 0);
		P_In	: in std_logic_vector(7 downto 0);
		P_Out	: out std_logic_vector(7 downto 0);
		Q		: out std_logic_vector(7 downto 0)
	);
	end component;

end;
