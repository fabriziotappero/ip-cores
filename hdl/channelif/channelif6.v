// FCP Channel Interface

module channelif6
(
	// To ethernet platform
	input					in_sof,
	input					in_eof,
	input					in_src_rdy,
	output				in_dst_rdy,
	input		[7:0]		in_data,
	input		[3:0]		inport_addr,
	output				out_sof,
	output				out_eof,
	output				out_src_rdy,
	input					out_dst_rdy,
	output	[7:0]		out_data,
	input		[3:0]		outport_addr,
	// Channel 1 
	input					ch1_in_sof,
	input					ch1_in_eof,
	input					ch1_in_src_rdy,
	output				ch1_in_dst_rdy,
	input		[7:0]		ch1_in_data,
	output				ch1_out_sof,
	output				ch1_out_eof,
	output				ch1_out_src_rdy,
	input					ch1_out_dst_rdy,
	output	[7:0]		ch1_out_data,
	output				ch1_wen,
	output				ch1_ren,
	// Channel 2 
	input					ch2_in_sof,
	input					ch2_in_eof,
	input					ch2_in_src_rdy,
	output				ch2_in_dst_rdy,
	input		[7:0]		ch2_in_data,
	output				ch2_out_sof,
	output				ch2_out_eof,
	output				ch2_out_src_rdy,
	input					ch2_out_dst_rdy,
	output	[7:0]		ch2_out_data,
	output				ch2_wen,
	output				ch2_ren,
	// Channel 3 
	input					ch3_in_sof,
	input					ch3_in_eof,
	input					ch3_in_src_rdy,
	output				ch3_in_dst_rdy,
	input		[7:0]		ch3_in_data,
	output				ch3_out_sof,
	output				ch3_out_eof,
	output				ch3_out_src_rdy,
	input					ch3_out_dst_rdy,
	output	[7:0]		ch3_out_data,
	output				ch3_wen,
	output				ch3_ren,
	// Channel 4 
	input					ch4_in_sof,
	input					ch4_in_eof,
	input					ch4_in_src_rdy,
	output				ch4_in_dst_rdy,
	input		[7:0]		ch4_in_data,
	output				ch4_out_sof,
	output				ch4_out_eof,
	output				ch4_out_src_rdy,
	input					ch4_out_dst_rdy,
	output	[7:0]		ch4_out_data,
	output				ch4_wen,
	output				ch4_ren,
	// Channel 5 
	input					ch5_in_sof,
	input					ch5_in_eof,
	input					ch5_in_src_rdy,
	output				ch5_in_dst_rdy,
	input		[7:0]		ch5_in_data,
	output				ch5_out_sof,
	output				ch5_out_eof,
	output				ch5_out_src_rdy,
	input					ch5_out_dst_rdy,
	output	[7:0]		ch5_out_data,
	output				ch5_wen,
	output				ch5_ren,
	// Channel 6 
	input					ch6_in_sof,
	input					ch6_in_eof,
	input					ch6_in_src_rdy,
	output				ch6_in_dst_rdy,
	input		[7:0]		ch6_in_data,
	output				ch6_out_sof,
	output				ch6_out_eof,
	output				ch6_out_src_rdy,
	input					ch6_out_dst_rdy,
	output	[7:0]		ch6_out_data,
	output				ch6_wen,
	output				ch6_ren,
	
	// To user logic
	output	[15:0]	wenables,
	output	[15:0]	renables
);

//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//                                          Channel-Enable Decoders
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

reg [15:0]		wenables_i;
reg [15:0]		renables_i;

always @(inport_addr)
begin
	case (inport_addr)
		4'h0 : wenables_i = 16'b0000000000000001;
		4'h1 : wenables_i = 16'b0000000000000010;
		4'h2 : wenables_i = 16'b0000000000000100;
		4'h3 : wenables_i = 16'b0000000000001000;
		4'h4 : wenables_i = 16'b0000000000010000;
		4'h5 : wenables_i = 16'b0000000000100000;
		4'h6 : wenables_i = 16'b0000000001000000;
		4'h7 : wenables_i = 16'b0000000010000000;
		4'h8 : wenables_i = 16'b0000000100000000;
		4'h9 : wenables_i = 16'b0000001000000000;
		4'hA : wenables_i = 16'b0000010000000000;
		4'hB : wenables_i = 16'b0000100000000000;
		4'hC : wenables_i = 16'b0001000000000000;
		4'hD : wenables_i = 16'b0010000000000000;
		4'hE : wenables_i = 16'b0100000000000000;
		4'hF : wenables_i = 16'b1000000000000000;
		default: wenables_i = 16'b0000000000000000;
	endcase
end

always @(outport_addr)
begin
	case (outport_addr)
		4'h0 : renables_i = 16'b0000000000000001;
		4'h1 : renables_i = 16'b0000000000000010;
		4'h2 : renables_i = 16'b0000000000000100;
		4'h3 : renables_i = 16'b0000000000001000;
		4'h4 : renables_i = 16'b0000000000010000;
		4'h5 : renables_i = 16'b0000000000100000;
		4'h6 : renables_i = 16'b0000000001000000;
		4'h7 : renables_i = 16'b0000000010000000;
		4'h8 : renables_i = 16'b0000000100000000;
		4'h9 : renables_i = 16'b0000001000000000;
		4'hA : renables_i = 16'b0000010000000000;
		4'hB : renables_i = 16'b0000100000000000;
		4'hC : renables_i = 16'b0001000000000000;
		4'hD : renables_i = 16'b0010000000000000;
		4'hE : renables_i = 16'b0100000000000000;
		4'hF : renables_i = 16'b1000000000000000;
		default: renables_i = 16'b0000000000000000;
	endcase
end

assign wenables = wenables_i;
assign renables = renables_i;


//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//                                          Multiplexers
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------


assign in_dst_rdy = (ch1_wen & ch1_out_dst_rdy) | (ch2_wen & ch2_out_dst_rdy) | (ch3_wen & ch3_out_dst_rdy) | (ch4_wen & ch4_out_dst_rdy) | (ch5_wen & ch5_out_dst_rdy) | (ch6_wen & ch6_out_dst_rdy);
assign out_sof = (ch1_ren & ch1_in_sof) | (ch2_ren & ch2_in_sof) | (ch3_ren & ch3_in_sof) | (ch4_ren & ch4_in_sof) | (ch5_ren & ch5_in_sof) | (ch6_ren & ch6_in_sof);
assign out_eof = (ch1_ren & ch1_in_eof) | (ch2_ren & ch2_in_eof) | (ch3_ren & ch3_in_eof) | (ch4_ren & ch4_in_eof) | (ch5_ren & ch5_in_eof) | (ch6_ren & ch6_in_eof);
assign out_src_rdy = (ch1_ren & ch1_in_src_rdy) | (ch2_ren & ch2_in_src_rdy) | (ch3_ren & ch3_in_src_rdy) | (ch4_ren & ch4_in_src_rdy) | (ch5_ren & ch5_in_src_rdy) | (ch6_ren & ch6_in_src_rdy);
assign out_data = ({8{ch1_ren}} & ch1_in_data) | ({8{ch2_ren}} & ch2_in_data) | ({8{ch3_ren}} & ch3_in_data) | ({8{ch4_ren}} & ch4_in_data) | ({8{ch5_ren}} & ch5_in_data) | ({8{ch6_ren}} & ch6_in_data);

//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//                                          Passthroughs
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

assign ch1_in_dst_rdy = out_dst_rdy & ch1_ren;
assign ch1_out_src_rdy = in_src_rdy & ch1_wen;
assign ch1_out_sof = in_sof;
assign ch1_out_eof = in_eof;
assign ch1_out_data = in_data;
assign ch1_wen = wenables_i[1];
assign ch1_ren = renables_i[1];

assign ch2_in_dst_rdy = out_dst_rdy & ch2_ren;
assign ch2_out_src_rdy = in_src_rdy & ch2_wen;
assign ch2_out_sof = in_sof;
assign ch2_out_eof = in_eof;
assign ch2_out_data = in_data;
assign ch2_wen = wenables_i[2];
assign ch2_ren = renables_i[2];

assign ch3_in_dst_rdy = out_dst_rdy & ch3_ren;
assign ch3_out_src_rdy = in_src_rdy & ch3_wen;
assign ch3_out_sof = in_sof;
assign ch3_out_eof = in_eof;
assign ch3_out_data = in_data;
assign ch3_wen = wenables_i[3];
assign ch3_ren = renables_i[3];

assign ch4_in_dst_rdy = out_dst_rdy & ch4_ren;
assign ch4_out_src_rdy = in_src_rdy & ch4_wen;
assign ch4_out_sof = in_sof;
assign ch4_out_eof = in_eof;
assign ch4_out_data = in_data;
assign ch4_wen = wenables_i[4];
assign ch4_ren = renables_i[4];

assign ch5_in_dst_rdy = out_dst_rdy & ch5_ren;
assign ch5_out_src_rdy = in_src_rdy & ch5_wen;
assign ch5_out_sof = in_sof;
assign ch5_out_eof = in_eof;
assign ch5_out_data = in_data;
assign ch5_wen = wenables_i[5];
assign ch5_ren = renables_i[5];

assign ch6_in_dst_rdy = out_dst_rdy & ch6_ren;
assign ch6_out_src_rdy = in_src_rdy & ch6_wen;
assign ch6_out_sof = in_sof;
assign ch6_out_eof = in_eof;
assign ch6_out_data = in_data;
assign ch6_wen = wenables_i[6];
assign ch6_ren = renables_i[6];

endmodule
