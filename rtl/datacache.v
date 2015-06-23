/* verilator lint_off UNUSED */
/* verilator lint_off CASEX */
/* verilator lint_off PINNOCONNECT */
/* verilator lint_off PINMISSING */
/* verilator lint_off IMPLICIT */
/* verilator lint_off WIDTH */
/* verilator lint_off CASEINCOMPLETE */
/* verilator lint_off COMBDLY */

module datacache (A,D,Q,WEN,clk);
input [10:0] A;
input [31:0] D;
output reg [31:0] Q;
input clk;
input WEN;
reg [31:0] Mem [2047:0];

always @(posedge clk) Q <= Mem[A];
always @(posedge clk) if (WEN ==0) Mem[A] <= D;

endmodule
