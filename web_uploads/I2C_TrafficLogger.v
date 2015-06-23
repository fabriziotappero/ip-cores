//This Verilog code datalog I2C bus traffic and writes into an external
//RAM in 8 bit byte format. It supports the 5 Atmel I2C read/write
//protocals:  (1) One byte read-  S:DEV:ADD:R:A:DATA:A:P
//            (2) One byte write- S:DEV:ADD:W:A:DATA:A:P
//            (3) Page write -    S:DEV:ADD:W:A:DATA1:A:DATA2:A ...P
//            (4) Page read-      S:DEV:ADD:R:A:DATA1:A:DATA2:A ...P
//            (5) Random read-    S:DEV:W:A:ADD:A:S:DEV:R:A:DATA:A:...P
//
//Algorithm-
//The design consist of a start and stop bit detector, a serial to
//parallel shift register, a read write control. Serial to parallel
//conversion begin when the start bit is detected, upon which all
//necessary data are initialized. 
//into an external RAM in a 9 bit wide format. The 9th bit is output as
//This I2C traffic logger works best with Clk 5 to 10MHz. The I2C
//clock speed from 30KHz to 180KHz
`timescale 10ns/100ps
module 		I2CLog(Clk,SDA,SCL,Rst,Ce,Oe,We,ACK,Dout,Current_addr);
input 		Clk,Rst,SDA,SCL;
output   	Ce,Oe,We,ACK;
output[7:0]     Dout;
output[14:0]    Current_addr;
wire		Start,Stop,SDA,SCL,RW,ACK,Clk,Rst,ByteRdy;
wire[8:0] 	Byte;
I2C        	ModStSp(Clk,SCL,SDA,Start,Stop,Rst);
Serial2Byte 	ModSerial2Byte(SCL,SDA,RW,Start,Rst,Byte,ACK,ByteRdy);
ByteWr2Ram  	ModByteWr(Clk,SCL,Rst,ByteRdy,Oe,We,Ce,Byte,Dout,ACK,Current_addr);
RWCtrl          ModRW(Clk,Start,Stop,Rst,RW); 
endmodule 

//StartStop verilog code generates a start pulse on posedge of
//I2C start bit, and a stop pulse on the posedge of I2C stop bit. 
//The pulse width is about 2 clock cycles and varies slightly
//due to asynchronous timing of start and stop bits
//This design is verified on I2C bus such as Atmel eproms
//to detect start and stop bit up to 200KHz bus rate
//The propagation delays from the edge of the I2C start and
//stop bits to the leading edge of the Start/Stop pulse is ~10nS
//Note implementation on C4000 Xilinx have to choose the global
//clocks for the SDA and SCL pins. Only P13,P35,P10,P72,P78 work
//in the XS40 board. Typical implementation: SCL=P10,SDA=P35,Start=P27
//Stop=P28,ResetPON=P44(from Xport control)
module StartTrigger(SCL,SDA,Start,Reset);
	input SCL,SDA,Reset;
	output Start;
	wire   Din;
	wire   SCL;
	DlatchNeg   StLatch(Reset,SDA,SCL,Start);
endmodule
module StopTrigger(SCL,SDA,Start,Reset);
	input SCL,SDA,Reset;
	output Start;
	wire   Din;
	wire   SCL;
	DlatchPos   SpLatch(Reset,SDA,SCL,Start);
endmodule
module DlatchNeg(Reset,Clk,Din,Q);
	input Reset,Clk,Din;
	output   Q;
	reg Q;
	always @(negedge Clk or posedge Reset)
		if (Reset) 
			Q=1'b0;
		else
			Q=Din;
endmodule
module DlatchPos(Reset,Clk,Din,Q);
	input Reset,Clk,Din;
	output   Q;
	reg Q;
	always @(posedge Clk or posedge Reset)
		if (Reset) 
			Q=1'b0;
		else
			Q=Din;
endmodule
module I2CStart(Clk,SCL,SDA,Start,ResetPON);
        input   Clk,SCL,SDA,ResetPON;
        output  Start;
        reg	[1:0]	StState_reg,StNext_state;
        wire    Clk,Start,Reset,SCL,SDA;
        reg     RstStart,ResetPON;

parameter	StReset_state   = 2'b00;
parameter	PulseStart_state  = 2'b01;
parameter       PulseOff_state  = 2'b10;
assign          Reset= (RstStart || ResetPON);
StartTrigger   ModStart(SCL,SDA,Start,Reset);       
always @(posedge ResetPON or posedge Clk)
	if (ResetPON == 1) 
	begin
	        StState_reg <= StReset_state;
    	        end
 	   else 
 	   begin
 	   	StState_reg <= StNext_state;
 	  end
always @(StState_reg or Clk) 
		case (StState_reg)	
			StReset_state:
			if (Start == 1)
				begin
					StNext_state <=PulseStart_state;  
					RstStart=0;
				end
			else
				begin
			                RstStart=0;
			                StNext_state <= StReset_state; 
				 end
		   	PulseStart_state:
			begin
				RstStart=0;
				StNext_state <= PulseOff_state;
			end
			PulseOff_state:
			 begin
			        RstStart=1;
			        StNext_state <= StReset_state; 
			        end
			default: StNext_state <= StReset_state;	  
			endcase	 
 			
endmodule
module I2CStop(Clk,SCL,SDA,Stop,ResetPON);
        input   Clk,SCL,SDA,ResetPON;
        output  Stop;
        reg	[1:0]	SpState_reg,SpNext_state;
        wire    Clk,Stop,Reset,SCL,SDA;
        reg     RstStop,ResetPON;

parameter	SpReset_state   = 2'b00;
parameter	PulseStop_state  = 2'b01;
parameter       PulseOffStop_state  = 2'b10;
assign          Reset= (RstStop || ResetPON);
StopTrigger   ModStop(SCL,SDA,Stop,Reset);       
always @(posedge ResetPON or posedge Clk)
	if (ResetPON == 1) 
	begin
	        SpState_reg <= SpReset_state;
    	        end
 	   else 
 	   begin
 	   	SpState_reg <= SpNext_state;
 	  end
always @(SpState_reg or Clk) 
		case (SpState_reg)	
			SpReset_state:
			if (Stop == 1)
				begin
					SpNext_state <=PulseStop_state;  
					RstStop=0;
				end
			else
				begin
			                RstStop=0;
			                SpNext_state <= SpReset_state; 
				 end
		   	PulseStop_state:
			begin
				RstStop=0;
				SpNext_state <= PulseOffStop_state;
			end
			PulseOffStop_state:
			 begin
			        RstStop=1;
			        SpNext_state <= SpReset_state; 
			        end
			default: SpNext_state <= SpReset_state;	  
			endcase	 
 			
endmodule
module I2C(Clk,SCL,SDA,Start,Stop,ResetPON);
        input   Clk,SCL,SDA,ResetPON;
        output  Start,Stop;
        reg     SCL,SDA,ResetPON;
        wire    Clk;
I2CStop   mod1(Clk,SCL,SDA,Stop,ResetPON);
I2CStart  mod2(Clk,SCL,SDA,Start,ResetPON);
endmodule        

//Serial to parallel conversion module. 
//This module converts the serial SDA bits into a 9 bit
//byte format with the 9th bit as ACK. Conversion commences
//and ends with asserting and de-asserting the input Start
//signal. The Start behaves like a reset where the output byte is
//initialized to 0, and bit count is set to 0, and handshake ByteRdy
//is reseted to 0. ByteRdy is asserted every 9th cycle
                 
module         Serial2Byte (SCL,SDA,RW,Start,Reset,Byte,ACK,ByteRdy);
input          SCL,SDA,RW,Start,Reset;
output[8:0]    Byte;
output         ACK,ByteRdy;
reg[8:0]       Byte;
reg            ByteRdy;
wire	       RWInv,RstSerial;
reg[3:0]       COUNT;
reg[1:0]       state_reg,next_state;
parameter      reset_state='b00;
parameter      start_state='b01;
parameter      stop_state ='b10;
assign 	       RWInv=~RW;
assign	       RstSerial=Reset||Start;	
always @(posedge SCL or posedge RstSerial or posedge RWInv)
	begin
   		if (RstSerial)
	   		begin
	      			COUNT = 4'b0;
	      			ByteRdy =0;
	      			Byte = 9'b0;
	      		end
	      	else if (RWInv)
   		  	 begin
	    			COUNT=4'b0;
	    			ByteRdy =0;
	    			Byte=9'b0;
	    		 end
	    		 else
	   		begin
	      			Byte = {Byte[7:0],SDA};	
	      			COUNT = COUNT + 1;
	      			if (COUNT==9)
  			 		begin
   						ByteRdy =1;
   						COUNT =0;   
   			 		end 
   			 		else
   			 			ByteRdy=0;  
			end		  	
	end
endmodule  
          
//Write to Ram
//A repeated read2 and write2 is added to give longer valid write time                          
module 		ByteWr2Ram(Clk,SCL,Rst,ByteRdy,Oe,We,Ce,Din,Dout,ACK,Current_addr);
input    	Clk,SCL,Rst,ByteRdy;
input[8:0]      Din;
output[7:0]     Dout;
output[14:0]    Current_addr;
output  	Oe,Ce,We,ACK;
reg             Oe,Ce,We; 
reg             RstByteRdy,ByteRdyOut,ACK;
wire            Din1,Rst;
reg[7:0]        Dout;
reg[14:0]  	Current_addr,Next_addr;
reg[7:0]   	Current_data,Next_data;
reg[2:0]	state_reg,next_state;
assign          Din1='b1;
parameter	reset_state   = 3'b000;
parameter	load_state    = 3'b001;
parameter  	write1_state   = 3'b010;
parameter       write2_state   = 3'b011;
parameter       read1_state    = 3'b100;
parameter       read2_state    = 3'b101;
DFF             Mod1(ByteRdy,RstByteRdy,Din1,ByteRdyOut);
	always @(posedge Clk or posedge Rst)
	   if (Rst)
		 	state_reg = reset_state;
		 else
 			state_reg = next_state;
 	always @(posedge Clk)			
 		case (state_reg)	
			reset_state:
			begin 
			   if (Rst)
			   begin
			        next_state =reset_state;	
			        Next_addr  ='h0000;
			        Current_addr ='h0000;
			        Dout       ='b00000000;
			        Oe         =1;
				We         =1;
				Ce         =1;
				RstByteRdy =1;
			        end
			    else
			        begin
				next_state =load_state;
				RstByteRdy =0;
				end
			end
			
		        load_state:
		       
		        if (ByteRdyOut)
		              begin
			   	Oe =1;
			   	We =1;
			   	Ce =0;
			   	Current_addr =Next_addr;
			   	next_state  = write1_state;
			   	Dout[7:0] =Din[8:1];
			   	ACK = Din[0];
			   	RstByteRdy =0;
			 	end 
			 	else
			 	begin
			 	next_state =load_state;
			 	Current_addr =Next_addr;
			 	end
			write1_state:
			begin
				We =0;
				Oe =1;
				Ce =0;
				next_state = write2_state;
				RstByteRdy =1;
				end
			write2_state:
			begin
			        We=0;
			        Oe=1;
			        Ce=0;
			        RstByteRdy =0;	
			        next_state = read1_state;
			end
		    
			read1_state:
				begin
					We =1;
					Oe =1;
					Ce =0;
					RstByteRdy=0;
					next_state = read2_state;
				end
			read2_state:
				begin
					We=1;
					Oe=1;
					Ce=0;
					next_state = load_state;
					Next_addr =Current_addr+1;
					
				end
			default         next_state = load_state;			
		
		endcase
	endmodule

module DFF(CLK,RESET,DIN,DOUT);
	  input CLK,RESET,DIN;
	  output DOUT;
	  reg DOUT;
	always @(posedge CLK or posedge RESET)
		begin 
      			if (RESET)	  
         			DOUT = 1'b0;
      			else          
         			DOUT = DIN;
		end
endmodule
//This code generates an one short trigger pulse
//when arm=1 at trigger in
//A 3 state machine clocked bythe fast Clk to ensure
//RW signal responds to Start and Stop signal with little delay
//The state machine toggles between start and stop signal to 
//generate the RW output for RAM write.
module    RWCtrl (Clk,Start,Stop,Reset,RW);
input       Clk,Start,Stop,Reset;
output      RW;
wire        Clk; 
reg         RW; 
reg	[2:0]	state_reg,next_state;
parameter	start_state   = 2'b00;
parameter	arming_state  = 2'b01;
parameter	stop_state    = 2'b10;  
always @(posedge Clk or posedge Reset) 
	if (Reset) state_reg <= start_state;
	   else state_reg <= next_state;
always @(state_reg or Start or Stop) 
		case (state_reg)	
			start_state:
			if (Start == 1)
				begin
					next_state <= arming_state;
					RW =1;
				end
			else	
				begin
					RW =0;
					next_state <= start_state; 
				end
			arming_state:
		      if (Stop==1)
		      begin
		                RW=0;
		      		next_state <= start_state;
		      		end
			 else 
				  begin
					RW=1;
					next_state <= arming_state; 
				  end

			default: next_state <= start_state;
		endcase	 
endmodule 
