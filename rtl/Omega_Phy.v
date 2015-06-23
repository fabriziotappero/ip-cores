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



module Omega_Phy
///// calculates Omega and Phy polynomials 
///    Omega = (Syndromes_16 * Lamda_8)  mod16
///    Phy = dirvetive (Lamda_8)      
(

input clk, // input clock planned to be 56 Mhz
input reset, // active high asynchronous reset

 //   active high flag for one clock to indicate that input Sm is ready
input Sm_ready,  
 // input modified syndromes in decimal format 
input [7:0] Sm1,Sm2,Sm3,Sm4,Sm5,Sm6,Sm7,Sm8,                
input [7:0] Sm9,Sm10,Sm11,Sm12,Sm13,Sm14,Sm15,Sm16,    

// active high flag for one clock to indicate that lamda polynomial is ready
input L_ready, 
///  lamda coeff values in decimal format 
input [7:0] L1,L2,L3,L4,L5,L6,L7,L8,  

input [7:0] pow1,pow2,pow3,  /// output of power memories
input [7:0] dec1,        	/// output of decimal memories

output reg [7:0] add_pow1,add_pow2,add_pow3, /// address to power memories
output  [7:0] add_dec1,              		 /// address to decimal memories

// active high flag for one clock to indicate that Phy and Omega polynomials are ready
output reg poly_ready ,  
// decimal value of first coeff of Omega polynomial
output  [7:0] O1,    
/// power values of omega polynomial coeff from 2:16
output  [7:0] O2,O3,O4,O5,O6,O7,O8,O9,O10,O11,O12,O13,O14,O15,O16,  

output  reg [7:0] P1,    // decimal value of first coeff of Phy polynomial
output  reg [7:0] P3,P5,P7  /// power values of phy polynomial 


);



parameter state1    =  19'b0000000000000000001;
parameter state2    =  19'b0000000000000000010;
parameter state10  =  19'b0000000000000000100;
parameter state11  =  19'b0000000000000001000;
parameter state12  =  19'b0000000000000010000;
parameter state13  =  19'b0000000000000100000;
parameter state14  =  19'b0000000000001000000;
parameter state15  =  19'b0000000000010000000;
parameter state16  =  19'b0000000000100000000;
parameter state17  =  19'b0000000001000000000;
parameter state18  =  19'b0000000010000000000;
parameter state19  =  19'b0000000100000000000;
parameter state20  =  19'b0000001000000000000;
parameter state21  =  19'b0000010000000000000;
parameter state22  =  19'b0000100000000000000;
parameter state23  =  19'b0001000000000000000;
parameter state24  =  19'b0010000000000000000;
parameter state25  =  19'b0100000000000000000;
parameter state26  =  19'b1000000000000000000;

reg [18:0] state = state1;


reg [7:0] Sp [1:15]; // syndromes power values
reg [7:0] L   [1:8]; // lamda decimal values
reg [7:0] Lp [1:8];  // lamda power values

reg [7:0] O [1:16]; // omega values

assign O1=O[1];
assign O2=O[2];
assign O3=O[3];
assign O4=O[4];
assign O5=O[5];
assign O6=O[6];
assign O7=O[7];
assign O8=O[8];
assign O9=O[9];
assign O10=O[10];
assign O11=O[11];
assign O12=O[12];
assign O13=O[13];
assign O14=O[14];
assign O15=O[15];
assign O16=O[16];


reg [3:0]  cnt;
reg [3:0]  cnt1;
reg [3:0]  cnt2;


reg [8:0] add_1;
reg F1;  // is 255 flag

assign add_dec1  =(F1)?  8'h00 :(&add_1[7:0])?     8'h01 : add_1[7:0]+add_1[8]+1;

integer k;

always@ (posedge clk or posedge reset)
begin
	if (reset)
		begin
			poly_ready<=0;
			P1<= 0;P3<= 0;P5<= 0;P7<= 0;
			add_pow1<=0;add_pow2<=0;add_pow3<=0;
			
			add_1<=0;
			F1<=0;
			
			for(k=1;k<=15;k=k+1)
				begin
					Sp[k] <=0;
					O[k] <=0;
				end
				
			for(k=1;k<=8;k=k+1)
				begin
					L[k]<=0;
					Lp[k]<=0;
				end

			O[16] <=0;
			
			cnt<=0;
			cnt1<=0;
			cnt2<=0;
			state<=state1;
		end
	else
		begin
			case (state)
			////////////////////////////////////////////
			state1:begin       ///// register inputs
				
				if(Sm_ready)
					begin
						O[1]<=Sm1;
						O[2]<=Sm2;O[3]<=Sm3;O[4]<=Sm4;O[5]<=Sm5;
						O[6]<=Sm6;O[7]<=Sm7;O[8]<=Sm8;O[9]<=Sm9;     
						O[10]<=Sm10;O[11]<=Sm11;O[12]<=Sm12;
						O[13]<=Sm13;O[14]<=Sm14;O[15]<=Sm15;O[16]<=Sm16;
					end
				
				if(L_ready)
					begin
						L[1]<=L1;L[2]<=L2;L[3]<=L3;L[4]<=L4;L[5]<=L5;
						L[6]<=L6;L[7]<=L7;L[8]<=L8;
						P1<= L1;P3<= 255;P5<= 255;P7<= 255;
						state<=state2;	
						end
				cnt<=0;	
			end
			/////////////////////////////////////////////////////////////
			state2:begin  //// get power values of  syndromes and lamda coeff
				
				if (cnt == 9)
					begin
						state<=state10;   
						cnt<=0;
					end
				else
					cnt<=cnt+1;
				///////////////////////////////////////
				case(cnt)
				
				0:begin
					add_pow1<= O[1];
					add_pow2<= O[2];
					add_pow3<= O[3];
				end
				
				1:begin
					add_pow1<= O[4];
					add_pow2<= O[5];
					add_pow3<= O[6];
				end
				
				2:begin
					add_pow1<= O[7];
					add_pow2<= O[8];
					add_pow3<= O[9];
					
					
					Sp[1] <= pow1;
					Sp[2] <= pow2;
					Sp[3] <= pow3;
				end
				
				3:begin
					add_pow1<= O[10];
					add_pow2<= O[11];
					add_pow3<= O[12];
					
					Sp[4] <= pow1;
					Sp[5] <= pow2;
					Sp[6] <= pow3;
				end
				
				4:begin
					add_pow1<= O[13];
					add_pow2<= O[14];
					add_pow3<= O[15];
					
					Sp[7] <= pow1;
					Sp[8] <= pow2;
					Sp[9] <= pow3;
				end
				
				5:begin
					add_pow1<= L[1];
					add_pow2<= L[2];
					add_pow3<= L[3];
					
					Sp[10] <= pow1;
					Sp[11] <= pow2;
					Sp[12] <= pow3;
				end
				
				6:begin
					add_pow1<= L[4];
					add_pow2<= L[5];
					add_pow3<= L[6];
					
					Sp[13] <= pow1;
					Sp[14] <= pow2;
					Sp[15] <= pow3;
				end
				
				7:begin
					add_pow1<= L[7];
					add_pow2<= L[8];
					
					Lp[1] <= pow1;
					Lp[2] <= pow2;
					Lp[3] <= pow3;
					
					P3<=pow3;
				end
				
				8:begin
					Lp[4] <= pow1;
					Lp[5] <= pow2;
					Lp[6] <= pow3;
					
					P5<=pow2;
				end
				
				default:begin
					Lp[7] <= pow1;
					Lp[8] <= pow2;
					
					P7<=pow1;
				end
				
				endcase	
			end
			/////////////////////////////////////////////////////
			/// just a name for the next state but it is state number three in sequence
			state10:begin   //// calculate O2
				if(cnt == 2)
					begin
						state<=state11;
						cnt<=0;
						cnt1<=1;
						cnt2<=2;
					end
				else
					cnt<=cnt+1;
				
				add_1<= Sp[1]+Lp[1];
				F1<= (&Sp[1] || &Lp[1])? 1:0;
				
				if(cnt == 2)
					O[2] <= O[2] ^ dec1;
					
			end
			/////////////////////////////////////////////////
			state11:begin     /// O3 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[3]<=O[3]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 1)
							begin
								cnt2<=3;
								cnt1<=1;
								state<=state12;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			/////////////////////////////////////////////////
			state12:begin     /// O4 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[4]<=O[4]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 1)
							begin
								cnt2<=4;
								cnt1<=1;
								state<=state13;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			///////////////////////////////////////////////////
			state13:begin     /// O5 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[5]<=O[5]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 1)
							begin
								cnt2<=5;
								cnt1<=1;
								state<=state14;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			////////////////////////////////////////////////////
			state14:begin     /// O6 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[6]<=O[6]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 1)
							begin
								cnt2<=6;
								cnt1<=1;
								state<=state15;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			///////////////////////////////////////////////////
			state15:begin     /// O7 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[7]<=O[7]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 1)
							begin
								cnt2<=7;
								cnt1<=1;
								state<=state16;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			////////////////////////////////////////////////
			state16:begin     /// O8 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[8]<=O[8]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 1)
							begin
								cnt2<=8;
								cnt1<=1;
								state<=state17;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			//////////////////////////////////////////////
			state17:begin     /// O9 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[9]<=O[9]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 1)
							begin
								cnt2<=9;
								cnt1<=1;
								state<=state18;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			//////////////////////////////////////////////////
			state18:begin     /// O10 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[10]<=O[10]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 2)
							begin
								cnt2<=10;
								cnt1<=1;
								state<=state19;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			///////////////////////////////////////////////////
			state19:begin     /// O11 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[11]<=O[11]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 3)
							begin
								cnt2<=11;
								cnt1<=1;
								state<=state20;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			/////////////////////////////////////////////////
			state20:begin     /// O12 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[12]<=O[12]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 4)
							begin
								cnt2<=12;
								cnt1<=1;
								state<=state21;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			/////////////////////////////////////////
			state21:begin     /// O13 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[13]<=O[13]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 5)
							begin
								cnt2<=13;
								cnt1<=1;
								state<=state22;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			////////////////////////////////////////////////
			state22:begin     /// O14 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[14]<=O[14]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 6)
							begin
								cnt2<=14;
								cnt1<=1;
								state<=state23;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			/////////////////////////////////////////////
			state23:begin     /// O15 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[15]<=O[15]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 7)
							begin
								cnt2<=15;
								cnt1<=1;
								state<=state24;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			//////////////////////////////////////////////
			state24:begin     /// O16 calculation
				if(cnt == 2)
					begin
						cnt<=0;
						O[16]<=O[16]^dec1;
					end
				else
					cnt<=cnt+1;
				/////////////////////////////////////////
				if (cnt == 2)
					begin
						if (cnt2 == 8)
							begin
								cnt2<=0;
								cnt1<=0;
								state<=state25;
							end
						else
							begin
								cnt2<=cnt2-1;
								cnt1<=cnt1+1;
							end
					end
				////////////////////////////////////////
				add_1 <= Lp[cnt1] + Sp[cnt2];
				F1<= (&Lp[cnt1]  ||  &Sp[cnt2])? 1:0;
			end
			////////////////////////////////////////////////
			state25:begin     //// getting power values of O2 : O16
				if (cnt == 6)
					begin
						state<=state26;     
						cnt<=0;
						poly_ready<=1;	
					end
				else
					cnt<=cnt+1;
				///////////////////////////////////////
				case(cnt)
				
				0:begin
					add_pow1<= O[2];
					add_pow2<= O[3];
					add_pow3<= O[4];
				end
				
				1:begin
					add_pow1<= O[5];
					add_pow2<= O[6];
					add_pow3<= O[7];
				end
				
				2:begin
					add_pow1<= O[8];
					add_pow2<= O[9];
					add_pow3<= O[10];
					
					O[2] <= pow1;
					O[3]  <= pow2;
					O[4] <= pow3;
				end
				
				3:begin
					add_pow1<= O[11];
					add_pow2<= O[12];
					add_pow3<= O[13];
					
					O[5] <= pow1;
					O[6]  <= pow2;
					O[7] <= pow3;
				end
				
				4:begin
					add_pow1<= O[14];
					add_pow2<= O[15];
					add_pow3<= O[16];
					
					O[8] <= pow1;
					O[9]  <= pow2;
					O[10] <= pow3;
				end
				
				5:begin
					O[11] <= pow1;
					O[12]  <= pow2;
					O[13] <= pow3;
				end
				
				default:begin
					O[14] <= pow1;
					O[15]  <= pow2;
					O[16] <= pow3;
				end
				
				endcase
				
			end
			/////////////////////////////////////////////////
			default:begin     /// state26   
				poly_ready<=0;
				state<=state1;
			end
			///////////////////////////////////////////////
			endcase
		end
end


endmodule 