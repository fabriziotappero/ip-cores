// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 1ns/10ps


module tb_dut(
                input tb_clk,
                input tb_rst
              );


  // -----------------------------
  //  bfm_ahb
  wire          hclk;
  wire          hresetn;
  wire  [31:0]  haddr;
  wire  [1:0]   htrans;
  wire          hwrite;
  wire  [2:0]   hsize;
  wire  [2:0]   hburst;
  wire  [3:0]   hprot;
  wire  [31:0]  hwdata;
  wire          hsel;

  wire  [31:0]  hrdata;
  wire          hready_in;
  wire          hready_out;
  wire  [1:0]   hresp;
  
  bfm_ahb 
    i_bfm_ahb(
                .hclk(hclk),
                .hresetn(hresetn),
                .haddr(haddr),
                .htrans(htrans),
                .hwrite(hwrite),
                .hsize(hsize),
                .hburst(hburst),
                .hprot(hprot),
                .hwdata(hwdata),
                .hsel(hsel),
                .hrdata(hrdata),
                .hready_in(hready_in),
                .hready_out(hready_out),
                .hresp(hresp),
                .bfm_clk(tb_clk),
                .bfm_reset(tb_rst)
              );
  

  // --------------------------------------------------------------------
  //  wb_slave_model
  wire          wb_clk_o; 
  wire          wb_rst_o; 
  wire [31:0]   wb_data_i;
  wire [31:0]   wb_data_o;
  wire [31:0]   wb_addr_o;
  wire [3:0]    wb_sel_o;
  wire          wb_we_o;
  wire          wb_cyc_o;
  wire          wb_stb_o;
  wire          wb_ack_i;
  wire          wb_err_i;
  wire          wb_rty_i;
    
  wb_arm_slave_top 
    i_wb_arm_slave_top(  
                        .ahb_hclk(hclk), 
                        .ahb_hreset(hresetn), 
                        .ahb_hrdata(hrdata), 
                        .ahb_hresp(hresp), 
                        .ahb_hready_out(hready_out), 
                        .ahb_hsplit(), 
                        .ahb_hwdata(hwdata), 
                        .ahb_haddr(haddr[7:0]), 
                        .ahb_hsize(hsize), 
                        .ahb_hwrite(hwrite), 
                        .ahb_hburst(hburst), 
                        .ahb_htrans(htrans), 
                        .ahb_hprot(), 
                        .ahb_hsel(hsel), 
                        .ahb_hready_in(hready_in),
                        .wb_clk_o(wb_clk_o), 
                        .wb_rst_o(wb_rst_o), 
                        .wb_ack_i(wb_ack_i), 
                        .wb_err_i(wb_err_i), 
                        .wb_rty_i(wb_rty_i), 
                        .wb_dat_i(wb_data_i),
                        .wb_cyc_o(wb_cyc_o), 
                        .wb_adr_o(wb_addr_o[7:0]), 
                        .wb_stb_o(wb_stb_o), 
                        .wb_we_o(wb_we_o), 
                        .wb_sel_o(wb_sel_o), 
                        .wb_dat_o(wb_data_o) 
                      );
                                      
                
  // --------------------------------------------------------------------
  //  wb_slave_model
  wb_slave_model #(.DWIDTH(32), .AWIDTH(8), .ACK_DELAY(0), .SLAVE_RAM_INIT("wb_slave_32_bit.txt") )
    i_wb_slave_model(  
      .clk_i(wb_clk_o), 
      .rst_i(wb_rst_o), 
      .dat_o(wb_data_i), 
      .dat_i(wb_data_o), 
      .adr_i( wb_addr_o[7:0] ),
      .cyc_i(wb_cyc_o), 
      .stb_i(wb_stb_o), 
      .we_i(wb_we_o), 
      .sel_i(wb_sel_o),
      .ack_o(wb_ack_i), 
      .err_o(wb_err_i), 
      .rty_o(wb_rty_i) 
    );
    
    
  // --------------------------------------------------------------------
  //  
                        
                        
    
endmodule


