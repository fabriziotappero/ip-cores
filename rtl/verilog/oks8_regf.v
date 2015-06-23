//                              -*- Mode: Verilog -*-
// Filename        : oks8_regf.v
// Description     : OKS8 General Purpose Register Area
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

`include "oks8_defines.v"

// =====================================================================
// REGISTER FILE BANK
// The bank of the register file
// =====================================================================
module regf ( clk, address, en, we, din, dout );

parameter width = 7;
parameter depth = 128;

input					clk;
input [width-1:0]		address;
input					en;
input					we;
input [7:0]				din;
output [7:0]			dout;

reg [width-1:0]	addr_r;
reg [7:0]	mem[0:depth-1];

// synopsys translate_off
integer i;

initial begin
  for ( i = 0; i < depth; i = i + 1 )
	mem[i] <= 8'h00;
end
// synopsys translate_on

always @(posedge clk)
   addr_r <= address;
   
assign dout = (en) ? mem[addr_r] : `DAT_Z;

always @(posedge clk)
   if (en && we) mem[address] <= din;

endmodule

// =====================================================================
// REGISTER FILE
// The register file from 00h to CFh
// =====================================================================
module oks8_regf ( clk, address, en, we, din, dout );

input			clk;
input [7:0]		address;
input			en;
input			we;
input [7:0]		din;
output [7:0]	dout;

wire en_f1, en_f2, en_f3;

assign en_f1 = en && (!address[7]);
assign en_f2 = en && (!en_f1) && (!address[6]);
assign en_f3 = en && (!en_f1) && (!en_f2) && (!(address[5] || address[4]));

//
// 00h ~ 7Fh
//
regf #(7, 128) f1 (
  .clk		( clk ),
  .address	( address[6:0] ),
  .en		( en_f1 ),
  .we		( we ),
  .din		( din ),
  .dout		( dout )
  );

//
// 80h ~ BFh
//
regf #(6, 64) f2 (
  .clk		( clk ),
  .address	( address[5:0] ),
  .en		( en_f2 ),
  .we		( we ),
  .din		( din ),
  .dout		( dout )
  );

//
// C0h ~ CFh (R0 ~ R15)
//
regf #(4, 16) f3 (
  .clk		( clk ),
  .address	( address[3:0] ),
  .en		( en_f3 ),
  .we		( we ),
  .din		( din ),
  .dout		( dout )
  );

endmodule
