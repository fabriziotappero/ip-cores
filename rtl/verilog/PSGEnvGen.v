/* ============================================================================
    (C) 2007  Robert Finch
	All rights reserved.

	PSGEnvGen.v
	Version 1.1

	ADSR envelope generator.

    This source code is available for evaluation and validation purposes
    only. This copyright statement and disclaimer must remain present in
    the file.


	NO WARRANTY.
    THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
    EXPRESS OR IMPLIED. The user must assume the entire risk of using the
    Work.

    IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
    INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
    THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.

    IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
    IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
    REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
    LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
    AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
    LOSSES RELATING TO SUCH UNAUTHORIZED USE.


    Note that this envelope generator directly uses the values for attack,
    decay, sustain, and release. The original SID had to use four bit codes
    and lookup tables due to register limitations. This generator is
	built assuming there aren't any such register limitations.
	A wrapper could be built to provide that functionality.
	
    This component isn't really meant to be used in isolation. It is
    intended to be integrated into a larger audio component (eg SID
    emulator). The host component should take care of wrapping the control
    signals into a register array.

    The 'cnt' signal acts a prescaler used to determine the base frequency
    used to generate envelopes. The core expects to be driven at
    approximately a 1.0MHz rate for proper envelope generation. This is
    accomplished using the 'cnt' signal, which should the output of a
    counter used to divide the master clock frequency down to approximately
    a 1MHz rate. Therefore, the master clock frequency must be at least 4MHz
    for a 4 channel generator, 8MHZ for an 8 channel generator. The test
    system uses a 66.667MHz master clock and 'cnt' is the output of a seven
    bit counter that divides by 66.

    Note the resource space optimization. Rather than simply build a single
    channel ADSR envelope generator and instantiate it four or eight times,
    This unit uses a single envelope generator and time-multiplexes the
    controls from four (or eight) different channels. The ADSR is just
	complex enough that it's less expensive resource wise to multiplex the
	control signals. The luxury of time division multiplexing can be used
	here since audio signals are low frequency. The time division multiplex
	means that we need a clock that's four (or eight) times faster than
	would be needed if independent ADSR's were used. This probably isn't a
	problem for most cases.

	Spartan3
	Webpack 9.1i xc3s1000-4ft256
	522 LUTs / 271 slices / 81.155 MHz (speed)
============================================================================ */

/*
	sample attack values / rates
	----------------------------
	8		2ms
	32		8ms
	64		16ms
	96		24ms
	152		38ms
	224		56ms
	272		68ms
	320		80ms
	400		100ms
	955		239ms
	1998	500ms
	3196	800ms
	3995	1s
	12784	3.2s
	21174	5.3s
	31960	8s

	rate = 990.00ns x 256 x value
*/


// envelope generator states
`define ENV_IDLE	0
`define ENV_ATTACK	1
`define ENV_DECAY	2
`define ENV_SUSTAIN	3
`define ENV_RELEASE	4

// Envelope generator
module PSGEnvGen(rst, clk, cnt,
	gate,
	attack0, attack1, attack2, attack3,
	decay0, decay1, decay2, decay3,
	sustain0, sustain1, sustain2, sustain3,
	relese0, relese1, relese2, relese3,
	o);
	parameter pChannels = 4;
	parameter pPrescalerBits = 8;
	input rst;							// reset
	input clk;							// core clock
	input [pPrescalerBits-1:0] cnt;		// clock rate prescaler
	input [15:0] attack0;
	input [15:0] attack1;
	input [15:0] attack2;
	input [15:0] attack3;
	input [11:0] decay0;
	input [11:0] decay1;
	input [11:0] decay2;
	input [11:0] decay3;
	input [7:0] sustain0;
	input [7:0] sustain1;
	input [7:0] sustain2;
	input [7:0] sustain3;
	input [11:0] relese0;
	input [11:0] relese1;
	input [11:0] relese2;
	input [11:0] relese3;
	input [3:0] gate;
	output [7:0] o;

	reg [7:0] sustain;
	reg [15:0] attack;
	reg [17:0] decay;
	reg [17:0] relese;
	// Per channel count storage
	reg [7:0] envCtr [3:0];
	reg [7:0] envCtr2 [3:0];
	reg [7:0] iv [3:0];			// interval value for decay/release
	reg [2:0] icnt [3:0];		// interval count
	reg [19:0] envDvn [3:0];
	reg [2:0] envState [3:0];

	reg [2:0] envStateNxt;
	reg [15:0] envStepPeriod;	// determines the length of one step of the envelope generator
	reg [7:0] envCtrx;
	reg [19:0] envDvnx;

	// Time multiplexed values
	wire [15:0] attack_x;
	wire [11:0] decay_x;
	wire [7:0] sustain_x;
	wire [11:0] relese_x;

	integer n;

    wire [1:0] sel = cnt[1:0];

	mux4to1 #(16) u1 (
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

	always @(attack_x)
		attack <= attack_x;

	always @(decay_x)
		decay <= decay_x;

	always @(sustain_x)
		sustain <= sustain_x;

	always @(relese_x)
		relese <= relese_x;


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


