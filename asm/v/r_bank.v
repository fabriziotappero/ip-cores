
///
/// created by oc8051 rom maker
/// author: Simon Teran (simont@opencores.org)
///
/// source file: D:\tmp\asm\TEMP\r_bank.hex
/// date: 15.7.02
/// time: 21:28:31
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

    buff [16'h00_00] = 8'h85;
    buff [16'h00_01] = 8'hD0;
    buff [16'h00_02] = 8'h90;
    buff [16'h00_03] = 8'h00;
    buff [16'h00_04] = 8'h00;
    buff [16'h00_05] = 8'h01;
    buff [16'h00_06] = 8'h03;
    buff [16'h00_07] = 8'hE4;
    buff [16'h00_08] = 8'hF8;
    buff [16'h00_09] = 8'h7C;
    buff [16'h00_0a] = 8'h40;
    buff [16'h00_0b] = 8'h75;
    buff [16'h00_0c] = 8'hD0;
    buff [16'h00_0d] = 8'h08;
    buff [16'h00_0e] = 8'h78;
    buff [16'h00_0f] = 8'h01;
    buff [16'h00_10] = 8'h7C;
    buff [16'h00_11] = 8'h41;
    buff [16'h00_12] = 8'h75;
    buff [16'h00_13] = 8'hD0;
    buff [16'h00_14] = 8'h10;
    buff [16'h00_15] = 8'h78;
    buff [16'h00_16] = 8'h02;
    buff [16'h00_17] = 8'h7C;
    buff [16'h00_18] = 8'h42;
    buff [16'h00_19] = 8'h75;
    buff [16'h00_1a] = 8'hD0;
    buff [16'h00_1b] = 8'h18;
    buff [16'h00_1c] = 8'h78;
    buff [16'h00_1d] = 8'h03;
    buff [16'h00_1e] = 8'h7C;
    buff [16'h00_1f] = 8'h43;
    buff [16'h00_20] = 8'h75;
    buff [16'h00_21] = 8'h80;
    buff [16'h00_22] = 8'h00;
    buff [16'h00_23] = 8'h75;
    buff [16'h00_24] = 8'hD0;
    buff [16'h00_25] = 8'h10;
    buff [16'h00_26] = 8'hE8;
    buff [16'h00_27] = 8'h94;
    buff [16'h00_28] = 8'h02;
    buff [16'h00_29] = 8'h70;
    buff [16'h00_2a] = 8'hD5;
    buff [16'h00_2b] = 8'hEC;
    buff [16'h00_2c] = 8'h94;
    buff [16'h00_2d] = 8'h42;
    buff [16'h00_2e] = 8'h70;
    buff [16'h00_2f] = 8'hD0;
    buff [16'h00_30] = 8'h75;
    buff [16'h00_31] = 8'h80;
    buff [16'h00_32] = 8'h01;
    buff [16'h00_33] = 8'h75;
    buff [16'h00_34] = 8'hD0;
    buff [16'h00_35] = 8'h08;
    buff [16'h00_36] = 8'hE8;
    buff [16'h00_37] = 8'h94;
    buff [16'h00_38] = 8'h01;
    buff [16'h00_39] = 8'h70;
    buff [16'h00_3a] = 8'hC5;
    buff [16'h00_3b] = 8'hEC;
    buff [16'h00_3c] = 8'h94;
    buff [16'h00_3d] = 8'h41;
    buff [16'h00_3e] = 8'h70;
    buff [16'h00_3f] = 8'hC0;
    buff [16'h00_40] = 8'h75;
    buff [16'h00_41] = 8'h80;
    buff [16'h00_42] = 8'h02;
    buff [16'h00_43] = 8'h75;
    buff [16'h00_44] = 8'hD0;
    buff [16'h00_45] = 8'h18;
    buff [16'h00_46] = 8'hE8;
    buff [16'h00_47] = 8'h94;
    buff [16'h00_48] = 8'h03;
    buff [16'h00_49] = 8'h70;
    buff [16'h00_4a] = 8'hB5;
    buff [16'h00_4b] = 8'hEC;
    buff [16'h00_4c] = 8'h94;
    buff [16'h00_4d] = 8'h43;
    buff [16'h00_4e] = 8'h70;
    buff [16'h00_4f] = 8'hB0;
    buff [16'h00_50] = 8'h75;
    buff [16'h00_51] = 8'h80;
    buff [16'h00_52] = 8'h03;
    buff [16'h00_53] = 8'h75;
    buff [16'h00_54] = 8'hD0;
    buff [16'h00_55] = 8'h10;
    buff [16'h00_56] = 8'hE8;
    buff [16'h00_57] = 8'h70;
    buff [16'h00_58] = 8'hA7;
    buff [16'h00_59] = 8'hEC;
    buff [16'h00_5a] = 8'h94;
    buff [16'h00_5b] = 8'h04;
    buff [16'h00_5c] = 8'h70;
    buff [16'h00_5d] = 8'hA2;
    buff [16'h00_5e] = 8'h75;
    buff [16'h00_5f] = 8'h80;
    buff [16'h00_60] = 8'h04;
end

always @(posedge clk)
begin
  data1 <= #1 buff [addr];
  data2 <= #1 buff [addr+1];
  data3 <= #1 buff [addr+2];
end

endmodule
