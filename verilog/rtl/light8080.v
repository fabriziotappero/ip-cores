//---------------------------------------------------------------------------------------
// light8080 : Intel 8080 binary compatible core
//---------------------------------------------------------------------------------------
// v1.3    (12 FEB 2012) Fix: General solution to AND, OR, XOR clearing CY,ACY.
// v1.2    (08 jul 2010) Fix: XOR operations were not clearing CY,ACY.
// v1.1    (20 sep 2008) Microcode bug in INR fixed.
// v1.0    (05 nov 2007) First release. Jose A. Ruiz.
//
// This file and all the light8080 project files are freeware (See COPYING.TXT)
//---------------------------------------------------------------------------------------
//
// vma :      enable a memory or io r/w access.
// io :       access in progress is io (and not memory) 
// rd :       read memory or io 
// wr :       write memory or io
// data_out : data output
// addr_out : memory and io address
// data_in :  data input
// halt :     halt status (1 when in halt state)
// inte :     interrupt status (1 when enabled)
// intr :     interrupt request
// inta :     interrupt acknowledge
// reset :    synchronous reset
// clk :      clock
//
// (see timing diagrams at bottom of file)
//---------------------------------------------------------------------------------------
//
// Timing diagram 1: RD and WR cycles
//
//            1     2     3     4     5     6     7     8     
//             __    __    __    __    __    __    __    __   
// clk      __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__
//
//          ==|=====|=====|=====|=====|=====|=====|=====|=====|
//
// addr_o   xxxxxxxxxxxxxx< ADR >xxxxxxxxxxx< ADR >xxxxxxxxxxx
//
// data_i   xxxxxxxxxxxxxxxxxxxx< Din >xxxxxxxxxxxxxxxxxxxxxxx
//
// data_o   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx< Dout>xxxxxxxxxxx
//                         _____             _____
// vma_o    ______________/     \___________/     \___________
//                         _____
// rd_o     ______________/     \_____________________________
//                                           _____
// wr_o     ________________________________/     \___________
//
// (functional diagram, actual time delays not shown)
////////////////////////////////////////////////////////////////////////////////
// This diagram shows a read cycle and a write cycle back to back.
// In clock edges (4) and (7), the address is loaded into the external 
// synchronous RAM address register. 
// In clock edge (5), read data is loaded into the CPU.
// In clock edge (7), write data is loaded into the external synchronous RAM.
// In actual operation, the CPU does about 1 rd/wr cycle for each 5 clock 
// cycles, which is a waste of RAM bandwidth.
//
//---------------------------------------------------------------------------------------

module light8080 
(  
	clk, reset, 
	addr_out, vma, 
	io, rd, 
	wr, fetch, 
	data_in, data_out, 
	inta, inte, 
	halt, intr 
);

//---------------------------------------------------------------------------------------
// 
// All memory and io accesses are synchronous (rising clock edge). Signal vma 
// works as the master memory and io synchronous enable. More specifically:
//
//    * All memory/io control signals (io,rd,wr) are valid only when vma is 
//      high. They never activate when vma is inactive. 
//    * Signals data_out and address are only valid when vma=1'b1. The high 
//      address byte is 0x00 for all io accesses.
//    * Signal data_in should be valid by the end of the cycle after vma=1'b1, 
//      data is clocked in by the rising clock edge.
//
// All signals are assumed to be synchronous to the master clock. Prevention of
// metastability, if necessary, is up to you.
// 
// Signal reset needs to be active for just 1 clock cycle (it is sampled on a 
// positive clock edge and is subject to setup and hold times).
// Once reset is deasserted, the first fetch at address 0x0000 will happen 4
// cycles later.
//
// Signal intr is sampled on all positive clock edges. If asserted when inte is
// high, interrupts will be disabled, inta will be asserted high and a fetch 
// cycle will occur immediately after the current instruction ends execution,
// except if intr was asserted at the last cycle of an instruction. In that case
// it will be honored after the next instruction ends.
// The fetched instruction will be executed normally, except that PC will not 
// be valid in any subsequent fetch cycles of the same instruction, 
// and will not be incremented (In practice, the same as the original 8080).
// inta will remain high for the duration of the fetched instruction, including
// fetch and execution time (in the original 8080 it was high only for the 
// opcode fetch cycle). 
// PC will not be autoincremented while inta is high, but it can be explicitly 
// modified (e.g. RST, CALL, etc.). Again, the same as the original.
// Interrupts will be disabled upon assertion of inta, and remain disabled 
// until explicitly enabled by the program (as in the original).
// If intr is asserted when inte is low, the interrupt will not be attended but
// it will be registered in an int_pending flag, so it will be honored when 
// interrupts are enabled.
// 
//
// The above means that any instruction can be supplied in an inta cycle, 
// either single byte or multibyte. See the design notes.
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
// module interfaces 
input			clk;
input			reset; 

output	[15:0]	addr_out;
output			vma;
output			io;
output			rd;
output			wr;
output			fetch;

input	[7:0]	data_in;
output	[7:0]	data_out;

output			inta;
output			inte;
output			halt;
input			intr;

//---------------------------------------------------------------------------------------
// internal signals 
// addr_low: low byte of address
reg [7:0] addr_low; 
// IR: instruction register. some bits left unused.  
reg [7:0] IR;
// s_field: IR field, sss source reg code
wire [2:0] s_field;
// d_field: IR field, ddd destination reg code
wire [2:0] d_field;
// p_field: IR field, pp 16-bit reg pair code
wire [1:0] p_field;
// rbh: 1 when p_field=11, used in reg bank addressing for 'special' regs
wire rbh; 				// 1 when P=11 (special case)  
// alu_op: uinst field, ALU operation code 
wire [3:0] alu_op; 
// uc_addr: microcode (ucode) address 
reg [7:0] uc_addr;
// next_uc_addr: computed next microcode address (uaddr++/jump/ret/fetch)
reg [8:0] next_uc_addr;
// uc_jmp_addr: uinst field, absolute ucode jump address
wire [7:0] uc_jmp_addr;
// uc_ret_address: ucode return address saved in previous jump
reg [7:0] uc_ret_addr; 
// addr_plus_1: uaddr + 1
wire [7:0] addr_plus_1;
// do_reset: reset, delayed 1 cycle // used to reset the microcode sequencer
reg do_reset; 

// uc_flags1: uinst field, encoded flag of group 1 (see ucode file)
wire [2:0] uc_flags1;
// uc_flags2: uinst field, encoded flag of group 2 (see ucode file)
wire [2:0] uc_flags2; 
// uc_addr_sel: selection of next uc_addr, composition of 4 flags
wire [3:0] uc_addr_sel;
// NOTE: see microcode file for information on flags
wire uc_jsr;  		// uinst field, decoded 'jsr' flag
wire uc_tjsr;  		// uinst field, decoded 'tjsr' flag
wire uc_decode;		// uinst field, decoded 'decode' flag
wire uc_end;		// uinst field, decoded 'end' flag
reg condition_reg;	// registered tjst condition
// condition: tjsr condition (computed ccc condition from '80 instructions)
reg condition; 
// condition_sel: IR field, ccc condition code
wire uc_do_jmp;		// uinst jump (jsr/tjsr) flag, pipelined
wire uc_do_ret;		// ret flag, pipelined
wire uc_halt_flag;	// uinst field, decoded 'halt' flag
wire uc_halt;		// halt command
reg halt_reg;		// halt status reg, output as 'halt' signal
wire uc_ei;			// uinst field, decoded 'ei' flag
wire uc_di;			// uinst field, decoded 'di' flag
reg inte_reg;		// inte status reg, output as 'inte' signal
reg int_pending;	// intr requested, inta not active yet
reg inta_reg;		// inta status reg, output as 'inta'
wire clr_t1;		// uinst field, explicitly erase T1
wire do_clr_t1;		// clr_t1 pipelined
wire clr_t2;		// uinst field, explicitly erase T2
wire do_clr_t2;		// clr_t2 pipelined
wire [31:0] ucode;	// microcode word
reg [24:0] ucode_field2;	// pipelined microcode
// used to delay interrup enable for one entire instruction after EI
reg delayed_ei;

wire load_al; 		// uinst field, load AL reg from rbank
wire load_addr; 	// uinst field, enable external addr reg load
wire load_t1; 		// uinst field, load reg T1 
wire load_t2; 		// uinst field, load reg T2
wire mux_in; 		// uinst field, T1/T2 input data selection
wire load_do; 		// uinst field, pipelined, load DO reg
// rb_addr_sel: uinst field, rbank address selection: (sss,ddd,pp,ra_field)
wire [1:0] rb_addr_sel;
// ra_field: uinst field, explicit reg bank address
wire [3:0] ra_field; 
wire [7:0] rbank_data;	// rbank output
reg [7:0] alu_output;	// ALU output
// data_output: datapath output: ALU output vs. F reg 
wire [7:0] data_output; 
reg [7:0] T1; 		// T1 reg (ALU operand)
reg [7:0] T2; 		// T2 reg (ALU operand)
// alu_input: data loaded into T1, T2: rbank data vs. DI
wire [7:0] alu_input;
wire we_rb;							// uinst field, commands a write to the rbank
wire inhibit_pc_increment;			// avoid PC changes (during INTA)
reg [3:0] rbank_rd_addr; 			// rbank rd addr
wire [3:0] rbank_wr_addr; 			// rbank wr addr
reg [7:0] DO; 						// data output reg
    
// Register bank : BC, DE, HL, AF, [PC, XY, ZW, SP]
// This will be implemented as asynchronous LUT RAM in those devices where this
// feature is available (Xilinx) and as multiplexed registers where it isn't
// (Altera).
reg [7:0] rbank[0:15];

reg [7:0] flag_reg;		// F register
// flag_pattern: uinst field, F update pattern: which flags are updated
wire [1:0] flag_pattern;
wire flag_s; 			// new computed S flag  
wire flag_z; 			// new computed Z flag
wire flag_p; 			// new computed P flag
wire flag_cy; 			// new computed C flag
wire flag_cy_1; 		// C flag computed from arith/logic operation
wire flag_cy_2; 		// C flag computed from CPC circuit
wire do_cy_op; 			// ALU explicit CY operation (CPC, etc.)
wire do_cy_op_d; 		// do_cy_op, pipelined
wire do_cpc; 			// ALU operation is CPC
wire do_cpc_d; 			// do_cpc, pipelined
wire do_daa; 			// ALU operation is DAA
wire clear_cy; 			// Instruction unconditionally clears CY
wire clear_ac; 			// Instruction unconditionally clears AC
wire set_ac; 			// Instruction unconditionally sets AC
wire flag_ac; 			// new computed half carry flag
// flag_aux_cy: new computed half carry flag (used in 16-bit ops)
wire flag_aux_cy;
wire load_psw; 			// load F register

// aux carry computation and control signals
wire use_aux; 			// decoded from flags in 1st phase
wire use_aux_cy; 		// 2nd phase signal
reg reg_aux_cy;
wire aux_cy_in;
wire set_aux_cy;
wire set_aux;

// ALU control signals, together they select ALU operation
wire [1:0] alu_fn;
wire use_logic; 		// logic/arith mux control 
wire [1:0] mux_fn;
wire use_psw; 			// ALU/F mux control

// ALU arithmetic operands and result
wire [8:0] arith_op1;
wire [8:0] arith_op2;
wire [8:0] arith_op2_sgn;
wire [8:0] arith_res;
wire [7:0] arith_res8;

// ALU DAA intermediate signals (DAA has fully dedicated logic)
wire [8:0] daa_res;
reg [8:0] daa_res9;
wire daa_test1;
wire daa_test1a;
wire daa_test2;
wire [7:0] arith_daa_res;
wire cy_daa;
    
// ALU CY flag intermediate signals
wire cy_in_sgn;
wire cy_in;
wire cy_in_gated;
wire cy_adder;
wire cy_arith;
wire cy_shifter;

// ALU intermediate results
reg [7:0] logic_res;
wire [7:0] shift_res;
wire [7:0] alu_mux1;
    
//---------------------------------------------------------------------------------------
// module implementation 
// IR register, load when uc_decode flag activates 
always @ (posedge clk) 
begin
	if (uc_decode) 
		IR <= data_in;
end

assign s_field = IR[2:0]; // IR field extraction : sss reg code
assign d_field = IR[5:3]; // ddd reg code
assign p_field = IR[5:4]; // pp 16-bit reg pair code   

//---------------------------------------------------------------------------------------
// Microcode sequencer
// do_reset is reset delayed 1 cycle
always @ (posedge clk)    
	do_reset <= reset;

assign uc_flags1 = ucode[31:29];
assign uc_flags2 = ucode[28:26];

// microcode address control flags are gated by do_reset (reset has priority)
assign uc_do_ret = ((uc_flags2 == 3'b011) && !do_reset) ? 1'b1 : 1'b0;
assign uc_jsr    = ((uc_flags2 == 3'b010) && !do_reset) ? 1'b1 : 1'b0;  
assign uc_tjsr   = ((uc_flags2 == 3'b100) && !do_reset) ? 1'b1 : 1'b0;    
assign uc_decode = ((uc_flags1 == 3'b001) && !do_reset) ? 1'b1 : 1'b0;  
assign uc_end    = (((uc_flags2 == 3'b001) || (uc_tjsr && !condition_reg)) && !do_reset) ? 1'b1 : 1'b0;  

// other microinstruction flags are decoded
assign uc_halt_flag = (uc_flags1 == 3'b111) ? 1'b1 : 1'b0;
assign uc_halt = (uc_halt_flag && !inta_reg) ? 1'b1 : 1'b0;  
assign uc_ei   = (uc_flags1 == 3'b011) ? 1'b1 : 1'b0;  
assign uc_di   = ((uc_flags1 == 3'b010) || inta_reg) ? 1'b1 : 1'b0; 
// clr_t1/2 clears T1/T2 when explicitly commanded; T2 and T1 clear implicitly 
// at the end of each instruction (by uc_decode)
assign clr_t2  = (uc_flags2 == 3'b001) ? 1'b1 : 1'b0;
assign clr_t1  = (uc_flags1 == 3'b110) ? 1'b1 : 1'b0;
assign use_aux = (uc_flags1 == 3'b101) ? 1'b1 : 1'b0;  
assign set_aux = (uc_flags2 == 3'b111) ? 1'b1 : 1'b0;

assign load_al = ucode[24];
assign load_addr = ucode[25];

assign do_cy_op_d = (ucode[5:2] == 4'b1011) ? 1'b1 : 1'b0; // decode CY ALU op
assign do_cpc_d = ucode[0];	// decode CPC ALU op

// uinst jump command, either unconditional or on a given condition
assign uc_do_jmp = uc_jsr | (uc_tjsr & condition_reg);

assign vma = load_addr;  // addr is valid, either for memory or io

// assume the only uinst that does memory access in the range 0..f is 'fetch'
assign fetch = ((uc_addr[7:4] == 4'b0) && load_addr) ? 1'b1 : 1'b0;

// external bus interface control signals
assign io = (uc_flags1 == 3'b100) ? 1'b1 : 1'b0; // IO access (vs. memory)
assign rd = (uc_flags2 == 3'b101) ? 1'b1 : 1'b0; // RD access
assign wr = (uc_flags2 == 3'b110) ? 1'b1 : 1'b0; // WR access  

assign uc_jmp_addr = {ucode[11:10], ucode[5:0]};
assign uc_addr_sel = {uc_do_ret, uc_do_jmp, uc_decode, uc_end};
assign addr_plus_1 = uc_addr + 8'd1;

// TODO simplify this!!

// NOTE: when end==1'b1 we jump either to the FETCH ucode or to the HALT ucode
// depending on the value of the halt signal.
// We use the unregistered uc_halt instead of halt_reg because otherwise #end
// should be on the cycle following #halt, wasting a cycle.
// This means that the flag #halt has to be used with #end or will be ignored. 
// Note how we used DI (containing instruction opcode) as a microcode address
always @ (*)
begin 
	case (uc_addr_sel)
		4'b1000:	next_uc_addr <= {1'b0, uc_ret_addr};	// ret                        
		4'b0100:	next_uc_addr <= {1'b0, uc_jmp_addr};	// jsr/tjsr                   
		4'b0000:	next_uc_addr <= {1'b0, addr_plus_1};	// uaddr++                    
		4'b0001:	next_uc_addr <= {6'b0, uc_halt, 2'b11};	// end: go to fetch/halt uaddr
		default:	next_uc_addr <= {1'b1, data_in};		// decode fetched address 
	endcase  
end 

// read microcode rom is implemented here in a different module 
micro_rom rom 
(
	.clock(clk), 
	.uc_addr(next_uc_addr), 
	.uc_dout(ucode) 
);

// microcode address register
always @ (posedge clk)
begin 
	if (reset) 
		uc_addr <= 8'h0;
	else
		uc_addr <= next_uc_addr[7:0];  
end 

// ucode address 1-level 'return stack'
always @ (posedge clk)
begin
	if (reset) 
		uc_ret_addr <= 8'h0;
	else if (uc_do_jmp) 
		uc_ret_addr <= addr_plus_1;
end    

assign alu_op = ucode[3:0]; 

// pipeline uinst field2 for 1-cycle delayed execution.
// note the same rbank addr field is used in cycles 1 and 2; this enforces
// some constraints on uinst programming but simplifies the system.
always @ (posedge clk)
begin
	ucode_field2 <= {do_cy_op_d, do_cpc_d, clr_t2, clr_t1, 
					  set_aux, use_aux, rbank_rd_addr, ucode[14:4], alu_op};
end

//---------------------------------------------------------------------------------------
// HALT logic
always @ (posedge clk)
begin
	if (reset || int_pending)	//inta_reg
		halt_reg <= 1'b0;
	else if (uc_halt) 
		halt_reg <= 1'b1;
end

assign halt = halt_reg;

//---------------------------------------------------------------------------------------
// INTE logic // inte_reg = 1'b1 means interrupts ENABLED
always @ (posedge clk)
begin
	if (reset) 
	begin 
		inte_reg <= 1'b0;
		delayed_ei <= 1'b0;
	end 
	else 
	begin 
		if ((uc_di || uc_ei) && uc_end) 
		begin 
			//inte_reg <= uc_ei;
			delayed_ei <= uc_ei; // FIXME DI must not be delayed
		end 
		
		// at the last cycle of every instruction...
		if (uc_end) 
		begin 
			// ...disable interrupts if the instruction is DI...
			if (uc_di) 
				inte_reg <= 1'b0;
			else
			// ...of enable interrupts after the instruction following EI
				inte_reg <= delayed_ei;
		end 
	end 
end 

assign inte = inte_reg;

// interrupts are ignored when inte=1'b0 but they are registered and will be
// honored when interrupts are enabled
always @ (posedge clk)
begin
	if (reset) 
		int_pending <= 1'b0;
	else 
	begin 
		// intr will raise int_pending only if inta has not been asserted. 
		// Otherwise, if intr overlapped inta, we'd enter a microcode endless 
		// loop, executing the interrupt vector again and again.
		if (intr && inte_reg && !int_pending && !inta_reg) 
			int_pending <= 1'b1;
		else if (inte_reg && uc_end) 
			// int_pending is cleared when we're about to service the interrupt, 
			// that is when interrupts are enabled and the current instruction ends.
			int_pending <= 1'b0;
	end 
end

//---------------------------------------------------------------------------------------
// INTA logic
// INTA goes high from END to END, that is for the entire time the instruction
// takes to fetch and execute; in the original 8080 it was asserted only for 
// the M1 cycle.
// All instructions can be used in an inta cycle, including XTHL which was
// forbidden in the original 8080. 
// It's up to you figuring out which cycle is which in multibyte instructions.
always @ (posedge clk)
begin
	if (reset) 
		inta_reg <= 1'b0;
	else if (int_pending && uc_end) 
 		// enter INTA state
		inta_reg <= 1'b1;
	else if (uc_end && !uc_halt_flag) 
		// exit INTA state
		// NOTE: don't reset inta when exiting halt state (uc_halt_flag=1'b1).
		// If we omit this condition, when intr happens on halt state, inta
		// will only last for 1 cycle, because in halt state uc_end is 
		// always asserted.
		inta_reg <= 1'b0;
end    
  
assign inta = inta_reg;

//---------------------------------------------------------------------------------------
// Datapath

// extract pipelined microcode fields
assign ra_field = ucode[18:15];
assign load_t1 = ucode[23];  
assign load_t2 = ucode[22];  
assign mux_in = ucode[21];
assign rb_addr_sel = ucode[20:19];  
assign load_do = ucode_field2[7];
assign set_aux_cy = ucode_field2[20]; 
assign do_clr_t1 = ucode_field2[21]; 
assign do_clr_t2 = ucode_field2[22]; 

// T1 register 
always @ (posedge clk)
begin
	if (reset || uc_decode || do_clr_t1) 
		T1 <= 8'h0;
	else if (load_t1) 
		T1 <= alu_input;
end

// T2 register
always @ (posedge clk)
begin
	if (reset || uc_decode || do_clr_t2) 
		T2 <= 8'h0;
	else if (load_t2) 
		T2 <= alu_input;
end

// T1/T2 input data mux
assign alu_input = mux_in ? rbank_data : data_in;

// register bank address mux logic
assign rbh = (p_field == 2'b11) ? 1'b1 : 1'b0;

always @ (*) 
begin 
	case (rb_addr_sel) 
		2'b00:	rbank_rd_addr <= ra_field;    
		2'b01:	rbank_rd_addr <= {1'b0, s_field};
		2'b10:	rbank_rd_addr <= {1'b0, d_field}; 
		2'b11:	rbank_rd_addr <= {rbh, p_field, ra_field[0]};
	endcase 
end 

// RBank writes are inhibited in INTA state, but only for PC increments.
assign inhibit_pc_increment = (inta_reg && use_aux_cy && (rbank_wr_addr[3:1] == 3'b100)) ? 1'b1 : 1'b0;
assign we_rb = ucode_field2[6] & ~inhibit_pc_increment;

// Register bank logic 
// NOTE: read is asynchronous, while write is synchronous; but note also
// that write phase for a given uinst happens the cycle after the read phase.
// This way we give the ALU time to do its job.
assign rbank_wr_addr = ucode_field2[18:15];
always @ (posedge clk)
begin
	if (we_rb) 
		rbank[rbank_wr_addr] <= alu_output;
end
assign rbank_data = rbank[rbank_rd_addr];

// should we read F register or ALU output?
assign use_psw = (ucode_field2[5:4] == 2'b11) ? 1'b1 : 1'b0;
assign data_output = use_psw ? flag_reg : alu_output;

always @ (posedge clk)
begin
	if (load_do) 
		DO <= data_output;
end

//---------------------------------------------------------------------------------------
// ALU 
assign alu_fn = ucode_field2[1:0];
assign use_logic = ucode_field2[2];
assign mux_fn = ucode_field2[4:3];
//#### make sure this is "00" in the microcode when no F updates should happen!
assign flag_pattern =  ucode_field2[9:8];
assign use_aux_cy = ucode_field2[19];
assign do_cpc = ucode_field2[23];
assign do_cy_op = ucode_field2[24];
assign do_daa = (ucode_field2[5:2] == 4'b1010) ? 1'b1 : 1'b0;

// ucode_field2(14) will be set for those instructions that modify CY and AC
// without following the standard rules -- AND, OR and XOR instructions.
// Some instructions will unconditionally clear CY (AND, OR, XOR)
assign clear_cy = ucode_field2[14];
// Some instructions will unconditionally clear AC (OR, XOR)...
assign clear_ac = (ucode_field2[14] && (ucode_field2[5:0] != 6'b000100)) ? 1'b1 : 1'b0;
// ...and some others unconditionally SET AC (AND)
assign set_ac = (ucode_field2[14] && (ucode_field2[5:0] == 6'b000100)) ? 1'b1 : 1'b0;

assign aux_cy_in = (!set_aux_cy) ? reg_aux_cy : 1'b1;

// carry input selection: normal or aux (for 16 bit increments)?
assign cy_in = (!use_aux_cy) ? flag_reg[0] : aux_cy_in;

// carry is not used (0) in add/sub operations
assign cy_in_gated = cy_in & alu_fn[0];

//---------------------------------------------------------------------------------------
// Adder/substractor

// zero extend adder operands to 9 bits to ease CY output synthesis
// use zero extension because we're only interested in cy from 7 to 8
assign arith_op1 = {1'b0, T2};
assign arith_op2 = {1'b0, T1};

// The adder/substractor is done in 2 stages to help XSL synth it properly
// Other codings result in 1 adder + a substractor + 1 mux

// do 2nd op 2's complement if substracting...
assign arith_op2_sgn = (!alu_fn[1]) ? arith_op2 : ~arith_op2;
// ...and complement cy input too
assign cy_in_sgn = (!alu_fn[1]) ? cy_in_gated : ~cy_in_gated;

// once 2nd operand has been negated (or not) add operands normally
assign arith_res = arith_op1 + arith_op2_sgn + cy_in_sgn;

// take only 8 bits; 9th bit of adder is cy output
assign arith_res8 = arith_res[7:0];
assign cy_adder = arith_res[8];

//---------------------------------------------------------------------------------------
// DAA dedicated logic
// Note a DAA takes 2 cycles to complete! 

//daa_test1a=1'b1 when daa_res9(7:4) > 0x06
assign daa_test1a = arith_op2[3] & (arith_op2[2] | arith_op2[1] | arith_op2[0]);  
assign daa_test1 = (flag_reg[4] || daa_test1a) ? 1'b1 : 1'b0;

always @ (posedge clk)
begin
	if (reset) 
		daa_res9 <= 9'b0;
	else if (daa_test1) 
		daa_res9 <= arith_op2 + 9'd6;
	else
		daa_res9 <= arith_op2;
end

assign daa_test2 = (flag_reg[0] || daa_test1a) ? 1'b1 : 1'b0;

assign daa_res = daa_test2 ? ({1'b0, daa_res9[7:0]} + 9'h60) : daa_res9;

assign cy_daa = daa_res[8];

// DAA vs. adder mux
assign arith_daa_res = do_daa ? daa_res[7:0] : arith_res8;  

// DAA vs. adder CY mux
assign cy_arith = do_daa ? cy_daa : cy_adder;

//---------------------------------------------------------------------------------------
// Logic operations block
always @ (*) 
begin 
	case (alu_fn) 
		2'b00:	logic_res <= T1 & T2; 
		2'b01:	logic_res <= T1 ^ T2; 
		2'b10:	logic_res <= T1 | T2; 
		2'b11:	logic_res <= ~T1;   
	endcase 
end 

//---------------------------------------------------------------------------------------
// Shifter
assign shift_res[6:1] = (!alu_fn[0]) ? T1[5:0] : T1[7:2]; 

assign shift_res[0] = (alu_fn == 2'b00) ? T1[7] :	// rot left 
                      (alu_fn == 2'b10) ? cy_in :	// rot left through carry
                                          T1[1];	// rot right
assign shift_res[7] = (alu_fn == 2'b01) ? T1[0] :	// rot right
                      (alu_fn == 2'b11) ? cy_in :	// rot right through carry
                                          T1[6]; 	// rot left

assign cy_shifter = (!alu_fn[0]) ? T1[7] :		// left
                                   T1[0]; 		// right

assign alu_mux1 = use_logic ? logic_res : shift_res;

always @ (*) 
begin 
	case (mux_fn) 
		2'b00:	alu_output <= alu_mux1;
		2'b01:	alu_output <= arith_daa_res;
		2'b10:	alu_output <= ~alu_mux1;
		2'b11:	alu_output <= {2'b0, d_field, 3'b0}; 	// RST  
	endcase 
end 

//---------------------------------------------------------------------------------------
// flag computation 
assign flag_s = alu_output[7];
assign flag_p = ~(^alu_output);
assign flag_z = (alu_output == 8'h0) ? 1'b1 : 1'b0;

// AC is either the CY from bit 4 OR 0 if the instruction clears it implicitly
assign flag_ac = set_ac    ? 1'b1 : 
                 clear_ac  ? 1'b0 : 
                 (arith_op1[4] ^ arith_op2_sgn[4] ^ alu_output[4]);

// CY comes from the adder or the shifter, or is 0 if the instruction 
// implicitly clears it.
assign flag_cy_1 = clear_cy   ? 1'b0      :
                   use_logic  ? cy_arith  : 
                   cy_shifter;
                     
assign flag_cy_2 = (!do_cpc) ? ~flag_reg[0] : 1'b1; // cmc, stc
assign flag_cy = (!do_cy_op) ? flag_cy_1 : flag_cy_2;

assign flag_aux_cy = cy_adder;

// auxiliary carry reg
always @ (posedge clk)
begin
	if (reset || uc_decode) 
		reg_aux_cy <= 1'b1; // inits to 0 every instruction
	else
		reg_aux_cy <= flag_aux_cy;
end              

// load PSW from ALU (i.e. POP AF) or from flag signals
assign load_psw = (we_rb && (rbank_wr_addr == 4'b0110)) ? 1'b1 : 1'b0;

// The F register has been split in two separate groups that always update
// together (C and all others).

// F register, flags S,Z,AC,P and C 
always @ (posedge clk)
begin
	if (reset) 
	begin 
		flag_reg[7] <= 1'b0;
		flag_reg[6] <= 1'b0;
		flag_reg[5] <= 1'b0; // constant flag
		flag_reg[4] <= 1'b0;
		flag_reg[3] <= 1'b0; // constant flag
		flag_reg[2] <= 1'b0;
		flag_reg[1] <= 1'b1; // constant flag
		flag_reg[0] <= 1'b0;
	end 
	else 
	begin 
		if (flag_pattern[1])
		begin  
			if (load_psw) 
			begin 
				flag_reg[7] <= alu_output[7];
				flag_reg[6] <= alu_output[6];
				flag_reg[4] <= alu_output[4];
				flag_reg[2] <= alu_output[2];
			end 
			else
			begin 
				flag_reg[7] <= flag_s;
				flag_reg[6] <= flag_z;
				flag_reg[4] <= flag_ac;
				flag_reg[2] <= flag_p;      
			end 
		end 

		// C flag 		
		if (flag_pattern[0]) 
		begin 
			if (load_psw) 
				flag_reg[0] <= alu_output[0];  
			else
				flag_reg[0] <= flag_cy;
		end 
		
		// constant flags 
		flag_reg[5] <= 1'b0; // constant flag
		flag_reg[3] <= 1'b0; // constant flag
		flag_reg[1] <= 1'b1; // constant flag
	end 
end

//---------------------------------------------------------------------------------------
// Condition computation
always @ (*) 
begin 
	case (d_field[2:0]) 
		3'b000:	condition <= ~flag_reg[6]; // NZ 
		3'b001:	condition <=  flag_reg[6]; // Z 
		3'b010:	condition <= ~flag_reg[0]; // NC
		3'b011:	condition <=  flag_reg[0]; // C 
		3'b100:	condition <= ~flag_reg[2]; // PO
		3'b101:	condition <=  flag_reg[2]; // PE
		3'b110:	condition <= ~flag_reg[7]; // P 
		3'b111:	condition <=  flag_reg[7]; // M 
	endcase 
end 
                
// condition is registered to shorten the delay path; the extra 1-cycle
// delay is not relevant because conditions are tested in the next instruction
// at the earliest, and there's at least the fetch uinsts intervening.                
always @ (posedge clk)
begin
	if (reset) 
		condition_reg <= 1'b0;
	else
		condition_reg <= condition;
end                            

// low byte address register
always @ (posedge clk)
begin
	if (reset) 
		addr_low <= 8'h0;
	else if (load_al) 
		addr_low <= rbank_data;
end

// note external address registers (high byte) are loaded directly from rbank
assign addr_out = {rbank_data, addr_low};

assign data_out = DO;

endmodule 
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
