`timescale 1ns / 1ps
`include "const.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ivan Krutov (grvfrv@gmail.com)
// 
// Create Date:    22:59:14 08/28/2012 
// Design Name: 
// Module Name:    EthernetTX 
// Project Name:   Cheap Ethernet
// Target Devices: Spartan 3E
// Tool versions:  ISE 14.1
// Description:    Base functional or ARP, ICMP, UDP
//
// Dependencies:   TENBASET_TxD.v, const.vh
//
// Revision: 
// Revision 0.9 beta
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module EthernetTX(clk20,
	HostIP, RemoteIP, HostMAC, RemoteMAC, HostPort, RemotePort,
	SendStart, SendDataReq, SendData, SendDataLen, SendDataPos, SendingPacket, 
	SendPacketType, SendICMPId, SendICMPSeq, SendICMPCRC,
	Ethernet_TDp, Ethernet_TDm);

input clk20;
input [31:0] HostIP;
input [31:0] RemoteIP;
input [47:0] HostMAC;
input [47:0] RemoteMAC;
input [15:0] HostPort;
input [15:0] RemotePort;
input SendStart;
input [7:0] SendData;
input [9:0] SendDataLen;
output [9:0] SendDataPos;
output SendingPacket;
output SendDataReq;
input [2:0] SendPacketType;
input [15:0] SendICMPId;
input [15:0] SendICMPSeq;
input [15:0] SendICMPCRC;
output Ethernet_TDp, Ethernet_TDm;

reg [7:0] pkt_data = 0;

reg SendingPacket = 0;
wire [10:0] rdaddress;
wire [7:0] ShiftData;
wire [3:0] ShiftCount;
wire readram;

wire [9:0] SendDataPos = (rdaddress > 12'h32) ? (rdaddress - 12'h32) : 0;
wire [15:0] IPHLen = 8'd20 + 8'd8 + SendDataLen;
wire [15:0] UDPHLen = 8'd8 + SendDataLen;

reg [31:0] CRC = 0;
reg CRCflush = 0; 
reg CRCinit = 0; 

assign SendDataReq = (rdaddress > 8'h30) && readram;

// calculate the IP checksum, big-endian style
wire [18:0] IPchecksum1 = (SendPacketType == `ICMPReply ? 19'hC51D : 19'hC52D) + SendDataLen + 
								  HostIP[31:16] + HostIP[15:0] + RemoteIP[31:16] + RemoteIP[15:0];
wire [15:0] IPchecksum2 = ~((IPchecksum1[15:0] + IPchecksum1[18:16]));


TENBASET_TxD TENBASET_TxD1 (clk20, 
	SendingPacket, pkt_data, rdaddress, ShiftData, ShiftCount, CRCflush, ~CRC[31], readram,
	Ethernet_TDp, Ethernet_TDm);


always @(posedge clk20) begin
	if (SendStart) 
		SendingPacket <= 1; 
	else if (ShiftCount == 14 && rdaddress == (54 + SendDataLen)) 
		SendingPacket <= 0;
end

// generate the CRC32
wire CRCinput = CRCflush ? 0 : (ShiftData[0] ^ CRC[31]);
always @(posedge clk20) begin
	if (CRCflush) 
		CRCflush <= SendingPacket; 
	else if (readram) 
		CRCflush <= (rdaddress == (50 + SendDataLen));
	if (readram) 
		CRCinit <= (rdaddress == 7);
	if (ShiftCount[0]) 
		CRC <= CRCinit ? ~0 : ({CRC[30:0],1'b0} ^ ({32{CRCinput}} & 32'h04C11DB7));
end

wire ARP = (SendPacketType == `ARPReply || SendPacketType == `ARPReq);

always @(posedge clk20)
case (rdaddress)
// Ethernet preamble
  12'h00: pkt_data <= 8'h55;
  12'h01: pkt_data <= 8'h55;
  12'h02: pkt_data <= 8'h55;
  12'h03: pkt_data <= 8'h55;
  12'h04: pkt_data <= 8'h55;
  12'h05: pkt_data <= 8'h55;
  12'h06: pkt_data <= 8'h55;
  12'h07: pkt_data <= 8'hD5;
// Ethernet header
  12'h08: pkt_data <= SendPacketType == `ARPReq ? 8'hFF : RemoteMAC[47:40];
  12'h09: pkt_data <= SendPacketType == `ARPReq ? 8'hFF : RemoteMAC[39:32];
  12'h0A: pkt_data <= SendPacketType == `ARPReq ? 8'hFF : RemoteMAC[31:24];
  12'h0B: pkt_data <= SendPacketType == `ARPReq ? 8'hFF : RemoteMAC[23:16];
  12'h0C: pkt_data <= SendPacketType == `ARPReq ? 8'hFF : RemoteMAC[15:8];
  12'h0D: pkt_data <= SendPacketType == `ARPReq ? 8'hFF : RemoteMAC[7:0];
  12'h0E: pkt_data <= HostMAC[47:40];
  12'h0F: pkt_data <= HostMAC[39:32];
  12'h10: pkt_data <= HostMAC[31:24];
  12'h11: pkt_data <= HostMAC[23:16];
  12'h12: pkt_data <= HostMAC[15:8];
  12'h13: pkt_data <= HostMAC[7:0];
// IP header / ARP / ICMP
  12'h14: pkt_data <= 8'h08;
  12'h15: pkt_data <= ARP ? 8'h06 : 8'h00;
  12'h16: pkt_data <= ARP ? 8'h00 : 8'h45;
  12'h17: pkt_data <= ARP ? 8'h01 : 8'h00;
  12'h18: pkt_data <= ARP ? 8'h08 : IPHLen[15:8];
  12'h19: pkt_data <= ARP ? 8'h00 : IPHLen[7:0];
  12'h1A: pkt_data <= ARP ? 8'h06 : 8'h00;
  12'h1B: pkt_data <= ARP ? 8'h04 : 8'h00;
  12'h1C: pkt_data <= 8'h00;
  12'h1D: pkt_data <= SendPacketType == `ARPReply ? 8'h02 : SendPacketType == `ARPReq ? 8'h01 : 8'h00;
  12'h1E: pkt_data <= ARP ? HostMAC[47:40] : 8'h80;
  12'h1F: pkt_data <= ARP ? HostMAC[39:32] : SendPacketType == `ICMPReply ? 8'h01 : 8'h11;
  12'h20: pkt_data <= ARP ? HostMAC[31:24] : IPchecksum2[15:8];
  12'h21: pkt_data <= ARP ? HostMAC[23:16] : IPchecksum2[ 7:0];
  12'h22: pkt_data <= ARP ? HostMAC[15:8] : HostIP[31:24];
  12'h23: pkt_data <= ARP ? HostMAC[7:0] : HostIP[23:16];
  12'h24: pkt_data <= ARP ? HostIP[31:24] : HostIP[15:8];
  12'h25: pkt_data <= ARP ? HostIP[23:16] : HostIP[7:0];
  12'h26: pkt_data <= ARP ? HostIP[15:8] : RemoteIP[31:24];
  12'h27: pkt_data <= ARP ? HostIP[7:0] : RemoteIP[23:16];
  12'h28: pkt_data <= SendPacketType == `ARPReply ? RemoteMAC[47:40] : SendPacketType == `ARPReq ? 8'h00 : RemoteIP[15:8];
  12'h29: pkt_data <= SendPacketType == `ARPReply ? RemoteMAC[39:32] : SendPacketType == `ARPReq ? 8'h00 : RemoteIP[7:0];
// UDP header / ARP / ICMP
  12'h2A: pkt_data <= SendPacketType == `ARPReply ? RemoteMAC[31:24] : SendPacketType == `ICMPReply ? 8'h00 : SendPacketType == `ARPReq ? 8'h00 : HostPort[15:8];
  12'h2B: pkt_data <= SendPacketType == `ARPReply ? RemoteMAC[23:16] : HostPort[7:0];
  12'h2C: pkt_data <= SendPacketType == `ARPReply ? RemoteMAC[15:8] : SendPacketType == `ICMPReply ? SendICMPCRC[15:8] : SendPacketType == `ARPReq ? 8'h00 : RemotePort[15:8];
  12'h2D: pkt_data <= SendPacketType == `ARPReply ? RemoteMAC[7:0] : SendPacketType == `ICMPReply ? SendICMPCRC[7:0] : RemotePort[7:0];
  12'h2E: pkt_data <= ARP ? RemoteIP[31:24] : SendPacketType == `ICMPReply ? SendICMPId[15:8] : UDPHLen[15:8];
  12'h2F: pkt_data <= ARP ? RemoteIP[23:16] : SendPacketType == `ICMPReply ? SendICMPId[7:0] : UDPHLen[7:0];
  12'h30: pkt_data <= ARP ? RemoteIP[15:8] : SendPacketType == `ICMPReply ? SendICMPSeq[15:8] : 8'h00;
  12'h31: pkt_data <= ARP ? RemoteIP[7:0] : SendPacketType == `ICMPReply ? SendICMPSeq[7:0] : 8'h00;
  default: pkt_data <= ARP ? 8'h00 : SendData;
endcase

endmodule
