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

package ao486.test.string;

import ao486.test.TestUnit;
import static ao486.test.TestUnit.run_test;
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


public class TestMOVS_rep_any_interrupt extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestMOVS_rep_any_interrupt.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(1376 + index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            // if false: v8086 mode
            boolean is_real = true;
            
            InstructionLayer instr  = new InstructionLayer(random, prohibited_list, true);
            layers.add(instr);
            StackLayer stack        = new StackLayer(random, prohibited_list);
            layers.add(stack);
            layers.add(new OtherLayer(is_real ? OtherLayer.Type.REAL : OtherLayer.Type.PROTECTED_OR_V8086, random));
            layers.add(new FlagsLayer(is_real ? FlagsLayer.Type.RANDOM : FlagsLayer.Type.V8086, random));
            layers.add(new GeneralRegisterLayer(random));
            layers.add(new SegmentLayer(random));
            layers.add(new MemoryLayer(random, random.nextBoolean()));
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
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            long cs_limit = getInput("cs_limit");
            
            
            /* 0 - no rep; no interrupt
             * 1 - no rep; interrupt on 0
             * 2 - no rep; no interrupt; ecx = 0
             * 3 - rep;    no interrupt; ecx = 0
             * 4 - rep;    interrupt on 0
             * 5 - rep;    interrupt on 8
             * 6 - rep;    interrupt on 9
             */
            int type = random.nextInt(7);
            
            int interrupt_position = -1;
            if(type == 0) {
                interrupt_position = -1;
            }
            else if(type == 1) {
                interrupt_position = 0;
            }
            else if(type == 2) {
                interrupt_position = -1;
            }
            else if(type == 3) {
                interrupt_position = -1;
            }
            else if(type == 4) {
                interrupt_position = 0;
            }
            else if(type == 5) {
                interrupt_position = 8;
            }
            else if(type == 6) {
                interrupt_position = 9;
            }
            
            final int interrupt_position_final = interrupt_position;
            
            final int test_type = (type == 0)? 3 : (type == 1 || type == 2 || type == 3)? 4 : 12;
            final int ecx       = (type == 2 || type == 3)? 0 : 10;
            Layer esp_layer = new Layer() {
                long esp()      { return 0xF0; }
                long ss_base()  { return 0; }
                long iflag()    { return 1; }
                long tflag()    { return 0; }
                
                long cs_d_b()   { return 0; }
                
                long ecx()      { return ecx; }
                
                long check_interrupt(long counter) { return counter == interrupt_position_final? 0xAB : 0x100; }
                
                long get_test_type() { return test_type; }
            };
            layers.addFirst(esp_layer);
            
            long handler = cs_limit;
            
            //0xAB -- interrupt vector = 0xAB*4 = 0x2AC linear
            MemoryPatchLayer int_patch = new MemoryPatchLayer(random, prohibited_list, (int)(0xAB*4), (byte)(handler&0xFF),(byte)((handler>>8)&0xFF), 0x00,0x00);
            layers.addFirst(int_patch);
            
            //interrupt handler: simply IRET
            MemoryPatchLayer handler_patch = new MemoryPatchLayer(random, prohibited_list, (int)handler, 0xCF);
            layers.addFirst(handler_patch);
            
            // byte or word/double word
            String instr_string = random.nextBoolean()? "A4" : "A5"; // MOVS
            String rep_string   = (type == 0 || type == 1 || type == 2)? "" : random.nextBoolean()? "F2" : "F3";
            
            // add instruction
            instruction = rep_string + instr_string + "90909090909090909090909090909090"; 
            
            instr.add_instruction(instruction); 
            
            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }
}
