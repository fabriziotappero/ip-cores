
///
/// created by p8051Rom.exe
/// author: Simon Teran (simont@opencores.org)
///
/// source file: D:\verilog\oc8051\test\divmul.hex
/// date: 6.6.02
/// time: 22:00:45
///

module oc8051_rom (rst, clk, addr, ea_int, data1, data2, data3);

parameter INT_ROM_WID= 8;

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
    buff [16'h00_02] = 8'h5B;
    buff [16'h00_03] = 8'h75;
    buff [16'h00_04] = 8'h08;
    buff [16'h00_05] = 8'h00;
    buff [16'h00_06] = 8'h75;
    buff [16'h00_07] = 8'h09;
    buff [16'h00_08] = 8'h86;
    buff [16'h00_09] = 8'h7B;
    buff [16'h00_0a] = 8'h01;
    buff [16'h00_0b] = 8'h7A;
    buff [16'h00_0c] = 8'h00;
    buff [16'h00_0d] = 8'hE4;
    buff [16'h00_0e] = 8'hFF;
    buff [16'h00_0f] = 8'hFE;
    buff [16'h00_10] = 8'h0B;
    buff [16'h00_11] = 8'hBB;
    buff [16'h00_12] = 8'h00;
    buff [16'h00_13] = 8'h01;
    buff [16'h00_14] = 8'h0A;
    buff [16'h00_15] = 8'h0F;
    buff [16'h00_16] = 8'hBF;
    buff [16'h00_17] = 8'h00;
    buff [16'h00_18] = 8'h01;
    buff [16'h00_19] = 8'h0E;
    buff [16'h00_1a] = 8'hEF;
    buff [16'h00_1b] = 8'h64;
    buff [16'h00_1c] = 8'h0C;
    buff [16'h00_1d] = 8'h4E;
    buff [16'h00_1e] = 8'h70;
    buff [16'h00_1f] = 8'hF0;
    buff [16'h00_20] = 8'hAC;
    buff [16'h00_21] = 8'h02;
    buff [16'h00_22] = 8'hAD;
    buff [16'h00_23] = 8'h03;
    buff [16'h00_24] = 8'hAE;
    buff [16'h00_25] = 8'h08;
    buff [16'h00_26] = 8'hAF;
    buff [16'h00_27] = 8'h09;
    buff [16'h00_28] = 8'h12;
    buff [16'h00_29] = 8'h00;
    buff [16'h00_2a] = 8'h7B;
    buff [16'h00_2b] = 8'h8E;
    buff [16'h00_2c] = 8'h0A;
    buff [16'h00_2d] = 8'h8F;
    buff [16'h00_2e] = 8'h0B;
    buff [16'h00_2f] = 8'hAC;
    buff [16'h00_30] = 8'h02;
    buff [16'h00_31] = 8'hAD;
    buff [16'h00_32] = 8'h03;
    buff [16'h00_33] = 8'hAE;
    buff [16'h00_34] = 8'h08;
    buff [16'h00_35] = 8'hAF;
    buff [16'h00_36] = 8'h09;
    buff [16'h00_37] = 8'h12;
    buff [16'h00_38] = 8'h00;
    buff [16'h00_39] = 8'h7B;
    buff [16'h00_3a] = 8'h8C;
    buff [16'h00_3b] = 8'h0C;
    buff [16'h00_3c] = 8'h8D;
    buff [16'h00_3d] = 8'h0D;
    buff [16'h00_3e] = 8'hAC;
    buff [16'h00_3f] = 8'h02;
    buff [16'h00_40] = 8'hAD;
    buff [16'h00_41] = 8'h03;
    buff [16'h00_42] = 8'hAE;
    buff [16'h00_43] = 8'h0A;
    buff [16'h00_44] = 8'hAF;
    buff [16'h00_45] = 8'h0B;
    buff [16'h00_46] = 8'h12;
    buff [16'h00_47] = 8'h00;
    buff [16'h00_48] = 8'h67;
    buff [16'h00_49] = 8'hE5;
    buff [16'h00_4a] = 8'h0D;
    buff [16'h00_4b] = 8'h2F;
    buff [16'h00_4c] = 8'hFF;
    buff [16'h00_4d] = 8'hE5;
    buff [16'h00_4e] = 8'h0C;
    buff [16'h00_4f] = 8'h3E;
    buff [16'h00_50] = 8'h85;
    buff [16'h00_51] = 8'h0B;
    buff [16'h00_52] = 8'h80;
    buff [16'h00_53] = 8'h85;
    buff [16'h00_54] = 8'h0D;
    buff [16'h00_55] = 8'h80;
    buff [16'h00_56] = 8'h8F;
    buff [16'h00_57] = 8'h80;
    buff [16'h00_58] = 8'h80;
    buff [16'h00_59] = 8'hFE;
    buff [16'h00_5a] = 8'h22;
    buff [16'h00_5b] = 8'h78;
    buff [16'h00_5c] = 8'h7F;
    buff [16'h00_5d] = 8'hE4;
    buff [16'h00_5e] = 8'hF6;
    buff [16'h00_5f] = 8'hD8;
    buff [16'h00_60] = 8'hFD;
    buff [16'h00_61] = 8'h75;
    buff [16'h00_62] = 8'h81;
    buff [16'h00_63] = 8'h0D;
    buff [16'h00_64] = 8'h02;
    buff [16'h00_65] = 8'h00;
    buff [16'h00_66] = 8'h03;
    buff [16'h00_67] = 8'hEF;
    buff [16'h00_68] = 8'hF8;
    buff [16'h00_69] = 8'h8D;
    buff [16'h00_6a] = 8'hF0;
    buff [16'h00_6b] = 8'hA4;
    buff [16'h00_6c] = 8'hFF;
    buff [16'h00_6d] = 8'hED;
    buff [16'h00_6e] = 8'hC5;
    buff [16'h00_6f] = 8'hF0;
    buff [16'h00_70] = 8'hCE;
    buff [16'h00_71] = 8'hA4;
    buff [16'h00_72] = 8'h2E;
    buff [16'h00_73] = 8'hFE;
    buff [16'h00_74] = 8'hEC;
    buff [16'h00_75] = 8'h88;
    buff [16'h00_76] = 8'hF0;
    buff [16'h00_77] = 8'hA4;
    buff [16'h00_78] = 8'h2E;
    buff [16'h00_79] = 8'hFE;
    buff [16'h00_7a] = 8'h22;
    buff [16'h00_7b] = 8'hBC;
    buff [16'h00_7c] = 8'h00;
    buff [16'h00_7d] = 8'h0B;
    buff [16'h00_7e] = 8'hBE;
    buff [16'h00_7f] = 8'h00;
    buff [16'h00_80] = 8'h29;
    buff [16'h00_81] = 8'hEF;
    buff [16'h00_82] = 8'h8D;
    buff [16'h00_83] = 8'hF0;
    buff [16'h00_84] = 8'h84;
    buff [16'h00_85] = 8'hFF;
    buff [16'h00_86] = 8'hAD;
    buff [16'h00_87] = 8'hF0;
    buff [16'h00_88] = 8'h22;
    buff [16'h00_89] = 8'hE4;
    buff [16'h00_8a] = 8'hCC;
    buff [16'h00_8b] = 8'hF8;
    buff [16'h00_8c] = 8'h75;
    buff [16'h00_8d] = 8'hF0;
    buff [16'h00_8e] = 8'h08;
    buff [16'h00_8f] = 8'hEF;
    buff [16'h00_90] = 8'h2F;
    buff [16'h00_91] = 8'hFF;
    buff [16'h00_92] = 8'hEE;
    buff [16'h00_93] = 8'h33;
    buff [16'h00_94] = 8'hFE;
    buff [16'h00_95] = 8'hEC;
    buff [16'h00_96] = 8'h33;
    buff [16'h00_97] = 8'hFC;
    buff [16'h00_98] = 8'hEE;
    buff [16'h00_99] = 8'h9D;
    buff [16'h00_9a] = 8'hEC;
    buff [16'h00_9b] = 8'h98;
    buff [16'h00_9c] = 8'h40;
    buff [16'h00_9d] = 8'h05;
    buff [16'h00_9e] = 8'hFC;
    buff [16'h00_9f] = 8'hEE;
    buff [16'h00_a0] = 8'h9D;
    buff [16'h00_a1] = 8'hFE;
    buff [16'h00_a2] = 8'h0F;
    buff [16'h00_a3] = 8'hD5;
    buff [16'h00_a4] = 8'hF0;
    buff [16'h00_a5] = 8'hE9;
    buff [16'h00_a6] = 8'hE4;
    buff [16'h00_a7] = 8'hCE;
    buff [16'h00_a8] = 8'hFD;
    buff [16'h00_a9] = 8'h22;
    buff [16'h00_aa] = 8'hED;
    buff [16'h00_ab] = 8'hF8;
    buff [16'h00_ac] = 8'hF5;
    buff [16'h00_ad] = 8'hF0;
    buff [16'h00_ae] = 8'hEE;
    buff [16'h00_af] = 8'h84;
    buff [16'h00_b0] = 8'h20;
    buff [16'h00_b1] = 8'hD2;
    buff [16'h00_b2] = 8'h1C;
    buff [16'h00_b3] = 8'hFE;
    buff [16'h00_b4] = 8'hAD;
    buff [16'h00_b5] = 8'hF0;
    buff [16'h00_b6] = 8'h75;
    buff [16'h00_b7] = 8'hF0;
    buff [16'h00_b8] = 8'h08;
    buff [16'h00_b9] = 8'hEF;
    buff [16'h00_ba] = 8'h2F;
    buff [16'h00_bb] = 8'hFF;
    buff [16'h00_bc] = 8'hED;
    buff [16'h00_bd] = 8'h33;
    buff [16'h00_be] = 8'hFD;
    buff [16'h00_bf] = 8'h40;
    buff [16'h00_c0] = 8'h07;
    buff [16'h00_c1] = 8'h98;
    buff [16'h00_c2] = 8'h50;
    buff [16'h00_c3] = 8'h06;
    buff [16'h00_c4] = 8'hD5;
    buff [16'h00_c5] = 8'hF0;
    buff [16'h00_c6] = 8'hF2;
    buff [16'h00_c7] = 8'h22;
    buff [16'h00_c8] = 8'hC3;
    buff [16'h00_c9] = 8'h98;
    buff [16'h00_ca] = 8'hFD;
    buff [16'h00_cb] = 8'h0F;
    buff [16'h00_cc] = 8'hD5;
    buff [16'h00_cd] = 8'hF0;
    buff [16'h00_ce] = 8'hEA;
    buff [16'h00_cf] = 8'h22;
end

always @(posedge clk)
begin
  data1 <= #1 buff [addr];
  data2 <= #1 buff [addr+1];
  data3 <= #1 buff [addr+2];
end

endmodule
