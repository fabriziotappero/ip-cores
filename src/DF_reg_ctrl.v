//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : DF_reg_ctrl.v
// Generated : Nov 27,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// buffer buf0 ~ buf3 & transpose reg t0 ~ t1 control
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module DF_reg_ctrl (gclk_DF,reset_n,DF_edge_counter_MW,one_edge_counter_MW,
	mb_num_h_DF,mb_num_v_DF,q0_MW,q1_MW,q2_MW,q3_MW,p0_MW,p1_MW,p2_MW,p3_MW,
	buf0_0,buf0_1,buf0_2,buf0_3,buf1_0,buf1_1,buf1_2,buf1_3,
	buf2_0,buf2_1,buf2_2,buf2_3,buf3_0,buf3_1,buf3_2,buf3_3,
	t0_0,t0_1,t0_2,t0_3,t1_0,t1_1,t1_2,t1_3,t2_0,t2_1,t2_2,t2_3);
	input gclk_DF,reset_n;
	input [5:0] DF_edge_counter_MW;
	input [1:0] one_edge_counter_MW;
	input [3:0] mb_num_h_DF;
	input [3:0] mb_num_v_DF;
	input [7:0] q0_MW,q1_MW,q2_MW,q3_MW;
	input [7:0] p0_MW,p1_MW,p2_MW,p3_MW;
	
	output [31:0] buf0_0,buf0_1,buf0_2,buf0_3;
	output [31:0] buf1_0,buf1_1,buf1_2,buf1_3;
	output [31:0] buf2_0,buf2_1,buf2_2,buf2_3;
	output [31:0] buf3_0,buf3_1,buf3_2,buf3_3;
	output [31:0] t0_0,t0_1,t0_2,t0_3;
	output [31:0] t1_0,t1_1,t1_2,t1_3;
	output [31:0] t2_0,t2_1,t2_2,t2_3;
	
	reg [31:0] buf0_0,buf0_1,buf0_2,buf0_3;
	reg [31:0] buf1_0,buf1_1,buf1_2,buf1_3;
	reg [31:0] buf2_0,buf2_1,buf2_2,buf2_3;
	reg [31:0] buf3_0,buf3_1,buf3_2,buf3_3;
	reg [31:0] t0_0,t0_1,t0_2,t0_3;
	reg [31:0] t1_0,t1_1,t1_2,t1_3;
	reg [31:0] t2_0,t2_1,t2_2,t2_3;
	//------------------------------------------------------
	//buf0
	//------------------------------------------------------
	wire buf0_no_transpose;	//buf0 updated without transpose
	wire buf0_transpose;		//buf0 updated after   transpose
	assign buf0_no_transpose = (
		DF_edge_counter_MW == 6'd0  || DF_edge_counter_MW == 6'd4  || DF_edge_counter_MW == 6'd6  ||
		DF_edge_counter_MW == 6'd12 || DF_edge_counter_MW == 6'd16 || DF_edge_counter_MW == 6'd20 ||
		DF_edge_counter_MW == 6'd22 || DF_edge_counter_MW == 6'd28 || DF_edge_counter_MW == 6'd32 ||
		DF_edge_counter_MW == 6'd36 || DF_edge_counter_MW == 6'd40 || DF_edge_counter_MW == 6'd44);
	assign buf0_transpose = (
		DF_edge_counter_MW == 6'd1  || DF_edge_counter_MW == 6'd5  || DF_edge_counter_MW == 6'd10 ||
		DF_edge_counter_MW == 6'd14 || DF_edge_counter_MW == 6'd17 || DF_edge_counter_MW == 6'd26 ||
		DF_edge_counter_MW == 6'd30 || DF_edge_counter_MW == 6'd33 || DF_edge_counter_MW == 6'd38 ||
		DF_edge_counter_MW == 6'd41 || DF_edge_counter_MW == 6'd46);
		
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin 
				buf0_0 <= 0;	buf0_1 <= 0;	buf0_2 <= 0;	buf0_3 <= 0;
			end
		//no transpose update,always "q" position (right or down of the edge to be filtered)
		else if (buf0_no_transpose)
			case (one_edge_counter_MW)
				2'd0:buf0_0 <= {q3_MW,q2_MW,q1_MW,q0_MW};
				2'd1:buf0_1 <= {q3_MW,q2_MW,q1_MW,q0_MW};
				2'd2:buf0_2 <= {q3_MW,q2_MW,q1_MW,q0_MW};
				2'd3:buf0_3 <= {q3_MW,q2_MW,q1_MW,q0_MW};
			endcase
		//transpose update,always "p" position (left or up of the edge to be filtered)
		else if (buf0_transpose)
			case (one_edge_counter_MW)
				2'd0:begin	buf0_0[7:0]   <= p3_MW;	buf0_1[7:0]   <= p2_MW;
							buf0_2[7:0]   <= p1_MW;	buf0_3[7:0]   <= p0_MW;	end
				2'd1:begin	buf0_0[15:8]  <= p3_MW;	buf0_1[15:8]  <= p2_MW;
							buf0_2[15:8]  <= p1_MW;	buf0_3[15:8]  <= p0_MW;	end
				2'd2:begin	buf0_0[23:16] <= p3_MW;	buf0_1[23:16] <= p2_MW;
							buf0_2[23:16] <= p1_MW;	buf0_3[23:16] <= p0_MW;	end
				2'd3:begin	buf0_0[31:24] <= p3_MW;	buf0_1[31:24] <= p2_MW;
							buf0_2[31:24] <= p1_MW;	buf0_3[31:24] <= p0_MW;	end
			endcase	
	//------------------------------------------------------
	//buf1
	//------------------------------------------------------
	wire buf1_no_transpose;	//buf1 updated without transpose
	wire buf1_transpose;		//buf1 updated after   transpose
	wire buf1_transpose_p;	//buf1 transpose and buf1 stores "p" position pixels
	assign buf1_no_transpose = ( 
		DF_edge_counter_MW == 6'd1  || DF_edge_counter_MW == 6'd8  || DF_edge_counter_MW == 6'd13 ||
		DF_edge_counter_MW == 6'd17 || DF_edge_counter_MW == 6'd24 || DF_edge_counter_MW == 6'd29 ||
		DF_edge_counter_MW == 6'd37 || DF_edge_counter_MW == 6'd45);
	assign buf1_transpose = (
		DF_edge_counter_MW == 6'd6  || DF_edge_counter_MW == 6'd10 || DF_edge_counter_MW == 6'd22 || 
		DF_edge_counter_MW == 6'd26 || DF_edge_counter_MW == 6'd33 || DF_edge_counter_MW == 6'd41);
	assign buf1_transpose_p = (DF_edge_counter_MW == 6'd6  || DF_edge_counter_MW == 6'd9  
							|| DF_edge_counter_MW == 6'd22);
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin 
				buf1_0 <= 0;	buf1_1 <= 0;	buf1_2 <= 0;	buf1_3 <= 0;
			end
		//no transpose update,always "q" position (right or down of the edge to be filtered)
		else if (buf1_no_transpose)
			case (one_edge_counter_MW)
				2'd0:buf1_0 <= {q3_MW,q2_MW,q1_MW,q0_MW};
				2'd1:buf1_1 <= {q3_MW,q2_MW,q1_MW,q0_MW};
				2'd2:buf1_2 <= {q3_MW,q2_MW,q1_MW,q0_MW};
				2'd3:buf1_3 <= {q3_MW,q2_MW,q1_MW,q0_MW};
			endcase
		//transpose update,"p":6/9/22,"q":10,26,33,41
		else if (buf1_transpose)
			begin 
				if (buf1_transpose_p)	// edge 6,22  "p"
					case (one_edge_counter_MW)
						2'd0:begin	buf1_0[7:0]   <= p3_MW;	buf1_1[7:0]   <= p2_MW;
									buf1_2[7:0]   <= p1_MW;	buf1_3[7:0]   <= p0_MW;	end
						2'd1:begin	buf1_0[15:8]  <= p3_MW;	buf1_1[15:8]  <= p2_MW;
									buf1_2[15:8]  <= p1_MW;	buf1_3[15:8]  <= p0_MW;	end
						2'd2:begin	buf1_0[23:16] <= p3_MW;	buf1_1[23:16] <= p2_MW;
									buf1_2[23:16] <= p1_MW;	buf1_3[23:16] <= p0_MW;	end
						2'd3:begin	buf1_0[31:24] <= p3_MW;	buf1_1[31:24] <= p2_MW;
									buf1_2[31:24] <= p1_MW;	buf1_3[31:24] <= p0_MW;	end
					endcase
				else					//edge 10,26,33,41  "q"
					case (one_edge_counter_MW)
						2'd0:begin	buf1_0[7:0]   <= q0_MW;	buf1_1[7:0]   <= q1_MW;
									buf1_2[7:0]   <= q2_MW;	buf1_3[7:0]   <= q3_MW;	end
						2'd1:begin	buf1_0[15:8]  <= q0_MW;	buf1_1[15:8]  <= q1_MW;
									buf1_2[15:8]  <= q2_MW;	buf1_3[15:8]  <= q3_MW;	end
						2'd2:begin	buf1_0[23:16] <= q0_MW;	buf1_1[23:16] <= q1_MW;
									buf1_2[23:16] <= q2_MW;	buf1_3[23:16] <= q3_MW;	end
						2'd3:begin	buf1_0[31:24] <= q0_MW;	buf1_1[31:24] <= q1_MW;
									buf1_2[31:24] <= q2_MW;	buf1_3[31:24] <= q3_MW;	end
					endcase
			end
	//------------------------------------------------------
	//buf2
	//------------------------------------------------------
	wire buf2_no_transpose;	//buf2 updated without transpose
	wire buf2_transpose;		//buf2 updated after   transpose
	wire buf2_transpose_p;	//buf2 transpose and buf2 stores "p" position pixels
	assign buf2_no_transpose = ( 
		DF_edge_counter_MW == 6'd2  || DF_edge_counter_MW == 6'd7  || DF_edge_counter_MW == 6'd18 ||
		DF_edge_counter_MW == 6'd23 || DF_edge_counter_MW == 6'd34 || DF_edge_counter_MW == 6'd42);
	assign buf2_transpose = (
		DF_edge_counter_MW == 6'd3  || DF_edge_counter_MW == 6'd11 || DF_edge_counter_MW == 6'd19 ||
		DF_edge_counter_MW == 6'd21 || DF_edge_counter_MW == 6'd27 || DF_edge_counter_MW == 6'd30 ||
		DF_edge_counter_MW == 6'd35 || DF_edge_counter_MW == 6'd38 || DF_edge_counter_MW == 6'd43 ||
		DF_edge_counter_MW == 6'd46);
	assign buf2_transpose_p = (DF_edge_counter_MW == 6'd3  || DF_edge_counter_MW == 6'd11  
							|| DF_edge_counter_MW == 6'd19 || DF_edge_counter_MW == 6'd27
							|| DF_edge_counter_MW == 6'd35 || DF_edge_counter_MW == 6'd43);
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin 
				buf2_0 <= 0;	buf2_1 <= 0;	buf2_2 <= 0;	buf2_3 <= 0;
			end
		//no transpose update,always "q" position (right or down of the edge to be filtered)
		else if (buf2_no_transpose)
			case (one_edge_counter_MW)
				2'd0:buf2_0 <= {q3_MW,q2_MW,q1_MW,q0_MW};
				2'd1:buf2_1 <= {q3_MW,q2_MW,q1_MW,q0_MW};
				2'd2:buf2_2 <= {q3_MW,q2_MW,q1_MW,q0_MW};
				2'd3:buf2_3 <= {q3_MW,q2_MW,q1_MW,q0_MW};
			endcase
		//transpose update,"p":3,11,19,27,35,43  "q":21,30,38,46
		else if (buf2_transpose)
			begin 
				if (buf2_transpose_p)	//"p":3,11,19,27,35,43
					case (one_edge_counter_MW)
						2'd0:begin	buf2_0[7:0]   <= p3_MW;	buf2_1[7:0]   <= p2_MW;
									buf2_2[7:0]   <= p1_MW;	buf2_3[7:0]   <= p0_MW;	end
						2'd1:begin	buf2_0[15:8]  <= p3_MW;	buf2_1[15:8]  <= p2_MW;
									buf2_2[15:8]  <= p1_MW;	buf2_3[15:8]  <= p0_MW;	end
						2'd2:begin	buf2_0[23:16] <= p3_MW;	buf2_1[23:16] <= p2_MW;
									buf2_2[23:16] <= p1_MW;	buf2_3[23:16] <= p0_MW;	end
						2'd3:begin	buf2_0[31:24] <= p3_MW;	buf2_1[31:24] <= p2_MW;
									buf2_2[31:24] <= p1_MW;	buf2_3[31:24] <= p0_MW;	end
					endcase
				else					//"q":21,30,38,46
					case (one_edge_counter_MW)
						2'd0:begin	buf2_0[7:0]   <= q0_MW;	buf2_1[7:0]   <= q1_MW;
									buf2_2[7:0]   <= q2_MW;	buf2_3[7:0]   <= q3_MW;	end
						2'd1:begin	buf2_0[15:8]  <= q0_MW;	buf2_1[15:8]  <= q1_MW;
									buf2_2[15:8]  <= q2_MW;	buf2_3[15:8]  <= q3_MW;	end
						2'd2:begin	buf2_0[23:16] <= q0_MW;	buf2_1[23:16] <= q1_MW;
									buf2_2[23:16] <= q2_MW;	buf2_3[23:16] <= q3_MW;	end
						2'd3:begin	buf2_0[31:24] <= q0_MW;	buf2_1[31:24] <= q1_MW;
									buf2_2[31:24] <= q2_MW;	buf2_3[31:24] <= q3_MW;	end
					endcase
			end	
	//------------------------------------------------------
	//buf3
	//------------------------------------------------------
	wire buf3_no_transpose;	//buf3 updated without transpose
	wire buf3_transpose;		//buf3 updated after   transpose
	wire buf3_transpose_p;	//buf3 transpose and buf1 stores "p" position pixels
	assign buf3_no_transpose = (DF_edge_counter_MW == 6'd3  || DF_edge_counter_MW == 6'd19);
	assign buf3_transpose = (	DF_edge_counter_MW == 6'd7  || 
		DF_edge_counter_MW == 6'd11 || DF_edge_counter_MW == 6'd23 || DF_edge_counter_MW == 6'd27 || 
		DF_edge_counter_MW == 6'd25 || DF_edge_counter_MW == 6'd35 || DF_edge_counter_MW == 6'd43);
	assign buf3_transpose_p = (DF_edge_counter_MW == 6'd7  || DF_edge_counter_MW == 6'd23);  
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin 
				buf3_0 <= 0;	buf3_1 <= 0;	buf3_2 <= 0;	buf3_3 <= 0;
			end
		//no transpose update,always "q" position (right or down of the edge to be filtered)
		else if (buf3_no_transpose)
			case (one_edge_counter_MW)
				2'd0:buf3_0 <= {q3_MW,q2_MW,q1_MW,q0_MW};
				2'd1:buf3_1 <= {q3_MW,q2_MW,q1_MW,q0_MW};
				2'd2:buf3_2 <= {q3_MW,q2_MW,q1_MW,q0_MW};
				2'd3:buf3_3 <= {q3_MW,q2_MW,q1_MW,q0_MW};
			endcase
		//transpose update,"p":7,23  "q":11,25,27,35,43
		else if (buf3_transpose)
			begin 
				if (buf3_transpose_p)	//"p":7,23
					case (one_edge_counter_MW)
						2'd0:begin	buf3_0[7:0]   <= p3_MW;	buf3_1[7:0]   <= p2_MW;
									buf3_2[7:0]   <= p1_MW;	buf3_3[7:0]   <= p0_MW;	end
						2'd1:begin	buf3_0[15:8]  <= p3_MW;	buf3_1[15:8]  <= p2_MW;
									buf3_2[15:8]  <= p1_MW;	buf3_3[15:8]  <= p0_MW;	end
						2'd2:begin	buf3_0[23:16] <= p3_MW;	buf3_1[23:16] <= p2_MW;
									buf3_2[23:16] <= p1_MW;	buf3_3[23:16] <= p0_MW;	end
						2'd3:begin	buf3_0[31:24] <= p3_MW;	buf3_1[31:24] <= p2_MW;
									buf3_2[31:24] <= p1_MW;	buf3_3[31:24] <= p0_MW;	end
					endcase
				else					//"q":11,25,35,43
					case (one_edge_counter_MW)
						2'd0:begin	buf3_0[7:0]   <= q0_MW;	buf3_1[7:0]   <= q1_MW;
									buf3_2[7:0]   <= q2_MW;	buf3_3[7:0]   <= q3_MW;	end
						2'd1:begin	buf3_0[15:8]  <= q0_MW;	buf3_1[15:8]  <= q1_MW;
									buf3_2[15:8]  <= q2_MW;	buf3_3[15:8]  <= q3_MW;	end
						2'd2:begin	buf3_0[23:16] <= q0_MW;	buf3_1[23:16] <= q1_MW;
									buf3_2[23:16] <= q2_MW;	buf3_3[23:16] <= q3_MW;	end
						2'd3:begin	buf3_0[31:24] <= q0_MW;	buf3_1[31:24] <= q1_MW;
									buf3_2[31:24] <= q2_MW;	buf3_3[31:24] <= q3_MW;	end
					endcase
			end
	//------------------------------------------------------
	//T0:always updated after transpose,always "p" position
	//------------------------------------------------------
	wire t0_transpose;		//t0 updated after transpose
	assign t0_transpose = (
	DF_edge_counter_MW == 6'd4  || DF_edge_counter_MW == 6'd8  || DF_edge_counter_MW == 6'd12 || DF_edge_counter_MW == 6'd36 || 
	DF_edge_counter_MW == 6'd44 || DF_edge_counter_MW == 6'd15 || DF_edge_counter_MW == 6'd20 || DF_edge_counter_MW == 6'd24 || 
	DF_edge_counter_MW == 6'd28 || DF_edge_counter_MW == 6'd31 || DF_edge_counter_MW == 6'd39 || DF_edge_counter_MW == 6'd47);

	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin 
				t0_0 <= 0;	t0_1 <= 0;	t0_2 <= 0;	t0_3 <= 0;
			end
		//always transpose update for "p" position
		else if (t0_transpose)
			case (one_edge_counter_MW)
				2'd0:begin	t0_0[7:0]   <= p3_MW;	t0_1[7:0]   <= p2_MW;
							t0_2[7:0]   <= p1_MW;	t0_3[7:0]   <= p0_MW;	end
				2'd1:begin	t0_0[15:8]  <= p3_MW;	t0_1[15:8]  <= p2_MW;
							t0_2[15:8]  <= p1_MW;	t0_3[15:8]  <= p0_MW;	end
				2'd2:begin	t0_0[23:16] <= p3_MW;	t0_1[23:16] <= p2_MW;
							t0_2[23:16] <= p1_MW;	t0_3[23:16] <= p0_MW;	end
				2'd3:begin	t0_0[31:24] <= p3_MW;	t0_1[31:24] <= p2_MW;
							t0_2[31:24] <= p1_MW;	t0_3[31:24] <= p0_MW;	end
			endcase
	//------------------------------------------------------
	//T1:always updated after transpose
	//------------------------------------------------------
	wire t1_transpose;		//t1 updated after   transpose
	wire t1_transpose_q;	//t1 transpose and t1 stores "q" position pixels
	assign t1_transpose = (
	DF_edge_counter_MW == 6'd13 || DF_edge_counter_MW == 6'd37 || DF_edge_counter_MW == 6'd45 || DF_edge_counter_MW == 6'd9  || 
	DF_edge_counter_MW == 6'd21 || DF_edge_counter_MW == 6'd25 || DF_edge_counter_MW == 6'd29 || DF_edge_counter_MW == 6'd31 || 
	DF_edge_counter_MW == 6'd39 || DF_edge_counter_MW == 6'd47);
	
	assign t1_transpose_q = (DF_edge_counter_MW == 6'd31 || DF_edge_counter_MW == 6'd39 || 
							 DF_edge_counter_MW == 6'd47);
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin 
				t1_0 <= 0;	t1_1 <= 0;	t1_2 <= 0;	t1_3 <= 0;
			end
		else if (t1_transpose && !t1_transpose_q)	//t1 transpose "p"
			case (one_edge_counter_MW)
				2'd0:begin	t1_0[7:0]   <= p3_MW;	t1_1[7:0]   <= p2_MW;
							t1_2[7:0]   <= p1_MW;	t1_3[7:0]   <= p0_MW;	end
				2'd1:begin	t1_0[15:8]  <= p3_MW;	t1_1[15:8]  <= p2_MW;
							t1_2[15:8]  <= p1_MW;	t1_3[15:8]  <= p0_MW;	end
				2'd2:begin	t1_0[23:16] <= p3_MW;	t1_1[23:16] <= p2_MW;
							t1_2[23:16] <= p1_MW;	t1_3[23:16] <= p0_MW;	end
				2'd3:begin	t1_0[31:24] <= p3_MW;	t1_1[31:24] <= p2_MW;
							t1_2[31:24] <= p1_MW;	t1_3[31:24] <= p0_MW;	end
			endcase
		else if (t1_transpose)						//t1 transpose "q"
			case (one_edge_counter_MW)
				2'd0:begin	t1_0[7:0]   <= q0_MW;	t1_1[7:0]   <= q1_MW;
							t1_2[7:0]   <= q2_MW;	t1_3[7:0]   <= q3_MW;	end
				2'd1:begin	t1_0[15:8]  <= q0_MW;	t1_1[15:8]  <= q1_MW;
							t1_2[15:8]  <= q2_MW;	t1_3[15:8]  <= q3_MW;	end
				2'd2:begin	t1_0[23:16] <= q0_MW;	t1_1[23:16] <= q1_MW;
							t1_2[23:16] <= q2_MW;	t1_3[23:16] <= q3_MW;	end
				2'd3:begin	t1_0[31:24] <= q0_MW;	t1_1[31:24] <= q1_MW;
							t1_2[31:24] <= q2_MW;	t1_3[31:24] <= q3_MW;	end
			endcase
	//--------------------------------------------------------------------
	//T2:only used after filter edge 18/34/42 to update mbAddrB of left MB
	//-------------------------------------------------------------------- 
	wire t2_wr;
	assign t2_wr = ((mb_num_h_DF != 0 && mb_num_v_DF != 4'd8) && 
	(DF_edge_counter_MW == 6'd18 || DF_edge_counter_MW == 6'd34 || DF_edge_counter_MW == 6'd42));
	always @ (posedge gclk_DF or negedge reset_n)
		if (reset_n == 1'b0)
			begin
				t2_0 <= 0;	t2_1 <= 0;	t2_2 <= 0;	t2_3 <= 0;
			end
		else if (t2_wr)
			case (one_edge_counter_MW)
				2'd0:begin	t2_0[7:0]   <= p3_MW;	t2_1[7:0]   <= p2_MW;
							t2_2[7:0]   <= p1_MW;	t2_3[7:0]   <= p0_MW;	end
				2'd1:begin	t2_0[15:8]  <= p3_MW;	t2_1[15:8]  <= p2_MW;
							t2_2[15:8]  <= p1_MW;	t2_3[15:8]  <= p0_MW;	end
				2'd2:begin	t2_0[23:16] <= p3_MW;	t2_1[23:16] <= p2_MW;
							t2_2[23:16] <= p1_MW;	t2_3[23:16] <= p0_MW;	end
				2'd3:begin	t2_0[31:24] <= p3_MW;	t2_1[31:24] <= p2_MW;
							t2_2[31:24] <= p1_MW;	t2_3[31:24] <= p0_MW;	end
			endcase
endmodule
		