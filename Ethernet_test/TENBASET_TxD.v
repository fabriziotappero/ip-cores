`timescale 1ns / 1ps
// 10BASE-T transmit interface (based on fpga4fun.com version)
module TENBASET_TxD(clk20, 
	SendingPacket, pkt_data, rdaddress, ShiftData, ShiftCount, CRCflush, CRC, readram,
	Ethernet_TDp, Ethernet_TDm);

input clk20;	// a 20MHz clock (this code won't work with a different frequency)
input [7:0] pkt_data;
output [10:0] rdaddress;
input SendingPacket;
output ShiftData;
output [3:0] ShiftCount;
input CRCflush;
input CRC;
output readram;
output Ethernet_TDp, Ethernet_TDm;	// the two differential 10BASE-T outputs


reg [10:0] rdaddress = 0;
reg [3:0] ShiftCount = 0;
wire readram = (ShiftCount == 15);
reg [7:0] ShiftData = 0;
reg [17:0] LinkPulseCount = 0; 
reg LinkPulse = 0; 
reg SendingPacketData = 0; 
reg [2:0] idlecount = 0; 
reg qo = 0; 
reg qoe = 0; 
reg Ethernet_TDp = 0; 
reg Ethernet_TDm = 0; 


//////////////////////////////////////////////////////////////////////
// 10BASE-T's magic

always @(posedge clk20) begin
	ShiftCount <= SendingPacket ? ShiftCount + 1 : 15;
	if (ShiftCount == 15) 
		rdaddress <= SendingPacket ? rdaddress + 1 : 0;
	if (ShiftCount[0]) 
		ShiftData <= readram ? pkt_data : {1'b0, ShiftData[7:1]};
end

// generate the NLP
always @(posedge clk20) begin
	LinkPulseCount <= SendingPacket ? 0 : LinkPulseCount + 1;
	LinkPulse <= &LinkPulseCount[17:1];
end

wire dataout = CRCflush ? CRC : ShiftData[0];

// TP_IDL, shift-register and manchester encoder
always @(posedge clk20) begin
	SendingPacketData <= SendingPacket;
	if (SendingPacketData) 
		idlecount <= 0; 
	else if (~&idlecount) 
		idlecount <= idlecount + 1;
	qo <= SendingPacketData ? ~dataout ^ ShiftCount[0] : 1;
	qoe <= SendingPacketData | LinkPulse | (idlecount < 6);
	Ethernet_TDp <= (qoe ? qo : 1'b0);
	Ethernet_TDm <= (qoe ? ~qo : 1'b0);
end

endmodule
