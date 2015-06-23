// Inputs are ri (Ring In), ro (Ring Out),
// fli (FIB lookup in), prx (port in/RX), and ptx (port out/TX)

module port_ring_tap
  #(parameter portnum = 0,
    parameter rdp_sz = `PRW_SZ,
    parameter pdp_sz = `PFW_SZ
    )
  (
   input         clk,
   input         reset,

   input         ri_srdy,
   output        ri_drdy,
   input [rdp_sz-1:0] ri_data,
   
   input         prx_srdy,
   output        prx_drdy,
   input [pdp_sz-1:0] prx_data,

   output        ro_srdy,
   input         ro_drdy,
   output [rdp_sz-1:0] ro_data,
   
   output        ptx_srdy,
   input         ptx_drdy,
   output [pdp_sz-1:0] ptx_data,

   input         fli_srdy,
   output        fli_drdy,
   input [`NUM_PORTS-1:0] fli_data,

   output        rarb_req,
   input         rarb_ack
   );

  wire [`PRW_SZ-1:0]	lri_data;		// From tc_ri of sd_input.v
  wire [`NUM_PORTS-1:0]	lfli_data;		// From tc_fli of sd_input.v
  wire [`PFW_SZ-1:0]	lprx_data;		// From tc_prx of sd_input.v
  wire [`PFW_SZ-1:0]	lptx_data;		// From fsm of port_ring_tap_fsm.v
  wire [`PRW_SZ-1:0]	lro_data;		// From fsm of port_ring_tap_fsm.v
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire                  lfli_drdy;              // From fsm of port_ring_tap_fsm.v
  wire                  lfli_srdy;              // From tc_fli of sd_input.v
  wire                  lprx_drdy;              // From fsm of port_ring_tap_fsm.v
  wire                  lprx_srdy;              // From tc_prx of sd_input.v
  wire                  lptx_drdy;              // From tc_ptx of sd_output.v
  wire                  lptx_srdy;              // From fsm of port_ring_tap_fsm.v
  wire                  lri_drdy;               // From fsm of port_ring_tap_fsm.v
  wire                  lri_srdy;               // From tc_ri of sd_input.v
  wire                  lro_drdy;               // From tc_ro of sd_output.v
  wire                  lro_srdy;               // From fsm of port_ring_tap_fsm.v
  // End of automatics
  
  /* sd_input AUTO_TEMPLATE "tc_\(.*\)"
   (
    .c_\(.*\)     (@_\1),
    .ip_\(.*\)    (l@_\1),
   );
   */

  sd_input #(rdp_sz) tc_ri
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (ri_drdy),               // Templated
     .ip_srdy                           (lri_srdy),              // Templated
     .ip_data                           (lri_data),              // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_srdy                            (ri_srdy),               // Templated
     .c_data                            (ri_data),               // Templated
     .ip_drdy                           (lri_drdy));              // Templated
  
  sd_input #(pdp_sz) tc_prx
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (prx_drdy),              // Templated
     .ip_srdy                           (lprx_srdy),             // Templated
     .ip_data                           (lprx_data),             // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_srdy                            (prx_srdy),              // Templated
     .c_data                            (prx_data),              // Templated
     .ip_drdy                           (lprx_drdy));             // Templated
  
  sd_input #(`NUM_PORTS) tc_fli
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (fli_drdy),              // Templated
     .ip_srdy                           (lfli_srdy),             // Templated
     .ip_data                           (lfli_data),             // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_srdy                            (fli_srdy),              // Templated
     .c_data                            (fli_data),              // Templated
     .ip_drdy                           (lfli_drdy));             // Templated

  port_ring_tap_fsm #(rdp_sz, pdp_sz, portnum) fsm
    (/*AUTOINST*/
     // Outputs
     .lfli_drdy                         (lfli_drdy),
     .lprx_drdy                         (lprx_drdy),
     .lptx_data                         (lptx_data[pdp_sz-1:0]),
     .lptx_srdy                         (lptx_srdy),
     .lri_drdy                          (lri_drdy),
     .lro_data                          (lro_data[rdp_sz-1:0]),
     .lro_srdy                          (lro_srdy),
     .rarb_req                          (rarb_req),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .lfli_data                         (lfli_data[`NUM_PORTS-1:0]),
     .lfli_srdy                         (lfli_srdy),
     .lprx_data                         (lprx_data[pdp_sz-1:0]),
     .lprx_srdy                         (lprx_srdy),
     .lptx_drdy                         (lptx_drdy),
     .lri_data                          (lri_data[rdp_sz-1:0]),
     .lri_srdy                          (lri_srdy),
     .lro_drdy                          (lro_drdy),
     .rarb_ack                          (rarb_ack));

  /* sd_output AUTO_TEMPLATE "tc_\(.*\)"
   (
    .ic_\(.*\)    (l@_\1),
    .p_\(.*\)     (@_\1),
   );
   */

  sd_output #(pdp_sz) tc_ptx
    (/*AUTOINST*/
     // Outputs
     .ic_drdy                           (lptx_drdy),             // Templated
     .p_srdy                            (ptx_srdy),              // Templated
     .p_data                            (ptx_data),              // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .ic_srdy                           (lptx_srdy),             // Templated
     .ic_data                           (lptx_data),             // Templated
     .p_drdy                            (ptx_drdy));              // Templated

  sd_output #(rdp_sz) tc_ro
    (/*AUTOINST*/
     // Outputs
     .ic_drdy                           (lro_drdy),              // Templated
     .p_srdy                            (ro_srdy),               // Templated
     .p_data                            (ro_data),               // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .ic_srdy                           (lro_srdy),              // Templated
     .ic_data                           (lro_data),              // Templated
     .p_drdy                            (ro_drdy));               // Templated

endmodule // port_ring_tap
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/memory" "../../../rtl/verilog/forks")
// End:  
