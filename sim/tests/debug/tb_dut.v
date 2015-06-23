// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


`include "timescale.v"


module tb_dut(
                input tb_clk,
                input tb_rst
              );


  // --------------------------------------------------------------------
  // wires
  wire [3:0]  boot_strap = 4'b0010;


  // --------------------------------------------------------------------
  // de1 wires
  wire  [1:0]   clock_24;
  wire  [1:0]   clock_27;
  wire          clock_50;
  wire          ext_clock;
  wire  [3:0]   key;
  wire  [9:0]   sw;
  wire  [6:0]   hex0;
  wire  [6:0]   hex1;
  wire  [6:0]   hex2;
  wire  [6:0]   hex3;
  wire  [7:0]   ledg;
  wire  [9:0]   ledr;
  wire          uart_txd;
  wire          uart_rxd;
  wire  [15:0]  dram_dq;
  wire  [11:0]  dram_addr;
  wire          dram_ldqm;
  wire          dram_udqm;
  wire          dram_we_n;
  wire          dram_cas_n;
  wire          dram_ras_n;
  wire          dram_cs_n;
  wire          dram_ba_0;
  wire          dram_ba_1;
  wire          dram_clk;
  wire          dram_cke;
  wire  [7:0]   fl_dq;
  wire  [21:0]  fl_addr;
  wire          fl_we_n;
  wire          fl_rst_n;
  wire          fl_oe_n;
  wire          fl_ce_n;
  wire  [15:0]  sram_dq;
  wire  [17:0]  sram_addr;
  wire          sram_ub_n;
  wire          sram_lb_n;
  wire          sram_we_n;
  wire          sram_ce_n;
  wire          sram_oe_n;
  wire          sd_dat;
  wire          sd_dat3;
  wire          sd_cmd;
  wire          sd_clk;
  wire          i2c_sdat;
  wire          i2c_sclk;
  wire          ps2_dat;
  wire          ps2_clk;
  wire          tdi;
  wire          tck;
  wire          tcs;
  wire          tdo;
  wire          vga_hs;
  wire          vga_vs;
  wire  [3:0]   vga_r;
  wire  [3:0]   vga_g;
  wire  [3:0]   vga_b;
  wire          aud_adclrck;
  wire          aud_adcdat;
  wire          aud_daclrck;
  wire          aud_dacdat;
  wire          aud_bclk;
  wire          aud_xck;
  wire  [35:0]  gpio_0;
  wire  [35:0]  gpio_1;


  // --------------------------------------------------------------------
  // fpga top
  assign clock_24 = {1'b0, tb_clk};
  assign sw       = {6'b000000, boot_strap};
  assign key      = {3'b000, ~tb_rst};

top
  i_top(
    ////////////////////////  Clock Input     ////////////////////////
    .clock_24( clock_24 ),               //  24 MHz
    .clock_27(clock_27),               //  27 MHz
    .clock_50(clock_50),               //  50 MHz
    .ext_clock(ext_clock),              //  External Clock
    ////////////////////////  Push Button     ////////////////////////
    .key( key ),                    //  Pushbutton[3:0]
    ////////////////////////  DPDT Switch     ////////////////////////
    .sw( sw ),                     //  Toggle Switch[9:0]
    ////////////////////////  7-SEG Dispaly   ////////////////////////
    .hex0(hex0),                   //  Seven Segment Digit 0
    .hex1(hex1),                   //  Seven Segment Digit 1
    .hex2(hex2),                   //  Seven Segment Digit 2
    .hex3(hex3),                   //  Seven Segment Digit 3
    ////////////////////////////  LED     ////////////////////////////
    .ledg(ledg),                   //  LED Green[7:0]
    .ledr(ledr),                   //  LED Red[9:0]
    ////////////////////////////  UART    ////////////////////////////
    .uart_txd(uart_txd),               //  UART Transmitter
    .uart_rxd(uart_rxd),               //  UART Receiver
    ///////////////////////       SDRAM Interface ////////////////////////
    .dram_dq(dram_dq),                //  SDRAM Data bus 16 Bits
    .dram_addr(dram_addr),              //  SDRAM Address bus 12 Bits
    .dram_ldqm(dram_ldqm),              //  SDRAM Low-byte Data Mask
    .dram_udqm(dram_udqm),              //  SDRAM High-byte Data Mask
    .dram_we_n(dram_we_n),              //  SDRAM Write Enable
    .dram_cas_n(dram_cas_n),             //  SDRAM Column Address Strobe
    .dram_ras_n(dram_ras_n),             //  SDRAM Row Address Strobe
    .dram_cs_n(dram_cs_n),              //  SDRAM Chip Select
    .dram_ba_0(dram_ba_0),              //  SDRAM Bank Address 0
    .dram_ba_1(dram_ba_1),              //  SDRAM Bank Address 0
    .dram_clk(dram_clk),               //  SDRAM Clock
    .dram_cke(dram_cke),               //  SDRAM Clock Enable
    ////////////////////////  Flash Interface ////////////////////////
    .fl_dq(fl_dq),                  //  FLASH Data bus 8 Bits
    .fl_addr(fl_addr),                //  FLASH Address bus 22 Bits
    .fl_we_n(fl_we_n),                //  FLASH Write Enable
    .fl_rst_n(fl_rst_n),               //  FLASH Reset
    .fl_oe_n(fl_oe_n),                //  FLASH Output Enable
    .fl_ce_n(fl_ce_n),                //  FLASH Chip Enable
    ////////////////////////  SRAM Interface  ////////////////////////
    .sram_dq(sram_dq),                //  SRAM Data bus 16 Bits
    .sram_addr(sram_addr),              //  SRAM Address bus 18 Bits
    .sram_ub_n(sram_ub_n),              //  SRAM High-byte Data Mask
    .sram_lb_n(sram_lb_n),              //  SRAM Low-byte Data Mask
    .sram_we_n(sram_we_n),              //  SRAM Write Enable
    .sram_ce_n(sram_ce_n),              //  SRAM Chip Enable
    .sram_oe_n(sram_oe_n),              //  SRAM Output Enable
    ////////////////////  SD Card Interface   ////////////////////////
    .sd_dat(sd_dat),                 //  SD Card Data
    .sd_dat3(sd_dat3),                //  SD Card Data 3
    .sd_cmd(sd_cmd),                 //  SD Card Command Signal
    .sd_clk(sd_clk),                 //  SD Card Clock
    ////////////////////////  I2C     ////////////////////////////////
    .i2c_sdat(i2c_sdat),               //  I2C Data
    .i2c_sclk(i2c_sclk),               //  I2C Clock
    ////////////////////////  PS2     ////////////////////////////////
    .ps2_dat(ps2_dat),                //  PS2 Data
    .ps2_clk(ps2_clk),                //  PS2 Clock
    ////////////////////  USB JTAG link   ////////////////////////////
    .tdi(tdi),                    // CPLD -> FPGA (data in)
    .tck(tck),                    // CPLD -> FPGA (clk)
    .tcs(tcs),                    // CPLD -> FPGA (CS)
    .tdo(tdo),                    // FPGA -> CPLD (data out)
    ////////////////////////  VGA         ////////////////////////////
    .vga_hs(vga_hs),                 //  VGA H_SYNC
    .vga_vs(vga_vs),                 //  VGA V_SYNC
    .vga_r(vga_r),                  //  VGA Red[3:0]
    .vga_g(vga_g),                  //  VGA Green[3:0]
    .vga_b(vga_b),                  //  VGA Blue[3:0]
    ////////////////////  Audio CODEC     ////////////////////////////
    .aud_adclrck(aud_adclrck),            //  Audio CODEC ADC LR Clock
    .aud_adcdat(aud_adcdat),             //  Audio CODEC ADC Data
    .aud_daclrck(aud_daclrck),            //  Audio CODEC DAC LR Clock
    .aud_dacdat(aud_dacdat),             //  Audio CODEC DAC Data
    .aud_bclk(aud_bclk),               //  Audio CODEC Bit-Stream Clock
    .aud_xck(aud_xck),                //  Audio CODEC Chip Clock
    ////////////////////////  GPIO    ////////////////////////////////
    .gpio_0(gpio_0),                 //  GPIO Connection 0
    .gpio_1(gpio_1)                  //  GPIO Connection 1
  );


  // --------------------------------------------------------------------
  // IS61LV25616
  IS61LV25616 
    i_IS61LV25616 (
                    .A(sram_addr),
                    .IO(sram_dq),
                    .CE_(sram_ce_n),
                    .OE_(sram_oe_n),
                    .WE_(sram_we_n),
                    .LB_(sram_lb_n),
                    .UB_(sram_ub_n)
                  );


  // --------------------------------------------------------------------
  // s29al032d_00
  s29al032d_00 
    i_s29al032d_00(
                    .A21(fl_addr[21]),
                    .A20(fl_addr[20]),
                    .A19(fl_addr[19]),
                    .A18(fl_addr[18]),
                    .A17(fl_addr[17]),
                    .A16(fl_addr[16]),
                    .A15(fl_addr[15]),
                    .A14(fl_addr[14]),
                    .A13(fl_addr[13]),
                    .A12(fl_addr[12]),
                    .A11(fl_addr[11]),
                    .A10(fl_addr[10]),
                    .A9(fl_addr[9]),
                    .A8(fl_addr[8]),
                    .A7(fl_addr[7]),
                    .A6(fl_addr[6]),
                    .A5(fl_addr[5]),
                    .A4(fl_addr[4]),
                    .A3(fl_addr[3]),
                    .A2(fl_addr[2]),
                    .A1(fl_addr[1]),
                    .A0(fl_addr[0]),
  
                    .DQ7(fl_dq[7]),
                    .DQ6(fl_dq[6]),
                    .DQ5(fl_dq[5]),
                    .DQ4(fl_dq[4]),
                    .DQ3(fl_dq[3]),
                    .DQ2(fl_dq[2]),
                    .DQ1(fl_dq[1]),
                    .DQ0(fl_dq[0]),
  
                    .CENeg(fl_ce_n),
                    .OENeg(fl_oe_n),
                    .WENeg(fl_we_n),
                    .RESETNeg(fl_rst_n),
                    .ACC(),
                    .RY()
                  );


  // --------------------------------------------------------------------
  //  async_mem_master
  wire [31:0] mem_d;
  wire [31:0] mem_a;
  wire        mem_oe_n;
  wire [3:0]  mem_bls_n;
  wire        mem_we_n;
  wire        mem_cs_n; 
  
  assign gpio_0[23:0] = mem_a[23:0];
  
  async_mem_master #( .ce_setup(10), .op_hold(15) )
    async_mem(
      .mem_d( gpio_1[31:0] ),
      .mem_a( mem_a ),
      .mem_oe_n( gpio_0[30] ),
      .mem_bls_n( { gpio_0[26], gpio_0[27], gpio_0[28], gpio_0[29] } ),
      .mem_we_n( gpio_0[25] ),
      .mem_cs_n( gpio_0[24] ),

      .tb_clk(tb_clk),
      .tb_rst(tb_rst)
    );
    

endmodule

