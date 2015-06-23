//=============================================================================
//	2007,2010  Robert Finch
//	robfinch@FPGAfield.ca
//
//	PSG16.v 
//		4 Channel ADSR sound generator
//
//	This source code is available only for veiwing, testing and evaluation
//	purposes. Any commercial use requires a license. This copyright
//	statement and disclaimer must remain present in the file.
//
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//	EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//	Work.
//
//	IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//	IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//	IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//	REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//	LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//	AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//	LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
//
//	Registers
//	0	    ffffffff ffffffff	freq [15:0]
//	1	    ----pppp pppppppp	pulse width [11:0]
//	2	    trsg--fo -vvvvv-- 	test, ringmod, sync, gate, filter, output, voice type
//											vvvvv
//											wnpst
//	3	    -------- --------  	reserved
//	4	    aaaaaaaa aaaaaaaa 	attack
//	5	    ----dddd dddddddd 	decay
//	6	    -------- ssssssss	sustain
//	7	    ----rrrr rrrrrrrr	release
//	...
//	64      -------- ----vvvv   volume (0-15)
//	65      nnnnnnnn nnnnnnnn   osc3 oscillator 3
//	66      -------- nnnnnnnn   env3 envelope 3
//	67
//	68      aa------ --------   wave table address a15-14
//	69      aaaaaaaa aaaaaaaa   wave table address a31-16
//
//  80-87   s---kkkk kkkkkkkk   filter coefficients
//  88-96   -------- --------   reserved for more filter coefficients
//
//
//	Spartan3
//	Webpack 12.3  xc3s1200e-4fg320
//	1290 LUTs / 893 slices / 69.339 MHz
//	1 Multipliers
//=============================================================================

module PSG16(rst_i, clk_i, cyc_i, stb_i, ack_o, we_i, sel_i, adr_i, dat_i, dat_o,
	vol_o, bg, 
	m_cyc_o, m_stb_o, m_ack_i, m_we_o, m_sel_o, m_adr_o, m_dat_i, o
);
parameter pClkDivide = 66;

// WISHBONE SYSCON
input rst_i;
input clk_i;			// system clock
// WISHBONE SLAVE
input cyc_i;			// cycle valid
input stb_i;			// circuit select
output ack_o;
input we_i;				// write
input  [1:0] sel_i;		// byte selects
input [43:0] adr_i;		// address input
input [15:0] dat_i;		// data input
output [15:0] dat_o;	// data output
// WISHBONE MASTER
output m_cyc_o;			// bus request
output m_stb_o;			// strobe output
input m_ack_i;
output m_we_o;			// write enable (always inactive)
output [ 1:0] m_sel_o;	// byte lane selects
output [43:0] m_adr_o;	// wave table address
input  [11:0] m_dat_i;	// wave table data input

output vol_o;

input bg;				// bus grant

output [11:0] o;

// I/O registers
reg [15:0] dat_o;
reg vol_o;
reg [43:0] m_adr_o;

reg [3:0] test;				// test (enable note generator)
reg [4:0] vt [3:0];			// voice type
reg [15:0] freq0, freq1, freq2, freq3;	// frequency control
reg [11:0] pw0, pw1, pw2, pw3;			// pulse width control
reg [3:0] gate;
reg [15:0] attack0, attack1, attack2, attack3;
reg [11:0] decay0, decay1, decay2, decay3;
reg [7:0] sustain0, sustain1, sustain2, sustain3;
reg [11:0] relese0, relese1, relese2, relese3;
reg [3:0] sync;
reg [3:0] ringmod;
reg [3:0] outctrl;
reg [3:0] filt;                // 1 = output goes to filter
wire [23:0] acc0, acc1, acc2, acc3;
reg [3:0] volume;	// master volume
wire [11:0] ngo;	// not generator output
wire [7:0] env;		// envelope generator output
wire [7:0] env3;
wire [7:0] ibr;
wire [7:0] ibg;
wire [21:0] out1;
wire [21:0] out3;
wire [19:0] out4;
wire [21:0] filtin1;	// FIR filter input
wire [14:0] filt_o;		// FIR filter output

wire cs = cyc_i && stb_i && (adr_i[43:8]==36'hFFF_FFD4_00);
assign m_cyc_o = |ibr & ~bg;
assign m_stb_o = m_cyc_o;
assign m_we_o  = 1'b0;
assign m_sel_o = {m_cyc_o,m_cyc_o};
assign ack_o = cs;
wire my_ack = m_ack_i;

// write to registers
always @(posedge clk_i)
begin
	if (rst_i) begin
		freq0 <= 0;
		freq1 <= 0;
		freq2 <= 0;
		freq3 <= 0;
		pw0 <= 0;
		pw1 <= 0;
		pw2 <= 0;
		pw3 <= 0;
		test <= 0;
		vt[0] <= 0;
		vt[1] <= 0;
		vt[2] <= 0;
		vt[3] <= 0;
		gate <= 0;
		outctrl <= 0;
		filt <= 0;
		attack0 <= 0;
		attack1 <= 0;
		attack2 <= 0;
		attack3 <= 0;
		decay0 <= 0;
		sustain0 <= 0;
		relese0 <= 0;
		decay1 <= 0;
		sustain1 <= 0;
		relese1 <= 0;
		decay2 <= 0;
		sustain2 <= 0;
		relese2 <= 0;
		decay3 <= 0;
		sustain3 <= 0;
		relese3 <= 0;
		sync <= 0;
		ringmod <= 0;
		volume <= 0;
		m_adr_o[31:14] <= 18'b0000_0000_0000_0011_10;	// 00038000
	end
	else begin
		if (ack_o & we_i) begin
			case(adr_i[7:1])
			7'd0:
					begin
						if (sel_i[0]) freq0[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) freq0[15:8] <= dat_i[15:8];
					end
			7'd1:
					begin 
						if (sel_i[0]) pw0[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) pw0[11:8] <= dat_i[11:8];
					end
			7'd2:	begin
						if (sel_i[0]) vt[0] <= dat_i[6:2];
						if (sel_i[1]) begin
							outctrl[0] <= dat_i[8];
							filt[0] <= dat_i[9];
							gate[0] <= dat_i[12];
							sync[0] <= dat_i[13];
							ringmod[0] <= dat_i[14]; 
							test[0] <= dat_i[15];
						end
					end
			7'd3:	;
			7'd4:	attack0 <= dat_i;
			7'd5:	decay0 <= dat_i;
			7'd6:	if (sel_i[0]) sustain0 <= dat_i;
			7'd7:	relese0 <= dat_i;

			7'd8:
					begin
						if (sel_i[0]) freq1[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) freq1[15:8] <= dat_i[15:8];
					end
			7'd9:
					begin
						if (sel_i[0]) pw1[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) pw1[11:8] <= dat_i[11:8];
					end
			7'd10:	begin
						if (sel_i[0]) vt[1] <= dat_i[6:2];
						if (sel_i[1]) begin
							outctrl[1] <= dat_i[8];
							filt[1] <= dat_i[9];
							gate[1] <= dat_i[12];
							sync[1] <= dat_i[13];
							ringmod[1] <= dat_i[14]; 
							test[1] <= dat_i[15];
						end
					end
			7'd11: ;
			7'd12:	attack1 <= dat_i;
			7'd13:	decay1 <= dat_i;
			7'd14:	if (sel_i[0]) sustain1 <= dat_i;
			7'd15:	relese1 <= dat_i;

			7'd16:
					begin
						if (sel_i[0]) freq2[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) freq2[15:8] <= dat_i[15:8];
					end
			7'd17:
					begin
						if (sel_i[0]) pw2[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) pw2[11:8] <= dat_i[11:8];
					end
			7'd18:	begin
						if (sel_i[0]) vt[2] <= dat_i[6:2];
						if (sel_i[1]) begin
							outctrl[2] <= dat_i[8];
							filt[2] <= dat_i[9];
							gate[2] <= dat_i[12];
							sync[2] <= dat_i[5];
							outctrl[0] <= dat_i[13];
							ringmod[2] <= dat_i[14]; 
							test[2] <= dat_i[15];
						end
					end
			7'd19: ;
			7'd20:	attack2 <= dat_i;
			7'd21:	decay2 <= dat_i;
			7'd22:	if (sel_i[0]) sustain2 <= dat_i;
			7'd23:	relese2 <= dat_i;

			7'd24:
					begin
						if (sel_i[0]) freq3[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) freq3[15:8] <= dat_i[15:8];
					end
			7'd25:
					begin
						if (sel_i[0]) pw3[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) pw3[11:8] <= dat_i[11:8];
					end
			7'd26:	begin
						if (sel_i[0]) vt[3] <= dat_i[6:2];
						if (sel_i[1]) begin
							outctrl[3] <= dat_i[8];
							filt[3] <= dat_i[9];
							gate[3] <= dat_i[12];
							sync[3] <= dat_i[13];
							ringmod[3] <= dat_i[14]; 
							test[3] <= dat_i[15];
						end
					end
			7'd27: ;
			7'd28:	attack3 <= dat_i;
			7'd29:	decay3 <= dat_i;
			7'd30:	if (sel_i[0]) sustain3 <= dat_i;
			7'd31:	relese3 <= dat_i;

			7'd64:	if (sel_i[0]) volume <= dat_i[3:0];

			7'd68:	begin
						if (sel_i[1]) m_adr_o[15:14] <= dat_i[15:14];
					end
			7'd69:
					begin
						if (sel_i[0]) m_adr_o[23:16] <= dat_i[ 7:0];
						if (sel_i[1]) m_adr_o[31:24] <= dat_i[15:8];
					end
			7'd70:	begin
						if (sel_i[0]) m_adr_o[39:32] <= dat_i[ 7:0];
						if (sel_i[1]) m_adr_o[43:40] <= dat_i[11:8];
					end
			default:	;
			endcase
		end
	end
end


always @(adr_i or acc3 or env3 or cs)
begin
	if (cs) begin
		case(adr_i[6:0])
		7'd65:	begin
				vol_o <= 1'b1;
				dat_o <= acc3[23:8];
				end
		7'd66:	begin
				vol_o <= 1'b1;
				dat_o <= env3;
				end
		default: begin
				dat_o <= env3;
				vol_o <= 1'b0;
				end
		endcase
	end
	else begin
		dat_o <= 16'b0;
		vol_o <= 1'b0;
	end
end

wire [3:0] ibg1 = ibg & {4{bg}};
wire [11:0] alow;

// set wave table output address
always @(ibg1 or acc1 or acc0 or acc2 or acc3 or alow)
begin
	m_adr_o[13:12] <= {ibg1[2]|ibg1[3],ibg1[1]|ibg1[3]};
	m_adr_o[11:0] <= alow;
end

mux4to1 #(12) u11
(
	.e(1'b1),
	.s(m_adr_o[13:12]),
	.i0({acc0[23:13],1'b0}),
	.i1({acc1[23:13],1'b0}),
	.i2({acc2[23:13],1'b0}),
	.i3({acc3[23:13],1'b0}),
	.z(alow)
);

// This counter controls channel multiplexing and the base
// operating frequency.
wire [7:0] cnt;
counter #(8) u1
(
	.rst(rst_i),
	.clk(clk_i),
	.ce(1'b1),
	.ld(cnt!=pClkDivide),
	.d(8'd1),
	.q(cnt)
);

// channel select signal
wire [1:0] sel = cnt[1:0];


// bus arbitrator for wave table access
wire [2:0] bgn;
PSGBusArb u2
(
	.rst(rst_i),
	.clk(clk_i),
	.ce(1'b1),
	.ack(1'b1), .seln(bgn),
	.req0(ibr[0]), .req1(ibr[1]), .req2(ibr[2]), .req3(ibr[3]),
	.sel0(ibg[0]), .sel1(ibg[1]), .sel2(ibg[2]), .sel3(ibg[3]),
	.req4(1'b0), .req5(1'b0), .req6(1'b0), .req7(1'b0),
	.sel4(), .sel5(), .sel6(), .sel7()
);

// note generator - multi-channel
PSGNoteGen u3
(
	.rst(rst_i), .clk(clk_i),
	.cnt(cnt), .br(ibr), .bg(ibg1), .ack(my_ack), .bgn(bgn),
	.test(test),
	.vt0(vt[0]), .vt1(vt[1]), .vt2(vt[2]), .vt3(vt[3]), 
	.freq0(freq0), .freq1(freq1), .freq2(freq2), .freq3(freq3),
	.pw0(pw0), .pw1(pw1), .pw2(pw2), .pw3(pw3),
	.acc0(acc0), .acc1(acc1), .acc2(acc2), .acc3(acc3),
	.wave(m_dat_i),
	.sync(sync),
	.ringmod(ringmod),
	.o(ngo)
);

// envelope generator - multi-channel
PSGEnvGen u4
(
	.rst(rst_i),
	.clk(clk_i),
	.cnt(cnt),
	.gate(gate),
	.attack0(attack0), .attack1(attack1), .attack2(attack2), .attack3(attack3),
	.decay0(decay0), .decay1(decay1), .decay2(decay2), .decay3(decay3),
	.sustain0(sustain0), .sustain1(sustain1), .sustain2(sustain2), .sustain3(sustain3),
	.relese0(relese0), .relese1(relese1), .relese2(relese2), .relese3(relese3),
	.o(env)
);

// shape output according to envelope
PSGShaper u5
(
	.clk_i(clk_i),
	.ce(1'b1),
	.tgi(ngo),
	.env(env),
	.o(out2)
);

// Sum the channels not going to the filter
PSGChannelSummer u6
(
	.clk_i(clk_i),
	.cnt(cnt),
	.outctrl(outctrl),
	.tmc_i(out2),
	.o(out1)
);

// Sum the channels going to the filter
PSGChannelSummer u7
(
	.clk_i(clk_i),
	.cnt(cnt),
	.outctrl(filt),
	.tmc_i(out2),
	.o(filtin1)
);

// The FIR filter
PSGFilter u8
(
	.rst(rst_i),
	.clk(clk_i),
	.cnt(cnt),
	.wr(we_i && stb_i && adr_i[6:4]==3'b101),
    .adr(adr_i[3:0]),
    .din({dat_i[15],dat_i[11:0]}),
    .i(filtin1[21:7]),
    .o(filt_o)
);

// Sum the filtered and unfiltered output
PSGOutputSummer u9
(
	.clk_i(clk_i),
	.cnt(cnt),
	.ufi(out1),
	.fi({filt_o,7'b0}),
	.o(out3)
);

// Last stage:
// Adjust output according to master volume
PSGMasterVolumeControl u10
(
	.rst_i(rst_i),
	.clk_i(clk_i),
	.i(out3[21:6]),
	.volume(volume),
	.o(out4)
);

assign o = out4[19:8];

endmodule

