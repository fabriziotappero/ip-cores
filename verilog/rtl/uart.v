//---------------------------------------------------------------------------------------
// uart top level module  
//
//---------------------------------------------------------------------------------------

module uart 
(
	clock, reset,
	serIn, serOut,
	txData, txValid, 
	txBusy, txDone, 
	rxData, rxValid, 
	baudDiv
);
//---------------------------------------------------------------------------------------
// module interfaces 
// global signals 
input 			clock;		// global clock input 
input 			reset;		// global reset input 
// uart serial signals 
input			serIn;		// serial data input 
output			serOut;		// serial data output 
// transmit and receive internal interface signals 
input	[7:0]	txData;		// data byte to transmit 
input			txValid;	// asserted to indicate that there is a new data byte for transmission 
output 			txBusy;		// signs that transmitter is busy 
output			txDone;		// transmitter done pulse 
output	[7:0]	rxData;		// data byte received 
output 			rxValid;	// signs that a new byte was received 
// baud rate configuration register 
input	[15:0]	baudDiv;	// baud rate setting register = round(clock_freq/baud_rate/16) - 1

//---------------------------------------------------------------------------------------
// internal declarations 
// registered output 
reg serOut, txBusy, txDone, rxValid;
reg [7:0] rxData;

// internals 
reg [8:0] txShiftReg;
reg [7:0] rxShiftReg;
reg [3:0] txBaudCnt, txBitCnt, rxBaudCnt, rxBitCnt;
reg [15:0] baudCount;
reg baudCE16, sserIn, rxBusy;

//---------------------------------------------------------------------------------------
// module implementation 
// transmitter control process 
always @ (posedge reset or posedge clock)
begin 
	if (reset) 
	begin 
		txBusy <= 1'b0;
		txDone <= 1'b0;
		txShiftReg <= 9'b0;
		serOut <= 1'b1;
		txBaudCnt <= 4'b0;
		txBitCnt <= 4'b0;
	end 
	else if (!txBusy) 
	begin 
		// check if transmitter operation should start 
		if (txValid) 
		begin 
			// register the data shift register and assert the transmitter busy flag 
			txShiftReg <= {txData, 1'b0};
			txBusy <= 1'b1;
		end 
			
		// defaults 
		serOut <= 1'b1;
		txDone <= 1'b0;
		txBaudCnt <= 4'b0;
		txBitCnt <= 4'b0;
	end 
	else if (baudCE16) 
	begin 
		// check if next bit should be sent out 
		if (txBaudCnt == 4'b0) 
		begin 
			//check if this is the last bit 
			if (txBitCnt == 4'd10) 
			begin 
				// clear the busy flag and pulse done flag 
				txBusy <= 1'b0;
				txDone <= 1'b1;
			end 
			
			// update the bit counter 
			txBitCnt <= txBitCnt + 4'd1;
			
			// update the serial output and shift register 
			serOut <= txShiftReg[0];
			txShiftReg <= {1'b1, txShiftReg[8:1]};
		end 
		
		// update the baud clock counter 
		txBaudCnt <= txBaudCnt + 4'd1;
	end 
end 

// receiver control process 
always @ (posedge reset or posedge clock)
begin 
	if (reset) 
	begin 
		rxBusy <= 1'b0;
		rxShiftReg <= 8'b0;
		rxBaudCnt <= 4'b0;
		rxBitCnt <= 4'b0;
		rxData <= 8'b0;
		rxValid <= 1'b0;
	end 
	else if (!rxBusy) 
	begin 
		// check start bit 
		if (!sserIn && baudCE16) 
		begin 
			// check if the serial input is zero for 8 baudCE16 cycles 
			if (rxBaudCnt == 4'd7)
			begin 
				// sign that receiver is busy and clear the bit counter 
				rxBusy <= 1'b1;
				rxBaudCnt <= 4'b0;
			end 
			else 
				rxBaudCnt <= rxBaudCnt + 4'd1;
		end 
		
		// defaults 
		rxBitCnt <= 4'b0;
		rxValid <= 1'b0;
	end 
	else if (baudCE16)
	begin 
		// check if bit should be sampled 
		if (rxBaudCnt == 4'd15) 
		begin 
			// update the input shift register and bit counter 
			rxShiftReg <= {sserIn, rxShiftReg[7:1]};
			rxBitCnt <= rxBitCnt + 4'd1;
			
			// check if this is the last data bit 
			if (rxBitCnt == 4'd8)
			begin 
				// sample the received data byte 
				rxData <= rxShiftReg;
				rxValid <= 1'b1;
				
				// clear receiver busy flag 
				rxBusy <= 1'b0;
			end 
		end 
		
		// update the baud clock counter 
		rxBaudCnt <= rxBaudCnt + 4'd1;
	end 
end 

// sample serial input 
always @ (posedge reset or posedge clock)
begin 
	if (reset) 
		sserIn <= 1'b0;
	else 
		sserIn <= serIn;
end 

// baud rate clock generator 
always @ (posedge reset or posedge clock)
begin 
	if (reset) 
	begin 
		baudCount <= 16'b0;
		baudCE16 <= 1'b0;
	end 
	else if (baudCount == baudDiv) 
	begin 
		// clear the divider counter and pulse the clock enable signal 
		baudCount <= 16'b0;
		baudCE16 <= 1'b1;
	end 
	else 
	begin 
		// update the clock divider counter and clear the 
		baudCount <= baudCount + 16'd1;
		baudCE16 <= 1'b0;
	end 
end 

endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------
