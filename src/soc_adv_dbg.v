// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


`include "timescale.v"
`include "soc_defines.v"


module soc_adv_dbg
  #(
    parameter ALTERA_JTAG = 1
  )
  (
`ifdef USE_EXT_JTAG  
     input         jtag_tck_i,
     input         jtag_tms_i,
     input         jtag_tdo_i,
     output        jtag_tdi_o,
`endif
  
     input         wb_clk_i,
     output [31:0] wb_adr_o,
     output [31:0] wb_dat_o,
     input  [31:0] wb_dat_i,
     output        wb_cyc_o,
     output        wb_stb_o,
     output [3:0]  wb_sel_o,
     output        wb_we_o,
     input         wb_ack_i,
     output        wb_cab_o,
     input         wb_err_i,
     output [2:0]  wb_cti_o,
     output [1:0]  wb_bte_o,

     // CPU signals
     input         cpu0_clk_i,
     output [31:0] cpu0_addr_o,
     input  [31:0] cpu0_data_i,
     output [31:0] cpu0_data_o,
     input         cpu0_bp_i,
     output        cpu0_stall_o,
     output        cpu0_stb_o,
     output        cpu0_we_o,
     input         cpu0_ack_i,
     output        cpu0_rst_o

  );


  //---------------------------------------------------
  // adbg_top

  // Connections between TAP and debug module
  wire capture_dr;
  wire shift_dr;
  wire pause_dr;
  wire update_dr;
  wire dbg_rst;
  wire dbg_tdi;
  wire dbg_tck;
  wire dbg_tdo;
  wire dbg_sel;
  
`ifdef USE_EXT_JTAG  
  assign dbg_tck = jtag_tck_i;
`endif

  adbg_top
    i_adbg_top(
      .tck_i(dbg_tck),  // JTAG signals 
      .tdi_i(dbg_tdo),
      .tdo_o(dbg_tdi),
      .rst_i(dbg_rst),

      .shift_dr_i(shift_dr),   // TAP states
      .pause_dr_i(pause_dr),
      .update_dr_i(update_dr),
      .capture_dr_i(capture_dr),
      .debug_select_i(dbg_sel),  // Instructions

      .wb_clk_i(wb_clk_i),  // WISHBONE common signals
      .wb_adr_o(wb_adr_o),  // WISHBONE master interface
      .wb_dat_o(wb_dat_o),
      .wb_dat_i(wb_dat_i),
      .wb_cyc_o(wb_cyc_o),
      .wb_stb_o(wb_stb_o),
      .wb_sel_o(wb_sel_o),
      .wb_we_o(wb_we_o),
      .wb_ack_i(wb_ack_i),
      .wb_cab_o(wb_cab_o),
      .wb_err_i(wb_err_i),
      .wb_cti_o(wb_cti_o),
      .wb_bte_o(wb_bte_o),
      .cpu0_clk_i(cpu0_clk_i),  // CPU signals
      .cpu0_addr_o(cpu0_addr_o),
      .cpu0_data_i(cpu0_data_i),
      .cpu0_data_o(cpu0_data_o),
      .cpu0_bp_i(cpu0_bp_i),
      .cpu0_stall_o(cpu0_stall_o),
      .cpu0_stb_o(cpu0_stb_o),
      .cpu0_we_o(cpu0_we_o),
      .cpu0_ack_i(cpu0_ack_i),
      .cpu0_rst_o(cpu0_rst_o)
    );


  //---------------------------------------------------
  // JTAG TAP controller instantiation
  generate
    if( ALTERA_JTAG )
      begin
        altera_virtual_jtag
          i_altera_virtual_jtag(
            .tck_o(dbg_tck),
            .debug_tdo_i(dbg_tdi),
            .tdi_o(dbg_tdo),
            .test_logic_reset_o(dbg_rst),
            .run_test_idle_o(),
            .shift_dr_o(shift_dr),
            .capture_dr_o(capture_dr),
            .pause_dr_o(pause_dr),
            .update_dr_o(update_dr),
            .debug_select_o(dbg_sel)
          );
      end
    else
      begin
        tap_top
          i_tap (
            // JTAG pads
            .tms_pad_i(jtag_tms_i),
            .tck_pad_i(dbg_tck),
            .trstn_pad_i(1'b1),
            .tdi_pad_i(jtag_tdo_i),
            .tdo_pad_o(jtag_tdi_o),
            .tdo_padoe_o(),

            // TAP states
            .test_logic_reset_o(dbg_rst),
            .run_test_idle_o(),
            .shift_dr_o(shift_dr),
            .pause_dr_o(pause_dr),
            .update_dr_o(update_dr),
            .capture_dr_o(capture_dr),

            // Select signals for boundary scan or mbist
            .extest_select_o(),
            .sample_preload_select_o(),
            .mbist_select_o(),
            .debug_select_o(dbg_sel),

            // TDO signal that is connected to TDI of sub-modules.
            .tdi_o(dbg_tdo),

            // TDI signals from sub-modules
            .debug_tdo_i(dbg_tdi),    // from debug module
            .bs_chain_tdo_i(1'b0), // from Boundary Scan Chain
            .mbist_tdo_i(1'b0)     // from Mbist Chain
          );
      end
  endgenerate


  //---------------------------------------------------
  //


endmodule


