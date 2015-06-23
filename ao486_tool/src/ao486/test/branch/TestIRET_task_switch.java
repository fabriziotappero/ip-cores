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
import ao486.test.layers.OtherLayer;
import ao486.test.layers.Pair;
import ao486.test.layers.SegmentLayer;
import ao486.test.layers.StackLayer;
import ao486.test.layers.TSSCurrentLayer;
import java.io.*;
import java.util.LinkedList;
import java.util.Random;


public class TestIRET_task_switch extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestIRET_task_switch.class);
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
            
            InstructionLayer instr  = new InstructionLayer(random, prohibited_list);
            layers.add(instr);
            StackLayer stack        = new StackLayer(random, prohibited_list);
            layers.add(stack);
            layers.add(new OtherLayer(OtherLayer.Type.PROTECTED_OR_V8086, random));
            layers.add(new FlagsLayer(FlagsLayer.Type.NOT_V8086_NT, random));
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
            
            /* 0 - link tss selector with TI set
             * 1 - TSS descriptor out of bounds
             * 2 - invalid TSS descriptor
             * 
             * >=3 - task switch tests
             */

            int type = random.nextInt(4);
            int task_switch_type = -1;
            
            DescriptorTableLayer tables = null;
            int new_tss_selector = -1;
            int old_tss_limit = 0xFFFF;
            
            TSSCurrentLayer.Type old_tss_type = random.nextBoolean()? TSSCurrentLayer.Type.BUSY_286 : TSSCurrentLayer.Type.BUSY_386;
            
            //------------------------------------------------------------------
            //------------------------------------------------------------------
            
            
            
            
            //------------------------------------------------------------------
            //------------------------------------------------------------------
            
            if(type == 0) {
                new_tss_selector = random.nextInt(65536);
                new_tss_selector |= 4;
                
                TSSCurrentLayer current_tss = new TSSCurrentLayer(random, old_tss_type, 0xFFFF, new_tss_selector, prohibited_list);
                layers.addFirst(current_tss);
            }
            else if(type == 1) {
                tables = new DescriptorTableLayer(random, prohibited_list, true);
                
                new_tss_selector = tables.getOutOfBoundsIndex(false);
                if(new_tss_selector == -1) continue;
                
                new_tss_selector <<= 3;
                new_tss_selector |= random.nextInt(0x8);
            }
            else if(type == 2) {
                
                boolean conds[] = new boolean[3];
                int cond = 1 << random.nextInt(conds.length);
                
                boolean new_tss_seg  = false;
                int     new_tss_type = 0;
                boolean new_tss_p    = false;
                
                int     new_tss_dpl  = random.nextInt(4);
                boolean new_tss_d_b  = random.nextBoolean();
                boolean new_tss_l    = random.nextBoolean();
                boolean new_tss_avl  = random.nextBoolean();
                int     new_tss_rpl  = random.nextInt(4);
                
                do {
                    new_tss_seg = random.nextBoolean();
                    new_tss_type= random.nextInt(16);
                    new_tss_p   = random.nextBoolean();
                    
                    conds[0] = new_tss_seg;
                    conds[1] = new_tss_type != 0x3 && new_tss_type != 0xb;
                    conds[2] = new_tss_p == false;
                }
                while(!isAccepted(cond, conds[0],conds[1],conds[2]));
                
                //---------
                long new_tss_base, new_tss_limit;
                boolean new_tss_g;
                while(true) {
                    new_tss_base = Layer.norm(random.nextInt());
                    new_tss_g    = random.nextBoolean();
                    
                    new_tss_limit = random.nextInt(new_tss_g? 0xF+1 : 0xFFFF + 1);
                    if(new_tss_g) new_tss_limit = (new_tss_limit << 12) | 0xFFF;
                        
                    if( new_tss_base + new_tss_limit < 4294967296L &&
                        Layer.collides(prohibited_list, (int)new_tss_base, (int)(new_tss_base + new_tss_limit)) == false )
                    {
                        prohibited_list.add(new Pair<>(new_tss_base, new_tss_base + new_tss_limit));
                        break;
                    }
                }

                long new_tss_limit_final = new_tss_g? new_tss_limit >> 12 : new_tss_limit;
                
                Descriptor tss_desc = new Descriptor((int)new_tss_base, (int)new_tss_limit_final, new_tss_type, new_tss_seg, new_tss_p, new_tss_dpl, new_tss_d_b, new_tss_g, new_tss_l, new_tss_avl);
                
                tables = new DescriptorTableLayer(random, prohibited_list, true);
                new_tss_selector = tables.addDescriptor(false, tss_desc);
                if(new_tss_selector == -1) continue;
                
                //copy
                new_tss_selector <<= 3;
                new_tss_selector |= new_tss_rpl;
            }
            else if(type >= 3) {
                boolean conds[] = new boolean[3];
                int cond = 0;

                boolean new_tss_seg  = false;
                int     new_tss_type = 0;
                boolean new_tss_p    = false;

                int     new_tss_dpl  = random.nextInt(4);
                boolean new_tss_d_b  = random.nextBoolean();
                boolean new_tss_l    = random.nextBoolean();
                boolean new_tss_avl  = random.nextBoolean();
                int     new_tss_rpl  = random.nextInt(4);

                do {
                    new_tss_seg = random.nextBoolean();
                    new_tss_type= (type == 8 || type == 9)? 0xB : random.nextInt(16);
                    new_tss_p   = random.nextBoolean();

                    conds[0] = new_tss_seg;
                    conds[1] = new_tss_type != 0x3 && new_tss_type != 0xb;
                    conds[2] = new_tss_p == false;
                }
                while(!isAccepted(cond, conds[0],conds[1],conds[2]));

                //---------
                long new_tss_base, new_tss_limit;
                boolean new_tss_g;
                while(true) {
                    new_tss_base = Layer.norm(random.nextInt());
                    new_tss_g    = random.nextBoolean();

                    new_tss_limit = random.nextInt(new_tss_g? 0xF+1 : 0xFFFF + 1);
                    if(new_tss_g) new_tss_limit = (new_tss_limit << 12) | 0xFFF;

                    if( new_tss_base + new_tss_limit < 4294967296L &&
                        Layer.collides(prohibited_list, (int)new_tss_base, (int)(new_tss_base + new_tss_limit)) == false)
                    {
                        prohibited_list.add(new Pair<>(new_tss_base, new_tss_base + new_tss_limit));
                        break;
                    }
                }

                long new_tss_limit_final = new_tss_g? new_tss_limit >> 12 : new_tss_limit;

                Descriptor tss_desc = new Descriptor((int)new_tss_base, (int)new_tss_limit_final, new_tss_type, new_tss_seg, new_tss_p, new_tss_dpl, new_tss_d_b, new_tss_g, new_tss_l, new_tss_avl);

                //--------------------------------------------------------------
                //--------------------------------------------------------------
                //--------------------------------------------------------------
                
                boolean is_ok = TestTaskSwitch.test(random, this, prohibited_list, TestTaskSwitch.Source.FROM_IRET, tss_desc, new_tss_rpl, null, task_switch_type);
                if(is_ok == false) continue;
                
                tables              = TestTaskSwitch.tables;
                new_tss_selector    = TestTaskSwitch.new_tss_selector;
                old_tss_limit       = TestTaskSwitch.old_tss_limit;
            }
            
            //------------------------------------------------------------------
            //------------------------------------------------------------------
            
            if(type != 0) {
                TSSCurrentLayer old_tss = new TSSCurrentLayer(random, old_tss_type, old_tss_limit, new_tss_selector, prohibited_list);
                layers.addFirst(old_tss);
                
                layers.addFirst(tables);
            }
            
            
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