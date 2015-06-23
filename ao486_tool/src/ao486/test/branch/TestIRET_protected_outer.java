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
import ao486.test.layers.DescriptorTableLayer;
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


public class TestIRET_protected_outer extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestIRET_protected_outer.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(45 + index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            InstructionLayer instr  = new InstructionLayer(random, prohibited_list);
            layers.add(instr);
            StackLayer stack        = new StackLayer(random, prohibited_list);
            layers.add(stack);
            layers.add(new OtherLayer(OtherLayer.Type.PROTECTED_OR_V8086, random));
            layers.add(new FlagsLayer(FlagsLayer.Type.NOT_V8086_NOT_NT, random));
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
            boolean cs_d_b  = getInput("cs_d_b") == 1;
            
            boolean a32     = random.nextBoolean();
            boolean o32     = random.nextBoolean();
            
            
            long cs  = 0;
            long eip = 0;
            long eflags = Layer.norm(random.nextInt());
            
            // eflags with no vmflag
            eflags &= 0xFFFDFFFF;
            
            //-------------------------- prepare CS
            
            DescriptorTableLayer tables = new DescriptorTableLayer(random, prohibited_list, true);

            boolean is_ldt = random.nextBoolean();

            boolean conds[] = new boolean[6];
            int cond = 0;

            int     new_cs_rpl  = 0;
            int     old_cs_rpl  = 0;
            boolean new_cs_seg  = false;
            int     new_cs_type = 0;
            int     new_cs_dpl  = 0;
            boolean new_cs_p    = false;

            do {
                old_cs_rpl  = random.nextInt(3);
                new_cs_seg  = random.nextBoolean();
                new_cs_type = random.nextInt(16);
                new_cs_dpl  = random.nextInt(4);
                new_cs_p    = random.nextBoolean();

                new_cs_rpl = old_cs_rpl+1+random.nextInt(3-old_cs_rpl);

                conds[0] = new_cs_rpl < old_cs_rpl;
                //check_cs()
                conds[1] = new_cs_seg == false;
                conds[2] = ((new_cs_type >> 3)&1) == 0; // is data segment
                conds[3] = ((new_cs_type >> 3)&1) == 1 && ((new_cs_type >> 2)&1) == 0 && new_cs_dpl != new_cs_rpl; // code non conforming
                conds[4] = ((new_cs_type >> 3)&1) == 1 && ((new_cs_type >> 2)&1) == 1 && new_cs_dpl > new_cs_rpl;  // code conforming
                conds[5] = new_cs_p == false;
            }
            while(!isAccepted(cond, conds[0],conds[1],conds[2],conds[3],conds[4],conds[5]));

            long new_cs_base, new_cs_limit;
            boolean new_cs_g;
            while(true) {
                new_cs_base = Layer.norm(random.nextInt());
                new_cs_g    = random.nextBoolean();
                
                new_cs_limit = random.nextInt(new_cs_g? 2 : 0xFFFF + 1);
                if(new_cs_g) new_cs_limit = (new_cs_limit << 12) | 0xFFF;
                
                if( new_cs_base + new_cs_limit < 4294967296L &&
                    Layer.collides(prohibited_list, (int)new_cs_base, (int)(new_cs_base + new_cs_limit)) == false    
                ) break;
            }

            boolean new_cs_d_b = random.nextBoolean();
            boolean new_cs_l   = random.nextBoolean();
            boolean new_cs_avl = random.nextBoolean();
            long new_cs_limit_final = new_cs_g? new_cs_limit >> 12 : new_cs_limit;
            Descriptor cs_desc = new Descriptor((int)new_cs_base, (int)new_cs_limit_final, new_cs_type, new_cs_seg, new_cs_p, new_cs_dpl, new_cs_d_b, new_cs_g, new_cs_l, new_cs_avl);

            final int old_cs_rpl_final = old_cs_rpl;
            Layer cs_rpl_layer = new Layer() {
                long cs_rpl() { return old_cs_rpl_final; }
            };
            layers.addFirst(cs_rpl_layer);

            int index = tables.addDescriptor(is_ldt, cs_desc);
            if(index == -1) continue;

            index = index << 3;
            if(is_ldt) index |= 4;

            index |= new_cs_rpl;

            cs = index;

            
            /* all outer
            * 
            * 0. ss_selector null
            * 1. ss_descriptor out of bounds
            * 2. check ss
            * 3. eip out of bounds
            * 4. all ok
            */
            
            int test_type = 4; //random.nextInt(5);
            
            if(test_type == 3) {
                while(true) {
                    eip = new_cs_limit + 1 + random.nextInt(10);

                    if(o32 == false) eip &= 0xFFFF;

                    if(eip > new_cs_limit) break;
                }
                if(o32 == false) eip |= (random.nextInt() & 0xFFFF0000);
            }
            else {
                while(true) {
                    eip = Layer.norm(random.nextInt((int)new_cs_limit+1));

                    if(o32 == false) eip &= 0xFFFF;

                    if(eip <= new_cs_limit) break;
                }
                
                long dest = new_cs_base + eip;
                // adding always possible
                MemoryPatchLayer patch = new MemoryPatchLayer(random, prohibited_list, (int)dest, 0x0F,0x0F);
                layers.addFirst(patch);

                if(o32 == false) eip |= (random.nextInt() & 0xFFFF0000);
            }

            
            
            //-------------------------- prepare SS
            long ss  = random.nextInt(4);
            long esp = Layer.norm(random.nextInt());
            

            if(test_type == 0) {
                // nothing
            }
            else if(test_type == 1) {
                is_ldt = random.nextBoolean();
                
                index = tables.getOutOfBoundsIndex(is_ldt);
                if(index == -1) continue;

                index = index << 3;
                if(is_ldt) index |= 4;

                index |= new_cs_rpl;
                
                ss = index;
            }
            else if(test_type == 2 || test_type == 3 || test_type == 4) {
                is_ldt = random.nextBoolean();
                
                conds = new boolean[6];
                cond = 1 << random.nextInt(conds.length);
                if(test_type >= 3) cond = 0;
                
                int     new_ss_rpl  = 0;
                boolean new_ss_seg  = false;
                int     new_ss_type = 0;
                int     new_ss_dpl  = 0;
                boolean new_ss_p    = false;
                
                do {
                    new_ss_rpl  = random.nextInt(4);
                    new_ss_seg  = random.nextBoolean();
                    new_ss_type = random.nextInt(16);
                    new_ss_dpl  = random.nextInt(4);
                    new_ss_p    = random.nextBoolean();
                    
                    conds[0] = new_ss_rpl != new_cs_rpl;
                    conds[1] = new_ss_seg == false;
                    conds[2] = ((new_ss_type >> 3)&1) == 1; // is code segment
                    conds[3] = ((new_ss_type >> 3)&1) == 0 && ((new_ss_type >> 1)&1) == 0; // data not writable
                    conds[4] = new_ss_dpl != new_cs_rpl;
                    conds[5] = new_ss_p == false;
                }
                while(!isAccepted(cond, conds[0],conds[1],conds[2],conds[3],conds[4],conds[5]));
                
                long new_ss_base, new_ss_limit;
                while(true) {
                    new_ss_base = Layer.norm(random.nextInt());

                    new_ss_limit = random.nextInt(0xFFFF + 1);

                    if( new_ss_base + new_ss_limit < 4294967296L &&
                        Layer.collides(prohibited_list, (int)new_ss_base, (int)(new_ss_base + new_ss_limit)) == false    
                    ) break;
                }
                
                boolean new_ss_d_b = random.nextBoolean();
                boolean new_ss_g   = random.nextBoolean();
                boolean new_ss_l   = random.nextBoolean();
                boolean new_ss_avl = random.nextBoolean();
                Descriptor ss_desc = new Descriptor((int)new_ss_base, (int)new_ss_limit, new_ss_type, new_ss_seg, new_ss_p, new_ss_dpl, new_ss_d_b, new_ss_g, new_ss_l, new_ss_avl);
                
                
                index = tables.addDescriptor(is_ldt, ss_desc);
                if(index == -1) continue;

                index = index << 3;
                if(is_ldt) index |= 4;

                index |= new_ss_rpl;
                
                ss = index;
            }
            
            // entry stack
            if(o32) {
                stack.push_dword((int)eip);     //eip
                stack.push_dword((int)cs);      //cs
                stack.push_dword((int)eflags);  //eflags
                stack.push_dword((int)esp); // esp
                stack.push_dword((int)ss);  // ss
            }
            else {
                stack.push_word((int)eip);      //eip
                stack.push_word((int)cs);       //cs
                stack.push_word((int)eflags);   //eflags
                stack.push_word((int)esp); // esp
                stack.push_word((int)ss);  // ss
            }
            
            layers.addFirst(tables);
            
            // add instruction
            instruction = prepare_instr(cs_d_b, a32, o32);
            instr.add_instruction(instruction);
            
            
            
            // end condition
            break;
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