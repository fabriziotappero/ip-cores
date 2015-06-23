//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code Creates VMM Environment of the I2C M/S Core.						//
//			 																			//
//																						//		
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"
`include "config.sv"
`include "vmm_i2c_interface.sv"
//`include "debug_if.sv"
`include "vmm_i2c_sb_pkt.sv"
`include "vmm_i2c_mon_pkt.sv"
`include "vmm_i2c_reg_pkt.sv"
`include "vmm_i2c_scenario_packet.sv"
`include "vmm_i2c_stimulus_packet.sv"
`include "vmm_i2c_data_packet.sv"
`include "vmm_i2c_scenario_generator.sv"
`include "sb_callback.sv"
`include "vmm_i2c_driver.sv"
`include "vmm_i2c_slave_driver.sv"

class i2c_env extends vmm_env;

	vmm_log log = new("log", "ENV");
	virtual i2c_pin_if pif;								// Virtual Interface
	i2c_scenario_generator sc_gen;						// Scenario Generator
	configuration cfg;									// Configuration Class
	stimulus_packet_channel m_stim_req_chan;			// Scenarion_gen to W/B Driver Channel
	stimulus_packet_channel s_stim_req_chan;			// Scenarion_gen to I2C M/S Driver Channel	
	i2c_master_driver m_driver_xactor;					// W/B Driver Xactor
	i2c_slave_driver s_driver_xactor;					// I2C Driver Xactor
	i2c_scoreboard i2c_sb;								// Scoreboard
	sb_callback sb_c;									// Sb_Callback
	i2c_coverage i2c_cov;								// Coverage_Module
	i2c_monitor i2c_mon;								// Monitor 

	bit rand_tran = 1'b0;								// Rand_mode
	integer transaction_count;							// No. of Transaction

// Class Constructor
	function new(virtual i2c_pin_if pif);
		super.new("MY_ENV");
		this.pif = pif;
//		this.d_if = d_if;
		$value$plusargs("transaction_count=%d",transaction_count);
		$value$plusargs("rand_trans=%b",rand_tran);
		cfg = new();
	endfunction


//Gen Config Function. If rand_trans is 1 then this will randomize trasaction_count in config class
	virtual function void gen_cfg();
		super.gen_cfg();
		`vmm_note(log, "inside gen_cfg");
		if(rand_tran)
		begin
			if(!cfg.randomize())
				`vmm_error(log,"Configuration Randomization Failed");
			transaction_count = cfg.transaction_count;
		end		
	endfunction

// Build function to all Connections Initializaion
	virtual function void build();
		super.build();
		m_stim_req_chan = new("master_stimulus_packet_channel", "m_stim_req_chan");
		s_stim_req_chan = new("slave_stimulus_packet_channel", "s_stim_req_chan");
		sc_gen = new("scenario_generator", "generator", m_stim_req_chan, s_stim_req_chan);
		m_driver_xactor = new("i2c_master_driver", "m_driver_xactor", this.pif, m_stim_req_chan);	
		s_driver_xactor = new("i2c_slave_driver", "s_driver_xactor", this.pif, s_stim_req_chan);
		sc_gen.transaction_count = transaction_count;	
		i2c_sb = new("I2C_Scoreboard", "SCOREBOARD");
		i2c_cov = new("I2C_Coverage", "COVERAGE");
		i2c_mon = new("I2C_Monitor", "MONITOR",this.pif);
		sb_c = new(i2c_sb, i2c_cov, i2c_mon);
		m_driver_xactor.append_callback(sb_c);
		s_driver_xactor.append_callback(sb_c);
		i2c_mon.append_callback(sb_c);
	endfunction

// Reset DUT task. It will reset dut for 5 system clk cycle
	virtual task reset_dut();
		super.reset_dut();
		m_driver_xactor.set_enable_signals;
		pif.rst = 1;
		repeat(5)
		begin
			@(posedge pif.clk);
			pif.rst = 0;
		end
		`vmm_note(log, "inside reset_dut");
	endtask

// cfg dut task for configuration of DUT.	
	virtual task cfg_dut();
		super.cfg_dut();
		`vmm_note(log, "inside cfg_dut");
	endtask

// Start Transactor task. This will start all transactor in the Environment.	
	virtual task start();
		super.start();
		sc_gen.start_xactor();
     	m_driver_xactor.start_xactor();
 		s_driver_xactor.start_xactor();
 		i2c_mon.start_xactor();
		`vmm_note(log, "inside start");
	endtask

// Wait for end task. It will wait for Done signal from Scenario Generartor.	
	virtual task wait_for_end();
		super.wait_for_end();
		`vmm_note(log, "inside wait_for_end");
		`vmm_note(log, "inside wait_for_end: before wait for done");
		this.sc_gen.notify.wait_for(this.sc_gen.DONE);
		`vmm_note(log, "inside wait_for_end: Affter wait for done");
	endtask
	
// Report Task
	virtual task report();
		super.report();
//		i2c_sb.sb_display();
		`vmm_note(log, "inside report");
	endtask

// Clean-up task
	virtual task cleanup();
		super.cleanup();
		`vmm_note(log, "inside cleanup");
	endtask

endclass

















































