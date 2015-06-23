
///
/// created by oc8051 rom maker
/// author: Simon Teran (simont@opencores.org)
///
/// source file: C:\simont\monasm1.hex
/// date: 8/21/2002
/// time: 4:20:40 PM
///

module ROM32X1(O, A0, A1, A2, A3, A4); // synthesis syn_black_box syn_resources="luts=2"
output O;
input A0;
input A1;
input A2;
input A3;
input A4;
endmodule

//rom for 8051 processor

module oc8051_rom (rst, clk, addr, ea_int, data1, data2, data3);

parameter INT_ROM_WID= 10;

input rst, clk;
input [15:0] addr;
output ea_int;
output [7:0] data1, data2, data3;
reg ea_int;
reg [4:0] addr01;
reg [7:0] data1, data2, data3;

wire ea;
wire [15:0] addr_rst;
wire [7:0] int_data0, int_data1, int_data2, int_data3, int_data4, int_data5, int_data6, int_data7, int_data8, int_data9, int_data10, int_data11, int_data12, int_data13, int_data14, int_data15, int_data16, int_data17, int_data18, int_data19, int_data20, int_data21, int_data22, int_data23, int_data24, int_data25, int_data26, int_data27, int_data28, int_data29, int_data30, int_data31;

assign ea = | addr[15:INT_ROM_WID];

assign addr_rst = rst ? 16'h0000 : addr;

  rom0 rom_0 (.a(addr01), .o(int_data0));
  rom1 rom_1 (.a(addr01), .o(int_data1));
  rom2 rom_2 (.a(addr_rst[9:5]), .o(int_data2));
  rom3 rom_3 (.a(addr_rst[9:5]), .o(int_data3));
  rom4 rom_4 (.a(addr_rst[9:5]), .o(int_data4));
  rom5 rom_5 (.a(addr_rst[9:5]), .o(int_data5));
  rom6 rom_6 (.a(addr_rst[9:5]), .o(int_data6));
  rom7 rom_7 (.a(addr_rst[9:5]), .o(int_data7));
  rom8 rom_8 (.a(addr_rst[9:5]), .o(int_data8));
  rom9 rom_9 (.a(addr_rst[9:5]), .o(int_data9));
  rom10 rom_10 (.a(addr_rst[9:5]), .o(int_data10));
  rom11 rom_11 (.a(addr_rst[9:5]), .o(int_data11));
  rom12 rom_12 (.a(addr_rst[9:5]), .o(int_data12));
  rom13 rom_13 (.a(addr_rst[9:5]), .o(int_data13));
  rom14 rom_14 (.a(addr_rst[9:5]), .o(int_data14));
  rom15 rom_15 (.a(addr_rst[9:5]), .o(int_data15));
  rom16 rom_16 (.a(addr_rst[9:5]), .o(int_data16));
  rom17 rom_17 (.a(addr_rst[9:5]), .o(int_data17));
  rom18 rom_18 (.a(addr_rst[9:5]), .o(int_data18));
  rom19 rom_19 (.a(addr_rst[9:5]), .o(int_data19));
  rom20 rom_20 (.a(addr_rst[9:5]), .o(int_data20));
  rom21 rom_21 (.a(addr_rst[9:5]), .o(int_data21));
  rom22 rom_22 (.a(addr_rst[9:5]), .o(int_data22));
  rom23 rom_23 (.a(addr_rst[9:5]), .o(int_data23));
  rom24 rom_24 (.a(addr_rst[9:5]), .o(int_data24));
  rom25 rom_25 (.a(addr_rst[9:5]), .o(int_data25));
  rom26 rom_26 (.a(addr_rst[9:5]), .o(int_data26));
  rom27 rom_27 (.a(addr_rst[9:5]), .o(int_data27));
  rom28 rom_28 (.a(addr_rst[9:5]), .o(int_data28));
  rom29 rom_29 (.a(addr_rst[9:5]), .o(int_data29));
  rom30 rom_30 (.a(addr_rst[9:5]), .o(int_data30));
  rom31 rom_31 (.a(addr_rst[9:5]), .o(int_data31));

always @(addr_rst)
begin
  if (addr_rst[1])
    addr01= addr_rst[9:5]+ 5'h1;
  else
    addr01= addr_rst[9:5];
end

//
// always read tree bits in row
always @(posedge clk)
begin
  case(addr[4:0])
    5'd0: begin
      data1 <= #1 int_data0;
      data2 <= #1 int_data1;
      data3 <= #1 int_data2;
	end
    5'd1: begin
      data1 <= #1 int_data1;
      data2 <= #1 int_data2;
      data3 <= #1 int_data3;
	end
    5'd2: begin
      data1 <= #1 int_data2;
      data2 <= #1 int_data3;
      data3 <= #1 int_data4;
	end
    5'd3: begin
      data1 <= #1 int_data3;
      data2 <= #1 int_data4;
      data3 <= #1 int_data5;
	end
    5'd4: begin
      data1 <= #1 int_data4;
      data2 <= #1 int_data5;
      data3 <= #1 int_data6;
	end
    5'd5: begin
      data1 <= #1 int_data5;
      data2 <= #1 int_data6;
      data3 <= #1 int_data7;
	end
    5'd6: begin
      data1 <= #1 int_data6;
      data2 <= #1 int_data7;
      data3 <= #1 int_data8;
	end
    5'd7: begin
      data1 <= #1 int_data7;
      data2 <= #1 int_data8;
      data3 <= #1 int_data9;
	end
    5'd8: begin
      data1 <= #1 int_data8;
      data2 <= #1 int_data9;
      data3 <= #1 int_data10;
	end
    5'd9: begin
      data1 <= #1 int_data9;
      data2 <= #1 int_data10;
      data3 <= #1 int_data11;
	end
    5'd10: begin
      data1 <= #1 int_data10;
      data2 <= #1 int_data11;
      data3 <= #1 int_data12;
	end
    5'd11: begin
      data1 <= #1 int_data11;
      data2 <= #1 int_data12;
      data3 <= #1 int_data13;
	end
    5'd12: begin
      data1 <= #1 int_data12;
      data2 <= #1 int_data13;
      data3 <= #1 int_data14;
	end
    5'd13: begin
      data1 <= #1 int_data13;
      data2 <= #1 int_data14;
      data3 <= #1 int_data15;
	end
    5'd14: begin
      data1 <= #1 int_data14;
      data2 <= #1 int_data15;
      data3 <= #1 int_data16;
	end
    5'd15: begin
      data1 <= #1 int_data15;
      data2 <= #1 int_data16;
      data3 <= #1 int_data17;
	end
    5'd16: begin
      data1 <= #1 int_data16;
      data2 <= #1 int_data17;
      data3 <= #1 int_data18;
	end
    5'd17: begin
      data1 <= #1 int_data17;
      data2 <= #1 int_data18;
      data3 <= #1 int_data19;
	end
    5'd18: begin
      data1 <= #1 int_data18;
      data2 <= #1 int_data19;
      data3 <= #1 int_data20;
	end
    5'd19: begin
      data1 <= #1 int_data19;
      data2 <= #1 int_data20;
      data3 <= #1 int_data21;
	end
    5'd20: begin
      data1 <= #1 int_data20;
      data2 <= #1 int_data21;
      data3 <= #1 int_data22;
	end
    5'd21: begin
      data1 <= #1 int_data21;
      data2 <= #1 int_data22;
      data3 <= #1 int_data23;
	end
    5'd22: begin
      data1 <= #1 int_data22;
      data2 <= #1 int_data23;
      data3 <= #1 int_data24;
	end
    5'd23: begin
      data1 <= #1 int_data23;
      data2 <= #1 int_data24;
      data3 <= #1 int_data25;
	end
    5'd24: begin
      data1 <= #1 int_data24;
      data2 <= #1 int_data25;
      data3 <= #1 int_data26;
	end
    5'd25: begin
      data1 <= #1 int_data25;
      data2 <= #1 int_data26;
      data3 <= #1 int_data27;
	end
    5'd26: begin
      data1 <= #1 int_data26;
      data2 <= #1 int_data27;
      data3 <= #1 int_data28;
	end
    5'd27: begin
      data1 <= #1 int_data27;
      data2 <= #1 int_data28;
      data3 <= #1 int_data29;
	end
    5'd28: begin
      data1 <= #1 int_data28;
      data2 <= #1 int_data29;
      data3 <= #1 int_data30;
	end
    5'd29: begin
      data1 <= #1 int_data29;
      data2 <= #1 int_data30;
      data3 <= #1 int_data31;
	end
    5'd30: begin
      data1 <= #1 int_data30;
      data2 <= #1 int_data31;
      data3 <= #1 int_data0;
	end
    5'd31: begin
      data1 <= #1 int_data31;
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

endmodule


//rom0
module rom0 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00092dd0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00143111" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000008d8" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00178438" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000203c4" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000880c0" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0008a0c0" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00032bc0" */;
endmodule

//rom1
module rom1 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00160931" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001e0294" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00193938" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00180010" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00032148" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001f1564" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001f1d60" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000021f0" */;
endmodule

//rom2
module rom2 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0015a771" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0017b405" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c2601" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00040170" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002ff1" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001f0e4d" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001f2ec8" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00008d35" */;
endmodule

//rom3
module rom3 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00070d2c" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00012083" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00070f30" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00150014" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00128d75" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0017af31" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00078f70" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000224" */;
endmodule

//rom4
module rom4 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c12f0" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00031218" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f10c0" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d1020" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0010bf2c" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00179048" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00071d44" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00003f60" */;
endmodule

//rom5
module rom5 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001402a8" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0008309e" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00100224" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00081c08" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00101274" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00141278" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0004126e" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000052e8" */;
endmodule

//rom6
module rom6 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001a7348" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00043c5e" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00042090" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f6b10" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0012624a" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001c6582" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c7084" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0003dbfc" */;
endmodule

//rom7
module rom7 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000007de" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000041e8" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d3662" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0008001c" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00039ef6" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001fee62" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000fae62" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000039f4" */;
endmodule

//rom8
module rom8 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0012e844" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00022100" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00180014" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00190972" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000b616" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001fd99c" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001b469c" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002f02" */;
endmodule

//rom9
module rom9 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001a6068" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00124138" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001e2048" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00120000" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00052c86" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001f6808" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001e7826" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002924" */;
endmodule

//rom10
module rom10 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c6b8a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001e4d10" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001e1caa" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00162300" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000b9fa" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001e5fda" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001e5dca" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000be68" */;
endmodule

//rom11
module rom11 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001c3f3e" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00041601" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00052830" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0015002e" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000a899" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001ca8d1" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001cbcd0" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0001168e" */;
endmodule

//rom12
module rom12 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00020014" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0002824c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001b1500" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00080310" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0011bd18" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001dc32a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00196920" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00027e14" */;
endmodule

//rom13
module rom13 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0010050a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0010520c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00150422" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00151cbc" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000082" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001d409a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0015409a" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000024c" */;
endmodule

//rom14
module rom14 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0004224a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001c1b0e" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c0050" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c3a32" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001103d8" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001dbff0" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=001c1e70" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000b86e" */;
endmodule

//rom15
module rom15 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00082ffa" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0014242a" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c0946" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0014048e" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000adc82" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000ec9c6" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000cd9e4" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00006166" */;
endmodule

//rom16
module rom16 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e8002" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0005a410" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c1622" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00092200" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0002cbf2" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000ee75e" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c4fce" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00012d60" */;
endmodule

//rom17
module rom17 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000545a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a746c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00010122" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000022" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00034150" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b4010" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00095524" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000034c2" */;
endmodule

//rom18
module rom18 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e698a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00026342" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c5d0e" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00052942" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0002fcce" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000bea7a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000968e8" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00009cca" */;
endmodule

//rom19
module rom19 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0001ae6a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c0031" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00020e22" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000484a8" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b1ffb" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b9ef7" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00088a86" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000108" */;
endmodule

//rom20
module rom20 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00060870" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001158" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00022024" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00042816" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0002eeec" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0006b4fc" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0004e630" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00004a12" */;
endmodule

//rom21
module rom21 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00095118" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00027910" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f250c" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d0900" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000242bc" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00064548" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0004506a" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000114b0" */;
endmodule

//rom22
module rom22 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0002091a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000a2190" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00071002" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c8e18" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0003d34a" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0007ea46" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00054246" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00009908" */;
endmodule

//rom23
module rom23 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000cb8cc" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00080d84" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d25e8" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b81a8" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000223ee" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000fb7fc" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000db572" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000d02" */;
endmodule

//rom24
module rom24 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000fe720" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c0830" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0004812c" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00020a2a" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0003066c" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f8f28" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000c9368" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000069e0" */;
endmodule

//rom25
module rom25 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00063490" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00002820" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00007498" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00080042" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00082332" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e5136" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00065316" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001d10" */;
endmodule

//rom26
module rom26 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00011a54" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00033a0c" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00040740" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00058834" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000869ba" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000eca2e" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00065f20" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00019690" */;
endmodule

//rom27
module rom27 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000b040a" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00030091" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0008d40e" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00004008" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00099577" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000fc77b" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0003c74a" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001548" */;
endmodule

//rom28
module rom28 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000da040" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00053290" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0002bb40" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000880a" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00080ca8" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000fac4e" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00078ddc" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0000057a" */;
endmodule

//rom29
module rom29 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00078b24" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000de308" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f880c" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000d8414" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00083156" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000f8040" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00079240" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000043da" */;
endmodule

//rom30
module rom30 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00042152" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00030f00" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0007c756" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00050120" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00000b1e" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0007dd5a" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=0007d53a" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001728" */;
endmodule

//rom31
module rom31 (o,a);
input [4:0] a;
output [7:0] o;
ROM32X1 u0 (o[0],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e0408" */;
ROM32X1 u1 (o[1],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00001140" */;
ROM32X1 u2 (o[2],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e20a0" */;
ROM32X1 u3 (o[3],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000e1200" */;
ROM32X1 u4 (o[4],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=00004c18" */;
ROM32X1 u5 (o[5],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000475ac" */;
ROM32X1 u6 (o[6],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000450b4" */;
ROM32X1 u7 (o[7],a[0],a[1],a[2],a[3],a[4]) /* synthesis xc_props="INIT=000038f2" */;
endmodule

