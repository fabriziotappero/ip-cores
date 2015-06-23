//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : NumCoeffTrailingOnes_decoding.v
// Generated : June 8, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Decoding for Table 9-5 on Page159 of H.264/AVC standard 2003
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module NumCoeffTrailingOnes_decoding (clk,reset_n,cavlc_decoder_state,heading_one_pos,BitStream_buffer_output,
	nC,TrailingOnes,TotalCoeff,NumCoeffTrailingOnes_len);
	input clk,reset_n;
	input [3:0] cavlc_decoder_state;
	input [3:0] heading_one_pos;
	input [15:0] BitStream_buffer_output;
	input [4:0] nC;
	output [1:0] TrailingOnes;
	output [4:0] TotalCoeff;
	output [4:0] NumCoeffTrailingOnes_len;
	reg [1:0] TrailingOnes;
	reg [4:0] TotalCoeff;
	reg [4:0] NumCoeffTrailingOnes_len;
		
	reg [1:0] TrailingOnes_reg;
	reg [4:0] TotalCoeff_reg;
	
	wire nC_0to2,nC_2to4,nC_4to8,nC_n1,nC_GE8;
	wire nC_0to2_t0,nC_0to2_t1,nC_0to2_t2,nC_0to2_t3;
	wire nC_2to4_t0,nC_2to4_t1,nC_2to4_t2,nC_2to4_t3;
	wire nC_4to8_t0,nC_4to8_t1;
	wire nC_n1_t0;
	//Select nC values to choose table
	assign nC_0to2 = (cavlc_decoder_state == `NumCoeffTrailingOnes_LUT && (nC == 5'd0 || nC == 5'd1));
	assign nC_2to4 = (cavlc_decoder_state == `NumCoeffTrailingOnes_LUT && (nC == 5'd2 || nC == 5'd3));
	assign nC_4to8 = (cavlc_decoder_state == `NumCoeffTrailingOnes_LUT && (nC == 5'd4 || nC == 5'd5 || nC == 5'd6 || nC == 5'd7));
	assign nC_n1   = (cavlc_decoder_state == `NumCoeffTrailingOnes_LUT && (nC == 5'd31));
	assign nC_GE8  = (cavlc_decoder_state == `NumCoeffTrailingOnes_LUT && !nC_0to2 && !nC_2to4 && !nC_4to8 && !nC_n1);
	
	//1.nC_0to2 t0 ~ t4	sub-table selection
	assign nC_0to2_t0 = (nC_0to2 && (heading_one_pos == 4'd0 || heading_one_pos == 4'd1 || heading_one_pos == 4'd2));
	assign nC_0to2_t1 = (nC_0to2 && (heading_one_pos == 4'd3 || heading_one_pos == 4'd4));
	assign nC_0to2_t2 = (nC_0to2 && (heading_one_pos == 4'd5 || heading_one_pos == 4'd6 || heading_one_pos == 4'd7 || heading_one_pos == 4'd8));
	assign nC_0to2_t3 = (nC_0to2 && (heading_one_pos == 4'd9 || heading_one_pos == 4'd10));
	//2.nC_2to4 t0 ~ t4	sub-table selection
	assign nC_2to4_t0 = (nC_2to4 && (heading_one_pos == 4'd0 || heading_one_pos == 4'd1));
	assign nC_2to4_t1 = (nC_2to4 && (heading_one_pos == 4'd2 || heading_one_pos == 4'd3));
	assign nC_2to4_t2 = (nC_2to4 && (heading_one_pos == 4'd4 || heading_one_pos == 4'd5 || heading_one_pos == 4'd6));
	assign nC_2to4_t3 = (nC_2to4 && (heading_one_pos == 4'd7 || heading_one_pos == 4'd8));
	//3.nC_4to8 t0 ~ t2	sub-table selection 
	assign nC_4to8_t0 = (nC_4to8 && heading_one_pos == 4'd0);
	assign nC_4to8_t1 = (nC_4to8 && (heading_one_pos == 4'd1 || heading_one_pos == 4'd2 || heading_one_pos == 4'd3 || heading_one_pos == 4'd4));
	//4.nC_GE8:single table, NO sub-table selection
	//5.nC_n1 t0 ~ t1 sub-table selection
	assign nC_n1_t0 = (nC_n1 && (heading_one_pos == 4'd0 || heading_one_pos == 4'd1 || heading_one_pos == 4'd2));
	
	//NumCoeffTrailingOnes_len
	always @ (nC_0to2 or nC_2to4 or nC_4to8 or nC_GE8 or nC_n1 or heading_one_pos or BitStream_buffer_output)
		if (nC_0to2)
			case (heading_one_pos)
				0 :NumCoeffTrailingOnes_len <= 5'd1;
				1 :NumCoeffTrailingOnes_len <= 5'd2;
				2 :NumCoeffTrailingOnes_len <= 5'd3;
				3 :NumCoeffTrailingOnes_len <= (BitStream_buffer_output[11] == 1)? 5'd5:5'd6;
				4 :NumCoeffTrailingOnes_len <= (BitStream_buffer_output[10] == 1)? 5'd6:5'd7;
				5 :NumCoeffTrailingOnes_len <= 5'd8;
				6 :NumCoeffTrailingOnes_len <= 5'd9;
				7 :NumCoeffTrailingOnes_len <= 5'd10;
				8 :NumCoeffTrailingOnes_len <= 5'd11;
				9 :NumCoeffTrailingOnes_len <= 5'd13;
				10:NumCoeffTrailingOnes_len <= 5'd14;
				11:NumCoeffTrailingOnes_len <= 5'd15;
				12:NumCoeffTrailingOnes_len <= 5'd16;
				13:NumCoeffTrailingOnes_len <= 5'd16;
				14:NumCoeffTrailingOnes_len <= 5'd15;
				default:NumCoeffTrailingOnes_len <= 5'd0;
			endcase
		else if (nC_2to4)
			case (heading_one_pos)
				0 :NumCoeffTrailingOnes_len <= 5'd2;
				1 :NumCoeffTrailingOnes_len <= (BitStream_buffer_output[13] == 1)? 5'd3:5'd4;
				2 :NumCoeffTrailingOnes_len <= (BitStream_buffer_output[12] == 1)? 5'd5:5'd6;
				3 :NumCoeffTrailingOnes_len <= 5'd6;
				4 :NumCoeffTrailingOnes_len <= 5'd7;
				5 :NumCoeffTrailingOnes_len <= 5'd8;
				6 :NumCoeffTrailingOnes_len <= 5'd9;
				7 :NumCoeffTrailingOnes_len <= 5'd11;
				8 :NumCoeffTrailingOnes_len <= 5'd12;
				9 :NumCoeffTrailingOnes_len <= 5'd13;
				10:NumCoeffTrailingOnes_len <= (BitStream_buffer_output[4] == 1)? 5'd13:5'd14;
				11:NumCoeffTrailingOnes_len <= 5'd14;
				12:NumCoeffTrailingOnes_len <= 5'd13;
				default:NumCoeffTrailingOnes_len <= 5'd0;
			endcase
		else if (nC_n1)
			case (heading_one_pos)
				0:NumCoeffTrailingOnes_len <= 5'd1;
				1:NumCoeffTrailingOnes_len <= 5'd2;
				2:NumCoeffTrailingOnes_len <= 5'd3;
				3:NumCoeffTrailingOnes_len <= 5'd6;
				4:NumCoeffTrailingOnes_len <= 5'd6;
				5:NumCoeffTrailingOnes_len <= 5'd7;
				6:NumCoeffTrailingOnes_len <= 5'd8;
				default:NumCoeffTrailingOnes_len <= 5'd7;
			endcase
		else if (nC_4to8)
			case (heading_one_pos)
				0 :NumCoeffTrailingOnes_len <= 5'd4;
				1 :NumCoeffTrailingOnes_len <= 5'd5;
				2 :NumCoeffTrailingOnes_len <= 5'd6;
				3 :NumCoeffTrailingOnes_len <= 5'd7;
				4 :NumCoeffTrailingOnes_len <= 5'd8;
				5 :NumCoeffTrailingOnes_len <= 5'd9;
				6 :NumCoeffTrailingOnes_len <= (BitStream_buffer_output[8:7] == 2'b11)? 5'd9:5'd10;
				7 :NumCoeffTrailingOnes_len <= 5'd10;
				8 :NumCoeffTrailingOnes_len <= 5'd10;
				9 :NumCoeffTrailingOnes_len <= 5'd10;
				10:NumCoeffTrailingOnes_len <= 5'd10;
				default:NumCoeffTrailingOnes_len <= 5'd0;
			endcase
		else if (nC_GE8)		
			NumCoeffTrailingOnes_len <= 5'd6;
		else
			NumCoeffTrailingOnes_len <= 0;
		
	
	//TrailingOnes
	always @ (posedge clk)
		if (reset_n == 0)
			TrailingOnes_reg <= 0;
		else if (cavlc_decoder_state == `NumCoeffTrailingOnes_LUT)
			TrailingOnes_reg <= TrailingOnes;
			
	always @ (nC_0to2 or nC_2to4 or nC_4to8 or nC_n1 or nC_GE8 
	or nC_0to2_t0 or nC_0to2_t1 or nC_0to2_t2 or nC_0to2_t3  
	or nC_2to4_t0 or nC_2to4_t1 or nC_2to4_t2 or nC_2to4_t3  
	or nC_4to8_t0 or nC_4to8_t1 or nC_n1_t0  
	or TrailingOnes_reg or heading_one_pos or BitStream_buffer_output)
		if (nC_0to2)
			begin
				if (nC_0to2_t0) 
					TrailingOnes <= heading_one_pos[1:0];
				else if (nC_0to2_t1)
					begin
						if (heading_one_pos == 4'd3 && !BitStream_buffer_output[11])
							TrailingOnes <= (BitStream_buffer_output[10])? 2'd0:2'd1;
						else if (heading_one_pos == 4'd4 && BitStream_buffer_output[10:9] == 2'b01)
							TrailingOnes <= 2'd2;
						else
							TrailingOnes <= 2'd3;
					end
				else if (nC_0to2_t2)
					begin
						if (heading_one_pos == 4'd5)
							case (BitStream_buffer_output[9:8])
								2'b00:TrailingOnes <= 2'd3;
								2'b01:TrailingOnes <= 2'd2;
								2'b10:TrailingOnes <= 2'd1;
								2'b11:TrailingOnes <= 2'd0;
							endcase
						else if (heading_one_pos == 4'd6)
							case (BitStream_buffer_output[8:7])
								2'b00:TrailingOnes <= 2'd3;
								2'b01:TrailingOnes <= 2'd2;
								2'b10:TrailingOnes <= 2'd1;
								2'b11:TrailingOnes <= 2'd0;
							endcase
						else if (heading_one_pos == 4'd7)
							case (BitStream_buffer_output[7:6])
								2'b00:TrailingOnes <= 2'd3;
								2'b01:TrailingOnes <= 2'd2;
								2'b10:TrailingOnes <= 2'd1;
								2'b11:TrailingOnes <= 2'd0;
							endcase
						else 
							case (BitStream_buffer_output[6:5])
								2'b00:TrailingOnes <= 2'd3;
								2'b01:TrailingOnes <= 2'd2;
								2'b10:TrailingOnes <= 2'd1;
								2'b11:TrailingOnes <= 2'd0;
							endcase
					end
				else if (nC_0to2_t3)
					begin 
						if (heading_one_pos == 4'd9)
							case (BitStream_buffer_output[4:3])
								2'b00:TrailingOnes <= (BitStream_buffer_output[5])? 2'd3:2'd0;
								2'b10:TrailingOnes <= 2'd1;
								2'b01:TrailingOnes <= 2'd2;
								2'b11:TrailingOnes <= 2'd0;
							endcase
						else
							case (BitStream_buffer_output[3:2])
								2'b00:TrailingOnes <= 2'd3;
								2'b01:TrailingOnes <= 2'd2;
								2'b10:TrailingOnes <= 2'd1;
								2'b11:TrailingOnes <= 2'd0;
							endcase
					end
				else
					begin
						if ((heading_one_pos == 4'd11 &&  BitStream_buffer_output[2:1] == 2'b11) ||
                (heading_one_pos == 4'd12 &&  BitStream_buffer_output[1:0] == 2'b11) ||
                (heading_one_pos == 4'd13 && (BitStream_buffer_output[1:0] == 2'b00  || BitStream_buffer_output[1:0] == 2'b11)))
							TrailingOnes <= 2'd0;
						else if ((heading_one_pos == 4'd11 && BitStream_buffer_output[2:1] == 2'b10) ||
                     (heading_one_pos == 4'd12 && BitStream_buffer_output[1:0] == 2'b10) ||
                     (heading_one_pos == 4'd13 && BitStream_buffer_output[1:0] == 2'b10) ||
                      heading_one_pos == 4'd14)
							TrailingOnes <= 2'd1;
						else if ((heading_one_pos == 4'd11 && BitStream_buffer_output[2:1] == 2'b01) ||
                     (heading_one_pos == 4'd12 && BitStream_buffer_output[1:0] == 2'b01) ||
                     (heading_one_pos == 4'd13 && BitStream_buffer_output[1:0] == 2'b01))
							TrailingOnes <= 2'd2;
						else
							TrailingOnes <= 2'd3;
					end
			end
		else if (nC_2to4)
			begin
				if (nC_2to4_t0)
					begin
						if (heading_one_pos == 4'd0)
							TrailingOnes <= {1'b0,~BitStream_buffer_output[14]};
						else
							TrailingOnes <= (BitStream_buffer_output[13])? 2'd2:2'd3;
					end
				else if (nC_2to4_t1)
					begin
						if ((heading_one_pos == 4'd2 && BitStream_buffer_output[12:10] == 3'b011) ||
                (heading_one_pos == 4'd3 && BitStream_buffer_output[11:10] == 2'b11))
							TrailingOnes <= 2'd0;
						else if ((heading_one_pos == 4'd2 && (BitStream_buffer_output[12:11] == 2'b11 || BitStream_buffer_output[12:10] == 3'b010)) ||
                     (heading_one_pos == 4'd3 &&  BitStream_buffer_output[11:10] == 2'b10))
							TrailingOnes <= 2'd1;
						else if ((heading_one_pos == 4'd2 && BitStream_buffer_output[12:10] == 3'b001) ||
                     (heading_one_pos == 4'd3 && BitStream_buffer_output[11:10] == 2'b01))
							TrailingOnes <= 2'd2;
						else
							TrailingOnes <= 2'd3;
					end
				else if (nC_2to4_t2)
					begin
						if (heading_one_pos == 4'd4)
							case (BitStream_buffer_output[10:9])
								2'b00:TrailingOnes <= 2'd3;
								2'b01:TrailingOnes <= 2'd2;
								2'b10:TrailingOnes <= 2'd1;
								2'b11:TrailingOnes <= 2'd0;
							endcase
						else if (heading_one_pos == 4'd5)
							case (BitStream_buffer_output[9:8])
								2'b00:TrailingOnes <= 2'd0;
								2'b01:TrailingOnes <= 2'd2;
								2'b10:TrailingOnes <= 2'd1;
								2'b11:TrailingOnes <= 2'd0;
							endcase
						else 
							case (BitStream_buffer_output[8:7])
								2'b00:TrailingOnes <= 2'd3;
								2'b01:TrailingOnes <= 2'd2;
								2'b10:TrailingOnes <= 2'd1;
								2'b11:TrailingOnes <= 2'd0;
							endcase
					end
				else if (nC_2to4_t3)
					begin 
						if ((heading_one_pos == 4'd7 && BitStream_buffer_output[6:5] == 2'b11) || 
                (heading_one_pos == 4'd8 && (BitStream_buffer_output[5:4] == 2'b11 || BitStream_buffer_output[6:4] == 3'b000)))
							TrailingOnes <= 2'd0;
						else if ((heading_one_pos == 4'd7 && BitStream_buffer_output[6:5] == 2'b10) || 
                     (heading_one_pos == 4'd8 && BitStream_buffer_output[5:4] == 2'b10)) 
							TrailingOnes <= 2'd1;
						else if ((heading_one_pos == 4'd7 && BitStream_buffer_output[6:5] == 2'b01) || 
                     (heading_one_pos == 4'd8 && BitStream_buffer_output[5:4] == 2'b01)) 
							TrailingOnes <= 2'd2;
						else
							TrailingOnes <= 2'd3;
					end
				else
					begin
						if ((heading_one_pos == 4'd9  &&  BitStream_buffer_output[4:3] == 2'b11) ||
                (heading_one_pos == 4'd10 && (BitStream_buffer_output[4:3] == 2'b11  || BitStream_buffer_output[4:2] == 3'b001)) ||
                (heading_one_pos == 4'd11 &&  BitStream_buffer_output[3:2] == 2'b11))
							TrailingOnes <= 2'd0;
						else if ((heading_one_pos == 4'd9  &&  BitStream_buffer_output[4:3] == 2'b10) ||
                     (heading_one_pos == 4'd10 && (BitStream_buffer_output[4:2] == 3'b000 || BitStream_buffer_output[4:2] == 3'b011)) ||
                     (heading_one_pos == 4'd11 &&  BitStream_buffer_output[3:2] == 2'b10))
							TrailingOnes <= 2'd1;
						else if ((heading_one_pos == 4'd9  &&  BitStream_buffer_output[4:3] == 2'b01) ||
                     (heading_one_pos == 4'd10 && (BitStream_buffer_output[4:3] == 2'b10  || BitStream_buffer_output[4:2] == 3'b010)) ||
                     (heading_one_pos == 4'd11 &&  BitStream_buffer_output[3:2] == 2'b01))
							TrailingOnes <= 2'd2;
						else
							TrailingOnes <= 2'd3;
					end
			end
		else if (nC_n1)
			begin 
				if (nC_n1_t0)
					begin 
						if      (BitStream_buffer_output[15])	TrailingOnes <= 2'd1;
						else if (BitStream_buffer_output[14])	TrailingOnes <= 2'd0;
						else                                  TrailingOnes <= 2'd2;
					end
				else
					begin
						if ((heading_one_pos == 4'd3 && (BitStream_buffer_output[11:10] == 2'b00 || BitStream_buffer_output[11:10] == 2'b11)) ||
                 heading_one_pos == 4'd4)
							TrailingOnes <= 2'd0;
						else if ((heading_one_pos == 4'd3 && BitStream_buffer_output[11:10] == 2'b10) ||
                     (heading_one_pos == 4'd5 && BitStream_buffer_output[9]) ||
                     (heading_one_pos == 4'd6 && BitStream_buffer_output[8]))
							TrailingOnes <= 2'd1;
						else if ((heading_one_pos == 4'd5 && !BitStream_buffer_output[9]) ||
                     (heading_one_pos == 4'd6 && !BitStream_buffer_output[8]))
							TrailingOnes <= 2'd2;
						else
							TrailingOnes <= 2'd3;
					end
			end
		else if (nC_4to8)
			begin
				if (nC_4to8_t0)
					begin
						if      (BitStream_buffer_output[14:12] == 3'b111)	TrailingOnes <= 2'd0;
						else if (BitStream_buffer_output[14:12] == 3'b110)	TrailingOnes <= 2'd1;
						else if (BitStream_buffer_output[14:12] == 3'b101)	TrailingOnes <= 2'd2;
						else                                                TrailingOnes <= 2'd3;
					end
				else if (nC_4to8_t1)
					begin
						if ((heading_one_pos == 4'd1 && 
							(BitStream_buffer_output[13:11] == 3'b000 || BitStream_buffer_output[13:11] == 3'b010 || 
							 BitStream_buffer_output[13:11] == 3'b100 || BitStream_buffer_output[13:11] == 3'b111)) ||
							(heading_one_pos == 4'd2 && BitStream_buffer_output[11:10] == 2'b10 ) ||
							(heading_one_pos == 4'd3 && BitStream_buffer_output[11:9]  == 3'b110) ||
							(heading_one_pos == 4'd4 && BitStream_buffer_output[9:8]   == 2'b10 ))
							TrailingOnes <= 2'd1;
						else if (
							(heading_one_pos == 4'd1 && (BitStream_buffer_output[13:11] == 3'b001 || BitStream_buffer_output[13:11] == 3'b011 || BitStream_buffer_output[13:11] == 3'b110))||
							(heading_one_pos == 4'd2 &&  BitStream_buffer_output[11:10] == 2'b01) ||
							(heading_one_pos == 4'd3 && (BitStream_buffer_output[11:9]  == 3'b010 || BitStream_buffer_output[11:9]  == 3'b101))||
							(heading_one_pos == 4'd4 &&  BitStream_buffer_output[9:8]   == 2'b01))
							TrailingOnes <= 2'd2;
						else if (
							(heading_one_pos == 4'd1 && BitStream_buffer_output[13:11] == 3'b101) ||
							(heading_one_pos == 4'd2 && BitStream_buffer_output[12:10] == 3'b100) ||
							(heading_one_pos == 4'd3 && BitStream_buffer_output[11:9]  == 3'b100) ||
							(heading_one_pos == 4'd4 && BitStream_buffer_output[9:8]   == 2'b00))
							TrailingOnes <= 2'd3;
						else
							TrailingOnes <= 2'd0;
					end
				else
					begin
						if ((heading_one_pos == 4'd5 && BitStream_buffer_output[8:7] == 2'b10) ||
                (heading_one_pos == 4'd6 && (BitStream_buffer_output[8:7] == 2'b11 || BitStream_buffer_output[7:6] == 2'b00)) ||
                (heading_one_pos == 4'd7 && BitStream_buffer_output[7:6] == 2'b00))
							TrailingOnes <= 2'd1;
						else if (
							(heading_one_pos == 4'd5 && BitStream_buffer_output[8:7] == 2'b01)  ||
							(heading_one_pos == 4'd6 && BitStream_buffer_output[8:6] == 3'b011) ||
							(heading_one_pos == 4'd7 && BitStream_buffer_output[7:6] == 2'b11)  ||
							(heading_one_pos == 4'd8 && BitStream_buffer_output[6]))
							TrailingOnes <= 2'd2;
						else if (
							(heading_one_pos == 4'd5 &&  BitStream_buffer_output[9:7] == 3'b100)  ||
							(heading_one_pos == 4'd6 &&  BitStream_buffer_output[8:6] == 3'b010) ||
							(heading_one_pos == 4'd7 &&  BitStream_buffer_output[7:6] == 2'b10)  ||
							(heading_one_pos == 4'd8 && !BitStream_buffer_output[6]))
							TrailingOnes <= 2'd3;
						else
							TrailingOnes <= 2'd0;
					end
			end
		else if (nC_GE8)
			begin
				if (BitStream_buffer_output[15:10] == 6'b0 || heading_one_pos == 4'd4)
					TrailingOnes <= 2'd0;
				else if (heading_one_pos == 4'd5)
					TrailingOnes <= 2'd1;
				else
					TrailingOnes <= BitStream_buffer_output[11:10];
			end
		else
			TrailingOnes <= TrailingOnes_reg; 
			
	//TotalCoeff
	always @ (posedge clk)
		if (reset_n == 0)
			TotalCoeff_reg <= 0;
		else if (cavlc_decoder_state == `NumCoeffTrailingOnes_LUT)
			TotalCoeff_reg <= TotalCoeff;
			
	always @ (nC_0to2 or nC_2to4 or nC_4to8 or nC_n1 or nC_GE8 
	or nC_0to2_t0 or nC_0to2_t1 or nC_0to2_t2 or nC_0to2_t3  
	or nC_2to4_t0 or nC_2to4_t1 or nC_2to4_t2 or nC_2to4_t3  
	or nC_4to8_t0 or nC_4to8_t1 or nC_n1_t0  
	or TotalCoeff_reg or heading_one_pos or BitStream_buffer_output)
		if (nC_0to2)
			begin
				if (nC_0to2_t0) 
					TotalCoeff <= {3'b0,heading_one_pos[1:0]};
				else if (nC_0to2_t1)
					begin
						if (heading_one_pos == 4'd3)
							case (BitStream_buffer_output[11:10])
								2'b00  :TotalCoeff <= 5'd2;
								2'b01  :TotalCoeff <= 5'd1;
								default:TotalCoeff <= 5'd3;
							endcase
						else
							case (BitStream_buffer_output[10:9])
								2'b00  :TotalCoeff <= 5'd5;
								2'b01  :TotalCoeff <= 5'd3;
								default:TotalCoeff <= 5'd4;
							endcase
					end
				else if (nC_0to2_t2)
					begin
						if (heading_one_pos == 4'd5)
							case (BitStream_buffer_output[9:8])
								2'b00:TotalCoeff <= 5'd6;
								2'b01:TotalCoeff <= 5'd4;
								2'b10:TotalCoeff <= 5'd3;
								2'b11:TotalCoeff <= 5'd2;
							endcase
						else if (heading_one_pos == 4'd6)
							case (BitStream_buffer_output[8:7])
								2'b00:TotalCoeff <= 5'd7;
								2'b01:TotalCoeff <= 5'd5;
								2'b10:TotalCoeff <= 5'd4;
								2'b11:TotalCoeff <= 5'd3;
							endcase
						else if (heading_one_pos == 4'd7)
							case (BitStream_buffer_output[7:6])
								2'b00:TotalCoeff <= 5'd8;
								2'b01:TotalCoeff <= 5'd6;
								2'b10:TotalCoeff <= 5'd5;
								2'b11:TotalCoeff <= 5'd4;
							endcase
						else 
							case (BitStream_buffer_output[6:5])
								2'b00:TotalCoeff <= 5'd9;
								2'b01:TotalCoeff <= 5'd7;
								2'b10:TotalCoeff <= 5'd6;
								2'b11:TotalCoeff <= 5'd5;
							endcase
					end
				else if (nC_0to2_t3)
					begin 
						if (heading_one_pos == 4'd9)
							case (BitStream_buffer_output[5:3])
								3'b001		   :TotalCoeff <= 5'd9;
								3'b011,3'b110:TotalCoeff <= 5'd7;
								3'b100		   :TotalCoeff <= 5'd10;
								3'b111		   :TotalCoeff <= 5'd6;
								default		   :TotalCoeff <= 5'd8;
							endcase
						else
							case (BitStream_buffer_output[4:2])
								3'b000		   :TotalCoeff <= 5'd12; 
								3'b001,3'b100:TotalCoeff <= 5'd11;
								3'b110,3'b111:TotalCoeff <= 5'd9;
								default      :TotalCoeff <= 5'd10;
							endcase
					end
				else
					begin 
						if (heading_one_pos == 4'd11)
							case (BitStream_buffer_output[3:1])
								3'b000       :TotalCoeff <= 5'd14;
								3'b001,3'b100:TotalCoeff <= 5'd13;
								3'b110,3'b111:TotalCoeff <= 5'd11;
								default      :TotalCoeff <= 5'd12;
							endcase
						else if (heading_one_pos == 4'd12)
							case (BitStream_buffer_output[2:0])
								3'b000              :TotalCoeff <= 5'd16;
								3'b011,3'b101,3'b110:TotalCoeff <= 5'd14;
								3'b111              :TotalCoeff <= 5'd13;
								default             :TotalCoeff <= 5'd15;
							endcase							
						else if (heading_one_pos == 4'd13) 
							TotalCoeff <= (BitStream_buffer_output[1:0] == 2'b11)? 5'd15:5'd16;
						else
							TotalCoeff <= 5'd13;
					end
			end
		else if (nC_2to4)
			begin
				if (nC_2to4_t0)
					begin
						if (heading_one_pos == 4'd0)
							TotalCoeff <= {4'b0,~BitStream_buffer_output[14]};
						else
							case (BitStream_buffer_output[13:12])
								2'b00  :TotalCoeff <= 5'd4;
								2'b01  :TotalCoeff <= 5'd3;
								default:TotalCoeff <= 5'd2;
							endcase
					end
				else if (nC_2to4_t1)
					begin
						if (heading_one_pos == 4'd2)
							case (BitStream_buffer_output[12:11])
								2'b00:TotalCoeff <= (BitStream_buffer_output[10])? 5'd3:5'd6;
								2'b01:TotalCoeff <= (BitStream_buffer_output[10])? 5'd1:5'd3;
								2'b10:TotalCoeff <= 5'd5;
								2'b11:TotalCoeff <= 5'd2;
							endcase
						else
							case (BitStream_buffer_output[11:10])
								2'b00  :TotalCoeff <= 5'd7;
								2'b11  :TotalCoeff <= 5'd2;
								default:TotalCoeff <= 5'd4;
							endcase
					end	
				else if (nC_2to4_t2)
					begin
						if (heading_one_pos == 4'd4)
							case (BitStream_buffer_output[10:9])
								2'b00  :TotalCoeff <= 5'd8;
								2'b11  :TotalCoeff <= 5'd3;
								default:TotalCoeff <= 5'd5;
							endcase
						else if (heading_one_pos == 4'd5)
							case (BitStream_buffer_output[9:8])
								2'b00  :TotalCoeff <= 5'd5;
								2'b11  :TotalCoeff <= 5'd4;
								default:TotalCoeff <= 5'd6;
							endcase
						else
							case (BitStream_buffer_output[8:7])
								2'b00  :TotalCoeff <= 5'd9;
								2'b11  :TotalCoeff <= 5'd6;
								default:TotalCoeff <= 5'd7;
							endcase
					end
				else if (nC_2to4_t3)
					begin 
						if (heading_one_pos == 4'd7)
							case (BitStream_buffer_output[7:5])
								3'b000       :TotalCoeff <= 5'd11;
								3'b001,3'b010:TotalCoeff <= 5'd9;
								3'b100       :TotalCoeff <= 5'd10;
								3'b111       :TotalCoeff <= 5'd7;
								default      :TotalCoeff <= 5'd8;
							endcase
						else
							case (BitStream_buffer_output[6:4])
								3'b000,3'b001,3'b010:TotalCoeff <= 5'd11; 
								3'b100              :TotalCoeff <= 5'd12;
								3'b111              :TotalCoeff <= 5'd9;
								default             :TotalCoeff <= 5'd10;
							endcase
					end
				else
					begin 
						if (heading_one_pos == 4'd9)
							case (BitStream_buffer_output[5:3])
								3'b000              :TotalCoeff <= 5'd14;
								3'b101,3'b110,3'b111:TotalCoeff <= 5'd12;
								default             :TotalCoeff <= 5'd13;
							endcase
						else if (heading_one_pos == 4'd10)
							TotalCoeff <= (BitStream_buffer_output[4:2] == 3'b0 || BitStream_buffer_output[4:2] == 3'b001 || BitStream_buffer_output[4:2] == 3'b010)? 5'd15:5'd14;
						else if (heading_one_pos == 4'd11)
							TotalCoeff <= 5'd16;
						else 
							TotalCoeff <= 5'd15;
					end
			end
		else if (nC_n1)
			begin 
				if (nC_n1_t0)
					begin 
						if      (BitStream_buffer_output[15])	TotalCoeff <= 5'd1;
						else if (BitStream_buffer_output[14])	TotalCoeff <= 5'd0;
						else                                  TotalCoeff <= 5'd2;
					end
				else 
					begin 
						if (heading_one_pos == 4'd3)
							case (BitStream_buffer_output[11:10])
								2'b01  :TotalCoeff <= 5'd3;
								2'b11  :TotalCoeff <= 5'd1;
								default:TotalCoeff <= 5'd2;
							endcase
						else if (heading_one_pos == 4'd4)
							TotalCoeff <= (BitStream_buffer_output[10])? 5'd3:5'd4;
						else if (heading_one_pos == 4'd5)
							TotalCoeff <= 5'd3;
						else
							TotalCoeff <= 5'd4;
					end
			end
		else if (nC_4to8)
			begin
				if (nC_4to8_t0)
					TotalCoeff <= {2'b0,~BitStream_buffer_output[14:12]};
				else if (nC_4to8_t1)
					begin
						if (heading_one_pos == 4'd1)
							case (BitStream_buffer_output[13:11])
								3'b000,3'b001:TotalCoeff <= 5'd5;
								3'b010,3'b011:TotalCoeff <= 5'd4;
								3'b101       :TotalCoeff <= 5'd8;
								3'b111       :TotalCoeff <= 5'd2;
								default      :TotalCoeff <= 5'd3;
							endcase
						else if (heading_one_pos == 4'd2)
							case (BitStream_buffer_output[12:10])
								3'b000       :TotalCoeff <= 5'd3;
								3'b001,3'b010:TotalCoeff <= 5'd7;
								3'b011       :TotalCoeff <= 5'd2;
								3'b100       :TotalCoeff <= 5'd9;
								3'b111       :TotalCoeff <= 5'd1;
								default      :TotalCoeff <= 5'd6;
							endcase
						else if (heading_one_pos == 4'd3)
							case (BitStream_buffer_output[11:9])
								3'b000 :TotalCoeff <= 5'd7;
								3'b001 :TotalCoeff <= 5'd6;
								3'b010 :TotalCoeff <= 5'd9;
								3'b011 :TotalCoeff <= 5'd5;
								3'b100 :TotalCoeff <= 5'd10;
								3'b111 :TotalCoeff <= 5'd4;
								default:TotalCoeff <= 5'd8;
							endcase
						else 
							case (BitStream_buffer_output[10:8])
								3'b000       :TotalCoeff <= 5'd12;
								3'b001,3'b100:TotalCoeff <= 5'd11;
								3'b010,3'b101:TotalCoeff <= 5'd10;
								3'b111       :TotalCoeff <= 5'd8;
								default      :TotalCoeff <= 5'd9;
							endcase
					end
				else
					begin
						if (heading_one_pos == 4'd5)
							case (BitStream_buffer_output[9:7])
								3'b001,3'b100	:TotalCoeff <= 5'd13;
								3'b011,3'b110	:TotalCoeff <= 5'd11;
								3'b111        :TotalCoeff <= 5'd10;
								default       :TotalCoeff <= 5'd12;
							endcase
						else if (heading_one_pos == 4'd6)
							case (BitStream_buffer_output[8:6])
								3'b000              :TotalCoeff <= 5'd15;
								3'b101,3'b110,3'b111:TotalCoeff <= 5'd13;
								default             :TotalCoeff <= 5'd14;
							endcase
						else if (heading_one_pos == 4'd7)
							TotalCoeff <= (BitStream_buffer_output[7:6] == 2'b00)? 5'd16:5'd15;
						else 
							TotalCoeff <= 5'd16; 
					end
			end
		else if (nC_GE8)
			begin
				if (heading_one_pos == 4'd4)
					TotalCoeff <= 5'd0;
				else
					TotalCoeff <= BitStream_buffer_output[15:12] + 1;
			end
		else
			TotalCoeff <= TotalCoeff_reg;			
endmodule	