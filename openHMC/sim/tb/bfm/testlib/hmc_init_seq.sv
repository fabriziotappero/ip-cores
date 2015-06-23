/*
 *                              .--------------. .----------------. .------------.
 *                             | .------------. | .--------------. | .----------. |
 *                             | | ____  ____ | | | ____    ____ | | |   ______ | |
 *                             | ||_   ||   _|| | ||_   \  /   _|| | | .' ___  || |
 *       ___  _ __   ___ _ __  | |  | |__| |  | | |  |   \/   |  | | |/ .'   \_|| |
 *      / _ \| '_ \ / _ \ '_ \ | |  |  __  |  | | |  | |\  /| |  | | || |       | |
 *       (_) | |_) |  __/ | | || | _| |  | |_ | | | _| |_\/_| |_ | | |\ `.___.'\| |
 *      \___/| .__/ \___|_| |_|| ||____||____|| | ||_____||_____|| | | `._____.'| |
 *           | |               | |            | | |              | | |          | |
 *           |_|               | '------------' | '--------------' | '----------' |
 *                              '--------------' '----------------' '------------'
 *
 *  openHMC - An Open Source Hybrid Memory Cube Controller
 *  (C) Copyright 2014 Computer Architecture Group - University of Heidelberg
 *  www.ziti.uni-heidelberg.de
 *  B6, 26
 *  68159 Mannheim
 *  Germany
 *
 *  Contact: openhmc@ziti.uni-heidelberg.de
 *  http://ra.ziti.uni-heidelberg.de/openhmc
 *
 *   This source file is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Lesser General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This source file is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Lesser General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public License
 *   along with this source file.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 */

`ifndef HMC_INIT_SEQ
`define HMC_INIT_SEQ

class hmc_init_seq extends hmc_base_seq;

	// hmc_link_config link_config;

	function new(string name="hmc_init_seq");
		super.new(name);
	endfunction : new

	`uvm_object_utils(hmc_init_seq)
	`uvm_declare_p_sequencer(hmc_vseqr)

	bit phy_ready = 1'b0;
	bit link_up = 1'b0;
	int timeout = 0;

	task body();

		//-- configure the HMC controller
		reg_hmc_controller_rf_control_c 		control;
		reg_hmc_controller_rf_status_general_c 	status;
		reg_hmc_controller_rf_status_init_c 	status_init;

		`uvm_info(get_type_name(), "Running init sequence", UVM_NONE)


		$cast(control,p_sequencer.rf_seqr_hmc.get_by_name("control"));
		control.set_check_on_read(1'b0);
		p_sequencer.rf_seqr_hmc.read_reg(control);

		control.fields.first_cube_ID_ 		= p_sequencer.link_cfg.cube_id;
		control.fields.rx_token_count_ 		= p_sequencer.link_cfg.rx_tokens;
		control.fields.scrambler_disable_ 	= ~p_sequencer.link_cfg.cfg_scram_enb;
		control.fields.bit_slip_time_ 		= 40;
		control.fields.set_hmc_sleep_ 		= 0;
		control.fields.run_length_enable_ 	= ~p_sequencer.link_cfg.cfg_scram_enb;
		control.fields.irtry_to_send_ 		= p_sequencer.link_cfg.cfg_init_retry_txcnt*4;
		control.fields.irtry_received_threshold_ = p_sequencer.link_cfg.cfg_init_retry_rxcnt;

		p_sequencer.rf_seqr_hmc.write_reg(control);

		//Dummy Read to status init
		$cast(status_init,p_sequencer.rf_seqr_hmc.get_by_name("status_init"));
		status_init.set_check_on_read(1'b0);
		p_sequencer.rf_seqr_hmc.read_reg(status_init);

		//-- Wait until the PHY is ready
		$cast(status,p_sequencer.rf_seqr_hmc.get_by_name("status_general"));
		status.set_check_on_read(1'b0);
		while (phy_ready == 1'b0)
		begin
			#3us;
			p_sequencer.rf_seqr_hmc.read_reg(status);
			phy_ready = status.fields.phy_ready_;
			`uvm_info(get_type_name(), "Waiting for the phy to get ready", UVM_NONE)
		end
		`uvm_info(get_type_name(), "Phy is ready", UVM_NONE)

		//-- Set Reset and Init Continue;
		control.fields.p_rst_n_ = 1;
		control.fields.hmc_init_cont_set_ = 1;
		p_sequencer.rf_seqr_hmc.write_reg(control);

		//-- Poll on link_up to make sure that it comes up.
		while (link_up == 1'b0)
		begin
			if (timeout == 8000) //-- Try Resetting it.
			begin
				`uvm_info(get_type_name(), "The link didn't come up... Resetting it.", UVM_NONE)
				control.fields.p_rst_n_ = 0;
				p_sequencer.rf_seqr_hmc.write_reg(control);
				#30us;
				control.fields.p_rst_n_ = 1;
				p_sequencer.rf_seqr_hmc.write_reg(control);
				timeout = 0;
			end
			#4ns;
			p_sequencer.rf_seqr_hmc.read_reg(status);
			link_up = status.fields.link_up_;
			timeout = timeout + 1;
		end

	endtask : body

endclass : hmc_init_seq

`endif // HMC_INIT_SEQ
