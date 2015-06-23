`include "TransmitTop.v"
module TransmitTopPause_tb();

//Input from user logic
reg [63:0] TX_DATA;
reg [63:0] TX_DATA_int;
reg [7:0] TX_DATA_VALID; // To accept the data valid to be available
reg Append_last_bit;
reg TX_CLK;
reg RESET;
reg TX_START; // This signify the first frame of data
reg TX_UNDERRUN; // this will cause an error to be injected into the data
reg [7:0] TX_IFG_DELAY; // this will cause a delay in the ack signal

//input to transmit fault signals
reg RXTXLINKFAULT;
reg LOCALLINKFAULT;
reg [15:0] FC_TRANS_PAUSEDATA; //pause frame data
reg FC_TRANS_PAUSEVAL; //pulse signal to indicate a pause frame to be sent

//apply pause timing
reg [15:0] FC_TX_PAUSEDATA;
reg FC_TX_PAUSEVALID;

//apply configuration value
reg [31:0] TX_CFG_REG_VALUE;
reg TX_CFG_REG_VALID;

//output to stat register
wire TX_STATS_VALID;
wire [9:0] TXSTATREGPLUS; // a pulse for each reg for stats
wire [63:0] TXD;
wire [7:0] TXC;
wire TX_ACK;
reg D_START;

reg START_TX_BITS;

// Initialize all variables
initial begin        
  Append_last_bit = 0;
  TX_CLK = 1;       // initial value of clock
  RESET <= 0;       // initial value of reset
  TX_START <= 0;      // initial value of enable
  TX_DATA_VALID <= 8'h00;
  D_START = 0;
  FC_TX_PAUSEVALID <= 0;
  FC_TX_PAUSEDATA <= 0;
  FC_TRANS_PAUSEDATA <= 0;
  FC_TRANS_PAUSEVAL <= 0;
  TX_UNDERRUN = 0;
  #5 RESET <= 1;    // Assert the reset
  #10 RESET <= 0;    // De-assert the reset 

  #15 //TX_START <= 1;
      //TX_DATA_VALID <= 8'hFF;
	//D_START <= 1;
  #20 TX_START <= 0;
  #400 	//TX_DATA_VALID <= 8'h00;
        //FC_TX_PAUSEVALID <= 1;
        //FC_TX_PAUSEDATA <= 30;
          FC_TRANS_PAUSEDATA <= 30;
          FC_TRANS_PAUSEVAL <= 1;
	 //TX_DATA_VALID <= 8'h7f;
  #10 	TX_DATA_VALID <= 8'h00;
		D_START = 0;
        //FC_TX_PAUSEVALID <= 0;
        //FC_TX_PAUSEDATA <= 0;
          FC_TRANS_PAUSEDATA <= 0;
  	  FC_TRANS_PAUSEVAL <= 0;
  #20 //TX_START <= 1;
      //TX_DATA_VALID <= 8'hFF;
	//D_START = 1;
  #20 TX_START <= 0;
  #400 	TX_DATA_VALID <= 8'h00;
  #10 	TX_DATA_VALID <= 8'h00;
		D_START = 0;
  #1300 $finish;     // Terminate simulation
end

always @(posedge D_START or posedge TX_CLK)
begin
  if (D_START == 0) begin
    TX_DATA = 64'h0000000000000000;
  end
  //else if (TX_DATA_VALID == 8'h07) begin
  //  TX_DATA = 64'h000000000077FFCC;
  //end
  else if (Append_last_bit == 1) begin
//    TX_DATA = 64'h202020202077FFCC;
    TX_DATA = 64'h000000000077FFCC;
  end
  else if (START_TX_BITS == 1) begin
    TX_DATA = TX_DATA + 1;
  end
  else begin
    TX_DATA = 64'h0000000000000001;
  end
end



always @(TX_DATA)
begin
  if (TX_DATA == 2) begin
     TX_DATA_int[31:0] <= TX_DATA[31:0];
     TX_DATA_int[47:32] <= 300;
     TX_DATA_int[63:48] <= TX_DATA[63:48];
  end 
  else begin
     TX_DATA_int <= TX_DATA;
  end

end


always @(TX_ACK | TX_START)
begin
  if (TX_ACK) begin
    START_TX_BITS = 1;
  end
  else if (TX_START) begin
    START_TX_BITS = 0;
  end 
end


// Clock generator
always begin
  #5 TX_CLK= ~TX_CLK; // Toggle clock every 5 ticks
end

// Connect DUT to test bench
TRANSMIT_TOP U_top_module (
TX_DATA_int, 
TX_DATA_VALID, 
TX_CLK, 
RESET, 
TX_START, 
TX_ACK, 
TX_UNDERRUN, 
TX_IFG_DELAY,
RXTXLINKFAULT, 
LOCALLINKFAULT,
TX_STATS_VALID,
TXSTATREGPLUS,
TXD, 
TXC, 
FC_TRANS_PAUSEDATA, 
FC_TRANS_PAUSEVAL, 
FC_TX_PAUSEDATA, 
FC_TX_PAUSEVALID,
TX_CFG_REG_VALUE,
TX_CFG_REG_VALID
);




endmodule

