// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 1ns/10ps


module tb_top();

  // --------------------------------------------------------------------
  // clock & reset
  
  parameter CLK_PERIOD = 54; // use ~18.4MHZ for main clk
  
  wire tb_clk;
  tb_clk #( .CLK_PERIOD(CLK_PERIOD) ) i_tb_clk ( tb_clk );
  
  
  wire tb_rst;
  
  tb_reset #( .ASSERT_TIME(CLK_PERIOD*10) ) i_tb_rst( tb_rst );
  
  initial
    begin
      $display("\n^^^---------------------------------");
      #(CLK_PERIOD/3);
      i_tb_rst.assert_reset();
    end  
    
    
  // --------------------------------------------------------------------
  // system wires
  

    
// --------------------------------------------------------------------
// dut
  wire  [31:0]  wbs_tx_data_i;
  wire  [31:0]  wbs_tx_data_o;
  wire  [31:0]  wbs_tx_addr_i;
  wire  [3:0]   wbs_tx_sel_i;
  wire          wbs_tx_we_i;
  wire          wbs_tx_cyc_i;
  wire          wbs_tx_stb_i;
  wire          wbs_tx_ack_o;
  wire          wbs_tx_err_o;
  wire          wbs_tx_rty_o;
  
  wire          i2s_tx_sck; 
  wire          i2s_tx_ws;
  wire          i2s_tx_sd;
        
  i2s_to_wb_top
    i_i2s_to_wb_top
    (
      .wbs_data_i(wbs_tx_data_i),
      .wbs_data_o(wbs_tx_data_o),
      .wbs_addr_i(wbs_tx_addr_i),
      .wbs_sel_i(wbs_tx_sel_i),
      .wbs_we_i(wbs_tx_we_i),
      .wbs_cyc_i(wbs_tx_cyc_i),
      .wbs_stb_i(wbs_tx_stb_i),
      .wbs_ack_o(wbs_tx_ack_o),
      .wbs_err_o(wbs_tx_err_o),
      .wbs_rty_o(wbs_tx_rty_o),
      
      .i2s_sck_i(i2s_tx_sck), 
      .i2s_ws_i(i2s_tx_ws),
      .i2s_sd_o(i2s_tx_sd),
          
      .i2s_clk_i(tb_clk), 
      .i2s_rst_i(tb_rst)
    );


  // --------------------------------------------------------------------
  // i2s_rx_bfm
  i2s_rx_bfm
    rx_bfm
    (
      .bfm_data_i(wbs_tx_data_o),
      .bfm_data_o(wbs_tx_data_i),
      .bfm_addr_i(wbs_tx_addr_i),
      .bfm_sel_i(wbs_tx_sel_i),
      .bfm_we_i(wbs_tx_we_i),
      .bfm_cyc_i(wbs_tx_cyc_i),
      .bfm_stb_i(wbs_tx_stb_i),
      .bfm_ack_o(wbs_tx_ack_o),
      .bfm_err_o(wbs_tx_err_o),
      .bfm_rty_o(wbs_tx_rty_o),
      
      .bfm_sck_o(i2s_tx_sck), 
      .bfm_ws_o(i2s_tx_ws),
      .bfm_sck_i(i2s_tx_sck), 
      .bfm_ws_i(i2s_tx_ws),
      .bfm_sd_i(i2s_tx_sd),
          
      .bfm_clk_i(tb_clk), 
      .bfm_rst_i(tb_rst)
    );
    
    
  // --------------------------------------------------------------------
  //  wb_hi_master_model
  wb_master_model 
    wbm
    (
      .clk(tb_clk),
      .rst(tb_rst),
      .adr(wbs_tx_addr_i),
      .din(wbs_tx_data_o),
      .dout(wbs_tx_data_i),
      .cyc(wbs_tx_cyc_i),
      .stb(wbs_tx_stb_i),
      .we(wbs_tx_we_i),
      .sel(wbs_tx_sel_i),
      .ack(wbs_tx_ack_o),
      .err(wbs_tx_err_o),
      .rty(wbs_tx_rty_o)
    );
    
    
// dut
// --------------------------------------------------------------------

    
// --------------------------------------------------------------------
// test 

  the_test test( tb_clk, tb_rst );
  
  initial
    begin
    
      wait( ~tb_rst );
      
      repeat(2) @(posedge tb_clk);
      
      test.run_the_test();
      
      $display("\n^^^---------------------------------");
      $display("^^^ %15.t | Testbench done.\n", $time);
      
      $stop();
    
    end
  
endmodule

