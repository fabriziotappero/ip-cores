/*
Developed by Jeff Lieu (lieumychuong@gmail.com)

File		:
Description	:

Remarks		:

Revision	:
	Date	Author	Description

*/
`timescale 1ns/10ps

module mMACEmulator(
	input i_RxClk,
	input i_TxClk,
	input [07:00] i8_RxD,
	input i_RxDV,
	input i_RxER,	
	output reg [07:00] o8_TxD,
	output reg o_TxEN,
	output reg o_TxER,
	
	input [1:0] i2_Speed,	
	input i_Reset_L);
	
	reg r_Active;
	integer Octet;
	integer ExtCycles;
	integer ErrCycles;
	integer RxPktCnt;
	wire w_Active;
	wire w_Sop;
	wire w_Eop;
	reg [07:00] ReceivedPkt[0:10000];
	reg [07:00] r8_LstRxD;
	integer RxPtr;
	reg ReceiveEnable;
	
	assign w_Sop = ~r_Active & w_Active;
	assign w_Eop = r_Active & (~w_Active);
	
	
		initial 
			begin
			RxPktCnt=0;
			o_TxEN=0;
			o_TxER=0;
			o8_TxD=0;
			ReceiveEnable <= 1'b0;
			end
	
	assign w_Active=i_RxDV|i_RxER;
	always@(posedge i_RxClk)	
		begin
			r_Active <= w_Active;
			r8_LstRxD 	<= i8_RxD;
		end
		
		
		
	
	task automatic tsk_ReceivePkt;		
		output [07:00] ov_ReceivedPkt[0:10000];
		output integer FrameSize;
		output integer ExtCycles;
		output integer ErrCycles;
		
		integer Octet;
	begin
		ExtCycles = 0;
		ErrCycles = 0;
		for(Octet=0;Octet<10000;Octet=Octet+1)
			ov_ReceivedPkt[Octet]=0;		
		Octet=0;
		$display("(%d)MAC	: Start Rx Task",$time);
		if(i2_Speed==2'b10)
		begin
			while(w_Active!=1'b1||r_Active!=1'b0)
				@(posedge i_RxClk);
			while(w_Active!=1'b1||i8_RxD!=8'hD5||r8_LstRxD!=8'h55)
				@(posedge i_RxClk);
			
			@(posedge i_RxClk);
			$display("MAC: Start Receiving");
			while(r_Active!=1'b1||w_Active!=1'b0)
			begin
				if(i_RxDV==1'b1 && i_RxER==1'b0)
					begin			
					ov_ReceivedPkt[Octet]=i8_RxD;							
					Octet=Octet+1;	
					end
				else if(i_RxDV==1'b0 && i_RxER==1'b1) 
					begin
						case(i8_RxD)
						8'h0F: begin 						
								ExtCycles = ExtCycles+1;						
							   end
						8'h1F: begin 
								$display("Error Propagation");
								ExtCycles = ExtCycles+1;
								ErrCycles = ErrCycles+1;
								end
						default: $display("Unknown %x",i8_RxD);
						endcase
					end
				else if(i_RxDV==1'b1 && i_RxER==1'b1) 
					begin				
						ErrCycles = ErrCycles+1;					
					end	
				@(posedge i_RxClk);
			end
		end 
		else
		begin
			while(w_Active!=1'b1||r_Active!=1'b0)
				@(posedge i_RxClk);
			while(w_Active!=1'b1||i8_RxD[3:0]!=4'hD||r8_LstRxD[3:0]!=4'h5)
				@(posedge i_RxClk);
			@(posedge i_RxClk);
			$display("MAC: Start Receiving");
			while(r_Active!=1'b1||w_Active!=1'b0)
			begin
				if(i_RxDV==1'b1 && i_RxER==1'b0)
					begin			
					ov_ReceivedPkt[Octet][3:0]=i8_RxD[3:0];							
					@(posedge i_RxClk);
					ov_ReceivedPkt[Octet][7:4]=i8_RxD[3:0];							
					Octet=Octet+1;	
					end									
				else if(i_RxDV==1'b1 && i_RxER==1'b1) 
					begin				
						ErrCycles = ErrCycles+1;					
					end	
				@(posedge i_RxClk);
			end
		
		
		end
		FrameSize=Octet;
		$display("MAC: Packet Received with %d bytes",FrameSize);		
	end
	endtask

	task automatic tsk_TransmitPkt;
		ref reg [7:0] iv_TransmitPkt[0:10000];
		input integer PktSize;
		input integer PktIFG;
		
		integer Octet;
	begin
		if(i2_Speed==2'b10) 
		begin
			for(Octet=0;Octet<8;Octet++)
				begin
				@(posedge i_TxClk);#1;
				o_TxEN = 1'b1;
				o_TxER = 1'b0;
				o8_TxD = (Octet==7)?8'hD5:8'h55;			
				end
			for(Octet=0;Octet<PktSize;Octet=Octet+1)
					begin
					@(posedge i_TxClk);#1;
					o_TxEN = 1'b1;
					o_TxER = 1'b0;
					o8_TxD = iv_TransmitPkt[Octet];
					end
					@(posedge i_TxClk);#1;
					o_TxEN = 1'b0;
				//Interframe Gap
				for(Octet=0;Octet<PktIFG;Octet=Octet+1)
					begin @(posedge i_TxClk);#1; end
		end else
		begin
			for(Octet=0;Octet<8;Octet++)
				begin
				@(posedge i_TxClk);#1;
				o_TxEN = 1'b1;
				o_TxER = 1'b0;
				o8_TxD = (Octet==7)?8'h5:8'h5;			
				@(posedge i_TxClk);#1;				
				o8_TxD = (Octet==7)?8'hD:8'h5;
				end
			for(Octet=0;Octet<PktSize;Octet=Octet+1)
					begin
					@(posedge i_TxClk);#1;
					o_TxEN = 1'b1;
					o_TxER = 1'b0;
					o8_TxD = iv_TransmitPkt[Octet][3:0];
					@(posedge i_TxClk);#1;
					o8_TxD = iv_TransmitPkt[Octet][7:4];
					end
				@(posedge i_TxClk);#1;
				o_TxEN = 1'b0;
				//Interframe Gap
				for(Octet=0;Octet<PktIFG;Octet=Octet+1)
					begin @(posedge i_TxClk);#1; end		
		end
	end
	endtask


endmodule
