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
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//   ROM with 128 samples of the sine waves at the frequencies = 1, 3,5 and 7
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   `timescale 1 ns / 1 ps  
module Wave_ROM128 ( ADDR ,DATA_RE,DATA_IM,DATA_REF ); 
    	output [15:0] DATA_RE,DATA_IM,DATA_REF ;     
    	input [6:0]    ADDR ;     
    	reg [15:0] cosi[0:127];    
    	initial	  begin    
 cosi[0]=16'h7FFF; cosi[1]=16'h7FD7; cosi[2]=16'h7F61; cosi[3]=16'h7E9C; cosi[4]=16'h7D89; cosi[5]=16'h7C29; cosi[6]=16'h7A7C; cosi[7]=16'h7883; cosi[8]=16'h7640; cosi[9]=16'h73B5; cosi[10]=16'h70E1; cosi[11]=16'h6DC9; cosi[12]=16'h6A6C; cosi[13]=16'h66CE; cosi[14]=16'h62F1; cosi[15]=16'h5ED6;
 cosi[16]=16'h5A81; cosi[17]=16'h55F4; cosi[18]=16'h5133; cosi[19]=16'h4C3F; cosi[20]=16'h471C; cosi[21]=16'h41CD; cosi[22]=16'h3C56; cosi[23]=16'h36B9; cosi[24]=16'h30FB; cosi[25]=16'h2B1E; cosi[26]=16'h2527; cosi[27]=16'h1F19; cosi[28]=16'h18F8; cosi[29]=16'h12C7; cosi[30]=16'h0C8B; cosi[31]=16'h0647;
 cosi[32]=16'h0000; cosi[33]=16'hF9B9; cosi[34]=16'hF375; cosi[35]=16'hED39; cosi[36]=16'hE708; cosi[37]=16'hE0E7; cosi[38]=16'hDAD9; cosi[39]=16'hD4E2; cosi[40]=16'hCF05; cosi[41]=16'hC947; cosi[42]=16'hC3AA; cosi[43]=16'hBE33; cosi[44]=16'hB8E4; cosi[45]=16'hB3C1; cosi[46]=16'hAECD; cosi[47]=16'hAA0C;
 cosi[48]=16'hA57F; cosi[49]=16'hA12A; cosi[50]=16'h9D0F; cosi[51]=16'h9932; cosi[52]=16'h9594; cosi[53]=16'h9237; cosi[54]=16'h8F1F; cosi[55]=16'h8C4B; cosi[56]=16'h89C0; cosi[57]=16'h877D; cosi[58]=16'h8584; cosi[59]=16'h83D7; cosi[60]=16'h8277; cosi[61]=16'h8164; cosi[62]=16'h809F; cosi[63]=16'h8029;
 cosi[64]=16'h8001; cosi[65]=16'h8029; cosi[66]=16'h809F; cosi[67]=16'h8164; cosi[68]=16'h8277; cosi[69]=16'h83D7; cosi[70]=16'h8584; cosi[71]=16'h877D; cosi[72]=16'h89C0; cosi[73]=16'h8C4B; cosi[74]=16'h8F1F; cosi[75]=16'h9237; cosi[76]=16'h9594; cosi[77]=16'h9932; cosi[78]=16'h9D0F; cosi[79]=16'hA12A;
 cosi[80]=16'hA57F; cosi[81]=16'hAA0C; cosi[82]=16'hAECD; cosi[83]=16'hB3C1; cosi[84]=16'hB8E4; cosi[85]=16'hBE33; cosi[86]=16'hC3AA; cosi[87]=16'hC947; cosi[88]=16'hCF05; cosi[89]=16'hD4E2; cosi[90]=16'hDAD9; cosi[91]=16'hE0E7; cosi[92]=16'hE708; cosi[93]=16'hED39; cosi[94]=16'hF375; cosi[95]=16'hF9B9;
 cosi[96]=16'h0000; cosi[97]=16'h0647; cosi[98]=16'h0C8B; cosi[99]=16'h12C7; cosi[100]=16'h18F8; cosi[101]=16'h1F19; cosi[102]=16'h2527; cosi[103]=16'h2B1E; cosi[104]=16'h30FB; cosi[105]=16'h36B9; cosi[106]=16'h3C56; cosi[107]=16'h41CD; cosi[108]=16'h471C; cosi[109]=16'h4C3F; cosi[110]=16'h5133; cosi[111]=16'h55F4;
 cosi[112]=16'h5A81; cosi[113]=16'h5ED6; cosi[114]=16'h62F1; cosi[115]=16'h66CE; cosi[116]=16'h6A6C; cosi[117]=16'h6DC9; cosi[118]=16'h70E1; cosi[119]=16'h73B5; cosi[120]=16'h7640; cosi[121]=16'h7883; cosi[122]=16'h7A7C; cosi[123]=16'h7C29; cosi[124]=16'h7D89; cosi[125]=16'h7E9C; cosi[126]=16'h7F61; cosi[127]=16'h7FD7;
     end 

    	reg [15:0] sine[0:127];    
    	initial	  begin    
 sine[0]=16'h0000; sine[1]=16'h0647; sine[2]=16'h0C8B; sine[3]=16'h12C7; sine[4]=16'h18F8; sine[5]=16'h1F19; sine[6]=16'h2527; sine[7]=16'h2B1E; sine[8]=16'h30FB; sine[9]=16'h36B9; sine[10]=16'h3C56; sine[11]=16'h41CD; sine[12]=16'h471C; sine[13]=16'h4C3F; sine[14]=16'h5133; sine[15]=16'h55F4;
 sine[16]=16'h5A81; sine[17]=16'h5ED6; sine[18]=16'h62F1; sine[19]=16'h66CE; sine[20]=16'h6A6C; sine[21]=16'h6DC9; sine[22]=16'h70E1; sine[23]=16'h73B5; sine[24]=16'h7640; sine[25]=16'h7883; sine[26]=16'h7A7C; sine[27]=16'h7C29; sine[28]=16'h7D89; sine[29]=16'h7E9C; sine[30]=16'h7F61; sine[31]=16'h7FD7;
 sine[32]=16'h7FFF; sine[33]=16'h7FD7; sine[34]=16'h7F61; sine[35]=16'h7E9C; sine[36]=16'h7D89; sine[37]=16'h7C29; sine[38]=16'h7A7C; sine[39]=16'h7883; sine[40]=16'h7640; sine[41]=16'h73B5; sine[42]=16'h70E1; sine[43]=16'h6DC9; sine[44]=16'h6A6C; sine[45]=16'h66CE; sine[46]=16'h62F1; sine[47]=16'h5ED6;
 sine[48]=16'h5A81; sine[49]=16'h55F4; sine[50]=16'h5133; sine[51]=16'h4C3F; sine[52]=16'h471C; sine[53]=16'h41CD; sine[54]=16'h3C56; sine[55]=16'h36B9; sine[56]=16'h30FB; sine[57]=16'h2B1E; sine[58]=16'h2527; sine[59]=16'h1F19; sine[60]=16'h18F8; sine[61]=16'h12C7; sine[62]=16'h0C8B; sine[63]=16'h0647;
 sine[64]=16'h0000; sine[65]=16'hF9B9; sine[66]=16'hF375; sine[67]=16'hED39; sine[68]=16'hE708; sine[69]=16'hE0E7; sine[70]=16'hDAD9; sine[71]=16'hD4E2; sine[72]=16'hCF05; sine[73]=16'hC947; sine[74]=16'hC3AA; sine[75]=16'hBE33; sine[76]=16'hB8E4; sine[77]=16'hB3C1; sine[78]=16'hAECD; sine[79]=16'hAA0C;
 sine[80]=16'hA57F; sine[81]=16'hA12A; sine[82]=16'h9D0F; sine[83]=16'h9932; sine[84]=16'h9594; sine[85]=16'h9237; sine[86]=16'h8F1F; sine[87]=16'h8C4B; sine[88]=16'h89C0; sine[89]=16'h877D; sine[90]=16'h8584; sine[91]=16'h83D7; sine[92]=16'h8277; sine[93]=16'h8164; sine[94]=16'h809F; sine[95]=16'h8029;
 sine[96]=16'h8001; sine[97]=16'h8029; sine[98]=16'h809F; sine[99]=16'h8164; sine[100]=16'h8277; sine[101]=16'h83D7; sine[102]=16'h8584; sine[103]=16'h877D; sine[104]=16'h89C0; sine[105]=16'h8C4B; sine[106]=16'h8F1F; sine[107]=16'h9237; sine[108]=16'h9594; sine[109]=16'h9932; sine[110]=16'h9D0F; sine[111]=16'hA12A;
 sine[112]=16'hA57F; sine[113]=16'hAA0C; sine[114]=16'hAECD; sine[115]=16'hB3C1; sine[116]=16'hB8E4; sine[117]=16'hBE33; sine[118]=16'hC3AA; sine[119]=16'hC947; sine[120]=16'hCF05; sine[121]=16'hD4E2; sine[122]=16'hDAD9; sine[123]=16'hE0E7; sine[124]=16'hE708; sine[125]=16'hED39; sine[126]=16'hF375; sine[127]=16'hF9B9;
      end 

    	reg [15:0] deltas[0:127];    
    	initial	  begin    
 deltas[0]=16'h0000; deltas[1]=16'h0000; deltas[2]=16'h0000; deltas[3]=16'h0000;
 deltas[4]=16'h0000; deltas[5]=16'h0000; deltas[6]=16'h0000; deltas[7]=16'h0000;
 deltas[8]=16'h0000; deltas[9]=16'h0000; deltas[10]=16'h0000; deltas[11]=16'h0000;
 deltas[12]=16'h0000; deltas[13]=16'h0000; deltas[14]=16'h0000; deltas[15]=16'h0000;
 deltas[16]=16'h0000; deltas[17]=16'h0000; deltas[18]=16'h0000; deltas[19]=16'h0000;
 deltas[20]=16'h0000; deltas[21]=16'h0000; deltas[22]=16'h0000; deltas[23]=16'h0000;
 deltas[24]=16'h0000; deltas[25]=16'h0000; deltas[26]=16'h0000; deltas[27]=16'h0000;
 deltas[28]=16'h0000; deltas[29]=16'h0000; deltas[30]=16'h0000; deltas[31]=16'h0000;
 deltas[32]=16'h0000; deltas[33]=16'h0000; deltas[34]=16'h0000; deltas[35]=16'h0000;
 deltas[36]=16'h0000; deltas[37]=16'h0000; deltas[38]=16'h0000; deltas[39]=16'h0000;
 deltas[40]=16'h0000; deltas[41]=16'h0000; deltas[42]=16'h0000; deltas[43]=16'h0000;
 deltas[44]=16'h0000; deltas[45]=16'h0000; deltas[46]=16'h0000; deltas[47]=16'h0000;
 deltas[48]=16'h0000; deltas[49]=16'h0000; deltas[50]=16'h0000; deltas[51]=16'h0000;
 deltas[52]=16'h0000; deltas[53]=16'h0000; deltas[54]=16'h0000; deltas[55]=16'h0000;
 deltas[56]=16'h0000; deltas[57]=16'h0000; deltas[58]=16'h0000; deltas[59]=16'h0000;
 deltas[60]=16'h0000; deltas[61]=16'h0000; deltas[62]=16'h0000; deltas[63]=16'h0000;
 deltas[64]=16'h0000; deltas[65]=16'h0000; deltas[66]=16'h0000; deltas[67]=16'h0000;
 deltas[68]=16'h0000; deltas[69]=16'h0000; deltas[70]=16'h0000; deltas[71]=16'h0000;
 deltas[72]=16'h0000; deltas[73]=16'h0000; deltas[74]=16'h0000; deltas[75]=16'h0000;
 deltas[76]=16'h0000; deltas[77]=16'h0000; deltas[78]=16'h0000; deltas[79]=16'h0000;
 deltas[80]=16'h0000; deltas[81]=16'h0000; deltas[82]=16'h0000; deltas[83]=16'h0000;
 deltas[84]=16'h0000; deltas[85]=16'h0000; deltas[86]=16'h0000; deltas[87]=16'h0000;
 deltas[88]=16'h0000; deltas[89]=16'h0000; deltas[90]=16'h0000; deltas[91]=16'h0000;
 deltas[92]=16'h0000; deltas[93]=16'h0000; deltas[94]=16'h0000; deltas[95]=16'h0000;
 deltas[96]=16'h0000; deltas[97]=16'h0000; deltas[98]=16'h0000; deltas[99]=16'h0000;
 deltas[100]=16'h0000; deltas[101]=16'h0000; deltas[102]=16'h0000; deltas[103]=16'h0000;
 deltas[104]=16'h0000; deltas[105]=16'h0000; deltas[106]=16'h0000; deltas[107]=16'h0000;
 deltas[108]=16'h0000; deltas[109]=16'h0000; deltas[110]=16'h0000; deltas[111]=16'h0000;
 deltas[112]=16'h0000; deltas[113]=16'h0000; deltas[114]=16'h0000; deltas[115]=16'h0000;
 deltas[116]=16'h0000; deltas[117]=16'h0000; deltas[118]=16'h0000; deltas[119]=16'h0000;
 deltas[120]=16'h0000; deltas[121]=16'h0000; deltas[122]=16'h0000; deltas[123]=16'h0000;
 deltas[124]=16'h0000; deltas[125]=16'h0000; deltas[126]=16'h0000; deltas[127]=16'h0000;
 deltas[1]=16'h5A7F; deltas[3]=16'h5A7F; deltas[5]=16'h5A7F; deltas[7]=16'h5A7F;
     end 

	assign DATA_RE=cosi[ADDR];	
	assign DATA_IM=sine[ADDR];	
	assign DATA_REF=deltas[ADDR];	
endmodule   
