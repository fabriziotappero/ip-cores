


module soc_mem_bank_2(
                        input   [31:0]  mem_data_i,
                        output  [31:0]  mem_data_o,
                        input   [31:0]  mem_addr_i,
                        input   [3:0]   mem_sel_i,
                        input           mem_we_i,
                        input           mem_cyc_i,
                        input           mem_stb_i,
                        output          mem_ack_o,
                        output          mem_err_o,
                        output          mem_rty_o,
                        
                        inout   [7:0]   fl_dq,
                        output  [21:0]  fl_addr,
                        output          fl_we_n,
                        output          fl_rst_n,
                        output          fl_oe_n,
                        output          fl_ce_n,
        
                        input           mem_clk_i, 
                        input           mem_rst_i
                      );
                     
  parameter USE_NOR_FLASH     = 1; 
                           
  generate 
    if( USE_NOR_FLASH )
      begin
        //---------------------------------------------------
        // nor flash
        async_mem_if #( .AW(22), .DW(8) )
        i_flash (
                  .async_dq(fl_dq),    
                  .async_addr(fl_addr),  
                  .async_ub_n(),  
                  .async_lb_n(),  
                  .async_we_n(fl_we_n),  
                  .async_ce_n(fl_ce_n),  
                  .async_oe_n(fl_oe_n),  
                  .wb_clk_i(mem_clk_i),   
                  .wb_rst_i(mem_rst_i),
                  .wb_adr_i( {13'h0000, mem_addr_i[18:0]} ),
                  .wb_dat_i(mem_data_i),
                  .wb_we_i(mem_we_i),
                  .wb_stb_i(mem_stb_i),
                  .wb_cyc_i(mem_cyc_i),
                  .wb_sel_i(mem_sel_i),
                  .wb_dat_o(mem_data_o),
                  .wb_ack_o(mem_ack_o),
                  .ce_setup(4'h1), 
                  .op_hold(4'h3), 
                  .ce_hold(4'h1),
                  .big_endian_if_i(1'b1),
                  .lo_byte_if_i(1'b1)
                );
          
        //---------------------------------------------------
        // outputs for nor flash
        assign mem_err_o = 1'b0;
        assign mem_rty_o = 1'b0;
        assign fl_rst_n = ~mem_rst_i;
          
      end
    else
      begin
        //---------------------------------------------------
        // outputs for stub
        assign mem_data_o = 32'h1bad_c0de;
        assign mem_ack_o = mem_cyc_i & mem_stb_i;
        assign mem_err_o = 1'b0;
        assign mem_rty_o = 1'b0;
      end  

  endgenerate       
  
endmodule

