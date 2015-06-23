//
// dac.v -- DAC control circuit
//


module dac(clk, reset,
           sample_l, sample_r, next,
           mclk, sclk, lrck, sdti);
    input clk;
    input reset;
    input [15:0] sample_l;
    input [15:0] sample_r;
    output next;
    output mclk;
    output sclk;
    output lrck;
    output sdti;

  reg [9:0] timing;
  reg [63:0] sr;
  wire shift;

  always @(posedge clk) begin
    if (reset) begin
      timing <= 10'h0;
    end else begin
      timing <= timing + 1;
    end
  end

  assign mclk = timing[1];
  assign sclk = timing[3];
  assign lrck = timing[9];

  assign next = (timing[9:0] == 10'h1FF) ? 1 : 0;
  assign shift = (timing[3:0] == 4'hF) ? 1 : 0;

  always @(posedge clk) begin
    if (reset) begin
      sr <= 64'h0;
    end else begin
      if (next) begin
        sr[63:52] <= 12'h000;
        sr[51:32] <= { sample_l[15:0], 4'h0 };
        sr[31:20] <= 12'h000;
        sr[19: 0] <= { sample_r[15:0], 4'h0 };
      end else begin
        if (shift) begin
          sr[63:1] <= sr[62:0];
          sr[0] <= 1'b0;
        end
      end
    end
  end

  assign sdti = sr[63];

endmodule
