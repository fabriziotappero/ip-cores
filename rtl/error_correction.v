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


module error_correction
//// evaluate error values, locations and correct it
(

input clk, // input clock planned to be 56 Mhz
input reset, // active high asynchronous reset


//active high flag for one clock to indicate that Phy and Omega polynomials are ready
input poly_ready ,
// decimal value of first coeff of Omega polynomial  
input  [7:0] O1,    
/// power values of omega polynomial coeff from 2:16
input  [7:0] O2,O3,O4,O5,O6,O7,O8,O9,O10,O11,O12,O13,O14,O15,O16,  
input [7:0] P1,    // decimal value of first coeff of Phy polynomial
input [7:0] P3,P5,P7,  /// power values of Phy polynomial coeff 

input roots_ready, // output active high flag to indicate that all roots is ready
input [3:0] root_count, ///  up to 8
input [7:0] r1,r2,r3,r4,r5,r6,r7,r8, // roots of lamda polynomial up to 8 roots

input [7:0] pow1,pow2,pow3,pow4,    /// output of power memories
input [7:0] dec1,dec2,dec3, dec4,        /// output of decimal memories

output reg [7:0] add_pow1,add_pow2,add_pow3,add_pow4, /// address to power memories
output  [7:0] add_dec1,add_dec2,add_dec3,add_dec4,  /// address to decimal memories

output RE,WE,    //// Write and read enable for input block storage memory
output reg [7:0] Address,   //// address to input block storage memory
//// corrected value  =  initial value xor  correction
output reg [7:0] correction_value,     
input [7:0] initial_value,  //// input initial value

output reg DONE

);


reg WE_0,RE_0;

reg [3:0] r_cnt;    ///   root count
reg [7:0] rd [1:8];   /// roots decimal values
reg [7:0] rp [1:8];  //// roots power values
reg [7:0] O [1:16]; //// omega poly
reg [7:0] P [1:4];  //// phy poly

reg [7:0] eL [1:8];    /// locations of errors 
reg [7:0] eV [1:8];   //// power values to evaluate to get correction values


reg [7:0] V;
reg [8:0] Vx2;
reg [9:0] Vx3;
reg [10:0] Vx6;
reg [10:0] Vx7;
reg [10:0] Vx8;
reg [11:0] Vx9;


reg [11:0] add1,add2,add3,add4;
reg [8:0] add_1,add_2,add_3,add_4;


reg IS_255_1,IS_255_2,IS_255_3,IS_255_4;
reg IS_255_1_delayed,IS_255_2_delayed,IS_255_3_delayed,IS_255_4_delayed;
reg div1;

reg [7:0] OV,PV;   
////// OV ==> evalute omega in decimal format
////// PV ==> evalute phy in decimal format
reg [3:0] cnt ;

reg [3:0] op_cnt;  

parameter state1  = 7'b0000001;
parameter state2  = 7'b0000010;
parameter state3  = 7'b0000100;
parameter state4  = 7'b0001000;
parameter state5  = 7'b0010000;
parameter state6  = 7'b0100000;
parameter state7  = 7'b1000000;


reg [6:0] state = state1;

integer k;
reg in_range;
//////////////////////////  assigns /////////////////////////////////
assign RE = RE_0 ;
assign WE =(WE_0  &&   ( Address < 188)  && in_range) ? 1:0;



//// to handle mutipilcation / division output (address to decimal memory)
assign add_dec1  =(IS_255_1_delayed)?  8'h00 :
				 (&add_1[7:0] && !add_1[8])?     8'h01 : 
				 (div1)? add_1[7:0] - (add_1[8]) +1 : 
				 add_1[7:0] +add_1[8] +1 ;
				 
assign add_dec2  =(IS_255_2_delayed)?  8'h00 :
				  (&add_2[7:0] )?      8'h01 : 
				  add_2[7:0] +add_2[8] +1 ;

assign add_dec3  =(IS_255_3_delayed)?  8'h00 :
		          (&add_3[7:0] )?      8'h01 : 
				  add_3[7:0] +add_3[8] +1 ;
				  
assign add_dec4  =(IS_255_4_delayed)?  8'h00 :
			      (&add_4[7:0] )?      8'h01 : 
				  add_4[7:0] +add_4[8] +1 ;

always@(posedge clk or posedge reset)
begin
	if(reset)
		begin
			
			for(k=1;k<=16;k=k+1)
				begin
					O[k] <=0;
				end
				
			for(k=1;k<=8;k=k+1)
				begin
					rd[k]<=0;
					rp[k]<=0;
				end
			
			for(k=1;k<=4;k=k+1)
				begin
					P[k]<=0;
				end
				
			for(k=1;k<=8;k=k+1)
				begin
					eL[k]<=0;
					eV[k]<=0;
				end	
					
			 WE_0<=0;RE_0<=0;
				
			r_cnt<=0;	

			 V<=0;
			 Vx2<=0;
			 Vx3<=0;
			 Vx6<=0;
			 Vx7<=0;
			 Vx8<=0;
			 Vx9<=0;


			 add1<=0;add2<=0;add3<=0;add4<=0;
			 add_1<=0;add_2<=0;add_3<=0;add_4<=0;
			 IS_255_1<=0;IS_255_2<=0;IS_255_3<=0;IS_255_4<=0;
			 IS_255_1_delayed<=0;IS_255_2_delayed<=0;
			 IS_255_3_delayed<=0;IS_255_4_delayed<=0;
			 div1<=0;
				
			 in_range<=0;
			 cnt <=0;
			 op_cnt <=0;
			 
			add_pow1<=0;add_pow2<=0;add_pow3<=0;add_pow4<=0;
			
			Address<=0;
			correction_value<=0;
			DONE<=0;
			
			OV<=0;PV<=0;
			state<= state1;
		end
	else
		begin
		case(state)
		///////////////////////////////////////////////////////////
		state1:begin   /// register inputs
			
			for(k=1;k<=8;k=k+1)
				begin
					eL[k]<=188;
					eV[k]<=0;
				end	
			
			
			if(poly_ready)
				begin
					O[1]<=O1;O[2]<=O2;O[3]<=O3;O[4]<=O4;O[5]<=O5;O[6]<=O6;
					O[7]<=O7;O[8]<=O8;     
					O[9]<=O9;O[10]<=O10;O[11]<=O11;O[12]<=O12;O[13]<=O13;
					O[14]<=O14;O[15]<=O15;O[16]<=O16;
					
					P[1]<=P1;P[2]<=P3;P[3]<=P5;P[4]<=P7;
					end
			
			if(roots_ready)
				begin
					r_cnt<= root_count;
					rd[1]<=r1;rd[2]<=r2;rd[3]<=r3;rd[4]<=r4;
					rd[5]<=r5;rd[6]<=r6;rd[7]<=r7;rd[8]<=r8;
					state<=state2;
				end
				
				
		end
		////////////////////////////////////////////////////////
		state2:begin   /// convert roots to power values
			if(cnt == 3 )
				begin
					cnt<=1;
					state<=state3;
				end
			else
				cnt<=cnt+1;
			/////////////////////////////////////////////////////	
			case(cnt)
			
			0:begin
				add_pow1<=rd[1];
				add_pow2<=rd[2];
				add_pow3<=rd[3];
				add_pow4<=rd[4];
			end			
			
			1:begin
				add_pow1<=rd[5];
				add_pow2<=rd[6];
				add_pow3<=rd[7];
				add_pow4<=rd[8];
			end			
			
			2:begin
				rp[1]<=pow1;
				rp[2]<=pow2;
				rp[3]<=pow3;
				rp[4]<=pow4;
			end			
			
			default:begin
				rp[5]<=pow1;
				rp[6]<=pow2;
				rp[7]<=pow3;
				rp[8]<=pow4;
			end			
			
			endcase
		end
		/////////////////////////////////////////////////
		state3:begin   //// allocate eL,eV
			if(cnt == r_cnt)
				begin
					cnt<=0;
					state<=state4;
					op_cnt <=0;
				end
			else
				cnt<=cnt+1;
			///////////////////////////////////////
					eL[cnt]<=(rp[cnt]==0)?0:255-rp[cnt];
					// 0 is a special case
					// error location = inverse power value of root
					eV[cnt]<=rp[cnt];				
		end
		////////////////////////////////////////////////////////
		////// work with the roots one by one 
		state4:begin
			if(cnt==0)
				begin
					op_cnt<=op_cnt+1;
					cnt<=1;
					WE_0<=0;
				end
			else
				begin
					
					if(op_cnt > r_cnt)
						begin
							in_range<=0;
						end
					else	
						begin
							in_range <= 1;
						end
					
					
					if(op_cnt == 9)
						begin
							DONE<=1;
							cnt<=0;
							state<=state7;
						end
					else
						begin
							state<=state5;
							Address<=203-eL[op_cnt];
							RE_0<=1;
							V<= eV[op_cnt];
							Vx2<= eV[op_cnt]+eV[op_cnt];
							Vx3<= eV[op_cnt]+eV[op_cnt]+eV[op_cnt];
							cnt<=0;
							
							div1<=0;
							OV<=O[1];
							PV<=P[1];
							correction_value<=0;
						end
				end
		end
		///////////////////////////////////////////////
		state5:begin   /// main operation
			if(cnt == 7)
				begin
					cnt<=0;
					state<=state6;
				end
			else
				cnt<=cnt+1;
			///////////////////////////////////////
			RE_0<=0;
			
			Vx6<=Vx3+Vx3;    /// ready at 1 
			Vx7<=Vx6+V;       /// ready at 2
			Vx8<=Vx6+Vx2;   /// ready at 2
			Vx9<=Vx6+Vx3;   /// ready at 2
			
			IS_255_1_delayed<=IS_255_1;
			IS_255_2_delayed<=IS_255_2;
			IS_255_3_delayed<=IS_255_3;
			IS_255_4_delayed<=IS_255_4;
			
			add_1<= add1[11:8]+add1[7:0];
			add_2<= add2[11:8]+add2[7:0];
			add_3<= add3[11:8]+add3[7:0];
			add_4<= add4[11:8]+add4[7:0];
			///////////////////////////////////////
			case(cnt)
			
			0:begin
				add1<= O[2]+V;
				add2<= O[3]+Vx2;
				add3<= O[4]+Vx3;
				add4<= O[5]+Vx3+V;
				
				IS_255_1<= (&O[2] || &V)? 1:0;
				IS_255_2<= (&O[3] || &V)? 1:0;
				IS_255_3<= (&O[4] || &V)? 1:0;
				IS_255_4<= (&O[5] || &V)? 1:0;
			end
			
			1:begin
				add1<= O[6]+Vx2+Vx3;
				add2<= O[7]+Vx6;
				add3<= O[8]+Vx6+V;
				add4<= O[9]+Vx6+Vx2;
				
				IS_255_1<= (&O[6] || &V)? 1:0;
				IS_255_2<= (&O[7] || &V)? 1:0;
				IS_255_3<= (&O[8] || &V)? 1:0;
				IS_255_4<= (&O[9] || &V)? 1:0;
			end
			
			2:begin
				add1<= O[10]+Vx9;
				add2<= O[11]+Vx9+V;
				add3<= O[12]+Vx9+Vx2;
				add4<= O[13]+Vx9+Vx3;
				
				IS_255_1<= (&O[10] || &V)? 1:0;
				IS_255_2<= (&O[11] || &V)? 1:0;
				IS_255_3<= (&O[12] || &V)? 1:0;
				IS_255_4<= (&O[13] || &V)? 1:0;
			end
			
			3:begin
				add1<= O[14]+Vx6+Vx7;
				add2<= O[15]+Vx6+Vx8;
				add3<= O[16]+Vx6+Vx9;
				add4<= 0;
				
				IS_255_1<= (&O[14] || &V)? 1:0;
				IS_255_2<= (&O[15] || &V)? 1:0;
				IS_255_3<= (&O[16] || &V)? 1:0;
				IS_255_4<=  1;
			end
			
			default:begin
				add1<= P[2]+Vx2;
				add2<= P[3]+Vx3+V;
				add3<= P[4]+Vx6;
				add4<= 0;
			
				IS_255_1<= (&P[2] || &V)? 1:0;
				IS_255_2<= (&P[3] || &V)? 1:0;
				IS_255_3<= (&P[4] || &V)? 1:0;
				IS_255_4<= 1;
			end
			
			endcase
			/////////////////////////////////////////////////
			if(cnt>2 && cnt < 7)   //// from 3 to 6
				OV<=OV^dec1^dec2^dec3^dec4;
				
			if(cnt ==7)  // 7
				PV<=PV^dec1^dec2^dec3^dec4;
				
		end
		/////////////////////////////////////////////////////
		//// divide OV/PV and write value in output memory	
		state6:begin  	
			if(cnt == 4)
				begin
					cnt<=0;
					WE_0<=1;
					state<=state4;
				end	
			else
				cnt<=cnt+1;
			///////////////////////////////////////
			div1<=1;
			add_pow1<=OV;
			add_pow2<=PV;
			add_1 <= pow1-pow2;
			IS_255_1_delayed<= (&pow1 || &pow2)? 1:0;
			correction_value<= initial_value ^ dec1;
		end
		///////////////////////////////////////////////////////
		default:begin    //// state7
			state<= state1;
			DONE<=0;
			cnt<=0;
		end
		/////////////////////////////////////////////////////
		endcase
		end
end

endmodule 