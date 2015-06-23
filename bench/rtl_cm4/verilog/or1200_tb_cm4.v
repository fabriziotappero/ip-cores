///////////////////////////////////////////////
//	OR1200 Testbench Top Level for
//	Random Instruction Code Generator
//	and Hyper Pipelined OR1200 Core with
//	CMF = 4
///////////////////////////////////////////////

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_testbench_cm4();


parameter dw = `OR1200_OPERAND_WIDTH;
parameter aw = `OR1200_OPERAND_WIDTH;
parameter ppic_ints = `OR1200_PIC_INTS;

//
// I/O
//

//
// System
//
//reg			clk_i;
//reg			rst_i;
reg	[1:0]		clmode_i;	// 00 WB=RISC, 01 WB=RISC/2, 10 N/A, 11 WB=RISC/4
reg	[ppic_ints-1:0]	pic_ints_i;

//
// Instruction WISHBONE interface
//
//reg			iwb_clk_i;	// clock input
//reg			iwb_rst_i;	// reset input
wire			iwb_ack_i;	// normal termination
reg			iwb_err_i;	// termination w/ error
reg			iwb_rty_i;	// termination w/ retry
wire	[dw-1:0]	iwb_dat_i;	// input data bus
wire			iwb_cyc_o;	// cycle valid output
wire	[aw-1:0]	iwb_adr_o;	// address bus outputs
wire			iwb_stb_o;	// strobe output
wire			iwb_we_o;	// indicates write transfer
wire	[3:0]		iwb_sel_o;	// byte select outputs
wire	[dw-1:0]	iwb_dat_o;	// output data bus
`ifdef OR1200_WB_CAB
wire			iwb_cab_o;	// indicates consecutive address burst
`endif
`ifdef OR1200_WB_B3
wire	[2:0]		iwb_cti_o;	// cycle type identifier
wire	[1:0]		iwb_bte_o;	// burst type extension
`endif

//
// Data WISHBONE interface
//
//reg			dwb_clk_i;	// clock input
//reg			dwb_rst_i;	// reset input
reg			dwb_ack_i;	// normal termination
reg			dwb_err_i;	// termination w/ error
reg			dwb_rty_i;	// termination w/ retry
reg	[dw-1:0]	dwb_dat_i;	// input data bus
wire			dwb_cyc_o;	// cycle valid output
wire	[aw-1:0]	dwb_adr_o;	// address bus outputs
wire			dwb_stb_o;	// strobe output
wire			dwb_we_o;	// indicates write transfer
wire	[3:0]		dwb_sel_o;	// byte select outputs
wire	[dw-1:0]	dwb_dat_o;	// output data bus
`ifdef OR1200_WB_CAB
wire			dwb_cab_o;	// indicates consecutive address burst
`endif
`ifdef OR1200_WB_B3
wire	[2:0]		dwb_cti_o;	// cycle type identifier
wire	[1:0]		dwb_bte_o;	// burst type extension
`endif

//
// External Debug Interface
//
reg			dbg_stall_i;	// External Stall Input
reg			dbg_ewt_i;	// External Watchpoint Trigger Input
wire	[3:0]		dbg_lss_o;	// External Load/Store Unit Status
wire	[1:0]		dbg_is_o;	// External Insn Fetch Status
wire	[10:0]		dbg_wp_o;	// Watchpoints Outputs
wire			dbg_bp_o;	// Breakpoint Output
reg			dbg_stb_i;      // External Address/Data Strobe
reg			dbg_we_i;       // External Write Enable
reg	[aw-1:0]	dbg_adr_i;	// External Address Input
reg	[dw-1:0]	dbg_dat_i;	// External Data Input
wire	[dw-1:0]	dbg_dat_o;	// External Data Output
wire			dbg_ack_o;	// External Data Acknowledge (not WB compatible)

`ifdef OR1200_BIST
//
// RAM BIST
//
reg mbist_si_i;
reg [`OR1200_MBIST_CTRL_WIDTH - 1:0] mbist_ctrl_i;
wire mbist_so_o;
`endif

//
// Power Management
//
reg			pm_cpustall_i;
wire	[3:0]		pm_clksd_o;
wire			pm_dc_gate_o;
wire			pm_ic_gate_o;
wire			pm_dmmu_gate_o;
wire			pm_immu_gate_o;
wire			pm_tt_gate_o;
wire			pm_cpu_gate_o;
wire			pm_wakeup_o;
wire			pm_lvolt_o;


/////////////////////////////////////////////////
//	Top Level Clocks, Reset and
//	Core Multiplier Level Selector
/////////////////////////////////////////////////

reg system_clk;
reg clk_i;
reg clk_i_cml_1;
reg clk_i_cml_2;
reg clk_i_cml_3;
reg [1:0] cmls;
reg rst;
integer cnt = 0;
reg [3:0] core_off;
parameter turnOffTime_2nd = 8502;
parameter turnOffTime_3nd = 15388;
parameter turnOnTime_3nd = 25226;
parameter turnOnTime_2nd = 34551;

/////////////////////////////////////////////////
//	Initial
/////////////////////////////////////////////////

initial begin
	system_clk <= 0;
	clk_i <= 0;
	clk_i_cml_1 <= 0;
	clk_i_cml_2 <= 0;
	clk_i_cml_3 <= 0;
	cmls <= 0;
	rst <= 1;
	core_off <= 0;

	clmode_i <= 0;	// 00 WB=RISC, 01 WB=RISC/2, 10 N/A, 11 WB=RISC/4
	pic_ints_i = 0;
	iwb_err_i = 0;	// termination w/ error
	iwb_rty_i = 0;	// termination w/ retry
	dwb_ack_i = 0;	// normal termination
	dwb_err_i = 0;	// termination w/ error
	dwb_rty_i = 0;	// termination w/ retry
	dwb_dat_i = 0;	// input data bus
	dbg_stall_i = 0;	// External Stall Input
	dbg_ewt_i = 0;	// External Watchpoint Trigger Input
	dbg_stb_i = 0;      // External Address/Data Strobe
	dbg_we_i = 0;       // External Write Enable
	dbg_adr_i = 0;	// External Address Input
	dbg_dat_i = 0;	// External Data Input
	pm_cpustall_i = 0;
end

/////////////////////////////////////////////////
//	Clock Generator
/////////////////////////////////////////////////
always begin
	#(50) 
	system_clk <= ~system_clk;

	// do not clock       when (core_off[1] and cmls == 0) or (core_off[2] and cmls == 1);
	clk_i       <= ~system_clk & (~(core_off[1] & (cmls == 0))) & (~(core_off[2] & (cmls == 1)));  

   	// do not clock cml_1 when (core_off[1] and cmls == 1) or (core_off[2] and cmls == 2);
	clk_i_cml_1 <= ~system_clk & (~(core_off[1] & (cmls == 1))) & (~(core_off[2] & (cmls == 2)));  

   	// do not clock cml_2 when (core_off[1] and cmls == 2) or (core_off[2] and cmls == 0);
	clk_i_cml_2 <= ~system_clk & (~(core_off[1] & (cmls == 2))) & (~(core_off[2] & (cmls == 3)));  

   	// do not clock cml_3 when (core_off[1] and cmls == 3) or (core_off[2] and cmls == 0);
	clk_i_cml_3 <= ~system_clk & (~(core_off[1] & (cmls == 3))) & (~(core_off[2] & (cmls == 0)));  
end

/////////////////////////////////////////////////
//	Core Multiplier Level Selector
/////////////////////////////////////////////////

always @(posedge system_clk)
	if (cmls == 3)
		cmls <= 0;
	else
		cmls <= cmls + 1;
   

/////////////////////////////////////////////////
//	Reset Generator
/////////////////////////////////////////////////

initial begin
	repeat (20) @(negedge system_clk);
	rst <= 0;
	repeat (turnOnTime_3nd - 19) @(negedge system_clk);
	rst <= 1;
	#20; //@(negedge system_clk);
	rst <= 0;
	repeat (turnOnTime_2nd - (turnOnTime_3nd - 19) - 17) @(negedge system_clk);
	rst <= 1;
	#20; 
	rst <= 0;
end

/////////////////////////////////////////////////
//	Process turns off/on second core
/////////////////////////////////////////////////

always @ (posedge system_clk) begin
	if (cnt == turnOffTime_2nd) begin
		core_off[1] <= 1'b1;
	end
	if (cnt == turnOffTime_3nd) begin
		core_off[2] <= 1'b1;
	end
	if (cnt == turnOnTime_2nd - 1) begin
		core_off[1] <= 1'b0;
	end
	if (cnt == turnOnTime_3nd - 1) begin
		core_off[2] <= 1'b0;
	end
end

/////////////////////////////////////////////////
//	Count and Stop after 20000 Cycles
/////////////////////////////////////////////////

always @ (posedge system_clk) 
begin
	cnt <= cnt + 1;
	if (cnt == 47000) begin
		$stop;
	end
end


/////////////////////////////////////////////////
//	Random Instruction Code Generator for 
//	3 Hyper Pipelined OR1200
/////////////////////////////////////////////////

random_rom_wb_cm4 random_rom_wb_cm4_i 
	( 
	.dat_o(iwb_dat_i),
	.adr_i(iwb_adr_o[25:2]), 
	.sel_i(iwb_sel_o), 
	.cyc_i(iwb_cyc_o), 
	.stb_i(iwb_stb_o), 
	.ack_o(iwb_ack_i), 
	.clk_i(system_clk),
	.cmls(cmls),
	.rst_i(rst),
	.core_off(core_off) );

/////////////////////////////////////////////////
//	Instantiation of Hyper Pipelined OR1200
//	with CMF = 3
/////////////////////////////////////////////////

or1200_top_cm4 or1200_top_cm4_i
     (
	.clk_i_cml_3(clk_i_cml_3),
	.clk_i_cml_2(clk_i_cml_2),
	.clk_i_cml_1(clk_i_cml_1),
	.cmls(cmls),
	// System
	.clk_i(clk_i), 
	.rst_i(rst), 
	.pic_ints_i(pic_ints_i), 
	.clmode_i(clmode_i),

	// Instruction WISHBONE INTERFACE
	//.iwb_clk_i(clk), 
	//.iwb_rst_i(rst), 
	.iwb_ack_i(iwb_ack_i), 
	.iwb_err_i(iwb_err_i), 
	.iwb_rty_i(iwb_rty_i), 
	.iwb_dat_i(iwb_dat_i),
	.iwb_cyc_o(iwb_cyc_o), 
	.iwb_adr_o(iwb_adr_o), 
	.iwb_stb_o(iwb_stb_o), 
	.iwb_we_o(iwb_we_o), 
	.iwb_sel_o(iwb_sel_o), 
	.iwb_dat_o(iwb_dat_o),
`ifdef OR1200_WB_CAB
	.iwb_cab_o(iwb_cab_o),
`endif
`ifdef OR1200_WB_B3
	.iwb_cti_o(iwb_cti_o), 
	.iwb_bte_o(iwb_bte_o),
`endif
	// Data WISHBONE INTERFACE
	//.dwb_clk_i(clk), 
	//.dwb_rst_i(rst), 
	.dwb_ack_i(dwb_ack_i), 
	.dwb_err_i(dwb_err_i), 
	.dwb_rty_i(dwb_rty_i), 
	.dwb_dat_i(dwb_dat_i),
	.dwb_cyc_o(dwb_cyc_o), 
	.dwb_adr_o(dwb_adr_o), 
	.dwb_stb_o(dwb_stb_o), 
	.dwb_we_o(dwb_we_o), 
	.dwb_sel_o(dwb_sel_o), 
	.dwb_dat_o(dwb_dat_o),
`ifdef OR1200_WB_CAB
	.dwb_cab_o(dwb_cab_o),
`endif
`ifdef OR1200_WB_B3
	.dwb_cti_o(dwb_cti_o), 
	.dwb_bte_o(dwb_bte_o),
`endif

	// External Debug Interface
	.dbg_stall_i(dbg_stall_i), 
	.dbg_ewt_i(dbg_ewt_i),	
	.dbg_lss_o(dbg_lss_o), 
	.dbg_is_o(dbg_is_o), 
	.dbg_wp_o(dbg_wp_o), 
	.dbg_bp_o(dbg_bp_o),
	.dbg_stb_i(dbg_stb_i), 
	.dbg_we_i(dbg_we_i), 
	.dbg_adr_i(dbg_adr_i), 
	.dbg_dat_i(dbg_dat_i), 
	.dbg_dat_o(dbg_dat_o), 
	.dbg_ack_o(dbg_ack_o),
	
`ifdef OR1200_BIST
	// RAM BIST
	.mbist_si_i(mbist_si_i), 
	.mbist_so_o(mbist_so_o), 
	.mbist_ctrl_i(mbist_ctrl_i),
`endif
	// Power Management
	.pm_cpustall_i(pm_cpustall_i),
	.pm_clksd_o(pm_clksd_o), 
	.pm_dc_gate_o(pm_dc_gate_o), 
	.pm_ic_gate_o(pm_ic_gate_o), 
	.pm_dmmu_gate_o(pm_dmmu_gate_o), 
	.pm_immu_gate_o(pm_immu_gate_o), 
	.pm_tt_gate_o(pm_tt_gate_o), 
	.pm_cpu_gate_o(pm_cpu_gate_o), 
	.pm_wakeup_o(pm_wakeup_o), 
	.pm_lvolt_o(pm_lvolt_o)
);



endmodule
