--
-- AT90Sxxxx compatible microcontroller core
--
-- Version : 0221b
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

package AX_Pack is

	component AX_ALU
	port(
		Clk			: in std_logic;
		ROM_Data	: in std_logic_vector(15 downto 0);
		A			: in std_logic_vector(7 downto 0);
		B			: in std_logic_vector(7 downto 0);
		Q			: out std_logic_vector(7 downto 0);
		SREG		: in std_logic_vector(7 downto 0);
		PassB		: in std_logic;
		Skip		: in std_logic;
		Do_Other	: out std_logic;
		Z_Skip		: out std_logic;
		Status_D	: out std_logic_vector(6 downto 0);
		Status_Wr	: out std_logic_vector(6 downto 0)	-- T,H,S,V,N,Z,C
	);
	end component;

	component AX_PCS
	generic(
		HW_Stack	: boolean
	);
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		Offs_In		: in std_logic_vector(11 downto 0);
		Z			: in unsigned(15 downto 0);
		Data_In		: in std_logic_vector(7 downto 0);
		Pause		: in std_logic;
		Push		: in std_logic;
		Pop			: in std_logic;
		HRet		: in std_logic;
		LRet		: in std_logic;
		ZJmp		: in std_logic;
		RJmp		: in std_logic;
		CInt		: in std_logic_vector(3 downto 0);
		IPending	: in std_logic;
		IPush		: out std_logic;
		NPC			: out std_logic_vector(15 downto 0);
		PC			: out std_logic_vector(15 downto 0)
	);
	end component;

	component AX_DPRAM
	port(
		Clk			: in std_logic;
		Rst_n		: in std_logic;
		Wr			: in std_logic;
		Rd_Addr		: in std_logic_vector(4 downto 0);
		Wr_Addr		: in std_logic_vector(4 downto 0);
		Data_In		: in std_logic_vector(7 downto 0);
		Data_Out	: out std_logic_vector(7 downto 0)
	);
	end component;

	component AX_Reg
	generic(
		BigISet : boolean
	);
	port(
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
	end component;

	component AX_RAM
	generic(
		RAMAddressWidth : integer
	);
	port(
		Clk			: in std_logic;
		Rd_Addr		: in std_logic_vector(RAMAddressWidth downto 0);
		Wr_Addr		: in std_logic_vector(RAMAddressWidth downto 0);
		Wr			: in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		Data_Out	: out std_logic_vector(7 downto 0)
	);
	end component;

	component AX8
	generic(
		ROMAddressWidth : integer;
		RAMAddressWidth : integer;
		BigISet : boolean
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
	end component;

	component AX_Port
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		PORT_Sel	: in std_logic;
		DDR_Sel		: in std_logic;
		PIN_Sel		: in std_logic;
		Wr			: in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		Dir			: out std_logic_vector(7 downto 0);
		Port_Input	: out std_logic_vector(7 downto 0);
		Port_Output	: out std_logic_vector(7 downto 0);
		IOPort		: inout std_logic_vector(7 downto 0)
	);
	end component;

	component AX_UART
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		UDR_Sel		: in std_logic;
		USR_Sel		: in std_logic;
		UCR_Sel		: in std_logic;
		UBRR_Sel	: in std_logic;
		Rd			: in std_logic;
		Wr			: in std_logic;
		TXC_Clr		: in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		UDR			: out std_logic_vector(7 downto 0);
		USR			: out std_logic_vector(7 downto 3);
		UCR			: out std_logic_vector(7 downto 0);
		UBRR		: out std_logic_vector(7 downto 0);
		RXD			: in std_logic;
		TXD			: out std_logic;
		Int_RX		: out std_logic;
		Int_TR		: out std_logic;
		Int_TC		: out std_logic
	);
	end component;

	component AX_TC8
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		T			: in std_logic;
		TCCR_Sel	: in std_logic;
		TCNT_Sel	: in std_logic;
		Wr			: in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		TCCR		: out std_logic_vector(2 downto 0);
		TCNT		: out std_logic_vector(7 downto 0);
		Int			: out std_logic
	);
	end component;

	component AX_TC16
	port(
		Clk			: in std_logic;
		Reset_n		: in std_logic;
		T			: in std_logic;
		ICP			: in std_logic;
		TCCR_Sel	: in std_logic;
		TCNT_Sel	: in std_logic;
		OCR_Sel		: in std_logic;
		ICR_Sel		: in std_logic;
		A0			: in std_logic;
		Rd			: in std_logic;
		Wr			: in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		COM			: out std_logic_vector(1 downto 0);
		PWM			: out std_logic_vector(1 downto 0);
		CRBH		: out std_logic_vector(1 downto 0);
		CRBL		: out std_logic_vector(3 downto 0);
		TCNT		: out std_logic_vector(15 downto 0);
		IC			: out std_logic_vector(15 downto 0);
		OCR			: out std_logic_vector(15 downto 0);
		Tmp			: out std_logic_vector(15 downto 0);
		OC			: out std_logic;
		Int_TO		: out std_logic;
		Int_OC		: out std_logic;
		Int_IC		: out std_logic
	);
	end component;

	procedure AddSub(A : std_logic_vector;
					B : std_logic_vector;
					Sub : std_logic;
					Carry_In : std_logic;
					signal Res : out std_logic_vector;
					signal Carry : out std_logic);

end AX_Pack;

package body AX_Pack is

	procedure AddSub(A : std_logic_vector;
					B : std_logic_vector;
					Sub : std_logic;
					Carry_In : std_logic;
					signal Res : out std_logic_vector;
					signal Carry : out std_logic) is
		variable B_i		: unsigned(A'length downto 0);
		variable Full_Carry	: unsigned(A'length downto 0);
		variable Res_i		: unsigned(A'length downto 0);
	begin
		if Sub = '1' then
			B_i := "0" & unsigned(not B);
		else
			B_i := "0" & unsigned(B);
		end if;
		if (Sub = '1' and Carry_In = '1') or (Sub = '0' and Carry_In = '1') then
			Full_Carry := (others => '0');
			Full_Carry(0) := '1';
		else
			Full_Carry := (others => '0');
		end if;
		Res_i := unsigned("0" & A) + B_i + Full_Carry;
		Carry <= Res_i(A'length);
		Res <= std_logic_vector(Res_i(A'length - 1 downto 0));
	end;

end;
