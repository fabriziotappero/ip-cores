///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2005 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
// Modified for HPDMC simulation, based on Xilinx 05/29/07 revision
///////////////////////////////////////////////////////////////////////////////

module ODDR #(
	parameter DDR_CLK_EDGE = "OPPOSITE_EDGE",
	parameter INIT = 1'b0,
	parameter SRTYPE = "SYNC"
) (
	output Q,
	input C,
	input CE,
	input D1,
	input D2,
	input R,
	input S
);

reg q_out = INIT, qd2_posedge_int;

wire c_in;
wire ce_in;
wire d1_in;
wire d2_in;
wire gsr_in;
wire r_in;
wire s_in;

buf buf_c(c_in, C);
buf buf_ce(ce_in, CE);
buf buf_d1(d1_in, D1);
buf buf_d2(d2_in, D2);
buf buf_q(Q, q_out);
buf buf_r(r_in, R);
buf buf_s(s_in, S); 

initial begin
	if((INIT != 0) && (INIT != 1)) begin
		$display("Attribute Syntax Error : The attribute INIT on ODDR instance %m is set to %d.  Legal values for this attribute are 0 or 1.", INIT);
		$finish;
	end

	if((DDR_CLK_EDGE != "OPPOSITE_EDGE") && (DDR_CLK_EDGE != "SAME_EDGE")) begin
		$display("Attribute Syntax Error : The attribute DDR_CLK_EDGE on ODDR instance %m is set to %s.  Legal values for this attribute are OPPOSITE_EDGE or SAME_EDGE.", DDR_CLK_EDGE);
		$finish;
	end

	if((SRTYPE != "ASYNC") && (SRTYPE != "SYNC")) begin
		$display("Attribute Syntax Error : The attribute SRTYPE on ODDR instance %m is set to %s.  Legal values for this attribute are ASYNC or SYNC.", SRTYPE);
		$finish;
	end
end

always @(r_in, s_in) begin
	if(r_in == 1'b1 && SRTYPE == "ASYNC") begin
		assign q_out = 1'b0;
		assign qd2_posedge_int = 1'b0;
	end else if(r_in == 1'b0 && s_in == 1'b1 && SRTYPE == "ASYNC") begin
		assign q_out = 1'b1;
		assign qd2_posedge_int = 1'b1;
	end else if((r_in == 1'b1 || s_in == 1'b1) && SRTYPE == "SYNC") begin
		deassign q_out;
		deassign qd2_posedge_int;
	end else if(r_in == 1'b0 && s_in == 1'b0) begin
		deassign q_out;
		deassign qd2_posedge_int;
	end
end

always @(posedge c_in) begin
	if(r_in == 1'b1) begin
		q_out <= 1'b0;
		qd2_posedge_int <= 1'b0;
	end else if(r_in == 1'b0 && s_in == 1'b1) begin
		q_out <= 1'b1;
		qd2_posedge_int <= 1'b1;
	end else if(ce_in == 1'b1 && r_in == 1'b0 && s_in == 1'b0) begin
		q_out <= d1_in;
		qd2_posedge_int <= d2_in;
	end
end

always @(negedge c_in) begin
	if(r_in == 1'b1)
		q_out <= 1'b0;
	else if(r_in == 1'b0 && s_in == 1'b1)
		q_out <= 1'b1;
	else if(ce_in == 1'b1 && r_in == 1'b0 && s_in == 1'b0) begin
		if(DDR_CLK_EDGE == "SAME_EDGE")
			q_out <= qd2_posedge_int;
		else if(DDR_CLK_EDGE == "OPPOSITE_EDGE")
			q_out <= d2_in;
	end
end

endmodule
