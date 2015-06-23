/*
 * Simply RISC M1 Central Processing Unit
 */

`include "m1_defs.vh"

module m1_cpu (

    // System
    input sys_clock_i,                            // System Clock
    input sys_reset_i,                            // System Reset
    input sys_irq_i,                              // Interrupt Request

    // ALU
    output[31:0] alu_a_o,                         // ALU Operand A
    output[31:0] alu_b_o,                         // ALU Operand B
    output[4:0] alu_func_o,                       // ALU Function
    output alu_signed_o,                          // ALU operation is Signed
    input[32:0] alu_result_i,                     // ALU Result with Carry

    // Multiplier
    output reg mul_req_o,                         // Multiplier Request
    output[31:0] mul_a_o,                         // Multiplier Operand A
    output[31:0] mul_b_o,                         // Multiplier Operand B
    output mul_signed_o,                          // Multiplication is Signed
    input mul_ack_i,                              // Multiplier Ack
    input[63:0] mul_product_i,                    // Multiplier Product

    // Divider
    output reg div_req_o,                         // Divider Request
    output[31:0] div_a_o,                         // Divider Operand A
    output[31:0] div_b_o,                         // Divider Operand B
    output div_signed_o,                          // Division is Signed
    input div_ack_i,                              // Divider Ack
    input[31:0] div_quotient_i,                   // Divider Quotient
    input[31:0] div_remainder_i,                  // Divider Remainder

    // Instruction Memory
    output imem_read_o,                           // I$ Read
    output[31:0] imem_addr_o,                     // I$ Address
    input imem_done_i,                            // I$ Done
    input[31:0] imem_data_i,                      // I$ Data

    // Data Memory
    output dmem_read_o,                           // D$ Read
    output dmem_write_o,                          // D$ Write
    output[3:0] dmem_sel_o,                       // D$ Byte selector
    output[31:0] dmem_addr_o,                     // D$ Address
    output[31:0] dmem_data_o,                     // D$ Write Data
    input dmem_done_i,                            // D$ Done
    input[31:0] dmem_data_i                       // D$ Read Data

  );

  /*
   * Registers
   */

  // Register file
  reg[31:0] GPR[31:0];                            // General Purpose Registers
  reg[31:0] PC;                                   // Program Counter
  reg[31:0] HI, LO;                               // HI and LO registers (for multiplication/division)
  reg[31:0] SysCon[0:31];                         // System Control registers
   
  /*
   * Pipeline latches
   */

  // Latch 1: IF/ID
  reg[31:0] if_id_opcode;                                            // Instruction Register
  reg[31:0] if_id_addr, if_id_addrnext;                              // Addresses of the fetched opcode and of the next one

  // Latch 2: ID/EX
  reg[31:0] id_ex_opcode;
  reg[31:0] id_ex_addr, id_ex_addrnext;
  reg[31:0] id_ex_addrbranch, id_ex_addrjump, id_ex_addrjr;          // Evaluated jump addresses
  reg[31:0] id_ex_alu_a, id_ex_alu_b;                                // ALU operands
  reg[4:0] id_ex_alu_func;                                           // ALU operation code
  reg id_ex_alu_signed;                                              // ALU operation is signed
  reg id_ex_branch, id_ex_jump, id_ex_jr, id_ex_linked;              // Instruction is a jump
  reg id_ex_mult, id_ex_div;                                         // Instruction is a multiplication/division
  reg id_ex_load, id_ex_store;                                       // Instruction is a load/store
  reg[2:0] id_ex_size;                                               // Load/store size (see defs.h)
  reg[31:0] id_ex_store_value;                                       // Store value
  reg[4:0] id_ex_destreg;                                            // Destination register (GPR number)
  reg id_ex_desthi, id_ex_destlo;                                    // Destination register (HI/LO)
  reg[4:0] id_ex_destsyscon;                                         // Destination register (System Control)

  // Latch 3: EX/MEM
  reg[31:0] ex_mem_opcode;
  reg[31:0] ex_mem_addr, ex_mem_addrnext;
  reg[31:0] ex_mem_addrbranch, ex_mem_addrjump, ex_mem_addrjr;
  reg[63:0] ex_mem_aluout;                                           // ALU result
  reg ex_mem_carry;                                                  // ALU carry
  reg ex_mem_branch, ex_mem_jump, ex_mem_jr, ex_mem_linked;
  reg ex_mem_mult, ex_mem_div;
  reg ex_mem_load, ex_mem_store;
  reg[2:0] ex_mem_size;
  reg[31:0] ex_mem_store_value;
  reg[3:0] ex_mem_store_sel;                                         // Byte Selector on Stores
  reg[31:0] ex_mem_destold;                                          // Old value for partial rewrite
  reg[4:0] ex_mem_destreg;
  reg ex_mem_desthi, ex_mem_destlo;
  reg[4:0] ex_mem_destsyscon;
   
  // Latch 4: MEM/WB
  reg[31:0] mem_wb_opcode;
  reg[31:0] mem_wb_addr, mem_wb_addrnext;
  reg[63:0] mem_wb_value;                                            // Write-back value
  reg[4:0] mem_wb_destreg;
  reg mem_wb_desthi, mem_wb_destlo;
  reg [4:0] mem_wb_destsyscon;

  /*
   * Combinational logic
   */  

  // ALU
  assign alu_a_o = id_ex_alu_a;
  assign alu_b_o = id_ex_alu_b;
  assign alu_func_o = id_ex_alu_func;
  assign alu_signed_o = id_ex_alu_signed;

  // Multiplier
  assign mul_a_o = id_ex_alu_a;
  assign mul_b_o = id_ex_alu_b;
  assign mul_signed_o = id_ex_alu_signed;
  wire mul_ready = (mul_req_o==mul_ack_i);  // Convert ABP ack to true/false format
  wire mul_busy = !mul_ready;

  // Divider
  assign div_a_o = id_ex_alu_a;
  assign div_b_o = id_ex_alu_b;
  assign div_signed_o = id_ex_alu_signed;
  wire div_ready = (div_req_o==div_ack_i);  // Convert ABP ack to true/false format
  wire div_busy = !div_ready;

  // Incremented Program Counter
  wire[31:0] PCnext = PC + 4;

  // Instruction Memory
  assign imem_read_o = 1;
  assign imem_addr_o = PC;

  // Data Memory
  assign dmem_addr_o = ex_mem_aluout;
  assign dmem_read_o = ex_mem_load;
  assign dmem_write_o = ex_mem_store;
  assign dmem_data_o = ex_mem_store_value;
  assign dmem_sel_o = ex_mem_store_sel;

  // Decode fields from the Instruction Register
  wire[5:0] if_id_op = if_id_opcode[31:26];                                     // Operation code
  wire[4:0] if_id_rs = if_id_opcode[25:21];                                     // Source register
  wire[4:0] if_id_rt = if_id_opcode[20:16];                                     // Target register
  wire[4:0] if_id_rd = if_id_opcode[15:11];                                     // Destination register
  wire[31:0] if_id_imm_signext = {{16{if_id_opcode[15]}}, if_id_opcode[15:0]};  // Immediate field with sign-extension
  wire[31:0] if_id_imm_zeroext = {16'b0, if_id_opcode[15:0]};                   // Immediate field with zero-extension
  wire[25:0] if_id_index = if_id_opcode[25:0];                                  // Index field
  wire[4:0] if_id_shamt = if_id_opcode[10:6];                                   // Shift amount
  wire[5:0] if_id_func = if_id_opcode[5:0];                                     // Function

  // True for still undecoded operations that read GPR[rs]
  wire if_id_reads_rs = (
    if_id_op==`OPCODE_BEQ || if_id_op==`OPCODE_BNE || if_id_op==`OPCODE_BLEZ || if_id_op==`OPCODE_BGTZ ||
    if_id_op==`OPCODE_ADDI || if_id_op==`OPCODE_ADDIU || if_id_op==`OPCODE_SLTI || if_id_op==`OPCODE_SLTIU ||
    if_id_op==`OPCODE_ANDI || if_id_op==`OPCODE_ORI || if_id_op==`OPCODE_XORI || if_id_op==`OPCODE_LB ||
    if_id_op==`OPCODE_LH || if_id_op==`OPCODE_LWL || if_id_op==`OPCODE_LW || if_id_op==`OPCODE_LBU ||
    if_id_op==`OPCODE_LHU || if_id_op==`OPCODE_LWR || if_id_op==`OPCODE_SB || if_id_op==`OPCODE_SH ||
    if_id_op==`OPCODE_SWL || if_id_op==`OPCODE_SW || if_id_op==`OPCODE_SWR || (
      if_id_op==`OPCODE_SPECIAL && (
        if_id_func==`FUNCTION_SLLV || if_id_func==`FUNCTION_SRLV || if_id_func==`FUNCTION_SRAV ||
        if_id_func==`FUNCTION_JR || if_id_func==`FUNCTION_JALR || if_id_func==`FUNCTION_MTHI ||
        if_id_func==`FUNCTION_MTLO || if_id_func==`FUNCTION_MULT || if_id_func==`FUNCTION_MULTU ||
        if_id_func==`FUNCTION_DIV || if_id_func==`FUNCTION_DIVU || if_id_func==`FUNCTION_ADD ||
        if_id_func==`FUNCTION_ADDU || if_id_func==`FUNCTION_SUB || if_id_func==`FUNCTION_SUBU ||
        if_id_func==`FUNCTION_AND || if_id_func==`FUNCTION_OR || if_id_func==`FUNCTION_XOR ||
        if_id_func==`FUNCTION_NOR || if_id_func==`FUNCTION_SLT || if_id_func==`FUNCTION_SLTU
      )
    ) || (
      if_id_op==`OPCODE_BCOND && (
        if_id_rt==`BCOND_BLTZ || if_id_rt==`BCOND_BGEZ || if_id_rt==`BCOND_BLTZAL || if_id_rt==`BCOND_BGEZAL
      )
   )
  );

  // True for still undecoded operations that read GPR[rt]
  wire if_id_reads_rt = (
    if_id_op==`OPCODE_BEQ || if_id_op==`OPCODE_BNE || if_id_op==`OPCODE_SB || if_id_op==`OPCODE_SH ||
    if_id_op==`OPCODE_SWL || if_id_op==`OPCODE_SW || if_id_op==`OPCODE_SWR || (
      if_id_op==`OPCODE_SPECIAL && (
        if_id_func==`FUNCTION_SLL || if_id_func==`FUNCTION_SRL || if_id_func==`FUNCTION_SRA ||
        if_id_func==`FUNCTION_SLLV || if_id_func==`FUNCTION_SRLV || if_id_func==`FUNCTION_SRAV ||
        if_id_func==`FUNCTION_MULT || if_id_func==`FUNCTION_MULTU || if_id_func==`FUNCTION_DIV ||
        if_id_func==`FUNCTION_DIVU || if_id_func==`FUNCTION_ADD || if_id_func==`FUNCTION_ADDU ||
        if_id_func==`FUNCTION_SUB || if_id_func==`FUNCTION_SUBU || if_id_func==`FUNCTION_AND ||
        if_id_func==`FUNCTION_OR || if_id_func==`FUNCTION_XOR || if_id_func==`FUNCTION_NOR ||
        if_id_func==`FUNCTION_SLT || if_id_func==`FUNCTION_SLTU
      )
    )
  );

  // True for still undecoded operations that read the HI register
  wire if_id_reads_hi = (if_id_op==`OPCODE_SPECIAL && if_id_func==`FUNCTION_MFHI);

  // True for still undecoded operations that read the LO register
  wire if_id_reads_lo = (if_id_op==`OPCODE_SPECIAL && if_id_func==`FUNCTION_MFLO);

  // Finally detect a RAW hazard
  wire raw_detected = (
    (if_id_reads_rs && if_id_rs!=0 &&
      (if_id_rs==id_ex_destreg || if_id_rs==ex_mem_destreg || if_id_rs==mem_wb_destreg)) ||
    (if_id_reads_rt && if_id_rt!=0 &&
      (if_id_rt==id_ex_destreg || if_id_rt==ex_mem_destreg || if_id_rt==mem_wb_destreg)) ||
    (if_id_reads_hi && (id_ex_desthi || ex_mem_desthi || mem_wb_desthi)) ||
    (if_id_reads_lo && (id_ex_destlo || ex_mem_destlo || mem_wb_destlo))
  );

  // Stall signals for all the stages
  wire if_stall, id_stall, ex_stall, mem_stall, wb_stall;
  assign if_stall = id_stall || !imem_done_i;
  assign id_stall = ex_stall || raw_detected;
  assign ex_stall = mem_stall || mul_busy || div_busy;
  assign mem_stall = wb_stall || ( (dmem_read_o||dmem_write_o) && !dmem_done_i);
  assign wb_stall = 0;

  // Branch taken
  wire branch_taken;
  assign branch_taken = ( ex_mem_branch==1 && (ex_mem_aluout==32'h00000001) );
   
  // Name the System Configuration registers
  wire[31:0] BadVAddr = SysCon[`SYSCON_BADVADDR];
  wire[31:0] Status = SysCon[`SYSCON_STATUS];
  wire[31:0] Cause = SysCon[`SYSCON_CAUSE];
  wire[31:0] EPC = SysCon[`SYSCON_EPC];
  wire[31:0] PrID = SysCon[`SYSCON_PRID];
   
  // Index for GPR initialization
  integer i;

  /*
   * Sequential logic
   */

  always @ (posedge sys_clock_i) begin

    // Initialize all the registers
    if (sys_reset_i==1) begin

      // GPRs initialization
      for(i=0; i<=31; i=i+1) GPR[i] <= 32'h00000000;

      // System registers
      PC <= `BOOT_ADDRESS;
      HI <= 0;
      LO <= 0;

      // Initialize system configuration registers
      for(i=0; i<=31; i=i+1) SysCon[i] <= 32'h00000000;
       
      // Initialize ABP requests to instantiated modules
      mul_req_o <= 0;
      div_req_o <= 0;

      // Latch 1: IF/ID
      if_id_opcode <= `NOP;
      if_id_addr <= `BOOT_ADDRESS;
      if_id_addrnext <= 0;

      // Latch 2: ID/EX
      id_ex_opcode <= 0;
      id_ex_addr <= 0;
      id_ex_addrnext <= 0;
      id_ex_addrjump <= 0;
      id_ex_addrbranch <= 0;
      id_ex_alu_a <= 0;
      id_ex_alu_b <= 0;
      id_ex_alu_func <= `ALU_OP_ADD;
      id_ex_alu_signed <= 0;
      id_ex_branch <= 0;
      id_ex_jump <= 0;
      id_ex_jr <=0;
      id_ex_linked <= 0;
      id_ex_mult <= 0;
      id_ex_div <= 0;
      id_ex_load <= 0;
      id_ex_store <= 0;
      id_ex_size <= 0;
      id_ex_store_value <= 0;
      id_ex_destreg <= 0;
      id_ex_desthi <= 0;
      id_ex_destlo <= 0;

      ex_mem_opcode <= 0;
      ex_mem_addr <= 0;
      ex_mem_addrnext <= 0;
      ex_mem_addrjump <= 0;
      ex_mem_addrbranch <= 0;
      ex_mem_aluout <= 0;
      ex_mem_carry <= 0;
      ex_mem_branch <= 0;
      ex_mem_jump <= 0;
      ex_mem_jr <= 0;
      ex_mem_linked <= 0;
      ex_mem_mult <= 0;
      ex_mem_div <= 0;
      ex_mem_load <= 0;
      ex_mem_store <= 0;
      ex_mem_store_value <= 0;
      ex_mem_store_sel <= 0;
      ex_mem_destreg <= 0;
      ex_mem_desthi <= 0;
      ex_mem_destlo <= 0;

      // Latch 4: MEM/WB
      mem_wb_opcode <= 0;
      mem_wb_addr <= 0;
      mem_wb_addrnext <= 0;
      mem_wb_value <= 0;
      mem_wb_destreg <= 0;
      mem_wb_desthi <= 0;
      mem_wb_destlo <= 0;

    end else begin

      $display("================> Time %t <================", $time);

      /*
       * Pipeline Stage 1: Instruction Fetch (IF)
       * 
       * READ/WRITE:
       * - read memory
       * - write the IF/ID latch
       * - write the PC register
       * 
       * DESCRIPTION:
       * This stage usually reads the next instruction from the PC address in memory and
       * then updates the PC value by incrementing it by 4.
       */

      // Handle hazards (if_stall = id_stall || !imem_done_i)
      if(if_stall) begin

        // IF stall backward propagated from ID
        if(id_stall) begin
          $display("INFO: CPU(%m)-IF: Fetching stalled like ID, latch keeps old value");
        // IMEM is not ready
        end else begin
          $display("INFO: CPU(%m)-IF: Fetching stalled due to IMEM, latch filled with bubble");
          if_id_opcode <= `BUBBLE;
        end

      end else begin

        // If branch taken update the Program Counter (branch_taken = ex_mem_branch==1 && ex_mem_aluout==32'h00000001)
        if(branch_taken) begin

          $display("INFO: CPU(%m)-IF: Bubble inserted due branch taken in EX/MEM instruction @ADDR=%X w/OPCODE=%X having ALUout=%X", ex_mem_addr, ex_mem_opcode, ex_mem_aluout);
          if_id_opcode <= `BUBBLE;
          PC <= ex_mem_addrbranch;

        // Jump to the required immediate address
        end else if(id_ex_jump==1) begin

          $display("INFO: CPU(%m)-IF: Bubble inserted due to jump in ID/EX instruction @ADDR=%X w/OPCODE=%X", id_ex_addr, id_ex_opcode);
          if_id_opcode <= `BUBBLE;
          PC <= id_ex_addrjump;
	
        // Jump to the required address stored in GPR
        end else if(id_ex_jr==1) begin

          $display("INFO: CPU(%m)-IF: Bubble inserted due to jump register in ID/EX instruction @ADDR=%X w/OPCODE=%X", id_ex_addr, id_ex_opcode);
          if_id_opcode <= `BUBBLE;
          PC <= id_ex_addrjr;
	
        // Normal execution
        end else begin

          $display("INFO: CPU(%m)-IF: Fetched from Program Counter @ADDR=%h getting OPCODE=%X", PC, imem_data_i);
          if_id_opcode <= imem_data_i;
          if_id_addr <= PC;
          if_id_addrnext <= PCnext;
          PC <= PCnext;

        end
      end

      /*
       * Pipeline Stage 2: Instruction Decode (ID)
       * 
       * READ/WRITE:
       * - read the IF/ID latch
       * - read the register file
       * - write the ID/EX latch
       * 
       * DESCRIPTION:
       * This stage decodes the instruction and puts the values for the ALU inputs
       */

      if(branch_taken) begin
        $display("INFO: CPU(%m)-ID: Branch taken and bubble inserted");
        id_ex_opcode <=`BUBBLE;
        id_ex_alu_a <= 0;
        id_ex_alu_b <= 0;
        id_ex_alu_func <= `ALU_OP_ADD;
        id_ex_alu_signed <= 0;
        id_ex_addr <= if_id_addr;
        id_ex_addrnext <= 0;
        id_ex_addrjump <= 0;
        id_ex_addrbranch <= 0;
        id_ex_branch <= 0;
        id_ex_jump <= 0;
        id_ex_jr <= 0;
        id_ex_linked <= 0;
        id_ex_mult <= 0;
        id_ex_div <= 0;
        id_ex_load <= 0;
        id_ex_store <= 0;
        id_ex_destreg <= 0;
        id_ex_desthi <= 0;
        id_ex_destlo <= 0;
      end else if(id_stall) begin
   
        if(ex_stall) begin
          $display("INFO: CPU(%m)-ID: Decoding stalled and latch kept");
        end else begin
          $display("INFO: CPU(%m)-ID: Decoding stalled and bubble inserted");
          id_ex_opcode <=`BUBBLE;
          id_ex_alu_a <= 0;
          id_ex_alu_b <= 0;
          id_ex_alu_func <= `ALU_OP_ADD;
          id_ex_alu_signed <= 0;
          id_ex_addr <= if_id_addr;
          id_ex_addrnext <= 0;
          id_ex_addrjump <= 0;
          id_ex_addrbranch <= 0;
          id_ex_branch <= 0;
          id_ex_jump <= 0;
          id_ex_jr <= 0;
          id_ex_linked <= 0;
          id_ex_mult <= 0;
          id_ex_div <= 0;
          id_ex_load <= 0;
          id_ex_store <= 0;
          id_ex_destreg <= 0;
          id_ex_desthi <= 0;
          id_ex_destlo <= 0;
        end
      end else begin
        id_ex_opcode <= if_id_opcode;
        id_ex_addr <= if_id_addr;
        id_ex_addrnext <= if_id_addrnext;
        id_ex_addrbranch <= if_id_addrnext + {if_id_imm_signext[29:0], 2'b00};
        id_ex_addrjump <= {if_id_addr[31:28], if_id_index, 2'b00};
        id_ex_addrjr <= GPR[if_id_rs];

        if(if_id_opcode==`BUBBLE) begin
          $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as BUBBLE", if_id_addr, if_id_opcode);
          id_ex_alu_a <= 0;
          id_ex_alu_b <= 0;
          id_ex_alu_func <= `ALU_OP_ADD;
          id_ex_alu_signed <= 0;
          id_ex_branch <= 0;
          id_ex_jump <= 0;
          id_ex_jr <= 0;
          id_ex_linked <= 0;
          id_ex_mult <= 0;
          id_ex_div <= 0;
          id_ex_load <= 0;
          id_ex_store <= 0;
          id_ex_size <= 0;
          id_ex_store_value <= 0;
          id_ex_destreg <= 0;
          id_ex_desthi <= 0;
          id_ex_destlo <= 0;
	end else case(if_id_op)
          `OPCODE_J:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as J %h", if_id_addr, if_id_opcode, if_id_index);
              id_ex_alu_a <= 0;
              id_ex_alu_b <= 0;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 0;
              id_ex_jump <= 1;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= 0;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_JAL:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as JAL %h", if_id_addr, if_id_opcode, if_id_index);
              id_ex_alu_a <= if_id_addrnext;
              id_ex_alu_b <= 4;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 0;
              id_ex_jump <= 1;
              id_ex_jr <= 0;
              id_ex_linked <= 1;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= 31;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_BEQ:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as BEQ r%d, r%d, %h", if_id_addr, if_id_opcode, if_id_rs, if_id_rt, if_id_imm_signext);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= GPR[if_id_rt];
              id_ex_alu_func <= `ALU_OP_SEQ;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 1;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= 0;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_BNE:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as BNE r%d, r%d, %h", if_id_addr, if_id_opcode, if_id_rs, if_id_rt, if_id_imm_signext);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= GPR[if_id_rt];
              id_ex_alu_func <= `ALU_OP_SNE;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 1;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= 0;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_BLEZ:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as BLEZ r%d, %h", if_id_addr, if_id_opcode, if_id_rs, if_id_imm_signext);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= 0;
              id_ex_alu_func <= `ALU_OP_SLE;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 1;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= 0;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_BGTZ:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as BGTZ r%d, %h", if_id_addr, if_id_opcode, if_id_rs, if_id_imm_signext);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= 0;
              id_ex_alu_func <= `ALU_OP_SGT;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 1;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= 0;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_ADDI:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as ADDI r%d, r%d, %h", if_id_addr, if_id_opcode, if_id_rt, if_id_rs, if_id_imm_signext);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 1;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_ADDIU:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as ADDIU r%d, r%d, %h", if_id_addr, if_id_opcode, if_id_rt, if_id_rs, if_id_imm_signext);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_SLTI:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SLTI r%d, r%d, %h", if_id_addr, if_id_opcode, if_id_rt, if_id_rs, if_id_imm_signext);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_SLT;
              id_ex_alu_signed <= 1;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_SLTIU:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SLTIU r%d, r%d, %h", if_id_addr, if_id_opcode, if_id_rt, if_id_rs, if_id_imm_signext);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_SLT;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_ANDI:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as ANDI r%d, r%d, %h", if_id_addr, if_id_opcode, if_id_rt, if_id_rs, if_id_imm_zeroext);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_zeroext;
              id_ex_alu_func <= `ALU_OP_AND;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_ORI:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as ORI r%d, r%d, %h", if_id_addr, if_id_opcode, if_id_rt, if_id_rs, if_id_imm_zeroext);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_zeroext;
              id_ex_alu_func <= `ALU_OP_OR;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_XORI:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as XORI r%d, r%d, %h", if_id_addr, if_id_opcode, if_id_rt, if_id_rs, if_id_imm_zeroext);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_zeroext;
              id_ex_alu_func <= `ALU_OP_XOR;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_LUI:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as LUI r%d, %h", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_zeroext);
              id_ex_alu_a <= if_id_imm_zeroext;
              id_ex_alu_b <= 16;
              id_ex_alu_func <= `ALU_OP_SLL;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 0;
              id_ex_size <= 0;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_COP0:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as COP0", if_id_addr, if_id_opcode);
            end
          `OPCODE_COP1:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as COP1", if_id_addr, if_id_opcode);
            end
          `OPCODE_COP2:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as COP2", if_id_addr, if_id_opcode);
            end
          `OPCODE_COP3:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as COP3", if_id_addr, if_id_opcode);
            end
          `OPCODE_LB:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as LB r%d, %d(r%d)", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_signext, if_id_rs);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 1;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 1;
              id_ex_store <= 0;
              id_ex_size <= `SIZE_BYTE;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_LH:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as LH r%d, %d(r%d)", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_signext, if_id_rs);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 1;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 1;
              id_ex_store <= 0;
              id_ex_size <= `SIZE_HALF;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_LWL:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as LWL r%d, %d(r%d)", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_signext, if_id_rs);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 1;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 1;
              id_ex_store <= 0;
              id_ex_size <= `SIZE_LEFT;
              id_ex_store_value <= GPR[if_id_rt];
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_LW:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as LW r%d, %d(r%d)", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_signext, if_id_rs);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 1;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 1;
              id_ex_store <= 0;
              id_ex_size <= `SIZE_WORD;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_LBU:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as LBU r%d, %d(r%d)", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_signext, if_id_rs);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 1;
              id_ex_store <= 0;
              id_ex_size <= `SIZE_BYTE;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_LHU:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as LHU r%d, %d(r%d)", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_signext, if_id_rs);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 0;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 1;
              id_ex_store <= 0;
              id_ex_size <= `SIZE_HALF;
              id_ex_store_value <= 0;
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_LWR:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as LWR r%d, %d(r%d)", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_signext, if_id_rs);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 1;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 1;
              id_ex_store <= 0;
              id_ex_size <= `SIZE_RIGHT;
              id_ex_store_value <= GPR[if_id_rt];
              id_ex_destreg <= if_id_rt;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_SB:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SB r%d, %d(r%d)", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_signext, if_id_rs);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 1;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 1;
              id_ex_size <= `SIZE_BYTE;
              id_ex_store_value <= GPR[if_id_rt];
              id_ex_destreg <= 0;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_SH:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SH r%d, %d(r%d)", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_signext, if_id_rs);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 1;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 1;
              id_ex_size <= `SIZE_HALF;
              id_ex_store_value <= GPR[if_id_rt];
              id_ex_destreg <= 0;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
             end
          `OPCODE_SWL:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SWL r%d, %d(r%d)", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_signext, if_id_rs);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 1;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 1;
              id_ex_size <= `SIZE_LEFT;
              id_ex_store_value <= GPR[if_id_rt];
              id_ex_destreg <= 0;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_SW:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SW r%d, %d(r%d)", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_signext, if_id_rs);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 1;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 1;
              id_ex_size <= `SIZE_WORD;
              id_ex_store_value <= GPR[if_id_rt];
              id_ex_destreg <= 0;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_SWR:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SWR r%d, %d(r%d)", if_id_addr, if_id_opcode, if_id_rt, if_id_imm_signext, if_id_rs);
              id_ex_alu_a <= GPR[if_id_rs];
              id_ex_alu_b <= if_id_imm_signext;
              id_ex_alu_func <= `ALU_OP_ADD;
              id_ex_alu_signed <= 1;
              id_ex_branch <= 0;
              id_ex_jump <= 0;
              id_ex_jr <= 0;
              id_ex_linked <= 0;
              id_ex_mult <= 0;
	      id_ex_div <= 0;
              id_ex_load <= 0;
              id_ex_store <= 1;
              id_ex_size <= `SIZE_RIGHT;
              id_ex_store_value <= GPR[if_id_rt];
              id_ex_destreg <= 0;
              id_ex_desthi <= 0;
              id_ex_destlo <= 0;
            end
          `OPCODE_LWC1:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as LWC1", if_id_addr, if_id_opcode);
           end
          `OPCODE_LWC2:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as LWC2", if_id_addr, if_id_opcode);
            end
          `OPCODE_LWC3:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as LWC3", if_id_addr, if_id_opcode);
            end
          `OPCODE_SWC1:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SWC1", if_id_addr, if_id_opcode);
            end
          `OPCODE_SWC2:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SWC2", if_id_addr, if_id_opcode);
            end
          `OPCODE_SWC3:
            begin
              $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SWC3", if_id_addr, if_id_opcode);
            end
          `OPCODE_SPECIAL:
            case(if_id_func)
              `FUNCTION_SLL:
                begin
                  if(if_id_opcode==`NOP) $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as NOP", if_id_addr, if_id_opcode);
                  else $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SLL r%d, r%d, %h", if_id_addr, if_id_opcode, if_id_rd, if_id_rt, if_id_shamt);
                  id_ex_alu_a <= GPR[if_id_rt];
                  id_ex_alu_b <= if_id_shamt;
                  id_ex_alu_func <= `ALU_OP_SLL;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_SRL:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SRL r%d, r%d, %h", if_id_addr, if_id_opcode, if_id_rd, if_id_rt, if_id_shamt);
                  id_ex_alu_a <= GPR[if_id_rt];
                  id_ex_alu_b <= if_id_shamt;
                  id_ex_alu_func <= `ALU_OP_SRL;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_SRA:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SRA r%d, r%d, %h", if_id_addr, if_id_opcode, if_id_rd, if_id_rt, if_id_shamt);
                  id_ex_alu_a <= GPR[if_id_rt];
                  id_ex_alu_b <= if_id_shamt;
                  id_ex_alu_func <= `ALU_OP_SRA;
                  id_ex_alu_signed <= 1;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_SLLV:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SLLV r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rt, if_id_rs);
                  id_ex_alu_a <= GPR[if_id_rt];
                  id_ex_alu_b <= GPR[if_id_rs];
                  id_ex_alu_func <= `ALU_OP_SLL;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_SRLV:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SRLV r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rt, if_id_rs);
                  id_ex_alu_a <= GPR[if_id_rt];
                  id_ex_alu_b <= GPR[if_id_rs];
                  id_ex_alu_func <= `ALU_OP_SRL;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_SRAV:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SRAV r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rt, if_id_rs);
                  id_ex_alu_a <= GPR[if_id_rt];
                  id_ex_alu_b <= GPR[if_id_rs];
                  id_ex_alu_func <= `ALU_OP_SRA;
                  id_ex_alu_signed <= 1;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_JR:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as JR r%d", if_id_addr, if_id_opcode, if_id_rs);
                  id_ex_alu_a <= 0;
                  id_ex_alu_b <= 0;
                  id_ex_alu_func <= `ALU_OP_ADD;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 1;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= 0;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_JALR:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as JALR [r%d,] r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rs);
                  id_ex_alu_a <= if_id_addrnext;
                  id_ex_alu_b <= 4;
                  id_ex_alu_func <= `ALU_OP_ADD;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 1;
                  id_ex_linked <= 1;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_SYSCALL:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SYSCALL", if_id_addr, if_id_opcode);
//                  id_ex_alu_a <= 0;
//                  id_ex_alu_b <= 0;
//                  id_ex_alu_func <= `ALU_OP_ADD;
//                  id_ex_alu_signed <= 0;
//                  id_ex_branch <= 0;
//                  id_ex_jump <= 0;
//                  id_ex_jr <= 0;
//                  id_ex_linked <= 0;
//                  id_ex_mult <= 0;
//                  id_ex_div <= 0;
//                  id_ex_load <= 0;
//                  id_ex_store <= 0;
//                  id_ex_size <= 0;
//                  id_ex_store_value <= 0;
//                  id_ex_destreg <= 0;
//                  id_ex_desthi <= 0;
//                  id_ex_destlo <= 0;
                end
              `FUNCTION_BREAK:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as BREAK", if_id_addr, if_id_opcode);
//                  id_ex_alu_a <= 0;
//                  id_ex_alu_b <= 0;
//                  id_ex_alu_func <= `ALU_OP_ADD;
//                  id_ex_alu_signed <= 0;
//                  id_ex_branch <= 0;
//                  id_ex_jump <= 0;
//                  id_ex_jr <= 0;
//                  id_ex_linked <= 0;
//                  id_ex_mult <= 0;
//                  id_ex_div <= 0;
//                  id_ex_load <= 0;
//                  id_ex_store <= 0;
//                  id_ex_size <= 0;
//                  id_ex_store_value <= 0;
//                  id_ex_destreg <= 0;
//                  id_ex_desthi <= 0;
//                  id_ex_destlo <= 0;
                end
              `FUNCTION_MFHI:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as MFHI r%d", if_id_addr, if_id_opcode, if_id_rd);
                  id_ex_alu_a <= HI;
                  id_ex_alu_b <= 0;
                  id_ex_alu_func <= `ALU_OP_ADD;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_MTHI:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as MTHI r%d", if_id_addr, if_id_opcode, if_id_rs);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= 0;
                  id_ex_alu_func <= `ALU_OP_ADD;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= 0;
                  id_ex_desthi <= 1;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_MFLO:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as MFLO r%d", if_id_addr, if_id_opcode, if_id_rd);
                  id_ex_alu_a <= LO;
                  id_ex_alu_b <= 0;
                  id_ex_alu_func <= `ALU_OP_ADD;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_MTLO:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as MTLO r%d", if_id_addr, if_id_opcode, if_id_rs);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= 0;
                  id_ex_alu_func <= `ALU_OP_ADD;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= 0;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 1;
                end
              `FUNCTION_MULT:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as MULT r%d, r%d", if_id_addr, if_id_opcode, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_MULT;
                  id_ex_alu_signed <= 1;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 1;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= 0;
                  id_ex_desthi <= 1;
                  id_ex_destlo <= 1;
                  mul_req_o <= !mul_req_o;  // Toggle the ABP request
                end
              `FUNCTION_MULTU:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as MULTU r%d, r%d", if_id_addr, if_id_opcode, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_MULT;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 1;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= 0;
                  id_ex_desthi <= 1;
                  id_ex_destlo <= 1;
                  mul_req_o <= !mul_req_o;  // Toggle the ABP request
                end
              `FUNCTION_DIV:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as DIV r%d, r%d", if_id_addr, if_id_opcode, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_DIV;
                  id_ex_alu_signed <= 1;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 1;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= 0;
                  id_ex_desthi <= 1;
                  id_ex_destlo <= 1;
                  div_req_o <= !div_req_o;  // Toggle the ABP request
                end
              `FUNCTION_DIVU:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as DIVU r%d, r%d", if_id_addr, if_id_opcode, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_DIV;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 1;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= 0;
                  id_ex_desthi <= 1;
                  id_ex_destlo <= 1;
                  div_req_o <= !div_req_o;  // Toggle the ABP request
                end
              `FUNCTION_ADD:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as ADD r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_ADD;
                  id_ex_alu_signed <= 1;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_ADDU:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as ADDU r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_ADD;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_SUB:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SUB r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_SUB;
                  id_ex_alu_signed <= 1;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_SUBU:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SUBU r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_SUB;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_AND:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as AND r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_AND;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_OR:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as OR r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_OR;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_XOR:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as XOR r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_XOR;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_NOR:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as NOR r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_NOR;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_SLT:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SLT r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_SLT;
                  id_ex_alu_signed <= 1;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `FUNCTION_SLTU:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as SLTU r%d, r%d, r%d", if_id_addr, if_id_opcode, if_id_rd, if_id_rs, if_id_rt);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= GPR[if_id_rt];
                  id_ex_alu_func <= `ALU_OP_SLT;
                  id_ex_alu_signed <= 0;
                  id_ex_branch <= 0;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
            endcase
          `OPCODE_BCOND:
            case(if_id_rt)
              `BCOND_BLTZ:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as BLTZ r%d, %h", if_id_addr, if_id_opcode, if_id_rs, if_id_imm_signext);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= 0;
                  id_ex_alu_func <= `ALU_OP_SLT;
                  id_ex_alu_signed <= 1;
                  id_ex_branch <= 1;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `BCOND_BGEZ:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as BGEZ r%d, %h", if_id_addr, if_id_opcode, if_id_rs, if_id_imm_signext);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= 0;
                  id_ex_alu_func <= `ALU_OP_SGE;
                  id_ex_alu_signed <= 1;
                  id_ex_branch <= 1;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 0;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= if_id_rd;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `BCOND_BLTZAL:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as BLTZAL r%d, %h", if_id_addr, if_id_opcode, if_id_rs, if_id_imm_signext);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= 0;
                  id_ex_alu_func <= `ALU_OP_SLT;
                  id_ex_alu_signed <= 1;
                  id_ex_branch <= 1;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 1;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= 31;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
              `BCOND_BGEZAL:
                begin
                  $display("INFO: CPU(%m)-ID: Decoded instruction @ADDR=%X w/OPCODE=%X as BGEZAL r%d, %h", if_id_addr, if_id_opcode, if_id_rs, if_id_imm_signext);
                  id_ex_alu_a <= GPR[if_id_rs];
                  id_ex_alu_b <= 0;
                  id_ex_alu_func <=`ALU_OP_SGE;
                  id_ex_alu_signed <= 1;
                  id_ex_branch <= 1;
                  id_ex_jump <= 0;
                  id_ex_jr <= 0;
                  id_ex_linked <= 1;
                  id_ex_mult <= 0;
	          id_ex_div <= 0;
                  id_ex_load <= 0;
                  id_ex_store <= 0;
                  id_ex_size <= 0;
                  id_ex_store_value <= 0;
                  id_ex_destreg <= 31;
                  id_ex_desthi <= 0;
                  id_ex_destlo <= 0;
                end
            endcase

        endcase

      end

      /*
       * Pipeline Stage 3: Execute (EX)
       * 
       * READ/WRITE:
       * - read the ID/EX latch
       * - write the EX/MEM latch
       * 
       * DESCRIPTION:
       * This stage takes the result from the ALU and put it in the proper latch.
       * Please note that assignments to ALU inputs are done outside since they're wires.
       */

      if(ex_stall) begin
      
        if(mem_stall) begin
          $display("INFO: CPU(%m)-EX: Execution stalled and latch kept");
        end else begin
          $display("INFO: CPU(%m)-EX: Execution stalled and bubble inserted");
          ex_mem_opcode <= `BUBBLE;
          ex_mem_addr <= id_ex_addr;
          ex_mem_addrnext <= 0;
          ex_mem_destreg <= 0;
          ex_mem_desthi <= 0;
          ex_mem_destlo <= 0;
        end

      end else begin
      
        // If not stalled propagate values to next latches
        ex_mem_opcode      <= id_ex_opcode;
        ex_mem_addr        <= id_ex_addr;
        ex_mem_addrnext    <= id_ex_addrnext;
        ex_mem_addrjump    <= id_ex_addrjump;
        ex_mem_addrbranch  <= id_ex_addrbranch;
        ex_mem_branch      <= id_ex_branch;
        ex_mem_jump        <= id_ex_jump;
        ex_mem_jr          <= id_ex_jr;
        ex_mem_linked      <= id_ex_linked;
        ex_mem_mult        <= id_ex_mult;
        ex_mem_div         <= id_ex_div;
        ex_mem_load        <= id_ex_load;
        ex_mem_store       <= id_ex_store;
        ex_mem_size        <= id_ex_size;
        ex_mem_destold     <= id_ex_store_value;	 
        ex_mem_destreg     <= id_ex_destreg;
        ex_mem_desthi      <= id_ex_desthi;
        ex_mem_destlo      <= id_ex_destlo;

        // Choose the output from ALU, Multiplier or Divider
        if(id_ex_mult) begin
          ex_mem_aluout <= mul_product_i;
	  ex_mem_carry <= 1'b0;
	end else if(id_ex_div) begin
          ex_mem_aluout <= { div_remainder_i, div_quotient_i };
	  ex_mem_carry <= 1'b0;
        end else begin
          ex_mem_aluout <= {32'b0, alu_result_i[31:0]};
          ex_mem_carry <= alu_result_i[32];
	end

        // Handle all supported store sizes
        if(id_ex_store) begin
          $display("INFO: CPU(%m)-EX: Execution of Store instruction @ADDR=%X w/OPCODE=%X started to STORE_ADDR=%X w/STORE_DATA=%X", id_ex_addr, id_ex_opcode, alu_result_i, id_ex_store_value);
          case(id_ex_size)
            `SIZE_WORD: begin
              ex_mem_store_value <= id_ex_store_value;
              ex_mem_store_sel <= 4'b1111;
            end
            `SIZE_HALF: begin
              if(alu_result_i[1]==0) begin
                ex_mem_store_value <= {{16'b0}, id_ex_store_value[15:0]};
                ex_mem_store_sel <= 4'b0011;
              end else begin
                ex_mem_store_value <= {id_ex_store_value[15:0], {16'b0}};
                ex_mem_store_sel <= 4'b1100;
              end
            end
            `SIZE_BYTE: begin
              case(alu_result_i[1:0])
                2'b00: begin
                  ex_mem_store_value <= {{24'b0}, id_ex_store_value[7:0]};
                  ex_mem_store_sel <= 4'b0001;
                end
                2'b01: begin
                  ex_mem_store_value <= {{16'b0}, id_ex_store_value[7:0],{8'b0}};
                  ex_mem_store_sel <= 4'b0010;
                end
                2'b10: begin
                  ex_mem_store_value <= {{8'b0}, id_ex_store_value[7:0],{16'b0}};
                  ex_mem_store_sel <= 4'b0100;
                end
                2'b11: begin
                  ex_mem_store_value <= {id_ex_store_value[7:0], {24'b0}};
                  ex_mem_store_sel <= 4'b1000;
                end
              endcase
            end
	    `SIZE_LEFT: begin
              case(alu_result_i[1:0])
                2'b00: begin
                  ex_mem_store_value <= {24'b0, id_ex_store_value[31:24]};
                  ex_mem_store_sel <= 4'b0001;
		end
                2'b01: begin
                  ex_mem_store_value <= {16'b0, id_ex_store_value[31:16]};
                  ex_mem_store_sel <= 4'b0011;
		end
                2'b10: begin
                  ex_mem_store_value <= {8'b0, id_ex_store_value[31:8]};
                  ex_mem_store_sel <= 4'b0111;
		end
                2'b11: begin
                  ex_mem_store_value <= id_ex_store_value;
                  ex_mem_store_sel <= 4'b1111;
		end
              endcase
            end
	    `SIZE_RIGHT: begin
              case(alu_result_i[1:0])
                2'b00: begin
                  ex_mem_store_value <= id_ex_store_value;
                  ex_mem_store_sel <= 4'b1111;
		end
                2'b01: begin
                  ex_mem_store_value <= {id_ex_store_value[23:0], 8'b0};
                  ex_mem_store_sel <= 4'b1110;
		end
                2'b10: begin
                  ex_mem_store_value <= {id_ex_store_value[15:0], 16'b0};
                  ex_mem_store_sel <= 4'b1100;
		end
                2'b11: begin
                  ex_mem_store_value <= {id_ex_store_value[7:0], 24'b0};
                  ex_mem_store_sel <= 4'b1000;
		end
              endcase
            end
          endcase

        // Not a store
        end else begin
          $display("INFO: CPU(%m)-EX: Execution of instruction @ADDR=%X w/OPCODE=%X gave ALU result %X", id_ex_addr, id_ex_opcode, alu_result_i);
        end

      end

      /*
       * Pipeline Stage 4: Memory access (MEM)
       * 
       * READ/WRITE:
       * - read the EX/MEM latch
       * - read or write memory
       * - write the MEM/WB latch
       * 
       * DESCRIPTION:
       * This stage perform accesses to memory to read/write the data during
       * the load/store operations.
       */

      if(mem_stall) begin

        $display("INFO: CPU(%m)-MEM: Memory stalled");

      end else begin

        mem_wb_opcode     <= ex_mem_opcode;
        mem_wb_addr       <= ex_mem_addr;
        mem_wb_addrnext   <= ex_mem_addrnext;
        mem_wb_destreg    <= ex_mem_destreg;
        mem_wb_desthi     <= ex_mem_desthi;
        mem_wb_destlo     <= ex_mem_destlo;

        // Handle all supported load sizes
        if(ex_mem_load) begin

          $display("INFO: CPU(%m)-MEM: Loading value %X", dmem_data_i);
          mem_wb_value[63:32] <= 32'b0;
	  case(ex_mem_size)
	    `SIZE_WORD: begin
              mem_wb_value[31:0] <= dmem_data_i;
	    end
	    `SIZE_HALF: begin
	      if(ex_mem_aluout[1]==0) mem_wb_value[31:0] <= {{16{dmem_data_i[15]}}, dmem_data_i[15:0]};
	      else mem_wb_value[31:0] <= {{16{dmem_data_i[31]}}, dmem_data_i[31:16]};
	    end
	    `SIZE_BYTE: begin
	      case(ex_mem_aluout[1:0])
		2'b00: mem_wb_value[31:0] <= {{24{dmem_data_i[7]}},  dmem_data_i[7:0]};
		2'b01: mem_wb_value[31:0] <= {{24{dmem_data_i[15]}}, dmem_data_i[15:8]};
		2'b10: mem_wb_value[31:0] <= {{24{dmem_data_i[23]}}, dmem_data_i[23:16]};
		2'b11: mem_wb_value[31:0] <= {{24{dmem_data_i[31]}}, dmem_data_i[31:24]};		
	      endcase	       
	    end
	    `SIZE_LEFT: begin
	      case(ex_mem_aluout[1:0])
		2'b00: mem_wb_value[31:0] <= {dmem_data_i[7:0],  ex_mem_destold[23:0]};
		2'b01: mem_wb_value[31:0] <= {dmem_data_i[15:0], ex_mem_destold[15:0]};
		2'b10: mem_wb_value[31:0] <= {dmem_data_i[23:0], ex_mem_destold[7:0]};
		2'b11: mem_wb_value[31:0] <= dmem_data_i;
	      endcase
	    end
	    `SIZE_RIGHT: begin
	      case(ex_mem_aluout[1:0])
		2'b00: mem_wb_value[31:0] <= dmem_data_i;
		2'b01: mem_wb_value[31:0] <= {ex_mem_destold[31:24], dmem_data_i[31:8]};
		2'b10: mem_wb_value[31:0] <= {ex_mem_destold[31:16], dmem_data_i[31:16]};
		2'b11: mem_wb_value[31:0] <= {ex_mem_destold[31:8],  dmem_data_i[31:24]};
	      endcase
	    end
          endcase	    

        // For multiplications and divisions the result is 64-bit wide
        end else if (ex_mem_desthi && ex_mem_destlo) begin            			

          $display("INFO: CPU(%m)-MEM: Propagating value %X", ex_mem_aluout);
          mem_wb_value[63:32] <= ex_mem_aluout[63:32];
          mem_wb_value[31:0] <= ex_mem_aluout[31:0];	

        // For MTHI instruction we must move the value to the correct side of the bus
        end else if (ex_mem_desthi) begin

          $display("INFO: CPU(%m)-MEM: Propagating value %X", ex_mem_aluout);
          mem_wb_value[63:32] <= ex_mem_aluout[31:0];
          mem_wb_value[31:0] <= 32'b0;

        // The default is working with 32-bit values
        end else begin

          $display("INFO: CPU(%m)-MEM: Propagating value %X", ex_mem_aluout);
          mem_wb_value[63:32] <= 32'b0;
          mem_wb_value[31:0] <= ex_mem_aluout[31:0];

        end

      end

      /*
       * Pipeline Stage 5: Write Back (WB)
       * 
       * READ/WRITE:
       * - read the MEM/WB latch
       * - write the register file
       * 
       * DESCRIPTION:
       * This stage writes back the result into the proper register (GPR, HI, LO).
       */

      if(wb_stall) begin

        $display("INFO: CPU(%m)-WB: Write-Back stalled");

      end else begin

        // GPRs
        if(mem_wb_destreg!=0) begin
          $display("INFO: CPU(%m)-WB: Writing Back GPR[%d]=%X", mem_wb_destreg, mem_wb_value[31:0]);
          GPR[mem_wb_destreg] <= mem_wb_value[31:0];
        end

        // HI
        if(mem_wb_desthi) begin
          $display("INFO: CPU(%m)-WB: Writing Back HI=%X", mem_wb_value[63:32]);
          HI <= mem_wb_value[63:32];
        end

        // LO
        if(mem_wb_destlo) begin
          $display("INFO: CPU(%m)-WB: Writing Back LO=%X", mem_wb_value[31:0]);
          LO <= mem_wb_value[31:0];
        end

        // SysCon
        if(mem_wb_destsyscon!=0) begin
          $display("INFO: CPU(%m)-WB: Writing Back SysCon[%d]=%X", mem_wb_destsyscon, mem_wb_value[31:0]);
          SysCon[mem_wb_destsyscon] <= mem_wb_value[31:0];
        end
	 
        // Idle
        if(mem_wb_destreg==0 & mem_wb_desthi==0 & mem_wb_destlo==0)
          $display("INFO: CPU(%m)-WB: Write-Back has nothing to do");

      end

      // Display register file at each raising edge
      $display("INFO: CPU(%m)-Regs: R00=%X R01=%X R02=%X R03=%X R04=%X R05=%X R06=%X R07=%X",
        GPR[0], GPR[1], GPR[2], GPR[3], GPR[4], GPR[5], GPR[6], GPR[7]);
      $display("INFO: CPU(%m)-Regs: R08=%X R09=%X R10=%X R11=%X R12=%X R13=%X R14=%X R15=%X",
        GPR[8], GPR[9], GPR[10], GPR[11], GPR[12], GPR[13], GPR[14], GPR[15]);
      $display("INFO: CPU(%m)-Regs: R16=%X R17=%X R18=%X R19=%X R20=%X R21=%X R22=%X R23=%X",
        GPR[16], GPR[17], GPR[18], GPR[19], GPR[20], GPR[21], GPR[22], GPR[23]);
      $display("INFO: CPU(%m)-Regs: R24=%X R25=%X R26=%X R27=%X R28=%X R29=%X R30=%X R31=%X",
        GPR[24], GPR[25], GPR[26], GPR[27], GPR[28], GPR[29], GPR[30], GPR[31]);
      $display("INFO: CPU(%m)-Regs: PC=%X HI=%X LO=%X",
        PC, HI, LO);

    end
  end

endmodule

