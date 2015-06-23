// Compare logic

module comparelogic
(
	input		[15:0]		data,
	input		[1:0]			mode,
	output	reg			result
);

always @(data or mode)
begin
	case (mode)
		0: result = ~( | data ); // ==
		1: result = ~( data[15] && ( | data )); // >
		2: result = ( data[15] && ( | data )); // <
		3: result = ( | data ); // !=
		default: $display("Error in CompareLogic Case");
	endcase
end

endmodule
