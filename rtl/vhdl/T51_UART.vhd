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
-- 15-Jan-06 : Bugfix for writing SCON Register in mode 0

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity T51_UART is
	generic(
		FastCount	: integer := 0;
		tristate  : integer := 1
	);
	port(
		Clk			: in std_logic;
		Rst_n		: in std_logic;
		UseR2		: in std_logic;
		UseT2		: in std_logic;
		BaudC2		: in std_logic;
		BaudC1		: in std_logic;
		SC_Sel		: in std_logic;
		SB_Sel		: in std_logic;
		SC_Wr		: in std_logic;
		SB_Wr		: in std_logic;
		SMOD		: in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		Data_Out	: out std_logic_vector(7 downto 0);
		RXD			: in std_logic;
		RXD_IsO		: out std_logic;
		RXD_O		: out std_logic;
		TXD			: out std_logic;
		RI			: out std_logic;
		TI			: out std_logic
	);
end T51_UART;

architecture rtl of T51_UART is

	signal	SCON			: std_logic_vector(7 downto 0);
	signal	SBUF			: std_logic_vector(7 downto 0);

	signal	Baud16R_i		: std_logic;
	signal	Baud16T_i		: std_logic;
	signal	BaudC1_g		: std_logic;
	signal	BaudFix			: std_logic;

	signal	Bit_Phase		: unsigned(3 downto 0);
	signal	RX_Filtered		: std_logic;
	signal	RX_ShiftReg		: std_logic_vector(8 downto 0);
	signal	RX_Bit_Cnt		: integer range 0 to 11;
	signal	RX_Shifting		: std_logic;
--	signal	Overflow_t		: std_logic;

	signal	TXD_i			: std_logic;
	signal	TX_Tick			: std_logic;
	signal	TX_Start		: std_logic;
	signal	TX_Shifting		: std_logic;
	signal	TX_Data			: std_logic_vector(7 downto 0);
	signal	TX_ShiftReg		: std_logic_vector(8 downto 0);
	signal	TX_Bit_Cnt		: integer range 0 to 11;

	signal	Tick6			: std_logic;

begin

	-- Registers
	tristate_mux: if tristate/=0 generate
  	Data_Out <= SCON when SC_Sel = '1' else "ZZZZZZZZ";
  	Data_Out <= SBUF when SB_Sel = '1' else "ZZZZZZZZ";
  end generate;
	
	std_mux: if tristate=0 generate
  	Data_Out <= SCON when SC_Sel = '1' else 
  	            SBUF when SB_Sel = '1' else 
  	            (others =>'-');	
	end generate;
	
	process (Rst_n, Clk)
	begin
		if Rst_n = '0' then
			SCON(7 downto 3) <= "00000";
		elsif Clk'event and Clk = '1' then
			if SC_Wr = '1' then
				SCON(7 downto 3) <= Data_In(7 downto 3);
			end if;
		end if;
	end process;

	Baud16T_i <= (UseT2 and BaudC2) or (not UseT2 and BaudC1 and BaudC1_g) when SCON(6) = '1' else 
	             BaudFix;
	Baud16R_i <= (UseR2 and BaudC2) or (not UseR2 and BaudC1 and BaudC1_g) when SCON(6) = '1' else 
	             BaudFix;

	-- Baud x 16 clock generator
	process (Clk, Rst_n)
		variable Baud_Cnt : unsigned(5 downto 0);
	begin
		if Rst_n = '0' then
			Baud_Cnt := "000000";
			BaudFix <= '0';
			BaudC1_g <= '0';
		elsif Clk'event and Clk='1' then
			BaudFix <= '0';
			if SMOD = '0' and BaudC1 = '1' then
				BaudC1_g <= not BaudC1_g;
		  elsif SMOD = '1' then
		    BaudC1_g <= '1';
			end if;
			if Baud_Cnt(4 downto 0) = "11111" and (SMOD = '1' or Baud_Cnt(5) = '1') then
				BaudFix <= '1';
			end if;
			Baud_Cnt := Baud_Cnt - 1;
		end if;
	end process;

	-- Input filter
	process (Clk, Rst_n)
		variable Samples : std_logic_vector(1 downto 0);
	begin
		if Rst_n = '0' then
			Samples := "11";
			RX_Filtered <= '1';
		elsif Clk'event and Clk = '1' then
			if Baud16R_i = '1' then
				Samples(1) := Samples(0);
				Samples(0) := RXD;
			end if;
			if Samples = "00" then
				RX_Filtered <= '0';
			end if;
			if Samples = "11" then
				RX_Filtered <= '1';
			end if;
		end if;
	end process;

	-- Receive state machine
	RI <= SCON(0);
	process (Clk, Rst_n)
	begin
		if Rst_n = '0' then
			SCON(0) <= '0';
			SCON(2) <= '0';
			SBUF <= "00000000";
			Bit_Phase <= "0000";
			RX_ShiftReg(8 downto 0) <= "000000000";
			RX_Bit_Cnt <= 0;
			RX_Shifting <= '0';
		elsif Clk'event and Clk = '1' then
			if SC_Wr = '1' then
				SCON(0) <= Data_In(0);
				SCON(2) <= Data_In(2);
--				RX_Shifting <= '0';
			end if;
			if SCON(7 downto 6) /= "00" then
        RX_Shifting <= '0';
      end if;
			if SCON(7 downto 6) = "00" and Tick6 = '1' and (TXD_i = '0' or RX_Bit_Cnt = 0) then
				if SCON(4) = '1' and SCON(0) = '0' and RX_Bit_Cnt = 0 then
					RX_Shifting <= '1';
					RX_Bit_Cnt <= 1;
				elsif RX_Bit_Cnt /= 0 then
					if RX_Bit_Cnt = 8 then
						RX_Shifting <= '0';
						SCON(0) <= '1';
						SBUF(6 downto 0) <= RX_ShiftReg(7 downto 1);
						SBUF(7) <= RX_Filtered;
						RX_Bit_Cnt <= 0;
					else
						RX_ShiftReg(7 downto 0) <= RX_ShiftReg(8 downto 1);
						RX_ShiftReg(7) <= RX_Filtered;
						RX_Bit_Cnt <= RX_Bit_Cnt + 1;
					end if;
				end if;
			elsif Baud16R_i = '1' and SCON(4) = '1' then
				if RX_Bit_Cnt = 0 and (RX_Filtered = '1' or Bit_Phase = "0111") then
					Bit_Phase <= "0000";
				else
					Bit_Phase <= Bit_Phase + 1;
				end if;
				if RX_Bit_Cnt = 0 then
					if Bit_Phase = "0111" then
						RX_Bit_Cnt <= RX_Bit_Cnt + 1;
					end if;
				elsif Bit_Phase = "1111" then
					RX_Bit_Cnt <= RX_Bit_Cnt + 1;
					if (SCON(7) = '0' and RX_Bit_Cnt = 9) or
						(SCON(7) = '1' and RX_Bit_Cnt = 10) then -- Stop bit
						RX_Bit_Cnt <= 0;
						if not (SCON(5) = '1' and RX_ShiftReg(8) = '0') then
							SCON(0) <= '1';
						end if;
						if SCON(7 downto 5) = "010" then
							SCON(2) <= RX_Filtered;
						end if;
						if SCON(7) = '1' then
							SCON(2) <= RX_ShiftReg(8);
						end if;
						SBUF <= RX_ShiftReg(7 downto 0);
					else
						RX_ShiftReg(7 downto 0) <= RX_ShiftReg(8 downto 1);
						if SCON(7) = '1' then
							RX_ShiftReg(8) <= RX_Filtered;
						else
							RX_ShiftReg(7) <= RX_Filtered;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Transmit bit tick
	process (Clk, Rst_n)
		variable TX_Cnt : unsigned(3 downto 0);
	begin
		if Rst_n = '0' then
			TX_Cnt := "0000";
			TX_Tick <= '0';
		elsif Clk'event and Clk = '1' then
			TX_Tick <= '0';
			if Baud16T_i = '1' then
				if TX_Cnt = "1111" then
					TX_Tick <= '1';
				end if;
				TX_Cnt := TX_Cnt + 1;
			end if;
		end if;
	end process;

	-- Transmit state machine
	RXD_IsO <= TX_Shifting;
	TI <= SCON(1);
	TXD <= TXD_i;
	process (Clk, Rst_n)
	begin
		if Rst_n = '0' then
			SCON(1) <= '0';
			TX_Bit_Cnt <= 0;
			TX_ShiftReg <= (others => '0');
			TX_Data <= (others => '0');
			TX_Start <= '0';
			TX_Shifting <= '0';
			TXD_i <= '1';
			RXD_O <= '1';
		elsif Clk'event and Clk = '1' then
			if SC_Wr = '1' then
				SCON(1) <= Data_In(1);
--				TX_Shifting <= '0';
			end if;
			if SB_Wr = '1' then
				TX_Data <= Data_In;
				TX_Start <= '1';
			end if;
			if SCON(7 downto 6) /= "00" then
			  TX_Shifting <= '0';
			end if;
			if Tick6 = '1' and (RX_Shifting = '1' or TX_Shifting = '1') then
				TXD_i <= not TXD_i;
			end if;
			if SCON(7 downto 6) = "00" and Tick6 = '1' and (TXD_i = '0' or TX_Bit_Cnt = 0) then
				if TX_Start = '1' and TX_Bit_Cnt = 0 then
					TX_ShiftReg(6 downto 0) <= TX_Data(7 downto 1);
					TX_Shifting <= '1';
					TX_Bit_Cnt <= 1;
					TX_Start <= '0';
					RXD_O <= TX_Data(0);
				elsif TX_Bit_Cnt /= 0 then
					if TX_Bit_Cnt = 8 then
						TX_Shifting <= '0';
						SCON(1) <= '1';
						RXD_O <= '1';
						TX_Bit_Cnt <= 0;
					else
						RXD_O <= TX_ShiftReg(0);
--						SCON(1) <= '1';
						TX_Bit_Cnt <= TX_Bit_Cnt + 1;
					end if;
					TX_ShiftReg(7 downto 0) <= TX_ShiftReg(8 downto 1);
				end if;
			elsif TX_Tick = '1' then
				case TX_Bit_Cnt is
				when 0 =>
					if TX_Start = '1' then
						TX_Bit_Cnt <= 1;
					end if;
					TXD_i <= '1';
				when 1 => -- Start bit
					TX_ShiftReg(7 downto 0) <= TX_Data;
					TX_ShiftReg(8) <= SCON(3);
					TX_Start <= '0';
					TXD_i <= '0';
					TX_Bit_Cnt <= TX_Bit_Cnt + 1;
				when others =>
					TX_Bit_Cnt <= TX_Bit_Cnt + 1;
					if SCON(7) = '1' then
						if TX_Bit_Cnt = 10 then
							TX_Bit_Cnt <= 0;
							SCON(1) <= '1';
						end if;
					else
						if TX_Bit_Cnt = 9 then
							TX_Bit_Cnt <= 0;
							SCON(1) <= '1';
						end if;
					end if;
					TXD_i <= TX_ShiftReg(0);
					TX_ShiftReg(7 downto 0) <= TX_ShiftReg(8 downto 1);
				end case;
			end if;
		end if;
	end process;

	-- Tick generator
	process (Clk, Rst_n)
		variable Prescaler : unsigned(2 downto 0);
	begin
		if Rst_n = '0' then
			Prescaler := (others => '0');
			Tick6 <= '0';
		elsif Clk'event and Clk='1' then
			Tick6 <= '0';
			if Prescaler = "101" then
				Prescaler := "000";
				Tick6 <= '1';
			else
				Prescaler := Prescaler + 1;
			end if;
			if FastCount/=0 then
				Tick6 <= '1';
			end if;
		end if;
	end process;

end;
