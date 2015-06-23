--
-- AT90Sxxxx compatible microcontroller core
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
--	http://www.opencores.org/cvsweb.shtml/ax8/
--
-- Limitations :
--	No power down sleep, only 16 bit addresses, no external RAM
--
-- File history :
--
--	0146 : First release
--	0220 : Added support for synchronous ROM
--	0221 : Changed tristate buses
--	0221b : Changed tristate buses
--	0224 : Fixed reset

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.AX_Pack.all;

entity AX8 is
	generic(
		ROMAddressWidth : integer;
		RAMAddressWidth : integer;
		BigISet : boolean;
		TriState : boolean := false
	);
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		ROM_Addr	: out std_logic_vector(ROMAddressWidth - 1 downto 0);
		ROM_Data	: in std_logic_vector(15 downto 0);
		Sleep_En	: in std_logic;
		Int_Trig	: in std_logic_vector(15 downto 1);
		Int_Acc		: out std_logic_vector(15 downto 1);
		SREG		: out std_logic_vector(7 downto 0);
		SP			: out std_logic_vector(15 downto 0);
		IO_Rd		: out std_logic;
		IO_Wr		: out std_logic;
		IO_Addr		: out std_logic_vector(5 downto 0);
		IO_RData	: in std_logic_vector(7 downto 0);
		IO_WData	: out std_logic_vector(7 downto 0);
		WDR			: out std_logic
	);
end AX8;

architecture rtl of AX8 is

	-- Registers
	signal	SREG_i		: std_logic_vector(7 downto 0);
	signal	SP_i		: unsigned(15 downto 0);
	signal	NPC			: std_logic_vector(15 downto 0);
	signal	PC			: std_logic_vector(15 downto 0);
	signal	PCH			: std_logic_vector(7 downto 0);
	signal	Dec_SP		: std_logic;
	signal	Inc_SP		: std_logic;
	signal	X			: unsigned(15 downto 0);
	signal	Y			: unsigned(15 downto 0);
	signal	Z			: unsigned(15 downto 0);
	signal	Add			: std_logic;
	signal	Sub			: std_logic;
	signal	AS_Offset	: std_logic_vector(5 downto 0);
	signal	Dec_X		: std_logic;
	signal	Dec_Y		: std_logic;
	signal	Dec_Z		: std_logic;
	signal	Inc_X		: std_logic;
	signal	Inc_Y		: std_logic;
	signal	Inc_Z		: std_logic;

	-- ALU signals
	signal	Do_Other	: std_logic;
	signal	Pass_Mux	: std_logic_vector(7 downto 0);
	signal	Op_Mux		: std_logic_vector(7 downto 0);
	signal	Status_D	: std_logic_vector(6 downto 0);
	signal	Status_D_R	: std_logic_vector(4 downto 0);
	signal	Status_Wr	: std_logic_vector(6 downto 0);
	signal	Status_D_Wr	: std_logic;

	-- Misc signals
	signal	Rd_Addr		: std_logic_vector(15 downto 0);
	signal	Rr_Addr		: std_logic_vector(15 downto 0);
	signal	IO_Addr_i	: std_logic_vector(5 downto 0);

	signal	Wr_Data		: std_logic_vector(7 downto 0);
	signal	Rd_Data		: std_logic_vector(7 downto 0);
	signal	Rr_Data		: std_logic_vector(7 downto 0);

	signal	RAM_Data	: std_logic_vector(7 downto 0);

	signal	Offset		: std_logic_vector(11 downto 0);

	signal	Q			: std_logic_vector(7 downto 0);

	signal	Disp		: std_logic_vector(5 downto 0);

	signal	Bit_Pattern	: std_logic_vector(7 downto 0);
	signal	IO_BMData	: std_logic_vector(7 downto 0);
	signal	IO_BTest	: std_logic_vector(7 downto 0);
	signal	Do_SBIC		: std_logic;
	signal	Do_SBIS		: std_logic;

	signal	CInt		: std_logic_vector(3 downto 0);
	signal	IPush		: std_logic;
	signal	IPending	: std_logic;

	-- Registered instruction word.
	signal	Inst		: std_logic_vector(15 downto 0);

	-- Control signals
	signal	Rst_r		: std_logic;
	signal	IO_IR		: std_logic;
	signal	RAM_IR		: std_logic;
	signal	PMH_IR		: std_logic;
	signal	PML_IR		: std_logic;
	signal	IO_IW		: std_logic;
	signal	RAM_IW		: std_logic;
	signal	Reg_IW		: std_logic;
	signal	Reg_Wr		: std_logic;
	signal	HPC_Rd		: std_logic;
	signal	LPC_Rd		: std_logic;
	signal	Reg_Rd		: std_logic;
	signal	RAM_Rd		: std_logic;
	signal	PMH_Rd		: std_logic;
	signal	PML_Rd		: std_logic;
	signal	Reg_Wr_ID	: std_logic;
	signal	RAM_Wr_ID	: std_logic;
	signal	PassB		: std_logic;
	signal	IO_Rd_i		: std_logic;
	signal	IO_Wr_i		: std_logic;
	signal	Z_Skip		: std_logic;
	signal	IOZ_Skip	: std_logic;
	signal	Pause		: std_logic_vector(1 downto 0);
	signal	DidPause	: std_logic_vector(1 downto 0);
	signal	PCPause		: std_logic;
	signal	IndSkip		: std_logic;
	signal	Inst_Skip	: std_logic;
	signal	PreDecode	: std_logic;
	signal	Imm_Op		: std_logic;
	signal	Push		: std_logic;
	signal	Pop			: std_logic;
	signal	HRet		: std_logic;
	signal	LRet		: std_logic;
	signal	ZJmp		: std_logic;
	signal	RJmp		: std_logic;
	signal	CBranch		: std_logic;
	signal	Sleep		: std_logic;

begin

	PreDecode <= '1' when Rst_r = '0' and Inst_Skip = '0' and (Pause = "00" or DidPause = "01") else '0';

	-- Addressing control:
	-- IO and Rd/Rr address are always generated parallel with fetch
	-- On indirect addressing the correct address is generated on the next positive clock edge
	-- The chip selects are only used with 2+ cycle instructions
	Disp <= Inst(13) & Inst(11 downto 10) & Inst(2 downto 0);
	Reg_Wr <= '1' when
					Inst(15 downto 12) = "0010" or
					Inst(15 downto 14) = "01" or
					Inst(15 downto 11) = "00001" or
					Inst(15 downto 11) = "00011" or
					Inst(15 downto 12) = "1110" or
					Inst(15 downto 9) = "1111100" or
					(Inst(15 downto 9) = "1001010" and Inst(3 downto 1) /= "100") or
					Inst(15 downto 11) = "10110" or
					Reg_Wr_ID = '1'
				else '0';
	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			Reg_Wr_ID <= Reg_IW;
			RAM_Wr_ID <= RAM_IW;
		end if;
	end process;
	process (ROM_Data, Inst, DidPause, Pause, SP_i, X, Y, Z, Disp, IPush)
	begin
		Rd_Addr <= (others => '-');
		Rr_Addr <= (others => '-');
		Rd_Addr(4 downto 0) <= ROM_Data(8 downto 4);
		Rr_Addr(4 downto 0) <= ROM_Data(9) & ROM_Data(3 downto 0);
		if ROM_Data(15 downto 12) = "0011" or
			ROM_Data(15 downto 14) = "01" or
			ROM_Data(15 downto 12) = "1110" then
			-- Special case for immediate data and four bit address
			Rd_Addr(4) <= '1';
		end if;

		Dec_X <= '0';
		Dec_Y <= '0';
		Dec_Z <= '0';
		Inc_X <= '0';
		Inc_Y <= '0';
		Inc_Z <= '0';
		Dec_SP <= '0';
		Inc_SP <= '0';
		if DidPause = "00" and Pause = "01" then
			if BigIset then
				if Inst(15 downto 14) = "10" and Inst(12) = '0' then
					if Inst(9) = '0' and Inst(3) = '0' then -- LDD Z
						Rd_Addr(4 downto 0) <= Inst(8 downto 4);
						Rr_Addr <= std_logic_vector(Z + unsigned(Disp));
					end if;
					if Inst(9) = '0' and Inst(3) = '1' then -- LDD Y
						Rd_Addr(4 downto 0) <= Inst(8 downto 4);
						Rr_Addr <= std_logic_vector(Y + unsigned(Disp));
					end if;
					if Inst(9) = '1' and Inst(3) = '0' then -- STD Z
						Rr_Addr(4 downto 0) <= Inst(8 downto 4);
						Rd_Addr <= std_logic_vector(Z + unsigned(Disp));
					end if;
					if Inst(9) = '1' and Inst(3) = '1' then -- STD Y
						Rr_Addr(4 downto 0) <= Inst(8 downto 4);
						Rd_Addr <= std_logic_vector(Y + unsigned(Disp));
					end if;
				end if;
				if Inst(15 downto 9) = "1001000" then
					Rd_Addr(4 downto 0) <= Inst(8 downto 4);
					if Inst(3 downto 0) = "0000" then
						Rr_Addr <= ROM_Data;
					end if;
					if Inst(3 downto 0) = "0001" then
						Rr_Addr <= std_logic_vector(Z);
						Inc_Z <= '1';
					end if;
					if Inst(3 downto 0) = "0010" then
						Rr_Addr <= std_logic_vector(Z - 1);
						Dec_Z <= '1';
					end if;
					if Inst(3 downto 0) = "1001" then
						Rr_Addr <= std_logic_vector(Y);
						Inc_Y <= '1';
					end if;
					if Inst(3 downto 0) = "1010" then
						Rr_Addr <= std_logic_vector(Y - 1);
						Dec_Y <= '1';
					end if;
					if Inst(3 downto 0) = "1100" then
						Rr_Addr <= std_logic_vector(X);
					end if;
					if Inst(3 downto 0) = "1101" then
						Rr_Addr <= std_logic_vector(X);
						Inc_X <= '1';
					end if;
					if Inst(3 downto 0) = "1110" then
						Rr_Addr <= std_logic_vector(X - 1);
						Dec_X <= '1';
					end if;
					if Inst(3 downto 0) = "1111" then	-- POP
						Rr_Addr <= std_logic_vector(SP_i + 1);
						Inc_SP <= '1';
					end if;
				end if;
				if Inst(15 downto 9) = "1001001" then
					Rr_Addr(4 downto 0) <= Inst(8 downto 4);
					if Inst(3 downto 0) = "0000" then
						Rd_Addr <= ROM_Data;
					end if;
					if Inst(3 downto 0) = "0001" then
						Rd_Addr <= std_logic_vector(Z);
						Inc_Z <= '1';
					end if;
					if Inst(3 downto 0) = "0010" then
						Rd_Addr <= std_logic_vector(Z - 1);
						Dec_Z <= '1';
					end if;
					if Inst(3 downto 0) = "1001" then
						Rd_Addr <= std_logic_vector(Y);
						Inc_Y <= '1';
					end if;
					if Inst(3 downto 0) = "1010" then
						Rd_Addr <= std_logic_vector(Y - 1);
						Dec_Y <= '1';
					end if;
					if Inst(3 downto 0) = "1100" then
						Rd_Addr <= std_logic_vector(X);
					end if;
					if Inst(3 downto 0) = "1101" then
						Rd_Addr <= std_logic_vector(X);
						Inc_X <= '1';
					end if;
					if Inst(3 downto 0) = "1110" then
						Rd_Addr <= std_logic_vector(X - 1);
						Dec_X <= '1';
					end if;
					if Inst(3 downto 0) = "1111" then	-- PUSH
						Rd_Addr <= std_logic_vector(SP_i);
						Dec_SP <= '1';
					end if;
				end if;
			else
				if Inst(15 downto 9) = "1000000" then -- LD Z
					Rd_Addr(4 downto 0) <= Inst(8 downto 4);
					Rr_Addr <= std_logic_vector(Z);
				end if;
				if Inst(15 downto 9) = "1000001" then -- ST Z
					Rr_Addr(4 downto 0) <= Inst(8 downto 4);
					Rd_Addr <= std_logic_vector(Z);
				end if;
			end if;
		end if;
		if ((DidPause /= "01" and (Inst = "1001010100001001" or Inst(15 downto 12) = "1101")) or IPush = '1') and BigISet then
			-- RCALL, ICALL
			Rd_Addr <= std_logic_vector(SP_i);
			Dec_SP <= '1';
		end if;
		if DidPause(0) = DidPause(1) and (Inst = "1001010100001000" or Inst = "1001010100011000") and BigISet then
			-- RET, RETI
			Rr_Addr <= std_logic_vector(SP_i + 1);
			Inc_SP <= '1';
		end if;
		if DidPause = "00" and Inst = "1001010111001000" and BigISet then
			-- LPM
			Rd_Addr(4 downto 0) <= (others => '0');
		end if;
	end process;
	process (Inst, DidPause, Rd_Addr, Rr_Addr, Dec_SP, Inc_SP, Z)
	begin
		IO_IR <= '0';
		RAM_IR <= '0';
		PMH_IR <= '0';
		PML_IR <= '0';
		Reg_IW <= '0';
		IO_IW <= '0';
		RAM_IW <= '0';
		if (DidPause = "00" and
			((Inst(15 downto 14) = "10" and Inst(12) = '0') or	-- LDD/STD
			Inst(15 downto 10) = "100100")) or					-- LD/ST
			(Dec_SP = '1' or Inc_SP = '1') then
			if (Dec_SP = '0' and Inc_SP = '0' and Inst(9) = '0') or Inc_SP = '1' then -- LD
				if Rr_Addr(15 downto 5) = "00000000000" then
				elsif Rr_Addr(15 downto 7) = "000000000" and Rr_Addr(10 downto 9) /= "00" and Rr_Addr(10 downto 9) /= "11" then
					IO_IR <= '1';
				else
					RAM_IR <= '1';
				end if;
				if not (Inst = "1001010100001000" or Inst = "1001010100011000") then -- not RETx
					Reg_IW <= '1';
				end if;
			else
				if Rd_Addr(15 downto 5) = "00000000000" then
					Reg_IW <= '1';
				elsif Rd_Addr(15 downto 7) = "000000000" and Rd_Addr(10 downto 9) /= "00" and Rd_Addr(10 downto 9) /= "11" then
					IO_IW <= '1';
				else
					RAM_IW <= '1';
				end if;
			end if;
		end if;
		if DidPause = "00" and Inst = "1001010111001000" then
			-- LPM
			Reg_IW <= '1';
			PMH_IR <= Z(0);
			PML_IR <= not Z(0);
		end if;
	end process;

	-- IO access
	SP <= std_logic_vector(SP_i);
	IO_Addr <= IO_Addr_i;
	IO_Rd <= IO_Rd_i;
	IO_Wr <= IO_Wr_i;
	IO_WData <= IO_BMData when Inst(15 downto 11) = "10011" and Inst(8) = '0' else Rd_Data;
	IO_BTest <= Bit_Pattern and IO_RData;
	IOZ_Skip <= '1' when ((IO_BTest /= "00000000") and (Do_SBIS = '1')) or
					((IO_BTest = "00000000") and (Do_SBIC = '1')) else '0';
	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			if BigISet then
				SP_i <= (others => '0');
			end if;
			IO_Addr_i <= (others => '0');
			IO_BMData <= (others => '0');
			IO_Wr_i <= '0';
			Do_SBIC <= '0';
			Do_SBIS <= '0';
		elsif Clk'event and Clk = '1' then
			Do_SBIC <= '0';
			Do_SBIS <= '0';
			if ROM_Data(15 downto 8) = "10011001" and PreDecode = '1' then
				Do_SBIC <= '1';
			end if;
			if ROM_Data(15 downto 8) = "10011011" and PreDecode = '1' then
				Do_SBIS <= '1';
			end if;
			if (Inst(15 downto 11) = "10011" and Inst(8) = '0' and DidPause(0) = '0') or
				(ROM_Data(15 downto 11) = "10111" and PreDecode = '1') or IO_IW = '1' then
				IO_Wr_i <= '1';
			else
				IO_Wr_i <= '0';
			end if;
			IO_BMData <= IO_RData;
			IO_BMData(to_integer(unsigned(Inst(2 downto 0)))) <= Inst(9);	-- CBI, SBI
			if Inst(15 downto 10) /= "100110" or DidPause(0) = '1' then
				if ROM_Data(13) = '0' then
					IO_Addr_i <= "0" & ROM_Data(7 downto 3);
				else
					IO_Addr_i <= ROM_Data(10 downto 9) & ROM_Data(3 downto 0);
				end if;
			end if;
			if IO_IR = '1' then
				IO_Addr_i <= std_logic_vector(resize(unsigned(Rr_Addr) - 32, 6));
			end if;
			if IO_IW = '1' then
				IO_Addr_i <= std_logic_vector(resize(unsigned(Rd_Addr) - 32, 6));
			end if;
			if IO_Wr_i = '1' and BigISet then
				if IO_Addr_i = "111101" then --$3D ($5D) SPL Stack Pointer Low
					SP_i(7 downto 0) <= unsigned(Rd_Data);
				end if;
				if IO_Addr_i = "111110" then --$3E ($5E) SPH Stack Pointer High
					SP_i(15 downto 8) <= unsigned(Rd_Data);
				end if;
			end if;
			if Dec_SP = '1' and BigISet then
				SP_i <= SP_i - 1;
			end if;
			if Inc_SP = '1' and BigISet then
				SP_i <= SP_i + 1;
			end if;
		end if;
	end process;

	-- Instruction register
	Inst_Skip <= Z_Skip or RJmp or ZJmp or IOZ_Skip or Sleep or IPending or IPush;
	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			Rst_r <= '1';
			Inst <= (others => '0'); -- Force NOP at reset.
			DidPause <= "00";
			Bit_Pattern <= "00000000";
		elsif Clk'event and Clk = '1' then
			Rst_r <= '0';
			if DidPause = "00" then
				DidPause <= Pause;
			else
				DidPause <= std_logic_vector(unsigned(DidPause) - 1);
			end if;
			if (Pause /= "00" and DidPause = "00") or DidPause(1) = '1' then
				-- Pause: instruction retained
			elsif Rst_r = '1' or Inst_Skip = '1' then
				-- Skip/flush: NOP insertion
				Inst <= (others => '0');
			else
				Inst <= ROM_Data;
			end if;
			case ROM_Data(2 downto 0) is
			when "000" =>
				Bit_Pattern <= "00000001";
			when "001" =>
				Bit_Pattern <= "00000010";
			when "010" =>
				Bit_Pattern <= "00000100";
			when "011" =>
				Bit_Pattern <= "00001000";
			when "100" =>
				Bit_Pattern <= "00010000";
			when "101" =>
				Bit_Pattern <= "00100000";
			when "110" =>
				Bit_Pattern <= "01000000";
			when others =>
				Bit_Pattern <= "10000000";
			end case;
		end if;
	end process;

	-- Status register
	SREG <= SREG_i;
	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			SREG_i <= "00000000";
		elsif Clk'event and Clk = '1' then
			if IO_Wr_i = '1' and IO_Addr_i = "111111" then --$3F ($5F) SREG Status Register
				SREG_i <= Rd_Data;
			end if;
			if Inst(15 downto 8) = "10010100" and Inst(3 downto 0) = "1000" then
				SREG_i(to_integer(unsigned(Inst(6 downto 4)))) <= not Inst(7);	-- BSET, BCLR
			end if;
			if Inst = "1001010100011000" then SREG_i(7) <= '1'; end if;
			if IPush = '1' then
				SREG_i(7) <= '0';
			end if;
			if Status_Wr(6) = '1' then SREG_i(6) <= Status_D(6); end if;
			if Status_Wr(5) = '1' then SREG_i(5) <= Status_D(5); end if;
			if Status_Wr(4) = '1' then SREG_i(4) <= Status_D(4); end if;
			if Status_Wr(3) = '1' then SREG_i(3) <= Status_D(3); end if;
			if Status_Wr(2) = '1' then SREG_i(2) <= Status_D(2); end if;
			if Status_Wr(1) = '1' then SREG_i(1) <= Status_D(1); end if;
			if Status_Wr(0) = '1' then SREG_i(0) <= Status_D(0); end if;
			if Status_D_Wr = '1' and BigISet then SREG_i(4 downto 0) <= Status_D_R; end if;
		end if;
	end process;

	-- Registers
	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			Add <= '0';
			Sub <= '0';
			if BigISet then
				Status_D_Wr	<= '0';
				if ROM_Data(15 downto 8) = "10010110" and PreDecode = '1' then
					Add <= '1';
				end if;
				if ROM_Data(15 downto 8) = "10010111" and PreDecode = '1' then
					Sub <= '1';
				end if;
				if Inst(15 downto 9) = "1001011" and DidPause = "00" then
					Status_D_Wr	<= '1';
				end if;
			end if;
		end if;
	end process;
	AS_Offset(5 downto 4) <= Inst(7 downto 6);
	AS_Offset(3 downto 0) <= Inst(3 downto 0);
	pr : AX_Reg
		generic map(
			BigISet => BigISet)
		port map (
			Clk => Clk,
			Reset_n => Reset_n,
			Wr => Reg_Wr,
			Rd_Addr => Rd_Addr(4 downto 0),
			Rr_Addr => Rr_Addr(4 downto 0),
			Data_In => Wr_Data,
			Rd_Data => Rd_Data,
			Rr_Data => Rr_Data,
			Add => Add,
			Sub => Sub,
			AS_Offset => AS_Offset,
			AS_Reg => Inst(5 downto 4),
			Dec_X => Dec_X,
			Dec_Y => Dec_Y,
			Dec_Z => Dec_Z,
			Inc_X => Inc_X,
			Inc_Y => Inc_Y,
			Inc_Z => Inc_Z,
			X => X,
			Y => Y,
			Z => Z,
			Status_D => Status_D_R);

	-- RAM
	g1 : if BigISet generate
		dr : AX_RAM
			generic map(
				RAMAddressWidth => RAMAddressWidth)
			port map (
				Clk => Clk,
				Rd_Addr => Rr_Addr(RAMAddressWidth downto 0),
				Wr_Addr => Rd_Addr(RAMAddressWidth downto 0),
				Wr => RAM_Wr_ID,
				Data_In => Wr_Data,
				Data_Out => RAM_Data);
	end generate;

	-- Program counter
	ROM_Addr <= "0" & std_logic_vector(Z(ROMAddressWidth - 1 downto 1))
				when Inst = "1001010111001000" and DidPause = "00"
				else NPC(ROMAddressWidth - 1 downto 0);
	PCPause <= '1' when Rst_r = '1' or (IndSkip = '0' and ((Pause /= "00" and DidPause = "00") or DidPause(1) = '1')) or Sleep = '1' else '0';
	RJmp <= '1' when Inst(15 downto 12) = "1100" or
			(Inst(15 downto 12) = "1101" and DidPause = "10") or
			(CBranch = '1' and Inst(10) = '0' and ((SREG_i and Bit_Pattern) /= "00000000")) or
			(CBranch = '1' and Inst(10) = '1' and ((SREG_i and Bit_Pattern) = "00000000")) else '0';
	HRet <= '1' when DidPause = "11" and BigIset and
			(Inst = "1001010100001000" or Inst = "1001010100011000") else '0';
	LRet <= '1' when DidPause = "10" and BigIset and
			(Inst = "1001010100001000" or Inst = "1001010100011000") else '0';
	ZJmp <= '1' when (Inst = "1001010000001001" or
			(DidPause = "10" and Inst = "1001010100001001")) and BigIset else '0';
	Push <= '1' when (Inst(15 downto 12) = "1101" or Inst = "1001010100001001") and DidPause = "00" and not BigIset else '0';
	Pop <= '1' when Inst(15 downto 5) = "10010101000" and Inst(3 downto 0) = "1000" and DidPause = "00" and not BigIset else '0';
	CBranch <= '1' when Inst(15 downto 11) = "11110" else '0';
	-- Used for >=2 cycles instructions that are not skip, jump or branch
	Pause <= "01" when (Inst(15 downto 14) = "10" and Inst(12) = '0') or	-- LDD/STD
					Inst(15 downto 10) = "100100" or						-- LD/ST
					(Inst(15 downto 11) = "10011" and Inst(8) = '0') or		-- CBI/SBI
					Inst(15 downto 9) = "1001011" else						-- ADIW/SBIW
			"10" when Inst(15 downto 12) = "1101" or						-- RCALL
					Inst = "1001010100001001" or							-- ICALL
					Inst = "1001010110001000" or							-- SLEEP
					Inst = "1001010111001000" else							-- LPM
			"11" when Inst = "1001010100001000" or							-- RET
					Inst = "1001010100011000" else "00";					-- RETI
	IndSkip <= '1' when (Inst(15 downto 10) = "100100" and Inst(3 downto 0) = "0000") else '0';
	Offset <= Inst(11 downto 0) when CBranch = '0' else
		std_logic_vector(resize(signed(Inst(9 downto 3)),12));
	pcnt : AX_PCS
		generic map(
			HW_Stack => not BigISet)
		port map (
			Clk => Clk,
			Reset_n => Reset_n,
			Offs_In => Offset,
			Z => Z,
			Data_In => Wr_Data,
			Pause => PCPause,
			Push => Push,
			Pop => Pop,
			HRet => HRet,
			LRet => LRet,
			ZJmp => ZJmp,
			RJmp => RJmp,
			CInt => CInt,
			IPending => IPending,
			IPush => IPush,
			NPC => NPC,
			PC => PC);

	-- ALU
	PassB <= '1' when (Pause /= "00" and DidPause /= "01") or IPush = '1' else '0';
	gNoTri : if not TriState generate
		Pass_Mux <= Inst(11 downto 8) & Inst(3 downto 0) when Imm_Op = '1' else
			RAM_Data when RAM_Rd = '1' else
			PCH when HPC_Rd = '1' and BigIset else
			PC(7 downto 0) when LPC_Rd = '1' and BigIset else
			Rr_Data when Reg_Rd = '1' else
			ROM_Data(15 downto 8) when PMH_Rd = '1' and BigIset else
			ROM_Data(7 downto 0) when PML_Rd = '1' and BigIset else
			IO_RData;
	end generate;
	gTri : if TriState generate
		Pass_Mux <= Inst(11 downto 8) & Inst(3 downto 0) when Imm_Op = '1' else "ZZZZZZZZ";
		Pass_Mux <= IO_RData when IO_Rd_i = '1' else "ZZZZZZZZ";
		Pass_Mux <= RAM_Data when RAM_Rd = '1' else "ZZZZZZZZ";
		Pass_Mux <= PCH when HPC_Rd = '1' and BigIset else "ZZZZZZZZ";
		Pass_Mux <= PC(7 downto 0) when LPC_Rd = '1' and BigIset else "ZZZZZZZZ";
		Pass_Mux <= Rr_Data when Reg_Rd = '1' else "ZZZZZZZZ";
		Pass_Mux <= ROM_Data(15 downto 8) when PMH_Rd = '1' and BigIset else "ZZZZZZZZ";
		Pass_Mux <= ROM_Data(7 downto 0) when PML_Rd = '1' and BigIset else "ZZZZZZZZ";
	end generate;
	Wr_Data <= Pass_Mux when Do_Other = '1' else Q;
	Op_Mux <= Inst(11 downto 8) & Inst(3 downto 0) when Imm_Op = '1' else Rr_Data;
	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			PCH <= PC(15 downto 8);
			IO_Rd_i <= '0';
			Imm_Op <= '0';
			RAM_Rd <= '0';
			Reg_Rd <= '0';
			HPC_Rd <= '0';
			LPC_Rd <= '0';
			PMH_Rd <= '0';
			PML_Rd <= '0';
			if (ROM_Data(15 downto 12) = "0011" or
				ROM_Data(15 downto 14) = "01" or
				ROM_Data(15 downto 12) = "1110") and
				PreDecode = '1' then
				Imm_Op <= '1';
			elsif RAM_IR = '1' then
				RAM_Rd <= '1';
			elsif PMH_IR = '1' and BigIset then
				PMH_Rd <= '1';
			elsif PML_IR = '1' and BigIset then
				PML_Rd <= '1';
			elsif ((ROM_Data(15 downto 10) = "100110" or ROM_Data(15 downto 11) = "10110") and PreDecode = '1') or IO_IR = '1' then
				IO_Rd_i <= '1';
			elsif ((DidPause = "10" and (Inst = "1001010100001001" or Inst(15 downto 12) = "1101")) or
				(IPush = '1' and IPending = '0')) and BigIset then
				HPC_Rd <= '1';
			elsif ((DidPause = "00" and (Inst = "1001010100001001" or Inst(15 downto 12) = "1101")) or
				(IPush = '1' and IPending = '1')) and BigIset then
				LPC_Rd <= '1';
			else
				Reg_Rd <= '1';
			end if;
		end if;
	end process;
	alu : AX_ALU
		port map(
			Clk => Clk,
			ROM_Data => ROM_Data,
			A => Rd_Data,
			B => Op_Mux,
			Q => Q,
			SREG => SREG_i,
			PassB => PassB,
			Skip => Inst_Skip,
			Do_Other => Do_Other,
			Z_Skip => Z_Skip,
			Status_D => Status_D,
			Status_Wr => Status_Wr);

	-- Interrupts and stuff
	process (Reset_n, Clk)
	begin
		if Reset_n = '0' then
			WDR <= '1';
			Sleep <= '0';
			CInt <= "0000";
			Int_Acc <= (others => '0');
			IPending <= '0';
		elsif Clk'event and Clk = '1' then
			if Inst = "1001010110101000" then
				WDR <= '1';
			else
				WDR <= '0';
			end if;
			if Inst = "1001010110001000" and Sleep_En = '1' then
				Sleep <= '1';
			end if;
			if Int_Trig /= "000000000000000" and SREG_i(7) = '1' then
				Sleep <= '0';
				IPending <= '1';
			end if;
			Int_Acc <= (others => '0');
			if IPending = '1' and IPush = '1' then
				IPending <= '0';
				if Int_Trig(1) = '1' then CInt <= "0001"; Int_Acc(1) <= '1';
				elsif Int_Trig(2) = '1' then CInt <= "0010"; Int_Acc(2) <= '1';
				elsif Int_Trig(3) = '1' then CInt <= "0011"; Int_Acc(3) <= '1';
				elsif Int_Trig(4) = '1' then CInt <= "0100"; Int_Acc(4) <= '1';
				elsif Int_Trig(5) = '1' then CInt <= "0101"; Int_Acc(5) <= '1';
				elsif Int_Trig(6) = '1' then CInt <= "0110"; Int_Acc(6) <= '1';
				elsif Int_Trig(7) = '1' then CInt <= "0111"; Int_Acc(7) <= '1';
				elsif Int_Trig(8) = '1' then CInt <= "1000"; Int_Acc(8) <= '1';
				elsif Int_Trig(9) = '1' then CInt <= "1001"; Int_Acc(9) <= '1';
				elsif Int_Trig(10) = '1' then CInt <= "1010"; Int_Acc(10) <= '1';
				elsif Int_Trig(11) = '1' then CInt <= "1011"; Int_Acc(11) <= '1';
				elsif Int_Trig(12) = '1' then CInt <= "1100"; Int_Acc(12) <= '1';
				elsif Int_Trig(13) = '1' then CInt <= "1101"; Int_Acc(13) <= '1';
				elsif Int_Trig(14) = '1' then CInt <= "1110"; Int_Acc(14) <= '1';
				elsif Int_Trig(15) = '1' then CInt <= "1111"; Int_Acc(15) <= '1';
				end if;
			end if;
			if Inst = "1001010100011000" then
				CInt <= "0000";
			end if;
		end if;
	end process;

end;
