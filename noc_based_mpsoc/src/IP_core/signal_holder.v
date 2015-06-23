


`include "../define.v"

module	signal_holder # (
	parameter DELAY_COUNT = 1000,
	parameter COUNTER_WIDTH = log2(DELAY_COUNT)
)
(
	input reset_in,
	input clk,
	output reg reset_out
);

`LOG2

reg	[COUNTER_WIDTH-1	:0]	counter;

always@(posedge clk or posedge reset_in)
begin
	if(reset_in)begin
		reset_out	<=	1'b1;
		counter 		<={COUNTER_WIDTH{1'b0}};
	end else begin
		if(counter == DELAY_COUNT) begin
			reset_out	<=	1'b0;
		end else begin 
			reset_out	<=	1'b1;
			counter 		<= counter +1'b1;
		end
	end
end

endmodule
