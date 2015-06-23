//////////////////////////////////////////////////////////////////
////
////
//// 	AES CORE BLOCK
////
////
////
//// This file is part of the APB to I2C project
////
//// http://www.opencores.org/cores/apbi2c/
////
////
////
//// Description
////
//// Implementation of APB IP core according to
////
//// aes128_spec IP core specification document.
////
////
////
//// To Do: Things are right here but always all block can suffer changes
////
////
////
////
////
//// Author(s): - Felipe Fernandes Da Costa, fefe2560@gmail.com
////		  Julio Cesar 
////
///////////////////////////////////////////////////////////////// 
////
////
//// Copyright (C) 2009 Authors and OPENCORES.ORG
////
////
////
//// This source file may be used and distributed without
////
//// restriction provided that this copyright statement is not
////
//// removed from the file and that any derivative work contains
//// the original copyright notice and the associated disclaimer.
////
////
//// This source file is free software; you can redistribute it
////
//// and/or modify it under the terms of the GNU Lesser General
////
//// Public License as published by the Free Software Foundation;
//// either version 2.1 of the License, or (at your option) any
////
//// later version.
////
////
////
//// This source is distributed in the hope that it will be
////
//// useful, but WITHOUT ANY WARRANTY; without even the implied
////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
////
//// PURPOSE. See the GNU Lesser General Public License for more
//// details.
////
////
////
//// You should have received a copy of the GNU Lesser General
////
//// Public License along with this source; if not, download it
////
//// from http://www.opencores.org/lgpl.shtml
////
////
///////////////////////////////////////////////////////////////////
module control_unit
(
	output reg [ 2:0] sbox_sel,
	output reg [ 1:0] rk_sel,
	output reg [ 1:0] key_out_sel,
	output reg [ 1:0] col_sel,
	output reg [ 3:0] key_en,
	output reg [ 3:0] col_en,
	output     [ 3:0] round,
	output reg bypass_rk,
	output reg bypass_key_en,
	output reg key_sel,
	output reg iv_cnt_en,
	output reg iv_cnt_sel,
	output reg key_derivation_en,
	output end_comp,
	output key_init,
	output key_gen,
	output mode_ctr,
	output mode_cbc,
	output last_round,
  output encrypt_decrypt,	
	input [1:0] operation_mode,
	input [1:0] aes_mode,
	input start,
	input disable_core,
	input clk,
	input rst_n
);
//`include "include/host_interface.vh"
//`include "include/control_unit_params.vh"

//=====================================================================================
// Memory Mapped Registers Address
//=====================================================================================
localparam AES_CR    = 4'd00;
localparam AES_SR    = 4'd01;
localparam AES_DINR  = 4'd02;
localparam AES_DOUTR = 4'd03;
localparam AES_KEYR0 = 4'd04;
localparam AES_KEYR1 = 4'd05;
localparam AES_KEYR2 = 4'd06;
localparam AES_KEYR3 = 4'd07;
localparam AES_IVR0  = 4'd08;
localparam AES_IVR1  = 4'd09;
localparam AES_IVR2  = 4'd10;
localparam AES_IVR3  = 4'd11;

//=============================================================================
// Operation Modes
//=============================================================================
localparam ENCRYPTION     = 2'b00;
localparam KEY_DERIVATION = 2'b01;
localparam DECRYPTION     = 2'b10;
localparam DECRYP_W_DERIV = 2'b11;

//=============================================================================
// AES Modes
//=============================================================================
localparam ECB = 2'b00;
localparam CBC = 2'b01;
localparam CTR = 2'b10;

//=============================================================================
// SBOX SEL
//=============================================================================
localparam COL_0 = 3'b000;
localparam COL_1 = 3'b001;
localparam COL_2 = 3'b010;
localparam COL_3 = 3'b011;
localparam G_FUNCTION = 3'b100;

//=============================================================================
// RK_SEL
//=============================================================================
localparam COL        = 2'b00;
localparam MIXCOL_IN  = 2'b01;
localparam MIXCOL_OUT = 2'b10;

//=============================================================================
// KEY_OUT_SEL
//=============================================================================
localparam KEY_0 = 2'b00;
localparam KEY_1 = 2'b01;
localparam KEY_2 = 2'b10;
localparam KEY_3 = 2'b11;

//=============================================================================
// COL_SEL
//=============================================================================
localparam SHIFT_ROWS = 2'b00;
localparam ADD_RK_OUT = 2'b01;
localparam INPUT      = 2'b10;

//=============================================================================
// KEY_SEL
//=============================================================================
localparam KEY_HOST = 1'b0;
localparam KEY_OUT  = 1'b1;

//=============================================================================
// KEY_EN
//=============================================================================
localparam KEY_DIS  = 4'b0000;
localparam EN_KEY_0 = 4'b0001;
localparam EN_KEY_1 = 4'b0010;
localparam EN_KEY_2 = 4'b0100;
localparam EN_KEY_3 = 4'b1000;
localparam KEY_ALL  = 4'b1111;

//=============================================================================
// COL_EN
//=============================================================================
localparam COL_DIS  = 4'b0000;
localparam EN_COL_0 = 4'b0001;
localparam EN_COL_1 = 4'b0010;
localparam EN_COL_2 = 4'b0100;
localparam EN_COL_3 = 4'b1000;
localparam COL_ALL  = 4'b1111;

//=============================================================================
// IV_CNT_SEL
//=============================================================================
localparam IV_CNT = 1'b1;
localparam IV_BUS = 1'b0;

//=============================================================================
// ENABLES
//=============================================================================
localparam ENABLE = 1'b1;
localparam DISABLE = 1'b0;

localparam NUMBER_ROUND      = 4'd10;
localparam NUMBER_ROUND_INC  = 4'd11;
localparam INITIAL_ROUND     = 4'd00;

//=============================================================================
// FSM STATES
//=============================================================================
localparam IDLE        = 4'd00;
localparam ROUND0_COL0 = 4'd01;
localparam ROUND0_COL1 = 4'd02;
localparam ROUND0_COL2 = 4'd03;
localparam ROUND0_COL3 = 4'd04;
localparam ROUND_KEY0  = 4'd05;
localparam ROUND_COL0  = 4'd06;
localparam ROUND_COL1  = 4'd07;
localparam ROUND_COL2  = 4'd08;
localparam ROUND_COL3  = 4'd09;
localparam READY       = 4'd10;
localparam GEN_KEY0    = 4'd11;
localparam GEN_KEY1    = 4'd12;
localparam GEN_KEY2    = 4'd13;
localparam GEN_KEY3    = 4'd14;
localparam NOP         = 4'd15;

reg [3:0] state, next_state;
reg [3:0] rd_count;

reg rd_count_en;
//reg end_aes_pp1, end_aes_pp2;
wire op_key_derivation;
wire first_round;
wire [1:0] op_mode;
wire enc_dec;

// State Flops Definition
always @(posedge clk, negedge rst_n)
	begin
		if(!rst_n)
			state <= IDLE;
		else
			if(disable_core)
				state <= IDLE;
			else
				state <= next_state;
	end

assign encrypt_decrypt = (op_mode == ENCRYPTION || op_mode == KEY_DERIVATION || state == GEN_KEY0   
			  ||   state == GEN_KEY1       ||state == GEN_KEY2   ||   state == GEN_KEY3       );

assign enc_dec = encrypt_decrypt | mode_ctr;
assign key_gen = (state == ROUND_KEY0);

assign op_key_derivation = (op_mode == KEY_DERIVATION);

assign mode_ctr = (aes_mode == CTR);
assign mode_cbc = (aes_mode == CBC);

assign key_init = start;

assign op_mode = (mode_ctr) ? ENCRYPTION : operation_mode;

// Next State Logic
always @(*)
	begin
		next_state = state;
		case(state)
			IDLE:
				begin
					if(!start)
						next_state = IDLE;
					else
						case(op_mode)
							ENCRYPTION    : next_state = ROUND0_COL0;
							DECRYPTION    : next_state = ROUND0_COL3;
							KEY_DERIVATION: next_state = GEN_KEY0;
							DECRYP_W_DERIV: next_state = GEN_KEY0;
							default       : next_state = IDLE;
						endcase
				end
			ROUND0_COL0:
				begin
					next_state = (enc_dec) ? ROUND0_COL1 : ROUND_KEY0; 
				end
			ROUND0_COL1:
				begin
					next_state = (enc_dec) ? ROUND0_COL2 : ROUND0_COL0;
				end
			ROUND0_COL2:
				begin
					next_state = (enc_dec) ? ROUND0_COL3 : ROUND0_COL1;
				end
			ROUND0_COL3:
				begin
					next_state = (enc_dec) ? ROUND_KEY0 : ROUND0_COL2;
				end
			ROUND_KEY0 :
				begin
					if(!first_round)
						begin
							next_state = (last_round) ? READY : NOP;
						end
					else
						begin
							next_state = (enc_dec) ? ROUND_COL0 : ROUND_COL3;
						end
				end
			NOP        :
				begin
					next_state = (enc_dec) ? ROUND_COL0 : ROUND_COL3;
				end
			ROUND_COL0 :
				begin
					next_state = (enc_dec) ? ROUND_COL1 : ROUND_KEY0;
				end
			ROUND_COL1 :
				begin
					next_state = (enc_dec) ? ROUND_COL2 : ROUND_COL0;
				end
			ROUND_COL2 :
				begin
					next_state = (enc_dec) ? ROUND_COL3 : ROUND_COL1;
				end
			ROUND_COL3 :
				begin
					if(last_round && enc_dec)
						next_state = READY;
					else
					next_state = (enc_dec) ? ROUND_KEY0 : ROUND_COL2;
				end
			GEN_KEY0   :
				begin
					next_state = GEN_KEY1;
				end
			GEN_KEY1   :
				begin
					next_state = GEN_KEY2;
				end
			GEN_KEY2   :
				begin
					next_state = GEN_KEY3;
				end
			GEN_KEY3   :
				begin
					if(last_round)
						next_state = (op_key_derivation) ? READY : ROUND0_COL3;
					else
						next_state = GEN_KEY0;
				end
			READY      :
				begin
					next_state = IDLE;
				end
		endcase
	end
 
       
// Output Logic
assign end_comp = (state == READY)?ENABLE:DISABLE;

/*
always @(posedge clk, negedge rst_n)
begin
		if(!rst_n)
		begin
			end_aes_pp1 <= 1'b0;
			end_aes_pp2 <= 1'b0; 
			end_comp <= 1'b0;
		end
		else
			if(state == READY)
			begin
				end_aes_pp1 <= ENABLE;
				//end_aes_pp2 <= end_aes_pp1;
				end_comp <= end_aes_pp1 ;
			end
			else
			begin
				end_aes_pp1 <= DISABLE;
				//end_aes_pp2 <= end_aes_pp1;
				end_comp <= end_aes_pp1 ;
			end

end
*/
always @(*)
	begin
		sbox_sel = COL_0;
		rk_sel = COL;
		bypass_rk = DISABLE;
		key_out_sel = KEY_0;
		col_sel = INPUT;
		key_sel = KEY_HOST;
		key_en = KEY_DIS;
		col_en = COL_DIS;
		rd_count_en = DISABLE;
		iv_cnt_en = DISABLE;
		iv_cnt_sel = IV_BUS;
		bypass_key_en = DISABLE;
		key_derivation_en = DISABLE;
		//end_comp = DISABLE;
		case(state)
			ROUND0_COL0:
				begin
					sbox_sel = COL_0;
					rk_sel   = COL;
					bypass_rk = ENABLE;
					bypass_key_en = ENABLE;
					key_out_sel = KEY_0;
					col_sel = (enc_dec) ? ADD_RK_OUT : SHIFT_ROWS;
					col_en =  (enc_dec) ? EN_COL_0 : COL_ALL;
				end
			ROUND0_COL1:
				begin
					sbox_sel = COL_1;
					rk_sel   = COL;
					bypass_rk = ENABLE;
					bypass_key_en = ENABLE;
					key_out_sel = KEY_1;
					col_sel = ADD_RK_OUT;
					col_en = EN_COL_1;
					if(!enc_dec)
						begin
							key_sel = KEY_OUT;
							key_en =  EN_KEY_1;
						end
				end
			ROUND0_COL2:
				begin
					sbox_sel = COL_2;
					rk_sel   = COL;
					bypass_rk = ENABLE;
					bypass_key_en = ENABLE;
					key_out_sel = KEY_2;
					col_sel = ADD_RK_OUT;
					col_en = EN_COL_2;
					if(!enc_dec)
						begin
							key_sel = KEY_OUT;
							key_en =  EN_KEY_2;
						end
				end
			ROUND0_COL3:
				begin
					sbox_sel = COL_3;
					rk_sel   = COL;
					bypass_key_en = ENABLE;
					key_out_sel = KEY_3;
					col_sel = (enc_dec) ? SHIFT_ROWS : ADD_RK_OUT;
					col_en =  (enc_dec) ? COL_ALL : EN_COL_3;
					bypass_rk = ENABLE;
					if(!enc_dec)
					begin
							key_sel = KEY_OUT;
							key_en =  EN_KEY_3;
					end
				end
			ROUND_KEY0:
				begin
					sbox_sel = G_FUNCTION;
					key_sel = KEY_OUT;
					key_en = EN_KEY_0;
					rd_count_en = ENABLE;
				end
			ROUND_COL0:
				begin
					sbox_sel = COL_0;
					rk_sel = (last_round) ? MIXCOL_IN : MIXCOL_OUT;
					key_out_sel = KEY_0;
					key_sel = KEY_OUT;

					if(enc_dec)
						key_en = EN_KEY_1;
					if((mode_cbc && last_round && !enc_dec) || (mode_ctr && last_round))
						col_sel = INPUT;
					else
						begin
							if(!enc_dec)
								col_sel = (last_round) ? ADD_RK_OUT : SHIFT_ROWS;
							else
								col_sel = ADD_RK_OUT;
						end
					if(enc_dec)
						col_en = EN_COL_0;
					else
						col_en = (last_round) ? EN_COL_0 : COL_ALL;
				end
			ROUND_COL1:
				begin
					sbox_sel = COL_1;
					rk_sel   = (last_round) ? MIXCOL_IN : MIXCOL_OUT;
					key_out_sel = KEY_1;
					key_sel = KEY_OUT;
					if(enc_dec)
						key_en = EN_KEY_2;
					else
						key_en = EN_KEY_1;
					if((mode_cbc && last_round && !enc_dec) || (mode_ctr && last_round))
						col_sel = INPUT;
					else
						col_sel = ADD_RK_OUT;
					col_en = EN_COL_1;
				end
			ROUND_COL2:
				begin
					sbox_sel = COL_2;
					rk_sel   = (last_round) ? MIXCOL_IN : MIXCOL_OUT;
					key_out_sel = KEY_2;
					key_sel = KEY_OUT;
					if(enc_dec)
						key_en = EN_KEY_3;
					else
						key_en = EN_KEY_2;
					if((mode_cbc && last_round && !enc_dec) || (mode_ctr && last_round))
						col_sel = INPUT;
					else
						col_sel = ADD_RK_OUT;
					col_en = EN_COL_2;
				end
			ROUND_COL3:
				begin
					sbox_sel = COL_3;
					rk_sel   = (last_round) ? MIXCOL_IN : MIXCOL_OUT;
					key_out_sel = KEY_3;
					key_sel = KEY_OUT;
					if(!enc_dec)
						key_en = EN_KEY_3;
					if((mode_cbc && last_round && !enc_dec) || (mode_ctr && last_round))
						col_sel = INPUT;
					else
						begin
							if(enc_dec)
								col_sel = (last_round) ? ADD_RK_OUT : SHIFT_ROWS;
							else
								col_sel = ADD_RK_OUT;
						end
					if(enc_dec)
						col_en = (last_round) ? EN_COL_3 : COL_ALL;
					else
						col_en = EN_COL_3;
					if(mode_ctr && last_round)
						begin
							iv_cnt_en = ENABLE;
							iv_cnt_sel = IV_CNT;
						end
				end
			GEN_KEY0:
				begin
					sbox_sel = G_FUNCTION;
					rd_count_en = ENABLE;
				end
			GEN_KEY1:
				begin
					key_en = EN_KEY_1 | EN_KEY_0; //Enable key 0 AND key 1
					key_sel = KEY_OUT;
					bypass_key_en = ENABLE;
				end
			GEN_KEY2:
				begin
					key_en = EN_KEY_2;
					key_sel = KEY_OUT;
					bypass_key_en = ENABLE;
				end
			GEN_KEY3:
				begin
					key_en = EN_KEY_3;
					key_sel = KEY_OUT;
					bypass_key_en = ENABLE;
				end
			READY:
				begin
					//end_comp = ENABLE;
					if(op_mode == KEY_DERIVATION)
						key_derivation_en = ENABLE;
				end
		endcase
	end

// Round Counter
always @(posedge clk, negedge rst_n)
	begin
		if(!rst_n)
			rd_count <= INITIAL_ROUND;
		else
			if(state == IDLE || (state == GEN_KEY3 && last_round))
				rd_count <= INITIAL_ROUND;
			else 
				if(rd_count_en)
					rd_count <= rd_count + 1'b1;
	end

assign round = rd_count;
assign first_round = (rd_count == INITIAL_ROUND);
assign last_round  = (rd_count == NUMBER_ROUND || rd_count == NUMBER_ROUND_INC);

endmodule
