/////////////////////////////////////////////////////////////////////
////                                                             ////
////  rotating unit, stays between 2 stages of FFT pipeline      ////
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
// File name            : 
// File Revision        : 
// Last modification    : Sun Sep 30 20:11:56 2007
/////////////////////////////////////////////////////////////////////
// FUNCTION: complex multiplication to the twiddle factors proper to the 64  point FFT
// PROPERTIES: 1) Has 64-clock cycle period starting with the START impulse and continuing forever
//	         2) rounding	is not used
/////////////////////////////////////////////////////////////////////

`timescale 1ps / 1ps
`include "FFT64_CONFIG.inc"	 

module ROTATOR64 (CLK ,RST,ED,START, DR,DI, DOR, DOI,RDY  );
	`USFFT64paramnb	
	`USFFT64paramnw	
	
	input RST ;
	wire RST ;
	input CLK ;
	wire CLK ;
	input ED ; //operation enable
	input [nb+1:0] DI;  //Imaginary part of data
	wire [nb+1:0]  DI ;
	input [nb+1:0]  DR ; //Real part of data
	input START ;		   //1-st Data is entered after this impulse 
	wire START ;
	
	output [nb+1:0]  DOI ; //Imaginary part of data
	wire [nb+1:0]  DOI ;
	output [nb+1:0]  DOR ; //Real part of data
	wire [nb+1:0]  DOR ;
	output RDY ;	   //repeats START impulse following the output data
	reg RDY ;		 
	

	reg [5:0] addrw;
	reg sd1,sd2;
	always	@( posedge CLK)	  //address counter for twiddle factors
		begin
			if (RST) begin
					addrw<=0;
					sd1<=0;
					sd2<=0;
				end
			else if (START && ED)  begin
					addrw[5:0]<=0;
					sd1<=START;
					sd2<=0;		 
				end
			else if (ED) 	  begin
					addrw<=addrw+1; 
					sd1<=START;
					sd2<=sd1;
					RDY<=sd2;	 
				end
		end			  

		wire signed [nw-1:0] wr,wi; //twiddle factor coefficients
	//twiddle factor ROM
	WROM64 UROM( .ADDR(addrw),	.WR(wr),.WI(wi) );	
		
		
	reg signed [nb+1 : 0] drd,did;
	reg signed [nw-1 : 0] wrd,wid;
	wire signed [nw+nb+1 : 0] drri,drii,diri,diii;
	reg signed [nb+2:0] drr,dri,dir,dii,dwr,dwi;
	
	assign  	drri=drd*wrd;  
	assign	diri=did*wrd;  
	assign	drii=drd*wid;
	assign	diii=did*wid;  
	
	always @(posedge CLK)	 //complex multiplier	 
		begin
			if (ED) begin	
					drd<=DR;
					did<=DI;
					wrd<=wr;
					wid<=wi;
					drr<=drri[nw+nb+1 :nw-1]; //msbs of multiplications are stored
					dri<=drii[nw+nb+1 : nw-1];
					dir<=diri[nw+nb+1 : nw-1];
					dii<=diii[nw+nb+1 : nw-1];
					dwr<=drr - dii;				
					dwi<=dri + dir;  
				end	 
		end 		
	assign DOR=dwr[nb+2:1];       
	assign DOI=dwi[nb+2 :1];
	
endmodule
