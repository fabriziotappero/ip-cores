///////////////////////////////////////////////////////////////////////
////                                                               ////
////  CY7C185 model (Cypress 8kx8 fast asynchronous sram)          ////
////                                                               ////
////                                                               ////
////  Author: Richard Herveille                                    ////
////          richard@asics.ws                                     ////
////          www.asics.ws                                         ////
////                                                               ////
////  Downloaded from: http://www.opencores.org/projects/mem_ctrl  ////
////                                                               ////
///////////////////////////////////////////////////////////////////////
////                                                               ////
//// Copyright (C) 2002 Richard Herveille                          ////
////                    richard@asics.ws                           ////
////                                                               ////
//// This source file may be used and distributed without          ////
//// restriction provided that this copyright statement is not     ////
//// removed from the file and that any derivative work contains   ////
//// the original copyright notice and the associated disclaimer.  ////
////                                                               ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY       ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED     ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS     ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR        ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,           ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES      ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE     ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR          ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF    ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT    ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT    ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE           ////
//// POSSIBILITY OF SUCH DAMAGE.                                   ////
////                                                               ////
///////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: m8kx8.v,v 1.1 2002-03-06 15:15:35 rherveille Exp $
//
//  $Date: 2002-03-06 15:15:35 $
//  $Revision: 1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
//

`timescale 1ns/10ps

module A8Kx8(Address, dataIO, OEn, CE1n, CE2, WEn);

	//
	// parameters
	//
	
	//
	// inputs & outputs
	//
	input [12:0] Address;
	inout [ 7:0] dataIO;
	input        OEn;
	input        CE1n;
	input        CE2;
	input        WEn;

	//
	// variables
	//
	reg [ 7:0] mem_array  [8191:0];

	reg delayed_WE;
	reg [ 7:0] data_temp, dataIO1;
	reg is_write;

	wire CE = !CE1n && CE2;
	reg OE_OEn, OE_CE;
	wire OE = OE_OEn && OE_CE;

	reg read_cycle1, read_cycle2;

	time Trc;
	time Taa;
	time Toha;
	time Tace;
	time Tdoe;
	time Tlzoe;
	time Thzoe;
	time Tlzce;
	time Thzce;

	time Twc;
	time Tsce;
	time Taw;
	time Tpwe;
	time Tsd;
	time Thzwe;
	time Tlzwe;
	
	time CE_start, CE_end;
	time write_WE_start, read_WE_start;
	time dataIO_start;	
	time Address_start;
	time OEn_start,  OEn_end;

	initial
		begin
			read_cycle1 = 1'b0;
			read_cycle2 = 1'b0;

			// read cycle
			Trc   = 20;
			Taa   = 20;
			Toha  = 5;
			Tace  = 20;
			Tdoe  = 9;
			Tlzoe = 3;
			Thzoe = 8;
			Tlzce = 5; // not completely accurate. Tlzce2 = 3ns
			Thzce = 8;

			// write cycle
			Twc   = 20;
			Tsce  = 15;
			Taw   = 15;
			Tpwe  = 15;
			Tsd   = 10;
			Thzwe = 7;
			Tlzwe = 5;
		end

	//
	// module body
	//

	// assign output
	assign dataIO = (OE && !delayed_WE) ? data_temp : 8'bz;

	// assign times

	always@(posedge CE)
		begin
			CE_start <= $time;

			#Tlzce OE_CE <= CE;
		end

	always@(negedge CE)
		begin
			CE_end <= $time;

			#Thzce OE_CE <= CE;
		end

	always@(dataIO)
		begin
			dataIO_start <= $time;
		end

	always@(negedge WEn)
		begin
			write_WE_start <= $time;

			# Thzwe delayed_WE <= !WEn;
		end

	always@(posedge WEn)
		begin
			read_WE_start <= $time;

			#Tlzwe delayed_WE <= !WEn;
		end

	always@(Address)
		begin
			Address_start <= $time;
		end

	always@(negedge OEn)
		begin
			OEn_start <= $time;

			#Tlzoe OE_OEn <= !OEn;
		end

	always@(posedge OEn)
		begin
			OEn_end <= $time;

			#Thzoe OE_OEn <= !OEn;
		end
	//
	// write cycles
	//

	always@(WEn or CE)
		is_write <= !WEn && CE;

	// write cycle no.1 & no.3 WE controlled
	always@(posedge WEn or negedge CE)
		begin
			// check if CE asserted ( CE1n == 1'b0 && CE2 == 1'b1)
			if (is_write)
			begin

				// check WE valid time
				if ( ($time - write_WE_start) >= Tpwe)
				begin

					// check CE valid time
					if ( ($time - CE_start) >= Tsce)
					begin

						// check data_in setup-time
						if ( ($time - dataIO_start) >= Tsd)
						begin

							// check address valid time
							if ( ($time - Address_start >= Taw) )
								mem_array[Address] <= dataIO;
							else
								$display("Address setup to WE write end violation at time %t", $time);
						end
						else
							$display("Data setup to WE write end violation at time %t", $time);
					end
					else
						$display("CE to WE write end violation at time %t", $time);
				end
				else
					$display("WE pulse width violation at time %t", $time);
			end
		end


	//
	// Read cycles
	//

	always@(Address or WEn or CE or OEn)
		begin
			// check if valid read cycle
			if (CE && WEn)
				begin
					if ( (($time - CE_start) >= Trc) && (CE_start >= CE_end) &&
							(($time - OEn_start) >= Trc) && (OEn_start >= OEn_end) ) // ???
						begin

							// check Trc
							if ( ($time - Address_start < Trc) )
							begin
								$display("Read cycle time violation, caused by address change at time %t", $time);
								$display("CE: %t, OEn: %t, Adr: %t", $time - CE_start, $time - OEn_start, $time - Address_start);
							end

							// read cycle no.1
							read_cycle1 <= 1'b1;
							read_cycle2 <= 1'b0;
						end
					else
						begin
							// read cycle no.2
							read_cycle1 <= 1'b0;
							read_cycle2 <= 1'b1;
						end
				end
			else
				begin
					read_cycle1 = 1'b0;
					read_cycle2 = 1'b0;
				end
		end


	// perform actual read
	always
		begin
			#1;
			if (read_cycle1)
				if ( ($time - Address_start) >= Taa)
					data_temp <= mem_array[Address];
				else if ( ($time - Address_start >= Toha) )
					data_temp <= 8'bx;

			if (read_cycle2)
				if ( (($time - OEn_start) >= Tdoe) && (($time - CE_start) >= Tace) )
					data_temp <= mem_array[Address];
				else if ( (($time - OEn_start) >= Tlzoe) && (($time - CE_start) >= Tlzce) )
					data_temp <= 8'bx;
		end

endmodule



