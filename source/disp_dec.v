module disp_dec(disp_dec_in, disp_dec_out);
	input [3:0] disp_dec_in;
	output reg [6:0] disp_dec_out;

	always @(disp_dec_in)
	begin
		case (disp_dec_in)
			4'b0000: disp_dec_out <= 7'b1000000;
			4'b0001: disp_dec_out <= 7'b1111001;
			4'b0010: disp_dec_out <= 7'b0100100;
			4'b0011: disp_dec_out <= 7'b0110000;

			4'b0100: disp_dec_out <= 7'b0011001;
			4'b0101: disp_dec_out <= 7'b0010010;
			4'b0110: disp_dec_out <= 7'b0000010;
			4'b0111: disp_dec_out <= 7'b1111000;

			4'b1000: disp_dec_out <= 7'b0000000;
			4'b1001: disp_dec_out <= 7'b0010000;
			4'b1010: disp_dec_out <= 7'b0001000;
			4'b1011: disp_dec_out <= 7'b0000011;

			4'b1100: disp_dec_out <= 7'b1000110;
			4'b1101: disp_dec_out <= 7'b0100001;
			4'b1110: disp_dec_out <= 7'b0000110;
			4'b1111: disp_dec_out <= 7'b0001110;
		endcase
	end
endmodule
