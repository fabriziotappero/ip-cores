/*
 * Simply RISC M1 Divider
 *
 * Simple RTL-level divider with Alternating Bit Protocol (ABP) interface.
 */

// 32-bit / 32-bit Integer Divider (this version is not optimized and always takes 32 cycles)
module m1_div(
    input            sys_reset_i,      // System Reset
    input            sys_clock_i,      // System Clock
    input[31:0]      a_i,              // Operand A
    input[31:0]      b_i,              // Operand B
    input            signed_i,         // If division is signed
    output reg[31:0] quotient_o,       // Quotient of division
    output reg[31:0] remainder_o,      // Remainder of division
    input            abp_req_i,        // ABP Request
    output reg       abp_ack_o         // ABP Acknowledgement
  );

  // Registers
  reg[63:0]    a_latched;        // Latched 'a' input
  reg[63:0]    b_latched;        // Latched 'b' input
  reg[31:0]    quotient_tmp;     // Temporary result
  reg[31:0]    remainder_tmp;    // Temporary result
  reg          negative_output;  // If output is negative
  reg[5:0]     count;            // Downward counter (32->0)
  reg          abp_last;         // Level of last ABP request
  reg[63:0]    diff;             // Difference

  // Sequential logic
  always @(posedge sys_clock_i) begin

    // Initialization
    if(sys_reset_i) begin

      quotient_o = 0;
      remainder_o = 0;
      abp_ack_o = 0;
      negative_output = 0;
      count = 6'd0;
      abp_last = 0;

    // New request
    end else if(abp_req_i!=abp_last) begin

      abp_last = abp_req_i;     // Latch level of ABP request
      count  = 6'd32;           // Start counter
      quotient_tmp = 0;         // Initialize result
      remainder_tmp = 0;        // Initialize result
      a_latched = (!signed_i || !a_i[31]) ? { 32'd0, a_i } : { 32'd0, (~a_i + 1'b1) };
      b_latched = (!signed_i || !b_i[31]) ? { 1'b0, b_i, 31'd0 } : { 1'b0, ~b_i + 1'b1, 31'd0 };
      negative_output = signed_i && (a_i[31] ^ b_i[31]);
      quotient_o = (!negative_output) ? quotient_tmp : (~quotient_tmp+1);  // Debugging only
      remainder_o = (!negative_output) ? a_latched[31:0] : (~a_latched[31:0]+1);  // Debugging only
        
    // Calculating
    end else if(count>0) begin

      count = count-1;
      diff = a_latched-b_latched;
      quotient_tmp = quotient_tmp << 1;
      if(!diff[63]) begin
        a_latched = diff;
        quotient_tmp[0] = 1;
      end
      b_latched = b_latched >> 1;
      quotient_o = (!negative_output) ? quotient_tmp : (~quotient_tmp+1);  // Debugging only
      remainder_o = (!negative_output) ? a_latched[31:0] : (~a_latched[31:0]+1);  // Debugging only

    // Return the result
    end else if(count==0) begin

      abp_ack_o = abp_req_i;    // Return the result
      quotient_o = (!negative_output) ? quotient_tmp : (~quotient_tmp+1);
      remainder_o = (!negative_output) ? a_latched[31:0] : (~a_latched[31:0]+1);

    end

  end

endmodule

