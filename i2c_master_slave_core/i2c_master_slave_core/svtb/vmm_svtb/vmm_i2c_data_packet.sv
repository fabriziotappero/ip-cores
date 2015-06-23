//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//  This file is the data packet class for Scenario Generator.							//
//	The Packet Randomizes data_pkt whose size will be assigned in Scenario Generator.	//
//																						//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////

`include "vmm.sv"

class i2c_data_packet extends vmm_data; 
 	vmm_log  log;  
	rand bit [7:0] data_pkt[];   // data packets to be transfered

	function new();
       		super.new(this.log);
		this.log = new("Data_packet", "class");
   	endfunction 

	function void display();
		int i;
		this.log.start_msg(vmm_log::NOTE_TYP);
		while( i < data_pkt.size)
		begin			
			void'(this.log.text($psprintf("Data_Byte[%0d] is %b", i, this.data_pkt[i])));
			i++;
		end
		this.log.end_msg();
	endfunction	


	function vmm_data copy(vmm_data to = null);
		copy = new this;
	endfunction

endclass : i2c_data_packet

