//
// xmtbuf.v -- serial line transmitter buffer
//


module xmtbuf(clk, reset, write, ready, data_in, serial_out);
    input clk;
    input reset;
    input write;
    output reg ready;
    input [7:0] data_in;
    output serial_out;

  reg [1:0] state;
  reg [7:0] data_hold;
  reg load;
  wire empty;

  xmt xmt1(clk, reset, load, empty, data_hold, serial_out);

  always @(posedge clk) begin
    if (reset == 1) begin
      state <= 2'b00;
      ready <= 1;
      load <= 0;
    end else begin
      case (state)
        2'b00:
          begin
            if (write == 1) begin
              state <= 2'b01;
              data_hold <= data_in;
              ready <= 0;
              load <= 1;
            end
          end
        2'b01:
          begin
            state <= 2'b10;
            ready <= 1;
            load <= 0;
          end
        2'b10:
          begin
            if (empty == 1 && write == 0) begin
              state <= 2'b00;
              ready <= 1;
              load <= 0;
            end else
            if (empty == 1 && write == 1) begin
              state <= 2'b01;
              data_hold <= data_in;
              ready <= 0;
              load <= 1;
            end else
            if (empty == 0 && write == 1) begin
              state <= 2'b11;
              data_hold <= data_in;
              ready <= 0;
              load <= 0;
            end
          end
        2'b11:
          begin
            if (empty == 1) begin
              state <= 2'b01;
              ready <= 0;
              load <= 1;
            end
          end
      endcase
    end
  end

endmodule
