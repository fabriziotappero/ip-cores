//
// bio.v -- board specific I/O
//


module bio(clk, reset,
           en, wr, addr,
           data_in, data_out,
           wt, spi_en,
           sw, led,
           lcd_e, lcd_rw, lcd_rs,
           spi_ss_b, fpga_init_b);
    // internal interface
    input clk;
    input reset;
    input en;
    input wr;
    input addr;
    input [31:0] data_in;
    output [31:0] data_out;
    output wt;
    output spi_en;
    // external interface
    input [3:0] sw;
    output [7:0] led;
    output lcd_e;
    output lcd_rw;
    output lcd_rs;
    output spi_ss_b;
    output fpga_init_b;

  reg [31:0] bio_out;
  wire [31:0] bio_in;

  reg [3:0] sw_p;
  reg [3:0] sw_s;

  always @(posedge clk) begin
    if (reset) begin
      bio_out[31:0] <= 32'h0;
    end else begin
      if (en & wr & ~addr) begin
        bio_out[31:0] <= data_in[31:0];
      end
    end
  end

  assign data_out[31:0] =
    (addr == 0) ? bio_out[31:0] : bio_in[31:0];
  assign wt = 0;
  assign spi_en = bio_out[31];

  always @(posedge clk) begin
    sw_p[3:0] <= sw[3:0];
    sw_s[3:0] <= sw_p[3:0];
  end

  assign bio_in[31:0] = { 28'h0, sw_s[3:0] };

  assign led[7:0] = bio_out[7:0];

  // disable the character LCD screen
  // it may be enabled if spi_en = 1
  assign lcd_e = 0;
  assign lcd_rw = 0;
  assign lcd_rs = 0;

  // disable SPI serial and platform flash ROMs
  assign spi_ss_b = 1;
  assign fpga_init_b = 0;

endmodule
