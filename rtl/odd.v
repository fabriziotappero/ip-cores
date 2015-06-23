
`include "defines.v"

module odd(clk, out, N, reset, enable);

	input clk;					// slow clock
	output out;					// fast output clock
	input [`SIZE-1:0] N;		// division factor
	input reset;				// synchronous reset
	input enable;				// odd enable

	reg [`SIZE-1:0] counter;	// these 2 counters are used
	reg [`SIZE-1:0] counter2;	// to non-overlapping signals
	reg out_counter;			// positive edge triggered counter
	reg out_counter2;			// negative edge triggered counter
	reg rst_pulse;				// pulse generated when vector N changes
	reg [`SIZE-1:0] old_N;		// gets set to old N when N is changed
	wire not_zero;				// if !not_zero, we devide by 1

	assign out = out_counter2 ^ out_counter;	// xor to generate 50% duty, half-period
												// waves of final output
	// positive edge counter/divider
	always @(posedge clk)
	begin
		if(reset | rst_pulse)
		begin
			counter <= N;
			out_counter <= 1;
		end
		else if (enable)
		begin
			if(counter == 1)
			begin
				counter <= N;
				out_counter <= ~out_counter;
			end
			else
			begin
				counter <= counter - 1'b1;
			end
		end
	end

	reg [`SIZE-1:0] initial_begin;		// this is used to offset the negative edge counter
	wire [`SIZE:0] interm_3;			// from the positive edge counter in order to
	assign interm_3 = {1'b0,N} + 2'b11;		// guarante 50% duty cycle.

	// counter driven by negative edge of clock.
	always @(negedge clk)
	begin
		if(reset | rst_pulse)						// reset the counter at system reset
		begin										// or change of N.
			counter2 <= N;
			initial_begin <= interm_3[`SIZE:1];
			out_counter2 <= 1;
		end
		else if(initial_begin <= 1 && enable)		// Do normal logic after odd calibration.
		begin										// This is the same as the even counter.
			if(counter2 == 1)
			begin
				counter2 <= N;
				out_counter2 <= ~out_counter2;
			end
			else
			begin
				counter2 <= counter2 - 1'b1;
			end
		end
		else if(enable)
		begin
			initial_begin <= initial_begin - 1'b1;
		end
	end

	//
	// reset pulse generator:
	//               __    __    __    __    _
	// clk:       __/  \__/  \__/  \__/  \__/
	//            _ __________________________
	// N:         _X__________________________
	//               _____
	// rst_pulse: __/     \___________________
	//
	// This block generates an internal reset for the odd divider in the
	// form of a single pulse signal when the odd divider is enabled.
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			rst_pulse <= 0;
		end
		else if(enable)
		begin
			if(N != old_N)		// pulse when reset changes
			begin
				rst_pulse <= 1;
			end
			else
			begin
				rst_pulse <= 0;
			end
		end
	end

	always @(posedge clk)
	begin
		old_N <= N;	// always save the old N value to guarante reset from
	end				// an even-to-odd transition.

endmodule //odd
