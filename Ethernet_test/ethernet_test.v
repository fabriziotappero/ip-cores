`timescale 1ns / 1ps
`include "const.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ivan Krutov (grvfrv@gmail.com)
// 
// Create Date:    10:36:10 08/28/2012 
// Design Name:    Cheap Ethernet test project
// Module Name:    ethernet_test
// Project Name:   Cheap Ethernet
// Target Devices: Spartan 3E
// Tool versions:  ISE 14.1
// Description:    Base functional of ARP, ICMP, UDP server, UDP client.
//
// Dependencies:   EthernetRX.v, EthernetTX.v, TENBASET_RxD.v, TENBASET_TxD.v,
//	                const.vh
// Revision: 
// Revision 0.9 beta
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module ethernet_test(clk_in, 
	Ethernet_RDp, Ethernet_RDm, Ethernet_TDp, Ethernet_TDm, Ethernet_LED_Link, Ethernet_LED_Act,
	PushButton, LED_Test);

input clk_in;								// 50 MHz
input Ethernet_RDp, Ethernet_RDm;	// Ethernel input
output Ethernet_TDp, Ethernet_TDm;	// Ethernel output
output Ethernet_LED_Link;				// Ethernet link - Not realized! (VCC)
output Ethernet_LED_Act;				// Etheret activity (low - active)
input PushButton;							// Pushbutton for send data test
output LED_Test;

// Server config
wire [31:0] HostIP     	= 32'hC0A8012C;	// 192.168.1.44
wire [47:0] HostMAC    	= 48'h001234567890;
wire [15:0] HostPort   	= 16'd1024;

// Client config
wire [31:0] RemoteIP		= 32'hC0A80102;	// 192.168.1.2
reg [47:0] RemoteMAC		= 48'h0;
wire [15:0] RemotePort	= 16'd1024;

wire clk20, clk50;
wire Ethernet_RD;

reg SendStart = 0;
wire SendDataReq;
reg [7:0] SendData = 0;
reg [9:0] SendDataLen = 0;
wire [9:0] SendDataPos;
wire SendingPacket;
reg [2:0] SendPacketType = 0;

reg [31:0] SendToIP   = 32'h0;
reg [47:0] SendToMAC  = 48'h0;
reg [15:0] SendToPort = 16'h0;

wire RcvStart, RcvStop;
wire [7:0] RcvData;
wire [9:0] RcvDataLen;
wire [9:0] RcvDataPos;
wire RcvDataAvailable;
wire RcvCRCValid;
wire ReceivingPacket;
wire [2:0] RcvPacketType;
wire [31:0] RcvFromIP;
wire [47:0] RcvFromMAC;
wire [15:0] RcvFromPort;
wire [15:0] RcvICMPId;
wire [15:0] RcvICMPSeq;
wire [15:0] RcvICMPCRC;

wire Ethernet_LED_Link = 1;
reg Ethernet_LED_Act = 0;
reg LED_Test = 0;
reg last_btn_st = 0;

reg PacketReceived = 0;
reg PacketProcessed = 0;
reg [7:0] Cmd = 0;
reg [7:0] Arg = 0;
reg SendReq = 0;

reg [2:0] SavedPacketType = 0;
reg [9:0] SavedDataLen = 0;
reg [15:0] SavedPort = 0;
reg SavedEcho = 0;
reg Echo = 0;

wire [16:0] SendICMPCRC1 = {RcvICMPCRC[15:8] + 9'h08, RcvICMPCRC[7:0]};
wire [15:0] SendICMPCRC2 = SendICMPCRC1[15:0] + SendICMPCRC1[16];

wire [7:0] FIFOOut;
wire FIFOFull;
wire FIFOEmpty;


DCMMAIN DCMMAIN1 (
    .CLKIN_IN(clk_in),	// 50 MHz
    .RST_IN(1'b0),
    .CLKDV_OUT(), 
    .CLKFX_OUT(clk20), 
    .CLKIN_IBUFG_OUT(), 
    .CLK0_OUT(clk50),
	 .LOCKED_OUT());

   IBUFDS #(
      .IBUF_DELAY_VALUE("0"),    // Specify the amount of added input delay for
                                 //    the buffer: "0"-"12" (Spartan-3E)
      .IFD_DELAY_VALUE("0"),  // Specify the amount of added delay for input
                                 //    register: "AUTO", "0"-"6" (Spartan-3E)
      .IOSTANDARD("DIFF_HSTL_III_18")     // Specify the input I/O standard
   ) IBUFDS_EthRD (
      .O(Ethernet_RD),  // Buffer output
      .I(Ethernet_RDp),  // Diff_p buffer input (connect directly to top-level port)
      .IB(Ethernet_RDm) // Diff_n buffer input (connect directly to top-level port)
   );

FIFORX FIFO_RD (
  .rst(RcvStart), // input rst
  .wr_clk(clk50), // input wr_clk
  .rd_clk(clk20), // input rd_clk
  .din(RcvData), // input [7 : 0] din
  .wr_en(RcvDataAvailable), // input wr_en
  .rd_en(SendDataReq /*&& SendingPacket*/), // input rd_en
  .dout(FIFOOut), // output [7 : 0] dout
  .full(FIFOFull), // output full
  .empty(FIFOEmpty) // output empty
);

EthernetTX EthTX1 (clk20, 
	HostIP, SendToIP, HostMAC, SendToMAC, HostPort, SendToPort, 
   SendStart, SendDataReq, SendData, SendDataLen, SendDataPos, SendingPacket, 
	SendPacketType, RcvICMPId, RcvICMPSeq, SendICMPCRC2,
	Ethernet_TDp, Ethernet_TDm);

EthernetRX EthRX1 (clk50, 
	Ethernet_RD,
	HostIP, HostMAC, HostPort,
	RcvStart, RcvStop, RcvData, RcvDataLen, RcvDataPos, RcvDataAvailable, RcvCRCValid, ReceivingPacket,
	RcvPacketType, RcvICMPId, RcvICMPSeq, RcvICMPCRC,
	RcvFromIP, RcvFromMAC, RcvFromPort);


// Ethernet LEDs
reg [19:0] EthLEDCnt = 0;
always @(posedge clk20) begin
	EthLEDCnt <= EthLEDCnt + 1;
	Ethernet_LED_Act <= Ethernet_LED_Act && !(ReceivingPacket | SendingPacket);
	if (Ethernet_LED_Act)
		EthLEDCnt <= 0;
	if (&EthLEDCnt)
		Ethernet_LED_Act <= 1;
end

// Transmit packets
always @(posedge clk20) begin
	SendStart = 0;
	if (!SendingPacket && (PacketReceived || SendReq) && !PacketProcessed)
		begin
		Echo <= 0;
		PacketProcessed <= 1;
		SendToIP <= RcvFromIP;
		SendToMAC <= RcvFromMAC;

		if (RcvPacketType ==	`ARPReply)			// Remote MAC resolved
			begin
			RemoteMAC = RcvFromMAC;
			SendToPort = SavedPort;
			SendStart = 1;
			SendPacketType = SavedPacketType;
			SendDataLen = SavedDataLen;
			Echo <= SavedEcho;
			end
		else if ((RcvPacketType == `UDP) || SendReq)	// Send UDP packet
			begin
			if (SendReq)
				begin
				SendToIP <= RemoteIP;
				SendToMAC <= RemoteMAC;
				end
			else if (Cmd == `CmdDataEcho)
				Echo <= 1;
			SendToPort = RemotePort;
			SendStart = 1;
			SendPacketType = `UDP;
			SendDataLen = SendReq ? 18 : RcvDataLen;
			end
		else if (RcvPacketType == `ARPReq)				// Send ARP reply
			begin
			SendStart = 1;
			SendPacketType = `ARPReply;
			SendDataLen = 18;
			end
		else if (RcvPacketType == `ICMPReq)				// Send ICMP reply
			begin
			Echo <= 1;
			SendStart = 1;
			SendPacketType = `ICMPReply;
			SendDataLen = RcvDataLen;
			end

		if (~|RemoteMAC && SendStart && SendReq)		// If remote MAC unknown send ARP request
			begin													// TODO: clear RemoteMAC after 2 minutes inactivity
			SavedPacketType <= SendPacketType;
			SavedDataLen <= SendDataLen;
			SavedPort <= SendToPort;
			SavedEcho <= Echo;
			SendToIP <= RemoteIP;
			SendStart = 1;
			SendPacketType = `ARPReq;
			SendDataLen = 18;
			end
		end

	if (!PacketReceived && !SendReq)
		PacketProcessed <= 0;

	case (SendDataPos)
		0: SendData <= Cmd;
		1: SendData <= Arg;
		default: SendData <= 0;
	endcase

	if (Echo /*RcvPacketType == `ICMPReq*/)	// Cmd: Data echo
		SendData <= FIFOOut;
end


reg [25:0] cnt = 0;
reg AutoSend = 1;

// Receive packets
always @(posedge clk50) begin
	if (~&cnt)
		cnt <= cnt + 1;
	
	if (PacketProcessed)
		begin
		PacketReceived <= 0;
		SendReq <= 0;
		end
	
	if (RcvDataAvailable)
		if (RcvPacketType == `UDP)
			case (RcvDataPos)
				0: Cmd <= RcvData;
				1: Arg <= RcvData;
			endcase
	
	if (RcvStop && RcvCRCValid)
		begin
		PacketReceived <= 1;
		if (RcvPacketType == `UDP)
			begin
			if (Cmd == `CmdLEDCtrl)			// Received Cmd: Leds control
				begin
				LED_Test <= Arg[0];
				Cmd <= `CmdDone;				// Send reply: Cmd: Done
				end
			else if (Cmd == `CmdStatus)	// Received Cmd: Get Status
				begin
				Cmd <= `CmdStatus;			// Send reply: Cmd: Status
				Arg <= {5'd0, PushButton, AutoSend, LED_Test};	// Status
				end
			else if (Cmd == `CmdSetConfig)// Received Cmd: Set Config
				begin
				Cmd <= `CmdDone;				// Send reply: Cmd: Status
				AutoSend <= Arg[0];
				end
			end
		end
		
	if (!SendingPacket && !ReceivingPacket && !PacketProcessed)
		begin
		last_btn_st <= PushButton;
		if (last_btn_st != PushButton || (&cnt && AutoSend))
			begin
			cnt <= 0;
			Cmd <= `CmdSwChanged;	// Cmd: Pushbuttons state changed
			if (&cnt)
				Cmd <= `CmdStatus;
			Arg <= {8{PushButton}};
			SendReq <= 1;
			end
		end
end

endmodule
