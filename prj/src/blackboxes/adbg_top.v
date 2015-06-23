

`include "adbg_defines.v"

module adbg_top(
                // JTAG signals
                tck_i,
                tdi_i,
                tdo_o,
                rst_i,


                // TAP states
                shift_dr_i,
                pause_dr_i,
                update_dr_i,
                capture_dr_i,

                // Instructions
                debug_select_i


                `ifdef DBG_WISHBONE_SUPPORTED
                // WISHBONE common signals
                ,
                wb_clk_i,
                wb_rst_i,
                
                // WISHBONE master interface
                wb_adr_o,
                wb_dat_o,
                wb_dat_i,
                wb_cyc_o,
                wb_stb_o,
                wb_sel_o,
                wb_we_o,
                wb_ack_i,
                wb_cab_o,
                wb_err_i,
                wb_cti_o,
                wb_bte_o
                `endif

                `ifdef DBG_CPU0_SUPPORTED
                // CPU signals
                ,
                cpu0_clk_i, 
                cpu0_addr_o, 
                cpu0_data_i, 
                cpu0_data_o,
                cpu0_bp_i,
                cpu0_stall_o,
                cpu0_stb_o,
                cpu0_we_o,
                cpu0_ack_i,
                cpu0_rst_o
                `endif

                `ifdef DBG_CPU1_SUPPORTED
                // CPU signals
                ,
                cpu1_clk_i, 
                cpu1_addr_o, 
                cpu1_data_i, 
                cpu1_data_o,
                cpu1_bp_i,
                cpu1_stall_o,
                cpu1_stb_o,
                cpu1_we_o,
                cpu1_ack_i,
                cpu1_rst_o
                `endif
		
                `ifdef DBG_JSP_SUPPORTED
                ,
		`ifndef DBG_WISHBONE_SUPPORTED
		wb_clk_i,
		wb_rst_i,
		`endif
		
                // WISHBONE target interface
                wb_jsp_adr_i,
                wb_jsp_dat_o,
                wb_jsp_dat_i,
                wb_jsp_cyc_i,
                wb_jsp_stb_i,
                wb_jsp_sel_i,
                wb_jsp_we_i,
                wb_jsp_ack_o,
                wb_jsp_cab_i,
                wb_jsp_err_o,
                wb_jsp_cti_i,
                wb_jsp_bte_i,
		int_o
                `endif
		
		);


   // JTAG signals
   input   tck_i;
   input   tdi_i;
   output  tdo_o;
   input   rst_i;

   // TAP states
   input   shift_dr_i;
   input   pause_dr_i;
   input   update_dr_i;
   input   capture_dr_i;

   // Module select from TAP
   input   debug_select_i;

`ifdef DBG_WISHBONE_SUPPORTED
   input   wb_clk_i;
   input   wb_rst_i;
   output [31:0] wb_adr_o;
   output [31:0] wb_dat_o;
   input [31:0]  wb_dat_i;
   output        wb_cyc_o;
   output        wb_stb_o;
   output [3:0]  wb_sel_o;
   output        wb_we_o;
   input         wb_ack_i;
   output        wb_cab_o;
   input         wb_err_i;
   output [2:0]  wb_cti_o;
   output [1:0]  wb_bte_o;
`endif

`ifdef DBG_CPU0_SUPPORTED
   // CPU signals
   input         cpu0_clk_i; 
   output [31:0] cpu0_addr_o; 
   input [31:0]  cpu0_data_i; 
   output [31:0] cpu0_data_o;
   input         cpu0_bp_i;
   output        cpu0_stall_o;
   output        cpu0_stb_o;
   output        cpu0_we_o;
   input         cpu0_ack_i;
   output        cpu0_rst_o;
`endif

`ifdef DBG_CPU1_SUPPORTED
   input         cpu1_clk_i; 
   output [31:0] cpu1_addr_o; 
   input [31:0]  cpu1_data_i; 
   output [31:0] cpu1_data_o;
   input         cpu1_bp_i;
   output        cpu1_stall_o;
   output        cpu1_stb_o;
   output        cpu1_we_o;
   input         cpu1_ack_i;
   output        cpu1_rst_o;
`endif

`ifdef DBG_JSP_SUPPORTED
   `ifndef DBG_WISHBONE_SUPPORTED
   input   wb_clk_i;
   input   wb_rst_i;
   `endif
   input [31:0]  wb_jsp_adr_i;
   output [31:0] wb_jsp_dat_o;
   input [31:0]  wb_jsp_dat_i;
   input         wb_jsp_cyc_i;
   input         wb_jsp_stb_i;
   input [3:0]   wb_jsp_sel_i;
   input         wb_jsp_we_i;
   output        wb_jsp_ack_o;
   input         wb_jsp_cab_i;
   output        wb_jsp_err_o;
   input [2:0]   wb_jsp_cti_i;
   input [1:0]   wb_jsp_bte_i;
   output 	 int_o;
`endif


endmodule
