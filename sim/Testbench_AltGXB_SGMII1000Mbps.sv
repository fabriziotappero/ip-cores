/*
Developed by Jeff Lieu (lieumychuong@gmail.com)

File		:
Description	:
	In this test, we use Altera Tranceiver as Link Partner
	Configure bothside to be 1000BaseX Mode

Remarks		:
	There seems to be a bug in Altera's core, tx path
	- The Tx Path sometime omits 1 pre-ample octet depending on the cycle that TxEN is aserted. 
	- At the transmit task, the #8 delay will have effect on the Altera's core. Without delay, 
		the first packet is transmitted with the first octet somehow removed (you can confirm this 
		by looking at the Codegroup that is input of u0SGMII/u0Receive/
	- With the delay on, the first packet is fine, but the second packet has some problem.
	- This has something todo with the alignment of the TxEN,
		I'm not sure whether the MAC layer is responsible for aligning TxEN's assertion or not.
	- This test only Transmits normal frame, i.e no Carrier Extension or Error Propagation
	
	- The Path of U0 --> U1 is ok.
	
	- Testing with Version 11.1sp2 core seems to be ok, this problem is not found
	
Revision	:
	Date	Author	Description

*/
`timescale 1ns/1ps
`include "SGMIIDefs.v"

module mSGMIITestbench();
`include "Veritil.v"


reg r_Reset_L;
reg r_Clk125M;
reg r_Clk50M;


wire			w_u1RxClk;
wire			w_u1TxClk;
wire 			w_u1RxDV;
wire 			w_u1RxER;
wire [07:00] 	w8_u1RxD;
wire [07:00] 	w8_u1TxD;
wire 			w_u1TxEN;
wire 			w_u1TxER;

wire 			w_u0RxDV;
wire 			w_u0RxER;
wire [07:00] 	w8_u0RxD;
wire [07:00] 	w8_u0TxD;
wire 			w_u0TxEN;
wire 			w_u0TxER;


wire w_u0WbCyc, w_u0WbAck, w_u0WbStb, w_u0WbWEn;
wire [31:00] w32_u0WbAddr, w32_u0WbWrData, w32_u0WbRdData;
wire w_u1WbCyc, w_u1WbAck, w_u1WbStb, w_u1WbWEn;
wire [31:00] w32_u1WbAddr, w32_u1WbWrData, w32_u1WbRdData;
wire w_u0ANDone,w_u1ANDone;

`define tstcfg_Normal		0
`define tstcfg_CarrierExt	1
`define tstcfg_BurstTrans	2
`define tstcfg_ErrorProp1	3
`define tstcfg_ErrorProp2	4
`define tstcfg_SizeXShort	0
`define tstcfg_SizeShort	1
`define tstcfg_SizeMedium	2
`define tstcfg_SizeLarge	3
`define tstcfg_SizeXLarge	4

`define tstcfg_1000X		0
`define tstcfg_SGMII1G		1
`define tstcfg_SGMII100M	2

integer tstcfg_Standard;

integer tstcfg_PktSize;
integer tstcfg_Type;
integer tstcfg_Seed;
integer tstcfg_TxPktCnt;
integer tstcfg_RxPktCnt;

	reg [15:00] r16_CoreVersion;
	wire [01:00] w2_u0Speed;
	

	initial r_Clk125M <= 1'b0;
	initial r_Clk50M <= 1'b0;
	always@*
		#4 r_Clk125M <= ~r_Clk125M;
	
	always@*	
		#10 r_Clk50M <= ~r_Clk50M;
		
	wire w_u0Rx,w_u0Tx;
	wire w_u1Rx,w_u1Tx;
		
		initial 
			begin
				$display("------------------------------------");
				$display("-------Subtleware Ltd Pte 2012------");
				$display("--Testing SGMII in SGMII 1000Gb Mode------");
				$display("------------------------------------");				
				tstcfg_TxPktCnt = 0;
				tstcfg_RxPktCnt = 0;
				r_Reset_L <= 1'b0;
				#1000;
				r_Reset_L <= 1'b1;	
				#1000;
				u0WishboneMstr.tsk_Read((10<<2),r16_CoreVersion);
				$display("---Core Version : %x", r16_CoreVersion);
				tsk_Setup();
			end
	
	mWishboneMstr u0WishboneMstr(
	.o_WbCyc	(w_u0WbCyc),
	.o_WbStb	(w_u0WbStb),
	.o_WbWEn	(w_u0WbWEn),
	.ov_WbAddr	(w32_u0WbAddr),
	.ov_WbWrData(w32_u0WbWrData),
	.iv_WbRdData(w32_u0WbRdData),
	.i_Ack		(w_u0WbAck),
	.i_Stall	(1'b0),
	.i_Rty		(1'b0),
	.i_Clk		(w_u0GMIIClk));
	
	mWishboneMstr u1WishboneMstr(
	.o_WbCyc	(w_u1WbCyc),
	.o_WbStb	(w_u1WbStb),
	.o_WbWEn	(w_u1WbWEn),
	.ov_WbAddr	(w32_u1WbAddr),
	.ov_WbWrData(w32_u1WbWrData),
	.iv_WbRdData(w32_u1WbRdData),
	.i_Ack		(w_u1WbAck),
	.i_Stall	(1'b0),
	.i_Rty		(1'b0),
	.i_Clk		(w_u1RxClk));
	
	//Tranceiver Interface
	mSGMII u0SGMII (
	.i_SerRx			(w_u0Rx),
	.o_SerTx			(w_u0Tx),
	.i_CalClk			(r_Clk50M),
	.i_RefClk125M		(r_Clk125M),
	.i_ARstHardware_L	(r_Reset_L),

	//Local BUS interface
	//Wishbonebus, single transaction mode (non-pipeline slave)
	.i_Cyc		(w_u0WbCyc),
	.i_Stb		(w_u0WbStb),
	.i_WEn		(w_u0WbWEn),
	.i32_WrData	(w32_u0WbWrData),
	.iv_Addr	(w32_u0WbAddr[7:0]),
	.o32_RdData	(w32_u0WbRdData),
	.o_Ack		(w_u0WbAck),
	
	.i_Mdc		(1'b0),
	.io_Mdio	(),
	
	.i_PhyLink	(1'b1),
	.i2_PhySpeed(2'b00),
	.i_PhyDuplex(1'b0),
	//Status
	.o_ANDone	(w_u0ANDone),
	.o_Linkup	(w_u0LinkUp),
	.o2_SGMIISpeed	(w2_u0Speed),
	.o_SGMIIDuplex	(w_u0Duplex),
	
	//GMII Interface
	.i8_TxD		(w8_u0TxD),
	.i_TxEN		(w_u0TxEN),
	.i_TxER		(w_u0TxER),
	.o8_RxD		(w8_u0RxD),
	.o_RxDV		(w_u0RxDV),
	.o_RxER		(w_u0RxER),
	.o_GMIIClk	(w_u0GMIIClk),
	.o_Col		(),
	.o_Crs		());


	
	sgmii u1SGMII (
	.gmii_rx_d		(w8_u1RxD),
	.gmii_rx_dv		(w_u1RxDV),
	.gmii_rx_err	(w_u1RxER),
	
	.gmii_tx_d		(w8_u1TxD),
	.gmii_tx_en		(w_u1TxEN),
	.gmii_tx_err	(w_u1TxER),
	
	.tx_clk			(w_u1TxClk),//output,
	.rx_clk			(w_u1RxClk),
	.led_an			(w_u1ANDone),
	.led_disp_err	(),
	.led_char_err	(),
	.led_link		(w_led_link),
	.rx_recovclkout	(),
	
	.rxp				(w_u1Rx),
	.txp				(w_u1Tx),
	.pcs_pwrdn_out		(),
	.reconfig_fromgxb	(),	
	
	.reset_tx_clk	(~r_Reset_L),
	.reset_rx_clk	(~r_Reset_L),
	
	.readdata		(w32_u1WbRdData[15:00]),
	.waitrequest	(w_AvlWaitReq),
	.address		(w32_u1WbAddr[6:2]),
	.read			(w_AvlRd),
	.writedata		(w32_u1WbWrData[15:00]),
	.write			(w_AvlWr),
	.clk			(w_u1RxClk),
	.reset			(~r_Reset_L),
	
	.ref_clk			(r_Clk125M),
	.gxb_pwrdn_in		(1'b0),
	.gxb_cal_blk_clk	(r_Clk50M),
	.reconfig_clk		(r_Clk50M),
	.reconfig_togxb		(5'b0),
	.reconfig_busy		());
	
	
	//MacEmulation
	mMACEmulator u0MacEmulator(
	.i_RxClk	(w_u0GMIIClk),
	.i_TxClk	(w_u0GMIIClk),
	
	.i8_RxD	(w8_u0RxD),
	.i_RxDV	(w_u0RxDV),
	.i_RxER	(w_u0RxER),
	.o8_TxD	(w8_u0TxD),
	.o_TxEN	(w_u0TxEN),
	.o_TxER	(w_u0TxER),
	
	.i_Reset_L(r_Reset_L));
	
	 mMACEmulator u1MacEmulator(
	.i_RxClk	(w_u1RxClk),	
	.i_TxClk	(w_u1TxClk),	
	.i8_RxD	(w8_u1RxD),
	.i_RxDV	(w_u1RxDV),
	.i_RxER	(w_u1RxER),
	.o8_TxD	(w8_u1TxD),
	.o_TxEN	(w_u1TxEN),
	.o_TxER	(w_u1TxER),
	
	.i_Reset_L(r_Reset_L));
	
	
	
	//This portion translate Wishbone Signal to Avalon Signal
	assign w_AvlWr = w_u1WbStb & w_u1WbCyc & w_u1WbWEn;
	assign w_AvlRd = w_u1WbStb & w_u1WbCyc & (~w_u1WbWEn);
	assign w_u1WbAck = ~w_AvlWaitReq;
		
	assign w_u0Rx = w_u1Tx;
	assign w_u1Rx = w_u0Tx;
	
	reg [7:0] 	r8_TxBuffer[0:1023][0:10000];	
	integer		s32_TxCarrierExtCycles[0:1023];
	integer		s32_TxCarrierErrCycles[0:1023];
	reg [7:0] 	r8_u0RxBuffer[0:1023][0:10000];	
	reg [7:0] 	r8_u1RxBuffer[0:1023][0:10000];
	
	
	reg [15:00] r16_u0Ability;
	reg [15:00] r16_u1Ability;
	reg [31:00] r32_ReadData;
	integer I;
	integer length;
	integer u0RxPktCnt,u1RxPktCnt;
	integer u0ExtCycles,u1ExtCycles;
	integer u0ErrCycles,u1ErrCycles;
	integer u0FrameSize,u1FrameSize;
	
	
	initial		
		begin
			length = 100;
			
			#100;
		
			$display("Waiting for Auto Negotiation Done");		
			#100;
			while(w_u0ANDone==1'b0) 
				begin 
				@(posedge w_u0GMIIClk);#1;
				end

			//Verify link partner ability
			u0WishboneMstr.tsk_Read(16'h14,r32_ReadData);
			`CheckE(r32_ReadData[15:00],r16_u1Ability,"Link Partner Advertised Ability")
			u1WishboneMstr.tsk_Read(16'h14,r32_ReadData);
			`CheckE(r32_ReadData[15:00],r16_u0Ability,"Link Partner Advertised Ability")
			
			#1000;
			$display("Start Generating Scenarios");
			for(I=0;I<1000;I=I+1)
					tsk_ScenariosGenerator();				
			
			
			$display("Test Result: %s (Error Count = %d)",ErrorCnt>0?"FAILED":"PASSED",ErrorCnt);
			#3000;	
		end
		
		initial
			begin:u1Receiving
			u1RxPktCnt=0;
			$display("Waiting for Auto Negotiation Done");		
			#100;
			while(w_u1ANDone==1'b0) 
				begin 
				@(posedge w_u1RxClk);#1;
				end
			forever
				begin
				u1MacEmulator.tsk_ReceivePkt(r8_u1RxBuffer[u1RxPktCnt],u1FrameSize,u1ExtCycles,u1ErrCycles);
				u1FrameSize--;
				while(u1FrameSize>=0)
					begin						
						`CheckF(r8_u1RxBuffer[u1RxPktCnt][u1FrameSize],r8_TxBuffer[u1RxPktCnt][u1FrameSize],"Received byte")
						u1FrameSize--;				
					end
				u1RxPktCnt=u1RxPktCnt+1;
				$display("u1: Checked Pkt %d",u1RxPktCnt);
				end
			
			end
		
		initial
			begin:u0Receiving
			u0RxPktCnt=0;
			$display("Waiting for Auto Negotiation Done");		
			#100;
			while(w_u0ANDone==1'b0) 
				begin 
				@(posedge w_u0GMIIClk);#1;
				end
			forever
				begin
				u0MacEmulator.tsk_ReceivePkt(r8_u0RxBuffer[u0RxPktCnt],u0FrameSize,u0ExtCycles,u0ErrCycles);
				u0FrameSize--;
				while(u0FrameSize>=0)
					begin						
						`CheckF(r8_u0RxBuffer[u0RxPktCnt][u0FrameSize],r8_TxBuffer[u0RxPktCnt][u0FrameSize],"Received byte")
						u0FrameSize--;				
					end
				u0RxPktCnt=u0RxPktCnt+1;
				$display("u0: Checked Pkt %d",u0RxPktCnt);
				end
			
			end
	


	task tsk_Setup;
		begin	
		//U1 is ALTERA's		
		u1WishboneMstr.tsk_Read(7'b10001_00,r16_CoreVersion);		
		$display("Altera SGMII Core Version %x",r16_CoreVersion);
		
		u1WishboneMstr.tsk_Write(0,32'h0000_1000);					//Enable Auto-Negotiation
		r16_u1Ability=16'h1400;
		u1WishboneMstr.tsk_Write(7'b00100_00,r16_u1Ability);		//Set Dev Ability
		
		u1WishboneMstr.tsk_Write(7'b10010_00,32'h01E2);				//Set Link Timer to 10000 ns
		u1WishboneMstr.tsk_Write(7'b10011_00,32'h0000);				
		u1WishboneMstr.tsk_Read(7'b10010_00,r16_CoreVersion);		
		$display("Link Timer 0 %x",r16_CoreVersion);
		u1WishboneMstr.tsk_Read(7'b10011_00,r16_CoreVersion);		
		$display("Link Timer 1 %x",r16_CoreVersion);
		u1WishboneMstr.tsk_Write(7'b10100_00,{27'h0,1'b1,4'b0011});	//Enable SGMII Mode,
		u1WishboneMstr.tsk_Read(7'b10100_00,r16_CoreVersion);		
		$display("Mode Register 1 %x",r16_CoreVersion);
		
		
		//U0 is MINE		
		r16_u0Ability=16'h1800;
		u0WishboneMstr.tsk_Write(7'b00100_00,r16_u0Ability);		//Set Dev Ability, this is advertised information 
		u0WishboneMstr.tsk_Write((8<<2),32'h0000_01E2);				//Set Link Timer to 2500 ns
		u0WishboneMstr.tsk_Write((9<<2),32'h0000_0000);		
		u0WishboneMstr.tsk_Write((31<<2),32'h0007);					//Enable SGMII, PHY Side
		$display("Restart PHY auto-nego");
		u0WishboneMstr.tsk_Write(0,32'h0000_1340);					//Restart Auto-negotiation, set Full Duplex, 1000Mbps
		
		end
	endtask
			
	task tsk_ScenariosGenerator;	
		//Generate Type of Transmission
		begin
		tstcfg_Seed = $random;
		tstcfg_Type	   = $dist_uniform(tstcfg_Seed,0,4);
		tstcfg_Type		= `tstcfg_Normal;
		case(tstcfg_Type)
		`tstcfg_Normal: begin $display("Transmit Type Normal"); tsk_TransmitNormal(); end
		`tstcfg_BurstTrans: begin $display("Transmit Type Burst"); tsk_TransmitBurst(); end
		`tstcfg_CarrierExt: begin $display("Transmit Type Carrier Extension"); tsk_TransmitCarrExt(); end
		`tstcfg_ErrorProp1: begin $display("Transmit Type Error Prop within Frame"); tsk_TransmitErrInFrame(); end
		`tstcfg_ErrorProp2: begin $display("Transmit Type Error Prop out of Frame"); tsk_TransmitErrOutFrame();end
		endcase		
		
		end
	endtask
	
	task tsk_TransmitNormal;
		integer PktSize;
		integer PktNum;
		integer PktIFG;		
		integer Idx;
		integer Octet;
	begin				
		PktNum = $dist_uniform(tstcfg_Seed,1,10);//From 1 to 10
		for(Idx=0;Idx<PktNum;Idx=Idx+1)
		begin				
			PktIFG = $dist_uniform(tstcfg_Seed,10,14);//From 2 to 10
			tstcfg_PktSize = $dist_uniform(tstcfg_Seed,0,4);					
			
			case(tstcfg_PktSize)
			`tstcfg_SizeXShort	: PktSize = $dist_uniform(tstcfg_Seed,64,128);	
			`tstcfg_SizeShort	: PktSize = $dist_uniform(tstcfg_Seed,128,512);	
			`tstcfg_SizeMedium	: PktSize = $dist_uniform(tstcfg_Seed,512,1024);	
			`tstcfg_SizeLarge	: PktSize = $dist_uniform(tstcfg_Seed,1024,1518);	
			`tstcfg_SizeXLarge	: PktSize = $dist_uniform(tstcfg_Seed,1518,9000);	
			endcase		
			
			s32_TxCarrierExtCycles[tstcfg_TxPktCnt+Idx]=(PktSize&32'h1)?1:0;
			s32_TxCarrierErrCycles[tstcfg_TxPktCnt+Idx]=0;
			for(Octet=0;Octet<PktSize;Octet=Octet+1)
				begin
					r8_TxBuffer[tstcfg_TxPktCnt+Idx][Octet]=$random;
				end
			r8_TxBuffer[tstcfg_TxPktCnt+Idx][8]=PktSize & 32'h00FF;					
			r8_TxBuffer[tstcfg_TxPktCnt+Idx][9]=((PktSize & 32'hFF00)>>8);					
			//Transmit:
			
			fork
				begin
				$display("u0: Sending Packet %d Size %d",tstcfg_TxPktCnt+Idx,PktSize);
				u0MacEmulator.tsk_TransmitPkt(r8_TxBuffer[tstcfg_TxPktCnt+Idx],PktSize,PktIFG);							
				end
				begin 
				$display("u1: Sending Packet %d Size %d",tstcfg_TxPktCnt+Idx,PktSize);
				//#8;		//If You Remove This Delay, you will have error in first packet.
				u1MacEmulator.tsk_TransmitPkt(r8_TxBuffer[tstcfg_TxPktCnt+Idx],PktSize,PktIFG);
				end
			join
			
		
		end
		tstcfg_TxPktCnt = tstcfg_TxPktCnt+PktNum;
		
	end	
	endtask


	task tsk_TransmitBurst;
	integer PktSize;
	integer PktNum;
	integer PktIFG;		
	integer Idx;
	integer Octet;
	integer ExtCycles;	
	integer TotalExtCycles;
	integer TotalBytes;
	integer PktStartOffset;
	begin		
		PktNum = $dist_uniform(tstcfg_Seed,1,6);//From 1 to 10
		PktIFG = $dist_uniform(tstcfg_Seed,10,14);//From 2 to 10
		s32_TxCarrierExtCycles[tstcfg_TxPktCnt]=0;
		TotalBytes=0;
		TotalExtCycles=0;
		PktStartOffset=0;
		$display("Bursting : %d packets",PktNum);
		for(Idx=0;Idx<PktNum;Idx=Idx+1)
		begin							
			tstcfg_PktSize = $dist_uniform(tstcfg_Seed,0,3);				//Nojumbo
			ExtCycles = $dist_uniform(tstcfg_Seed,3,5);//Burst must have at least 2 /R/ interpacket R
			
			case(tstcfg_PktSize)
			`tstcfg_SizeXShort	: PktSize = $dist_uniform(tstcfg_Seed,64,128);	
			`tstcfg_SizeShort	: PktSize = $dist_uniform(tstcfg_Seed,128,512);	
			`tstcfg_SizeMedium	: PktSize = $dist_uniform(tstcfg_Seed,512,1024);	
			`tstcfg_SizeLarge	: PktSize = $dist_uniform(tstcfg_Seed,1024,1518);	
			`tstcfg_SizeXLarge	: PktSize = $dist_uniform(tstcfg_Seed,1518,9000);	
			endcase
			
			TotalExtCycles=TotalExtCycles+ExtCycles;
			TotalBytes = TotalBytes+PktSize;		
			
			//Generate Packet
			for(Octet=0;Octet<PktSize;Octet=Octet+1)
				begin
				if(Octet<7)
					r8_TxBuffer[tstcfg_TxPktCnt][PktStartOffset+Octet]=8'h55;					
				else if(Octet==7)
					r8_TxBuffer[tstcfg_TxPktCnt][PktStartOffset+Octet]=8'hD5;
				else
					r8_TxBuffer[tstcfg_TxPktCnt][PktStartOffset+Octet]=$random;
				end
			r8_TxBuffer[tstcfg_TxPktCnt][PktStartOffset+8]=PktSize & 32'h00FF;					
			r8_TxBuffer[tstcfg_TxPktCnt][PktStartOffset+9]=((PktSize & 32'hFF00)>>8);					
			//Transmit:
			$display("Not complete task");
			$display("Sender 	: Sending Packet %d (part %d) Size %d",tstcfg_TxPktCnt,Idx,PktSize);
		end
		//Send Interframe Gap		
		s32_TxCarrierErrCycles[tstcfg_TxPktCnt]=0;
		s32_TxCarrierExtCycles[tstcfg_TxPktCnt]=((TotalBytes+TotalExtCycles)&32'h1)?(TotalExtCycles+1):TotalExtCycles;
		tstcfg_TxPktCnt = tstcfg_TxPktCnt+1;
	end	
	endtask
	
	task tsk_TransmitCarrExt;
	integer PktSize;
	integer PktNum;
	integer PktIFG;		
	integer Idx;
	integer Octet;
	integer ExtCycles;	
	begin		
		PktNum = $dist_uniform(tstcfg_Seed,1,10);//From 1 to 10
		for(Idx=0;Idx<PktNum;Idx=Idx+1)
		begin				
			PktIFG = $dist_uniform(tstcfg_Seed,10,14);//From 2 to 10
			tstcfg_PktSize = $dist_uniform(tstcfg_Seed,0,4);				
			ExtCycles = $dist_uniform(tstcfg_Seed,1,100);//From 2 to 10
			
			case(tstcfg_PktSize)
			`tstcfg_SizeXShort	: PktSize = $dist_uniform(tstcfg_Seed,64,128);	
			`tstcfg_SizeShort	: PktSize = $dist_uniform(tstcfg_Seed,128,512);	
			`tstcfg_SizeMedium	: PktSize = $dist_uniform(tstcfg_Seed,512,1024);	
			`tstcfg_SizeLarge	: PktSize = $dist_uniform(tstcfg_Seed,1024,1518);	
			`tstcfg_SizeXLarge	: PktSize = $dist_uniform(tstcfg_Seed,1518,9000);	
			endcase
			
			s32_TxCarrierExtCycles[tstcfg_TxPktCnt+Idx]=((PktSize+ExtCycles)&32'h1)?ExtCycles+1:ExtCycles;
			s32_TxCarrierErrCycles[tstcfg_TxPktCnt+Idx]=0;
			//Generate Packet
			for(Octet=0;Octet<PktSize;Octet=Octet+1)
				begin
				if(Octet<7)
					r8_TxBuffer[tstcfg_TxPktCnt+Idx][Octet]=8'h55;					
				else if(Octet==7)
					r8_TxBuffer[tstcfg_TxPktCnt+Idx][Octet]=8'hD5;
				else
					r8_TxBuffer[tstcfg_TxPktCnt+Idx][Octet]=$random;
				end
			r8_TxBuffer[tstcfg_TxPktCnt+Idx][8]=PktSize & 32'h00FF;					
			r8_TxBuffer[tstcfg_TxPktCnt+Idx][9]=((PktSize & 32'hFF00)>>8);					
			//Transmit:
			$display("Not complete task");			
			$display("Sender 	: Sending Packet %d Size %d",(tstcfg_TxPktCnt+Idx),PktSize);
		end
		tstcfg_TxPktCnt = tstcfg_TxPktCnt+PktNum;
	end	
	endtask
	
	task tsk_TransmitErrInFrame;	
		integer PktSize;
		integer PktNum;
		integer PktIFG;		
		integer Idx;
		integer Octet;
		integer ErrorCycle;
		integer ErrorPos;
	begin				
		PktNum = $dist_uniform(tstcfg_Seed,1,10);//From 1 to 10
		ErrorCycle = $dist_uniform(tstcfg_Seed,1,10);//From 1 to 10
		
		for(Idx=0;Idx<PktNum;Idx=Idx+1)
		begin				
			PktIFG = $dist_uniform(tstcfg_Seed,10,14);//From 2 to 10
			tstcfg_PktSize = $dist_uniform(tstcfg_Seed,0,4);					
			
			case(tstcfg_PktSize)
			`tstcfg_SizeXShort	: PktSize = $dist_uniform(tstcfg_Seed,64,128);	
			`tstcfg_SizeShort	: PktSize = $dist_uniform(tstcfg_Seed,128,512);	
			`tstcfg_SizeMedium	: PktSize = $dist_uniform(tstcfg_Seed,512,1024);	
			`tstcfg_SizeLarge	: PktSize = $dist_uniform(tstcfg_Seed,1024,1518);	
			`tstcfg_SizeXLarge	: PktSize = $dist_uniform(tstcfg_Seed,1518,9000);	
			endcase		
			
			s32_TxCarrierExtCycles[tstcfg_TxPktCnt+Idx]=(PktSize&32'h1)?1:0;
			ErrorPos = $dist_uniform(tstcfg_Seed,1,(PktSize-ErrorCycle));
			s32_TxCarrierErrCycles[tstcfg_TxPktCnt+Idx]=ErrorCycle;
			for(Octet=0;Octet<PktSize;Octet=Octet+1)
				begin
				if(Octet<7)
					r8_TxBuffer[tstcfg_TxPktCnt+Idx][Octet]=8'h55;					
				else if(Octet==7)
					r8_TxBuffer[tstcfg_TxPktCnt+Idx][Octet]=8'hD5;
				else
					r8_TxBuffer[tstcfg_TxPktCnt+Idx][Octet]=$random;
				end
			r8_TxBuffer[tstcfg_TxPktCnt+Idx][8]=PktSize & 32'h00FF;					
			r8_TxBuffer[tstcfg_TxPktCnt+Idx][9]=((PktSize & 32'hFF00)>>8);					
			//Transmit:
			$display("Not complete task");
			
		$display("Sender 	: Sending Packet %d Size %d",tstcfg_TxPktCnt+Idx,PktSize);
		end
		tstcfg_TxPktCnt = tstcfg_TxPktCnt+PktNum;
		
	end	
	endtask
	
	task tsk_TransmitErrOutFrame;		
		integer PktSize;
		integer PktNum;
		integer PktIFG;		
		integer Idx;
		integer Octet;
		integer ErrorCycle;
		integer ErrorPos;
		integer ExtCycles;
	begin				
		PktNum = $dist_uniform(tstcfg_Seed,1,10);//From 1 to 10		
		
		for(Idx=0;Idx<PktNum;Idx=Idx+1)
		begin				
			ExtCycles = $dist_uniform(tstcfg_Seed,7,20);
			ErrorCycle = $dist_uniform(tstcfg_Seed,1,3);//From 1 to 10
			PktIFG = $dist_uniform(tstcfg_Seed,10,14);//From 2 to 10
			tstcfg_PktSize = $dist_uniform(tstcfg_Seed,0,4);								
			case(tstcfg_PktSize)
			`tstcfg_SizeXShort	: PktSize = $dist_uniform(tstcfg_Seed,64,128);	
			`tstcfg_SizeShort	: PktSize = $dist_uniform(tstcfg_Seed,128,512);	
			`tstcfg_SizeMedium	: PktSize = $dist_uniform(tstcfg_Seed,512,1024);	
			`tstcfg_SizeLarge	: PktSize = $dist_uniform(tstcfg_Seed,1024,1518);	
			`tstcfg_SizeXLarge	: PktSize = $dist_uniform(tstcfg_Seed,1518,9000);	
			endcase		
			
			s32_TxCarrierExtCycles[tstcfg_TxPktCnt+Idx]=((PktSize+ExtCycles)&32'h1)?(ExtCycles+1):ExtCycles;
			ErrorPos = $dist_uniform(tstcfg_Seed,3,(ExtCycles-ErrorCycle));
			$display("----Ext = %d, Error = %d",ExtCycles,ErrorCycle);
			s32_TxCarrierErrCycles[tstcfg_TxPktCnt+Idx]=ErrorCycle;
			for(Octet=0;Octet<PktSize;Octet=Octet+1)
				begin
				if(Octet<7)
					r8_TxBuffer[tstcfg_TxPktCnt+Idx][Octet]=8'h55;					
				else if(Octet==7)
					r8_TxBuffer[tstcfg_TxPktCnt+Idx][Octet]=8'hD5;
				else
					r8_TxBuffer[tstcfg_TxPktCnt+Idx][Octet]=$random;
				end
			r8_TxBuffer[tstcfg_TxPktCnt+Idx][8]=PktSize & 32'h00FF;					
			r8_TxBuffer[tstcfg_TxPktCnt+Idx][9]=((PktSize & 32'hFF00)>>8);					
			//Transmit:
		$display("Not complete task");
			
		$display("Sender 	: Sending Packet %d Size %d",tstcfg_TxPktCnt+Idx,PktSize);
		end
		tstcfg_TxPktCnt = tstcfg_TxPktCnt+PktNum;
		
	end	
	endtask

	
	//Informatiion
	always@(*)
	begin
		if(w_u0LinkUp==1'b1) $display("Link Acquired"); else $display("Link Dropped");
		if(w_u0ANDone==1'b1) begin
			$display("Auto-nego completes");	
			$display("Link Speed %d Mbps",(w2_u0Speed==2'b10)?1000:((w2_u0Speed==2'b01)?100:((w2_u0Speed==2'b00)?10:0)));
			$display("Link Duplex %s ",w_u0Duplex?"Full":"Half");
			end
	end
	
	reg [15:00] r16_LpAbility;
	initial	
		begin
		
		forever
			begin
			#1000;
			u1WishboneMstr.tsk_Read(7'b00101_00,r16_LpAbility);		//Enable SGMII Mode, Speed 1000Gb, Full Duplex
			//$display("Partner Ability %x",r16_LpAbility);
			end
		end
	
endmodule

//TODO Test case Loopback
//TODO Test Auto Negotiation													(Good)
//TODO Test Restart Auto Negotiation											(Good)
//TODO Test case 1) Basic, Random size packets from 16 bytes to 10000 bytes		
//TODO Test case 2) Carrier Extension,  figure 35-6
//TODO Test case 3) Burst transmission, figure 35-7
//TODO Test case 4) Error Propagation with in aframe, figure 35-4
//TODO Test case 5) Error Propagation with carrier extension, figure 35-4
