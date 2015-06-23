///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////

// Modified for HPDMC simulation, based on Xilinx 01/12/09 revision
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module ODDR2 (Q, C0, C1, CE, D0, D1, R, S);
    
    output Q;

    input C0;
    input C1;
    input CE;
    input D0;
    input D1;

    input R;
    input S;

    parameter DDR_ALIGNMENT = "NONE";    
    parameter INIT = 1'b0;
    parameter SRTYPE = "SYNC";

    pullup   P1 (CE);
    pulldown P2 (R);
    pulldown P3 (S);

    reg q_out, q_d1_c0_out_int; 
    wire PC0, PC1;    
    
    buf buf_q (Q, q_out);


    initial begin

	if ((INIT != 1'b0) && (INIT != 1'b1)) begin
	    $display("Attribute Syntax Error : The attribute INIT on ODDR2 instance %m is set to %d.  Legal values for this attribute are 0 or 1.", INIT);
	    $finish;
	end
	
    	if ((DDR_ALIGNMENT != "NONE") && (DDR_ALIGNMENT != "C0") && (DDR_ALIGNMENT != "C1")) begin
	    $display("Attribute Syntax Error : The attribute DDR_ALIGNMENT on ODDR2 instance %m is set to %s.  Legal values for this attribute are NONE, C0 or C1.", DDR_ALIGNMENT);
	    $finish;
	end
	
	if ((SRTYPE != "ASYNC") && (SRTYPE != "SYNC")) begin
	    $display("Attribute Syntax Error : The attribute SRTYPE on ODDR2 instance %m is set to %s.  Legal values for this attribute are ASYNC or SYNC.", SRTYPE);
	    $finish;
	end

    end // initial begin

    initial begin
        assign q_out = INIT;
        assign q_d1_c0_out_int = INIT;
    end

    always @(R or S) begin

	    deassign q_out;
	    deassign q_d1_c0_out_int;
	    
	    if (SRTYPE == "ASYNC") begin
		if (R == 1) begin
		    assign q_out = 0;
		    assign q_d1_c0_out_int = 0;
		end
		else if (R == 0 && S == 1) begin
		    assign q_out = 1;
		    assign q_d1_c0_out_int = 1;
		end
	    end // if (SRTYPE == "ASYNC")
	
    end // always @ (GSR or R or S)

    assign PC0 = ((DDR_ALIGNMENT== "C0") || (DDR_ALIGNMENT== "NONE"))?  C0 : C1;
    assign PC1 = ((DDR_ALIGNMENT== "C0") || (DDR_ALIGNMENT== "NONE"))?  C1 : C0;

    always @(posedge PC0) begin
	
 	if (R == 1 && SRTYPE == "SYNC") begin
	    q_out <= 0;
	    q_d1_c0_out_int <= 0;
	end
	else if (R == 0 && S == 1 && SRTYPE == "SYNC") begin
	    q_out <= 1;
	    q_d1_c0_out_int <= 1;
	end
	else if (CE == 1 && R == 0 && S == 0) begin
		q_out <= D0;
	        q_d1_c0_out_int <= D1 ;
	end // if (CE == 1 && R == 0 && S == 0)
	
    end // always @ (posedge C0)
    
    
    always @(posedge PC1) begin
	
	if (R == 1 && SRTYPE == "SYNC") begin
	    q_out <= 0;
	end
	else if (R == 0 && S == 1 && SRTYPE == "SYNC") begin
	    q_out <= 1;
	    end
	else if (CE == 1 && R == 0 && S == 0) begin
	    
	    if (DDR_ALIGNMENT == "NONE")
		q_out <= D1;
	    else  
		q_out <= q_d1_c0_out_int;
		
	    
	end // if (CE == 1 && R == 0 && S == 0)
	
    end // always @ (negedge c_in)
    
    
    specify

	if (C0) (C0 => Q) = (100, 100);
	if (C1) (C1 => Q) = (100, 100);
	specparam PATHPULSE$ = 0;

    endspecify

endmodule // ODDR2

