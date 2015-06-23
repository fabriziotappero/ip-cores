// Moving LED module

module counting_led
(
	input				clk,
	input				rst,
	output  [7:0]	leds
);

reg [7:0] count;

always @(posedge clk)
begin
	if (rst) count <= 0;
	else count <= count + 1;
end

assign leds = count;
	
endmodule
