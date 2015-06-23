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

package T51_Pack is

	component T51_MD
	port(
		Clk			: in std_logic;
		ACC			: in std_logic_vector(7 downto 0);
		B			: in std_logic_vector(7 downto 0);
		Mul_Q		: out std_logic_vector(15 downto 0);
		Mul_OV		: out std_logic;
		Div_Q		: out std_logic_vector(15 downto 0);
		Div_OV		: out std_logic;
		Div_Rdy		: out std_logic
	);
	end component;

	component T51_ALU
	generic(
		tristate  : integer := 0
	);
	port(
		Clk			: in std_logic;
		Last		: in std_logic;
		OpCode		: in std_logic_vector(7 downto 0);
		ACC			: in std_logic_vector(7 downto 0);
		B			: in std_logic_vector(7 downto 0);
		IA			: in std_logic_vector(7 downto 0);
		IB			: in std_logic_vector(7 downto 0);
		Bit_Pattern	: in std_logic_vector(7 downto 0);
		CY_In		: in std_logic;
		AC_In		: in std_logic;
		ACC_Q		: out std_logic_vector(7 downto 0);
		B_Q			: out std_logic_vector(7 downto 0);
		IDCPBL_Q	: out std_logic_vector(7 downto 0);
		Div_Rdy		: out std_logic;
		CJNE		: out std_logic;
		DJNZ		: out std_logic;
		CY_Out		: out std_logic;
		AC_Out		: out std_logic;
		OV_Out		: out std_logic;
		CY_Wr		: out std_logic;
		AC_Wr		: out std_logic;
		OV_Wr		: out std_logic
	);
	end component;

	component T51_RAM
	generic(
		RAMAddressWidth : integer
	);
	port (
		Clk			: in std_logic;
		ARE			: in std_logic;
		Rst_n		: in std_logic;
		Wr			: in std_logic;
		DIn			: in std_logic_vector(7 downto 0);
		Int_AddrA	: in std_logic_vector(7 downto 0);
		Int_AddrA_r	: out std_logic_vector(7 downto 0);
		Int_AddrB	: in std_logic_vector(7 downto 0);
		Mem_A		: out std_logic_vector(7 downto 0);
		Mem_B		: out std_logic_vector(7 downto 0)
	);
	end component;
	
  component T51_RAM_Altera
	generic(
		RAMAddressWidth : integer
	);
	port (
		Clk			: in std_logic;
		ARE			: in std_logic;
		Rst_n		: in std_logic;
		Wr			: in std_logic;
		DIn			: in std_logic_vector(7 downto 0);
		Int_AddrA	: in std_logic_vector(7 downto 0);
		Int_AddrA_r	: out std_logic_vector(7 downto 0);
		Int_AddrB	: in std_logic_vector(7 downto 0);
		Mem_A		: out std_logic_vector(7 downto 0);
		Mem_B		: out std_logic_vector(7 downto 0)
	);
	end component;

	component T51
	generic(
		DualBus         : integer := 1;
		RAMAddressWidth : integer := 8;
		SecondDPTR      : integer := 0;
		t8032           : integer := 0;
		tristate        : integer := 1
	);
	port(
		Clk			     : in std_logic;
		Rst_n		     : in std_logic;
		Ready		     : in std_logic;
		ROM_Addr	   : out std_logic_vector(15 downto 0);
		ROM_Data	   : in std_logic_vector(7 downto 0);
		RAM_Addr	   : out std_logic_vector(15 downto 0);
		RAM_RData	   : in std_logic_vector(7 downto 0);
		RAM_WData	   : out std_logic_vector(7 downto 0);
		RAM_Cycle	   : out std_logic;
		RAM_Rd		   : out std_logic;
		RAM_Wr		   : out std_logic;
		Int_Trig	   : in std_logic_vector(6 downto 0);
		Int_Acc		   : out std_logic_vector(6 downto 0);
		SFR_Rd_RMW	 : out std_logic;
		SFR_Wr		   : out std_logic;
		SFR_Addr	   : out std_logic_vector(6 downto 0);
		SFR_WData	   : out std_logic_vector(7 downto 0);
		SFR_RData_in : in  std_logic_vector(7 downto 0);
		IRAM_Wr      : out std_logic;
		IRAM_Addr	   : out std_logic_vector(7 downto 0);
		IRAM_WData   : out std_logic_vector(7 downto 0)
	);
	end component;

	component T51_Glue
	generic(
		tristate  : integer := 1
	);
	port(
		Clk			: in std_logic;
		Rst_n		: in std_logic;
		INT0		: in std_logic;
		INT1		: in std_logic;
		RI			: in std_logic;
		TI			: in std_logic;
		OF0			: in std_logic;
		OF1			: in std_logic;
		OF2			: in std_logic;
		IO_Wr		: in std_logic;
		IO_Addr		: in std_logic_vector(6 downto 0);
		IO_Addr_r	: in std_logic_vector(6 downto 0);
		IO_WData	: in std_logic_vector(7 downto 0);
		IO_RData	: out std_logic_vector(7 downto 0);
		Selected  : out std_logic;
		Int_Acc		: in std_logic_vector(6 downto 0);    -- Acknowledge
		R0			: out std_logic;
		R1			: out std_logic;
		SMOD		: out std_logic;
		P0_Sel		: out std_logic;
		P1_Sel		: out std_logic;
		P2_Sel		: out std_logic;
		P3_Sel		: out std_logic;
		TMOD_Sel	: out std_logic;
		TL0_Sel		: out std_logic;
		TL1_Sel		: out std_logic;
		TH0_Sel		: out std_logic;
		TH1_Sel		: out std_logic;
		T2CON_Sel	: out std_logic;
		RCAP2L_Sel	: out std_logic;
		RCAP2H_Sel	: out std_logic;
		TL2_Sel		: out std_logic;
		TH2_Sel		: out std_logic;
		SCON_Sel	: out std_logic;
		SBUF_Sel	: out std_logic;
		P0_Wr		: out std_logic;
		P1_Wr		: out std_logic;
		P2_Wr		: out std_logic;
		P3_Wr		: out std_logic;
		TMOD_Wr		: out std_logic;
		TL0_Wr		: out std_logic;
		TL1_Wr		: out std_logic;
		TH0_Wr		: out std_logic;
		TH1_Wr		: out std_logic;
		T2CON_Wr	: out std_logic;
		RCAP2L_Wr	: out std_logic;
		RCAP2H_Wr	: out std_logic;
		TL2_Wr		: out std_logic;
		TH2_Wr		: out std_logic;
		SCON_Wr		: out std_logic;
		SBUF_Wr		: out std_logic;
		Int_Trig	: out std_logic_vector(6 downto 0)
	);
	end component;

	component T51_Port
	generic(
		tristate  : integer := 1
	);
	port(
		Clk			  : in std_logic;
		Rst_n		  : in std_logic;
		Sel			  : in std_logic;
		Rd_RMW		: in std_logic;
		Wr			  : in std_logic;
		Data_In		: in std_logic_vector(7 downto 0);
		Data_Out	: out std_logic_vector(7 downto 0);
		IOPort_in : in std_logic_vector(7 downto 0);
		IOPort_out : out std_logic_vector(7 downto 0)
	);
	end component;

	component T51_TC01
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
	end component;

	component T51_TC2
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
	end component;

	component T51_UART
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
	end component;

	procedure AddSub(A : std_logic_vector;
					B : std_logic_vector;
					Sub : std_logic;
					Carry_In : std_logic;
					signal Res : out std_logic_vector;
					signal Carry : out std_logic);

end T51_Pack;

package body T51_Pack is

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
