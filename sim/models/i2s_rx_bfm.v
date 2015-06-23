// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 1ns/10ps


module
  i2s_rx_bfm
  #(
    parameter DELAY = 3
  ) 
  (
    input   [31:0]  bfm_data_i,
    output  [31:0]  bfm_data_o,
    input   [31:0]  bfm_addr_i,
    input   [3:0]   bfm_sel_i,
    input           bfm_we_i,
    input           bfm_cyc_i,
    input           bfm_stb_i,
    output          bfm_ack_o,
    output          bfm_err_o,
    output          bfm_rty_o,
    
    output          bfm_sck_o, 
    output          bfm_ws_o,
    input           bfm_sck_i, 
    input           bfm_ws_i,
    input           bfm_sd_i,
        
    input           bfm_clk_i, 
    input           bfm_rst_i
  );

  //---------------------------------------------------
  //  init regs
  reg enable_r;
  
  initial
    begin
      enable_r <= 1'b0;
    end
    
    
  //---------------------------------------------------
  //  enable
  task enable_bfm;
    begin
    
    enable_r <= 1'b1;
    
    $display( "-#- %15.t | %m: BFM enabled.", $time );
      
    end
  endtask  

      
  //---------------------------------------------------
  //  disable
  task disable_bfm;
    begin
    
    enable_r <= 1'b0;
    
    $display( "-#- %15.t | %m: BFM disabled.", $time );
      
    end
  endtask  

      
  //---------------------------------------------------
  //  generate ws
  reg [5:0] count;
  
  always @(negedge bfm_clk_i)
    if( bfm_rst_i )
      count <= 0;
    else
      count <= count + 1;
      
  //---------------------------------------------------
  //  
  reg [31:0] i2s_data;
  
  always @(posedge bfm_sck_i)
    i2s_data <= { i2s_data[30:0], bfm_sd_i };
    
  reg [1:0] bfm_ws_i_r;
    
  always @(posedge bfm_sck_i)
    bfm_ws_i_r <= {bfm_ws_i_r[0], bfm_ws_i};
    
  wire bfm_ws_rise_edge;
  wire bfm_ws_fall_edge;
    
  assign bfm_ws_rise_edge = (bfm_ws_i_r[0] ^ bfm_ws_i_r[1]) & bfm_ws_i_r[0];  // right
  assign bfm_ws_fall_edge = (bfm_ws_i_r[0] ^ bfm_ws_i_r[1]) & ~bfm_ws_i_r[0]; // left
  
  
  //---------------------------------------------------
  //  
  always @(posedge bfm_sck_i)
    begin
    
      if(bfm_ws_fall_edge)
        $display( "-#- %15.t | %m: right channel is 0x%8.x.", $time, i2s_data );
      
      if(bfm_ws_rise_edge)
        $display( "-#- %15.t | %m: left  channel is 0x%8.x.", $time, i2s_data );
      
    end  
  

  //---------------------------------------------------
  //  assign outputs
  assign #DELAY bfm_ws_o   = enable_r ? count[5]  : 1'bz;
  assign #DELAY bfm_sck_o  = enable_r ? bfm_clk_i : 1'bz;
    

endmodule

