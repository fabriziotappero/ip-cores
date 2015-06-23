//
// dac.v -- DAC control circuit
//

`timescale 1ns/1ns

module dac(clk, reset,
           sample_l, sample_r, next,
           sck, sdi, ld);
    input clk;
    input reset;
    input [15:0] sample_l;
    input [15:0] sample_r;
    output next;
    output sck;
    output sdi;
    output reg ld;

  reg [9:0] timing;
  reg [47:0] sr;
  wire shift;

  always @(posedge clk) begin
    if (reset) begin
      timing <= 10'h0;
    end else begin
      timing <= timing + 1;
    end
  end

  assign sck = timing[0];
  assign next = (timing[9:0] == 10'h001) ? 1 : 0;

  always @(posedge clk) begin
    if (reset) begin
      ld <= 1'b1;
    end else begin
      if (timing[9:0] == 10'h001) begin
        ld <= 1'b0;
      end
      if (timing[9:0] == 10'h031) begin
        ld <= 1'b1;
      end
      if (timing[9:0] == 10'h033) begin
        ld <= 1'b0;
      end
      if (timing[9:0] == 10'h063) begin
        ld <= 1'b1;
      end
    end
  end

  assign shift = sck & ~ld;

  always @(posedge clk) begin
    if (reset) begin
      sr <= 48'h0;
    end else begin
      if (next) begin
        sr[47:44] <= 4'b0011;
        sr[43:40] <= 4'b0000;
        sr[39:24] <= { ~sample_l[15],
                        sample_l[14:0] };
        sr[23:20] <= 4'b0011;
        sr[19:16] <= 4'b0001;
        sr[15: 0] <= { ~sample_r[15],
                        sample_r[14:0] };
      end else begin
        if (shift) begin
          sr[47:1] <= sr[46:0];
          sr[0] <= 1'b0;
        end
      end
    end
  end

  assign sdi = sr[47];

endmodule
