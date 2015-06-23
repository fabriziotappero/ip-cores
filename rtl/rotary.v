//----------------------------------------------------------------------------
// Decode rotary encoder to clk-syncronous signals
//
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------

module rotary (
	input        clk,
	input        reset,
	input [2:0]  rot,
	//
	output       rot_btn,
	output reg   rot_event,
	output reg   rot_left
);

assign rot_btn = 0;


//----------------------------------------------------------------------------
// decode rotary encoder
//----------------------------------------------------------------------------
parameter  counter_init = 10000000;
reg [31:0] counter;

reg rot_event2;
reg rot_left2;

always @(posedge clk)
begin
	if (reset)
		counter <= counter_init;
	else begin
		rot_event  <= rot_event2;
		rot_left   <= rot_left2;

		rot_event2 <= 0;
		rot_left2  <= 0;

		if (counter == 0) begin
			counter <= counter_init;

			if (rot[0] | rot[1])
				rot_event2 <= 1;

			if (rot[0])
				rot_left2  <= 1;
		end else
			counter <= counter - 1;
	end
end


endmodule
