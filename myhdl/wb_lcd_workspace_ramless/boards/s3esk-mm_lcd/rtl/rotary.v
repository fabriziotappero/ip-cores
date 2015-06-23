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
	output reg   rot_btn,
	output reg   rot_event,
	output reg   rot_left
);

//----------------------------------------------------------------------------
// decode rotary encoder
//----------------------------------------------------------------------------
reg [1:0] rot_q;

always @(posedge clk)
begin
	case (rot[1:0])
		2'b00: rot_q <= { rot_q[1], 1'b0 };
		2'b01: rot_q <= { 1'b0, rot_q[0] };
		2'b10: rot_q <= { 1'b1, rot_q[0] };
		2'b11: rot_q <= { rot_q[1], 1'b1 };
	endcase
end

reg [1:0] rot_q_delayed;

always @(posedge clk)
begin
	rot_q_delayed <= rot_q;

	if (rot_q[0] && ~rot_q_delayed[0]) begin
		rot_event <= 1;
		rot_left  <= rot_q[1];
	end else
		rot_event <= 0;
end

//----------------------------------------------------------------------------
// debounce push button (rot[2])
//----------------------------------------------------------------------------
reg [2:0]  rot_d;
reg [15:0] dead_count;

always @(posedge clk)
begin
	if (reset) begin
		rot_btn    <= 0;
		dead_count <= 0;
	end else begin
		rot_btn <= 1'b0;
		rot_d   <= { rot_d[1:0], rot[2] };

		if (dead_count == 0) begin
			if ( rot_d[2:1] == 2'b01 ) begin
				rot_btn    <= 1'b1;
				dead_count <= dead_count - 1;
			end
		end else
			dead_count <= dead_count - 1;
	end
end

endmodule