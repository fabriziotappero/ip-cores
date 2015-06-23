// --------------------------------------------------------------------
//
// --------------------------------------------------------------------




module soc_mem_bank_3(
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
	                      
                        inout   [15:0]  sram_dq,
                        output  [17:0]  sram_addr,
                        output          sram_ub_n,
                        output          sram_lb_n,
                        output          sram_we_n,
                        output          sram_ce_n,
                        output          sram_oe_n,
	      
	                      input           mem_clk_i, 
	                      input           mem_rst_i
	                    );
                     
	parameter USE_ON_CHIP_MEM 	= 0; 
	parameter ON_CHIP_MEM_DEPTH = 14; 
	
	parameter USE_ASYNC_SRAM 	  = 1; 

	generate 
		if( USE_ON_CHIP_MEM )
		  begin
        //---------------------------------------------------
        // ram_byte_0
      	soc_ram #( 	.DATA_WIDTH(8), .ADDR_WIDTH(ON_CHIP_MEM_DEPTH), .MEM_INIT(0) )
      	i_ram_byte_0				(
      		                    .data(mem_data_i[7:0]),
      		                    .addr( mem_addr_i[(ON_CHIP_MEM_DEPTH + 1):2] ),
      		                    .we(mem_we_i & mem_sel_i[0]),
      		                    .clk(~mem_clk_i),
      		                    .q(mem_data_o[7:0])
      		                  );
      	                    
        //---------------------------------------------------
        // ram_byte_1
      	soc_ram #( 	.DATA_WIDTH(8), .ADDR_WIDTH(ON_CHIP_MEM_DEPTH), .MEM_INIT(0) )
      	i_ram_byte_1				(
      		                    .data(mem_data_i[15:8]),
      		                    .addr( mem_addr_i[(ON_CHIP_MEM_DEPTH + 1):2] ),
      		                    .we(mem_we_i & mem_sel_i[1]),
      		                    .clk(~mem_clk_i),
      		                    .q(mem_data_o[15:8])
      		                  );
      		                  
        //---------------------------------------------------
        // ram_byte_2
      	soc_ram #( 	.DATA_WIDTH(8), .ADDR_WIDTH(ON_CHIP_MEM_DEPTH), .MEM_INIT(0) )
      	i_ram_byte_2				(
      		                    .data(mem_data_i[23:16]),
      		                    .addr( mem_addr_i[(ON_CHIP_MEM_DEPTH + 1):2] ),
      		                    .we(mem_we_i & mem_sel_i[2]),
      		                    .clk(~mem_clk_i),
      		                    .q(mem_data_o[23:16])
      		                  );
      	                    
        //---------------------------------------------------
        // ram_byte_3
      	soc_ram #( 	.DATA_WIDTH(8), .ADDR_WIDTH(ON_CHIP_MEM_DEPTH), .MEM_INIT(0) )
      	i_ram_byte_3				(
      		                    .data(mem_data_i[31:24]),
      		                    .addr( mem_addr_i[(ON_CHIP_MEM_DEPTH + 1):2] ),
      		                    .we(mem_we_i & mem_sel_i[3]),
      		                    .clk(~mem_clk_i),
      		                    .q(mem_data_o[31:24])
      		                  );
      	                    
        //---------------------------------------------------
        // outputs for on chip memory
        assign mem_ack_o = mem_cyc_i & mem_stb_i;
        assign mem_err_o = 1'b0;
        assign mem_rty_o = 1'b0;
        
      end  
		else if( USE_ASYNC_SRAM )
		  begin
        //---------------------------------------------------
        // async_mem_if
        async_mem_if #( .AW(18), .DW(16) )
        i_sram (
                  .async_dq(sram_dq),    
                  .async_addr(sram_addr),  
                  .async_ub_n(sram_ub_n),  
                  .async_lb_n(sram_lb_n),  
                  .async_we_n(sram_we_n),  
                  .async_ce_n(sram_ce_n),  
                  .async_oe_n(sram_oe_n),  
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
                  .ce_setup(4'h0), 
                  .op_hold(4'h1), 
                  .ce_hold(4'h0),
                  .big_endian_if_i(1'b1),
                  .lo_byte_if_i(1'b0)
                );
                
        //---------------------------------------------------
        // outputs for async_mem_if
        assign mem_err_o = 1'b0;
        assign mem_rty_o = 1'b0;
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

