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
// DESCRIPTION	:	 Complex Multiplier by 0.7071
// FUNCTION:	 	   Constant multiplier
// FILES:			 MPU707.v
//  PROPERTIES: 1) Is based on shifts right and add
//							2) for short input bit width 0.7071 is approximated as 10110101	                           then rounding	is not used
//							3) for long input bit width 0.7071 is approximated as 10110101000000101	       
//						    4) hardware is 4 or 5 adders 
//						    5) MPYJ switches multiply by j 				 
//							6) A complex data is multiplied for 2 cycles
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
`include "FFT128_CONFIG.inc"

module MPUC707 ( CLK,ED, DS, MPYJ,DR,DI ,DOR ,DOI,  );
	`FFT128paramnb 
//	MPUC707 #(nb+2) UM707(.CLK(CLK),.ED(ED), .DS(es), .MPYJ(mpyj) ,
	
	input CLK ;
	wire CLK ;
	input DS ;					//data strobe
	wire DS ;
	input ED; 					 //slowdown
	input MPYJ ;				//the result is multiplied by -j
	wire MPYJ ;
	input [nb-1:0] DR ;
	wire signed [nb-1:0] DR ;
	input [nb-1:0] DI ;
	wire signed [nb-1:0] DI ;	   
	
	output [nb-1:0] DOR ;
	reg [nb-1:0] DOR ;	
	output [nb-1:0] DOI ;
	reg [nb-1:0] DOI ;	 
	
	reg signed [nb+1 :0] dx5;	 
	reg signed	[nb : 0] dt;		   
	reg signed	[nb-1 : 0] dii;		   
	wire signed [nb+2 : 0]  dx5p; 
	wire  signed  [nb+3 : 0] dot;	
	reg edd,edd2, edd3;        		//delayed data enable impulse        
	reg mpyjd,mpyjd2,mpyjd3;
	reg [nb-1:0] doo ;	
	reg [nb-1:0] droo ;	
	
	always @(posedge CLK)
		begin
			if (ED) begin	  
					edd<=DS;
					edd2<=edd;	
					edd3<=edd2;	
					mpyjd<=MPYJ;
					mpyjd2<=mpyjd;
					mpyjd3<=mpyjd2;
					if (DS)	 begin
							dx5<=DR+(DR <<2);	 //multiply by 5 
							dt<=DR;	  
							dii<=DI;
						end
					else	 begin
							dx5<=dii+(dii <<2);	 //multiply by 5
							dt<=dii;
						end
					doo<=(dot >>>4) ;	
					droo<=doo;	
					if (edd3) 	 
						if (mpyjd3) begin
								DOR<=doo;
							DOI<= - droo; end
						else begin
								DOR<=droo;
							DOI<=  doo; end					
				end 
		end		
		
	assign	dx5p=(dx5<<1)+(dx5>>>2);		// multiply by 101101		 	
	
	`ifdef FFT128bitwidth_coef_high
	assign   dot=	dx5p+(dt>>>4)+(dx5>>>12);//	(dt>>>9);   // multiply by 10110101000000101	      
	`else	                               
	assign    dot=		dx5p+(dt>>>4)	;  // multiply by 10110101	   
	`endif	 	
	
	
	
endmodule
