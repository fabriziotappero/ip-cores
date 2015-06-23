//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : Intra_pred_PE.v
// Generated : Sep 19, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Processing Element for Intra prediction,PE0 ~ PE3
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module Intra_pred_PE (clk,reset_n,mb_type_general,blk4x4_rec_counter,blk4x4_intra_calculate_counter,
	Intra4x4_predmode,Intra16x16_predmode,Intra_chroma_predmode,
	blkAddrA_availability,blkAddrB_availability,mbAddrA_availability,mbAddrB_availability, 
	
	Intra_mbAddrA_window0,Intra_mbAddrA_window1,Intra_mbAddrA_window2,Intra_mbAddrA_window3,
	Intra_mbAddrB_window0,Intra_mbAddrB_window1,Intra_mbAddrB_window2,Intra_mbAddrB_window3,
	Intra_mbAddrC_window0,Intra_mbAddrC_window1,Intra_mbAddrC_window2,Intra_mbAddrC_window3,
	Intra_mbAddrD_window,
	
	Intra_mbAddrA_reg0, Intra_mbAddrA_reg1, Intra_mbAddrA_reg2, Intra_mbAddrA_reg3,
	Intra_mbAddrA_reg4, Intra_mbAddrA_reg5, Intra_mbAddrA_reg6, Intra_mbAddrA_reg7,
	Intra_mbAddrA_reg8, Intra_mbAddrA_reg9, Intra_mbAddrA_reg10,Intra_mbAddrA_reg11,
	Intra_mbAddrA_reg12,Intra_mbAddrA_reg13,Intra_mbAddrA_reg14,Intra_mbAddrA_reg15,
	Intra_mbAddrB_reg0, Intra_mbAddrB_reg1, Intra_mbAddrB_reg2, Intra_mbAddrB_reg3,
	Intra_mbAddrB_reg4, Intra_mbAddrB_reg5, Intra_mbAddrB_reg6, Intra_mbAddrB_reg7,
	Intra_mbAddrB_reg8, Intra_mbAddrB_reg9, Intra_mbAddrB_reg10,Intra_mbAddrB_reg11,
	Intra_mbAddrB_reg12,Intra_mbAddrB_reg13,Intra_mbAddrB_reg14,Intra_mbAddrB_reg15,
	
	blk4x4_pred_output0, blk4x4_pred_output1, blk4x4_pred_output2,
	blk4x4_pred_output4, blk4x4_pred_output5, blk4x4_pred_output6,
	blk4x4_pred_output8, blk4x4_pred_output9, blk4x4_pred_output10,
	blk4x4_pred_output12,blk4x4_pred_output13,blk4x4_pred_output14,
	
	seed,b,c,
	
	PE0_out,PE1_out,PE2_out,PE3_out,PE0_sum_out,PE3_sum_out);
	input clk,reset_n;
	input [3:0] mb_type_general;
	input [4:0] blk4x4_rec_counter;
	input [2:0] blk4x4_intra_calculate_counter;
	input [3:0]	Intra4x4_predmode;
	input [1:0] Intra16x16_predmode;
	input [1:0] Intra_chroma_predmode;
	input blkAddrA_availability;
	input blkAddrB_availability;
	input mbAddrA_availability;
	input mbAddrB_availability;
	input [15:0] Intra_mbAddrA_window0,Intra_mbAddrA_window1,Intra_mbAddrA_window2,Intra_mbAddrA_window3;
	input [15:0] Intra_mbAddrB_window0,Intra_mbAddrB_window1,Intra_mbAddrB_window2,Intra_mbAddrB_window3;
	input [15:0] Intra_mbAddrC_window0,Intra_mbAddrC_window1,Intra_mbAddrC_window2,Intra_mbAddrC_window3;
	input [15:0] Intra_mbAddrD_window;
	input [15:0] Intra_mbAddrA_reg0, Intra_mbAddrA_reg1, Intra_mbAddrA_reg2, Intra_mbAddrA_reg3;
	input [15:0] Intra_mbAddrA_reg4, Intra_mbAddrA_reg5, Intra_mbAddrA_reg6, Intra_mbAddrA_reg7;
	input [15:0] Intra_mbAddrA_reg8, Intra_mbAddrA_reg9, Intra_mbAddrA_reg10,Intra_mbAddrA_reg11;
	input [15:0] Intra_mbAddrA_reg12,Intra_mbAddrA_reg13,Intra_mbAddrA_reg14,Intra_mbAddrA_reg15;
	input [15:0] Intra_mbAddrB_reg0, Intra_mbAddrB_reg1, Intra_mbAddrB_reg2, Intra_mbAddrB_reg3;
	input [15:0] Intra_mbAddrB_reg4, Intra_mbAddrB_reg5, Intra_mbAddrB_reg6, Intra_mbAddrB_reg7;
	input [15:0] Intra_mbAddrB_reg8, Intra_mbAddrB_reg9, Intra_mbAddrB_reg10,Intra_mbAddrB_reg11;
	input [15:0] Intra_mbAddrB_reg12,Intra_mbAddrB_reg13,Intra_mbAddrB_reg14,Intra_mbAddrB_reg15;
	input [15:0] blk4x4_pred_output0, blk4x4_pred_output1, blk4x4_pred_output2;
	input [15:0] blk4x4_pred_output4, blk4x4_pred_output5, blk4x4_pred_output6;
	input [15:0] blk4x4_pred_output8, blk4x4_pred_output9, blk4x4_pred_output10;
	input [15:0] blk4x4_pred_output12,blk4x4_pred_output13,blk4x4_pred_output14;
	input [15:0] seed;
	input [11:0] b,c;
	
	output [7:0] PE0_out;
	output [7:0] PE1_out;
	output [7:0] PE2_out;
	output [7:0] PE3_out;
	output [15:0] PE0_sum_out; //for store as 2nd-level seed
	output [15:0] PE3_sum_out;	//for store as 2nd-level seed
	
	reg [15:0] PE0_in0,PE0_in1,PE0_in2,PE0_in3;
	reg PE0_IsShift;
	reg PE0_IsStore;
	reg PE0_IsClip;
	reg PE0_full_bypass;
	reg [4:0] PE0_round_value;
	reg [2:0] PE0_shift_len;
	
	reg [15:0] PE1_in0,PE1_in1,PE1_in2,PE1_in3;
	reg PE1_IsShift;
	reg PE1_IsStore;
	reg PE1_IsClip;
	reg PE1_full_bypass;
	reg [4:0] PE1_round_value;
	reg [2:0] PE1_shift_len; 
	
	reg [15:0] PE2_in0,PE2_in1,PE2_in2,PE2_in3;
	reg PE2_IsShift;
	reg PE2_IsStore;
	reg PE2_IsClip;
	reg PE2_full_bypass;
	reg [4:0] PE2_round_value;
	reg [2:0] PE2_shift_len; 
	
	reg [15:0] PE3_in0,PE3_in1,PE3_in2,PE3_in3;
	reg PE3_IsShift;
	reg PE3_IsStore;
	reg PE3_IsClip;
	reg PE3_full_bypass;
	reg [4:0] PE3_round_value;
	reg [2:0] PE3_shift_len;
	
	wire [15:0] PE0_out_reg;
	wire [15:0] PE1_out_reg;
	wire [15:0] PE2_out_reg;
	wire [15:0] PE3_out_reg;
	
	wire [15:0] PE0_sum_out;
	wire [15:0] PE1_sum_out;
	wire [15:0] PE2_sum_out;
	wire [15:0] PE3_sum_out;
	
	wire [15:0] b_ext,c_ext;
	assign b_ext = (b[11] == 1'b1)? {4'b1111,b}:{4'b0000,b};
	assign c_ext = (c[11] == 1'b1)? {4'b1111,c}:{4'b0000,c};
	
	PE PE0	(
		.clk(clk),
		.reset_n(reset_n),
		.in0(PE0_in0),
		.in1(PE0_in1),
		.in2(PE0_in2),
		.in3(PE0_in3),
		.IsShift(PE0_IsShift),
		.IsStore(PE0_IsStore),
		.IsClip(PE0_IsClip),
		.full_bypass(PE0_full_bypass),
		.round_value(PE0_round_value),
		.shift_len(PE0_shift_len),
		.PE_out_reg(PE0_out_reg),
		.PE_out(PE0_out),
		.sum_out(PE0_sum_out)
		);
	PE PE1	(
		.clk(clk),
		.reset_n(reset_n),
		.in0(PE1_in0),
		.in1(PE1_in1),
		.in2(PE1_in2),
		.in3(PE1_in3),
		.IsShift(PE1_IsShift),
		.IsStore(PE1_IsStore),
		.IsClip(PE1_IsClip),
		.full_bypass(PE1_full_bypass),
		.round_value(PE1_round_value),
		.shift_len(PE1_shift_len),
		.PE_out_reg(PE1_out_reg),
		.PE_out(PE1_out),
		.sum_out(PE1_sum_out)
		);
	PE PE2	(
		.clk(clk),
		.reset_n(reset_n),
		.in0(PE2_in0),
		.in1(PE2_in1),
		.in2(PE2_in2),
		.in3(PE2_in3),
		.IsShift(PE2_IsShift),
		.IsStore(PE2_IsStore),
		.IsClip(PE2_IsClip),
		.full_bypass(PE2_full_bypass),
		.round_value(PE2_round_value),
		.shift_len(PE2_shift_len),
		.PE_out_reg(PE2_out_reg),
		.PE_out(PE2_out),
		.sum_out(PE2_sum_out)
		);
	PE PE3	(
		.clk(clk),
		.reset_n(reset_n),
		.in0(PE3_in0),
		.in1(PE3_in1),
		.in2(PE3_in2),
		.in3(PE3_in3),
		.IsShift(PE3_IsShift),
		.IsStore(PE3_IsStore),
		.IsClip(PE3_IsClip),
		.full_bypass(PE3_full_bypass),
		.round_value(PE3_round_value),
		.shift_len(PE3_shift_len),
		.PE_out_reg(PE3_out_reg),
		.PE_out(PE3_out),
		.sum_out(PE3_sum_out)
		);
	//----
	//PE0 |
	//----
	always @ (mb_type_general or blk4x4_rec_counter or blk4x4_intra_calculate_counter
		or Intra4x4_predmode or Intra16x16_predmode or Intra_chroma_predmode
		or blkAddrA_availability or blkAddrB_availability or mbAddrA_availability or mbAddrB_availability
		or Intra_mbAddrA_window0 or Intra_mbAddrA_window1 or Intra_mbAddrA_window2
		or Intra_mbAddrB_window0 or Intra_mbAddrB_window1 or Intra_mbAddrB_window2 or Intra_mbAddrB_window3
		or Intra_mbAddrD_window
		or Intra_mbAddrA_reg0 or Intra_mbAddrA_reg1 or Intra_mbAddrA_reg2 or Intra_mbAddrA_reg3
		or Intra_mbAddrB_reg1 or Intra_mbAddrB_reg2 or Intra_mbAddrB_reg3
		or PE0_out_reg or PE1_out_reg or PE2_out_reg or PE3_out_reg
		or blk4x4_pred_output4 or blk4x4_pred_output5  or blk4x4_pred_output8
		or blk4x4_pred_output9 or blk4x4_pred_output10 or blk4x4_pred_output12
		or seed or b_ext or c_ext)
		//Intra 4x4
		if (mb_type_general[3:2] == 2'b11 && blk4x4_rec_counter < 16)
			case (Intra4x4_predmode)
				`Intra4x4_Vertical:	
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE0_in0 <= Intra_mbAddrB_window0;
						3:PE0_in0 <= Intra_mbAddrB_window1;
						2:PE0_in0 <= Intra_mbAddrB_window2;
						1:PE0_in0 <= Intra_mbAddrB_window3;
						default:PE0_in0 <= 0;
					endcase
					PE0_in1 	    <= 0; 	PE0_in2    	    <= 0;	PE0_in3 	  <= 0;	
					PE0_IsShift     <= 0;	PE0_IsStore     <= 0;	PE0_IsClip    <= 0;	
					PE0_full_bypass <= 1;	PE0_round_value <= 0;	PE0_shift_len <= 0;
				end
				`Intra4x4_Horizontal:
				begin
					PE0_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window0:0;
					PE0_in1 	    <= 0; 	PE0_in2 		<= 0;	PE0_in3       <= 0; 	
					PE0_IsShift     <= 0;	PE0_IsStore     <= 0;	PE0_IsClip    <= 0;
					PE0_full_bypass <= 1;	PE0_round_value <= 0;	PE0_shift_len <= 0;
				end
				`Intra4x4_DC:
				case (blk4x4_intra_calculate_counter)
					4:		//A ~ D
					begin
						if (blkAddrB_availability == 1)
							begin
								PE0_in0 <= Intra_mbAddrB_window0;	PE0_in1 <= Intra_mbAddrB_window1;
								PE0_in2 <= Intra_mbAddrB_window2;	PE0_in3 <= Intra_mbAddrB_window3;
								PE0_IsStore <= 1'b1;				PE0_full_bypass <= 1'b0;
							end
						else
							begin
								PE0_in0 <= 0;	PE0_in1 <= 0;	PE0_in2 <= 0;	PE0_in3 <= 0;
								PE0_IsStore <= 1'b0;			PE0_full_bypass <= 1'b1;
							end
						PE0_IsShift     <= 0;	PE0_IsClip    <= 0;
						PE0_round_value <= 0;	PE0_shift_len <= 0;
					end
					3:
					begin
						case ({blkAddrB_availability,blkAddrA_availability})
							2'b00:
							begin
								PE0_in0 <= 128;				PE0_in1 <= 0;	
								PE0_full_bypass <= 1'b1;	PE0_round_value <= 0;	PE0_shift_len <= 0;
							end
							2'b01,2'b10:
							begin
								PE0_in0 <= (blkAddrB_availability)? PE0_out_reg:0;
								PE0_in1 <= (blkAddrA_availability)? PE1_out_reg:0;
								PE0_full_bypass <= 1'b0;	PE0_round_value <= 2;	PE0_shift_len <= 2;
							end
							2'b11:
							begin
								PE0_in0 <= PE0_out_reg;	PE0_in1 <= PE1_out_reg;
								PE0_full_bypass <= 1'b0;	PE0_round_value <= 4;	PE0_shift_len <= 3;
							end
						endcase
						PE0_in2 <= 0;		PE0_in3 <= 0;
						PE0_IsStore <= 0;	PE0_IsShift <= 0;	PE0_IsClip <= 0;
					end
					default:
					begin
						PE0_in0 <= 0;	PE0_in1 <= 0;	PE0_in2 <= 0;	PE0_in3 <= 0; 		
						PE0_IsShift <= 0;		PE0_IsStore <= 0;	PE0_IsClip <= 0;	
						PE0_full_bypass <= 1;	PE0_round_value <= 0;	PE0_shift_len <= 0;
					end
				endcase
				`Intra4x4_Diagonal_Down_Left:
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE0_in0 <= Intra_mbAddrB_window0;
						3:PE0_in0 <= blk4x4_pred_output4;
						2:PE0_in0 <= blk4x4_pred_output8;
						1:PE0_in0 <= blk4x4_pred_output12;
						default:PE0_in0 <= 0;
					endcase
					PE0_in1 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrB_window2:0;
					PE0_in2 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrB_window1:0;
					PE0_in3 <= 0;
					PE0_IsShift <= (blk4x4_intra_calculate_counter == 4)? 1'b1:1'b0;
					PE0_IsStore <= 1'b0; PE0_IsClip <= 1'b0;
					PE0_full_bypass <= (blk4x4_intra_calculate_counter == 4)? 1'b0:1'b1;
					PE0_round_value <= (blk4x4_intra_calculate_counter == 4)? 5'b00010:5'b0; // +2
					PE0_shift_len	<= (blk4x4_intra_calculate_counter == 4)? 3'b010:3'b0;   // >>2
				end		
				`Intra4x4_Diagonal_Down_Right:
				begin
					case (blk4x4_intra_calculate_counter)
						4:begin	PE0_in0 <= Intra_mbAddrB_window0;	PE0_in1 <= Intra_mbAddrA_window0;
								PE0_in2 <= Intra_mbAddrD_window;				end
						3:begin	PE0_in0 <= Intra_mbAddrD_window;	PE0_in1 <= Intra_mbAddrB_window1;
								PE0_in2 <= Intra_mbAddrB_window0;				end
						2:begin	PE0_in0 <= Intra_mbAddrB_window0;	PE0_in1 <= Intra_mbAddrB_window2;
								PE0_in2 <= Intra_mbAddrB_window1;				end
						1:begin	PE0_in0 <= Intra_mbAddrB_window1;	PE0_in1 <= Intra_mbAddrB_window3;
								PE0_in2 <= Intra_mbAddrB_window2;				end		
						default:begin	PE0_in0 <= 0;PE0_in1 <= 0;PE0_in2 <= 0;	end
					endcase
					PE0_in3 <= 0;
					PE0_IsShift <= (blk4x4_intra_calculate_counter == 0)? 1'b0:1'b1;
					PE0_IsStore <= 1'b0; PE0_IsClip <= 1'b0;	PE0_full_bypass <= 1'b0;
					PE0_round_value <= (blk4x4_intra_calculate_counter == 0)? 5'b0:5'b00010; // +2
					PE0_shift_len	<= (blk4x4_intra_calculate_counter == 0)? 3'b0:3'b010;   // >>2
				end
				`Intra4x4_Vertical_Right:
				begin
					case (blk4x4_intra_calculate_counter)
						4:begin	PE0_in0 <= Intra_mbAddrB_window0;PE0_in1 <= Intra_mbAddrD_window; end
						3:begin	PE0_in0 <= Intra_mbAddrB_window0;PE0_in1 <= Intra_mbAddrB_window1;end
						2:begin	PE0_in0 <= Intra_mbAddrB_window2;PE0_in1 <= Intra_mbAddrB_window1;end
						1:begin	PE0_in0 <= Intra_mbAddrB_window2;PE0_in1 <= Intra_mbAddrB_window3;end
						default:begin	PE0_in0 <= 0;PE0_in1 <= 0;							      end
					endcase
					PE0_in2 <= 0;	PE0_in3 <= 0;
					PE0_IsShift <= 1'b0;PE0_IsStore <= 1'b0; PE0_IsClip <= 1'b0;	PE0_full_bypass <= 1'b0;
					PE0_round_value <= (blk4x4_intra_calculate_counter == 0)? 5'b0:5'b00001; // +1
					PE0_shift_len	<= (blk4x4_intra_calculate_counter == 0)? 3'b0:3'b001;   // >>1
				end
				`Intra4x4_Horizontal_Down:
				begin
					case (blk4x4_intra_calculate_counter)
						4:begin	PE0_in0 <= Intra_mbAddrA_window0;PE0_in1 <= Intra_mbAddrD_window;
								PE0_in2 <= 0;
								PE0_round_value <= 5'b00001;	PE0_shift_len <= 3'b001;end
						3:begin	PE0_in0 <= Intra_mbAddrA_window0;PE0_in1 <= Intra_mbAddrB_window0;
								PE0_in2 <= Intra_mbAddrD_window;				
								PE0_round_value <= 5'b00010;	PE0_shift_len <= 3'b010;end
						2:begin	PE0_in0 <= Intra_mbAddrD_window;	 PE0_in1 <= Intra_mbAddrB_window1;
								PE0_in2 <= Intra_mbAddrB_window0;
								PE0_round_value <= 5'b00010;	PE0_shift_len <= 3'b010;end
						1:begin	PE0_in0 <= Intra_mbAddrB_window0;PE0_in1 <= Intra_mbAddrB_window2;
								PE0_in2 <= Intra_mbAddrB_window1;				
								PE0_round_value <= 5'b00010;	PE0_shift_len <= 3'b010;end
						default:begin	PE0_in0 <= 0;PE0_in1 <= 0;PE0_in2 <= 0;	
										PE0_round_value <= 0;PE0_shift_len <= 0;	end
					endcase
					PE0_in3 <= 0;
					PE0_IsShift <= (blk4x4_intra_calculate_counter == 3 || blk4x4_intra_calculate_counter == 2
					|| blk4x4_intra_calculate_counter == 1)? 1'b1:1'b0;
					PE0_IsStore <= 1'b0; PE0_IsClip <= 1'b0;	PE0_full_bypass <= 1'b0;
				end
				`Intra4x4_Vertical_Left:
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE0_in0 <= Intra_mbAddrB_window0;
						3:PE0_in0 <= blk4x4_pred_output8;
						2:PE0_in0 <= blk4x4_pred_output9;
						1:PE0_in0 <= blk4x4_pred_output10;
						default:PE0_in0 <= 0;
					endcase
					PE0_in1 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrB_window1:0;
					PE0_in2 <= 0;	PE0_in3 <= 0;
					PE0_IsShift <= 1'b0; PE0_IsStore <= 1'b0; PE0_IsClip <= 1'b0;
					PE0_full_bypass <= (blk4x4_intra_calculate_counter == 4)? 1'b0:1'b1;
					PE0_round_value <= (blk4x4_intra_calculate_counter == 4)? 5'b00001:5'b0; // +1
					PE0_shift_len	<= (blk4x4_intra_calculate_counter == 4)? 3'b001:3'b0;   // >>1
				end
				`Intra4x4_Horizontal_Up:
				begin
					case (blk4x4_intra_calculate_counter)
						4:begin	PE0_in0 <= Intra_mbAddrA_window0;	PE0_in1 <= Intra_mbAddrA_window1;	end
						3:begin	PE0_in0 <= Intra_mbAddrA_window0;	PE0_in1 <= Intra_mbAddrA_window2;	end
						2:begin	PE0_in0 <= blk4x4_pred_output4;	PE0_in1 <= 0;				 	end
						1:begin	PE0_in0 <= blk4x4_pred_output5;	PE0_in1 <= 0;					end
						default:begin	PE0_in0 <= 0;	PE0_in1 <= 0;									end
					endcase
					PE0_in2 <= (blk4x4_intra_calculate_counter == 3)? Intra_mbAddrA_window1:0;
					PE0_in3 <= 0;
					PE0_IsShift <= (blk4x4_intra_calculate_counter == 3)? 1'b1:1'b0;
					PE0_IsStore <= 1'b0; PE0_IsClip <= 1'b0;
					PE0_full_bypass <= (blk4x4_intra_calculate_counter == 4 || 
										blk4x4_intra_calculate_counter == 3)? 1'b0:1'b1;
					PE0_round_value <= (blk4x4_intra_calculate_counter == 4)? 5'd1:
								       (blk4x4_intra_calculate_counter == 3)? 5'd2:5'd0;
				 	PE0_shift_len	<= (blk4x4_intra_calculate_counter == 4)? 3'd1:
								       (blk4x4_intra_calculate_counter == 3)? 3'd2:3'd0;
				end
				default:
				begin
					PE0_in0 <= 0;	PE0_in1 <= 0;	PE0_in2 <= 0;	PE0_in3 <= 0;
					PE0_IsShift 	<= 0;	PE0_IsStore 	<= 0;	PE0_IsClip 	  <= 0;
					PE0_full_bypass <= 0;	PE0_round_value <= 0;	PE0_shift_len <= 0;	
				end
			endcase
		//Intra16x16
		else if (mb_type_general[3:2] == 2'b10 && blk4x4_rec_counter < 16)
			case (Intra16x16_predmode)
				`Intra16x16_Vertical:
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE0_in0 <= Intra_mbAddrB_window0;
						3:PE0_in0 <= Intra_mbAddrB_window1;
						2:PE0_in0 <= Intra_mbAddrB_window2;
						1:PE0_in0 <= Intra_mbAddrB_window3;
						default:PE0_in0 <= 0;
					endcase
					PE0_in1 		<= 0; 	PE0_in2 		<= 0;	PE0_in3       <= 0; 		
					PE0_IsShift 	<= 0;	PE0_IsStore 	<= 0;	PE0_IsClip 	  <= 0;
					PE0_full_bypass <= 1;	PE0_round_value <= 0;	PE0_shift_len <= 0;
				end
				`Intra16x16_Horizontal:
				begin
					PE0_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window0:0;
					PE0_in1 		<= 0; 	PE0_in2 		<= 0;	PE0_in3 	  <= 0; 		
					PE0_IsShift 	<= 0;	PE0_IsStore 	<= 0;	PE0_IsClip    <= 0;
					PE0_full_bypass <= 1;	PE0_round_value <= 0;	PE0_shift_len <= 0;
				end
				`Intra16x16_DC:
				if (blk4x4_rec_counter == 0)
					case (blk4x4_intra_calculate_counter)
						4:begin		//	A2 + B2 + C2 + D2
							PE0_in0 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg0;
							PE0_in1 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg1;
							PE0_in2 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg2;
							PE0_in3 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg3;
							PE0_IsShift 	<= 0;	PE0_IsStore 	<= 1;	PE0_IsClip    <= 0;
							PE0_full_bypass <= 0;	PE0_round_value <= 0;	PE0_shift_len <= 0;	end
						3:begin		//	PE0 output + B1 + C1 + D1
							PE0_in0 <= PE0_out_reg;
							PE0_in1 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg1;
							PE0_in2 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg2;
							PE0_in3 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg3;
							PE0_IsShift 	<= 0;	PE0_IsStore 	<= 1;	PE0_IsClip 	  <= 0;
							PE0_full_bypass <= 0;	PE0_round_value <= 0;	PE0_shift_len <= 0;	end
						2:begin		//	PE0 output + PE1 output + PE2 output + PE3 output
							PE0_in0 <= PE0_out_reg;	PE0_in1 <= PE1_out_reg;
							PE0_in2 <= PE2_out_reg;	PE0_in3 <= PE3_out_reg;
							PE0_IsShift 	<= 0;	PE0_IsStore 	<= 1;	PE0_IsClip 	  <= 0;
							PE0_full_bypass <= 0;	PE0_round_value <= 0;	PE0_shift_len <= 0;	end
						1:begin		//	final DC output
							PE0_in0 <= (!mbAddrA_availability && !mbAddrB_availability)? 16'd128:PE0_out_reg;
							PE0_in1 <= PE1_out_reg;		PE0_in2 	<= 0;	PE0_in3    <= 0;
							PE0_IsShift <= 0;			PE0_IsStore <= 1;	PE0_IsClip <= 0;
							PE0_full_bypass <= (!mbAddrA_availability && !mbAddrB_availability)? 1'b1    :1'b0;
							PE0_round_value <= ( mbAddrA_availability &&  mbAddrB_availability)? 5'b10000:5'b01000;		
							PE0_shift_len 	<= ( mbAddrA_availability &&  mbAddrB_availability)? 3'b101  :3'b100;
						  end
						default:begin
							PE0_in0 <= 0;	PE0_in1 <= 0;	PE0_in2 <= 0;	PE0_in3 <= 0;
							PE0_IsShift 	<= 0;	PE0_IsStore 	<= 0;	PE0_IsClip 	  <= 0;
							PE0_full_bypass <= 0;	PE0_round_value <= 0;	PE0_shift_len <= 0;	end
					endcase
				else
					begin
						PE0_in0 <= 0;	PE0_in1 <= 0;	PE0_in2 <= 0;	PE0_in3 <= 0;
						PE0_IsShift 	<= 0;	PE0_IsStore 	<= 0;	PE0_IsClip 	  <= 0;
						PE0_full_bypass <= 0;	PE0_round_value <= 0;	PE0_shift_len <= 0;
					end
				`Intra16x16_Plane:
				begin
					if (blk4x4_intra_calculate_counter != 0)
						//blk0,2,4,6,8,10,12,14,calc counter == 3'b100:PE0_in0 <= seed;
						//other cases								  :PE0_in0 <= left pixel output
						PE0_in0 <= (blk4x4_intra_calculate_counter == 4 && blk4x4_rec_counter[0] == 1'b0)? 
									seed:PE0_out_reg;
					else
						PE0_in0 <= 0;
					//blk0,2,8,10,calc counter == 3'b100:PE0_in1 <= c_ext
					//other cases                       :PE0_in1 <= b_ext
					if (blk4x4_intra_calculate_counter != 0)
						PE0_in1 <= (blk4x4_intra_calculate_counter == 4 && !blk4x4_rec_counter[2] && !blk4x4_rec_counter[0])?
									c_ext:b_ext;
					else
						PE0_in1 <= 0;
					PE0_in2			<= 0;		PE0_in3	<= 0;
					PE0_IsShift 	<= 1'b0;
					PE0_IsStore		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE0_IsClip 		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE0_full_bypass	<= 1'b0;
					PE0_round_value <= (blk4x4_intra_calculate_counter != 0)? 5'd16:5'd0;
					PE0_shift_len	<= (blk4x4_intra_calculate_counter != 0)? 3'd5 :3'd0;
				end
			endcase
		//Chroma
		else if (mb_type_general[3] == 1'b1 && blk4x4_rec_counter > 15)
			case (Intra_chroma_predmode)
				`Intra_chroma_DC:
				begin
					case ({mbAddrA_availability,mbAddrB_availability})
						2'b00:PE0_in0 <= (blk4x4_intra_calculate_counter == 3)? 15'd128:15'd0;
						2'b01:PE0_in0 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrB_window0:
										 (blk4x4_intra_calculate_counter == 3)? PE0_out_reg:0;
						2'b10:PE0_in0 <= (blk4x4_intra_calculate_counter == 3)? PE1_out_reg:0;
						2'b11:
						if (blk4x4_intra_calculate_counter == 4)
							PE0_in0 <= (blk4x4_rec_counter == 18 || blk4x4_rec_counter == 22)? 
										0:Intra_mbAddrB_window0;
						else if (blk4x4_intra_calculate_counter == 3)
							PE0_in0 <= PE0_out_reg;
						else
							PE0_in0 <= 0;
					endcase
					case ({mbAddrA_availability,mbAddrB_availability})
						2'b00:PE0_in1 <= 0;
						2'b01:PE0_in1 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrB_window1:0;
						2'b10:PE0_in1 <= 0;
						2'b11:
						if (blk4x4_intra_calculate_counter == 4)
							PE0_in1 <= (blk4x4_rec_counter == 18 || blk4x4_rec_counter == 22)? 
										0:Intra_mbAddrB_window1;
						else if (blk4x4_intra_calculate_counter == 3)
							PE0_in1 <= PE1_out_reg;
						else
							PE0_in1 <= 0;
					endcase
					case (mbAddrB_availability)
						1'b0:begin PE0_in2 <= 0; PE0_in3 <= 0; end
						1'b1:
						begin
							if (blk4x4_intra_calculate_counter == 4)
								begin
									PE0_in2 <= ((blk4x4_rec_counter == 18 || blk4x4_rec_counter == 22) && mbAddrA_availability)?
												0:Intra_mbAddrB_window2;
									PE0_in3 <= ((blk4x4_rec_counter == 18 || blk4x4_rec_counter == 22) && mbAddrA_availability)?
												0:Intra_mbAddrB_window3;
								end
							else
								begin PE0_in2 <= 0; PE0_in3 <= 0; end
						end
					endcase
					PE0_IsShift <= 1'b0;
					PE0_IsStore <= (mbAddrB_availability && blk4x4_intra_calculate_counter == 4)? 1'b1:1'b0; 
					PE0_IsClip  <= 1'b0;
					PE0_full_bypass <= (!mbAddrA_availability && !mbAddrB_availability && 
										blk4x4_intra_calculate_counter == 3)? 1'b1:1'b0;
					case ({mbAddrA_availability,mbAddrB_availability})
						2'b00		:begin PE0_round_value <= 0; PE0_shift_len <= 0; end
						2'b01,2'b10	:begin PE0_round_value <= (blk4x4_intra_calculate_counter == 3)? 5'd2:5'd0;
										   PE0_shift_len   <= (blk4x4_intra_calculate_counter == 3)? 3'd2:3'd0; end	
						2'b11:
						begin
							if (blk4x4_intra_calculate_counter == 3)
								begin 
									PE0_round_value <= (blk4x4_rec_counter == 16 || blk4x4_rec_counter == 19 || 
									blk4x4_rec_counter == 20 || blk4x4_rec_counter == 23)? 5'd4:5'd2;
									PE0_shift_len   <= (blk4x4_rec_counter == 16 || blk4x4_rec_counter == 19 || 
									blk4x4_rec_counter == 20 || blk4x4_rec_counter == 23)? 3'd3:3'd2;
								end
							else
								begin PE0_round_value <= 0; PE0_shift_len <= 0; end
						end		
					endcase
				end
				`Intra_chroma_Horizontal:	//---horizontal---
				begin
					PE0_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window0:0;
					PE0_in1 		<= 0; 	PE0_in2 		<= 0;	PE0_in3 	  <= 0; 		
					PE0_IsShift 	<= 0;	PE0_IsStore 	<= 0;	PE0_IsClip    <= 0;
					PE0_full_bypass <= 1;	PE0_round_value <= 0;	PE0_shift_len <= 0;
				end
				`Intra_chroma_Vertical:		//---vertical---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE0_in0 <= Intra_mbAddrB_window0;
						3:PE0_in0 <= Intra_mbAddrB_window1;
						2:PE0_in0 <= Intra_mbAddrB_window2;
						1:PE0_in0 <= Intra_mbAddrB_window3;
						default:PE0_in0 <= 0;
					endcase
					PE0_in1 		<= 0; 	PE0_in2 		<= 0;	PE0_in3       <= 0; 		
					PE0_IsShift 	<= 0;	PE0_IsStore 	<= 0;	PE0_IsClip 	  <= 0;
					PE0_full_bypass <= 1;	PE0_round_value <= 0;	PE0_shift_len <= 0;
				end
				`Intra_chroma_Plane:			//---plane---
				begin
					if (blk4x4_intra_calculate_counter != 0)
						//need seed,	   blk4x4 = 16 | 18 | 20 | 22
						//do not need seed,blk4x4 = 17 | 19 | 21 | 23
						PE0_in0 <= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? 
									seed:PE0_out_reg;
					else
						PE0_in0 <= 0;
					if (blk4x4_intra_calculate_counter != 0)
						PE0_in1 <= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? c_ext:b_ext;
					else
						PE0_in1 <= 0;
					PE0_in2			<= 0;		PE0_in3	<= 0;
					PE0_IsShift 	<= 1'b0;
					PE0_IsStore		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE0_IsClip 		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE0_full_bypass	<= 1'b0;
					PE0_round_value <= (blk4x4_intra_calculate_counter != 0)? 5'd16:5'd0;
					PE0_shift_len	<= (blk4x4_intra_calculate_counter != 0)? 3'd5 :3'd0;
				end
			endcase
		else
			begin
				PE0_in0 <= 0;	PE0_in1 <= 0;	PE0_in2 <= 0;	PE0_in3 <= 0;
				PE0_IsShift 	<= 0;	PE0_IsStore 	<= 0;	PE0_IsClip 	  <= 0;
				PE0_full_bypass <= 0;	PE0_round_value <= 0;	PE0_shift_len <= 0;	
			end
	//----
	//PE1 |
	//----
	always @ (mb_type_general or blk4x4_rec_counter or blk4x4_intra_calculate_counter
		or Intra4x4_predmode or Intra16x16_predmode or Intra_chroma_predmode
		or blkAddrA_availability or mbAddrA_availability or mbAddrB_availability
		
		or Intra_mbAddrA_window0 or Intra_mbAddrA_window1 or Intra_mbAddrA_window2 or Intra_mbAddrA_window3
		or Intra_mbAddrB_window0 or Intra_mbAddrB_window1 or Intra_mbAddrB_window2 or Intra_mbAddrB_window3
		or Intra_mbAddrD_window
		
		or Intra_mbAddrA_reg4 or Intra_mbAddrA_reg5 or Intra_mbAddrA_reg6 or Intra_mbAddrA_reg7
		or Intra_mbAddrB_reg0 or Intra_mbAddrB_reg4 or Intra_mbAddrB_reg5 or Intra_mbAddrB_reg6
		or Intra_mbAddrB_reg7 or Intra_mbAddrB_reg8 or Intra_mbAddrB_reg12
		
		or PE1_out_reg 
		or blk4x4_pred_output0  or blk4x4_pred_output1 or blk4x4_pred_output2
		or blk4x4_pred_output8  or blk4x4_pred_output9 or blk4x4_pred_output12
		or blk4x4_pred_output13 or blk4x4_pred_output14
		or seed or b_ext or c_ext)
		//Intra 4x4																						  
		if (mb_type_general[3:2] == 2'b11 && blk4x4_rec_counter < 16)				
			case (Intra4x4_predmode)
				`Intra4x4_Vertical:	//---Vertical---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE1_in0 <= Intra_mbAddrB_window0;
						3:PE1_in0 <= Intra_mbAddrB_window1;
						2:PE1_in0 <= Intra_mbAddrB_window2;
						1:PE1_in0 <= Intra_mbAddrB_window3;
						default:PE1_in0 <= 0;
					endcase
					PE1_in1 	    <= 0; 	PE1_in2    	    <= 0;	PE1_in3 	  <= 0;	
					PE1_IsShift     <= 0;	PE1_IsStore     <= 0;	PE1_IsClip    <= 0;	
					PE1_full_bypass <= 1;	PE1_round_value <= 0;	PE1_shift_len <= 0;
				end
				`Intra4x4_Horizontal:	//---Horizontal---
				begin
					PE1_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window1:0;
					PE1_in1 	    <= 0; 	PE1_in2 		<= 0;	PE1_in3       <= 0; 	
					PE1_IsShift     <= 0;	PE1_IsStore     <= 0;	PE1_IsClip    <= 0;
					PE1_full_bypass <= 1;	PE1_round_value <= 0;	PE1_shift_len <= 0;
				end
				`Intra4x4_DC:			//---DC---
				begin
					PE1_in0 <= (blk4x4_intra_calculate_counter == 4 && blkAddrA_availability == 1)? 
								Intra_mbAddrA_window0:0;
					PE1_in1 <= (blk4x4_intra_calculate_counter == 4 && blkAddrA_availability == 1)? 
								Intra_mbAddrA_window1:0;
					PE1_in2 <= (blk4x4_intra_calculate_counter == 4 && blkAddrA_availability == 1)? 
								Intra_mbAddrA_window2:0;
					PE1_in3 <= (blk4x4_intra_calculate_counter == 4 && blkAddrA_availability == 1)? 
								Intra_mbAddrA_window3:0;
					PE1_IsStore <= (blk4x4_intra_calculate_counter == 4 && blkAddrA_availability == 1)? 1'b1:1'b0;
					PE1_full_bypass <= 1'b0;	PE1_IsShift   <= 0;	PE1_IsClip    <= 0;
					PE1_round_value <= 0;	PE1_shift_len <= 0;
				end
				`Intra4x4_Diagonal_Down_Left:	//---diagonal down-left---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE1_in0 <= Intra_mbAddrB_window1;
						3:PE1_in0 <= blk4x4_pred_output8;
						2:PE1_in0 <= blk4x4_pred_output12;
						1:PE1_in0 <= blk4x4_pred_output13;
						default:PE1_in0 <= 0;
					endcase
					PE1_in1 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrB_window3:0;
					PE1_in2 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrB_window2:0;
					PE1_in3 <= 0;
					PE1_IsShift <= (blk4x4_intra_calculate_counter == 4)? 1'b1:1'b0;
					PE1_IsStore <= 1'b0; PE1_IsClip <= 1'b0;
					PE1_full_bypass <= (blk4x4_intra_calculate_counter == 4)? 1'b0:1'b1;
					PE1_round_value <= (blk4x4_intra_calculate_counter == 4)? 5'b00010:5'b0; // +2
					PE1_shift_len	<= (blk4x4_intra_calculate_counter == 4)? 3'b010  :3'b0; // >>2
				end		
				`Intra4x4_Diagonal_Down_Right:	//---diagonal down-right---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE1_in0 <= Intra_mbAddrD_window;
						3:PE1_in0 <= blk4x4_pred_output0;
						2:PE1_in0 <= blk4x4_pred_output1;
						1:PE1_in0 <= blk4x4_pred_output2;
						default:PE1_in0 <= 0;
					endcase
					PE1_in1 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrA_window1:0;
					PE1_in2 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrA_window0:0;
					PE1_in3 <= 0;
					PE1_IsShift <= (blk4x4_intra_calculate_counter == 0)? 1'b0:1'b1;
					PE1_IsStore <= 1'b0; PE1_IsClip <= 1'b0;	
					PE1_full_bypass <= (blk4x4_intra_calculate_counter == 4)? 1'b0:1'b1;
					PE1_round_value <= (blk4x4_intra_calculate_counter == 0)? 5'b0:5'b00010; // +2
					PE1_shift_len	<= (blk4x4_intra_calculate_counter == 0)? 3'b0:3'b010;   // >>2
				end
				`Intra4x4_Vertical_Right:		//---vertical right---
				begin
					case (blk4x4_intra_calculate_counter)
						4:begin	PE1_in0 <= Intra_mbAddrB_window0;	PE1_in1 <= Intra_mbAddrA_window0;
								PE1_in2 <= Intra_mbAddrD_window;				end
						3:begin	PE1_in0 <= Intra_mbAddrD_window;	 	PE1_in1 <= Intra_mbAddrB_window1;
								PE1_in2 <= Intra_mbAddrB_window0;				end
						2:begin	PE1_in0 <= Intra_mbAddrB_window0;	PE1_in1 <= Intra_mbAddrB_window2;
								PE1_in2 <= Intra_mbAddrB_window1;				end
						1:begin	PE1_in0 <= Intra_mbAddrB_window1;	PE1_in1 <= Intra_mbAddrB_window3;
								PE1_in2 <= Intra_mbAddrB_window2;				end		
						default:begin	PE1_in0 <= 0;PE1_in1 <= 0;PE1_in2 <= 0;	end
					endcase
					PE1_in3 <= 0;
					PE1_IsShift <= (blk4x4_intra_calculate_counter == 0)? 1'b0:1'b1;
					PE1_IsStore <= 1'b0; PE1_IsClip <= 1'b0;	PE1_full_bypass <= 1'b0;
					PE1_round_value <= (blk4x4_intra_calculate_counter == 0)? 5'b0:5'b00010; // +2
					PE1_shift_len	<= (blk4x4_intra_calculate_counter == 0)? 3'b0:3'b010;   // >>2
				end
				`Intra4x4_Horizontal_Down:		//---horizontal down---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE1_in0 <= Intra_mbAddrA_window0;
						3:PE1_in0 <= Intra_mbAddrD_window;
						2:PE1_in0 <= blk4x4_pred_output0;
						1:PE1_in0 <= blk4x4_pred_output1;
						default:PE1_in0 <= 0;
					endcase
					PE1_in1 <= (blk4x4_intra_calculate_counter == 4 || blk4x4_intra_calculate_counter == 3)?
								Intra_mbAddrA_window1:0;
					PE1_in2 <= (blk4x4_intra_calculate_counter == 3)? Intra_mbAddrA_window0:0;
					PE1_in3 <= 0;
					PE1_IsShift <= (blk4x4_intra_calculate_counter == 3)? 1'b1:1'b0;
					PE1_IsStore <= 1'b0; PE1_IsClip <= 1'b0;
					PE1_full_bypass <= (blk4x4_intra_calculate_counter == 2 || 
										blk4x4_intra_calculate_counter == 1)? 1'b1:1'b0;
					PE1_round_value <= (blk4x4_intra_calculate_counter == 4)? 5'd1:
									   (blk4x4_intra_calculate_counter == 3)? 5'd2:5'd0; 
				 	PE1_shift_len	<= (blk4x4_intra_calculate_counter == 4)? 3'd1:
									   (blk4x4_intra_calculate_counter == 3)? 3'd2:3'd0; 
				end
				`Intra4x4_Vertical_Left:			//---vertical left---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE1_in0 <= Intra_mbAddrB_window0;
						3:PE1_in0 <= blk4x4_pred_output12;
						2:PE1_in0 <= blk4x4_pred_output13;
						1:PE1_in0 <= blk4x4_pred_output14;
						default:PE1_in0 <= 0;
					endcase
					PE1_in1 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrB_window2:0;
					PE1_in2 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrB_window1:0;
					PE1_in3 <= 0;
					PE1_IsShift <= (blk4x4_intra_calculate_counter == 4)? 1'b1:1'b0; 
					PE1_IsStore <= 1'b0; PE1_IsClip <= 1'b0;
					PE1_full_bypass <= (blk4x4_intra_calculate_counter == 4)? 1'b0:1'b1;
					PE1_round_value <= (blk4x4_intra_calculate_counter == 4)? 5'd2:5'd0; // +2
					PE1_shift_len	<= (blk4x4_intra_calculate_counter == 4)? 3'd2:3'd0; // >>2
				end
				`Intra4x4_Horizontal_Up:			//---horizontal up---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE1_in0 <= Intra_mbAddrA_window1;
						3:PE1_in0 <= Intra_mbAddrA_window1;
						2:PE1_in0 <= blk4x4_pred_output8;
						1:PE1_in0 <= blk4x4_pred_output9;
						default:PE1_in0 <= 0;
					endcase
					PE1_in1 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrA_window2:
							   (blk4x4_intra_calculate_counter == 3)? Intra_mbAddrA_window3:0;
					PE1_in2 <= (blk4x4_intra_calculate_counter == 3)? Intra_mbAddrA_window2:0;
					PE1_in3 <= 0;
					PE1_IsShift <= (blk4x4_intra_calculate_counter == 3)? 1'b1:1'b0;
					PE1_IsStore <= 1'b0; PE1_IsClip <= 1'b0;	
					PE1_full_bypass <= (blk4x4_intra_calculate_counter == 2 || 
										blk4x4_intra_calculate_counter == 1)? 1'b1:1'b0;
					PE1_round_value <= (blk4x4_intra_calculate_counter == 4)? 5'd1:
									   (blk4x4_intra_calculate_counter == 3)? 5'd2:5'd0; 
				 	PE1_shift_len	<= (blk4x4_intra_calculate_counter == 4)? 3'd1:
									   (blk4x4_intra_calculate_counter == 3)? 3'd2:3'd0; 
				end
				default:
				begin
					PE1_in0 <= 0;	PE1_in1 <= 0;	PE1_in2 <= 0;	PE1_in3 <= 0;
					PE1_IsShift 	<= 0;	PE1_IsStore 	<= 0;	PE1_IsClip 	  <= 0;
					PE1_full_bypass <= 0;	PE1_round_value <= 0;	PE1_shift_len <= 0;	
				end
			endcase
		//Intra16x16
		else if (mb_type_general[3:2] == 2'b10 && blk4x4_rec_counter < 16)
			case (Intra16x16_predmode)
				`Intra16x16_Vertical:	//---Vertical---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE1_in0 <= Intra_mbAddrB_window0;
						3:PE1_in0 <= Intra_mbAddrB_window1;
						2:PE1_in0 <= Intra_mbAddrB_window2;
						1:PE1_in0 <= Intra_mbAddrB_window3;
						default:PE1_in0 <= 0;
					endcase
					PE1_in1 		<= 0; 	PE1_in2 		<= 0;	PE1_in3       <= 0; 		
					PE1_IsShift 	<= 0;	PE1_IsStore 	<= 0;	PE1_IsClip 	  <= 0;
					PE1_full_bypass <= 1;	PE1_round_value <= 0;	PE1_shift_len <= 0;
				end
				`Intra16x16_Horizontal:	//---Horizontal---
				begin
					PE1_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window1:0;
					PE1_in1 		<= 0; 	PE1_in2 		<= 0;	PE1_in3 	  <= 0; 		
					PE1_IsShift 	<= 0;	PE1_IsStore 	<= 0;	PE1_IsClip    <= 0;
					PE1_full_bypass <= 1;	PE1_round_value <= 0;	PE1_shift_len <= 0;
				end
				`Intra16x16_DC:	//---DC---
				if (blk4x4_rec_counter == 0)
					case (blk4x4_intra_calculate_counter)
						4:begin		//	E2 + F2 + G2 + H2
							PE1_in0 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg4;
							PE1_in1 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg5;
							PE1_in2 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg6;
							PE1_in3 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg7;
							PE1_IsShift 	<= 0;	PE1_IsStore 	<= 1;	PE1_IsClip    <= 0;
							PE1_full_bypass <= 0;	PE1_round_value <= 0;	PE1_shift_len <= 0;	end
						3:begin		//	PE1 output + F1 + G1 + H1
							PE1_in0 <= PE1_out_reg;
							PE1_in1 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg5;
							PE1_in2 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg6;
							PE1_in3 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg7;
							PE1_IsShift 	<= 0;	PE1_IsStore 	<= 1;	PE1_IsClip 	  <= 0;
							PE1_full_bypass <= 0;	PE1_round_value <= 0;	PE1_shift_len <= 0;	end
						2:begin		//	A1 + E1 + I1 + M1
							PE1_in0 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg0;
							PE1_in1 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg4;
							PE1_in2 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg8;
							PE1_in3 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg12;
							PE1_IsShift 	<= 0;	PE1_IsStore 	<= 1;	PE1_IsClip 	  <= 0;
							PE1_full_bypass <= 0;	PE1_round_value <= 0;	PE1_shift_len <= 0;	end
						default:begin
							PE1_in0 <= 0;	PE1_in1 <= 0;	PE1_in2 <= 0;	PE1_in3 <= 0;
							PE1_IsShift 	<= 0;	PE1_IsStore 	<= 0;	PE1_IsClip 	  <= 0;
							PE1_full_bypass <= 0;	PE1_round_value <= 0;	PE1_shift_len <= 0;	end
					endcase
				else
					begin
						PE1_in0 <= 0;	PE1_in1 <= 0;	PE1_in2 <= 0;	PE1_in3 <= 0;
						PE1_IsShift 	<= 0;	PE1_IsStore 	<= 0;	PE1_IsClip 	  <= 0;
						PE1_full_bypass <= 0;	PE1_round_value <= 0;	PE1_shift_len <= 0;
					end
				`Intra16x16_Plane:	//---plane---
				begin
					if (blk4x4_intra_calculate_counter != 0)
						//blk0,2,4,6,8,10,12,14,calc counter == 3'b100:PE1_in0 <= seed;
						//other cases								  :PE1_in0 <= left pixel output
						PE1_in0 <= (blk4x4_intra_calculate_counter == 4 && blk4x4_rec_counter[0] == 1'b0)? 
									seed:PE1_out_reg;
					else
						PE1_in0 <= 0;
					if (blk4x4_intra_calculate_counter != 0)
						//blk0,2,8,10,calc counter == 3'b100:PE1_in1 <= c_ext x 2
						//other cases                       :PE1_in1 <= b_ext
						PE1_in1 <= (blk4x4_intra_calculate_counter == 4 && !blk4x4_rec_counter[2] && !blk4x4_rec_counter[0])? 
									{c_ext[14:0],1'b0}:b_ext;
					else
						PE1_in1 <= 0;
					//blk4,6,12,14,calc counter == 3'b100:PE1_in2 <= c_ext;
					//other cases						 :PE1_in2 <= 0
					PE1_in2	<= (blk4x4_intra_calculate_counter == 4 && blk4x4_rec_counter[2] && !blk4x4_rec_counter[0])?
								c_ext:0;
					PE1_in3	<= 0;
					PE1_IsShift	 	<= 1'b0;
					PE1_IsStore		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE1_IsClip 		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE1_full_bypass	<= 1'b0;
					PE1_round_value <= (blk4x4_intra_calculate_counter != 0)? 5'd16:5'd0;
					PE1_shift_len	<= (blk4x4_intra_calculate_counter != 0)? 3'd5 :3'd0;
				end
			endcase
		//Chroma
		else if (mb_type_general[3] == 1'b1 && blk4x4_rec_counter > 15)
			case (Intra_chroma_predmode)
				`Intra_chroma_DC:	//---DC---
				if (blk4x4_intra_calculate_counter == 4) 
					begin
						case ({mbAddrA_availability,mbAddrB_availability})
							2'b00,2'b01:
							begin
								PE1_in0 <= 0;	PE1_in1 <= 0;	PE1_in2 <= 0;	PE1_in3 <= 0;
							end
							2'b10:
							begin
								PE1_in0 <= Intra_mbAddrA_window0;	PE1_in1 <= Intra_mbAddrA_window1;
								PE1_in2 <= Intra_mbAddrA_window2;	PE1_in3 <= Intra_mbAddrA_window3;
							end
							2'b11:
							begin
								PE1_in0 <= (blk4x4_rec_counter == 17 || blk4x4_rec_counter == 21)?
											0:Intra_mbAddrA_window0;	
								PE1_in1 <= (blk4x4_rec_counter == 17 || blk4x4_rec_counter == 21)?
											0:Intra_mbAddrA_window1;
								PE1_in2 <= (blk4x4_rec_counter == 17 || blk4x4_rec_counter == 21)?
											0:Intra_mbAddrA_window2;	
								PE1_in3 <= (blk4x4_rec_counter == 17 || blk4x4_rec_counter == 21)?
											0:Intra_mbAddrA_window3;
							end
						endcase
						PE1_IsShift <= 1'b0; 	PE1_IsClip <= 1'b0;	
						PE1_IsStore <= (mbAddrA_availability)? 1'b1:1'b0;
						PE1_full_bypass <= 1'b0;
						PE1_round_value <= 0;	PE1_shift_len <= 0;
					end
				else
					begin
						PE1_in0 <= 0;	PE1_in1 <= 0;	PE1_in2 <= 0;	PE1_in3 <= 0;
						PE1_IsShift 	<= 0;	PE1_IsStore 	<= 0;	PE1_IsClip 	  <= 0;
						PE1_full_bypass <= 0;	PE1_round_value <= 0;	PE1_shift_len <= 0;
					end
				`Intra_chroma_Horizontal:	//---horizontal---
				begin
					PE1_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window1:0;
					PE1_in1 		<= 0; 	PE1_in2 		<= 0;	PE1_in3 	  <= 0; 		
					PE1_IsShift 	<= 0;	PE1_IsStore 	<= 0;	PE1_IsClip    <= 0;
					PE1_full_bypass <= 1;	PE1_round_value <= 0;	PE1_shift_len <= 0;
				end
				`Intra_chroma_Vertical:	//---vertical---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE1_in0 <= Intra_mbAddrB_window0;
						3:PE1_in0 <= Intra_mbAddrB_window1;
						2:PE1_in0 <= Intra_mbAddrB_window2;
						1:PE1_in0 <= Intra_mbAddrB_window3;
						default:PE1_in0 <= 0;
					endcase
					PE1_in1 		<= 0; 	PE1_in2 		<= 0;	PE1_in3       <= 0; 		
					PE1_IsShift 	<= 0;	PE1_IsStore 	<= 0;	PE1_IsClip 	  <= 0;
					PE1_full_bypass <= 1;	PE1_round_value <= 0;	PE1_shift_len <= 0;
				end
				`Intra_chroma_Plane:	//---plane---
				begin
					if (blk4x4_intra_calculate_counter != 0)
						//need seed,	   blk4x4 = 16 | 18 | 20 | 22
						//do not need seed,blk4x4 = 17 | 19 | 21 | 23
						PE1_in0 <= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? 
									seed:PE1_out_reg;
					else
						PE1_in0 <= 0; 
					if (blk4x4_intra_calculate_counter != 0)
						PE1_in1 <= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? 
									0:b_ext;
					else
						PE1_in1 <= 0;
					//0,2,8,10,the 4th cycle,+2c
					PE1_in2	<= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? c_ext:0;
					PE1_in3	<= 0;
					PE1_IsShift <= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? 
									1'b1:1'b0;
					PE1_IsStore		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE1_IsClip 		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE1_full_bypass	<= 1'b0;
					PE1_round_value <= (blk4x4_intra_calculate_counter != 0)? 5'd16:5'd0;
					PE1_shift_len	<= (blk4x4_intra_calculate_counter != 0)? 3'd5 :3'd0;
				end
			endcase
		else
			begin
				PE1_in0 <= 0;	PE1_in1 <= 0;	PE1_in2 <= 0;	PE1_in3 <= 0;
				PE1_IsShift 	<= 0;	PE1_IsStore 	<= 0;	PE1_IsClip 	  <= 0;
				PE1_full_bypass <= 0;	PE1_round_value <= 0;	PE1_shift_len <= 0;	
			end																		   
			
	//----
	//PE2 |
	//----
	always @ (mb_type_general or blk4x4_rec_counter or blk4x4_intra_calculate_counter
		or Intra4x4_predmode or Intra16x16_predmode or Intra_chroma_predmode
		or mbAddrA_availability or mbAddrB_availability
		
		or Intra_mbAddrA_window0 or Intra_mbAddrA_window1 or Intra_mbAddrA_window2 or Intra_mbAddrA_window3
		or Intra_mbAddrB_window0 or Intra_mbAddrB_window1 or Intra_mbAddrB_window2 or Intra_mbAddrB_window3
		or Intra_mbAddrD_window
		or Intra_mbAddrC_window0 or Intra_mbAddrC_window1
		
		or Intra_mbAddrA_reg8 or Intra_mbAddrA_reg9 or Intra_mbAddrA_reg10 or Intra_mbAddrA_reg11
		or Intra_mbAddrB_reg9 or Intra_mbAddrB_reg10 or Intra_mbAddrB_reg11
		or blk4x4_pred_output0  or blk4x4_pred_output1 or blk4x4_pred_output2	 
		or blk4x4_pred_output4  or blk4x4_pred_output5 or blk4x4_pred_output12
		or blk4x4_pred_output13 or blk4x4_pred_output14
		or PE2_out_reg 
		
		or seed or b_ext or c_ext)
		//Intra 4x4
		if (mb_type_general[3:2] == 2'b11 && blk4x4_rec_counter < 16)
			case (Intra4x4_predmode)
				`Intra4x4_Vertical:		//---Vertical---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE2_in0 <= Intra_mbAddrB_window0;
						3:PE2_in0 <= Intra_mbAddrB_window1;
						2:PE2_in0 <= Intra_mbAddrB_window2;
						1:PE2_in0 <= Intra_mbAddrB_window3;
						default:PE2_in0 <= 0;
					endcase
					PE2_in1 	    <= 0; 	PE2_in2    	    <= 0;	PE2_in3 	  <= 0;	
					PE2_IsShift     <= 0;	PE2_IsStore     <= 0;	PE2_IsClip    <= 0;	
					PE2_full_bypass <= 1;	PE2_round_value <= 0;	PE2_shift_len <= 0;
				end
				`Intra4x4_Horizontal:	//---Horizontal---
				begin
					PE2_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window2:0;
					PE2_in1 	    <= 0; 	PE2_in2 		<= 0;	PE2_in3       <= 0; 	
					PE2_IsShift     <= 0;	PE2_IsStore     <= 0;	PE2_IsClip    <= 0;
					PE2_full_bypass <= 1;	PE2_round_value <= 0;	PE2_shift_len <= 0;
				end
				//-------------
				//no PE2 for DC
				//4'b0010:
				//-------------
				`Intra4x4_Diagonal_Down_Left:	//---diagonal down-left---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE2_in0 <= Intra_mbAddrB_window2;
						3:PE2_in0 <= blk4x4_pred_output12;
						2:PE2_in0 <= blk4x4_pred_output13;
						1:PE2_in0 <= blk4x4_pred_output14;
						default:PE2_in0 <= 0;
					endcase
					PE2_in1 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrC_window0:0;
					PE2_in2 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrB_window3:0;
					PE2_in3 <= 0;
					PE2_IsShift <= (blk4x4_intra_calculate_counter == 4)? 1'b1:1'b0;
					PE2_IsStore <= 1'b0; PE2_IsClip <= 1'b0;
					PE2_full_bypass <= (blk4x4_intra_calculate_counter == 4)? 1'b0:1'b1;
					PE2_round_value <= (blk4x4_intra_calculate_counter == 4)? 5'd2:5'd0; // +2
					PE2_shift_len	<= (blk4x4_intra_calculate_counter == 4)? 3'd2:3'd0; // >>2
				end		
				`Intra4x4_Diagonal_Down_Right:	//---diagonal down-right---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE2_in0 <= Intra_mbAddrA_window0;
						3:PE2_in0 <= blk4x4_pred_output4;
						2:PE2_in0 <= blk4x4_pred_output0;
						1:PE2_in0 <= blk4x4_pred_output1;
						default:PE2_in0 <= 0;
					endcase
					PE2_in1 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrA_window2:0;
					PE2_in2 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrA_window1:0;
					PE2_in3 <= 0;
					PE2_IsShift <= (blk4x4_intra_calculate_counter == 0)? 1'b0:1'b1;
					PE2_IsStore <= 1'b0; PE2_IsClip <= 1'b0;	
					PE2_full_bypass <= (blk4x4_intra_calculate_counter == 4)? 1'b0:1'b1;
					PE2_round_value <= (blk4x4_intra_calculate_counter == 0)? 5'd0:5'd2; // +2
					PE2_shift_len	<= (blk4x4_intra_calculate_counter == 0)? 3'd0:3'd2; // >>2
				end
				`Intra4x4_Vertical_Right:	//---vertical right---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE2_in0 <= Intra_mbAddrD_window;
						3:PE2_in0 <= blk4x4_pred_output0;
						2:PE2_in0 <= blk4x4_pred_output1;
						1:PE2_in0 <= blk4x4_pred_output2;
						default:PE2_in0 <= 0;
					endcase
					PE2_in1 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrA_window1:0;
					PE2_in2 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrA_window0:0;
					PE2_in3 <= 0;
					PE2_IsShift <= (blk4x4_intra_calculate_counter == 0)? 1'b0:1'b1;
					PE2_IsStore <= 1'b0; PE2_IsClip <= 1'b0;	
					PE2_full_bypass <= (blk4x4_intra_calculate_counter == 4)? 1'b0:1'b1;
					PE2_round_value <= (blk4x4_intra_calculate_counter == 0)? 5'd0:5'd2; // +2
					PE2_shift_len	<= (blk4x4_intra_calculate_counter == 0)? 3'd0:3'd2; // >>2
				end
				`Intra4x4_Horizontal_Down:	//---horizontal down---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE2_in0 <= Intra_mbAddrA_window1;
						3:PE2_in0 <= Intra_mbAddrA_window0;
						2:PE2_in0 <= blk4x4_pred_output4;
						1:PE2_in0 <= blk4x4_pred_output5;
						default:PE2_in0 <= 0;
					endcase
					PE2_in1 <= (blk4x4_intra_calculate_counter == 4 || blk4x4_intra_calculate_counter == 3)?
								Intra_mbAddrA_window2:0;
					PE2_in2 <= (blk4x4_intra_calculate_counter == 3)? Intra_mbAddrA_window1:0;
					PE2_in3 <= 0;
					PE2_IsShift <= (blk4x4_intra_calculate_counter == 3)? 1'b1:1'b0;
					PE2_IsStore <= 1'b0; PE2_IsClip <= 1'b0;	
					PE2_full_bypass <= (blk4x4_intra_calculate_counter == 2 || 
										blk4x4_intra_calculate_counter == 1)? 1'b1:1'b0;
					PE2_round_value <= (blk4x4_intra_calculate_counter == 4)? 5'd1:
									   (blk4x4_intra_calculate_counter == 3)? 5'd2:5'd0; 
				 	PE2_shift_len	<= (blk4x4_intra_calculate_counter == 4)? 3'd1:
									   (blk4x4_intra_calculate_counter == 3)? 3'd2:3'd0; 
				end
				`Intra4x4_Vertical_Left:		//---vertical left---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE2_in0 <= Intra_mbAddrB_window1;
						3:PE2_in0 <= Intra_mbAddrB_window3;
						2:PE2_in0 <= Intra_mbAddrB_window3;
						1:PE2_in0 <= Intra_mbAddrC_window1;
						default:PE2_in0 <= 0;
					endcase
					case (blk4x4_intra_calculate_counter)
						4,3:PE2_in1 <= Intra_mbAddrB_window2;
						2,1:PE2_in1 <= Intra_mbAddrC_window0;
						default:PE2_in1 <= 0;
					endcase
					PE2_in2 <= 0;		PE2_in3 <= 0;
					PE2_IsShift <= 0; 	PE2_IsStore <= 0; PE2_IsClip <= 1'b0;	PE2_full_bypass <= 1'b0;
					PE2_round_value <= (blk4x4_intra_calculate_counter != 0)? 5'd1:5'd0; // +1
					PE2_shift_len	<= (blk4x4_intra_calculate_counter != 0)? 3'd1:3'd0; // >>1
				end
				`Intra4x4_Horizontal_Up:		//---horizontal up---
				begin
					case (blk4x4_intra_calculate_counter)
						4,3:PE2_in0 <= Intra_mbAddrA_window2;
						2,1:PE2_in0 <= blk4x4_pred_output12;
						default:PE2_in0 <= 0;
					endcase
					PE2_in1 <= (blk4x4_intra_calculate_counter == 4 || blk4x4_intra_calculate_counter == 3)?
								Intra_mbAddrA_window3:0;
					PE2_in2 <= (blk4x4_intra_calculate_counter == 3)? Intra_mbAddrA_window3:0;
					PE2_in3 <= 0;
					PE2_IsShift <= (blk4x4_intra_calculate_counter == 3)? 1'b1:1'b0;
					PE2_IsStore <= 1'b0; PE2_IsClip <= 1'b0;	
					PE2_full_bypass <= (blk4x4_intra_calculate_counter == 2 || 
										blk4x4_intra_calculate_counter == 1)? 1'b1:1'b0;
					PE2_round_value <= (blk4x4_intra_calculate_counter == 4)? 5'd1:
									   (blk4x4_intra_calculate_counter == 3)? 5'd2:5'd0; 
				 	PE2_shift_len	<= (blk4x4_intra_calculate_counter == 4)? 3'd1:
									   (blk4x4_intra_calculate_counter == 3)? 3'd2:3'd0; 
				end
				default:
				begin
					PE2_in0 <= 0;	PE2_in1 <= 0;	PE2_in2 <= 0;	PE2_in3 <= 0;
					PE2_IsShift 	<= 0;	PE2_IsStore 	<= 0;	PE2_IsClip 	  <= 0;
					PE2_full_bypass <= 0;	PE2_round_value <= 0;	PE2_shift_len <= 0;	
				end
			endcase
		//Intra16x16
		else if (mb_type_general[3:2] == 2'b10 && blk4x4_rec_counter < 16)
			case (Intra16x16_predmode)
				`Intra16x16_Vertical:	//---Vertical---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE2_in0 <= Intra_mbAddrB_window0;
						3:PE2_in0 <= Intra_mbAddrB_window1;
						2:PE2_in0 <= Intra_mbAddrB_window2;
						1:PE2_in0 <= Intra_mbAddrB_window3;
						default:PE2_in0 <= 0;
					endcase
					PE2_in1 		<= 0; 	PE2_in2 		<= 0;	PE2_in3       <= 0; 		
					PE2_IsShift 	<= 0;	PE2_IsStore 	<= 0;	PE2_IsClip 	  <= 0;
					PE2_full_bypass <= 1;	PE2_round_value <= 0;	PE2_shift_len <= 0;
				end
				`Intra16x16_Horizontal:	//---Horizontal---
				begin
					PE2_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window2:0;
					PE2_in1 		<= 0; 	PE2_in2 		<= 0;	PE2_in3 	  <= 0; 		
					PE2_IsShift 	<= 0;	PE2_IsStore 	<= 0;	PE2_IsClip    <= 0;
					PE2_full_bypass <= 1;	PE2_round_value <= 0;	PE2_shift_len <= 0;
				end
				`Intra16x16_DC:	//---DC---
				if (blk4x4_rec_counter == 0)
					case (blk4x4_intra_calculate_counter)
						4:begin		//	I2 + J2 + K2 + L2
							PE2_in0 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg8;
							PE2_in1 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg9;
							PE2_in2 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg10;
							PE2_in3 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg11;
							PE2_IsShift 	<= 0;	PE2_IsStore 	<= 1;	PE2_IsClip    <= 0;
							PE2_full_bypass <= 0;	PE2_round_value <= 0;	PE2_shift_len <= 0;	end
						3:begin		//	PE2 output + J1 + K1 + L1
							PE2_in0 <= PE2_out_reg;
							PE2_in1 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg9;
							PE2_in2 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg10;
							PE2_in3 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg11;
							PE2_IsShift 	<= 0;	PE2_IsStore 	<= 1;	PE2_IsClip 	  <= 0;
							PE2_full_bypass <= 0;	PE2_round_value <= 0;	PE2_shift_len <= 0;	end
						default:begin
							PE2_in0 <= 0;	PE2_in1 <= 0;	PE2_in2 <= 0;	PE2_in3 <= 0;
							PE2_IsShift 	<= 0;	PE2_IsStore 	<= 0;	PE2_IsClip 	  <= 0;
							PE2_full_bypass <= 0;	PE2_round_value <= 0;	PE2_shift_len <= 0;	end
					endcase
				else
					begin
						PE2_in0 <= 0;	PE2_in1 <= 0;	PE2_in2 <= 0;	PE2_in3 <= 0;
						PE2_IsShift 	<= 0;	PE2_IsStore 	<= 0;	PE2_IsClip 	  <= 0;
						PE2_full_bypass <= 0;	PE2_round_value <= 0;	PE2_shift_len <= 0;
					end
				`Intra16x16_Plane:	//---plane---
				begin 
					if (blk4x4_intra_calculate_counter != 0)
						//blk0,2,4,6,8,10,12,14,calc counter == 3'b100:PE2_in0 <= seed;
						//other cases								  :PE2_in0 <= left pixel output
						PE2_in0 <= (blk4x4_intra_calculate_counter == 4 && blk4x4_rec_counter[0] == 1'b0)? 
									seed:PE2_out_reg;
					else
						PE2_in0 <= 0;
					if (blk4x4_intra_calculate_counter != 0)
						//blk0,2,8,10,calc counter == 3'b100:PE2_in1 <= c_ext x 2
						//other cases                       :PE2_in1 <= b_ext
						PE2_in1 <= (blk4x4_intra_calculate_counter == 4 && !blk4x4_rec_counter[2] && !blk4x4_rec_counter[0])? 
									{c_ext[14:0],1'b0}:b_ext;
					else
						PE2_in1 <= 0;
					//blk0,2, 8,10,calc counter == 3'b100:PE2_in2 <= c_ext;
					//blk4,6,12,14,calc counter == 3'b100:PE2_in2 <= c_ext x 2;
					//other cases						 :PE2_in2 <= 0
					if (blk4x4_intra_calculate_counter == 3'b100 && !blk4x4_rec_counter[0])
						PE2_in2 <= (blk4x4_rec_counter[2])? {c_ext[14:0],1'b0}:c_ext;
					else
						PE2_in2 <= 0;
					PE2_in3	<= 0;
					PE2_IsShift 	<= 1'b0;
					PE2_IsStore		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE2_IsClip 		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE2_full_bypass	<= 1'b0;
					PE2_round_value <= (blk4x4_intra_calculate_counter != 0)? 5'd16:5'd0;
					PE2_shift_len	<= (blk4x4_intra_calculate_counter != 0)? 3'd5 :3'd0;
				end
			endcase
		//Chroma
		else if (mb_type_general[3] == 1'b1 && blk4x4_rec_counter > 15)
			case (Intra_chroma_predmode)
				//--------------------
				//no PE2 for Chroma DC
				//2'b00:
				//--------------------
				`Intra_chroma_Horizontal:	//---horizontal---
				begin
					PE2_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window2:0;
					PE2_in1 		<= 0; 	PE2_in2 		<= 0;	PE2_in3 	  <= 0; 		
					PE2_IsShift 	<= 0;	PE2_IsStore 	<= 0;	PE2_IsClip    <= 0;
					PE2_full_bypass <= 1;	PE2_round_value <= 0;	PE2_shift_len <= 0;
				end
				`Intra_chroma_Vertical:		//---vertical---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE2_in0 <= Intra_mbAddrB_window0;
						3:PE2_in0 <= Intra_mbAddrB_window1;
						2:PE2_in0 <= Intra_mbAddrB_window2;
						1:PE2_in0 <= Intra_mbAddrB_window3;
						default:PE2_in0 <= 0;
					endcase
					PE2_in1 		<= 0; 	PE2_in2 		<= 0;	PE2_in3       <= 0; 		
					PE2_IsShift 	<= 0;	PE2_IsStore 	<= 0;	PE2_IsClip 	  <= 0;
					PE2_full_bypass <= 1;	PE2_round_value <= 0;	PE2_shift_len <= 0;
				end
				`Intra_chroma_Plane:	//---plane---
				begin
					if (blk4x4_intra_calculate_counter != 0)
						//need seed,	   blk4x4 = 16 | 18 | 20 | 22
						//do not need seed,blk4x4 = 17 | 19 | 21 | 23
						PE2_in0 <= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? 
									seed:PE2_out_reg;
					else
						PE2_in0 <= 0; 
					if (blk4x4_intra_calculate_counter != 0)
						PE2_in1 <= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? 
									c_ext:b_ext;
					else
						PE2_in1 <= 0;
					PE2_in2 	<= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? 
									c_ext:0;
					PE2_in3		<= 0;
					PE2_IsShift <= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? 
									1'b1:1'b0;
					PE2_IsStore		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE2_IsClip 		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE2_full_bypass	<= 1'b0;
					PE2_round_value <= (blk4x4_intra_calculate_counter != 0)? 5'd16:5'd0;
					PE2_shift_len	<= (blk4x4_intra_calculate_counter != 0)? 3'd5 :3'd0;
				end
				default:
				begin
					PE2_in0 <= 0;	PE2_in1 <= 0;	PE2_in2 <= 0;	PE2_in3 <= 0;
					PE2_IsShift 	<= 0;	PE2_IsStore 	<= 0;	PE2_IsClip 	  <= 0;
					PE2_full_bypass <= 0;	PE2_round_value <= 0;	PE2_shift_len <= 0;	
				end
			endcase
		else
			begin
				PE2_in0 <= 0;	PE2_in1 <= 0;	PE2_in2 <= 0;	PE2_in3 <= 0;
				PE2_IsShift 	<= 0;	PE2_IsStore 	<= 0;	PE2_IsClip 	  <= 0;
				PE2_full_bypass <= 0;	PE2_round_value <= 0;	PE2_shift_len <= 0;	
			end
			
	//----
	//PE3 |
	//----
	always @ (mb_type_general or blk4x4_rec_counter or blk4x4_intra_calculate_counter
		or Intra4x4_predmode or Intra16x16_predmode or Intra_chroma_predmode
		or mbAddrA_availability or mbAddrB_availability
		or Intra_mbAddrA_window0 or Intra_mbAddrA_window1 or Intra_mbAddrA_window2 or Intra_mbAddrA_window3
		or Intra_mbAddrB_window0 or Intra_mbAddrB_window1 or Intra_mbAddrB_window2 or Intra_mbAddrB_window3
		or Intra_mbAddrC_window0 or Intra_mbAddrC_window1 or Intra_mbAddrC_window2 or Intra_mbAddrC_window3
		
		or Intra_mbAddrA_reg12 or Intra_mbAddrA_reg13 or Intra_mbAddrA_reg14 or Intra_mbAddrA_reg15
		or Intra_mbAddrB_reg13 or Intra_mbAddrB_reg14 or Intra_mbAddrB_reg15
		or blk4x4_pred_output0 or blk4x4_pred_output4  or blk4x4_pred_output5
		or blk4x4_pred_output6 or blk4x4_pred_output8 or blk4x4_pred_output9
		or PE3_out_reg
		
		or seed or b_ext or c_ext)
		//Intra 4x4
		if (mb_type_general[3:2] == 2'b11 && blk4x4_rec_counter < 16)
			case (Intra4x4_predmode)
				`Intra4x4_Vertical:		//---Vertical---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE3_in0 <= Intra_mbAddrB_window0;
						3:PE3_in0 <= Intra_mbAddrB_window1;
						2:PE3_in0 <= Intra_mbAddrB_window2;
						1:PE3_in0 <= Intra_mbAddrB_window3;
						default:PE3_in0 <= 0;
					endcase
					PE3_in1 	    <= 0; 	PE3_in2    	    <= 0;	PE3_in3 	  <= 0;	
					PE3_IsShift     <= 0;	PE3_IsStore     <= 0;	PE3_IsClip    <= 0;	
					PE3_full_bypass <= 1;	PE3_round_value <= 0;	PE3_shift_len <= 0;
				end
				`Intra4x4_Horizontal:	//---Horizontal---
				begin
					PE3_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window3:0;
					PE3_in1 	    <= 0; 	PE3_in2 		<= 0;	PE3_in3       <= 0; 	
					PE3_IsShift     <= 0;	PE3_IsStore     <= 0;	PE3_IsClip    <= 0;
					PE3_full_bypass <= 1;	PE3_round_value <= 0;	PE3_shift_len <= 0;
				end
				//-------------
				//no PE2 for DC
				//4'b0010:
				//-------------
				`Intra4x4_Diagonal_Down_Left:	//---diagonal down-left---
				begin
					case (blk4x4_intra_calculate_counter)
						4:begin	PE3_in0 <= Intra_mbAddrB_window3;	PE3_in1 <= Intra_mbAddrC_window1;
								PE3_in2 <= Intra_mbAddrC_window0;				end
						3:begin	PE3_in0 <= Intra_mbAddrC_window0;	PE3_in1 <= Intra_mbAddrC_window2;
								PE3_in2 <= Intra_mbAddrC_window1;				end
						2:begin	PE3_in0 <= Intra_mbAddrC_window1;	PE3_in1 <= Intra_mbAddrC_window3;
								PE3_in2 <= Intra_mbAddrC_window2;				end
						1:begin	PE3_in0 <= Intra_mbAddrC_window2;	PE3_in1 <= Intra_mbAddrC_window3;
								PE3_in2 <= Intra_mbAddrC_window3;				end		
						default:begin	PE3_in0 <= 0;PE3_in1 <= 0;PE3_in2 <= 0;	end
					endcase
					PE3_in3 <= 0;
					PE3_IsShift <= (blk4x4_intra_calculate_counter == 0)? 1'b0:1'b1;
					PE3_IsStore <= 1'b0; PE3_IsClip <= 1'b0;	PE3_full_bypass <= 1'b0;
					PE3_round_value <= (blk4x4_intra_calculate_counter == 0)? 5'd0:5'd2; // +2
					PE3_shift_len	<= (blk4x4_intra_calculate_counter == 0)? 3'd0:3'd2;   // >>2
				end	
				`Intra4x4_Diagonal_Down_Right:	//---diagonal down-right---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE3_in0 <= Intra_mbAddrA_window1;
						3:PE3_in0 <= blk4x4_pred_output8;
						2:PE3_in0 <= blk4x4_pred_output4;
						1:PE3_in0 <= blk4x4_pred_output0;
						default:PE3_in0 <= 0;
					endcase
					PE3_in1 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrA_window3:0;
					PE3_in2 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrA_window2:0;
					PE3_in3 <= 0;
					PE3_IsShift <= (blk4x4_intra_calculate_counter == 0)? 1'b0:1'b1;
					PE3_IsStore <= 1'b0; PE3_IsClip <= 1'b0;	
					PE3_full_bypass <= (blk4x4_intra_calculate_counter == 4)? 1'b0:1'b1;
					PE3_round_value <= (blk4x4_intra_calculate_counter == 0)? 5'd0:5'd2; // +2
					PE3_shift_len	<= (blk4x4_intra_calculate_counter == 0)? 3'd0:3'd2; // >>2
				end
				`Intra4x4_Vertical_Right:		//---vertical right---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE3_in0 <= Intra_mbAddrA_window0;
						3:PE3_in0 <= blk4x4_pred_output4;
						2:PE3_in0 <= blk4x4_pred_output5;
						1:PE3_in0 <= blk4x4_pred_output6;
						default:PE3_in0 <= 0;
					endcase
					PE3_in1 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrA_window2:0;
					PE3_in2 <= (blk4x4_intra_calculate_counter == 4)? Intra_mbAddrA_window1:0;
					PE3_in3 <= 0;
					PE3_IsShift <= (blk4x4_intra_calculate_counter == 0)? 1'b0:1'b1;
					PE3_IsStore <= 1'b0; PE3_IsClip <= 1'b0;	
					PE3_full_bypass <= (blk4x4_intra_calculate_counter == 4)? 1'b0:1'b1;
					PE3_round_value <= (blk4x4_intra_calculate_counter == 0)? 5'd0:5'd2; // +2
					PE3_shift_len	<= (blk4x4_intra_calculate_counter == 0)? 3'd0:3'd2; // >>2
				end
				`Intra4x4_Horizontal_Down:	//---horizontal down---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE3_in0 <= Intra_mbAddrA_window2;
						3:PE3_in0 <= Intra_mbAddrA_window1;
						2:PE3_in0 <= blk4x4_pred_output8;
						1:PE3_in0 <= blk4x4_pred_output9;
						default:PE3_in0 <= 0;
					endcase
					PE3_in1 <= (blk4x4_intra_calculate_counter == 4 || blk4x4_intra_calculate_counter == 3)?
								Intra_mbAddrA_window3:0;
					PE3_in2 <= (blk4x4_intra_calculate_counter == 3)? Intra_mbAddrA_window2:0;
					PE3_in3 <= 0;
					PE3_IsShift <= (blk4x4_intra_calculate_counter == 3)? 1'b1:1'b0;
					PE3_IsStore <= 1'b0; PE3_IsClip <= 1'b0;	
					PE3_full_bypass <= (blk4x4_intra_calculate_counter == 2 || 
										blk4x4_intra_calculate_counter == 1)? 1'b1:1'b0;
					PE3_round_value <= (blk4x4_intra_calculate_counter == 4)? 5'd1:
									   (blk4x4_intra_calculate_counter == 3)? 5'd2:5'd0; 
				 	PE3_shift_len	<= (blk4x4_intra_calculate_counter == 4)? 3'd1:
									   (blk4x4_intra_calculate_counter == 3)? 3'd2:3'd0; 
				end
				`Intra4x4_Vertical_Left:	//---vertical left---
				begin
					case (blk4x4_intra_calculate_counter)
						4:begin	PE3_in0 <= Intra_mbAddrB_window1;	PE3_in1 <= Intra_mbAddrB_window3;
								PE3_in2 <= Intra_mbAddrB_window2;				end
						3:begin	PE3_in0 <= Intra_mbAddrB_window2;	PE3_in1 <= Intra_mbAddrC_window0;
								PE3_in2 <= Intra_mbAddrB_window3;				end
						2:begin	PE3_in0 <= Intra_mbAddrB_window3;	PE3_in1 <= Intra_mbAddrC_window1;
								PE3_in2 <= Intra_mbAddrC_window0;				end
						1:begin	PE3_in0 <= Intra_mbAddrC_window0;	PE3_in1 <= Intra_mbAddrC_window2;
								PE3_in2 <= Intra_mbAddrC_window1;				end		
						default:begin	PE3_in0 <= 0;PE3_in1 <= 0;PE3_in2 <= 0;	end
					endcase
					PE3_in3 <= 0;
					PE3_IsShift <= (blk4x4_intra_calculate_counter == 0)? 1'b0:1'b1;
					PE3_IsStore <= 1'b0; PE3_IsClip <= 1'b0;	PE3_full_bypass <= 1'b0;
					PE3_round_value <= (blk4x4_intra_calculate_counter == 0)? 5'd0:5'd2; // +2
					PE3_shift_len	<= (blk4x4_intra_calculate_counter == 0)? 3'd0:3'd2; // >>2
				end
				`Intra4x4_Horizontal_Up:	//---horizontal up---
				begin
					PE3_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window3:0;
					PE3_in1 <= 0;	PE3_in2 <= 0;	PE3_in3 <= 0;
					PE3_IsShift 	<= 0;	PE3_IsStore 	<= 0;	PE3_IsClip 	  <= 0;
					PE3_full_bypass <= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE3_round_value <= 0;	PE3_shift_len <= 0; 
				end
				default:
				begin
					PE3_in0 <= 0;	PE3_in1 <= 0;	PE3_in2 <= 0;	PE3_in3 <= 0;
					PE3_IsShift 	<= 0;	PE3_IsStore 	<= 0;	PE3_IsClip 	  <= 0;
					PE3_full_bypass <= 0;	PE3_round_value <= 0;	PE3_shift_len <= 0;	
				end
			endcase
		//Intra16x16
		else if (mb_type_general[3:2] == 2'b10 && blk4x4_rec_counter < 16)
			case (Intra16x16_predmode)
				`Intra16x16_Vertical:	//---Vertical---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE3_in0 <= Intra_mbAddrB_window0;
						3:PE3_in0 <= Intra_mbAddrB_window1;
						2:PE3_in0 <= Intra_mbAddrB_window2;
						1:PE3_in0 <= Intra_mbAddrB_window3;
						default:PE3_in0 <= 0;
					endcase
					PE3_in1 		<= 0; 	PE3_in2 		<= 0;	PE3_in3       <= 0; 		
					PE3_IsShift 	<= 0;	PE3_IsStore 	<= 0;	PE3_IsClip 	  <= 0;
					PE3_full_bypass <= 1;	PE3_round_value <= 0;	PE3_shift_len <= 0;
				end
				`Intra16x16_Horizontal:	//---Horizontal---
				begin
					PE3_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window3:0;
					PE3_in1 		<= 0; 	PE3_in2 		<= 0;	PE3_in3 	  <= 0; 		
					PE3_IsShift 	<= 0;	PE3_IsStore 	<= 0;	PE3_IsClip    <= 0;
					PE3_full_bypass <= 1;	PE3_round_value <= 0;	PE3_shift_len <= 0;
				end
				`Intra16x16_DC:			//---DC---
				if (blk4x4_rec_counter == 0)
					case (blk4x4_intra_calculate_counter)
						4:begin		//	M2 + N2 + O2 + P2
							PE3_in0 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg12;
							PE3_in1 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg13;
							PE3_in2 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg14;
							PE3_in3 <= (mbAddrA_availability == 0)? 0:Intra_mbAddrA_reg15;
							PE3_IsShift 	<= 0;	PE3_IsStore 	<= 1;	PE3_IsClip    <= 0;
							PE3_full_bypass <= 0;	PE3_round_value <= 0;	PE3_shift_len <= 0;	end
						3:begin		//	PE3 output + N1 + O1 + P1
							PE3_in0 <= PE3_out_reg;
							PE3_in1 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg13;
							PE3_in2 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg14;
							PE3_in3 <= (mbAddrB_availability == 0)? 0:Intra_mbAddrB_reg15;
							PE3_IsShift 	<= 0;	PE3_IsStore 	<= 1;	PE3_IsClip 	  <= 0;
							PE3_full_bypass <= 0;	PE3_round_value <= 0;	PE3_shift_len <= 0;	end
						default:begin
							PE3_in0 <= 0;	PE3_in1 <= 0;	PE3_in2 <= 0;	PE3_in3 <= 0;
							PE3_IsShift 	<= 0;	PE3_IsStore 	<= 0;	PE3_IsClip 	  <= 0;
							PE3_full_bypass <= 0;	PE3_round_value <= 0;	PE3_shift_len <= 0;	end
					endcase
				else
					begin
						PE3_in0 <= 0;	PE3_in1 <= 0;	PE3_in2 <= 0;	PE3_in3 <= 0;
						PE3_IsShift 	<= 0;	PE3_IsStore 	<= 0;	PE3_IsClip 	  <= 0;
						PE3_full_bypass <= 0;	PE3_round_value <= 0;	PE3_shift_len <= 0;
					end
				`Intra16x16_Plane:	//---plane---
				begin 
					if (blk4x4_intra_calculate_counter != 0)
						//blk0,2,4,6,8,10,12,14,calc counter == 3'b100:PE3_in0 <= seed;
						//other cases								  :PE3_in0 <= left pixel output
						PE3_in0 <= (blk4x4_intra_calculate_counter == 4 && blk4x4_rec_counter[0] == 1'b0)? 
									seed:PE3_out_reg;
					else
						PE3_in0 <= 0;
					if (blk4x4_intra_calculate_counter != 0)
						//blk0,2,8,10,calc counter == 3'b100:PE3_in1 <= c_ext x 4
						//other cases                       :PE3_in1 <= b_ext
						PE3_in1 <= (blk4x4_intra_calculate_counter == 4 && !blk4x4_rec_counter[2] && !blk4x4_rec_counter[0])? 
									{c_ext[13:0],2'b0}:b_ext;
					else
						PE3_in1 <= 0;
					//blk4,6,12,14,calc counter == 3'b100:PE3_in2 <= c_ext x 2;
					//other cases						 :PE3_in2 <= 0
					PE3_in2 <= (blk4x4_intra_calculate_counter == 3'b100 && blk4x4_rec_counter[2] && !blk4x4_rec_counter[0])?
								{c_ext[14:0],1'b0}:0;
					//blk4,6,12,14,calc counter == 3'b100:PE3_in3 <= c_ext;
					//other cases						 :PE3_in3 <= 0
					PE3_in3 <= (blk4x4_intra_calculate_counter == 3'b100 && blk4x4_rec_counter[2] && !blk4x4_rec_counter[0])?
								c_ext:0;
					PE3_IsShift 	<= 1'b0;
					PE3_IsStore		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE3_IsClip 		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE3_full_bypass	<= 1'b0;
					PE3_round_value <= (blk4x4_intra_calculate_counter != 0)? 5'd16:5'd0;
					PE3_shift_len	<= (blk4x4_intra_calculate_counter != 0)? 3'd5 :3'd0;
				end
			endcase
		//Chroma
		else if (mb_type_general[3] == 1'b1 && blk4x4_rec_counter > 15)
			case (Intra_chroma_predmode)
				//--------------------
				//no PE2 for Chroma DC
				//2'b00:
				//--------------------
				`Intra_chroma_Horizontal:	//---horizontal---
				begin
					PE3_in0 <= (blk4x4_intra_calculate_counter != 0)? Intra_mbAddrA_window3:0;
					PE3_in1 		<= 0; 	PE3_in2 		<= 0;	PE3_in3 	  <= 0; 		
					PE3_IsShift 	<= 0;	PE3_IsStore 	<= 0;	PE3_IsClip    <= 0;
					PE3_full_bypass <= 1;	PE3_round_value <= 0;	PE3_shift_len <= 0;
				end
				`Intra_chroma_Vertical:	//---vertical---
				begin
					case (blk4x4_intra_calculate_counter)
						4:PE3_in0 <= Intra_mbAddrB_window0;
						3:PE3_in0 <= Intra_mbAddrB_window1;
						2:PE3_in0 <= Intra_mbAddrB_window2;
						1:PE3_in0 <= Intra_mbAddrB_window3;
						default:PE3_in0 <= 0;
					endcase
					PE3_in1 		<= 0; 	PE3_in2 		<= 0;	PE3_in3       <= 0; 		
					PE3_IsShift 	<= 0;	PE3_IsStore 	<= 0;	PE3_IsClip 	  <= 0;
					PE3_full_bypass <= 1;	PE3_round_value <= 0;	PE3_shift_len <= 0;
				end
				`Intra_chroma_Plane:	//---plane---
				begin
					if (blk4x4_intra_calculate_counter != 0)
						//need seed,	   blk4x4 = 16 | 18 | 20 | 22
						//do not need seed,blk4x4 = 17 | 19 | 21 | 23
						PE3_in0 <= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? 
									seed:PE3_out_reg;
					else
						PE3_in0 <= 0; 
					if (blk4x4_intra_calculate_counter != 0)
						PE3_in1 <= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? 
									{c_ext[14:0],1'b0}:b_ext;
					else
						PE3_in1 <= 0;
					PE3_in2 	<= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? 
									c_ext:0;
					PE3_in3		<= 0;
					PE3_IsShift <= (blk4x4_rec_counter[0] == 1'b0 && blk4x4_intra_calculate_counter == 4)? 
									1'b1:1'b0;
					PE3_IsStore		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE3_IsClip 		<= (blk4x4_intra_calculate_counter != 0)? 1'b1:1'b0;
					PE3_full_bypass	<= 1'b0;
					PE3_round_value <= (blk4x4_intra_calculate_counter != 0)? 5'd16:5'd0;
					PE3_shift_len	<= (blk4x4_intra_calculate_counter != 0)? 3'd5 :3'd0;
				end
				default:
				begin
					PE3_in0 <= 0;	PE3_in1 <= 0;	PE3_in2 <= 0;	PE3_in3 <= 0;
					PE3_IsShift 	<= 0;	PE3_IsStore 	<= 0;	PE3_IsClip 	  <= 0;
					PE3_full_bypass <= 0;	PE3_round_value <= 0;	PE3_shift_len <= 0;	
				end
			endcase
		else
			begin
				PE3_in0 <= 0;	PE3_in1 <= 0;	PE3_in2 <= 0;	PE3_in3 <= 0;
				PE3_IsShift 	<= 0;	PE3_IsStore 	<= 0;	PE3_IsClip 	  <= 0;
				PE3_full_bypass <= 0;	PE3_round_value <= 0;	PE3_shift_len <= 0;	
			end
endmodule

module PE (clk,reset_n,in0,in1,in2,in3,IsShift,IsStore,IsClip,full_bypass,round_value,shift_len,
	PE_out_reg,PE_out,sum_out);
	input clk,reset_n;
	input [15:0] in0,in1,in2,in3;
	input IsShift;
	input IsStore;
	input IsClip;
	input full_bypass;
	input [4:0] round_value;
	input [2:0] shift_len;
	
	
	output [15:0] PE_out_reg;
	output [7:0] PE_out;
	output [15:0] sum_out;
	reg [15:0] PE_out_reg;
	
	wire [15:0] sum1;
	wire [15:0] sum2;
	wire [16:0] round_tmp;
	wire [15:0] round_out;
	wire [7:0] clip_out;
	
	assign sum1 = (full_bypass)? 0:(in0 + in1);
	assign sum2 = (full_bypass)? 0:((IsShift)? {in2[14:0],1'b0}:(in2 + in3));
	assign sum_out = (full_bypass)? 0:(sum1 + sum2);
	
	always @ (posedge clk)
		if (reset_n == 1'b0)
			PE_out_reg <= 0;
		else if (IsStore)
			PE_out_reg <= sum_out;	
			
	assign round_tmp = sum_out + round_value;
	assign round_out = round_tmp >> shift_len;
	assign clip_out = (IsClip)? ((round_out[15] == 1'b1)? 8'd0:((round_out[15:8] == 0)? round_out[7:0]:8'd255))
					  :round_out[7:0];
	assign PE_out = (full_bypass)? in0[7:0]:clip_out;
endmodule