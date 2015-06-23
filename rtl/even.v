
`include "defines.v"

module even(clk, out, N, reset, not_zero, enable);

	input clk;				// fast input clock
	output out;				// slower divided clock
	input [`SIZE-1:0] N;	// divide by factor 'N'
	input reset;			// asynchronous reset
	input not_zero;			// if !not_zero divide by 1
	input enable;			// enable the even divider

	reg [`SIZE-1:0] counter;
	reg out_counter;
	wire [`SIZE-1:0] div_2;


	// if N=0 just output the clock, otherwise, divide it.
	assign out = (clk & !not_zero) | (out_counter & not_zero);
	assign div_2 = {1'b0, N[`SIZE-1:1]};

	// simple flip-flop even divider
	always @(posedge reset or posedge clk)
	begin
		if(reset)						// asynch. reset
		begin
			counter <= 1;
			out_counter <= 1;
		end
		else if(enable)					// only use switching power if enabled
		begin
			if(counter == 1)			// divide after counter has reached bottom
			begin						// of interval 'N' which will be value '1'
				counter <= div_2;
				out_counter <= ~out_counter;
			end
			else
			begin						// decrement the counter and wait
				counter <= counter-1;	// to start next trasition.
			end
		end
	end

endmodule //even
