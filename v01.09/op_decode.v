/*
--------------------------------------------------------------------------------

Module : op_decode.v

--------------------------------------------------------------------------------

Function:
- Opcode decoder for processor.

Instantiates:
- (2x) vector_sr.v

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
	parameter	integer							STACKS			= 4,		// number of stacks
	parameter	integer							STK_W				= 2,		// stack selector width
	parameter	integer							DATA_W			= 32,		// data width
	parameter	integer							IM_DATA_W		= 8,		// immediate data width
	parameter	integer							IM_ADDR_W		= 6,		// immediate data width
	parameter	integer							OP_CODE_W		= 16,		// op code width
	parameter	integer							LG_W				= 2		// logical operation width
	)
	(
	// clocks & resets
	input			wire								clk_i,						// clock
	input			wire								rst_i,						// async. reset, active high
	// state I/O
	input			wire								thrd_clr_i,					// thread clear
	input			wire								thrd_intr_i,				// thread interrupt
	input			wire	[OP_CODE_W-1:0]		op_code_i,					// op_code
	output		wire								op_code_er_o,				// 1=illegal op code encountered
	// data I/O
	output		wire	[IM_DATA_W-1:0]		im_data_o,					// immediate data
	output		wire	[IM_ADDR_W-1:0]		im_addr_o,					// immediate address (offset)
	// pc pipe control
	output		wire								pc_clr_o,					// pc clear
	output		wire								lit_o,						// 1 : pc=pc++ for lit
	output		wire								jmp_o,						// 1 : pc=pc+B for jump (cond)
	output		wire								gto_o,						// 1 : pc=B for goto / gosub (cond)
	output		wire								intr_o,						// 1 : pc=intr
	// conditional masks
	output		wire								tst_eq_o,					// = test
	output		wire								tst_lt_o,					// < test
	output		wire								tst_gt_o,					// > test
	output		wire								tst_ab_o,					// 1=a/b test; 0=a/z test
	// stacks control
	output		wire								stk_clr_o,					// stacks clear
	output		wire	[STACKS-1:0]			pop_o,						// stacks pop
	output		wire	[STACKS-1:0]			push_o,						// stacks push
	// alu control
	output		wire	[STK_W-1:0]				a_sel_o,						// stack selector
	output		wire	[STK_W-1:0]				b_sel_o,						// stack selector
	output		wire								imda_o,						// 1=immediate data
	output		wire								imad_o,						// 1=immediate address
	output		wire								sgn_o,						// 1=signed
	output		wire								ext_o,						// 1=extended
	output		wire	[LG_W-1:0]				lg_o,							// see decode in notes
	output		wire								add_o,						// 1=add
	output		wire								sub_o,						// 1=subtract
	output		wire								mul_o,						// 1=multiply
	output		wire								shl_o,						// 1=shift left
	output		wire								cpy_o,						// 1=copy b
	output		wire								dm_o,							// 1=data mem
	output		wire								rtn_o,						// 1=return pc
	output		wire								rd_o,							// 1=read
	output		wire								wr_o							// 1=write
	);

	
	/*
	----------------------
	-- internal signals --
	----------------------
	*/
	`include "op_encode.h"
	wire												thrd_clr, thrd_intr;
	wire					[OP_CODE_W-1:0]		op_code;
	reg												op_ok, op_code_ok_lo, op_code_ok_hi;
	wire												op_code_er;
	//
	reg					[IM_DATA_W-1:0]		im_data;
	reg					[IM_ADDR_W-1:0]		im_addr;
	reg												pc_clr;
	reg												intr, gto, jmp, lit;
	reg												tst_lo, tst_hi, tst_ab, tst_gt, tst_lt, tst_eq;
	reg												stk_clr;
	reg												a_pop, b_pop;
	reg												push_lo, push_hi;
	wire					[STACKS-1:0]			pop, push;
	reg					[STK_W-1:0]				a_sel, b_sel;
	reg												imad_6b, imad_5b;
	reg												imda_8b, imda_6b;
	wire												imad, imda;
	reg												rtn, dm, cpy, shl, mul, sub, add, ext, sgn;
	reg					[LG_W-1:0]				lg;
	reg												rd, wr;



	/*
	================
	== code start ==
	================
	*/


	// optional input registers
	vector_sr
	#(
	.REGS			( REGS_IN ),
	.DATA_W		( 2+OP_CODE_W ),
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
	wire [1:0]	op_code_a_sel  = op_code[1:0];
	wire [1:0]	op_code_b_sel  = op_code[3:2];
	wire      	op_code_a_pop  = op_code[4];
	wire      	op_code_b_pop  = op_code[5];
	wire [9:0]	op_code_op     = op_code[15:6];
	wire [2:0]	op_code_tst_hi = op_code[14:12];
	wire [2:0]	op_code_tst_lo = op_code[8:6];
	wire [7:0]	op_code_im     = op_code[13:6];
	//
	reg  [2:0]	tst_hi_field, tst_lo_field;
	reg  [7:0]	im_field;


	// mid register for immediate and test fields
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			tst_hi_field <= 'b0;
			tst_lo_field <= 'b0;
			im_field <= 'b0;
		end else begin
			tst_hi_field <= op_code_tst_hi;
			tst_lo_field <= op_code_tst_lo;
			im_field <= op_code_im;
		end
	end

	// mid register if & case: clear, interrupt, and op_code decode
	always @ ( posedge clk_i or posedge rst_i ) begin
		if ( rst_i ) begin
			op_ok <= 'b0;
			op_code_ok_lo <= 'b0;
			op_code_ok_hi <= 'b0;
			pc_clr <= 'b0;
			lit <= 'b0;
			jmp <= 'b0;
			gto <= 'b0;
			intr <= 'b0;
			tst_hi <= 'b0;
			tst_lo <= 'b0;
			tst_ab <= 'b0;
			stk_clr <= 'b0;
			a_pop <= 'b0;
			b_pop <= 'b0;
			push_lo <= 'b0;
			push_hi <= 'b0;
			a_sel <= 'b0;
			b_sel <= 'b0;
			imad_6b <= 'b0;
			imad_5b <= 'b0;
			imda_8b <= 'b0;
			imda_6b <= 'b0;
			sgn <= 'b0;
			ext <= 'b0;
			lg <= 'b0;
			add <= 'b0;
			sub <= 'b0;
			mul <= 'b0;
			shl <= 'b0;
			cpy <= 'b0;
			dm <= 'b0;
			rtn <= 'b0;
			rd <= 'b0;
			wr <= 'b0;
		end else begin
			// default values
			op_ok <= 'b0;  // default is bad op
			op_code_ok_lo <= 'b0;  // default is bad opcode
			op_code_ok_hi <= 'b0;  // default is bad opcode
			pc_clr <= 'b0;  // default is no pc clear
			lit <= 'b0;  // default is no lit
			jmp <= 'b0;  // default is no jump
			gto <= 'b0;  // default is no goto
			intr <= 'b0;  // default is no interrupt
			tst_hi <= 'b0;  // default is no test
			tst_lo <= 'b0;  // default is no test
			tst_ab <= 'b0;  // default is comparison to zero
			stk_clr <= 'b0;  // default is no stack clear
			a_pop <= op_code_a_pop;  // default is op_code directive
			b_pop <= op_code_b_pop;  // default is op_code directive
			push_lo <= 'b0;  // default is no push
			push_hi <= 'b0;  // default is no push
			a_sel <= op_code_a_sel;  // default is op_code directive
			b_sel <= op_code_b_sel;  // default is op_code directive
			imad_6b <= 'b0;  // default is not immediate address
			imad_5b <= 'b0;  // default is not immediate address
			imda_8b <= 'b0;  // default is not immediate data
			imda_6b <= 'b0;  // default is not immediate data
			sgn <= 'b1;  // default is signed!
			ext <= 'b0;  // default is unextended
			lg <= 'b0;  // default is a&b
			add <= 'b0;  // default is logic
			sub <= 'b0;   // default is logic
			mul <= 'b0;  // default is logic
			shl <= 'b0;   // default is logic
			cpy <= 'b0;   // default is logic
			dm <= 'b0;  // default is logic
			rtn <= 'b0;  // default is logic
			rd <= 'b0;  // default is don't read
			wr <= 'b0;  // default is don't write
			if ( thrd_clr ) begin
				op_ok <= 'b1;  // good op
				pc_clr <= 'b1;  // clear pc
				stk_clr <= 'b1;  // clear stacks
				a_pop <= 'b0;  // no pop
				b_pop <= 'b0;  // no pop
			end else if ( thrd_intr ) begin
				op_ok <= 'b1;  // good op
				intr <= 'b1;  // don't inc PC
				a_pop <= 'b0;  // no pop
				b_pop <= 'b0;  // no pop
				push_lo <= 'b1;  // push
				a_sel <= 'b0;  // push return address to stack 0
				rtn <= 'b1;  // push pc
			end else begin
				casex ( op_code_op )
					///////////////////////////////////////
					// immediate read & write - 64 codes //
					///////////////////////////////////////
					op_rd_i : begin
						op_code_ok_lo <= 'b1;  // good opcode
						push_lo <= 'b1;  // push
						dm <= 'b1;  // dm
						rd <= 'b1;  // read
					end
					op_rd_ix : begin
						op_code_ok_lo <= 'b1;  // good opcode
						push_lo <= 'b1;  // push
						dm <= 'b1;  // dm
						rd <= 'b1;  // read
						ext <= 'b1;  // extended
					end
					op_wr_i : begin
						op_code_ok_lo <= 'b1;  // good opcode
						wr <= 'b1;  // write
					end
					op_wr_ix : begin
						op_code_ok_lo <= 'b1;  // good opcode
						wr <= 'b1;  // write
						ext <= 'b1;  // extended
					end
					////////////////////////////////////////////
					// immediate conditional jump - 384 codes //
					////////////////////////////////////////////
					op_jmp_iez, op_jmp_ilz, op_jmp_ilez : begin
						op_code_ok_lo <= 'b1;  // good opcode
						jmp <= 'b1;  // jump
						imad_5b <= 'b1;  // immediate address
						tst_hi <= 'b1;  // high field
					end
					op_jmp_ie, op_jmp_il, op_jmp_ile : begin
						op_code_ok_lo <= 'b1;  // good opcode
						jmp <= 'b1;  // jump
						imad_5b <= 'b1;  // immediate address
						tst_hi <= 'b1;  // high field
						tst_ab <= 'b1;  // a & b comparison
					end
					op_jmp_igz, op_jmp_igez, op_jmp_iglz : begin
						op_code_ok_lo <= 'b1;  // good opcode
						jmp <= 'b1;  // jump
						imad_5b <= 'b1;  // immediate address
						tst_hi <= 'b1;  // high field
					end
					op_jmp_iug, op_jmp_iuge, op_jmp_igl : begin  // gl is sign neutral
						op_code_ok_lo <= 'b1;  // good opcode
						jmp <= 'b1;  // jump
						imad_5b <= 'b1;  // immediate address
						tst_hi <= 'b1;  // high field
						tst_ab <= 'b1;  // a & b comparison
						sgn <= 'b0;  // unsigned
					end
					/////////////////////////////////////////////
					// immediate unconditional jump - 64 codes //
					/////////////////////////////////////////////
					op_jmp_i : begin
						op_code_ok_lo <= 'b1;  // good opcode
						jmp <= 'b1;  // jump
						imad_6b <= 'b1;  // immediate address
					end
					////////////////////////////////
					// immediate data - 256 codes //
					////////////////////////////////
					op_byt_i : begin
						op_code_ok_lo <= 'b1;  // good opcode
						push_lo <= 'b1;  // push
						imda_8b <= 'b1;  // immediate data
						cpy <= 'b1;  // copy
					end
					/////////////////////////////////
					// immediate shift - 128 codes //
					/////////////////////////////////
					op_shl_i : begin
						op_code_ok_lo <= 'b1;  // good opcode
						push_lo <= 'b1;  // push
						imda_6b <= 'b1;  // immediate data
						shl <= 'b1;  // shift left
					end
					op_shl_iu : begin
						op_code_ok_lo <= 'b1;  // good opcode
						push_lo <= 'b1;  // push
						imda_6b <= 'b1;  // immediate data
						shl <= 'b1;  // shift left
						sgn <= 'b0;  // unsigned
					end
					//////////////////////////////
					// immediate add - 64 codes //
					//////////////////////////////
					op_add_i : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						imda_6b <= 'b1;  // immediate data
						add <= 'b1;  // add
					end
					/////////////////////////////////////
					// conditional jump - 7 of 8 codes //
					/////////////////////////////////////
					op_jmp_ez, op_jmp_lz, op_jmp_lez, op_jmp_gz, op_jmp_gez, op_jmp_glz, op_jmp : begin
						op_code_ok_lo <= 'b1;  // good opcode
						jmp <= 'b1;  // jump
						tst_lo <= 'b1;  // low field
					end
					/////////////////////////////////////
					// conditional goto - 7 of 8 codes //
					/////////////////////////////////////
					op_gto_ez, op_gto_lz, op_gto_lez, op_gto_gz, op_gto_gez, op_gto_glz, op_gto : begin
						op_code_ok_lo <= 'b1;  // good opcode
						gto <= 'b1;  // goto
						tst_lo <= 'b1;  // low field
					end
					////////////////////////
					// singles - 48 codes //
					////////////////////////
					/////////////
					// group 1 //
					/////////////
					op_add : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						add <= 'b1;  // add
					end
					op_add_x : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						add <= 'b1;  // add
						ext <= 'b1;  // extended
					end
					op_add_ux : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						add <= 'b1;  // add
						ext <= 'b1;  // extended
						sgn <= 'b0;  // unsigned
					end
					op_sub : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						sub <= 'b1;  // sub
					end
					op_sub_x : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						sub <= 'b1;  // sub
						ext <= 'b1;  // extended
					end
					op_sub_ux : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						sub <= 'b1;  // sub
						ext <= 'b1;  // extended
						sgn <= 'b0;  // unsigned
					end
					op_mul : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						mul <= 'b1;  // multiply
					end
					op_mul_x : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						mul <= 'b1;  // multiply
						ext <= 'b1;  // extended
					end
					op_mul_ux : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						mul <= 'b1;  // multiply
						ext <= 'b1;  // extended
						sgn <= 'b0;  // unsigned
					end
					op_shl : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						shl <= 'b1;  // shift left
					end
					op_shl_u : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						shl <= 'b1;  // shift left
						sgn <= 'b0;  // unsigned
					end
					/////////////
					// group 2 //
					/////////////
					op_and : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
					end
					op_or : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						lg <= 'd1;
					end
					op_xor : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						lg <= 'd2;
					end
					op_not : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						lg <= 'd3;
					end
					op_and_b : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						ext <= 'b1;  // extended
					end
					op_or_b : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						lg <= 'd1;
						ext <= 'b1;  // extended
					end
					op_xor_b : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						lg <= 'd2;
						ext <= 'b1;  // extended
					end
					/////////////
					// group 3 //
					/////////////
					op_lit : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						lit <= 'b1;  // lit
						dm <= 'b1;  // dm
					end
					op_lit_u : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						lit <= 'b1;  // lit
						dm <= 'b1;  // dm
						sgn <= 'b0;  // unsigned
					end
					op_lit_x : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						lit <= 'b1;  // lit
						dm <= 'b1;  // dm
						ext <= 'b1;  // extended
					end
					op_cpy : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						cpy <= 'b1;  // copy
					end
					op_pc : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						rtn <= 'b1;  // push pc
					end
					op_gsb : begin
						op_code_ok_hi <= 'b1;  // good opcode
						push_hi <= 'b1;  // push
						gto <= 'b1;  // goto
						rtn <= 'b1;  // push pc
					end
					op_cls : begin
						op_code_ok_hi <= 'b1;  // good opcode
						stk_clr <= 'b1;  // stack clear
						a_pop <= 'b0;  // no pop
						b_pop <= 'b0;  // no pop
					end
					op_pop : begin
						op_code_ok_hi <= 'b1;  // good opcode
					end
					op_nop : begin
						op_code_ok_hi <= 'b1;  // good opcode
						a_pop <= 'b0;  // no pop
						b_pop <= 'b0;  // no pop
					end
					default: begin
						// nothing here
					end
				endcase
			end
		end
	end

	
	// decode test
	always @ ( * ) begin
		casex ( { tst_hi, tst_lo } )
			2'b00 : { tst_gt, tst_lt, tst_eq } <= 3'b111;  // default is always
			2'b01 : { tst_gt, tst_lt, tst_eq } <= tst_lo_field;
			2'b1x : { tst_gt, tst_lt, tst_eq } <= tst_hi_field;
		endcase
	end

	// decode immediate data
	always @ ( * ) begin
		case ( imda_6b )
			1'b0 : im_data <= im_field;  // byte default
			1'b1 : im_data <= $signed( im_field[5:0] );  // signed 6 bit
		endcase
	end

	// decode immediate address
	always @ ( * ) begin
		case ( imad_5b )
			1'b0 : im_addr <= im_field[IM_ADDR_W-1:0];  // 6 bit default
			1'b1 : im_addr <= $signed( im_field[4:0] );  // signed 5 bit
		endcase
	end

	// decode control
	assign imda = imda_8b | imda_6b;
	assign imad = imad_6b | imad_5b;

	// decode pop & push
	assign pop = ( a_pop << a_sel ) | ( b_pop << b_sel );
	assign push = ( ( push_lo | push_hi ) << a_sel );
	
	// decode errors
	assign op_code_er = ~( op_ok | op_code_ok_lo | op_code_ok_hi );


	// optional output registers
	vector_sr
	#(
	.REGS			( REGS_OUT ),
	.DATA_W		( 1+IM_ADDR_W+IM_DATA_W+10+STACKS+STACKS+STK_W+STK_W+9+LG_W+4 ),
	.RESET_VAL	( 0 )
	)
	out_regs
	(
	.clk_i		( clk_i ),
	.rst_i		( rst_i ),
	.data_i		( { op_code_er,   im_addr,   im_data,   pc_clr,   intr,   gto,   jmp,   lit,   tst_gt,   tst_lt,   tst_eq,   tst_ab,   stk_clr,   pop,   push,   a_sel,   b_sel,   imda,   imad,   rtn,   dm,   cpy,   shl,   mul,   sub,   add,   lg,   ext,   sgn,   rd,   wr } ),
	.data_o		( { op_code_er_o, im_addr_o, im_data_o, pc_clr_o, intr_o, gto_o, jmp_o, lit_o, tst_gt_o, tst_lt_o, tst_eq_o, tst_ab_o, stk_clr_o, pop_o, push_o, a_sel_o, b_sel_o, imda_o, imad_o, rtn_o, dm_o, cpy_o, shl_o, mul_o, sub_o, add_o, lg_o, ext_o, sgn_o, rd_o, wr_o } )
	);

	
endmodule
