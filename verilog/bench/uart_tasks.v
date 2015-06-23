//------------------------------------------------------------------------------
// uart tasks:
//		send_serial		serial transmitter 
// 		get_serial		serial receiver 
//
//------------------------------------------------------------------------------

/*  Serial Parameters used for send_serial task and its callers. */
`define PARITY_OFF		1'b0
`define PARITY_ON		1'b1
`define PARITY_ODD		1'b0
`define PARITY_EVEN		1'b1
`define NSTOPS_1		1'b0
`define NSTOPS_2		1'b1
`define BAUD_115200		3'b000
`define BAUD_38400		3'b001
`define BAUD_28800		3'b010
`define BAUD_19200		3'b011
`define BAUD_9600		3'b100
`define BAUD_4800		3'b101
`define BAUD_2400		3'b110
`define BAUD_1200		3'b111
`define NBITS_7			1'b0
`define NBITS_8			1'b1
// constants for status from get_serial task 
`define RECEIVE_RESULT_OK			4'b1000 
`define RECEIVE_RESULT_FALSESTART	4'b0001 
`define RECEIVE_RESULT_BADPARITY	4'b0010 
`define RECEIVE_RESULT_BADSTOP		4'b0100 

// uart tasks global interfaces signals 
reg serial_out;		// transmit serial output 
reg serial_in;		// receive serial input 
reg [7:0] get_serial_data;		// data received from serial 
reg [7:0] get_serial_status;	// status of receive operation 

//------------------------------------------------------------------------------
// uart transmit task 
// 
// usage:
//		send_serial (data, baud_rate, parity_type, parity_on, stop_bits_num, 
//														data_bit_num, baud_error);
// where:
//		data			data character for transmission 
//		parity_type		this is a flag indicating that parity should be even 
//						(either 'PARITY_ODD or 'PARITY_EVEN)
//		parity_on		indicates that the parity is used 
//						(either 'PARITY_OFF or 'PARITY_ON)
//		stop_bits_num	number of stop bits (either NSTOPS_1 or NSTOPS_2)
//		data_bit_num	number of data bits (either NBITS_7 or NBITS_8)
//		baud_error		baud error in precentage (-5 is -5%)
// 

task send_serial;
// task input parameters 
input [7:0] inputchar;
input baud;
input paritytype;
input parityenable;
input nstops;
input nbits;
input baud_error_factor;
// internal registers 
reg       nbits;
reg       parityenable;
reg       paritytype;
reg [1:0] baud;
reg       nstops;
integer		baud_error_factor;  // e.g. +5 means 5% too fast and -5 means 5% too slow
reg	[7:0] 	char;
reg [7:0]	disp_char;
reg         parity_bit;
integer     bit_time;
integer		num_of_bits;
// task implementation 
begin 
	char = inputchar;
	parity_bit = 1'b0;
	// calculate bit time from input baud rate - this assumes a simulation resolution of 1ns 
	case (baud)
		`BAUD_115200: bit_time = 1000000000/(115200 + 1152*baud_error_factor);
//	        `BAUD_115200: bit_time = 40000000000/(115200 + 1152*baud_error_factor);
		`BAUD_38400:  bit_time = 1000000000/(38400 + 384*baud_error_factor);
		`BAUD_28800:  bit_time = 1000000000/(28800 + 288*baud_error_factor);
		`BAUD_19200:  bit_time = 1000000000/(19200 + 192*baud_error_factor);
		`BAUD_9600:   bit_time = 1000000000/(9600 + 96*baud_error_factor);
		`BAUD_4800:   bit_time = 1000000000/(4800 + 48*baud_error_factor);
		`BAUD_2400:   bit_time = 1000000000/(2400 + 24*baud_error_factor);
		`BAUD_1200:   bit_time = 1000000000/(1200 + 12*baud_error_factor);
	endcase   

	// display info 
	disp_char = (char >= 8'h20) ? char : 8'hb0;
	$display ("Sending character 0x%h (\"%c\"), at %0d baud (err=%0d), %0d bits, %0s parity, %0d stops",
		(nbits == `NBITS_7) ? (char & 8'h7f) : char,
		(nbits == `NBITS_7) ? (disp_char & 8'h7f) : disp_char,
		1000000000/bit_time,
		baud_error_factor,
		(nbits == `NBITS_7) ? 7 : 8,
		(parityenable == `PARITY_OFF) ? "NONE" : (paritytype == `PARITY_EVEN) ? "EVEN" : "ODD",
		(nstops == `NSTOPS_1) ? 1 : 2
	);

	// Start bit
	serial_out = 1'b0;   // Start bit.
	#(bit_time);

	// Output data bits
	num_of_bits = (nbits == `NBITS_7) ? 7 : 8;
	repeat (num_of_bits) 
	begin
		serial_out = char[0];
		#(bit_time);
		char = {1'b0, char[7:1]};
	end

	// check if parity is enabled 
	if (parityenable == `PARITY_ON) begin
		parity_bit = (nbits == `NBITS_7) ? ^inputchar[6:0] : ^inputchar[7:0];
		// even parity
		if (paritytype == `PARITY_ODD) 
			parity_bit = ~parity_bit; 
			
		serial_out = parity_bit;
		#(bit_time);
	end
	
	// Stop bit.
	serial_out = 1'b1;   
	#(bit_time);
	// Second stop bit
	if (nstops) 
		#(bit_time);
end
endtask

//------------------------------------------------------------------------------
// uart receive task 
// 
// usage:
//		get_serial (baud_rate, parity_type, parity_on, stop_bits_num, data_bit_num);
// where:
//		data			data character for transmission 
//		parity_type		this is a flag indicating that parity should be even 
//						(either 'PARITY_ODD or 'PARITY_EVEN)
//		parity_on		indicates that the parity is used 
//						(either 'PARITY_OFF or 'PARITY_ON)
//		stop_bits_num	number of stop bits (either NSTOPS_1 or NSTOPS_2)
//		data_bit_num	number of data bits (either NBITS_7 or NBITS_8)
// 
task get_serial;
// input parameters 
input baud;
input paritytype;
input parityenable;
input nstops;
input nbits;
// internal registers 
reg       nbits;
reg       parityenable;
reg       paritytype;
reg [1:0] baud;
reg       nstops;
integer     bit_time;
reg         expected_parity;
integer		num_of_bits;
// task implementation 
begin 
	// init receive globals 
	get_serial_status = 0;
	get_serial_data = 0;

	// calculate bit time from input baud rate - this assumes a simulation resolution of 1ns 
	case (baud)
		`BAUD_115200: bit_time = 1000000000/115200;
		`BAUD_38400:  bit_time = 1000000000/38400;
		`BAUD_28800:  bit_time = 1000000000/28800;
		`BAUD_19200:  bit_time = 1000000000/19200;
		`BAUD_9600:   bit_time = 1000000000/9600;
		`BAUD_4800:   bit_time = 1000000000/4800;
		`BAUD_2400:   bit_time = 1000000000/2400;
		`BAUD_1200:   bit_time = 1000000000/1200;
	endcase   

	// Assume OK until bad things happen.
	get_serial_status = `RECEIVE_RESULT_OK;  

	// wait for start bit edge 
	@(negedge serial_in);  

	// wait till center of start bit 
	#(bit_time/2);  

	// make sure its really a start bit
	if (serial_in != 0) 
		get_serial_status = get_serial_status | `RECEIVE_RESULT_FALSESTART;
	else 
	begin
		// get all the data bits (7 or 8) 
		num_of_bits = (nbits == `NBITS_7) ? 7 : 8;
		repeat (num_of_bits) 
		begin 
			// wait till center 
			#(bit_time);  
			// sample a data bit
			get_serial_data = {serial_in, get_serial_data[7:1]};
		end

		// If we are only expecting 7 bits, go ahead and right-justify what we have
		if (nbits == `NBITS_7)
			get_serial_data = {1'b0, get_serial_data[7:1]};

		// wait for next bit to start 
		#(bit_time);

 		// now, we have either a parity bit, or a stop bit
 		if (parityenable == `PARITY_ON) begin
 			if (paritytype == `PARITY_EVEN)
 				expected_parity = (nbits == `NBITS_7) ? (^get_serial_data[6:0]) :            
 															(^get_serial_data[7:0]);
 			else
 				expected_parity = (nbits == `NBITS_7) ? (~(^get_serial_data[6:0])) :  
 															(~(^get_serial_data[7:0]));

 			if (expected_parity != serial_in)
 				get_serial_status = get_serial_status | `RECEIVE_RESULT_BADPARITY;
 		end
 		// wait for either 1 or 2 stop bits
 		else begin
 			// this is a stop bit.
 			if (serial_in != 1)
 				get_serial_status = get_serial_status | `RECEIVE_RESULT_BADSTOP;
 			else
 				// that was cool.  if 2 stops, then do this again
 				if (nstops) 
 				begin
 					#(bit_time);
 					if (serial_in != 1)
 						get_serial_status = get_serial_status | `RECEIVE_RESULT_BADSTOP;
 				end
 		end
	end
end
endtask

