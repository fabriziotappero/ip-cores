/*! \author Guy Hutchison
 *  \brief Top level for bridge example
 * 
 *  4-port bridge has 4 GMII interfaces, each one of which has its own RX clock
 *  Port macros contain all packet buffering, and ring interface to communicate
 *  with other port macros.
 *  FIB block receives requests from all ports and sends results back to the
 *  same port containing forwarding information.
 */

module bridge_ex2
  (input  clk,    //% 125 Mhz system clock
   input  reset,  //% Active high system reset
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                gmii_rx_clk_0,          // To p0 of port_macro.v
   input                gmii_rx_clk_1,          // To p1 of port_macro.v
   input                gmii_rx_clk_2,          // To p2 of port_macro.v
   input                gmii_rx_clk_3,          // To p3 of port_macro.v
   input                gmii_rx_dv_0,           // To p0 of port_macro.v
   input                gmii_rx_dv_1,           // To p1 of port_macro.v
   input                gmii_rx_dv_2,           // To p2 of port_macro.v
   input                gmii_rx_dv_3,           // To p3 of port_macro.v
   input [7:0]          gmii_rxd_0,             // To p0 of port_macro.v
   input [7:0]          gmii_rxd_1,             // To p1 of port_macro.v
   input [7:0]          gmii_rxd_2,             // To p2 of port_macro.v
   input [7:0]          gmii_rxd_3,             // To p3 of port_macro.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output               gmii_tx_en_0,           // From p0 of port_macro.v
   output               gmii_tx_en_1,           // From p1 of port_macro.v
   output               gmii_tx_en_2,           // From p2 of port_macro.v
   output               gmii_tx_en_3,           // From p3 of port_macro.v
   output [7:0]         gmii_txd_0,             // From p0 of port_macro.v
   output [7:0]         gmii_txd_1,             // From p1 of port_macro.v
   output [7:0]         gmii_txd_2,             // From p2 of port_macro.v
   output [7:0]         gmii_txd_3             // From p3 of port_macro.v
   // End of automatics
   );

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [(`NUM_PORTS)-1:0] drf_drdy;             // From control0 of control_pipe.v
  wire [95:0]           drf_page_list;          // From p0 of port_macro.v, ...
  wire [3:0]            drf_srdy;               // From p0 of port_macro.v, ...
  wire [`LL_PG_ASZ-1:0] f2d_data_0;             // From control0 of control_pipe.v
  wire [`LL_PG_ASZ-1:0] f2d_data_1;             // From control0 of control_pipe.v
  wire [`LL_PG_ASZ-1:0] f2d_data_2;             // From control0 of control_pipe.v
  wire [`LL_PG_ASZ-1:0] f2d_data_3;             // From control0 of control_pipe.v
  wire [3:0]            f2d_drdy;               // From p0 of port_macro.v, ...
  wire [3:0]            f2d_srdy;               // From control0 of control_pipe.v
  wire [(`NUM_PORTS)-1:0] lnp_drdy;             // From control0 of control_pipe.v
  wire [99:0]           lnp_pnp;                // From p0 of port_macro.v, ...
  wire [3:0]            lnp_srdy;               // From p0 of port_macro.v, ...
  wire [(`NUM_PORTS)-1:0] par_drdy;             // From control0 of control_pipe.v
  wire [3:0]            par_srdy;               // From p0 of port_macro.v, ...
  wire [3:0]            parr_drdy;              // From p0 of port_macro.v, ...
  wire [(`LL_PG_ASZ)-1:0] parr_page;            // From control0 of control_pipe.v
  wire [(`NUM_PORTS)-1:0] parr_srdy;            // From control0 of control_pipe.v
  wire [`PBR_SZ-1:0]    pbra_data_0;            // From p0 of port_macro.v
  wire [`PBR_SZ-1:0]    pbra_data_1;            // From p1 of port_macro.v
  wire [`PBR_SZ-1:0]    pbra_data_2;            // From p2 of port_macro.v
  wire [`PBR_SZ-1:0]    pbra_data_3;            // From p3 of port_macro.v
  wire [3:0]            pbra_drdy;              // From pktbuf of packet_buffer.v
  wire [3:0]            pbra_srdy;              // From p0 of port_macro.v, ...
  wire [`PBR_SZ-1:0]    pbrd_data_0;            // From p0 of port_macro.v
  wire [`PBR_SZ-1:0]    pbrd_data_1;            // From p1 of port_macro.v
  wire [`PBR_SZ-1:0]    pbrd_data_2;            // From p2 of port_macro.v
  wire [`PBR_SZ-1:0]    pbrd_data_3;            // From p3 of port_macro.v
  wire [3:0]            pbrd_drdy;              // From pktbuf of packet_buffer.v
  wire [3:0]            pbrd_srdy;              // From p0 of port_macro.v, ...
  wire [`PFW_SZ-1:0]    pbrr_data;              // From pktbuf of packet_buffer.v
  wire [3:0]            pbrr_drdy;              // From p0 of port_macro.v, ...
  wire [3:0]            pbrr_srdy;              // From pktbuf of packet_buffer.v
  wire [(`PAR_DATA_SZ)+(`LL_PG_ASZ*2)-1:0] pm2f_data_0;// From p0 of port_macro.v
  wire [(`PAR_DATA_SZ)+(`LL_PG_ASZ*2)-1:0] pm2f_data_1;// From p1 of port_macro.v
  wire [(`PAR_DATA_SZ)+(`LL_PG_ASZ*2)-1:0] pm2f_data_2;// From p2 of port_macro.v
  wire [(`PAR_DATA_SZ)+(`LL_PG_ASZ*2)-1:0] pm2f_data_3;// From p3 of port_macro.v
  wire [`NUM_PORTS-1:0] pm2f_drdy;              // From control0 of control_pipe.v
  wire [3:0]            pm2f_srdy;              // From p0 of port_macro.v, ...
  wire [(`NUM_PORTS)-1:0] rlp_drdy;             // From control0 of control_pipe.v
  wire [47:0]           rlp_rd_page;            // From p0 of port_macro.v, ...
  wire [3:0]            rlp_srdy;               // From p0 of port_macro.v, ...
  wire [(`LL_PG_ASZ+1)-1:0] rlpr_data;          // From control0 of control_pipe.v
  wire [3:0]            rlpr_drdy;              // From p0 of port_macro.v, ...
  wire [(`NUM_PORTS)-1:0] rlpr_srdy;            // From control0 of control_pipe.v
  // End of automatics

  /* port_macro AUTO_TEMPLATE
   (
   .clk				(clk),
   .reset			(reset),
   .p2f_srdy				(p2f_srdy[@]),
   .p2f_drdy				(p2f_drdy[@]),
   .fli_srdy				(flo_srdy[@]),
   .fli_drdy				(flo_drdy[@]),
   .fli_data                            (flo_data),
   .drf_srdy (drf_srdy[@]),
   .drf_drdy (drf_drdy[@]),
   .f2d_srdy (f2d_srdy[@]),
   .f2d_drdy (f2d_drdy[@]),
   .par_srdy (par_srdy[@]),
   .par_drdy (par_drdy[@]),
   .parr_srdy (parr_srdy[@]),
   .parr_drdy (parr_drdy[@]),
   .parr_page  (parr_page[`LL_PG_ASZ-1:0]),
   .lnp_srdy  (lnp_srdy[@]),
   .lnp_drdy  (lnp_drdy[@]),
   .rlp_srdy  (rlp_srdy[@]),
   .rlp_drdy  (rlp_drdy[@]),
   .rlpr_srdy  (rlpr_srdy[@]),
   .rlpr_drdy  (rlpr_drdy[@]),
   .rlpr_data  (rlpr_data[`LL_PG_ASZ:0]),
   .pbrr_data  (pbrr_data[`PFW_SZ-1:0]),
   // page size is 12 bits, use 24 bits for each drf port, 25 bits for link port
   .drf_page_list                       (drf_page_list[@"(- (* (+ @ 1) 24) 1)":@"(* @ 24)"]),
   .lnp_pnp                           (lnp_pnp[@"(- (* (+ @ 1) 25) 1)":@"(* @ 25)"]),
   // page address size is 12 bits
   .rlp_rd_page                       (rlp_rd_page[@"(- (* (+ @ 1) 12) 1)":@"(* @ 12)"]),
   .pm2f_srdy (pm2f_srdy[@]),
   .pm2f_drdy (pm2f_drdy[@]),
   .pbra_srdy (pbra_srdy[@]),
   .pbra_drdy (pbra_drdy[@]),
   .pbrd_srdy (pbrd_srdy[@]),
   .pbrd_drdy (pbrd_drdy[@]),
   .pbrr_srdy (pbrr_srdy[@]),
   .pbrr_drdy (pbrr_drdy[@]),
  .\(.*\)     (\1_@[]),
   );
   */
  port_macro #(0) p0
    (/*AUTOINST*/
     // Outputs
     .drf_page_list                     (drf_page_list[23:0]),   // Templated
     .drf_srdy                          (drf_srdy[0]),           // Templated
     .f2d_drdy                          (f2d_drdy[0]),           // Templated
     .gmii_tx_en                        (gmii_tx_en_0),          // Templated
     .gmii_txd                          (gmii_txd_0[7:0]),       // Templated
     .lnp_pnp                           (lnp_pnp[24:0]),         // Templated
     .lnp_srdy                          (lnp_srdy[0]),           // Templated
     .par_srdy                          (par_srdy[0]),           // Templated
     .parr_drdy                         (parr_drdy[0]),          // Templated
     .pbra_data                         (pbra_data_0[`PBR_SZ-1:0]), // Templated
     .pbra_srdy                         (pbra_srdy[0]),          // Templated
     .pbrd_data                         (pbrd_data_0[`PBR_SZ-1:0]), // Templated
     .pbrd_srdy                         (pbrd_srdy[0]),          // Templated
     .pbrr_drdy                         (pbrr_drdy[0]),          // Templated
     .pm2f_data                         (pm2f_data_0[(`PAR_DATA_SZ)+(`LL_PG_ASZ*2)-1:0]), // Templated
     .pm2f_srdy                         (pm2f_srdy[0]),          // Templated
     .rlp_rd_page                       (rlp_rd_page[11:0]),     // Templated
     .rlp_srdy                          (rlp_srdy[0]),           // Templated
     .rlpr_drdy                         (rlpr_drdy[0]),          // Templated
     // Inputs
     .clk                               (clk),                   // Templated
     .reset                             (reset),                 // Templated
     .drf_drdy                          (drf_drdy[0]),           // Templated
     .f2d_data                          (f2d_data_0[`LL_PG_ASZ-1:0]), // Templated
     .f2d_srdy                          (f2d_srdy[0]),           // Templated
     .gmii_rx_clk                       (gmii_rx_clk_0),         // Templated
     .gmii_rx_dv                        (gmii_rx_dv_0),          // Templated
     .gmii_rxd                          (gmii_rxd_0[7:0]),       // Templated
     .lnp_drdy                          (lnp_drdy[0]),           // Templated
     .par_drdy                          (par_drdy[0]),           // Templated
     .parr_page                         (parr_page[`LL_PG_ASZ-1:0]), // Templated
     .parr_srdy                         (parr_srdy[0]),          // Templated
     .pbra_drdy                         (pbra_drdy[0]),          // Templated
     .pbrd_drdy                         (pbrd_drdy[0]),          // Templated
     .pbrr_data                         (pbrr_data[`PFW_SZ-1:0]), // Templated
     .pbrr_srdy                         (pbrr_srdy[0]),          // Templated
     .pm2f_drdy                         (pm2f_drdy[0]),          // Templated
     .rlp_drdy                          (rlp_drdy[0]),           // Templated
     .rlpr_data                         (rlpr_data[`LL_PG_ASZ:0]), // Templated
     .rlpr_srdy                         (rlpr_srdy[0]));          // Templated

  port_macro #(1) p1
    (/*AUTOINST*/
     // Outputs
     .drf_page_list                     (drf_page_list[47:24]),  // Templated
     .drf_srdy                          (drf_srdy[1]),           // Templated
     .f2d_drdy                          (f2d_drdy[1]),           // Templated
     .gmii_tx_en                        (gmii_tx_en_1),          // Templated
     .gmii_txd                          (gmii_txd_1[7:0]),       // Templated
     .lnp_pnp                           (lnp_pnp[49:25]),        // Templated
     .lnp_srdy                          (lnp_srdy[1]),           // Templated
     .par_srdy                          (par_srdy[1]),           // Templated
     .parr_drdy                         (parr_drdy[1]),          // Templated
     .pbra_data                         (pbra_data_1[`PBR_SZ-1:0]), // Templated
     .pbra_srdy                         (pbra_srdy[1]),          // Templated
     .pbrd_data                         (pbrd_data_1[`PBR_SZ-1:0]), // Templated
     .pbrd_srdy                         (pbrd_srdy[1]),          // Templated
     .pbrr_drdy                         (pbrr_drdy[1]),          // Templated
     .pm2f_data                         (pm2f_data_1[(`PAR_DATA_SZ)+(`LL_PG_ASZ*2)-1:0]), // Templated
     .pm2f_srdy                         (pm2f_srdy[1]),          // Templated
     .rlp_rd_page                       (rlp_rd_page[23:12]),    // Templated
     .rlp_srdy                          (rlp_srdy[1]),           // Templated
     .rlpr_drdy                         (rlpr_drdy[1]),          // Templated
     // Inputs
     .clk                               (clk),                   // Templated
     .reset                             (reset),                 // Templated
     .drf_drdy                          (drf_drdy[1]),           // Templated
     .f2d_data                          (f2d_data_1[`LL_PG_ASZ-1:0]), // Templated
     .f2d_srdy                          (f2d_srdy[1]),           // Templated
     .gmii_rx_clk                       (gmii_rx_clk_1),         // Templated
     .gmii_rx_dv                        (gmii_rx_dv_1),          // Templated
     .gmii_rxd                          (gmii_rxd_1[7:0]),       // Templated
     .lnp_drdy                          (lnp_drdy[1]),           // Templated
     .par_drdy                          (par_drdy[1]),           // Templated
     .parr_page                         (parr_page[`LL_PG_ASZ-1:0]), // Templated
     .parr_srdy                         (parr_srdy[1]),          // Templated
     .pbra_drdy                         (pbra_drdy[1]),          // Templated
     .pbrd_drdy                         (pbrd_drdy[1]),          // Templated
     .pbrr_data                         (pbrr_data[`PFW_SZ-1:0]), // Templated
     .pbrr_srdy                         (pbrr_srdy[1]),          // Templated
     .pm2f_drdy                         (pm2f_drdy[1]),          // Templated
     .rlp_drdy                          (rlp_drdy[1]),           // Templated
     .rlpr_data                         (rlpr_data[`LL_PG_ASZ:0]), // Templated
     .rlpr_srdy                         (rlpr_srdy[1]));          // Templated

  port_macro #(2) p2
    (/*AUTOINST*/
     // Outputs
     .drf_page_list                     (drf_page_list[71:48]),  // Templated
     .drf_srdy                          (drf_srdy[2]),           // Templated
     .f2d_drdy                          (f2d_drdy[2]),           // Templated
     .gmii_tx_en                        (gmii_tx_en_2),          // Templated
     .gmii_txd                          (gmii_txd_2[7:0]),       // Templated
     .lnp_pnp                           (lnp_pnp[74:50]),        // Templated
     .lnp_srdy                          (lnp_srdy[2]),           // Templated
     .par_srdy                          (par_srdy[2]),           // Templated
     .parr_drdy                         (parr_drdy[2]),          // Templated
     .pbra_data                         (pbra_data_2[`PBR_SZ-1:0]), // Templated
     .pbra_srdy                         (pbra_srdy[2]),          // Templated
     .pbrd_data                         (pbrd_data_2[`PBR_SZ-1:0]), // Templated
     .pbrd_srdy                         (pbrd_srdy[2]),          // Templated
     .pbrr_drdy                         (pbrr_drdy[2]),          // Templated
     .pm2f_data                         (pm2f_data_2[(`PAR_DATA_SZ)+(`LL_PG_ASZ*2)-1:0]), // Templated
     .pm2f_srdy                         (pm2f_srdy[2]),          // Templated
     .rlp_rd_page                       (rlp_rd_page[35:24]),    // Templated
     .rlp_srdy                          (rlp_srdy[2]),           // Templated
     .rlpr_drdy                         (rlpr_drdy[2]),          // Templated
     // Inputs
     .clk                               (clk),                   // Templated
     .reset                             (reset),                 // Templated
     .drf_drdy                          (drf_drdy[2]),           // Templated
     .f2d_data                          (f2d_data_2[`LL_PG_ASZ-1:0]), // Templated
     .f2d_srdy                          (f2d_srdy[2]),           // Templated
     .gmii_rx_clk                       (gmii_rx_clk_2),         // Templated
     .gmii_rx_dv                        (gmii_rx_dv_2),          // Templated
     .gmii_rxd                          (gmii_rxd_2[7:0]),       // Templated
     .lnp_drdy                          (lnp_drdy[2]),           // Templated
     .par_drdy                          (par_drdy[2]),           // Templated
     .parr_page                         (parr_page[`LL_PG_ASZ-1:0]), // Templated
     .parr_srdy                         (parr_srdy[2]),          // Templated
     .pbra_drdy                         (pbra_drdy[2]),          // Templated
     .pbrd_drdy                         (pbrd_drdy[2]),          // Templated
     .pbrr_data                         (pbrr_data[`PFW_SZ-1:0]), // Templated
     .pbrr_srdy                         (pbrr_srdy[2]),          // Templated
     .pm2f_drdy                         (pm2f_drdy[2]),          // Templated
     .rlp_drdy                          (rlp_drdy[2]),           // Templated
     .rlpr_data                         (rlpr_data[`LL_PG_ASZ:0]), // Templated
     .rlpr_srdy                         (rlpr_srdy[2]));          // Templated

  port_macro #(3) p3
    (/*AUTOINST*/
     // Outputs
     .drf_page_list                     (drf_page_list[95:72]),  // Templated
     .drf_srdy                          (drf_srdy[3]),           // Templated
     .f2d_drdy                          (f2d_drdy[3]),           // Templated
     .gmii_tx_en                        (gmii_tx_en_3),          // Templated
     .gmii_txd                          (gmii_txd_3[7:0]),       // Templated
     .lnp_pnp                           (lnp_pnp[99:75]),        // Templated
     .lnp_srdy                          (lnp_srdy[3]),           // Templated
     .par_srdy                          (par_srdy[3]),           // Templated
     .parr_drdy                         (parr_drdy[3]),          // Templated
     .pbra_data                         (pbra_data_3[`PBR_SZ-1:0]), // Templated
     .pbra_srdy                         (pbra_srdy[3]),          // Templated
     .pbrd_data                         (pbrd_data_3[`PBR_SZ-1:0]), // Templated
     .pbrd_srdy                         (pbrd_srdy[3]),          // Templated
     .pbrr_drdy                         (pbrr_drdy[3]),          // Templated
     .pm2f_data                         (pm2f_data_3[(`PAR_DATA_SZ)+(`LL_PG_ASZ*2)-1:0]), // Templated
     .pm2f_srdy                         (pm2f_srdy[3]),          // Templated
     .rlp_rd_page                       (rlp_rd_page[47:36]),    // Templated
     .rlp_srdy                          (rlp_srdy[3]),           // Templated
     .rlpr_drdy                         (rlpr_drdy[3]),          // Templated
     // Inputs
     .clk                               (clk),                   // Templated
     .reset                             (reset),                 // Templated
     .drf_drdy                          (drf_drdy[3]),           // Templated
     .f2d_data                          (f2d_data_3[`LL_PG_ASZ-1:0]), // Templated
     .f2d_srdy                          (f2d_srdy[3]),           // Templated
     .gmii_rx_clk                       (gmii_rx_clk_3),         // Templated
     .gmii_rx_dv                        (gmii_rx_dv_3),          // Templated
     .gmii_rxd                          (gmii_rxd_3[7:0]),       // Templated
     .lnp_drdy                          (lnp_drdy[3]),           // Templated
     .par_drdy                          (par_drdy[3]),           // Templated
     .parr_page                         (parr_page[`LL_PG_ASZ-1:0]), // Templated
     .parr_srdy                         (parr_srdy[3]),          // Templated
     .pbra_drdy                         (pbra_drdy[3]),          // Templated
     .pbrd_drdy                         (pbrd_drdy[3]),          // Templated
     .pbrr_data                         (pbrr_data[`PFW_SZ-1:0]), // Templated
     .pbrr_srdy                         (pbrr_srdy[3]),          // Templated
     .pm2f_drdy                         (pm2f_drdy[3]),          // Templated
     .rlp_drdy                          (rlp_drdy[3]),           // Templated
     .rlpr_data                         (rlpr_data[`LL_PG_ASZ:0]), // Templated
     .rlpr_srdy                         (rlpr_srdy[3]));          // Templated

  control_pipe control0
    (/*AUTOINST*/
     // Outputs
     .drf_drdy                          (drf_drdy[(`NUM_PORTS)-1:0]),
     .f2d_data_0                        (f2d_data_0[`LL_PG_ASZ-1:0]),
     .f2d_data_1                        (f2d_data_1[`LL_PG_ASZ-1:0]),
     .f2d_data_2                        (f2d_data_2[`LL_PG_ASZ-1:0]),
     .f2d_data_3                        (f2d_data_3[`LL_PG_ASZ-1:0]),
     .f2d_srdy                          (f2d_srdy[3:0]),
     .lnp_drdy                          (lnp_drdy[(`NUM_PORTS)-1:0]),
     .par_drdy                          (par_drdy[(`NUM_PORTS)-1:0]),
     .parr_page                         (parr_page[(`LL_PG_ASZ)-1:0]),
     .parr_srdy                         (parr_srdy[(`NUM_PORTS)-1:0]),
     .pm2f_drdy                         (pm2f_drdy[`NUM_PORTS-1:0]),
     .rlp_drdy                          (rlp_drdy[(`NUM_PORTS)-1:0]),
     .rlpr_data                         (rlpr_data[(`LL_PG_ASZ+1)-1:0]),
     .rlpr_srdy                         (rlpr_srdy[(`NUM_PORTS)-1:0]),
     // Inputs
     .pm2f_data_0                       (pm2f_data_0[`PM2F_SZ-1:0]),
     .pm2f_data_1                       (pm2f_data_1[`PM2F_SZ-1:0]),
     .pm2f_data_2                       (pm2f_data_2[`PM2F_SZ-1:0]),
     .pm2f_data_3                       (pm2f_data_3[`PM2F_SZ-1:0]),
     .clk                               (clk),
     .drf_page_list                     (drf_page_list[`NUM_PORTS*`LL_PG_ASZ*2-1:0]),
     .drf_srdy                          (drf_srdy[(`NUM_PORTS)-1:0]),
     .f2d_drdy                          (f2d_drdy[3:0]),
     .lnp_pnp                           (lnp_pnp[`LL_LNP_SZ*4-1:0]),
     .lnp_srdy                          (lnp_srdy[(`NUM_PORTS)-1:0]),
     .par_srdy                          (par_srdy[(`NUM_PORTS)-1:0]),
     .parr_drdy                         (parr_drdy[(`NUM_PORTS)-1:0]),
     .pm2f_srdy                         (pm2f_srdy[`NUM_PORTS-1:0]),
     .reset                             (reset),
     .rlp_rd_page                       (rlp_rd_page[(`NUM_PORTS)*(`LL_PG_ASZ)-1:0]),
     .rlp_srdy                          (rlp_srdy[(`NUM_PORTS)-1:0]),
     .rlpr_drdy                         (rlpr_drdy[(`NUM_PORTS)-1:0]));

  packet_buffer pktbuf
    (/*AUTOINST*/
     // Outputs
     .pbra_drdy                         (pbra_drdy[3:0]),
     .pbrd_drdy                         (pbrd_drdy[3:0]),
     .pbrr_srdy                         (pbrr_srdy[3:0]),
     .pbrr_data                         (pbrr_data[`PFW_SZ-1:0]),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .pbra_srdy                         (pbra_srdy[3:0]),
     .pbra_data_0                       (pbra_data_0[`PBR_SZ-1:0]),
     .pbra_data_1                       (pbra_data_1[`PBR_SZ-1:0]),
     .pbra_data_2                       (pbra_data_2[`PBR_SZ-1:0]),
     .pbra_data_3                       (pbra_data_3[`PBR_SZ-1:0]),
     .pbrd_data_0                       (pbrd_data_0[`PBR_SZ-1:0]),
     .pbrd_data_1                       (pbrd_data_1[`PBR_SZ-1:0]),
     .pbrd_data_2                       (pbrd_data_2[`PBR_SZ-1:0]),
     .pbrd_data_3                       (pbrd_data_3[`PBR_SZ-1:0]),
     .pbrd_srdy                         (pbrd_srdy[3:0]),
     .pbrr_drdy                         (pbrr_drdy[3:0]));

endmodule // bridge_ex1
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/buffers" "../../../rtl/verilog/forks")
// End:  
