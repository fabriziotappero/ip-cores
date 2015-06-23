/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE Master Model                                      ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/wb_dma/    ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Rudolf Usselmann                         ////
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
//  $Id: wb_mast_model.v,v 1.2 2003-09-23 13:09:25 markom Exp $
//
//  $Date: 2003-09-23 13:09:25 $
//  $Revision: 1.2 $
//  $Author: markom $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.1  2001/08/21 05:42:32  rudi
//
//               - Changed Directory Structure
//               - Added verilog Source Code
//               - Changed IO pin names and defines statements
//
//
//
//                        

`include "wb_model_defines.v"

module wb_mast(clk, rst, adr, din, dout, cyc, stb, sel, we, ack, err, rty);

input		clk, rst;
output	[31:0]	adr;
input	[31:0]	din;
output	[31:0]	dout;
output		cyc, stb;
output	[3:0]	sel;
output		we;
input		ack, err, rty;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[31:0]	adr;
reg	[31:0]	dout;
reg		cyc, stb;
reg	[3:0]	sel;
reg		we;

////////////////////////////////////////////////////////////////////
//
// Memory Logic
//

initial
   begin
	//adr = 32'hxxxx_xxxx;
	//adr = 0;
	adr = 32'hffff_ffff;
	dout = 32'hxxxx_xxxx;
	cyc = 0;
	stb = 0;
	sel = 4'hx;
	we = 1'hx;
	#1;
	$display("\nINFO: WISHBONE MASTER MODEL INSTANTIATED (%m)\n");
   end

////////////////////////////////////////////////////////////////////
//
// Write 1 Word Task
//

task wb_wr1;
input	[31:0]	a;
input	[3:0]	s;
input	[31:0]	d;

begin
@(posedge clk);
#1;
adr = a;
dout = d;
cyc = 1;
stb = 1;
we=1;
sel = s;

@(posedge clk);
while(~ack)	@(posedge clk);
#1;
cyc=0;
stb=0;
adr = 32'hxxxx_xxxx;
dout = 32'hxxxx_xxxx;
we = 1'hx;
sel = 4'hx;

//@(posedge clk);
end
endtask


////////////////////////////////////////////////////////////////////
//
// Write 4 Words Task
//

task wb_wr4;
input	[31:0]	a;
input	[3:0]	s;
input		delay;
input	[31:0]	d1;
input	[31:0]	d2;
input	[31:0]	d3;
input	[31:0]	d4;

integer		delay;

begin

@(posedge clk);
#1;
cyc = 1;
sel = s;

repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
adr = a;
dout = d1;
stb = 1;
we=1;
while(~ack)	@(posedge clk);
#2;
stb=0;
we=1'bx;
dout = 32'hxxxx_xxxx;


repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
stb=1;
adr = a+4;
dout = d2;
we=1;
@(posedge clk);
while(~ack)	@(posedge clk);
#2;
stb=0;
we=1'bx;
dout = 32'hxxxx_xxxx;

repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
stb=1;
adr = a+8;
dout = d3;
we=1;
@(posedge clk);
while(~ack)	@(posedge clk);
#2;
stb=0;
we=1'bx;
dout = 32'hxxxx_xxxx;

repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
stb=1;
adr = a+12;
dout = d4;
we=1;
@(posedge clk);
while(~ack)	@(posedge clk);
#1;
stb=0;
cyc=0;

adr = 32'hxxxx_xxxx;
dout = 32'hxxxx_xxxx;
we = 1'hx;
sel = 4'hx;

end
endtask


////////////////////////////////////////////////////////////////////
//
// Read 1 Word Task
//

task wb_rd1;
input	[31:0]	a;
input	[3:0]	s;
output	[31:0]	d;

begin

@(posedge clk);
#1;
adr = a;
cyc = 1;
stb = 1;
we  = 0;
sel = s;

//@(posedge clk);
while(~ack)	@(posedge clk);
d = din;
#1;
cyc=0;
stb=0;
//adr = 32'hxxxx_xxxx;
//adr = 0;
adr = 32'hffff_ffff;
dout = 32'hxxxx_xxxx;
we = 1'hx;
sel = 4'hx;

end
endtask


////////////////////////////////////////////////////////////////////
//
// Read 4 Words Task
//


task wb_rd4;
input	[31:0]	a;
input	[3:0]	s;
input		delay;
output	[31:0]	d1;
output	[31:0]	d2;
output	[31:0]	d3;
output	[31:0]	d4;

integer		delay;
begin

@(posedge clk);
#1;
cyc = 1;
we = 0;
sel = s;
repeat(delay)	@(posedge clk);

adr = a;
stb = 1;
while(~ack)	@(posedge clk);
d1 = din;
#2;
stb=0;
we = 1'hx;
sel = 4'hx;
repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
we = 0;
sel = s;

adr = a+4;
stb = 1;
@(posedge clk);
while(~ack)	@(posedge clk);
d2 = din;
#2;
stb=0;
we = 1'hx;
sel = 4'hx;
repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
we = 0;
sel = s;


adr = a+8;
stb = 1;
@(posedge clk);
while(~ack)	@(posedge clk);
d3 = din;
#2;
stb=0;
we = 1'hx;
sel = 4'hx;
repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
we = 0;
sel = s;

adr = a+12;
stb = 1;
@(posedge clk);
while(~ack)	@(posedge clk);
d4 = din;
#1;
stb=0;
cyc=0;
we = 1'hx;
sel = 4'hx;
adr = 32'hffff_ffff;
end
endtask


endmodule
