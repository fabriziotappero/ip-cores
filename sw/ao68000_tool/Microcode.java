/*
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package ao68000_tool;

public class Microcode {
    static void microcode(Parser p) throws Exception {

        p.label("reset");
        
        p       .GROUP_0_FLAG_SET();

                // wait for instruction prefetch
        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

                // move SSP and PC from prefetch
        p       .AN_INPUT_FROM_PREFETCH_IR().AN_ADDRESS_SSP().AN_WRITE_ENABLE_SET()
                .PC_FROM_PREFETCH_IR()
                // jump to main loop
                .BRANCH_procedure().PROCEDURE_jump_to_main_loop();
                

        p.label("MICROPC_ADDRESS_BUS_TRAP");

                // save trap number and bus cycle extended information
        p       .TRAP_FROM_INTERRUPT()
                .OP2_MOVE_ADDRESS_BUS_INFO()
                // clear internal flags
                .READ_MODIFY_WRITE_FLAG_CLEAR()
                .INSTRUCTION_FLAG_SET()
                .DO_READ_FLAG_CLEAR()
                .DO_WRITE_FLAG_CLEAR()
                .DO_INTERRUPT_FLAG_CLEAR()

                // check if group_0_flag already active
                .BRANCH_group_0_flag().offset("address_bus_trap_group_0_flag_cleared");

                        // if group_0_flag active: block processor
        p               .DO_BLOCKED_FLAG_SET()
                        .BRANCH_procedure()
                        .PROCEDURE_wait_finished();

                // continue processing trap
        p       .label("address_bus_trap_group_0_flag_cleared");
        p       .GROUP_0_FLAG_SET();

        //--
                // move PC to OP1
        p       .OP1_FROM_PC();
                // move OP1 to result
        p       .ALU_SIMPLE_MOVE()
                // move SR to OP1
                .OP1_FROM_SR();

                // set supervisor, clear trace
        p       .ALU_SR_SET_TRAP();

        //--
                // stack PC
        p       .SIZE_LONG().EA_REG_3b111().EA_MOD_PREDEC().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea()
                // move SR to result
                .ALU_SIMPLE_MOVE()
                // move IR to OP1
                .OP1_FROM_IR();

                // stack SR
        p       .SIZE_WORD().EA_REG_3b111().EA_MOD_PREDEC().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea()
                // move IR to result
                .ALU_SIMPLE_MOVE()
                // move fault address to OP1
                .OP1_FROM_FAULT_ADDRESS();

        //--
                // stack IR
        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea()
                // move fault address to result
                .ALU_SIMPLE_MOVE()
                // move bus cycle info stored in OP2 to OP1
                .OP1_FROM_OP2();

                // stack fault address
        p       .SIZE_LONG().EA_REG_3b111().EA_MOD_PREDEC().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea()
                // move bus cycle info from OP1 to result
                .ALU_SIMPLE_MOVE();

                // stack bus cycle info
        p       .SIZE_WORD().EA_REG_3b111().EA_MOD_PREDEC().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        //--
                // load PC from exception vector table
        p       .ADDRESS_FROM_TRAP()
                .SIZE_LONG().EA_REG_3b111().EA_MOD_PREDEC().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();
        p       .ALU_SIMPLE_MOVE();

                // wait for instruction prefetch
        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p       .PC_FROM_RESULT();

                // wait one cycle to check loaded PC: is it even ?
        p       .OP1_FROM_OP2();
        //--
                // jump to main loop
        p       .BRANCH_procedure().PROCEDURE_jump_to_main_loop();

        p.label("MICROPC_TRAP_ENTRY");

        //--
                // move PC to OP1
        p       .OP1_FROM_PC();
                // move OP1 to result
        p       .ALU_SIMPLE_MOVE()
                // move SR to OP1
                .OP1_FROM_SR();

                // set supervisor, clear trace
        p       .ALU_SR_SET_TRAP();

        //--
                // stack PC
        p       .SIZE_LONG().EA_REG_3b111().EA_MOD_PREDEC().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea()
                // move SR to result
                .ALU_SIMPLE_MOVE();

                // stack SR
        p       .SIZE_WORD().EA_REG_3b111().EA_MOD_PREDEC().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        //--
                // load PC from exception vector table
        p       .ADDRESS_FROM_TRAP()
                .SIZE_LONG().EA_REG_3b111().EA_MOD_PREDEC().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();
        p       .ALU_SIMPLE_MOVE();

                // wait for instruction prefetch
        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p       .PC_FROM_RESULT();

                // wait one cycle to check loaded PC: is it even ?
        p       .OP1_FROM_OP2();
        
        //--
                // return
        p       .BRANCH_procedure().PROCEDURE_return();
        

        p.label("MICROPC_MAIN_LOOP");

                // check if stop flag set and wait for valid prefetch and decode instruction
                // execute instruction, instruction generated trap possible
        p       .BRANCH_stop_flag_wait_ir_decode().offset("main_loop_after_execution")
                // clear read-modify-write flag always
                .READ_MODIFY_WRITE_FLAG_CLEAR()

                // save trace flag, only when valid prefetch and valid instruction and stop flag cleared
                .TRACE_FLAG_COPY_WHEN_NO_STOP()

                // save first instruction word, only when prefetch valid and stop flag cleared
                .IR_LOAD_WHEN_PREFETCH_VALID()
                // clear group 0 flag, only when valid prefetch and stop flag cleared
                .GROUP_0_FLAG_CLEAR_WHEN_VALID_PREFETCH()

                // increment PC by 2, only when valid prefetch and valid instruction and stop flag cleared
                .PC_INCR_BY_2_IN_MAIN_LOOP()
                // clear instruction flag, only when valid prefetch and valid instruction and stop flag cleared
                .INSTRUCTION_FLAG_CLEAR_IN_MAIN_LOOP();
                
                        // call trap
        p               .TRAP_FROM_DECODER()
                        .INSTRUCTION_FLAG_SET()
                        .BRANCH_procedure().PROCEDURE_call_trap();
                                // after trap jump to main loop
        p                       .BRANCH_procedure().PROCEDURE_jump_to_main_loop();

                // jump here after execution
        p       .label("main_loop_after_execution");

                // check if trace flag set and check external interrupt
        p       .BRANCH_trace_flag_and_interrupt().offset("main_loop_interrupt")
                // set instruction flag, always
                .INSTRUCTION_FLAG_SET();
        
                        // call trap
        p               .TRAP_TRACE()
                        .STOP_FLAG_CLEAR()
                        .BRANCH_procedure().PROCEDURE_call_trap();
                        // after trap continue

                // jump here if trace flag not set and interupt pending
        p       .label("main_loop_interrupt");

                // check external interrupt
        p       .DO_INTERRUPT_FLAG_SET_IF_ACTIVE()
                .BRANCH_procedure().PROCEDURE_interrupt_mask();

        p               .BRANCH_procedure().PROCEDURE_wait_finished()
                        .ALU_SR_SET_INTERRUPT();

        p               .DO_INTERRUPT_FLAG_CLEAR()
                        .TRAP_FROM_INTERRUPT()
                        .STOP_FLAG_CLEAR()
                        .BRANCH_procedure().PROCEDURE_call_trap();

                        // after trap jump to main loop
                        p       .BRANCH_procedure().PROCEDURE_jump_to_main_loop();

        // **************************************************************** EA

        // load ea: to address register

        // (An), (An)+:
        p.label("MICROPC_LOAD_EA_An");
        p.label("MICROPC_LOAD_EA_An_plus");

        p       .ADDRESS_FROM_AN_OUTPUT()
                .BRANCH_procedure().PROCEDURE_return();

        // -(An):
        p.label("MICROPC_LOAD_EA_minus_An");

        p       .ADDRESS_FROM_AN_OUTPUT();
        p       .ADDRESS_DECR_BY_SIZE()
                .BRANCH_procedure().PROCEDURE_return();

        // (d16, An):
        p.label("MICROPC_LOAD_EA_d16_An");

        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();
        
        p       .INDEX_0()
                .OFFSET_IMM_16()
                .PC_INCR_BY_2()
                .ADDRESS_FROM_AN_OUTPUT();

        p       .ADDRESS_FROM_BASE_INDEX_OFFSET()
                .BRANCH_procedure().PROCEDURE_return();

        // (d8, An, Xn):
        p.label("MICROPC_LOAD_EA_d8_An_Xn");

        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid()
                .ADDRESS_FROM_AN_OUTPUT();

        p       .AN_ADDRESS_FROM_EXTENDED()
                .DN_ADDRESS_FROM_EXTENDED()
                .OFFSET_IMM_8();

        p       .AN_ADDRESS_FROM_EXTENDED()
                .INDEX_LOAD_EXTENDED()
                .PC_INCR_BY_2();

        p       .ADDRESS_FROM_BASE_INDEX_OFFSET()
                .BRANCH_procedure().PROCEDURE_return();

        // (xxx).W:
        p.label("MICROPC_LOAD_EA_xxx_W");

        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p       .ADDRESS_FROM_IMM_16()
                .PC_INCR_BY_2()
                .BRANCH_procedure().PROCEDURE_return();

        // (xxx).L:
        p.label("MICROPC_LOAD_EA_xxx_L");

        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p       .ADDRESS_FROM_IMM_32()
                .PC_INCR_BY_4()
                .BRANCH_procedure().PROCEDURE_return();

        // (d16, PC):
        p.label("MICROPC_LOAD_EA_d16_PC");

        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p       .INDEX_0()
                .OFFSET_IMM_16();

        p       .ADDRESS_FROM_PC_INDEX_OFFSET()
                .PC_INCR_BY_2()
                .BRANCH_procedure().PROCEDURE_return();
                
        // (d8, PC, Xn):
        p.label("MICROPC_LOAD_EA_d8_PC_Xn");

        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p       .AN_ADDRESS_FROM_EXTENDED()
                .DN_ADDRESS_FROM_EXTENDED()
                .OFFSET_IMM_8();

        p       .AN_ADDRESS_FROM_EXTENDED()
                .INDEX_LOAD_EXTENDED();

        p       .ADDRESS_FROM_PC_INDEX_OFFSET()
                .PC_INCR_BY_2()
                .BRANCH_procedure().PROCEDURE_return();
        
        p.label("MICROPC_LOAD_EA_illegal_command");

                // call trap
        p       .TRAP_ILLEGAL_INSTR()
                .BRANCH_procedure().PROCEDURE_call_trap();
                // after trap jump to main loop
        p       .BRANCH_procedure().PROCEDURE_jump_to_main_loop();

        
        // perform_ea_read: memory, Dn,An,immediate

        // Dn:
        p.label("MICROPC_PERFORM_EA_READ_Dn");

        p       .OP1_FROM_DN()
                .BRANCH_procedure().PROCEDURE_return();

        // An:
        p.label("MICROPC_PERFORM_EA_READ_An");

        p       .OP1_FROM_AN()
                .BRANCH_procedure().PROCEDURE_return();

        // immediate
        p.label("MICROPC_PERFORM_EA_READ_imm");

        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p       .OP1_FROM_IMMEDIATE()
                .PC_INCR_BY_SIZE()
                .BRANCH_procedure().PROCEDURE_return();

        // memory
        p.label("MICROPC_PERFORM_EA_READ_memory");

        p       .DO_READ_FLAG_SET()
                .BRANCH_procedure().PROCEDURE_wait_finished();

        p       .DO_READ_FLAG_CLEAR()
                .OP1_FROM_DATA()
                .BRANCH_procedure().PROCEDURE_return();
        
        // perform ea write: memory, Dn,An
        // size of operand matters: select in memory write
        
        // Dn:
        p.label("MICROPC_PERFORM_EA_WRITE_Dn");

        p       .DN_WRITE_ENABLE_SET()
                .BRANCH_procedure().PROCEDURE_return();
        

        // An:
        p.label("MICROPC_PERFORM_EA_WRITE_An");

        p       .AN_WRITE_ENABLE_SET()
                .BRANCH_procedure().PROCEDURE_return();

        // memory:
        p.label("MICROPC_PERFORM_EA_WRITE_memory");

        p       .DATA_WRITE_FROM_RESULT()
                .DO_WRITE_FLAG_SET()
                .BRANCH_procedure().PROCEDURE_wait_finished();

        p       .DO_WRITE_FLAG_CLEAR()
                .BRANCH_procedure().PROCEDURE_return();

        // save ea: (An)+,-(An)

        // (An)+:
        p.label("MICROPC_SAVE_EA_An_plus");

        p       .ADDRESS_INCR_BY_SIZE();

        p       .AN_INPUT_FROM_ADDRESS()
                .AN_WRITE_ENABLE_SET()
                .BRANCH_procedure().PROCEDURE_return();

        // -(An)
        p.label("MICROPC_SAVE_EA_minus_An");

        p       .AN_INPUT_FROM_ADDRESS()
                .AN_WRITE_ENABLE_SET()
                .BRANCH_procedure().PROCEDURE_return();

        // **************************************************************** Instructions

        p.label("MICROPC_MOVEP_memory_to_register");

        p       .SIZE_BYTE().EA_REG_IR_2_0().EA_MOD_INDIRECTOFFSET().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_read();

        p       .ALU_MOVEP_M2R_1()
                .ADDRESS_INCR_BY_2()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_MOVEP_M2R_2()
                .ADDRESS_INCR_BY_2()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_MOVEP_M2R_3()
                .ADDRESS_INCR_BY_2()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_MOVEP_M2R_4()
                .SIZE_1().EA_REG_IR_11_9().EA_MOD_DN().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_MOVEP_register_to_memory");

        p       .SIZE_1_PLUS().EA_REG_IR_11_9().EA_MOD_DN().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .SIZE_BYTE().EA_REG_IR_2_0().EA_MOD_INDIRECTOFFSET().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_load_ea();

        p       .ALU_MOVEP_R2M_1()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .ADDRESS_INCR_BY_2()
                .ALU_MOVEP_R2M_2()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_movep_16().offset("movep_16");

        p               .ADDRESS_INCR_BY_2()
                        .ALU_MOVEP_R2M_3()
                        .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p               .ADDRESS_INCR_BY_2()
                        .ALU_MOVEP_R2M_4()
                        .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

                // jump here if word operation
        p       .label("movep_16");

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_MOVEM_memory_to_register");

        p       .SIZE_WORD().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();

        p       .OP1_FROM_IMMEDIATE()
                .PC_INCR_BY_SIZE();

        p       .MOVEM_REG_FROM_OP1()
                .MOVEM_MODREG_LOAD_0()
                .MOVEM_LOOP_LOAD_0()
                .SIZE_2().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_CONTROL_POSTINC();

        p       .BRANCH_procedure().PROCEDURE_call_load_ea();

                // push current micro pc on stack
        p       .BRANCH_procedure().PROCEDURE_push_micropc();

                // check if loop finished
        p       .BRANCH_movem_loop().offset("movem_memory_to_register_loop");

                        // check if operation on register required
        p               .BRANCH_movem_reg().offset("movem_memory_to_register_reg");

        p                       .SIZE_2().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_CONTROL_POSTINC();
        p                       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p                       .ALU_SIGN_EXTEND()
                                .ADDRESS_INCR_BY_SIZE()
                                .SIZE_LONG().EA_REG_MOVEM_REG_2_0().EA_MOD_MOVEM_MOD_5_3().EA_TYPE_DN_AN();
        p                       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

                        // jump here if operation on register not required
        p               .label("movem_memory_to_register_reg");

        p               .MOVEM_MODREG_INCR_BY_1()
                        .MOVEM_REG_SHIFT_RIGHT()
                        .MOVEM_LOOP_INCR_BY_1()
                        .BRANCH_procedure().PROCEDURE_return();

                // jump here if loop finished
        p       .label("movem_memory_to_register_loop");

        p       .BRANCH_procedure().PROCEDURE_pop_micropc()
                .SIZE_2().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_CONTROL_POSTINC();

        p       .BRANCH_procedure().PROCEDURE_call_save_ea()
                .ADDRESS_DECR_BY_SIZE();

        p       .BRANCH_procedure().PROCEDURE_return();
        
        p.label("MICROPC_MOVEM_register_to_memory_predecrement");

        p       .SIZE_WORD().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();

        p       .OP1_FROM_IMMEDIATE()
                .PC_INCR_BY_SIZE();
        
        p       .MOVEM_REG_FROM_OP1()
                .MOVEM_MODREG_LOAD_6b001111()
                .MOVEM_LOOP_LOAD_0()
                .SIZE_2().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_CONTROLALTER_PREDEC();

        p       .BRANCH_procedure().PROCEDURE_call_load_ea();

                // push current micro pc on stack
        p       .BRANCH_procedure().PROCEDURE_push_micropc();

                 // check if loop finished
        p       .BRANCH_movem_loop().offset("movem_register_to_memory_predecrement_loop");

                        // check if operation on register required
        p               .BRANCH_movem_reg().offset("movem_register_to_memory_predecrement_reg");

        p                       .SIZE_2().EA_REG_MOVEM_REG_2_0().EA_MOD_MOVEM_MOD_5_3().EA_TYPE_DN_AN();
        p                       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p                       .ALU_SIGN_EXTEND()
                                .SIZE_2().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_CONTROLALTER_PREDEC();
        p                       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p                       .ADDRESS_DECR_BY_SIZE();

                        // jump here if operation on register not required
        p               .label("movem_register_to_memory_predecrement_reg");

        p               .MOVEM_MODREG_DECR_BY_1()
                        .MOVEM_REG_SHIFT_RIGHT()
                        .MOVEM_LOOP_INCR_BY_1()
                        .BRANCH_procedure().PROCEDURE_return();

                // jump here if loop finished
        p       .label("movem_register_to_memory_predecrement_loop");

        p       .BRANCH_procedure().PROCEDURE_pop_micropc()
                .ADDRESS_INCR_BY_SIZE();

        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_MOVEM_register_to_memory_control");

        p       .SIZE_WORD().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();

        p       .OP1_FROM_IMMEDIATE()
                .PC_INCR_BY_SIZE();

        p       .MOVEM_REG_FROM_OP1()
                .MOVEM_MODREG_LOAD_0()
                .MOVEM_LOOP_LOAD_0()
                .SIZE_2().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_CONTROLALTER_PREDEC();

        p       .BRANCH_procedure().PROCEDURE_call_load_ea();

                // push current micro pc on stack
        p       .BRANCH_procedure().PROCEDURE_push_micropc();

                 // check if loop finished
        p       .BRANCH_movem_loop().offset("movem_register_to_memory_control_loop");

                        // check if operation on register required
        p               .BRANCH_movem_reg().offset("movem_register_to_memory_control_reg");

        p                       .SIZE_2().EA_REG_MOVEM_REG_2_0().EA_MOD_MOVEM_MOD_5_3().EA_TYPE_DN_AN();
        p                       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p                       .ALU_SIGN_EXTEND()
                                .SIZE_2().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_CONTROLALTER_PREDEC();
        p                       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p                       .ADDRESS_INCR_BY_SIZE();

                        // jump here if operation on register not required
        p               .label("movem_register_to_memory_control_reg");

        p               .MOVEM_MODREG_INCR_BY_1()
                        .MOVEM_REG_SHIFT_RIGHT()
                        .MOVEM_LOOP_INCR_BY_1()
                        .BRANCH_procedure().PROCEDURE_return();

                // jump here if loop finished
        p       .label("movem_register_to_memory_control_loop");

        p       .BRANCH_procedure().PROCEDURE_pop_micropc();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_LEA");

        p       .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_CONTROL();
        p       .BRANCH_procedure().PROCEDURE_call_load_ea();

        p       .OP1_FROM_ADDRESS();

        p       .ALU_SIMPLE_MOVE()
                .SIZE_LONG().EA_REG_IR_11_9().EA_MOD_AN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_PEA");

        p       .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_CONTROL();
        p       .BRANCH_procedure().PROCEDURE_call_load_ea();

        p       .OP1_FROM_ADDRESS();

        p       .ALU_SIMPLE_MOVE()
                .SIZE_LONG().EA_REG_3b111().EA_MOD_PREDEC().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_load_ea();

        p       .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_ANDI_EORI_ORI_ADDI_SUBI");
//+++
        p       .SIZE_3().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();

        p       .OP1_FROM_IMMEDIATE()
                .PC_INCR_BY_SIZE()
                
                .SIZE_3().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATAALTER();

        p       .OP2_FROM_OP1()
                .BRANCH_procedure().PROCEDURE_call_read();

        p       .ALU_ARITHMETIC_LOGIC()
                .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_ORI_to_CCR_ORI_to_SR_ANDI_to_CCR_ANDI_to_SR_EORI_to_CCR_EORI_to_SR");
//+
        p       .SIZE_3().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();

        p       .OP1_FROM_IMMEDIATE()
                .PC_INCR_BY_SIZE();

        p       .OP2_FROM_OP1()
                .OP1_FROM_SR();

        p       .ALU_ARITHMETIC_LOGIC();

        p       .OP1_FROM_RESULT();

        p       .ALU_MOVE_TO_CCR_SR_RTE_RTR_STOP_LOGIC_TO_CCR_SR()
                .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_CMPI");
//+
        p       .SIZE_3().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();

        p       .OP1_FROM_IMMEDIATE()
                .PC_INCR_BY_SIZE()

                .SIZE_3().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATAALTER();

        p       .OP2_FROM_OP1()
                .BRANCH_procedure().PROCEDURE_call_read();
        
        p       .ALU_ARITHMETIC_LOGIC()
                .BRANCH_procedure().PROCEDURE_call_save_ea();     

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_ABCD_SBCD_ADDX_SUBX");

        p       .SIZE_3().EA_REG_IR_2_0().EA_MOD_DN_PREDEC().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .OP2_FROM_OP1()
                .SIZE_3().EA_REG_IR_11_9().EA_MOD_DN_PREDEC().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_ABCD_SBCD_ADDX_SUBX_prepare();
        p       .ALU_ABCD_SBCD_ADDX_SUBX()
                .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_EXG");

        p       .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DN_AN();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_SIMPLE_MOVE()
                .SIZE_LONG().EA_REG_IR_11_9().EA_MOD_DN_AN_EXG().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .ALU_SIMPLE_MOVE()
                .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DN_AN();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();


        p.label("MICROPC_CMPM");

        p       .SIZE_3().EA_REG_IR_2_0().EA_MOD_POSTINC().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .OP2_FROM_OP1()
                .SIZE_3().EA_REG_IR_11_9().EA_MOD_POSTINC().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_read();

        p       .ALU_ARITHMETIC_LOGIC()
                .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_all_immediate_register");

        p       .SIZE_3().EA_REG_IR_11_9().EA_MOD_DN().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .OP2_FROM_OP1()
                .SIZE_3().EA_REG_IR_2_0().EA_MOD_DN().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .OP2_LOAD_COUNT();

        p       .ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_prepare();

        p       .BRANCH_procedure().PROCEDURE_push_micropc();

        p       .BRANCH_operand2().offset("shift_rotate_immediate_loop");

        p               .ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR();
        p               .OP1_FROM_RESULT()
                        .OP2_DECR_BY_1()
                        .BRANCH_procedure().PROCEDURE_return();

                // jump here if loop finished
        p       .label("shift_rotate_immediate_loop");

        p       .BRANCH_procedure().PROCEDURE_pop_micropc();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_all_memory");

        p       .SIZE_WORD().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_MEMORYALTER();

        p       .BRANCH_procedure().PROCEDURE_call_read();

        p       .OP2_LOAD_1();

        p       .ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_prepare();
        p       .ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR();

        p       .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_MOVE");

        p       .SIZE_4().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .ALU_SIMPLE_MOVE()
                .SIZE_4().EA_REG_IR_11_9().EA_MOD_IR_8_6().EA_TYPE_DATAALTER();

        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();
        p       .ALU_MOVE()
                .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_MOVEA");

        p       .SIZE_4().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .ALU_SIGN_EXTEND()
                .SIZE_4().EA_REG_IR_11_9().EA_MOD_AN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_EOR");

        p       .SIZE_3().EA_REG_IR_11_9().EA_MOD_DN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .OP2_FROM_OP1()
                .SIZE_3().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATAALTER();

        p       .BRANCH_procedure().PROCEDURE_call_read();

        p       .ALU_ARITHMETIC_LOGIC()
                .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_ADD_to_mem_SUB_to_mem_AND_to_mem_OR_to_mem");

        p       .SIZE_3().EA_REG_IR_11_9().EA_MOD_DN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .OP2_FROM_OP1()
                .SIZE_3().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_MEMORYALTER();

        p       .BRANCH_procedure().PROCEDURE_call_read();

        p       .ALU_ARITHMETIC_LOGIC()
                .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_ADD_to_Dn_SUB_to_Dn_AND_to_Dn_OR_to_Dn");

        p       .SIZE_3().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .OP2_FROM_OP1()
                .SIZE_3().EA_REG_IR_11_9().EA_MOD_DN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_ARITHMETIC_LOGIC()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_CMP");

        p       .SIZE_3().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .OP2_FROM_OP1()
                .SIZE_3().EA_REG_IR_11_9().EA_MOD_DN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_ARITHMETIC_LOGIC()
                .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_ADDA_SUBA");

        p       .SIZE_5().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .OP2_FROM_OP1()
                .SIZE_LONG().EA_REG_IR_11_9().EA_MOD_AN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_ADDA_SUBA_CMPA_ADDQ_SUBQ()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_CMPA");

        p       .SIZE_5().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .OP2_FROM_OP1()
                .SIZE_LONG().EA_REG_IR_11_9().EA_MOD_AN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_ADDA_SUBA_CMPA_ADDQ_SUBQ()
                .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_CHK");

        p       .SIZE_WORD().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATA();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .OP2_FROM_OP1()
                .SIZE_WORD().EA_REG_IR_11_9().EA_MOD_DN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_CHK();

        p       .BRANCH_alu_signal().offset("chk_no_trap");
        p               .TRAP_CHK()
                        .BRANCH_procedure().PROCEDURE_call_trap();
                        // after return continue
        
                // jump here if no trap
        p       .label("chk_no_trap");

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_MULS_MULU_DIVS_DIVU");

        p       .SIZE_WORD().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATA();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .OP2_FROM_OP1()
                .SIZE_LONG().EA_REG_IR_11_9().EA_MOD_DN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_MULS_MULU_DIVS_DIVU();

        p       .BRANCH_alu_signal().offset("div_no_div_by_zero_trap");
        p               .TRAP_DIV_BY_ZERO()
                        .BRANCH_procedure().PROCEDURE_call_trap();
                        // return after return
        p               .BRANCH_procedure().PROCEDURE_return();

                // jump here if no trap
        p       .label("div_no_div_by_zero_trap");

                // push current micro pc on stack
        p       .BRANCH_procedure().PROCEDURE_push_micropc();

                 // check if operation finished
        p       .BRANCH_alu_mult_div_ready().offset("mult_div_loop");
        p               .BRANCH_procedure().PROCEDURE_return();

                // jump here after first loop finished
        p       .label("mult_div_loop");

        p       .ALU_MULS_MULU_DIVS_DIVU()
                .BRANCH_procedure().PROCEDURE_pop_micropc();

        p       .BRANCH_alu_signal().offset("mult_div_no_overflow");
        p           .BRANCH_procedure().PROCEDURE_return();

                // jump here if overflow
        p       .label("mult_div_no_overflow");
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();
        p       .BRANCH_procedure().PROCEDURE_return();
        
        p.label("MICROPC_MOVEQ");

        p       .OP1_MOVEQ()
                .SIZE_LONG().EA_REG_IR_11_9().EA_MOD_DN().EA_TYPE_ALL();

        p       .ALU_MOVE()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_BCHG_BCLR_BSET_immediate");

        p       .SIZE_BYTE().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();

        p       .OP1_FROM_IMMEDIATE()
                .PC_INCR_BY_SIZE();
        
        p       .OP2_FROM_OP1()
                .SIZE_6().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATAALTER();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        
        p       .ALU_BCHG_BCLR_BSET_BTST()
                .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_BTST_immediate");

        p       .SIZE_BYTE().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();

        p       .OP1_FROM_IMMEDIATE()
                .PC_INCR_BY_SIZE();
        
        p       .OP2_FROM_OP1()
                .SIZE_6().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATA();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .ALU_BCHG_BCLR_BSET_BTST()
                .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_BCHG_BCLR_BSET_register");

        p       .SIZE_6().EA_REG_IR_11_9().EA_MOD_DN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .OP2_FROM_OP1()
                .SIZE_6().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATAALTER();

        p       .BRANCH_procedure().PROCEDURE_call_read();

        p       .ALU_BCHG_BCLR_BSET_BTST()
                .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_BTST_register");

        p       .SIZE_6().EA_REG_IR_11_9().EA_MOD_DN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .OP2_FROM_OP1()
                .SIZE_6().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATA();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .ALU_BCHG_BCLR_BSET_BTST()
                .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_TAS");

        p       .READ_MODIFY_WRITE_FLAG_SET()
                .SIZE_BYTE().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATAALTER();

        p       .BRANCH_procedure().PROCEDURE_call_read();

        p       .ALU_TAS()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .READ_MODIFY_WRITE_FLAG_CLEAR()
                .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_NEGX_CLR_NEG_NOT_NBCD");

        p       .SIZE_3().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATAALTER();

        p       .BRANCH_procedure().PROCEDURE_call_read();

        p       .ALU_NEGX_CLR_NEG_NOT_NBCD_SWAP_EXT()
                .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_SWAP_EXT");

        p       .SIZE_2().EA_REG_IR_2_0().EA_MOD_DN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_NEGX_CLR_NEG_NOT_NBCD_SWAP_EXT()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_TST");

        p       .SIZE_3().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATAALTER();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .ALU_MOVE()
                .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_ADDQ_SUBQ_not_An");

        p       .OP2_ADDQ_SUBQ()
                .SIZE_3().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATAALTER();

        p       .BRANCH_procedure().PROCEDURE_call_read();

        p       .ALU_ARITHMETIC_LOGIC()
                .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_ADDQ_SUBQ_An");

        p       .OP2_ADDQ_SUBQ()
                .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_AN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_ADDA_SUBA_CMPA_ADDQ_SUBQ()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_Scc");

        p       .BRANCH_condition_0().offset("scc_condition_0");
        p               .OP1_LOAD_ONES();

                // jump here if condition is false
        p       .label("scc_condition_0");

        p       .BRANCH_condition_1().offset("scc_condition_1");
        p               .OP1_LOAD_ZEROS();

                // jump here if condition is true
        p       .label("scc_condition_1");

        p       .ALU_SIMPLE_MOVE()
                .SIZE_BYTE().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATAALTER();

        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_Bcc_BRA");

        p       .OP1_FROM_PC();

        p       .ALU_SIMPLE_MOVE()
                .BRANCH_ir().offset("bcc_bra_no_word");

        p               .SIZE_WORD().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                        .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();
        
        p               .OP1_FROM_IMMEDIATE()
                        .PC_INCR_BY_SIZE();

                // jump here if no need to load extra immediate word
        p       .label("bcc_bra_no_word");

        p       .BRANCH_condition_0().offset("bcc_bra_no_branch");

        p               .OP2_FROM_OP1();
        p               .OP2_MOVE_OFFSET()
                        .OP1_FROM_RESULT();

        p               .ALU_SIMPLE_LONG_ADD();

                        // wait for instruction prefetch
        p               .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();
        
        p               .PC_FROM_RESULT();

                        // wait for PC check
        p               .ALU_SIMPLE_MOVE();

                // jump here if no branch
        p       .label("bcc_bra_no_branch");

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_DBcc");

        p       .BRANCH_condition_1().offset("dbcc_condition_true");

        p               .OP2_LOAD_1()
                        .SIZE_WORD().EA_REG_IR_2_0().EA_MOD_DN().EA_TYPE_ALL();

        p               .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p               .ALU_SIMPLE_LONG_SUB();

        p               .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p               .OP1_FROM_PC()
                        .SIZE_WORD().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                        .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();

        p               .BRANCH_result().offset("dbcc_condition_true");

        p                       .OP1_FROM_IMMEDIATE()
                                .ALU_SIMPLE_MOVE();

        p                       .OP2_FROM_OP1()
                                .OP1_FROM_RESULT();

        p                       .ALU_SIMPLE_LONG_ADD()
                                // wait for instruction prefetch
                                .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p                       .PC_FROM_RESULT();

                                // wait for PC check
        p                       .ALU_SIMPLE_MOVE();
        
        p                       .BRANCH_procedure().PROCEDURE_return();

                // jump here if condition is true
        p       .label("dbcc_condition_true");

        p       .PC_INCR_BY_2()
                .BRANCH_procedure().PROCEDURE_return();
        
        p.label("MICROPC_MOVE_FROM_SR");

        p       .OP1_FROM_SR()
                .SIZE_WORD().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATAALTER();

        p       .ALU_SIMPLE_MOVE()
                .BRANCH_procedure().PROCEDURE_call_load_ea();

        p       .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_MOVE_TO_CCR_MOVE_TO_SR");

        p       .SIZE_WORD().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_DATA();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .ALU_MOVE_TO_CCR_SR_RTE_RTR_STOP_LOGIC_TO_CCR_SR()
                .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_MOVE_USP_to_USP");

        p       .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_AN().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

        p       .ALU_SIMPLE_MOVE();

        p       .AN_ADDRESS_USP()
                .AN_WRITE_ENABLE_SET();

        p       .BRANCH_procedure().PROCEDURE_return();
                
                
        p.label("MICROPC_MOVE_USP_to_An");

        p       .OP1_FROM_USP()
                .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_AN().EA_TYPE_ALL();

        p       .ALU_SIMPLE_MOVE()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_LINK");

                // load An to OP1
        p       .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_AN().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

                // move OP1 to result
        p       .ALU_LINK_MOVE()
                .SIZE_LONG().EA_REG_3b111().EA_MOD_PREDEC().EA_TYPE_ALL();

                // write result to (SP)
        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

                // load SP to OP1
        p       .SIZE_LONG().EA_REG_3b111().EA_MOD_AN().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

                // move OP1 to result
        p       .ALU_SIMPLE_MOVE()
                .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_AN().EA_TYPE_ALL();

                // save result to An
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

                // load offset word to OP1
        p       .SIZE_WORD().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();

        p       .OP1_FROM_IMMEDIATE()
                .PC_INCR_BY_SIZE();

                // move OP1 to OP2
        p       .OP2_FROM_OP1()
                .SIZE_LONG().EA_REG_3b111().EA_MOD_AN().EA_TYPE_ALL();

                // load SP to OP1
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

                // add offset and SP to SP
        p       .ALU_SIMPLE_LONG_ADD()
                .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_ULNK");
                // load An to OP1
        p       .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_AN().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();

                // move OP1 to result
        p       .ALU_SIMPLE_MOVE()
                .SIZE_LONG().EA_REG_3b111().EA_MOD_AN().EA_TYPE_ALL();

                // save result to SP
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

                // load (SP) to OP1
        p       .SIZE_LONG().EA_REG_3b111().EA_MOD_POSTINC().EA_TYPE_ALL();
        p       .BRANCH_procedure().PROCEDURE_call_load_ea();
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();
        
                // move OP1 to result
        p       .ALU_SIMPLE_MOVE()
                .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_AN().EA_TYPE_ALL();

                // save result to An
        p       .BRANCH_procedure().PROCEDURE_call_perform_ea_write();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_BSR");

        p       .OP1_FROM_PC();

        p       .ALU_SIMPLE_MOVE()
                .BRANCH_ir().offset("bsr_no_word");
        p               .SIZE_WORD().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                        .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();

        p               .OP1_FROM_IMMEDIATE()
                        .PC_INCR_BY_SIZE();

                // jump here if no need to load extra immediate word
        p       .label("bsr_no_word");

        p       .OP2_FROM_OP1();
        p       .OP2_MOVE_OFFSET()
                .OP1_FROM_RESULT();

        p       .ALU_SIMPLE_LONG_ADD();

                // wait for instruction prefetch
        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p       .OP1_FROM_PC()
                .PC_FROM_RESULT();

        p       .SIZE_LONG().EA_REG_3b111().EA_MOD_PREDEC().EA_TYPE_ALL();

        p       .ALU_SIMPLE_MOVE()
                .BRANCH_procedure().PROCEDURE_call_load_ea();
                
        p       .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_JMP");

        p       .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_CONTROL();

        p       .BRANCH_procedure().PROCEDURE_call_load_ea();

        p       .OP1_FROM_ADDRESS();
        p       .ALU_SIMPLE_MOVE();

                // wait for instruction prefetch
        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p       .PC_FROM_RESULT();

                // wait for PC check
        p       .ALU_SIMPLE_MOVE();
        
        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_JSR");

        p       .SIZE_LONG().EA_REG_IR_2_0().EA_MOD_IR_5_3().EA_TYPE_CONTROL();

        p       .BRANCH_procedure().PROCEDURE_call_load_ea();

        p       .OP1_FROM_ADDRESS();
        p       .ALU_SIMPLE_MOVE();

                // wait for instruction prefetch
        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p       .OP1_FROM_PC()
                .PC_FROM_RESULT();

        p       .SIZE_LONG().EA_REG_3b111().EA_MOD_PREDEC().EA_TYPE_ALL();

        p       .ALU_SIMPLE_MOVE()
                .BRANCH_procedure().PROCEDURE_call_load_ea();

        p       .BRANCH_procedure().PROCEDURE_call_write();

        p.label("MICROPC_RTE_RTR");

        p       .SIZE_WORD().EA_REG_3b111().EA_MOD_POSTINC().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .ALU_SIMPLE_MOVE()
                .SIZE_LONG().EA_REG_3b111().EA_MOD_POSTINC().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .ALU_SIMPLE_MOVE()
                .OP1_FROM_RESULT();
        p       .ALU_MOVE_TO_CCR_SR_RTE_RTR_STOP_LOGIC_TO_CCR_SR();

                // wait for instruction prefetch
        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p       .PC_FROM_RESULT();
        
                // wait for PC check
        p       .ALU_SIMPLE_MOVE();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_RTS");

        p       .SIZE_LONG().EA_REG_3b111().EA_MOD_POSTINC().EA_TYPE_ALL();

        p       .BRANCH_procedure().PROCEDURE_call_read();
        p       .BRANCH_procedure().PROCEDURE_call_save_ea();

        p       .ALU_SIMPLE_MOVE();

                // wait for instruction prefetch
        p       .BRANCH_procedure().PROCEDURE_wait_prefetch_valid();

        p       .PC_FROM_RESULT();

                // wait for PC check
        p       .ALU_SIMPLE_MOVE();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_NOP");

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_TRAP");

        p       .TRAP_TRAP()
                .BRANCH_procedure().PROCEDURE_call_trap();

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_TRAPV");

        p       .BRANCH_V().offset("trapv_no_trap");

        p               .TRAP_TRAPV()
                        .BRANCH_procedure().PROCEDURE_call_trap();

                // jump here if overflow == 0
        p       .label("trapv_no_trap");

        p       .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_RESET");

        p       .DO_RESET_FLAG_SET();
        p       .BRANCH_procedure().PROCEDURE_wait_finished();
        
        p       .DO_RESET_FLAG_CLEAR()
                .BRANCH_procedure().PROCEDURE_return();

        p.label("MICROPC_STOP");

        p       .SIZE_WORD().EA_REG_3b100().EA_MOD_3b111().EA_TYPE_ALL()
                .BRANCH_procedure().PROCEDURE_wait_prefetch_valid_32();

        p       .OP1_FROM_IMMEDIATE()
                .PC_INCR_BY_SIZE();

        p       .ALU_MOVE_TO_CCR_SR_RTE_RTR_STOP_LOGIC_TO_CCR_SR()
                .STOP_FLAG_SET()
                .BRANCH_procedure().PROCEDURE_return();
    }
}
