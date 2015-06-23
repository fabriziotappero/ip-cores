--
-- PIC16xx compatible microcontroller core
--
-- Version : 0232
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
--	Registers implemented in this entity are INDF, PCL, STATUS, FSR, (PCLATH)
--	other registers must be implemented externally including GPR
--
-- File history :
--
--	0232 : Fixed bank decoding and FSR/PCLATH register access

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.PPX_Pack.all;

entity PPX16 is
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
end PPX16;

architecture rtl of PPX16 is

	-- File control
	signal	File_Addr_i		: std_logic_vector(InstructionLength - 6 downto 0);
	signal	File_Addr_i_r	: std_logic_vector(InstructionLength - 6 downto 0);
	signal	File_Wr_i		: std_logic;
	signal	PC_CS			: std_logic;

	-- Registers
	signal	W_i				: std_logic_vector(7 downto 0);
	signal	PCLATH_d		: std_logic_vector(4 downto 0);
	signal	PCLATH_i		: std_logic_vector(4 downto 0);
	signal	STATUS_i		: std_logic_vector(7 downto 0);
	signal	FSR_d			: std_logic_vector(7 downto 0);
	signal	FSR_i			: std_logic_vector(7 downto 0);
	signal	NPC				: std_logic_vector(InstructionLength - 2 downto 0);

	-- Registered instruction word
	signal	Inst			: std_logic_vector(InstructionLength - 1 downto 0);

	-- Control signals
	signal	Res_Bus_i		: std_logic_vector(7 downto 0);
	signal	Q				: std_logic_vector(7 downto 0);
	signal	Op_Mux			: std_logic_vector(7 downto 0);
	signal	STATUS_d_i		: std_logic_vector(7 downto 0);
	signal	STATUS_d		: std_logic_vector(2 downto 0);
	signal	STATUS_Wr		: std_logic_vector(2 downto 0);
	signal	Z_Skip			: std_logic;
	signal	B_Skip			: std_logic;
	signal	Inst_Skip		: std_logic;
	signal	W_Wr_i			: std_logic;
	signal	Imm_Op			: std_logic;
	signal	Push			: std_logic;
	signal	Pop				: std_logic;
	signal	Goto			: std_logic;
	signal	IRet			: std_logic;
	signal	A2Res			: std_logic;
	signal	B2Res			: std_logic;
	signal	Sleep			: std_logic;
	signal	Sleep_r			: std_logic;
	signal	Int				: std_logic;
	signal	Int_Pending		: std_logic;

begin

	Int_Acc <= Int;
	W_Wr <= W_Wr_i;
	W <= W_i;
	STATUS <= STATUS_d_i;
	PCLATH <= PCLATH_d;
	FSR <= FSR_d;

	-- Instruction register
	Instruction <= Inst;
	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			Inst <= (others => '0'); -- Force NOP at reset.
		elsif Clk'event and Clk = '1' then
			if Inst_Skip = '1' then
				Inst <= (others => '0'); -- Flush (Force NOP)
			else
				Inst <= ROM_Data;
			end if;
		end if;
	end process;

	-- File address
	File_Addr <= File_Addr_i;
	i12 : if InstructionLength = 12 generate
		File_Addr_i <= FSR_d(6 downto 0) when
-- pragma translate_off
					is_x(ROM_Data) or
-- pragma translate_on
					unsigned(ROM_Data(4 downto 0)) = 0 else
					FSR_d(6 downto 5) & ROM_Data(4 downto 0);
	end generate;
	i14 : if InstructionLength = 14 generate
		File_Addr_i <= STATUS_d_i(7) & FSR_d(7 downto 0) when
-- pragma translate_off
					is_x(ROM_Data) or
-- pragma translate_on
					unsigned(ROM_Data(6 downto 0)) = 0 else
					STATUS_d_i(6 downto 5) & ROM_Data(6 downto 0);
	end generate;
	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			File_Addr_r <= File_Addr_i;
			File_Addr_i_r <= File_Addr_i;
		end if;
	end process;

	-- PCLATH Register
	PCLATH_d <= Res_Bus_i(4 downto 0) when
		to_integer(unsigned(File_Addr_i_r(6 downto 0))) = 10 and File_Wr_i = '1'
		else PCLATH_i;
	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			PCLATH_i <= "00000";
		elsif Clk'event and Clk = '1' then
			PCLATH_i <= PCLATH_d;
		end if;
	end process;

	-- Working register
	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			if W_Wr_i = '1' then
				W_i <= Res_Bus_i;
			end if;
		end if;
	end process;

	-- Status register
	process (STATUS_Wr, STATUS_d, STATUS_i, A2Res, Op_Bus, File_Addr_i_r, File_Wr_i, Res_Bus_i)
	begin
		STATUS_d_i <= STATUS_i;
		if STATUS_Wr(0) = '1' then
			STATUS_d_i(0) <= STATUS_d(0);
		end if;
		if STATUS_Wr(1) = '1' then
			STATUS_d_i(1) <= STATUS_d(1);
		end if;
		if STATUS_Wr(2) = '1' then
			STATUS_d_i(2) <= STATUS_d(2);
		end if;
		if A2Res = '1' then
			STATUS_d_i(2) <= '0';
			if Op_Bus = "00000000" then
				STATUS_d_i(2) <= '1';
			end if;
		end if;
		if to_integer(unsigned(File_Addr_i_r(InstructionLength - 8 downto 0))) = 3 and File_Wr_i = '1' then
			STATUS_d_i <= Res_Bus_i;
		end if;
	end process;
	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			STATUS_i <= "00011000";
		elsif Clk'event and Clk = '1' then
			STATUS_i <= STATUS_d_i;
		end if;
	end process;

	-- FSR Register
	FSR_d <= Res_Bus_i when
		to_integer(unsigned(File_Addr_i_r(InstructionLength - 8 downto 0))) = 4 and
		File_Wr_i = '1' else FSR_i;
	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			FSR_i <= "11111111";
		elsif Clk'event and Clk = '1' then
			FSR_i <= FSR_d;
		end if;
	end process;

	-- Program counter
	PC_CS <= '1' when to_integer(unsigned(File_Addr_i_r(InstructionLength - 8 downto 0))) = 2 else '0';
	ROM_Addr <= NPC(ROMAddressWidth - 1 downto 0);
	pcs : PPX_PCS
		generic map(
			PC_Width => InstructionLength - 1,
			StackAddrWidth => StackAddrWidth,
			TopBoot => TopBoot)
		port map(
			Clk => Clk,
			Reset_n => Reset_n,
			CS => PC_CS,
			Wr => File_Wr_i,
			Data_In => Res_Bus_i,
			Addr_In => Inst(InstructionLength - 4 downto 0),
			PCLATH => PCLATH_i,
			STATUS => STATUS_i(6 downto 5),
			NPC => NPC,
			Int => Int,
			Sleep => Sleep_r,
			Push => Push,
			Pop => Pop,
			Goto => Goto);

	-- ALU
	Op_Mux <= Inst(7 downto 0) when Imm_Op = '1' else W_i;
	Res_Bus <= Res_Bus_i;
	Res_Bus_i <= Op_Bus when A2Res = '1' else Op_Mux when B2Res = '1' else Q;
	alu : PPX_ALU
		generic map(InstructionLength => InstructionLength)
		port map(
			Clk => Clk,
			ROM_Data => ROM_Data,
			A => Op_Bus,
			B => Op_Mux,
			Q => Q,
			Skip => Inst_Skip,
			Carry => STATUS_i(0),
			Z_Skip => Z_Skip,
			STATUS_d => STATUS_d,
			STATUS_Wr => STATUS_Wr);

	-- Instruction decoder
	File_Wr <= File_Wr_i;
	Inst_Skip <= Z_Skip or B_Skip or Sleep_r or Int_Pending;
	id : PPX_Ctrl
		generic map(InstructionLength => InstructionLength)
		port map(
			Clk => Clk,
			Reset_n => Reset_n,
			ROM_Data => ROM_Data,
			Inst => Inst,
			Skip => Inst_Skip,
			File_Wr => File_Wr_i,
			W_Wr => W_Wr_i,
			Imm_Op => Imm_Op,
			A2Res => A2Res,
			B2Res => B2Res,
			Push => Push,
			Pop => Pop,
			Goto => Goto,
			IRet => IRet,
			B_Skip => B_Skip,
			Sleep => Sleep);

	-- Interrupt
	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			Sleep_r <= '0';
			Int <= '0';
			Int_Pending <= '0';
			Int_Ret <= '0';
		elsif Clk'event and Clk = '1' then
			if Sleep = '1' then
				Sleep_r <= '1';
			end if;
			if Int_Trig = '1' then
				Sleep_r <= '0';
			end if;
			Int_Pending <= '0';
			Int <= '0';
			if Int_Trig = '1' and GIE = '1' and Int = '0' then
				Int_Pending <= '1';
			end if;
			if Int_Pending = '1' and Int = '0' and (Z_Skip or B_Skip or Sleep_r) = '0' then
				Int <= '1';
			end if;
			if IRet = '1' then
				Int_Ret <= '1';
			else
				Int_Ret <= '0';
			end if;
		end if;
	end process;

end;
