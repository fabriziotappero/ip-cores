// $Header: /home/marcus/revision_ctrl_test/oc_cvs/cvs/m1_core/hdl/behav/xilinx_unisim/FDDRRSE.v,v 1.1 2008-11-07 13:12:06 fafa1971 Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.27)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Dual Data Rate D Flip-Flop with Synchronous Reset and Set and Clock Enable
// /___/   /\     Filename : FDDRRSE.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:16 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/04/05 - Rev 0.0.1 Remove input/output bufs; Seperate GSR from clock block.
//    05/06/05 - Remove internal input data strobe and add to the output. (CR207678)
//    10/20/05 - Add set & reset check to main  block. (CR219794)
//    10/28/05 - combine strobe block and data block. (CR220298).
//    2/07/06 - Remove set & reset from main block and add specify block (CR225119)
//    2/10/06 - Change Q from reg to wire (CR 225613)
// End Revision

`timescale  1 ps / 1 ps


module FDDRRSE (Q, C0, C1, CE, D0, D1, R, S);

    parameter INIT = 1'h0;

    output Q;

    input  C0, C1, CE, D0, D1, R, S;

    wire Q;
    reg q_out;

    reg q0_out, q1_out;
    reg C0_tmp, C1_tmp;

    initial begin
       q_out = INIT;
       q0_out = INIT;
       q1_out = INIT;
       C0_tmp = 0;
       C1_tmp = 0;
    end

    assign Q = q_out;

    always @(posedge C0) 
      if (CE == 1 || R == 1 || S == 1) begin
      C0_tmp <=  1;
      C0_tmp <= #100 0;
    end

    always @(posedge C1) 
     if (CE == 1 || R == 1 || S == 1) begin
      C1_tmp <=  1;
      C1_tmp <= #100 0;
    end

        always @(posedge C0) 
            if (R)
                q0_out <=  0;
            else if (S)
                q0_out <=  1;
            else if (CE)
                q0_out <= D0;

        always @(posedge C1)
            if (R)
                q1_out <=  0;
            else if (S)
                q1_out <=  1;
            else if (CE)
                q1_out <=  D1;

       always @(posedge C0_tmp or posedge C1_tmp )
            if (C1_tmp)
               q_out =  q1_out;
            else 
               q_out =  q0_out;

    specify
        if (R)
            (posedge C0 => (Q +: 1'b0)) = (100, 100);
        if (!R && S)
            (posedge C0 => (Q +: 1'b1)) = (100, 100);
        if (!R && !S && CE)
            (posedge C0 => (Q +: D0)) = (100, 100);
        if (R)
            (posedge C1 => (Q +: 1'b0)) = (100, 100);
        if (!R && S)
            (posedge C1 => (Q +: 1'b1)) = (100, 100);
        if (!R && !S && CE)
            (posedge C1 => (Q +: D1)) = (100, 100);
    endspecify

endmodule
