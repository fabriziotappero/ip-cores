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



module RS_dec 
//////////// integration of decoder blocks
(
  input clk, // input clock 
  input reset, // active high asynchronous reset
  input CE, // chip enable active high flag for one clock with every input byte (minimum spaceing 8 clocks)
  input [7:0] input_byte, // input byte
  
  output [7:0] Out_byte,   // output byte
  output CEO,  // chip enable for the next block will be active high for one clock , every 8 clks
  output Valid_out /// valid out for every output block (188 byte)
);


wire CEO_0;

///////////////////////////////////////assigns////////////////////////
assign CEO = CEO_0 && Valid_out ;

//////////////////////////////// input_syndromes/////////////////
wire S_ready;  // active high flag for one clock to indicate that syndromes is ready 
/// syndromes decimal values
wire [7:0] s0,s1,s2,s3,s4,s5,s6,s7;   
wire [7:0] s8,s9,s10,s11,s12,s13,s14,s15;   

wire [7:0] In_mem_Read_byte;
wire [7:0] In_mem_R_Add;
wire  In_mem_RE;

/////////////////////////////////////////////////////////////
input_syndromes input_syndromes_unit
(
.clk(clk), 
.reset(reset), 
.CE(CE),  // chip enable active high flag should be active for one clock with every input
.input_byte(input_byte), // input byte

//////////////////////////////////////
.R_Add(In_mem_R_Add),
.RE(In_mem_RE),
.Read_byte(In_mem_Read_byte),

/// syndromes 16 elements
.S_Ready(S_ready),
.s0(s0),.s1(s1),.s2(s2),.s3(s3),.s4(s4),.s5(s5),.s6(s6),.s7(s7),
.s8(s8),.s9(s9),.s10(s10),.s11(s11),.s12(s12),.s13(s13),.s14(s14),.s15(s15)

);

/////////////////transport_in2out////////////////////////////////////
wire WE_transport;
wire [7:0]WrAdd_transport;

wire transport_done;
////////////////////////////////////////////////////////////////
transport_in2out  transport_in2out_unit
(

.clk(clk), 
.reset(reset), 

.S_Ready(S_ready), 

.RE(In_mem_RE),
.RdAdd(In_mem_R_Add),

.WE(WE_transport),  
.WrAdd(WrAdd_transport),

.Wr_done(transport_done)

);


////////BM_lamda//////////////////////////////////////////////////////////
wire  L_ready;  // active high flag for one clock to indicate that lamda polynomial is ready
wire [7:0] L1,L2,L3,L4,L5,L6,L7,L8;   ///  lamda coeff values in decimal format 

reg [7:0] pow1_BM_lamda,pow2_BM_lamda;    
reg [7:0] dec1_BM_lamda;        

wire  [7:0] add_pow1_BM_lamda,add_pow2_BM_lamda;  
wire  [7:0] add_dec1_BM_lamda;    

///////////////////////////////////////////////////////////////////////////////////////////////////
BM_lamda   BM_lamda_unit
(
.clk(clk), 
.reset(reset),

.erasure_ready(1'b0),
.erasure_cnt(4'b0),


.Sm_ready(S_ready),
.Sm1(s0),
.Sm2(s1),
.Sm3(s2),
.Sm4(s3),
.Sm5(s4),
.Sm6(s5),
.Sm7(s6),
.Sm8(s7), 
.Sm9(s8),
.Sm10(s9),
.Sm11(s10),
.Sm12(s11),
.Sm13(s12),
.Sm14(s13),
.Sm15(s14),
.Sm16(s15),




.add_pow1(add_pow1_BM_lamda),  
.add_pow2(add_pow2_BM_lamda),  

.add_dec1(add_dec1_BM_lamda),



.pow1(pow1_BM_lamda),  
.pow2(pow2_BM_lamda),  

.dec1(dec1_BM_lamda),




.L_ready(L_ready),
.L1(L1),
.L2(L2),
.L3(L3),
.L4(L4),
.L5(L5),
.L6(L6),
.L7(L7),
.L8(L8) 
 
);

////////////lamda_roots////////////////////////////////////////////////////////////////
wire roots_ready;
wire [3:0] root_cnt;  //from 0 to 8
wire [7:0] r1,r2,r3,r4,r5,r6,r7,r8; // output roots of lamda polynomial (decimal) up to 8 roots

reg [7:0] pow1_lamda_roots;    
reg [7:0] dec1_lamda_roots,dec2_lamda_roots,dec3_lamda_roots;        

wire  [7:0] add_pow1_lamda_roots;  
wire  [7:0] add_dec1_lamda_roots,add_dec2_lamda_roots,add_dec3_lamda_roots;    

////////////////////////////////////////////////////////////////////////////////////////
lamda_roots lamda_roots_unit
(
.CE(L_ready), 
.clk(clk), 
.reset(reset), 

.Lc0(8'h01),   // always equals one 
.Lc1(L1),
.Lc2(L2),
.Lc3(L3),
.Lc4(L4),
.Lc5(L5),
.Lc6(L6),
.Lc7(L7),
.Lc8(L8), 

.add_GF_ascending(add_pow1_lamda_roots),   
.add_GF_dec0(add_dec1_lamda_roots),
.add_GF_dec1(add_dec2_lamda_roots),
.add_GF_dec2(add_dec3_lamda_roots),         

.power(pow1_lamda_roots),  
.decimal0(dec1_lamda_roots),
.decimal1(dec2_lamda_roots),
.decimal2(dec3_lamda_roots),

.CEO(roots_ready), 
.root_cnt(root_cnt), ///  up to 8
.r1(r1),
.r2(r2),
.r3(r3),
.r4(r4),
.r5(r5),
.r6(r6),
.r7(r7),
.r8(r8)
);

///////////Omega_Phy//////////////////////////////////////////////////////////////////////
wire  poly_ready ;  // active high flag for one clock to indicate that Phy and Omega polynomials are ready

wire   [7:0] O1;    // decimal value of first coeff of Omega polynomial
wire   [7:0] O2,O3,O4,O5,O6,O7,O8,O9,O10,O11,O12,O13,O14,O15,O16;  /// power values of omega polynomial coeff from 2:16

wire   [7:0] P1;    // decimal value of first coeff of Phy polynomial
wire   [7:0] P3,P5,P7;  /// power values of Phy polynomial coeff 

reg [7:0] dec1_Omega_Phy;    
reg [7:0] pow1_Omega_Phy,pow2_Omega_Phy,pow3_Omega_Phy;        

wire  [7:0] add_dec1_Omega_Phy;  
wire  [7:0] add_pow1_Omega_Phy,add_pow2_Omega_Phy,add_pow3_Omega_Phy;    


////////////////////////////////////////////////////////////////////////////////////
Omega_Phy   Omega_Phy_unit
(
.clk(clk), 
.reset(reset), 


.Sm_ready(S_ready),
.Sm1(s0),
.Sm2(s1),
.Sm3(s2),
.Sm4(s3),
.Sm5(s4),
.Sm6(s5),
.Sm7(s6),
.Sm8(s7), 
.Sm9(s8),
.Sm10(s9),
.Sm11(s10),
.Sm12(s11),
.Sm13(s12),
.Sm14(s13),
.Sm15(s14),
.Sm16(s15),





.add_pow1(add_pow1_Omega_Phy),  
.add_pow2(add_pow2_Omega_Phy),  
.add_pow3(add_pow3_Omega_Phy),  

.add_dec1(add_dec1_Omega_Phy),



.pow1(pow1_Omega_Phy),  
.pow2(pow2_Omega_Phy),  
.pow3(pow3_Omega_Phy),  

.dec1(dec1_Omega_Phy),




.L_ready(L_ready),
.L1(L1),
.L2(L2),
.L3(L3),
.L4(L4),
.L5(L5),
.L6(L6),
.L7(L7),
.L8(L8) ,



.poly_ready(poly_ready),
.O1(O1), 
.O2(O2), 
.O3(O3), 
.O4(O4), 
.O5(O5), 
.O6(O6), 
.O7(O7), 
.O8(O8), 
.O9(O9), 
.O10(O10), 
.O11(O11), 
.O12(O12), 
.O13(O13), 
.O14(O14), 
.O15(O15), 
.O16(O16), 

.P1(P1), 
.P3(P3), 
.P5(P5), 
.P7(P7)

);

//////////////////error_correction///////////////////////////////////////////
wire RE_error_correction,WE_error_correction;    
//// write and read enable for input block storage memory
wire  [7:0] Address_error_correction;   //// address to input block storage memory
wire  [7:0] correction_value;     //// corrected value  =  initial value xor  correction
reg [7:0] initial_value;  //// input initial value

wire  DONE;


reg [7:0] pow1_error_correction,pow2_error_correction,pow3_error_correction,pow4_error_correction;    
reg [7:0] dec1_error_correction,dec2_error_correction,dec3_error_correction,dec4_error_correction;        

wire  [7:0] add_pow1_error_correction,add_pow2_error_correction,add_pow3_error_correction,add_pow4_error_correction;  
wire  [7:0] add_dec1_error_correction,add_dec2_error_correction,add_dec3_error_correction,add_dec4_error_correction;    


////////////////////////////////////////////////////////////////////////////////
error_correction   error_correction_unit
(
.clk(clk), // .clock 
.reset(reset), // active high asynchronous reset





.add_pow1(add_pow1_error_correction),  
.add_pow2(add_pow2_error_correction),  
.add_pow3(add_pow3_error_correction),  
.add_pow4(add_pow4_error_correction),  

.add_dec1(add_dec1_error_correction),
.add_dec2(add_dec2_error_correction),
.add_dec3(add_dec3_error_correction),
.add_dec4(add_dec4_error_correction),



.pow1(pow1_error_correction),  
.pow2(pow2_error_correction),  
.pow3(pow3_error_correction),  
.pow4(pow4_error_correction),  

.dec1(dec1_error_correction),
.dec2(dec2_error_correction),
.dec3(dec3_error_correction),
.dec4(dec4_error_correction),




.roots_ready(roots_ready),
.root_count(root_cnt),
.r1(r1),
.r2(r2),
.r3(r3),
.r4(r4),
.r5(r5),
.r6(r6),
.r7(r7),
.r8(r8) ,



.poly_ready(poly_ready),
.O1(O1), 
.O2(O2), 
.O3(O3), 
.O4(O4), 
.O5(O5), 
.O6(O6), 
.O7(O7), 
.O8(O8), 
.O9(O9), 
.O10(O10), 
.O11(O11), 
.O12(O12), 
.O13(O13), 
.O14(O14), 
.O15(O15), 
.O16(O16), 

.P1(P1), 
.P3(P3), 
.P5(P5), 
.P7(P7),  

.RE(RE_error_correction),
.WE(WE_error_correction), 
.Address(Address_error_correction), 
.correction_value(correction_value), 
.initial_value(initial_value),  

.DONE(DONE)

);

///////////////////////out_stage//////////////////////////////////////////////////////////
wire RE_out_stage;
wire [7:0] RdAdd_out_stage;
reg [7:0] In_byte_out_stage;

wire out_done;

reg DONE_ext;   /// if DONE comes before out_stage is completed , extend DONE for the next block
/////////////////////////////////////////////////////////////////////////////////////////////
out_stage   out_stage_unit
(
.clk(clk), 
.reset(reset),

.DONE(DONE || DONE_ext), 

.RE(RE_out_stage),  

.RdAdd(RdAdd_out_stage),

.In_byte(In_byte_out_stage),
 
.Out_byte(Out_byte),
.CEO(CEO_0),
.Valid_out(Valid_out),
 
.out_done(out_done)
);


//////////////////out_memories//////////////////////////////////////////////////////////
reg RE1,WE1,RE2,WE2;
reg [7:0] R_Add1,W_Add1,R_Add2,W_Add2;
wire [7:0] out_byte1,out_byte2;
reg   [7:0] input_byte1,input_byte2;
////////////////////////////////////////////////////////////////////////////////////////////
DP_RAM #(.num_words(188),.address_width(8),.data_width(8)) 
mem_out_1 
(
.clk(clk),
.we(WE1),
.re(RE1),
.address_read(R_Add1),
.address_write(W_Add1),
.data_in(input_byte1),
.data_out(out_byte1)
);

DP_RAM #(.num_words(188),.address_width(8),.data_width(8))  
mem_out_2
(
.clk(clk),
.we(WE2),
.re(RE2),
.address_read(R_Add2),
.address_write(W_Add2),
.data_in(input_byte2),
.data_out(out_byte2)
);

///////////////////////////////////////////////////////////////////////////////////
/////// GF Roms////////////////////////////////////////////////////////////////////

wire [7:0] pow1,pow2,pow3,pow4;    /// output of power memories
wire [7:0] dec1,dec2,dec3,dec4;        /// output of decimal memories

reg  [7:0] add_pow1,add_pow2,add_pow3,add_pow4;  /// address to power memories
reg  [7:0] add_dec1,add_dec2,add_dec3,add_dec4;    /// address to decimal memories

////// instant of GF_matrix_ascending_binary Rom////////////////////////////////////
GF_matrix_ascending_binary   power_rom_instant1
(
.clk(clk),
.re(1'b1),
.address_read(add_pow1),
.data_out(pow1)
);
/////// instant of GF_matrix_ascending_binary Rom////////////////////////////////////
GF_matrix_ascending_binary   power_rom_instant2
(
.clk(clk),
.re(1'b1),
.address_read(add_pow2),
.data_out(pow2)
);
///////// instant of GF_matrix_ascending_binary Rom////////////////////////////////////
GF_matrix_ascending_binary   power_rom_instant3
(
.clk(clk),
.re(1'b1),
.address_read(add_pow3),
.data_out(pow3)
);
////// instant of GF_matrix_ascending_binary Rom////////////////////////////////////
GF_matrix_ascending_binary   power_rom_instant4
(
.clk(clk),
.re(1'b1),
.address_read(add_pow4),
.data_out(pow4)
);
//////////GF_matrix_dec Rom //////////////////////////
GF_matrix_dec rom_instant_1 
(
.clk(clk),
.re(1'b1),
.address_read(add_dec1),
.data_out(dec1)
);
//////////GF_matrix_dec Rom //////////////////////////
GF_matrix_dec rom_instant_2 
(
.clk(clk),
.re(1'b1),
.address_read(add_dec2),
.data_out(dec2)
);

//////////GF_matrix_dec Rom //////////////////////////
GF_matrix_dec rom_instant_3 
(
.clk(clk),
.re(1'b1),
.address_read(add_dec3),
.data_out(dec3)
);

//////////GF_matrix_dec Rom //////////////////////////
GF_matrix_dec rom_instant_4 
(
.clk(clk),
.re(1'b1),
.address_read(add_dec4),
.data_out(dec4)
);

/////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////Main FSM//////////////////
/////////////////////////////////////////////////////////////////////////

reg S_flag,L_flag,R_flag,T_flag,out_flag;

parameter state1  = 6'b000001;
parameter state2  = 6'b000010;
parameter state3  = 6'b000100;
parameter state4  = 6'b001000;
parameter state5  = 6'b010000;
parameter state6  = 6'b100000;
reg [5:0] state = state1;



always@(posedge clk or posedge reset)
begin
	if(reset)
		begin
			S_flag<=0;L_flag<=0;R_flag<=0;T_flag<=0;
			out_flag<=0;
			DONE_ext<=0;
			state<=state1;
		end
	else
		begin
		
			///////////////////////////////////////////////////////////////////////////////////
			if(S_ready)
				begin
					T_flag<=1;
				end			
				
			if(transport_done)
				begin
					T_flag<=0;
				end	
			///////////////////////////////////////////////////////////////////////////////////
			if(DONE )
				out_flag<=1;
			if(out_done && !DONE_ext && !DONE)
				out_flag<=0;
			///////////////////////////////////////////////////////////////////////////////////
			if(DONE  && out_flag && !out_done)  
			///when error correction is done before out_stage end past operation, DONE_ext will be used
				DONE_ext<=1;
			if(out_done)    
			///// when out_stage is done no need for the DONE_ext flag as the out_stage block has allready use it
				DONE_ext<=0;
			///////////////////////////////////////////////////////////////////////////////////
			
			case(state)
			/////////////////////////////////////////////////////////////////////
			state1:begin
				if(S_ready)
					begin
						S_flag<=1;
						state<=state2;
					end
			end
			////////////////////////////////////////////////////////////
			state2:begin
				if(L_ready)
					begin
						S_flag<=0;
						L_flag<=1;
						state<=state3;
					end
			end
			////////////////////////////////////////////////////////////
			state3:begin
				if(roots_ready)
					begin
						L_flag<=0;
						R_flag<=1;
						state<=state4;
					end
			end
			////////////////////////////////////////////////////////////////
			default:begin   ///state4
				if(DONE)
					begin
						R_flag<=0;
						state<=state1;
					end
			end
			/////////////////////////////////////////////////////////////
			
			endcase
		end
end


wire [2:0] control;

assign control ={R_flag,L_flag,S_flag};


////////////////    GF memories switching ////////////////////
always@(*)
begin

	////////////////////////////////////////////////////////////////////////////
	add_pow1<=0;
	add_pow2<=0;
	add_pow3<=0;
	add_pow4<=0;
	add_dec1<=0;
	add_dec2<=0;
	add_dec3<=0;
	add_dec4<=0;
	pow1_BM_lamda<=0;
	pow2_BM_lamda<=0;
	dec1_BM_lamda<=0;
	pow1_lamda_roots<=0;
	pow1_Omega_Phy<=0;
	pow2_Omega_Phy<=0;
	pow3_Omega_Phy<=0;
	dec1_lamda_roots<=0;
	dec2_lamda_roots<=0;
	dec3_lamda_roots<=0;
	dec1_Omega_Phy<=0;
	pow1_error_correction<=0;
	pow2_error_correction<=0;
	pow3_error_correction<=0;
	pow4_error_correction<=0;
	dec1_error_correction<=0;
	dec2_error_correction<=0;
	dec3_error_correction<=0;
	dec4_error_correction<=0;
	////////////////////////////////////////////////////////////////////////////
	case (control)
	///////////////////////////////////////////////////////////////////////////
		3'b001:begin
			add_pow1<=add_pow1_BM_lamda;
			add_pow2<=add_pow2_BM_lamda;
			
			add_dec1<=add_dec1_BM_lamda;
			
			pow1_BM_lamda<=pow1;
			pow2_BM_lamda<=pow2;
			
			dec1_BM_lamda<=dec1;
		end	
	/////////////////////////////////////////////////////////////////////////
		3'b010:begin
			add_pow1<=add_pow1_lamda_roots;
			add_pow2<=add_pow1_Omega_Phy;
			add_pow3<=add_pow2_Omega_Phy;
			add_pow4<=add_pow3_Omega_Phy;
			
			add_dec1<=add_dec1_lamda_roots;
			add_dec2<=add_dec2_lamda_roots;
			add_dec3<=add_dec3_lamda_roots;
			add_dec4<=add_dec1_Omega_Phy;
			
			pow1_lamda_roots<=pow1;
			pow1_Omega_Phy<=pow2;
			pow2_Omega_Phy<=pow3;
			pow3_Omega_Phy<=pow4;
			
			dec1_lamda_roots<=dec1;
			dec2_lamda_roots<=dec2;
			dec3_lamda_roots<=dec3;
			dec1_Omega_Phy<=dec4;
		end
	//////////////////////////////////////////////////////////////////////////////////////		
		3'b100:begin
			add_pow1<=add_pow1_error_correction;
			add_pow2<=add_pow2_error_correction;
			add_pow3<=add_pow3_error_correction;
			add_pow4<=add_pow4_error_correction;
			
			add_dec1<=add_dec1_error_correction;
			add_dec2<=add_dec2_error_correction;
			add_dec3<=add_dec3_error_correction;
			add_dec4<=add_dec4_error_correction;
			
			pow1_error_correction<=pow1;
			pow2_error_correction<=pow2;
			pow3_error_correction<=pow3;
			pow4_error_correction<=pow4;
			
			dec1_error_correction<=dec1;
			dec2_error_correction<=dec2;
			dec3_error_correction<=dec3;
			dec4_error_correction<=dec4;
			
		end	
	////////////////////////////////////////////////////////////////////////////////
	endcase
end
///////////////////////////////////////////////////////////////////////////////////////////////////



///////  Wrting control for out_memories ///////////////////////////////
always@(posedge clk or posedge reset)
begin
	if(reset)
		begin
			WE1<=0;
			WE2<=0;
			
			W_Add1<=0;
			W_Add2<=0;
			
			input_byte1<=0;
			input_byte2<=0;
		end
	
	else
		begin
		
			if(T_flag)
				begin
/////////////////////////////////////////////////transport_in2out
						if (WE_transport )
							begin
								WE1<=1;
								WE2<=0;
								
								W_Add1<=WrAdd_transport;
								W_Add2<=0;
								
								input_byte1<=In_mem_Read_byte;
								input_byte2<=0;
							end
						else
							begin
								WE2<=1;
								WE1<=0;
								
								W_Add2<=WrAdd_transport;
								W_Add1<=0;
								
								input_byte2<=In_mem_Read_byte;
								input_byte1<=0;
							end
				end
				
			else
				begin
//////////////////////////////////////////////////error correction
						if (WE_transport )
							begin
								WE1<=WE_error_correction;
								WE2<=0;
								
								W_Add1<=Address_error_correction;
								W_Add2<=0;
								
								input_byte1<=correction_value;
								input_byte2<=0;
							end
						else
							begin
								WE2<=WE_error_correction;
								WE1<=0;
								
								W_Add2<=Address_error_correction;
								W_Add1<=0;
								
								input_byte2<=correction_value;
								input_byte1<=0;							
							end
///////////////////////////////////////////////////////////////////////////////////////////////////////////
				end	
		end				
end

/////////////////////////////////  Reading control for out_memories ///////////////////////////////
always@(posedge clk or posedge reset)
begin
	if(reset)
		begin
			RE1<=0;
			RE2<=0;
			R_Add1<=0;
			R_Add2<=0;
			initial_value<=0;
			In_byte_out_stage<=0;
		end
	else	
		begin
			if(R_flag)
				begin
					if (WE_transport )
						begin
							RE1<=RE_error_correction;
							R_Add1<=Address_error_correction;
							initial_value<=out_byte1;
						end
					else
						begin
							RE2<=RE_error_correction;
							R_Add2<=Address_error_correction;
							initial_value<=out_byte2;
						end
				end
			
			if(out_flag)
				begin
					if(RE_out_stage)
						begin
							RE1<=1;
							R_Add1<=RdAdd_out_stage;
							In_byte_out_stage<=out_byte1;
						end
					else
						begin
							RE2<=1;
							R_Add2<=RdAdd_out_stage;
							In_byte_out_stage<=out_byte2;
						end
				end
		end	
end

endmodule

