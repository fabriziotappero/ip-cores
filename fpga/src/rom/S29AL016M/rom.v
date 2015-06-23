//
// rom.v -- parallel flash ROM interface
//


module rom(clk, reset,
           en, wr, size, addr,
           data_out, wt,
           ce_n, oe_n, we_n, rst_n, byte_n, a, d);
    // internal interface signals
    input clk;
    input reset;
    input en;
    input wr;
    input [1:0] size;
    input [20:0] addr;
    output reg [31:0] data_out;
    output reg wt;
    // flash ROM interface signals
    output ce_n;
    output oe_n;
    output we_n;
    output rst_n;
    output byte_n;
    output [19:0] a;
    input [15:0] d;

  reg [3:0] state;
  reg upper_half;

  // the following control signals are all
  // either constantly asserted or deasserted
  assign ce_n = 0;
  assign oe_n = 0;
  assign we_n = 1;
  assign rst_n = 1;
  assign byte_n = 1;

  // the flash ROM is organized in 16-bit halfwords
  // address line a[0] is controlled by the state machine
  // (this is necessary for word accesses)
  assign a[19:1] = addr[20:2];
  assign a[0] = upper_half;

  // the state machine
  always @(posedge clk) begin
    if (reset == 1) begin
      state <= 0;
      wt <= 1;
    end else begin
      if (state == 0) begin
        // wait for start of access
        if (en == 1 && wr == 0) begin
          state <= 1;
          if (size[1] == 1) begin
            // word access
            upper_half <= 0;
          end else begin
            // halfword or byte access
            upper_half <= addr[1];
          end
        end
      end else
      if (state == 6) begin
        if (size[1] == 1) begin
          // word access
          // latch upper halfword
          data_out[31:24] <= d[7:0];
          data_out[23:16] <= d[15:8];
          state <= 7;
          upper_half <= 1;
        end else begin
          // halfword or byte access
          data_out[31:16] <= 16'h0000;
          if (size[0] == 1) begin
            // halfword access
            data_out[15:8] <= d[7:0];
            data_out[7:0] <= d[15:8];
          end else begin
            // byte access
            data_out[15:8] <= 8'h00;
            if (addr[0] == 0) begin
              // even address
              data_out[7:0] <= d[7:0];
            end else begin
              // odd address
              data_out[7:0] <= d[15:8];
            end
          end
          state <= 13;
          wt <= 0;
        end
      end else
      if (state == 12) begin
        // word access (state is only reached in this case)
        // latch lower halfword
        data_out[15:8] <= d[7:0];
        data_out[7:0] <= d[15:8];
        state <= 13;
        wt <= 0;
      end else
      if (state == 13) begin
        // end of access
        wt <= 1;
        state <= 0;
      end else begin
        // wait for flash ROM access time to pass
        state <= state + 1;
      end
    end
  end

endmodule
