//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 internal program rom                                   ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   internal program rom for 8051 core                         ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2003/06/03 17:09:57  simont
// pipelined acces to axternal instruction interface added.
//
// Revision 1.2  2003/04/03 19:17:19  simont
// add `include "oc8051_defines.v"
//
// Revision 1.1  2003/04/02 11:16:22  simont
// initial inport
//
// Revision 1.4  2002/10/23 17:00:18  simont
// signal es_int=1'b0
//
// Revision 1.3  2002/09/30 17:34:01  simont
// prepared header
//
//
`include "oc8051_defines.v"

module oc8051_rom (rst, clk, addr, ea_int, data_o);

//parameter INT_ROM_WID= 15;

input rst, clk;
input [15:0] addr;
//input [22:0] addr;
output ea_int;
output [31:0] data_o;

reg [31:0] data_o;
wire ea;

reg ea_int;


`ifdef OC8051_XILINX_ROM

parameter INT_ROM_WID= 12;

reg [4:0] addr01;


wire [15:0] addr_rst;
wire [7:0] int_data0, int_data1, int_data2, int_data3, int_data4, int_data5, int_data6, int_data7, int_data8, int_data9, int_data10, int_data11, int_data12, int_data13, int_data14, int_data15, int_data16, int_data17, int_data18, int_data19, int_data20, int_data21, int_data22, int_data23, int_data24, int_data25, int_data26, int_data27, int_data28, int_data29, int_data30, int_data31, int_data32, int_data33, int_data34, int_data35, int_data36, int_data37, int_data38, int_data39, int_data40, int_data41, int_data42, int_data43, int_data44, int_data45, int_data46, int_data47, int_data48, int_data49, int_data50, int_data51, int_data52, int_data53, int_data54, int_data55, int_data56, int_data57, int_data58, int_data59, int_data60, int_data61, int_data62, int_data63, int_data64, int_data65, int_data66, int_data67, int_data68, int_data69, int_data70, int_data71, int_data72, int_data73, int_data74, int_data75, int_data76, int_data77, int_data78, int_data79, int_data80, int_data81, int_data82, int_data83, int_data84, int_data85, int_data86, int_data87, int_data88, int_data89, int_data90, int_data91, int_data92, int_data93, int_data94, int_data95, int_data96, int_data97, int_data98, int_data99, int_data100, int_data101, int_data102, int_data103, int_data104, int_data105, int_data106, int_data107, int_data108, int_data109, int_data110, int_data111, int_data112, int_data113, int_data114, int_data115, int_data116, int_data117, int_data118, int_data119, int_data120, int_data121, int_data122, int_data123, int_data124, int_data125, int_data126, int_data127;

assign ea = | addr[15:INT_ROM_WID];

assign addr_rst = rst ? 16'h0000 : addr;

  rom0 rom_0 (.a(addr01), .o(int_data0));
  rom1 rom_1 (.a(addr01), .o(int_data1));
  rom2 rom_2 (.a(addr_rst[11:7]), .o(int_data2));
  rom3 rom_3 (.a(addr_rst[11:7]), .o(int_data3));
  rom4 rom_4 (.a(addr_rst[11:7]), .o(int_data4));
  rom5 rom_5 (.a(addr_rst[11:7]), .o(int_data5));
  rom6 rom_6 (.a(addr_rst[11:7]), .o(int_data6));
  rom7 rom_7 (.a(addr_rst[11:7]), .o(int_data7));
  rom8 rom_8 (.a(addr_rst[11:7]), .o(int_data8));
  rom9 rom_9 (.a(addr_rst[11:7]), .o(int_data9));
  rom10 rom_10 (.a(addr_rst[11:7]), .o(int_data10));
  rom11 rom_11 (.a(addr_rst[11:7]), .o(int_data11));
  rom12 rom_12 (.a(addr_rst[11:7]), .o(int_data12));
  rom13 rom_13 (.a(addr_rst[11:7]), .o(int_data13));
  rom14 rom_14 (.a(addr_rst[11:7]), .o(int_data14));
  rom15 rom_15 (.a(addr_rst[11:7]), .o(int_data15));
  rom16 rom_16 (.a(addr_rst[11:7]), .o(int_data16));
  rom17 rom_17 (.a(addr_rst[11:7]), .o(int_data17));
  rom18 rom_18 (.a(addr_rst[11:7]), .o(int_data18));
  rom19 rom_19 (.a(addr_rst[11:7]), .o(int_data19));
  rom20 rom_20 (.a(addr_rst[11:7]), .o(int_data20));
  rom21 rom_21 (.a(addr_rst[11:7]), .o(int_data21));
  rom22 rom_22 (.a(addr_rst[11:7]), .o(int_data22));
  rom23 rom_23 (.a(addr_rst[11:7]), .o(int_data23));
  rom24 rom_24 (.a(addr_rst[11:7]), .o(int_data24));
  rom25 rom_25 (.a(addr_rst[11:7]), .o(int_data25));
  rom26 rom_26 (.a(addr_rst[11:7]), .o(int_data26));
  rom27 rom_27 (.a(addr_rst[11:7]), .o(int_data27));
  rom28 rom_28 (.a(addr_rst[11:7]), .o(int_data28));
  rom29 rom_29 (.a(addr_rst[11:7]), .o(int_data29));
  rom30 rom_30 (.a(addr_rst[11:7]), .o(int_data30));
  rom31 rom_31 (.a(addr_rst[11:7]), .o(int_data31));
  rom32 rom_32 (.a(addr_rst[11:7]), .o(int_data32));
  rom33 rom_33 (.a(addr_rst[11:7]), .o(int_data33));
  rom34 rom_34 (.a(addr_rst[11:7]), .o(int_data34));
  rom35 rom_35 (.a(addr_rst[11:7]), .o(int_data35));
  rom36 rom_36 (.a(addr_rst[11:7]), .o(int_data36));
  rom37 rom_37 (.a(addr_rst[11:7]), .o(int_data37));
  rom38 rom_38 (.a(addr_rst[11:7]), .o(int_data38));
  rom39 rom_39 (.a(addr_rst[11:7]), .o(int_data39));
  rom40 rom_40 (.a(addr_rst[11:7]), .o(int_data40));
  rom41 rom_41 (.a(addr_rst[11:7]), .o(int_data41));
  rom42 rom_42 (.a(addr_rst[11:7]), .o(int_data42));
  rom43 rom_43 (.a(addr_rst[11:7]), .o(int_data43));
  rom44 rom_44 (.a(addr_rst[11:7]), .o(int_data44));
  rom45 rom_45 (.a(addr_rst[11:7]), .o(int_data45));
  rom46 rom_46 (.a(addr_rst[11:7]), .o(int_data46));
  rom47 rom_47 (.a(addr_rst[11:7]), .o(int_data47));
  rom48 rom_48 (.a(addr_rst[11:7]), .o(int_data48));
  rom49 rom_49 (.a(addr_rst[11:7]), .o(int_data49));
  rom50 rom_50 (.a(addr_rst[11:7]), .o(int_data50));
  rom51 rom_51 (.a(addr_rst[11:7]), .o(int_data51));
  rom52 rom_52 (.a(addr_rst[11:7]), .o(int_data52));
  rom53 rom_53 (.a(addr_rst[11:7]), .o(int_data53));
  rom54 rom_54 (.a(addr_rst[11:7]), .o(int_data54));
  rom55 rom_55 (.a(addr_rst[11:7]), .o(int_data55));
  rom56 rom_56 (.a(addr_rst[11:7]), .o(int_data56));
  rom57 rom_57 (.a(addr_rst[11:7]), .o(int_data57));
  rom58 rom_58 (.a(addr_rst[11:7]), .o(int_data58));
  rom59 rom_59 (.a(addr_rst[11:7]), .o(int_data59));
  rom60 rom_60 (.a(addr_rst[11:7]), .o(int_data60));
  rom61 rom_61 (.a(addr_rst[11:7]), .o(int_data61));
  rom62 rom_62 (.a(addr_rst[11:7]), .o(int_data62));
  rom63 rom_63 (.a(addr_rst[11:7]), .o(int_data63));
  rom64 rom_64 (.a(addr_rst[11:7]), .o(int_data64));
  rom65 rom_65 (.a(addr_rst[11:7]), .o(int_data65));
  rom66 rom_66 (.a(addr_rst[11:7]), .o(int_data66));
  rom67 rom_67 (.a(addr_rst[11:7]), .o(int_data67));
  rom68 rom_68 (.a(addr_rst[11:7]), .o(int_data68));
  rom69 rom_69 (.a(addr_rst[11:7]), .o(int_data69));
  rom70 rom_70 (.a(addr_rst[11:7]), .o(int_data70));
  rom71 rom_71 (.a(addr_rst[11:7]), .o(int_data71));
  rom72 rom_72 (.a(addr_rst[11:7]), .o(int_data72));
  rom73 rom_73 (.a(addr_rst[11:7]), .o(int_data73));
  rom74 rom_74 (.a(addr_rst[11:7]), .o(int_data74));
  rom75 rom_75 (.a(addr_rst[11:7]), .o(int_data75));
  rom76 rom_76 (.a(addr_rst[11:7]), .o(int_data76));
  rom77 rom_77 (.a(addr_rst[11:7]), .o(int_data77));
  rom78 rom_78 (.a(addr_rst[11:7]), .o(int_data78));
  rom79 rom_79 (.a(addr_rst[11:7]), .o(int_data79));
  rom80 rom_80 (.a(addr_rst[11:7]), .o(int_data80));
  rom81 rom_81 (.a(addr_rst[11:7]), .o(int_data81));
  rom82 rom_82 (.a(addr_rst[11:7]), .o(int_data82));
  rom83 rom_83 (.a(addr_rst[11:7]), .o(int_data83));
  rom84 rom_84 (.a(addr_rst[11:7]), .o(int_data84));
  rom85 rom_85 (.a(addr_rst[11:7]), .o(int_data85));
  rom86 rom_86 (.a(addr_rst[11:7]), .o(int_data86));
  rom87 rom_87 (.a(addr_rst[11:7]), .o(int_data87));
  rom88 rom_88 (.a(addr_rst[11:7]), .o(int_data88));
  rom89 rom_89 (.a(addr_rst[11:7]), .o(int_data89));
  rom90 rom_90 (.a(addr_rst[11:7]), .o(int_data90));
  rom91 rom_91 (.a(addr_rst[11:7]), .o(int_data91));
  rom92 rom_92 (.a(addr_rst[11:7]), .o(int_data92));
  rom93 rom_93 (.a(addr_rst[11:7]), .o(int_data93));
  rom94 rom_94 (.a(addr_rst[11:7]), .o(int_data94));
  rom95 rom_95 (.a(addr_rst[11:7]), .o(int_data95));
  rom96 rom_96 (.a(addr_rst[11:7]), .o(int_data96));
  rom97 rom_97 (.a(addr_rst[11:7]), .o(int_data97));
  rom98 rom_98 (.a(addr_rst[11:7]), .o(int_data98));
  rom99 rom_99 (.a(addr_rst[11:7]), .o(int_data99));
  rom100 rom_100 (.a(addr_rst[11:7]), .o(int_data100));
  rom101 rom_101 (.a(addr_rst[11:7]), .o(int_data101));
  rom102 rom_102 (.a(addr_rst[11:7]), .o(int_data102));
  rom103 rom_103 (.a(addr_rst[11:7]), .o(int_data103));
  rom104 rom_104 (.a(addr_rst[11:7]), .o(int_data104));
  rom105 rom_105 (.a(addr_rst[11:7]), .o(int_data105));
  rom106 rom_106 (.a(addr_rst[11:7]), .o(int_data106));
  rom107 rom_107 (.a(addr_rst[11:7]), .o(int_data107));
  rom108 rom_108 (.a(addr_rst[11:7]), .o(int_data108));
  rom109 rom_109 (.a(addr_rst[11:7]), .o(int_data109));
  rom110 rom_110 (.a(addr_rst[11:7]), .o(int_data110));
  rom111 rom_111 (.a(addr_rst[11:7]), .o(int_data111));
  rom112 rom_112 (.a(addr_rst[11:7]), .o(int_data112));
  rom113 rom_113 (.a(addr_rst[11:7]), .o(int_data113));
  rom114 rom_114 (.a(addr_rst[11:7]), .o(int_data114));
  rom115 rom_115 (.a(addr_rst[11:7]), .o(int_data115));
  rom116 rom_116 (.a(addr_rst[11:7]), .o(int_data116));
  rom117 rom_117 (.a(addr_rst[11:7]), .o(int_data117));
  rom118 rom_118 (.a(addr_rst[11:7]), .o(int_data118));
  rom119 rom_119 (.a(addr_rst[11:7]), .o(int_data119));
  rom120 rom_120 (.a(addr_rst[11:7]), .o(int_data120));
  rom121 rom_121 (.a(addr_rst[11:7]), .o(int_data121));
  rom122 rom_122 (.a(addr_rst[11:7]), .o(int_data122));
  rom123 rom_123 (.a(addr_rst[11:7]), .o(int_data123));
  rom124 rom_124 (.a(addr_rst[11:7]), .o(int_data124));
  rom125 rom_125 (.a(addr_rst[11:7]), .o(int_data125));
  rom126 rom_126 (.a(addr_rst[11:7]), .o(int_data126));
  rom127 rom_127 (.a(addr_rst[11:7]), .o(int_data127));

always @(addr_rst)
begin
  if (addr_rst[1])
    addr01= addr_rst[11:7]+ 5'h1;
  else
    addr01= addr_rst[11:7];
end

//
// always read tree bits in row
always @(posedge clk)
begin
  case(addr[6:0]) /* synopsys parallel_case */
    7'd0: begin
      data1 <= #1 int_data0;
      data2 <= #1 int_data1;
      data3 <= #1 int_data2;
	end
    7'd1: begin
      data1 <= #1 int_data1;
      data2 <= #1 int_data2;
      data3 <= #1 int_data3;
	end
    7'd2: begin
      data1 <= #1 int_data2;
      data2 <= #1 int_data3;
      data3 <= #1 int_data4;
	end
    7'd3: begin
      data1 <= #1 int_data3;
      data2 <= #1 int_data4;
      data3 <= #1 int_data5;
	end
    7'd4: begin
      data1 <= #1 int_data4;
      data2 <= #1 int_data5;
      data3 <= #1 int_data6;
	end
    7'd5: begin
      data1 <= #1 int_data5;
      data2 <= #1 int_data6;
      data3 <= #1 int_data7;
	end
    7'd6: begin
      data1 <= #1 int_data6;
      data2 <= #1 int_data7;
      data3 <= #1 int_data8;
	end
    7'd7: begin
      data1 <= #1 int_data7;
      data2 <= #1 int_data8;
      data3 <= #1 int_data9;
	end
    7'd8: begin
      data1 <= #1 int_data8;
      data2 <= #1 int_data9;
      data3 <= #1 int_data10;
	end
    7'd9: begin
      data1 <= #1 int_data9;
      data2 <= #1 int_data10;
      data3 <= #1 int_data11;
	end
    7'd10: begin
      data1 <= #1 int_data10;
      data2 <= #1 int_data11;
      data3 <= #1 int_data12;
	end
    7'd11: begin
      data1 <= #1 int_data11;
      data2 <= #1 int_data12;
      data3 <= #1 int_data13;
	end
    7'd12: begin
      data1 <= #1 int_data12;
      data2 <= #1 int_data13;
      data3 <= #1 int_data14;
	end
    7'd13: begin
      data1 <= #1 int_data13;
      data2 <= #1 int_data14;
      data3 <= #1 int_data15;
	end
    7'd14: begin
      data1 <= #1 int_data14;
      data2 <= #1 int_data15;
      data3 <= #1 int_data16;
	end
    7'd15: begin
      data1 <= #1 int_data15;
      data2 <= #1 int_data16;
      data3 <= #1 int_data17;
	end
    7'd16: begin
      data1 <= #1 int_data16;
      data2 <= #1 int_data17;
      data3 <= #1 int_data18;
	end
    7'd17: begin
      data1 <= #1 int_data17;
      data2 <= #1 int_data18;
      data3 <= #1 int_data19;
	end
    7'd18: begin
      data1 <= #1 int_data18;
      data2 <= #1 int_data19;
      data3 <= #1 int_data20;
	end
    7'd19: begin
      data1 <= #1 int_data19;
      data2 <= #1 int_data20;
      data3 <= #1 int_data21;
	end
    7'd20: begin
      data1 <= #1 int_data20;
      data2 <= #1 int_data21;
      data3 <= #1 int_data22;
	end
    7'd21: begin
      data1 <= #1 int_data21;
      data2 <= #1 int_data22;
      data3 <= #1 int_data23;
	end
    7'd22: begin
      data1 <= #1 int_data22;
      data2 <= #1 int_data23;
      data3 <= #1 int_data24;
	end
    7'd23: begin
      data1 <= #1 int_data23;
      data2 <= #1 int_data24;
      data3 <= #1 int_data25;
	end
    7'd24: begin
      data1 <= #1 int_data24;
      data2 <= #1 int_data25;
      data3 <= #1 int_data26;
	end
    7'd25: begin
      data1 <= #1 int_data25;
      data2 <= #1 int_data26;
      data3 <= #1 int_data27;
	end
    7'd26: begin
      data1 <= #1 int_data26;
      data2 <= #1 int_data27;
      data3 <= #1 int_data28;
	end
    7'd27: begin
      data1 <= #1 int_data27;
      data2 <= #1 int_data28;
      data3 <= #1 int_data29;
	end
    7'd28: begin
      data1 <= #1 int_data28;
      data2 <= #1 int_data29;
      data3 <= #1 int_data30;
	end
    7'd29: begin
      data1 <= #1 int_data29;
      data2 <= #1 int_data30;
      data3 <= #1 int_data31;
	end
    7'd30: begin
      data1 <= #1 int_data30;
      data2 <= #1 int_data31;
      data3 <= #1 int_data32;
	end
    7'd31: begin
      data1 <= #1 int_data31;
      data2 <= #1 int_data32;
      data3 <= #1 int_data33;
	end
    7'd32: begin
      data1 <= #1 int_data32;
      data2 <= #1 int_data33;
      data3 <= #1 int_data34;
	end
    7'd33: begin
      data1 <= #1 int_data33;
      data2 <= #1 int_data34;
      data3 <= #1 int_data35;
	end
    7'd34: begin
      data1 <= #1 int_data34;
      data2 <= #1 int_data35;
      data3 <= #1 int_data36;
	end
    7'd35: begin
      data1 <= #1 int_data35;
      data2 <= #1 int_data36;
      data3 <= #1 int_data37;
	end
    7'd36: begin
      data1 <= #1 int_data36;
      data2 <= #1 int_data37;
      data3 <= #1 int_data38;
	end
    7'd37: begin
      data1 <= #1 int_data37;
      data2 <= #1 int_data38;
      data3 <= #1 int_data39;
	end
    7'd38: begin
      data1 <= #1 int_data38;
      data2 <= #1 int_data39;
      data3 <= #1 int_data40;
	end
    7'd39: begin
      data1 <= #1 int_data39;
      data2 <= #1 int_data40;
      data3 <= #1 int_data41;
	end
    7'd40: begin
      data1 <= #1 int_data40;
      data2 <= #1 int_data41;
      data3 <= #1 int_data42;
	end
    7'd41: begin
      data1 <= #1 int_data41;
      data2 <= #1 int_data42;
      data3 <= #1 int_data43;
	end
    7'd42: begin
      data1 <= #1 int_data42;
      data2 <= #1 int_data43;
      data3 <= #1 int_data44;
	end
    7'd43: begin
      data1 <= #1 int_data43;
      data2 <= #1 int_data44;
      data3 <= #1 int_data45;
	end
    7'd44: begin
      data1 <= #1 int_data44;
      data2 <= #1 int_data45;
      data3 <= #1 int_data46;
	end
    7'd45: begin
      data1 <= #1 int_data45;
      data2 <= #1 int_data46;
      data3 <= #1 int_data47;
	end
    7'd46: begin
      data1 <= #1 int_data46;
      data2 <= #1 int_data47;
      data3 <= #1 int_data48;
	end
    7'd47: begin
      data1 <= #1 int_data47;
      data2 <= #1 int_data48;
      data3 <= #1 int_data49;
	end
    7'd48: begin
      data1 <= #1 int_data48;
      data2 <= #1 int_data49;
      data3 <= #1 int_data50;
	end
    7'd49: begin
      data1 <= #1 int_data49;
      data2 <= #1 int_data50;
      data3 <= #1 int_data51;
	end
    7'd50: begin
      data1 <= #1 int_data50;
      data2 <= #1 int_data51;
      data3 <= #1 int_data52;
	end
    7'd51: begin
      data1 <= #1 int_data51;
      data2 <= #1 int_data52;
      data3 <= #1 int_data53;
	end
    7'd52: begin
      data1 <= #1 int_data52;
      data2 <= #1 int_data53;
      data3 <= #1 int_data54;
	end
    7'd53: begin
      data1 <= #1 int_data53;
      data2 <= #1 int_data54;
      data3 <= #1 int_data55;
	end
    7'd54: begin
      data1 <= #1 int_data54;
      data2 <= #1 int_data55;
      data3 <= #1 int_data56;
	end
    7'd55: begin
      data1 <= #1 int_data55;
      data2 <= #1 int_data56;
      data3 <= #1 int_data57;
	end
    7'd56: begin
      data1 <= #1 int_data56;
      data2 <= #1 int_data57;
      data3 <= #1 int_data58;
	end
    7'd57: begin
      data1 <= #1 int_data57;
      data2 <= #1 int_data58;
      data3 <= #1 int_data59;
	end
    7'd58: begin
      data1 <= #1 int_data58;
      data2 <= #1 int_data59;
      data3 <= #1 int_data60;
	end
    7'd59: begin
      data1 <= #1 int_data59;
      data2 <= #1 int_data60;
      data3 <= #1 int_data61;
	end
    7'd60: begin
      data1 <= #1 int_data60;
      data2 <= #1 int_data61;
      data3 <= #1 int_data62;
	end
    7'd61: begin
      data1 <= #1 int_data61;
      data2 <= #1 int_data62;
      data3 <= #1 int_data63;
	end
    7'd62: begin
      data1 <= #1 int_data62;
      data2 <= #1 int_data63;
      data3 <= #1 int_data64;
	end
    7'd63: begin
      data1 <= #1 int_data63;
      data2 <= #1 int_data64;
      data3 <= #1 int_data65;
	end
    7'd64: begin
      data1 <= #1 int_data64;
      data2 <= #1 int_data65;
      data3 <= #1 int_data66;
	end
    7'd65: begin
      data1 <= #1 int_data65;
      data2 <= #1 int_data66;
      data3 <= #1 int_data67;
	end
    7'd66: begin
      data1 <= #1 int_data66;
      data2 <= #1 int_data67;
      data3 <= #1 int_data68;
	end
    7'd67: begin
      data1 <= #1 int_data67;
      data2 <= #1 int_data68;
      data3 <= #1 int_data69;
	end
    7'd68: begin
      data1 <= #1 int_data68;
      data2 <= #1 int_data69;
      data3 <= #1 int_data70;
	end
    7'd69: begin
      data1 <= #1 int_data69;
      data2 <= #1 int_data70;
      data3 <= #1 int_data71;
	end
    7'd70: begin
      data1 <= #1 int_data70;
      data2 <= #1 int_data71;
      data3 <= #1 int_data72;
	end
    7'd71: begin
      data1 <= #1 int_data71;
      data2 <= #1 int_data72;
      data3 <= #1 int_data73;
	end
    7'd72: begin
      data1 <= #1 int_data72;
      data2 <= #1 int_data73;
      data3 <= #1 int_data74;
	end
    7'd73: begin
      data1 <= #1 int_data73;
      data2 <= #1 int_data74;
      data3 <= #1 int_data75;
	end
    7'd74: begin
      data1 <= #1 int_data74;
      data2 <= #1 int_data75;
      data3 <= #1 int_data76;
	end
    7'd75: begin
      data1 <= #1 int_data75;
      data2 <= #1 int_data76;
      data3 <= #1 int_data77;
	end
    7'd76: begin
      data1 <= #1 int_data76;
      data2 <= #1 int_data77;
      data3 <= #1 int_data78;
	end
    7'd77: begin
      data1 <= #1 int_data77;
      data2 <= #1 int_data78;
      data3 <= #1 int_data79;
	end
    7'd78: begin
      data1 <= #1 int_data78;
      data2 <= #1 int_data79;
      data3 <= #1 int_data80;
	end
    7'd79: begin
      data1 <= #1 int_data79;
      data2 <= #1 int_data80;
      data3 <= #1 int_data81;
	end
    7'd80: begin
      data1 <= #1 int_data80;
      data2 <= #1 int_data81;
      data3 <= #1 int_data82;
	end
    7'd81: begin
      data1 <= #1 int_data81;
      data2 <= #1 int_data82;
      data3 <= #1 int_data83;
	end
    7'd82: begin
      data1 <= #1 int_data82;
      data2 <= #1 int_data83;
      data3 <= #1 int_data84;
	end
    7'd83: begin
      data1 <= #1 int_data83;
      data2 <= #1 int_data84;
      data3 <= #1 int_data85;
	end
    7'd84: begin
      data1 <= #1 int_data84;
      data2 <= #1 int_data85;
      data3 <= #1 int_data86;
	end
    7'd85: begin
      data1 <= #1 int_data85;
      data2 <= #1 int_data86;
      data3 <= #1 int_data87;
	end
    7'd86: begin
      data1 <= #1 int_data86;
      data2 <= #1 int_data87;
      data3 <= #1 int_data88;
	end
    7'd87: begin
      data1 <= #1 int_data87;
      data2 <= #1 int_data88;
      data3 <= #1 int_data89;
	end
    7'd88: begin
      data1 <= #1 int_data88;
      data2 <= #1 int_data89;
      data3 <= #1 int_data90;
	end
    7'd89: begin
      data1 <= #1 int_data89;
      data2 <= #1 int_data90;
      data3 <= #1 int_data91;
	end
    7'd90: begin
      data1 <= #1 int_data90;
      data2 <= #1 int_data91;
      data3 <= #1 int_data92;
	end
    7'd91: begin
      data1 <= #1 int_data91;
      data2 <= #1 int_data92;
      data3 <= #1 int_data93;
	end
    7'd92: begin
      data1 <= #1 int_data92;
      data2 <= #1 int_data93;
      data3 <= #1 int_data94;
	end
    7'd93: begin
      data1 <= #1 int_data93;
      data2 <= #1 int_data94;
      data3 <= #1 int_data95;
	end
    7'd94: begin
      data1 <= #1 int_data94;
      data2 <= #1 int_data95;
      data3 <= #1 int_data96;
	end
    7'd95: begin
      data1 <= #1 int_data95;
      data2 <= #1 int_data96;
      data3 <= #1 int_data97;
	end
    7'd96: begin
      data1 <= #1 int_data96;
      data2 <= #1 int_data97;
      data3 <= #1 int_data98;
	end
    7'd97: begin
      data1 <= #1 int_data97;
      data2 <= #1 int_data98;
      data3 <= #1 int_data99;
	end
    7'd98: begin
      data1 <= #1 int_data98;
      data2 <= #1 int_data99;
      data3 <= #1 int_data100;
	end
    7'd99: begin
      data1 <= #1 int_data99;
      data2 <= #1 int_data100;
      data3 <= #1 int_data101;
	end
    7'd100: begin
      data1 <= #1 int_data100;
      data2 <= #1 int_data101;
      data3 <= #1 int_data102;
	end
    7'd101: begin
      data1 <= #1 int_data101;
      data2 <= #1 int_data102;
      data3 <= #1 int_data103;
	end
    7'd102: begin
      data1 <= #1 int_data102;
      data2 <= #1 int_data103;
      data3 <= #1 int_data104;
	end
    7'd103: begin
      data1 <= #1 int_data103;
      data2 <= #1 int_data104;
      data3 <= #1 int_data105;
	end
    7'd104: begin
      data1 <= #1 int_data104;
      data2 <= #1 int_data105;
      data3 <= #1 int_data106;
	end
    7'd105: begin
      data1 <= #1 int_data105;
      data2 <= #1 int_data106;
      data3 <= #1 int_data107;
	end
    7'd106: begin
      data1 <= #1 int_data106;
      data2 <= #1 int_data107;
      data3 <= #1 int_data108;
	end
    7'd107: begin
      data1 <= #1 int_data107;
      data2 <= #1 int_data108;
      data3 <= #1 int_data109;
	end
    7'd108: begin
      data1 <= #1 int_data108;
      data2 <= #1 int_data109;
      data3 <= #1 int_data110;
	end
    7'd109: begin
      data1 <= #1 int_data109;
      data2 <= #1 int_data110;
      data3 <= #1 int_data111;
	end
    7'd110: begin
      data1 <= #1 int_data110;
      data2 <= #1 int_data111;
      data3 <= #1 int_data112;
	end
    7'd111: begin
      data1 <= #1 int_data111;
      data2 <= #1 int_data112;
      data3 <= #1 int_data113;
	end
    7'd112: begin
      data1 <= #1 int_data112;
      data2 <= #1 int_data113;
      data3 <= #1 int_data114;
	end
    7'd113: begin
      data1 <= #1 int_data113;
      data2 <= #1 int_data114;
      data3 <= #1 int_data115;
	end
    7'd114: begin
      data1 <= #1 int_data114;
      data2 <= #1 int_data115;
      data3 <= #1 int_data116;
	end
    7'd115: begin
      data1 <= #1 int_data115;
      data2 <= #1 int_data116;
      data3 <= #1 int_data117;
	end
    7'd116: begin
      data1 <= #1 int_data116;
      data2 <= #1 int_data117;
      data3 <= #1 int_data118;
	end
    7'd117: begin
      data1 <= #1 int_data117;
      data2 <= #1 int_data118;
      data3 <= #1 int_data119;
	end
    7'd118: begin
      data1 <= #1 int_data118;
      data2 <= #1 int_data119;
      data3 <= #1 int_data120;
	end
    7'd119: begin
      data1 <= #1 int_data119;
      data2 <= #1 int_data120;
      data3 <= #1 int_data121;
	end
    7'd120: begin
      data1 <= #1 int_data120;
      data2 <= #1 int_data121;
      data3 <= #1 int_data122;
	end
    7'd121: begin
      data1 <= #1 int_data121;
      data2 <= #1 int_data122;
      data3 <= #1 int_data123;
	end
    7'd122: begin
      data1 <= #1 int_data122;
      data2 <= #1 int_data123;
      data3 <= #1 int_data124;
	end
    7'd123: begin
      data1 <= #1 int_data123;
      data2 <= #1 int_data124;
      data3 <= #1 int_data125;
	end
    7'd124: begin
      data1 <= #1 int_data124;
      data2 <= #1 int_data125;
      data3 <= #1 int_data126;
	end
    7'd125: begin
      data1 <= #1 int_data125;
      data2 <= #1 int_data126;
      data3 <= #1 int_data127;
	end
    7'd126: begin
      data1 <= #1 int_data126;
      data2 <= #1 int_data127;
      data3 <= #1 int_data0;
	end
    7'd127: begin
      data1 <= #1 int_data127;
      data2 <= #1 int_data0;
      data3 <= #1 int_data1;
	end
    default: begin
      data1 <= #1 8'h00;
      data2 <= #1 8'h00;
      data3 <= #1 8'h00;
	end
  endcase
end

always @(posedge clk or posedge rst)
 if (rst)
   ea_int <= #1 1'b1;
  else ea_int <= #1 !ea;

`else


reg [7:0] buff [0:65535]; //64kb

assign ea = 1'b0;

initial
begin
  $readmemh("../../../bench/in/oc8051_rom.in", buff);
end

always @(posedge clk or posedge rst)
 if (rst)
   ea_int <= #1 1'b1;
  else ea_int <= #1 !ea;

always @(posedge clk)
begin
  data_o <= #1 {buff[addr+3], buff[addr+2], buff[addr+1], buff[addr]};
end


`endif


endmodule


`ifdef OC8051_XILINX_ROM

//rom0
module rom0 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=004760c0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00475754" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=032c2000" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00300087" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0228b085" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01002085" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=015378ed" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=024bd0c4" */;
endmodule

//rom1
module rom1 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022c68a6" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0008e892" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=032feb64" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0010a020" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=015b2028" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00bca44c" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02bc34c2" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=016700c3" */;
endmodule

//rom2
module rom2 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00701310" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01a79000" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a40cee" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01371711" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02340c6b" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022c00c4" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022c50c4" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000aaa" */;
endmodule

//rom3
module rom3 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00f46b58" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=027c0c49" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0280bb9b" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00088848" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00807bbd" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c30bf9" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01b72fbd" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00343c40" */;
endmodule

//rom4
module rom4 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0340f400" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01036080" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03677000" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0110b0c4" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00ecabfa" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0248ecaa" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0258ecea" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02a4c790" */;
endmodule

//rom5
module rom5 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02638826" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02cca816" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03c36298" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02e40029" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02e3d7a0" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03431409" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02d394c5" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0020c005" */;
endmodule

//rom6
module rom6 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=010070c0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01885b92" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0318302c" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=004044c0" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0223a46d" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=012c20a9" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=002cb029" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03030084" */;
endmodule

//rom7
module rom7 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00289808" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d8429" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02bf1b1c" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00820339" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=033b6429" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=010b5069" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=034854e9" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00503421" */;
endmodule

//rom8
module rom8 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=019c8ff3" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01438c62" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=002c6c4b" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01904b92" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00bc93d5" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02acb31d" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02bc1335" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c09b32" */;
endmodule

//rom9
module rom9 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01004a06" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0300642c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02835972" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00230208" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000cdb73" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00904fb2" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01f0cb93" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01cc1441" */;
endmodule

//rom10
module rom10 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=026f5480" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00d8c4d4" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0338e680" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00036050" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03a358a2" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03234240" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03af4228" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c34942" */;
endmodule

//rom11
module rom11 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b2e334" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01ac492a" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b38899" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01202a00" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0232faf1" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b3b259" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00f3f551" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02c16380" */;
endmodule

//rom12
module rom12 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02637465" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00434de2" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01ce621d" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=026e0080" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01f3a04d" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02422290" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02433231" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=019181a8" */;
endmodule

//rom13
module rom13 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=006ca309" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0232a510" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0151b922" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001eaa5a" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d72e1" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=014db1c4" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=017d71c5" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00ec0129" */;
endmodule

//rom14
module rom14 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002cb2" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0033c0d5" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02085465" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02450843" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=010c18cb" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008c184a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01ae0b1a" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00021853" */;
endmodule

//rom15
module rom15 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02247616" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a64f08" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01f6f6d7" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02368d00" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=026f3ef6" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022658fe" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022f78e6" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02406000" */;
endmodule

//rom16
module rom16 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00d9a200" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00442ca0" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=038f21fa" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0010aaa0" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=029cf3cc" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03def39a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02bef75b" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00129484" */;
endmodule

//rom17
module rom17 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0223de06" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01237e04" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=021014e3" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01209000" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03da88a2" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=025882a2" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=015b8ab2" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008b0908" */;
endmodule

//rom18
module rom18 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00822340" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00804d64" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00e7108b" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02c00a20" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02b10be3" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=030c062a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=038421f2" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=003f3761" */;
endmodule

//rom19
module rom19 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0256e421" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0387452b" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=015ac695" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0023004e" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00160871" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=005aa200" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02769a61" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=024ca130" */;
endmodule

//rom20
module rom20 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01507386" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001643a0" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01962932" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02d25004" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=013678b4" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03373167" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=033f25cd" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000184" */;
endmodule

//rom21
module rom21 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b0cc00" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00251ac1" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0269408f" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=009c8448" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03ca61bc" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008a5016" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008249b6" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03c03800" */;
endmodule

//rom22
module rom22 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00730101" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02101d00" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03212219" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00020834" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=021dd058" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=032da894" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=033d9cc2" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02b05c09" */;
endmodule

//rom23
module rom23 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00348623" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01a827a8" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b08e12" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=002c40cc" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=006b0816" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02684216" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02721036" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00010a28" */;
endmodule

//rom24
module rom24 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b31840" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=027b4450" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d3b126" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01102810" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=009592ab" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0099940c" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b482cc" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00280463" */;
endmodule

//rom25
module rom25 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0346a616" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d0433" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02665666" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0100628a" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03b8385e" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03422906" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=035a2816" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01ea3050" */;
endmodule

//rom26
module rom26 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0134c390" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01522880" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0007195d" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0063da01" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=023ac37a" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0086433e" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01ae47ae" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03044080" */;
endmodule

//rom27
module rom27 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0017662b" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=029e6c24" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=014c0298" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02052805" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=014d99cb" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=032d9a5b" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0337da5b" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00534189" */;
endmodule

//rom28
module rom28 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=010c3346" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03248460" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00bba08b" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c00204" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00137387" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0109320f" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d0017" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001e4200" */;
endmodule

//rom29
module rom29 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b09c14" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00034969" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0324b616" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02930009" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00bcc090" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00e8b296" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01e8ba86" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=019c3800" */;
endmodule

//rom30
module rom30 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=028846e6" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00cc4ac2" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00406536" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02054903" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02b1d817" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02135427" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=039b500f" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02a8d030" */;
endmodule

//rom31
module rom31 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01404535" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=013262c8" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03da0477" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01100100" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02e8953b" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02c4f567" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02e41d27" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00084100" */;
endmodule

//rom32
module rom32 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=020350c1" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022d8082" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0196734c" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001803" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=015b0579" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=009a7155" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02936155" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03416428" */;
endmodule

//rom33
module rom33 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0244461a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01404a0d" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0264b28e" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b18ca9" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03cf3458" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=038d3a9e" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02dd3808" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00034bc8" */;
endmodule

//rom34
module rom34 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=023a8140" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02c82561" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=021a4892" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02aaa041" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0337c899" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=033a801b" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0331831f" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0024c980" */;
endmodule

//rom35
module rom35 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0311fa85" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01176acd" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02791cbd" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01d08cad" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02b85985" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02389991" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=003c3893" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0080a980" */;
endmodule

//rom36
module rom36 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02788531" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c0311" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=030b214c" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=005a0463" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01701c2d" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03495dab" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03c95dbb" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00611534" */;
endmodule

//rom37
module rom37 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=033a1850" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0310588c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022cd6b2" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02071048" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02ea847e" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022b847c" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=037ba568" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0153004b" */;
endmodule

//rom38
module rom38 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=017767c3" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0121ac20" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02b276f9" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00242623" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=032e45c5" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00ae46dd" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=013f44d5" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=034d1602" */;
endmodule

//rom39
module rom39 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00ba8a65" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=029a006c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=039f2f41" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0032804c" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=025fe7c7" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02960743" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=035e1773" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03c164a1" */;
endmodule

//rom40
module rom40 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00247801" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=002328d1" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=004818a7" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000368d1" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01a0066d" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02c8dc77" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03f0844f" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00280b40" */;
endmodule

//rom41
module rom41 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01648f42" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022455e1" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d08a32" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0082042d" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00022b13" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00433807" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=006f2943" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00441151" */;
endmodule

//rom42
module rom42 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03aa200c" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01af321c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=027bc4d7" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00226090" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02329d01" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=026e8557" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03e2947b" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01941948" */;
endmodule

//rom43
module rom43 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00114d80" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a0901" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01c12f48" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00104a81" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03f16cd8" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008d61d0" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=009775f4" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=036e418a" */;
endmodule

//rom44
module rom44 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0240f2c0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02ca2854" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=010264be" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0382a241" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=012f26a6" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=035276d3" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=023e6782" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00096660" */;
endmodule

//rom45
module rom45 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000426c0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02306582" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00160af4" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008109a2" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008932fc" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01e39298" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01cab6d9" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00026404" */;
endmodule

//rom46
module rom46 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=003e1a4a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=016f90c9" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d0b756" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02001ac5" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00161fe1" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00984bf2" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b64bf1" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00260c84" */;
endmodule

//rom47
module rom47 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03489a90" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e4698" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0163d823" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02810420" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03f0a835" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03449e26" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0348bad6" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02be1591" */;
endmodule

//rom48
module rom48 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00356b59" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00120945" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=021a6ab1" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00130841" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03ebdf75" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02075eb1" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02975fa3" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=016d9180" */;
endmodule

//rom49
module rom49 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03098402" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00500e22" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03c112b4" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00080a22" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=026ff387" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=032ba3d5" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=016722df" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00085108" */;
endmodule

//rom50
module rom50 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=002379e0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0145bca5" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b51303" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=023350c4" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02290863" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02894388" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02090b39" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000009a2" */;
endmodule

//rom51
module rom51 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02340e14" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02896092" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=036c9e79" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d9801e" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=029e1bf5" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02341225" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02b61385" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00300042" */;
endmodule

//rom52
module rom52 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=036a8fa8" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00222fe5" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=023a6abc" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0161cee1" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03758e9a" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03f98ece" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03f98a8e" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=014c8050" */;
endmodule

//rom53
module rom53 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02265616" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02a40113" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03c2b616" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02006011" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0358fc4e" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=034af655" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=036edef6" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=003a6008" */;
endmodule

//rom54
module rom54 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02d1a2ea" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03070084" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00aae1ee" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01120a80" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00bbfef2" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00927236" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0293f217" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02691400" */;
endmodule

//rom55
module rom55 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=007a0ad1" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02528d1c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=021c03e2" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01350714" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01b0e775" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=035903c6" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03120ac7" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a328a4" */;
endmodule

//rom56
module rom56 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01952bc6" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001186e4" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0253bbff" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000500e8" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=027f03f3" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01bd6bd6" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01bd09d2" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02461a03" */;
endmodule

//rom57
module rom57 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00544809" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02e6e850" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02208e42" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=011a8c59" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022d897e" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02004afa" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03055abe" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0304c159" */;
endmodule

//rom58
module rom58 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001056b8" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00155392" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01a9a848" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00802486" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=013c1de9" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=026a0469" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=027a0459" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01140c10" */;
endmodule

//rom59
module rom59 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01b82c17" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=025a1704" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=025200f3" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a92801" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008024f8" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01857032" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01b5a465" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0085348c" */;
endmodule

//rom60
module rom60 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02ef2408" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008534a0" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=026ac37f" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000021a0" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03fe3c05" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=036e6cb3" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03fb7833" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00855484" */;
endmodule

//rom61
module rom61 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01300960" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00206069" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01a5c204" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00202101" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02ff9bd0" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a80180" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a817f2" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=024f8360" */;
endmodule

//rom62
module rom62 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=003cfcc1" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0053b483" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0282ddfa" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0363100b" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=006acbf4" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03824925" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d0eb46" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01102000" */;
endmodule

//rom63
module rom63 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a02cdc" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02622c54" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01981be2" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002848" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01905aea" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008d99c8" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a59dd9" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0138451a" */;
endmodule

//rom64
module rom64 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b00782" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01a5d486" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02c7819a" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d25283" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0090079a" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008057ca" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a823eb" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00101412" */;
endmodule

//rom65
module rom65 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0267b804" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a04ae8" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00259391" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02e202e8" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=027f3683" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=037713a2" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03771f02" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02428881" */;
endmodule

//rom66
module rom66 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c0ae04" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=014a2603" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03904ba0" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0030600f" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02c51af8" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02083398" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=026231de" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00cf3321" */;
endmodule

//rom67
module rom67 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03834916" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008a0c38" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d62b96" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00834858" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03dbe987" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d34b07" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01fe4a87" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0008e120" */;
endmodule

//rom68
module rom68 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00602648" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0025a248" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02025793" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00302200" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01004034" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02024132" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=029a497b" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0142104c" */;
endmodule

//rom69
module rom69 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02520980" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d200b2" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=013d8465" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000dcd1a" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00f221db" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0150203b" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03123693" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022200d2" */;
endmodule

//rom70
module rom70 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=003f9e10" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01081095" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02c23e62" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0035a201" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0257c4f2" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00878c22" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=002f8dba" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=024d8810" */;
endmodule

//rom71
module rom71 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00924b99" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02d2d9aa" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=038a29b5" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01032aaf" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022f2fd8" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02a37af9" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02336ae0" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=029c5400" */;
endmodule

//rom72
module rom72 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0138a6e6" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=003ef660" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0030eb9a" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=010a2604" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01cc3f2c" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03c82396" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d033b5" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=010838ac" */;
endmodule

//rom73
module rom73 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00206b81" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02802fc1" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03a54aaf" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c00881" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=010efabd" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=012f4ba7" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=013bf996" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0021ab00" */;
endmodule

//rom74
module rom74 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02ef9140" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01e91044" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=023ca721" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01222414" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0221c92b" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02248b88" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02e58a8a" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c54101" */;
endmodule

//rom75
module rom75 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=012c4e1b" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00245ad9" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01d8010d" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00014481" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d3a449" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01c9450d" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01eb2573" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=023c8411" */;
endmodule

//rom76
module rom76 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03528166" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0183fb22" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0326347c" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03910020" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=013c80fd" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0308844d" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=031804cf" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=006c0412" */;
endmodule

//rom77
module rom77 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01e20811" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03448509" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00827a32" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00206089" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00ed1463" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01da2001" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01bb3404" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00022462" */;
endmodule

//rom78
module rom78 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=018a5cac" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=009b00ac" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d39f43" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0282c040" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c67a19" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a67415" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01a67e9d" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01404ea8" */;
endmodule

//rom79
module rom79 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0352a910" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=012e2551" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01b40984" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03018109" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03109dae" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0391cc2a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0393cb22" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02039484" */;
endmodule

//rom80
module rom80 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00ad0625" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00017235" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03a644c7" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00088067" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03b289a6" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02649407" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0265850c" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01970c00" */;
endmodule

//rom81
module rom81 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03804148" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01c6b210" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02c16122" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008a8140" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02b944ef" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03804cee" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=019844e7" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=002d0040" */;
endmodule

//rom82
module rom82 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02682496" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=003108a5" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=024c930f" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00013474" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03ec617f" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=034a8163" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03eaa176" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0004e028" */;
endmodule

//rom83
module rom83 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0200f17b" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0322c6e1" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0396295e" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02105a40" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=024cb25e" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02057156" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0201b777" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00489721" */;
endmodule

//rom84
module rom84 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03520fc0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=024140c4" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01ab0723" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00789804" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00523b39" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01969f2a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=035e9e4a" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0310ad51" */;
endmodule

//rom85
module rom85 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01210038" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03cc3432" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=011561dd" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01a058aa" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01b38e80" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03312d4c" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03b189c0" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=002206c0" */;
endmodule

//rom86
module rom86 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0206cdc6" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02022b14" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=036e8ece" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=024a5804" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03375aed" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02a64ccf" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02a45ced" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01115400" */;
endmodule

//rom87
module rom87 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0078c041" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0193db40" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0280387a" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01492050" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=005d08e1" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02490c4b" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0258cc4e" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=025cc080" */;
endmodule

//rom88
module rom88 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=028434fc" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00210ce8" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02de9381" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00022ad4" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00e8b015" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03e83051" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03fc703f" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0200a078" */;
endmodule

//rom89
module rom89 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=027a6b03" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0304cd82" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03092175" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02138308" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=028a3b7f" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0222225b" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=022a2b51" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00e21a24" */;
endmodule

//rom90
module rom90 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01497425" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c87850" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03062ea2" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000520d5" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=031b6a42" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0183f241" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01bba348" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02094046" */;
endmodule

//rom91
module rom91 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0004018a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0282b74a" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0241824a" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00262092" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03550af6" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=020504be" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02054ef7" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03440080" */;
endmodule

//rom92
module rom92 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0110a4a4" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01316120" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0184debd" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00831021" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=002a8c8e" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03268693" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=037ea6d6" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00542208" */;
endmodule

//rom93
module rom93 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00827892" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=030b08ca" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=021a61bf" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008a10ca" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0096d6f5" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00e252be" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00e35abc" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b59c01" */;
endmodule

//rom94
module rom94 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02952101" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c32aa5" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=034bad13" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=011536a5" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02bbf4ab" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0203b9fb" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02a339fb" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=009848a0" */;
endmodule

//rom95
module rom95 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=014101ba" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000584ba" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=006c4b06" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01844052" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03d90b63" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01d4430f" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01dd23a3" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=030108a0" */;
endmodule

//rom96
module rom96 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00172812" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02b64210" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0381a6ea" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02909c01" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01ef336a" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03a900ab" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03ab129a" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=004711d4" */;
endmodule

//rom97
module rom97 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0021a5a0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=030b11f0" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00d7721b" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0149c460" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00d78d91" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00b3ae5b" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00f3ae8f" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0026a640" */;
endmodule

//rom98
module rom98 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000f08d" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0044298f" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=028cbc85" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03106a87" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=010bf6e9" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=018cf6c1" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01bff6fd" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00004208" */;
endmodule

//rom99
module rom99 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03188093" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01b88890" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01e0e946" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=034b83b9" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=038cf85c" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=038cca9b" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=039cca00" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02103684" */;
endmodule

//rom100
module rom100 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=036c3160" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008cb024" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03334452" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c4a104" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03600350" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03631742" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=037b03eb" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=004b0134" */;
endmodule

//rom101
module rom101 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03530ed9" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03c01a41" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=038781f8" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=031004c8" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03f465fc" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0307a145" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0347a946" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00e3cc20" */;
endmodule

//rom102
module rom102 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0307e084" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0103ea66" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02637deb" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00033044" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02638c59" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=034301d2" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01fb8594" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000084c9" */;
endmodule

//rom103
module rom103 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0247f099" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03670098" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0118a7de" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00005089" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008435f6" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0200f1fc" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0303f8ec" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01079503" */;
endmodule

//rom104
module rom104 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0240e222" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0240e224" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03bfa350" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0220be06" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=035ff459" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0280f799" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0200f7d9" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=011f0202" */;
endmodule

//rom105
module rom105 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03bc7389" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=038f2831" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c42a45" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=003b2199" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=007ca38b" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01ac6e06" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=033cee02" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02e06800" */;
endmodule

//rom106
module rom106 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0200e054" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002472" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02208c8d" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001000" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01a07add" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03bf400f" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03bf715d" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02403ad4" */;
endmodule

//rom107
module rom107 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0220ef00" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=031f9bf8" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=039b2f52" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02840888" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02400f7a" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02404cba" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0240cc6e" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000c8a9" */;
endmodule

//rom108
module rom108 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01bb702d" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a02208" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=031ba124" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00402001" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=021feda0" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=011f69e1" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01bf79fc" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03a0940a" */;
endmodule

//rom109
module rom109 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01404d92" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03448940" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03801686" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01008648" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=039b34bc" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03a0511a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03c07101" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=027b4024" */;
endmodule

//rom110
module rom110 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001972a4" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00856c05" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=014c7196" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00890225" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=015153dd" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0265d386" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=027ed2ce" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01200314" */;
endmodule

//rom111
module rom111 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00446a88" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03df82b8" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0284ad91" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=010004c0" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0084129d" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00846184" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00a46386" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00007201" */;
endmodule

//rom112
module rom112 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0264ff4c" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00403bc9" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=029fa8a2" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=003b24a3" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0244ec92" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0384fc90" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0384ee5c" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000ec9" */;
endmodule

//rom113
module rom113 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001b48b0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01801180" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01c04c5e" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001b0030" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02dfecef" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=003b6c35" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001b6ea5" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02ff80ea" */;
endmodule

//rom114
module rom114 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0322a0a0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=020426a7" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=031e9359" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02011406" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=019bc8f1" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=033b8010" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03bf00b0" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00204822" */;
endmodule

//rom115
module rom115 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00025fa0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0207e780" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00820095" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00035080" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=013a14cb" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=004258df" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=006216fb" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01181700" */;
endmodule

//rom116
module rom116 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=003010f1" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0043687c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02f4b489" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=030e802e" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001815a7" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01981025" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=011913b5" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00010035" */;
endmodule

//rom117
module rom117 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=027d93a1" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01b11250" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=005179ba" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=029ff901" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02f7b43e" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0257b0bb" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02f7b4ae" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0224a080" */;
endmodule

//rom118
module rom118 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=021968c6" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b16cc" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03062182" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0112d88c" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=024fedae" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02a6e98e" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=028fe99b" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0069482a" */;
endmodule

//rom119
module rom119 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0154955f" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0092843c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00c7db12" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=014c8020" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0352f809" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0123c992" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=017bdd8c" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0331344c" */;
endmodule

//rom120
module rom120 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0284ba00" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02543ae0" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0380b757" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=02011a88" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0388df5d" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0380bb0a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03b89a42" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00050f15" */;
endmodule

//rom121
module rom121 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00198e11" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0031b011" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01779b35" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00518431" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=009dca89" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0013cb51" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01138bdb" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00860001" */;
endmodule

//rom122
module rom122 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00ea1120" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=008e8142" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00247040" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0140a0a8" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01731e37" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01e55c35" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01ff5c35" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=004a4a20" */;
endmodule

//rom123
module rom123 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=015124f9" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01c249bc" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=010a8447" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01012601" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=012c3a46" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0116a054" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0144e0e8" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=026af0aa" */;
endmodule

//rom124
module rom124 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=017ea002" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00568202" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03a21d9f" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=028e2002" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=036be4df" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=03027417" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0373a437" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=025888ca" */;
endmodule

//rom125
module rom125 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0181416c" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0121b121" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0155e2fc" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01802241" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01de20a7" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01cce037" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01cee837" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0090c121" */;
endmodule

//rom126
module rom126 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01c72e11" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00846c52" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=012d7806" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=002a1a23" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0190a2b8" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000122ad" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0181afb8" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00910610" */;
endmodule

//rom127
module rom127 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0025d188" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=010529bc" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01c9c652" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00213064" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01fb5633" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00bb5a32" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01bb5223" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=01641820" */;
endmodule


`endif
