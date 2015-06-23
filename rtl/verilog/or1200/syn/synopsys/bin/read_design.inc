/* Set search path for verilog include files */
search_path = search_path + RTL_PATH + { GATE_PATH }

/* Read verilog files of the OR1200 IP core */
if (TOPLEVEL == "or1200_top") {

	read -f verilog or1200_alu.v
	read -f verilog or1200_amultp2_32x32.v
	read -f verilog or1200_cfgr.v
	read -f verilog or1200_cpu.v
	read -f verilog or1200_ctrl.v
	read -f verilog or1200_dc_fsm.v
	read -f verilog or1200_dc_ram.v
	read -f verilog or1200_dc_tag.v
	read -f verilog or1200_dc_top.v
	read -f verilog or1200_dmmu_tlb.v
	read -f verilog or1200_dmmu_top.v
	read -f verilog or1200_dpram_32x32.v
	read -f verilog or1200_du.v
	read -f verilog or1200_except.v
	read -f verilog or1200_freeze.v
	read -f verilog or1200_genpc.v
	read -f verilog or1200_gmultp2_32x32.v
	read -f verilog or1200_ic_fsm.v
	read -f verilog or1200_ic_ram.v
	read -f verilog or1200_ic_tag.v
	read -f verilog or1200_ic_top.v
	read -f verilog or1200_if.v
	read -f verilog or1200_immu_tlb.v
	read -f verilog or1200_immu_top.v
	read -f verilog or1200_lsu.v
	read -f verilog or1200_mem2reg.v
	read -f verilog or1200_mult_mac.v
	read -f verilog or1200_operandmuxes.v
	read -f verilog or1200_pic.v
	read -f verilog or1200_pm.v
	read -f verilog or1200_reg2mem.v
	read -f verilog or1200_rf.v
	read -f verilog or1200_rfram_generic.v
	read -f verilog or1200_sb.v
	read -f verilog or1200_sb_fifo.v
	read -f verilog or1200_spram_1024x32.v
	read -f verilog or1200_spram_1024x8.v
	read -f verilog or1200_spram_2048x32.v
	read -f verilog or1200_spram_2048x8.v
	read -f verilog or1200_spram_256x21.v
	read -f verilog or1200_spram_512x20.v
	read -f verilog or1200_spram_64x14.v
	read -f verilog or1200_spram_64x22.v
	read -f verilog or1200_spram_64x24.v
	read -f verilog or1200_sprs.v
	read -f verilog or1200_top.v
	read -f verilog or1200_tt.v
	read -f verilog or1200_wb_biu.v
	read -f verilog or1200_wbmux.v

} else {
	echo "Non-existing top level."
	exit
}

