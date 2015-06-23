//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code defines Scoreboard Packet. This packet will be sent to Scoreboard	//
//	and Coverage Module from Both W/B Driver and I2C M/S Driver through vmm_callback.	//
//																						//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"

class scoreboard_pkt extends vmm_data;

	vmm_log log;
	bit master_slave;					// 1 for Master; 0 for Slave;
	bit tx_rx;							// 1 for Tx; 0 for Rx
	bit [6:0] slave_address;			// 7-bit Slave Address
	bit [7:0] data_byte;				// 8-bit Data Byte

	function new();
		super.new(this.log);
		this.log = new("Sb Data", "class");	
   	endfunction 

	function vmm_data copy(vmm_data to = null);
		copy = new this;
	endfunction


	function void display();
		this.log.start_msg(vmm_log::NOTE_TYP);
		void'(this.log.text($psprintf("master_slave is %0b", this.master_slave)));
		void'(this.log.text($psprintf("tx_rx is %0b", this.tx_rx)));
		void'(this.log.text($psprintf("slave_address is %b", this.slave_address)));
		void'(this.log.text($psprintf("data_byte is %b", this.data_byte)));
		this.log.end_msg();
	endfunction

endclass
		
