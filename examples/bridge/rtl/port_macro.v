module port_macro
  #(parameter port_num = 0,
    parameter lpsz = 12,
    parameter lpdsz = 13)
  (input         clk,
   input         reset,

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                drf_drdy,               // To dealloc of deallocator.v
   input [`LL_PG_ASZ-1:0] f2d_data,             // To dealloc of deallocator.v
   input                f2d_srdy,               // To dealloc of deallocator.v
   input                gmii_rx_clk,            // To port_clocking of port_clocking.v, ...
   input                gmii_rx_dv,             // To rx_gigmac of sd_rx_gigmac.v
   input [7:0]          gmii_rxd,               // To rx_gigmac of sd_rx_gigmac.v
   input                lnp_drdy,               // To alloc of allocator.v
   input                par_drdy,               // To alloc of allocator.v
   input [`LL_PG_ASZ-1:0] parr_page,            // To alloc of allocator.v
   input                parr_srdy,              // To alloc of allocator.v
   input                pbra_drdy,              // To alloc of allocator.v
   input                pbrd_drdy,              // To dealloc of deallocator.v
   input [`PFW_SZ-1:0]  pbrr_data,              // To dealloc of deallocator.v
   input                pbrr_srdy,              // To dealloc of deallocator.v
   input                pm2f_drdy,              // To pm2f_join of sd_ajoin2.v
   input                rlp_drdy,               // To dealloc of deallocator.v
   input [`LL_PG_ASZ:0] rlpr_data,              // To dealloc of deallocator.v
   input                rlpr_srdy,              // To dealloc of deallocator.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [`LL_PG_ASZ*2-1:0] drf_page_list,     // From dealloc of deallocator.v
   output               drf_srdy,               // From dealloc of deallocator.v
   output               f2d_drdy,               // From dealloc of deallocator.v
   output               gmii_tx_en,             // From tx_gmii of sd_tx_gigmac.v
   output [7:0]         gmii_txd,               // From tx_gmii of sd_tx_gigmac.v
   output [`LL_LNP_SZ-1:0] lnp_pnp,             // From alloc of allocator.v
   output               lnp_srdy,               // From alloc of allocator.v
   output               par_srdy,               // From alloc of allocator.v
   output               parr_drdy,              // From alloc of allocator.v
   output [`PBR_SZ-1:0] pbra_data,              // From alloc of allocator.v
   output               pbra_srdy,              // From alloc of allocator.v
   output [`PBR_SZ-1:0] pbrd_data,              // From dealloc of deallocator.v
   output               pbrd_srdy,              // From dealloc of deallocator.v
   output               pbrr_drdy,              // From dealloc of deallocator.v
   output [(`PAR_DATA_SZ)+(`LL_PG_ASZ*2)-1:0] pm2f_data,// From pm2f_join of sd_ajoin2.v
   output               pm2f_srdy,              // From pm2f_join of sd_ajoin2.v
   output [`LL_PG_ASZ-1:0] rlp_rd_page,         // From dealloc of deallocator.v
   output               rlp_srdy,               // From dealloc of deallocator.v
   output               rlpr_drdy              // From dealloc of deallocator.v
   // End of automatics
   );

  wire [`RX_USG_SZ-1:0] rx_usage;
  wire [`TX_USG_SZ-1:0] tx_usage;
  wire [`PFW_SZ-1:0]	prx_data;		// From fifo_rx of sd_fifo_b.v
  wire [`PFW_SZ-1:0]	ptx_data;		// From fifo_tx of sd_fifo_b.v
  wire [`PFW_SZ-1:0]	rttx_data;		// From ring_tap of port_ring_tap.v
  wire [1:0] 		rxg_code;		// From rx_sync_fifo of sd_fifo_s.v
  wire [7:0] 		rxg_data;		// From rx_sync_fifo of sd_fifo_s.v
  wire [`PFW_SZ-1:0]	ctx_data;		// From oflow of egr_oflow.v
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire                  a2f_drdy;               // From pm2f_join of sd_ajoin2.v
  wire [`LL_PG_ASZ-1:0] a2f_end;                // From alloc of allocator.v
  wire                  a2f_srdy;               // From alloc of allocator.v
  wire [`LL_PG_ASZ-1:0] a2f_start;              // From alloc of allocator.v
  wire                  crx_abort;              // From con of concentrator.v
  wire                  crx_commit;             // From con of concentrator.v
  wire [`PFW_SZ-1:0]    crx_data;               // From con of concentrator.v
  wire                  crx_drdy;               // From alloc of allocator.v
  wire                  crx_srdy;               // From con of concentrator.v
  wire                  gmii_rx_reset;          // From port_clocking of port_clocking.v
  wire [`PAR_DATA_SZ-1:0] p2f_data;             // From pkt_parse of pkt_parse.v
  wire                  p2f_drdy;               // From pm2f_join of sd_ajoin2.v
  wire                  p2f_srdy;               // From pkt_parse of pkt_parse.v
  wire [1:0]            pdo_code;               // From pkt_parse of pkt_parse.v
  wire [7:0]            pdo_data;               // From pkt_parse of pkt_parse.v
  wire                  pdo_drdy;               // From con of concentrator.v
  wire                  pdo_srdy;               // From pkt_parse of pkt_parse.v
  wire                  ptx_drdy;               // From dst of distributor.v
  wire                  ptx_srdy;               // From dealloc of deallocator.v
  wire [1:0]            rxc_rxg_code;           // From rx_gigmac of sd_rx_gigmac.v
  wire [7:0]            rxc_rxg_data;           // From rx_gigmac of sd_rx_gigmac.v
  wire                  rxc_rxg_drdy;           // From rx_sync_fifo of sd_fifo_s.v
  wire                  rxc_rxg_srdy;           // From rx_gigmac of sd_rx_gigmac.v
  wire                  rxg_drdy;               // From pkt_parse of pkt_parse.v
  wire                  rxg_srdy;               // From rx_sync_fifo of sd_fifo_s.v
  wire [1:0]            txg_code;               // From dst of distributor.v
  wire [7:0]            txg_data;               // From dst of distributor.v
  wire                  txg_drdy;               // From tx_gmii of sd_tx_gigmac.v
  wire                  txg_srdy;               // From dst of distributor.v
  // End of automatics


  port_clocking port_clocking
    (/*AUTOINST*/
     // Outputs
     .gmii_rx_reset                     (gmii_rx_reset),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .gmii_rx_clk                       (gmii_rx_clk));

/*  sd_rx_gigmac AUTO_TEMPLATE
 (
   .clk				(gmii_rx_clk),
   .reset			(gmii_rx_reset),
   .rxg_\(.*\)			(rxc_rxg_\1[]),
 );
 */
  sd_rx_gigmac rx_gigmac
    (
     .cfg_check_crc (1'b0),
     /*AUTOINST*/
     // Outputs
     .rxg_srdy                          (rxc_rxg_srdy),          // Templated
     .rxg_code                          (rxc_rxg_code[1:0]),     // Templated
     .rxg_data                          (rxc_rxg_data[7:0]),     // Templated
     // Inputs
     .clk                               (gmii_rx_clk),           // Templated
     .reset                             (gmii_rx_reset),         // Templated
     .gmii_rx_dv                        (gmii_rx_dv),
     .gmii_rxd                          (gmii_rxd[7:0]),
     .rxg_drdy                          (rxc_rxg_drdy));          // Templated

/* sd_fifo_s AUTO_TEMPLATE
 (
     .c_clk				(gmii_rx_clk),
     .c_reset				(gmii_rx_reset),
     .c_data				({rxc_rxg_code,rxc_rxg_data}),
     .p_data				({rxg_code,rxg_data}),
     .p_clk				(clk),
     .p_reset				(reset),
  .c_\(.*\)			(rxc_rxg_\1[]),
  .p_\(.*\)			(rxg_\1[]),
 );
 */
  sd_fifo_s #(8+2,16,1) rx_sync_fifo
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (rxc_rxg_drdy),          // Templated
     .p_srdy                            (rxg_srdy),              // Templated
     .p_data                            ({rxg_code,rxg_data}),   // Templated
     // Inputs
     .c_clk                             (gmii_rx_clk),           // Templated
     .c_reset                           (gmii_rx_reset),         // Templated
     .c_srdy                            (rxc_rxg_srdy),          // Templated
     .c_data                            ({rxc_rxg_code,rxc_rxg_data}), // Templated
     .p_clk                             (clk),                   // Templated
     .p_reset                           (reset),                 // Templated
     .p_drdy                            (rxg_drdy));              // Templated

  pkt_parse #(port_num) pkt_parse
    (
     /*AUTOINST*/
     // Outputs
     .rxg_drdy                          (rxg_drdy),
     .p2f_srdy                          (p2f_srdy),
     .p2f_data                          (p2f_data[`PAR_DATA_SZ-1:0]),
     .pdo_srdy                          (pdo_srdy),
     .pdo_code                          (pdo_code[1:0]),
     .pdo_data                          (pdo_data[7:0]),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .rxg_srdy                          (rxg_srdy),
     .rxg_code                          (rxg_code[1:0]),
     .rxg_data                          (rxg_data[7:0]),
     .p2f_drdy                          (p2f_drdy),
     .pdo_drdy                          (pdo_drdy));

/* concentrator AUTO_TEMPLATE
 (
    .c_\(.*\)     (pdo_\1[]),
    .p_\(.*\)     (crx_\1[]),
 );
 */
  concentrator con
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (pdo_drdy),              // Templated
     .p_data                            (crx_data[`PFW_SZ-1:0]), // Templated
     .p_srdy                            (crx_srdy),              // Templated
     .p_commit                          (crx_commit),            // Templated
     .p_abort                           (crx_abort),             // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_data                            (pdo_data[7:0]),         // Templated
     .c_code                            (pdo_code[1:0]),         // Templated
     .c_srdy                            (pdo_srdy),              // Templated
     .p_drdy                            (crx_drdy));              // Templated

/* allocator AUTO_TEMPLATE
 (
 );
 */
  allocator alloc
    (/*AUTOINST*/
     // Outputs
     .crx_drdy                          (crx_drdy),
     .par_srdy                          (par_srdy),
     .parr_drdy                         (parr_drdy),
     .lnp_srdy                          (lnp_srdy),
     .lnp_pnp                           (lnp_pnp[`LL_LNP_SZ-1:0]),
     .pbra_data                         (pbra_data[`PBR_SZ-1:0]),
     .pbra_srdy                         (pbra_srdy),
     .a2f_start                         (a2f_start[`LL_PG_ASZ-1:0]),
     .a2f_end                           (a2f_end[`LL_PG_ASZ-1:0]),
     .a2f_srdy                          (a2f_srdy),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .crx_abort                         (crx_abort),
     .crx_commit                        (crx_commit),
     .crx_data                          (crx_data[`PFW_SZ-1:0]),
     .crx_srdy                          (crx_srdy),
     .par_drdy                          (par_drdy),
     .parr_srdy                         (parr_srdy),
     .parr_page                         (parr_page[`LL_PG_ASZ-1:0]),
     .lnp_drdy                          (lnp_drdy),
     .pbra_drdy                         (pbra_drdy),
     .a2f_drdy                          (a2f_drdy));

/* sd_ajoin2 AUTO_TEMPLATE
 (
   .c2_data                     ({a2f_end,a2f_start}),
   .c1_\(.*\)			(p2f_\1[]),
   .c2_\(.*\)			(a2f_\1[]),
   .p_\(.*\)			(pm2f_\1[]),
 );
 */
  sd_ajoin2 #(.c1_width(`PAR_DATA_SZ), .c2_width(`LL_PG_ASZ*2)) pm2f_join
    (/*AUTOINST*/
     // Outputs
     .c1_drdy                           (p2f_drdy),              // Templated
     .c2_drdy                           (a2f_drdy),              // Templated
     .p_srdy                            (pm2f_srdy),             // Templated
     .p_data                            (pm2f_data[(`PAR_DATA_SZ)+(`LL_PG_ASZ*2)-1:0]), // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c1_srdy                           (p2f_srdy),              // Templated
     .c1_data                           (p2f_data[(`PAR_DATA_SZ)-1:0]), // Templated
     .c2_srdy                           (a2f_srdy),              // Templated
     .c2_data                           ({a2f_end,a2f_start}),   // Templated
     .p_drdy                            (pm2f_drdy));             // Templated

  deallocator dealloc
    (/*AUTOINST*/
     // Outputs
     .f2d_drdy                          (f2d_drdy),
     .rlp_srdy                          (rlp_srdy),
     .rlp_rd_page                       (rlp_rd_page[`LL_PG_ASZ-1:0]),
     .rlpr_drdy                         (rlpr_drdy),
     .drf_srdy                          (drf_srdy),
     .drf_page_list                     (drf_page_list[`LL_PG_ASZ*2-1:0]),
     .pbrd_data                         (pbrd_data[`PBR_SZ-1:0]),
     .pbrd_srdy                         (pbrd_srdy),
     .pbrr_drdy                         (pbrr_drdy),
     .ptx_srdy                          (ptx_srdy),
     .ptx_data                          (ptx_data[`PFW_SZ-1:0]),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .port_num                          (port_num[1:0]),
     .f2d_srdy                          (f2d_srdy),
     .f2d_data                          (f2d_data[`LL_PG_ASZ-1:0]),
     .rlp_drdy                          (rlp_drdy),
     .rlpr_srdy                         (rlpr_srdy),
     .rlpr_data                         (rlpr_data[`LL_PG_ASZ:0]),
     .drf_drdy                          (drf_drdy),
     .pbrd_drdy                         (pbrd_drdy),
     .pbrr_srdy                         (pbrr_srdy),
     .pbrr_data                         (pbrr_data[`PFW_SZ-1:0]),
     .ptx_drdy                          (ptx_drdy));

/* distributor AUTO_TEMPLATE
 (
    .p_\(.*\)    (txg_\1[]),
 );
 */
  distributor dst
    (/*AUTOINST*/
     // Outputs
     .ptx_drdy                          (ptx_drdy),
     .p_srdy                            (txg_srdy),              // Templated
     .p_code                            (txg_code[1:0]),         // Templated
     .p_data                            (txg_data[7:0]),         // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .ptx_srdy                          (ptx_srdy),
     .ptx_data                          (ptx_data[`PFW_SZ-1:0]),
     .p_drdy                            (txg_drdy));              // Templated

  sd_tx_gigmac tx_gmii
    (/*AUTOINST*/
     // Outputs
     .gmii_tx_en                        (gmii_tx_en),
     .gmii_txd                          (gmii_txd[7:0]),
     .txg_drdy                          (txg_drdy),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .txg_srdy                          (txg_srdy),
     .txg_code                          (txg_code[1:0]),
     .txg_data                          (txg_data[7:0]));
  
endmodule // port_macro
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/buffers" "../../../rtl/verilog/forks")
// End:  
