/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES RCON Block                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
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


`timescale 1 ns/1 ps

module aes_rcon(clk, kld,out,out2);

input		clk;
input		kld;

output reg  [7:0] out,out2;

reg	[3:0]	rcnt_reg;
wire	[3:0]	rcnt_next;


assign rcnt_next = (kld) ? 0 : rcnt_reg+2;


always @*
begin
		out  = kld ? 8'h01:frcon(rcnt_next-1);
		out2 = kld ? 8'h01:frcon(rcnt_next); 
end		 


always @(posedge clk)
begin

		rcnt_reg <= rcnt_next;
/*		$strobe($time,": out is %h, out2 is %h\n",out,out2);
*/	
end	



function [7:0]	frcon;
input	[3:0]	i;
case(i)	// synopsys parallel_case
   4'h0: frcon=8'h01;		//1
   4'h1: frcon=8'h02;		//x
   4'h2: frcon=8'h04;		//x^2
   4'h3: frcon=8'h08;		//x^3
   4'h4: frcon=8'h10;		//x^4
   4'h5: frcon=8'h20;		//x^5
   4'h6: frcon=8'h40;		//x^6
   4'h7: frcon=8'h80;		//x^7
   4'h8: frcon=8'h1b;		//x^8
   4'h9: frcon=8'h36;		//x^9
   default: frcon=8'h00;
endcase
endfunction

endmodule
