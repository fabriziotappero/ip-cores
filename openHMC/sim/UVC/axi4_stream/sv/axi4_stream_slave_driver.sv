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

`ifndef AXI4_STREAM_SLAVE_DRIVER_SV
`define AXI4_STREAM_SLAVE_DRIVER_SV

//-- After this works for HMC, generalize for PCIe as well
class axi4_stream_slave_driver #(parameter DATA_BYTES = 16, parameter TUSER_WIDTH = 16) extends uvm_driver #(hmc_packet);

	axi4_stream_config axi4_stream_cfg;

	virtual interface axi4_stream_if #(.DATA_BYTES(DATA_BYTES), .TUSER_WIDTH(TUSER_WIDTH)) vif;
	
	
	`uvm_component_param_utils_begin(axi4_stream_slave_driver #(.DATA_BYTES(DATA_BYTES), .TUSER_WIDTH(TUSER_WIDTH)))
		`uvm_field_object(axi4_stream_cfg, UVM_DEFAULT)
	`uvm_component_utils_end

 	

	function new(string name="axi4_stream_slave_driver", uvm_component parent);
		super.new(name,parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(uvm_config_db#(virtual interface axi4_stream_if #(.DATA_BYTES(DATA_BYTES), .TUSER_WIDTH(TUSER_WIDTH)))::get(this, "", "vif",vif) ) begin
			this.vif = vif;
		end else begin
			`uvm_fatal(get_type_name(),"vif is not set")
		end
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		bit ready_asserted = 0;
		bit last_valid = 0;
		int set_probability;

		super.run_phase(phase);

		forever begin
			if(vif.ARESET_N !== 1) begin
				vif.TREADY <= 1'b0;
				@(posedge vif.ARESET_N);
			end

			fork
				forever begin
					//-- Accept packets
					@(negedge vif.ACLK);

					set_probability_randomization : assert (std::randomize(set_probability) with {set_probability >= 0 && set_probability < 10;});

					//-- Higher probability to be ready when the master has something to send
					if (ready_asserted == 0 && vif.TVALID == 1 && set_probability > 3) begin
						ready_asserted = 1;
					//-- Can be ready when the master has nothing to send
					end else if (ready_asserted == 0 && vif.TVALID == 0 && set_probability > 8) begin
						ready_asserted = 1;
					//-- Only become not ready after accepting something
					end else if (ready_asserted == 1 && vif.TVALID == 1 && set_probability > 3) begin
						ready_asserted = 0;
					end
							
					vif.TREADY <= ready_asserted;	
					last_valid = vif.TVALID == 1'b1;
				end
				begin //-- Asynchronous reset
					@(negedge vif.ARESET_N);
				end
			join_any
			disable fork;
		end

	endtask : run_phase

endclass : axi4_stream_slave_driver

`endif // AXI4_STREAM_SLAVE_DRIVER_SV

