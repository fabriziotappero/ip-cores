//                              -*- Mode: Verilog -*-
// Filename        : oks8.v
// Description     : OKS8 CPU Top Level without peripherals
// Author          : Jian Li
// Created On      : Sat Jan 07 09:09:49 2006
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

/*
 * Copyright (C) 2006 to Jian Li
 * Contact: kongzilee@yahoo.com.cn
 * 
 * This source file may be used and distributed without restriction
 * provided that this copyright statement is not removed from the file
 * and that any derivative works contain the original copyright notice
 * and the associated disclaimer.
 * 
 * THIS SOFTWARE IS PROVIDE "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
 * SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

`include "oks8_defines.v"
`include "oks8_power.v"
`include "oks8_regf.v"
`include "oks8_decoder.v"
`include "oks8_execute.v"

///////////////////////////////////////////////////

module oks8 (/*AUTOARG*/
  // Inputs
  rst_i, clk_i, int_i,
  // Inouts
  dat_i,
  // Outputs
  rst_o, clk_o, ien_o, den_o, we_o, add_o, dat_o
  );

parameter iw = `W_INST;

// Inputs
input rst_i;
input clk_i;
input int_i;

// Outputs
output rst_o;
output clk_o;
output ien_o;
output den_o;
output we_o;
output [15:0] add_o;
output [7:0] dat_o;

// Inouts
inout [7:0] dat_i;

parameter
  st_dcode = 1'b0, st_exec = 1'b1;

// =====================================================================
// REGISTER/WIRE DECLARATIONS
// =====================================================================
wire s$_fen;
wire ex_den, ex_ien, ex_fen, ex_we;
wire [15:0] ex_add;

wire dx_den;
wire [3:0] dx_alu;
wire [1:0] dx_sts;
wire [7:0] dx_r1;
wire [2:0] dx_r1_t;
wire [7:0] dx_r2;
wire [2:0] dx_r2_t;
wire [15:0] dx_r3;

wire s$_clk, s$_rst;
wire s$_int;
wire [1:0] s$_dp;

reg state;
reg [15:0] pc;
reg [7:0] s$_icode;

reg decoder_en, execute_en;
wire dc_final, ex_final;

// =====================================================================
// INSTANTIATIONS
// =====================================================================
//
// Register memory
//
oks8_regf regf0 (
	.clk		(clk_o),
	.address	(add_o[7:0]),
	.en			(s$_fen),
	.we			(we_o),
	.din		(dat_o),
	.dout		(dat_i)
	);

//
// Power
//
oks8_power pow0 (
  // Inputs
  .clk_i		( clk_i ),
  .rst_i		( rst_i ),
  .int_i		( int_i ),
  .dp_i			( s$_dp ),
  // Outputs
  .s$_clk		( s$_clk ),
  .s$_rst		( s$_rst ),
  .p$_clk		( p$_clk ),
  .s$_int		( s$_int )
  );

//
// Decoder
//
oks8_decoder d0 (
  // Inputs
  .clk_i	( clk_o ),
  .rst_i	( s$_rst ),
  .op_i		( s$_icode ),
  .en_i		( decoder_en ),

  // outputs
  .dp_o		( s$_dp ),
  .fin_o	( dc_final ),
  .dx_den	( dx_den ),
  .dx_alu	( dx_alu ),
  .dx_sts	( dx_sts ),
  .dx_r1	( dx_r1 ),
  .dx_r1_t	( dx_r1_t ),
  .dx_r2	( dx_r2 ),
  .dx_r2_t	( dx_r2_t ),
  .dx_r3	( dx_r3 )
  );

//
// Execute
//
oks8_execute ex0 (
  // Inputs
  .clk_i	( p$_clk ),
  .rst_i	( s$_rst ),
  .en_i		( execute_en ),
  .int_i	( s$_int ),
  .dx_den	( dx_den ),
  .dx_alu	( dx_alu ),
  .dx_sts	( dx_sts ),
  .dx_r1_t	( dx_r1_t ),
  .dx_r2_t	( dx_r2_t ),
  .dx_r1	( dx_r1 ),
  .dx_r2	( dx_r2 ),
  .dx_r3	( dx_r3 ),
  .dat_i	( dat_i),
  .ex_final ( ex_final ),

  // Outputs
  .ien_o	( ex_ien ),
  .den_o	( ex_den ),
  .fen_o	( ex_fen ),
  .we_o		( ex_we ),
  .add_o	( ex_add ),
  .dat_o	( dat_o )
  );

///////////////////////////////////////////////////
//
// SYSTEM INTERFACE
//
assign clk_o = ~p$_clk;
assign rst_o = s$_rst;

//
// BUS INTERFACE
// Control access the IMEM/DMEM/REGF.
//
assign ien_o = (execute_en) ? ex_ien : 1'b1;
assign den_o = (execute_en) ? ex_den : 1'b0;
assign we_o  = (execute_en) ? ex_we : 1'b0;
assign add_o = ex_add;

assign s$_fen = (execute_en) ? ex_fen : 1'b0;
assign ex_add = (execute_en) ? 16'hZZZZ : pc;

//
// SET PC
// Get PC from execute when it finish, then add 1.
//
always @(posedge clk_o)
  if (execute_en && ex_final)
	pc[iw-1:0] <= add_o[iw-1:0] + 1'b1;

//
// MAIN LOOP
// Switch between decoder and execute.
//
always @(posedge p$_clk)
  if (s$_rst) begin
	pc[iw-1:0] <= `V_RST;
	s$_icode <= 8'h94;	// IVALID INSTRUCTION
	decoder_en <= 1;
	execute_en <= 0;
	state <= st_dcode;
  end else begin
	case (state)
	  st_dcode:
	  begin
	    s$_icode <= dat_i;
		if (dc_final) begin
		  state <= st_exec;
		  decoder_en <= 0;
		  execute_en <= 1;
		  s$_icode <= dat_i;
		end else
		  pc[iw-1:0] <= pc[iw-1:0] + 1'b1;
	  end
	  st_exec:
		if (ex_final) begin
		  decoder_en <= 1;
		  execute_en <= 0;
	      state <= st_dcode;
		  s$_icode <= dat_i;
		end
	endcase
  end

endmodule	 // oks8

