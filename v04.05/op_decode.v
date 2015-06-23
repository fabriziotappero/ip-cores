/*
--------------------------------------------------------------------------------

Module : op_decode.v

--------------------------------------------------------------------------------

Function:
- Opcode decoder for processor.

Instantiates:
- (2x) pipe.v
- (1x) op_encode.h

Notes:
- I/O optionally registered.
- Middle register is always present.
- Operates on the current thread in the stage.

--------------------------------------------------------------------------------
*/

module op_decode
	#(
	parameter	integer							REGS_IN			= 1,		// register option for inputs
	parameter	integer							REGS_OUT			= 1,		// register option for outputs
	parameter	integer							STACKS			= 8,		// number of stacks
	parameter	integer							STK_W				= 3,		// stack selector width
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							IM_W				= 6,		// immediate width
	parameter	integer							MEM_DATA_W		= 16,		// op code width
	parameter	integer							LG_SEL_W			= 4,		// logical operation width
	parameter	integer							TST_W				= 4		// test field width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// state I/O
	input			wire								thrd_clr_i,					// thread clear
	input			wire								thrd_intr_i,				// thread interrupt
	input			wire	[MEM_DATA_W-1:0]		op_code_i,					// op_code
	output		wire								op_code_er_o,				// 1=illegal op code encountered
	// data I/O
	output		wire	[IM_W-1:0]				im_o,							// immediate
	// pc pipe control
	output		wire								pc_clr_o,					// 1 : pc clear
	output		wire								cnd_o,						// 1 : conditional
	output		wire								lit_o,						// 1 : pc=pc++ for literal data
	output		wire								jmp_o,						// 1 : pc=pc+B|I for jump (cond)
	output		wire								gto_o,						// 1 : pc=B for goto / gosub
	output		wire								intr_o,						// 1 : pc=intr
	// conditional masks
	output		wire	[TST_W-1:0]				tst_o,						// test field (see tst_encode.h)
	// stacks control
	output		wire								stk_clr_o,					// stacks clear
	output		wire	[STACKS-1:0]			pop_o,						// stacks pop
	output		wire	[STACKS-1:0]			push_o,						// stacks push
	// alu control
	output		wire	[STK_W-1:0]				data_sel_a_o,				// a stack selector
	output		wire	[STK_W-1:0]				data_sel_b_o,				// b stack selector
	output		wire	[STK_W-1:0]				addr_sel_b_o,				// b stack selector
	output		wire								imda_o,						// 1=immediate data
	output		wire								imad_o,						// 1=immediate address
	output		wire								sgn_o,						// 1=signed
	output		wire								ext_o,						// 1=extended
	output		wire								hgh_o,						// 1=high
	output		wire	[LG_SEL_W-1:0]			lg_sel_o,					// logic operation (see lg_sel_encode.h)
	output		wire								add_o,						// 1=add
	output		wire								sub_o,						// 1=subtract
	output		wire								mul_o,						// 1=multiply
	output		wire								shl_o,						// 1=shift left
	output		wire								pow_o,						// 1=power of 2
	output		wire								rtn_o,						// 1=return pc
	output		wire								dm_rd_o,						// 1=read
	output		wire								dm_wr_o,						// 1=write
	output		wire								rg_rd_o,						// 1=read
	output		wire								rg_wr_o						// 1=write
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	`include "lg_sel_encode.h"
	`include "tst_encode.h"
	`include "op_encode.h"
	//
	wire												thrd_clr, thrd_intr;
	wire					[MEM_DATA_W-1:0]		op_code;
	reg												op_ok;
	reg					[4:0]						op_code_ok;
	wire												op_code_er;
	//
	reg					[IM_W-1:0]				im;
	reg												pc_clr;
	reg												intr, gto, jmp, lit, cnd;
	reg					[TST_W-1:0]				tst;
	reg												stk_clr;
	reg					[4:0]						push_a;
	reg					[4:0]						pop_a, pop_b;
	wire					[STACKS-1:0]			pop, push;
	reg					[STK_W-1:0]				data_sel_a, data_sel_b, addr_sel_b;
	reg												imda;
	reg												imad;
	reg												rtn, pow, shl, mul, sub, add, hgh, ext, sgn;
	reg					[LG_SEL_W-1:0]			lg_sel;
	reg												dm_rd, dm_wr, rg_rd, rg_wr;
	reg					[STACKS-1:0]			pop_all;



	/*
	================
	== code start ==
	================
	*/


	// optional input registers
	pipe
	#(
	.DEPTH		( REGS_IN ),
	.WIDTH		( 2+MEM_DATA_W ),
	.RESET_VAL	( 0 )
	)
	in_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { thrd_clr_i, thrd_intr_i, op_code_i } ),
	.data_o		( { thrd_clr,   thrd_intr,   op_code } )
	);


	// instantiate & split out op_code fields
	wire [2:0]	op_code_sa = op_code[2:0];
	wire      	op_code_pa = op_code[3];
	wire [2:0]	op_code_sb = op_code[6:4];
	wire      	op_code_pb = op_code[7];
	wire [3:0]	op_code_th = op_code[15:12];
	wire [3:0]	op_code_tm = { 2'b00, op_code[11:10] };
	wire [3:0]	op_code_tl = { 2'b00, op_code[9:8] };
	wire [5:0]	op_code_i4 = $signed( op_code[11:8] );
	wire [5:0]	op_code_i6 = op_code[9:4];
	wire [7:0]	op_code_pf = op_code[7:0];
	//
	reg  [2:0]	sa_reg, sb_reg;


	// mid register if & case: clear, interrupt, and op_code decode
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			op_ok <= 'b0;
			op_code_ok <= 'b0;
			pc_clr <= 'b0;
			cnd <= 'b0;
			lit <= 'b0;
			jmp <= 'b0;
			gto <= 'b0;
			intr <= 'b0;
			tst <= 'b0;
			stk_clr <= 'b0;
			pop_all <= 'b0;
			pop_a <= 'b0;
			pop_b <= 'b0;
			push_a <= 'b0;
			data_sel_a <= 'b0;
			data_sel_b <= 'b0;
			addr_sel_b <= 'b0;
			imda <= 'b0;
			imad <= 'b0;
			im <= 'b0;
			sgn <= 'b0;
			ext <= 'b0;
			hgh <= 'b0;
			lg_sel <= `lg_cpy;
			add <= 'b0;
			sub <= 'b0;
			mul <= 'b0;
			shl <= 'b0;
			pow <= 'b0;
			rtn <= 'b0;
			dm_rd <= 'b0;
			dm_wr <= 'b0;
			rg_rd <= 'b0;
			rg_wr <= 'b0;
			sa_reg <= 'b0;
			sb_reg <= 'b0;
		end else begin
			// default values
			op_ok <= 'b0;  // default is bad op
			op_code_ok <= 'b0;  // default is bad opcode
			pc_clr <= 'b0;  // default is no pc clear
			cnd <= 'b0;  // default is unconditional
			lit <= 'b0;  // default is no follow
			jmp <= 'b0;  // default is no jump
			gto <= 'b0;  // default is no goto
			intr <= 'b0;  // default is no interrupt
			tst <= op_code_tl;  // default is low test field
			stk_clr <= 'b0;  // default is no stack clear
			pop_all <= 'b0;  // default is no pop
			pop_a <= 'b0;  // default is no pop
			pop_b <= 'b0;  // default is no pop
			push_a <= 'b0;  // default is no push
			data_sel_a <= op_code_sa;  // default is op_code directive
			data_sel_b <= op_code_sb;  // default is op_code directive
			addr_sel_b <= op_code_sb;  // default is op_code directive
			imda <= 'b0;  // default is not immediate data
			imad <= 'b0;  // default is not immediate address
			im <= op_code_i6;  // default is full width
			sgn <= 'b0;  // default is unsigned
			hgh <= 'b0;  // default is not high
			ext <= 'b0;  // default is unextended
			lg_sel <= `lg_cpy;  // default is thru
			add <= 'b0;  // default is thru
			sub <= 'b0;   // default is thru
			mul <= 'b0;  // default is thru
			shl <= 'b0;   // default is thru
			pow <= 'b0;   // default is thru
			rtn <= 'b0;  // default is thru
			dm_rd <= 'b0;  // default is don't read
			dm_wr <= 'b0;  // default is don't write
			rg_rd <= 'b0;  // default is don't read
			rg_wr <= 'b0;  // default is don't write
			sa_reg <= op_code_sa;  // default is follow op_code
			sb_reg <= op_code_sb;  // default is follow op_code
			if ( thrd_clr ) begin
				op_ok <= 'b1;  // good op
				pc_clr <= 'b1;  // clear pc
				stk_clr <= 'b1;  // clear stacks
			end else if ( thrd_intr ) begin
				op_ok <= 'b1;  // good op
				intr <= 'b1;  // don't inc PC
				push_a[0] <= 'b1;  // push
				data_sel_a <= 'b0;  // push return address to stack 0
				rtn <= 'b1;  // push pc
			end else begin
				casex ( op_code )
					////////////////////
					// group 0 - misc //
					////////////////////
					op_nop : begin
						op_code_ok[0] <= 'b1;
					end
					op_pop : begin
						op_code_ok[0] <= 'b1;
						pop_all <= op_code_pf;
					end
					op_pgc : begin
						op_code_ok[0] <= 'b1;
						pop_a[0] <= op_code_pa;
						pop_b[0] <= op_code_pb;
						push_a[0] <= 'b1;  // push
						rtn <= 'b1;  // push pc
					end
					op_lit_s : begin
						op_code_ok[0] <= 'b1;
						pop_a[0] <= op_code_pa;
						pop_b[0] <= op_code_pb;
						push_a[0] <= 'b1;  // push
						lit <= 'b1;  // lit
						dm_rd <= 'b1;  // dm
						sgn <= 'b1;  // signed
					end
					op_lit_h : begin
						op_code_ok[0] <= 'b1;
						pop_a[0] <= op_code_pa;
						pop_b[0] <= op_code_pb;
						push_a[0] <= 'b1;  // push
						data_sel_b <= op_code_sa;  // route A thru ALU bypass
						lit <= 'b1;  // lit
						dm_rd <= 'b1;  // dm
						hgh <= 'b1;  // high
					end
					op_lit_u : begin
						op_code_ok[0] <= 'b1;
						pop_a[0] <= op_code_pa;
						pop_b[0] <= op_code_pb;
						push_a[0] <= 'b1;  // push
						lit <= 'b1;  // lit
						dm_rd <= 'b1;  // dm
					end
					op_reg_rs : begin
						op_code_ok[0] <= 'b1;
						pop_a[0] <= op_code_pa;
						pop_b[0] <= op_code_pb;
						push_a[0] <= 'b1;  // push
						rg_rd <= 'b1;  // read
						sgn <= 'b1;  // signed
					end
					op_reg_rh : begin
						op_code_ok[0] <= 'b1;
						pop_a[0] <= op_code_pa;
						pop_b[0] <= op_code_pb;
						push_a[0] <= 'b1;  // push
						data_sel_b <= op_code_sa;  // route A thru ALU bypass
						rg_rd <= 'b1;  // read
						hgh <= 'b1;  // high
					end
					op_reg_w : begin
						op_code_ok[0] <= 'b1;
						pop_a[0] <= op_code_pa;
						pop_b[0] <= op_code_pb;
						rg_wr <= 'b1;  // write
					end
					op_reg_wh : begin
						op_code_ok[0] <= 'b1;
						pop_a[0] <= op_code_pa;
						pop_b[0] <= op_code_pb;
						rg_wr <= 'b1;  // write
						hgh <= 'b1;  // high
					end
					///////////////////////
					// group 1 - logical //
					///////////////////////
					op_cpy : begin
						op_code_ok[1] <= 'b1;
						pop_a[1] <= op_code_pa;
						pop_b[1] <= op_code_pb;
						push_a[1] <= 'b1;  // push
						lg_sel <= `lg_cpy;
					end
					op_nsg : begin
						op_code_ok[1] <= 'b1;
						pop_a[1] <= op_code_pa;
						pop_b[1] <= op_code_pb;
						push_a[1] <= 'b1;  // push
						lg_sel <= `lg_nsg;
					end
					op_not : begin
						op_code_ok[1] <= 'b1;
						pop_a[1] <= op_code_pa;
						pop_b[1] <= op_code_pb;
						push_a[1] <= 'b1;  // push
						lg_sel <= `lg_not;
					end
					op_flp : begin
						op_code_ok[1] <= 'b1;
						pop_a[1] <= op_code_pa;
						pop_b[1] <= op_code_pb;
						push_a[1] <= 'b1;  // push
						lg_sel <= `lg_flp;
					end
					op_lzc : begin
						op_code_ok[1] <= 'b1;
						pop_a[1] <= op_code_pa;
						pop_b[1] <= op_code_pb;
						push_a[1] <= 'b1;  // push
						lg_sel <= `lg_lzc;
					end
					op_bra : begin
						op_code_ok[1] <= 'b1;
						pop_a[1] <= op_code_pa;
						pop_b[1] <= op_code_pb;
						push_a[1] <= 'b1;  // push
						lg_sel <= `lg_bra;
					end
					op_bro : begin
						op_code_ok[1] <= 'b1;
						pop_a[1] <= op_code_pa;
						pop_b[1] <= op_code_pb;
						push_a[1] <= 'b1;  // push
						lg_sel <= `lg_bro;
					end
					op_brx : begin
						op_code_ok[1] <= 'b1;
						pop_a[1] <= op_code_pa;
						pop_b[1] <= op_code_pb;
						push_a[1] <= 'b1;  // push
						lg_sel <= `lg_brx;
					end
					op_and : begin
						op_code_ok[1] <= 'b1;
						pop_a[1] <= op_code_pa;
						pop_b[1] <= op_code_pb;
						push_a[1] <= 'b1;  // push
						lg_sel <= `lg_and;
					end
					op_orr : begin
						op_code_ok[1] <= 'b1;
						pop_a[1] <= op_code_pa;
						pop_b[1] <= op_code_pb;
						push_a[1] <= 'b1;  // push
						lg_sel <= `lg_orr;
					end
					op_xor : begin
						op_code_ok[1] <= 'b1;
						pop_a[1] <= op_code_pa;
						pop_b[1] <= op_code_pb;
						push_a[1] <= 'b1;  // push
						lg_sel <= `lg_xor;
					end
					//////////////////////////
					// group 2 - arithmetic //
					//////////////////////////
					op_add : begin
						op_code_ok[2] <= 'b1;
						pop_a[2] <= op_code_pa;
						pop_b[2] <= op_code_pb;
						push_a[2] <= 'b1;  // push
						add <= 'b1;  // add
					end
					op_add_xs : begin
						op_code_ok[2] <= 'b1;
						pop_a[2] <= op_code_pa;
						pop_b[2] <= op_code_pb;
						push_a[2] <= 'b1;  // push
						add <= 'b1;  // add
						ext <= 'b1;  // extended
						sgn <= 'b1;  // signed
					end
					op_add_xu : begin
						op_code_ok[2] <= 'b1;
						pop_a[2] <= op_code_pa;
						pop_b[2] <= op_code_pb;
						push_a[2] <= 'b1;  // push
						add <= 'b1;  // add
						ext <= 'b1;  // extended
					end
					op_sub : begin
						op_code_ok[2] <= 'b1;
						pop_a[2] <= op_code_pa;
						pop_b[2] <= op_code_pb;
						push_a[2] <= 'b1;  // push
						sub <= 'b1;  // sub
					end
					op_sub_xs : begin
						op_code_ok[2] <= 'b1;
						pop_a[2] <= op_code_pa;
						pop_b[2] <= op_code_pb;
						push_a[2] <= 'b1;  // push
						sub <= 'b1;  // sub
						ext <= 'b1;  // extended
						sgn <= 'b1;  // signed
					end
					op_sub_xu : begin
						op_code_ok[2] <= 'b1;
						pop_a[2] <= op_code_pa;
						pop_b[2] <= op_code_pb;
						push_a[2] <= 'b1;  // push
						sub <= 'b1;  // sub
						ext <= 'b1;  // extended
					end
					op_mul : begin
						op_code_ok[2] <= 'b1;
						pop_a[2] <= op_code_pa;
						pop_b[2] <= op_code_pb;
						push_a[2] <= 'b1;  // push
						mul <= 'b1;  // multiply
					end
					op_mul_xs : begin
						op_code_ok[2] <= 'b1;
						pop_a[2] <= op_code_pa;
						pop_b[2] <= op_code_pb;
						push_a[2] <= 'b1;  // push
						mul <= 'b1;  // multiply
						ext <= 'b1;  // extended
						sgn <= 'b1;  // signed
					end
					op_mul_xu : begin
						op_code_ok[2] <= 'b1;
						pop_a[2] <= op_code_pa;
						pop_b[2] <= op_code_pb;
						push_a[2] <= 'b1;  // push
						mul <= 'b1;  // multiply
						ext <= 'b1;  // extended
					end
					op_shl_s : begin
						op_code_ok[2] <= 'b1;
						pop_a[2] <= op_code_pa;
						pop_b[2] <= op_code_pb;
						push_a[2] <= 'b1;  // push
						shl <= 'b1;  // shift left
						sgn <= 'b1;  // signed
					end
					op_shl_u : begin
						op_code_ok[2] <= 'b1;
						pop_a[2] <= op_code_pa;
						pop_b[2] <= op_code_pb;
						push_a[2] <= 'b1;  // push
						shl <= 'b1;  // shift left
					end
					op_pow : begin
						op_code_ok[2] <= 'b1;
						pop_a[2] <= op_code_pa;
						pop_b[2] <= op_code_pb;
						push_a[2] <= 'b1;  // push
						pow <= 'b1;  // power of 2
					end
					////////////////////////
					// group 3 - branches //
					////////////////////////
					op_jmp_z, op_jmp_nz, op_jmp_lz, op_jmp_nlz : begin
						op_code_ok[3] <= 'b1;
						pop_a[3] <= op_code_pa;
						pop_b[3] <= op_code_pb;
						jmp <= 'b1;  // jump
						cnd <= 'b1;  // conditional
						tst <= op_code_tl;  // lo test field
					end
					op_jmp : begin
						op_code_ok[3] <= 'b1;
						pop_a[3] <= op_code_pa;
						pop_b[3] <= op_code_pb;
						jmp <= 'b1;  // jump
					end
					op_gto : begin
						op_code_ok[3] <= 'b1;
						pop_a[3] <= op_code_pa;
						pop_b[3] <= op_code_pb;
						gto <= 'b1;  // goto
					end
					op_gsb : begin
						op_code_ok[3] <= 'b1;
						pop_a[3] <= op_code_pa;
						pop_b[3] <= op_code_pb;
						push_a[3] <= 'b1;  // push
						gto <= 'b1;  // goto
						rtn <= 'b1;  // push pc
					end
					//////////////////////////
					// group 4 - immediates //
					//////////////////////////
					///////////////////////////////////
					// immediate memory read & write //
					///////////////////////////////////
					op_mem_irs : begin
						op_code_ok[4] <= 'b1;
						pop_a[4] <= op_code_pa;
						pop_b[4] <= op_code_pb;
						push_a[4] <= 'b1;  // push
						im <= op_code_i4;  // small im
						dm_rd <= 'b1;  // read
						sgn <= 'b1;  // signed
					end
					op_mem_irh : begin
						op_code_ok[4] <= 'b1;
						pop_a[4] <= op_code_pa;
						pop_b[4] <= op_code_pb;
						push_a[4] <= 'b1;  // push
						im <= op_code_i4;  // small im
						data_sel_b <= op_code_sa;  // route A thru ALU bypass
						dm_rd <= 'b1;  // read
						hgh <= 'b1;  // high
					end
					op_mem_iw : begin
						op_code_ok[4] <= 'b1;
						pop_a[4] <= op_code_pa;
						pop_b[4] <= op_code_pb;
						im <= op_code_i4;  // small im
						dm_wr <= 'b1;  // write
					end
					op_mem_iwh : begin
						op_code_ok[4] <= 'b1;
						pop_a[4] <= op_code_pa;
						pop_b[4] <= op_code_pb;
						im <= op_code_i4;  // small im
						dm_wr <= 'b1;  // write
						hgh <= 'b1;  // high
					end
					/////////////////////////////////
					// immediate conditional jumps //
					/////////////////////////////////
					op_jmp_ie, op_jmp_ine, op_jmp_ilu, op_jmp_inlu : begin
						op_code_ok[4] <= 'b1;
						pop_a[4] <= op_code_pa;
						pop_b[4] <= op_code_pb;
						jmp <= 'b1;  // jump
						cnd <= 'b1;  // conditional
						imad <= 'b1;  // immediate address
						im <= op_code_i4;  // small im
						tst <= op_code_th;  // hi test field
					end
					op_jmp_ils, op_jmp_inls : begin
						op_code_ok[4] <= 'b1;
						pop_a[4] <= op_code_pa;
						pop_b[4] <= op_code_pb;
						jmp <= 'b1;  // jump
						cnd <= 'b1;  // conditional
						imad <= 'b1;  // immediate address
						im <= op_code_i4;  // small im
						tst <= op_code_th;  // hi test field
						sgn <= 'b1;  // signed
					end
					op_jmp_iz, op_jmp_inz, op_jmp_ilz, op_jmp_inlz : begin
						op_code_ok[4] <= 'b1;
						pop_a[4] <= op_code_pa;
						jmp <= 'b1;  // jump
						cnd <= 'b1;  // conditional
						imad <= 'b1;  // immediate address
						tst <= op_code_tm;  // mid test field
					end
					////////////////////
					// immediate data //
					////////////////////
					op_dat_is : begin
						op_code_ok[4] <= 'b1;
						pop_a[4] <= op_code_pa;
						push_a[4] <= 'b1;  // push
						imda <= 'b1;  // immediate b data
						sgn <= 'b1;  // signed
					end
					///////////////////
					// immediate add //
					///////////////////
					op_add_is : begin
						op_code_ok[4] <= 'b1;
						pop_a[4] <= op_code_pa;
						push_a[4] <= 'b1;  // push
						imda <= 'b1;  // immediate b data
						add <= 'b1;  // add
						sgn <= 'b1;  // signed
					end
					//////////////////////
					// immediate shifts //
					//////////////////////
					op_shl_is : begin
						op_code_ok[4] <= 'b1;
						pop_a[4] <= op_code_pa;
						push_a[4] <= 'b1;  // push
						imda <= 'b1;  // immediate b data
						shl <= 'b1;  // shift left
						sgn <= 'b1;  // signed
					end
					op_psu_i : begin
						op_code_ok[4] <= 'b1;
						pop_a[4] <= op_code_pa;
						push_a[4] <= 'b1;  // push
						imda <= 'b1;  // immediate b data
						shl <= 'b1;  // shift left
						pow <= 'b1;  // power of 2
					end
					default: begin
						// nothing here
					end
				endcase
			end
		end
	end

	// decode pop & push (note: use registered select fields here)
	assign pop  = ( ( |pop_a ) << sa_reg ) | ( ( |pop_b ) << sb_reg ) | pop_all;
	assign push = ( |push_a ) << sa_reg;
	
	// decode errors
	assign op_code_er = ~( op_ok | ( |op_code_ok ) );


	// optional output registers
	pipe
	#(
	.DEPTH		( REGS_OUT ),
	.WIDTH		( TST_W+LG_SEL_W+STACKS+STACKS+STK_W+STK_W+STK_W+IM_W ),
	.RESET_VAL	( 0 )
	)
	out_regs_vectors
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { tst,   lg_sel,   push,   pop,   addr_sel_b,   data_sel_b,   data_sel_a,   im   } ),
	.data_o		( { tst_o, lg_sel_o, push_o, pop_o, addr_sel_b_o, data_sel_b_o, data_sel_a_o, im_o } )
	);


	pipe
	#(
	.DEPTH		( REGS_OUT ),
	.WIDTH		( 23 ),
	.RESET_VAL	( 0 )
	)
	out_regs_singles
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { op_code_er,   pc_clr,   cnd,   lit,   jmp,   gto,   intr,   stk_clr,   imda,   imad,   sgn,   ext,   hgh,   add,   sub,   mul,   shl,   pow,   rtn,   dm_rd,   dm_wr,   rg_rd,   rg_wr } ),
	.data_o		( { op_code_er_o, pc_clr_o, cnd_o, lit_o, jmp_o, gto_o, intr_o, stk_clr_o, imda_o, imad_o, sgn_o, ext_o, hgh_o, add_o, sub_o, mul_o, shl_o, pow_o, rtn_o, dm_rd_o, dm_wr_o, rg_rd_o, rg_wr_o } )
	);


endmodule
