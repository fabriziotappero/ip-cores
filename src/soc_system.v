// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


module
  soc_system(
              input   [31:0]  sys_data_i,
              output  [31:0]  sys_data_o,
              input   [31:0]  sys_addr_i,
              input   [3:0]   sys_sel_i,
              input           sys_we_i,
              input           sys_cyc_i,
              input           sys_stb_i,
              output          sys_ack_o,
              output          sys_err_o,
              output          sys_rty_o,

              input   [3:0]   boot_strap,
              output  [1:0]   boot_select,
              output  [1:0]   boot_remap,

              input           sys_clk_i,
              input           sys_rst_i
            );


  //---------------------------------------------------
  // boot_strap flops
  
  reg [3:0] boot_strap_r;
  
  always @(negedge sys_rst_i)
    boot_strap_r <= boot_strap;

            
  //---------------------------------------------------
  // soc_registers
  soc_registers
    i_soc_registers(
                      .reg_data_i(sys_data_i),
                      .reg_data_o(sys_data_o),
                      .reg_addr_i(sys_addr_i),
                      .reg_sel_i(sys_sel_i),
                      .reg_we_i(sys_we_i),
                      .reg_cyc_i(sys_cyc_i),
                      .reg_stb_i(sys_stb_i),
                      .reg_ack_o(sys_ack_o),
                      .reg_err_o(sys_err_o),
                      .reg_rty_o(sys_rty_o),

                      .reg_clk_i(sys_clk_i),
                      .reg_rst_i(sys_rst_i)
                    );

  //---------------------------------------------------
  // outputs
  assign boot_remap[1:0]   = boot_strap_r[1:0];
  assign boot_select[1:0]  = boot_strap_r[3:2];

endmodule

