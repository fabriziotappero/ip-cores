module ack_counter (
clock , // 156 MHz clock
reset , // active high, asynchronous Reset input
ready,
tx_start , // Active high tx_start signal for counter
max_count, //16 bit reg for the maximum count to generate the ack signal
tx_ack	// Active high signal
);

// Ports declaration
input clock;
input reset;
input ready;
input tx_start;
input [15:0] max_count;

output tx_ack;

// Wire connections
//Input
wire clock;
wire reset;
wire ready;
wire tx_start;
wire [15:0] max_count;

//Output
reg tx_ack;



//Internal wires
reg start_count;
reg start_count_del;
reg [15:0] counter;


always @ (reset or tx_start or counter or max_count)
begin 

  if (reset) begin
    start_count <= 0;
  end

  else if (tx_start) begin
    start_count <= 1;
  end

  else if ((counter == max_count) & !ready) begin  //& !ready
    start_count <= 0;
  end

end 


always @ (posedge clock or posedge reset)
begin 

  if (reset) begin
    counter <= 0;
  end
  
  else if (counter == max_count) begin
    counter <= 0;
  end

  else if (start_count) begin
    counter <= counter + 1;
  end

end 


always @ (posedge clock or posedge reset)
begin 

  if (reset) begin
    start_count_del <= 0;
    tx_ack <= 0;
  end
  else begin
    start_count_del <= start_count;
    tx_ack <= ~start_count & start_count_del;
  end

end 

endmodule // End of Module 

