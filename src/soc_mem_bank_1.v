


module soc_mem_bank_1(
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
	      
	                      input           mem_clk_i, 
	                      input           mem_rst_i
	                    );
                     
                           
  //---------------------------------------------------
  // outputs
  assign mem_data_o = 32'h1bad_c0de;
  assign mem_ack_o = mem_cyc_i & mem_stb_i;
  assign mem_err_o = 1'b0;
  assign mem_rty_o = 1'b0;

endmodule

