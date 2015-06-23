//
// rcvbuf.v -- serial line receiver buffer
//


module rcvbuf(clk, reset, read, ready, data_out, serial_in);
    input clk;
    input reset;
    input read;
    output reg ready;
    output reg [7:0] data_out;
    input serial_in;

  wire full;
  wire [7:0] parallel_out;

  rcv rcv1(clk, reset, full, parallel_out, serial_in);

  always @(posedge clk) begin
    if (reset == 1) begin
      ready <= 0;
    end else begin
      if (full == 1) begin
        data_out <= parallel_out;
      end
      if (full == 1 || read == 1) begin
        ready <= full;
      end
    end
  end

endmodule
