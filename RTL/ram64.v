/////////////////////////////////////////////////////////////////////
////                                                             ////
////  1-port synchronous RAM                                     ////
////                                                             ////
////  Authors: Anatoliy Sergienko, Volodya Lepeha                ////
////  Company: Unicore Systems http://unicore.co.ua              ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2006-2010 Unicore Systems LTD                 ////
//// www.unicore.co.ua                                           ////
//// o.uzenkov@unicore.co.ua                                     ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// THIS SOFTWARE IS PROVIDED "AS IS"                           ////
//// AND ANY EXPRESSED OR IMPLIED WARRANTIES,                    ////
//// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED                  ////
//// WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT              ////
//// AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.        ////
//// IN NO EVENT SHALL THE UNICORE SYSTEMS OR ITS                ////
//// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,            ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL            ////
//// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT         ////
//// OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,               ////
//// DATA, OR PROFITS; OR BUSINESS INTERRUPTION)                 ////
//// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,              ////
//// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING                 ////
//// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,                 ////
//// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.          ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
// Design_Version       : 1.0
// File name            : RAM64.v
// File Revision        : 
// Last modification    : Sun Sep 30 20:11:56 2007
/////////////////////////////////////////////////////////////////////
// FUNCTION: 1-port synchronous RAM
// FILES:    RAM64.v -single ported synchronous RAM
// PROPERTIES: 1) Has the volume of 64 data
//	         2) RAM is synchronous one, the read datum is outputted 
//                in 2 cycles after the address setting
//		   3) Can be substituted to any 2-port synchronous RAM 
/////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps
`include "FFT64_CONFIG.inc"	 

module RAM64 ( CLK, ED,WE ,ADDR ,DI ,DO );
	`USFFT64paramnb	
	
	output [nb-1:0] DO ;
	reg [nb-1:0] DO ;
	input CLK ;
	wire CLK ;	 
	input ED;
	input WE ;
	wire WE ;
	input [5:0] ADDR ;
	wire [5:0] ADDR ;
	input [nb-1:0] DI ;
	wire [nb-1:0] DI ;
	reg [nb-1:0] mem [63:0];
	reg [5:0] addrrd;		  
	
	always @(posedge CLK) begin
			if (ED) begin
					if (WE)		mem[ADDR] <= DI;
					addrrd <= ADDR;	         //storing the address
					DO <= mem[addrrd];	   // registering the read datum
				end	  
		end
	
	
endmodule
