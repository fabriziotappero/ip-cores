//
// spi.v -- SPI bus controller
//


module spi(clk, reset, spi_en,
           dac_sample_l, dac_sample_r, dac_next,
           spi_sck, spi_mosi,
           dac_cs_n, dac_clr_n,
           amp_cs_n, amp_shdn,
           ad_conv);
    // internal interface
    input clk;
    input reset;
    input spi_en;
    // DAC controller interface
    input [15:0] dac_sample_l;
    input [15:0] dac_sample_r;
    output dac_next;
    // external interface
    output spi_sck;
    output spi_mosi;
    output dac_cs_n;
    output dac_clr_n;
    output amp_cs_n;
    output amp_shdn;
    output ad_conv;

  //------------------------------------------------------------

  //
  // SPI timing and clock generator
  //

  reg [9:0] timing;

  always @(posedge clk) begin
    if (reset) begin
      timing <= 10'h0;
    end else begin
      if (spi_en == 1'b0 && timing == 10'h0) begin
        // put SPI on hold in state 0 if disabled
        timing <= timing;
      end else begin
        // else step through the command cycle
        timing <= timing + 1;
      end
    end
  end

  assign spi_sck = timing[0];

  //------------------------------------------------------------

  //
  // DAC controller
  //

  reg dac_ld;
  reg [47:0] dac_sr;
  wire dac_shift;

  assign dac_next = (timing[9:0] == 10'h001) ? 1 : 0;

  always @(posedge clk) begin
    if (reset) begin
      dac_ld <= 1'b1;
    end else begin
      if (timing[9:0] == 10'h001) begin
        dac_ld <= 1'b0;
      end
      if (timing[9:0] == 10'h031) begin
        dac_ld <= 1'b1;
      end
      if (timing[9:0] == 10'h033) begin
        dac_ld <= 1'b0;
      end
      if (timing[9:0] == 10'h063) begin
        dac_ld <= 1'b1;
      end
    end
  end

  assign dac_shift = spi_sck & ~dac_ld;

  always @(posedge clk) begin
    if (reset) begin
      dac_sr <= 48'h0;
    end else begin
      if (dac_next) begin
        dac_sr[47:44] <= 4'b0011;
        dac_sr[43:40] <= 4'b0000;
        dac_sr[39:24] <= { ~dac_sample_l[15],
                            dac_sample_l[14:0] };
        dac_sr[23:20] <= 4'b0011;
        dac_sr[19:16] <= 4'b0001;
        dac_sr[15: 0] <= { ~dac_sample_r[15],
                            dac_sample_r[14:0] };
      end else begin
        if (dac_shift) begin
          dac_sr[47:1] <= dac_sr[46:0];
          dac_sr[0] <= 1'b0;
        end
      end
    end
  end

  assign dac_cs_n = dac_ld;
  assign dac_clr_n = ~reset;

  //------------------------------------------------------------

  //
  // amplifier controller
  //

  assign amp_cs_n = 1;
  assign amp_shdn = reset;

  //------------------------------------------------------------

  //
  // ADC controller
  //

  assign ad_conv = 0;

  //------------------------------------------------------------

  //
  // SPI data output
  //

  assign spi_mosi = dac_sr[47];

endmodule
