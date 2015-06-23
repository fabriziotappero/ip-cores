


module soc_registers(
                      input   [31:0]  reg_data_i,
                      output  [31:0]  reg_data_o,
                      input   [31:0]  reg_addr_i,
                      input   [3:0]   reg_sel_i,
                      input           reg_we_i,
                      input           reg_cyc_i,
                      input           reg_stb_i,
                      output          reg_ack_o,
                      output          reg_err_o,
                      output          reg_rty_o,
      
                      input           reg_clk_i, 
                      input           reg_rst_i
                    );
                     
                           
  //---------------------------------------------------
  // outputs
  assign reg_data_o = 32'h1bad_c0de;
  assign reg_ack_o = reg_cyc_i & reg_stb_i;
  assign reg_err_o = 1'b0;
  assign reg_rty_o = 1'b0;

endmodule

