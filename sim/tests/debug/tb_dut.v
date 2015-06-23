// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`timescale 1ns/10ps


module tb_dut(
                input tb_clk,
                input tb_rst
              );


  // --------------------------------------------------------------------
  //  async_mem_master
  wire [31:0] mem_d;
  wire [31:0] mem_a;
  wire        mem_oe_n;
  wire [3:0]  mem_bls_n;
  wire        mem_we_n;
  wire        mem_cs_n; 
  
  async_mem_master 
    async_mem(
      .mem_d(mem_d),
      .mem_a(mem_a),
      .mem_oe_n(mem_oe_n),
      .mem_bls_n(mem_bls_n),
      .mem_we_n(mem_we_n),
      .mem_cs_n(mem_cs_n),
      
      .tb_clk(tb_clk),
      .tb_rst(tb_rst)
    );

  
  
  // --------------------------------------------------------------------
  //  wb_async_mem_bridge
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
  
  wb_async_mem_bridge 
    i_wb_async_mem_bridge(
      .wb_data_i(wb_data_i),
      .wb_data_o(wb_data_o),
      .wb_addr_o(wb_addr_o),
      .wb_sel_o(wb_sel_o),
      .wb_we_o(wb_we_o),
      .wb_cyc_o(wb_cyc_o),
      .wb_stb_o(wb_stb_o),
      .wb_ack_i(wb_ack_i),
      .wb_err_i(wb_err_i),
      .wb_rty_i(wb_rty_i),
      
      .mem_d(mem_d),
      .mem_a(mem_a),
      .mem_oe_n(mem_oe_n),
      .mem_bls_n(mem_bls_n),
      .mem_we_n(mem_we_n),
      .mem_cs_n(mem_cs_n),
      
      .wb_clk_i(tb_clk),
      .wb_rst_i(tb_rst)
  );

  
  
  // --------------------------------------------------------------------
  //  wb_slave_model
  wb_slave_model #(.DWIDTH(32), .AWIDTH(8), .ACK_DELAY(0), .SLAVE_RAM_INIT("wb_slave_32_bit.txt") )
    i_wb_slave_model(  
      .clk_i(tb_clk), 
      .rst_i(tb_rst), 
      .dat_o(wb_data_i), 
      .dat_i(wb_data_o), 
      .adr_i(wb_addr_o),
      .cyc_i(wb_cyc_o), 
      .stb_i(wb_stb_o), 
      .we_i(wb_we_o), 
      .sel_i(wb_sel_o),
      .ack_o(wb_ack_i), 
      .err_o(wb_err_i), 
      .rty_o(wb_rty_i) 
    );
                        
                        
    
endmodule


