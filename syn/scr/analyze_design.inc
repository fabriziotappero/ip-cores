/* Set search path for verilog include files */
search_path = search_path + { RTL_PATH } + { GATE_PATH }

/* Read verilog files of the PCI IP core */
if (TOPLEVEL == "TOP") {
	analyze -f verilog pci_bridge32.v
	analyze -f verilog mas_load_next_crit.v 
	analyze -f verilog pci_parity_check.v 
	analyze -f verilog pci_target_unit.v 
	analyze -f verilog wb_addr_mux.v 
	analyze -f verilog cbe_en_crit.v 
	analyze -f verilog fifo_control.v 
	analyze -f verilog out_reg.v 
	analyze -f verilog pci_target32_ad_en_crit.v 
	analyze -f verilog pci_tpram.v 
	analyze -f verilog wb_master.v
	analyze -f verilog conf_cyc_addr_dec.v 
	analyze -f verilog frame_crit.v 
	analyze -f verilog par_cbe_crit.v 
	analyze -f verilog pci_target32_clk_en.v 
	analyze -f verilog pciw_fifo_control.v 
	analyze -f verilog wb_slave.v 
	analyze -f verilog conf_space.v 
	analyze -f verilog frame_en_crit.v 
	analyze -f verilog par_crit.v 
	analyze -f verilog pci_target32_ctrl_en_crit.v 
	analyze -f verilog pciw_pcir_fifos.v 
	analyze -f verilog wb_slave_unit.v 
	analyze -f verilog frame_load_crit.v 
	analyze -f verilog pci_bridge32.v 
	analyze -f verilog pci_target32_devs_crit.v 
	analyze -f verilog perr_crit.v 
	analyze -f verilog wbr_fifo_control.v 
	analyze -f verilog cur_out_reg.v 
	analyze -f verilog io_mux_en_mult.v 
	analyze -f verilog pci_decoder.v 
	analyze -f verilog pci_target32_interface.v 
	analyze -f verilog perr_en_crit.v 
	analyze -f verilog wbw_fifo_control.v 
	analyze -f verilog decoder.v 
	analyze -f verilog io_mux_load_mux.v 
	analyze -f verilog pci_in_reg.v 
	analyze -f verilog pci_target32_load_crit.v 
	analyze -f verilog serr_crit.v 
	analyze -f verilog wbw_wbr_fifos.v 
	analyze -f verilog delayed_sync.v 
	analyze -f verilog irdy_out_crit.v 
	analyze -f verilog pci_io_mux.v 
	analyze -f verilog pci_target32_sm.v 
	analyze -f verilog serr_en_crit.v 
	analyze -f verilog delayed_write_reg.v 
	analyze -f verilog mas_ad_en_crit.v 
	analyze -f verilog pci_master32_sm.v 
	analyze -f verilog pci_target32_stop_crit.v 
	analyze -f verilog synchronizer_flop.v 
	analyze -f verilog mas_ch_state_crit.v 
	analyze -f verilog pci_master32_sm_if.v 
	analyze -f verilog pci_target32_trdy_crit.v 
	analyze -f verilog top.v 
	analyze -f verilog pci_rst_int.v
        analyze -f verilog sync_module.v
        analyze -f verilog wb_tpram.v
} else {
	echo "Non-existing top level."
	exit
}

