// --------------------------------------------------------------------
//
// --------------------------------------------------------------------

`include "timescale.v"


module 
  wb_async_mem_bridge
  #(
    parameter DW = 32,
    parameter AW = 32
  ) 
  (
    input   [(DW-1):0]  wb_data_i,
    output  [(DW-1):0]  wb_data_o,
    output  [(AW-1):0]  wb_addr_o,
    output  [3:0]       wb_sel_o,
    output              wb_we_o,
    output              wb_cyc_o,
    output              wb_stb_o,
    input               wb_ack_i,
    input               wb_err_i,
    input               wb_rty_i,
    
    inout   [(DW-1):0]  mem_d,
    input   [(AW-1):0]  mem_a,
    input               mem_oe_n,
    input   [3:0]       mem_bls_n,
    input               mem_we_n,
    input               mem_cs_n,
    
    input               wb_clk_i,
    input               wb_rst_i
  );

  
// --------------------------------------------------------------------
//  sync data & bls
  wire [(DW-1):0] sync_mem_d;
  wire [(AW-1):0] sync_mem_a;
  wire [3:0] sync_mem_bls_n;

  genvar i;
  
  generate
    for( i = 0; i < DW; i = i + 1 )
      begin: sync_data_loop
        sync i_sync( .async_sig(mem_d[i]), .sync_out(sync_mem_d[i]), .clk(wb_clk_i) );
      end
  endgenerate

  generate
    for( i = 0; i < AW; i = i + 1 )
      begin: sync_addr_loop
        sync i_sync( .async_sig(mem_a[i]), .sync_out(sync_mem_a[i]), .clk(wb_clk_i) );
      end
  endgenerate

  generate
    for( i = 0; i < 4; i = i + 1 )
      begin: sync_bls_loop
        sync i_sync( .async_sig(mem_bls_n[i]), .sync_out(sync_mem_bls_n[i]), .clk(wb_clk_i) );
      end
  endgenerate
  
  
// --------------------------------------------------------------------
//  sync mem_cs_n & mem_oe_n & mem_we_n
  wire sync_mem_oe_n, sync_mem_oe_n_rise, sync_mem_oe_n_fall;
  wire sync_mem_cs_n;
  wire sync_mem_we_n, sync_mem_we_n_rise, sync_mem_we_n_fall;
  
  sync_edge_detect
    i_sync_mem_oe_n(
                    .async_sig(mem_oe_n),
                    .sync_out(sync_mem_oe_n),
                    .clk(wb_clk_i),
                    .rise(sync_mem_oe_n_rise),
                    .fall(sync_mem_oe_n_fall)
                  );

  sync 
    i_sync_mem_cs_n( 
            .async_sig(mem_cs_n), 
            .sync_out(sync_mem_cs_n), 
            .clk(wb_clk_i) 
          );

  sync_edge_detect
    i_sync_mem_we_n(
                    .async_sig(mem_we_n),
                    .sync_out(sync_mem_we_n),
                    .clk(wb_clk_i),
                    .rise(sync_mem_we_n_rise),
                    .fall(sync_mem_we_n_fall)
                  );
                  

// --------------------------------------------------------------------
//  state machine
  wb_async_mem_sm #( .DW(DW), .AW(AW) ) 
    i_wb_async_mem_sm
    (
      .wb_data_i(wb_data_i),
//       .wb_data_o(wb_data_o),
      .wb_addr_i(wb_addr_o),
//       .wb_sel_o(wb_sel_o),
      .wb_we_o(wb_we_o),
      .wb_cyc_o(wb_cyc_o),
      .wb_stb_o(wb_stb_o),
      .wb_ack_i(wb_ack_i),
      .wb_err_i(wb_err_i),
      .wb_rty_i(wb_rty_i),
      
      .mem_d(sync_mem_d),
      .mem_a(sync_mem_a),
      .mem_oe_n(sync_mem_oe_n),
      .mem_bls_n(sync_mem_bls_n),
      .mem_we_n(sync_mem_we_n),
      .mem_cs_n(sync_mem_cs_n),
      
      .mem_we_n_fall(sync_mem_we_n_fall),
      .mem_oe_n_fall(sync_mem_oe_n_fall),
            
      .wb_clk_i(wb_clk_i),
      .wb_rst_i(wb_rst_i)
    );

                  
                  
// --------------------------------------------------------------------
//  wb_data_i flop
  reg [(DW-1):0] wb_data_i_r;
  
  always @(posedge wb_clk_i)
    if(wb_ack_i)
      wb_data_i_r <= wb_data_i;
    
    
// --------------------------------------------------------------------
//  wb_data_o flop
  reg [(DW-1):0] wb_data_o_r;
  
  always @(posedge wb_clk_i)
    if(~sync_mem_we_n)
      wb_data_o_r <= sync_mem_d;
    
    
// --------------------------------------------------------------------
//  outputs
  
  assign mem_d = (~sync_mem_oe_n & ~sync_mem_cs_n ) ? wb_data_i_r : 'bz;
  
  assign wb_addr_o = sync_mem_a;
  assign wb_data_o = wb_data_o_r;
  assign wb_sel_o = ~sync_mem_bls_n;
  
  
endmodule

