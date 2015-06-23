// 32 bit Port Register

`timescale 1ns/100ps

module port_register(
	input					clk,
	input					rst,
	input					wen,
	input					ren,
	input					in_sof,
	input					in_eof,
	input					in_src_rdy,
	output				in_dst_rdy,
	input		[7:0]		in_data,
	
	output	reg		out_sof,
	output	reg		out_eof,
	input					out_dst_rdy,
	output				out_src_rdy,
	output	reg [7:0]		out_data
);


reg reg_enable;
reg shift_en;
reg [1:0] rstate;
reg [1:0] nextrstate;
reg [23:0] shift_reg;
reg [31:0] word_reg;
reg [1:0] wstate;
reg [1:0] nextwstate;

assign in_dst_rdy = 1;
assign out_src_rdy = 1;

always@(wstate, wen, in_sof, in_src_rdy)
begin
	reg_enable = 0;
	shift_en = 0;
	nextwstate = wstate;
	case (wstate)
		0: // waiting byte 0
		begin
			if (wen & in_sof & in_src_rdy)
			begin
				shift_en = 1;
				nextwstate = 1;
			end
		end
		1: // waiting byte 1 
		begin
			if (wen & in_src_rdy)
			begin
				shift_en = 1;
				nextwstate = 2;
			end
		end
		2: // waiting byte 2
		begin
			if (wen & in_src_rdy)
			begin
				shift_en = 1;
				nextwstate = 3;
			end
		end
		3: // waiting byte 3
		begin
			if (wen & in_src_rdy)
			begin
				reg_enable = 1;
				nextwstate = 0;
			end
		end
	endcase
end

always@(posedge clk or posedge rst)
begin
	if (rst)
		wstate <= 0;
	else
		wstate <= nextwstate;
end

// shift register and word register
always@(posedge clk or posedge rst)
begin
	if (rst)
	begin
		shift_reg <= 0;
		word_reg <= 0;
	end
	else
	begin
		if (shift_en)
		begin
			shift_reg <= {in_data, shift_reg[23:8]};
		end
		if (reg_enable)
		begin
			word_reg <= {in_data, shift_reg};
		end
	end
end

always@(rstate or ren or out_dst_rdy)
begin
	out_data = 0;
	out_eof = 0;
	out_sof = 0;
	nextrstate = rstate;
	case (rstate)
		0: // waiting for read
		begin
			out_data = word_reg[7:0];
			out_sof = 1;
			if (ren & out_dst_rdy)
			begin
				nextrstate = 1;
			end
		end
		1: // waiting for read 2
		begin
			out_data = word_reg[15:8];
			if (ren & out_dst_rdy)
			begin
				nextrstate = 2;
			end
		end
		2: // waiting for read 3
		begin
			out_data = word_reg[23:16];
			if (ren & out_dst_rdy)
			begin
				nextrstate = 3;
			end
		end
		3: // waiting for read 4
		begin
			out_data = word_reg[31:24];
			out_eof = 1;
			if (ren & out_dst_rdy)
			begin
				nextrstate = 0;
			end
		end
	endcase
end

always@(posedge clk or posedge rst)
begin
	if (rst)
		rstate <= 0;
	else
		rstate <= nextrstate;
end

endmodule
