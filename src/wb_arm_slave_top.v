//
//
//

`timescale 1ns / 100ps

module 
  wb_arm_slave_top
  #(
    parameter AWIDTH = 32,
    parameter DWIDTH = 32
  ) 
  (
    // -----------------------------
    // AHB interface
    input               ahb_hclk,
    input               ahb_hreset,
    output [DWIDTH-1:0] ahb_hrdata,
    output [1:0]        ahb_hresp,
    output              ahb_hready_out,
    output [15:0]       ahb_hsplit,
    input  [DWIDTH-1:0] ahb_hwdata,
    input  [AWIDTH-1:0] ahb_haddr,
    input  [2:0]        ahb_hsize,
    input               ahb_hwrite,
    input  [2:0]        ahb_hburst,
    input  [1:0]        ahb_htrans,
    input  [3:0]        ahb_hprot,
    input               ahb_hsel,
    input               ahb_hready_in,
                      
                      
    // -----------------------------
    // Data WISHBONE interface
  
    input			          wb_ack_i,	// normal termination
    input			          wb_err_i,	// termination w/ error
    input			          wb_rty_i,	// termination w/ retry
    input	 [DWIDTH-1:0] wb_dat_i,	// input data bus
    output			        wb_cyc_o,	// cycle valid output
    output [AWIDTH-1:0]	wb_adr_o,	// address bus outputs
    output			        wb_stb_o,	// strobe output
    output			        wb_we_o,	// indicates write transfer
    output [3:0]		    wb_sel_o,	// byte select outputs
    output [DWIDTH-1:0]	wb_dat_o,	// output data bus
    output		          wb_clk_o,	// clock input
    output		          wb_rst_o	// reset input
  );
  
  // -----------------------------
  //  ahb_haddr & control flops
  wire flop_en = ahb_hready_in & ahb_hsel & ~ahb_data_phase;
  
  reg [AWIDTH-1:0] ahb_haddr_r;
  always @ (posedge ahb_hclk)
    if ( flop_en )
      ahb_haddr_r <= ahb_haddr; 
      
      
  reg [1:0] ahb_htrans_r;
  always @ (posedge ahb_hclk)
    if ( flop_en )
      ahb_htrans_r <= ahb_htrans; 
      
      
  reg ahb_hwrite_r;
  always @ (posedge ahb_hclk)
    if ( flop_en )
      ahb_hwrite_r <= ahb_hwrite; 
      
      
  reg [2:0] ahb_hsize_r;
  always @ (posedge ahb_hclk)
    if ( flop_en )
      ahb_hsize_r <= ahb_hsize; 
      
      
  reg [2:0] ahb_hburst_r;
  always @ (posedge ahb_hclk)
    if ( flop_en )
      ahb_hburst_r <= ahb_hburst; 
      
      
  // -----------------------------
  //  wb_arm_phase_fsm
  wire ahb_data_phase;
  wire fsm_error;
  
  wb_arm_phase_fsm 
    i_wb_arm_phase_fsm(
      .ahb_hclk       (ahb_hclk),
      .ahb_hreset     (ahb_hreset),
      .ahb_hsel       (ahb_hsel),
      .ahb_hready_in  (ahb_hready_in),
      .ahb_hready_out (ahb_hready_out),
      .ahb_htrans     (ahb_htrans),
      .ahb_data_phase (ahb_data_phase),
      .fsm_error      (fsm_error)
    );
                        
                        
  // -----------------------------
  // hresp encoder
  reg [1:0] enc_hresp;
  
  always @(*)
    casez( { ahb_htrans_r, fsm_error } )
      { 2'b??, 1'b1 }:  enc_hresp = 2'b01;
      { 2'b11, 1'b? }:  enc_hresp = 2'b01;    // burst not supported yet
      default:          enc_hresp = 2'b00;
    endcase
  
  
  // -----------------------------
  // wb_sel encoder
  reg [3:0] enc_wb_sel;
  
  always @(*)
    casez( { ahb_hsize_r, ahb_haddr_r[1:0] } )
      { 3'b010, 2'b?? }:  enc_wb_sel = 4'b1111;
      { 3'b001, 2'b0? }:  enc_wb_sel = 4'b0011;
      { 3'b001, 2'b1? }:  enc_wb_sel = 4'b1100;
      { 3'b000, 2'b00 }:  enc_wb_sel = 4'b0001;
      { 3'b000, 2'b01 }:  enc_wb_sel = 4'b0010;
      { 3'b000, 2'b10 }:  enc_wb_sel = 4'b0100;
      { 3'b000, 2'b11 }:  enc_wb_sel = 4'b1000;
      default:            enc_wb_sel = 4'b0000;
    endcase
  
  
  // -----------------------------
  // outputs

  assign ahb_hresp      = enc_hresp;
  assign ahb_hready_out = wb_ack_i;
  assign ahb_hsplit     = 0;
  assign wb_sel_o       = enc_wb_sel;	
  
  assign wb_adr_o   = ahb_haddr_r;
  assign ahb_hrdata = wb_dat_i;
  assign wb_we_o    = ahb_hwrite_r & ( (ahb_htrans_r != 2'b00) | (ahb_htrans_r != 2'b01) );
  assign wb_cyc_o   = ahb_data_phase;
  assign wb_stb_o   = ahb_data_phase;
  assign wb_dat_o   = ahb_hwdata;	
  
  assign wb_clk_o = ahb_hclk;
  assign wb_rst_o = ~ahb_hreset;	
  
endmodule




		

