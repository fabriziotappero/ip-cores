/* This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
   
   Email : semiconductors@varkongroup.com
   Tel   : 1-732-447-8611
   
*/


/// this block is used to calculate lamda polynomial roots
module lamda_roots
(
// active high flag for one clock edge to indicate that lamda polynomial coeff is ready
input CE,  
input clk, // input clock planned to be 56 Mhz
input reset, // active high asynchronous reset
input [7:0] Lc0,Lc1,Lc2,Lc3,Lc4,Lc5,Lc6,Lc7,Lc8, /// input coeff of lamda polynomial

output reg [7:0] add_GF_ascending,   // output address to GF_ascending_rom
output reg[7:0] add_GF_dec0,add_GF_dec1,add_GF_dec2, // output address to GF_dec_rom

input [7:0] power,  // input power value from GF_ascending_rom
input [7:0] decimal0,decimal1,decimal2, // input decimal value of GF_dec_rom

 // output active high flag to indicate that all roots is ready (for one clock)
output reg CEO,
output reg [3:0] root_cnt, ///  up to 8
// output roots of lamda polynomial up to 8 roots
output reg [7:0] r1,r2,r3,r4,r5,r6,r7,r8 
);


reg one,two; //states
/// decimal value & power value of possible values of roots 0---255
reg [7:0] V,Vp;  
reg [3:0] cnt9;
reg [1:0] cnt3;

reg [11:0] add0,add1,add2;
reg [8:0] Vx2;
reg [9:0] Vx3;
reg [10:0] Vx6;
reg [7:0] X0,X1,X2,X3;   /// xor values
reg [7:0] GF1,GF2,GF3,GF4; /// decimal GF values
reg [7:0] GF5,GF6,GF7,GF8; /// decimal GF values
reg [8:0] add_GF_dec0_reg,add_GF_dec1_reg,add_GF_dec2_reg;
reg [7:0] add_GF_dec0_reg0,add_GF_dec1_reg0,add_GF_dec2_reg0;
reg F0,F1,F2;   /// IS 255
reg FF0,FF1,FF2; /// IS 255 delayed one clock
reg FFF0,FFF1,FFF2; /// IS 255  delayed two clocks
reg [7:0] L0,L1,L2,L3,L4,L5,L6,L7,L8; /// Lamda coeff
reg yes,E;
reg chk_flag; 
reg [1:0] chk_cnt;
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
/////////////////// values generator (0--255  every three clocks)
always@(posedge clk or posedge reset)
begin
	if (reset)
		begin
			cnt3<=2;
			V<=8'd255;
		end
	else
		begin
			if(two)
				begin
					if (cnt3 ==2)
						begin
							cnt3<=0;
							V<=V+1;
						end
					else	
						cnt3<=cnt3+1;
				end
			else
				begin
					cnt3<=2;
					V<=8'd255;
				end
		end
end



/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////// main process
always@(posedge clk or posedge reset)
begin
	if (reset)
		begin
			one<=0;
			two<=0;
			cnt9<=0;
			L0<=0;L1<=0;L2<=0;L3<=0;L4<=0;
			L5<=0;L6<=0;L7<=0;L8<=0;
			add_GF_dec0_reg<=0;add_GF_dec1_reg<=0;add_GF_dec2_reg<=0;
			add_GF_dec0_reg0<=0;add_GF_dec1_reg0<=0;add_GF_dec2_reg0<=0;
			F0<=0;F1<=0;F2<=0;
			FF0<=0;FF1<=0;FF2<=0;
			FFF0<=0;FFF1<=0;FFF2<=0;
			add0<=0;add1<=0;add2<=0;
			Vx2<=0;Vx3<=0;Vx6<=0;Vp<=0;
			X0<=0;X1<=0;X2<=0;X3<=0;
			GF1<=0;GF2<=0;GF3<=0;GF4<=0;
			GF5<=0;GF6<=0;GF7<=0;GF8<=0;
			yes<=0;
			E<=0;
			chk_flag<=0; chk_cnt<=0;
			////////////////outputs///////////////////////
			root_cnt<=0;
			CEO<=0;
			r1<=0;r2<=0;r3<=0;r4<=0;
			r5<=0;r6<=0;r7<=0;r8<=0;
			add_GF_dec0<=0;add_GF_dec1<=0;add_GF_dec2<=0;
			add_GF_ascending<=0;
		end
	else
		begin
			if(CE)
				begin
					one<=1;
					L0<=Lc0; // no need to convert it to power form
					add_GF_ascending<=Lc1;
					L2<=Lc2;L3<=Lc3;L4<=Lc4;
					L5<=Lc5;L6<=Lc6;L7<=Lc7;L8<=Lc8;
					cnt9<=7;
				end
			////// state one////////////////////////////////////////////////	
			if(one)
				begin
					cnt9<=cnt9-1;
					/////////////////////////////////
					case(cnt9)
					7: begin add_GF_ascending<=L2; end
					6: begin add_GF_ascending<=L3; L1<=power; end
					5: begin add_GF_ascending<=L4; L2<=power; end
					4: begin add_GF_ascending<=L5; L3<=power; end
					3: begin add_GF_ascending<=L6; L4<=power; end
					2: begin add_GF_ascending<=L7; L5<=power; end
					1: begin add_GF_ascending<=L8; L6<=power; end
					0: begin  L7<=power;  end
					15:begin 
							L8<=power;  one<=0; two<=1; root_cnt<=0;
							/// to avoid false roots from xor operations
							X0<=8'h55;X1<=8'hAA;X2<=8'hF1;X3<=8'h55;
							GF1<=0;GF2<=0;GF3<=0;GF4<=0;
							GF5<=0;GF6<=0;GF7<=0;GF8<=0;
							r1<=0;r2<=0;r3<=0;r4<=0;
							r5<=0;r6<=0;r7<=0;r8<=0;
							chk_flag<=0; chk_cnt<=0;
						end
					default: begin   add_GF_ascending<=L2;       end   /// just for default case
					endcase
					//////////////////////////////////
				end	
			////// state two////////////////////////////////////
			if(two)
				begin
					///////////////Delay level one ////////////////////
					if(cnt3 == 0)
						begin
							add_GF_ascending<=V;
						end
					//////////////////////////////////////////////////////
					///////////////////////////Delay level  two//////////
					Vp <=power;
					////////////////////////////////////////////////////////
					///////////////////////////Delay level  three//////////
					 case (cnt3)  
					 0:
						 begin
							 add0<=L1+Vp;
							 add1<=L2+Vp+Vp;
							 add2<=0;
							 F0<= (&L1 || &Vp);
							 F1<=(&L2 || &Vp);
							 F2<=0;
						 end
					1:
						 begin
							 add0<=L3+Vx3;
							 add1<=L4+Vx3+Vp;
							 add2<=L5+Vx3+Vx2;
							 F0<= (&L3 || &Vp);
							 F1<=(&L4 || &Vp);
							 F2<=(&L5 || &Vp);
						 end
					2:
						 begin
							 add0<=L6+Vx6;
							 add1<=L7+Vx6+Vp;
							 add2<=L8+Vx6+Vx2;
							 F0<= (&L6 || &Vp);
							 F1<=(&L7|| &Vp);
							 F2<=(&L8 || &Vp);
						 end
					default:
						 begin /// using first case values for default
							 add0<=L1+Vp;
							 add1<=L2+Vp+Vp;
							 add2<=0;
							 F0<= (&L1 || &Vp);
							 F1<=(&L2 || &Vp);
							 F2<=0;
						 end	 
					 endcase
					 //// Vp constant for 3 clocks so these operations can  
					 /////be done without using operation switcher cnt3
					 Vx2<=Vp+Vp;
					 Vx3<=Vp+Vp+Vp;
					 Vx6<=Vx3+Vx3;
					 
					 ////////////////////////////////////////////////////
					///////////////////////////Delay level  four/////////
					 /// 8 + 4 ===> need 9 bits
					add_GF_dec0_reg<=add0[11:8] + add0[7:0];   
					add_GF_dec1_reg<=add1[11:8] + add1[7:0];
					add_GF_dec2_reg<=add2[11:8] + add2[7:0];
					 
					 FF0<=F0; FF1<=F1; FF2<=F2;
					 ///////////////////////////////////////////////////
					///////////////////////////Delay level  five///////
					 ///   9 bits  =====> 8 bits
					add_GF_dec0_reg0<=add_GF_dec0_reg[8] + add_GF_dec0_reg[7:0];  
					add_GF_dec1_reg0<=add_GF_dec1_reg[8] + add_GF_dec1_reg[7:0];
					add_GF_dec2_reg0<=add_GF_dec2_reg[8] + add_GF_dec2_reg[7:0];
					 
					 FFF0<=FF0; FFF1<=FF1; FFF2<=FF2;
					//////////////////////////////////////////////////////////
					///////////////////////////Delay level  six/////////////
					 add_GF_dec0 <= (FFF0)?  8'h00 : (&add_GF_dec0_reg0)? 8'h01:add_GF_dec0_reg0+1;
					 add_GF_dec1 <= (FFF1)?  8'h00 : (&add_GF_dec1_reg0)? 8'h01:add_GF_dec1_reg0+1;
					 add_GF_dec2 <= (FFF2)?  8'h00 : (&add_GF_dec2_reg0)? 8'h01:add_GF_dec2_reg0+1;
					 ////////////////////////////////////////////////////////
					///////////////////////////Delay level  seven///////////
					X0<=L0;
					GF1<=decimal0;
					GF2<=decimal1;
					///////////////////////////////////////////////////////
					///////////////////////////Delay level  eight/////////
					X1<=X0 ^ GF1^GF2;
					GF3<=decimal0;
					GF4<=decimal1;
					GF5<=decimal2;
					//////////////////////////////////////////////////////
					///////////////////////////Delay level  nine/////////
					X2<=X1 ^ GF3^GF4^GF5;
					GF6<=decimal0;
					GF7<=decimal1;
					GF8<=decimal2;
					/////////////////////////////////////////////////////
					///////////////////////////Delay level  ten/////////
					X3<=X2 ^ GF6^GF7^GF8;
					////////////////////////////////////////////////////
					///////////////////////////Delay level  eleven//////
					if (X3==0  && chk_flag && cnt3==0)
						begin
							root_cnt<=root_cnt+1;
							yes<=1;
						end
					/////////////////////////////////////////////////////
					///////////////////////////Delay level  twelve//////
					if(yes)
						begin
							yes<=0;
							case(root_cnt)
							1: begin r1<=V-8'd4; end
							2: begin r2<=V-8'd4; end
							3: begin r3<=V-8'd4; end
							4: begin r4<=V-8'd4; end
							5: begin r5<=V-8'd4; end
							6: begin r6<=V-8'd4; end
							7: begin r7<=V-8'd4; end
							default: begin r8<=V-8'd4; end
							endcase
						end
					//////////////////////////////////////////////////
					///////////////////////////Delay level  thirteen//
					if(&(V-8'd4)  &&  E  && cnt3 == 1)   
					// when value == 255+delay , we now scanned all possible values of roots 
						begin
							two<=0;
							CEO<=1;
							E<=0;
						end
						
					if(&V && cnt3==0)  
					// when value == 255 and cnt3 ==0 so 255 value entered state two
						E<=1;
					////////////////////////////////////////////////////
					/////////////////////chk_flag generation part//////
					/////to control the check of X3 (xor out value) only with right places .
					if(cnt3 == 0)
						begin
							if(&chk_cnt)
								begin
									chk_cnt<= 2'd3;
									chk_flag<=1;
								end
							else
								chk_cnt<=chk_cnt+1;
						end
				end
			///////////////////////////////////////////////
			if (CEO)
				CEO<=0; /// to make it active for one clock
		end
end		



endmodule 