--
-- PIC16xx compatible microcontroller core
--
-- Version : 0224
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
--	http://www.opencores.org/cvsweb.shtml/ppx16/
--
-- Limitations :
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;

package PPX_Pack is

	component PPX_ALU
	generic(
		InstructionLength : integer
	);
	port (
		Clk			: in std_logic;
		ROM_Data	: in std_logic_vector(InstructionLength - 1 downto 0);
		A			: in std_logic_vector(7 downto 0);
		B			: in std_logic_vector(7 downto 0);
		Q			: out std_logic_vector(7 downto 0);
		Skip		: in std_logic;
		Carry		: in std_logic;
		Z_Skip		: out std_logic;
		STATUS_d	: out std_logic_vector(2 downto 0);
		STATUS_Wr	: out std_logic_vector(2 downto 0)
	);
	end component;

	component PPX_Ctrl
	generic(
		InstructionLength : integer
	);
	port(
		Clk			: in std_logic;
		Reset_n			: in std_logic;
		ROM_Data	: in std_logic_vector(InstructionLength - 1 downto 0);
		Inst		: in std_logic_vector(InstructionLength - 1 downto 0);
		Skip		: in std_logic;
		File_Wr		: out std_logic;
		W_Wr		: out std_logic;
		Imm_Op		: out std_logic;
		A2Res		: out std_logic;
		B2Res		: out std_logic;
		Push		: out std_logic;
		Pop			: out std_logic;
		Goto		: out std_logic;
		IRet		: out std_logic;
		B_Skip		: out std_logic;
		Sleep		: out std_logic
	);
	end component;

	component PPX_PCS
	generic(
		PC_Width		: integer;
		StackAddrWidth	: integer;
		TopBoot			: boolean
	);
	port(
		Clk				: in std_logic;
		Reset_n			: in std_logic;
		CS				: in std_logic;
		Wr				: in std_logic;
		Data_In			: in std_logic_vector(7 downto 0);
		Addr_In			: in std_logic_vector(PC_Width - 3 downto 0);
		PCLATH			: in std_logic_vector(4 downto 0);
		STATUS			: in std_logic_vector(6 downto 5);
		NPC				: out std_logic_vector(PC_Width - 1 downto 0);
		Int				: in std_logic;
		Sleep			: in std_logic;
		Push			: in std_logic;
		Pop				: in std_logic;
		Goto			: in std_logic
	);
	end component;

	component PPX16
	generic(
		InstructionLength	: integer;
		ROMAddressWidth		: integer;
		StackAddrWidth		: integer;
		TopBoot				: boolean
	);
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		ROM_Addr	: out std_logic_vector(ROMAddressWidth - 1 downto 0);
		ROM_Data	: in std_logic_vector(InstructionLength - 1 downto 0);
		Int_Trig	: in std_logic;
		GIE			: in std_logic;
		Int_Acc		: out std_logic;
		Int_Ret		: out std_logic;
		File_Addr	: out std_logic_vector(InstructionLength - 6 downto 0);
		File_Addr_r	: out std_logic_vector(InstructionLength - 6 downto 0);
		File_Wr		: out std_logic;
		W_Wr		: out std_logic;
		Instruction	: out std_logic_vector(InstructionLength - 1 downto 0);
		Op_Bus		: in std_logic_vector(7 downto 0);
		W			: out std_logic_vector(7 downto 0);
		STATUS		: out std_logic_vector(7 downto 0);
		FSR			: out std_logic_vector(7 downto 0);
		PCLATH		: out std_logic_vector(4 downto 0);
		Res_Bus		: out std_logic_vector(7 downto 0)
	);
	end component;

	component PPX_RAM
	generic(
		Bottom		: integer;
		Top			: integer;
		AddrWidth	: integer
	);
	port(
		Clk			: in std_logic;
		CS			: in std_logic;
		Wr			: in std_logic;
		Addr		: in std_logic_vector(AddrWidth - 1 downto 0);
		Data_In		: in std_logic_vector(7 downto 0);
		Data_Out	: out std_logic_vector(7 downto 0)
	);
	end component;

	component PPX_Port
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		Port_Wr		: in std_logic;
		Tris_Wr		: in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		Port_In		: out std_logic_vector(7 downto 0);
		Tris		: out std_logic_vector(7 downto 0);
		IOPort		: inout std_logic_vector(7 downto 0)
	);
	end component;

	component PPX_TMR
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
	end component;

end PPX_Pack;
