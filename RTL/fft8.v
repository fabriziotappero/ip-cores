/////////////////////////////////////////////////////////////////////
////                                                             ////
////  8-point FFT, First stage of FFT 64 processor               ////
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
// File name            : FFT8.v
// File Revision        : 
// Last modification    : Sun Sep 30 20:11:56 2007
/////////////////////////////////////////////////////////////////////
// FUNCTION: 8-point FFT
// FILES: FFT8.v - 1-st stage, contains
//        MPU707.v - multiplier to the factor 0.707.
// PROPERTIES:1) Fully pipelined
//		  2) Each clock cycle complex datum is entered
//               and complex result is outputted
//		  3) Has 8-clock cycle period starting with the START 
//               impulse and continuing forever
//		  4) rounding	is not used
//		  5)Algorithm is from the book "H.J.Nussbaumer FFT and 
//              convolution algorithms".
//		  6)IFFT is performed by substituting the output result 
//              order to the reversed one
//		    (by exchanging - to + and + to -)
/////////////////////////////////////////////////////////////////////
//Algorithm:
//  procedure FFT8(
//		 D: in MEMOC8;  -- input array
//		 DO:out MEMOC8)  -- output ARRAY
//		is   
//		variable t1,t2,t3,t4,t5,t6,t7,t8,m0,m1,m2,m3,m4,m5,m6,m7: complex;
//		variable s1,s2,s3,s4: complex;
//	begin		  				   
//		t1:=D(0) + D(4);
//		m3:=D(0) - D(4);
//		t2:=D(6) + D(2);
// 	    m6:=CBASE_j*(D(6)-D(2));
//		t3:=D(1) + D(5);
//		t4:=D(1) - D(5);
//		t5:=D(3) + D(7);
//		t6:=D(3) - D(7);
//		t8:=t5 + t3;
//		m5:=CBASE_j*(t5-t3);
//		t7:=t1 + t2;
//		m2:=t1 - t2;
//		m0:=t7 + t8;
//		m1:=t7 - t8;	  
//		m4:=SQRT(0.5)*(t4 - t6);
//		m7:=-CBASE_j*SQRT(0.5)*(t4 + t6);	   
//		s1:=m3 + m4;
//		s2:=m3 - m4;
//		s3:=m6 + m7;
//		s4:=m6 - m7;
//		DO(0):=m0;
//		DO(4):=m1;
//		DO(1):=s1 + s3;
//		DO(7):=s1 - s3;
//		DO(2):=m2 + m5;
//		DO(6):=m2 - m5;
//		DO(5):=s2 + s4;
//		DO(3):=s2 - s4;
//	end procedure;	
/////////////////////////////////////////////////////////////////////
`timescale 1ps / 1ps  
`include "FFT64_CONFIG.inc"	 

module FFT8 ( DOR ,DII ,RST ,ED ,CLK ,DOI ,START ,DIR ,RDY );
	`USFFT64paramnb	
	
	input ED ;
	wire ED ;
	input RST ;
	wire RST ;
	input CLK ;
	wire CLK ;
	input [nb-1:0] DII ;
	wire [nb-1:0] DII ;
	input START ;
	wire START ;
	input [nb-1:0] DIR ;
	wire [nb-1:0] DIR ;
	
	output [nb+2:0] DOI ;
	wire [nb+2:0] DOI ;
	output [nb+2:0] DOR ;
	wire [nb+2:0] DOR ;
	output RDY ;
	reg RDY ;		   
	
	reg [2:0] ct; //main phase counter
	reg [3:0] ctd; //delay counter
	
	always @(   posedge CLK) begin	//Control counter
			//
			if (RST)	begin
					ct<=0; 
					ctd<=15; 
				RDY<=0;  end
			else if (START)	  begin
					ct<=0; 
					ctd<=0;	
				RDY<=0;   end
			else if (ED) begin	
					RDY<=0; 
					ct<=ct+1;	
					if (ctd !=4'b1111)
						ctd<=ctd+1;		
					if (ctd==12 ) 
						RDY<=1;
				end 
			
		end	   
	
	reg signed	[nb-1: 0] dr,d1r,d2r,d3r,d4r,di,d1i,d2i,d3i,d4i;
	always @(posedge CLK)	  // input register file
		begin
			if (ED) 	begin
					dr<=DIR;  
					d1r<=dr;  
					d2r<=d1r;
					d3r<=d2r;
					d4r<=d3r;				
					di<=DII;  
					d1i<=di;  
					d2i<=d1i;
					d3i<=d2i;
					d4i<=d3i;				
				end
		end 	
	
	reg signed	[nb:0]	s1r,s2r,s1d1r,s1d2r,s1d3r,s2d1r,s2d2r,s2d3r;
	reg signed	[nb:0]	s1i,s2i,s1d1i,s1d2i,s1d3i,s2d1i,s2d2i,s2d3i;
	always @(posedge CLK)	begin		   // S1,S2 =t1-t6,m3 and delayed
			if (ED && ((ct==5) || (ct==6) || (ct==7) || (ct==0))) begin
					s1r<=d4r + dr ;
					s1i<=d4i + di ;
					s2r<=d4r - dr ;
					s2i<= d4i - di;
				end	
			if	(ED)   begin
					s1d1r<=s1r;
					s1d2r<=s1d1r;	  
					s1d1i<=s1i;
					s1d2i<=s1d1i;	  
					if (ct==0 || ct==1)	 begin	  //## note for vhdl
							s1d3r<=s1d2r;
							s1d3i<=s1d2i;
						end
					if (ct==6 || ct==7 || ct==0) begin
							s2d1r<=s2r;
							s2d2r<=s2d1r;
							s2d1i<=s2i;
							s2d2i<=s2d1i;
						end		  
					if (ct==0) begin
							s2d3r<=s2d2r;
							s2d3i<=s2d2i;
						end 
				end
		end			  
	
	
	reg signed [nb+1:0]	s3r,s4r,s3d1r,s3d2r,s3d3r;
	reg signed [nb+1:0]	s3i,s4i,s3d1i,s3d2i,s3d3i;
	always @(posedge CLK)	begin		  //ALU	S3:	
			if (ED)  
				case (ct) 
					0: begin s3r<=  s1d2r+s1r;	 	   //t7
						s3i<= s1d2i+ s1i ;end  
					1: begin s3r<=  s1d3r - s1d1r;	 	 //m2
						s3i<= s1d3i - s1d1i; end 
					2: begin s3r<= s1d3r +s1r;	 	 //t8
						s3i<= s1d3i+ s1i ; end
					3: begin s3r<=  s1d3r - s1r;	 	 //
						s3i<= s1d3i - s1i ; end
				endcase
			
			if	(ED) begin
					if (ct==1 || ct==2 || ct==3) begin
							s3d1r<=s3r;						//t8
							s3d1i<=s3i;
						end 
					if ( ct==2 || ct==3) begin
							s3d2r<=s3d1r;	  				//m2
							s3d3r<=s3d2r;				   //t7
							s3d2i<=s3d1i;	  
							s3d3i<=s3d2i;
						end 
				end 		  
		end 		  		
	
	always @ (posedge CLK)	begin		  // S4 
			if (ED)	begin
					if (ct==1) begin
							s4r<= s2d2r + s2r;
						s4i<= s2d2i + s2i; end
					else if (ct==2) begin
							s4r<=s2d2r - s2r;
							s4i<= s2d2i - s2i;
						end 
				end 
		end 
	
	assign	em = ((ct==2 || ct==3 || ct==4)&& ED);
	
	wire signed [nb+1:0] m4m7r,m4m7i;
	MPU707 #(nb) UMR( .CLK(CLK),.EI(em),.DI(s4r),.DO(m4m7r));	 //  UMR
	MPU707 #(nb) UMI( .CLK(CLK),.EI(em),.DI(s4i),	.DO(m4m7i));	 //  UMR
	
	reg signed [nb+1:0]	sjr,sji, m6r,m6i;
	always @ (posedge CLK)	begin		   //multiply by J 
			if (ED) begin	
					case  (ct) 
						3: begin sjr<= s2d1i;	                //m6
							sji<=0 - s2d1r; end
						4: begin sjr<= m4m7i;	//m7
							sji<=0 - m4m7r;end
						6: begin sjr<= s3i;		//m5
							sji<=0 - s3r;	  end
					endcase
					if (ct==4) begin
							m6r<=sjr;				 //m6
							m6i<=sji;
						end
				end 
		end 	
	
	reg 	signed [nb+2:0]	s5r,s5d1r,s5d2r,q1r;
	reg 	signed [nb+2:0]	s5i,s5d1i,s5d2i,q1i;
	always @ (posedge CLK)		     // 	S5:
		if (ED)	  
			case  (ct) 
				5: begin q1r<=s2d3r +m4m7r ;	   //	 S1
						q1i<=s2d3i +m4m7i ;	 
						s5r<=m6r + sjr;
					s5i<=m6i + sji; end
				6: begin 	s5r<=m6r - sjr;
						s5i<=m6i - sji;								  
						s5d1r<=s5r;
					s5d1i<=s5i; end
				7: begin	 s5r<=s2d3r - m4m7r;
						s5i<=s2d3i - m4m7i;	  
						s5d1r<=s5r;
						s5d1i<=s5i;
						s5d2r<=s5d1r;
						s5d2i<=s5d1i;
					end
			endcase
	
	reg 	signed [nb+3:0]	s6r,s6i	;
	`ifdef paramifft
	always @ (posedge CLK)	begin		 //  S6-- result adder
			if (ED)  
				case  (ct) 
					5: begin s6r<=s3d3r +s3d1r ;	  // --	 D0
						s6i<=s3d3i +s3d1i ;end	   //--	 D0
					6: begin  
								s6r<=q1r - s5r ;	   
							s6i<=q1i - s5i ;	 end
					7:  begin	  
								s6r<=s3d2r - sjr ;	  
							s6i<=s3d2i - sji ;	  end
					0:  begin 
								s6r<=s5r + s5d1r ;	   
							s6i<= s5i +s5d1i ;	end   
					1:begin	s6r<=s3d3r - s3d1r ;	    //--	 D4
						s6i<=s3d3i - s3d1i ; end
					2: begin	  
								s6r<= s5r - s5d1r ;	       //	 D5
							s6i<= s5i - s5d1i ;	   end
					3: begin  							    //	 D6
								s6r<=s3d3r + sjr ;	   
								s6i<=s3d3i + sji ;	
							end 	  
					4:   begin 									   //	 D0
								s6r<= q1r + s5d2r ;	   
								s6i<= q1i + s5d2i ;	  
							end 
				endcase
		end	
		
   `else
			always @ (posedge CLK)	begin		 //  S6-- result adder
			if (ED)  
				case  (ct) 
					5: begin s6r<=s3d3r +s3d1r ;	  // --	 D0
						s6i<=s3d3i +s3d1i ;end	   //--	 D0
					6:  begin 
								s6r<=q1r + s5r ;	             //--	 D1
							s6i<=q1i + s5i ; end	 
						7:   begin 
								s6r<=s3d2r +sjr ;	         //--	 D2
							s6i<=s3d2i +sji ;	   end
					0:   begin 
								s6r<=s5r - s5d1r ;	               // --	 D3
							s6i<= s5i - s5d1i ;end	   
						
					1:begin	s6r<=s3d3r - s3d1r ;	    //--	 D4
						s6i<=s3d3i - s3d1i ; end
					2:   begin 
								s6r<=s5r + s5d1r ;	              //--	 D5
							s6i<=s5i + s5d1i ; end	   
						
					3:  begin 
								s6r<= s3d3r - sjr ;	        //	 D6
							s6i<=s3d3i - sji ;	end
					
					4:   begin 
								s6r<= q1r - s5d2r ;	         //	 D0
							s6i<=  q1i - s5d2i ;	end
						
				endcase
		end	  
	`endif 
		
	assign #1	DOR=s6r[nb+2:0];
	assign #1	DOI= s6i[nb+2:0];
	
endmodule
