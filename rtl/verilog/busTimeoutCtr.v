/* ===============================================================
	(C) 2005  Robert Finch
	All rights reserved.
	rob@birdcomputer.ca

	busTimeoutCtr.v
		Generates a timeout signal if the bus hasn't responded
	within a preset period.


	This source code is free for use and modification for
	non-commercial or evaluation purposes, provided this
	copyright statement and disclaimer remains present in
	the file.

	If you do modify the code, please state the origin and
	note that you have modified the code.

	NO WARRANTY.
	THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF
	ANY KIND, WHETHER EXPRESS OR IMPLIED. The user must assume
	the entire risk of using the Work.

	IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
	ANY INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES
	WHATSOEVER RELATING TO THE USE OF THIS WORK, OR YOUR
	RELATIONSHIP WITH THE AUTHOR.

	IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU
	TO USE THE WORK IN APPLICATIONS OR SYSTEMS WHERE THE
	WORK'S FAILURE TO PERFORM CAN REASONABLY BE EXPECTED
	TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN LOSS
	OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK,
	AND YOU AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS
	FROM ANY CLAIMS OR LOSSES RELATING TO SUCH UNAUTHORIZED
	USE.


		The default reset state is to request the bus.
		This little circuit asserts the br line to an external
	bus when req pulses high (for a clock cycle or more) and
	removes the br signal if there is no pending req, once a
	bg has been given.
	
	br goes high as soon as req goes high, but then remains
	high even if req is removed.
	br goes low as soon as bg goes high UNLESS there is also
	a req present, in which case it stays high.

	br	= the signal to the external bus that a request is
		  present
	bg	= the signal from the external bus that the bus has
	      been granted
	req	= signal provided by the master to indicate that it
		  needs the bus. The master should monitor the bg
		  signal to know when it has control of the bus.
	rdy = input indicating that the bus transaction is
	      complete
	timeout = flag indicating that the request has timed out.
	      Pulses high for one cycle.

	9LUTs / 8 slices
=============================================================== */

module busTimeoutCtr(
	input rst,		// reset
	input crst,		// critical reset
	input clk,		// system clock
	input ce,		// core clock enable
	input req,		// request bus
	input rdy,		// data ready input
	output timeout	// timeout
);
	parameter pTimeout = 20;		// max 61

	reg [5:0] btc;	// bus timeout counter

	always @(posedge clk)
		if (rst)
			btc <= 0;
		else if (ce) begin
			if (req)
				btc <= pTimeout+2;
			else if (rdy)
				btc <= 0;
			else if (btc > 0)
				btc <= btc - 1;
		end

	assign timeout = btc==6'd1;

endmodule


