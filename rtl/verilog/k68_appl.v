//                              -*- Mode: Verilog -*-
// Filename        : k68_appl.v
// Description     : K68 uController RISC Application
// Author          : Shawn Tan
// Created On      : Tue Mar 25 16:19:58 2003
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 to Shawn Tan Ser Ngiap.                  ////
////                       shawn.tan@aeste.net                   ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
//
// Xilinx specific implementation successful on a Spartan2-200
//
// You should write your own k68_appl layer depending on application.
// For the example application, it instantiates internal XILINX ram
// for both ROM and RAM. We use the INIT_XX specification in the UCF
// file to define the contents of the ROM with our software.
//
// To do this, you'll need to use the software splitrom to get the
// values to put into the UCF file. Refer to the documentation for
// more information.
//
// You can also include any other peripherals here that are not in
// the main core. Any modifications to the core, should be made at
// k68_cpu and below. Any additional internal components should be
// added to the k68_soc. Any extra peripherals should be added to
// k68_appl.
//
////////////////////////////////////////////////////////////////////

`include "k68_defines.v"

module k68_appl (/*AUTOARG*/
   // Outputs
   tx_o, rts_o, clk_o, dbg_o, 
   // Inputs
   clk_i, rst_i, int_i, rx_i, cts_i
   ) ;

   parameter aw = `k68_ADDR_W;
   parameter dw = `k68_DATA_W;

   input clk_i,rst_i;
   input [2:0] 	   int_i;
   
   wire [aw-1:0] add_o;
   wire [dw-1:0] m_dat_i;
   wire [dw-1:0] dat_o;
   wire [dw-1:0] p_dat_i;
   wire [dw-1:0] dat_i;
   wire 	 we_o;
   
   input [1:0] 	 rx_i,cts_i;
   output [1:0]  tx_o,rts_o;
   output 	 clk_o;
   wire 	 rst_o;
      
   output [7:0] dbg_o;

   reg [22:0] 	cnt;
   wire 	clk;
   assign 	clk = cnt[22];
   always @(posedge clk_i) cnt <= cnt + 1'b1;
   
   assign 	dbg_o = {add_o[9:2]};
         
   // 
   // SPROM uses Xilinx internal RAM as ROM
   // 2kB of ROM.
   // 
   RAMB4_S8 rom0(
		 .WE(1'b0),
		 .EN(1'b1),
		 .RST(1'b0),
		 .CLK(clk_o),
		 .ADDR(add_o[10:2]),
		 .DO(p_dat_i[7:0])
		 );

   RAMB4_S8 rom1(
		 .WE(1'b0),
		 .EN(1'b1),
		 .RST(1'b0),
		 .CLK(clk_o),
		 .ADDR(add_o[10:2]),
		 .DO(p_dat_i[15:8])
		 );
   
   RAMB4_S8 rom2(
		 .WE(1'b0),
		 .EN(1'b1),
		 .RST(1'b0),
		 .CLK(clk_o),
		 .ADDR(add_o[10:2]),
		 .DO(p_dat_i[23:16])
		 );
   
   RAMB4_S8 rom3(
		 .WE(1'b0),
		 .EN(1'b1),
		 .RST(1'b0),
		 .CLK(clk_o),
		 .ADDR(add_o[10:2]),
		 .DO(p_dat_i[31:24])
		 );
     
   //
   // SPRAM uses Xilinx Internal RAM
   // 2kB of RAM
   // To have more RAM, instantiate several units of RAM and map
   // the addresses.
   //
   RAMB4_S8 ram0(
		 .WE(we_o),
		 .EN(1'b1),
		 .RST(rst_o),
		 .CLK(clk_o),
		 .ADDR(add_o[10:2]),
		 .DO(m_dat_i[7:0]),
		 .DI(dat_o[7:0])
		 );

   RAMB4_S8 ram1(
		 .WE(we_o),
		 .EN(1'b1),
		 .RST(rst_o),
		 .CLK(clk_o),
		 .ADDR(add_o[10:2]),
		 .DO(m_dat_i[15:8]),
		 .DI(dat_o[15:8])
		 );
   
   RAMB4_S8 ram2(
		 .WE(we_o),
		 .EN(1'b1),
		 .RST(rst_o),
		 .CLK(clk_o),
		 .ADDR(add_o[10:2]),
		 .DO(m_dat_i[23:16]),
		 .DI(dat_o[23:16])
		 );
   
   RAMB4_S8 ram3(
		 .WE(we_o),
		 .EN(1'b1),
		 .RST(rst_o),
		 .CLK(clk_o),
		 .ADDR(add_o[10:2]),
		 .DO(m_dat_i[31:24]),
		 .DI(dat_o[31:24])
		 );


   assign dat_i = (add_o[aw-1] == 1'b1) ? m_dat_i : p_dat_i;
   
   k68_soc soc0 (
		 .add_o(add_o),
		 .dat_o(dat_o),
		 .dat_i(dat_i),
		 .we_o(we_o),
		 .tx_o(tx_o),.rts_o(rts_o),
		 .rx_i(rx_i),.cts_i(cts_i),
		 .int_i(int_i),
		 .clk_o(clk_o), .rst_o(rst_o),
		 .clk_i(clk_i), .rst_i(rst_i)
		 );
      
endmodule // k68_appl
