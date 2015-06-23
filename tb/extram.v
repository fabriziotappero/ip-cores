/* verilator lint_off UNUSED */
/* verilator lint_off CASEX */
module extram(clk,DB,A,UB,LB,WEN,OE);

input clk;
input [23:0] A;
inout [15:0] DB;
input        UB,LB;
input        WEN;
input        OE;

reg    [7:0] Mem1 [(4096*1024-1):0];
reg    [7:0] Mem2 [(4096*1024-1):0];
reg    [7:0] Mem3 [(4096*1024-1):0];
reg    [7:0] Mem4 [(4096*1024-1):0];

wire  [21:0] A0;
reg   [21:0] k;
reg          A1r;
reg   [31:0] Qint;

assign A0 = A[23:2];

initial 
begin
$display ("init ram...");
for (k = 0; k < (4096*1024-1); k = k + 1)
begin
    Mem1[k] = 255;
    Mem2[k] = 255;
    Mem3[k] = 255;
    Mem4[k] = 255;
end
$display ("filled ram(s)...");

$readmemh("/home/leo/cpu/mem/vmlinux-1.mem", Mem1 , 32'h0100000/4);
$readmemh("/home/leo/cpu/mem/vmlinux-2.mem", Mem2 , 32'h0100000/4);
$readmemh("/home/leo/cpu/mem/vmlinux-3.mem", Mem3 , 32'h0100000/4);
$readmemh("/home/leo/cpu/mem/vmlinux-4.mem", Mem4 , 32'h0100000/4);


$readmemh("/home/leo/cpu/mem/root-1.mem" , Mem1 , 32'h0400000/4);
$readmemh("/home/leo/cpu/mem/root-2.mem" , Mem2 , 32'h0400000/4);
$readmemh("/home/leo/cpu/mem/root-3.mem" , Mem3 , 32'h0400000/4);
$readmemh("/home/leo/cpu/mem/root-4.mem" , Mem4 , 32'h0400000/4);

end

// Read process
always @(posedge clk) Qint[ 7: 0] <= Mem1[A0];
always @(posedge clk) Qint[15: 8] <= Mem2[A0];
always @(posedge clk) Qint[23:16] <= Mem3[A0];
always @(posedge clk) Qint[31:24] <= Mem4[A0];
always @(posedge clk) A1r <= A[1];
assign DB = OE ? 16'bz :
            A1r ? Qint[31:16] : Qint[15:0];
  
// Write Process  
always @(posedge clk) if ((WEN == 0) && (LB==0) &&(A[1]==0)) Mem1[A0] <= DB[ 7: 0];
always @(posedge clk) if ((WEN == 0) && (UB==0) &&(A[1]==0)) Mem2[A0] <= DB[15: 8];

always @(posedge clk) if ((WEN == 0) && (LB==0) &&(A[1]==1)) Mem3[A0] <= DB[ 7: 0];
always @(posedge clk) if ((WEN == 0) && (UB==0) &&(A[1]==1)) Mem4[A0] <= DB[15: 8];

endmodule
