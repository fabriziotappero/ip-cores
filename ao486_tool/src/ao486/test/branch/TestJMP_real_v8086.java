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

package ao486.test.branch;

import ao486.test.TestUnit;
import ao486.test.layers.EffectiveAddressLayerFactory;
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


public class TestJMP_real_v8086 extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestJMP_real_v8086.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(3 + index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            // if false: v8086 mode
            boolean is_real = random.nextBoolean();
            
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
            
            /*
             * 0 - eip out of bounds
             * 
             * 1 - all ok
             */
            
            int type = random.nextInt(2);
            
            // instruction size
            boolean cs_d_b = getInput("cs_d_b") == 1;
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            // destination
            long cs         = random.nextInt(0xFFFF+1);
            long cs_limit   = (is_real == false)? 0xFFFF : getInput("cs_limit");
            long new_eip    = random.nextInt((int)cs_limit+1);
            
            if(o32 == false) new_eip &= 0xFFFF;
            
            if(type == 0 && o32 == false && cs_limit <= 0xFFFF) new_eip = 0xFFFF - 4 + random.nextInt(5);
            if(type == 0 && o32 == true)                        new_eip = cs_limit + random.nextInt(5);
            
            // dest instruction
            long dest = (cs << 4) + new_eip;

            boolean can_add = Layer.collides(prohibited_list, (int)dest, (int)(dest+1));
            if(can_add == false) continue;
            
            MemoryPatchLayer patch = new MemoryPatchLayer(random, prohibited_list, (int)dest, 0x0F,0x0F);
            layers.addFirst(patch);
            
            // add instruction
            byte extra_bytes[] = null;
            
            boolean is_Ep = random.nextBoolean();
            
            if(is_Ep) {
                byte modregrm_bytes[] = EffectiveAddressLayerFactory.prepare(
                        o32? (((cs & 0xFFFF) << 32) | (new_eip & 0xFFFFFFFF)) : (((cs & 0xFFFF) << 16) | (new_eip & 0xFFFF)),
                        5, EffectiveAddressLayerFactory.modregrm_reg_t.SET,
                        o32? 6 : 4, a32,
                        layers, random, this, true, false);
                extra_bytes = modregrm_bytes;
            }
            else {
                long immediate = o32? (((cs & 0xFFFF) << 32) | (new_eip & 0xFFFFFFFF)) : (((cs & 0xFFFF) << 16) | (new_eip & 0xFFFF));
            
                byte imm_bytes[] = new byte[o32? 6 : 4];
                for(int i=0; i<imm_bytes.length; i++) {
                    imm_bytes[i] = (byte)(immediate & 0xFF);
                    immediate >>= 8;
                }
                extra_bytes = imm_bytes;
            }
            
            instruction = prepare_instr(cs_d_b, a32, o32, extra_bytes, is_Ep);
            instr.add_instruction(instruction);

System.out.printf("a32: %b, o32: %b, cs_d_b: %b\n", a32,o32,cs_d_b);
System.out.printf("cs: %x\n", cs);
System.out.printf("cs_limit: %x\n", cs_limit);
System.out.printf("new_eip: %x\n", new_eip);
System.out.printf("o32: %b\n", o32);
System.out.printf("is_real: %b\n", is_real);

            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }

    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32, byte extra_bytes[], boolean is_Ep) throws Exception {
        int opcodes[] = {
            0xFF, 0xEA
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        int opcode = opcodes[is_Ep? 0 : 1];
        
        byte instr[] = new byte[1 + extra_bytes.length];
        instr[0] = (byte)opcode;
        System.arraycopy(extra_bytes, 0, instr, 1, extra_bytes.length);
        
        return prefix + bytesToHex(instr);
    }

}