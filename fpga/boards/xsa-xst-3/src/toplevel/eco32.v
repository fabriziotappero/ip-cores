//
// eco32.v -- ECO32 top-level description
//


module eco32(clk_in,
             reset_inout_n,
             sdram_clk,
             sdram_fb,
             sdram_cke,
             sdram_cs_n,
             sdram_ras_n,
             sdram_cas_n,
             sdram_we_n,
             sdram_ba,
             sdram_a,
             sdram_udqm,
             sdram_ldqm,
             sdram_dq,
             flash_ce_n,
             flash_oe_n,
             flash_we_n,
             flash_rst_n,
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
             pbus_d,
             pbus_a,
             pbus_read_n,
             pbus_write_n,
             ata_cs0_n,
             ata_cs1_n,
             ata_intrq,
             ata_dmarq,
             ata_dmack_n,
             ata_iordy,
             dac_mclk,
             dac_sclk,
             dac_lrck,
             dac_sdti,
             slot1_cs_n,
             slot2_cs_n,
             ether_cs_n,
             sw1_3,
             sw1_4,
             sw2_n,
             sw3_n);

    // clock and reset
    input clk_in;
    inout reset_inout_n;
    // SDRAM
    output sdram_clk;
    input sdram_fb;
    output sdram_cke;
    output sdram_cs_n;
    output sdram_ras_n;
    output sdram_cas_n;
    output sdram_we_n;
    output [1:0] sdram_ba;
    output [12:0] sdram_a;
    output sdram_udqm;
    output sdram_ldqm;
    inout [15:0] sdram_dq;
    // flash ROM
    output flash_ce_n;
    output flash_oe_n;
    output flash_we_n;
    output flash_rst_n;
    output flash_byte_n;
    output [19:0] flash_a;
    input [15:0] flash_d;
    // VGA display
    output vga_hsync;
    output vga_vsync;
    output [2:0] vga_r;
    output [2:0] vga_g;
    output [2:0] vga_b;
    // keyboard
    input ps2_clk;
    input ps2_data;
    // serial line 0
    input rs232_0_rxd;
    output rs232_0_txd;
    // serial line 1
    input rs232_1_rxd;
    output rs232_1_txd;
    // peripheral bus
    inout [15:0] pbus_d;
    output [4:0] pbus_a;
    output pbus_read_n;
    output pbus_write_n;
    // ATA adapter
    output ata_cs0_n;
    output ata_cs1_n;
    input ata_intrq;
    input ata_dmarq;
    output ata_dmack_n;
    input ata_iordy;
    // audio DAC
    output dac_mclk;
    output dac_sclk;
    output dac_lrck;
    output dac_sdti;
    // expansion slot 1
    output slot1_cs_n;
    // expansion slot 2
    output slot2_cs_n;
    // ethernet
    output ether_cs_n;
    // board I/O
    input sw1_3;
    input sw1_4;
    input sw2_n;
    input sw3_n;

  // clk_rst
  wire clk;
  wire clk_ok;
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
  wire [24:0] ram_addr;
  wire [31:0] ram_data_in;
  wire [31:0] ram_data_out;
  wire ram_wt;
  // rom
  wire rom_en;
  wire rom_wr;
  wire [1:0] rom_size;
  wire [20:0] rom_addr;
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
  // dsk
  wire dsk_en;
  wire dsk_wr;
  wire [19:2] dsk_addr;
  wire [31:0] dsk_data_in;
  wire [31:0] dsk_data_out;
  wire dsk_wt;
  wire dsk_irq;
  // fms
  wire fms_en;
  wire fms_wr;
  wire [11:2] fms_addr;
  wire [31:0] fms_data_in;
  wire [31:0] fms_data_out;
  wire fms_wt;
  // dac
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

  clk_rst clk_rst1(
    .clk_in(clk_in),
    .reset_inout_n(reset_inout_n),
    .sdram_clk(sdram_clk),
    .sdram_fb(sdram_fb),
    .clk(clk),
    .clk_ok(clk_ok),
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
    .ram_addr(ram_addr[24:0]),
    .ram_data_in(ram_data_in[31:0]),
    .ram_data_out(ram_data_out[31:0]),
    .ram_wt(ram_wt),
    // rom
    .rom_en(rom_en),
    .rom_wr(rom_wr),
    .rom_size(rom_size[1:0]),
    .rom_addr(rom_addr[20:0]),
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
    // dsk
    .dsk_en(dsk_en),
    .dsk_wr(dsk_wr),
    .dsk_addr(dsk_addr[19:2]),
    .dsk_data_in(dsk_data_in[31:0]),
    .dsk_data_out(dsk_data_out[31:0]),
    .dsk_wt(dsk_wt),
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
  assign cpu_irq[ 8] = dsk_irq;
  assign cpu_irq[ 7] = 1'b0;
  assign cpu_irq[ 6] = 1'b0;
  assign cpu_irq[ 5] = 1'b0;
  assign cpu_irq[ 4] = kbd_irq;
  assign cpu_irq[ 3] = ser1_irq_r;
  assign cpu_irq[ 2] = ser1_irq_t;
  assign cpu_irq[ 1] = ser0_irq_r;
  assign cpu_irq[ 0] = ser0_irq_t;

  ram ram1(
    .clk(clk),
    .clk_ok(clk_ok),
    .reset(reset),
    .en(ram_en),
    .wr(ram_wr),
    .size(ram_size[1:0]),
    .addr(ram_addr[24:0]),
    .data_in(ram_data_in[31:0]),
    .data_out(ram_data_out[31:0]),
    .wt(ram_wt),
    .sdram_cke(sdram_cke),
    .sdram_cs_n(sdram_cs_n),
    .sdram_ras_n(sdram_ras_n),
    .sdram_cas_n(sdram_cas_n),
    .sdram_we_n(sdram_we_n),
    .sdram_ba(sdram_ba[1:0]),
    .sdram_a(sdram_a[12:0]),
    .sdram_udqm(sdram_udqm),
    .sdram_ldqm(sdram_ldqm),
    .sdram_dq(sdram_dq[15:0])
  );

  rom rom1(
    .clk(clk),
    .reset(reset),
    .en(rom_en),
    .wr(rom_wr),
    .size(rom_size[1:0]),
    .addr(rom_addr[20:0]),
    .data_out(rom_data_out[31:0]),
    .wt(rom_wt),
    .ce_n(flash_ce_n),
    .oe_n(flash_oe_n),
    .we_n(flash_we_n),
    .rst_n(flash_rst_n),
    .byte_n(flash_byte_n),
    .a(flash_a[19:0]),
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
    .r(vga_r[2:0]),
    .g(vga_g[2:0]),
    .b(vga_b[2:0])
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

  dsk dsk1(
    .clk(clk),
    .reset(reset),
    .en(dsk_en),
    .wr(dsk_wr),
    .addr(dsk_addr[19:2]),
    .data_in(dsk_data_in[31:0]),
    .data_out(dsk_data_out[31:0]),
    .wt(dsk_wt),
    .irq(dsk_irq),
    .ata_d(pbus_d[15:0]),
    .ata_a(pbus_a[2:0]),
    .ata_cs0_n(ata_cs0_n),
    .ata_cs1_n(ata_cs1_n),
    .ata_dior_n(pbus_read_n),
    .ata_diow_n(pbus_write_n),
    .ata_intrq(ata_intrq),
    .ata_dmarq(ata_dmarq),
    .ata_dmack_n(ata_dmack_n),
    .ata_iordy(ata_iordy)
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

  dac dac1(
    .clk(clk),
    .reset(reset),
    .sample_l(dac_sample_l[15:0]),
    .sample_r(dac_sample_r[15:0]),
    .next(dac_next),
    .mclk(dac_mclk),
    .sclk(dac_sclk),
    .lrck(dac_lrck),
    .sdti(dac_sdti)
  );

  assign pbus_a[4:3] = 2'b00;
  assign slot1_cs_n = 1;
  assign slot2_cs_n = 1;
  assign ether_cs_n = 1;

  bio bio1(
    .clk(clk),
    .reset(reset),
    .en(bio_en),
    .wr(bio_wr),
    .addr(bio_addr),
    .data_in(bio_data_in[31:0]),
    .data_out(bio_data_out[31:0]),
    .wt(bio_wt),
    .sw1_1(flash_a[19]),
    .sw1_2(flash_a[18]),
    .sw1_3(sw1_3),
    .sw1_4(sw1_4),
    .sw2_n(sw2_n),
    .sw3_n(sw3_n)
  );

endmodule
