/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores Memory Controller Testbench                      ////
////  Additional checks                                          ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/mem_ctrl/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001, 2002 Richard Herveille                  ////
////                          richard@asics.ws                   ////
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
//  $Id: checkers.v,v 1.1 2002-03-06 15:10:34 rherveille Exp $
//
//  $Date: 2002-03-06 15:10:34 $
//  $Revision: 1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//

`include "timescale.v"

//////////////////////////////
// external bus-master model
//

module bm_model(br, bg, chk);

	// parameters
	reg on_off;

	// inputs
	output br;
	reg br;
	input  bg;
	input chk;

	integer delay;

	initial
		begin
			on_off = 0;
			br = 1'b0;
		end

	always
	begin
		wait(on_off)

		delay = ($random >> 24) +10;

		// wait a random moment
		# delay;

		// assert bus_request
		br = 1'b1;
		$display("External bus-master requesting bus at time %t... ", $time);

		// wait for assertion of bus_grant
		wait(bg);
		$display("Bus granted at time %t.", $time);

		// check the memory controller output_enable signal, should be negated
		if (chk)
			$display("Memory controller output signals not in tri-state.");

		delay = ($random >> 24) +10;
				
		// wait a random moment
		# delay;

		// negate bus_request					
		br = 1'b0;
		$display("External bus-master releasing bus at time %t ...", $time);

		// wait for negation of bus_grant
		wait(!bg);
		$display("Bus released at time %t.", $time);

	end
endmodule


//
// WISHBONE Bus Watchdog
//
module watch_dog(clk, cyc_i, ack_i, adr_i);

	// parameters
	parameter count = 1000;

	// inputs
	input clk;
	input cyc_i;
	input ack_i;
	input [31:0] adr_i;

	// variables
	integer cnt;

	// module body
	always@(posedge clk)
		if (!cyc_i || ack_i)
			cnt <= #1 count;
		else
			begin
				cnt <= #1 cnt -1;

				if (cnt == 0)
					begin
						$display("\n\n WATCHDOG TIMER EXPIRED \n\n");
						$display("Time: %t, address: %h", $time, adr_i);
						$stop;
					end
			end
endmodule


//
// Check status of Wishbone ERR_O line
//

module err_check(err, sel_par);

	//
	// inputs
	//
	input err;
	input sel_par;

	//
	// module body
	//
	always@(err)
		case (err)
			1'b1:
				if(sel_par)
					begin
						$display("*");
						$display("* ERROR: WISHBONE ERR_O asserted at time %t", $time);
						$display("*");
					end
				else
						$display("Wishbone ERR_O asserted (ok)");
	
			1'bx:
				begin
					$display("*");
					$display("* ERROR: WISHBONE ERR_O undefined at time %t", $time);
					$display("*");
				end
		endcase
endmodule

//
// Check status of Wishbone ERR_O line
//

module cs_check(cs);

	//
	// inputs
	//
	input [7:0] cs;

	//
	// module body
	//
	always@(cs)
	begin
		if ((cs[7] == 1'bx) | (cs[6] == 1'bx) | (cs[5] == 1'bx) | (cs[4] == 1'bx) | 
		    (cs[3] == 1'bx) | (cs[2] == 1'bx) | (cs[1] == 1'bx) | (cs[0] == 1'bx) )
			begin
				$display("*");
				$display("* ERROR: CHIP SELECT SIGNAL UNDEFINED at time %t", $time);
				$display("*");
			end

		if ((!cs[7] & !(&cs[6:0])            ) |
		    (!cs[6] & !(&{cs[7]  , cs[5:0]}) ) |
		    (!cs[5] & !(&{cs[7:6], cs[4:0]}) ) |
		    (!cs[4] & !(&{cs[7:5], cs[3:0]}) ) |
		    (!cs[3] & !(&{cs[7:4], cs[2:0]}) ) |
		    (!cs[2] & !(&{cs[7:3], cs[1:0]}) ) |
		    (!cs[1] & !(&{cs[7:2], cs[0]}  ) ) |
		    (!cs[0] & !(&cs[7:1])          )   )
			begin
				$display("*");
				$display("* ERROR: MULTIPLE CHIP SELECT SIGNALS ASSERTED at time %t", $time);
				$display("*");
			end
	end

endmodule

