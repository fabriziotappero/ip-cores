/* Set search path for verilog include files */
search_path = search_path + { RTL_PATH } + { GATE_PATH }

/* Read verilog files of the PCI IP core */
if (TOPLEVEL == "TOP") {
	read -f verilog pci_bridge32.v
	read -f verilog mas_load_next_crit.v 
	read -f verilog pci_parity_check.v 
	read -f verilog pci_target_unit.v 
	read -f verilog wb_addr_mux.v 
	read -f verilog cbe_en_crit.v 
	read -f verilog fifo_control.v 
	read -f verilog out_reg.v 
	read -f verilog pci_target32_ad_en_crit.v 
	read -f verilog pci_tpram.v 
	read -f verilog wb_master.v
	read -f verilog conf_cyc_addr_dec.v 
	read -f verilog frame_crit.v 
	read -f verilog par_cbe_crit.v 
	read -f verilog pci_target32_clk_en.v 
	read -f verilog pciw_fifo_control.v 
	read -f verilog wb_slave.v 
	read -f verilog conf_space.v 
	read -f verilog frame_en_crit.v 
	read -f verilog par_crit.v 
	read -f verilog pci_target32_ctrl_en_crit.v 
	read -f verilog pciw_pcir_fifos.v 
	read -f verilog wb_slave_unit.v 
	read -f verilog frame_load_crit.v 
	read -f verilog pci_bridge32.v 
	read -f verilog pci_target32_devs_crit.v 
	read -f verilog perr_crit.v 
	read -f verilog wbr_fifo_control.v 
	read -f verilog cur_out_reg.v 
	read -f verilog io_mux_en_mult.v 
	read -f verilog pci_decoder.v 
	read -f verilog pci_target32_interface.v 
	read -f verilog perr_en_crit.v 
	read -f verilog wbw_fifo_control.v 
	read -f verilog decoder.v 
	read -f verilog io_mux_load_mux.v 
	read -f verilog pci_in_reg.v 
	read -f verilog pci_target32_load_crit.v 
	read -f verilog serr_crit.v 
	read -f verilog wbw_wbr_fifos.v 
	read -f verilog delayed_sync.v 
	read -f verilog irdy_out_crit.v 
	read -f verilog pci_io_mux.v 
	read -f verilog pci_target32_sm.v 
	read -f verilog serr_en_crit.v 
	read -f verilog delayed_write_reg.v 
	read -f verilog mas_ad_en_crit.v 
	read -f verilog pci_master32_sm.v 
	read -f verilog pci_target32_stop_crit.v 
	read -f verilog synchronizer_flop.v 
	read -f verilog mas_ch_state_crit.v 
	read -f verilog pci_master32_sm_if.v 
	read -f verilog pci_target32_trdy_crit.v 
	read -f verilog top.v 
	read -f verilog pci_rst_int.v
        read -f verilog wb_tpram.v
} else {
	echo "Non-existing top level."
	exit
}

