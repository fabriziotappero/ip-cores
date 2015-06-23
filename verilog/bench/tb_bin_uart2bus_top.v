//---------------------------------------------------------------------------------------
// uart test bench   
//
//---------------------------------------------------------------------------------------

`include "timescale.v"

module test;
//---------------------------------------------------------------------------------------
// include uart tasks 
`include "uart_tasks.v" 

// define if simulation should be binary or ascii 
parameter BINARY_MODE = 1;

// internal signal  
reg clock;		// global clock 
reg reset;		// global reset 
reg [6:0] counter;

//---------------------------------------------------------------------------------------
// test bench implementation 
// global signals generation  
initial
begin
	counter = 0;
	reset = 1;
	#40 reset = 0;
end 

// clock generator - 40MHz clock 
always 
begin 
	#12 clock = 0;
	#13 clock = 1;
end 

// test bench dump variables 
initial 
begin 
	$dumpfile("test.vcd");
	//$dumpall;
	$dumpvars(0, test);
end 

//------------------------------------------------------------------
// test bench transmitter and receiver 
// uart transmit - test bench control 
integer file;		// file handler index 
integer char;		// character read from file 
integer file_len;	// length of binary simulation file 
integer byte_idx;	// byte index in binary mode simulation 
integer tx_len;
integer rx_len;
reg new_rx_data;
reg [7:0] tx_byte;

initial 
begin 
	// defualt value of serial output 
	serial_out = 1;
	// wait for reset to de-assert 
	while (reset) @ (posedge clock);
	// wait for another 100 clock cycles before starting simulation 
	repeat (100) @ (posedge clock);

	// check simulation mode 
	if (BINARY_MODE > 0)
	begin 
		// binary mode simulation 
		$display("Starting binary mode simulation");
		// open binary command file 
		file=$fopen("test.bin", "rb"); 
		// in binary simulation mode the first two byte contain the file length (MSB first) 
		file_len = $fgetc(file);
		file_len = 256*file_len + $fgetc(file);
		$display("File length: %d", file_len);
		
		// send entire file to uart 
		byte_idx = 0;
		while (byte_idx < file_len)
		begin 
			// each "record" in the binary starts with two bytes: the first is the number 
			// of bytes to transmit and the second is the number of received bytes to wait 
			// for before transmitting the next command. 
			tx_len = $fgetc(file);
			rx_len = $fgetc(file);
			$display("Executing command with %d tx bytes and %d rx bytes", tx_len, rx_len);
			byte_idx = byte_idx + 2;
			
			// transmit command 
			while (tx_len > 0)
			begin 
				// read next byte from file and transmit it 
				char = $fgetc(file);
				tx_byte = char;
				byte_idx = byte_idx + 1;
				send_serial(tx_byte, `BAUD_115200, `PARITY_EVEN, `PARITY_OFF, `NSTOPS_1, `NBITS_8, 0); 
				// update tx_len 
				tx_len = tx_len - 1;
			end 
			
			// wait for received bytes 
			while (rx_len > 0)
			begin 
				// one clock delay to allow new_rx_data to update 
				@(posedge new_rx_data) rx_len = rx_len - 1;
				// check if a new byte was received 
				if (new_rx_data)
					rx_len = rx_len - 1;
			end 
			
			$display("Command finished");
		end 
	end 
	else 
	begin 
		// ascii mode simulation 
		// open UART command file 
		file=$fopen("test.txt", "rt"); 
		// transmit the byte in the command file one by one 
		char = $fgetc(file);
		while (char >= 0) begin 
			// transmit byte through UART 
			send_serial(char, `BAUD_115200, `PARITY_EVEN, `PARITY_OFF, `NSTOPS_1, `NBITS_8, 0); 
			#200000;
			// read next byte from file 
			char = $fgetc(file);
		end 
	end 
	
	// close input file 
	$fclose(file);
	
	// delay and finish 
	#500000;
	$finish;
end 

// uart receive 
initial 
begin 
	// default value for serial receiver and serial input 
	serial_in = 1;
	get_serial_data = 0;		// data received from get_serial task 
	get_serial_status = 0;		// status of get_serial task  
end 

// serial sniffer loop 
always 
begin 
	// clear new_rx_data flag 
	new_rx_data = 0;
	
	// call serial sniffer 
	get_serial(`BAUD_115200, `PARITY_EVEN, `PARITY_OFF, `NSTOPS_1, `NBITS_8);
	
	// check serial receiver status 
	// byte received OK 
	if (get_serial_status & `RECEIVE_RESULT_OK)
	begin
		// check if not a control character (above and including space ascii code)
		if (get_serial_data >= 8'h20) 
			$display("received byte 0x%h (\"%c\") at %t ns", get_serial_data, get_serial_data, $time);
		else 
			$display("received byte 0x%h (\"%c\") at %t ns", get_serial_data, 8'hb0, $time);
		
		// sign to transmit process that a new byte was received 
		@(posedge clock) new_rx_data = 1;
		@(posedge clock) new_rx_data = 0;
	end 
	
	// false start error 
	if (get_serial_status & `RECEIVE_RESULT_FALSESTART)
		$display("Error (get_char): false start condition at %t", $realtime);

	// bad parity error 		
	if (get_serial_status & `RECEIVE_RESULT_BADPARITY)
		$display("Error (get_char): bad parity condition at %t", $realtime);

	// bad stop bits sequence 	
	if (get_serial_status & `RECEIVE_RESULT_BADSTOP)
		$display("Error (get_char): bad stop bits sequence at %t", $realtime);
end 

//------------------------------------------------------------------
// device under test 
// DUT interface 
wire	[15:0]	int_address;	// address bus to register file 
wire	[7:0]	int_wr_data;	// write data to register file 
wire			int_write;		// write control to register file 
wire			int_read;		// read control to register file 
wire	[7:0]	int_rd_data;	// data read from register file 
wire			int_req;		// bus access request signal 
wire			int_gnt;		// bus access grant signal 
wire			ser_in;			// DUT serial input 
wire			ser_out;		// DUT serial output 

// DUT instance 
uart2bus_top uart2bus1
(
	.clock(clock), 
	.reset(reset),
	.ser_in(ser_in), 
	.ser_out(ser_out),
	.int_address(int_address), 
	.int_wr_data(int_wr_data), 
	.int_write(int_write),
	.int_rd_data(int_rd_data), 
	.int_read(int_read), 
	.int_req(int_req), 
	.int_gnt(int_gnt) 
);
// bus grant is always active 
assign int_gnt = 1'b1;

// serial interface to test bench 
assign ser_in = serial_out;
always @ (posedge clock) serial_in = ser_out;

// register file model 
reg_file_model reg_file1 
(
	.clock(clock), 
	.reset(reset),
	.int_address(int_address[7:0]), 
	.int_wr_data(int_wr_data), 
	.int_write(int_write),
	.int_rd_data(int_rd_data), 
	.int_read(int_read)
);

endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------
