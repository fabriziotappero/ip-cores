//////////////////////////counter.v///////////////////////////////////////////////////////////////////////////////
														//
//Designed Engineer:	Ravi Gupta										//
//Company Name	   :	Toomuch Semiconductor
//Email		   :	ravi1.gupta@toomuchsemi.com								//
														//
//Purpose	   :	Used for counting clock pulses for prescale register and number of bytes transferred	//
//Created	   :	22-11-07										//
														//				
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"*/


module counter (clk,asyn_rst,enable,load,data_in,out);

input	clk,asyn_rst,enable,load;
input	[7:0] data_in;
output	[7:0] out;

reg	[7:0]data;

always@(posedge clk or posedge asyn_rst)
begin
	if(asyn_rst)
		data<=8'h0;				//clear all bits upon asynchronous reset.
	else if(load)
		data<=data_in;				//load the counter with incoming data if load signal is high
	else if(enable)
		data<=data + 1'b1;			//Increment the counter if enable bit is high
	else
		data<=data;				//else hold the data;else part is mention to avoid latch formation
end

assign out=data;

endmodule 	 	
