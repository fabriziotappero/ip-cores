`timescale 1ns / 1ps
// ============================================================================
//  (C) 2007,2012  Robert Finch
//  robfinch<remove>@opencores.org
//	All rights reserved.
//
//	PSGEnvGen.v
//	Version 1.1
//
//	ADSR envelope generator.
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//
//    This component isn't really meant to be used in isolation. It is
//    intended to be integrated into a larger audio component (eg SID
//    emulator). The host component should take care of wrapping the control
//    signals into a register array.
//
//    The 'cnt' signal acts a prescaler used to determine the base frequency
//    used to generate envelopes. The core expects to be driven at
//    approximately a 1.0MHz rate for proper envelope generation. This is
//    accomplished using the 'cnt' signal, which should the output of a
//    counter used to divide the master clock frequency down to approximately
//    a 1MHz rate. Therefore, the master clock frequency must be at least 4MHz
//    for a 4 channel generator, 8MHZ for an 8 channel generator. The test
//    system uses a 66.667MHz master clock and 'cnt' is the output of a seven
//    bit counter that divides by 66.
//
//    Note the resource space optimization. Rather than simply build a single
//    channel ADSR envelope generator and instantiate it four or eight times,
//    This unit uses a single envelope generator and time-multiplexes the
//    controls from four (or eight) different channels. The ADSR is just
//	complex enough that it's less expensive resource wise to multiplex the
//	control signals. The luxury of time division multiplexing can be used
//	here since audio signals are low frequency. The time division multiplex
//	means that we need a clock that's four (or eight) times faster than
//	would be needed if independent ADSR's were used. This probably isn't a
//	problem for most cases.
//
//	Spartan3
//	Webpack 9.1i xc3s1000-4ft256
//	522 LUTs / 271 slices / 81.155 MHz (speed)
//============================================================================ */

/*
	code sample attack values / rates
	---------------------------------
	0   8		2ms
	1	32		8ms
	2	64		16ms
	3	96		24ms
	4	152		38ms
	5	224		56ms
	6	272		68ms
	7	320		80ms
	8	400		100ms
	9	955		239ms
	10	1998	500ms
	11	3196	800ms
	12	3995	1s
	13	12784	3.2s
	14	21174	5.3s
	15	31960	8s

	rate = 990.00ns x 256 x value
*/


// envelope generator states
`define ENV_IDLE	0
`define ENV_ATTACK	1
`define ENV_DECAY	2
`define ENV_SUSTAIN	3
`define ENV_RELEASE	4

//`define CHANNELS8

// Envelope generator
module PSGEnvGen(rst, clk, cnt,
	gate,
	attack0, attack1, attack2, attack3,
	decay0, decay1, decay2, decay3,
	sustain0, sustain1, sustain2, sustain3,
	relese0, relese1, relese2, relese3,
`ifdef CHANNELS8
	attack4, attack5, attack6, attack7,
	decay4, decay5, decay6, decay7,
	sustain4, sustain5, sustain6, sustain7,
	relese4, relese5, relese6, relese7,
`endif
	o);
	parameter pChannels = 4;
	parameter pPrescalerBits = 5;
	input rst;							// reset
	input clk;							// core clock
	input [pPrescalerBits-1:0] cnt;		// clock rate prescaler
	input [3:0] attack0;
	input [3:0] attack1;
	input [3:0] attack2;
	input [3:0] attack3;
	input [3:0] decay0;
	input [3:0] decay1;
	input [3:0] decay2;
	input [3:0] decay3;
	input [3:0] sustain0;
	input [3:0] sustain1;
	input [3:0] sustain2;
	input [3:0] sustain3;
	input [3:0] relese0;
	input [3:0] relese1;
	input [3:0] relese2;
	input [3:0] relese3;
`ifdef CHANNELS8
	input [7:0] gate;
	input [3:0] attack4;
	input [3:0] attack5;
	input [3:0] attack6;
	input [3:0] attack7;
	input [3:0] decay4;
	input [3:0] decay5;
	input [3:0] decay6;
	input [3:0] decay7;
	input [3:0] sustain4;
	input [3:0] sustain5;
	input [3:0] sustain6;
	input [3:0] sustain7;
	input [3:0] relese4;
	input [3:0] relese5;
	input [3:0] relese6;
	input [3:0] relese7;
`else
	input [3:0] gate;
`endif
	output [7:0] o;

	reg [7:0] sustain;
	reg [15:0] attack;
	reg [17:0] decay;
	reg [17:0] relese;
`ifdef CHANNELS8
	reg [7:0] envCtr [7:0];
	reg [7:0] envCtr2 [7:0];	// for counting intervals
	reg [7:0] iv[7:0];			// interval value for decay/release
	reg [2:0] icnt[7:0];			// interval count
	reg [19:0] envDvn [7:0];
	reg [2:0] envState [7:0];
`else
	reg [7:0] envCtr [3:0];
	reg [7:0] envCtr2 [3:0];
	reg [7:0] iv[3:0];			// interval value for decay/release
	reg [2:0] icnt[3:0];			// interval count
	reg [19:0] envDvn [3:0];
	reg [2:0] envState [3:0];
`endif
	reg [2:0] envStateNxt;
	reg [15:0] envStepPeriod;	// determines the length of one step of the envelope generator
	reg [7:0] envCtrx;
	reg [19:0] envDvnx;

	wire [3:0] attack_x;
	wire [3:0] decay_x;
	wire [3:0] sustain_x;
	wire [3:0] relese_x;

	integer n;

	// Decodes a 4-bit code into an attack value
	function [15:0] AttackDecode;
		input [3:0] atk;
		
		begin
		case(atk)
		4'd0:	AttackDecode = 16'd8;
		4'd1:	AttackDecode = 16'd32;
		4'd2:	AttackDecode = 16'd63;
		4'd3:	AttackDecode = 16'd95;
		4'd4:	AttackDecode = 16'd150;
		4'd5:	AttackDecode = 16'd221;
		4'd6:	AttackDecode = 16'd268;
		4'd7:	AttackDecode = 16'd316;
		4'd8:	AttackDecode = 16'd395;
		4'd9:	AttackDecode = 16'd986;
		4'd10:	AttackDecode = 16'd1973;
		4'd11:	AttackDecode = 16'd3157;
		4'd12:	AttackDecode = 16'd3946;
		4'd13:	AttackDecode = 16'd11837;
		4'd14:	AttackDecode = 16'd19729;
		4'd15:	AttackDecode = 16'd31566;
		endcase
		end

	endfunction

	// Decodes a 4-bit code into a decay/release value
	function [15:0] DecayDecode;
		input [3:0] dec;
		
		begin
		case(dec)
		4'd0:	DecayDecode = 17'd24;
		4'd1:	DecayDecode = 17'd95;
		4'd2:	DecayDecode = 17'd190;
		4'd3:	DecayDecode = 17'd285;
		4'd4:	DecayDecode = 17'd452;
		4'd5:	DecayDecode = 17'd665;
		4'd6:	DecayDecode = 17'd808;
		4'd7:	DecayDecode = 17'd951;
		4'd8:	DecayDecode = 17'd1188;
		4'd9:	DecayDecode = 17'd2971;
		4'd10:	DecayDecode = 17'd5942;
		4'd11:	DecayDecode = 17'd9507;
		4'd12:	DecayDecode = 17'd11884;
		4'd13:	DecayDecode = 17'd35651;
		4'd14:	DecayDecode = 17'd59418;
		4'd15:	DecayDecode = 17'd95068;
		endcase
		end

	endfunction

`ifdef CHANNELS8
    wire [2:0] sel = cnt[2:0];

	always @(sel or
		attack0 or attack1 or attack2 or attack3 or
		attack4 or attack5 or attack6 or attack7)
		case (sel)
		0:	attack_x <= attack0;
		1:	attack_x <= attack1;
		2:	attack_x <= attack2;
		3:	attack_x <= attack3;
		4:	attack_x <= attack4;
		5:	attack_x <= attack5;
		6:	attack_x <= attack6;
		7:	attack_x <= attack7;
		endcase

	always @(sel or
		decay0 or decay1 or decay2 or decay3 or
		decay4 or decay5 or decay6 or decay7)
		case (sel)
		0:	decay_x <= decay0;
		1:	decay_x <= decay1;
		2:	decay_x <= decay2;
		3:	decay_x <= decay3;
		4:	decay_x <= decay4;
		5:	decay_x <= decay5;
		6:	decay_x <= decay6;
		7:	decay_x <= decay7;
		endcase

	always @(sel or
		sustain0 or sustain1 or sustain2 or sustain3 or
		sustain4 or sustain5 or sustain6 or sustain7)
		case (sel)
		0:	sustain <= sustain0;
		1:	sustain <= sustain1;
		2:	sustain <= sustain2;
		3:	sustain <= sustain3;
		4:	sustain <= sustain4;
		5:	sustain <= sustain5;
		6:	sustain <= sustain6;
		7:	sustain <= sustain7;
		endcase

	always @(sel or
		relese0 or relese1 or relese2 or relese3 or
		relese4 or relese5 or relese6 or relese7)
		case (sel)
		0:	relese <= relese0;
		1:	relese <= relese1;
		2:	relese <= relese2;
		3:	relese <= relese3;
		4:	relese <= relese4;
		5:	relese <= relese5;
		6:	relese <= relese6;
		7:	relese <= relese7;
		endcase

`else

    wire [1:0] sel = cnt[1:0];

	mux4to1 #(4) u1 (
		.e(1'b1),
		.s(sel),
		.i0(attack0),
		.i1(attack1),
		.i2(attack2),
		.i3(attack3),
		.z(attack_x)
	);

	mux4to1 #(12) u2 (
		.e(1'b1),
		.s(sel),
		.i0(decay0),
		.i1(decay1),
		.i2(decay2),
		.i3(decay3),
		.z(decay_x)
	);

	mux4to1 #(8) u3 (
		.e(1'b1),
		.s(sel),
		.i0(sustain0),
		.i1(sustain1),
		.i2(sustain2),
		.i3(sustain3),
		.z(sustain_x)
	);

	mux4to1 #(12) u4 (
		.e(1'b1),
		.s(sel),
		.i0(relese0),
		.i1(relese1),
		.i2(relese2),
		.i3(relese3),
		.z(relese_x)
	);

`endif

	always @(attack_x)
		attack <= AttackDecode(attack_x);

	always @(decay_x)
		decay <= DecayDecode(decay_x);

	always @(sustain_x)
		sustain <= {sustain_x,sustain_x};

	always @(relese_x)
		relese <= DecayDecode(relese_x);


	always @(sel)
		envCtrx <= envCtr[sel];

	always @(sel)
		envDvnx <= envDvn[sel];


	// Envelope generate state machine
	// Determine the next envelope state
	always @(sel or gate or sustain)
	begin
		case (envState[sel])
		`ENV_IDLE:
			if (gate[sel])
				envStateNxt <= `ENV_ATTACK;
			else
				envStateNxt <= `ENV_IDLE;
		`ENV_ATTACK:
			if (envCtrx==8'hFE) begin
				if (sustain==8'hFF)
					envStateNxt <= `ENV_SUSTAIN;
				else
					envStateNxt <= `ENV_DECAY;
			end
			else
				envStateNxt <= `ENV_ATTACK;
		`ENV_DECAY:
			if (envCtrx==sustain)
				envStateNxt <= `ENV_SUSTAIN;
			else
				envStateNxt <= `ENV_DECAY;
		`ENV_SUSTAIN:
			if (~gate[sel])
				envStateNxt <= `ENV_RELEASE;
			else
				envStateNxt <= `ENV_SUSTAIN;
		`ENV_RELEASE: begin
			if (envCtrx==8'h00)
				envStateNxt <= `ENV_IDLE;
			else if (gate[sel])
				envStateNxt <= `ENV_SUSTAIN;
			else
				envStateNxt <= `ENV_RELEASE;
			end
		// In case of hardware problem
		default:
			envStateNxt <= `ENV_IDLE;
		endcase
	end

	always @(posedge clk)
		if (rst) begin
		    for (n = 0; n < pChannels; n = n + 1)
		        envState[n] <= `ENV_IDLE;
		end
		else if (cnt < pChannels)
			envState[sel] <= envStateNxt;


	// Handle envelope counter
	always @(posedge clk)
		if (rst) begin
		    for (n = 0; n < pChannels; n = n + 1) begin
		        envCtr[n] <= 0;
		        envCtr2[n] <= 0;
		        icnt[n] <= 0;
		        iv[n] <= 0;
		    end
		end
		else if (cnt < pChannels) begin
			case (envState[sel])
			`ENV_IDLE:
				begin
				envCtr[sel] <= 0;
				envCtr2[sel] <= 0;
				icnt[sel] <= 0;
				iv[sel] <= 0;
				end
			`ENV_SUSTAIN:
				begin
				envCtr2[sel] <= 0;
				icnt[sel] <= 0;
				iv[sel] <= sustain >> 3;
				end
			`ENV_ATTACK:
				begin
				icnt[sel] <= 0;
				iv[sel] <= (8'hff - sustain) >> 3;
				if (envDvnx==20'h0) begin
					envCtr2[sel] <= 0;
					envCtr[sel] <= envCtrx + 1;
				end
				end
			`ENV_DECAY,
			`ENV_RELEASE:
				if (envDvnx==20'h0) begin
					envCtr[sel] <= envCtrx - 1;
					if (envCtr2[sel]==iv[sel]) begin
						envCtr2[sel] <= 0;
						if (icnt[sel] < 3'd7)
							icnt[sel] <= icnt[sel] + 1;
					end
					else
						envCtr2[sel] <= envCtr2[sel] + 1;
				end
			endcase
		end

	// Determine envelope divider adjustment source
	always @(sel or attack or decay or relese)
	begin
		case(envState[sel])
		`ENV_ATTACK:	envStepPeriod <= attack;
		`ENV_DECAY:		envStepPeriod <= decay;
		`ENV_RELEASE:	envStepPeriod <= relese;
		default:		envStepPeriod <= 16'h0;
		endcase
	end


	// double the delay at appropriate points
	// for exponential modelling
	wire [19:0] envStepPeriod1 = {4'b0,envStepPeriod} << icnt[sel];


	// handle the clock divider
	// loadable down counter
	// This sets the period of each step of the envelope
	always @(posedge clk)
		if (rst) begin
			for (n = 0; n < pChannels; n = n + 1)
				envDvn[n] <= 0;
		end
		else if (cnt < pChannels) begin
			if (envDvnx==20'h0)
				envDvn[sel] <= envStepPeriod1;
			else
				envDvn[sel] <= envDvnx - 1;
		end

	assign o = envCtrx;

endmodule


