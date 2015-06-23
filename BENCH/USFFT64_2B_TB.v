/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Testbench for the UNFFT64_core - FFT 64 processor          ////
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
// FUNCTION:a set of 4 sine waves is inputted to the FFT processor,
//          the results are compared with the expected waves,
//          the square root mean error is calculated (without a root)
// FILES:   USFFT64_2B_TB.v - this file, contains
//	      USFFT64_2B.v - unit under test
//          sin_tst_rom.v - rom with the test waveform, generating by 
//          sinerom64_gen.pl   
//  PROPERTIES: 1) the calculated error after ca. 4us modeling 
//		is outputted to the console	 as the note:
//   	      rms error is           1 lsb
//		2)if the error is 0,1,2 then the test is OK
//		3) the customer can exchange the test selecting the 
//		different frequencies and generating the wave ROM by
//          the script  sinerom64_gen.pl   		 	
//		4) the proper operation can be checked by investigation
//          of the core output waveforms
/////////////////////////////////////////////////////////////////////
`include "FFT64_CONFIG.inc"	 

`timescale 1ns / 1ps
module USFFT64_2B_tb;
	//Parameters declaration: 
	//defparam UUT.nb = 12;
	`USFFT64paramnb	
	
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
	wire [5:0]ADDR;
	wire signed [nb+2:0]DOR;
	wire signed [nb+2:0]DOI;		 
	
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
	
	reg [5:0] ct64;
	always @(posedge CLK or posedge START) begin
			if (START) ct64 = 6'b000000;
			else ct64 = ct64 + 'd1;
		end
	
	wire [15:0] DATA_RE,DATA_IM,DATA_0;	
	Wave_ROM64 UG( .ADDR(ct64) ,
		.DATA_RE(DATA_RE), .DATA_IM(DATA_IM), .DATA_REF(DATA_0) );// 
	
	assign DR=DATA_RE[15:15-nb+1];
	assign DI=DATA_IM[15:15-nb+1];
	
	// Unit Under Test 
	USFFT64_2B UUT (
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
		
		wire [5:0] addrr;		  
	`ifdef USFFT64paramifft
		assign addrr= (64-ADDR);  //the result order if IFFT 
	`else  
		assign addrr= ADDR;
	`endif
	

		wire signed [15:0] DATA_R0,DATA_I0,DATA_REF;	
	Wave_ROM64 UR( .ADDR(addrr) ,
		.DATA_RE(DATA_R0), .DATA_IM(DATA_I0), .DATA_REF(DATA_REF) );// 
	
	wire signed [18:15-nb+1] DREF=2*DATA_REF[15:15-nb+1];
	
	integer sqra; 
	integer ctres; 
	reg f;				  
	initial f=0;
	always@(posedge CLK) begin 
		if (f) 
			ctres=ctres+1;
			if (RST || RDY)  begin
				if (RDY) f=1;
				sqra=0;
				ctres=0; end
			else if (ctres<64) begin
					#2 sqra = sqra +(DREF-DOR)*(DREF-DOR);
				#2 sqra = sqra +(DOI)*(DOI); end		 
			else if (ctres==64)  
				$display("rms error is ", (sqra/128), " lsb");
		end

	
endmodule
