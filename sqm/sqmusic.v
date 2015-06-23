/*
	SQmusic
  Music synthetiser compatible with AY-3-8910 software compatible 
  Version 0.1, tested on simulation only with Capcom's 1942

  (c) Jose Tejada Gomez, 9th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada@ieee.org

*/

/* Capcom arcade boards like 1942 use two memory locations to
communicate with the AY-3-8910 (or compatible) chip.  This small code
provides a 2-byte memory map as expected by Capcom games
*/
`timescale 1ns / 1ps
module AY_3_8910_capcom
#( parameter dump_writes=0, parameter id=0 )
(
	input reset_n,
  input clk, // CPU clock
	input sound_clk, // normally slower than the CPU clock
  input  [7:0] din,
  input  adr,
  input wr_n,  // write
	input cs_n, // chip select
  output [3:0]A,B,C // channel outputs
);

reg [3:0] adr_latch;
wire sample = ~cs_n & ~wr_n;
wire core_wr = adr & sample;
reg count;

always @(posedge clk or negedge reset_n) begin
	if(!reset_n) 
		adr_latch <= 0;
	else 
	if( sample && adr==0 )
		adr_latch <= din[3:0];
end

SQMUSIC #(dump_writes, id) core( .reset_n(reset_n), .clk(sound_clk), .data_in(din),
	.adr( adr_latch ), .rd(1'b0), .wr(core_wr), .A(A), .B(B), .C(C) );
endmodule

//////////////////////////////////////////////////////////////////////////////
/*  The AY core does
*/
module SQMUSIC
#( parameter dump_writes=0, parameter id=0 ) // set to 1 to dump register writes
( // note that input ports are not multiplexed
  input reset_n,
  input clk,
  input  [7:0] data_in,
  output reg [7:0] data_out,
  input  [3:0] adr,
  input rd, // read
  input wr,  // write
  output [3:0]A,B,C // channel outputs
);

reg [7:0] regarray[15:0];
reg [3:0] clkdiv16;

wire [3:0] envelope;
wire [2:0] sqwave;
wire noise, envclk;
wire Amix = (noise|regarray[7][3]) ^ (sqwave[0]|regarray[7][0]);
wire Bmix = (noise|regarray[7][4]) ^ (sqwave[1]|regarray[7][1]);
wire Cmix = (noise|regarray[7][5]) ^ (sqwave[2]|regarray[7][2]);

// internal modules operate at clk/16
SQM_CLK_DIVIDER #(12) chA( .clk(clkdiv16[3]), .reset_n(reset_n), 
  .period({regarray[1][3:0], regarray[0][7:0] }), .div(sqwave[0]) );
SQM_CLK_DIVIDER #(12) chB( .clk(clkdiv16[3]), .reset_n(reset_n), 
  .period({regarray[3][3:0], regarray[2][7:0] }), .div(sqwave[1]) );
SQM_CLK_DIVIDER #(12) chC( .clk(clkdiv16[3]), .reset_n(reset_n), 
  .period({regarray[5][3:0], regarray[4][7:0] }), .div(sqwave[2]) );

// the noise uses a x2 faster clock in order to produce a frequency
// of Fclk/16 when period is 1
SQM_NOISE    ng( .clk(clkdiv16[3]), .reset_n(reset_n), 
  .period(regarray[6][4:0]), .noise(noise) );
// envelope generator
SQM_CLK_DIVIDER #(16) envclkdiv( .clk(clkdiv16[2]), .reset_n(reset_n), 
  .period({regarray[14],regarray[13]}), .div(envclk) );  
SQM_ENVELOPE env( .clk(envclk),.ctrl(regarray[15][3:0]),
  .gain(envelope), .reset_n(reset_n) );

assign A=regarray[10][4]? envelope&{4{Amix}} : regarray[10][3:0]&{4{Amix}};
assign B=regarray[11][4]? envelope&{4{Bmix}} : regarray[10][3:0]&{4{Bmix}};
assign C=regarray[12][4]? envelope&{4{Cmix}} : regarray[10][3:0]&{4{Cmix}};

// 16-count divider
always @(posedge clk or negedge reset_n) begin
  if( !reset_n) 
    clkdiv16<=0;
  else
    clkdiv16<=clkdiv16+1;
end

integer aux;
always @(posedge clk or negedge reset_n) begin
  if( !reset_n ) begin
    data_out=0;
    for(aux=0;aux<=15;aux=aux+1) regarray[aux]=0;
  end
  else begin
    if( rd ) 
      data_out=regarray[ adr ];
    else if( wr ) begin
      regarray[adr]=data_in;
      if( dump_writes ) begin
        $display("#%d, %t, %d, %d", id, $realtime, adr, data_in );
      end
    end
  end
end

endmodule

module SQM_CLK_DIVIDER(   
  clk, // this is the divided down clock from the core
  reset_n,
  period,
	div
);

parameter bw=12;
input clk; // this is the divided down clock from the core
input reset_n;
input [bw-1:0]period;
output div;

reg [bw-1:0]count;
reg clkdiv;

initial clkdiv=0;

assign div = period==1 ? clk : clkdiv;

always @(posedge clk or negedge reset_n) begin
  if( !reset_n) begin
    count<=0;
    clkdiv<=0;
  end
  else begin
    if( period==0 ) begin
      clkdiv<=0;
      count<=0;
    end
    else if( count >= period ) begin
        count <= 0;
        clkdiv <= ~clkdiv;
      end
      else count <= count+1;
  end
end
endmodule

////////////////////////////////////////////////////////////////
module SQM_NOISE(
  input clk, // this is the divided down clock from the core
  input reset_n,
  input [4:0]period,
  output noise
);

reg [5:0]count;
reg [16:0]poly17;
wire poly17_zero = poly17==0;
assign noise=poly17[16];
wire noise_clk;

always @(posedge noise_clk or negedge reset_n) begin
  if( !reset_n) begin
    poly17<=0;
  end
  else begin
     poly17<={ poly17[0] ^ poly17[2] ^ poly17_zero, poly17[16:1] };
  end
end

SQM_CLK_DIVIDER #(5) ndiv( .clk(clk), .reset_n(reset_n), 
  .period(period), .div(noise_clk) );
endmodule

////////////////////////////////////////////////////////////////
module SQM_ENVELOPE(
  input clk, // this is the divided down clock from the core
  input reset_n,
  input [3:0]ctrl,
  output reg [3:0]gain
);

reg dir; // direction
reg stop;
reg [3:0]prev_ctrl; // last control orders

always @(posedge clk or negedge reset_n) begin
  if( !reset_n) begin
    gain<=4'hF;
    dir<=0;
    prev_ctrl<=0;
    stop<=1;
  end
  else begin
    if (ctrl!=prev_ctrl) begin
      prev_ctrl<=ctrl;
      if( ctrl[2] ) begin 
        gain<=0;
        dir<=1;
        stop<=0;
      end
      else begin
        gain<=4'hF;
        dir<=0;
        stop<=0;
      end
    end
    else begin 
      if (!stop) begin
        if( !prev_ctrl[3] && ((gain==0&&!dir) || (gain==4'hF&&dir))) begin
          stop<=1;
          gain<=0;
        end
        else begin
          if( prev_ctrl[0] && ( (gain==0&&!dir) || (gain==4'hF&&dir))) begin // HOLD
            stop<=1;
            gain <= prev_ctrl[1]? ~gain : gain;
          end 
          else begin
            gain <= dir ? gain+1 : gain-1;          
            if( prev_ctrl[1:0]==2'b10 && ( (gain==1&&!dir) || (gain==4'hE&&dir))) begin // ALTERNATE
              dir <= ~dir;
            end
          end
        end
      end
    end
  end
end
endmodule
