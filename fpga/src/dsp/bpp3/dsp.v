//
// dsp.v -- character display interface
//


module dsp(clk, reset,
           addr, en, wr, wt,
           data_in, data_out,
           hsync, vsync,
           r, g, b);
    // internal interface
    input clk;
    input reset;
    input [13:2] addr;
    input en;
    input wr;
    output wt;
    input [15:0] data_in;
    output [15:0] data_out;
    // external interface
    output hsync;
    output vsync;
    output r;
    output g;
    output b;

  reg state;

  display display1(
    .clk(clk),
    .dsp_row(addr[13:9]),
    .dsp_col(addr[8:2]),
    .dsp_en(en),
    .dsp_wr(wr),
    .dsp_wr_data(data_in[15:0]),
    .dsp_rd_data(data_out[15:0]),
    .hsync(hsync),
    .vsync(vsync),
    .r(r),
    .g(g),
    .b(b)
  );

  always @(posedge clk) begin
    if (reset == 1) begin
      state <= 1'b0;
    end else begin
      case (state)
        1'b0:
          begin
            if (en == 1 && wr == 0) begin
              state <= 1'b1;
            end
          end
        1'b1:
          begin
            state <= 1'b0;
          end
      endcase
    end
  end

  assign wt = (en == 1 && wr == 0 && state == 1'b0) ? 1 : 0;

endmodule
