module control_pipe
  (
   input  [`PM2F_SZ-1:0]  pm2f_data_0,            // To fib_arb of sd_rrmux.v
   input  [`PM2F_SZ-1:0]  pm2f_data_1,            // To fib_arb of sd_rrmux.v
   input  [`PM2F_SZ-1:0]  pm2f_data_2,            // To fib_arb of sd_rrmux.v
   input  [`PM2F_SZ-1:0]  pm2f_data_3,            // To fib_arb of sd_rrmux.v
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                clk,                    // To fib_arb of sd_rrmux.v, ...
   input [`NUM_PORTS*`LL_PG_ASZ*2-1:0] drf_page_list,// To lm of llmanager.v
   input [(`NUM_PORTS)-1:0] drf_srdy,           // To lm of llmanager.v
   input [3:0]          f2d_drdy,               // To cq0 of sd_fifo_s.v, ...
   input [`LL_LNP_SZ*4-1:0] lnp_pnp,            // To lm of llmanager.v
   input [(`NUM_PORTS)-1:0] lnp_srdy,           // To lm of llmanager.v
   input [(`NUM_PORTS)-1:0] par_srdy,           // To lm of llmanager.v
   input [(`NUM_PORTS)-1:0] parr_drdy,          // To lm of llmanager.v
   input [`NUM_PORTS-1:0] pm2f_srdy,            // To fib_arb of sd_rrmux.v
   input                reset,                  // To fib_arb of sd_rrmux.v, ...
   input [(`NUM_PORTS)*(`LL_PG_ASZ)-1:0] rlp_rd_page,// To lm of llmanager.v
   input [(`NUM_PORTS)-1:0] rlp_srdy,           // To lm of llmanager.v
   input [(`NUM_PORTS)-1:0] rlpr_drdy,          // To lm of llmanager.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [(`NUM_PORTS)-1:0] drf_drdy,          // From lm of llmanager.v
   output [`LL_PG_ASZ-1:0] f2d_data_0,          // From cq0 of sd_fifo_s.v
   output [`LL_PG_ASZ-1:0] f2d_data_1,          // From cq1 of sd_fifo_s.v
   output [`LL_PG_ASZ-1:0] f2d_data_2,          // From cq2 of sd_fifo_s.v
   output [`LL_PG_ASZ-1:0] f2d_data_3,          // From cq3 of sd_fifo_s.v
   output [3:0]         f2d_srdy,               // From cq0 of sd_fifo_s.v, ...
   output [(`NUM_PORTS)-1:0] lnp_drdy,          // From lm of llmanager.v
   output [(`NUM_PORTS)-1:0] par_drdy,          // From lm of llmanager.v
   output [(`LL_PG_ASZ)-1:0] parr_page,         // From lm of llmanager.v
   output [(`NUM_PORTS)-1:0] parr_srdy,         // From lm of llmanager.v
   output [`NUM_PORTS-1:0] pm2f_drdy,           // From fib_arb of sd_rrmux.v
   output [(`NUM_PORTS)-1:0] rlp_drdy,          // From lm of llmanager.v
   output [(`LL_PG_ASZ+1)-1:0] rlpr_data,       // From lm of llmanager.v
   output [(`NUM_PORTS)-1:0] rlpr_srdy         // From lm of llmanager.v
   // End of automatics
   );

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [`LL_PG_ASZ-1:0] flo_data;               // From fib_lookup of fib_lookup.v
  wire [3:0]            flo_drdy;               // From cq0 of sd_fifo_s.v, ...
  wire [`NUM_PORTS-1:0] flo_srdy;               // From fib_lookup of fib_lookup.v
  wire [(`LL_PG_ASZ)-1:0] pgmem_rd_addr;        // From lm of llmanager.v
  wire [(`LL_PG_ASZ+1)-1:0] pgmem_rd_data;      // From pglist_mem of behave2p_mem.v
  wire                  pgmem_rd_en;            // From lm of llmanager.v
  wire [(`LL_PG_ASZ)-1:0] pgmem_wr_addr;        // From lm of llmanager.v
  wire [(`LL_PG_ASZ+1)-1:0] pgmem_wr_data;      // From lm of llmanager.v
  wire                  pgmem_wr_en;            // From lm of llmanager.v
  wire [`PM2F_SZ-1:0]   ppi_data;               // From fib_arb of sd_rrmux.v
  wire                  ppi_drdy;               // From fib_lookup of fib_lookup.v
  wire                  ppi_srdy;               // From fib_arb of sd_rrmux.v
  wire [(`LL_PG_ASZ)-1:0] ref_rd_addr;          // From lm of llmanager.v
  wire [(`LL_REFSZ)-1:0] ref_rd_data;           // From ref_mem of behave2p_mem.v
  wire                  ref_rd_en;              // From lm of llmanager.v
  wire [(`LL_PG_ASZ)-1:0] ref_wr_addr;          // From lm of llmanager.v
  wire [(`LL_REFSZ)-1:0] ref_wr_data;           // From lm of llmanager.v
  wire                  ref_wr_en;              // From lm of llmanager.v
  wire [`LL_REFSZ-1:0]  refup_count;            // From fib_lookup of fib_lookup.v
  wire                  refup_drdy;             // From lm of llmanager.v
  wire [`LL_PG_ASZ-1:0] refup_page;             // From fib_lookup of fib_lookup.v
  wire                  refup_srdy;             // From fib_lookup of fib_lookup.v
  // End of automatics

/*  sd_rrmux AUTO_TEMPLATE
 (
 .p_grant (),
 .p_data  (ppi_data[`PM2F_SZ-1:0]),
 .c_data  ({pm2f_data_3,pm2f_data_2,pm2f_data_1,pm2f_data_0}),
 .c_srdy  (pm2f_srdy[`NUM_PORTS-1:0]),
 .c_drdy  (pm2f_drdy[`NUM_PORTS-1:0]),
 .c_rearb                           (1'b1),
 .c_\(.*\)   (pm2f_\1[]),
 .p_\(.*\)   (ppi_\1[]),
 );
 */
  sd_rrmux #(
              // Parameters
              .width                    (`PM2F_SZ),
              .inputs                   (`NUM_PORTS),
              .mode                     (0),
              .fast_arb                 (1)) fib_arb
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (pm2f_drdy[`NUM_PORTS-1:0]), // Templated
     .p_data                            (ppi_data[`PM2F_SZ-1:0]), // Templated
     .p_grant                           (),                      // Templated
     .p_srdy                            (ppi_srdy),              // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_data                            ({pm2f_data_3,pm2f_data_2,pm2f_data_1,pm2f_data_0}), // Templated
     .c_srdy                            (pm2f_srdy[`NUM_PORTS-1:0]), // Templated
     .c_rearb                           (1'b1),                  // Templated
     .p_drdy                            (ppi_drdy));              // Templated

  fib_lookup fib_lookup
    (/*AUTOINST*/
     // Outputs
     .flo_data                          (flo_data[`LL_PG_ASZ-1:0]),
     .flo_srdy                          (flo_srdy[`NUM_PORTS-1:0]),
     .ppi_drdy                          (ppi_drdy),
     .refup_count                       (refup_count[`LL_REFSZ-1:0]),
     .refup_page                        (refup_page[`LL_PG_ASZ-1:0]),
     .refup_srdy                        (refup_srdy),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .ppi_data                          (ppi_data[`PM2F_SZ-1:0]),
     .flo_drdy                          (flo_drdy[`NUM_PORTS-1:0]),
     .ppi_srdy                          (ppi_srdy),
     .refup_drdy                        (refup_drdy));

/* llmanager AUTO_TEMPLATE
 (
  .lnp_pnp                       (lnp_pnp[`LL_LNP_SZ*4-1:0]),
  .drf_page_list              (drf_page_list[`NUM_PORTS*`LL_PG_ASZ*2-1:0]),
  .free_count                 (),
 );
 */
  llmanager #(
              // Parameters
              .lpsz                     (`LL_PG_ASZ),
              .lpdsz                    (`LL_PG_ASZ+1),
              .pages                    (`LL_PAGES),
              .sources                  (`NUM_PORTS),
              .maxref                   (`LL_MAX_REF),
              .refsz                    (`LL_REFSZ),
              .sinks                    (`NUM_PORTS),
              .sksz                     (2)) lm
    (/*AUTOINST*/
     // Outputs
     .par_drdy                          (par_drdy[(`NUM_PORTS)-1:0]),
     .parr_srdy                         (parr_srdy[(`NUM_PORTS)-1:0]),
     .parr_page                         (parr_page[(`LL_PG_ASZ)-1:0]),
     .lnp_drdy                          (lnp_drdy[(`NUM_PORTS)-1:0]),
     .rlp_drdy                          (rlp_drdy[(`NUM_PORTS)-1:0]),
     .rlpr_srdy                         (rlpr_srdy[(`NUM_PORTS)-1:0]),
     .rlpr_data                         (rlpr_data[(`LL_PG_ASZ+1)-1:0]),
     .drf_drdy                          (drf_drdy[(`NUM_PORTS)-1:0]),
     .refup_drdy                        (refup_drdy),
     .pgmem_wr_en                       (pgmem_wr_en),
     .pgmem_wr_addr                     (pgmem_wr_addr[(`LL_PG_ASZ)-1:0]),
     .pgmem_wr_data                     (pgmem_wr_data[(`LL_PG_ASZ+1)-1:0]),
     .pgmem_rd_addr                     (pgmem_rd_addr[(`LL_PG_ASZ)-1:0]),
     .pgmem_rd_en                       (pgmem_rd_en),
     .ref_wr_en                         (ref_wr_en),
     .ref_wr_addr                       (ref_wr_addr[(`LL_PG_ASZ)-1:0]),
     .ref_wr_data                       (ref_wr_data[(`LL_REFSZ)-1:0]),
     .ref_rd_addr                       (ref_rd_addr[(`LL_PG_ASZ)-1:0]),
     .ref_rd_en                         (ref_rd_en),
     .free_count                        (),                      // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .par_srdy                          (par_srdy[(`NUM_PORTS)-1:0]),
     .parr_drdy                         (parr_drdy[(`NUM_PORTS)-1:0]),
     .lnp_srdy                          (lnp_srdy[(`NUM_PORTS)-1:0]),
     .lnp_pnp                           (lnp_pnp[`LL_LNP_SZ*4-1:0]), // Templated
     .rlp_srdy                          (rlp_srdy[(`NUM_PORTS)-1:0]),
     .rlp_rd_page                       (rlp_rd_page[(`NUM_PORTS)*(`LL_PG_ASZ)-1:0]),
     .rlpr_drdy                         (rlpr_drdy[(`NUM_PORTS)-1:0]),
     .drf_srdy                          (drf_srdy[(`NUM_PORTS)-1:0]),
     .drf_page_list                     (drf_page_list[`NUM_PORTS*`LL_PG_ASZ*2-1:0]), // Templated
     .refup_srdy                        (refup_srdy),
     .refup_page                        (refup_page[(`LL_PG_ASZ)-1:0]),
     .refup_count                       (refup_count[(`LL_REFSZ)-1:0]),
     .pgmem_rd_data                     (pgmem_rd_data[(`LL_PG_ASZ+1)-1:0]),
     .ref_rd_data                       (ref_rd_data[(`LL_REFSZ)-1:0]));
   
/* behave2p_mem AUTO_TEMPLATE
 (

     .wr_clk         (clk),
     .rd_clk         (clk),

     .wr_en          (pgmem_wr_en),
     .d_in           (pgmem_wr_data[]),
     .wr_addr        (pgmem_wr_addr[]),

     .rd_en          (pgmem_rd_en),
     .rd_addr        (pgmem_rd_addr[]),
     .d_out          (pgmem_rd_data[]),
 ); 
 */
  behave2p_mem #(.depth   (`LL_PAGES), 
                 .addr_sz (`LL_PG_ASZ),
                 .width   (`LL_PG_ASZ+1)) pglist_mem
    (/*AUTOINST*/
     // Outputs
     .d_out                             (pgmem_rd_data[(`LL_PG_ASZ+1)-1:0]), // Templated
     // Inputs
     .wr_en                             (pgmem_wr_en),           // Templated
     .rd_en                             (pgmem_rd_en),           // Templated
     .wr_clk                            (clk),                   // Templated
     .rd_clk                            (clk),                   // Templated
     .d_in                              (pgmem_wr_data[(`LL_PG_ASZ+1)-1:0]), // Templated
     .rd_addr                           (pgmem_rd_addr[(`LL_PG_ASZ)-1:0]), // Templated
     .wr_addr                           (pgmem_wr_addr[(`LL_PG_ASZ)-1:0])); // Templated

/* behave2p_mem AUTO_TEMPLATE
 (

     .wr_clk         (clk),
     .rd_clk         (clk),

     .wr_en          (ref_wr_en),
     .d_in           (ref_wr_data[]),
     .wr_addr        (ref_wr_addr[]),

     .rd_en          (ref_rd_en),
     .rd_addr        (ref_rd_addr[]),
     .d_out          (ref_rd_data[]),
 ); 
 */
  behave2p_mem #(.depth   (`LL_PAGES), 
                 .addr_sz (`LL_PG_ASZ),
                 .width   (`LL_REFSZ)) ref_mem
    (/*AUTOINST*/
     // Outputs
     .d_out                             (ref_rd_data[(`LL_REFSZ)-1:0]), // Templated
     // Inputs
     .wr_en                             (ref_wr_en),             // Templated
     .rd_en                             (ref_rd_en),             // Templated
     .wr_clk                            (clk),                   // Templated
     .rd_clk                            (clk),                   // Templated
     .d_in                              (ref_wr_data[(`LL_REFSZ)-1:0]), // Templated
     .rd_addr                           (ref_rd_addr[(`LL_PG_ASZ)-1:0]), // Templated
     .wr_addr                           (ref_wr_addr[(`LL_PG_ASZ)-1:0])); // Templated

/* sd_fifo_s AUTO_TEMPLATE
 (
  .c_clk (clk),
  .c_reset (reset),
  .p_clk (clk),
  .p_reset (reset),
  .c_data     (flo_data[`LL_PG_ASZ-1:0]),
  .c_\(.*\)   (flo_\1[@]),
  .p_\(.*\)   (f2d_\1[@]),
  .p_data     (f2d_data_@[`LL_PG_ASZ-1:0]),
 );
 */
  sd_fifo_s #(.width(`LL_PG_ASZ), .depth(8)) cq0
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (flo_drdy[0]),           // Templated
     .p_srdy                            (f2d_srdy[0]),           // Templated
     .p_data                            (f2d_data_0[`LL_PG_ASZ-1:0]), // Templated
     // Inputs
     .c_clk                             (clk),                   // Templated
     .c_reset                           (reset),                 // Templated
     .c_srdy                            (flo_srdy[0]),           // Templated
     .c_data                            (flo_data[`LL_PG_ASZ-1:0]), // Templated
     .p_clk                             (clk),                   // Templated
     .p_reset                           (reset),                 // Templated
     .p_drdy                            (f2d_drdy[0]));           // Templated

  sd_fifo_s #(.width(`LL_PG_ASZ), .depth(8)) cq1
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (flo_drdy[1]),           // Templated
     .p_srdy                            (f2d_srdy[1]),           // Templated
     .p_data                            (f2d_data_1[`LL_PG_ASZ-1:0]), // Templated
     // Inputs
     .c_clk                             (clk),                   // Templated
     .c_reset                           (reset),                 // Templated
     .c_srdy                            (flo_srdy[1]),           // Templated
     .c_data                            (flo_data[`LL_PG_ASZ-1:0]), // Templated
     .p_clk                             (clk),                   // Templated
     .p_reset                           (reset),                 // Templated
     .p_drdy                            (f2d_drdy[1]));           // Templated

  sd_fifo_s #(.width(`LL_PG_ASZ), .depth(8)) cq2
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (flo_drdy[2]),           // Templated
     .p_srdy                            (f2d_srdy[2]),           // Templated
     .p_data                            (f2d_data_2[`LL_PG_ASZ-1:0]), // Templated
     // Inputs
     .c_clk                             (clk),                   // Templated
     .c_reset                           (reset),                 // Templated
     .c_srdy                            (flo_srdy[2]),           // Templated
     .c_data                            (flo_data[`LL_PG_ASZ-1:0]), // Templated
     .p_clk                             (clk),                   // Templated
     .p_reset                           (reset),                 // Templated
     .p_drdy                            (f2d_drdy[2]));           // Templated

  sd_fifo_s #(.width(`LL_PG_ASZ), .depth(8)) cq3
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (flo_drdy[3]),           // Templated
     .p_srdy                            (f2d_srdy[3]),           // Templated
     .p_data                            (f2d_data_3[`LL_PG_ASZ-1:0]), // Templated
     // Inputs
     .c_clk                             (clk),                   // Templated
     .c_reset                           (reset),                 // Templated
     .c_srdy                            (flo_srdy[3]),           // Templated
     .c_data                            (flo_data[`LL_PG_ASZ-1:0]), // Templated
     .p_clk                             (clk),                   // Templated
     .p_reset                           (reset),                 // Templated
     .p_drdy                            (f2d_drdy[3]));           // Templated


endmodule // control_pipe
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/buffers" "../../../rtl/verilog/forks" "../../../rtl/verilog/memory" "../../llmanager")
// End:  
