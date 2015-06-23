/*	MODULE: openfire bootram
	DESCRIPTION: Contains BRAM instanties loaded with the boot program

AUTHOR: 
Antonio J. Anton
Anro Ingenieros (www.anro-ingenieros.com)
aj@anro-ingenieros.com

REVISION HISTORY:
Revision 1.0, 26/03/2007
Initial release

COPYRIGHT:
Copyright (c) 2007 Antonio J. Anton

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.*/

`timescale 1ns / 1ps

// bootram is an internal 2048 x 32 bit dualport ram inside
// FPGA to let CPU boot without external resources
// this RAM is shared by program and data 

module openfire_bootram(
	rst, clk, ins_addr, ins_output,
	data_we, data_addr, data_input, data_output,
	data_sel
);

input			  rst;				// reset sincrono
input			  clk;				// reloj
input	 [10:0] ins_addr;			// 11 bit INS-ADDR
output [31:0] ins_output;		// 32 bit INSTRUCTION
input			  data_we;			// activa escritura DATA
input	 [10:0] data_addr;		// 11 bit DATA-ADDR
input  [31:0] data_input;		// 32 bit DATA-IN
output [31:0] data_output;		// 32 bit DATA-OUT
input	 [3:0]  data_sel;			// byte selector

// ------------ block ram instances -------------
RAMB16_S9_S9 MEM3(
      .DOA(ins_output[31:24]),      // Port A ins_output
      .DOB(data_output[31:24]),     // Port B data_output
      .DOPA( ),    						// Port A 1-bit Parity Output NO
      .DOPB( ),    						// Port B 1-bit Parity Output NO
      .ADDRA(ins_addr[10:0]),  		// Port A 11-bit Address Input
      .ADDRB(data_addr[10:0]),  		// Port B 11-bit Address Input
      .CLKA(clk),    					// Port A Clock
      .CLKB(clk),    					// Port B Clock
      .DIA(8'b0),      					// Port A 8-bit Data Input NO
      .DIB(data_input[31:24]),      // Port B 8-bit Data Input
      .DIPA(1'b0),    					// Port A 1-bit parity Input
      .DIPB(1'b0),    					// Port-B 1-bit parity Input
      .ENA(1'b1),      					// Port A RAM Enable Input
      .ENB(1'b1),							// PortB RAM Enable Input
      .SSRA(rst),    					// Port A Synchronous Set/Reset Input
      .SSRB(rst),    					// Port B Synchronous Set/Reset Input
      .WEA(1'b0),      					// Port A Write Enable Input NO
      .WEB(data_we & data_sel[3])	// Port B Write Enable Input
   );

RAMB16_S9_S9 MEM2(
      .DOA(ins_output[23:16]),      // Port A ins_output
      .DOB(data_output[23:16]),     // Port B data_output
      .DOPA( ),    						// Port A 1-bit Parity Output NO
      .DOPB( ),    						// Port B 1-bit Parity Output NO
      .ADDRA(ins_addr[10:0]),  		// Port A 11-bit Address Input
      .ADDRB(data_addr[10:0]),  		// Port B 11-bit Address Input
      .CLKA(clk),    					// Port A Clock
      .CLKB(clk),    					// Port B Clock
      .DIA(8'b0),      					// Port A 8-bit Data Input NO
      .DIB(data_input[23:16]),      // Port B 8-bit Data Input
      .DIPA(1'b0),    					// Port A 1-bit parity Input
      .DIPB(1'b0),    					// Port-B 1-bit parity Input
      .ENA(1'b1),      					// Port A RAM Enable Input
      .ENB(1'b1), 						// PortB RAM Enable Input
      .SSRA(rst),    					// Port A Synchronous Set/Reset Input
      .SSRB(rst),    					// Port B Synchronous Set/Reset Input
      .WEA(1'b0),      					// Port A Write Enable Input NO
      .WEB(data_we & data_sel[2])	// Port B Write Enable Input
   );

RAMB16_S9_S9 MEM1(
      .DOA(ins_output[15:8]),       // Port A ins_output
      .DOB(data_output[15:8]),      // Port B data_output
      .DOPA( ),    						// Port A 1-bit Parity Output NO
      .DOPB( ),    						// Port B 1-bit Parity Output NO
      .ADDRA(ins_addr[10:0]),  		// Port A 11-bit Address Input
      .ADDRB(data_addr[10:0]),  		// Port B 11-bit Address Input
      .CLKA(clk),    					// Port A Clock
      .CLKB(clk),    					// Port B Clock
      .DIA(8'b0),      					// Port A 8-bit Data Input NO
      .DIB(data_input[15:8]),       // Port B 8-bit Data Input
      .DIPA(1'b0),    					// Port A 1-bit parity Input
      .DIPB(1'b0),    					// Port-B 1-bit parity Input
      .ENA(1'b1),      					// Port A RAM Enable Input
      .ENB(1'b1), 						// PortB RAM Enable Input
      .SSRA(rst),    					// Port A Synchronous Set/Reset Input
      .SSRB(rst),    					// Port B Synchronous Set/Reset Input
      .WEA(1'b0),      					// Port A Write Enable Input NO
      .WEB(data_we & data_sel[1])	// Port B Write Enable Input
   );

RAMB16_S9_S9 MEM0(
      .DOA(ins_output[7:0]),        // Port A ins_output
      .DOB(data_output[7:0]),       // Port B data_output
      .DOPA( ),    						// Port A 1-bit Parity Output NO
      .DOPB( ),    						// Port B 1-bit Parity Output NO
      .ADDRA(ins_addr[10:0]),  		// Port A 11-bit Address Input
      .ADDRB(data_addr[10:0]),  		// Port B 11-bit Address Input
      .CLKA(clk),    					// Port A Clock
      .CLKB(clk),    					// Port B Clock
      .DIA(8'b0),      					// Port A 8-bit Data Input NO
      .DIB(data_input[7:0]),        // Port B 8-bit Data Input
      .DIPA(1'b0),    					// Port A 1-bit parity Input
      .DIPB(1'b0),    					// Port-B 1-bit parity Input
      .ENA(1'b1),      					// Port A RAM Enable Input
      .ENB(1'b1),							// PortB RAM Enable Input
      .SSRA(rst),    					// Port A Synchronous Set/Reset Input
      .SSRB(rst),    					// Port B Synchronous Set/Reset Input
      .WEA(1'b0),      					// Port A Write Enable Input NO
      .WEB(data_we & data_sel[0]) 	// Port B Write Enable Input
   );

// ---------------- memory content -----------------
// this macro is replaced by a series of
// defparam MEMx.INIT_yy  = 256'h{hexadecimal bytes};
// as per BIN file provided to bin2bram
//
// also de MEMx.INIT_A/B and MEMx.SRVAL_A/B are initialized
// with the 1st DWORD in the BIN file to be available at startup/reset
										  
// $DUMP_INIT_RAM

// blockram configuration and parity bits are left empty
// so default values are used

endmodule
