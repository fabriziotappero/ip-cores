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


public class TestJMP_near_Ev extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestJMP_near_Ev.class);
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
            
            InstructionLayer instr = new InstructionLayer(random, prohibited_list);
            layers.add(instr);
            StackLayer stack = new StackLayer(random, prohibited_list);
            layers.add(stack);
            layers.add(new OtherLayer(OtherLayer.Type.RANDOM, random));
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
            
            /* 0 - eip out of bounds
             * 
             * 1 - all ok
             */
            
            int type = 1;
            
            // instruction size
            boolean cs_d_b = getInput("cs_d_b") == 1;
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            // destination
            long cs_limit = getInput("cs_limit");
            long cs_base  = Layer.norm(getInput("cs_base"));
            long new_eip  = random.nextInt((int)cs_limit);
            
            if(o32 == false) new_eip &= 0xFFFF;
            
            if(type == 0 && o32 == false && cs_limit <= 0xFFFF) new_eip = 0xFFFF - 5 + random.nextInt(5);
            if(type == 0 && o32 == true)                        new_eip = cs_limit + random.nextInt(5);
            
            byte modregrm_bytes[] = EffectiveAddressLayerFactory.prepare(
                    new_eip,
                    4, EffectiveAddressLayerFactory.modregrm_reg_t.SET,
                    o32? 4 : 2, a32,
                    layers, random, this, false, false);
            
            long dest = cs_base + new_eip;
            
            MemoryPatchLayer patch = new MemoryPatchLayer(random, prohibited_list, (int)dest, 0x0F,0x0F);
            layers.addFirst(patch);
            
            // add instruction
            
            instruction = prepare_instr(cs_d_b, a32, o32, modregrm_bytes);
            instr.add_instruction(instruction);
System.out.printf("a32: %b, o32: %b, cs_d_b: %b\n", a32,o32,cs_d_b);
System.out.printf("dest:     %08x\n", dest);
System.out.printf("new_eip:  %08x\n", new_eip);
System.out.printf("cs_base:  %08x\n", cs_base);
System.out.printf("cs_limit: %08x\n", cs_limit);
            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }

    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32, byte modregrm_bytes[]) throws Exception {
        int opcodes[] = {
            0xFF
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        int opcode = opcodes[random.nextInt(opcodes.length)];
        
        byte instr[] = new byte[1 + modregrm_bytes.length];
        instr[0] = (byte)opcode;
        System.arraycopy(modregrm_bytes, 0, instr, 1, modregrm_bytes.length);
        
        return prefix + bytesToHex(instr);
    }

}