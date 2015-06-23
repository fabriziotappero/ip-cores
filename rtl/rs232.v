`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:20:21 05/08/2009 
// Design Name: 
// Module Name:    rs232 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//   original source fpga4fun.com
//
//////////////////////////////////////////////////////////////////////////////////
module rs232(
		clk,
		RST,
		TxD_start, 
		TxD_data, 
		TxD, 
		TxD_busy
    );
input clk, TxD_start;
input [7:0] TxD_data;
input RST;
output TxD, TxD_busy;


parameter ClkFrequency = 50000000; // 50MHz
parameter Baud = 115200;
parameter BaudGeneratorAccWidth = 17;
parameter BaudGeneratorInc = ((Baud<<(BaudGeneratorAccWidth-4))+(ClkFrequency>>5))/(ClkFrequency>>4); 
//(Baud<<BaudGeneratorAccWidth)/ClkFrequency;
//parameter RegisterInputData = 1;	// in RegisterInputData mode, the input doesn't have to stay valid while the character is been transmitted


reg [BaudGeneratorAccWidth:0] BaudGeneratorAcc;

/*always @(posedge clk)
  BaudGeneratorAcc <= BaudGeneratorAcc[BaudGeneratorAccWidth-1:0] + BaudGeneratorInc;
*/
always @(posedge clk) 
     if(TxD_busy) 
	      BaudGeneratorAcc <= BaudGeneratorAcc[BaudGeneratorAccWidth-1:0] + BaudGeneratorInc;
			
			
wire BaudTick = BaudGeneratorAcc[BaudGeneratorAccWidth]; 

// Transmitter state machine
reg [3:0] state;
wire TxD_ready = (state==0);
assign TxD_busy = ~TxD_ready;

//reg [7:0] TxD_dataReg_d;
reg [7:0] TxD_dataReg_q;

always @(posedge clk) 
	if ( RST ) begin
		TxD_dataReg_q <= 8'b0;
	end
	else
	if(TxD_ready & TxD_start) begin
		TxD_dataReg_q <= TxD_data;
	end
	else begin
		TxD_dataReg_q <= TxD_dataReg_q;
	end
	
	
wire [7:0] TxD_dataD = TxD_dataReg_q;

always @(posedge clk)
case(state)
	4'b0000: if(TxD_start) state <= 4'b0001;
	4'b0001: if(BaudTick) state <= 4'b0100;
	4'b0100: if(BaudTick) state <= 4'b1000;  // start
	4'b1000: if(BaudTick) state <= 4'b1001;  // bit 0
	4'b1001: if(BaudTick) state <= 4'b1010;  // bit 1
	4'b1010: if(BaudTick) state <= 4'b1011;  // bit 2
	4'b1011: if(BaudTick) state <= 4'b1100;  // bit 3
	4'b1100: if(BaudTick) state <= 4'b1101;  // bit 4
	4'b1101: if(BaudTick) state <= 4'b1110;  // bit 5
	4'b1110: if(BaudTick) state <= 4'b1111;  // bit 6
	4'b1111: if(BaudTick) state <= 4'b0010;  // bit 7
	4'b0010: if(BaudTick) state <= 4'b0011;  // stop1
	4'b0011: if(BaudTick) state <= 4'b0000;  // stop2
	default: if(BaudTick) state <= 4'b0000;
endcase

// Output mux
reg muxbit;
always @( * )
case(state[2:0])
	3'd0: muxbit <= TxD_dataD[0];
	3'd1: muxbit <= TxD_dataD[1];
	3'd2: muxbit <= TxD_dataD[2];
	3'd3: muxbit <= TxD_dataD[3];
	3'd4: muxbit <= TxD_dataD[4];
	3'd5: muxbit <= TxD_dataD[5];
	3'd6: muxbit <= TxD_dataD[6];
	3'd7: muxbit <= TxD_dataD[7];
endcase

// Put together the start, data and stop bits
reg TxD;
always @(posedge clk) 
	TxD <= (state<4) | (state[3] & muxbit);  // register the output to make it glitch free

endmodule
