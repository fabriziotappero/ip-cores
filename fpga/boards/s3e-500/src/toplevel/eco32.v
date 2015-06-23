//
// eco32.v -- ECO32 top-level description
//


module eco32(clk_in,
             reset_in,
             sdram_ck_p,
             sdram_ck_n,
             sdram_cke,
             sdram_cs_n,
             sdram_ras_n,
             sdram_cas_n,
             sdram_we_n,
             sdram_ba,
             sdram_a,
             sdram_udm,
             sdram_ldm,
             sdram_udqs,
             sdram_ldqs,
             sdram_dq,
             flash_ce_n,
             flash_oe_n,
             flash_we_n,
             flash_byte_n,
             flash_a,
             flash_d,
             vga_hsync,
             vga_vsync,
             vga_r,
             vga_g,
             vga_b,
             ps2_clk,
             ps2_data,
             rs232_0_rxd,
             rs232_0_txd,
             rs232_1_rxd,
             rs232_1_txd,
             spi_sck,
             spi_mosi,
             dac_cs_n,
             dac_clr_n,
             amp_cs_n,
             amp_shdn,
             ad_conv,
             sw,
             led,
             lcd_e,
             lcd_rw,
             lcd_rs,
             spi_ss_b,
             fpga_init_b);
    // clock and reset
    input clk_in;
    input reset_in;
    // SDRAM
    output sdram_ck_p;
    output sdram_ck_n;
    output sdram_cke;
    output sdram_cs_n;
    output sdram_ras_n;
    output sdram_cas_n;
    output sdram_we_n;
    output [1:0] sdram_ba;
    output [12:0] sdram_a;
    output sdram_udm;
    output sdram_ldm;
    inout sdram_udqs;
    inout sdram_ldqs;
    inout [15:0] sdram_dq;
    // flash ROM
    output flash_ce_n;
    output flash_oe_n;
    output flash_we_n;
    output flash_byte_n;
    output [23:0] flash_a;
    input [15:0] flash_d;
    // VGA display
    output vga_hsync;
    output vga_vsync;
    output vga_r;
    output vga_g;
    output vga_b;
    // keyboard
    input ps2_clk;
    input ps2_data;
    // serial line 0
    input rs232_0_rxd;
    output rs232_0_txd;
    // serial line 1
    input rs232_1_rxd;
    output rs232_1_txd;
    // SPI bus controller
    output spi_sck;
    output spi_mosi;
    output dac_cs_n;
    output dac_clr_n;
    output amp_cs_n;
    output amp_shdn;
    output ad_conv;
    // board I/O
    input [3:0] sw;
    output [7:0] led;
    output lcd_e;
    output lcd_rw;
    output lcd_rs;
    output spi_ss_b;
    output fpga_init_b;

  // clk_rst
  wire ddr_clk_0;
  wire ddr_clk_90;
  wire ddr_clk_180;
  wire ddr_clk_270;
  wire ddr_clk_ok;
  wire clk;
  wire reset;
  // cpu
  wire cpu_en;
  wire cpu_wr;
  wire [1:0] cpu_size;
  wire [31:0] cpu_addr;
  wire [31:0] cpu_data_in;
  wire [31:0] cpu_data_out;
  wire cpu_wt;
  wire [15:0] cpu_irq;
  // ram
  wire ram_en;
  wire ram_wr;
  wire [1:0] ram_size;
  wire [25:0] ram_addr;
  wire [31:0] ram_data_in;
  wire [31:0] ram_data_out;
  wire ram_wt;
  // rom
  wire rom_en;
  wire rom_wr;
  wire [1:0] rom_size;
  wire [23:0] rom_addr;
  wire [31:0] rom_data_out;
  wire rom_wt;
  // tmr0
  wire tmr0_en;
  wire tmr0_wr;
  wire [3:2] tmr0_addr;
  wire [31:0] tmr0_data_in;
  wire [31:0] tmr0_data_out;
  wire tmr0_wt;
  wire tmr0_irq;
  // tmr1
  wire tmr1_en;
  wire tmr1_wr;
  wire [3:2] tmr1_addr;
  wire [31:0] tmr1_data_in;
  wire [31:0] tmr1_data_out;
  wire tmr1_wt;
  wire tmr1_irq;
  // dsp
  wire dsp_en;
  wire dsp_wr;
  wire [13:2] dsp_addr;
  wire [15:0] dsp_data_in;
  wire [15:0] dsp_data_out;
  wire dsp_wt;
  // kbd
  wire kbd_en;
  wire kbd_wr;
  wire kbd_addr;
  wire [7:0] kbd_data_in;
  wire [7:0] kbd_data_out;
  wire kbd_wt;
  wire kbd_irq;
  // ser0
  wire ser0_en;
  wire ser0_wr;
  wire [3:2] ser0_addr;
  wire [7:0] ser0_data_in;
  wire [7:0] ser0_data_out;
  wire ser0_wt;
  wire ser0_irq_r;
  wire ser0_irq_t;
  // ser1
  wire ser1_en;
  wire ser1_wr;
  wire [3:2] ser1_addr;
  wire [7:0] ser1_data_in;
  wire [7:0] ser1_data_out;
  wire ser1_wt;
  wire ser1_irq_r;
  wire ser1_irq_t;
  // fms
  wire fms_en;
  wire fms_wr;
  wire [11:2] fms_addr;
  wire [31:0] fms_data_in;
  wire [31:0] fms_data_out;
  wire fms_wt;
  // spi
  wire [15:0] dac_sample_l;
  wire [15:0] dac_sample_r;
  wire dac_next;
  // bio
  wire bio_en;
  wire bio_wr;
  wire bio_addr;
  wire [31:0] bio_data_in;
  wire [31:0] bio_data_out;
  wire bio_wt;
  wire spi_en;

  clk_rst clk_rst1(
    .clk_in(clk_in),
    .reset_in(reset_in),
    .ddr_clk_0(ddr_clk_0),
    .ddr_clk_90(ddr_clk_90),
    .ddr_clk_180(ddr_clk_180),
    .ddr_clk_270(ddr_clk_270),
    .ddr_clk_ok(ddr_clk_ok),
    .clk(clk),
    .reset(reset)
  );

  busctrl busctrl1(
    // cpu
    .cpu_en(cpu_en),
    .cpu_wr(cpu_wr),
    .cpu_size(cpu_size[1:0]),
    .cpu_addr(cpu_addr[31:0]),
    .cpu_data_in(cpu_data_in[31:0]),
    .cpu_data_out(cpu_data_out[31:0]),
    .cpu_wt(cpu_wt),
    // ram
    .ram_en(ram_en),
    .ram_wr(ram_wr),
    .ram_size(ram_size[1:0]),
    .ram_addr(ram_addr[25:0]),
    .ram_data_in(ram_data_in[31:0]),
    .ram_data_out(ram_data_out[31:0]),
    .ram_wt(ram_wt),
    // rom
    .rom_en(rom_en),
    .rom_wr(rom_wr),
    .rom_size(rom_size[1:0]),
    .rom_addr(rom_addr[23:0]),
    .rom_data_out(rom_data_out[31:0]),
    .rom_wt(rom_wt),
    // tmr0
    .tmr0_en(tmr0_en),
    .tmr0_wr(tmr0_wr),
    .tmr0_addr(tmr0_addr[3:2]),
    .tmr0_data_in(tmr0_data_in[31:0]),
    .tmr0_data_out(tmr0_data_out[31:0]),
    .tmr0_wt(tmr0_wt),
    // tmr1
    .tmr1_en(tmr1_en),
    .tmr1_wr(tmr1_wr),
    .tmr1_addr(tmr1_addr[3:2]),
    .tmr1_data_in(tmr1_data_in[31:0]),
    .tmr1_data_out(tmr1_data_out[31:0]),
    .tmr1_wt(tmr1_wt),
    // dsp
    .dsp_en(dsp_en),
    .dsp_wr(dsp_wr),
    .dsp_addr(dsp_addr[13:2]),
    .dsp_data_in(dsp_data_in[15:0]),
    .dsp_data_out(dsp_data_out[15:0]),
    .dsp_wt(dsp_wt),
    // kbd
    .kbd_en(kbd_en),
    .kbd_wr(kbd_wr),
    .kbd_addr(kbd_addr),
    .kbd_data_in(kbd_data_in[7:0]),
    .kbd_data_out(kbd_data_out[7:0]),
    .kbd_wt(kbd_wt),
    // ser0
    .ser0_en(ser0_en),
    .ser0_wr(ser0_wr),
    .ser0_addr(ser0_addr[3:2]),
    .ser0_data_in(ser0_data_in[7:0]),
    .ser0_data_out(ser0_data_out[7:0]),
    .ser0_wt(ser0_wt),
    // ser1
    .ser1_en(ser1_en),
    .ser1_wr(ser1_wr),
    .ser1_addr(ser1_addr[3:2]),
    .ser1_data_in(ser1_data_in[7:0]),
    .ser1_data_out(ser1_data_out[7:0]),
    .ser1_wt(ser1_wt),
    // fms
    .fms_en(fms_en),
    .fms_wr(fms_wr),
    .fms_addr(fms_addr[11:2]),
    .fms_data_in(fms_data_in[31:0]),
    .fms_data_out(fms_data_out[31:0]),
    .fms_wt(fms_wt),
    // bio
    .bio_en(bio_en),
    .bio_wr(bio_wr),
    .bio_addr(bio_addr),
    .bio_data_in(bio_data_in[31:0]),
    .bio_data_out(bio_data_out[31:0]),
    .bio_wt(bio_wt)
  );

  cpu cpu1(
    .clk(clk),
    .reset(reset),
    .bus_en(cpu_en),
    .bus_wr(cpu_wr),
    .bus_size(cpu_size[1:0]),
    .bus_addr(cpu_addr[31:0]),
    .bus_data_in(cpu_data_in[31:0]),
    .bus_data_out(cpu_data_out[31:0]),
    .bus_wt(cpu_wt),
    .irq(cpu_irq[15:0])
  );

  assign cpu_irq[15] = tmr1_irq;
  assign cpu_irq[14] = tmr0_irq;
  assign cpu_irq[13] = 1'b0;
  assign cpu_irq[12] = 1'b0;
  assign cpu_irq[11] = 1'b0;
  assign cpu_irq[10] = 1'b0;
  assign cpu_irq[ 9] = 1'b0;
  assign cpu_irq[ 8] = 1'b0;  //dsk_irq;
  assign cpu_irq[ 7] = 1'b0;
  assign cpu_irq[ 6] = 1'b0;
  assign cpu_irq[ 5] = 1'b0;
  assign cpu_irq[ 4] = kbd_irq;
  assign cpu_irq[ 3] = ser1_irq_r;
  assign cpu_irq[ 2] = ser1_irq_t;
  assign cpu_irq[ 1] = ser0_irq_r;
  assign cpu_irq[ 0] = ser0_irq_t;

  ram ram1(
    .ddr_clk_0(ddr_clk_0),
    .ddr_clk_90(ddr_clk_90),
    .ddr_clk_180(ddr_clk_180),
    .ddr_clk_270(ddr_clk_270),
    .ddr_clk_ok(ddr_clk_ok),
    .clk(clk),
    .reset(reset),
    .en(ram_en),
    .wr(ram_wr),
    .size(ram_size[1:0]),
    .addr(ram_addr[25:0]),
    .data_in(ram_data_in[31:0]),
    .data_out(ram_data_out[31:0]),
    .wt(ram_wt),
    .sdram_ck_p(sdram_ck_p),
    .sdram_ck_n(sdram_ck_n),
    .sdram_cke(sdram_cke),
    .sdram_cs_n(sdram_cs_n),
    .sdram_ras_n(sdram_ras_n),
    .sdram_cas_n(sdram_cas_n),
    .sdram_we_n(sdram_we_n),
    .sdram_ba(sdram_ba[1:0]),
    .sdram_a(sdram_a[12:0]),
    .sdram_udm(sdram_udm),
    .sdram_ldm(sdram_ldm),
    .sdram_udqs(sdram_udqs),
    .sdram_ldqs(sdram_ldqs),
    .sdram_dq(sdram_dq[15:0])
  );

  rom rom1(
    .clk(clk),
    .reset(reset),
    .en(rom_en),
    .wr(rom_wr),
    .size(rom_size[1:0]),
    .addr(rom_addr[23:0]),
    .data_out(rom_data_out[31:0]),
    .wt(rom_wt),
    .spi_en(spi_en),
    .ce_n(flash_ce_n),
    .oe_n(flash_oe_n),
    .we_n(flash_we_n),
    .byte_n(flash_byte_n),
    .a(flash_a[23:0]),
    .d(flash_d[15:0])
  );

  tmr tmr1_0(
    .clk(clk),
    .reset(reset),
    .en(tmr0_en),
    .wr(tmr0_wr),
    .addr(tmr0_addr[3:2]),
    .data_in(tmr0_data_in[31:0]),
    .data_out(tmr0_data_out[31:0]),
    .wt(tmr0_wt),
    .irq(tmr0_irq)
  );

  tmr tmr1_1(
    .clk(clk),
    .reset(reset),
    .en(tmr1_en),
    .wr(tmr1_wr),
    .addr(tmr1_addr[3:2]),
    .data_in(tmr1_data_in[31:0]),
    .data_out(tmr1_data_out[31:0]),
    .wt(tmr1_wt),
    .irq(tmr1_irq)
  );

  dsp dsp1(
    .clk(clk),
    .reset(reset),
    .en(dsp_en),
    .wr(dsp_wr),
    .addr(dsp_addr[13:2]),
    .data_in(dsp_data_in[15:0]),
    .data_out(dsp_data_out[15:0]),
    .wt(dsp_wt),
    .hsync(vga_hsync),
    .vsync(vga_vsync),
    .r(vga_r),
    .g(vga_g),
    .b(vga_b)
  );

  kbd kbd1(
    .clk(clk),
    .reset(reset),
    .en(kbd_en),
    .wr(kbd_wr),
    .addr(kbd_addr),
    .data_in(kbd_data_in[7:0]),
    .data_out(kbd_data_out[7:0]),
    .wt(kbd_wt),
    .irq(kbd_irq),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data)
  );

  ser ser1_0(
    .clk(clk),
    .reset(reset),
    .en(ser0_en),
    .wr(ser0_wr),
    .addr(ser0_addr[3:2]),
    .data_in(ser0_data_in[7:0]),
    .data_out(ser0_data_out[7:0]),
    .wt(ser0_wt),
    .irq_r(ser0_irq_r),
    .irq_t(ser0_irq_t),
    .rxd(rs232_0_rxd),
    .txd(rs232_0_txd)
  );

  ser ser1_1(
    .clk(clk),
    .reset(reset),
    .en(ser1_en),
    .wr(ser1_wr),
    .addr(ser1_addr[3:2]),
    .data_in(ser1_data_in[7:0]),
    .data_out(ser1_data_out[7:0]),
    .wt(ser1_wt),
    .irq_r(ser1_irq_r),
    .irq_t(ser1_irq_t),
    .rxd(rs232_1_rxd),
    .txd(rs232_1_txd)
  );

  fms fms1(
    .clk(clk),
    .reset(reset),
    .en(fms_en),
    .wr(fms_wr),
    .addr(fms_addr[11:2]),
    .data_in(fms_data_in[31:0]),
    .data_out(fms_data_out[31:0]),
    .wt(fms_wt),
    .next(dac_next),
    .sample_l(dac_sample_l[15:0]),
    .sample_r(dac_sample_r[15:0])
  );

  spi spi1(
    .clk(clk),
    .reset(reset),
    .spi_en(spi_en),
    .dac_sample_l(dac_sample_l[15:0]),
    .dac_sample_r(dac_sample_r[15:0]),
    .dac_next(dac_next),
    .spi_sck(spi_sck),
    .spi_mosi(spi_mosi),
    .dac_cs_n(dac_cs_n),
    .dac_clr_n(dac_clr_n),
    .amp_cs_n(amp_cs_n),
    .amp_shdn(amp_shdn),
    .ad_conv(ad_conv)
  );

  bio bio1(
    .clk(clk),
    .reset(reset),
    .en(bio_en),
    .wr(bio_wr),
    .addr(bio_addr),
    .data_in(bio_data_in[31:0]),
    .data_out(bio_data_out[31:0]),
    .wt(bio_wt),
    .spi_en(spi_en),
    .sw(sw[3:0]),
    .led(led[7:0]),
    .lcd_e(lcd_e),
    .lcd_rw(lcd_rw),
    .lcd_rs(lcd_rs),
    .spi_ss_b(spi_ss_b),
    .fpga_init_b(fpga_init_b)
  );

endmodule
