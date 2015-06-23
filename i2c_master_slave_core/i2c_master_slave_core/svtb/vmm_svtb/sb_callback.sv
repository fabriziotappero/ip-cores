//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code implements all callback function defined in faced class named 		//
//	vmm_i2c_callback. All callback functions invoke another function/task in Scoreboard //
//  and Coverage Collector Module.														// 
//																						//
//////////////////////////////////////////////////////////////////////////////////////////


`include "vmm.sv"
`include "vmm_i2c_scoreboard.sv"
`include "vmm_i2c_coverage.sv"
`include "vmm_i2c_callback.sv"
`include "vmm_i2c_monitor.sv"

class sb_callback extends i2c_callback;

	vmm_log log = new("scorebd_cb","CALLBACK");
	scoreboard_pkt sb_pkt;								// Scoreboard Packet
	register_pkt reg_pkt;								// Register Packet
	stimulus_packet mon_stim_pkt;						// Stimulus Packet	
	monitor_pkt mon_pkt;								// Monitor Packet
	i2c_scoreboard i2c_sb;								// Scoreboard's Instance
	i2c_coverage i2c_cov;								// Coverage Instance
	i2c_monitor i2c_mon;								// Monitor's Instance

	function new(i2c_scoreboard i2c_sb, i2c_coverage i2c_cov, i2c_monitor i2c_mon);
		this.i2c_sb = i2c_sb;
		this.i2c_cov = i2c_cov;
		this.i2c_mon = i2c_mon;
	endfunction


// This task invoke pre_txn_push task in Scoreboard and pre_txn_start_cov task in Coverage module and send sb_pkt as a formal argument. 
	virtual task pre_transaction(scoreboard_pkt sb_pkt);
		this.i2c_sb.pre_txn_push(sb_pkt);
		this.i2c_cov.pre_txn_start_cov(sb_pkt);
	endtask
	
// This task invoke post_txn_push task in Scoreboard and send sb_pkt as a formal argument. 
	virtual task post_transaction(scoreboard_pkt sb_pkt);
		this.i2c_sb.post_txn_push(sb_pkt);
	endtask
	
// This task invoke write_reg task in Scoreboard and write_reg_cov task in Coverage module and send reg_pkt as a formal argument. 
	virtual task write_reg(register_pkt reg_pkt);
		this.i2c_sb.write_reg(reg_pkt);
		this.i2c_cov.write_reg_cov(reg_pkt);
	endtask
	
// This task invoke read_reg task in Scoreboard and read_reg_cov task in Coverage module and send reg_pkt as a formal argument. 
	virtual task read_reg(register_pkt reg_pkt);
		this.i2c_sb.read_reg(reg_pkt);
		this.i2c_cov.read_reg_cov(reg_pkt);
	endtask

// This task invoke get_packet_from_driver task in Monitor and send mon_stim_pkt as a formal argument. 
	virtual task send_pkt_to_monitor(stimulus_packet mon_stim_pkt);
		this.i2c_mon.get_packet_from_driver(mon_stim_pkt);
	endtask	

// This task invoke protocol_checks_cov task in Coverage Module and send mon_pkt as a formal argument. 
	virtual task protocol_checks_coverage(monitor_pkt mon_pkt);
		this.i2c_cov.protocol_checks_cov(mon_pkt);
	endtask	

endclass
	
