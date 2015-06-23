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
import ao486.test.layers.EffectiveAddressLayerFactory;
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


public class TestCALL_task_gate extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestCALL_task_gate.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(128+index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            InstructionLayer instr = new InstructionLayer(random, prohibited_list);
            layers.add(instr);
            StackLayer stack = new StackLayer(random, prohibited_list);
            layers.add(stack);
            layers.add(new OtherLayer(OtherLayer.Type.PROTECTED_OR_V8086, random));
            layers.add(new FlagsLayer(FlagsLayer.Type.NOT_V8086, random));
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
            
            /* null check, selector limit checked in: TestCALL_protected_seg
             * 
             * 0 - pre-(task gate) valid check
             * 1 - tss_selector TI
             * 2 - tss_descriptor out of bounds
             * 3 - tss_descriptor valid check
             * 
             * >=4 - task switch tests
             */

            int type = random.nextInt(5);
            System.out.println("Running test type: " + type);
            int task_switch_type = -1; //26;
            
            DescriptorTableLayer tables = null;
            int new_tss_selector = random.nextInt(4);
            int old_tss_limit = 0xFFFF;
            
            TSSCurrentLayer.Type old_tss_type = random.nextBoolean()? TSSCurrentLayer.Type.BUSY_286 : TSSCurrentLayer.Type.BUSY_386;
            
            //------------------------------------------------------------------
            //------------------------------------------------------------------
            
            if(type >= 0) {
                // prepare tss descriptor
                boolean is_tss_ldt = (type == 1)? true : false;
                
                boolean conds[] = new boolean[3];
                int cond = 1 << random.nextInt(conds.length);
                if(type >= 4) cond = 0;
                
                int     new_tss_rpl  = 0;
                boolean new_tss_seg  = false;
                int     new_tss_type = 0;
                int     new_tss_dpl  = 0;
                boolean new_tss_p    = false;
                
                do {
                    new_tss_seg  = random.nextBoolean();
                    new_tss_type = random.nextInt(16);
                    new_tss_p    = random.nextBoolean();
                    
                    new_tss_rpl  = random.nextInt(4);
                    new_tss_dpl  = random.nextInt(4);
                    
                    
                    conds[0] = new_tss_seg;
                    conds[1] = new_tss_type != 0x1 && new_tss_type != 0x9; //AVAIL_TSS_286,386
                    conds[2] = new_tss_p == false;
                }
                while(!isAccepted(cond, conds[0],conds[1],conds[2]));
                
                long new_tss_base, new_tss_limit;
                boolean new_tss_g;
                while(true) {
                    new_tss_base = Layer.norm(random.nextInt());
                    new_tss_g    = random.nextBoolean();
                    
                    new_tss_limit = random.nextInt(new_tss_g? 0xF : 0xFFFF);
                    if(new_tss_g) new_tss_limit = (new_tss_limit << 12) | 0xFFF;
                        
                    if( new_tss_base + new_tss_limit < 4294967296L &&
                        Layer.collides(prohibited_list, (int)new_tss_base, (int)(new_tss_base + new_tss_limit)) == false    
                    ) break;
                }
                
                boolean new_tss_d_b = random.nextBoolean();
                boolean new_tss_l   = random.nextBoolean();
                boolean new_tss_avl = random.nextBoolean();
                long new_tss_limit_final = new_tss_g? new_tss_limit >> 12 : new_tss_limit;
                Descriptor tss_desc = new Descriptor((int)new_tss_base, (int)new_tss_limit_final, new_tss_type, new_tss_seg, new_tss_p, new_tss_dpl, new_tss_d_b, new_tss_g, new_tss_l, new_tss_avl);

System.out.printf("tss_desc: ");
for(int i=0; i<8; i++) System.out.printf("%02x ", tss_desc.get_byte(i));
System.out.printf("\n");

                tables = new DescriptorTableLayer(random, prohibited_list, true);
                
                int index = -1;
                if(type != 2) {
                    index = tables.addDescriptor(is_tss_ldt, tss_desc);
                    if(index == -1) continue;
                }
                else {
                    index = tables.getOutOfBoundsIndex(is_tss_ldt);
                    if(index == -1) continue;
                }

                index <<= 3;
                if(is_tss_ldt) index |= 4;
                index |= new_tss_rpl;
                
                
                // prepare task gate descriptor
                
                
                boolean is_ldt = random.nextBoolean();
                
                conds = new boolean[3];
                cond = 1 << random.nextInt(conds.length);
                if(type >= 1) cond = 0;
                
                int     new_cs_rpl  = 0;
                int     old_cs_rpl  = 0;
                boolean new_cs_seg  = false;
                int     new_cs_type = 0;
                int     new_cs_dpl  = 0;
                boolean new_cs_p    = false;
                
                do {
                    new_cs_seg  = false;
                    new_cs_type = 0x5; //TASK_GATE
                    
                    new_cs_rpl  = random.nextInt(4);
                    old_cs_rpl  = random.nextInt(4);
                    new_cs_dpl  = random.nextInt(4);
                    new_cs_p    = random.nextBoolean();
                    is_ldt      = random.nextBoolean();
                    
                    conds[0] = new_cs_dpl < old_cs_rpl;
                    conds[1] = new_cs_dpl < new_cs_rpl;
                    conds[2] = new_cs_p == false;
                }
                while(!isAccepted(cond, conds[0],conds[1],conds[2]));
                
                long new_cs_base  = index;
                long new_cs_limit = Layer.norm(random.nextInt(0xFFFFF+1));
                boolean new_cs_g  = random.nextBoolean();
                
                boolean new_cs_d_b = random.nextBoolean();
                boolean new_cs_l   = random.nextBoolean();
                boolean new_cs_avl = random.nextBoolean();
                long new_cs_limit_final = new_cs_g? new_cs_limit >> 12 : new_cs_limit;
                Descriptor cs_desc = new Descriptor((int)new_cs_base, (int)new_cs_limit_final, new_cs_type, new_cs_seg, new_cs_p, new_cs_dpl, new_cs_d_b, new_cs_g, new_cs_l, new_cs_avl);

System.out.printf("cs_desc: ");
for(int i=0; i<8; i++) System.out.printf("%02x ", cs_desc.get_byte(i));
System.out.printf("\n");

                final int old_cs_rpl_final = old_cs_rpl;
                Layer cs_rpl_layer = new Layer() {
                    long cs_rpl() { return old_cs_rpl_final; }
                };
                layers.addFirst(cs_rpl_layer);
                
                //----------
                index = tables.addDescriptor(is_ldt, cs_desc);
                if(index == -1) continue;

                index = index << 3;
                if(is_ldt) index |= 4;
                index |= new_cs_rpl;

                new_tss_selector = index;
                TestTaskSwitch.new_tss_selector = new_tss_selector;
                
                if(type == 0) {
                    layers.addFirst(tables);
                }
                
System.out.printf("cond: %d\n", cond);

                if(type >= 4) {
                    boolean is_ok = TestTaskSwitch.test(random, this, prohibited_list, TestTaskSwitch.Source.FROM_CALL, tss_desc, new_cs_rpl, tables, task_switch_type);
                    if(is_ok == false) continue;

                    tables              = TestTaskSwitch.tables;
                    new_tss_selector    = TestTaskSwitch.new_tss_selector;
                    old_tss_limit       = TestTaskSwitch.old_tss_limit;
                }
            }
                        
            //------------------------------------------------------------------
            //------------------------------------------------------------------
            
            long new_eip = 0;
            long new_cs  = new_tss_selector;
            
            if(type >= 1) {
                TSSCurrentLayer old_tss = new TSSCurrentLayer(random, old_tss_type, old_tss_limit, new_tss_selector, prohibited_list);
                layers.addFirst(old_tss);

                layers.addFirst(tables);
            }
            
            // instruction
            byte extra_bytes[] = null;
            
            boolean is_Ep = random.nextBoolean();
            
            if(is_Ep) {
                byte modregrm_bytes[] = EffectiveAddressLayerFactory.prepare(
                        o32? (((new_cs & 0xFFFF) << 32) | (new_eip & 0xFFFFFFFF)) : (((new_cs & 0xFFFF) << 16) | (new_eip & 0xFFFF)),
                        3, EffectiveAddressLayerFactory.modregrm_reg_t.SET,
                        o32? 6 : 4, a32,
                        layers, random, this, true, false);
                extra_bytes = modregrm_bytes;
            }
            else {
                long immediate = o32? (((new_cs & 0xFFFF) << 32) | (new_eip & 0xFFFFFFFF)) : (((new_cs & 0xFFFF) << 16) | (new_eip & 0xFFFF));
            
                byte imm_bytes[] = new byte[o32? 6 : 4];
                for(int i=0; i<imm_bytes.length; i++) {
                    imm_bytes[i] = (byte)(immediate & 0xFF);
                    immediate >>= 8;
                }
                extra_bytes = imm_bytes;
            }
            
            instruction = prepare_instr(cs_d_b, a32, o32, extra_bytes, is_Ep);
            instr.add_instruction(instruction);

            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }

    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32, byte extra_bytes[], boolean is_Ep) throws Exception {
        int opcodes[] = {
            0xFF, 0x9A
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