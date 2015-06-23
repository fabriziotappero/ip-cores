// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"
`include "soc_defines.v"

module top(
  ////////////////////////  Clock Input     ////////////////////////
  input [1:0]       clock_24,               //  24 MHz
  input [1:0]       clock_27,               //  27 MHz
  input             clock_50,               //  50 MHz
  input             ext_clock,              //  External Clock
  ////////////////////////  Push Button     ////////////////////////
  input [3:0]       key,                    //  Pushbutton[3:0]
  ////////////////////////  DPDT Switch     ////////////////////////
  input [9:0]       sw,                     //  Toggle Switch[9:0]
  ////////////////////////  7-SEG Dispaly   ////////////////////////
  output    [6:0]   hex0,                   //  Seven Segment Digit 0
  output    [6:0]   hex1,                   //  Seven Segment Digit 1
  output    [6:0]   hex2,                   //  Seven Segment Digit 2
  output    [6:0]   hex3,                   //  Seven Segment Digit 3
  ////////////////////////////  LED     ////////////////////////////
  output    [7:0]   ledg,                   //  LED Green[7:0]
  output    [9:0]   ledr,                   //  LED Red[9:0]
  ////////////////////////////  UART    ////////////////////////////
  output            uart_txd,               //  UART Transmitter
  input             uart_rxd,               //  UART Receiver
  ///////////////////////       SDRAM Interface ////////////////////////
  inout [15:0]      dram_dq,                //  SDRAM Data bus 16 Bits
  output    [11:0]  dram_addr,              //  SDRAM Address bus 12 Bits
  output            dram_ldqm,              //  SDRAM Low-byte Data Mask 
  output            dram_udqm,              //  SDRAM High-byte Data Mask
  output            dram_we_n,              //  SDRAM Write Enable
  output            dram_cas_n,             //  SDRAM Column Address Strobe
  output            dram_ras_n,             //  SDRAM Row Address Strobe
  output            dram_cs_n,              //  SDRAM Chip Select
  output            dram_ba_0,              //  SDRAM Bank Address 0
  output            dram_ba_1,              //  SDRAM Bank Address 0
  output            dram_clk,               //  SDRAM Clock
  output            dram_cke,               //  SDRAM Clock Enable
  ////////////////////////  Flash Interface ////////////////////////
  inout [7:0]       fl_dq,                  //  FLASH Data bus 8 Bits
  output    [21:0]  fl_addr,                //  FLASH Address bus 22 Bits
  output            fl_we_n,                //  FLASH Write Enable
  output            fl_rst_n,               //  FLASH Reset
  output            fl_oe_n,                //  FLASH Output Enable
  output            fl_ce_n,                //  FLASH Chip Enable
  ////////////////////////  SRAM Interface  ////////////////////////
  inout   [15:0]    sram_dq,                //  SRAM Data bus 16 Bits
  output  [17:0]    sram_addr,              //  SRAM Address bus 18 Bits
  output            sram_ub_n,              //  SRAM High-byte Data Mask 
  output            sram_lb_n,              //  SRAM Low-byte Data Mask 
  output            sram_we_n,              //  SRAM Write Enable
  output            sram_ce_n,              //  SRAM Chip Enable
  output            sram_oe_n,              //  SRAM Output Enable
  ////////////////////  SD Card Interface   ////////////////////////
  inout             sd_dat,                 //  SD Card Data
  inout             sd_dat3,                //  SD Card Data 3
  inout             sd_cmd,                 //  SD Card Command Signal
  output            sd_clk,                 //  SD Card Clock
  ////////////////////////  I2C     ////////////////////////////////
  inout             i2c_sdat,               //  I2C Data
  output            i2c_sclk,               //  I2C Clock
  ////////////////////////  PS2     ////////////////////////////////
  input             ps2_dat,                //  PS2 Data
  input             ps2_clk,                //  PS2 Clock
  ////////////////////  USB JTAG link   ////////////////////////////
  input             tdi,                    // CPLD -> FPGA (data in)
  input             tck,                    // CPLD -> FPGA (clk)
  input             tcs,                    // CPLD -> FPGA (CS)
  output            tdo,                    // FPGA -> CPLD (data out)
  ////////////////////////  VGA         ////////////////////////////
  output            vga_hs,                 //  VGA H_SYNC
  output            vga_vs,                 //  VGA V_SYNC
  output    [3:0]   vga_r,                  //  VGA Red[3:0]
  output    [3:0]   vga_g,                  //  VGA Green[3:0]
  output    [3:0]   vga_b,                  //  VGA Blue[3:0]
  ////////////////////  Audio CODEC     ////////////////////////////
  inout             aud_adclrck,            //  Audio CODEC ADC LR Clock
  input             aud_adcdat,             //  Audio CODEC ADC Data
  inout             aud_daclrck,            //  Audio CODEC DAC LR Clock
  output            aud_dacdat,             //  Audio CODEC DAC Data
  inout             aud_bclk,               //  Audio CODEC Bit-Stream Clock
  output            aud_xck,                //  Audio CODEC Chip Clock
  ////////////////////////  GPIO    ////////////////////////////////
  inout [35:0]      gpio_0,                 //  GPIO Connection 0
  inout [35:0]      gpio_1                  //  GPIO Connection 1
);


  //---------------------------------------------------
  // system wires
  wire        reset_switch  = ~key[0];
  wire [3:0]  boot_strap    = sw[3:0];
  wire        sysclk        = clock_24[0];
  

  //---------------------------------------------------
  // FLED
  reg [24:0] counter;
  wire [7:0]  fled;

  always @(posedge sysclk or posedge reset_switch)
    if(reset_switch)
      counter <= 25'b0;
    else
      counter <= counter + 1;
  
  assign fled[0]  = sw[0];
  assign fled[1]  = sw[1];
  assign fled[2]  = sw[2];
  assign fled[3]  = sw[3];
  assign fled[4]  = sw[4];
  assign fled[5]  = sw[5];
  assign fled[6]  = sw[6];
  assign fled[7]  = counter[24];
  
  //---------------------------------------------------
  // IO pads
  genvar i;
  
  // gpio a
  wire [31:0] gpio_a_aux_i;
  wire [31:0] gpio_a_ext_pad_i;
  wire [31:0] gpio_a_ext_pad_o;
  wire [31:0] gpio_a_ext_padoe_o;
  wire [31:0] gpio_a_io_buffer_o;
  
  generate for( i = 0; i < 32; i = i + 1 )
    begin: gpio_a_pads
      assign gpio_a_io_buffer_o[i] = gpio_a_ext_padoe_o[i] ? gpio_a_ext_pad_o[i] : 1'bz;
    end  
  endgenerate  

  
  //---------------------------------------------------
  // soc_top
`ifdef USE_DEBUG_0  
  wire [255 : 0]  debug_0;
`endif

`ifdef USE_EXT_JTAG  
  wire jtag_tck_i; 
  wire jtag_tms_i; 
  wire jtag_tdo_i; 
  wire jtag_tdi_o; 
`endif
  
  soc_top i_or1200_soc_top
  (
    .uart_txd_0(uart_txd),       //  UART Transmitter
    .uart_rxd_0(uart_rxd),       //  UART Receiver
    ////////////////////////  Flash Interface ////////////////////////
    .fl_dq(fl_dq),          //  flash data bus 8 bits
    .fl_addr(fl_addr),        //  flash address bus 22 bits
    .fl_we_n(fl_we_n),        //  flash write enable
    .fl_rst_n(fl_rst_n),       //  flash reset
    .fl_oe_n(fl_oe_n),        //  flash output enable
    .fl_ce_n(fl_ce_n),        //  flash chip enable
    ////////////////////////  sram interface  ////////////////////////
    .sram_dq(sram_dq),        //  sram data bus 16 bits
    .sram_addr(sram_addr),      //  sram address bus 18 bits
    .sram_ub_n(sram_ub_n),      //  sram high-byte data mask
    .sram_lb_n(sram_lb_n),      //  sram low-byte data mask
    .sram_we_n(sram_we_n),      //  sram write enable
    .sram_ce_n(sram_ce_n),      //  sram chip enable
    .sram_oe_n(sram_oe_n),      //  sram output enable
    
    .gpio_a_aux_i(gpio_a_aux_i),    
    .gpio_a_ext_pad_i(gpio_a_ext_pad_i),  
    .gpio_a_ext_pad_o(gpio_a_ext_pad_o),  
    .gpio_a_ext_padoe_o(gpio_a_ext_padoe_o),  
    
//     .gpio_b_aux_i(gpio_b_aux_i),   
//     .gpio_b_ext_pad_i(gpio_b_ext_pad_i), 
//     .gpio_b_ext_pad_o(gpio_b_ext_pad_o), 
//     .gpio_b_ext_padoe_o(gpio_b_ext_padoe_o), 

//     .gpio_c_aux_i(gpio_c_aux_i),   
//     .gpio_c_ext_pad_i(gpio_c_ext_pad_i), 
//     .gpio_c_ext_pad_o(gpio_c_ext_pad_o), 
//     .gpio_c_ext_padoe_o(gpio_c_ext_padoe_o), 

//     .gpio_d_aux_i(gpio_d_aux_i),   
//     .gpio_d_ext_pad_i(gpio_d_ext_pad_i), 
//     .gpio_d_ext_pad_o(gpio_d_ext_pad_o), 
//     .gpio_d_ext_padoe_o(gpio_d_ext_padoe_o), 

//     .gpio_e_aux_i(gpio_e_aux_i),   
//     .gpio_e_ext_pad_i(gpio_e_ext_pad_i), 
//     .gpio_e_ext_pad_o(gpio_e_ext_pad_o), 
//     .gpio_e_ext_padoe_o(gpio_e_ext_padoe_o), 

//     .gpio_f_aux_i(gpio_f_aux_i),   
//     .gpio_f_ext_pad_i(gpio_f_ext_pad_i), 
//     .gpio_f_ext_pad_o(gpio_f_ext_pad_o), 
//     .gpio_f_ext_padoe_o(gpio_f_ext_padoe_o), 

//     .gpio_g_aux_i(gpio_g_aux_i),   
//     .gpio_g_ext_pad_i(gpio_g_ext_pad_i), 
//     .gpio_g_ext_pad_o(gpio_g_ext_pad_o), 
//     .gpio_g_ext_padoe_o(gpio_g_ext_padoe_o), 

    .boot_strap(boot_strap),
    
`ifdef USE_DEBUG_0  
    .debug_0(debug_0),
`endif

`ifdef USE_EXT_JTAG  
    .jtag_tck_i(jtag_tck_i), 
    .jtag_tms_i(jtag_tms_i), 
    .jtag_tdo_i(jtag_tdo_i), 
    .jtag_tdi_o(jtag_tdi_o),
`endif
    
    .sys_clk(sysclk),
    .sys_rst(reset_switch)
  );
      

  //---------------------------------------------------
  // outputs
  
  //  Turn off all display
  assign  hex0        =   7'hff;
  assign  hex1        =   7'hff;
  assign  hex2        =   7'hff;
  assign  hex3        =   7'hff;
//   assign  ledg        =   8'hff;
  assign  ledr        =   10'h000;
  
  //  All inout port turn to tri-state
  assign  dram_dq     =   16'hzzzz;
  assign  fl_dq       =   8'hzz;
//   assign  sram_dq     =   16'hzzzz;
  assign  sd_dat      =   1'bz;
  assign  i2c_sdat    =   1'bz;
  assign  aud_adclrck =   1'bz;
  assign  aud_daclrck =   1'bz;
  assign  aud_bclk    =   1'bz;
  assign  gpio_0      =   36'hzzzzzzzzz;
  assign  gpio_1      =   36'hzzzzzzzzz;
  
  assign ledg[7:0]        = gpio_a_io_buffer_o[7:0];
  assign gpio_a_aux_i     = { 24'h000000, fled };
  assign gpio_a_ext_pad_i = { 14'h0000, sw, ledg };

  
endmodule

