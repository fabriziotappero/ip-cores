//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code defines Monitor Packet. This packet will be sent to Scoreboard and	//
//	Coverage Module from Monitor Transactor.													  		//
//																						//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"

class monitor_pkt extends vmm_data;

	vmm_log log;
	bit start_bit;				// Start bit
	bit stop_bit;				// Stop bit
	bit slave_ack;				// Slave Acknowledgment
	bit data_ack;				// Data Acknowledgment
	bit intr_ack;				// Interrupt Generation Acknowledgment

// Class Constructor
	function new();
		super.new(this.log);
		this.log = new("Monitor Data", "class");	
   	endfunction 

	function vmm_data copy(vmm_data to = null);
		copy = new this;
	endfunction

// Display Function
	function void display();
		this.log.start_msg(vmm_log::NOTE_TYP);
		void'(this.log.text($psprintf("start_bit is %0b", this.start_bit)));
		void'(this.log.text($psprintf("stop_bit is %0b", this.stop_bit)));
		void'(this.log.text($psprintf("slave_ack is %b", this.slave_ack)));
		void'(this.log.text($psprintf("data_ack is %b", this.data_ack)));
		void'(this.log.text($psprintf("intr_ack is %b", this.intr_ack)));
		this.log.end_msg();
	endfunction

endclass
		
