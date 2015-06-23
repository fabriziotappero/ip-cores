//
// cpu.v -- the ECO32 CPU
//


module cpu(clk, reset,
           bus_en, bus_wr, bus_size, bus_addr,
           bus_data_in, bus_data_out, bus_wt,
           irq);
    input clk;				// system clock
    input reset;			// system reset
    output bus_en;			// bus enable
    output bus_wr;			// bus write
    output [1:0] bus_size;		// 00: byte, 01: halfword, 10: word
    output [31:0] bus_addr;		// bus address
    input [31:0] bus_data_in;		// bus data input, for reads
    output [31:0] bus_data_out;		// bus data output, for writes
    input bus_wt;			// bus wait
    input [15:0] irq;			// interrupt requests

  // program counter
  wire [31:0] pc;		// program counter
  wire pc_we;			// pc write enable
  wire [2:0] pc_src;		// pc source selector
  wire [31:0] pc_next;		// value written into pc

  // bus & mmu
  wire [31:0] mar;		// memory address register
  wire mar_we;			// mar write enable
  wire ma_src;			// memory address source selector
  wire [2:0] mmu_fnc;		// mmu function
  wire [31:0] virt_addr;	// virtual address
  wire [31:0] phys_addr;	// physical address
  wire [31:0] mdor;		// memory data out register
  wire mdor_we;			// mdor write enable
  wire [31:0] mdir;		// memory data in register
  wire mdir_we;			// mdir write enable
  wire mdir_sx;			// mdir sign-extend

  // instruction register & decoder
  wire ir_we;			// ir write enable
  wire [5:0] opcode;		// opcode part of ir
  wire [4:0] reg1;		// register 1 part of ir
  wire [4:0] reg2;		// register 2 part of ir
  wire [4:0] reg3;		// register 3 part of ir
  wire [31:0] sx16;		// sign-extended 16-bit immediate
  wire [31:0] zx16;		// zero-extended 16-bit immediate
  wire [31:0] hi16;		// high 16-bit immediate
  wire [31:0] sx16s2;		// sign-extended 16-bit immediate << 2
  wire [31:0] sx26s2;		// sign-extended 26-bit immediate << 2

  // register file
  wire [4:0] reg_a1;		// register address 1
  wire [31:0] reg_do1;		// register data out 1
  wire [1:0] reg_src2;		// register source 2 selector
  wire [4:0] reg_a2;		// register address 2
  wire [31:0] reg_do2;		// register data out 2
  wire reg_we2;			// register write enable 2
  wire reg_we2_prot;		// register write enable 2,
				// protected against writes with a2 = 0
  wire [2:0] reg_di2_src;	// register data in 2 source selector
  wire [31:0] reg_di2;		// register data in 2

  // alu, shift, and muldiv units
  wire alu_src1;		// alu source 1 selector
  wire [31:0] alu_op1;		// alu operand 1
  wire [2:0] alu_src2;		// alu source 2 selector
  wire [31:0] alu_op2;		// alu operand 2
  wire [2:0] alu_fnc;		// alu function
  wire [31:0] alu_res;		// alu result
  wire alu_equ;			// alu operand 1 = operand 2
  wire alu_ult;			// alu operand 1 < operand 2 (unsigned)
  wire alu_slt;			// alu operand 1 < operand 2 (signed)
  wire [1:0] shift_fnc;		// shift function
  wire [31:0] shift_res;	// shift result
  wire [2:0] muldiv_fnc;	// muldiv function
  wire muldiv_start;		// muldiv should start
  wire muldiv_done;		// muldiv has finished
  wire muldiv_error;		// muldiv detected division by zero
  wire [31:0] muldiv_res;	// muldiv result

  // special registers
  wire [2:0] sreg_num;		// special register number
  wire sreg_we;			// special register write enable
  wire [31:0] sreg_di;		// special register data in
  wire [31:0] sreg_do;		// special register data out
  wire [31:0] psw;		// special register 0 (psw) contents
  wire psw_we;			// psw write enable
  wire [31:0] psw_new;		// new psw contents
  wire [31:0] tlb_index;	// special register 1 (tlb index) contents
  wire tlb_index_we;		// tlb index write enable
  wire [31:0] tlb_index_new;	// new tlb index contents
  wire [31:0] tlb_entry_hi;	// special register 2 (tlb entry hi) contents
  wire tlb_entry_hi_we;		// tlb entry hi write enable
  wire [31:0] tlb_entry_hi_new;	// new tlb entry hi contents
  wire [31:0] tlb_entry_lo;	// special register 3 (tlb entry lo) contents
  wire tlb_entry_lo_we;		// tlb entry lo write enable
  wire [31:0] tlb_entry_lo_new;	// new tlb entry lo contents
  wire [31:0] mmu_bad_addr;	// special register 4 (mmu bad addr) contents
  wire mmu_bad_addr_we;		// mmu bad addr write enable
  wire [31:0] mmu_bad_addr_new;	// new mmu bad addr contents
  wire [31:0] mmu_bad_accs;	// special register 5 (mmu bad accs) contents
  wire mmu_bad_accs_we;		// mmu bad accs write enable
  wire [31:0] mmu_bad_accs_new;	// new mmu bad accs contents

  // mmu & tlb
  wire tlb_kmissed;		// page not found in tlb, MSB of addr is 1
  wire tlb_umissed;		// page not found in tlb, MSB of addr is 0
  wire tlb_invalid;		// tlb entry is invalid
  wire tlb_wrtprot;		// frame is write-protected

  //------------------------------------------------------------

  // program counter
  assign pc_next = (pc_src == 3'b000) ? alu_res :
                   (pc_src == 3'b001) ? 32'hE0000000 :
                   (pc_src == 3'b010) ? 32'hE0000004 :
                   (pc_src == 3'b011) ? 32'hC0000004 :
                   (pc_src == 3'b100) ? 32'hE0000008 :
                   (pc_src == 3'b101) ? 32'hC0000008 :
                   32'hxxxxxxxx;
  pc pc1(clk, pc_we, pc_next, pc);

  // bus & mmu
  mar mar1(clk, mar_we, alu_res, mar);
  assign virt_addr = (ma_src == 0) ? pc : mar;
  mmu mmu1(clk, reset, mmu_fnc, virt_addr, phys_addr,
           tlb_index, tlb_index_new,
           tlb_entry_hi, tlb_entry_hi_new,
           tlb_entry_lo, tlb_entry_lo_new,
           tlb_kmissed, tlb_umissed,
           tlb_invalid, tlb_wrtprot);
  assign bus_addr = phys_addr;
  mdor mdor1(clk, mdor_we, reg_do2, mdor);
  assign bus_data_out = mdor;
  mdir mdir1(clk, mdir_we, bus_data_in, bus_size, mdir_sx, mdir);

  // instruction register & decoder
  ir ir1(clk,
         ir_we, bus_data_in,
         opcode, reg1, reg2, reg3,
         sx16, zx16, hi16, sx16s2, sx26s2);

  // register file
  assign reg_a1 = reg1;
  assign reg_a2 = (reg_src2 == 2'b00) ? reg2 :
                  (reg_src2 == 2'b01) ? reg3 :
                  (reg_src2 == 2'b10) ? 5'b11111 :
                  (reg_src2 == 2'b11) ? 5'b11110 :
                  5'bxxxxx;
  assign reg_we2_prot = reg_we2 & (| reg_a2[4:0]);
  assign reg_di2 = (reg_di2_src == 3'b000) ? alu_res :
                   (reg_di2_src == 3'b001) ? shift_res :
                   (reg_di2_src == 3'b010) ? muldiv_res :
                   (reg_di2_src == 3'b011) ? mdir :
                   (reg_di2_src == 3'b100) ? sreg_do :
                   32'hxxxxxxxx;
  regs regs1(clk,
             reg_a1, reg_do1,
             reg_a2, reg_do2, reg_we2_prot, reg_di2);

  // alu, shift, and muldiv units
  assign alu_op1 = (alu_src1 == 0) ? pc : reg_do1;
  assign alu_op2 = (alu_src2 == 3'b000) ? 32'h00000004 :
                   (alu_src2 == 3'b001) ? reg_do2 :
                   (alu_src2 == 3'b010) ? sx16 :
                   (alu_src2 == 3'b011) ? zx16 :
                   (alu_src2 == 3'b100) ? hi16 :
                   (alu_src2 == 3'b101) ? sx16s2 :
                   (alu_src2 == 3'b110) ? sx26s2 :
                   32'hxxxxxxxx;
  alu alu1(alu_op1, alu_op2, alu_fnc,
           alu_res, alu_equ, alu_ult, alu_slt);
  shift shift1(clk, alu_op1, alu_op2[4:0], shift_fnc, shift_res);
  muldiv muldiv1(clk, alu_op1, alu_op2, muldiv_fnc, muldiv_start,
                 muldiv_done, muldiv_error, muldiv_res);

  // special registers
  assign sreg_num = zx16[2:0];
  assign sreg_di = reg_do2;
  sregs sregs1(clk, reset,
               sreg_num, sreg_we, sreg_di, sreg_do,
               psw, psw_we, psw_new,
               tlb_index, tlb_index_we, tlb_index_new,
               tlb_entry_hi, tlb_entry_hi_we, tlb_entry_hi_new,
               tlb_entry_lo, tlb_entry_lo_we, tlb_entry_lo_new,
               mmu_bad_addr, mmu_bad_addr_we, mmu_bad_addr_new,
               mmu_bad_accs, mmu_bad_accs_we, mmu_bad_accs_new);
  assign mmu_bad_addr_new = virt_addr;
  assign mmu_bad_accs_we = mmu_bad_addr_we;
  assign mmu_bad_accs_new = { 29'b0, bus_wr, bus_size[1:0] };

  // ctrl
  ctrl ctrl1(clk, reset,
             opcode, alu_equ, alu_ult, alu_slt,
             bus_wt, bus_en, bus_wr, bus_size,
             pc_src, pc_we,
             mar_we, ma_src, mmu_fnc,
             mdor_we, mdir_we, mdir_sx, ir_we,
             reg_src2, reg_di2_src, reg_we2,
             alu_src1, alu_src2, alu_fnc, shift_fnc,
             muldiv_fnc, muldiv_start,
             muldiv_done, muldiv_error,
             sreg_we, irq, psw, psw_we, psw_new,
             virt_addr[31], virt_addr[1], virt_addr[0],
             tlb_kmissed, tlb_umissed,
             tlb_invalid, tlb_wrtprot,
             tlb_index_we, tlb_entry_hi_we,
             tlb_entry_lo_we, mmu_bad_addr_we);

endmodule


//--------------------------------------------------------------
// ctrl -- the finite state machine within the CPU
//--------------------------------------------------------------


module ctrl(clk, reset,
            opcode, alu_equ, alu_ult, alu_slt,
            bus_wt, bus_en, bus_wr, bus_size,
            pc_src, pc_we,
            mar_we, ma_src, mmu_fnc,
            mdor_we, mdir_we, mdir_sx, ir_we,
            reg_src2, reg_di2_src, reg_we2,
            alu_src1, alu_src2, alu_fnc, shift_fnc,
            muldiv_fnc, muldiv_start,
            muldiv_done, muldiv_error,
            sreg_we, irq, psw, psw_we, psw_new,
            va_31, va_1, va_0,
            tlb_kmissed, tlb_umissed,
            tlb_invalid, tlb_wrtprot,
            tlb_index_we, tlb_entry_hi_we,
            tlb_entry_lo_we, mmu_bad_addr_we);
    input clk;
    input reset;
    input [5:0] opcode;
    input alu_equ;
    input alu_ult;
    input alu_slt;
    input bus_wt;
    output reg bus_en;
    output reg bus_wr;
    output reg [1:0] bus_size;
    output reg [2:0] pc_src;
    output reg pc_we;
    output reg mar_we;
    output reg ma_src;
    output reg [2:0] mmu_fnc;
    output reg mdor_we;
    output reg mdir_we;
    output reg mdir_sx;
    output reg ir_we;
    output reg [1:0] reg_src2;
    output reg [2:0] reg_di2_src;
    output reg reg_we2;
    output reg alu_src1;
    output reg [2:0] alu_src2;
    output reg [2:0] alu_fnc;
    output reg [1:0] shift_fnc;
    output reg [2:0] muldiv_fnc;
    output reg muldiv_start;
    input muldiv_done;
    input muldiv_error;
    output reg sreg_we;
    input [15:0] irq;
    input [31:0] psw;
    output reg psw_we;
    output reg [31:0] psw_new;
    input va_31, va_1, va_0;
    input tlb_kmissed;
    input tlb_umissed;
    input tlb_invalid;
    input tlb_wrtprot;
    output reg tlb_index_we;
    output reg tlb_entry_hi_we;
    output reg tlb_entry_lo_we;
    output reg mmu_bad_addr_we;

  wire type_rrr;		// instr type is RRR
  wire type_rrs;		// instr type is RRS
  wire type_rrh;		// instr type is RRH
  wire type_rhh;		// instr type is RHH
  wire type_rrb;		// instr type is RRB
  wire type_j;			// instr type is J
  wire type_jr;			// instr type is JR
  wire type_link;		// instr saves PC+4 in $31
  wire type_ld;			// instr loads data
  wire type_st;			// instr stores data
  wire type_ldst;		// instr loads or stores data
  wire [1:0] ldst_size;		// load/store transfer size
  wire type_shift;		// instr uses the shift unit
  wire type_muldiv;		// instr uses the muldiv unit
  wire type_fast;		// instr is not shift or muldiv
  wire type_mvfs;		// instr is mvfs
  wire type_mvts;		// instr is mvts
  wire type_rfx;		// instr is rfx
  wire type_trap;		// instr is trap
  wire type_tb;			// instr is a TLB instr
  reg [4:0] state;		// cpu internal state
				//  0: reset
				//  1: fetch instr (addr xlat)
				//  2: decode instr
				//     increment pc by 4
				//     possibly store pc+4 in $31
				//  3: execute RRR-type instr
				//  4: execute RRS-type instr
				//  5: execute RRH-type instr
				//  6: execute RHH-type instr
				//  7: execute RRB-type instr (1)
				//  8: execute RRB-type instr (2)
				//  9: execute J-type instr
				// 10: execute JR-type instr
				// 11: execute LDST-type instr (1)
				// 12: execute LD-type instr (addr xlat)
				// 13: execute LD-type instr (3)
				// 14: execute ST-type instr (addr xlat)
				// 15: interrupt
				// 16: extra state for RRR shift instr
				// 17: extra state for RRH shift instr
				// 18: extra state for RRR muldiv instr
				// 19: extra state for RRS muldiv instr
				// 20: extra state for RRH muldiv instr
				// 21: execute mvfs instr
				// 22: execute mvts instr
				// 23: execute rfx instr
				// 24: irq_trigger check for mvts and rfx
				// 25: exception (locus is PC-4)
				// 26: exception (locus is PC)
				// 27: execute TLB instr
				// 28: fetch instr (bus cycle)
				// 29: execute LD-type instr (bus cycle)
				// 30: execute ST-type instr (bus cycle)
				// all other: unused
  reg branch;			// take the branch iff true
  wire [15:0] irq_pending;	// the vector of pending unmasked irqs
  wire irq_trigger;		// true iff any pending irq is present
				// and interrupts are globally enabled
  reg [3:0] irq_priority;	// highest priority of pending interrupts
  reg [3:0] exc_priority;	// exception, when entering state 25 or 26
  reg [7:0] bus_count;		// counter to detect bus timeout
  wire bus_timeout;		// bus timeout detected
  wire exc_prv_addr;		// privileged address exception detected
  wire exc_ill_addr;		// illegal address exception detected
  wire exc_tlb_but_wrtprot;	// any tlb exception but write protection
  wire exc_tlb_any;		// any tlb exception

  //------------------------------------------------------------

  // decode instr type
  assign type_rrr    = ((opcode == 6'h00) ||
                        (opcode == 6'h02) ||
                        (opcode == 6'h04) ||
                        (opcode == 6'h06) ||
                        (opcode == 6'h08) ||
                        (opcode == 6'h0A) ||
                        (opcode == 6'h0C) ||
                        (opcode == 6'h0E) ||
                        (opcode == 6'h10) ||
                        (opcode == 6'h12) ||
                        (opcode == 6'h14) ||
                        (opcode == 6'h16) ||
                        (opcode == 6'h18) ||
                        (opcode == 6'h1A) ||
                        (opcode == 6'h1C)) ? 1 : 0;
  assign type_rrs    = ((opcode == 6'h01) ||
                        (opcode == 6'h03) ||
                        (opcode == 6'h05) ||
                        (opcode == 6'h09) ||
                        (opcode == 6'h0D)) ? 1 : 0;
  assign type_rrh    = ((opcode == 6'h07) ||
                        (opcode == 6'h0B) ||
                        (opcode == 6'h0F) ||
                        (opcode == 6'h11) ||
                        (opcode == 6'h13) ||
                        (opcode == 6'h15) ||
                        (opcode == 6'h17) ||
                        (opcode == 6'h19) ||
                        (opcode == 6'h1B) ||
                        (opcode == 6'h1D)) ? 1 : 0;
  assign type_rhh    = (opcode == 6'h1F) ? 1 : 0;
  assign type_rrb    = ((opcode == 6'h20) ||
                        (opcode == 6'h21) ||
                        (opcode == 6'h22) ||
                        (opcode == 6'h23) ||
                        (opcode == 6'h24) ||
                        (opcode == 6'h25) ||
                        (opcode == 6'h26) ||
                        (opcode == 6'h27) ||
                        (opcode == 6'h28) ||
                        (opcode == 6'h29)) ? 1 : 0;
  assign type_j      = ((opcode == 6'h2A) ||
                        (opcode == 6'h2C)) ? 1 : 0;
  assign type_jr     = ((opcode == 6'h2B) ||
                        (opcode == 6'h2D)) ? 1 : 0;
  assign type_link   = ((opcode == 6'h2C) ||
                        (opcode == 6'h2D)) ? 1 : 0;
  assign type_ld     = ((opcode == 6'h30) ||
                        (opcode == 6'h31) ||
                        (opcode == 6'h32) ||
                        (opcode == 6'h33) ||
                        (opcode == 6'h34)) ? 1 : 0;
  assign type_st     = ((opcode == 6'h35) ||
                        (opcode == 6'h36) ||
                        (opcode == 6'h37)) ? 1 : 0;
  assign type_ldst   = type_ld | type_st;
  assign ldst_size   = ((opcode == 6'h30) ||
                        (opcode == 6'h35)) ? 2'b10 :
                       ((opcode == 6'h31) ||
                        (opcode == 6'h32) ||
                        (opcode == 6'h36)) ? 2'b01 :
                       ((opcode == 6'h33) ||
                        (opcode == 6'h34) ||
                        (opcode == 6'h37)) ? 2'b00 :
                       2'bxx;
  assign type_shift  = ((opcode == 6'h18) ||
                        (opcode == 6'h19) ||
                        (opcode == 6'h1A) ||
                        (opcode == 6'h1B) ||
                        (opcode == 6'h1C) ||
                        (opcode == 6'h1D)) ? 1 : 0;
  assign type_muldiv = ((opcode == 6'h04) ||
                        (opcode == 6'h05) ||
                        (opcode == 6'h06) ||
                        (opcode == 6'h07) ||
                        (opcode == 6'h08) ||
                        (opcode == 6'h09) ||
                        (opcode == 6'h0A) ||
                        (opcode == 6'h0B) ||
                        (opcode == 6'h0C) ||
                        (opcode == 6'h0D) ||
                        (opcode == 6'h0E) ||
                        (opcode == 6'h0F)) ? 1 : 0;
  assign type_fast   = ~(type_shift | type_muldiv);
  assign type_mvfs   = (opcode == 6'h38) ? 1 : 0;
  assign type_mvts   = (opcode == 6'h39) ? 1 : 0;
  assign type_rfx    = (opcode == 6'h2F) ? 1 : 0;
  assign type_trap   = (opcode == 6'h2E) ? 1 : 0;
  assign type_tb     = ((opcode == 6'h3A) ||
                        (opcode == 6'h3B) ||
                        (opcode == 6'h3C) ||
                        (opcode == 6'h3D)) ? 1 : 0;

  // state machine
  always @(posedge clk) begin
    if (reset == 1) begin
      state <= 0;
    end else begin
      case (state)
        5'd0:  // reset
          begin
            state <= 5'd1;
          end
        5'd1:  // fetch instr (addr xlat)
          begin
            if (exc_prv_addr) begin
              state <= 26;
              exc_priority <= 4'd9;
            end else
            if (exc_ill_addr) begin
              state <= 26;
              exc_priority <= 4'd8;
            end else begin
              state <= 5'd28;
            end
          end
        5'd2:  // decode instr
               // increment pc by 4
               // possibly store pc+4 in $31
          begin
            if (type_rrr) begin
              // RRR-type instruction
              state <= 5'd3;
            end else
            if (type_rrs) begin
              // RRS-type instruction
              state <= 5'd4;
            end else
            if (type_rrh) begin
              // RRH-type instruction
              state <= 5'd5;
            end else
            if (type_rhh) begin
              // RHH-type instruction
              state <= 5'd6;
            end else
            if (type_rrb) begin
              // RRB-type instr
              state <= 5'd7;
            end else
            if (type_j) begin
              // J-type instr
              state <= 5'd9;
            end else
            if (type_jr) begin
              // JR-type instr
              state <= 5'd10;
            end else
            if (type_ldst) begin
              // LDST-type instr
              state <= 5'd11;
            end else
            if (type_mvfs) begin
              // mvfs instr
              state <= 5'd21;
            end else
            if (type_mvts) begin
              // mvts instr
              if (psw[26] == 1) begin
                state <= 5'd25;
                exc_priority <= 4'd2;
              end else begin
                state <= 5'd22;
              end
            end else
            if (type_rfx) begin
              // rfx instr
              if (psw[26] == 1) begin
                state <= 5'd25;
                exc_priority <= 4'd2;
              end else begin
                state <= 5'd23;
              end
            end else
            if (type_trap) begin
              // trap instr
              state <= 5'd25;
              exc_priority <= 4'd4;
            end else
            if (type_tb) begin
              // TLB instr
              if (psw[26] == 1) begin
                state <= 5'd25;
                exc_priority <= 4'd2;
              end else begin
                state <= 5'd27;
              end
            end else begin
              // illegal instruction
              state <= 5'd25;
              exc_priority <= 4'd1;
            end
          end
        5'd3:  // execute RRR-type instr
          begin
            if (type_muldiv) begin
              state <= 5'd18;
            end else
            if (type_shift) begin
              state <= 5'd16;
            end else begin
              if (irq_trigger) begin
                state <= 5'd15;
              end else begin
                state <= 5'd1;
              end
            end
          end
        5'd4:  // execute RRS-type instr
          begin
            if (type_muldiv) begin
              state <= 5'd19;
            end else begin
              if (irq_trigger) begin
                state <= 5'd15;
              end else begin
                state <= 5'd1;
              end
            end
          end
        5'd5:  // execute RRH-type instr
          begin
            if (type_muldiv) begin
              state <= 5'd20;
            end else
            if (type_shift) begin
              state <= 5'd17;
            end else begin
              if (irq_trigger) begin
                state <= 5'd15;
              end else begin
                state <= 5'd1;
              end
            end
          end
        5'd6:  // execute RHH-type instr
          begin
            if (irq_trigger) begin
              state <= 5'd15;
            end else begin
              state <= 5'd1;
            end
          end
        5'd7:  // execute RRB-type instr (1)
          begin
            if (branch) begin
              state <= 5'd8;
            end else begin
              if (irq_trigger) begin
                state <= 5'd15;
              end else begin
                state <= 5'd1;
              end
            end
          end
        5'd8:  // execute RRB-type instr (2)
          begin
            if (irq_trigger) begin
              state <= 5'd15;
            end else begin
              state <= 5'd1;
            end
          end
        5'd9:  // execute J-type instr
          begin
            if (irq_trigger) begin
              state <= 5'd15;
            end else begin
              state <= 5'd1;
            end
          end
        5'd10:  // execute JR-type instr
          begin
            if (irq_trigger) begin
              state <= 5'd15;
            end else begin
              state <= 5'd1;
            end
          end
        5'd11:  // execute LDST-type instr (1)
          begin
            if (type_ld) begin
              state <= 5'd12;
            end else begin
              state <= 5'd14;
            end
          end
        5'd12:  // execute LD-type instr (addr xlat)
          begin
            if (exc_prv_addr) begin
              state <= 25;
              exc_priority <= 4'd9;
            end else
            if (exc_ill_addr) begin
              state <= 25;
              exc_priority <= 4'd8;
            end else begin
              state <= 5'd29;
            end
          end
        5'd13:  // execute LD-type instr (3)
          begin
            if (irq_trigger) begin
              state <= 5'd15;
            end else begin
              state <= 5'd1;
            end
          end
        5'd14:  // execute ST-type instr (addr xlat)
          begin
            if (exc_prv_addr) begin
              state <= 25;
              exc_priority <= 4'd9;
            end else
            if (exc_ill_addr) begin
              state <= 25;
              exc_priority <= 4'd8;
            end else begin
              state <= 5'd30;
            end
          end
        5'd15:  // interrupt
          begin
            state <= 5'd1;
          end
        5'd16:  // extra state for RRR shift instr
          begin
            if (irq_trigger) begin
              state <= 5'd15;
            end else begin
              state <= 5'd1;
            end
          end
        5'd17:  // extra state for RRH shift instr
          begin
            if (irq_trigger) begin
              state <= 5'd15;
            end else begin
              state <= 5'd1;
            end
          end
        5'd18:  // extra state for RRR muldiv instr
          begin
            if (muldiv_done) begin
              if (muldiv_error) begin
                state <= 5'd25;
                exc_priority <= 4'd3;
              end else
              if (irq_trigger) begin
                state <= 5'd15;
              end else begin
                state <= 5'd1;
              end
            end else begin
              state <= 5'd18;
            end
          end
        5'd19:  // extra state for RRS muldiv instr
          begin
            if (muldiv_done) begin
              if (muldiv_error) begin
                state <= 5'd25;
                exc_priority <= 4'd3;
              end else
              if (irq_trigger) begin
                state <= 5'd15;
              end else begin
                state <= 5'd1;
              end
            end else begin
              state <= 5'd19;
            end
          end
        5'd20:  // extra state for RRH muldiv instr
          begin
            if (muldiv_done) begin
              if (muldiv_error) begin
                state <= 5'd25;
                exc_priority <= 4'd3;
              end else
              if (irq_trigger) begin
                state <= 5'd15;
              end else begin
                state <= 5'd1;
              end
            end else begin
              state <= 5'd20;
            end
          end
        5'd21:  // execute mvfs instr
          begin
            if (irq_trigger) begin
              state <= 5'd15;
            end else begin
              state <= 5'd1;
            end
          end
        5'd22:  // execute mvts instr
          begin
            state <= 5'd24;
          end
        5'd23:  // execute rfx instr
          begin
            state <= 5'd24;
          end
        5'd24:  // irq_trigger check for mvts and rfx
          begin
            if (irq_trigger) begin
              state <= 5'd15;
            end else begin
              state <= 5'd1;
            end
          end
        5'd25:  // exception (locus is PC-4)
          begin
            state <= 5'd1;
          end
        5'd26:  // exception (locus is PC)
          begin
            state <= 5'd1;
          end
        5'd27:  // execute TLB instr
          begin
            if (irq_trigger) begin
              state <= 5'd15;
            end else begin
              state <= 5'd1;
            end
          end
        5'd28:  // fetch instr (bus cycle)
          begin
            if (tlb_kmissed == 1 || tlb_umissed == 1) begin
              state <= 5'd26;
              exc_priority <= 4'd5;
            end else
            if (tlb_invalid == 1) begin
              state <= 5'd26;
              exc_priority <= 4'd7;
            end else
            if (bus_wt == 1) begin
              if (bus_timeout == 1) begin
                state <= 5'd26;
                exc_priority <= 4'd0;
              end else begin
                state <= 5'd28;
              end
            end else begin
              state <= 5'd2;
            end
          end
        5'd29:  // execute LD-type instr (bus cycle)
          begin
            if (tlb_kmissed == 1 || tlb_umissed == 1) begin
              state <= 5'd25;
              exc_priority <= 4'd5;
            end else
            if (tlb_invalid == 1) begin
              state <= 5'd25;
              exc_priority <= 4'd7;
            end else
            if (bus_wt == 1) begin
              if (bus_timeout == 1) begin
                state <= 5'd25;
                exc_priority <= 4'd0;
              end else begin
                state <= 5'd29;
              end
            end else begin
              state <= 5'd13;
            end
          end
        5'd30:  // execute ST-type instr (bus cycle)
          begin
            if (tlb_kmissed == 1 || tlb_umissed == 1) begin
              state <= 5'd25;
              exc_priority <= 4'd5;
            end else
            if (tlb_invalid == 1) begin
              state <= 5'd25;
              exc_priority <= 4'd7;
            end else
            if (tlb_wrtprot == 1) begin
              state <= 5'd25;
              exc_priority <= 4'd6;
            end else
            if (bus_wt == 1) begin
              if (bus_timeout == 1) begin
                state <= 5'd25;
                exc_priority <= 4'd0;
              end else begin
                state <= 5'd30;
              end
            end else begin
              if (irq_trigger) begin
                state <= 5'd15;
              end else begin
                state <= 5'd1;
              end
            end
          end
        default:  // all other states: unused
          begin
            state <= 5'd0;
          end
      endcase
    end
  end

  // bus timeout detector
  assign bus_timeout = (bus_count == 8'h00) ? 1 : 0;
  always @(posedge clk) begin
    if (bus_en == 1 && bus_wt == 1) begin
      // bus is waiting
      bus_count <= bus_count - 1;
    end else begin
      // bus is not waiting
      bus_count <= 8'hFF;
    end
  end

  // output logic
  always @(*) begin
    case (state)
      5'd0:  // reset
        begin
          pc_src = 3'b001;
          pc_we = 1'b1;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd1:  // fetch instr (addr xlat)
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'b0;
          mmu_fnc = (exc_prv_addr | exc_ill_addr) ? 3'b000 : 3'b001;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'b0;         // get bad_accs right in case of exc
          bus_size = 2'b10;      // enable illegal address detection
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = exc_prv_addr | exc_ill_addr;
        end
      5'd2:  // decode instr
             // increment pc by 4
             // possibly store pc+4 in $31
        begin
          pc_src = 3'b000;
          pc_we = 1'b1;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = (type_link == 1) ? 2'b10 :
                     (type_rfx == 1) ? 2'b11 :
                     2'b00;
          reg_di2_src = (type_link == 1) ? 3'b000 : 3'bxxx;
          reg_we2 = (type_link == 1) ? 1'b1 : 1'b0;
          alu_src1 = 1'b0;
          alu_src2 = 3'b000;
          alu_fnc = 3'b000;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd3:  // execute RRR-type instr
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b01;
          reg_di2_src = 3'b000;
          reg_we2 = type_fast;
          alu_src1 = 1'b1;
          alu_src2 = 3'b001;
          alu_fnc = { opcode[4], opcode[2], opcode[1] };
          shift_fnc = { opcode[2], opcode[1] };
          muldiv_fnc = { opcode[3], opcode[2], opcode[1] };
          muldiv_start = type_muldiv;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd4:  // execute RRS-type instr
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b00;
          reg_di2_src = 3'b000;
          reg_we2 = type_fast;
          alu_src1 = 1'b1;
          alu_src2 = 3'b010;
          alu_fnc = { opcode[4], opcode[2], opcode[1] };
          shift_fnc = 2'bxx;
          muldiv_fnc = { opcode[3], opcode[2], opcode[1] };
          muldiv_start = type_muldiv;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd5:  // execute RRH-type instr
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b00;
          reg_di2_src = 3'b000;
          reg_we2 = type_fast;
          alu_src1 = 1'b1;
          alu_src2 = 3'b011;
          alu_fnc = { opcode[4], opcode[2], opcode[1] };
          shift_fnc = { opcode[2], opcode[1] };
          muldiv_fnc = { opcode[3], opcode[2], opcode[1] };
          muldiv_start = type_muldiv;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd6:  // execute RHH-type instr
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b00;
          reg_di2_src = 3'b000;
          reg_we2 = 1'b1;
          alu_src1 = 1'bx;
          alu_src2 = 3'b100;
          alu_fnc = 3'b011;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd7:  // execute RRB-type instr (1)
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'b1;
          alu_src2 = 3'b001;
          alu_fnc = 3'b001;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd8:  // execute RRB-type instr (2)
        begin
          pc_src = 3'b000;
          pc_we = 1'b1;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'b0;
          alu_src2 = 3'b101;
          alu_fnc = 3'b000;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd9:  // execute J-type instr
        begin
          pc_src = 3'b000;
          pc_we = 1'b1;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'b0;
          alu_src2 = 3'b110;
          alu_fnc = 3'b000;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd10:  // execute JR-type instr
        begin
          pc_src = 3'b000;
          pc_we = 1'b1;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'b1;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'b010;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd11:  // execute LDST-type instr (1)
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b1;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b1;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'b1;
          alu_src2 = 3'b010;
          alu_fnc = 3'b000;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd12:  // execute LD-type instr (addr xlat)
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'b1;
          mmu_fnc = (exc_prv_addr | exc_ill_addr) ? 3'b000 : 3'b001;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'b0;         // get bad_accs right in case of exc
          bus_size = ldst_size;  // enable illegal address detection
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = exc_prv_addr | exc_ill_addr;
        end
      5'd13:  // execute LD-type instr (3)
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = ldst_size;
          mdir_we = 1'b0;
          mdir_sx = opcode[0];
          ir_we = 1'b0;
          reg_src2 = 2'b00;
          reg_di2_src = 3'b011;
          reg_we2 = 1'b1;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd14:  // execute ST-type instr (addr xlat)
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'b1;
          mmu_fnc = (exc_prv_addr | exc_ill_addr) ? 3'b000 : 3'b001;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'b1;         // get bad_accs right in case of exc
          bus_size = ldst_size;  // enable illegal address detection
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = exc_prv_addr | exc_ill_addr;
        end
      5'd15:  // interrupt
        begin
          pc_src = (psw[27] == 0) ? 3'b010 : 3'b011;
          pc_we = 1'b1;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b11;
          reg_di2_src = 3'b000;
          reg_we2 = 1'b1;
          alu_src1 = 1'b0;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'b010;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b1;
          psw_new = {
            psw[31:28],
            psw[27],
            1'b0, psw[26], psw[25],
            1'b0, psw[23], psw[22],
            1'b0, irq_priority,
            psw[15:0]
          };
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd16:  // extra state for RRR shift instr
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b01;
          reg_di2_src = 3'b001;
          reg_we2 = 1'b1;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd17:  // extra state for RRH shift instr
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b00;
          reg_di2_src = 3'b001;
          reg_we2 = 1'b1;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd18:  // extra state for RRR muldiv instr
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b01;
          reg_di2_src = 3'b010;
          reg_we2 = muldiv_done & ~muldiv_error;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd19:  // extra state for RRS muldiv instr
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b00;
          reg_di2_src = 3'b010;
          reg_we2 = muldiv_done & ~muldiv_error;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd20:  // extra state for RRH muldiv instr
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b00;
          reg_di2_src = 3'b010;
          reg_we2 = muldiv_done & ~muldiv_error;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd21:  // execute mvfs instr
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b00;
          reg_di2_src = 3'b100;
          reg_we2 = 1'b1;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd22:  // execute mvts instr
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b1;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd23:  // execute rfx instr
        begin
          pc_src = 3'b000;
          pc_we = 1'b1;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'bx;
          alu_src2 = 3'b001;
          alu_fnc = 3'b011;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b1;
          psw_new = {
            psw[31:28],
            psw[27],
            psw[25], psw[24], psw[24],
            psw[22], psw[21], psw[21],
            psw[20:16],
            psw[15:0]
          };
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd24:  // irq_trigger check for mvts and rfx
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd25:  // exception (locus is PC-4)
        begin
          pc_src = (psw[27] != 0) ?
                     ((tlb_umissed != 0) ? 3'b101 : 3'b011) :
                     ((tlb_umissed != 0) ? 3'b100 : 3'b010);
          pc_we = 1'b1;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b11;
          reg_di2_src = 3'b000;
          reg_we2 = 1'b1;
          alu_src1 = 1'b0;
          alu_src2 = 3'b000;
          alu_fnc = 3'b001;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b1;
          psw_new = {
            psw[31:28],
            psw[27],
            1'b0, psw[26], psw[25],
            1'b0, psw[23], psw[22],
            1'b1, exc_priority,
            psw[15:0]
          };
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd26:  // exception (locus is PC)
        begin
          pc_src = (psw[27] != 0) ?
                     ((tlb_umissed != 0) ? 3'b101 : 3'b011) :
                     ((tlb_umissed != 0) ? 3'b100 : 3'b010);
          pc_we = 1'b1;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'b11;
          reg_di2_src = 3'b000;
          reg_we2 = 1'b1;
          alu_src1 = 1'b0;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'b010;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b1;
          psw_new = {
            psw[31:28],
            psw[27],
            1'b0, psw[26], psw[25],
            1'b0, psw[23], psw[22],
            1'b1, exc_priority,
            psw[15:0]
          };
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = 1'b0;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd27:  // execute TLB instr
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'bx;
          mmu_fnc = opcode[2:0];
          mdor_we = 1'b0;
          bus_en = 1'b0;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = (opcode[2:0] == 3'b010) ? 1 : 0;
          tlb_entry_hi_we = (opcode[2:0] == 3'b100) ? 1 : 0;
          tlb_entry_lo_we = (opcode[2:0] == 3'b100) ? 1 : 0;
          mmu_bad_addr_we = 1'b0;
        end
      5'd28:  // fetch instr (bus cycle)
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'b0;	// hold vaddr for latching in bad addr reg
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = ~exc_tlb_but_wrtprot;
          bus_wr = 1'b0;
          bus_size = 2'b10;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b1;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = exc_tlb_but_wrtprot;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = exc_tlb_but_wrtprot;
        end
      5'd29:  // execute LD-type instr (bus cycle)
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'b1;	// hold vaddr for latching in bad addr reg
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = ~exc_tlb_but_wrtprot;
          bus_wr = 1'b0;
          bus_size = ldst_size;
          mdir_we = 1'b1;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = exc_tlb_but_wrtprot;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = exc_tlb_but_wrtprot;
        end
      5'd30:  // execute ST-type instr (bus cycle)
        begin
          pc_src = 3'bxxx;
          pc_we = 1'b0;
          mar_we = 1'b0;
          ma_src = 1'b1;	// hold vaddr for latching in bad addr reg
          mmu_fnc = 3'b000;
          mdor_we = 1'b0;
          bus_en = ~exc_tlb_any;
          bus_wr = 1'b1;
          bus_size = ldst_size;
          mdir_we = 1'b0;
          mdir_sx = 1'bx;
          ir_we = 1'b0;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'b0;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'b0;
          sreg_we = 1'b0;
          psw_we = 1'b0;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'b0;
          tlb_entry_hi_we = exc_tlb_any;
          tlb_entry_lo_we = 1'b0;
          mmu_bad_addr_we = exc_tlb_any;
        end
      default:  // all other states: unused
        begin
          pc_src = 3'bxxx;
          pc_we = 1'bx;
          mar_we = 1'bx;
          ma_src = 1'bx;
          mmu_fnc = 3'bxxx;
          mdor_we = 1'bx;
          bus_en = 1'bx;
          bus_wr = 1'bx;
          bus_size = 2'bxx;
          mdir_we = 1'bx;
          mdir_sx = 1'bx;
          ir_we = 1'bx;
          reg_src2 = 2'bxx;
          reg_di2_src = 3'bxxx;
          reg_we2 = 1'bx;
          alu_src1 = 1'bx;
          alu_src2 = 3'bxxx;
          alu_fnc = 3'bxxx;
          shift_fnc = 2'bxx;
          muldiv_fnc = 3'bxxx;
          muldiv_start = 1'bx;
          sreg_we = 1'bx;
          psw_we = 1'bx;
          psw_new = 32'hxxxxxxxx;
          tlb_index_we = 1'bx;
          tlb_entry_hi_we = 1'bx;
          tlb_entry_lo_we = 1'bx;
          mmu_bad_addr_we = 1'bx;
        end
    endcase
  end

  // branch logic
  always @(*) begin
    casex ( { opcode[3:0], alu_equ, alu_ult, alu_slt } )
      // eq
      7'b00000xx:  branch = 0;
      7'b00001xx:  branch = 1;
      // ne
      7'b00010xx:  branch = 1;
      7'b00011xx:  branch = 0;
      // le
      7'b00100x0:  branch = 0;
      7'b00101xx:  branch = 1;
      7'b0010xx1:  branch = 1;
      // leu
      7'b001100x:  branch = 0;
      7'b00111xx:  branch = 1;
      7'b0011x1x:  branch = 1;
      // lt
      7'b0100xx0:  branch = 0;
      7'b0100xx1:  branch = 1;
      // ltu
      7'b0101x0x:  branch = 0;
      7'b0101x1x:  branch = 1;
      // ge
      7'b0110xx0:  branch = 1;
      7'b0110xx1:  branch = 0;
      // geu
      7'b0111x0x:  branch = 1;
      7'b0111x1x:  branch = 0;
      // gt
      7'b10000x0:  branch = 1;
      7'b10001xx:  branch = 0;
      7'b1000xx1:  branch = 0;
      // gtu
      7'b100100x:  branch = 1;
      7'b10011xx:  branch = 0;
      7'b1001x1x:  branch = 0;
      // other
      default:     branch = 1'bx;
    endcase
  end

  // interrupts
  assign irq_pending = irq[15:0] & psw[15:0];
  assign irq_trigger = (| irq_pending) & psw[23];
  always @(*) begin
    if ((| irq_pending[15:8]) != 0) begin
      if ((| irq_pending[15:12]) != 0) begin
        if ((| irq_pending[15:14]) != 0) begin
          if (irq_pending[15] != 0) begin
            irq_priority = 4'd15;
          end else begin
            irq_priority = 4'd14;
          end
        end else begin
          if (irq_pending[13] != 0) begin
            irq_priority = 4'd13;
          end else begin
            irq_priority = 4'd12;
          end
        end
      end else begin
        if ((| irq_pending[11:10]) != 0) begin
          if (irq_pending[11] != 0) begin
            irq_priority = 4'd11;
          end else begin
            irq_priority = 4'd10;
          end
        end else begin
          if (irq_pending[9] != 0) begin
            irq_priority = 4'd9;
          end else begin
            irq_priority = 4'd8;
          end
        end
      end
    end else begin
      if ((| irq_pending[7:4]) != 0) begin
        if ((| irq_pending[7:6]) != 0) begin
          if (irq_pending[7] != 0) begin
            irq_priority = 4'd7;
          end else begin
            irq_priority = 4'd6;
          end
        end else begin
          if (irq_pending[5] != 0) begin
            irq_priority = 4'd5;
          end else begin
            irq_priority = 4'd4;
          end
        end
      end else begin
        if ((| irq_pending[3:2]) != 0) begin
          if (irq_pending[3] != 0) begin
            irq_priority = 4'd3;
          end else begin
            irq_priority = 4'd2;
          end
        end else begin
          if (irq_pending[1] != 0) begin
            irq_priority = 4'd1;
          end else begin
            irq_priority = 4'd0;
          end
        end
      end
    end
  end

  // exceptions
  assign exc_prv_addr = psw[26] & va_31;
  assign exc_ill_addr = (bus_size[0] & va_0) |
                        (bus_size[1] & va_0) |
                        (bus_size[1] & va_1);
  assign exc_tlb_but_wrtprot = tlb_kmissed | tlb_umissed | tlb_invalid;
  assign exc_tlb_any = exc_tlb_but_wrtprot | tlb_wrtprot;

endmodule


//--------------------------------------------------------------
// pc -- the program counter
//--------------------------------------------------------------


module pc(clk, pc_we, pc_next, pc);
    input clk;
    input pc_we;
    input [31:0] pc_next;
    output reg [31:0] pc;

  always @(posedge clk) begin
    if (pc_we == 1) begin
      pc <= pc_next;
    end
  end

endmodule


//--------------------------------------------------------------
// mar -- the memory address register
//--------------------------------------------------------------


module mar(clk, mar_we, mar_next, mar);
    input clk;
    input mar_we;
    input [31:0] mar_next;
    output reg [31:0] mar;

  always @(posedge clk) begin
    if (mar_we == 1) begin
      mar <= mar_next;
    end
  end

endmodule


//--------------------------------------------------------------
// mdor -- the memory data out register
//--------------------------------------------------------------


module mdor(clk, mdor_we, mdor_next, mdor);
    input clk;
    input mdor_we;
    input [31:0] mdor_next;
    output reg [31:0] mdor;

  always @(posedge clk) begin
    if (mdor_we == 1) begin
      mdor <= mdor_next;
    end
  end

endmodule


//--------------------------------------------------------------
// mdir -- the memory data in register
//--------------------------------------------------------------


module mdir(clk, mdir_we, mdir_next, size, sx, mdir);
    input clk;
    input mdir_we;
    input [31:0] mdir_next;
    input [1:0] size;
    input sx;
    output reg [31:0] mdir;

  reg [31:0] data;

  always @(posedge clk) begin
    if (mdir_we == 1) begin
      data <= mdir_next;
    end
  end

  always @(*) begin
    case ({ size, sx })
      3'b000:
        begin
          mdir[31:0] = { 24'h000000, data[7:0] };
        end
      3'b001:
        begin
          if (data[7] == 1) begin
            mdir[31:0] = { 24'hFFFFFF, data[7:0] };
          end else begin
            mdir[31:0] = { 24'h000000, data[7:0] };
          end
        end
      3'b010:
        begin
          mdir[31:0] = { 16'h0000, data[15:0] };
        end
      3'b011:
        begin
          if (data[15] == 1) begin
            mdir[31:0] = { 16'hFFFF, data[15:0] };
          end else begin
            mdir[31:0] = { 16'h0000, data[15:0] };
          end
        end
      default:
        begin
          mdir[31:0] = data[31:0];
        end
    endcase
  end

endmodule


//--------------------------------------------------------------
// ir -- the instruction register and decoder
//--------------------------------------------------------------


module ir(clk,
          ir_we, instr,
          opcode, reg1, reg2, reg3,
          sx16, zx16, hi16, sx16s2, sx26s2);
    input clk;
    input ir_we;
    input [31:0] instr;
    output [5:0] opcode;
    output [4:0] reg1;
    output [4:0] reg2;
    output [4:0] reg3;
    output [31:0] sx16;
    output [31:0] zx16;
    output [31:0] hi16;
    output [31:0] sx16s2;
    output [31:0] sx26s2;

  reg [31:0] ir;
  wire [15:0] copy_sign_16;	// 16-bit copy of a 16-bit immediate's sign
  wire [3:0] copy_sign_26;	// 4-bit copy of a 26-bit immediate's sign

  always @(posedge clk) begin
    if (ir_we) begin
      ir <= instr;
    end
  end

  assign opcode[5:0] = ir[31:26];
  assign reg1[4:0] = ir[25:21];
  assign reg2[4:0] = ir[20:16];
  assign reg3[4:0] = ir[15:11];
  assign copy_sign_16[15:0] = (ir[15] == 1) ? 16'hFFFF : 16'h0000;
  assign copy_sign_26[3:0] = (ir[25] == 1) ? 4'hF : 4'h0;
  assign sx16[31:0] = { copy_sign_16[15:0], ir[15:0] };
  assign zx16[31:0] = { 16'h0000, ir[15:0] };
  assign hi16[31:0] = { ir[15:0], 16'h0000 };
  assign sx16s2[31:0] = { copy_sign_16[13:0], ir[15:0], 2'b00 };
  assign sx26s2[31:0] = { copy_sign_26[3:0], ir[25:0], 2'b00 };

endmodule


//--------------------------------------------------------------
// regs -- the register file
//--------------------------------------------------------------


module regs(clk,
            rn1, do1,
            rn2, do2, we2, di2);
    input clk;
    input [4:0] rn1;
    output reg [31:0] do1;
    input [4:0] rn2;
    output reg [31:0] do2;
    input we2;
    input [31:0] di2;

  reg [31:0] r[0:31];

  always @(posedge clk) begin
    do1 <= r[rn1];
    if (we2 == 0) begin
      do2 <= r[rn2];
    end else begin
      do2 <= di2;
      r[rn2] <= di2;
    end
  end

endmodule


//--------------------------------------------------------------
// alu -- the arithmetic/logic unit
//--------------------------------------------------------------


module alu(a, b, fnc,
           res, equ, ult, slt);
    input [31:0] a;
    input [31:0] b;
    input [2:0] fnc;
    output [31:0] res;
    output equ;
    output ult;
    output slt;

  wire [32:0] a1;
  wire [32:0] b1;
  reg [32:0] res1;

  assign a1 = { 1'b0, a };
  assign b1 = { 1'b0, b };

  always @(*) begin
    case (fnc)
      3'b000:  res1 = a1 + b1;
      3'b001:  res1 = a1 - b1;
      3'b010:  res1 = a1;
      3'b011:  res1 = b1;
      3'b100:  res1 = a1 & b1;
      3'b101:  res1 = a1 | b1;
      3'b110:  res1 = a1 ^ b1;
      3'b111:  res1 = a1 ~^ b1;
      default: res1 = 33'hxxxxxxxx;
    endcase
  end

  assign res = res1[31:0];
  assign equ = ~| res1[31:0];
  assign ult = res1[32];
  assign slt = res1[32] ^ a[31] ^ b[31];

endmodule


//--------------------------------------------------------------
// shift -- the shift unit
//--------------------------------------------------------------


module shift(clk, data_in, shamt, fnc, data_out);
    input clk;
    input [31:0] data_in;
    input [4:0] shamt;
    input [1:0] fnc;
    output reg [31:0] data_out;

  always @(posedge clk) begin
    if (fnc == 2'b00) begin
      // sll
      data_out <= data_in << shamt;
    end else
    if (fnc == 2'b01) begin
      // slr
      data_out <= data_in >> shamt;
    end else
    if (fnc == 2'b10) begin
      // sar
      if (data_in[31] == 1) begin
        data_out <= ~(32'hFFFFFFFF >> shamt) |
                    (data_in >> shamt);
      end else begin
        data_out <= data_in >> shamt;
      end
    end else begin
      data_out <= 32'hxxxxxxxx;
    end
  end

endmodule


//--------------------------------------------------------------
// muldiv -- the multiplier/divide unit
//--------------------------------------------------------------


module muldiv(clk, a, b, fnc, start, done, error, res);
    input clk;
    input [31:0] a;
    input [31:0] b;
    input [2:0] fnc;
    input start;
    output reg done;
    output reg error;
    output reg [31:0] res;

  // fnc = 000    op = undefined
  //       001         undefined
  //       010         mul
  //       011         mulu
  //       100         div
  //       101         divu
  //       110         rem
  //       111         remu

  reg div;
  reg rem;
  reg [5:0] count;
  reg a_neg;
  reg b_neg;
  reg [31:0] b_abs;
  reg [64:0] q;
  wire [64:1] s;
  wire [64:0] d;

  assign s[64:32] = q[64:32] + { 1'b0, b_abs };
  assign s[31: 1] = q[31: 1];
  assign d[64:32] = q[64:32] - { 1'b0, b_abs };
  assign d[31: 0] = q[31: 0];

  always @(posedge clk) begin
    if (start == 1) begin
      if (fnc[2] == 1 && (| b[31:0]) == 0) begin
        // division by zero
        done <= 1;
        error <= 1;
      end else begin
        // operands are ok
        done <= 0;
        error <= 0;
      end
      div <= fnc[2];
      rem <= fnc[1];
      count <= 6'd0;
      if (fnc[0] == 0 && a[31] == 1) begin
        // negate first operand
        a_neg <= 1;
        if (fnc[2] == 0) begin
          // initialize q for multiplication
          q[64:32] <= 33'b0;
          q[31: 0] <= ~a + 1;
        end else begin
          // initialize q for division and remainder
          q[64:33] <= 32'b0;
          q[32: 1] <= ~a + 1;
          q[ 0: 0] <= 1'b0;
        end
      end else begin
        // use first operand as is
        a_neg <= 0;
        if (fnc[2] == 0) begin
          // initialize q for multiplication
          q[64:32] <= 33'b0;
          q[31: 0] <= a;
        end else begin
          // initialize q for division and remainder
          q[64:33] <= 32'b0;
          q[32: 1] <= a;
          q[ 0: 0] <= 1'b0;
        end
      end
      if (fnc[0] == 0 && b[31] == 1) begin
        // negate second operand
        b_neg <= 1;
        b_abs <= ~b + 1;
      end else begin
        // use second operand as is
        b_neg <= 0;
        b_abs <= b;
      end
    end else begin
      if (done == 0) begin
        // algorithm not yet finished
        if (div == 0) begin
          //
          // multiplication
          //
          if (count == 6'd32) begin
            // last step
            done <= 1;
            if (a_neg == b_neg) begin
              res <= q[31:0];
            end else begin
              res <= ~q[31:0] + 1;
            end
          end else begin
            // all other steps
            count <= count + 1;
            if (q[0] == 1) begin
              q <= { 1'b0, s[64:1] };
            end else begin
              q <= { 1'b0, q[64:1] };
            end
          end
        end else begin
          //
          // division and remainder
          //
          if (count == 6'd32) begin
            // last step
            done <= 1;
            if (rem == 0) begin
              // result <= quotient
              if (a_neg == b_neg) begin
                res <= q[31:0];
              end else begin
                res <= ~q[31:0] + 1;
              end
            end else begin
              // result <= remainder
              if (a_neg == 0) begin
                res <= q[64:33];
              end else begin
                res <= ~q[64:33] + 1;
              end
            end
          end else begin
            // all other steps
            count <= count + 1;
            if (d[64] == 0) begin
              q <= { d[63:0], 1'b1 };
            end else begin
              q <= { q[63:0], 1'b0 };
            end
          end
        end
      end
    end
  end

endmodule


//--------------------------------------------------------------
// sregs -- the special registers
//--------------------------------------------------------------


module sregs(clk, reset,
             rn, we, din, dout,
             psw, psw_we, psw_new,
             tlb_index, tlb_index_we, tlb_index_new,
             tlb_entry_hi, tlb_entry_hi_we, tlb_entry_hi_new,
             tlb_entry_lo, tlb_entry_lo_we, tlb_entry_lo_new,
             mmu_bad_addr, mmu_bad_addr_we, mmu_bad_addr_new,
             mmu_bad_accs, mmu_bad_accs_we, mmu_bad_accs_new);
    input clk;
    input reset;
    input [2:0] rn;
    input we;
    input [31:0] din;
    output [31:0] dout;
    output [31:0] psw;
    input psw_we;
    input [31:0] psw_new;
    output [31:0] tlb_index;
    input tlb_index_we;
    input [31:0] tlb_index_new;
    output [31:0] tlb_entry_hi;
    input tlb_entry_hi_we;
    input [31:0] tlb_entry_hi_new;
    output [31:0] tlb_entry_lo;
    input tlb_entry_lo_we;
    input [31:0] tlb_entry_lo_new;
    output [31:0] mmu_bad_addr;
    input mmu_bad_addr_we;
    input [31:0] mmu_bad_addr_new;
    output [31:0] mmu_bad_accs;
    input mmu_bad_accs_we;
    input [31:0] mmu_bad_accs_new;

  // rn = 000   register = PSW
  //      001              TLB index
  //      010              TLB entry high
  //      011              TLB entry low
  //      100              MMU bad address
  //      101              MMU bad access
  //      110              - not used -
  //      111              - not used -

  reg [31:0] sr[0:7];

  assign dout = sr[rn];
  assign psw = sr[0];
  assign tlb_index = sr[1];
  assign tlb_entry_hi = sr[2];
  assign tlb_entry_lo = sr[3];
  assign mmu_bad_addr = sr[4];
  assign mmu_bad_accs = sr[5];

  always @(posedge clk) begin
    if (reset == 1) begin
      sr[0] <= 32'h00000000;
    end else begin
      if (we == 1) begin
        sr[rn] <= din;
      end else begin
        if (psw_we) begin
          sr[0] <= psw_new;
        end
        if (tlb_index_we) begin
          sr[1] <= tlb_index_new;
        end
        if (tlb_entry_hi_we) begin
          sr[2] <= tlb_entry_hi_new;
        end
        if (tlb_entry_lo_we) begin
          sr[3] <= tlb_entry_lo_new;
        end
        if (mmu_bad_addr_we) begin
          sr[4] <= mmu_bad_addr_new;
        end
        if (mmu_bad_accs_we) begin
          sr[5] <= mmu_bad_accs_new;
        end
      end
    end
  end

endmodule


//--------------------------------------------------------------
// mmu -- the memory management unit
//--------------------------------------------------------------


module mmu(clk, reset, fnc, virt, phys,
           tlb_index, tlb_index_new,
           tlb_entry_hi, tlb_entry_hi_new,
           tlb_entry_lo, tlb_entry_lo_new,
           tlb_kmissed, tlb_umissed,
           tlb_invalid, tlb_wrtprot);
    input clk;
    input reset;
    input [2:0] fnc;
    input [31:0] virt;
    output [31:0] phys;
    input [31:0] tlb_index;
    output [31:0] tlb_index_new;
    input [31:0] tlb_entry_hi;
    output [31:0] tlb_entry_hi_new;
    input [31:0] tlb_entry_lo;
    output [31:0] tlb_entry_lo_new;
    output tlb_kmissed;
    output tlb_umissed;
    output tlb_invalid;
    output tlb_wrtprot;

  // fnc = 000    no operation, hold output
  //       001    map virt to phys address
  //       010    tbs
  //       011    tbwr
  //       100    tbri
  //       101    tbwi
  //       110    undefined
  //       111    undefined

  wire map;
  wire tbs;
  wire tbwr;
  wire tbri;
  wire tbwi;
  reg [19:0] page;
  reg [11:0] offset;
  wire [19:0] tlb_page;
  wire tlb_miss;
  wire [4:0] tlb_found;
  wire tlb_enable;
  wire [19:0] tlb_frame;
  wire tlb_wbit;
  wire tlb_vbit;
  wire [4:0] rw_index;
  wire [19:0] r_page;
  wire [19:0] r_frame;
  wire w_enable;
  wire [19:0] w_page;
  wire [19:0] w_frame;
  wire direct;
  wire [17:0] frame;
  reg [4:0] random_index;
  reg tlb_miss_delayed;

  // decode function
  assign map = (fnc == 3'b001) ? 1 : 0;
  assign tbs = (fnc == 3'b010) ? 1 : 0;
  assign tbwr = (fnc == 3'b011) ? 1 : 0;
  assign tbri = (fnc == 3'b100) ? 1 : 0;
  assign tbwi = (fnc == 3'b101) ? 1 : 0;

  // latch virtual address
  always @(posedge clk) begin
    if (map == 1) begin
      page <= virt[31:12];
      offset <= virt[11:0];
    end
  end

  // create tlb instance
  assign tlb_page = (tbs == 1) ? tlb_entry_hi[31:12] : virt[31:12];
  assign tlb_enable = map;
  assign tlb_wbit = tlb_frame[1];
  assign tlb_vbit = tlb_frame[0];
  assign rw_index = (tbwr == 1) ? random_index : tlb_index[4:0];
  assign tlb_index_new = { tlb_miss, 26'b0, tlb_found };
  assign tlb_entry_hi_new = { ((tbri == 1) ? r_page : page),
                              tlb_entry_hi[11:0] };
  assign tlb_entry_lo_new = { tlb_entry_lo[31:30], r_frame[19:2],
                              tlb_entry_lo[11:2], r_frame[1:0] };
  assign w_enable = tbwr | tbwi;
  assign w_page = tlb_entry_hi[31:12];
  assign w_frame = { tlb_entry_lo[29:12], tlb_entry_lo[1:0] };
  tlb tlb1(tlb_page, tlb_miss, tlb_found,
           clk, tlb_enable, tlb_frame,
           rw_index, r_page, r_frame,
           w_enable, w_page, w_frame);

  // construct physical address
  assign direct = (page[19:18] == 2'b11) ? 1 : 0;
  assign frame = (direct == 1) ? page[17:0] : tlb_frame[19:2];
  assign phys = { 2'b00, frame, offset };

  // generate "random" index
  always @(posedge clk) begin
    if (reset == 1) begin
      // the index register is counting down
      // so we must start at topmost index
      random_index <= 5'd31;
    end else begin
      // decrement index register "randomly"
      // (whenever there is a mapping operation)
      // skip "fixed" entries (0..3)
      if (map == 1) begin
        if (random_index == 5'd4) begin
          random_index <= 5'd31;
        end else begin
          random_index <= random_index - 1;
        end
      end
    end
  end

  // generate TLB exceptions
  always @(posedge clk) begin
    if (map == 1) begin
      tlb_miss_delayed <= tlb_miss;
    end
  end
  assign tlb_kmissed = tlb_miss_delayed & ~direct & page[19];
  assign tlb_umissed = tlb_miss_delayed & ~direct & ~page[19];
  assign tlb_invalid = ~tlb_vbit & ~direct;
  assign tlb_wrtprot = ~tlb_wbit & ~direct;

endmodule


//--------------------------------------------------------------
// tlb -- the translation lookaside buffer
//--------------------------------------------------------------


module tlb(page_in, miss, found,
           clk, enable, frame_out,
           rw_index, r_page, r_frame,
           w_enable, w_page, w_frame);
    input [19:0] page_in;
    output miss;
    output [4:0] found;
    input clk;
    input enable;
    output reg [19:0] frame_out;
    input [4:0] rw_index;
    output reg [19:0] r_page;
    output reg [19:0] r_frame;
    input w_enable;
    input [19:0] w_page;
    input [19:0] w_frame;

  reg [19:0] page[0:31];
  reg [19:0] frame[0:31];

  wire [19:0] p00, p01, p02, p03;
  wire [19:0] p04, p05, p06, p07;
  wire [19:0] p08, p09, p10, p11;
  wire [19:0] p12, p13, p14, p15;
  wire [19:0] p16, p17, p18, p19;
  wire [19:0] p20, p21, p22, p23;
  wire [19:0] p24, p25, p26, p27;
  wire [19:0] p28, p29, p30, p31;
  wire [31:0] match;

  assign p00 = page[ 0];
  assign p01 = page[ 1];
  assign p02 = page[ 2];
  assign p03 = page[ 3];
  assign p04 = page[ 4];
  assign p05 = page[ 5];
  assign p06 = page[ 6];
  assign p07 = page[ 7];
  assign p08 = page[ 8];
  assign p09 = page[ 9];
  assign p10 = page[10];
  assign p11 = page[11];
  assign p12 = page[12];
  assign p13 = page[13];
  assign p14 = page[14];
  assign p15 = page[15];
  assign p16 = page[16];
  assign p17 = page[17];
  assign p18 = page[18];
  assign p19 = page[19];
  assign p20 = page[20];
  assign p21 = page[21];
  assign p22 = page[22];
  assign p23 = page[23];
  assign p24 = page[24];
  assign p25 = page[25];
  assign p26 = page[26];
  assign p27 = page[27];
  assign p28 = page[28];
  assign p29 = page[29];
  assign p30 = page[30];
  assign p31 = page[31];

  assign match[ 0] = (page_in == p00) ? 1 : 0;
  assign match[ 1] = (page_in == p01) ? 1 : 0;
  assign match[ 2] = (page_in == p02) ? 1 : 0;
  assign match[ 3] = (page_in == p03) ? 1 : 0;
  assign match[ 4] = (page_in == p04) ? 1 : 0;
  assign match[ 5] = (page_in == p05) ? 1 : 0;
  assign match[ 6] = (page_in == p06) ? 1 : 0;
  assign match[ 7] = (page_in == p07) ? 1 : 0;
  assign match[ 8] = (page_in == p08) ? 1 : 0;
  assign match[ 9] = (page_in == p09) ? 1 : 0;
  assign match[10] = (page_in == p10) ? 1 : 0;
  assign match[11] = (page_in == p11) ? 1 : 0;
  assign match[12] = (page_in == p12) ? 1 : 0;
  assign match[13] = (page_in == p13) ? 1 : 0;
  assign match[14] = (page_in == p14) ? 1 : 0;
  assign match[15] = (page_in == p15) ? 1 : 0;
  assign match[16] = (page_in == p16) ? 1 : 0;
  assign match[17] = (page_in == p17) ? 1 : 0;
  assign match[18] = (page_in == p18) ? 1 : 0;
  assign match[19] = (page_in == p19) ? 1 : 0;
  assign match[20] = (page_in == p20) ? 1 : 0;
  assign match[21] = (page_in == p21) ? 1 : 0;
  assign match[22] = (page_in == p22) ? 1 : 0;
  assign match[23] = (page_in == p23) ? 1 : 0;
  assign match[24] = (page_in == p24) ? 1 : 0;
  assign match[25] = (page_in == p25) ? 1 : 0;
  assign match[26] = (page_in == p26) ? 1 : 0;
  assign match[27] = (page_in == p27) ? 1 : 0;
  assign match[28] = (page_in == p28) ? 1 : 0;
  assign match[29] = (page_in == p29) ? 1 : 0;
  assign match[30] = (page_in == p30) ? 1 : 0;
  assign match[31] = (page_in == p31) ? 1 : 0;

  assign miss = ~(| match[31:0]);

  assign found[0] = match[ 1] | match[ 3] | match[ 5] | match[ 7] |
                    match[ 9] | match[11] | match[13] | match[15] |
                    match[17] | match[19] | match[21] | match[23] |
                    match[25] | match[27] | match[29] | match[31];
  assign found[1] = match[ 2] | match[ 3] | match[ 6] | match[ 7] |
                    match[10] | match[11] | match[14] | match[15] |
                    match[18] | match[19] | match[22] | match[23] |
                    match[26] | match[27] | match[30] | match[31];
  assign found[2] = match[ 4] | match[ 5] | match[ 6] | match[ 7] |
                    match[12] | match[13] | match[14] | match[15] |
                    match[20] | match[21] | match[22] | match[23] |
                    match[28] | match[29] | match[30] | match[31];
  assign found[3] = match[ 8] | match[ 9] | match[10] | match[11] |
                    match[12] | match[13] | match[14] | match[15] |
                    match[24] | match[25] | match[26] | match[27] |
                    match[28] | match[29] | match[30] | match[31];
  assign found[4] = match[16] | match[17] | match[18] | match[19] |
                    match[20] | match[21] | match[22] | match[23] |
                    match[24] | match[25] | match[26] | match[27] |
                    match[28] | match[29] | match[30] | match[31];

  always @(posedge clk) begin
    if (enable == 1) begin
      frame_out <= frame[found];
    end
  end

  always @(posedge clk) begin
    if (w_enable == 1) begin
      page[rw_index] <= w_page;
      frame[rw_index] <= w_frame;
    end else begin
      r_page <= page[rw_index];
      r_frame <= frame[rw_index];
    end
  end

endmodule
