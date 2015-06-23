//
// rcv.v -- serial line receiver
//


module rcv(clk, reset, full, parallel_out, serial_in);
    input clk;
    input reset;
    output reg full;
    output [7:0] parallel_out;
    input serial_in;

  reg serial_p;
  reg serial_s;
  reg [3:0] state;
  reg [8:0] shift;
  reg [10:0] count;

  assign parallel_out[7:0] = shift[7:0];

  always @(posedge clk) begin
    serial_p <= serial_in;
    serial_s <= serial_p;
  end

  always @(posedge clk) begin
    if (reset == 1) begin
      state <= 4'h0;
      full <= 0;
    end else begin
      if (state == 4'h0) begin
        full <= 0;
        if (serial_s == 0) begin
          state <= 4'h1;
          count <= 651;
        end
      end else
      if (state == 4'hb) begin
        state <= 4'h0;
        full <= 1;
      end else begin
        if (count == 0) begin
          state <= state + 1;
          shift[8:0] <= { serial_s, shift[8:1] };
          count <= 1302;
        end else begin
          count <= count - 1;
        end
      end
    end
  end

endmodule
