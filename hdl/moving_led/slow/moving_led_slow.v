// Moving LED module

module moving_led
(
	input				clk,
	input				rst,
	output reg [7:0]	leds
);

reg [32:0] count;

always @(posedge clk)
begin
	if (rst) count <= 0;
	else count <= count + 1;
end

always @(posedge count[26] or posedge rst)
begin
	if (rst)
	begin
		leds <= 8'h0f;
	end
	else
	begin
		leds[7:1] <= leds[6:0];
		leds[0] <= leds[7];
	end
end
	
endmodule
