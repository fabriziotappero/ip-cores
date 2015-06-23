`timescale 1ns / 1ns
module test_f3m_mult;
reg [193:0] A, B;
reg clk, reset;
wire [193:0] C;
wire done;

f3m_mult uut(
        .A(A), 
        .B(B), 
        .clk(clk), 
        .reset(reset), 
        .C(C),
        .done(done)
);

initial
begin
clk = 0; reset = 0;
#100;

A=194'h8864990666a959a88500249a244495aaa26a2a0194082aa1;
B=194'h116698585aa229805611194a6520151245204aa9114a89200;
@(negedge clk); reset = 1; @(negedge clk); reset = 0;
@(posedge done);
if(C != 194'h100495240850452646608102a691160594240510028916090) begin $display("E!"); $finish; end
#100;
$finish;
end

always #10 clk = ~clk;
endmodule
