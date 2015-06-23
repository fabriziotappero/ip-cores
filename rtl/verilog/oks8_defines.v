//                              -*- Mode: Verilog -*-
// Filename        : oks8_defines.v
// Description     : OKS8 Defines
// Author          : Jian Li
// Created On      : Sat Jan 07 09:09:49 2006
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

/*
 * Copyright (C) 2006 to Jian Li
 * Contact: kongzilee@yahoo.com.cn
 * 
 * This source file may be used and distributed without restriction
 * provided that this copyright statement is not removed from the file
 * and that any derivative works contain the original copyright notice
 * and the associated disclaimer.
 * 
 * THIS SOFTWARE IS PROVIDE "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
 * SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

`ifndef DEFINED

// =====================================================================
// EDITABLE/CONFIGURABLE DEFINES
// =====================================================================

//
// VENDOR for RAMS
// VENDOR_FPGA = Leave it to synthesis tool to decide
`define VENDOR_FPGA

// =====================================================================
// MISC DEFINES ** DO NOT EDIT **
// =====================================================================
`define DAT_Z		8'hZZ

// =====================================================================
// ALU Internal Operation Codes
// Selection mode for the correct ALU operations
// =====================================================================
`define ALU_AND		4'b0100		// AND/TM
`define ALU_IOR		4'b0101		// IOR
`define ALU_XOR		4'b0110		// XOR/COM(COM is XOR 0xFF)
`define ALU_TCM		4'b0111		// TCM
`define ALU_SRA		4'b0000		// SRA
`define ALU_LDCX	4'b0001		// LDCD(I)/LDED(I)
`define ALU_JP		4'b0010		// JP
`define ALU_NON		4'b0011		// NON

`define ALU_ADD		4'b1000		// ADD/DEC
`define ALU_ADC		4'b1001		// ADD+C
`define ALU_SUB		4'b1010		// SUB/INC
`define ALU_SBC		4'b1011		// SUB-C
`define ALU_RR		4'b1100		// RR
`define ALU_RRC		4'b1101		// RRC
`define ALU_RL		4'b1110		// RL
`define ALU_RLC		4'b1111		// RLC

// 
// SOURCE OPERAND SOURCE
// Used to indicate Source operand source
`define SRC_DA		3'b100		// DA
`define SRC_R		3'b101		// r/R
`define SRC_IR		3'b110		// ir/IR/x[r]
`define SRC_IRR		3'b111		// irr/IRR/XS[rr]/XL[rr]
`define SRC_IM		3'b000		// IM/NONE
`define SRC_RET		3'b001		// RET
`define SRC_POP		3'b010		// POP
`define SRC_IRET	3'b011		// IRET

// 
// DESTINATION OPERAND SOURCE
// Used to indicate destination operand source
`define DST_DA		3'b100		// DA
`define DST_R		3'b101		// r/R
`define DST_IR		3'b110		// ir/IR/x[r]
`define DST_IRR		3'b111		// irr/IRR/XS[rr]/XL[rr]

`define DST_NON		3'b000		// NONE/RA
`define DST_R2		3'b001		// R2

`define DST_PUSH	3'b010		// PUSH
`define DST_CALL	3'b011		// CALL

//
// STATUS AFFECTEd
// Used to indicate which Flags are affected
`define STS_NON		2'b00
`define STS_ZS0		2'b01
`define STS_ZSV		2'b10
`define STS_ALL		2'b11

// =====================================================================
// VECTORS ** DO NOT EDIT **
// Various Program and Data Address pointers.
// Also used to decode standard internal registers.
// =====================================================================
`define V_FLAGS		8'hD5
`define V_SP		8'hD9
`define V_SYM		8'hDF
`define V_RST		13'h0100

// =====================================================================
// WIDTH DEFINES ** DO NOT EDIT **
// =====================================================================
`define W_DATA		5'd8
`define W_INST		5'd13

// *** DEFINED ***
`define DEFINED

`endif
