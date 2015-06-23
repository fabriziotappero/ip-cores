`timescale 1ns / 1ns
/*********************************************************************************************/
module cic_i_tb();
/*********************************************************************************************/
//TB example: impulse responce
/*********************************************************************************************/
localparam dw = 10;
localparam m = 4;
localparam r = 4;
localparam g = 1;
/*********************************************************************************************/
reg clk;
reg reset_n;
reg signed [dw-1:0] data_in;
wire in_dv;
reg [$clog2(r)-1:0] counter;
wire signed [dw+$clog2((r**(m))/r)-1:0] data_out;
/*********************************************************************************************/
initial begin : clk_gen
    clk <= 1'b0;
    #5 forever #5 clk <= ~clk;
end
/*********************************************************************************************/
initial begin : reset_gen
    $display($time, " << Starting the Simulation >>");
    reset_n = 1'b0;
    data_in = '0;
    repeat (2) @(negedge clk);
    $display($time, " << Coming out of reset >>");
    reset_n = 1'b1;
    repeat(3) @(posedge clk);
    data_in = 2**(dw-1)-1;
    @(posedge clk);
    data_in = '0;
end
/*********************************************************************************************/
assign in_dv = &counter;
/*********************************************************************************************/
always @(posedge clk)
begin
    if (!reset_n)
        counter = '0;
    else
        counter++;
end
/*********************************************************************************************/
cic_i #(dw, r, m, g) dut1
(
    .clk(clk),
    .reset_n(reset_n),
    .data_in(data_in),
    .in_dv(in_dv),
    .data_out(data_out)
);
/*********************************************************************************************/
endmodule
