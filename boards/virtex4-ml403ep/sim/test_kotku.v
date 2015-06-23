`timescale 1ns/10ps

module testbench;

  // Net and register declarations
  wire        lcd_clk;
  wire [ 1:0] lcd_r, lcd_g, lcd_b;
  wire        lcd_hsync;
  wire        lcd_vsync;
  reg         clk;
  reg         but;
  reg         ace_clk;
  wire        s_clk;
  wire [20:0] sf_addr;
  wire [31:0] sf_data;
  wire        sf_oe;
  wire        sf_we;
  wire [ 3:0] s_bw;
  wire        s_ce;
  wire        s_adv;
  wire        f_ce;

  wire [ 6:1] aceusb_a_;
  wire [15:0] aceusb_d_;
  wire        aceusb_oe_n_;
  wire        aceusb_we_n_;
  wire        ace_mpce_n_;
  wire        usb_cs_n_;
  wire        usb_hpi_reset_n_;

  // Module instances
  kotku_ml403 kotku (
    .tft_lcd_clk_   (lcd_clk),
    .tft_lcd_r_     (lcd_r),
    .tft_lcd_g_     (lcd_g),
    .tft_lcd_b_     (lcd_b),
    .tft_lcd_hsync_ (lcd_hsync),
    .tft_lcd_vsync_ (lcd_vsync),

    .sys_clk_in_ (clk),

    .sram_clk_        (s_clk),
    .sram_flash_addr_ (sf_addr),
    .sram_flash_data_ (sf_data),
    .sram_flash_oe_n_ (sf_oe),
    .sram_flash_we_n_ (sf_we),
    .sram_bw_         (s_bw),
    .sram_cen_        (s_ce),
    .sram_adv_ld_n_   (s_adv),
    .flash_ce2_       (f_ce),

    .aceusb_a_ (aceusb_a_),
    .aceusb_d_ (aceusb_d_),
    .aceusb_oe_n_ (aceusb_oe_n_),
    .aceusb_we_n_ (aceusb_we_n_),

    .ace_clkin_ (ace_clk),
    .ace_mpce_n_ (ace_mpce_n_),

    .usb_cs_n_ (usb_cs_n_),
    .usb_hpi_reset_n_ (usb_hpi_reset_n_)
  );

  flash_stub fs0 (
    .flash_addr_ (sf_addr),
    .flash_data_ (sf_data),
    .flash_oe_n_ (sf_oe),
    .flash_we_n_ (sf_we),
    .flash_ce2_  (f_ce)
  );

  cy7c1354 zbt (
    .d      (sf_data),
    .clk    (s_clk),
    .a      (sf_addr[17:0]),
    .bws    (s_bw),
    .we_b   (sf_we),
    .adv_lb (s_adv),
    .ce1b   (s_ce),
    .ce2    (1'b1),
    .ce3b   (1'b0),
    .oeb    (sf_oe),
    .cenb   (1'b0),
    .mode   (1'b0)
  );

  // Behaviour
  // Clock generation
  always  #5 clk = ~clk;
  always #15 ace_clk = ~ace_clk;

  initial
    begin
         clk <= 1'b0;
         ace_clk <= 1'b0;
         but <= 1'b0;
         #100000 but <= 1'b1;
         #700000 but <= 1'b0;
         #700000 but <= 1'b1;
    end

endmodule
