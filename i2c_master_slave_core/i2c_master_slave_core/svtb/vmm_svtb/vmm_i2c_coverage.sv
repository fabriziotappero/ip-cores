//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This Source Code Implements Coverage Collector.										//
//	This Coverage Module contains 3 Covergroups. CG1 for data transaction and modes of	//
//  of operation, CG2 for Register read-write testcases and CG3 for Protocol validation.//
//  All Covergroups are sampled on events which are triggered in different tasks.		//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"

class i2c_coverage extends vmm_xactor;

	scoreboard_pkt cov_pkt;					// Scoreboard_pkt's instance
	register_pkt reg_pkt;					// register_pkt's instance
	monitor_pkt mon_pkt;					// Monitor_pkt's instance
	event start_cov;						// Event data_tye to sample cg1
	event start_cov_reg;					// Event data type to sample cg2
	event start_protocol_checks_cov;		// Event data type to sample cg3

// local variables which gets assigned object's data members in tasks
	bit [7:0] data_byte;
	bit master_slave; 
	bit tx_rx;
	bit [6:0] slave_address;
	bit start_bit;
	bit stop_bit;
	bit slave_ack;
	bit data_ack;
	bit intr_ack;
	bit [7:0] reg_address;
	bit wr_rd;
	bit reset_bit;
	bit [8:0] reg_addr_txn;


// Covergroup CG1. This Covergroup Generate Coverage for modes of operation. their cross coverpoint is defined as well. 
// This covergroup will be sampled on every event of start_cov variable. This event will be triggered in task pre_txn_start_cov.
	covergroup cg1 @start_cov;
		data_in : coverpoint data_byte {
							bins low = {[8'h00 : 8'h40]};
							bins mid = {[8'h41 : 8'h80]};
							bins high = {[8'h81: 8'hff]};
							}
		m_s : coverpoint master_slave;
		tx_rx : coverpoint tx_rx;
		slave_addr: coverpoint slave_address {
							bins low = {[7'h00 : 7'h20]};
							bins mid = {[7'h21 : 7'h40]};
							bins high = {[7'h41: 7'h7f]};
							}
		data_mode_cross : cross data_in, m_s, tx_rx;		
	endgroup : cg1

// Covergroup CG2. This covergroup generate fucntion coverage for all register read-write operations. Cross Coverage is written 
// to check both read and write operation of all reigsters. Transaction Coverage is wrritten for write-write-read operations.
// This covergroup is sampled on every event of start_cov_reg.
	covergroup cg2 @start_cov_reg;
		register_addr : coverpoint reg_address {
							bins prescale = {8'h02};
							bins control  = {8'h04};
							bins timeout  = {8'h0A};
							bins address  = {8'h0C};
							bins data_tx  = {8'h0E};
							}
		write_read : coverpoint wr_rd {
							bins write = {1'b1};
							bins read  = {1'b0};
							}	
		cross_reg_addr_wr : cross register_addr, write_read;
		reset_test: coverpoint reset_bit {
   	                        bins reset = {1'b1};
							}
		prescale_txn : coverpoint wr_rd  iff(reg_address == 8'h02) { 
							bins wr_wr_rd = ( 1 => 1 => 0);
							}	
		control_txn : coverpoint wr_rd iff(reg_address == 8'h04) { 
							bins wr_wr_rd = ( 1'b1 => 1'b1 => 1'b0);
							}	
		timeout_txn : coverpoint wr_rd iff(reg_address == 8'h0A) { 
							bins wr_wr_rd = ( 1'b1 => 1'b1 => 1'b0);
							}	
		address_txn : coverpoint wr_rd iff(reg_address == 8'h0C) { 
							bins wr_wr_rd = ( 1'b1 => 1'b1 => 1'b0);
							}	
		data_tx_txn : coverpoint wr_rd iff(reg_address == 8'h0E) { 
							bins wr_wr_rd = ( 1'b1 => 1'b1 => 1'b0);
							}
		txn: 		coverpoint reg_addr_txn {
							bins pre = (9'h102 => 9'h102 => 9'h002);
							bins con = (9'h104 => 9'h104 => 9'h004);
							bins tim = (9'h10A => 9'h10A => 9'h00A);
							bins add = (9'h10C => 9'h10C => 9'h00C);
							bins dat = (9'h10E=> 9'h10E => 9'h00E);
							}	
	endgroup


// Covergroup CG3. This Covergroup is used to check fucntion coverage of all protocol validation. Cross Coverage is written to check 
// all protocol checks in every possible mode of operation. This Cover Group is sampled on every even of start_protocol_checks_cov.
 
	covergroup cg3 @start_protocol_checks_cov;
		start_bit : coverpoint start_bit {
							bins sta = {1'b1};
							}
		stop_bit  : coverpoint stop_bit {
							bins sto = {1'b1};
							}
		slave_ack : coverpoint slave_ack {
							bins sl_ac = {1'b1};
							}
		data_ack : coverpoint data_ack {
							bins da_ac = {1'b1};
							}	
		intr_ack : coverpoint intr_ack {
							bins int_ac = {1'b1};
							}
		start_mode_cross : cross start_bit, master_slave, tx_rx;
		stop_mode_corss  : cross stop_bit, master_slave, tx_rx;
		sack_mode_cross  : cross slave_ack, master_slave, tx_rx;
		dack_mode_cross  : cross data_ack, master_slave, tx_rx;
		inack_mode_cross : cross intr_ack, master_slave, tx_rx;
	endgroup


// Class Constructor
	function new(string name, string instance);
		super.new("fifo_coverage_gen","COVERAGE_GEN");
		cg1 = new;
		cg2 = new;
		cg3 = new;	
	endfunction


// This task will assign values of object's(cov_pkt) fields to local variables and then trigger the event start_cov to sample Covergroup CG1. 
	task pre_txn_start_cov (scoreboard_pkt cov_pkt);
		this.cov_pkt = cov_pkt;
		data_byte = cov_pkt.data_byte;
		slave_address = cov_pkt.slave_address;
		master_slave = cov_pkt.master_slave;
		tx_rx = cov_pkt.tx_rx;	
		-> start_cov;
	endtask

// This task will assign values of object's(reg_pkt) fields to local variables and then trigger the event start_cov_reg to sample Covergroup CG2. 
	task write_reg_cov (register_pkt reg_pkt);
		this.reg_pkt = reg_pkt;
		reg_address = reg_pkt.reg_address;
		wr_rd = reg_pkt.wr_rd;
		reset_bit = reg_pkt.reset_bit;
		reg_addr_txn = {wr_rd,reg_address};
		-> start_cov_reg;
	endtask

// This task will assign values of object's(reg_pkt) fields to local variables and then trigger the event start_cov_reg to sample Covergroup CG2. 
	task read_reg_cov (register_pkt reg_pkt);
		this.reg_pkt = reg_pkt;
		reg_address = reg_pkt.reg_address;
		wr_rd = reg_pkt.wr_rd;
		reg_addr_txn = {wr_rd,reg_address};
		-> start_cov_reg;
	endtask
	
// This task will assign values of object's(mon_pkt) fields to local variables and then trigger the event start_protocol_checks_cov to 
// sample Covergroup CG2. 
	task protocol_checks_cov (monitor_pkt mon_pkt);
		this.mon_pkt = mon_pkt;
		start_bit = mon_pkt.start_bit;
		stop_bit  = mon_pkt.stop_bit;
		slave_ack = mon_pkt.slave_ack;
		data_ack  = mon_pkt.data_ack;
		intr_ack  = mon_pkt.intr_ack;
		-> start_protocol_checks_cov;
	endtask

	
endclass	
