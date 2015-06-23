//	MODULE  : PROM_reader_serial.v
//	AUTHOR  : Stephan Neuhold
//	VERSION : v1.00
//
//	FUNCTION DESCRIPTION:
//	---------------------
//	This module provides the control state machine
//	for reading data from the PROM. This includes
//	searching for synchronisation patterns, retrieving
//	data, resetting the PROMs address counter.

// Signal format and FSM modified to be adapted OpenFIRE SOC

`timescale 1 ns / 1 ns
`include "openfire_define.v"

module PROM_reader_serial(	clock,			// cpu clock
									reset,			// reset signal (syncronous)
									read,				// request a byte from PROM (once synced)
									next_sync,		// seek next file in PROM
									din,				// din/d0 from PROM
									sync_pattern,	// sync pattern that determines start of file
									cclk,				// PROM clock
									sync,				// notify we are in sync (at a file)
									data_ready,		// notify dout data is ready
									reset_prom_n,	// PROM reset
									dout);			// PROM data

parameter									length = 5;
parameter									frequency = 50;
							
input											clock;
input											reset;
input											read;
input											next_sync;
input											din;
input				[(2**length) - 1:0]	sync_pattern;
output										cclk;
output										sync;
output	reg								data_ready;
output	reg								reset_prom_n;
output	reg	[7:0]						dout;
	
reg				[3:0]						current_state;
reg				[length:0]				count;
reg											sync_int;
reg											cclk_on;
wire				[7:0]						data;

parameter		[3:0]						Look4Sync   = 4'b0001,
												Wait4Active = 4'b0010,
												GetData     = 4'b0100,
												PresentData = 4'b1000;	

assign sync = sync_int;

//Clock generation and clock enable generation
clock_management	#(length, frequency)	Clock_Manager(
	.clock(clock),
	.enable(cclk_on),
	.read_enable(din_read_enable),
	.cclk(cclk)
	);
	
//Shift and compare operation	
shift_compare_serial	#(length, frequency)	Shift_And_Compare(
	.clock(clock),
	.reset(reset),
	.enable(din_read_enable),
	.din(din),
	.b(sync_pattern),
	.eq(sync_found),
	.din_shifted(data)
	);

//State machine
always @ (posedge clock)
begin
	if (reset)					// syncronous reset
	begin
		current_state <= Look4Sync;	// we are looking for the sync pattern
		dout 			  <= 0;
		count 		  <= 0;
		sync_int 	  <= 1'b0;
		data_ready 	  <= 1'b0;
		reset_prom_n  <= 1'b0;			// reset the prom
		cclk_on 		  <= 1'b1;			// activate cclk
	end
	else
	begin
		case (current_state)		
			//*************************************************************
			//*	This state clocks in one bit of data at a time from the
			//*	PROM. With every new bit clocked in a comparison is done
			//*	to check whether it matches the synchronisation pattern.
			//*	If the pattern is found then a further bits are read
			//*	from the PROM to provide the first byte of data appearing
			//*	after the synchronisation pattern.
			//*************************************************************
			Look4Sync:
			begin
				count 		<= 0;
				data_ready  <= 1'b0;
				sync_int 	<= sync_found;
				reset_prom_n<= 1'b1;				// end of prom reset
				if (sync_found)
				begin
					if(~next_sync) current_state <= Wait4Active;		// wait until next_sync
					cclk_on 	 	  <= 1'b0;		// when synced, stop prom clock
				end
			end		
			//*********************************************************
			//*	At this point the state machine waits for user input.
			//*	If the user pulses the "read" signal then 8 bits of
			//*	are retrieved from the PROM. If the user wants to
			//*	look for another synchronisation pattern and pulses
			//*	the "next_sync" signal, then the state machine goes
			//*	into the "Look4Sync" state.
			//*********************************************************
			Wait4Active:
			begin
				count 	  <= 0;
				data_ready <= 1'b0;
				if (read)					// request a byte from prom
				begin
					current_state <= GetData;
					cclk_on 		  <= 1'b1;
				end
				if (next_sync)				// request seek next file
				begin
					current_state <= Look4Sync;
					cclk_on 		  <= 1'b1;
				end
			end		
			//*********************************************************
			//*	This state gets the data from the PROM. If the
			//*	synchronisation pattern has just been found then
			//*	enough data is retrieved to present the first
			//*	8 bits after the pattern. This is dependant on the
			//*	synchronisation pattern length.
			//*	If the synchronisation pattern has already been found
			//*	previously then only the next 8 bits of data are
			//*	retrieved.
			//*********************************************************
			GetData:
			begin
				if (din_read_enable)		// if we can read a bit from prom...
				begin
					count <= count + 1;
					if (sync_int)
					begin
						if (count == (2**length - 1))
						begin
							current_state <= PresentData;
							sync_int 	  <= 1'b0;
							cclk_on 		  <= 1'b0;
						end
					end
					else
					begin
						if (count == 7)
						begin
							current_state <= PresentData;
							sync_int 	  <= 1'b0;
							cclk_on 	     <= 1'b0;
						end
					end
				end
			end		
			//*******************************************************
			//*	This state tells the user that 8 bits of data have
			//*	been retrieved and is presented on the "dout" port.
			//*	The "Wait4Active" state is then entered to wait for
			//*	another user request.
			//*******************************************************
			PresentData:
			begin
				dout 			  <= data;
				data_ready 	  <= 1'b1;
				if(~read) current_state <= Wait4Active;	// wait until cpu releases read bit
			end
				
			default:
			begin
			end
		
		endcase
	end
end

endmodule