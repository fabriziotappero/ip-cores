//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code defines Register Packet. This packet will be used while running	//
//	Register Read-Write Testcases and this packet will be sent to Scoreboard from W/B 	//
//  Master Driver to Scoreboard and Coverage Module.							  		//
//																						//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"

class register_pkt extends vmm_data;

	vmm_log log;
	bit [7:0] reg_address;
	bit [7:0] data_byte;
	bit wr_rd;
	bit reset_bit;

	function new();
		super.new(this.log);
		this.log = new("Reg Data", "class");	
   	endfunction 

	function vmm_data copy(vmm_data to = null);
		copy = new this;
	endfunction


	function void display();
		this.log.start_msg(vmm_log::NOTE_TYP);
		void'(this.log.text($psprintf("slave_address is %b", this.reg_address)));
		void'(this.log.text($psprintf("data_byte is %b", this.data_byte)));
		void'(this.log.text($psprintf("write_read is %b", this.wr_rd)));
		void'(this.log.text($psprintf("reset_bit is %b", this.reset_bit)));
		this.log.end_msg();
	endfunction

endclass
		
