// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_r_rf16x160.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================
 ////////////////////////////////////////////////////////////////////////
// 16 X 160 R1 W1 RF macro
// REad/Write ports can be accessed in PH1 only.
////////////////////////////////////////////////////////////////////////

//FPGA_SYN enables all FPGA related modifications
 



module bw_r_rf16x160(/*AUTOARG*/
   // Outputs
   dout, so_w, so_r, 
   // Inputs
   din, rd_adr, wr_adr, read_en, wr_en, rst_tri_en, word_wen, 
   byte_wen, rd_clk, wr_clk, se, si_r, si_w, reset_l, sehold
   );

   input [159:0]  din; // data input
   input [3:0]    rd_adr;   // read addr 
   input [3:0]	  wr_adr;  // write addr
   input          read_en;  
   input	  wr_en;	//   used in conjunction with
				//  word_wen and byte_wen 
   input	  rst_tri_en ; // gates off writes during SCAN.
   input [3:0]    word_wen; // word enables ( if you don't use these
			    // tie them to Vdd )
   input [19:0]	  byte_wen;	// byte enables ( if you don't use these
                            // tie them to Vdd )
   input          rd_clk;
   input          wr_clk;
   input          se, si_r, si_w ;
   input	  reset_l;
   input	  sehold; // hold scan in data.

   output [159:0] dout;
   output         so_w;
   output         so_r;
   

   // local signals
   reg  [159:0]   wrdata_d1;

   reg  [3:0]     rdptr_d1, wrptr_d1;
   reg            ren_d1;
   reg 	          wr_en_d1;





   wire          so;









   // internal variable
   integer          i, j;
   reg     [159:0]  temp, data_in, tmp_dout;
   reg     [3:0]    word_wen_d1;
   reg     [3:0]    word_wen_d2;
   reg     [19:0]   byte_wen_d1;
   reg			rst_tri_en_d1;


//-------

always @ (posedge wr_clk)
begin
  wrdata_d1[159:0]  <= (sehold) ? wrdata_d1[159:0]  : din[159:0];
  wr_en_d1          <= (sehold) ? wr_en_d1          : wr_en;
  word_wen_d1[3:0]  <= (sehold) ? word_wen_d1[3:0]  : word_wen[3:0];
  word_wen_d2[3:0]  <= (sehold) ? word_wen_d2[3:0]  : (word_wen[3:0] &
				{4{wr_en & ~rst_tri_en}});
  byte_wen_d1[19:0] <= (sehold) ? byte_wen_d1[19:0] : byte_wen[19:0];
  wrptr_d1[3:0]     <= (sehold) ? wrptr_d1[3:0]     : wr_adr[3:0];

  rst_tri_en_d1 <= rst_tri_en ; // not a real flop. ONly used as a trigger.
end
//-------








































































































































































//-------

always @ (posedge rd_clk)
begin
  ren_d1        <= (sehold) ? ren_d1        : read_en;
  rdptr_d1[3:0] <= (sehold) ? rdptr_d1[3:0] : rd_adr[3:0];
end
//-------









bw_r_rf16x2 arr0 (
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[ 0]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[  7:  0]),
	.rd_data(dout[  7:  0]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr1 (
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[ 1]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[ 15:  8]),
	.rd_data(dout[ 15:  8]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr2 (
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[ 2]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[ 23: 16]),
	.rd_data(dout[ 23: 16]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr3 (
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[ 3]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[ 31: 24]),
	.rd_data(dout[ 31: 24]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr4 (
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[ 4]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[ 39: 32]),
	.rd_data(dout[ 39: 32]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr5 (
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[ 5]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[ 47: 40]),
	.rd_data(dout[ 47: 40]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr6 (
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[ 6]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[ 55: 48]),
	.rd_data(dout[ 55: 48]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr7 (
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[ 7]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[ 63: 56]),
	.rd_data(dout[ 63: 56]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr8 (
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[ 8]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[ 71: 64]),
	.rd_data(dout[ 71: 64]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr9 (
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[ 9]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[ 79: 72]),
	.rd_data(dout[ 79: 72]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr10(
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[10]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[ 87: 80]),
	.rd_data(dout[ 87: 80]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr11(
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[11]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[ 95: 88]),
	.rd_data(dout[ 95: 88]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr12(
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[12]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[103: 96]),
	.rd_data(dout[103: 96]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr13(
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[13]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[111:104]),
	.rd_data(dout[111:104]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr14(
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[14]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[119:112]),
	.rd_data(dout[119:112]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr15(
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[15]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[127:120]),
	.rd_data(dout[127:120]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr16(
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[16]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[135:128]),
	.rd_data(dout[135:128]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr17(
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[17]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[143:136]),
	.rd_data(dout[143:136]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr18(
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[18]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[151:144]),
	.rd_data(dout[151:144]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));

bw_r_rf16x2 arr19(
	.word_wen(word_wen_d2),
	.wen(byte_wen_d1[19]),
	.ren(ren_d1),
	.wr_addr(wrptr_d1),
	.rd_addr(rdptr_d1),
	.wr_data(wrdata_d1[159:152]),
	.rd_data(dout[159:152]),
	.clk(wr_clk),
	.rd_clk(rd_clk),
	.reset_l(reset_l));


























































































































































endmodule // rf_16x160



module bw_r_rf16x2(word_wen, wen, ren, wr_addr, rd_addr, wr_data,
	rd_data, clk, rd_clk, reset_l);
  input [3:0] word_wen;
  input	      wen;
  input	      ren;
  input	[3:0] wr_addr;
  input [3:0] rd_addr;
  input [7:0] wr_data;
  output [7:0] rd_data;
  input	clk;
  input	rd_clk;
  input reset_l;

  reg	[7:0] rd_data_temp;

  reg [1:0] inq_ary0[15:0];
  reg [1:0] inq_ary1[15:0];
  reg [1:0] inq_ary2[15:0];
  reg [1:0] inq_ary3[15:0];

  always @(posedge clk) begin
    if(reset_l & wen & word_wen[0])
      inq_ary0[wr_addr] = {wr_data[4],wr_data[0]};
    if(reset_l & wen & word_wen[1])
      inq_ary1[wr_addr] = {wr_data[5],wr_data[1]};
    if(reset_l & wen & word_wen[2])
      inq_ary2[wr_addr] = {wr_data[6],wr_data[2]};
    if(reset_l & wen & word_wen[3])
      inq_ary3[wr_addr] = {wr_data[7],wr_data[3]};
  end

  always @(negedge rd_clk) begin
    if (~reset_l) begin
      rd_data_temp = 8'b0;
    end else if(ren == 1'b1) begin
        rd_data_temp = {inq_ary3[rd_addr], inq_ary2[rd_addr], inq_ary1[rd_addr], inq_ary0[rd_addr]};
    end
  end

  assign rd_data = {rd_data_temp[7], rd_data_temp[5], rd_data_temp[3], 
		rd_data_temp[1], rd_data_temp[6], rd_data_temp[4], 
		rd_data_temp[2], rd_data_temp[0]};

endmodule



