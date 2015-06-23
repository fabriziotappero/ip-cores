`timescale 1ns / 1ps
`include "const.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ivan Krutov (grvfrv@gmail.com)
// 
// Create Date:    10:39:30 08/29/2012 
// Design Name: 
// Module Name:    EthernetRX 
// Project Name:   Cheap Ethernet
// Target Devices: Spartan 3E
// Tool versions:  ISE 14.1
// Description:    Base functional or ARP, ICMP, UDP
//
// Dependencies:   TENBASET_RxD.v, const.vh
//
// Revision: 
// Revision 0.9 beta
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module EthernetRX(clk50,
	Ethernet_RD,
	HostIP, HostMAC, HostPort,
	RcvStart, RcvStop, RcvData, RcvDataLen, RcvDataPos, RcvDataAvailable, RcvCRCValid, ReceivingPacket,
	RcvPacketType, RcvICMPId, RcvICMPSeq, RcvICMPCRC,
	RcvFromIP, RcvFromMAC, RcvFromPort);

input clk50;
input Ethernet_RD;
input [31:0] HostIP;
input [47:0] HostMAC;
input [15:0] HostPort;

output RcvStart;
output RcvStop;
output [7:0] RcvData;
output [9:0] RcvDataLen;
output [9:0] RcvDataPos;
output RcvDataAvailable;
output [31:0] RcvFromIP;
output [47:0] RcvFromMAC;
output [15:0] RcvFromPort;
output RcvCRCValid;
output ReceivingPacket;
output [2:0] RcvPacketType;
output [15:0] RcvICMPId;
output [15:0] RcvICMPSeq;
output [15:0] RcvICMPCRC;


wire [7:0] RcvData;
wire RcvStop;
wire new_bit_available;
wire new_byte_available;
wire end_of_Ethernet_frame;
wire [9:0] sync2;
reg [31:0] RcvFromIP = 0;
reg [47:0] RcvFromMAC = 0;
reg [15:0] RcvFromPort = 0;
//reg RcvStart = 0;
reg [9:0] RcvDataLen = 0;
reg [9:0] RcvDataPos = 0;
reg RcvDataAvailable = 0;
reg RcvUserData = 0;
reg RcvCRCValid = 0;
reg [2:0] RcvPacketType = 0;
reg [15:0] RcvICMPId = 0;
reg [15:0] RcvICMPSeq = 0;
reg [15:0] RcvICMPCRC = 0;

reg IgnorePacket = 0;
reg [7:0] tmp = 0;
reg CRCinit = 0;
reg [31:0] CRC = 0;
reg [4:0] CRCcnt = 0;
reg CRCflush = 0;
reg MACValid = 0;
reg BroadcastValid = 0;
reg Broadcast = 0;
reg ARP = 0;
reg ICMP = 0;

assign ReceivingPacket = |sync2[9:3]; //~end_of_Ethernet_frame;

TENBASET_RxD TENBASET_RxD1 (clk50, 
	Ethernet_RD,
	RcvData,	RcvStart, RcvStop, new_bit_available, new_byte_available, end_of_Ethernet_frame, sync2);

// generate the CRC32
wire CRCinput = CRCflush ? 0 : RcvData[7] ^ CRC[31];
always @(posedge clk50) begin
	CRCinit <= (!RcvUserData && sync2 == 0);
	if (new_bit_available)
		CRC <= CRCinit ? ~0 : ({CRC[30:0], 1'b0} ^ ({32{CRCinput}} & 32'h04C11DB7));

	if (end_of_Ethernet_frame)
		begin
		CRCcnt <= 0;
		RcvCRCValid <= 0;
		end
		
	if (new_bit_available && CRCflush && (~CRC[31] == RcvData[7]))
		begin
		CRCcnt <= CRCcnt + 1;
		if (&CRCcnt)
			RcvCRCValid <= 1;
		end
end

// Packet disasembling
always @(posedge clk50) begin
	RcvDataAvailable <= 0;
	if (end_of_Ethernet_frame)
		begin
		BroadcastValid <= 1;
		MACValid <= 1;
		ARP <= 0;
		ICMP <= 0;
		Broadcast <= 0;
		CRCflush <= 0;
		RcvUserData <= 0;
		RcvDataPos = 0;
		IgnorePacket <= 0;
		end
	
	if (new_byte_available && !IgnorePacket)
		begin
		if (!RcvUserData)
			case (sync2[9:3])
				01: begin 
					 RcvPacketType <= `Unknown; 
					 if (RcvData != 8'hFF) 
					 	 BroadcastValid <= 0; 
					 if (RcvData != HostMAC[47:40]) 
						 MACValid <= 0; 
					 end
				02: begin 
					 if (RcvData != 8'hFF) 
						 BroadcastValid <= 0; 
					 if (RcvData != HostMAC[39:32]) 
						 MACValid <= 0; end
				03: begin 
					 if (RcvData != 8'hFF) 
						 BroadcastValid <= 0; 
					 if (RcvData != HostMAC[31:24]) 
						 MACValid <= 0; 
					 end
				04: begin 
					 if (RcvData != 8'hFF) 
						 BroadcastValid <= 0; 
					 if (RcvData != HostMAC[23:16]) 
						 MACValid <= 0; 
					 end
				05: begin 
					 if (RcvData != 8'hFF) 
						 BroadcastValid <= 0; 
					 if (RcvData != HostMAC[15:8]) 
						 MACValid <= 0; 
					 end
				06: begin 
					 if (RcvData != 8'hFF) 
						 BroadcastValid <= 0; 
					 if (RcvData != HostMAC[7:0]) 
						 MACValid <= 0; 
					 end
				07: begin 
					 RcvFromMAC[47:40] <= RcvData;
					 if (BroadcastValid) 
						 Broadcast <= 1;
					 else if (!MACValid) 
						 IgnorePacket <= 1; 
					 end
				08: RcvFromMAC[39:32] <= RcvData;
				09: RcvFromMAC[31:24] <= RcvData;
				10: RcvFromMAC[23:16] <= RcvData;
				11: RcvFromMAC[15:8] <= RcvData;
				12: RcvFromMAC[7:0] <= RcvData;

				13: if (RcvData != 8) IgnorePacket <= 1;	// protocol type
				14: if (RcvData == 6) ARP <= 1;
				17: tmp <= RcvData;								// ICMP length
				18: RcvDataLen <= {tmp, RcvData} - 28;		// ICMP length
				21: tmp <= RcvData;
				22: if (ARP) 
						 if (tmp == 8'h00) 
							 begin
							 RcvDataLen <= 18;
							 if (RcvData == 8'h01 && Broadcast) 
								 RcvPacketType <= `ARPReq; 
							 else if (RcvData == 8'h02) 
								 RcvPacketType <= `ARPReply; 
							 end 
				23: if (ARP) RcvFromMAC[47:40] <= RcvData;
				24: if (ARP) 
						 RcvFromMAC[39:32] <= RcvData; 
					 else if (RcvData == 1) 
						 ICMP <= 1; 
					 else if (RcvData == 17) 
						 RcvPacketType <= `UDP;
				25: if (ARP) RcvFromMAC[31:24] <= RcvData;
				26: if (ARP) RcvFromMAC[23:16] <= RcvData;
				27: if (ARP) 
						 RcvFromMAC[15:8] <= RcvData; 
					 else 
						 RcvFromIP[31:24] <= RcvData;
				28: if (ARP) 
						 RcvFromMAC[7:0] <= RcvData; 
					 else 
						 RcvFromIP[23:16] <= RcvData;
				29: if (ARP) 
						 RcvFromIP[31:24] <= RcvData; 
					 else 
						 RcvFromIP[15:8] <= RcvData;
				30: if (ARP) 
						 RcvFromIP[23:16] <= RcvData; 
					 else 
						 RcvFromIP[7:0] <= RcvData;
				31: if (ARP) RcvFromIP[15:8] <= RcvData;
				32: if (ARP) RcvFromIP[7:0] <= RcvData;

				35: if (ICMP) begin
						 if (RcvData == 8) 
							 RcvPacketType <= `ICMPReq; 
						 end
					 else 
						 RcvFromPort[15:8] <= RcvData;
				36: RcvFromPort[7:0] <= RcvData;
				37: if (!ARP) 
						 if (ICMP) 
							 RcvICMPCRC[15:8] <= RcvData; 
						 else if (RcvData != HostPort[15:8]) 
							 IgnorePacket <= 1;
				38: if (!ARP) 
						 if (ICMP) 
							 RcvICMPCRC[7:0] <= RcvData; 
						 else if (RcvData != HostPort[7:0]) 
							 IgnorePacket <= 1;
				39: if (ARP) 
						 begin 
						 if (RcvData != HostIP[31:24]) 
							 IgnorePacket <= 1; 
						 end 
					 else if (ICMP) 
						 RcvICMPId[15:8] <= RcvData; 
					 else 
						 tmp <= RcvData;
				40: if (ARP) begin 
						 if (RcvData != HostIP[23:16]) 
							 IgnorePacket <= 1; 
						 end 
					 else if (ICMP) 
						 RcvICMPId[7:0] <= RcvData; 
					 else 
						 RcvDataLen <= {tmp, RcvData} - 8;
				41: if (ARP) 
						 begin 
						 if (RcvData != HostIP[15:8]) 
							 IgnorePacket <= 1; 
						 end 
					 else if (ICMP) 
						 RcvICMPSeq[15:8] <= RcvData;
				42: if (ARP) begin 
						 if (RcvData != HostIP[7:0]) 
							 IgnorePacket <= 1; 
						 end 
					 else if (ICMP) 
						 RcvICMPSeq[7:0] <= RcvData;
				43: begin 
					 RcvDataAvailable <= 1; 
					 RcvUserData <= 1; 
					 end
			endcase
		else	
			begin 
			RcvDataAvailable <= 1; 
			RcvDataPos = RcvDataPos + 1; 
			if (RcvDataPos + 1 == RcvDataLen)
				CRCflush <= 1;
			end
		end
end

endmodule
