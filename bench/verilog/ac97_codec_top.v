/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Codec Top Level                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/ac97_ctrl/ ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: ac97_codec_top.v,v 1.2 2002-09-19 06:36:19 rudi Exp $
//
//  $Date: 2002-09-19 06:36:19 $
//  $Revision: 1.2 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.1  2002/02/13 08:22:32  rudi
//
//               Added test bench for public release
//
//
//
//

`include "ac97_defines.v"

module ac97_codec_top(clk, rst,
	sync,
	sdata_out,
	sdata_in
	);

input		clk, rst;

// --------------------------------------
// AC97 Codec Interface
input		sync;
output		sdata_out;
input		sdata_in;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire	[15:0]	out_slt0;
wire	[19:0]	out_slt1;
wire	[19:0]	out_slt2;
wire	[19:0]	out_slt3;
wire	[19:0]	out_slt4;
wire	[19:0]	out_slt5;
wire	[19:0]	out_slt6;
wire	[19:0]	out_slt7;
wire	[19:0]	out_slt8;
wire	[19:0]	out_slt9;
wire	[19:0]	out_slt10;
wire	[19:0]	out_slt11;
wire	[19:0]	out_slt12;

wire	[15:0]	in_slt0;
wire	[19:0]	in_slt1;
reg	[19:0]	in_slt2;
reg	[19:0]	in_slt3;
reg	[19:0]	in_slt4;
reg	[19:0]	in_slt5;
reg	[19:0]	in_slt6;
reg	[19:0]	in_slt7;
reg	[19:0]	in_slt8;
reg	[19:0]	in_slt9;
reg	[19:0]	in_slt10;
reg	[19:0]	in_slt11;
reg	[19:0]	in_slt12;

reg	[19:0]	smem[0:32];
reg	[19:0]	rmem[0:32];

reg	[15:0]	s0;
reg	[19:0]	s1;

integer		rs1_ptr, rs2_ptr;
integer		rs3_ptr, rs4_ptr, rs5_ptr, rs6_ptr, rs7_ptr;
integer		rs8_ptr, rs9_ptr, rs10_ptr, rs11_ptr, rs12_ptr;
integer		is2_ptr, is3_ptr, is4_ptr, is5_ptr, is6_ptr, is7_ptr;
integer		is8_ptr, is9_ptr, is10_ptr, is11_ptr, is12_ptr;
 
reg	[19:0]	rslt0;
reg	[19:0]	rslt1;
reg	[19:0]	rslt2;
reg	[19:0]	rs1_mem[0:256];
reg	[19:0]	rs2_mem[0:256];
reg	[19:0]	rs3_mem[0:256];
reg	[19:0]	rs4_mem[0:256];
reg	[19:0]	rs5_mem[0:256];
reg	[19:0]	rs6_mem[0:256];
reg	[19:0]	rs7_mem[0:256];
reg	[19:0]	rs8_mem[0:256];
reg	[19:0]	rs9_mem[0:256];
reg	[19:0]	rs10_mem[0:256];
reg	[19:0]	rs11_mem[0:256];
reg	[19:0]	rs12_mem[0:256];

reg	[19:0]	is2_mem[0:256];
reg	[19:0]	is3_mem[0:256];
reg	[19:0]	is4_mem[0:256];
reg	[19:0]	is5_mem[0:256];
reg	[19:0]	is6_mem[0:256];
reg	[19:0]	is7_mem[0:256];
reg	[19:0]	is8_mem[0:256];
reg	[19:0]	is9_mem[0:256];
reg	[19:0]	is10_mem[0:256];
reg	[19:0]	is11_mem[0:256];
reg	[19:0]	is12_mem[0:256];

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

task init;
input	mode;

integer	mode;
begin

fill_mem(mode);
clr_ptrs;

end
endtask

task fill_mem;
input	mode;

integer	mode;
integer n;

begin

if(mode==0)
for(n=0;n<256;n=n+1)
   begin
	is2_mem[n] = { 4'h0, n[11:0], 4'h0 };
	is3_mem[n] = { 4'h1, n[11:0], 4'h0 };
	is4_mem[n] = { 4'h2, n[11:0], 4'h0 };
	is5_mem[n] = { 4'h3, n[11:0], 4'h0 };
	is6_mem[n] = { 4'h4, n[11:0], 4'h0 };
	is7_mem[n] = { 4'h5, n[11:0], 4'h0 };
	is8_mem[n] = { 4'h6, n[11:0], 4'h0 };
	is9_mem[n] = { 4'h7, n[11:0], 4'h0 };
	is10_mem[n] = { 4'h8, n[11:0], 4'h0 };
	is11_mem[n] = { 4'h9, n[11:0], 4'h0 };
	is12_mem[n] = { 4'ha, n[11:0], 4'h0 };
   end
else
for(n=0;n<256;n=n+1)
   begin
	is2_mem[n] = $random;
	is3_mem[n] = $random;
	is4_mem[n] = $random;
	is5_mem[n] = $random;
	is6_mem[n] = $random;
	is7_mem[n] = $random;
	is8_mem[n] = $random;
	is9_mem[n] = $random;
	is10_mem[n] = $random;
	is11_mem[n] = $random;
	is12_mem[n] = $random;
   end

end
endtask

always @(posedge clk)
	if(!rst)	s0 = 0;

always @(posedge clk)
	if(!rst)	s1 = 0;

assign in_slt0  = s0;
assign in_slt1  = s1;


//always @(posedge sync)
always @(rslt0 or rslt1 or s0)
	if(s0[13] | (rslt0[14] & rslt1[19]) )
	   begin
		in_slt2 = #1 is2_mem[is2_ptr];
		is2_ptr = is2_ptr + 1;
	   end

always @(posedge sync)
	if(s0[12])
	   begin
		in_slt3 = #1 is3_mem[is3_ptr];
		is3_ptr = is3_ptr + 1;
	   end

always @(posedge sync)
	if(s0[11])
	   begin
		in_slt4 = #1 is4_mem[is4_ptr];
		is4_ptr = is4_ptr + 1;
	   end

always @(posedge sync)
	if(s0[10])
	   begin
		in_slt5 = #1 is5_mem[is5_ptr];
		is5_ptr = is5_ptr + 1;
	   end

always @(posedge sync)
	if(s0[9])
	   begin
		in_slt6 = #1 is6_mem[is6_ptr];
		is6_ptr = is6_ptr + 1;
	   end

always @(posedge sync)
	if(s0[8])
	   begin
		in_slt7 = #1 is7_mem[is7_ptr];
		is7_ptr = is7_ptr + 1;
	   end

always @(posedge sync)
	if(s0[7])
	   begin
		in_slt8 = #1 is8_mem[is8_ptr];
		is8_ptr = is8_ptr + 1;
	   end

always @(posedge sync)
	if(s0[6])
	   begin
		in_slt9 = #1 is9_mem[is9_ptr];
		is9_ptr = is9_ptr + 1;
	   end

always @(posedge sync)
	if(s0[5])
	   begin
		in_slt10 = #1 is10_mem[is10_ptr];
		is10_ptr = is10_ptr + 1;
	   end

always @(posedge sync)
	if(s0[4])
	   begin
		in_slt11 = #1 is11_mem[is11_ptr];
		is11_ptr = is11_ptr + 1;
	   end

always @(posedge sync)
	if(s0[3])
	   begin
		in_slt12 = #1 is12_mem[is12_ptr];
		is12_ptr = is12_ptr + 1;
	   end

always @(posedge sync)
   begin
	rslt0 <= #2 out_slt0;
	rslt1 <= #2 out_slt1;
	rslt2 <= #2 out_slt2;
   end

always @(posedge sync)
	if(out_slt0[15] & out_slt0[14])
	   begin
		rs1_mem[rs1_ptr] = #1 out_slt1;
		rs1_ptr = rs1_ptr + 1;
		//$display("INFO: Codec Register Addr: %h (%t)", out_slt1, $time);
	   end

always @(posedge sync)
	if(out_slt0[15] & out_slt0[13])
	   begin
		rs2_mem[rs2_ptr] = #1 out_slt2;
		rs2_ptr = rs2_ptr + 1;
		//$display("INFO: Codec Register Data: %h (%t)", out_slt2, $time);
	   end

always @(posedge sync)
	if(out_slt0[15] & out_slt0[12])
	   begin
		rs3_mem[rs3_ptr] = #1 out_slt3;
		rs3_ptr = rs3_ptr + 1;
	   end

always @(posedge sync)
	if(out_slt0[15] & out_slt0[11])
	   begin
		rs4_mem[rs4_ptr] = #1 out_slt4;
		rs4_ptr = rs4_ptr + 1;
	   end

always @(posedge sync)
	if(out_slt0[15] & out_slt0[10])
	   begin
		rs5_mem[rs5_ptr] = #1 out_slt5;
		rs5_ptr = rs5_ptr + 1;
	   end

always @(posedge sync)
	if(out_slt0[15] & out_slt0[9])
	   begin
		rs6_mem[rs6_ptr] = #1 out_slt6;
		rs6_ptr = rs6_ptr + 1;
	   end

always @(posedge sync)
	if(out_slt0[15] & out_slt0[8])
	   begin
		rs7_mem[rs7_ptr] = #1 out_slt7;
		rs7_ptr = rs7_ptr + 1;
	   end

always @(posedge sync)
	if(out_slt0[15] & out_slt0[7])
	   begin
		rs8_mem[rs8_ptr] = #1 out_slt8;
		rs8_ptr = rs8_ptr + 1;
	   end

always @(posedge sync)
	if(out_slt0[15] & out_slt0[6])
	   begin
		rs9_mem[rs9_ptr] = #1 out_slt9;
		rs9_ptr = rs9_ptr + 1;
	   end

always @(posedge sync)
	if(out_slt0[15] & out_slt0[5])
	   begin
		rs10_mem[rs10_ptr] = #1 out_slt10;
		rs10_ptr = rs10_ptr + 1;
	   end

always @(posedge sync)
	if(out_slt0[15] & out_slt0[4])
	   begin
		rs11_mem[rs11_ptr] = #1 out_slt11;
		rs11_ptr = rs11_ptr + 1;
	   end

always @(posedge sync)
	if(out_slt0[15] & out_slt0[3])
	   begin
		rs12_mem[rs12_ptr] = #1 out_slt12;
		rs12_ptr = rs12_ptr + 1;
	   end


task clr_ptrs;

begin

rs1_ptr = 0;
rs2_ptr = 0;
rs3_ptr = 0;
rs4_ptr = 0;
rs5_ptr = 0;
rs6_ptr = 0;
rs7_ptr = 0;
rs8_ptr = 0;
rs9_ptr = 0;
rs10_ptr = 0;
rs11_ptr = 0;
rs12_ptr = 0;

is2_ptr = 0;
is3_ptr = 0;
is4_ptr = 0;
is5_ptr = 0;
is6_ptr = 0;
is7_ptr = 0;
is8_ptr = 0;
is9_ptr = 0;
is10_ptr = 0;
is11_ptr = 0;
is12_ptr = 0;

end
endtask


task set_tag;
input		cr;
input	[11:0]	tag;

// s0 - 16 bits
// 15 - Codec Ready
// 14:3 - Slot 1-12 Valid bits
// 2:0 - RESERVED (stuffed with 0)
begin
s0 = {cr, tag, 3'h0};
end
endtask


task set_req;
input	[9:0]	req;

reg	[6:0]	idx;
begin

idx = out_slt1[18:12];
s1 = {1'b0, idx, ~req, 2'h0};

end
endtask


task tx1;
input	fcnt_max;	// Total number fo frames
input	rdy_del;	// How many frames before codec is ready
input	ovalid;		// Out Channels valid (Surround Sound)
input	ivalid;		// In Channels Valid (Mic & Line In)
input	oint;		// Output Intervals
input	iint;		// input Intervals

integer		fcnt_max, f;
integer		rdy_del;
reg	[9:0]	ovalid, ivalid;
reg	[19:0]	oint, iint;

reg		och0_v;
reg	[1:0]	och0_cnt;
reg		och1_v;
reg	[1:0]	och1_cnt;
reg		och2_v;
reg	[1:0]	och2_cnt;
reg		och3_v;
reg	[1:0]	och3_cnt;
reg		och4_v;
reg	[1:0]	och4_cnt;
reg		och5_v;
reg	[1:0]	och5_cnt;
reg		och6_v;
reg	[1:0]	och6_cnt;
reg		och7_v;
reg	[1:0]	och7_cnt;
reg		och8_v;
reg	[1:0]	och8_cnt;
reg		och9_v;
reg	[1:0]	och9_cnt;
reg		ich0_v;
reg	[1:0]	ich0_cnt;
reg		ich1_v;
reg	[1:0]	ich1_cnt;
reg		ich2_v;
reg	[1:0]	ich2_cnt;
reg		ich3_v;
reg	[1:0]	ich3_cnt;
reg		ich4_v;
reg	[1:0]	ich4_cnt;
reg		ich5_v;
reg	[1:0]	ich5_cnt;
reg		ich6_v;
reg	[1:0]	ich6_cnt;
reg		ich7_v;
reg	[1:0]	ich7_cnt;
reg		ich8_v;
reg	[1:0]	ich8_cnt;
reg		ich9_v;
reg	[1:0]	ich9_cnt;

begin

och0_cnt = 0;
och1_cnt = 0;
och2_cnt = 0;
och3_cnt = 0;
och4_cnt = 0;
och5_cnt = 0;
och6_cnt = 0;
och7_cnt = 0;
och8_cnt = 0;
och9_cnt = 0;

ich0_cnt = 0;
ich1_cnt = 0;
ich2_cnt = 0;
ich3_cnt = 0;
ich4_cnt = 0;
ich5_cnt = 0;
ich6_cnt = 0;
ich7_cnt = 0;
ich8_cnt = 0;
ich9_cnt = 0;

for(f=0;f<fcnt_max;f=f+1)
   begin
	while(!sync)	@(posedge clk);
	if(f>rdy_del)
	   begin

		och0_v = ovalid[9] & (och0_cnt == oint[19:18]);
		if(och0_v)	och0_cnt = 0;
		else		och0_cnt = och0_cnt + 1;
		och1_v = ovalid[8] & (och1_cnt == oint[17:16]);
		if(och1_v)	och1_cnt = 0;
		else		och1_cnt = och1_cnt + 1;
		och2_v = ovalid[7] & (och2_cnt == oint[15:14]);
		if(och2_v)	och2_cnt = 0;
		else		och2_cnt = och2_cnt + 1;
		och3_v = ovalid[6] & (och3_cnt == oint[13:12]);
		if(och3_v)	och3_cnt = 0;
		else		och3_cnt = och3_cnt + 1;
		och4_v = ovalid[5] & (och4_cnt == oint[11:10]);
		if(och4_v)	och4_cnt = 0;
		else		och4_cnt = och4_cnt + 1;
		och5_v = ovalid[4] & (och5_cnt == oint[9:8]);
		if(och5_v)	och5_cnt = 0;
		else		och5_cnt = och5_cnt + 1;
		och6_v = ovalid[3] & (och6_cnt == oint[7:6]);
		if(och6_v)	och6_cnt = 0;
		else		och6_cnt = och6_cnt + 1;
		och7_v = ovalid[2] & (och7_cnt == oint[5:4]);
		if(och7_v)	och7_cnt = 0;
		else		och7_cnt = och7_cnt + 1;
		och8_v = ovalid[1] & (och8_cnt == oint[3:2]);
		if(och8_v)	och8_cnt = 0;
		else		och8_cnt = och8_cnt + 1;
		och9_v = ovalid[0] & (och9_cnt == oint[1:0]);
		if(och9_v)	och9_cnt = 0;
		else		och9_cnt = och9_cnt + 1;

		ich0_v = ivalid[9] & (ich0_cnt == iint[19:18]);
		if(ich0_v)	ich0_cnt = 0;
		else		ich0_cnt = ich0_cnt + 1;
		ich1_v = ivalid[8] & (ich1_cnt == iint[17:16]);
		if(ich1_v)	ich1_cnt = 0;
		else		ich1_cnt = ich1_cnt + 1;
		ich2_v = ivalid[7] & (ich2_cnt == iint[15:14]);
		if(ich2_v)	ich2_cnt = 0;
		else		ich2_cnt = ich2_cnt + 1;
		ich3_v = ivalid[6] & (ich3_cnt == iint[13:12]);
		if(ich3_v)	ich3_cnt = 0;
		else		ich3_cnt = ich3_cnt + 1;
		ich4_v = ivalid[5] & (ich4_cnt == iint[11:10]);
		if(ich4_v)	ich4_cnt = 0;
		else		ich4_cnt = ich4_cnt + 1;
		ich5_v = ivalid[4] & (ich5_cnt == iint[9:8]);
		if(ich5_v)	ich5_cnt = 0;
		else		ich5_cnt = ich5_cnt + 1;
		ich6_v = ivalid[3] & (ich6_cnt == iint[7:6]);
		if(ich6_v)	ich6_cnt = 0;
		else		ich6_cnt = ich6_cnt + 1;
		ich7_v = ivalid[2] & (ich7_cnt == iint[5:4]);
		if(ich7_v)	ich7_cnt = 0;
		else		ich7_cnt = ich7_cnt + 1;
		ich8_v = ivalid[1] & (ich8_cnt == iint[3:2]);
		if(ich8_v)	ich8_cnt = 0;
		else		ich8_cnt = ich8_cnt + 1;
		ich9_v = ivalid[0] & (ich9_cnt == iint[1:0]);
		if(ich9_v)	ich9_cnt = 0;
		else		ich9_cnt = ich9_cnt + 1;

		set_tag(1'b1, { 1'b0,		// Slot 1
				1'b0,		// Slot 2
				ich0_v, ich1_v, ich2_v, ich3_v, ich4_v,
				ich5_v, ich6_v, ich7_v, ich8_v, ich9_v} );

		set_req( {	och0_v, och1_v, och2_v, och3_v, och4_v,
				och5_v, och6_v, och7_v, och8_v, och9_v} );

	   end
	while(sync)	@(posedge clk);
   end
end
endtask

////////////////////////////////////////////////////////////////////
//
// Modules
//

ac97_codec_sin	u0(
		.clk(		clk		),
		.rst(		rst		),
		.sync(		sync		),
		.slt0(		out_slt0	),
		.slt1(		out_slt1	),
		.slt2(		out_slt2	),
		.slt3(		out_slt3	),
		.slt4(		out_slt4	),
		.slt5(		out_slt5	),
		.slt6(		out_slt6	),
		.slt7(		out_slt7	),
		.slt8(		out_slt8	),
		.slt9(		out_slt9	),
		.slt10(		out_slt10	),
		.slt11(		out_slt11	),
		.slt12(		out_slt12	),
		.sdata_in(	sdata_in	)
		);

ac97_codec_sout	u1(
		.clk(		clk		),
		.rst(		rst		),
		.sync(		sync		),
		.slt0(		in_slt0		),
		.slt1(		in_slt1		),
		.slt2(		in_slt2		),
		.slt3(		in_slt3		),
		.slt4(		in_slt4		),
		.slt5(		in_slt5		),
		.slt6(		in_slt6		),
		.slt7(		in_slt7		),
		.slt8(		in_slt8		),
		.slt9(		in_slt9		),
		.slt10(		in_slt10	),
		.slt11(		in_slt11	),
		.slt12(		in_slt12	),
		.sdata_out(	sdata_out	)
		);

endmodule


