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
// DESCRIPTION	:	Top level  of the  high speed FFT  core
// FUNCTION:	 Structural model of the high speed 128-complex point FFT 
//			core intended for synthesizing 
//			for  any type FPGAs and ASIC.
// FILES:	FFT128.v - root unit, this file,   
//        FFT128_CONFIG.inc - core configuration file
//			BUFRAM128C.v	- 1-st,2-nd,3-d data buffer, contains:
//                 RAM2x128C.v - dual ported synchronous RAM, contains:		
//					   RAM128.v -single ported synchronous RAM
//			FFT16.v- 1-st,2-nd stages implementing 16-point FFTs, contains
//                 MPU707.v, MPU707_2.v - multiplier to the factor 0.707.
//			ROTATOR256.v - unit for rotating complex vectors, contains
//                  WROM256.v - ROM of twiddle factors.	   
//         CNORM.v - normalization stages   
//   		UNFFT256_TB.v - testbench file, includes:
//				 Wave_ROM256.v - ROM with input data and result reference data
//				SineROM256_gen.pl - PERL script to generate the Wave_ROM256.v file
//
// PROPERTIES: 1. Fully pipelined, 1 complex data in, 1 complex result out each clock cycle
//						   2. Input data, output data, coefficient widths are adjustable  in range 8..16
// 					   3. Normalization stages trigger the data overflow and shift data right 
//                            to prevent the overflow 	  
//						   4. Core can contain 2 or 3 data buffers. In the configuration of 2 buffers 
//                            the results are in the shuffled order but provided with the proper address.
//                        5. The core operation can be slowed down by the control of the ED input
//                        6. The reset RST is synchronous one
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
`timescale 1 ns / 1 ps
`include "FFT128_CONFIG.inc"	 

module FFT128 ( CLK ,RST ,ED ,START ,SHIFT ,DR ,DI ,RDY ,OVF1 ,OVF2 ,ADDR ,DOR ,DOI );
	`FFT128paramnb		  	 		//nb is the data bit width

	output RDY ;   			// in the next cycle after RDY=1 the 0-th result is present 
	wire RDY ;
	output OVF1 ;			// 1 signals that an overflow occured in the 1-st stage 
	wire OVF1 ;
	output OVF2 ;			// 1 signals that an overflow occured in the 2-nd stage 
	wire OVF2 ;
	output [6:0] ADDR ;	//result data address/number
	wire [6:0] ADDR ;
	output [nb+3:0] DOR ;//Real part of the output data, 
	wire [nb+3:0] DOR ;	 // the bit width is nb+4, can be decreased when instantiating the core 
	output [nb+3:0] DOI ;//Imaginary part of the output data
	wire [nb+3:0] DOI ;
	
	input CLK ;        			//Clock signal is less than 300 MHz for the Xilinx Virtex5 FPGA        
	wire CLK ;
	input RST ;				//Reset signal, is the synchronous one with respect to CLK
	wire RST ;
	input ED ;					//=1 enables the operation (eneabling CLK)
	wire ED ;
	input START ;  			// its falling edge starts the transform or the serie of transforms  
	wire START ;			 	// and resets the overflow detectors
	input [3:0] SHIFT ;		// bits 1,0 -shift left code in the 1-st stage
	wire [3:0] SHIFT ;	   	// bits 3,2 -shift left code in the 2-nd stage
	input [nb-1:0] DR ;		// Real part of the input data,  0-th data goes just after 
	wire [nb-1:0] DR ;	    // the START signal or after 255-th data of the previous transform
	input [nb-1:0] DI ;		//Imaginary part of the input data
	wire [nb-1:0] DI ;
	
	wire [nb-1:0] dr1,di1;
	wire [nb+1:0] dr3,di3,dr4,di4, dr5,di5 ;
	wire [nb+2:0] dr2,di2;
	wire [nb+5:0] dr6,di6; 	
	wire [nb+3:0] dr7,di7,dr8,di8;   
	wire rdy1,rdy2,rdy3,rdy4,rdy5,rdy6,rdy7,rdy8;			 
	reg [7:0] addri ;
												    // input buffer =8-bit inversion ordering
	BUFRAM128C_1 #(nb) U_BUF1(.CLK(CLK), .RST(RST), .ED(ED),	.START(START),
	.DR(DR),	.DI(DI),			.RDY(rdy1),	.DOR(dr1), .DOI(di1));	   
	
	//1-st stage of FFT
	FFT8 #(nb) U_FFT1(.CLK(CLK), .RST(RST), .ED(ED),
		.START(rdy1),.DIR(dr1),.DII(di1),
		.RDY(rdy2),	.DOR(dr2),.	DOI(di2));	
	
	wire	[1:0] shiftl=	 SHIFT[1:0]; 
	CNORM_1 #(nb) U_NORM1( .CLK(CLK),	.ED(ED),  //1-st normalization unit
		.START(rdy2),	// overflow detector reset
		.DR(dr2),	.DI(di2),
		.SHIFT(shiftl), //shift left bit number
		.OVF(OVF1),
		.RDY(rdy3),
		.DOR(dr3),.DOI(di3));	
		
	// rotator to the angles proportional to PI/64
	ROTATOR128 #(nb+2) U_MPU (.CLK(CLK),.RST(RST),.ED(ED),
		.START(rdy3),. DR(dr3),.DI(di3),
		.RDY(rdy4), .DOR(dr4),	.DOI(di4));
	
	BUFRAM128C_2 #(nb+2) U_BUF2(.CLK(CLK),.RST(RST),.ED(ED),	// intermediate buffer =8-bit inversion ordering
		.START(rdy4),. DR(dr4),.DI(di4),
		.RDY(rdy5), .DOR(dr5),	.DOI(di5));	 
	
	//2-nd stage of FFT
	FFT16 #(nb+2) U_FFT2(.CLK(CLK), .RST(RST), .ED(ED),
		.START(rdy5),. DIR(dr5),.DII(di5),
		.RDY(rdy6), .DOR(dr6),	.DOI(di6));
	
	wire	[1:0] shifth=	 SHIFT[3:2]; 
	//2-nd normalization unit
	CNORM_2 #(nb+2) U_NORM2 ( .CLK(CLK),	.ED(ED),
		.START(rdy6),	// overflow detector reset
		.DR(dr6),	.DI(di6),
		.SHIFT(shifth), //shift left bit number
		.OVF(OVF2),
		.RDY(rdy7),
		.DOR(dr7),	.DOI(di7));


		BUFRAM128C  #(nb+4) 	Ubuf3(.CLK(CLK),.RST(RST),.ED(ED),	// intermediate buffer =8-bit inversion ordering
		.START(rdy7),. DR(dr7),.DI(di7),
		.RDY(rdy8), .DOR(dr8),	.DOI(di8));	 	

	

	
	`ifdef FFT128parambuffers3  	 	// 3-data buffer configuratiion 		   
	always @(posedge CLK)	begin	//POINTER to the result samples
			if (RST)
				addri<=7'b000_0000;
			else if (rdy8==1 )  
				addri<=7'b000_0000;
			else if (ED)
				addri<=addri+1; 
		end
	
		assign ADDR=  addri ;
	assign	DOR=dr8;
	assign	DOI=di8;
	assign	RDY=rdy8;	

	`else
	 	always @(posedge CLK)	begin	//POINTER to the result samples
			if (RST)
				addri<=7'b000_0000;
			else if (rdy7) 
				addri<=7'b000_0000;
			else if (ED)
			addri<=addri+1; 
		end	  
	assign #1 	 ADDR=  {addri[2:0] , addri[6:3]} ;
	assign #2	DOR= dr7;
	assign #2  DOI= di7;
	assign  	RDY= rdy7;	
	`endif	
endmodule
