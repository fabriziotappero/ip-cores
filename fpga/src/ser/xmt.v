//
// xmt.v -- serial line transmitter
//


module xmt(clk, reset, load, empty, parallel_in, serial_out);
    input clk;
    input reset;
    input load;
    output reg empty;
    input [7:0] parallel_in;
    output serial_out;

  reg [3:0] state;
  reg [8:0] shift;
  reg [10:0] count;

  assign serial_out = shift[0];

  always @(posedge clk) begin
    if (reset == 1) begin
      state <= 4'h0;
      shift <= 9'b111111111;
      empty <= 1;
    end else begin
      if (state == 4'h0) begin
        if (load == 1) begin
          state <= 4'h1;
          shift <= { parallel_in, 1'b0 };
          count <= 1302;
          empty <= 0;
        end
      end else
      if (state == 4'hb) begin
        state <= 4'h0;
        empty <= 1;
      end else begin
        if (count == 0) begin
          state <= state + 1;
          shift[8:0] <= { 1'b1, shift[8:1] };
          count <= 1302;
        end else begin
          count <= count - 1;
        end
      end
    end
  end

endmodule
