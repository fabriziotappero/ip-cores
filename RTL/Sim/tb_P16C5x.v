///////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2008-2013 by Michael A. Morris, dba M. A. Morris & Associates
//
//  All rights reserved. The source code contained herein is publicly released
//  under the terms and conditions of the GNU Lesser Public License. No part of
//  this source code may be reproduced or transmitted in any form or by any
//  means, electronic or mechanical, including photocopying, recording, or any
//  information storage and retrieval system in violation of the license under
//  which the source code is released.
//
//  The source code contained herein is free; it may be redistributed and/or 
//  modified in accordance with the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either version 2.1 of
//  the GNU Lesser General Public License, or any later version.
//
//  The source code contained herein is freely released WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
//  PARTICULAR PURPOSE. (Refer to the GNU Lesser General Public License for
//  more details.)
//
//  A copy of the GNU Lesser General Public License should have been received
//  along with the source code contained herein; if not, a copy can be obtained
//  by writing to:
//
//  Free Software Foundation, Inc.
//  51 Franklin Street, Fifth Floor
//  Boston, MA  02110-1301 USA
//
//  Further, no use of this source code is permitted in any form or means
//  without inclusion of this banner prominently in any derived works. 
//
//  Michael A. Morris
//  Huntsville, AL
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris
//
// Create Date:     11:48:46 02/18/2008
// Design Name:     PIC16C5x
// Module Name:     C:/ISEProjects/ISE10.1i/P16C5x/tb_PIC16C5x.v
// Project Name:    PIC16C5x
// Target Device:   Spartan-II  
// Tool versions:   ISEWebPACK 10.1i SP3  
//
// Description: Verilog Test Fixture created by ISE for module: PIC16C5x. Test
//              program used to verify the execution engine. Test program uses
//              all of the instructions in the PIC16C5x instructions. Program
//              memory address range is not explicitly tested.
//
// Dependencies:	P16C5x.v 
//
// Revision: 
//
// 	0.01 	08B17	MAM	    File Created
//
//  1.00    13F15   MAM     Modified to support P16C5x implementation.
//
// Additional Comments: 
//
///////////////////////////////////////////////////////////////////////////////

module tb_P16C5x_v;

	// UUT Module Ports
	reg     POR;

	reg     Clk;
	reg     ClkEn;

	wire    [11:0] PC;
	reg     [11:0] ROM;

	reg     MCLR;
	reg     T0CKI;
	reg     WDTE;

	wire    WE_TRISA;
    wire    WE_TRISB;
    wire    WE_TRISC;
	wire    WE_PORTA;
    wire    WE_PORTB;
    wire    WE_PORTC;
    wire    RE_PORTA;
    wire    RE_PORTB;
    wire    RE_PORTC;
    
    wire    [7:0] IO_DO;
    reg     [7:0] IO_DI;

	// UUT Module Test Ports
    
    wire    Rst;
    
    wire    [5:0] OPTION;

    wire    [11:0] IR;
    wire    [ 9:0] dIR;
	wire    [11:0] ALU_Op;
	wire    [ 8:0] KI;
	wire    Err;
	
	wire    Skip;

 	wire    [11:0] TOS;
	wire    [11:0] NOS;

	wire    [7:0] W;

	wire    [6:0] FA;
	wire    [7:0] DO;
	wire    [7:0] DI;

	wire    [7:0] TMR0;
	wire    [7:0] FSR;
	wire    [7:0] STATUS;
	
    wire    T0CKI_Pls;
	
    wire    WDTClr;
	wire    [9:0] WDT;
	wire    WDT_TC;
	wire    WDT_TO;
	
    wire    [7:0] PSCntr;
	wire    PSC_Pls;
    
	// Instantiate the Unit Under Test (UUT)

	P16C5x  #(
                .pWDT_Size(10)
            ) uut (
                .POR(POR), 
                .Clk(Clk), 
                .ClkEn(ClkEn), 

                .MCLR(MCLR), 
                .T0CKI(T0CKI), 

                .WDTE(WDTE),
                
                .PC(PC), 
                .ROM(ROM), 
                
                .WE_TRISA(WE_TRISA), 
                .WE_TRISB(WE_TRISB), 
                .WE_TRISC(WE_TRISC), 
                .WE_PORTA(WE_PORTA), 
                .WE_PORTB(WE_PORTB), 
                .WE_PORTC(WE_PORTC), 
                .RE_PORTA(RE_PORTA), 
                .RE_PORTB(RE_PORTB), 
                .RE_PORTC(RE_PORTC),
                .IO_DO(IO_DO),
                .IO_DI(IO_DI),
                
                .Rst(Rst),
                
                .OPTION(OPTION), 

                .IR(IR),
                .dIR(dIR), 
                .ALU_Op(ALU_Op), 
                .KI(KI), 
                .Err(Err), 

                .Skip(Skip), 

                .TOS(TOS), 
                .NOS(NOS), 
                .W(W), 
                .FA(FA), 
                .DO(DO), 
                .DI(DI), 
                .TMR0(TMR0), 
                .FSR(FSR), 
                .STATUS(STATUS), 
                .T0CKI_Pls(T0CKI_Pls), 
                .WDTClr(WDTClr), 
                .WDT(WDT), 
                .WDT_TC(WDT_TC), 
                .WDT_TO(WDT_TO), 
                .PSCntr(PSCntr), 
                .PSC_Pls(PSC_Pls)
            );

	initial begin
		// Initialize Inputs
		POR     = 1;
		Clk     = 1;
        ClkEn   = 1;
//        IR      = 0;
		IO_DI   = 0;
		MCLR    = 0;
		T0CKI   = 0;
		WDTE    = 1;

		// Wait 100 ns for global reset to finish
		#101;

        POR = 0;
//        ClkEn = 1;

        #899;
        
	end
    
    always #5 Clk = ~Clk;
    
    always @(posedge Clk)
    begin
        if(POR)
            #1 ClkEn <= 0;
        else
            #1 ClkEn <= ~ClkEn;
    end
    
    // Test Program ROM
      
//    always @(PC or POR)
    always @(posedge Clk or posedge POR)
    begin
        if(POR)
            ROM <= 12'b1010_0000_0000;                  // GOTO    0x000   ;; Reset Vector: Jump 0x000 (Start)
        else
            case(PC[11:0])
                12'h000 : ROM <= #1 12'b0111_0110_0011; // BTFSS   0x03,3  ;; Test PD (STATUS.3), if set, not SLEEP restart
                12'h001 : ROM <= #1 12'b1010_0011_0000; // GOTO    0x030   ;; SLEEP restart, continue test program
                12'h002 : ROM <= #1 12'b1100_0000_0111; // MOVLW   0x07    ;; load OPTION
                12'h003 : ROM <= #1 12'b0000_0000_0010; // OPTION
                12'h004 : ROM <= #1 12'b0000_0100_0000; // CLRW            ;; clear working register
                12'h005 : ROM <= #1 12'b0000_0000_0101; // TRISA           ;; load W into port control registers
                12'h006 : ROM <= #1 12'b0000_0000_0110; // TRISB
                12'h007 : ROM <= #1 12'b0000_0000_0111; // TRISC
                12'h008 : ROM <= #1 12'b1010_0000_1010; // GOTO    0x00A   ;; Test GOTO
                12'h009 : ROM <= #1 12'b1100_1111_1111; // MOVLW   0xFF    ;; instruction should be skipped
                12'h00A : ROM <= #1 12'b1001_0000_1101; // CALL    0x0D    ;; Test CALL
                12'h00B : ROM <= #1 12'b0000_0010_0010; // MOVWF   0x02    ;; Test Computed GOTO, Load PCL with W
                12'h00C : ROM <= #1 12'b0000_0000_0000; // NOP             ;; No Operation
                12'h00D : ROM <= #1 12'b1000_0000_1110; // RETLW   0x0E    ;; Test RETLW, return 0x0E in W
                12'h00E : ROM <= #1 12'b1100_0000_1001; // MOVLW   0x09    ;; starting RAM + 1
                12'h00F : ROM <= #1 12'b0000_0010_0100; // MOVWF   0x04    ;; indirect address register (FSR)
//
                12'h010 : ROM <= #1 12'b1100_0001_0111; // MOVLW   0x17    ;; internal RAM count - 1
                12'h011 : ROM <= #1 12'b0000_0010_1000; // MOVWF   0x08    ;; loop counter
                12'h012 : ROM <= #1 12'b0000_0100_0000; // CLRW            ;; zero working register
                12'h013 : ROM <= #1 12'b0000_0010_0000; // MOVWF   0x00    ;; clear RAM indirectly
                12'h014 : ROM <= #1 12'b0010_1010_0100; // INCF    0x04,1  ;; increment FSR
                12'h015 : ROM <= #1 12'b0010_1110_1000; // DECFSZ  0x08,1  ;; decrement loop counter
                12'h016 : ROM <= #1 12'b1010_0001_0011; // GOTO    0x013   ;; loop until loop counter == 0
                12'h017 : ROM <= #1 12'b1100_0000_1001; // MOVLW   0x09    ;; starting RAM + 1
                12'h018 : ROM <= #1 12'b0000_0010_0100; // MOVWF   0x04    ;; reload FSR
                12'h019 : ROM <= #1 12'b1100_1110_1001; // MOVLW   0xE9    ;; set loop counter to 256 - 23
                12'h01A : ROM <= #1 12'b0000_0010_1000; // MOVWF   0x08
                12'h01B : ROM <= #1 12'b0010_0000_0000; // MOVF    0x00,0  ;; read memory into W 
                12'h01C : ROM <= #1 12'b0011_1110_1000; // INCFSZ  0x08,1  ;; increment counter loop until 0
                12'h01D : ROM <= #1 12'b1010_0001_1011; // GOTO    0x01B   ;; loop    
                12'h01E : ROM <= #1 12'b0000_0000_0100; // CLRWDT          ;; clear WDT
                12'h01F : ROM <= #1 12'b0000_0110_1000; // CLRF    0x08    ;; Clear Memory Location 0x08
//
                12'h020 : ROM <= #1 12'b0010_0110_1000; // DECF    0x08,1  ;; Decrement Memory Location 0x08
                12'h021 : ROM <= #1 12'b0001_1100_1000; // ADDWF   0x08,0  ;; Add Memory Location 0x08 to W, Store in W
                12'h022 : ROM <= #1 12'b0000_1010_1000; // SUBWF   0x08,1  ;; Subtract Memory Location 0x08
                12'h023 : ROM <= #1 12'b0011_0110_1000; // RLF     0x08,1  ;; Rotate Memory Location 0x08
                12'h024 : ROM <= #1 12'b0011_0010_1000; // RRF     0x08,1  ;; Rotate Memory Location
                12'h025 : ROM <= #1 12'b1100_0110_1001; // MOVLW   0x69    ;; Load W with test pattern: W <= 0x69
                12'h026 : ROM <= #1 12'b0000_0010_1000; // MOVWF   0x08    ;; Initialize Memory with test pattern
                12'h027 : ROM <= #1 12'b0011_1010_1000; // SWAPF   0x08,1  ;; Test SWAPF: (0x08) <= 0x96 
                12'h028 : ROM <= #1 12'b0001_0010_1000; // IORWF   0x08,1  ;; Test IORWF: (0x08) <= 0x69 | 0x96 
                12'h029 : ROM <= #1 12'b0001_0110_1000; // ANDWF   0x08,1  ;; Test ANDWF: (0x08) <= 0x69 & 0xFF
                12'h02A : ROM <= #1 12'b0001_1010_1000; // XORWF   0x08,1  :: Test XORWF: (0x08) <= 0x69 ^ 0x69
                12'h02B : ROM <= #1 12'b0010_0110_1000; // COMF    0x08    ;; Test COMF:  (0x08) <= ~0x00  
                12'h02C : ROM <= #1 12'b1101_1001_0110; // IORLW   0x96    ;; Test IORLW:      W <= 0x69 | 0x96
                12'h02D : ROM <= #1 12'b1110_0110_1001; // ANDLW   0x69    ;; Test ANDLW:      W <= 0xFF & 0x69
                12'h02E : ROM <= #1 12'b1111_0110_1001; // XORLW   0x69    ;; Test XORLW:      W <= 0x69 ^ 0x69
                12'h02F : ROM <= #1 12'b0000_0000_0011; // SLEEP           ;; Stop Execution of test program: HALT
//
                12'h030 : ROM <= #1 12'b0000_0000_0100; // CLRWDT          ;; Detected SLEEP restart, Clr WDT to reset PD
                12'h031 : ROM <= #1 12'b0110_0110_0011; // BTFSC   0x03,3  ;; Check STATUS.3, skip if ~PD clear
                12'h032 : ROM <= #1 12'b1010_0011_0100; // GOTO    0x034   ;; ~PD is set, CLRWDT cleared PD
                12'h033 : ROM <= #1 12'b1010_0011_0011; // GOTO    0x033   ;; ERROR: hold here on error
                12'h034 : ROM <= #1 12'b1100_0001_0000; // MOVLW   0x10    ;; Load FSR with non-banked RAM address
                12'h035 : ROM <= #1 12'b0000_0010_0100; // MOVWF   0x04    ;; Initialize FSR for Bit Processor Tests
                12'h036 : ROM <= #1 12'b0000_0110_0000; // CLRF    0x00    ;; Clear non-banked RAM location using INDF
                12'h037 : ROM <= #1 12'b0101_0000_0011; // BSF     0x03,0  ;; Set   STATUS.0 (C) bit 
                12'h038 : ROM <= #1 12'b0100_0010_0011; // BCF     0x03,1  ;; Clear STATUS.1 (DC) bit
                12'h039 : ROM <= #1 12'b0100_0100_0011; // BCF     0x03,2  ;; Clear STATUS.2 (Z) bit
                12'h03A : ROM <= #1 12'b0010_0000_0011; // MOVF    0x03,0  ;; Load W with STATUS
                12'h03B : ROM <= #1 12'b0011_0000_0000; // RRF     0x00,0  ;; Rotate Right RAM location: C <= 0,      W <= 0x80
                12'h03C : ROM <= #1 12'b0011_0110_0000; // RLF     0x00,0  ;; Rotate Left  RAM location: C <= 0, (INDF) <= 0x00
                12'h03D : ROM <= #1 12'b0000_0010_0000; // MOVWF   0x00    ;; Write result back to RAM: (INDF) <= 0x80
                12'h03E : ROM <= #1 12'b0000_0010_0001; // MOVWF   0x01    ;; Write to TMR0, clear Prescaler
                12'h03F : ROM <= #1 12'b1010_0100_0000; // GOTO    0x040   ;; Restart Program
//
                12'h040 : ROM <= #1 12'b0000_0000_0100; // CLRWDT          ;; Detected SLEEP restart, Clr WDT to reset PD
                12'h041 : ROM <= #1 12'b1100_1010_1010; // MOVLW   0xAA    ;; Load W with 0xAA
                12'h042 : ROM <= #1 12'b0000_0010_0101; // MOVWF   0x05    ;; WE_PortA
                12'h043 : ROM <= #1 12'b0000_0010_0110; // MOVWF   0x06    ;; WE_PortB
                12'h044 : ROM <= #1 12'b0000_0010_0111; // MOVWF   0x07    ;; WE_PortC
                12'h045 : ROM <= #1 12'b0010_0000_0101; // MOVF    0x05,0  ;; RE_PortA
                12'h046 : ROM <= #1 12'b0010_0000_0110; // MOVF    0x06,0  ;; RE_PortB
                12'h047 : ROM <= #1 12'b0010_0000_0111; // MOVF    0x07,0  ;; RE_PortC
                12'h048 : ROM <= #1 12'b0010_0110_0101; // COMF    0x05    ;; Complement PortA
                12'h049 : ROM <= #1 12'b0010_0110_0110; // COMF    0x06    ;; Complement PortB
                12'h04A : ROM <= #1 12'b0010_0110_0111; // COMF    0x07    ;; Complement PortC
                12'h04B : ROM <= #1 12'b0000_0110_0101; // CLRF    0x05    ;; Clear PortA
                12'h04C : ROM <= #1 12'b0000_0110_0110; // CLRF    0x06    ;; Clear PortB
                12'h04D : ROM <= #1 12'b0000_0110_0111; // CLRF    0x07    ;; Clear PortC
                12'h04E : ROM <= #1 12'b0000_0100_0000; // CLRW            ;; zero working register
                12'h04F : ROM <= #1 12'b1010_0000_0000; // GOTO    0x000   ;; Restart Program
//
                default : ROM <= #1 12'b1010_0000_0000; // GOTO    0x000   ;; Reset Vector: Jump 0x000 (Start)
            endcase
    end
    
endmodule

