////////////////////////////Shift.v/////////////////////////////////////////////////////////////////////
//												      //	
//Design Engineer:	Ravi Gupta								      //
//Company Name	 :	Toomuch Semiconductor
//Email		 :	ravi1.gupta@toomuchsemi.com						      //	
//												      //
//Purpose	 :	Used for shifting address and data in both transmit and recieve mode	      //	
//created	 :	22-11-07								      //
//												      //				
////////////////////////////////////////////////////////////////////////////////////////////////////////

/*// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"*/


module shift(clk,asyn_rst,load,shift_en,serial_in,data_in,serial_out,data_out);
	
input	clk,asyn_rst,load,shift_en,serial_in;
input	[7:0]data_in;

output	serial_out;
output	[7:0]data_out;

reg	[7:0]data;

always@(posedge clk or posedge asyn_rst or posedge load)
begin
	if(asyn_rst)
		data<=8'h0;				//clear the data register upon asynchronous reset.
	
	else if(load)
		data<=data_in;				//Load the internal register upon insertion of load bit.
	
	else if(shift_en)
		data<={data[6:0],serial_in};		//Upon shift_en high every time a new serial data is coming to LSB bit and data will be shifted
							//to one bit.
	else
		data<=data;				//Prevent formation of latches
end


assign data_out = data;					//Output the data in a data_register
assign serial_out = data[7];				//MSB is transmitted first in I2C protocol.


endmodule

//change loading into asynchronous mode		

