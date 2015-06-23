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

`ifndef HMC_CHECK_SEQ
`define HMC_CHECK_SEQ


class hmc_check_seq extends hmc_base_seq;

	function new(string name="hmc_check_seq");
		super.new(name);
	endfunction : new

	`uvm_object_utils(hmc_check_seq)
	`uvm_declare_p_sequencer(hmc_vseqr)

	int timer;
	int draintime = 200;

	task body();
		reg_hmc_controller_rf_status_general_c status;
		reg_hmc_controller_rf_sent_np_c sent_np;
		reg_hmc_controller_rf_rcvd_rsp_c rcvd_rsp;

		`uvm_info(get_type_name(), "Running Check Sequence", UVM_NONE)

		timer = 0;

		$cast(status,p_sequencer.rf_seqr_hmc.get_by_name("status_general"));
		status.set_check_on_read(1'b0);

		$cast(sent_np,p_sequencer.rf_seqr_hmc.get_by_name("sent_np"));
		sent_np.set_check_on_read(1'b0);

		$cast(rcvd_rsp,p_sequencer.rf_seqr_hmc.get_by_name("rcvd_rsp"));
		rcvd_rsp.set_check_on_read(1'b0);

		p_sequencer.rf_seqr_hmc.read_reg(status);
		p_sequencer.rf_seqr_hmc.read_reg(sent_np);
		p_sequencer.rf_seqr_hmc.read_reg(rcvd_rsp);

		#5us;

		while(	((sent_np.fields.cnt_ != rcvd_rsp.fields.cnt_) ||
				(status.fields.hmc_tokens_remaining_ != p_sequencer.link_cfg.hmc_tokens) ||
				(status.fields.rx_tokens_remaining_ != p_sequencer.link_cfg.rx_tokens)) 
				&&
				(timer < draintime)) begin
			#1us;
			p_sequencer.rf_seqr_hmc.read_reg(status);
			p_sequencer.rf_seqr_hmc.read_reg(sent_np);
			p_sequencer.rf_seqr_hmc.read_reg(rcvd_rsp);
			`uvm_info(get_type_name(),$psprintf("RX token count in TX_LINK = %0d, should be %0d", status.fields.rx_tokens_remaining_, p_sequencer.link_cfg.rx_tokens),UVM_LOW)
			`uvm_info(get_type_name(),$psprintf("HMC token count in TX_LINK = %0d, should be %0d", status.fields.hmc_tokens_remaining_, p_sequencer.link_cfg.hmc_tokens),UVM_LOW)
			`uvm_info(get_type_name(),$psprintf("sent = %0d non-posted packets, received %0d responses", sent_np.fields.cnt_, rcvd_rsp.fields.cnt_),UVM_LOW)
			timer++;
		end
		#1us;

		p_sequencer.rf_seqr_hmc.read_reg(status);
		p_sequencer.rf_seqr_hmc.read_reg(sent_np);
		p_sequencer.rf_seqr_hmc.read_reg(rcvd_rsp);

		#1us;

		//-- ***REPORTS***
		//-- Report Packet Counts
		if( timer==draintime ) begin
			`uvm_info(get_type_name(),$psprintf("Counted: %0d NP Requests, %0d Responses", sent_np.fields.cnt_, rcvd_rsp.fields.cnt_), UVM_LOW)
			`uvm_info(get_type_name(),$psprintf("Responder token count in TX_LINK = %0d, should be %0d", status.fields.hmc_tokens_remaining_, p_sequencer.link_cfg.hmc_tokens), UVM_LOW)
			`uvm_fatal(get_type_name(),$psprintf("Requester token count in TX_LINK = %0d, should be %0d", status.fields.rx_tokens_remaining_, p_sequencer.link_cfg.rx_tokens))		
		end

	endtask : body

endclass : hmc_check_seq

`endif // HMC_CHECK_SEQ
