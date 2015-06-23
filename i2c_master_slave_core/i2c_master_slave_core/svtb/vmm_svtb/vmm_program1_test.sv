//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code is written to apply directed test-case to I2C M/S core.			//
//	This test-case will be written to apply write-write-read operation on register	 	//
//  test-case. 																			//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"
`include "vmm_i2c_env.sv"
`include "vmm_clkgen.sv"

class i2c_scenario_generator1 extends i2c_scenario_generator;
	int transaction_count;
	byte reg_addr[5] = {8'h02, 8'h04, 8'h0A, 8'h0C, 8'h0E};

		function new( string name, string instance_name, stimulus_packet_channel m_req_chan = null, stimulus_packet_channel s_req_chan = null);
		super.new("scenario_generator ", "scenario_generator");
		if(m_req_chan == null) m_req_chan = new("master_stimulus_packet_channel", "m_req_chan");
		this.m_req_chan = m_req_chan;	
		if(s_req_chan == null) s_req_chan = new("slave_stimulus_packet_channel", "s_req_chan");
		this.s_req_chan = s_req_chan;	
		this.DONE = this.notify.configure(1,vmm_notify::ON_OFF); 
        sc_packet = new;
        stim_packet = new;
		d_pkt = new;
		$value$plusargs("transaction_count=%d",transaction_count);
		$value$plusargs("rand_gen=%b",rand_gen);
		$value$plusargs("master_slave=%b",master_slave);
		$value$plusargs("register_check=%b",register_check);
		$value$plusargs("reset_check=%b",reset_check);
		$value$plusargs("tx_rx=%b",tx_rx);
	endfunction


// Main task
	virtual protected task main();
	begin
		stim_packet.master_slave = 1'b1;
		stim_packet.tr = 1'b1;
		stim_packet.register_check = 1'b1;
		stim_packet.reset_check = 1'b0;
// For all internal register
		foreach (reg_addr[i])
		begin
			stim_packet.register_addr = reg_addr[i];
// Writing into registers twice
			for (int j = 1; j <=2 ; j++)
			begin
				stim_packet.register_data = {reg_addr[i]+j}; 	
				stim_packet.intr_en = 1'b1; 	
				this.m_req_chan.put(stim_packet);   // sending packet to master driver
				this.s_req_chan.put(stim_packet);	// sending packet to slave driver
			end
// Reading Registers 
			stim_packet.intr_en = 1'b0; 	
			this.m_req_chan.put(stim_packet);    	// sending packet to master driver
			this.s_req_chan.put(stim_packet);		// sending packet to slave driver
		end
		notify.indicate(DONE);	
	end
	endtask

endclass


//-------------------- Program Block --------------------------
program program_test(i2c_pin_if pif);

	i2c_scenario_generator1 i2c_sc_gen1;
	initial begin
		i2c_env env;
		env = new(pif);
		env.build();
		i2c_sc_gen1 = new("new_scenario_generator", "generator", env.m_stim_req_chan, env.s_stim_req_chan);	
		env.sc_gen = i2c_sc_gen1;		// Assigning a new Scenario Generator to handle of Old Scenarion Gen in env.
		env.run();
	end
endprogram
//-------------------------------------------------------------



//---------------------- Module Top --------------------
module top;

i2c_pin_if pif(); 
clkgen c_gen(pif);
program_test p_test(pif);

	wire dut_sda_o;
	wire dut_sda_oe;
	wire dut_sda_in;
	wire dut_scl_o;
	wire dut_scl_oe;
	wire dut_scl_in;
	wire temp;
	wire temp_scl;
    assign dut_sda_o = 1'b0;

	assign temp = pif.sda_oe & dut_sda_oe;
	assign temp_scl = pif.scl_oe & dut_scl_oe;
	assign pif.sda = temp ? 1'bz : 1'b0;
	assign pif.scl = temp_scl ? 1'bz : 1'b0;
    pullup p1_if(pif.sda);
    pullup p2_if(pif.scl);

	
block i2c_core( .scl_in(pif.scl),
				.scl_o(dut_scl_o),
				.scl_oe(dut_scl_oe),
				.sda_in(pif.sda),
				.sda_o(dut_sda_o),
				.sda_oe(dut_sda_oe),
				.wb_add_i(pif.addr_in),
				.wb_data_i(pif.data_in),
				.wb_data_o(pif.data_out),
				.wb_stb_i(pif.wb_stb_i),
				.wb_cyc_i(pif.wb_cyc_i),
				.wb_we_i(pif.we),
				.wb_ack_o(pif.ack_o),
				.irq(pif.irq),
				.trans_comp(pif.trans_comp),
				.wb_clk_i(pif.clk),
				.wb_rst_i(pif.rst)
				);

endmodule


