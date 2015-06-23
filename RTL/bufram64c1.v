/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Storage Buffer                                             ////
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
// File name            : BUFRAM64C1.v
// File Revision        : 
// Last modification    : Sun Sep 30 20:11:56 2007
/////////////////////////////////////////////////////////////////////
// FUNCTION: FIFO - buffer with direct input order and 8-th inverse 
//           output order
// FILES: BUFRAM64C1.v	- 1-st,2-nd,3-d data buffer, contains:
//        RAM2x64C_1.v - dual ported synchronous RAM, contains:		
//	    RAM64.v -single ported synchronous RAM
// PROPERTIES: 1)Has the volume of 2x64 complex data
//		   2)Contains 2- port RAM and address counter
//		   3)Has 64-clock cycle period starting with the START 
//               impulse and continuing forever    
//		   4)Signal RDY precedes the 1-st correct datum output 
//               from the buffer
/////////////////////////////////////////////////////////////////////
`timescale 1 ns / 1 ps
`include "FFT64_CONFIG.inc"	 

module BUFRAM64C1 ( CLK ,RST ,ED ,START ,DR ,DI ,RDY ,DOR ,DOI );
	`USFFT64paramnb
	output RDY ;
	reg RDY ;
	output [nb-1:0] DOR ;
	wire [nb-1:0] DOR ;
	output [nb-1:0] DOI ;
	wire [nb-1:0] DOI ;
	
	input CLK ;
	wire CLK ;
	input RST ;
	wire RST ;
	input ED ;
	wire ED ;
	input START ;
	wire START ;
	input [nb-1:0] DR ;
	wire [nb-1:0] DR ;
	input [nb-1:0] DI ;
	wire [nb-1:0] DI ;
	
	wire odd, we;
	wire [5:0] addrw,addrr;
	reg [6:0] addr;
	reg [7:0] ct2;		//counter for the RDY signal		 		  
	
	always @(posedge CLK)	//   CTADDR
		begin
			if (RST) begin
					addr<=6'b000000;
					ct2<= 7'b1000001;  
				RDY<=1'b0; end
			else if (START) begin 
					addr<=6'b000000;
					ct2<= 6'b000000;  
				RDY<=1'b0;end
			else if (ED)	begin
					RDY<=1'b0;
					addr<=addr+1; 
					if (ct2!=65) 
					ct2<=ct2+1;
					if (ct2==64) 
					RDY<=1'b1;
				end 
		end
			
	
assign	addrw=	addr[5:0];
assign	odd=addr[6];	   			// signal which switches the 2 parts of the buffer
assign	addrr={addr[2 : 0], addr[5 : 3]};	  // 8-th inverse output address
assign	we = ED;	  
	
	RAM2x64C_1 #(nb)	URAM(.CLK(CLK),.ED(ED),.WE(we),.ODD(odd),
	.ADDRW(addrw),	.ADDRR(addrr),
	.DR(DR),.DI(DI),
	.DOR(DOR),	.DOI(DOI));	   
	
endmodule
