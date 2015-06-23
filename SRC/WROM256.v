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
// DESCRIPTION	:	Twiddle factor ROM for 256-point FFT
// FUNCTION:	 	
// FILES:			 WROM64.v - ROM of twiddle factors.	   
//  PROPERTIES: 1) Has 64 complex coefficients which form a table 8x8,
//                         and stay in the needed order, as they are addressed
//                         by the simple counter 
//							2) 16-bit values are stored. When shorter bit width is set
//                            then rounding	is not used
//							3) for FFT and IFFT depending on paramifft	       
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
`include "FFT256_CONFIG.inc"	 
`timescale 1 ns / 1 ps  
module WROM256 ( WI ,WR ,ADDR );
	`FFT256paramnw	
	
	input [7:0] ADDR ;
	wire [7:0] ADDR ;
	
	output [nw-1:0] WI ;
	wire [nw-1:0] WI ;
	output [nw-1:0] WR ;
	wire [nw-1:0] WR ;
	
	wire [15:0] cosw[0:255];    
	assign cosw[0]=16'h7FFF; assign cosw[1]=16'h7FFF; assign cosw[2]=16'h7FFF; assign cosw[3]=16'h7FFF; assign cosw[4]=16'h7FFF; assign cosw[5]=16'h7FFF; assign cosw[6]=16'h7FFF; assign cosw[7]=16'h7FFF; assign cosw[8]=16'h7FFF; assign cosw[9]=16'h7FFF; assign cosw[10]=16'h7FFF; assign cosw[11]=16'h7FFF; assign cosw[12]=16'h7FFF; assign cosw[13]=16'h7FFF; assign cosw[14]=16'h7FFF; assign cosw[15]=16'h7FFF;
	assign cosw[16]=16'h7FFF; assign cosw[17]=16'h7FF5; assign cosw[18]=16'h7FD7; assign cosw[19]=16'h7FA6; assign cosw[20]=16'h7F61; assign cosw[21]=16'h7F08; assign cosw[22]=16'h7E9C; assign cosw[23]=16'h7E1C; assign cosw[24]=16'h7D89; assign cosw[25]=16'h7CE2; assign cosw[26]=16'h7C29; assign cosw[27]=16'h7B5C; assign cosw[28]=16'h7A7C; assign cosw[29]=16'h7989; assign cosw[30]=16'h7883; assign cosw[31]=16'h776B;
	assign cosw[32]=16'h7FFF; assign cosw[33]=16'h7FD7; assign cosw[34]=16'h7F61; assign cosw[35]=16'h7E9C; assign cosw[36]=16'h7D89; assign cosw[37]=16'h7C29; assign cosw[38]=16'h7A7C; assign cosw[39]=16'h7883; assign cosw[40]=16'h7640; assign cosw[41]=16'h73B5; assign cosw[42]=16'h70E1; assign cosw[43]=16'h6DC9; assign cosw[44]=16'h6A6C; assign cosw[45]=16'h66CE; assign cosw[46]=16'h62F1; assign cosw[47]=16'h5ED6;
	assign cosw[48]=16'h7FFF; assign cosw[49]=16'h7FA6; assign cosw[50]=16'h7E9C; assign cosw[51]=16'h7CE2; assign cosw[52]=16'h7A7C; assign cosw[53]=16'h776B; assign cosw[54]=16'h73B5; assign cosw[55]=16'h6F5E; assign cosw[56]=16'h6A6C; assign cosw[57]=16'h64E7; assign cosw[58]=16'h5ED6; assign cosw[59]=16'h5842; assign cosw[60]=16'h5133; assign cosw[61]=16'h49B3; assign cosw[62]=16'h41CD; assign cosw[63]=16'h398C;
	assign cosw[64]=16'h7FFF; assign cosw[65]=16'h7F61; assign cosw[66]=16'h7D89; assign cosw[67]=16'h7A7C; assign cosw[68]=16'h7640; assign cosw[69]=16'h70E1; assign cosw[70]=16'h6A6C; assign cosw[71]=16'h62F1; assign cosw[72]=16'h5A81; assign cosw[73]=16'h5133; assign cosw[74]=16'h471C; assign cosw[75]=16'h3C56; assign cosw[76]=16'h30FB; assign cosw[77]=16'h2527; assign cosw[78]=16'h18F8; assign cosw[79]=16'h0C8B;
	assign cosw[80]=16'h7FFF; assign cosw[81]=16'h7F08; assign cosw[82]=16'h7C29; assign cosw[83]=16'h776B; assign cosw[84]=16'h70E1; assign cosw[85]=16'h68A5; assign cosw[86]=16'h5ED6; assign cosw[87]=16'h539A; assign cosw[88]=16'h471C; assign cosw[89]=16'h398C; assign cosw[90]=16'h2B1E; assign cosw[91]=16'h1C0B; assign cosw[92]=16'h0C8B; assign cosw[93]=16'hFCDC; assign cosw[94]=16'hED39; assign cosw[95]=16'hDDDD;
	assign cosw[96]=16'h7FFF; assign cosw[97]=16'h7E9C; assign cosw[98]=16'h7A7C; assign cosw[99]=16'h73B5; assign cosw[100]=16'h6A6C; assign cosw[101]=16'h5ED6; assign cosw[102]=16'h5133; assign cosw[103]=16'h41CD; assign cosw[104]=16'h30FB; assign cosw[105]=16'h1F19; assign cosw[106]=16'h0C8B; assign cosw[107]=16'hF9B9; assign cosw[108]=16'hE708; assign cosw[109]=16'hD4E2; assign cosw[110]=16'hC3AA; assign cosw[111]=16'hB3C1;
	assign cosw[112]=16'h7FFF; assign cosw[113]=16'h7E1C; assign cosw[114]=16'h7883; assign cosw[115]=16'h6F5E; assign cosw[116]=16'h62F1; assign cosw[117]=16'h539A; assign cosw[118]=16'h41CD; assign cosw[119]=16'h2E10; assign cosw[120]=16'h18F8; assign cosw[121]=16'h0324; assign cosw[122]=16'hED39; assign cosw[123]=16'hD7DA; assign cosw[124]=16'hC3AA; assign cosw[125]=16'hB141; assign cosw[126]=16'hA12A; assign cosw[127]=16'h93DD;
	assign cosw[128]=16'h7FFF; assign cosw[129]=16'h7D89; assign cosw[130]=16'h7640; assign cosw[131]=16'h6A6C; assign cosw[132]=16'h5A81; assign cosw[133]=16'h471C; assign cosw[134]=16'h30FB; assign cosw[135]=16'h18F8; assign cosw[136]=16'h0000; assign cosw[137]=16'hE708; assign cosw[138]=16'hCF05; assign cosw[139]=16'hB8E4; assign cosw[140]=16'hA57F; assign cosw[141]=16'h9594; assign cosw[142]=16'h89C0; assign cosw[143]=16'h8277;
	assign cosw[144]=16'h7FFF; assign cosw[145]=16'h7CE2; assign cosw[146]=16'h73B5; assign cosw[147]=16'h64E7; assign cosw[148]=16'h5133; assign cosw[149]=16'h398C; assign cosw[150]=16'h1F19; assign cosw[151]=16'h0324; assign cosw[152]=16'hE708; assign cosw[153]=16'hCC22; assign cosw[154]=16'hB3C1; assign cosw[155]=16'h9F15; assign cosw[156]=16'h8F1F; assign cosw[157]=16'h84A4; assign cosw[158]=16'h8029; assign cosw[159]=16'h81E4;
	assign cosw[160]=16'h7FFF; assign cosw[161]=16'h7C29; assign cosw[162]=16'h70E1; assign cosw[163]=16'h5ED6; assign cosw[164]=16'h471C; assign cosw[165]=16'h2B1E; assign cosw[166]=16'h0C8B; assign cosw[167]=16'hED39; assign cosw[168]=16'hCF05; assign cosw[169]=16'hB3C1; assign cosw[170]=16'h9D0F; assign cosw[171]=16'h8C4B; assign cosw[172]=16'h8277; assign cosw[173]=16'h8029; assign cosw[174]=16'h8584; assign cosw[175]=16'h9237;
	assign cosw[176]=16'h7FFF; assign cosw[177]=16'h7B5C; assign cosw[178]=16'h6DC9; assign cosw[179]=16'h5842; assign cosw[180]=16'h3C56; assign cosw[181]=16'h1C0B; assign cosw[182]=16'hF9B9; assign cosw[183]=16'hD7DA; assign cosw[184]=16'hB8E4; assign cosw[185]=16'h9F15; assign cosw[186]=16'h8C4B; assign cosw[187]=16'h81E4; assign cosw[188]=16'h809F; assign cosw[189]=16'h8895; assign cosw[190]=16'h9932; assign cosw[191]=16'hB141;
	assign cosw[192]=16'h7FFF; assign cosw[193]=16'h7A7C; assign cosw[194]=16'h6A6C; assign cosw[195]=16'h5133; assign cosw[196]=16'h30FB; assign cosw[197]=16'h0C8B; assign cosw[198]=16'hE708; assign cosw[199]=16'hC3AA; assign cosw[200]=16'hA57F; assign cosw[201]=16'h8F1F; assign cosw[202]=16'h8277; assign cosw[203]=16'h809F; assign cosw[204]=16'h89C0; assign cosw[205]=16'h9D0F; assign cosw[206]=16'hB8E4; assign cosw[207]=16'hDAD9;
	assign cosw[208]=16'h7FFF; assign cosw[209]=16'h7989; assign cosw[210]=16'h66CE; assign cosw[211]=16'h49B3; assign cosw[212]=16'h2527; assign cosw[213]=16'hFCDC; assign cosw[214]=16'hD4E2; assign cosw[215]=16'hB141; assign cosw[216]=16'h9594; assign cosw[217]=16'h84A4; assign cosw[218]=16'h8029; assign cosw[219]=16'h8895; assign cosw[220]=16'h9D0F; assign cosw[221]=16'hBB86; assign cosw[222]=16'hE0E7; assign cosw[223]=16'h096A;
	assign cosw[224]=16'h7FFF; assign cosw[225]=16'h7883; assign cosw[226]=16'h62F1; assign cosw[227]=16'h41CD; assign cosw[228]=16'h18F8; assign cosw[229]=16'hED39; assign cosw[230]=16'hC3AA; assign cosw[231]=16'hA12A; assign cosw[232]=16'h89C0; assign cosw[233]=16'h8029; assign cosw[234]=16'h8584; assign cosw[235]=16'h9932; assign cosw[236]=16'hB8E4; assign cosw[237]=16'hE0E7; assign cosw[238]=16'h0C8B; assign cosw[239]=16'h36B9;
	assign cosw[240]=16'h7FFF; assign cosw[241]=16'h776B; assign cosw[242]=16'h5ED6; assign cosw[243]=16'h398C; assign cosw[244]=16'h0C8B; assign cosw[245]=16'hDDDD; assign cosw[246]=16'hB3C1; assign cosw[247]=16'h93DD; assign cosw[248]=16'h8277; assign cosw[249]=16'h81E4; assign cosw[250]=16'h9237; assign cosw[251]=16'hB141; assign cosw[252]=16'hDAD9; assign cosw[253]=16'h096A; assign cosw[254]=16'h36B9; assign cosw[255]=16'h5CB3;

	wire [15:0] sinw[0:255];    
	
	`ifdef FFT256paramifft			 //Inverse FFT
	assign sinw[0]=16'h0000; assign sinw[1]=16'h0000; assign sinw[2]=16'h0000; assign sinw[3]=16'h0000; assign sinw[4]=16'h0000; assign sinw[5]=16'h0000; assign sinw[6]=16'h0000; assign sinw[7]=16'h0000; assign sinw[8]=16'h0000; assign sinw[9]=16'h0000; assign sinw[10]=16'h0000; assign sinw[11]=16'h0000; assign sinw[12]=16'h0000; assign sinw[13]=16'h0000; assign sinw[14]=16'h0000; assign sinw[15]=16'h0000;
	assign sinw[16]=16'h0000; assign sinw[17]=16'h0324; assign sinw[18]=16'h0647; assign sinw[19]=16'h096A; assign sinw[20]=16'h0C8B; assign sinw[21]=16'h0FAB; assign sinw[22]=16'h12C7; assign sinw[23]=16'h15E1; assign sinw[24]=16'h18F8; assign sinw[25]=16'h1C0B; assign sinw[26]=16'h1F19; assign sinw[27]=16'h2223; assign sinw[28]=16'h2527; assign sinw[29]=16'h2826; assign sinw[30]=16'h2B1E; assign sinw[31]=16'h2E10;
	assign sinw[32]=16'h0000; assign sinw[33]=16'h0647; assign sinw[34]=16'h0C8B; assign sinw[35]=16'h12C7; assign sinw[36]=16'h18F8; assign sinw[37]=16'h1F19; assign sinw[38]=16'h2527; assign sinw[39]=16'h2B1E; assign sinw[40]=16'h30FB; assign sinw[41]=16'h36B9; assign sinw[42]=16'h3C56; assign sinw[43]=16'h41CD; assign sinw[44]=16'h471C; assign sinw[45]=16'h4C3F; assign sinw[46]=16'h5133; assign sinw[47]=16'h55F4;
	assign sinw[48]=16'h0000; assign sinw[49]=16'h096A; assign sinw[50]=16'h12C7; assign sinw[51]=16'h1C0B; assign sinw[52]=16'h2527; assign sinw[53]=16'h2E10; assign sinw[54]=16'h36B9; assign sinw[55]=16'h3F16; assign sinw[56]=16'h471C; assign sinw[57]=16'h4EBF; assign sinw[58]=16'h55F4; assign sinw[59]=16'h5CB3; assign sinw[60]=16'h62F1; assign sinw[61]=16'h68A5; assign sinw[62]=16'h6DC9; assign sinw[63]=16'h7254;
	assign sinw[64]=16'h0000; assign sinw[65]=16'h0C8B; assign sinw[66]=16'h18F8; assign sinw[67]=16'h2527; assign sinw[68]=16'h30FB; assign sinw[69]=16'h3C56; assign sinw[70]=16'h471C; assign sinw[71]=16'h5133; assign sinw[72]=16'h5A81; assign sinw[73]=16'h62F1; assign sinw[74]=16'h6A6C; assign sinw[75]=16'h70E1; assign sinw[76]=16'h7640; assign sinw[77]=16'h7A7C; assign sinw[78]=16'h7D89; assign sinw[79]=16'h7F61;
	assign sinw[80]=16'h0000; assign sinw[81]=16'h0FAB; assign sinw[82]=16'h1F19; assign sinw[83]=16'h2E10; assign sinw[84]=16'h3C56; assign sinw[85]=16'h49B3; assign sinw[86]=16'h55F4; assign sinw[87]=16'h60EB; assign sinw[88]=16'h6A6C; assign sinw[89]=16'h7254; assign sinw[90]=16'h7883; assign sinw[91]=16'h7CE2; assign sinw[92]=16'h7F61; assign sinw[93]=16'h7FF5; assign sinw[94]=16'h7E9C; assign sinw[95]=16'h7B5C;
	assign sinw[96]=16'h0000; assign sinw[97]=16'h12C7; assign sinw[98]=16'h2527; assign sinw[99]=16'h36B9; assign sinw[100]=16'h471C; assign sinw[101]=16'h55F4; assign sinw[102]=16'h62F1; assign sinw[103]=16'h6DC9; assign sinw[104]=16'h7640; assign sinw[105]=16'h7C29; assign sinw[106]=16'h7F61; assign sinw[107]=16'h7FD7; assign sinw[108]=16'h7D89; assign sinw[109]=16'h7883; assign sinw[110]=16'h70E1; assign sinw[111]=16'h66CE;
	assign sinw[112]=16'h0000; assign sinw[113]=16'h15E1; assign sinw[114]=16'h2B1E; assign sinw[115]=16'h3F16; assign sinw[116]=16'h5133; assign sinw[117]=16'h60EB; assign sinw[118]=16'h6DC9; assign sinw[119]=16'h776B; assign sinw[120]=16'h7D89; assign sinw[121]=16'h7FF5; assign sinw[122]=16'h7E9C; assign sinw[123]=16'h7989; assign sinw[124]=16'h70E1; assign sinw[125]=16'h64E7; assign sinw[126]=16'h55F4; assign sinw[127]=16'h447A;
	assign sinw[128]=16'h0000; assign sinw[129]=16'h18F8; assign sinw[130]=16'h30FB; assign sinw[131]=16'h471C; assign sinw[132]=16'h5A81; assign sinw[133]=16'h6A6C; assign sinw[134]=16'h7640; assign sinw[135]=16'h7D89; assign sinw[136]=16'h7FFF; assign sinw[137]=16'h7D89; assign sinw[138]=16'h7640; assign sinw[139]=16'h6A6C; assign sinw[140]=16'h5A81; assign sinw[141]=16'h471C; assign sinw[142]=16'h30FB; assign sinw[143]=16'h18F8;
	assign sinw[144]=16'h0000; assign sinw[145]=16'h1C0B; assign sinw[146]=16'h36B9; assign sinw[147]=16'h4EBF; assign sinw[148]=16'h62F1; assign sinw[149]=16'h7254; assign sinw[150]=16'h7C29; assign sinw[151]=16'h7FF5; assign sinw[152]=16'h7D89; assign sinw[153]=16'h7503; assign sinw[154]=16'h66CE; assign sinw[155]=16'h539A; assign sinw[156]=16'h3C56; assign sinw[157]=16'h2223; assign sinw[158]=16'h0647; assign sinw[159]=16'hEA1F;
	assign sinw[160]=16'h0000; assign sinw[161]=16'h1F19; assign sinw[162]=16'h3C56; assign sinw[163]=16'h55F4; assign sinw[164]=16'h6A6C; assign sinw[165]=16'h7883; assign sinw[166]=16'h7F61; assign sinw[167]=16'h7E9C; assign sinw[168]=16'h7640; assign sinw[169]=16'h66CE; assign sinw[170]=16'h5133; assign sinw[171]=16'h36B9; assign sinw[172]=16'h18F8; assign sinw[173]=16'hF9B9; assign sinw[174]=16'hDAD9; assign sinw[175]=16'hBE33;
	assign sinw[176]=16'h0000; assign sinw[177]=16'h2223; assign sinw[178]=16'h41CD; assign sinw[179]=16'h5CB3; assign sinw[180]=16'h70E1; assign sinw[181]=16'h7CE2; assign sinw[182]=16'h7FD7; assign sinw[183]=16'h7989; assign sinw[184]=16'h6A6C; assign sinw[185]=16'h539A; assign sinw[186]=16'h36B9; assign sinw[187]=16'h15E1; assign sinw[188]=16'hF375; assign sinw[189]=16'hD1F0; assign sinw[190]=16'hB3C1; assign sinw[191]=16'h9B19;
	assign sinw[192]=16'h0000; assign sinw[193]=16'h2527; assign sinw[194]=16'h471C; assign sinw[195]=16'h62F1; assign sinw[196]=16'h7640; assign sinw[197]=16'h7F61; assign sinw[198]=16'h7D89; assign sinw[199]=16'h70E1; assign sinw[200]=16'h5A81; assign sinw[201]=16'h3C56; assign sinw[202]=16'h18F8; assign sinw[203]=16'hF375; assign sinw[204]=16'hCF05; assign sinw[205]=16'hAECD; assign sinw[206]=16'h9594; assign sinw[207]=16'h8584;
	assign sinw[208]=16'h0000; assign sinw[209]=16'h2826; assign sinw[210]=16'h4C3F; assign sinw[211]=16'h68A5; assign sinw[212]=16'h7A7C; assign sinw[213]=16'h7FF5; assign sinw[214]=16'h7883; assign sinw[215]=16'h64E7; assign sinw[216]=16'h471C; assign sinw[217]=16'h2223; assign sinw[218]=16'hF9B9; assign sinw[219]=16'hD1F0; assign sinw[220]=16'hAECD; assign sinw[221]=16'h93DD; assign sinw[222]=16'h83D7; assign sinw[223]=16'h805A;
	assign sinw[224]=16'h0000; assign sinw[225]=16'h2B1E; assign sinw[226]=16'h5133; assign sinw[227]=16'h6DC9; assign sinw[228]=16'h7D89; assign sinw[229]=16'h7E9C; assign sinw[230]=16'h70E1; assign sinw[231]=16'h55F4; assign sinw[232]=16'h30FB; assign sinw[233]=16'h0647; assign sinw[234]=16'hDAD9; assign sinw[235]=16'hB3C1; assign sinw[236]=16'h9594; assign sinw[237]=16'h83D7; assign sinw[238]=16'h809F; assign sinw[239]=16'h8C4B;
	assign sinw[240]=16'h0000; assign sinw[241]=16'h2E10; assign sinw[242]=16'h55F4; assign sinw[243]=16'h7254; assign sinw[244]=16'h7F61; assign sinw[245]=16'h7B5C; assign sinw[246]=16'h66CE; assign sinw[247]=16'h447A; assign sinw[248]=16'h18F8; assign sinw[249]=16'hEA1F; assign sinw[250]=16'hBE33; assign sinw[251]=16'h9B19; assign sinw[252]=16'h8584; assign sinw[253]=16'h805A; assign sinw[254]=16'h8C4B; assign sinw[255]=16'hA7BE;
	
	`else		  //Forward FFT

assign sinw[0]=16'h0000; assign sinw[1]=16'h0000; assign sinw[2]=16'h0000; assign sinw[3]=16'h0000; assign sinw[4]=16'h0000; assign sinw[5]=16'h0000; assign sinw[6]=16'h0000; assign sinw[7]=16'h0000; assign sinw[8]=16'h0000; assign sinw[9]=16'h0000; assign sinw[10]=16'h0000; assign sinw[11]=16'h0000; assign sinw[12]=16'h0000; assign sinw[13]=16'h0000; assign sinw[14]=16'h0000; assign sinw[15]=16'h0000;
 assign sinw[16]=16'h0000; assign sinw[17]=16'hFCDC; assign sinw[18]=16'hF9B9; assign sinw[19]=16'hF696; assign sinw[20]=16'hF375; assign sinw[21]=16'hF055; assign sinw[22]=16'hED39; assign sinw[23]=16'hEA1F; assign sinw[24]=16'hE708; assign sinw[25]=16'hE3F5; assign sinw[26]=16'hE0E7; assign sinw[27]=16'hDDDD; assign sinw[28]=16'hDAD9; assign sinw[29]=16'hD7DA; assign sinw[30]=16'hD4E2; assign sinw[31]=16'hD1F0;
 assign sinw[32]=16'h0000; assign sinw[33]=16'hF9B9; assign sinw[34]=16'hF375; assign sinw[35]=16'hED39; assign sinw[36]=16'hE708; assign sinw[37]=16'hE0E7; assign sinw[38]=16'hDAD9; assign sinw[39]=16'hD4E2; assign sinw[40]=16'hCF05; assign sinw[41]=16'hC947; assign sinw[42]=16'hC3AA; assign sinw[43]=16'hBE33; assign sinw[44]=16'hB8E4; assign sinw[45]=16'hB3C1; assign sinw[46]=16'hAECD; assign sinw[47]=16'hAA0C;
 assign sinw[48]=16'h0000; assign sinw[49]=16'hF696; assign sinw[50]=16'hED39; assign sinw[51]=16'hE3F5; assign sinw[52]=16'hDAD9; assign sinw[53]=16'hD1F0; assign sinw[54]=16'hC947; assign sinw[55]=16'hC0EA; assign sinw[56]=16'hB8E4; assign sinw[57]=16'hB141; assign sinw[58]=16'hAA0C; assign sinw[59]=16'hA34D; assign sinw[60]=16'h9D0F; assign sinw[61]=16'h975B; assign sinw[62]=16'h9237; assign sinw[63]=16'h8DAC;
 assign sinw[64]=16'h0000; assign sinw[65]=16'hF375; assign sinw[66]=16'hE708; assign sinw[67]=16'hDAD9; assign sinw[68]=16'hCF05; assign sinw[69]=16'hC3AA; assign sinw[70]=16'hB8E4; assign sinw[71]=16'hAECD; assign sinw[72]=16'hA57F; assign sinw[73]=16'h9D0F; assign sinw[74]=16'h9594; assign sinw[75]=16'h8F1F; assign sinw[76]=16'h89C0; assign sinw[77]=16'h8584; assign sinw[78]=16'h8277; assign sinw[79]=16'h809F;
 assign sinw[80]=16'h0000; assign sinw[81]=16'hF055; assign sinw[82]=16'hE0E7; assign sinw[83]=16'hD1F0; assign sinw[84]=16'hC3AA; assign sinw[85]=16'hB64D; assign sinw[86]=16'hAA0C; assign sinw[87]=16'h9F15; assign sinw[88]=16'h9594; assign sinw[89]=16'h8DAC; assign sinw[90]=16'h877D; assign sinw[91]=16'h831E; assign sinw[92]=16'h809F; assign sinw[93]=16'h800B; assign sinw[94]=16'h8164; assign sinw[95]=16'h84A4;
 assign sinw[96]=16'h0000; assign sinw[97]=16'hED39; assign sinw[98]=16'hDAD9; assign sinw[99]=16'hC947; assign sinw[100]=16'hB8E4; assign sinw[101]=16'hAA0C; assign sinw[102]=16'h9D0F; assign sinw[103]=16'h9237; assign sinw[104]=16'h89C0; assign sinw[105]=16'h83D7; assign sinw[106]=16'h809F; assign sinw[107]=16'h8029; assign sinw[108]=16'h8277; assign sinw[109]=16'h877D; assign sinw[110]=16'h8F1F; assign sinw[111]=16'h9932;
 assign sinw[112]=16'h0000; assign sinw[113]=16'hEA1F; assign sinw[114]=16'hD4E2; assign sinw[115]=16'hC0EA; assign sinw[116]=16'hAECD; assign sinw[117]=16'h9F15; assign sinw[118]=16'h9237; assign sinw[119]=16'h8895; assign sinw[120]=16'h8277; assign sinw[121]=16'h800B; assign sinw[122]=16'h8164; assign sinw[123]=16'h8677; assign sinw[124]=16'h8F1F; assign sinw[125]=16'h9B19; assign sinw[126]=16'hAA0C; assign sinw[127]=16'hBB86;
 assign sinw[128]=16'h0000; assign sinw[129]=16'hE708; assign sinw[130]=16'hCF05; assign sinw[131]=16'hB8E4; assign sinw[132]=16'hA57F; assign sinw[133]=16'h9594; assign sinw[134]=16'h89C0; assign sinw[135]=16'h8277; assign sinw[136]=16'h8001; assign sinw[137]=16'h8277; assign sinw[138]=16'h89C0; assign sinw[139]=16'h9594; assign sinw[140]=16'hA57F; assign sinw[141]=16'hB8E4; assign sinw[142]=16'hCF05; assign sinw[143]=16'hE708;
 assign sinw[144]=16'h0000; assign sinw[145]=16'hE3F5; assign sinw[146]=16'hC947; assign sinw[147]=16'hB141; assign sinw[148]=16'h9D0F; assign sinw[149]=16'h8DAC; assign sinw[150]=16'h83D7; assign sinw[151]=16'h800B; assign sinw[152]=16'h8277; assign sinw[153]=16'h8AFD; assign sinw[154]=16'h9932; assign sinw[155]=16'hAC66; assign sinw[156]=16'hC3AA; assign sinw[157]=16'hDDDD; assign sinw[158]=16'hF9B9; assign sinw[159]=16'h15E1;
 assign sinw[160]=16'h0000; assign sinw[161]=16'hE0E7; assign sinw[162]=16'hC3AA; assign sinw[163]=16'hAA0C; assign sinw[164]=16'h9594; assign sinw[165]=16'h877D; assign sinw[166]=16'h809F; assign sinw[167]=16'h8164; assign sinw[168]=16'h89C0; assign sinw[169]=16'h9932; assign sinw[170]=16'hAECD; assign sinw[171]=16'hC947; assign sinw[172]=16'hE708; assign sinw[173]=16'h0647; assign sinw[174]=16'h2527; assign sinw[175]=16'h41CD;
 assign sinw[176]=16'h0000; assign sinw[177]=16'hDDDD; assign sinw[178]=16'hBE33; assign sinw[179]=16'hA34D; assign sinw[180]=16'h8F1F; assign sinw[181]=16'h831E; assign sinw[182]=16'h8029; assign sinw[183]=16'h8677; assign sinw[184]=16'h9594; assign sinw[185]=16'hAC66; assign sinw[186]=16'hC947; assign sinw[187]=16'hEA1F; assign sinw[188]=16'h0C8B; assign sinw[189]=16'h2E10; assign sinw[190]=16'h4C3F; assign sinw[191]=16'h64E7;
 assign sinw[192]=16'h0000; assign sinw[193]=16'hDAD9; assign sinw[194]=16'hB8E4; assign sinw[195]=16'h9D0F; assign sinw[196]=16'h89C0; assign sinw[197]=16'h809F; assign sinw[198]=16'h8277; assign sinw[199]=16'h8F1F; assign sinw[200]=16'hA57F; assign sinw[201]=16'hC3AA; assign sinw[202]=16'hE708; assign sinw[203]=16'h0C8B; assign sinw[204]=16'h30FB; assign sinw[205]=16'h5133; assign sinw[206]=16'h6A6C; assign sinw[207]=16'h7A7C;
 assign sinw[208]=16'h0000; assign sinw[209]=16'hD7DA; assign sinw[210]=16'hB3C1; assign sinw[211]=16'h975B; assign sinw[212]=16'h8584; assign sinw[213]=16'h800B; assign sinw[214]=16'h877D; assign sinw[215]=16'h9B19; assign sinw[216]=16'hB8E4; assign sinw[217]=16'hDDDD; assign sinw[218]=16'h0647; assign sinw[219]=16'h2E10; assign sinw[220]=16'h5133; assign sinw[221]=16'h6C23; assign sinw[222]=16'h7C29; assign sinw[223]=16'h7FA6;
 assign sinw[224]=16'h0000; assign sinw[225]=16'hD4E2; assign sinw[226]=16'hAECD; assign sinw[227]=16'h9237; assign sinw[228]=16'h8277; assign sinw[229]=16'h8164; assign sinw[230]=16'h8F1F; assign sinw[231]=16'hAA0C; assign sinw[232]=16'hCF05; assign sinw[233]=16'hF9B9; assign sinw[234]=16'h2527; assign sinw[235]=16'h4C3F; assign sinw[236]=16'h6A6C; assign sinw[237]=16'h7C29; assign sinw[238]=16'h7F61; assign sinw[239]=16'h73B5;
 assign sinw[240]=16'h0000; assign sinw[241]=16'hD1F0; assign sinw[242]=16'hAA0C; assign sinw[243]=16'h8DAC; assign sinw[244]=16'h809F; assign sinw[245]=16'h84A4; assign sinw[246]=16'h9932; assign sinw[247]=16'hBB86; assign sinw[248]=16'hE708; assign sinw[249]=16'h15E1; assign sinw[250]=16'h41CD; assign sinw[251]=16'h64E7; assign sinw[252]=16'h7A7C; assign sinw[253]=16'h7FA6; assign sinw[254]=16'h73B5; assign sinw[255]=16'h5842;
  	   	`endif

	
	wire [15:0] wri,wii 	  ;
	assign wri=cosw[ADDR];	
	assign wii=sinw[ADDR];		
	
	wire [nw:0] wrt,wit;
	
//	// precise rounding	 , must be minimized by the synthesizer		but not done at least by SYNPLIFY
//	reg signed [nw:0] wrt,wit;
//	always@(wri or wii or wrt or wit) begin
//			if (nw==16)  begin
//				WR<=wri;	 WI<= - wii; end
//			else if (nw==15)  begin	   //rounding only for positive and those that are not 111..1
//					wrt = wri +(~wri[15] &&(~&wri[14:16-nw]));
//					wit = wii  +(~wii[15] &&(~&wii[14:16-nw]));
//					WR<=wrt[15:1] ; 
//					WI<= - wit[15:16-nw] ; 
//				end
//			else begin			
//					if ((~wri[15] && (&wri[14:16-nw])) ||	//in positive MSBS are 	 1111
//					(wri[15] && wri[15-nw] && (~|wri[14-nw:0]))) //in negative const truncated bits not 1000 		 
//					
//					WR<=wri[15:16-nw] ; 
//					else  begin	
//					wrt = wri[15:15-nw]+1;
//					WR<= wrt[nw:1];	 end				
//					
//					if  ((~wii[15] && (&wii[14:16-nw])) ||	//in positive MSBS are 	 1111
//					(wii[15] && wii[15-nw] && (~|wii[14-nw:0]))) //in negative const truncated bits not 1000 		 
//					WI<=wii[15:16-nw] ; 
//					else begin	
//						wit = wii[15:15-nw]+1;
//					WI<= - wit[nw:1];	 end	
//				end		
//		end
//	
	assign	wrt = wri[15:16-nw];
	assign	wit = wii[15:16-nw];
	assign WR= wrt[nw-1:0];	  
	assign WI= wit[nw-1:0];
	
endmodule   
