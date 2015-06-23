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
// DESCRIPTION	:	Twiddle factor ROM for 128-point FFT
// FUNCTION:	 	
// FILES:			 WROM128.v - ROM of twiddle factors.	   
//  PROPERTIES: 1) Has 128 complex coefficients which form a table 8x16,
//                         and stay in the needed order, as they are addressed
//                         by the simple counter 
//							2) 16-bit values are stored. When shorter bit width is set
//                            then rounding	is not used
//							3) for FFT and IFFT depending on paramifft	       
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
`include "FFT128_CONFIG.inc"	 
`timescale 1 ns / 1 ps  
module WROM128 ( WI ,WR ,ADDR );
	`FFT128paramnw	
	
	input [6:0] ADDR ;
	wire [6:0] ADDR ;
	
	output [nw-1:0] WI ;
	wire [nw-1:0] WI ;
	output [nw-1:0] WR ;
	wire [nw-1:0] WR ;
	
	wire [15:0] cosw[0:127];    
assign cosw[0]=16'h7FFF;assign cosw[1]=16'h7FFF;assign cosw[2]=16'h7FFF;assign cosw[3]=16'h7FFF;assign cosw[4]=16'h7FFF;assign cosw[5]=16'h7FFF;assign cosw[6]=16'h7FFF;assign cosw[7]=16'h7FFF;assign cosw[8]=16'h7FFF;assign cosw[9]=16'h7FFF;assign cosw[10]=16'h7FFF;assign cosw[11]=16'h7FFF;assign cosw[12]=16'h7FFF;assign cosw[13]=16'h7FFF;assign cosw[14]=16'h7FFF;assign cosw[15]=16'h7FFF;
assign cosw[16]=16'h7FFF;assign cosw[17]=16'h7FD7;assign cosw[18]=16'h7F61;assign cosw[19]=16'h7E9C;assign cosw[20]=16'h7D89;assign cosw[21]=16'h7C29;assign cosw[22]=16'h7A7C;assign cosw[23]=16'h7883;assign cosw[24]=16'h7640;assign cosw[25]=16'h73B5;assign cosw[26]=16'h70E1;assign cosw[27]=16'h6DC9;assign cosw[28]=16'h6A6C;assign cosw[29]=16'h66CE;assign cosw[30]=16'h62F1;assign cosw[31]=16'h5ED6;
assign cosw[32]=16'h7FFF;assign cosw[33]=16'h7F61;assign cosw[34]=16'h7D89;assign cosw[35]=16'h7A7C;assign cosw[36]=16'h7640;assign cosw[37]=16'h70E1;assign cosw[38]=16'h6A6C;assign cosw[39]=16'h62F1;assign cosw[40]=16'h5A81;assign cosw[41]=16'h5133;assign cosw[42]=16'h471C;assign cosw[43]=16'h3C56;assign cosw[44]=16'h30FB;assign cosw[45]=16'h2527;assign cosw[46]=16'h18F8;assign cosw[47]=16'h0C8B;
assign cosw[48]=16'h7FFF;assign cosw[49]=16'h7E9C;assign cosw[50]=16'h7A7C;assign cosw[51]=16'h73B5;assign cosw[52]=16'h6A6C;assign cosw[53]=16'h5ED6;assign cosw[54]=16'h5133;assign cosw[55]=16'h41CD;assign cosw[56]=16'h30FB;assign cosw[57]=16'h1F19;assign cosw[58]=16'h0C8B;assign cosw[59]=16'hF9B9;assign cosw[60]=16'hE708;assign cosw[61]=16'hD4E2;assign cosw[62]=16'hC3AA;assign cosw[63]=16'hB3C1;
assign cosw[64]=16'h7FFF;assign cosw[65]=16'h7D89;assign cosw[66]=16'h7640;assign cosw[67]=16'h6A6C;assign cosw[68]=16'h5A81;assign cosw[69]=16'h471C;assign cosw[70]=16'h30FB;assign cosw[71]=16'h18F8;assign cosw[72]=16'h0000;assign cosw[73]=16'hE708;assign cosw[74]=16'hCF05;assign cosw[75]=16'hB8E4;assign cosw[76]=16'hA57F;assign cosw[77]=16'h9594;assign cosw[78]=16'h89C0;assign cosw[79]=16'h8277;
assign cosw[80]=16'h7FFF;assign cosw[81]=16'h7C29;assign cosw[82]=16'h70E1;assign cosw[83]=16'h5ED6;assign cosw[84]=16'h471C;assign cosw[85]=16'h2B1E;assign cosw[86]=16'h0C8B;assign cosw[87]=16'hED39;assign cosw[88]=16'hCF05;assign cosw[89]=16'hB3C1;assign cosw[90]=16'h9D0F;assign cosw[91]=16'h8C4B;assign cosw[92]=16'h8277;assign cosw[93]=16'h8029;assign cosw[94]=16'h8584;assign cosw[95]=16'h9237;
assign cosw[96]=16'h7FFF;assign cosw[97]=16'h7A7C;assign cosw[98]=16'h6A6C;assign cosw[99]=16'h5133;assign cosw[100]=16'h30FB;assign cosw[101]=16'h0C8B;assign cosw[102]=16'hE708;assign cosw[103]=16'hC3AA;assign cosw[104]=16'hA57F;assign cosw[105]=16'h8F1F;assign cosw[106]=16'h8277;assign cosw[107]=16'h809F;assign cosw[108]=16'h89C0;assign cosw[109]=16'h9D0F;assign cosw[110]=16'hB8E4;assign cosw[111]=16'hDAD9;
assign cosw[112]=16'h7FFF;assign cosw[113]=16'h7883;assign cosw[114]=16'h62F1;assign cosw[115]=16'h41CD;assign cosw[116]=16'h18F8;assign cosw[117]=16'hED39;assign cosw[118]=16'hC3AA;assign cosw[119]=16'hA12A;assign cosw[120]=16'h89C0;assign cosw[121]=16'h8029;assign cosw[122]=16'h8584;assign cosw[123]=16'h9932;assign cosw[124]=16'hB8E4;assign cosw[125]=16'hE0E7;assign cosw[126]=16'h0C8B;assign cosw[127]=16'h36B9;

	wire [15:0] sinw[0:127];    
	
	`ifdef FFT256paramifft			 //Inverse FFT
assign  sinw[0]=16'h0000;assign  sinw[1]=16'h0000;assign  sinw[2]=16'h0000;assign  sinw[3]=16'h0000;assign  sinw[4]=16'h0000;assign  sinw[5]=16'h0000;assign  sinw[6]=16'h0000;assign  sinw[7]=16'h0000;assign  sinw[8]=16'h0000;assign  sinw[9]=16'h0000;assign  sinw[10]=16'h0000;assign  sinw[11]=16'h0000;assign  sinw[12]=16'h0000;assign  sinw[13]=16'h0000;assign  sinw[14]=16'h0000;assign  sinw[15]=16'h0000;
assign  sinw[16]=16'h0000;assign  sinw[17]=16'h0647;assign  sinw[18]=16'h0C8B;assign  sinw[19]=16'h12C7;assign  sinw[20]=16'h18F8;assign  sinw[21]=16'h1F19;assign  sinw[22]=16'h2527;assign  sinw[23]=16'h2B1E;assign  sinw[24]=16'h30FB;assign  sinw[25]=16'h36B9;assign  sinw[26]=16'h3C56;assign  sinw[27]=16'h41CD;assign  sinw[28]=16'h471C;assign  sinw[29]=16'h4C3F;assign  sinw[30]=16'h5133;assign  sinw[31]=16'h55F4;
assign  sinw[32]=16'h0000;assign  sinw[33]=16'h0C8B;assign  sinw[34]=16'h18F8;assign  sinw[35]=16'h2527;assign  sinw[36]=16'h30FB;assign  sinw[37]=16'h3C56;assign  sinw[38]=16'h471C;assign  sinw[39]=16'h5133;assign  sinw[40]=16'h5A81;assign  sinw[41]=16'h62F1;assign  sinw[42]=16'h6A6C;assign  sinw[43]=16'h70E1;assign  sinw[44]=16'h7640;assign  sinw[45]=16'h7A7C;assign  sinw[46]=16'h7D89;assign  sinw[47]=16'h7F61;
assign  sinw[48]=16'h0000;assign  sinw[49]=16'h12C7;assign  sinw[50]=16'h2527;assign  sinw[51]=16'h36B9;assign  sinw[52]=16'h471C;assign  sinw[53]=16'h55F4;assign  sinw[54]=16'h62F1;assign  sinw[55]=16'h6DC9;assign  sinw[56]=16'h7640;assign  sinw[57]=16'h7C29;assign  sinw[58]=16'h7F61;assign  sinw[59]=16'h7FD7;assign  sinw[60]=16'h7D89;assign  sinw[61]=16'h7883;assign  sinw[62]=16'h70E1;assign  sinw[63]=16'h66CE;
assign  sinw[64]=16'h0000;assign  sinw[65]=16'h18F8;assign  sinw[66]=16'h30FB;assign  sinw[67]=16'h471C;assign  sinw[68]=16'h5A81;assign  sinw[69]=16'h6A6C;assign  sinw[70]=16'h7640;assign  sinw[71]=16'h7D89;assign  sinw[72]=16'h7FFF;assign  sinw[73]=16'h7D89;assign  sinw[74]=16'h7640;assign  sinw[75]=16'h6A6C;assign  sinw[76]=16'h5A81;assign  sinw[77]=16'h471C;assign  sinw[78]=16'h30FB;assign  sinw[79]=16'h18F8;
assign  sinw[80]=16'h0000;assign  sinw[81]=16'h1F19;assign  sinw[82]=16'h3C56;assign  sinw[83]=16'h55F4;assign  sinw[84]=16'h6A6C;assign  sinw[85]=16'h7883;assign  sinw[86]=16'h7F61;assign  sinw[87]=16'h7E9C;assign  sinw[88]=16'h7640;assign  sinw[89]=16'h66CE;assign  sinw[90]=16'h5133;assign  sinw[91]=16'h36B9;assign  sinw[92]=16'h18F8;assign  sinw[93]=16'hF9B9;assign  sinw[94]=16'hDAD9;assign  sinw[95]=16'hBE33;
assign  sinw[96]=16'h0000;assign  sinw[97]=16'h2527;assign  sinw[98]=16'h471C;assign  sinw[99]=16'h62F1;assign  sinw[100]=16'h7640;assign  sinw[101]=16'h7F61;assign  sinw[102]=16'h7D89;assign  sinw[103]=16'h70E1;assign  sinw[104]=16'h5A81;assign  sinw[105]=16'h3C56;assign  sinw[106]=16'h18F8;assign  sinw[107]=16'hF375;assign  sinw[108]=16'hCF05;assign  sinw[109]=16'hAECD;assign  sinw[110]=16'h9594;assign  sinw[111]=16'h8584;
assign  sinw[112]=16'h0000;assign  sinw[113]=16'h2B1E;assign  sinw[114]=16'h5133;assign  sinw[115]=16'h6DC9;assign  sinw[116]=16'h7D89;assign  sinw[117]=16'h7E9C;assign  sinw[118]=16'h70E1;assign  sinw[119]=16'h55F4;assign  sinw[120]=16'h30FB;assign  sinw[121]=16'h0647;assign  sinw[122]=16'hDAD9;assign  sinw[123]=16'hB3C1;assign  sinw[124]=16'h9594;assign  sinw[125]=16'h83D7;assign  sinw[126]=16'h809F;assign  sinw[127]=16'h8C4B;
	
	`else		  //Forward FFT

assign  sinw[0]=16'h0000;assign  sinw[1]=16'h0000;assign  sinw[2]=16'h0000;assign  sinw[3]=16'h0000;assign  sinw[4]=16'h0000;assign  sinw[5]=16'h0000;assign  sinw[6]=16'h0000;assign  sinw[7]=16'h0000;assign  sinw[8]=16'h0000;assign  sinw[9]=16'h0000;assign  sinw[10]=16'h0000;assign  sinw[11]=16'h0000;assign  sinw[12]=16'h0000;assign  sinw[13]=16'h0000;assign  sinw[14]=16'h0000;assign  sinw[15]=16'h0000;
assign  sinw[16]=16'h0000;assign  sinw[17]=16'hF9B9;assign  sinw[18]=16'hF375;assign  sinw[19]=16'hED39;assign  sinw[20]=16'hE708;assign  sinw[21]=16'hE0E7;assign  sinw[22]=16'hDAD9;assign  sinw[23]=16'hD4E2;assign  sinw[24]=16'hCF05;assign  sinw[25]=16'hC947;assign  sinw[26]=16'hC3AA;assign  sinw[27]=16'hBE33;assign  sinw[28]=16'hB8E4;assign  sinw[29]=16'hB3C1;assign  sinw[30]=16'hAECD;assign  sinw[31]=16'hAA0C;
assign  sinw[32]=16'h0000;assign  sinw[33]=16'hF375;assign  sinw[34]=16'hE708;assign  sinw[35]=16'hDAD9;assign  sinw[36]=16'hCF05;assign  sinw[37]=16'hC3AA;assign  sinw[38]=16'hB8E4;assign  sinw[39]=16'hAECD;assign  sinw[40]=16'hA57F;assign  sinw[41]=16'h9D0F;assign  sinw[42]=16'h9594;assign  sinw[43]=16'h8F1F;assign  sinw[44]=16'h89C0;assign  sinw[45]=16'h8584;assign  sinw[46]=16'h8277;assign  sinw[47]=16'h809F;
assign  sinw[48]=16'h0000;assign  sinw[49]=16'hED39;assign  sinw[50]=16'hDAD9;assign  sinw[51]=16'hC947;assign  sinw[52]=16'hB8E4;assign  sinw[53]=16'hAA0C;assign  sinw[54]=16'h9D0F;assign  sinw[55]=16'h9237;assign  sinw[56]=16'h89C0;assign  sinw[57]=16'h83D7;assign  sinw[58]=16'h809F;assign  sinw[59]=16'h8029;assign  sinw[60]=16'h8277;assign  sinw[61]=16'h877D;assign  sinw[62]=16'h8F1F;assign  sinw[63]=16'h9932;
assign  sinw[64]=16'h0000;assign  sinw[65]=16'hE708;assign  sinw[66]=16'hCF05;assign  sinw[67]=16'hB8E4;assign  sinw[68]=16'hA57F;assign  sinw[69]=16'h9594;assign  sinw[70]=16'h89C0;assign  sinw[71]=16'h8277;assign  sinw[72]=16'h8001;assign  sinw[73]=16'h8277;assign  sinw[74]=16'h89C0;assign  sinw[75]=16'h9594;assign  sinw[76]=16'hA57F;assign  sinw[77]=16'hB8E4;assign  sinw[78]=16'hCF05;assign  sinw[79]=16'hE708;
assign  sinw[80]=16'h0000;assign  sinw[81]=16'hE0E7;assign  sinw[82]=16'hC3AA;assign  sinw[83]=16'hAA0C;assign  sinw[84]=16'h9594;assign  sinw[85]=16'h877D;assign  sinw[86]=16'h809F;assign  sinw[87]=16'h8164;assign  sinw[88]=16'h89C0;assign  sinw[89]=16'h9932;assign  sinw[90]=16'hAECD;assign  sinw[91]=16'hC947;assign  sinw[92]=16'hE708;assign  sinw[93]=16'h0647;assign  sinw[94]=16'h2527;assign  sinw[95]=16'h41CD;
assign  sinw[96]=16'h0000;assign  sinw[97]=16'hDAD9;assign  sinw[98]=16'hB8E4;assign  sinw[99]=16'h9D0F;assign  sinw[100]=16'h89C0;assign  sinw[101]=16'h809F;assign  sinw[102]=16'h8277;assign  sinw[103]=16'h8F1F;assign  sinw[104]=16'hA57F;assign  sinw[105]=16'hC3AA;assign  sinw[106]=16'hE708;assign  sinw[107]=16'h0C8B;assign  sinw[108]=16'h30FB;assign  sinw[109]=16'h5133;assign  sinw[110]=16'h6A6C;assign  sinw[111]=16'h7A7C;
assign  sinw[112]=16'h0000;assign  sinw[113]=16'hD4E2;assign  sinw[114]=16'hAECD;assign  sinw[115]=16'h9237;assign  sinw[116]=16'h8277;assign  sinw[117]=16'h8164;assign  sinw[118]=16'h8F1F;assign  sinw[119]=16'hAA0C;assign  sinw[120]=16'hCF05;assign  sinw[121]=16'hF9B9;assign  sinw[122]=16'h2527;assign  sinw[123]=16'h4C3F;assign  sinw[124]=16'h6A6C;assign  sinw[125]=16'h7C29;assign  sinw[126]=16'h7F61;assign  sinw[127]=16'h73B5;
  	   	`endif

	
	wire [15:0] wri,wii 	  ;
	assign wri=cosw[ADDR];	
	assign wii=sinw[ADDR];		
	
	wire [nw:0] wrt,wit;
	

	assign	wrt = wri[15:16-nw];
	assign	wit = wii[15:16-nw];
	assign WR= wrt[nw-1:0];	  
	assign WI= wit[nw-1:0];
	
endmodule   
