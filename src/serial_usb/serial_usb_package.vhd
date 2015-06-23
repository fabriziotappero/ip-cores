------------------------------------------------------------------
-- Universal dongle board source code
-- 
-- Copyright (C) 2006 Artec Design <jyrit@artecdesign.ee>
-- 
-- This source code is free hardware; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
-- 
-- This source code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
-- 
-- 
-- The complete text of the GNU Lesser General Public License can be found in 
-- the file 'lesser.txt'.


----------------------------------------------------------------------------------
-- Company: Artec Design Ltd
-- Engineer: Jüri Toomessoo 
-- 
-- Create Date:		16:23  23/12/2011 
-- Design Name:		UART CPU interface package
-- Module Name:		serial_usb_package 
-- Project Name:	FlexyICE
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

package serial_usb_package is

	type usbser_ctrl is record
		mode_en : std_logic;            -- enable this block
	end record;

	-- USB interface types

	type usb_out is record
		rx_oe_n : std_logic;            -- enables out data if low (next byte detected by edge / in usb chip)
		tx_wr : std_logic;              -- write performed on edge \ of signal
		txdata : std_logic_vector(7 downto 0); --bus data		
	end record;

	type usb_in is record
		tx_empty_n : std_logic;         -- tx fifo empty (redy for new data if low)
		rx_full_n : std_logic;          -- rx fifo empty (data redy if low)
		rxdata : std_logic_vector(7 downto 0); --bus data		
	end record;

	--UART register descriptions


	--Interrupt Enable Register (IER)
	constant SEL_IER_RXDATA_INT : natural := 0; --Enable Received Data Available Interrupt
	constant SEL_IER_TXEMPY_INT : natural := 1; --Enable Transmitter Holding Register Empty Interrupt
	constant SEL_IER_RXLINE_INT : natural := 2; --Enable Receiver Line Status Interrupt
	constant SEL_IER_MODEM_INT  : natural := 3; --Enable Modem Status Interrupt
	--SEL_IER bit 7 downto 4  --Reserved
	type uart_int_ena is record
		reg : std_logic_vector(7 downto 0); --Register
	end record;

	--Interrupt Identification Register (IIR)
	constant SEL_IIR_PENDING_N : natural := 0; -- No Interrupt Pending when set to '1'
	subtype SEL_IIR_TYPE is natural range 3 downto 1; --
	constant VAL_IIR_TYPE_MODEM     : std_logic_vector(2 downto 0) := "000"; -- Modem Status Interrupt 
	constant VAL_IIR_TYPE_TXEMPTY   : std_logic_vector(2 downto 0) := "001"; -- Transmitter Holding Register Empty Interrupt
	constant VAL_IIR_TYPE_RXDATA    : std_logic_vector(2 downto 0) := "010"; -- Received Data Available Interrupt
	constant VAL_IIR_TYPE_RXLINE    : std_logic_vector(2 downto 0) := "011"; -- Receiver Line Status Interrupt
	constant SEL_IIR_TYPE_PENDING_N : std_logic_vector(2 downto 0) := "110"; -- 16550 Time-out Interrupt Pending when '1'
	-- SEL_IIR bit 4  -- Reserved 
	constant SEL_IIR_TYPE_FIFOENAB_N : natural := 5; -- 64 Byte Fifo Enabled (16750 only)
	subtype SEL_IIR_FIFO is natural range 7 downto 6; -- (16750 only)
	constant VAL_IIR_FIFO_NONE  : std_logic_vector(1 downto 0) := "00"; -- No fifo 
	constant VAL_IIR_FIFO_UNSTA : std_logic_vector(1 downto 0) := "01"; -- FIFO Enabled but Unusable 
	constant VAL_IIR_FIFO_ENAB  : std_logic_vector(1 downto 0) := "11"; -- FIFO Enabled 
	type uart_int_id is record
		reg : std_logic_vector(7 downto 0); --Register
	end record;

	--(TODO "Implement self clear for bits 1 and 2")
	-- First In / First Out Control Register (FCR) (Write only)
	constant SEL_FCR_FIFO_ENA   : natural := 0; -- Enable FIFO's on '1' (data in fifo is lost when set '0')
	constant SEL_FCR_FIFO_RXCLR : natural := 1; -- Clear Receive FIFO on '1' (Self clear bit)
	constant SEL_FCR_FIFO_TXCLR : natural := 2; -- Clear Transmit FIFO '1' (Self clear bit)
	constant SEL_FCR_DMA_MODE   : natural := 3; -- DMA Mode Select. Change status of RXRDY & TXRDY pins from mode 1 to mode 2.
	--SEL_FCR bit 4  -- Reserved 
	constant SEL_FCR_LARGEFIFO_ENA : natural := 5; -- Enable 64 Byte FIFO (16750 only)
	subtype SEL_FCR_RXINTLEVEL is natural range 7 downto 6; -- 	Interrupt Trigger Level on RX FIFO 
	constant VAL_FCR_RXINTLEVEL_1  : std_logic_vector(1 downto 0) := "00"; -- 1 Byte 
	constant VAL_FCR_RXINTLEVEL_4  : std_logic_vector(1 downto 0) := "01"; -- 4 Bytes 
	constant VAL_FCR_RXINTLEVEL_8  : std_logic_vector(1 downto 0) := "10"; -- 8 Bytes 
	constant VAL_FCR_RXINTLEVEL_14 : std_logic_vector(1 downto 0) := "11"; -- 14 Bytes
	type fifo_ctrl is record
		reg : std_logic_vector(7 downto 0); --Register
	end record;

	--Line Control Register (LCR)
	subtype SEL_LCR_WORDLEN is natural range 1 downto 0; --Word Length
	constant VAL_LCR_WORDLEN_5 : std_logic_vector(1 downto 0) := "00"; --  	5 Bits 
	constant VAL_LCR_WORDLEN_6 : std_logic_vector(1 downto 0) := "01"; --  	6 Bits 
	constant VAL_LCR_WORDLEN_7 : std_logic_vector(1 downto 0) := "10"; --  	7 Bits 
	constant VAL_LCR_WORDLEN_8 : std_logic_vector(1 downto 0) := "11"; --  	8 Bits 
	constant SEL_LCR_STOPLEN   : natural := 2; -- '0'One Stop Bit ; '1' 2 Stop bits for words of length 6,7 or 8 bits or 1.5 Stop Bits for Word lengths of 5 bits. 
	subtype SEL_LCR_PARITY is natural range 5 downto 3; --Parity Select
	constant VAL_LCR_PARITY_ODD  : std_logic_vector(2 downto 0) := "001"; --  	Odd Parity 
	constant VAL_LCR_PARITY_EVEN : std_logic_vector(2 downto 0) := "011"; --  	Even Parity 
	constant VAL_LCR_PARITY_HIGH : std_logic_vector(2 downto 0) := "101"; --  	High Parity (Sticky)
	constant VAL_LCR_PARITY_LOW  : std_logic_vector(2 downto 0) := "111"; --  	Low Parity (Sticky)
	constant SEL_LCR_BREAKENA    : natural := 6; -- 	Set Break Enable 
	constant SEL_LCR_DLAB        : natural := 7; -- 	'1' Divisor Latch Access Bit ; '0' Access to Receiver buffer, Transmitter buffer & Interrupt Enable Register 
	type line_ctrl is record
		reg : std_logic_vector(7 downto 0); --Register
	end record;
 
	-- TODO "Implement Loop back mode"
	--Modem Control Register (MCR)
	constant SEL_MCR_FTERMRDY : natural := 0; -- 	Force Data Terminal Ready
	constant SEL_MCR_FREQSND  : natural := 1; -- 	Force Request to Send
	constant SEL_MCR_AUX1     : natural := 2; -- 	Aux Output 1
	constant SEL_MCR_AUX2     : natural := 3; -- 	Aux Output 2
	constant SEL_MCR_LOOP     : natural := 4; -- 	LoopBack Mode 
	constant SEL_MCR_FLWCTRL  : natural := 5; -- 	Autoflow Control Enabled (16750 only)
	type modem_ctrl is record
		reg : std_logic_vector(7 downto 0); --Register
	end record;

	--Line Status Register (LSR)  (read only)
	constant SEL_LSR_DATARDY   : natural := 0; -- 	Data Ready TODO "Implement data ready"
	constant SEL_LSR_OVRERR    : natural := 1; -- 	Overrun Error (input reg over flow) TODO "Implement over run"
	constant SEL_LSR_PARERR    : natural := 2; -- 	Parity Error
	constant SEL_LSR_FRMERR    : natural := 3; -- 	Framing Error
	constant SEL_LSR_BREAKINT  : natural := 4; -- 	Break Interrupt 
	constant SEL_LSR_EMPTY_TXH : natural := 5; -- 	Empty Transmitter Holding Register
	constant SEL_LSR_EMPTY_DH  : natural := 6; -- 	Empty Data Holding Registers
	constant SEL_LSR_RXFIFOERR : natural := 7; -- 	Error in Received FIFO
	type line_status is record
		reg : std_logic_vector(7 downto 0); --Register
	end record;

	--Modem Status Register (MSR)
	constant SEL_MSR_CHN_CTS  : natural := 0; -- 	Delta Clear to Send (auto falloff on reg read)
	constant SEL_MSR_CHN_RDY  : natural := 1; -- 	Delta Data Set Ready (auto falloff on reg read)
	constant SEL_MSR_CHN_RING : natural := 2; -- 	Trailing Edge Ring Indicator (auto falloff on reg read)
	constant SEL_MSR_CHN_CD   : natural := 3; -- 	Delta Data Carrier Detect (auto falloff on reg read)
	constant SEL_MSR_CTC      : natural := 4; -- 	Clear To Send (signal state)
	constant SEL_MSR_RDY      : natural := 5; -- 	Data Set Ready (signal state)
	constant SEL_MSR_RING     : natural := 6; -- 	Ring Indicator (signal state)
	constant SEL_MSR_CD       : natural := 7; -- 	Carrier Detect (signal state)
	type modem_status is record
		reg : std_logic_vector(7 downto 0); --Register
	end record;

	-- Scratch Register
	type scratch is record
		reg : std_logic_vector(7 downto 0); --Register
	end record;

	type general_reg is record
		reg : std_logic_vector(7 downto 0); --Register
	end record;

	type uart_registers is record
		txhold : general_reg;           --Register (Write)	(OFS +0 DLAB=0)	--Transmitter Holding Buffer
		rxbuff : general_reg;           --Register (Read)	(OFS +0 DLAB=0)	--Receiver Buffer 
		div_low : general_reg;          --Register (R/W)	(OFS +0 DLAB=1)	--Divisor Latch Low Byte
		ier : uart_int_ena;             --Register (R/W)	(OFS +1 DLAB=0)	--Interrupt Enable Register 
		div_high : general_reg;         --Register (R/W)	(OFS +1 DLAB=1)	--Divisor Latch High Byte	
		iir : uart_int_id;              --Register (Read)	(OFS +2 DLAB=-) --Interrupt Identification Register
		fcr : fifo_ctrl;                --Register (Write)	(OFS +2 DLAB=-) --FIFO Control Register 
		lcr : line_ctrl;                --Register (R/W)	(OFS +3 DLAB=-)	--Line Control Register 	
		mcr : modem_ctrl;               --Register (R/W)	(OFS +4 DLAB=-)	--Modem Control Register	
		lsr : line_status;              --Register (Read)	(OFS +5 DLAB=-) --Line Status Register 
		msr : modem_status;             --Register (Read)	(OFS +6 DLAB=-) --Modem Status Register  
		scr : scratch;                  --Register (R/W)	(OFS +7 DLAB=-)	--Scratch Register 
	end record;

	procedure uart_reset(signal uart : out uart_registers);
	procedure fifo_reset(signal fifo : out usb_out);

	procedure set_uart_rx_int(variable uart : inout uart_registers);
	procedure clr_uart_rx_int(variable uart : inout uart_registers);

	procedure set_uart_tx_int(variable uart : inout uart_registers);
	procedure clr_uart_tx_int(variable uart : inout uart_registers);


end package serial_usb_package;
package body serial_usb_package is

	procedure fifo_reset(
		signal fifo : out usb_out) is
		variable f : usb_out;
	begin
		f.rx_oe_n:='1';
		f.tx_wr:='0';
		f.txdata:=(others=>'0');
		fifo<=f;
	end procedure fifo_reset;

	procedure uart_reset(
		signal uart : out uart_registers) is
		variable u : uart_registers;
	begin
		u.txhold.reg := x"00"; --not needed direct write possible
		u.rxbuff.reg := x"00";
		u.div_low.reg := x"00";
		u.ier.reg := x"00";		
		u.div_high.reg := x"01"; -- 115200 baud
		u.iir.reg := x"41"; --no int pending, fifo enabled but unusable		
		u.fcr.reg := x"00"; --
		u.lcr.reg := x"03"; -- set 8 bit data 1 stop no parity DLA 0
		u.mcr.reg := x"00"; --
		u.lsr.reg := x"60"; -- tx empty and rx empty flags set on reset
		u.msr.reg := x"10"; -- Clear To Send is high after reset
		u.scr.reg := x"00"; --
		uart <= u;
	end procedure uart_reset;


	procedure set_uart_rx_int(variable uart : inout uart_registers) is
		begin
			if uart.ier.reg(SEL_IER_RXDATA_INT)='1' then --int enabled
				uart.iir.reg(SEL_IIR_TYPE):=VAL_IIR_TYPE_RXDATA;
				uart.iir.reg(SEL_IIR_PENDING_N):='0'; --set int pending
			end if;					
		end procedure set_uart_rx_int;

	procedure clr_uart_rx_int(variable uart : inout uart_registers) is
		begin
			if uart.iir.reg(SEL_IIR_TYPE)=VAL_IIR_TYPE_RXDATA and uart.iir.reg(SEL_IIR_PENDING_N)='0' then --suitable int 
				uart.iir.reg(SEL_IIR_PENDING_N):='1'; --clear int pending
			end if;					
		end procedure clr_uart_rx_int;


	procedure set_uart_tx_int(variable uart : inout uart_registers) is
		begin
			if uart.ier.reg(SEL_IER_TXEMPY_INT)='1' then --int enabled
				uart.iir.reg(SEL_IIR_TYPE):=VAL_IIR_TYPE_TXEMPTY;
				uart.iir.reg(SEL_IIR_PENDING_N):='0'; --set int pending
			end if;					
		end procedure set_uart_tx_int;

	procedure clr_uart_tx_int(variable uart : inout uart_registers) is
		begin
			if uart.iir.reg(SEL_IIR_TYPE)=VAL_IIR_TYPE_TXEMPTY and uart.iir.reg(SEL_IIR_PENDING_N)='0' then --suitable int 
				uart.iir.reg(SEL_IIR_PENDING_N):='1'; --clear int pending
			end if;					
		end procedure clr_uart_tx_int;

end package body serial_usb_package;
