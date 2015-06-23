/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FFT/IFFT 128 points transform                              ////
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
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
// DESCRIPTION	:	Normalization unit
// FUNCTION:	 	shifting left up to 3 bits
//	FILES:		    	CNORM.v
//  PROPERTIES: 1) shifting left up to 3 bits controlled by the 2-bit code SHIFT
//						  	2) Is registered
//							3) Overflow detector detects the overflow event 
//                          by the given shift condition. The detector is zeroed by the START signal
//                         4) RDY is the START signal delayed to a single clock cycle
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// File        : 
// Generated   : 
//
// Description : 
//
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ps		 
`include "FFT128_CONFIG.inc"	 

module CNORM_1 ( CLK ,ED ,START ,DR ,DI ,SHIFT ,OVF ,RDY ,DOR ,DOI );
	`FFT128paramnb	
	
	output OVF ;
	reg OVF ;
	output RDY ;
	reg RDY ;
	output [nb+1:0] DOR ;
	wire [nb+1:0] DOR ;
	output [nb+1:0] DOI ;
	wire [nb+1:0] DOI ;
	
	input CLK ;
	wire CLK ;
	input ED ;
	wire ED ;
	input START ;
	wire START ;
	input [nb+2:0] DR ;
	wire [nb+2:0] DR ;
	input [nb+2:0] DI ;
	wire [nb+2:0] DI ;
	input [1:0] SHIFT ;			  //shift left code to 0,1,2,3 bits
	wire [1:0] SHIFT ;
	
	wire signed [nb+2:0]	 diri,diii;
	assign diri = DR << SHIFT;
	assign diii = DI << SHIFT;	 
	
	reg [nb+2:0]	dir,dii;
	
	`ifdef FFT128round 			//rounding
	always @( posedge CLK )    begin
			if (ED)	  begin	
					if (diri[nb+2] && ~diri[0])	// <0 with LSB=00 
						dir<=diri; 
					else   dir<=diri+2; 
					if (diii[nb+2] && ~diii[0])
						dii<=diii; 
					else   dii<=diii+2; 
				end 
		end   
		
	`else								 //truncation	 
	always @( posedge CLK )    begin
			if (ED)	  begin
					dir<=diri;
					dii<=diii;
				end 
		end  
	
	
	`endif
	
	always @( posedge CLK ) 	begin
			if (ED)	  begin
					RDY<=START;
					if (START) 
						OVF<=0;
					else   
						case (SHIFT) 
							2'b01 : OVF<= (DR[nb+2] != DR[nb+1]) || (DI[nb+2] != DI[nb+1]);
							2'b10 : OVF<= (DR[nb+2] != DR[nb+1]) || (DI[nb+2] != DI[nb+1]) ||
								(DR[nb+2] != DR[nb]) || (DI[nb+2] != DI[nb]);
							2'b11 : OVF<= (DR[nb+2] != DR[nb+1]) || (DI[nb+2] != DI[nb+1])||
								(DR[nb+2] != DR[nb]) || (DI[nb+2] != DI[nb]) ||
								(DR[nb+2] != DR[nb-1]) || (DI[nb+2] != DI[nb-1]);
						endcase						
				end
		end 
	
	assign DOR= dir[nb+2:1];
	assign DOI= dii[nb+2:1];
	
endmodule
