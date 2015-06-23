///////////////////////////////////////////////////////////////
// sha1_exec.v  version 0.1
//
// Core Data Path Model for SHA1 Hash Function
//  includes state machine model 
// 
// Described in Stalling, page 284
// (The variable names come from that section)
// 
// After start is raised, the output is available 81 cycles later
// The inputs are NOT latched but the outputs are.
// It is assumed that this module will be used with a wrapper
// probably providing HMAC.
//
// Paul Hartke, phartke@stanford.edu,  Copyright (c)2002
//
// The information and description contained herein is the
// property of Paul Hartke.
//
// Permission is granted for any reuse of this information
// and description as long as this copyright notice is
// preserved.  Modifications may be made as long as this
// notice is preserved.
// This code is made available "as is".  There is no warranty,
// so use it at your own risk.
// Documentation? "Use the source, Luke!"
///////////////////////////////////////////////////////////////

module sha1_exec(clk, reset, start, data_in, load_in, cv, 
  use_prev_cv, busy, out_valid, cv_next);
   
   input clk, reset;    // Global clock and synchronous reset
   
   input start;
   input [31:0] data_in;
   input load_in;
   input [159:0] cv;
   input use_prev_cv;
   output        busy;
   output        out_valid;
   output [159:0] cv_next;  
   
   reg            busy;        // Output control signals set
   reg            out_valid;   //   in FSM
   reg [6:0]      rnd_cnt_d;   // Counts the sha1 rounds.
   wire [6:0]     rnd_cnt_q;   //   -- 80 of them (perform 1 rnd/clk)
   wire [159:0]   rnd_d;       // round register for main pipeline
   wire [159:0]   rnd_q;
   wire [159:0]   sha1_round_wire;  // outputs of each round

   wire [159:0]   cv_d;        // Save msg input for addition
   wire [159:0]   cv_q;        //   in last cycle
   wire [159:0]   cv_next_d;   // Register the output.
   wire [159:0]   cv_next_q;
   
   // FSM states.. Not one hot since it is a small state machine...
   parameter      IDLE = 2'b00;
   parameter      CALC = 2'b01;
   parameter      VALID_OUT = 2'b10;
   parameter      VALID_OUT2 = 2'b11;
   wire [1:0]     state; 
   reg [1:0]      next_state;

   // The W round inputs are derived from the incoming message
   wire [511:0]   w_d;
   wire [511:0]   w_q;
   wire [511:0]   w_temp;
   wire [31:0]    w;    

   // Generate the W words for each round
   wire [31:0]    w_gen_temp = w_temp[511:480] ^ w_temp[447:416] ^ 
                  w_temp[255:224] ^ w_temp[95:64];  
   wire [31:0]    w_gen = {w_gen_temp[30:0], w_gen_temp[31]};
   
   // Select the incoming msg values or the computed ones
   assign         w_d = ((load_in == 1'b1) ? w_temp :
                  ((rnd_cnt_q < 7'd15) ? w_temp : 
                  {w_gen, w_temp[479:0]}));

   // Msg shift register.
   // Left Circular shift by 1 word 
   assign w_temp = (state == CALC) ? {w_q[479:0], w_q[511:480]} : 
     ((load_in == 1'b1) ? {w_q[479:0], data_in} : w_q);

   // W inputs come straight from a register output
   assign w = w_q[511:480];
   
   sha1_round sha1_round(.cv_in(rnd_q), .w(w), .round(rnd_cnt_q),
                           .cv_out(sha1_round_wire));

   // Accept the message input
   assign         rnd_d = ((state == CALC) ? sha1_round_wire : 
     (use_prev_cv == 1'b1) ? cv_next_q : cv);
   assign         cv_d = ((state == CALC) ? cv_q : 
     (use_prev_cv == 1'b1) ? cv_next_q : cv);

   // Calculate the final round...
   assign         cv_next_d = (state == VALID_OUT) ? 
                                ({cv_q[159:128] + rnd_q[159:128],
                                  cv_q[127:96] + rnd_q[127:96],
                                  cv_q[95:64] + rnd_q[95:64],
                                  cv_q[63:32] + rnd_q[63:32],
                                  cv_q[31:0] + rnd_q[31:0]}) :
                                  (cv_next_q);

   // Output the hash
   assign         cv_next = cv_next_q;

   // FSM start at IDLE from reset...
   // Only thing to note is that start going high restarts the state machine.
   always @(state or start or rnd_cnt_q)
     begin
        out_valid = 1'b0;       
        busy = 1'b0;
        rnd_cnt_d = 7'b0000000;
        case (state)
          IDLE : begin
             out_valid = 1'b0;
             rnd_cnt_d = 7'b0000000;
             if (start) begin
                busy = 1'b1;
                next_state = CALC;
             end
             else begin
                busy = 1'b1;
                next_state = IDLE;
             end
          end // case: IDLE
          
          CALC : begin
             busy = 1'b1;
             out_valid = 1'b0;
             if (start) begin
                next_state = IDLE;
                rnd_cnt_d = 7'd0000000;
             end
             else if (rnd_cnt_q == 7'd79) begin
                next_state = VALID_OUT;
                rnd_cnt_d = 7'd0000000;
             end
             else begin
                next_state = CALC;
                rnd_cnt_d = rnd_cnt_q + 7'd0000001;
             end
          end // case: CALC

          VALID_OUT : begin
             busy = 1'b1;
             out_valid = 1'b0;       
             // Allow cycle to latch output
             if (start) begin
                next_state = IDLE;
                rnd_cnt_d = 7'd0000000;
             end else begin
                next_state = VALID_OUT2;
             end
          end     

          VALID_OUT2 : begin
             busy = 1'b0;
             out_valid = 1'b1;
             if (start) begin
                next_state = CALC;
             end
             else begin
                next_state = IDLE;
             end
          end

          default : begin
             next_state = IDLE;
          end

        endcase
     end          
   
   // State Elements...
   dffhr #(7) rnd_cnt_reg (.d(rnd_cnt_d), .q(rnd_cnt_q),
                           .clk(clk), .r(reset));
   dffhr #(2) state_reg (.d(next_state), .q(state), 
                         .clk(clk), .r(reset)); 
   dffhr #(512) w_reg (.d(w_d), .q(w_q), .clk(clk), .r(reset));
   dffhr #(160) cv_reg (.d(cv_d), .q(cv_q), .clk(clk), .r(reset));
   dffhr #(160) rnd_reg (.d(rnd_d), .q(rnd_q), .clk(clk), .r(reset));
   dffhr #(160) cv_next_reg (.d(cv_next_d), .q(cv_next_q),
                             .clk(clk), .r(reset));   

endmodule // sha1_exec


