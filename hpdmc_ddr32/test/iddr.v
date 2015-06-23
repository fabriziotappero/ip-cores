///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
// Modified for HPDMC simulation, based on Xilinx 05/29/07 revision
///////////////////////////////////////////////////////////////////////////////


module IDDR #(
	parameter DDR_CLK_EDGE = "OPPOSITE_EDGE",
	parameter INIT_Q1 = 1'b0,
	parameter INIT_Q2 = 1'b0,
	parameter SRTYPE = "SYNC"
) (
	output Q1,
	output Q2,
	input C,
	input CE,
	input D,
	input R,
	input S
);

reg q1_out = INIT_Q1, q2_out = INIT_Q2;
reg q1_out_int, q2_out_int;
reg q1_out_pipelined, q2_out_same_edge_int;

wire c_in;
wire ce_in;
wire d_in;
wire gsr_in;
wire r_in;
wire s_in;

buf buf_c(c_in, C);
buf buf_ce(ce_in, CE);
buf buf_d(d_in, D);
buf buf_q1(Q1, q1_out);
buf buf_q2(Q2, q2_out);
buf buf_r(r_in, R);
buf buf_s(s_in, S);

initial begin
	if((INIT_Q1 != 0) && (INIT_Q1 != 1)) begin
		$display("Attribute Syntax Error : The attribute INIT_Q1 on IDDR instance %m is set to %d.  Legal values for this attribute are 0 or 1.", INIT_Q1);
		$finish;
	end
	
	if((INIT_Q2 != 0) && (INIT_Q2 != 1)) begin
		$display("Attribute Syntax Error : The attribute INIT_Q1 on IDDR instance %m is set to %d.  Legal values for this attribute are 0 or 1.", INIT_Q2);
		$finish;
	end
	
	if((DDR_CLK_EDGE != "OPPOSITE_EDGE") && (DDR_CLK_EDGE != "SAME_EDGE") && (DDR_CLK_EDGE != "SAME_EDGE_PIPELINED")) begin
		$display("Attribute Syntax Error : The attribute DDR_CLK_EDGE on IDDR instance %m is set to %s.  Legal values for this attribute are OPPOSITE_EDGE, SAME_EDGE or SAME_EDGE_PIPELINED.", DDR_CLK_EDGE);
		$finish;
	end
	
	if((SRTYPE != "ASYNC") && (SRTYPE != "SYNC")) begin
		$display("Attribute Syntax Error : The attribute SRTYPE on IDDR instance %m is set to %s.  Legal values for this attribute are ASYNC or SYNC.", SRTYPE);
		$finish;
	end
end

always @(r_in, s_in) begin
	if(r_in == 1'b1 && SRTYPE == "ASYNC") begin
		assign q1_out_int = 1'b0;
		assign q1_out_pipelined = 1'b0;
		assign q2_out_same_edge_int = 1'b0;
		assign q2_out_int = 1'b0;
	end else if(r_in == 1'b0 && s_in == 1'b1 && SRTYPE == "ASYNC") begin
		assign q1_out_int = 1'b1;
		assign q1_out_pipelined = 1'b1;
		assign q2_out_same_edge_int = 1'b1;
		assign q2_out_int = 1'b1;
	end else if((r_in == 1'b1 || s_in == 1'b1) && SRTYPE == "SYNC") begin
		deassign q1_out_int;
		deassign q1_out_pipelined;
		deassign q2_out_same_edge_int;
		deassign q2_out_int;
	end else if(r_in == 1'b0 && s_in == 1'b0) begin
		deassign q1_out_int;
		deassign q1_out_pipelined;
		deassign q2_out_same_edge_int;
		deassign q2_out_int;
	end
end

always @(posedge c_in) begin
	if(r_in == 1'b1) begin
		q1_out_int <= 1'b0;
		q1_out_pipelined <= 1'b0;
		q2_out_same_edge_int <= 1'b0;
	end else if(r_in == 1'b0 && s_in == 1'b1) begin
		q1_out_int <= 1'b1;
		q1_out_pipelined <= 1'b1;
		q2_out_same_edge_int <= 1'b1;
	end else if(ce_in == 1'b1 && r_in == 1'b0 && s_in == 1'b0) begin
		q1_out_int <= d_in;
		q1_out_pipelined <= q1_out_int;
		q2_out_same_edge_int <= q2_out_int;
	end
end

always @(negedge c_in) begin
	if(r_in == 1'b1)
		q2_out_int <= 1'b0;
	else if(r_in == 1'b0 && s_in == 1'b1)
		q2_out_int <= 1'b1;
	else if(ce_in == 1'b1 && r_in == 1'b0 && s_in == 1'b0)
		q2_out_int <= d_in;
end

always @(c_in, q1_out_int, q2_out_int, q2_out_same_edge_int, q1_out_pipelined) begin
	case(DDR_CLK_EDGE)
		"OPPOSITE_EDGE" : begin
			q1_out <= q1_out_int;
			q2_out <= q2_out_int;
		end
		"SAME_EDGE" : begin
			q1_out <= q1_out_int;
			q2_out <= q2_out_same_edge_int;
		end
		"SAME_EDGE_PIPELINED" : begin
			q1_out <= q1_out_pipelined;
			q2_out <= q2_out_same_edge_int;
		end
		default: begin
			$display("Attribute Syntax Error : The attribute DDR_CLK_EDGE on IDDR instance %m is set to %s.  Legal values for this attribute are OPPOSITE_EDGE, SAME_EDGE or SAME_EDGE_PIPELINED.", DDR_CLK_EDGE);
			$finish;
		end
	endcase
end

endmodule
