/* verilator lint_off UNUSED */
/* verilator lint_off CASEX */
module extrom(clk,rstn,D,A,Q,WEN_BE,req_ram,ack_ram);

output [15:0] Q;
input clk,rstn;
input [31:0] A;
input [15:0] D;
input [1:0] WEN_BE;
input req_ram;
output ack_ram;

reg    [7:0] Mem1 [255:0];
reg    [7:0] Mem2 [255:0];
reg    [7:0] Mem3 [255:0];
reg    [7:0] Mem4 [255:0];
reg          A1r;
reg   [31:0] Qint;
wire [7:0] A0;

assign A0 = A[9:2];

reg    [5:0] dly_reg;

assign ack_ram = dly_reg[0];

initial 
begin
$readmemh("/home/leo/cpu/mem/boot-1.mem" , Mem1 , 0,255);
$readmemh("/home/leo/cpu/mem/boot-2.mem" , Mem2 , 0,255);
$readmemh("/home/leo/cpu/mem/boot-3.mem" , Mem3 , 0,255);
$readmemh("/home/leo/cpu/mem/boot-4.mem" , Mem4 , 0,255);
end

always @(posedge clk or negedge rstn) 
 if (rstn == 0) dly_reg <=  0;
           else if (req_ram == 0) dly_reg <=0; else dly_reg <= {dly_reg[4:0],req_ram};

// Read process
always @(posedge clk) Qint[ 7: 0] <= Mem1[A0];
always @(posedge clk) Qint[15: 8] <= Mem2[A0];
always @(posedge clk) Qint[23:16] <= Mem3[A0];
always @(posedge clk) Qint[31:24] <= Mem4[A0];
always @(posedge clk) A1r <= A[1];
assign Q = A1r ? Qint[31:16] : Qint[15:0];

  
endmodule
