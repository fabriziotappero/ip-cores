/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Synchronous Chip Select Device Model                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/mem_ctrl/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000 Rudolf Usselmann                         ////
////                    rudi@asics.ws                            ////
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
//  $Id: sync_cs_dev.v,v 1.1 2001-07-29 07:34:40 rudi Exp $
//
//  $Date: 2001-07-29 07:34:40 $
//  $Revision: 1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.1.1.1  2001/05/13 09:36:38  rudi
//               Created Directory Structure
//
//
//
//                        

module sync_cs_dev(clk, addr, dq, cs_, we_, oe_, ack_ );
input		clk;
input	[15:0]	addr;
inout	[31:0]	dq;
input		cs_, we_, oe_;
output		ack_;

reg	[31:0]	data_o;
reg	[31:0]	mem[0:1024];
wire		rd, wr;

integer		rd_del;
reg	[31:0]	rd_r;
wire		rd_d;

integer		wr_del;
reg	[31:0]	wr_r;
wire		wr_d;

integer		ack_del;
reg	[31:0]	ack_r;
wire		ack_d;

initial	ack_del = 2;
initial	rd_del  = 7;
initial	wr_del  = 3;

task mem_fill;

integer n;

begin

for(n=0;n<1024;n=n+1)
	mem[n] = $random;

end
endtask


assign dq = rd_d ? data_o : 32'hzzzz_zzzz;

assign rd = ~cs_ &  we_ & ~oe_;
assign wr = ~cs_ & ~we_;

always @(posedge clk)
	if(~rd)		rd_r <= #1 0;
	else		rd_r <= #1 {rd_r[30:0], rd};
assign rd_d = rd_r[rd_del] & rd;

always @(posedge clk)
	if(~wr)		wr_r <= #1 0;
	else		wr_r <= #1 {wr_r[30:0], wr};
assign wr_d = wr_r[wr_del] & wr;

always @(posedge clk)
	data_o <= #1 mem[addr[9:0]];

always @(posedge clk)
	if(wr_d) mem[addr[9:0]] <= #1 dq;

assign ack_d = rd | wr;
always @(posedge clk)
	if(~rd & ~wr)	ack_r <= #1 0;
	else		ack_r <= #1 {ack_r[30:0], ack_d};

assign	ack_ = ack_r[ack_del] & ack_d;

endmodule
