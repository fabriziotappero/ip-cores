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


public class TestJcc_JECXZ extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestJcc_JECXZ.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(4+index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            InstructionLayer instr = new InstructionLayer(random, prohibited_list);
            layers.add(instr);
            layers.add(new StackLayer(random, prohibited_list));
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
            
            // instruction size
            boolean cs_d_b = getInput("cs_d_b") == 1;
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            
            final long ecx = random.nextInt(3);
            
            layers.addFirst(new Layer() {
               public long tflag() { return 0; }
               public long ecx()   { return ecx; }
            });
            
            // instruction
            instruction = prepare_instr(cs_d_b, a32, o32, null);
            
            instruction += "0F0F";
            
            // add instruction
            instr.add_instruction(instruction);
            
            //target memory patch
            long cs_base= getInput("cs_base");
            long eip    = getInput("eip");
            
System.out.printf("cs_base: %08x\n", cs_base);
System.out.printf("eip:     %08x\n", eip);
System.out.printf("offset:  %08x\n", offset);
System.out.printf("linear:  %08x\n", cs_base + eip);
System.out.printf("final:   %08x\n", cs_base + offset + eip + instruction.length()/2 - 2);
System.out.printf("cs_d_b:  %b\n",   cs_d_b);

            if(o32 == false) eip &= 0xFFFF;
            
            long dest = cs_base + eip + offset + instruction.length()/2 - 2;

            boolean can_add = Layer.collides(prohibited_list, (int)dest, (int)(dest+1));
            
            if(can_add == false) continue;
            
            MemoryPatchLayer patch = new MemoryPatchLayer(random, prohibited_list, (int)dest, 0x0F,0x0F);
            layers.addFirst(patch);
            
            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }
    
    int imm_len(boolean a16, boolean o16, int opcode) {
        int h = (opcode >> 4) & 0x0F;
        
        if(h == 8) return o16? 2 : 4;
        
        return 1;
    }
    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32, byte modregrm_bytes[]) throws Exception {
        int opcodes[] = {
            0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7A,0x7B,0x7C,0x7D,0x7E,0x7F,
            0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,
            0xE3
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        int     opcode      = (random.nextInt(5) == 0)? 0xE3 : opcodes[random.nextInt(opcodes.length)];
        boolean is_modregrm = false;
        
        byte possible_modregrm = (byte)random.nextInt();
        byte possible_sib      = (byte)random.nextInt();
      
        int len = (is_modregrm == false)? 1 : 1 + modregrm_len(!a32, unsigned(possible_modregrm), unsigned(possible_sib));
        len += imm_len(!a32, !o32, opcode);
System.out.println("[len final: " + len + "]");
        
        offset = 0;
        while(true) {
            int imm_len = imm_len(!a32, !o32, opcode);
            
            offset = random.nextInt();
            
            if(imm_len == 1) {
                offset &= 0xFF;
                byte b = (byte)offset;
                offset = b;
            }
            if(imm_len == 2) {
                offset &= 0xFFFF;
                short b = (short)offset;
                offset = b;
            }
            
            if(offset > 15 || offset < -15) break;
        }

        byte instr[] = new byte[len];
        instr[0] = (byte)opcode;
        if(len >= 2) instr[1] = (byte)((offset >> 0) & 0xFF);
        if(len >= 3) instr[2] = (byte)((offset >> 8) & 0xFF);
        if(len >= 4) instr[3] = (byte)((offset >> 16) & 0xFF);
        if(len >= 5) instr[4] = (byte)((offset >> 24) & 0xFF);
        
        if(((opcode >> 4) & 0xF) == 8) return prefix + "0F" + bytesToHex(instr);
        
        return prefix + bytesToHex(instr);
    }
    
    int offset;
}
