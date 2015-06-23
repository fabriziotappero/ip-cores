/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FFT/IFFT 256 points transform                              ////
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
// DESCRIPTION	:	 Testbench for the FFT256_core - FFT 256 processor
// FUNCTION:	 	  a set of 4 sine waves is inputted to the FFT processor,
//                         the results are compared with the expected waves,
//                        the square root mean error is calculated (without a root)
// FILES:			 FFT256_TB.v - this file, contains
//					  	FFT256.v - unit under test
//                    Wave_ROM256.v - rom with the test waveform, generating by 
//                    sinerom256_gen.pl   	   script
//  PROPERTIES: 1) the calculated error after ca. 12us modeling 
//									is outputted to the console	 as the note:
//   							rms error is           1 lsb
//							2)if the error is 0,1,2 then the test is OK
//							3) the customer can exchange the test selecting the 
//								different frequencies and generating the wave ROM by
//                            the script  sinerom256_gen.pl   		 	
//						   4) the proper operation can be checked by investigation
//                         of the core output waveforms
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
`include "FFT256_CONFIG.inc"	 

`timescale 1ns / 1 ps
module FFT256_tb;
	//Parameters declaration: 
	`FFT256paramnb	
	
	//Internal signals declarations:
	reg CLK;
	reg RST;
	reg ED;
	reg START;
	reg [3:0]SHIFT;
	wire [nb-1:0]DR;
	wire [nb-1:0]DI;
	wire RDY;
	wire OVF1;
	wire OVF2;
	wire [7:0]ADDR;
	wire signed [nb+3:0]DOR;
	wire signed [nb+3:0]DOI;		 
	
	initial 
		begin
			CLK = 1'b0;
			forever #5 CLK = ~CLK;
		end		  
		
	initial 
		begin	
			SHIFT = 4'b0000;
			ED = 1'b1;
			RST = 1'b0;
			START = 1'b0;
			#13 RST =1'b1;
			#43 RST =1'b0;
			#53 START =1'b1;
			#12 START =1'b0;
		end	  
	 
	//initial 								//ED testing
//		begin
//			#1 ED = 1'b0;
//			forever #10 ED = ~ED;
//		end		
		
	reg [7:0] ct256;
	always @(posedge CLK or posedge START)  
		if (ED)	begin
			if (START) ct256 = 8'b0000_0000;
			else ct256 = ct256+ 'd1;
		end	  
	
	wire [15:0] D_R,D_I,DATA_0;	
	Wave_ROM256 UG( .ADDR(ct256) ,
		.DATA_RE(D_R), .DATA_IM(D_I), .DATA_REF(DATA_0) );// 
	
	assign DR=(D_R[15]&&(nb!=16))? (D_R[15:15-nb+1]+1) : D_R[15:15-nb+1];
	assign DI=(D_I[15]&&(nb!=16))? (D_I[15:15-nb+1]+1) : D_I[15:15-nb+1];
	
	// Unit Under Test 
	FFT256 UUT (
		.CLK(CLK),
		.RST(RST),
		.ED(ED),
		.START(START),
		.SHIFT(SHIFT),
		.DR(DR),
		.DI(DI),
		.RDY(RDY),
		.OVF1(OVF1),
		.OVF2(OVF2),
		.ADDR(ADDR),
		.DOR(DOR),
		.DOI(DOI));
		
		wire [7:0] addrr;		  
	`ifdef FFT256paramifft
		assign addrr= (256-ADDR);  //the result order if IFFT 
	`else  
		assign addrr= ADDR;
	`endif
	

		wire signed [15:0] DATA_R0,DATA_I0,DATA_REF;	
	Wave_ROM256 UR( .ADDR(addrr) ,
		.DATA_RE(DATA_R0), .DATA_IM(DATA_I0), .DATA_REF(DATA_REF) );// 
	
	wire signed [18:15-nb+1] DREF=2*DATA_REF[15:15-nb+1];
	
	integer sqra; 
	integer ctres; 
	reg f;				  
	initial f=0;
	always@(posedge CLK) begin 	  //SQR calculator 
		if(ED) begin
		if (f) 
			ctres=ctres+1;
			if (RST || RDY)  begin
				if (RDY) f=1;
				sqra=0;
				ctres=0; end
			else if (ctres<256) begin			
				//considered that input phase is 45 deg. ie. DOI=DOR
					#2 sqra = sqra +(DREF-DOR)*(DREF-DOR);
				#2 sqra = sqra +(DREF-DOI)*(DREF-DOI); end		 
			else if (ctres==256)  
				$display("rms error is ", (sqra/512), " lsb");
		end	 end

	
endmodule
