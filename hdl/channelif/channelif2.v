// FCP Channel Interface

module channelif2
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


assign in_dst_rdy = (ch1_wen & ch1_out_dst_rdy) | (ch2_wen & ch2_out_dst_rdy);
assign out_sof = (ch1_ren & ch1_in_sof) | (ch2_ren & ch2_in_sof);
assign out_eof = (ch1_ren & ch1_in_eof) | (ch2_ren & ch2_in_eof);
assign out_src_rdy = (ch1_ren & ch1_in_src_rdy) | (ch2_ren & ch2_in_src_rdy);
assign out_data = ({8{ch1_ren}} & ch1_in_data) | ({8{ch2_ren}} & ch2_in_data);

//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//                                          Passthroughs
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

assign ch1_in_dst_rdy = out_dst_rdy;
assign ch1_out_src_rdy = in_src_rdy;
assign ch1_out_sof = in_sof;
assign ch1_out_eof = in_eof;
assign ch1_out_data = in_data;
assign ch1_wen = wenables_i[1];
assign ch1_ren = renables_i[1];

assign ch2_in_dst_rdy = out_dst_rdy;
assign ch2_out_src_rdy = in_src_rdy;
assign ch2_out_sof = in_sof;
assign ch2_out_eof = in_eof;
assign ch2_out_data = in_data;
assign ch2_wen = wenables_i[2];
assign ch2_ren = renables_i[2];

endmodule
