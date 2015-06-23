/* verilator lint_off UNUSED */
/* verilator lint_off CASEX */
module extrom(clk,A,Q);

output [31:0] Q;
input clk;
input [31:0] A;

reg    [7:0] Mem1 [255:0];
reg    [7:0] Mem2 [255:0];
reg    [7:0] Mem3 [255:0];
reg    [7:0] Mem4 [255:0];
reg   [31:0] Qint;
wire  [7:0] A0;

assign A0 = A[9:2];

initial 
begin
$readmemh("../mem/boot-1.mem" , Mem1 , 0,255);
$readmemh("../mem/boot-2.mem" , Mem2 , 0,255);
$readmemh("../mem/boot-3.mem" , Mem3 , 0,255);
$readmemh("../mem/boot-4.mem" , Mem4 , 0,255);
end

// Read process
always @(posedge clk) Qint[ 7: 0] <= Mem1[A0];
always @(posedge clk) Qint[15: 8] <= Mem2[A0];
always @(posedge clk) Qint[23:16] <= Mem3[A0];
always @(posedge clk) Qint[31:24] <= Mem4[A0];

assign Q = Qint;

  
endmodule
