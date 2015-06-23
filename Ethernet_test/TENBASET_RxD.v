`timescale 1ns / 1ps
// 10BASE-T receiving interface (based on fpga4fun.com version)
module TENBASET_RxD(clk48,
	manchester_data_in,
	RcvData, RcvStart, RcvStop, new_bit_available, new_byte_available, end_of_Ethernet_frame,	sync2);
	
input clk48;
input manchester_data_in;
output [7:0] RcvData;
output RcvStart;
output RcvStop;
output new_bit_available;
output new_byte_available;
output end_of_Ethernet_frame;
output [9:0] sync2;

reg [7:0] RcvData = 0;
reg RcvStart = 0;
reg RcvStop = 0;
reg new_bit_available = 0;
reg end_of_Ethernet_frame = 0;

reg [2:0] in_data = 0;
reg [1:0] cnt = 0;
reg [2:0] transition_timeout = 0;
reg [4:0] sync1 = 0;
reg [9:0] sync2 = 0;

wire new_byte_available = ((new_bit_available) && (sync2[2:0] == 3'h0) && (sync2[9:3] != 0));  

always @(posedge clk48) begin
	in_data <= {in_data[1:0], manchester_data_in};
	new_bit_available <= (cnt == 3);
	if (|cnt || (in_data[2] ^ in_data[1])) 
		cnt <= cnt + 1;
	if (cnt == 3) 
		RcvData <= {in_data[1], RcvData[7:1]};
end

/////////////////////////////////////////////////
always @(posedge clk48)	begin
	if (end_of_Ethernet_frame)
		sync1 <= 0; 
	else if (new_bit_available) 
		begin
		if (!(RcvData == 8'h55 || RcvData == 8'hAA)) // not preamble?
			sync1 <= 0;
		else if (~&sync1) // if all bits of this "sync1" counter are one, we decide that enough of the preamble
							 // has been received, so stop counting and wait for "sync2" to detect the SFD
			sync1 <= sync1 + 1; // otherwise keep counting
		end
end

always @(posedge clk48) begin
	RcvStart <= 0;
	if (end_of_Ethernet_frame)
		sync2 <= 0;
	else if (new_bit_available) 
		begin
		if  (|sync2) // if the SFD has already been detected (Ethernet data is coming in)
			begin
			sync2 <= sync2 + 1; // then count the bits coming in
			if (&sync2)
				sync2 <= 8;
			end
		else if (&sync1 && RcvData == 8'hD5) // otherwise, let's wait for the SFD (0xD5)
			begin
			RcvStart <= 1;
			sync2 <= 1;
			end
		end
end

/////////////////////////////////////////////////
// if no clock transistion is detected for some time, that's the end of the Ethernet frame

always @(posedge clk48) begin
	if (in_data[2] ^ in_data[1]) 
		transition_timeout <= 0;
	else if (~&cnt) 
		transition_timeout <= transition_timeout + 1;
end

always @(posedge clk48) begin 
	RcvStop <= 0;
	end_of_Ethernet_frame <= &transition_timeout;
	if (!end_of_Ethernet_frame && &transition_timeout && |sync2)
		RcvStop <= 1;
end

endmodule
