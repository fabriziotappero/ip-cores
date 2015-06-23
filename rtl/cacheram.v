module cacheram (A,D,Q,WEN,clk);
input [5:0] A;
input [127:0] D;
output reg [127:0] Q;
input clk;
input WEN;
reg [127:0] Mem [63:0];

always @(posedge clk) Q <= Mem[A];
always @(posedge clk) if (WEN ==0) Mem[A] <= D;

endmodule
