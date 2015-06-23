/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Multiplier by 0.7071                                       ////
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
// File name            : MPU707.v
// File Revision        : 
// Last modification    : Sun Sep 30 20:11:56 2007
/////////////////////////////////////////////////////////////////////
// FUNCTION: Constant multiplier
// PROPERTIES:1)Is based on shifts right and add
//		  2)for short input bit width 0.7071 is approximated as
//              10110101 then rounding is not used
//		  3)for long input bit width 0.7071 is approximated as 
//              10110101000000101	       
//		  4)hardware is 3 or 4 adders 
/////////////////////////////////////////////////////////////////////
`include "FFT64_CONFIG.inc"

module MPU707 ( CLK ,DO ,DI ,EI );
`USFFT64paramnb 
	
	input CLK ;
	wire CLK ;
	input [nb+1:0] DI ;
	wire signed [nb+1:0] DI ;
	input EI ;
	wire EI ;
	
	output [nb+1:0] DO ;
	reg [nb+1:0] DO ;	 
	
	reg signed [nb+5 :0] dx5;	 
	reg signed	[nb+2 : 0] dt;		   
	wire signed [nb+6 : 0]  dx5p; 
	wire  signed  [nb+6 : 0] dot;	
	
	always @(posedge CLK)
		begin
			if (EI) begin
					dx5<=DI+(DI <<2);	 //multiply by 5
					dt<=DI;		  
					DO<=dot >>>4;	
				end 
		end		 
		
	`ifdef USFFT64bitwidth_0707_high
	assign   dot=	(dx5p+(dt>>>4)+(dx5>>>12));	   // multiply by 10110101000000101	      
	`else	                               
	assign    dot=		(dx5p+(dt>>>4) )	;  // multiply by 10110101	   
	`endif	 	
		
		assign	dx5p=(dx5<<1)+(dx5>>>2);		// multiply by 101101		 	
	
	
endmodule
