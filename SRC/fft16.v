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
// DESCRIPTION	:	 Stage of FFT 128 processor
// FUNCTION:	 	  16-point FFT
// FILES:			 		FFT16.v -  stage, contains
//                    MPUC707.v - multiplier to the factor 0.707.
//                    MPUC541.v - multiplier to the factor 0.541.
//                    MPUC1307.v - multiplier to the factor 1.307.
//                    MPUC924_383.v - multiplier to the factors 0.924 and 0.383.
//  PROPERTIES: 1) Fully pipelined
//							2) Each clock cycle complex datum is entered
//                           and complex result is outputted
//							 3) Has 16-clock cycle period starting with the START impulse
//                          and continuing forever
//							4) rounding	is not used
//							5)Algorithm is from the book "H.J.Nussbaumer FFT and convolution algorithms".
//							6)IFFT is performed by substituting the output result order to the reversed one
//								(by exchanging - to + and + to -)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Algorithm:
///procedure FFT16(
//		X: in MEMOC;  -- входной массив данных
//		y:out MEMOC)  -- выходной массив спектров
//		is   
//		variable t1,t2,t3,t4,t5,t6,t7,t8,t9,t10: complex;
//		variable t11,t12,t13,t14,t15,t16,t17,t18,t19,t20: complex;
//		variable t21,t22,t23,t24,t25,t26: complex;
//		variable m0,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10: complex;
//		variable m11,m12,m13,m14,m15,m16,m17: complex;
//		variable s1,s2,s3,s4,s5,s6,s7,s8,s9,s10: complex;
//		variable s11,s12,s13,s14,s15,s16,s17,s18,s19,s20: complex;
//	begin		  				   
//		t1:=x(0) + x(8); 			m4:=x(0) - x(8);
//		t2:=x(4) + x(12);  	    m12:=-CBASE_j*(x(4)-x(12));
//		t3:=x(2) + x(10);			t4:=x(2) - x(10);
//		t5:=x(6) + x(14);			t6:=x(6) - x(14);
//		t7:=x(1) + x(9);			t8:=x(1) - x(9);
//		t9:=x(3) + x(11);			t10:=x(3) - x(11);
//		t11:=x(5) + x(13);		t12:=x(5) - x(13);
//		t13:=x(7) + x(15);		t14:=x(7) - x(15);
//		t15:=t1 + t2;				m3:= t1 - t2;
//		t16:=t3 + t5;				m11:= -CBASE_j*(t3 - t5);
//		t17:=t15 + t16;			m2:= t15 - t16;
//		t18:=t7 + t11;				t19:= t7 - t11;
//		t20:=t9 + t13;				t21:= t9 - t13;
//		t22:=t18 + t20;			m10:= -CBASE_j*(t18 - t20);
//		t23:=t8 + t14;				t24:= t8 - t14;
//		t25:=t12 + t10;			t26:= t12 - t10;
//		
//		m0:=t17 + t22;				m1:=t17 - t22;
//		m13:=-CBASE_j*c707*(t19 + t21);			m5:=c707*(t19 - t21);			  
//		m6:=c707*(t4 - t6);	  	m14:=-CBASE_j*c707*(t4 + t6);		
//	
//		m7:=c3*(t24+t26);
//		m8:=c13*(t24);
//		m9:=-s1_3*(t26);  
//		s7:= m8 - m7;					 
//		s8:= m9 - m7;   
//		
//		m15:=-CBASE_j*c1*(t23 + t25);	   
//		m16:= -CBASE_j*s1_3*(t23);	   
//		m17:=-CBASE_j*c13*(t25);
//		s15:= m15 - m16;							 
//		s16:= m15 - m17;
//		
//		s1:=m3 + m5;			s2:=m3 - m5;
//		s3:=m13 + m11;		s4:=m13 - m11;			  	
//		s5:=m4 + m6;			s6:=m4 - m6;
//		s9:=s5 + s7;				s10:=s5 - s7;
//		s11:=s6 + s8;			s12:=s6 - s8;
//		s13:=m12 + m14;		s14:=m12 - m14;			  	
//		s17:=s13 + s15;		s18:=s13 - s15;	  
//		s19:=s14 + s16;		s20:=s14 - s16;
//		
//		y(0):=m0; 			y(8):=m1;
//		y(1):=s9 + s17;	y(15):=s9 - s17;
//		y(2):=s1 + s3;		y(14):=s1 - s3;
//		y(3):=s12 - s20;	y(13):=s12 + s20;
//		y(4):=m2 + m10;	y(12):=m2 - m10;
//		y(5):=s11 + s19;	y(11):=s11 - s19;
//		y(6):=s2 + s4;		y(10):=s2 - s4;
//		y(7):=s10 - s18;	y(9):=s10 + s18;
//	end procedure;	
//

`timescale 1ns / 1ps  
`include "FFT128_CONFIG.inc"	 

module FFT16 ( DOR ,DII ,RST ,ED ,CLK ,DOI ,START ,DIR ,RDY );
	`FFT128paramnb	
	
	input ED ;		  //slowdown impulse
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
	
	output [nb+3:0] DOI ;
	wire [nb+3:0] DOI ;
	output [nb+3:0] DOR ;
	wire [nb+3:0] DOR ;
	output RDY ;
	reg RDY ;		   
	
	reg [3:0] ct; //main phase counter
	reg [5:0] ctd; //delay counter
	
	always @(   posedge CLK) begin	//Control counter
			//
			if (RST)	begin
					ct<=0; 
					ctd<=63; 
				RDY<=0;  end
			else if (START)	  begin
					ct<=0; 
					ctd<=0;	
				RDY<=0;   end
			else if (ED) begin	
					RDY<=0; 
					ct<=ct+1;	
					if (ctd !=6'b111111)
						ctd<=ctd+1;		
					if (ctd==44-16 ) 
						RDY<=1;
				end 
			
		end	   
	
	reg signed	[nb-1: 0] dr,d1r,d2r,d3r,d4r,d5r,d6r,d7r,d8r,di,d1i,d2i,d3i,d4i,d5i,d6i,d7i,d8i;
	always @(posedge CLK)	  // input register file
		begin
			if (ED) 	begin
					dr<=DIR;  
					d1r<=dr;  	d2r<=d1r;	d3r<=d2r;d4r<=d3r;
					d5r<=d4r;d6r<=d5r;	d7r<=d6r;	d8r<=d7r;				
					di<=DII;  
					d1i<=di; 	d2i<=d1i;	d3i<=d2i;	d4i<=d3i;
					d5i<=d4i;	d6i<=d5i;d7i<=d6i;	d8i<=d7i;			
				end
		end 	
	
	reg signed	[nb:0]	s1r,s1d1r,s1d2r,s1d3r,s1d4r,s1d5r,s1d6r,s1d7r,s1d8r; 	//even result sums
	reg signed	[nb:0]	s1i,s1d1i,s1d2i,s1d3i,s1d4i,s1d5i,s1d6i,s1d7i,s1d8i; 	//even result sums
	reg signed	[nb:0]	s2r,s2d1r,s2d2r,s2d3r,s2d4r,s2d5r,s2d6r,s2d7r,s2d8r,m4_12r;		//odd result sums
	reg signed	[nb:0]	s2i,s2d1i,s2d2i,s2d3i,s2d4i,s2d5i,s2d6i,s2d7i,s2d8i,m4_12i;		//odd result sums
	always @(posedge CLK)	begin		   // S1,S2 =t1-t14,m4,m12' and delayed
			if (ED && ((ct==9) || (ct==10) || (ct==11) ||(ct==12) ||
				(ct==13) || (ct==14) ||(ct==15) || (ct==0))) begin
					s1r<=d8r + dr ;
					s1i<=d8i + di ;
					s2r<=d8r - dr ;
					s2i<= d8i - di;
				end	
			if	(ED)   begin			//delayed results
					s1d1r<=s1r;	s1d2r<=s1d1r;	s1d1i<=s1i;   	s1d2i<=s1d1i;	  
					s1d3r<=s1d2r;	s1d3i<=s1d2i;	s1d4r<=s1d3r;	s1d4i<=s1d3i;
					s1d5r<=s1d4r;	s1d5i<=s1d4i;	s1d6r<=s1d5r;	s1d6i<=s1d5i;
					s1d7r<=s1d6r;	s1d7i<=s1d6i;	s1d8r<=s1d7r;	s1d8i<=s1d7i;
					
					s2d1r<=s2r;	s2d2r<=s2d1r;	s2d1i<=s2i;		s2d2i<=s2d1i;	  
					s2d3r<=s2d2r;	s2d3i<=s2d2i;	s2d4r<=s2d3r;	s2d4i<=s2d3i;
					s2d5r<=s2d4r;	s2d5i<=s2d4i;	s2d6r<=s2d5r;	s2d6i<=s2d5i;
					s2d7r<=s2d6r;	s2d7i<=s2d6i;	s2d8r<=s2d7r;	s2d8i<=s2d7i;	
					if (ct==2)  begin
						m4_12r<=s2d8r;	m4_12i<=s2d8i;	end
					else if  (ct==6)  begin
							m4_12r<=s2d8i;	m4_12i<= 0 - s2d8r;	
						end
				end
		end			  
	///////////////////////////////////////////
	//arm of even result calculations 
	////////////////////////////////////////////
	reg signed [nb+1:0]	s3r,s3d1r,s3d2r,s3d3r,s3d4r,s3d5r,s3d6r;
	reg signed [nb+1:0]	s3i,s3d1i,s3d2i,s3d3i,s3d4i,s3d5i,s3d6i;
	always @(posedge CLK)	begin		  //ALU	S3:	
			if (ED)  	  begin
					case (ct) 
						14 ,15 : begin s3r<=  s1d4r+s1r;	 	   //t15 //t18
							s3i<= s1d4i+ s1i ;end  
						0 ,1 : begin s3r<=  s1d6r - s1d2r;	 	   //m3, t19
							s3i<= s1d6i - s1d2i ;end  
						2 ,3  : begin s3r<= s1d6r +s1d2r;	 	 //t16 ,t20
							s3i<= s1d6i+ s1d2i ; end
						4 ,5 : begin s3r<=  s1d8r - s1d4r;	 	 //	m11',t21
							s3i<= s1d8i - s1d4i ; end		
					endcase
					s3d1r<=s3r; 	s3d1i<=s3i; 	s3d2r<=s3d1r; s3d2i<=s3d1i;	
					s3d3r<=s3d2r;	s3d3i<=s3d2i;	s3d4r<=s3d3r; s3d4i<=s3d3i;	
					s3d5r<=s3d4r;	s3d5i<=s3d4i;	s3d6r<=s3d5r; s3d6i<=s3d5i;	 
				end
		end 		  
	
	reg signed [nb+2:0]	s4r,s4d1r,s4d2r,s4d3r,s4d4r,s4d5r,s4d6r,s4d7r,m3r;
	reg signed [nb+2:0]	s4i,s4d1i,s4d2i,s4d3i,s4d4i,s4d5i,s4d6i,s4d7i,m3i;
	
	always @ (posedge CLK)	begin		  // S4 
			if (ED)	begin
					if ((ct==3) | (ct==4)) begin
							s4r<= s3d4r + s3r; //t17	   ,t22
						s4i<= s3d4i + s3i; end
					else if ((ct==5) | (ct==6) | (ct==8) ) begin
							s4r<=s3d6r - s3d2r;						   //m2,m10', m5'
						s4i<= s3d6i - s3d2i;  end
					else if (ct==7) begin
							s4r<=s3d1r + s3d5r;						 //m13
							s4i<= s3d1i + s3d5i;
						end   
					s4d1r<=s4r; 		s4d1i<=s4i; 		s4d2r<=s4d1r; s4d2i<=s4d1i;	
					s4d3r<=s4d2r;	s4d3i<=s4d2i;	s4d4r<=s4d3r; s4d4i<=s4d3i;	
					s4d5r<=s4d4r;	s4d5i<=s4d4i;	s4d6r<=s4d5r; s4d6i<=s4d5i;	  
					s4d7r<=s4d6r;	s4d7i<=s4d6i;	 
					if (ct==7) begin 
							m3r<=s3d6r;					 //m3
						m3i<=s3d6i;  end
				end 
		end 
	
	wire em707,mpyj7;
	assign	em707 = ((ct==8) || (ct==10 )||(ct==1) || (ct==5));	//control signals for the multiplier 
	assign   mpyj7 = ((ct==8) || (ct==5));
	
	reg signed [nb+2:0]	s7r,s7d1r;
	reg signed [nb+2:0]	s7i,s7d1i;
	wire signed [nb+2:0] m707r,m707i,m70r,m70i;	   
	assign m70r = ((ct==1) || (ct==5))? s7r :s4r;	   //multiplexor at the multiplier input
	assign m70i = ((ct==1) || (ct==5))? s7i :s4i;
	
	MPUC707 #(nb+3) UM707(  .CLK(CLK),.ED(ED),.DS(em707), .MPYJ(mpyj7),	 //multiplier by 0.707
		.DR(m70r),.DI(m70i) ,.DOR(m707r) ,.DOI(m707i));
	
	
	reg signed [nb+2:0]	s3jr,s3ji, m10r,m10i;
	always @ (posedge CLK)	begin		   //multiply by J 
			if (ED) begin	
					case  (ct) 
						11: begin s3jr<= s3d6i;	                //m11
							s3ji<=0 - s3d6r; end
						14: begin s3jr<= s4d7i;	//m10 
							s3ji<=0 - s4d7r; end
					endcase
					if (ct==1) begin
							m10r<=s3jr;				 //m10
							m10i<=s3ji;
						end
				end 
		end 	
	
	reg 	signed [nb+3:0]	s5r,s5d1r,s5d2r,s5d3r,s5d4r,s5d5r,s5d6r,s5d7r,s5d8r,s5d9r, s5d10r,m2r,m2dr;
	reg 	signed [nb+3:0]	s5i,s5d1i,s5d2i,s5d3i,s5d4i,s5d5i,s5d6i,s5d7i,s5d8i,s5d9i,s5d10i,m2i,m2di;
	always @ (posedge CLK)		     // 	S5:
		if (ED)	 begin 
				case  (ct) 
				10: begin 	s5r<=s4d5r + s4d6r;	//m0
					s5i<=s4d5i + s4d6i; end
				11: begin 	s5r<=s4d7r - s4d6r;	 //m1
					s5i<=s4d7i - s4d6i;	end							  
				12: begin	 s5r<=m707r + s3jr;	  //S3
				s5i<= m707i+s3ji;end
				13: begin	 s5r<=m707r - s3jr;	  //S4
				s5i<= m707i - s3ji;end
				14: begin	 s5r<= m3r+m707r;	  //S1
				s5i<= m3i+m707i ;end
				15: begin	 s5r<=m3r-m707r ;	  //S2
				s5i<= m3i -m707i ;end 
				6: begin	  //S2
					s5d10r<=s5d9r ;	  //S2
				s5d10i<=s5d9i ;end 
				
				endcase	 		
				if 	 ((ct==4)||(ct==5)||(ct==6)||(ct==7)) begin	
					s5d9r<=s5d8r ;	 s5d9i<=s5d8i ;	end	   
				
				s5d1r<=s5r;		s5d1i<=s5i;	    s5d2r<=s5d1r;	s5d2i<=s5d1i;	  
				s5d3r<=s5d2r;	s5d3i<=s5d2i;	s5d4r<=s5d3r;	s5d4i<=s5d3i;
				s5d5r<=s5d4r;	s5d5i<=s5d4i;	s5d6r<=s5d5r;	s5d6i<=s5d5i;
				s5d7r<=s5d6r;	s5d7i<=s5d6i;	s5d8r<=s5d7r;	s5d8i<=s5d7i;	 
				
				if (ct==13)  begin
					m2r<=s4d7r;	m2i<=s4d7i;	end
				if (ct==1)  begin
					m2dr<=m2r;	m2di<=m2i;	end
				
			end
	
	
	
	reg 	signed [nb+3:0]	s6r,s6i	;
	
	`ifdef FFT128paramifft				// For IFFT
	always @ (posedge CLK)	begin		 //  S6-- result adder
			if (ED)  
				case  (ct) 
					13: begin s6r<=s5d2r;	  // --	 Y0
						s6i<=(s5d2i);end	   //--	 Y0
					15: begin  
							s6r<=s5d2r - s5r ;	   		  //Y2
						s6i<=s5d2i - s5i ;	 end
					1:  begin	  
							s6r<=m2r - s3jr ;	  			//Y4
						s6i<=m2i - s3ji ;	  end
					3:  begin 
							s6r<=s5d3r - s5d5r ;	   		 //Y6
						s6i<= s5d3i -s5d5i ;	end   
					5:begin	s6r<=(s5d9r) ;	    //--	 Y8
						s6i<=(s5d9i) ; end
					7: begin	  
							s6r<= s5d7r + s5d9r ;	       //	 Y10
						s6i<= s5d7i + s5d9i ;	   end
					9: begin  							    //	 Y12
							s6r<=m2dr +m10r ;	   
							s6i<=m2di + m10i ;	
						end 	  
					11:   begin 									   //	Y14
							s6r<= s5d9r + s5d10r ;	   
							s6i<= s5d9i + s5d10i ;	  
						end 
				endcase	   
		end	
	
	`else
	always @ (posedge CLK)	begin		 //  S6-- result adder
			if (ED)  
				case  (ct) 
					13: begin s6r<=s5d2r;	  // --	 Y0
						s6i<=s5d2i;end	   //--	 Y0
					15: begin  
							s6r<=s5d2r + s5r ;	   		  //Y2
						s6i<=s5d2i + s5i ;	 end
					1:  begin	  
							s6r<=m2r + s3jr ;	  			//Y4
						s6i<=m2i + s3ji ;	  end
					3:  begin 
							s6r<=s5d3r + s5d5r ;	   		 //Y6
						s6i<= s5d3i +s5d5i ;	end   
					5:begin	s6r<=s5d9r;	    //--	 Y8
						s6i<=s5d9i; end
					7: begin	  
							s6r<= s5d7r - s5d9r ;	       //	 Y10
						s6i<= s5d7i - s5d9i ;	   end
					9: begin  							    //	 Y12
							s6r<=m2dr -m10r ;	   
							s6i<=m2di - m10i ;	
						end 	  
					11:   begin 									   //	Y14
							s6r<= s5d9r - s5d10r ;	   
							s6i<= s5d9i - s5d10i ;	  
						end 
				endcase	   
		end	
	`endif 		
	
	///////////////////////////////////////////////////////////
	//arm of odd result calculations 
	//////////////////////////////////////////////////////////

	always @(posedge CLK)	begin		  //ALU	S7:	
			if (ED)  
				case (ct) 		
					15:begin s7r<=  s2d2r-s2r;	 	   //t26
						s7i<= s2d2i- s2i ;end  
					0: begin s7r<=  s2d4r-s2r;	 	   //m6'
							s7i<= s2d4i- s2i ;
							s7d1r<=s7r;
						s7d1i<=s7i;end  
					1: begin s7r<=  s2d6r - s2r;	 	 //t24
						s7i<= s2d6i - s2i; end 
					2: begin s7r<= s7r -s7d1r;	 	 //m7'
						s7i<= s7i- s7d1i ; end
					3: begin s7r<=  s2d8r + s2d2r;	 	 //	t23
						s7i<= s2d8i + s2d2i ; end
					4: begin s7r<=  s2d8r + s2d4r;	 	 //	m14'
							s7i<= s2d8i + s2d4i ;
							s7d1r<=s7r;
						s7d1i<=s7i;end
					5: begin s7r<=  s2d8r + s2d6r;	 	 //	t25
						s7i<= s2d8i + s2d6i ; end
					6: begin  s7r<= s7r + s7d1r;	 	 //m15'
						s7i<= s7i + s7d1i ; end
				endcase								  
		end
	
	wire em541,mpyj541;
	wire signed [nb+2:0] m541r,m541i;	  
	assign	em541 = ((ct==0) || (ct==4));	//control signals for the multiplier 
	assign   mpyj541 = ((ct==4));
	MPUC541 #(nb+3) UM541(  .CLK(CLK),.ED(ED),.DS(em541), .MPYJ(mpyj541),	 //multiplier by 0.383
		.DR(s7r),.DI(s7i) ,.DOR(m541r) ,.DOI(m541i));
	
	
	wire em1307,mpyj1307;
	wire signed [nb+2:0] m1307r,m1307i;	  
	assign	em1307 = ((ct==2) || (ct==6));	//control signals for the multiplier 
	assign   mpyj1307 = ((ct==6));
	MPUC1307 #(nb+3) UM1307(  .CLK(CLK),.ED(ED),.DS(em1307), .MPYJ(mpyj1307),	 //multiplier by 1.306
		.DR(s7r),.DI(s7i) ,.DOR(m1307r) ,.DOI(m1307i));
	
	wire em383,mpyj383,c383;
	wire signed [nb+2:0] m383r,m383i;	  
	assign	em383 = ((ct==3) || (ct==7));	//control signals for the multiplier 
	assign   mpyj383 = ((ct==7));  
	assign c383 = (ct==3);
	MPUC924_383  #(nb+3) UM383(.CLK(CLK),.ED(ED),.DS(em383),.MPYJ(mpyj383),.C383(c383),	 //multiplier by 0.383
		.DR(s7r),.DI(s7i) ,.DOR(m383r) ,.DOI(m383i));
	
	reg signed [nb+2:0] m8_17r,m8_17i,m9_16r,m9_16i;	  
	always @(posedge CLK)	begin		  //Reg-s
			if	(ED) begin
					if (ct==4 || ct==8) begin
							m9_16r<=m541r;						//M9_ M16
							m9_16i<=m541i;
						end 
					if ( ct==6 || ct==10) begin
							m8_17r<=m1307r;	  				//M8_ M17
							m8_17i<=m1307i;
						end 
				end 		  
		end 		  		
	
	
	
	
	reg 	signed [nb+2:0]	s8r,s8i,s8d1r,s8d2r,s8d3r,s8d4r,s8d1i,s8d2i,s8d3i,s8d4i	;
	always @ (posedge CLK)	begin		 //  S8--  adder
			if (ED)  
				case  (ct) 
					5,9: begin s8r<=m4_12r +m707r ;	  // --	 S5	 S13
						s8i<=m4_12i +m707i  ;end	   //--	 
					6,10: begin  
							s8r<=m4_12r - m707r ;	  // --	 S6	, S14
						s8i<=m4_12i - m707i  ; end
					7:  begin	  
							s8r<=m8_17r - m383r ;	  // --	 S7	 ,S15
						s8i<=m8_17i -m383i  ;  end
					8:  begin 
							s8r<=m9_16r - m383r ;	  // --	 S8	,	S16
						s8i<=m9_16i -m383i  ;  	end    
					11:  begin	  
							s8r<=m383r - m9_16r  ;	  // --	 S7	 ,S15
						s8i<=m383i -   m9_16i;  end
					12:  begin 
							s8r<=m383r - m8_17r;	  // --	 S8	,	S16
						s8i<=m383i - m8_17i;  	end   
				endcase	  
			s8d1r<=s8r;		s8d1i<=s8i;	    s8d2r<=s8d1r;	s8d2i<=s8d1i;	  
			s8d3r<=s8d2r;	s8d3i<=s8d2i;	s8d4r<=s8d3r;	s8d4i<=s8d3i;
		end	
	
	reg 	signed [nb+3:0]	s9r,s9d1r,s9d2r,s9d3r,s9d4r,s9d5r,s9d6r,s9d7r,s9d8r,s9d9r, s9d10r,s9d11r,s9d12r,s9d13r;
	reg 	signed [nb+3:0]	s9i,s9d1i,s9d2i,s9d3i,s9d4i,s9d5i,s9d6i,s9d7i,s9d8i,s9d9i,s9d10i,s9d11i,s9d12i,s9d13i;
	always @ (posedge CLK)		     // 	ALU s9:
		if (ED)	 begin 
				case  (ct) 
				8,9,12: begin 	s9r<=  s8r + s8d2r;	// S9,S11	 , S17
					s9i<=s8i + s8d2i  ; end
				13: begin 	s9r<=  s8d2r - s8r;	// S20
					s9i<=s8d2i - s8i ; end
				10,11,14: begin 	s9r<=s8d4r - s8d2r;	 //S10, S12,S18
					s9i<=s8d4i - s8d2i;	end		
				15: begin 	s9r<=s8d4r + s8d2r;	 //S19
				s9i<=s8d4i + s8d2i;	end							  
				endcase	 		
				
				s9d1r<=s9r;		s9d1i<=s9i;	    s9d2r<=s9d1r;	s9d2i<=s9d1i;	  
				s9d3r<=s9d2r;	s9d3i<=s9d2i;	s9d4r<=s9d3r;	s9d4i<=s9d3i;
				s9d5r<=s9d4r;	s9d5i<=s9d4i;	s9d6r<=s9d5r;	s9d6i<=s9d5i;
				s9d7r<=s9d6r;	s9d7i<=s9d6i;	s9d8r<=s9d7r;	s9d8i<=s9d7i;	 
				
				s9d9r<=s9d8r ;	 s9d9i<=s9d8i ;	
				if ((ct!=8)) begin
					s9d10r<=s9d9r ;	 s9d10i<=s9d9i ;
					s9d11r<=s9d10r ;	 s9d11i<=s9d10i ;  end	
				if ((ct==4) ||(ct==5) ||(ct==7) ||(ct==9) )  begin
					s9d12r<=s9d11r ;	 s9d12i<=s9d11i ;	end
				if ((ct==5))begin
					s9d13r<=s9d12r ;	 s9d13i<=s9d12i ;	end
				
			end	   


	reg 	signed [nb+3:0]	s10r,s10i;
	reg 	signed [nb+3:0]	s10dr,s10di;

			`ifdef FFT256paramifft		//For IFFT
	always @ (posedge CLK)	begin		 //  S10-- result adder
			if (ED)  
				case  (ct) 
					13: begin s10r<=s9d4r -s9r ;	  // --	 Y1
						s10i<=s9d4i -s9i ;end	   //
					15:  begin 
							s10r<=s9d3r + s9d1r ;	             //--	 Y3
						s10i<=s9d3i + s9d1i ; end	 
					1:   begin 
							s10r<=s9d7r - s9d1r ;	         //--	 Y5
						s10i<=s9d7i - s9d1i ;	   end
					3:   begin 
							s10r<=s9d8r + s9d4r ;	               // --	 Y7
						s10i<= s9d8i + s9d4i ;end	   
					
					5:begin	s10r<=s9d10r - s9d6r ;	    //--	 Y9
					    s10i<=s9d10i - s9d6i ; end
					7:   begin 
							s10r<=s9d12r + s9d7r ;	              //--	 Y11
						s10i<=s9d12i + s9d7i ; end	   
					
					9:  begin 
							s10r<= s9d12r - s9d10r ;	        //	 Y13
						s10i<=s9d12i - s9d10i ;	end
					
					11:   begin 
							s10r<= s9d13r + s9d12r ;	         //	 Y15
						s10i<=  s9d13i + s9d12i ;	end
					
				endcase		 
			s10dr<=s10r; s10di<=s10i;
		end	
	`else
		
//	reg signed [nb+3:0]	s10r,s10i,s10dr,s10di;
	always @ (posedge CLK)	begin		 //  S10-- result adder
			if (ED)  
				case  (ct) 
					13: begin s10r<=s9d4r +s9r ;	  // --	 Y0
						s10i<=s9d4i +s9i ;end	   //
					15:  begin 
							s10r<=s9d3r - s9d1r ;	             //--	 Y3
						s10i<=s9d3i - s9d1i ; end	 
					1:   begin 
							s10r<=s9d7r +s9d1r ;	         //--	 Y5
						s10i<=s9d7i +s9d1i ;	   end
					3:   begin 
							s10r<=s9d8r - s9d4r ;	               // --	 Y7
						s10i<= s9d8i - s9d4i ;end	   
					
					5:begin	s10r<=s9d10r + s9d6r ;	    //--	 Y9
						s10i<=s9d10i + s9d6i ; end
					7:   begin 
							s10r<=s9d12r - s9d7r ;	              //--	 Y11
						s10i<=s9d12i - s9d7i ; end	   
					
					9:  begin 
							s10r<= s9d12r + s9d10r ;	        //	 Y13
						s10i<=s9d12i + s9d10i ;	end
					
					11:   begin 
							s10r<= s9d13r - s9d12r ;	         //	 Y15
						s10i<=  s9d13i - s9d12i ;	end
					
				endcase		 
			s10dr<=s10r; s10di<=s10i;
		end	  
		`endif 		 
		
//wire signed [nb+3:0]	s6sr,s6si;	  //saturation of results
//	assign s6sr = (~s6r[nb+4]&&s6r[nb+3])? ((1'b1 <<(nb+3))-1)	: s6r[nb+3:0];	
//	assign s6si = (~s6i[nb+4]&&s6i[nb+3])? ((1'b1<<(nb+3))-1)	    : s6i[nb+3:0];	
//
	
	wire selo;
	assign selo = ct-(ct/2)*2;
		assign #1	DOR=selo? s10dr:s6r;
		assign #1	DOI= selo? s10di:s6i;
	
endmodule
