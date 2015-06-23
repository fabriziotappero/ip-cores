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

package ao486.test.interrupt;

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


public class TestINT_INT3_INTO_INT1_real extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestINT_INT3_INTO_INT1_real.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(14 + index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            // if false: v8086 mode
            boolean is_real = true;
            
            InstructionLayer instr  = new InstructionLayer(random, prohibited_list);
            layers.add(instr);
            StackLayer stack        = new StackLayer(random, prohibited_list);
            layers.add(stack);
            layers.add(new OtherLayer(is_real ? OtherLayer.Type.REAL : OtherLayer.Type.PROTECTED_OR_V8086, random));
            layers.add(new FlagsLayer(is_real ? FlagsLayer.Type.RANDOM : FlagsLayer.Type.V8086, random));
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
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            long cs_limit = getInput("cs_limit");
            
            // type
            
            /* 0 - INTO overflow not set
             * 1 - IDTR limit
             * 2 - new_eip out of bounds
             * 
             * 3 - all ok
             */
            int type = random.nextInt(4);
            
            
            // instruction
            boolean is_into = (type == 0)? true : random.nextInt(3) == 0;
            
            instruction = prepare_instr(cs_d_b, a32, o32, is_into);
            
            
            if(type == 0) {
                
                Layer of_layer = new Layer() {
                    long oflag() { return 0; }
                };
                layers.addFirst(of_layer);
                
                instruction += "0F0F";
            }
            else if(type == 1) {
                
                final int limit = random.nextInt(vector * 4 + 3);
                Layer idtr_layer = new Layer() {
                    long idtr_limit() { return limit; }
                };
                layers.addFirst(idtr_layer);
            }
            else if(type >= 2) {
                final int limit = vector * 4 + 4 + random.nextInt(5);
                Layer idtr_limit_layer = new Layer() {
                    long idtr_limit() { return limit; }
                };
                layers.addFirst(idtr_limit_layer);
                
                // set idtr base
                long idtr_base;
                while(true) {
                    idtr_base = Layer.norm(random.nextInt());
                    
                    if( idtr_base + limit < 4294967296L &&
                        Layer.collides(prohibited_list, (int)idtr_base, (int)(idtr_base + limit)) == false    
                    ) break;
                }
                prohibited_list.add(new Pair<>(idtr_base, idtr_base + limit));
                
                final long idtr_base_final = idtr_base;
                Layer idtr_base_layer = new Layer() {
                    long idtr_base() { return idtr_base_final; }
                };
                layers.addFirst(idtr_base_layer);
                
                //set cs and eip
                long new_cs;
                long new_eip;
                long dest;
                while(true) {
                    new_cs = random.nextInt(65536);
                    new_eip = random.nextInt(65536);
                    
                    dest = (new_cs << 4) + new_eip;
                    
                    if( dest < 4294967296L &&
                        Layer.collides(prohibited_list, (int)dest, (int)(dest + 2)) == false    
                    ) break;
                }
                prohibited_list.add(new Pair<>(dest, dest + 2));
                
                if(type == 2 && cs_limit < 0xFFFF) {
                    new_eip = cs_limit + 1 + random.nextInt((int)(0xFFFF - cs_limit));
                }
                
                // set new_cs and new_eip
                MemoryPatchLayer int_patch = new MemoryPatchLayer(random, prohibited_list, (int)(idtr_base + 4*vector),
                        (byte)(new_eip & 0xFF), (byte)((new_eip >> 8) & 0xFF),
                        (byte)(new_cs & 0xFF), (byte)((new_cs >> 8) & 0xFF));
                layers.addFirst(int_patch);
                
                // set destination
                MemoryPatchLayer patch = new MemoryPatchLayer(random, prohibited_list, (int)dest, 0x0F,0x0F);
                layers.addFirst(patch);
                
System.out.printf("new_cs: %04x\n", new_cs);
System.out.printf("new_ip: %04x\n", new_eip);
System.out.printf("dest:   %08x\n", dest);
            }
            
            
            if(type >= 1 && is_into) {
                Layer of_layer = new Layer() {
                    boolean get_of() { return true; }
                };
                layers.addFirst(of_layer);
            }
            
            
            // add instruction
            instr.add_instruction(instruction);
            
            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }

    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32, boolean is_into) throws Exception {
        int opcodes[] = {
            0xCC,0xCD,0xF1,0xCE
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        int opcode = opcodes[(is_into)? 3 : random.nextInt(3)];
        
        int len = (opcode == 0xCD)? 2 : 1;
        
        byte instr[] = new byte[len];
        instr[0] = (byte)opcode;
        if(len >= 2) instr[1] = (byte)random.nextInt();
        
        if(opcode == 0xCC) vector = 3;
        if(opcode == 0xCD) vector = (instr[1] < 0)? instr[1] + 256 : instr[1];
        if(opcode == 0xCE) vector = 4;
        if(opcode == 0xF1) vector = 1;
        
        return prefix + bytesToHex(instr);
    }
    int vector;
}