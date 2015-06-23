// Inputs are PPI (port parser input)
// Outputs are FLO (FIB lookup out)

module fib_lookup
  (/*AUTOARG*/
  // Outputs
  refup_srdy, refup_page, refup_count, ppi_drdy, flo_data, flo_srdy,
  // Inputs
  refup_drdy, ppi_srdy, clk, reset, ppi_data, flo_drdy
  );

  input     clk;
  input     reset;

  input [`PM2F_SZ-1:0] ppi_data;
  output [`LL_PG_ASZ-1:0]  flo_data;
  output [`NUM_PORTS-1:0]  flo_srdy;
  input [`NUM_PORTS-1:0]   flo_drdy;
  /*AUTOINPUT*/
  // Beginning of automatic inputs (from unused autoinst inputs)
  input                 ppi_srdy;               // To port_parse_in of sd_input.v
  input                 refup_drdy;             // To fsm0 of fib_lookup_fsm.v
  // End of automatics
  /*AUTOOUTPUT*/
  // Beginning of automatic outputs (from unused autoinst outputs)
  output                ppi_drdy;               // From port_parse_in of sd_input.v
  output [`LL_REFSZ-1:0] refup_count;           // From fsm0 of fib_lookup_fsm.v
  output [`LL_PG_ASZ-1:0] refup_page;           // From fsm0 of fib_lookup_fsm.v
  output                refup_srdy;             // From fsm0 of fib_lookup_fsm.v
  // End of automatics

  wire [`FIB_ENTRY_SZ-1:0] ft_rdata;
  wire [`PM2F_SZ-1:0] lpp_data;
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [`FIB_ASZ-1:0]   ft_addr;                // From fsm0 of fib_lookup_fsm.v
  wire                  ft_rd_en;               // From fsm0 of fib_lookup_fsm.v
  wire [`FIB_ENTRY_SZ-1:0] ft_wdata;            // From fsm0 of fib_lookup_fsm.v
  wire                  ft_wr_en;               // From fsm0 of fib_lookup_fsm.v
  wire                  lout_drdy;              // From fib_res_out of sd_mirror.v
  wire [`NUM_PORTS-1:0] lout_dst_vld;           // From fsm0 of fib_lookup_fsm.v
  wire                  lout_srdy;              // From fsm0 of fib_lookup_fsm.v
  wire [`LL_PG_ASZ-1:0] lout_start;             // From fsm0 of fib_lookup_fsm.v
  wire                  lpp_drdy;               // From fsm0 of fib_lookup_fsm.v
  wire                  lpp_srdy;               // From port_parse_in of sd_input.v
  // End of automatics
  
/* sd_input AUTO_TEMPLATE
 (
 .c_\(.*\)      (ppi_\1),
 .ip_\(.*\)     (lpp_\1),
 );
 */
  sd_input #(`PM2F_SZ) port_parse_in
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (ppi_drdy),              // Templated
     .ip_srdy                           (lpp_srdy),              // Templated
     .ip_data                           (lpp_data),              // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_srdy                            (ppi_srdy),              // Templated
     .c_data                            (ppi_data),              // Templated
     .ip_drdy                           (lpp_drdy));              // Templated
  
/* behave1p_mem AUTO_TEMPLATE
 (
   .d_out                             (ft_rdata),
   .d_in                              (ft_wdata),
   .clk                               (clk),
   .\(.*\)     (ft_\1),
 );
 */
  behave1p_mem #(`FIB_ENTRIES, `FIB_ENTRY_SZ) fib_mem
    (/*AUTOINST*/
     // Outputs
     .d_out                             (ft_rdata),              // Templated
     // Inputs
     .wr_en                             (ft_wr_en),              // Templated
     .rd_en                             (ft_rd_en),              // Templated
     .clk                               (clk),                   // Templated
     .d_in                              (ft_wdata),              // Templated
     .addr                              (ft_addr));               // Templated

  fib_lookup_fsm fsm0
    (/*AUTOINST*/
     // Outputs
     .lpp_drdy                          (lpp_drdy),
     .ft_wdata                          (ft_wdata[`FIB_ENTRY_SZ-1:0]),
     .ft_rd_en                          (ft_rd_en),
     .ft_wr_en                          (ft_wr_en),
     .ft_addr                           (ft_addr[`FIB_ASZ-1:0]),
     .lout_start                        (lout_start[`LL_PG_ASZ-1:0]),
     .lout_srdy                         (lout_srdy),
     .lout_dst_vld                      (lout_dst_vld[`NUM_PORTS-1:0]),
     .refup_srdy                        (refup_srdy),
     .refup_page                        (refup_page[`LL_PG_ASZ-1:0]),
     .refup_count                       (refup_count[`LL_REFSZ-1:0]),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .lpp_data                          (lpp_data[`PM2F_SZ-1:0]),
     .lpp_srdy                          (lpp_srdy),
     .ft_rdata                          (ft_rdata[`FIB_ENTRY_SZ-1:0]),
     .lout_drdy                         (lout_drdy),
     .refup_drdy                        (refup_drdy));

/* sd_mirror AUTO_TEMPLATE
 (
 .c_data       (lout_start[`LL_PG_ASZ-1:0]),
 .c_\(.*\)     (lout_\1),
 .p_\(.*\)     (flo_\1),
 )
 */
  sd_mirror #(// Parameters
              .mirror                   (`NUM_PORTS),
              .width                    (`LL_PG_ASZ)) fib_res_out
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (lout_drdy),             // Templated
     .p_srdy                            (flo_srdy),              // Templated
     .p_data                            (flo_data),              // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_srdy                            (lout_srdy),             // Templated
     .c_data                            (lout_start[`LL_PG_ASZ-1:0]), // Templated
     .c_dst_vld                         (lout_dst_vld),          // Templated
     .p_drdy                            (flo_drdy));              // Templated

endmodule // fib_lookup
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/memory" "../../../rtl/verilog/forks")
// End:  
