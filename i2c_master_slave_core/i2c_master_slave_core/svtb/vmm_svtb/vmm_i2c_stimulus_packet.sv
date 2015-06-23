//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//  This file defines Stimulus packet class for Scenario Generator. 					//
// 	The Packet Randomizes intr_en to enable/disable interrupt, byte_count to transfer 	//
//  Random no. of data_bytes, register_address and data for register testcase. It also  //
//  randomize slave address. Other fields get assigned in Scenario generator class.		//
//  Constraint block called reg_add is used to contrain randomized fields.				//
//																						//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"

class stimulus_packet extends vmm_data; 
 
	vmm_log log;

	rand bit intr_en ;  			// 1 for Interrupt enable and 0 for disable
	rand int byte_count; 			// no. of bytes to be transfered
    rand bit [7:0] register_data; 	// to check register read/write
    rand bit [7:0] register_addr; 	// to select the address of internal register
	rand bit [6:0] slave_address; 	// slave address to be checked
	bit [7:0] data_packet[];   		// data packets to be transfered
 	bit master_slave;				// 1 for master and 0 for slave
	bit tr;							// 1 for trasmit and 0 for receive
	bit register_check;				// 1 to check registers writing and 0 for not.
	bit reset_check;				// 1 to check reset test and 0 for not.
	int temp_count; 

	constraint reg_add {
        register_addr inside {8'h02, 8'h04, 8'h0A, 8'h0C, 8'h0E};
		byte_count inside {[2:10]};
		slave_address < 7'b111_1111;
		intr_en dist {0 := 1, 1 :=1};
    }
	
	
	function new();
		super.new(this.log);
		this.log = new("Stimulus Data", "class");	
   	endfunction 

   	function void display();
		this.log.start_msg(vmm_log::NOTE_TYP);
		void'(this.log.text($psprintf("Master/Slave mode is = %b\n", master_slave)));
		void'(this.log.text($psprintf("tr = %d\n", tr)));
		void'(this.log.text($psprintf("register_check = %b\n", register_check)));
		void'(this.log.text($psprintf("reset_check = %b\n", reset_check)));
		void'(this.log.text($psprintf("Interrupt Enable is = %b\n", intr_en)));
		void'(this.log.text($psprintf("byte_count = %d\n", byte_count)));
		void'(this.log.text($psprintf("register_addr = %b\n", register_addr)));
		void'(this.log.text($psprintf("register_data = %b\n", register_data)));
		void'(this.log.text($psprintf("slave_address = %b\n", slave_address)));
		this.log.end_msg();
		temp_count = byte_count;
	endfunction	


	function vmm_data copy(vmm_data to = null);
		copy = new this;
	endfunction
	
endclass
`vmm_channel(stimulus_packet)         // This macro defined in VMM Methodology creates channel named stimulus_packet_channel

