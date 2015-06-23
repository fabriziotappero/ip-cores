// Top level for bridge example
//
// 4-port bridge has 4 GMII interfaces, each one of which has its own RX clock
// Port macros contain all packet buffering, and ring interface to communicate
// with other port macros.
// FIB block receives requests from all ports and sends results back to the
// same port containing forwarding information.

module bridge_ex1
  (input  clk,
   input  reset,
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

  wire [`PRW_SZ-1:0]	ri_data_0;
  wire [`PRW_SZ-1:0]	ri_data_1;
  wire [`PRW_SZ-1:0]	ri_data_2;
  wire [`PRW_SZ-1:0]	ri_data_3;
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [`NUM_PORTS-1:0] flo_data;               // From fib_lookup of fib_lookup.v
  wire [3:0]            flo_drdy;               // From p0 of port_macro.v, ...
  wire [`NUM_PORTS-1:0] flo_srdy;               // From fib_lookup of fib_lookup.v
  wire [`PAR_DATA_SZ-1:0] p2f_data_0;           // From p0 of port_macro.v
  wire [`PAR_DATA_SZ-1:0] p2f_data_1;           // From p1 of port_macro.v
  wire [`PAR_DATA_SZ-1:0] p2f_data_2;           // From p2 of port_macro.v
  wire [`PAR_DATA_SZ-1:0] p2f_data_3;           // From p3 of port_macro.v
  wire [`NUM_PORTS-1:0] p2f_drdy;               // From fib_arb of sd_rrmux.v
  wire [3:0]            p2f_srdy;               // From p0 of port_macro.v, ...
  wire [`PAR_DATA_SZ-1:0] ppi_data;             // From fib_arb of sd_rrmux.v
  wire                  ppi_drdy;               // From fib_lookup of fib_lookup.v
  wire                  ppi_srdy;               // From fib_arb of sd_rrmux.v
  wire [`NUM_PORTS-1:0] rarb_ack;               // From ring_arb of ring_arb.v
  wire [3:0]            rarb_req;               // From p0 of port_macro.v, ...
  wire                  ri_drdy_0;              // From p0 of port_macro.v
  wire                  ri_drdy_1;              // From p1 of port_macro.v
  wire                  ri_drdy_2;              // From p2 of port_macro.v
  wire                  ri_drdy_3;              // From p3 of port_macro.v
  wire                  ri_srdy_0;              // From p3 of port_macro.v
  wire                  ri_srdy_1;              // From p0 of port_macro.v
  wire                  ri_srdy_2;              // From p1 of port_macro.v
  wire                  ri_srdy_3;              // From p2 of port_macro.v
  // End of automatics

  /* port_macro AUTO_TEMPLATE
   (
   .clk				(clk),
   .reset			(reset),
   .ri_data                     (ri_data_@),
   .rarb_\(.*\)                 (rarb_\1[@]),
   .ro_\(.*\)        (ri_\1_@"(% (+ 1 @) 4)"),
   .p2f_srdy				(p2f_srdy[@]),
   .p2f_drdy				(p2f_drdy[@]),
   .fli_srdy				(flo_srdy[@]),
   .fli_drdy				(flo_drdy[@]),
   .fli_data                            (flo_data),
   .\(.*\)     (\1_@[]),
   );
   */
  port_macro #(0) p0
    (/*AUTOINST*/
     // Outputs
     .ro_data                           (ri_data_1),             // Templated
     .rarb_req                          (rarb_req[0]),           // Templated
     .fli_drdy                          (flo_drdy[0]),           // Templated
     .gmii_tx_en                        (gmii_tx_en_0),          // Templated
     .gmii_txd                          (gmii_txd_0[7:0]),       // Templated
     .p2f_data                          (p2f_data_0[`PAR_DATA_SZ-1:0]), // Templated
     .p2f_srdy                          (p2f_srdy[0]),           // Templated
     .ri_drdy                           (ri_drdy_0),             // Templated
     .ro_srdy                           (ri_srdy_1),             // Templated
     // Inputs
     .clk                               (clk),                   // Templated
     .reset                             (reset),                 // Templated
     .ri_data                           (ri_data_0),             // Templated
     .fli_data                          (flo_data),              // Templated
     .fli_srdy                          (flo_srdy[0]),           // Templated
     .gmii_rx_clk                       (gmii_rx_clk_0),         // Templated
     .gmii_rx_dv                        (gmii_rx_dv_0),          // Templated
     .gmii_rxd                          (gmii_rxd_0[7:0]),       // Templated
     .p2f_drdy                          (p2f_drdy[0]),           // Templated
     .rarb_ack                          (rarb_ack[0]),           // Templated
     .ri_srdy                           (ri_srdy_0),             // Templated
     .ro_drdy                           (ri_drdy_1));             // Templated

  port_macro #(1) p1
    (/*AUTOINST*/
     // Outputs
     .ro_data                           (ri_data_2),             // Templated
     .rarb_req                          (rarb_req[1]),           // Templated
     .fli_drdy                          (flo_drdy[1]),           // Templated
     .gmii_tx_en                        (gmii_tx_en_1),          // Templated
     .gmii_txd                          (gmii_txd_1[7:0]),       // Templated
     .p2f_data                          (p2f_data_1[`PAR_DATA_SZ-1:0]), // Templated
     .p2f_srdy                          (p2f_srdy[1]),           // Templated
     .ri_drdy                           (ri_drdy_1),             // Templated
     .ro_srdy                           (ri_srdy_2),             // Templated
     // Inputs
     .clk                               (clk),                   // Templated
     .reset                             (reset),                 // Templated
     .ri_data                           (ri_data_1),             // Templated
     .fli_data                          (flo_data),              // Templated
     .fli_srdy                          (flo_srdy[1]),           // Templated
     .gmii_rx_clk                       (gmii_rx_clk_1),         // Templated
     .gmii_rx_dv                        (gmii_rx_dv_1),          // Templated
     .gmii_rxd                          (gmii_rxd_1[7:0]),       // Templated
     .p2f_drdy                          (p2f_drdy[1]),           // Templated
     .rarb_ack                          (rarb_ack[1]),           // Templated
     .ri_srdy                           (ri_srdy_1),             // Templated
     .ro_drdy                           (ri_drdy_2));             // Templated

  port_macro #(2) p2
    (/*AUTOINST*/
     // Outputs
     .ro_data                           (ri_data_3),             // Templated
     .rarb_req                          (rarb_req[2]),           // Templated
     .fli_drdy                          (flo_drdy[2]),           // Templated
     .gmii_tx_en                        (gmii_tx_en_2),          // Templated
     .gmii_txd                          (gmii_txd_2[7:0]),       // Templated
     .p2f_data                          (p2f_data_2[`PAR_DATA_SZ-1:0]), // Templated
     .p2f_srdy                          (p2f_srdy[2]),           // Templated
     .ri_drdy                           (ri_drdy_2),             // Templated
     .ro_srdy                           (ri_srdy_3),             // Templated
     // Inputs
     .clk                               (clk),                   // Templated
     .reset                             (reset),                 // Templated
     .ri_data                           (ri_data_2),             // Templated
     .fli_data                          (flo_data),              // Templated
     .fli_srdy                          (flo_srdy[2]),           // Templated
     .gmii_rx_clk                       (gmii_rx_clk_2),         // Templated
     .gmii_rx_dv                        (gmii_rx_dv_2),          // Templated
     .gmii_rxd                          (gmii_rxd_2[7:0]),       // Templated
     .p2f_drdy                          (p2f_drdy[2]),           // Templated
     .rarb_ack                          (rarb_ack[2]),           // Templated
     .ri_srdy                           (ri_srdy_2),             // Templated
     .ro_drdy                           (ri_drdy_3));             // Templated

  port_macro #(3) p3
    (/*AUTOINST*/
     // Outputs
     .ro_data                           (ri_data_0),             // Templated
     .rarb_req                          (rarb_req[3]),           // Templated
     .fli_drdy                          (flo_drdy[3]),           // Templated
     .gmii_tx_en                        (gmii_tx_en_3),          // Templated
     .gmii_txd                          (gmii_txd_3[7:0]),       // Templated
     .p2f_data                          (p2f_data_3[`PAR_DATA_SZ-1:0]), // Templated
     .p2f_srdy                          (p2f_srdy[3]),           // Templated
     .ri_drdy                           (ri_drdy_3),             // Templated
     .ro_srdy                           (ri_srdy_0),             // Templated
     // Inputs
     .clk                               (clk),                   // Templated
     .reset                             (reset),                 // Templated
     .ri_data                           (ri_data_3),             // Templated
     .fli_data                          (flo_data),              // Templated
     .fli_srdy                          (flo_srdy[3]),           // Templated
     .gmii_rx_clk                       (gmii_rx_clk_3),         // Templated
     .gmii_rx_dv                        (gmii_rx_dv_3),          // Templated
     .gmii_rxd                          (gmii_rxd_3[7:0]),       // Templated
     .p2f_drdy                          (p2f_drdy[3]),           // Templated
     .rarb_ack                          (rarb_ack[3]),           // Templated
     .ri_srdy                           (ri_srdy_3),             // Templated
     .ro_drdy                           (ri_drdy_0));             // Templated

/*  sd_rrmux AUTO_TEMPLATE
 (
 .p_grant (),
 .p_data  (ppi_data[`PAR_DATA_SZ-1:0]),
 .c_data  ({p2f_data_3,p2f_data_2,p2f_data_1,p2f_data_0}),
 .c_srdy  (p2f_srdy[`NUM_PORTS-1:0]),
 .c_drdy  (p2f_drdy[`NUM_PORTS-1:0]),
 .c_\(.*\)   (p2f_\1[]),
 .p_\(.*\)   (ppi_\1[]),
 );
 */
  sd_rrmux #(
              // Parameters
              .width                    (`PAR_DATA_SZ),
              .inputs                   (`NUM_PORTS),
              .mode                     (0),
              .fast_arb                 (1)) fib_arb
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (p2f_drdy[`NUM_PORTS-1:0]), // Templated
     .p_data                            (ppi_data[`PAR_DATA_SZ-1:0]), // Templated
     .p_grant                           (),                      // Templated
     .p_srdy                            (ppi_srdy),              // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_data                            ({p2f_data_3,p2f_data_2,p2f_data_1,p2f_data_0}), // Templated
     .c_srdy                            (p2f_srdy[`NUM_PORTS-1:0]), // Templated
     .p_drdy                            (ppi_drdy));              // Templated

  fib_lookup fib_lookup
    (/*AUTOINST*/
     // Outputs
     .flo_data                          (flo_data[`NUM_PORTS-1:0]),
     .flo_srdy                          (flo_srdy[`NUM_PORTS-1:0]),
     .ppi_drdy                          (ppi_drdy),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .ppi_data                          (ppi_data[`PAR_DATA_SZ-1:0]),
     .flo_drdy                          (flo_drdy[`NUM_PORTS-1:0]),
     .ppi_srdy                          (ppi_srdy));

  ring_arb ring_arb
    (/*AUTOINST*/
     // Outputs
     .rarb_ack                          (rarb_ack[`NUM_PORTS-1:0]),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .rarb_req                          (rarb_req[`NUM_PORTS-1:0]));

endmodule // bridge_ex1
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/buffers" "../../../rtl/verilog/forks")
// End:  
