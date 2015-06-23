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


public class TestIRET_real_v8086 extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestIRET_real_v8086.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(1 + index);
        
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
            
            // instruction size
            boolean cs_d_b = getInput("cs_d_b") == 1;
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            // destination
            long cs     = random.nextInt(0xFFFF+1);
            long eip    = Layer.norm(0x1FFFF);
            long eflags = random.nextInt();
            
            if(o32 == false) eip &= 0xFFFF;

            long dest = (cs << 4) + eip;

            boolean can_add = Layer.collides(prohibited_list, (int)dest, (int)(dest+1));
            
            if(can_add == false) continue;
            
            MemoryPatchLayer patch = new MemoryPatchLayer(random, prohibited_list, (int)dest, 0x0F,0x0F);
            layers.addFirst(patch);
            
            // stack
            if(o32) {
                stack.push_dword((int)eip);                                     //eip
                stack.push_dword((int)cs | (random.nextInt() & 0xFFFF0000));    //cs
                stack.push_dword((int)eflags);                                  //eflags
            }
            else {
                stack.push_word((int)eip);      //eip
                stack.push_word((int)cs);       //cs
                stack.push_word((int)eflags);   //eflags
            }
            
            // add instruction
            boolean cr0_pe  = getInput("cr0_pe") == 1;
            boolean flag_vm = getInput("vmflag") == 1;
            
            instruction = prepare_instr(cs_d_b, a32, o32);
            instr.add_instruction(instruction);
            
            // end condition
            if(cr0_pe == false || flag_vm == true) {
System.out.printf("cs: %x\neip: %x\neflags: %x\ndst: %x\n", (int)cs,(int)eip,(int)eflags,(int)dest);
                break;
            }
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }

    int imm_len(boolean a32, boolean o32, int opcode) {
        return 0;
    }
    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32) throws Exception {
        int opcodes[] = {
            0xCF
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        int     opcode      = opcodes[random.nextInt(opcodes.length)];
        boolean is_modregrm = false;
        
        byte possible_modregrm = (byte)random.nextInt();
        byte possible_sib      = (byte)random.nextInt();
      
        int len = (is_modregrm == false)? 1 : 1 + modregrm_len(!cs_d_b, unsigned(possible_modregrm), unsigned(possible_sib));
        len += imm_len(a32, o32, opcode);

        
        byte instr[] = new byte[len];
        instr[0] = (byte)opcode;
        for(int i=1; i<len; i++) {
            if(i==1)        instr[1] = possible_modregrm;
            else if(i==2)   instr[2] = possible_sib;
            else            instr[i] = (byte)random.nextInt();
        }
        
        return prefix + bytesToHex(instr);
    }

}