//                              -*- Mode: Verilog -*-
// Filename        : k68_soc.v
// Description     : k68 SOC Top Level
// Author          : Shawn Tan
// Created On      : Sat Feb  8 20:58:34 2003
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

`include "k68_defines.v"

module k68_soc (/*AUTOARG*/
   // Outputs
   add_o, dat_o, we_o, tx_o, rts_o, clk_o, rst_o, 
   // Inputs
   dat_i, rst_i, clk_i, rx_i, cts_i, int_i
   ) ;
   parameter aw = `k68_ADDR_W;
   parameter dw = `k68_DATA_W;

   output [aw-1:0] add_o;
   input [dw-1:0]  dat_i;
   output [dw-1:0] dat_o;
   output 	   we_o;
   
   input 	   rst_i, clk_i;
   input [1:0] 	   rx_i,cts_i;
   output [1:0]    tx_o,rts_o;
   input [2:0] 	   int_i;
   output 	   clk_o;
   output 	   rst_o;
        
   wire 	   cs;
   wire [aw-1:0]   m_add_o;
   wire [dw-1:0]   m_dat_o;
   wire [dw-1:0]   m_dat_i;
   wire 	   m_we_o;
   wire 	   m_cs_o;
   
 	    
   wire [9:0] 	   a_dat_i, b_dat_i;
   wire 	   r_cs_o, r_we_o, a_cs_o, b_cs_o, a_we_o, b_we_o; 	    

   wire		   rst;
   wire [31:0] 	   d_dat_o,d_dat_i;
         
   assign 	   add_o = m_add_o;
   assign 	   dat_o = m_dat_o;
   assign 	   we_o = r_we_o;
 
   //
   // Arbiter
   //
   k68_arb arb0 (
		 .m_we_o(r_we_o),
		 .m_cs_o(r_cs_o),
		 .m_dat_i(dat_i),
		 
		 .a_we_o(a_we_o),
		 .a_cs_o(a_cs_o),
		 .a_dat_i(a_dat_i),

		 .b_we_o(b_we_o),
		 .b_cs_o(b_cs_o),
		 .b_dat_i(b_dat_i),
		 
		 .m_add_i(m_add_o),
		 .m_we_i(m_we_o),
		 .m_dat_o(m_dat_i),

		 .rst_i(rst_o)
		 );

   //
   // Instantiate CPU
   //
   k68_cpu cpu0(
		.add_o(m_add_o),
		.dat_o(m_dat_o),
		.dat_i(m_dat_i),
		.we_o(m_we_o),
		
		.int_i(int_i),
		.cs_o(cs),
		.clk_o(clk_o), .rst_o(rst_o),
		.clk_i(clk_i), .rst_i(rst_i)
		);


   
`ifdef k68_UART
   //
   // k68_sasc
   //

   wire [7:0] 	   brg0,brg1;
   assign 	   brg0 = `k68_div0;
   assign 	   brg1 = `k68_div1;
      
   k68_sasc uart0(
		  .tx_o(tx_o[0]),
		  .rts_o(rts_o[0]),
		  .dat_i({brg1,brg0,m_dat_o[7:0]}),
		  .dat_o(a_dat_i),
		  .cts_i(cts_i[0]),
		  .rx_i(rx_i[0]),
		  .cs_i(a_cs_o),
		  .we_i(a_we_o),
		  .clk_i(clk_o),.rst_i(rst_o)
		  );
   
   k68_sasc uart1(
		  .tx_o(tx_o[1]),
		  .rts_o(rts_o[1]),
		  .dat_i({brg1,brg0,m_dat_o[7:0]}),
		  .dat_o(b_dat_i),
		  .cts_i(cts_i[1]),
		  .rx_i(rx_i[1]),
		  .cs_i(b_cs_o),
		  .we_i(b_we_o),
		  .clk_i(clk_o),.rst_i(rst_o)
		  );
`endif
  
 
endmodule // k68_soc

/*
 *
 * Synchronous Bus Arbiter
 * Consider placing 0xFF000000 - 0xFFFFFFFF to Peripheral space
 * 
 * 0xFF000000 - GPIO
 * 0xFF010000 - UARTA
 * 0xFF020000 - UARTB
 * 0xFF030000 - DES
 * 
 * Others Reserved
 * 
 */

module k68_arb (/*AUTOARG*/
   // Outputs
   m_dat_o, m_we_o, m_cs_o, g_we_o, g_cs_o, a_we_o, a_cs_o, b_we_o, 
   b_cs_o, 
   // Inputs
   rst_i, m_add_i, m_we_i, m_dat_i, g_dat_i, a_dat_i, b_dat_i
   ) ;
   parameter aw = `k68_ADDR_W;
   parameter dw = `k68_DATA_W;
   parameter ow = `k68_OP_W;
    
   // Program Memory
   //input [dw-1:0]  p_dat_i;
   input     rst_i;
        
   // Data Memory
   output [dw-1:0] m_dat_o;
   input [aw-1:0]  m_add_i;
   input 	   m_we_i;
   reg [dw-1:0]    m_dat_o;
   
   // SPRAM
   input [dw-1:0]  m_dat_i;
   output 	   m_we_o;
   output 	   m_cs_o;
   reg 		   m_we_o, m_cs_o;
   
   // 
   // Peripherals
   //

   // GPIO PORTS
   input [15:0]    g_dat_i;
   output 	   g_we_o, g_cs_o;
   reg 		   g_we_o, g_cs_o;
   
   // UART A
   input [9:0] 	   a_dat_i;
   output 	   a_we_o, a_cs_o;
   reg 		   a_we_o, a_cs_o;
   
   // UART B
   input [9:0] 	   b_dat_i;
   output 	   b_we_o, b_cs_o;
   reg 		   b_we_o, b_cs_o;
   
   always @ ( /*AUTOSENSE*/a_dat_i or b_dat_i or g_dat_i or m_add_i
	     or m_dat_i or m_we_i or rst_i) begin
    if (rst_i) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      a_cs_o <= 0;
      a_we_o <= 0;
      b_cs_o <= 0;
      b_we_o <= 0;
      g_cs_o <= 0;
      g_we_o <= 0;
      m_cs_o <= 0;
      m_dat_o <= 0;
      m_we_o <= 0;
      // End of automatics
    end else begin // if (rst_i)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       a_cs_o <= 0;
       a_we_o <= 0;
       b_cs_o <= 0;
       b_we_o <= 0;
       g_cs_o <= 0;
       g_we_o <= 0;
       m_cs_o <= 0;
       m_dat_o <= 0;
       m_we_o <= 0;
       // End of automatics
       
      case (m_add_i[aw-1])
	1'b1:            
	  case (m_add_i[31:24])
	    8'hFF:
	      case (m_add_i[23:16])
		8'h00: begin // GPIO
		   g_cs_o <= 1'b1;
		   g_we_o <= m_we_i;
		   m_dat_o <= g_dat_i;
		end
`ifdef k68_UART
		8'h01: begin // UART A
		   a_cs_o <= 1'b1;
		   a_we_o <= m_we_i;
		   m_dat_o <= a_dat_i;
		end
		
		8'h02: begin // UART B
		   b_cs_o <= 1'b1;
		   b_we_o <= m_we_i;
		   m_dat_o <= b_dat_i;
		end
`endif
	       
		default: begin
		   /*AUTORESET*/
		   // Beginning of autoreset for uninitialized flops
		   a_cs_o <= 0;
		   a_we_o <= 0;
		   b_cs_o <= 0;
		   b_we_o <= 0;
		   g_cs_o <= 0;
		   g_we_o <= 0;
		   m_cs_o <= 0;
		   m_dat_o <= 0;
		   m_we_o <= 0;
		   // End of automatics
		end
	      endcase // case(m_add_i)
	    default: begin
	       m_we_o <= m_we_i;
	       m_cs_o <= 1'b1;
	       m_dat_o <= m_dat_i;
	    end
	  endcase // case(m_add_i[31:24])
	default:
	  case (m_add_i[1])
	    1'b1: begin
	       m_dat_o <= {m_dat_i[31:16], m_dat_i[31:16]};
	       m_we_o <= 1'b0;
	       m_cs_o <= 1'b0;
	       a_cs_o <= 1'b0;
	       b_cs_o <= 1'b0;
	       g_cs_o <= 1'b0;
	       
	    end
	    default: begin
	       m_dat_o <= {m_dat_i[15:0], m_dat_i[15:0]};
	       m_we_o <= 1'b0;
	       m_cs_o <= 1'b0;
	       a_cs_o <= 1'b0;
	       b_cs_o <= 1'b0;
	       g_cs_o <= 1'b0;
	       
	    end
	  endcase // case(m_add_i[1])
      endcase // case(m_add_i[31])
    end
   end
      
endmodule // k68_arb

