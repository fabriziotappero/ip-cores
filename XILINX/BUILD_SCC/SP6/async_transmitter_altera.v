module async_transmitter(clk, TxD_start, TxD_data, TxD, TxD_busy);
input clk, TxD_start;
input [7:0] TxD_data;
output TxD, TxD_busy;

//parameter ClkFrequency = 62500000; // 60MHz
parameter ClkFrequency = 20000000; // 50MHz
//parameter ClkFrequency = 27000000; // 27MHz
parameter Baud = 115200;

// Baud generator
parameter BaudGeneratorAccWidth = 16;
parameter BaudGeneratorInc = ((Baud<<(BaudGeneratorAccWidth-4))+(ClkFrequency>>5))/(ClkFrequency>>4);
reg [BaudGeneratorAccWidth:0] BaudGeneratorAcc;
wire BaudTick = BaudGeneratorAcc[BaudGeneratorAccWidth];
wire TxD_busy;
always @(posedge clk) if(TxD_busy) BaudGeneratorAcc <= BaudGeneratorAcc[BaudGeneratorAccWidth-1:0] + BaudGeneratorInc;

// Transmitter state machine
reg [3:0] state;
assign TxD_busy = (state!=0);

always @(posedge clk)
case(state)
  4'b0000: if(TxD_start) state <= 4'b0100;
  4'b0100: if(BaudTick) state <= 4'b1000;  // start
  4'b1000: if(BaudTick) state <= 4'b1001;  // bit 0
  4'b1001: if(BaudTick) state <= 4'b1010;  // bit 1
  4'b1010: if(BaudTick) state <= 4'b1011;  // bit 2
  4'b1011: if(BaudTick) state <= 4'b1100;  // bit 3
  4'b1100: if(BaudTick) state <= 4'b1101;  // bit 4
  4'b1101: if(BaudTick) state <= 4'b1110;  // bit 5
  4'b1110: if(BaudTick) state <= 4'b1111;  // bit 6
  4'b1111: if(BaudTick) state <= 4'b0001;  // bit 7
  4'b0001: if(BaudTick) state <= 4'b0010;  // stop1
  4'b0010: if(BaudTick) state <= 4'b0000;  // stop2
  default: if(BaudTick) state <= 4'b0000;
endcase

// Output mux
reg muxbit;
always @(state[2:0] or TxD_data)
case(state[2:0])
  0: muxbit <= TxD_data[0];
  1: muxbit <= TxD_data[1];
  2: muxbit <= TxD_data[2];
  3: muxbit <= TxD_data[3];
  4: muxbit <= TxD_data[4];
  5: muxbit <= TxD_data[5];
  6: muxbit <= TxD_data[6];
  7: muxbit <= TxD_data[7];
endcase

// Put together the start, data and stop bits
reg TxD;
always @(posedge clk) TxD <= (state<4) | (state[3] & muxbit);  // register the output to make it glitch free

endmodule
