/*	MODULE: openfire vga
	DESCRIPTION: I/O space and peripherals instantiation

AUTHOR: 
Antonio J. Anton
Anro Ingenieros (www.anro-ingenieros.com)
aj@anro-ingenieros.com

REVISION HISTORY:
Revision 1.0, 26/03/2007
Initial release

COPYRIGHT:
Copyright (c) 2007 Antonio J. Anton

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.*/

`timescale 1ns / 1ps
`include "openfire_define.v"

module openfire_iospace(
`ifdef SP3SK_USERIO
	leds, drivers_n, segments_n, pushbuttons, switches,
`endif
`ifdef UART1_ENABLE
	tx1, rx1,		  
`endif
`ifdef UART2_ENABLE
	tx2, rx2,
`endif
`ifdef SP3SK_PROM_DATA
	prom_din, prom_cclk, prom_reset_n,
`endif
`ifdef IO_MULTICYCLE
	done,
`endif
`ifdef ENABLE_INTERRUPTS
    interrupt,
`endif
	clk,  rst, read, write,
	addr, data_in, data_out
);

input				clk;
input				rst;
input				read;				// iospace read requesst
input				write;			// iospace write request
`ifdef IO_MULTICYCLE
output			done;				// iospace operation completed
`endif
input	 [`IO_SIZE-1:0] addr;	// address of operation
input  [31:0]  data_in;			// data from cpu
output [31:0]  data_out;		// data to cpu
`ifdef SP3SK_USERIO
output [7:0] 	leds;				// LEDS (1=on)
output [3:0]	drivers_n;		// 7SEG driver (negated)
output [7:0]	segments_n;		// segments (negated)
input	 [3:0]	pushbuttons;	// 4 pushbuttons (  pushbuttons[3] = reset)
input	 [7:0]	switches;		// 8 switches
`endif
`ifdef UART1_ENABLE
output			tx1;				// transmit #1
input				rx1;				// receive #1
`endif
`ifdef UART2_ENABLE
output			tx2;				// transmit #2
input				rx2;				// receive #2
`endif
`ifdef SP3SK_PROM_DATA
input 			prom_din;		// data in from PROM
output		   prom_cclk;		// clock to PROM
output			prom_reset_n;	// reset to PROM
`endif
`ifdef ENABLE_INTERRUPTS
output		   interrupt;		// interrupt line to cpu
`endif

// ---- handle multicycle i/o operations ----
`ifdef IO_MULTICYCLE
assign ready = 1;
`endif

// --------------- UARTS -----------------
`ifdef UART1_ENABLE					// assure that baudrate generator is
	`define UART_BAUDRATEGEN_ENABLE	// instantiated if a uart is in use
`endif
`ifdef UART2_ENABLE
	`define UART_BAUDRATEGEN_ENABLE
`endif

`ifdef UART_BAUDRATEGEN_ENABLE
reg 	[4:0] 	baud_count;			// counter for a tick generator each 16 clocks
reg  				en_16_x_baud;		// tick signal every 16 clocks --> baud generator
`endif

`ifdef UART1_ENABLE
wire  			write_to_uart;		// write byte into send FIFO
wire  			tx_full;				// TX FIFO is full
wire  			tx_half_full;		// TX FIFO is 1/2 full
reg  				read_from_uart;	// read byte from receive FIFO
wire 	[7:0] 	rx_data;				// recieved data
wire  			rx_data_present;	// RX FIFO has data
wire  			rx_full;				// RX FIFO is full
wire  			rx_half_full;		// RX FIFO 1/2 full
`endif

`ifdef UART2_ENABLE
wire  			write_to_uart2;	// indica que hay que meter en la TX FIFO un byte
wire  			tx2_full;			// indica que la TX FIFO esta llena
wire  			tx2_half_full;		// indica que la TX FIFO esta 1/2 llena
reg  				read_from_uart2;	// obtener en rx_data un byte de la RX FIFO
wire 	[7:0] 	rx2_data;			// donde esta el byte recibido
wire  			rx2_data_present;	// indica que hay datos en RX FIFO
wire  			rx2_full;			// RX FIFO llena
wire  			rx2_half_full;		// RX FIFO 1/2 llena
`endif

//---------- baud rate generator -------------
// Set baud rate to 9600 for the UART communications	 DIV=CLK/(16*BAUDRATE)
// Requires en_16_x_baud to be 153600Hz which is a single cycle pulse every 325 cycles at 50MHz 
// NOTE : If the highest value for baud_count exceeds 127 you will need to adjust 
//        the width in the reg declaration for baud_count.
`ifdef UART_BAUDRATEGEN_ENABLE
always @(posedge clk) 			
begin
 if (baud_count == `BAUD_COUNT)
	begin
      baud_count <= 1'b0;
      en_16_x_baud <= 1'b1;
	end
 else
	begin
		baud_count <= baud_count + 1;
		en_16_x_baud <= 1'b0;
 end
end  
`endif

// -------- UART #1  ------------
// Connect the 8-bit, 1 stop-bit, no parity transmit and receive macros.
// Each contains an embedded 16-byte FIFO buffer.

`ifdef UART1_ENABLE							// hack to enable status register
	`define UART_STATUS_REG					// if at least one uart is present
`endif
`ifdef UART2_ENABLE
	`define UART_STATUS_REG
`endif

`ifdef UART1_ENABLE
uart_tx transmit(	
		.data_in(data_in[31:24]),			// 8 bits bajos del registro = dato a enviar
    	.write_buffer(write_to_uart),		// 
    	.reset_buffer(rst),
    	.en_16_x_baud(en_16_x_baud),
    	.serial_out(tx1),
    	.buffer_full(tx_full),
    	.buffer_half_full(tx_half_full),
    	.clk(clk)
);

uart_rx receive(	
		.serial_in(rx1),
    	.data_out(rx_data),
    	.read_buffer(read_from_uart),
    	.reset_buffer(rst),
    	.en_16_x_baud(en_16_x_baud),
    	.buffer_data_present(rx_data_present),
    	.buffer_full(rx_full),
    	.buffer_half_full(rx_half_full),
    	.clk(clk)
);
`endif

// -------- UART #2  ------------
// Connect the 8-bit, 1 stop-bit, no parity transmit and receive macros.
// Each contains an embedded 16-byte FIFO buffer.
`ifdef UART2_ENABLE
uart_tx transmit2(	
		.data_in(data_out[31:24]),			// 8 bits bajos del registro = dato a enviar
    	.write_buffer(write_to_uart2),	// 
    	.reset_buffer(rst),
    	.en_16_x_baud(en_16_x_baud),
    	.serial_out(tx2),
    	.buffer_full(tx2_full),
    	.buffer_half_full(tx2_half_full),
    	.clk(clk)
);

uart_rx receive2(	
		.serial_in(rx2),
    	.data_out(rx2_data),
    	.read_buffer(read_from_uart2),
    	.reset_buffer(rst),
    	.en_16_x_baud(en_16_x_baud),
    	.buffer_data_present(rx2_data_present),
    	.buffer_full(rx2_full),
    	.buffer_half_full(rx2_half_full),
    	.clk(clk)
);
`endif

// ----- SP3 STARTER KIT USER PORTS : LEDS, 7SEG DISPLAY, SWITCHES & PUSHBUTTONS ----
`ifdef SP3SK_USERIO
reg  [7:0]	leds;				// 8 leds
reg  [3:0]	drivers_n;		// 4 drivers
reg  [7:0]	segments_n;		// 8 segments
`endif

// ----- SP3 STARTER KIT PLATFORM FLASH ------------
`ifdef SP3SK_PROM_DATA
reg				prom_read;			// signal the prom_reader to read next byte
reg				prom_next_sync;	// signal the prom_reader to seek next file
wire				prom_synced;		// notify prom is at the start of a file
wire				prom_dataready;	// notify prom has readed a byte
wire	[7:0]		prom_dataout;		// data readed from prom

PROM_reader_serial prom_file(
	.clock(clk), 			
	.reset(rst),
	.din(prom_din), 		
	.cclk(prom_cclk), 				
	.reset_prom_n(prom_reset_n),
	.read(prom_read), 	
	.next_sync(prom_next_sync), 
	.sync(prom_synced), 	
	.data_ready(prom_dataready), 
	.dout(prom_dataout),
	.sync_pattern(`PROM_SYNC_PATTERN)
);
`endif

// -------- TIMER #1 GENERATOR (31 bits) -----------
`ifdef TIMER1_GENERATOR
reg   [30:0]	max_timer1_count;	// 32 bit max-timer value
reg 	[30:0] 	timer1_count;		// current value of the counter
reg  				timer1_pulse;		// positive pulse generated when max_timer1_count is reached
reg				timer1_running;	// indicates if timer is running/stopped

always @(posedge clk) 
begin
      if(rst | ~timer1_running)		// rst or not running --> restart timer
		begin
		  timer1_count  <= 0;
		  timer1_pulse <= 0;
		end
		else if (timer1_count == max_timer1_count)	// if max_timer1 reached --> generate 1 clock pulse
		begin
         	timer1_count <= 1'b0;
         	timer1_pulse <= 1'b1;
//synthesis translate_off
				$display("TIMER1 TRIGGERED (max_timer1_count=0x%x)", max_timer1_count);
//synthesis translate_on
		end
      else
		begin
         	timer1_count <= timer1_count + 1;
         	timer1_pulse <= 1'b0;
		end
end
`endif

// ------- interrupt controller ---------
`ifdef ENABLE_INTERRUPTS
reg [31:0] 		device_interrupt;					// enable interrupt for specific device

wire				interrupt = 						// interrupt line is an OR MASK of devices
`ifdef TIMER1_GENERATOR
								(device_interrupt[0] & timer1_pulse) |			// timer1 can generate interrupt
`endif
`ifdef UART1_ENABLE
								(device_interrupt[1] & rx_data_present) |		// uart1 rx data present
`endif
`ifdef UART2_ENABLE
								(device_interrupt[2] & rx2_data_present) |	// uart2 rx data present
`endif						
								0;
`endif

// --------------- decode output port (data to device) ----------------
always @(posedge clk)
begin
  if(rst)
  begin							// initialize devices on reset
`ifdef SP3SK_USERIO
  	segments_n 			<= 8'hFF;	// 7 segment display off
	drivers_n  			<= 4'hF;
	leds		  			<= 8'h00;	// leds off
`endif
`ifdef SP3SK_PROM_DATA
	prom_next_sync 	<= 1'b0;		// no prom activity
	prom_read			<= 1'b0;
`endif
`ifdef TIMER1_GENERATOR
	max_timer1_count 	<= 0;			// timer1 stopped
	timer1_running		<= 1'b0;
`endif
`ifdef ENABLE_INTERRUPTS
	device_interrupt	<= 0;			// no interrupts
`endif
  end
  else if(write)				// write to an output port
  begin
	 case( addr[`IO_SIZE-1:0] )
`ifdef SP3SK_USERIO
		`ADDR_SP3_IO	: begin								
								segments_n 	<= data_in[31:24];	// LSByte is the high bits
								drivers_n  	<= data_in[23:20];
	 							leds 			<= data_in[15:8];
							  end
`endif
`ifdef UART1_ENABLE
	   `ADDR_UART1		: $display("UART1 WRITE: <%c>", data_in[31:24]);
`endif
`ifdef UART2_ENABLE
	   `ADDR_UART2		: $display("UART2 WRITE: <%c>", data_in[31:24]);
`endif
`ifdef SP3SK_PROM_DATA
		`ADDR_PROM     : begin
								prom_next_sync <= data_in[23];
							   prom_read 		<= data_in[22];
						     end
`endif
`ifdef TIMER1_GENERATOR
		`ADDR_TIMER1   : begin
							   max_timer1_count  <= data_in[30:0];
								timer1_running	   <= data_in[31];
//synthesis translate_off
								if(data_in[31] == 0) $display("TIMER1 STOP");
								else $display("TIMER1 START (max_timer1_count=0x%x)", data_in[30:0]);
//synthesis translate_on
							  end
`endif
`ifdef ENABLE_INTERRUPTS
		`ADDR_INT		: device_interrupt <= data_in;
`endif
      default        : $display("Error: Output port not valid: ", addr[`IO_SIZE-1:0]);
    endcase
  end 
end

// write to UART transmitter FIFO buffer at address 01 hex.
// This is a combinatorial decode because the FIFO is the 'port register'.
`ifdef UART1_ENABLE
wire   uart1_selected = addr[`IO_SIZE-1:0] == `ADDR_UART1;
assign write_to_uart  = write & uart1_selected;
`endif
`ifdef UART2_ENABLE
wire	 uart2_selected = addr[`IO_SIZE-1:0] == `ADDR_UART2;
assign write_to_uart2 = write & uart2_selected;
`endif

// --------------- decode input port (data to cpu) ----------------
reg [31:0] data_out;					// register to store data from an input port
//synthesis translate_off
initial data_out <= 0;
//synthesis translate_on

always @(posedge clk)
begin
  if(read)				// request an input port
  begin
  	 case( addr[`IO_SIZE-1:0] )
`ifdef SP3SK_USERIO
		`ADDR_SP3_IO	: begin
							   data_out[31:24]	<= segments_n;		// LSByte is the high bits
								data_out[23:20]	<= drivers_n;
								data_out[19:16]	<= pushbuttons;
								data_out[15:8]		<= leds;
								data_out[7:0]		<= switches;
							  end
`endif
`ifdef UART_STATUS_REG
		`ADDR_UARTS		: begin			// depending which uarts are enabled, fill the status register
  `ifdef UART1_ENABLE
								data_out[28:24] <= { tx_full, tx_half_full, rx_full, rx_half_full, rx_data_present };
								$display("UART-STATUS : rx1_data_present=%d, rx1_half_full=%d, rx1_full=%d, tx1_half_full=%d, tx1_full=%d",  rx_data_present, rx_half_full, rx_full, tx_half_full, tx_full);
  `endif
  `ifdef UART2_ENABLE
								data_out[12:8] <= { tx2_full, tx2_half_full, rx2_full, rx2_half_full, rx2_data_present };
								$display("UART-STATUS : rx2_data_present=%d, rx2_half_full=%d, rx2_full=%d, tx2_half_full=%d, tx2_full=%d",  rx2_data_present, rx2_half_full, rx2_full, tx2_half_full, tx2_full);  
	`endif
  							  end
`endif
`ifdef UART1_ENABLE
		`ADDR_UART1    : begin								// receive data UART1
								data_out[31:24] <= rx_data;
								$display("UART1 READ: %c", rx_data);
							  end
`endif
`ifdef UART2_ENABLE
		`ADDR_UART2    : begin								// receive data UART2
								data_out[31:24] <= rx_data2;
								$display("UART2 READ: %c", rx_data2);
						     end
`endif
`ifdef SP3SK_PROM_DATA
		`ADDR_PROM     : begin
								data_out[31:24] <= prom_dataout;		// data from PROM (only valid if prom_dataready)
								data_out[23]	 <= prom_next_sync;	// actual register
								data_out[22]	 <= prom_read;			// register
								data_out[21]	 <= prom_synced;		// prom is synced?
								data_out[20]	 <= prom_dataready;	// data is ready?
						     end
`endif
`ifdef TIMER1_GENERATOR
		`ADDR_TIMER1   : begin
							   data_out[30:0]	 <= timer1_count;
							   data_out[31]    <= timer1_running;
//synthesis translate_off
								if(timer1_running == 0) $display("TIMER1 STOPPED");
								else $display("TIMER1 RUNNING (count=0x%x)", timer1_count);
//synthesis translate_on
							  end
`endif
`ifdef ENABLE_INTERRUPTS
		`ADDR_INT		: data_out <= device_interrupt;
`endif
      default        : $display("Error: Input port not valid: ", addr[`IO_SIZE-1:0]);
    endcase
  end
  // Form read strobe for UART receiver FIFO buffer.
  // The fact that the read strobe will occur after the actual data is read by 
  // the CPU is acceptable because it is really means 'I have read you'!
`ifdef UART1_ENABLE
  read_from_uart  <= read & uart1_selected;	// strobe para dato leido desde uart #1
`endif
`ifdef UART2_ENABLE
  read_from_uart2 <= read & uart2_selected;	// strobe para dato leido desde uart #2
`endif
end

endmodule
