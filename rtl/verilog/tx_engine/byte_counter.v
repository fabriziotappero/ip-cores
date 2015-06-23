module byte_count_module(CLK, RESET, START, BYTE_COUNTER);

// Ports declaration
input CLK;
input RESET;
input START;



output [15:0] BYTE_COUNTER;

reg [15:0] BYTE_COUNTER;
reg [15:0] counter;

always @(posedge CLK or posedge RESET)
begin
   if (RESET == 1) begin
	   counter = 16'h0000;
   end
   // the ack is delayed which starts the counter
   else if (START == 1) begin
       counter = counter + 8;
   end
end

always @(posedge CLK)
begin
   BYTE_COUNTER = counter;
end

endmodule // End of Module 

