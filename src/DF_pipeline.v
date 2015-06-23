//-----------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : DF_pipeline.v
// Generated : Dec 2, 2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// 5-stage pipeline control for deblocking filter
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module DF_pipeline (clk,gclk_DF,gclk_end_of_MB_DEC,reset_n,disable_DF,end_of_BS_DEC,
	end_of_MB_DF,end_of_lastMB_DF,
	bs_V0,bs_V1,bs_V2,bs_V3,bs_H0,bs_H1,bs_H2,bs_H3,
	QPy,QPc,slice_alpha_c0_offset_div2,slice_beta_offset_div2,
	DF_mbAddrA_RF_dout,DF_mbAddrB_RAM_dout,rec_DF_RAM_dout,
	buf0_0,buf0_1,buf0_2,buf0_3,buf1_0,buf1_1,buf1_2,buf1_3,
	buf2_0,buf2_1,buf2_2,buf2_3,buf3_0,buf3_1,buf3_2,buf3_3,
	
	DF_duration,
	DF_edge_counter_MR,DF_edge_counter_MW,
	one_edge_counter_MR,one_edge_counter_MW,
	bs_curr_MR,bs_curr_MW,
	p0_MW,p1_MW,p2_MW,p3_MW,q0_MW,q1_MW,q2_MW,q3_MW);
	input clk;
	input gclk_DF;
	input gclk_end_of_MB_DEC;
	input reset_n;
	input disable_DF;
	input end_of_BS_DEC;
	input end_of_MB_DF;
	input end_of_lastMB_DF;
	input [11:0] bs_V0,bs_V1,bs_V2,bs_V3;
	input [11:0] bs_H0,bs_H1,bs_H2,bs_H3;
	input [5:0] QPy,QPc;
	input [3:0]	slice_alpha_c0_offset_div2,slice_beta_offset_div2;
	input [31:0] DF_mbAddrA_RF_dout,DF_mbAddrB_RAM_dout,rec_DF_RAM_dout;
	input [31:0] buf0_0,buf0_1,buf0_2,buf0_3,buf1_0,buf1_1,buf1_2,buf1_3;
	input [31:0] buf2_0,buf2_1,buf2_2,buf2_3,buf3_0,buf3_1,buf3_2,buf3_3;
	
	output DF_duration;
	output [5:0] DF_edge_counter_MR,DF_edge_counter_MW;
	output [1:0] one_edge_counter_MR,one_edge_counter_MW;
	output [2:0] bs_curr_MR;
	output [2:0] bs_curr_MW;
	output [7:0] p0_MW,p1_MW,p2_MW,p3_MW;
	output [7:0] q0_MW,q1_MW,q2_MW,q3_MW;
	
	reg DF_duration;
	always @ (posedge clk or negedge reset_n)
		if (reset_n == 1'b0)
			DF_duration <= 1'b0;
		else if (end_of_BS_DEC)
			DF_duration <= 1'b1;
		else if (end_of_MB_DF || end_of_lastMB_DF)
			DF_duration <= 1'b0;
	
	//---------------------------------------------------------------------
	//1.MR: Memory Read
	//---------------------------------------------------------------------
	//DF_edge_counter_MR & one_edge_counter_MR
	reg [5:0] DF_edge_counter_MR;
	reg [1:0] one_edge_counter_MR;
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			DF_edge_counter_MR <= 6'd48;
		else if (end_of_BS_DEC == 1'b1)
			DF_edge_counter_MR <= 0;
		else if (one_edge_counter_MR == 2'd3 && DF_edge_counter_MR != 6'd48)
			DF_edge_counter_MR <= DF_edge_counter_MR + 1;
		
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 0)
			one_edge_counter_MR <= 2'd3;
		else if (end_of_BS_DEC == 1'b1)
			one_edge_counter_MR <= 2'd0;
		else  
			begin
				if (one_edge_counter_MR == 2'd3 && DF_edge_counter_MR != 6'd47 && DF_edge_counter_MR[5:4] != 2'b11) //!47,!48
					one_edge_counter_MR <= 2'd0;
				else if (one_edge_counter_MR != 2'd3)
					one_edge_counter_MR <= one_edge_counter_MR + 1;
			end
	
	//lumaEdgeFlag_MR,chromaEdgeFlag_MR
	wire lumaEdgeFlag_MR,chromaEdgeFlag_MR;
	assign lumaEdgeFlag_MR   = !DF_edge_counter_MR[5];
	assign chromaEdgeFlag_MR =  DF_edge_counter_MR[5] && (DF_edge_counter_MR != 6'd48);
	
	//bs_curr_MR
	reg [2:0] bs_curr_MR;
	always @ (disable_DF or lumaEdgeFlag_MR or chromaEdgeFlag_MR or 
		DF_edge_counter_MR[4:0] or one_edge_counter_MR[1] or
		bs_V0 or bs_V1 or bs_V2 or bs_V3 or bs_H0 or bs_H1 or bs_H2 or bs_H3)
		if (!disable_DF && lumaEdgeFlag_MR)
			case (DF_edge_counter_MR[4:0])
				5'd0 :bs_curr_MR <= bs_V0[2:0];
				5'd1 :bs_curr_MR <= bs_V1[2:0];
				5'd2 :bs_curr_MR <= bs_V0[5:3];
				5'd3 :bs_curr_MR <= bs_V1[5:3];
				5'd4 :bs_curr_MR <= bs_H0[2:0];
				5'd5 :bs_curr_MR <= bs_H1[2:0];
				5'd6 :bs_curr_MR <= bs_V2[2:0];
				5'd7 :bs_curr_MR <= bs_V2[5:3];
				5'd8 :bs_curr_MR <= bs_H0[5:3];
				5'd9 :bs_curr_MR <= bs_H1[5:3];
				5'd10:bs_curr_MR <= bs_V3[2:0];
				5'd11:bs_curr_MR <= bs_V3[5:3];
				5'd12:bs_curr_MR <= bs_H0[8:6];
				5'd13:bs_curr_MR <= bs_H0[11:9];
				5'd14:bs_curr_MR <= bs_H1[8:6];
				5'd15:bs_curr_MR <= bs_H1[11:9];
				5'd16:bs_curr_MR <= bs_V0[8:6];
				5'd17:bs_curr_MR <= bs_V1[8:6];
				5'd18:bs_curr_MR <= bs_V0[11:9];
				5'd19:bs_curr_MR <= bs_V1[11:9];
				5'd20:bs_curr_MR <= bs_H2[2:0];
				5'd21:bs_curr_MR <= bs_H3[2:0];
				5'd22:bs_curr_MR <= bs_V2[8:6];
				5'd23:bs_curr_MR <= bs_V2[11:9];
				5'd24:bs_curr_MR <= bs_H2[5:3];
				5'd25:bs_curr_MR <= bs_H3[5:3];
				5'd26:bs_curr_MR <= bs_V3[8:6];
				5'd27:bs_curr_MR <= bs_V3[11:9];
				5'd28:bs_curr_MR <= bs_H2[8:6];
				5'd29:bs_curr_MR <= bs_H2[11:9];
				5'd30:bs_curr_MR <= bs_H3[8:6];
				5'd31:bs_curr_MR <= bs_H3[11:9];
			endcase
		else if (!disable_DF && chromaEdgeFlag_MR)
			case (DF_edge_counter_MR[3:0])
				4'd0,4'd8:	//32,40
				case (one_edge_counter_MR[1])
					1'b0:bs_curr_MR <= bs_V0[2:0];
					1'b1:bs_curr_MR <= bs_V0[5:3];
				endcase
				4'd2,4'd10:	//34,42
				case (one_edge_counter_MR[1])
					1'b0:bs_curr_MR <= bs_V0[8:6];
					1'b1:bs_curr_MR <= bs_V0[11:9];
				endcase
				4'd1,4'd9:	//33,41
				case (one_edge_counter_MR[1])
					1'b0:bs_curr_MR <= bs_V2[2:0];
					1'b1:bs_curr_MR <= bs_V2[5:3];
				endcase
				4'd3,4'd11:	//35,43
				case (one_edge_counter_MR[1])
					1'b0:bs_curr_MR <= bs_V2[8:6];
					1'b1:bs_curr_MR <= bs_V2[11:9];
				endcase
				4'd4,4'd12:	//36,44
				case (one_edge_counter_MR[1])
					1'b0:bs_curr_MR <= bs_H0[2:0];
					1'b1:bs_curr_MR <= bs_H0[5:3];
				endcase
				4'd5,4'd13:	//37,45
				case (one_edge_counter_MR[1])
					1'b0:bs_curr_MR <= bs_H0[8:6];
					1'b1:bs_curr_MR <= bs_H0[11:9];
				endcase
				4'd6,4'd14:	//38,46
				case (one_edge_counter_MR[1])
					1'b0:bs_curr_MR <= bs_H2[2:0];
					1'b1:bs_curr_MR <= bs_H2[5:3];
				endcase
				4'd7,4'd15:	//39,47
				case (one_edge_counter_MR[1])
					1'b0:bs_curr_MR <= bs_H2[8:6];
					1'b1:bs_curr_MR <= bs_H2[11:9];
				endcase
			endcase
		else
			bs_curr_MR <= 0;
				
	//	Pipelined parameters
	reg [2:0] bs_curr_TD;
	reg lumaEdgeFlag_TD,chromaEdgeFlag_TD;
	reg [5:0] DF_edge_counter_TD;
	reg [1:0] one_edge_counter_TD;
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				bs_curr_TD 			<= 0;
				lumaEdgeFlag_TD 	<= 0; 	
				chromaEdgeFlag_TD	<= 0;
				DF_edge_counter_TD	<= 6'd48;
				one_edge_counter_TD <= 2'd3;
			end	
		else
			begin
				bs_curr_TD 			<= bs_curr_MR;
				lumaEdgeFlag_TD 	<= lumaEdgeFlag_MR; 
				chromaEdgeFlag_TD 	<= chromaEdgeFlag_MR;
				DF_edge_counter_TD 	<= DF_edge_counter_MR;
				one_edge_counter_TD	<= one_edge_counter_MR;
			end
	//---------------------------------------------------------------------
	//2.TD: Threshold Decider
	//---------------------------------------------------------------------
	wire [6:0] indexA_y_unclipped,indexA_c_unclipped;
	wire [6:0] indexB_y_unclipped,indexB_c_unclipped;
	assign indexA_y_unclipped = QPy + {{2{slice_alpha_c0_offset_div2[3]}},slice_alpha_c0_offset_div2,1'b0};
	assign indexA_c_unclipped = QPc + {{2{slice_alpha_c0_offset_div2[3]}},slice_alpha_c0_offset_div2,1'b0};
	assign indexB_y_unclipped = QPy + {{2{slice_beta_offset_div2[3]}},slice_beta_offset_div2,1'b0};
	assign indexB_c_unclipped = QPc + {{2{slice_beta_offset_div2[3]}},slice_beta_offset_div2,1'b0};
	
	wire [5:0] indexA_y,indexA_c;
	wire [5:0] indexB_y,indexB_c;
	assign indexA_y = (indexA_y_unclipped[6] == 1)? 0:((indexA_y_unclipped[5:0] > 6'd51)? 6'd51:indexA_y_unclipped[5:0]);
	assign indexA_c = (indexA_c_unclipped[6] == 1)? 0:((indexA_c_unclipped[5:0] > 6'd51)? 6'd51:indexA_c_unclipped[5:0]);
	assign indexB_y = (indexB_y_unclipped[6] == 1)? 0:((indexB_y_unclipped[5:0] > 6'd51)? 6'd51:indexB_y_unclipped[5:0]);
	assign indexB_c = (indexB_c_unclipped[6] == 1)? 0:((indexB_c_unclipped[5:0] > 6'd51)? 6'd51:indexB_c_unclipped[5:0]);
	
	reg [5:0] indexA_y_reg,indexA_c_reg;
	reg [5:0] indexB_y_reg,indexB_c_reg;
	always @ (posedge gclk_end_of_MB_DEC or negedge reset_n)
		if (reset_n == 1'b0)
			begin	indexA_y_reg <= 0;	indexA_c_reg <= 0;	indexB_y_reg <= 0;	indexB_c_reg <= 0; end
		else if (!disable_DF)
			begin
				indexA_y_reg <= indexA_y;	indexA_c_reg <= indexA_c;
				indexB_y_reg <= indexB_y;	indexB_c_reg <= indexB_c;
			end
			
	wire [5:0] indexA,indexB;
	assign indexA = (lumaEdgeFlag_TD)? indexA_y_reg:((chromaEdgeFlag_TD)? indexA_c_reg:0);
	assign indexB = (lumaEdgeFlag_TD)? indexB_y_reg:((chromaEdgeFlag_TD)? indexB_c_reg:0);
	
	reg [7:0] alpha,beta;
	//alpha
	always @ (indexA)
		if (indexA < 16)
			alpha <= 0;
		else 
			case (indexA)
				6'd16,6'd17:alpha <= 8'd4;
				6'd18:alpha <= 8'd5;	6'd19:alpha <= 8'd6;	6'd20:alpha <= 8'd7;	6'd21:alpha <= 8'd8;
				6'd22:alpha <= 8'd9;	6'd23:alpha <= 8'd10;	6'd24:alpha <= 8'd12;	6'd25:alpha <= 8'd13;
				6'd26:alpha <= 8'd15;	6'd27:alpha <= 8'd17;	6'd28:alpha <= 8'd20;	6'd29:alpha <= 8'd22;
				6'd30:alpha <= 8'd25;	6'd31:alpha <= 8'd28;	6'd32:alpha <= 8'd32;	6'd33:alpha <= 8'd36;
				6'd34:alpha <= 8'd40;	6'd35:alpha <= 8'd45;	6'd36:alpha <= 8'd50;	6'd37:alpha <= 8'd56;
				6'd38:alpha <= 8'd63;	6'd39:alpha <= 8'd71;	6'd40:alpha <= 8'd80;	6'd41:alpha <= 8'd90;
				6'd42:alpha <= 8'd101;	6'd43:alpha <= 8'd113;	6'd44:alpha <= 8'd127;	6'd45:alpha <= 8'd144;
				6'd46:alpha <= 8'd162;	6'd47:alpha <= 8'd182;	6'd48:alpha <= 8'd203;	6'd49:alpha <= 8'd226;
				default:alpha <= 8'd255;
			endcase
	//beta
	always @ (indexB)
		if (indexB < 16)
			beta <= 0;
		else if (indexB > 15 && indexB < 26) 
			case (indexB)
				6'd16,6'd17,6'd18		:beta <= 8'd2;
				6'd19,6'd20,6'd21,6'd22	:beta <= 8'd3;
				6'd23,6'd24,6'd25		:beta <= 8'd4;
				default:beta <= 0;
			endcase
		else 
			beta <= indexB[5:1] - 3'd7; 
	
	wire [7:0] absolute_TD0_a,absolute_TD0_b;
	wire [7:0] absolute_TD1_a,absolute_TD1_b;
	wire [7:0] absolute_TD2_a,absolute_TD2_b;
	wire [7:0] absolute_TD0_out,absolute_TD1_out,absolute_TD2_out;
	absolute absolute_TD0 (.a(absolute_TD0_a),.b(absolute_TD0_b),.out(absolute_TD0_out));
	absolute absolute_TD1 (.a(absolute_TD1_a),.b(absolute_TD1_b),.out(absolute_TD1_out));
	absolute absolute_TD2 (.a(absolute_TD2_a),.b(absolute_TD2_b),.out(absolute_TD2_out));
	
	//p0 ~ p3
	wire Is_p_from_mbAddrA;
	wire Is_p_from_mbAddrB;
	wire Is_p_from_buf0;
	wire Is_p_from_buf1;
	wire Is_p_from_buf2;
	wire Is_p_from_buf3;
	assign Is_p_from_mbAddrA =    (DF_edge_counter_TD == 6'd0  || DF_edge_counter_TD == 6'd2  ||
	DF_edge_counter_TD == 6'd16 || DF_edge_counter_TD == 6'd18 || DF_edge_counter_TD == 6'd32 ||
	DF_edge_counter_TD == 6'd34 || DF_edge_counter_TD == 6'd40 || DF_edge_counter_TD == 6'd42);
	
	assign Is_p_from_mbAddrB =    (DF_edge_counter_TD == 6'd4  || DF_edge_counter_TD == 6'd8  ||
	DF_edge_counter_TD == 6'd12 || DF_edge_counter_TD == 6'd13 || DF_edge_counter_TD == 6'd20 ||
	DF_edge_counter_TD == 6'd24 || DF_edge_counter_TD == 6'd28 || DF_edge_counter_TD == 6'd29 ||
	DF_edge_counter_TD == 6'd36 || DF_edge_counter_TD == 6'd37 || DF_edge_counter_TD == 6'd44 ||
	DF_edge_counter_TD == 6'd45);
	
	assign Is_p_from_buf0 =       (DF_edge_counter_TD == 6'd1  || DF_edge_counter_TD == 6'd5  ||
	DF_edge_counter_TD == 6'd10 || DF_edge_counter_TD == 6'd14 || DF_edge_counter_TD == 6'd17 ||
	DF_edge_counter_TD == 6'd21 || DF_edge_counter_TD == 6'd26 || DF_edge_counter_TD == 6'd30 ||
	DF_edge_counter_TD == 6'd33 || DF_edge_counter_TD == 6'd38 || DF_edge_counter_TD == 6'd41 ||
	DF_edge_counter_TD == 6'd46);
	
	assign Is_p_from_buf1 =       (DF_edge_counter_TD == 6'd6  || DF_edge_counter_TD == 6'd9  ||
	DF_edge_counter_TD == 6'd15 || DF_edge_counter_TD == 6'd22 || DF_edge_counter_TD == 6'd25 ||
	DF_edge_counter_TD == 6'd31 || DF_edge_counter_TD == 6'd39 || DF_edge_counter_TD == 6'd47);
	
	assign Is_p_from_buf2 =       (DF_edge_counter_TD == 6'd3  || DF_edge_counter_TD == 6'd11 ||
	DF_edge_counter_TD == 6'd19 || DF_edge_counter_TD == 6'd27 || DF_edge_counter_TD == 6'd35 ||
	DF_edge_counter_TD == 6'd43);	
	
	assign Is_p_from_buf3 =       (DF_edge_counter_TD == 6'd7  || DF_edge_counter_TD == 6'd23);
	
	reg [7:0] p0,p1,p2,p3;
	always @ (Is_p_from_mbAddrA or Is_p_from_mbAddrB or Is_p_from_buf0 or Is_p_from_buf1 or 
		Is_p_from_buf2 or Is_p_from_buf3 or one_edge_counter_TD or
		DF_mbAddrA_RF_dout or DF_mbAddrB_RAM_dout or 
		buf0_0 or buf0_1 or buf0_2 or buf0_3 or buf1_0 or buf1_1 or buf1_2 or buf1_3 or 
		buf2_0 or buf2_1 or buf2_2 or buf2_3 or buf3_0 or buf3_1 or buf3_2 or buf3_3)
		case ({Is_p_from_mbAddrA,Is_p_from_mbAddrB,Is_p_from_buf0,Is_p_from_buf1,Is_p_from_buf2,Is_p_from_buf3})
			6'b100000:{p0,p1,p2,p3} <= DF_mbAddrA_RF_dout;
			6'b010000:{p0,p1,p2,p3} <= DF_mbAddrB_RAM_dout;
			6'b001000:	case (one_edge_counter_TD)
							2'b00:{p0,p1,p2,p3} <= buf0_0;
							2'b01:{p0,p1,p2,p3} <= buf0_1;
							2'b10:{p0,p1,p2,p3} <= buf0_2;
							2'b11:{p0,p1,p2,p3} <= buf0_3;
						endcase
			6'b000100:	case (one_edge_counter_TD)
							2'b00:{p0,p1,p2,p3} <= buf1_0;
							2'b01:{p0,p1,p2,p3} <= buf1_1;
							2'b10:{p0,p1,p2,p3} <= buf1_2;
							2'b11:{p0,p1,p2,p3} <= buf1_3;
						endcase
			6'b000010:	case (one_edge_counter_TD)
							2'b00:{p0,p1,p2,p3} <= buf2_0;
							2'b01:{p0,p1,p2,p3} <= buf2_1;
							2'b10:{p0,p1,p2,p3} <= buf2_2;
							2'b11:{p0,p1,p2,p3} <= buf2_3;
			 			endcase
			6'b000001:	case (one_edge_counter_TD)
							2'b00:{p0,p1,p2,p3} <= buf3_0;
							2'b01:{p0,p1,p2,p3} <= buf3_1;
							2'b10:{p0,p1,p2,p3} <= buf3_2;
							2'b11:{p0,p1,p2,p3} <= buf3_3;
			 			endcase 
			default:{p0,p1,p2,p3} <= 0;
		endcase
			 
	//q0 ~ q3
	wire Is_q_from_buf0;
	wire Is_q_from_buf1;
	wire Is_q_from_buf2;
	wire Is_q_from_buf3;
	
	assign Is_q_from_buf0 = (DF_edge_counter_TD == 6'd4  || DF_edge_counter_TD == 6'd12  ||
	DF_edge_counter_TD == 6'd20 || DF_edge_counter_TD == 6'd28 || DF_edge_counter_TD == 6'd36 ||
	DF_edge_counter_TD == 6'd44);
	
	assign Is_q_from_buf1 = (DF_edge_counter_TD == 6'd8  || DF_edge_counter_TD == 6'd13  ||
	DF_edge_counter_TD == 6'd24 || DF_edge_counter_TD == 6'd29 || DF_edge_counter_TD == 6'd37 ||
	DF_edge_counter_TD == 6'd45);
	
	assign Is_q_from_buf2 = (DF_edge_counter_TD == 6'd5  || DF_edge_counter_TD == 6'd14  ||
	DF_edge_counter_TD == 6'd21 || DF_edge_counter_TD == 6'd30 || DF_edge_counter_TD == 6'd38 ||
	DF_edge_counter_TD == 6'd46);
	
	assign Is_q_from_buf3 = (DF_edge_counter_TD == 6'd9  || DF_edge_counter_TD == 6'd15  ||
	DF_edge_counter_TD == 6'd25 || DF_edge_counter_TD == 6'd31 || DF_edge_counter_TD == 6'd39 ||
	DF_edge_counter_TD == 6'd47);	
	
	reg [7:0] q0,q1,q2,q3;
	always @ (Is_q_from_buf0 or Is_q_from_buf1 or Is_q_from_buf2 or Is_q_from_buf3 or 
		rec_DF_RAM_dout or one_edge_counter_TD or DF_edge_counter_TD or 
		buf0_0 or buf0_1 or buf0_2 or buf0_3 or buf1_0 or buf1_1 or buf1_2 or buf1_3 or 
		buf2_0 or buf2_1 or buf2_2 or buf2_3 or buf3_0 or buf3_1 or buf3_2 or buf3_3)
		case ({Is_q_from_buf0,Is_q_from_buf1,Is_q_from_buf2,Is_q_from_buf3})
			4'b1000:case (one_edge_counter_TD)
						2'b00:{q3,q2,q1,q0} <= buf0_0;
						2'b01:{q3,q2,q1,q0} <= buf0_1;
						2'b10:{q3,q2,q1,q0} <= buf0_2;
						2'b11:{q3,q2,q1,q0} <= buf0_3;
					endcase
			4'b0100:case (one_edge_counter_TD)
						2'b00:{q3,q2,q1,q0} <= buf1_0;
						2'b01:{q3,q2,q1,q0} <= buf1_1;
						2'b10:{q3,q2,q1,q0} <= buf1_2;
						2'b11:{q3,q2,q1,q0} <= buf1_3;
					endcase
			4'b0010:case (one_edge_counter_TD)
						2'b00:{q3,q2,q1,q0} <= buf2_0;
						2'b01:{q3,q2,q1,q0} <= buf2_1;
						2'b10:{q3,q2,q1,q0} <= buf2_2;
						2'b11:{q3,q2,q1,q0} <= buf2_3;
			 		endcase
			4'b0001:case (one_edge_counter_TD)
						2'b00:{q3,q2,q1,q0} <= buf3_0;
						2'b01:{q3,q2,q1,q0} <= buf3_1;
						2'b10:{q3,q2,q1,q0} <= buf3_2;
						2'b11:{q3,q2,q1,q0} <= buf3_3;
			 		endcase 
			default:if (DF_edge_counter_TD != 6'd48)	{q3,q2,q1,q0} <= rec_DF_RAM_dout;
					else								{q3,q2,q1,q0} <= 0;
		endcase
				
	// |p0 - q0| < alpha
	assign absolute_TD0_a = (!disable_DF && bs_curr_TD != 0)? p0:0;
	assign absolute_TD0_b = (!disable_DF && bs_curr_TD != 0)? q0:0;
	
	// |p1 - p0| < beta
	assign absolute_TD1_a = (!disable_DF && bs_curr_TD != 0)? p0:0;
	assign absolute_TD1_b = (!disable_DF && bs_curr_TD != 0)? p1:0;
	
	// |q1 - q0| < beta
	assign absolute_TD2_a = (!disable_DF && bs_curr_TD != 0)? q0:0;
	assign absolute_TD2_b = (!disable_DF && bs_curr_TD != 0)? q1:0;
	
	// Threshold
	wire threshold;
	assign threshold = ((absolute_TD0_out < alpha) && (absolute_TD1_out < beta) && 
						(absolute_TD2_out < beta))? 1'b1:1'b0;
	
	//	Pipelined parameters
	reg [2:0] bs_curr_PRE;
	reg [5:0] DF_edge_counter_PRE;
	reg [1:0] one_edge_counter_PRE;
	reg lumaEdgeFlag_PRE,chromaEdgeFlag_PRE;
	reg [7:0] p0_PRE,p1_PRE,p2_PRE,p3_PRE;
	reg [7:0] q0_PRE,q1_PRE,q2_PRE,q3_PRE;
	reg [5:0] indexA_PRE;
	reg [7:0] alpha_PRE,beta_PRE;
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				bs_curr_PRE 		 <= 0;
				DF_edge_counter_PRE  <= 6'd48;
				one_edge_counter_PRE <= 2'd3;
				lumaEdgeFlag_PRE 	 <= 0;
				chromaEdgeFlag_PRE 	 <= 0;
				indexA_PRE <= 0;
				alpha_PRE  <= 0;
				beta_PRE   <= 0;
				p0_PRE <= 0;	p1_PRE <= 0;	p2_PRE <= 0;	p3_PRE <= 0;
				q0_PRE <= 0;	q1_PRE <= 0;	q2_PRE <= 0;	q3_PRE <= 0;
			end
		else 
			begin
				bs_curr_PRE 		<= (threshold)? bs_curr_TD:0;
				DF_edge_counter_PRE	<= DF_edge_counter_TD;
				one_edge_counter_PRE<= one_edge_counter_TD;
				lumaEdgeFlag_PRE 	<= (threshold)? lumaEdgeFlag_TD:0;
				chromaEdgeFlag_PRE 	<= (threshold)? chromaEdgeFlag_TD:0;
				indexA_PRE <= (threshold)? indexA:0;
				alpha_PRE  <= (threshold)? alpha:0;
				beta_PRE   <= (threshold)? beta:0;
				p0_PRE <= p0;	p1_PRE <= p1;	p2_PRE <= p2;	p3_PRE <= p3;
				q0_PRE <= q0;	q1_PRE <= q1;	q2_PRE <= q2;	q3_PRE <= q3;
			end	
	//---------------------------------------------------------------------
	//3.PRE: Precomputation
	//---------------------------------------------------------------------
	wire [7:0] absolute_PRE0_a,absolute_PRE0_b;
	wire [7:0] absolute_PRE1_a,absolute_PRE1_b;
	wire [7:0] absolute_PRE2_a,absolute_PRE2_b;
	wire [7:0] absolute_PRE0_out,absolute_PRE1_out,absolute_PRE2_out;
	
	absolute absolute_PRE0 (.a(absolute_PRE0_a),.b(absolute_PRE0_b),.out(absolute_PRE0_out));
	absolute absolute_PRE1 (.a(absolute_PRE1_a),.b(absolute_PRE1_b),.out(absolute_PRE1_out));
	absolute absolute_PRE2 (.a(absolute_PRE2_a),.b(absolute_PRE2_b),.out(absolute_PRE2_out));
		
	// |p2 - p0| < beta
	assign absolute_PRE0_a = (bs_curr_PRE != 0 && lumaEdgeFlag_PRE)? p2_PRE:0;
	assign absolute_PRE0_b = (bs_curr_PRE != 0 && lumaEdgeFlag_PRE)? p0_PRE:0;
	
	// |q2 - q0| < beta
	assign absolute_PRE1_a = (bs_curr_PRE != 0 && lumaEdgeFlag_PRE)? q2_PRE:0;
	assign absolute_PRE1_b = (bs_curr_PRE != 0 && lumaEdgeFlag_PRE)? q0_PRE:0;
	
	// |p0 - q0| < alpha >> 2 + 2
	assign absolute_PRE2_a = (lumaEdgeFlag_PRE && bs_curr_PRE == 3'd4)? p0_PRE:0;
	assign absolute_PRE2_b = (lumaEdgeFlag_PRE && bs_curr_PRE == 3'd4)? q0_PRE:0;
	
	wire p2_m_p0_less_beta,q2_m_q0_less_beta,p0_m_q0_less_alpha_shift;
	assign p2_m_p0_less_beta = (bs_curr_PRE == 0 || !lumaEdgeFlag_PRE)? 1'b0:
								((absolute_PRE0_out < beta_PRE)? 1'b1:1'b0);
	assign q2_m_q0_less_beta = (bs_curr_PRE == 0 || !lumaEdgeFlag_PRE)? 1'b0:
								((absolute_PRE1_out < beta_PRE)? 1'b1:1'b0);
	assign p0_m_q0_less_alpha_shift = (!lumaEdgeFlag_PRE || bs_curr_PRE != 4)? 1'b0:
								((absolute_PRE2_out < ((alpha_PRE >> 2) + 2))? 1'b1:1'b0);
	// bs = 1 ~ 3
	reg [4:0] c1;
	always @ (bs_curr_PRE or indexA_PRE)
		if (bs_curr_PRE != 0 && bs_curr_PRE != 3'd4)
			case (bs_curr_PRE)
				3'd1:
				if 		(indexA_PRE < 23)	c1 <= 5'd0;
				else if (indexA_PRE < 33)	c1 <= 5'd1;
				else if (indexA_PRE < 37)	c1 <= 5'd2;
				else if (indexA_PRE < 40)	c1 <= 5'd3;
				else if (indexA_PRE < 43)	c1 <= 5'd4;
				else 
					case (indexA_PRE)
						6'd43:c1 <= 5'd5;	6'd44,6'd45:c1 <= 5'd6;
						6'd46:c1 <= 5'd7;	6'd47:c1 <= 5'd8;	6'd48:c1 <= 5'd9;
						6'd49:c1 <= 5'd10;	6'd50:c1 <= 5'd11;	6'd51:c1 <= 5'd13;
						default:c1 <= 0;
					endcase
				3'd2:
				if 		(indexA_PRE < 21)	c1 <= 5'd0;
				else if (indexA_PRE < 31)	c1 <= 5'd1;
				else if (indexA_PRE < 35)	c1 <= 5'd2;
				else if (indexA_PRE < 38)	c1 <= 5'd3;
				else 
					case (indexA_PRE)
						6'd38,6'd39:c1 <= 5'd4;					
						6'd40,6'd41:c1 <= 5'd5;
						6'd42:c1 <= 5'd6;	6'd43:c1 <= 5'd7;	6'd44,6'd45:c1 <= 5'd8;
						6'd46:c1 <= 5'd10;	6'd47:c1 <= 5'd11;	6'd48:c1 <= 5'd12;
						6'd49:c1 <= 5'd13;	6'd50:c1 <= 5'd15;	6'd51:c1 <= 5'd17;
						default:c1 <= 5'd0;
					endcase
				3'd3:
				if 		(indexA_PRE < 17)	c1 <= 5'd0;
				else if (indexA_PRE < 27)	c1 <= 5'd1;
				else if (indexA_PRE < 31)	c1 <= 5'd2;
				else if (indexA_PRE < 34)	c1 <= 5'd3;
				else if (indexA_PRE < 37)	c1 <= 5'd4;
				else 
					case (indexA_PRE)
						6'd37:c1 <= 5'd5;	6'd38,6'd39:c1 <= 5'd6;
						6'd40:c1 <= 5'd7;	6'd41:c1 <= 5'd8;	6'd42:c1 <= 5'd9;	6'd43:c1 <= 5'd10;
						6'd44:c1 <= 5'd11;	6'd45:c1 <= 5'd13;	6'd46:c1 <= 5'd14;	6'd47:c1 <= 5'd16;
						6'd48:c1 <= 5'd18;	6'd49:c1 <= 5'd20;	6'd50:c1 <= 5'd23;	6'd51:c1 <= 5'd25;
						default:c1 <= 5'd0;
					endcase
				default:c1 <= 0;
			endcase
		else 
			c1 <= 0; 
			
	reg [4:0] c0;
	always @ (bs_curr_PRE or lumaEdgeFlag_PRE or c1 or p2_m_p0_less_beta or q2_m_q0_less_beta)
		if (bs_curr_PRE != 0 && bs_curr_PRE != 3'd4)
			begin
				if (lumaEdgeFlag_PRE)	//filter luma edge
					c0 <= (  p2_m_p0_less_beta &&  q2_m_q0_less_beta)? (c1 + 2):
						  ((!p2_m_p0_less_beta && !q2_m_q0_less_beta)? c1:(c1+1));
				else			   		//filter chroma edge
					c0 <= c1 + 1;
	   		end
		else
			c0 <= 0;  
	
	//delta_0i = [(q0 - p0) << 2 + (p1 - q1) + 4] >> 3 : P151 (8-334) of H.264/AVC standard 2003
	wire [8:0] delta_0i;
	wire need_delta_0i;
	wire [8:0]  q0_m_p0; 		//p0 - q0
	wire [11:0] delta_0i_tmp;	//[(p0 - q0) << 2 + (p1 - q1) + 4]	
	assign need_delta_0i = (bs_curr_PRE != 0 && bs_curr_PRE != 3'd4);
	assign q0_m_p0 = 	  (need_delta_0i)? ({1'b0,q0_PRE} + {1'b1,~p0_PRE} + 1):0;
	assign delta_0i_tmp = (need_delta_0i)? ({q0_m_p0[8],q0_m_p0,2'b0} + p1_PRE + {4'b1111,~q1_PRE} + 5):0;
	assign delta_0i = delta_0i_tmp[11:3];
	
	
	//delta p1i = [(p2 + ((p0 + q0 + 1) >> 1) - (p1 << 1)] >> 1	: P152 (8-341) of H.264/AVC standard 2003
	//delta q1i = [(q2 + ((p0 + q0 + 1) >> 1) - (q1 << 1)] >> 1	: P152 (8-343) of H.264/AVC standard 2003
	wire [8:0] delta_p1i,delta_q1i;
	wire need_p1i;
	wire need_q1i;
	wire [8:0] p0_q0_sum; //p0+q0+1
	wire [9:0] neg_p1_shift; //-(p1 << 1)
	wire [9:0] neg_q1_shift; //-(q1 << 1)
	wire [9:0] delta_p1i_tmp;// (p2 + ((p0 + q0 + 1) >> 1) - (p1 << 1)
	wire [9:0] delta_q1i_tmp;// (q2 + ((p0 + q0 + 1) >> 1) - (q1 << 1)
	assign need_p1i = (bs_curr_PRE != 0 && bs_curr_PRE != 3'd4 && p2_m_p0_less_beta);
	assign need_q1i = (bs_curr_PRE != 0 && bs_curr_PRE != 3'd4 && q2_m_q0_less_beta);
	assign p0_q0_sum = (need_p1i || need_q1i)? ({1'b0,p0_PRE} + {1'b0,q0_PRE} + 1):0;
	assign neg_p1_shift =  (need_p1i)? ({1'b1,~p1_PRE,1'b1} + 1):0; 
	assign neg_q1_shift =  (need_q1i)? ({1'b1,~q1_PRE,1'b1} + 1):0;
	assign delta_p1i_tmp = (need_p1i)? (p2_PRE + p0_q0_sum[8:1] + neg_p1_shift):0;
	assign delta_q1i_tmp = (need_q1i)? (q2_PRE + p0_q0_sum[8:1] + neg_q1_shift):0;
	assign delta_p1i = delta_p1i_tmp[9:1];
	assign delta_q1i = delta_q1i_tmp[9:1];
	
	wire [8:0] clip_to_c_0_delta,clip_to_c_p1_delta,clip_to_c_q1_delta;
	wire [4:0] clip_to_c_0_c,clip_to_c_p1_c,clip_to_c_q1_c;
	wire [5:0] clip_to_c_0_out,clip_to_c_p1_out,clip_to_c_q1_out;
	clip_to_c clip_to_c_0 (.delta(clip_to_c_0_delta),.c(clip_to_c_0_c),.out(clip_to_c_0_out));
	clip_to_c clip_to_c_p1 (.delta(clip_to_c_p1_delta),.c(clip_to_c_p1_c),.out(clip_to_c_p1_out));
	clip_to_c clip_to_c_q1 (.delta(clip_to_c_q1_delta),.c(clip_to_c_q1_c),.out(clip_to_c_q1_out)); 
	
	assign clip_to_c_0_delta  = (bs_curr_PRE != 0 && bs_curr_PRE != 3'd4)? delta_0i:0;
	assign clip_to_c_0_c      = (bs_curr_PRE != 0 && bs_curr_PRE != 3'd4)? c0:0;
	assign clip_to_c_p1_delta = (bs_curr_PRE != 0 && bs_curr_PRE != 3'd4 && p2_m_p0_less_beta)? delta_p1i:0;
	assign clip_to_c_p1_c 	  = (bs_curr_PRE != 0 && bs_curr_PRE != 3'd4 && p2_m_p0_less_beta)? c1:0;
	assign clip_to_c_q1_delta = (bs_curr_PRE != 0 && bs_curr_PRE != 3'd4 && q2_m_q0_less_beta)? delta_q1i:0;
	assign clip_to_c_q1_c 	  = (bs_curr_PRE != 0 && bs_curr_PRE != 3'd4 && q2_m_q0_less_beta)? c1:0; 
					
	//	Pipelined parameters
	reg [5:0] delta_0,delta_p1,delta_q1;
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin delta_0 <= 0;	delta_p1 <= 0;	delta_q1 <= 0;	end		
		else if (bs_curr_PRE != 0 && bs_curr_PRE != 3'd4)
			begin
				delta_0  <= clip_to_c_0_out;
				delta_p1 <= (p2_m_p0_less_beta)? clip_to_c_p1_out:0;
				delta_q1 <= (q2_m_q0_less_beta)? clip_to_c_q1_out:0;
			end
	
	reg p2_m_p0_less_beta_FIR,q2_m_q0_less_beta_FIR,p0_m_q0_less_alpha_shift_FIR;
	reg lumaEdgeFlag_FIR,chromaEdgeFlag_FIR;
	reg [2:0] bs_curr_FIR;
	reg [5:0] DF_edge_counter_FIR;
	reg [1:0] one_edge_counter_FIR;
	reg [7:0] p0_FIR,p1_FIR,p2_FIR,p3_FIR;
	reg [7:0] q0_FIR,q1_FIR,q2_FIR,q3_FIR;
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				p2_m_p0_less_beta_FIR <= 0;	q2_m_q0_less_beta_FIR <= 0;	
				p0_m_q0_less_alpha_shift_FIR <= 0;
				bs_curr_FIR		<= 0;
				lumaEdgeFlag_FIR <= 0;			chromaEdgeFlag_FIR <= 0;
				DF_edge_counter_FIR <= 6'd48;	one_edge_counter_FIR <= 2'd3;
				p0_FIR <= 0;	p1_FIR <= 0;	p2_FIR <= 0;	p3_FIR <= 0;	
				q0_FIR <= 0;	q1_FIR <= 0;	q2_FIR <= 0;	q3_FIR <= 0;
			end
		else  
			begin
				p2_m_p0_less_beta_FIR <= p2_m_p0_less_beta;	
				q2_m_q0_less_beta_FIR <= q2_m_q0_less_beta;	
				p0_m_q0_less_alpha_shift_FIR <= p0_m_q0_less_alpha_shift;
				bs_curr_FIR 	<= bs_curr_PRE;
				lumaEdgeFlag_FIR <= lumaEdgeFlag_PRE;		chromaEdgeFlag_FIR <= chromaEdgeFlag_PRE;
				DF_edge_counter_FIR <= DF_edge_counter_PRE; one_edge_counter_FIR <= one_edge_counter_PRE;
				p0_FIR <= p0_PRE;	p1_FIR <= p1_PRE;	p2_FIR <= p2_PRE;	p3_FIR <= p3_PRE;
				q0_FIR <= q0_PRE;	q1_FIR <= q1_PRE;	q2_FIR <= q2_PRE;	q3_FIR <= q3_PRE;
			end
	//---------------------------------------------------------------------
	//4.FIR: filtering
	//---------------------------------------------------------------------
	reg [7:0] bs4_strong_FIR_p0,bs4_strong_FIR_p1,bs4_strong_FIR_p2,bs4_strong_FIR_p3;
	reg [7:0] bs4_strong_FIR_q0,bs4_strong_FIR_q1,bs4_strong_FIR_q2,bs4_strong_FIR_q3;
	wire [7:0] bs4_strong_FIR_p0_out,bs4_strong_FIR_p1_out,bs4_strong_FIR_p2_out;
	wire [7:0] bs4_strong_FIR_q0_out,bs4_strong_FIR_q1_out,bs4_strong_FIR_q2_out;
	bs4_strong_FIR bs4_strong_FIR (
		.p0(bs4_strong_FIR_p0),.p1(bs4_strong_FIR_p1),.p2(bs4_strong_FIR_p2),.p3(bs4_strong_FIR_p3),
		.q0(bs4_strong_FIR_q0),.q1(bs4_strong_FIR_q1),.q2(bs4_strong_FIR_q2),.q3(bs4_strong_FIR_q3),
		.p0_out(bs4_strong_FIR_p0_out),.p1_out(bs4_strong_FIR_p1_out),.p2_out(bs4_strong_FIR_p2_out),
		.q0_out(bs4_strong_FIR_q0_out),.q1_out(bs4_strong_FIR_q1_out),.q2_out(bs4_strong_FIR_q2_out)
		);
	reg [7:0] bs4_weak_FIR0_a,bs4_weak_FIR0_b,bs4_weak_FIR0_c;
	reg [7:0] bs4_weak_FIR1_a,bs4_weak_FIR1_b,bs4_weak_FIR1_c; 
	wire [7:0] bs4_weak_FIR0_out,bs4_weak_FIR1_out;
	bs4_weak_FIR bs4_weak_FIR0 (.a(bs4_weak_FIR0_a),.b(bs4_weak_FIR0_b),.c(bs4_weak_FIR0_c),.out(bs4_weak_FIR0_out));
	bs4_weak_FIR bs4_weak_FIR1 (.a(bs4_weak_FIR1_a),.b(bs4_weak_FIR1_b),.c(bs4_weak_FIR1_c),.out(bs4_weak_FIR1_out));
	// bs = 4
	always @ (bs_curr_FIR or lumaEdgeFlag_FIR or p0_m_q0_less_alpha_shift_FIR 
		or p2_m_p0_less_beta_FIR or q2_m_q0_less_beta_FIR
		or p0_FIR or p1_FIR or p2_FIR or p3_FIR or q0_FIR or q1_FIR or q2_FIR or q3_FIR)	
		if (bs_curr_FIR == 3'd4 && lumaEdgeFlag_FIR == 1'b1 && p0_m_q0_less_alpha_shift_FIR
			&& (p2_m_p0_less_beta_FIR || q2_m_q0_less_beta_FIR))
			begin
				bs4_strong_FIR_p0 <= p0_FIR;	bs4_strong_FIR_p1 <= p1_FIR;
				bs4_strong_FIR_p2 <= p2_FIR;	bs4_strong_FIR_p3 <= p3_FIR;
				bs4_strong_FIR_q0 <= q0_FIR;	bs4_strong_FIR_q1 <= q1_FIR;	
				bs4_strong_FIR_q2 <= q2_FIR;	bs4_strong_FIR_q3 <= q3_FIR;
			end
		else
			begin
				bs4_strong_FIR_p0 <= 0;	bs4_strong_FIR_p1 <= 0;	bs4_strong_FIR_p2 <= 0; bs4_strong_FIR_p3 <= 0;
				bs4_strong_FIR_q0 <= 0;	bs4_strong_FIR_q1 <= 0;	bs4_strong_FIR_q2 <= 0;	bs4_strong_FIR_q3 <= 0;
			end
	always @ (bs_curr_FIR or lumaEdgeFlag_FIR or chromaEdgeFlag_FIR
		or p2_m_p0_less_beta_FIR or p0_m_q0_less_alpha_shift_FIR
		or p1_FIR or p0_FIR or q1_FIR) 
		if (bs_curr_FIR == 3'd4 && lumaEdgeFlag_FIR == 1'b1)
			begin
				if (!p2_m_p0_less_beta_FIR || !p0_m_q0_less_alpha_shift_FIR)
					begin
						bs4_weak_FIR0_a <= p1_FIR;	bs4_weak_FIR0_b <= p0_FIR;	bs4_weak_FIR0_c <= q1_FIR;
					end
				else
					begin
						bs4_weak_FIR0_a <= 0;	bs4_weak_FIR0_b <= 0;	bs4_weak_FIR0_c <= 0;
					end
			end
		else if (bs_curr_FIR == 3'd4 && chromaEdgeFlag_FIR == 1'b1)
			begin
				bs4_weak_FIR0_a <= p1_FIR;	bs4_weak_FIR0_b <= p0_FIR;	bs4_weak_FIR0_c <= q1_FIR;
			end
		else
			begin
				bs4_weak_FIR0_a <= 0;	bs4_weak_FIR0_b <= 0;	bs4_weak_FIR0_c <= 0;
			end
	always @ (bs_curr_FIR or lumaEdgeFlag_FIR or chromaEdgeFlag_FIR
		or q2_m_q0_less_beta_FIR or p0_m_q0_less_alpha_shift_FIR
		or q1_FIR or q0_FIR or p1_FIR) 
		if (bs_curr_FIR == 3'd4 && lumaEdgeFlag_FIR == 1'b1)
			begin
				if (!q2_m_q0_less_beta_FIR || !p0_m_q0_less_alpha_shift_FIR)
					begin
						bs4_weak_FIR1_a <= q1_FIR;	bs4_weak_FIR1_b <= q0_FIR;	bs4_weak_FIR1_c <= p1_FIR;
					end
				else
					begin
						bs4_weak_FIR1_a <= 0;	bs4_weak_FIR1_b <= 0;	bs4_weak_FIR1_c <= 0;
					end
			end
		else if (bs_curr_FIR == 3'd4 && chromaEdgeFlag_FIR == 1'b1)
			begin
				bs4_weak_FIR1_a <= q1_FIR;	bs4_weak_FIR1_b <= q0_FIR;	bs4_weak_FIR1_c <= p1_FIR;
			end
		else
			begin
				bs4_weak_FIR1_a <= 0;	bs4_weak_FIR1_b <= 0;	bs4_weak_FIR1_c <= 0;
			end	
	//bs = 1 ~ 3,for p0 and q0 filtering
	wire [9:0] p0_MW_tmp,q0_MW_tmp;
	wire [7:0] p0_MW_clipped,q0_MW_clipped;
	assign p0_MW_tmp = (bs_curr_FIR != 0 && bs_curr_FIR != 3'd4)? ({2'b0,p0_FIR} + {{4{delta_0[5]}},delta_0}):0;
	assign q0_MW_tmp = (bs_curr_FIR != 0 && bs_curr_FIR != 3'd4)? ({2'b0,q0_FIR} + 
						{~delta_0[5],~delta_0[5],~delta_0[5],~delta_0[5],~delta_0} + 1):0;
	assign p0_MW_clipped = (p0_MW_tmp[9] == 1'b1)? 0:((p0_MW_tmp[8] == 1'b1)? 8'd255:p0_MW_tmp[7:0]);
	assign q0_MW_clipped = (q0_MW_tmp[9] == 1'b1)? 0:((q0_MW_tmp[8] == 1'b1)? 8'd255:q0_MW_tmp[7:0]);
			
	//	Pipelined parameters
	reg [7:0] p0_MW,p1_MW,p2_MW,p3_MW;
	reg [7:0] q0_MW,q1_MW,q2_MW,q3_MW;
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				p0_MW <= 0;	p1_MW <= 0;	p2_MW <= 0;
				q0_MW <= 0;	q1_MW <= 0;	q2_MW <= 0;
			end	
		else if (bs_curr_FIR == 3'd4)
			begin
				if (lumaEdgeFlag_FIR)
					begin
						p0_MW <= (p0_m_q0_less_alpha_shift_FIR && p2_m_p0_less_beta_FIR)? 
								  	bs4_strong_FIR_p0_out:bs4_weak_FIR0_out;
						q0_MW <= (p0_m_q0_less_alpha_shift_FIR && q2_m_q0_less_beta_FIR)? 
									bs4_strong_FIR_q0_out:bs4_weak_FIR1_out;
						p1_MW <= (p0_m_q0_less_alpha_shift_FIR && p2_m_p0_less_beta_FIR)? 
									bs4_strong_FIR_p1_out:p1_FIR;
						q1_MW <= (p0_m_q0_less_alpha_shift_FIR && q2_m_q0_less_beta_FIR)? 
									bs4_strong_FIR_q1_out:q1_FIR;
						p2_MW <= (p0_m_q0_less_alpha_shift_FIR && p2_m_p0_less_beta_FIR)? 
									bs4_strong_FIR_p2_out:p2_FIR;
						q2_MW <= (p0_m_q0_less_alpha_shift_FIR && q2_m_q0_less_beta_FIR)? 
									bs4_strong_FIR_q2_out:q2_FIR;
					end
				else
					begin 
						p0_MW <= bs4_weak_FIR0_out;	q0_MW <= bs4_weak_FIR1_out;
						p1_MW <= p1_FIR;		q1_MW <= q1_FIR;
						p2_MW <= p2_FIR;		q2_MW <= q2_FIR;
					end
			end
		else if (bs_curr_FIR != 0 && bs_curr_FIR != 3'd4)
			begin
				p0_MW <= p0_MW_clipped;
				q0_MW <= q0_MW_clipped;
				p1_MW <= (lumaEdgeFlag_FIR)? ((p2_m_p0_less_beta_FIR)? (p1_FIR + {delta_p1[5],delta_p1[5],delta_p1}):p1_FIR):p1_FIR; 
				q1_MW <= (lumaEdgeFlag_FIR)? ((q2_m_q0_less_beta_FIR)? (q1_FIR + {delta_q1[5],delta_q1[5],delta_q1}):q1_FIR):q1_FIR;
				p2_MW <= p2_FIR;
				q2_MW <= q2_FIR;
			end
		else
			begin
				p0_MW <= p0_FIR;	p1_MW <= p1_FIR;	p2_MW <= p2_FIR;
				q0_MW <= q0_FIR;	q1_MW <= q1_FIR;	q2_MW <= q2_FIR;
			end
	
	reg [2:0] bs_curr_MW;
	reg [5:0] DF_edge_counter_MW;
	reg [1:0] one_edge_counter_MW;
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				DF_edge_counter_MW <= 6'd48;	one_edge_counter_MW <= 2'd3;
				p3_MW <= 0;						q3_MW <= 0;
				bs_curr_MW <= 0;				
			end
		else
			begin
				DF_edge_counter_MW <= DF_edge_counter_FIR;		p3_MW <= p3_FIR;			
				one_edge_counter_MW <= one_edge_counter_FIR;	q3_MW <= q3_FIR;
				bs_curr_MW <= bs_curr_FIR;		
			end
endmodule

module absolute (a,b,out);
	input [7:0] a,b;
	output [7:0] out;
	
	assign out = (a > b)? (a - b):(b - a);
endmodule

module clip_to_c (delta,c,out);
	input [8:0] delta;
	input [4:0] c;		// 0 ~ 25,	 [4:0]
	output [5:0] out;	// -25 ~ 25, [5:0] 
	reg [5:0] out;
	
	wire [5:0] neg_c;	//-25 ~ 25,[5:0]
	assign neg_c = {1'b1,~c} + 1;
	
	always @ (delta or c or neg_c)
		if (delta[8] == 1'b0)	//delta is positive
			out <= (delta[7:0] > {3'b0,c})? {1'b0,c}:delta[5:0];
		else					//delta is negtive
			out <= (delta[7:0] < {2'b11,neg_c})? {1'b1,neg_c}:delta[5:0];
endmodule

module bs4_strong_FIR (p0,p1,p2,p3,q0,q1,q2,q3,p0_out,p1_out,p2_out,q0_out,q1_out,q2_out);
	input [7:0]  p0,p1,p2,p3,q0,q1,q2,q3;
	output [7:0] p0_out,p1_out,p2_out,q0_out,q1_out,q2_out;
	
	wire [8:0] sum_p2p3,sum_p1p2,sum_p0q0,sum_p1q1,sum_q1q2,sum_q2q3;
	assign sum_p2p3 = p2 + p3;
	assign sum_p1p2 = p1 + p2;
	assign sum_p0q0 = p0 + q0;
	assign sum_p1q1 = p1 + q1;
	assign sum_q1q2 = q1 + q2;
	assign sum_q2q3 = q2 + q3;
	
	wire [9:0] sum_p2p3_x2,sum_q2q3_x2;
	assign sum_p2p3_x2 = {sum_p2p3,1'b0};
	assign sum_q2q3_x2 = {sum_q2q3,1'b0};
	
	wire [9:0] sum_0,sum_1,sum_2;
	assign sum_0 = sum_p0q0 + sum_p1p2;
	assign sum_1 = sum_p0q0 + sum_p1q1;
	assign sum_2 = sum_p0q0 + sum_q1q2;
	
	wire [10:0] p0_tmp,p2_tmp,q0_tmp,q2_tmp;
	assign p0_tmp = sum_0 + sum_1;
	assign p2_tmp = sum_p2p3_x2 + sum_0;
	assign q0_tmp = sum_1 + sum_2;
	assign q2_tmp = sum_q2q3_x2 + sum_2;
	
	assign p0_out = (p0_tmp + 4) >> 3;
	assign p1_out = (sum_0  + 2) >> 2;
	assign p2_out = (p2_tmp + 4) >> 3;
	assign q0_out = (q0_tmp + 4) >> 3;
	assign q1_out = (sum_2  + 2) >> 2;
	assign q2_out = (q2_tmp + 4) >> 3;
endmodule

module bs4_weak_FIR (a,b,c,out);
	input [7:0] a,b,c;
	output [7:0] out;
	
	wire [8:0] a_x2;
	assign a_x2 = {a,1'b0};
	
	wire [8:0] sum_bc;
	assign sum_bc = b + c;
	
	wire [9:0] out_tmp;
	assign out_tmp = (a_x2 + sum_bc) + 2;
	assign out = out_tmp[9:2];
endmodule
	