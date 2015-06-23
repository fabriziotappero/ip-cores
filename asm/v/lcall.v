
///
/// created by p8051Rom.exe
/// author: Simon Teran (simont@opencores.org)
///
/// source file: D:\verilog\oc8051\test\lcall.hex
/// date: 6.6.02
/// time: 22:01:01
///

module oc8051_rom (rst, clk, addr, ea_int, data1, data2, data3);

parameter INT_ROM_WID= 7;

input rst, clk;
input [15:0] addr;
output ea_int;
output [7:0] data1, data2, data3;
reg [7:0] data1, data2, data3;
reg [7:0] buff [65535:0];
integer i;

wire ea;

assign ea = | addr[15:INT_ROM_WID];
assign ea_int = ! ea;

initial
begin
    for (i=0; i<65536; i=i+1)
      buff [i] = 8'h00;
#2

    buff [16'h00_00] = 8'h75;
    buff [16'h00_01] = 8'h20;
    buff [16'h00_02] = 8'h00;
    buff [16'h00_03] = 8'hD2;
    buff [16'h00_04] = 8'h02;
    buff [16'h00_05] = 8'h12;
    buff [16'h00_06] = 8'h00;
    buff [16'h00_07] = 8'h0E;
    buff [16'h00_08] = 8'h85;
    buff [16'h00_09] = 8'h20;
    buff [16'h00_0a] = 8'h80;
    buff [16'h00_0b] = 8'h02;
    buff [16'h00_0c] = 8'h00;
    buff [16'h00_0d] = 8'h12;
    buff [16'h00_0e] = 8'h75;
    buff [16'h00_0f] = 8'h80;
    buff [16'h00_10] = 8'h0A;
    buff [16'h00_11] = 8'h22;
    buff [16'h00_12] = 8'h00;
    buff [16'h00_13] = 8'h00;
end

always @(posedge clk)
begin
  data1 <= #1 buff [addr];
  data2 <= #1 buff [addr+1];
  data3 <= #1 buff [addr+2];
end

endmodule
