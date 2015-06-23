/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package ao486.test.debug;

import ao486.test.TestUnit;
import ao486.test.layers.FlagsLayer;
import ao486.test.layers.GeneralRegisterLayer;
import ao486.test.layers.HandleModeChangeLayer;
import ao486.test.layers.IOLayer;
import ao486.test.layers.InstructionLayer;
import ao486.test.layers.Layer;
import ao486.test.layers.MemoryLayer;
import ao486.test.layers.MemoryPatchLayer;
import ao486.test.layers.OtherLayer;
import ao486.test.layers.Pair;
import ao486.test.layers.SegmentLayer;
import ao486.test.layers.StackLayer;
import java.io.*;
import java.util.LinkedList;
import java.util.Random;


public class Test_trace extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(Test_trace.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    int type;
    
    @Override
    public void init() throws Exception {
        
        random = new Random(8 + index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            /* 0 - tf enable; some instructions; disable tf
             * 1 - tf enable; some instructions with inhibit; disable tf
             * 2 - like 0 but enable interrupts
             * 3 - tf enabled; REP LODS; disable tf
             * 4 - tf enable; HLT; interrupt with debug; disable tf
             */
            
            type = random.nextInt(5);
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            // if false: v8086 mode
            boolean is_real = true;
            
            InstructionLayer instr  = new InstructionLayer(random, prohibited_list, true);
            layers.add(instr);
            StackLayer stack        = new StackLayer(random, prohibited_list);
            layers.add(stack);
            layers.add(new OtherLayer(is_real ? OtherLayer.Type.REAL : OtherLayer.Type.PROTECTED_OR_V8086, random));
            layers.add(new FlagsLayer(FlagsLayer.Type.RANDOM, random));
            layers.add(new GeneralRegisterLayer(random));
            layers.add(new SegmentLayer(random));
            layers.add(new MemoryLayer(random));
            layers.add(new IOLayer(random));
            layers.addFirst(new HandleModeChangeLayer(
                    getInput("cr0_pe"),
                    getInput("vmflag"),
                    getInput("cs_rpl"),
                    getInput("cs_p"),
                    getInput("cs_s"),
                    getInput("cs_type")
            ));
            
            // instruction size
            boolean cs_d_b = getInput("cs_d_b") == 1;
            if(cs_d_b == true) continue;
            
            boolean vmflag = getInput("vmflag") == 1;
            
            long cs_limit = getInput("cs_limit");
            long cs_base  = getInput("cs_base");
            
            boolean a32 = random.nextBoolean();
            boolean o32 = true;
            
            final boolean iflag = (type == 2)? true : random.nextBoolean();
            final int ecx = (type == 3)? 4 : random.nextInt();
            Layer debug_layer = new Layer() {
                    
                long rflag()    { return 0; }
                long tflag()    { return 0; }
                long iflag()    { return iflag? 1 : 0; }
                long ecx()      { return ecx; }
                
                long check_interrupt(long counter) { return (type == 2 && (counter == 6))? 0xAB : (type == 4 && (counter == 2))? 0xAB : 0x100; }
                
                long get_test_type() { return 12; }
            };
            layers.addFirst(debug_layer);
            
            long handler = cs_limit;
            
            //0xAB -- interrupt vector = 0xAB*4 = 0x2AC linear
            MemoryPatchLayer int_patch = new MemoryPatchLayer(random, prohibited_list, (int)(0x01*4), (byte)(handler&0xFF),(byte)((handler>>8)&0xFF), 0x00,0x00);
            layers.addFirst(int_patch);
            
            MemoryPatchLayer interrupt_patch = new MemoryPatchLayer(random, prohibited_list, (int)(0xAB*4), (byte)(handler&0xFF),(byte)((handler>>8)&0xFF), 0x00,0x00);
            layers.addFirst(interrupt_patch);
            
            //interrupt handler: simply IRET
            MemoryPatchLayer handler_patch = new MemoryPatchLayer(random, prohibited_list, (int)handler, 0xCF);
            layers.addFirst(handler_patch);
            
            String prefix = "";
            if(cs_d_b != o32) { prefix = "66" + prefix; }
            
            int eflags_start = 0x00000300; //TF and IF set
            int eflags_end   = 0x00000200; //IF set
            stack.push_dword(eflags_start);
            stack.push_dword(eflags_end);
            
            instruction = "";
            if(type == 0 || type == 2) {
                // POPF + DAA(don't care) + POPF
                instruction = prefix + "9D" + "272727" + "9D" + "90909090909090909090900F0F";
            }
            else if(type == 1) {
                // POPF + DAA(don't care) + POP SS(for inhibit) + POPF
                instruction = prefix + "9D" + "27" + "17" + "2727" + "9D" + "90909090909090909090900F0F";
            }
            else if(type == 3) {
                // POPF + LODS + POPF
                instruction = prefix + "9D" + "F3" + "AD" + "9D" + "90909090909090909090900F0F";
            }
            else if(type == 4) {
                // POPF + HLT + POPF
                instruction = prefix + "9D" + "F4" + "9D" + "90909090909090909090900F0F";
            }
            
            // add instruction
            instr.add_instruction(instruction);
            
            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }

}
