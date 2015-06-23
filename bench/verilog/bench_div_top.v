/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Divider                   Testbench                        ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 Richard Herveille                        ////
////                    richard@asics.ws                         ////
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
//  $Id: bench_div_top.v,v 1.3 2003-09-17 13:09:23 rherveille Exp $
//
//  $Date: 2003-09-17 13:09:23 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.2  2002/10/31 13:53:55  rherveille
//               Modified testbench. Fixed a bug in the remainder output size of div_su.v
//
//               Revision 1.1.1.1  2002/10/29 20:29:08  rherveille
//
//
//               Revision 1.1.1.1  2002/03/26 07:25:12  rherveille
//               First upload
//
//

`include "timescale.v"

module bench_div_top();

	parameter z_width = 16;
	parameter d_width = z_width /2;

	parameter pipeline = d_width +4;

	parameter show_div0 = 0;
	parameter show_ovf  = 0;

	//
	// internal wires
	//
	reg clk;

	integer z, d, n;
	integer dz [pipeline:1];
	integer dd [pipeline:1];
	reg [d_width:1] di;
	reg [z_width:1] zi;

	integer sr, qr;

	wire [d_width   :0] s;
	wire [d_width   :0] q;
	wire div0, ovf;
	reg  [d_width :0] sc, qc;

	integer err_cnt;

	function integer twos;
		input [d_width:1] d;
	begin
	  if(d[d_width])
	    twos = -(~d[d_width:1] +1);
	  else
	    twos = d[d_width:1];
	end
	endfunction

	//
	// hookup division unit
	//
	div_su #(z_width) dut (
		.clk(clk),
		.ena(1'b1),
		.z(zi),
		.d(di),
		.q(q),
		.s(s),
		.div0(div0),
		.ovf(ovf)
	);

	always #2.5 clk <= ~clk;

	always @(posedge clk)
	  for(n=2; n<=pipeline; n=n+1)
	     begin
	         dz[n] <= #1 dz[n-1];
	         dd[n] <= #1 dd[n-1];
	     end

	initial
	begin
	    $display("*");
	    $display("* Starting testbench");
	    $display("*");

`ifdef WAVES
   $shm_open("waves");
   $shm_probe("AS",bench_div_top,"AS");
   $display("INFO: Signal dump enabled ...\n\n");
`endif

	    err_cnt = 0;

	    clk = 0; // start with low-level clock

	    // wait a while
	    @(posedge clk);

	    // present data
	    for(z=-(1<<(z_width -1)); z < 1<<(z_width -1); z=z+1)
	    for(d=0; d< 1<<(z_width/2); d=d+1)
	    begin
	        zi <= #1 z;
	        di <= #1 d;

	        dz[1] <= #1 z;
	        dd[1] <= #1 d;

	        qc = dz[pipeline] / dd[pipeline];
	        sc = dz[pipeline] - (dd[pipeline] * (dz[pipeline]/dd[pipeline]));

	        if(!ovf && !div0)
	          if ( (qc !== q) || (sc !== s) )
	            begin
	                $display("Result error (z/d=%0d/%0d). Received (q,s) = (%0d,%0d), expected (%0d,%0d)",
	                         dz[pipeline], dd[pipeline], twos(q), s, twos(qc), sc);

	                err_cnt = err_cnt +1;
	            end

	          if(show_div0)
	            if(div0)
	              $display("Division by zero (z/d=%0d/%0d)", dz[pipeline], dd[pipeline]);

	          if(show_ovf)
	            if(ovf)
	              $display("Overflow (z/d=%0d/%0d)", dz[pipeline], dd[pipeline]);

	          @(posedge clk);
	    end

	    // wait a while
	    repeat(20) @(posedge clk);

	    $display("*");
	    $display("* Testbench ended. Total errors = %d", err_cnt);
	    $display("*");

	    $stop;
	end

endmodule
