//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//  This file is the packet class for Scenario Generator. 								//
//	The Packet Randomizes Master/Slave bit,(1 for configuring DUT as a Master and 0 for //
//  Slave), tx_rx bit, which determines the direction of data to be transfered.	       	//
//  It also randomize reset_check and register_check to enable/disable reset or register//
//  testcases. Transacation_count will be assigned from environment itself.				//
//																						//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////


`include "vmm.sv"

class scenario_packet extends vmm_data; 
   
	vmm_log log;

	randc bit master_slave ;  		// 1 for master and and 0 for slave
	int transaction_count; 	   		// No. of transaction to be done
    rand bit register_check; 		// to check register read/write
    rand bit reset_check; 			// to check reset
	rand bit tx_rx ;  				// 1 for transmit and and 0 for receive
	
	
	function new();
    		super.new(this.log);
		this.log = new("Scenario data", "class");		
   	endfunction 

   	function void display();
		this.log.start_msg(vmm_log::NOTE_TYP);
		void'(this.log.text($psprintf("Master/Slave mode is = %b\n", master_slave)));
		void'(this.log.text($psprintf("transaction_count = %d\n", transaction_count)));
		void'(this.log.text($psprintf("register_check = %b\n", register_check)));
		void'(this.log.text($psprintf("reset_check = %b\n", reset_check)));
		void'(this.log.text($psprintf("tx_rx = %b\n", tx_rx)));
		this.log.end_msg();
	endfunction	


	function vmm_data copy(vmm_data to = null);
		copy = new this;
	endfunction
	
	constraint valid_scenario {
		reset_check dist {1 := 1 , 0 := 20};
		register_check dist { 1 := 1 , 0 := 20}; 
	}

endclass: scenario_packet


