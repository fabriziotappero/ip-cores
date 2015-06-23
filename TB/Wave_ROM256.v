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
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//   ROM with 256 samples of the sine waves at the frequencies = 1, 3,5 and 7
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   `timescale 1 ns / 1 ps  
module Wave_ROM256 ( ADDR ,DATA_RE,DATA_IM,DATA_REF ); 
    	output [15:0] DATA_RE,DATA_IM,DATA_REF ;     
    	input [7:0]    ADDR ;     
    	reg [15:0] cosi[0:255];    
    	initial	  begin    
 cosi[0]=16'h5A7F; cosi[1]=16'h5111; cosi[2]=16'h46AD; cosi[3]=16'h3B84; cosi[4]=16'h2FCE; cosi[5]=16'h23C4; cosi[6]=16'h17A2; cosi[7]=16'h0BA3; cosi[8]=16'h0000; cosi[9]=16'hF4F0; cosi[10]=16'hEAA4; cosi[11]=16'hE14A; cosi[12]=16'hD908; cosi[13]=16'hD1FD; cosi[14]=16'hCC40; cosi[15]=16'hC7E0;
 cosi[16]=16'hC4E2; cosi[17]=16'hC343; cosi[18]=16'hC2F9; cosi[19]=16'hC3F2; cosi[20]=16'hC611; cosi[21]=16'hC938; cosi[22]=16'hCD40; cosi[23]=16'hD1FE; cosi[24]=16'hD747; cosi[25]=16'hDCEC; cosi[26]=16'hE2BC; cosi[27]=16'hE88B; cosi[28]=16'hEE2C; cosi[29]=16'hF376; cosi[30]=16'hF846; cosi[31]=16'hFC7C;
 cosi[32]=16'h0000; cosi[33]=16'h02BF; cosi[34]=16'h04AE; cosi[35]=16'h05C8; cosi[36]=16'h060F; cosi[37]=16'h058D; cosi[38]=16'h0451; cosi[39]=16'h026E; cosi[40]=16'h0000; cosi[41]=16'hFD22; cosi[42]=16'hF9F3; cosi[43]=16'hF696; cosi[44]=16'hF32D; cosi[45]=16'hEFD8; cosi[46]=16'hECB7; cosi[47]=16'hE9E8;
 cosi[48]=16'hE783; cosi[49]=16'hE59F; cosi[50]=16'hE44A; cosi[51]=16'hE390; cosi[52]=16'hE376; cosi[53]=16'hE3FC; cosi[54]=16'hE51A; cosi[55]=16'hE6C6; cosi[56]=16'hE8EF; cosi[57]=16'hEB80; cosi[58]=16'hEE60; cosi[59]=16'hF176; cosi[60]=16'hF4A3; cosi[61]=16'hF7CA; cosi[62]=16'hFACE; cosi[63]=16'hFD94;
 cosi[64]=16'h0000; cosi[65]=16'h01FD; cosi[66]=16'h0378; cosi[67]=16'h0463; cosi[68]=16'h04B5; cosi[69]=16'h0469; cosi[70]=16'h0381; cosi[71]=16'h0204; cosi[72]=16'h0000; cosi[73]=16'hFD84; cosi[74]=16'hFAA7; cosi[75]=16'hF781; cosi[76]=16'hF42E; cosi[77]=16'hF0CD; cosi[78]=16'hED7C; cosi[79]=16'hEA5A;
 cosi[80]=16'hE783; cosi[81]=16'hE514; cosi[82]=16'hE323; cosi[83]=16'hE1C5; cosi[84]=16'hE109; cosi[85]=16'hE0F8; cosi[86]=16'hE195; cosi[87]=16'hE2DE; cosi[88]=16'hE4CB; cosi[89]=16'hE74B; cosi[90]=16'hEA4C; cosi[91]=16'hEDB2; cosi[92]=16'hF15E; cosi[93]=16'hF52F; cosi[94]=16'hF8FF; cosi[95]=16'hFCA8;
 cosi[96]=16'h0000; cosi[97]=16'h02E2; cosi[98]=16'h0529; cosi[99]=16'h06B4; cosi[100]=16'h0762; cosi[101]=16'h071D; cosi[102]=16'h05D2; cosi[103]=16'h0374; cosi[104]=16'h0000; cosi[105]=16'hFB78; cosi[106]=16'hF5E8; cosi[107]=16'hEF62; cosi[108]=16'hE801; cosi[109]=16'hDFE6; cosi[110]=16'hD73A; cosi[111]=16'hCE27;
 cosi[112]=16'hC4E2; cosi[113]=16'hBB9C; cosi[114]=16'hB28D; cosi[115]=16'hA9EB; cosi[116]=16'hA1EC; cosi[117]=16'h9AC2; cosi[118]=16'h949E; cosi[119]=16'h8FA9; cosi[120]=16'h8C08; cosi[121]=16'h89D8; cosi[122]=16'h892F; cosi[123]=16'h8A18; cosi[124]=16'h8C97; cosi[125]=16'h90A7; cosi[126]=16'h963A; cosi[127]=16'h9D38;
 cosi[128]=16'hA581; cosi[129]=16'hAEEF; cosi[130]=16'hB953; cosi[131]=16'hC47C; cosi[132]=16'hD032; cosi[133]=16'hDC3C; cosi[134]=16'hE85E; cosi[135]=16'hF45D; cosi[136]=16'h0000; cosi[137]=16'h0B10; cosi[138]=16'h155C; cosi[139]=16'h1EB6; cosi[140]=16'h26F8; cosi[141]=16'h2E03; cosi[142]=16'h33C0; cosi[143]=16'h3820;
 cosi[144]=16'h3B1E; cosi[145]=16'h3CBD; cosi[146]=16'h3D07; cosi[147]=16'h3C0E; cosi[148]=16'h39EF; cosi[149]=16'h36C8; cosi[150]=16'h32C0; cosi[151]=16'h2E02; cosi[152]=16'h28B9; cosi[153]=16'h2314; cosi[154]=16'h1D44; cosi[155]=16'h1775; cosi[156]=16'h11D4; cosi[157]=16'h0C8A; cosi[158]=16'h07BA; cosi[159]=16'h0384;
 cosi[160]=16'h0000; cosi[161]=16'hFD41; cosi[162]=16'hFB52; cosi[163]=16'hFA38; cosi[164]=16'hF9F1; cosi[165]=16'hFA73; cosi[166]=16'hFBAF; cosi[167]=16'hFD92; cosi[168]=16'h0000; cosi[169]=16'h02DE; cosi[170]=16'h060D; cosi[171]=16'h096A; cosi[172]=16'h0CD3; cosi[173]=16'h1028; cosi[174]=16'h1349; cosi[175]=16'h1618;
 cosi[176]=16'h187D; cosi[177]=16'h1A61; cosi[178]=16'h1BB6; cosi[179]=16'h1C70; cosi[180]=16'h1C8A; cosi[181]=16'h1C04; cosi[182]=16'h1AE6; cosi[183]=16'h193A; cosi[184]=16'h1711; cosi[185]=16'h1480; cosi[186]=16'h11A0; cosi[187]=16'h0E8A; cosi[188]=16'h0B5D; cosi[189]=16'h0836; cosi[190]=16'h0532; cosi[191]=16'h026C;
 cosi[192]=16'h0000; cosi[193]=16'hFE03; cosi[194]=16'hFC88; cosi[195]=16'hFB9D; cosi[196]=16'hFB4B; cosi[197]=16'hFB97; cosi[198]=16'hFC7F; cosi[199]=16'hFDFC; cosi[200]=16'h0000; cosi[201]=16'h027C; cosi[202]=16'h0559; cosi[203]=16'h087F; cosi[204]=16'h0BD2; cosi[205]=16'h0F33; cosi[206]=16'h1284; cosi[207]=16'h15A6;
 cosi[208]=16'h187D; cosi[209]=16'h1AEC; cosi[210]=16'h1CDD; cosi[211]=16'h1E3B; cosi[212]=16'h1EF7; cosi[213]=16'h1F08; cosi[214]=16'h1E6B; cosi[215]=16'h1D22; cosi[216]=16'h1B35; cosi[217]=16'h18B5; cosi[218]=16'h15B4; cosi[219]=16'h124E; cosi[220]=16'h0EA2; cosi[221]=16'h0AD1; cosi[222]=16'h0701; cosi[223]=16'h0358;
 cosi[224]=16'h0000; cosi[225]=16'hFD1E; cosi[226]=16'hFAD7; cosi[227]=16'hF94C; cosi[228]=16'hF89E; cosi[229]=16'hF8E3; cosi[230]=16'hFA2E; cosi[231]=16'hFC8C; cosi[232]=16'h0000; cosi[233]=16'h0488; cosi[234]=16'h0A18; cosi[235]=16'h109E; cosi[236]=16'h17FF; cosi[237]=16'h201A; cosi[238]=16'h28C6; cosi[239]=16'h31D9;
 cosi[240]=16'h3B1E; cosi[241]=16'h4464; cosi[242]=16'h4D73; cosi[243]=16'h5615; cosi[244]=16'h5E14; cosi[245]=16'h653E; cosi[246]=16'h6B62; cosi[247]=16'h7057; cosi[248]=16'h73F8; cosi[249]=16'h7628; cosi[250]=16'h76D1; cosi[251]=16'h75E8; cosi[252]=16'h7369; cosi[253]=16'h6F59; cosi[254]=16'h69C6; cosi[255]=16'h62C8;
     end 

    	reg [15:0] sine[0:255];    
    	initial	  begin    
 sine[0]=16'h5A7F; sine[1]=16'h62C8; sine[2]=16'h69C6; sine[3]=16'h6F59; sine[4]=16'h7369; sine[5]=16'h75E8; sine[6]=16'h76D1; sine[7]=16'h7628; sine[8]=16'h73F8; sine[9]=16'h7057; sine[10]=16'h6B62; sine[11]=16'h653E; sine[12]=16'h5E14; sine[13]=16'h5615; sine[14]=16'h4D73; sine[15]=16'h4464;
 sine[16]=16'h3B1E; sine[17]=16'h31D9; sine[18]=16'h28C6; sine[19]=16'h201A; sine[20]=16'h17FF; sine[21]=16'h109E; sine[22]=16'h0A18; sine[23]=16'h0488; sine[24]=16'h0000; sine[25]=16'hFC8C; sine[26]=16'hFA2E; sine[27]=16'hF8E3; sine[28]=16'hF89E; sine[29]=16'hF94C; sine[30]=16'hFAD7; sine[31]=16'hFD1E;
 sine[32]=16'h0000; sine[33]=16'h0358; sine[34]=16'h0701; sine[35]=16'h0AD1; sine[36]=16'h0EA2; sine[37]=16'h124E; sine[38]=16'h15B4; sine[39]=16'h18B5; sine[40]=16'h1B35; sine[41]=16'h1D22; sine[42]=16'h1E6B; sine[43]=16'h1F08; sine[44]=16'h1EF7; sine[45]=16'h1E3B; sine[46]=16'h1CDD; sine[47]=16'h1AEC;
 sine[48]=16'h187D; sine[49]=16'h15A6; sine[50]=16'h1284; sine[51]=16'h0F33; sine[52]=16'h0BD2; sine[53]=16'h087F; sine[54]=16'h0559; sine[55]=16'h027C; sine[56]=16'h0000; sine[57]=16'hFDFC; sine[58]=16'hFC7F; sine[59]=16'hFB97; sine[60]=16'hFB4B; sine[61]=16'hFB9D; sine[62]=16'hFC88; sine[63]=16'hFE03;
 sine[64]=16'h0000; sine[65]=16'h026C; sine[66]=16'h0532; sine[67]=16'h0836; sine[68]=16'h0B5D; sine[69]=16'h0E8A; sine[70]=16'h11A0; sine[71]=16'h1480; sine[72]=16'h1711; sine[73]=16'h193A; sine[74]=16'h1AE6; sine[75]=16'h1C04; sine[76]=16'h1C8A; sine[77]=16'h1C70; sine[78]=16'h1BB6; sine[79]=16'h1A61;
 sine[80]=16'h187D; sine[81]=16'h1618; sine[82]=16'h1349; sine[83]=16'h1028; sine[84]=16'h0CD3; sine[85]=16'h096A; sine[86]=16'h060D; sine[87]=16'h02DE; sine[88]=16'h0000; sine[89]=16'hFD92; sine[90]=16'hFBAF; sine[91]=16'hFA73; sine[92]=16'hF9F1; sine[93]=16'hFA38; sine[94]=16'hFB52; sine[95]=16'hFD41;
 sine[96]=16'h0000; sine[97]=16'h0384; sine[98]=16'h07BA; sine[99]=16'h0C8A; sine[100]=16'h11D4; sine[101]=16'h1775; sine[102]=16'h1D44; sine[103]=16'h2314; sine[104]=16'h28B9; sine[105]=16'h2E02; sine[106]=16'h32C0; sine[107]=16'h36C8; sine[108]=16'h39EF; sine[109]=16'h3C0E; sine[110]=16'h3D07; sine[111]=16'h3CBD;
 sine[112]=16'h3B1E; sine[113]=16'h3820; sine[114]=16'h33C0; sine[115]=16'h2E03; sine[116]=16'h26F8; sine[117]=16'h1EB6; sine[118]=16'h155C; sine[119]=16'h0B10; sine[120]=16'h0000; sine[121]=16'hF45D; sine[122]=16'hE85E; sine[123]=16'hDC3C; sine[124]=16'hD032; sine[125]=16'hC47C; sine[126]=16'hB953; sine[127]=16'hAEEF;
 sine[128]=16'hA581; sine[129]=16'h9D38; sine[130]=16'h963A; sine[131]=16'h90A7; sine[132]=16'h8C97; sine[133]=16'h8A18; sine[134]=16'h892F; sine[135]=16'h89D8; sine[136]=16'h8C08; sine[137]=16'h8FA9; sine[138]=16'h949E; sine[139]=16'h9AC2; sine[140]=16'hA1EC; sine[141]=16'hA9EB; sine[142]=16'hB28D; sine[143]=16'hBB9C;
 sine[144]=16'hC4E2; sine[145]=16'hCE27; sine[146]=16'hD73A; sine[147]=16'hDFE6; sine[148]=16'hE801; sine[149]=16'hEF62; sine[150]=16'hF5E8; sine[151]=16'hFB78; sine[152]=16'h0000; sine[153]=16'h0374; sine[154]=16'h05D2; sine[155]=16'h071D; sine[156]=16'h0762; sine[157]=16'h06B4; sine[158]=16'h0529; sine[159]=16'h02E2;
 sine[160]=16'h0000; sine[161]=16'hFCA8; sine[162]=16'hF8FF; sine[163]=16'hF52F; sine[164]=16'hF15E; sine[165]=16'hEDB2; sine[166]=16'hEA4C; sine[167]=16'hE74B; sine[168]=16'hE4CB; sine[169]=16'hE2DE; sine[170]=16'hE195; sine[171]=16'hE0F8; sine[172]=16'hE109; sine[173]=16'hE1C5; sine[174]=16'hE323; sine[175]=16'hE514;
 sine[176]=16'hE783; sine[177]=16'hEA5A; sine[178]=16'hED7C; sine[179]=16'hF0CD; sine[180]=16'hF42E; sine[181]=16'hF781; sine[182]=16'hFAA7; sine[183]=16'hFD84; sine[184]=16'h0000; sine[185]=16'h0204; sine[186]=16'h0381; sine[187]=16'h0469; sine[188]=16'h04B5; sine[189]=16'h0463; sine[190]=16'h0378; sine[191]=16'h01FD;
 sine[192]=16'h0000; sine[193]=16'hFD94; sine[194]=16'hFACE; sine[195]=16'hF7CA; sine[196]=16'hF4A3; sine[197]=16'hF176; sine[198]=16'hEE60; sine[199]=16'hEB80; sine[200]=16'hE8EF; sine[201]=16'hE6C6; sine[202]=16'hE51A; sine[203]=16'hE3FC; sine[204]=16'hE376; sine[205]=16'hE390; sine[206]=16'hE44A; sine[207]=16'hE59F;
 sine[208]=16'hE783; sine[209]=16'hE9E8; sine[210]=16'hECB7; sine[211]=16'hEFD8; sine[212]=16'hF32D; sine[213]=16'hF696; sine[214]=16'hF9F3; sine[215]=16'hFD22; sine[216]=16'h0000; sine[217]=16'h026E; sine[218]=16'h0451; sine[219]=16'h058D; sine[220]=16'h060F; sine[221]=16'h05C8; sine[222]=16'h04AE; sine[223]=16'h02BF;
 sine[224]=16'h0000; sine[225]=16'hFC7C; sine[226]=16'hF846; sine[227]=16'hF376; sine[228]=16'hEE2C; sine[229]=16'hE88B; sine[230]=16'hE2BC; sine[231]=16'hDCEC; sine[232]=16'hD747; sine[233]=16'hD1FE; sine[234]=16'hCD40; sine[235]=16'hC938; sine[236]=16'hC611; sine[237]=16'hC3F2; sine[238]=16'hC2F9; sine[239]=16'hC343;
 sine[240]=16'hC4E2; sine[241]=16'hC7E0; sine[242]=16'hCC40; sine[243]=16'hD1FD; sine[244]=16'hD908; sine[245]=16'hE14A; sine[246]=16'hEAA4; sine[247]=16'hF4F0; sine[248]=16'h0000; sine[249]=16'h0BA3; sine[250]=16'h17A2; sine[251]=16'h23C4; sine[252]=16'h2FCE; sine[253]=16'h3B84; sine[254]=16'h46AD; sine[255]=16'h5111;
      end 

    	reg [15:0] deltas[0:255];    
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
 deltas[128]=16'h0000; deltas[129]=16'h0000; deltas[130]=16'h0000; deltas[131]=16'h0000;
 deltas[132]=16'h0000; deltas[133]=16'h0000; deltas[134]=16'h0000; deltas[135]=16'h0000;
 deltas[136]=16'h0000; deltas[137]=16'h0000; deltas[138]=16'h0000; deltas[139]=16'h0000;
 deltas[140]=16'h0000; deltas[141]=16'h0000; deltas[142]=16'h0000; deltas[143]=16'h0000;
 deltas[144]=16'h0000; deltas[145]=16'h0000; deltas[146]=16'h0000; deltas[147]=16'h0000;
 deltas[148]=16'h0000; deltas[149]=16'h0000; deltas[150]=16'h0000; deltas[151]=16'h0000;
 deltas[152]=16'h0000; deltas[153]=16'h0000; deltas[154]=16'h0000; deltas[155]=16'h0000;
 deltas[156]=16'h0000; deltas[157]=16'h0000; deltas[158]=16'h0000; deltas[159]=16'h0000;
 deltas[160]=16'h0000; deltas[161]=16'h0000; deltas[162]=16'h0000; deltas[163]=16'h0000;
 deltas[164]=16'h0000; deltas[165]=16'h0000; deltas[166]=16'h0000; deltas[167]=16'h0000;
 deltas[168]=16'h0000; deltas[169]=16'h0000; deltas[170]=16'h0000; deltas[171]=16'h0000;
 deltas[172]=16'h0000; deltas[173]=16'h0000; deltas[174]=16'h0000; deltas[175]=16'h0000;
 deltas[176]=16'h0000; deltas[177]=16'h0000; deltas[178]=16'h0000; deltas[179]=16'h0000;
 deltas[180]=16'h0000; deltas[181]=16'h0000; deltas[182]=16'h0000; deltas[183]=16'h0000;
 deltas[184]=16'h0000; deltas[185]=16'h0000; deltas[186]=16'h0000; deltas[187]=16'h0000;
 deltas[188]=16'h0000; deltas[189]=16'h0000; deltas[190]=16'h0000; deltas[191]=16'h0000;
 deltas[192]=16'h0000; deltas[193]=16'h0000; deltas[194]=16'h0000; deltas[195]=16'h0000;
 deltas[196]=16'h0000; deltas[197]=16'h0000; deltas[198]=16'h0000; deltas[199]=16'h0000;
 deltas[200]=16'h0000; deltas[201]=16'h0000; deltas[202]=16'h0000; deltas[203]=16'h0000;
 deltas[204]=16'h0000; deltas[205]=16'h0000; deltas[206]=16'h0000; deltas[207]=16'h0000;
 deltas[208]=16'h0000; deltas[209]=16'h0000; deltas[210]=16'h0000; deltas[211]=16'h0000;
 deltas[212]=16'h0000; deltas[213]=16'h0000; deltas[214]=16'h0000; deltas[215]=16'h0000;
 deltas[216]=16'h0000; deltas[217]=16'h0000; deltas[218]=16'h0000; deltas[219]=16'h0000;
 deltas[220]=16'h0000; deltas[221]=16'h0000; deltas[222]=16'h0000; deltas[223]=16'h0000;
 deltas[224]=16'h0000; deltas[225]=16'h0000; deltas[226]=16'h0000; deltas[227]=16'h0000;
 deltas[228]=16'h0000; deltas[229]=16'h0000; deltas[230]=16'h0000; deltas[231]=16'h0000;
 deltas[232]=16'h0000; deltas[233]=16'h0000; deltas[234]=16'h0000; deltas[235]=16'h0000;
 deltas[236]=16'h0000; deltas[237]=16'h0000; deltas[238]=16'h0000; deltas[239]=16'h0000;
 deltas[240]=16'h0000; deltas[241]=16'h0000; deltas[242]=16'h0000; deltas[243]=16'h0000;
 deltas[244]=16'h0000; deltas[245]=16'h0000; deltas[246]=16'h0000; deltas[247]=16'h0000;
 deltas[248]=16'h0000; deltas[249]=16'h0000; deltas[250]=16'h0000; deltas[251]=16'h0000;
 deltas[252]=16'h0000; deltas[253]=16'h0000; deltas[254]=16'h0000; deltas[255]=16'h0000;
 deltas[1]=16'h5A7F; deltas[3]=16'h5A7F; deltas[5]=16'h5A7F; deltas[7]=16'h5A7F;
     end 

	assign DATA_RE=cosi[ADDR];	
	assign DATA_IM=sine[ADDR];	
	assign DATA_REF=deltas[ADDR];	
endmodule   
