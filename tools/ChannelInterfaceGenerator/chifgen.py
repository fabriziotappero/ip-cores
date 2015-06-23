# Channel Interface Generator

import sys

if (len(sys.argv) < 2):
	print 'Usage: chifgen <#channels>'
	exit()
	
numChannels = int(sys.argv[1])

if (numChannels < 1):
	print 'Must have one or more channels'
	exit()
	
f = open('channelif.v', 'w')

f.write('''// FCP Channel Interface

module channelif
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
	''')
	
for channel in range(1,numChannels+1):
	f.write('''// Channel {0:d} 
	input					ch{0:d}_in_sof,
	input					ch{0:d}_in_eof,
	input					ch{0:d}_in_src_rdy,
	output				ch{0:d}_in_dst_rdy,
	input		[7:0]		ch{0:d}_in_data,
	output				ch{0:d}_out_sof,
	output				ch{0:d}_out_eof,
	output				ch{0:d}_out_src_rdy,
	input					ch{0:d}_out_dst_rdy,
	output	[7:0]		ch{0:d}_out_data,
	output				ch{0:d}_wen,
	output				ch{0:d}_ren,
	'''.format(channel))
	
f.write('''
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


assign in_dst_rdy = (ch1_wen & ch1_out_dst_rdy)''')
for channel in range(2, numChannels+1): f.write(' | (ch{0:d}_wen & ch{0:d}_out_dst_rdy)'.format(channel))
f.write(''';
assign out_sof = (ch1_ren & ch1_in_sof)''')
for channel in range(2, numChannels+1): f.write(' | (ch{0:d}_ren & ch{0:d}_in_sof)'.format(channel))
f.write(''';
assign out_eof = (ch1_ren & ch1_in_eof)''')
for channel in range(2, numChannels+1): f.write(' | (ch{0:d}_ren & ch{0:d}_in_eof)'.format(channel))
f.write(''';
assign out_src_rdy = (ch1_ren & ch1_in_src_rdy)''')
for channel in range(2, numChannels+1): f.write(' | (ch{0:d}_ren & ch{0:d}_in_src_rdy)'.format(channel))
f.write(''';
assign out_data = ({8{ch1_ren}} & ch1_in_data)''')
for channel in range(2, numChannels+1): f.write(' | ({{8{{ch{0:d}_ren}}}} & ch{0:d}_in_data)'.format(channel))
f.write(''';

//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//                                          Passthroughs
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
''')
for channel in range(1, numChannels+1): f.write('''
assign ch{0:d}_in_dst_rdy = out_dst_rdy & ch{0:d}_ren;
assign ch{0:d}_out_src_rdy = in_src_rdy & ch{0:d}_wen;
assign ch{0:d}_out_sof = in_sof;
assign ch{0:d}_out_eof = in_eof;
assign ch{0:d}_out_data = in_data;
assign ch{0:d}_wen = wenables_i[{0:d}];
assign ch{0:d}_ren = renables_i[{0:d}];
'''.format(channel))
f.write('''
endmodule
''')
