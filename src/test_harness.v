// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"


module 
  test_harness(
    inout [35:0]    gpio_0,
    inout [35:0]    gpio_1,
    
    input           sys_clk_i,
    input           sys_rst_i
  );
  
    
// --------------------------------------------------------------------
//  wb_async_mem_bridge
  wire [31:0] wb_data_i;
  wire [31:0] wb_data_o;
  wire [31:0] wb_addr_o;
  wire [3:0]  wb_sel_o;
  wire        wb_we_o;
  wire        wb_cyc_o;
  wire        wb_stb_o;
  wire        wb_ack_i;
  wire        wb_err_i;
  wire        wb_rty_i;
  
  wb_async_mem_bridge i_wb_async_mem_bridge(
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
    
    .mem_d( gpio_1[31:0] ),
    .mem_a( {8'h00, gpio_0[23:0]} ),
    .mem_oe_n( gpio_0[30] ),
    .mem_bls_n( { gpio_0[26], gpio_0[27], gpio_0[28], gpio_0[29] } ),
    .mem_we_n( gpio_0[25] ),
    .mem_cs_n( gpio_0[24] ),
    
    .wb_clk_i(sys_clk_i),
    .wb_rst_i(sys_rst_i)
  );
  
  
  
// --------------------------------------------------------------------
//  soc_ram
  soc_ram
    i_soc_ram_0( 
      .data(wb_data_o[7:0]), 
      .addr(wb_addr_o[7:2]), 
      .we(wb_we_o & wb_stb_o & wb_sel_o[0]), 
      .clk(sys_clk_i), 
      .q(wb_data_i[7:0]) 
    );
    
  soc_ram
    i_soc_ram_1( 
      .data(wb_data_o[15:8]), 
      .addr(wb_addr_o[7:2]), 
      .we(wb_we_o & wb_stb_o & wb_sel_o[1]), 
      .clk(sys_clk_i), 
      .q(wb_data_i[15:8]) 
    );
    
  soc_ram
    i_soc_ram_2( 
      .data(wb_data_o[23:16]), 
      .addr(wb_addr_o[7:2]), 
      .we(wb_we_o & wb_stb_o & wb_sel_o[2]), 
      .clk(sys_clk_i), 
      .q(wb_data_i[23:16]) 
    );
    
  soc_ram
    i_soc_ram_3( 
      .data(wb_data_o[31:24]), 
      .addr(wb_addr_o[7:2]), 
      .we(wb_we_o & wb_stb_o & wb_sel_o[3]), 
      .clk(sys_clk_i), 
      .q(wb_data_i[31:24]) 
    );
    

endmodule

