
///
/// created by oc8051 rom maker
/// author: Simon Teran (simont@opencores.org)
///
/// source file: D:\tmp\asm\xram.hex
/// date: 10.7.02
/// time: 10:36:12
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

    buff [16'h00_00] = 8'h02;
    buff [16'h00_01] = 8'h00;
    buff [16'h00_02] = 8'h35;
    buff [16'h00_03] = 8'h90;
    buff [16'h00_04] = 8'h00;
    buff [16'h00_05] = 8'h00;
    buff [16'h00_06] = 8'h74;
    buff [16'h00_07] = 8'h01;
    buff [16'h00_08] = 8'hF0;
    buff [16'h00_09] = 8'hFF;
    buff [16'h00_0a] = 8'h7E;
    buff [16'h00_0b] = 8'h00;
    buff [16'h00_0c] = 8'h74;
    buff [16'h00_0d] = 8'hFF;
    buff [16'h00_0e] = 8'h2F;
    buff [16'h00_0f] = 8'hF5;
    buff [16'h00_10] = 8'h82;
    buff [16'h00_11] = 8'hEE;
    buff [16'h00_12] = 8'h34;
    buff [16'h00_13] = 8'hFF;
    buff [16'h00_14] = 8'hF5;
    buff [16'h00_15] = 8'h83;
    buff [16'h00_16] = 8'hE0;
    buff [16'h00_17] = 8'h04;
    buff [16'h00_18] = 8'hFD;
    buff [16'h00_19] = 8'h74;
    buff [16'h00_1a] = 8'h00;
    buff [16'h00_1b] = 8'h2F;
    buff [16'h00_1c] = 8'hF5;
    buff [16'h00_1d] = 8'h82;
    buff [16'h00_1e] = 8'hEE;
    buff [16'h00_1f] = 8'h34;
    buff [16'h00_20] = 8'h00;
    buff [16'h00_21] = 8'hF5;
    buff [16'h00_22] = 8'h83;
    buff [16'h00_23] = 8'hED;
    buff [16'h00_24] = 8'hF0;
    buff [16'h00_25] = 8'h0F;
    buff [16'h00_26] = 8'hBF;
    buff [16'h00_27] = 8'h00;
    buff [16'h00_28] = 8'h01;
    buff [16'h00_29] = 8'h0E;
    buff [16'h00_2a] = 8'hE4;
    buff [16'h00_2b] = 8'hB5;
    buff [16'h00_2c] = 8'h07;
    buff [16'h00_2d] = 8'hDE;
    buff [16'h00_2e] = 8'hEE;
    buff [16'h00_2f] = 8'hB4;
    buff [16'h00_30] = 8'h08;
    buff [16'h00_31] = 8'hDA;
    buff [16'h00_32] = 8'h80;
    buff [16'h00_33] = 8'hFE;
    buff [16'h00_34] = 8'h22;
    buff [16'h00_35] = 8'h78;
    buff [16'h00_36] = 8'h7F;
    buff [16'h00_37] = 8'hE4;
    buff [16'h00_38] = 8'hF6;
    buff [16'h00_39] = 8'hD8;
    buff [16'h00_3a] = 8'hFD;
    buff [16'h00_3b] = 8'h75;
    buff [16'h00_3c] = 8'h81;
    buff [16'h00_3d] = 8'h07;
    buff [16'h00_3e] = 8'h02;
    buff [16'h00_3f] = 8'h00;
    buff [16'h00_40] = 8'h03;
end

always @(posedge clk)
begin
  data1 <= #1 buff [addr];
  data2 <= #1 buff [addr+1];
  data3 <= #1 buff [addr+2];
end

endmodule
