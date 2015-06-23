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
import ao486.test.layers.MemoryPatchLayer;
import ao486.test.layers.OtherLayer;
import ao486.test.layers.Pair;
import ao486.test.layers.SegmentLayer;
import ao486.test.layers.StackLayer;
import ao486.test.layers.TSSCurrentLayer;
import java.io.*;
import java.util.LinkedList;
import java.util.Random;


public class TestCALL_call_gate_more extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestCALL_call_gate_more.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(12+index);
        
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
            
            /* 0 - call gate valid check
             * 1 - cs valid check
             * 
             * 2 - tss length
             * 3 - ss selector null
             * 4 - ss selector out of bounds
             * 5 - ss descriptor check
             * 6 - stack limit
             * 7 - eip out of bounds
             * 
             * 8 - all ok
             */

            int type = random.nextInt(8+1);
            System.out.println("Preparing test with type: " + type);
            
            DescriptorTableLayer tables = new DescriptorTableLayer(random, prohibited_list, true);
            
            //------------------------------------------------------------------
            //------------------------------------------------------------------
            
            // prepare cs descriptor
            boolean is_cs_ldt = random.nextBoolean();

            boolean conds[] = new boolean[3];
            int cond = 1 << random.nextInt(conds.length);
            if(type >= 2) cond = 0;

            int     new_cs_rpl  = 0;
            boolean new_cs_seg  = false;
            int     new_cs_type = 0;
            int     new_cs_dpl  = 0;
            boolean new_cs_p    = false;
            int     old_cs_rpl  = 0;

            do {
                do {
                    new_cs_seg  = random.nextBoolean();
                    new_cs_type = random.nextInt(16);
                    new_cs_p    = random.nextBoolean();

                    new_cs_rpl  = random.nextInt(4);
                    new_cs_dpl  = random.nextInt(4);

                    old_cs_rpl  = random.nextInt(4);
                }
                while( (((new_cs_type >> 2) & 1) == 0 && new_cs_dpl < old_cs_rpl) == false ); //non-conforming
                
                conds[0] = new_cs_seg == false;
                conds[1] = ((new_cs_type >> 3) & 1) == 0;
                conds[2] = new_cs_p == false;
                //conds[3] = new_cs_dpl > old_cs_rpl; //not possible
            }
            while(!isAccepted(cond, conds[0],conds[1],conds[2]));

System.out.printf("cond cs: %d\n", cond);

            long new_cs_base, new_cs_limit;
            boolean new_cs_g;
            while(true) {
                new_cs_base = Layer.norm(random.nextInt());
                new_cs_g    = random.nextBoolean();

                new_cs_limit = random.nextInt(new_cs_g? 0xF : 0xFFFF);
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

System.out.printf("cs_desc: ");
for(int i=0; i<8; i++) System.out.printf("%02x ", cs_desc.get_byte(i));
System.out.printf("\n");

            //-------

            int index = -1;
            if(type == 1 && random.nextInt(5) == 0) {
                index = random.nextInt(4);
            }
            else if(type == 1 && random.nextInt(5) == 0) {
                index = tables.getOutOfBoundsIndex(is_cs_ldt);
                if(index == -1) continue;
                
                index <<= 3;
                if(is_cs_ldt) index |= 4;
                index |= new_cs_rpl;
            }
            else {
                index = tables.addDescriptor(is_cs_ldt, cs_desc);
                if(index == -1) continue;
                
                index <<= 3;
                if(is_cs_ldt) index |= 4;
                index |= new_cs_rpl;
            }
            int cs_selector = index;
            
            //--------------------------------------------------------------
            // prepare ss descriptor
            
            boolean is_ss_ldt = random.nextBoolean();

            conds = new boolean[5];
            cond = 1 << random.nextInt(conds.length);
            if(type >= 6) cond = 0;

            int     new_ss_rpl  = 0;
            boolean new_ss_seg  = false;
            int     new_ss_type = 0;
            int     new_ss_dpl  = 0;
            boolean new_ss_p    = false;

            do {
                new_ss_seg  = random.nextBoolean();
                new_ss_type = random.nextInt(16);

                new_ss_rpl  = random.nextInt(4);
                new_ss_dpl  = random.nextInt(4);
                new_ss_p    = random.nextBoolean();
                is_ss_ldt   = random.nextBoolean();
                
                if(type >= 7) new_ss_type &= 0xB; // not expand-down
                
                conds[0] = new_ss_rpl != new_cs_dpl;
                conds[1] = new_ss_dpl != new_cs_dpl;
                conds[2] = new_ss_seg == false;
                conds[3] = ((new_ss_type >> 3)&1) == 1 || (((new_ss_type >> 3)&1) == 0 && ((new_ss_type >> 1)&1) == 0); // code or (data && ro)
                conds[4] = new_ss_p == false;
            }
            while(!isAccepted(cond, conds[0],conds[1],conds[2],conds[3],conds[4]));

            long new_ss_base, new_ss_limit;
            boolean new_ss_g;
            while(true) {
                new_ss_base = Layer.norm(random.nextInt());
                new_ss_g    = random.nextBoolean();

                new_ss_limit = random.nextInt(new_ss_g? 0xF : 0xFFFF);
                if(new_ss_g) new_cs_limit = (new_ss_limit << 12) | 0xFFF;

                if( new_ss_base + new_ss_limit < 4294967296L &&
                    Layer.collides(prohibited_list, (int)new_ss_base, (int)(new_ss_base + new_ss_limit)) == false    
                ) break;
            }
            boolean new_ss_d_b = random.nextBoolean();
            boolean new_ss_l   = random.nextBoolean();
            boolean new_ss_avl = random.nextBoolean();
            long new_ss_limit_final = new_ss_g? new_ss_limit >> 12 : new_ss_limit;
            Descriptor ss_desc = new Descriptor((int)new_ss_base, (int)new_ss_limit_final, new_ss_type, new_ss_seg, new_ss_p, new_ss_dpl, new_ss_d_b, new_ss_g, new_ss_l, new_ss_avl);
            
System.out.printf("cond ss: %d\n", cond);
            
System.out.printf("ss_desc: ");
for(int i=0; i<8; i++) System.out.printf("%02x ", ss_desc.get_byte(i));
System.out.printf("\n");

            //---------------
            index = -1;
            if(type == 3) {
                index = random.nextInt(4);
            }
            else if(type == 4) {
                index = tables.getOutOfBoundsIndex(is_ss_ldt);
                if(index == -1) continue;
                
                index <<= 3;
                if(is_ss_ldt) index |= 4;
                index |= new_ss_rpl;
            }
            else {
                index = tables.addDescriptor(is_ss_ldt, ss_desc);
                if(index == -1) continue;
                
                index <<= 3;
                if(is_ss_ldt) index |= 4;
                index |= new_ss_rpl;
            }
            int ss_selector = index;
            
            //--------------------------------------------------------------
            // TSS segment contents
            
            int tss_type_val = random.nextInt(4);
            TSSCurrentLayer.Type tss_type =
                    (tss_type_val == 0)? TSSCurrentLayer.Type.ACTIVE_286 :
                    (tss_type_val == 1)? TSSCurrentLayer.Type.ACTIVE_386 :
                    (tss_type_val == 2)? TSSCurrentLayer.Type.BUSY_286 :
                                         TSSCurrentLayer.Type.BUSY_386;
            
            int tss_max_offset = (tss_type == TSSCurrentLayer.Type.ACTIVE_286 || tss_type == TSSCurrentLayer.Type.BUSY_286)? 2 + new_cs_dpl*4 + 4 : 4 + new_cs_dpl*8 + 8;
            
            int tss_limit = (type == 2)? random.nextInt(tss_max_offset-1) : tss_max_offset + random.nextInt(5);
            
            //Random random, TSSCurrentLayer.Type type, int limit, int selector, LinkedList<Pair<Long, Long>> prohibited_list
            TSSCurrentLayer current_tss = new TSSCurrentLayer(random, tss_type, tss_limit, random.nextInt(65536), prohibited_list);
            
            long new_esp =
                    (type == 6)? new_ss_limit + 1 + random.nextInt(5) : random.nextInt((new_ss_limit == 0)? 1 : (int)new_ss_limit);
            
            current_tss.add_ss_esp(new_cs_dpl, new_esp, ss_selector);
            
            layers.addFirst(current_tss);
            
            //--------------------------------------------------------------
            // prepare call gate descriptor

            boolean is_cg_ldt = random.nextBoolean();

            conds = new boolean[2];
            cond = 1 << random.nextInt(conds.length);
            if(type >= 1) cond = 0;

            int     new_cg_rpl  = 0;
            boolean new_cg_seg  = false;
            int     new_cg_type = 0;
            int     new_cg_dpl  = 0;
            boolean new_cg_p    = false;

            do {
                new_cg_seg  = false;
                new_cg_type = random.nextBoolean()? 0x4 : 0xc; //CALL_GATE 286,386

                new_cg_rpl  = random.nextInt(4);
                new_cg_dpl  = random.nextInt(4);
                new_cg_p    = random.nextBoolean();
                is_cg_ldt   = random.nextBoolean();

                if((cond & 1) == 1 && old_cs_rpl == 0) {
                    cond &= 0xFE;
                    cond |= 2;
                }

                conds[0] = new_cg_dpl < old_cs_rpl || new_cg_dpl < new_cg_rpl;
                conds[1] = new_cg_p == false;
            }
            while(!isAccepted(cond, conds[0],conds[1]));

            long new_cg_base  = (random.nextInt(32) << 16) | cs_selector;
            long new_cg_limit = Layer.norm(random.nextInt(0xFFFFF+1));
            boolean new_cg_g  = random.nextBoolean();

            boolean new_cg_d_b = random.nextBoolean();
            boolean new_cg_l   = random.nextBoolean();
            boolean new_cg_avl = random.nextBoolean();
            long new_cg_limit_final = new_cg_g? new_cg_limit >> 12 : new_cg_limit;
            Descriptor cg_desc = new Descriptor((int)new_cg_base, (int)new_cg_limit_final, new_cg_type, new_cg_seg, new_cg_p, new_cg_dpl, new_cg_d_b, new_cg_g, new_cg_l, new_cg_avl);

//------------
            final int old_cs_rpl_final = old_cs_rpl;
            Layer cs_rpl_layer = new Layer() {
                long cs_rpl() { return old_cs_rpl_final; }
            };
            layers.addFirst(cs_rpl_layer);

            // eip limit
            long eip = 0;
            if(type == 7) {
                while(true) {
                    eip = new_cs_limit + 1 + random.nextInt(10);

                    if(new_cg_type == 0x4) eip &= 0xFFFF;

                    if(eip > new_cs_limit) break;
                }
                if(new_cg_type == 0x4) eip |= (random.nextInt() & 0xFFFF0000);
            }
            else {
                while(true) {
                    eip = Layer.norm(random.nextInt((int)new_cs_limit+1));

                    if(new_cg_type == 0x4) eip &= 0xFFFF;

                    if(eip <= new_cs_limit) break;
                }
                long dest = new_cs_base + eip;
                // adding always possible
                MemoryPatchLayer patch = new MemoryPatchLayer(random, prohibited_list, (int)dest, 0x0F,0x0F);
                layers.addFirst(patch);

                if(new_cg_type == 0x4) eip |= (random.nextInt() & 0xFFFF0000);
            }
            cg_desc.set_dest_offset(eip);

System.out.printf("cg_desc: ");
for(int i=0; i<8; i++) System.out.printf("%02x ", cg_desc.get_byte(i));
System.out.printf("\n");
            
            //----------
            index = tables.addDescriptor(is_cg_ldt, cg_desc);
            if(index == -1) continue;

            index = index << 3;
            if(is_cg_ldt) index |= 4;
            index |= new_cg_rpl;

System.out.printf("cond cg: %d\n", cond);
            
            layers.addFirst(tables);
            
            //------------------------------------------------------------------
            //------------------------------------------------------------------
            
            long new_eip = 0;
            long new_cs  = index;
            
            // instruction
            byte extra_bytes[] = null;
            
            boolean is_Ep = random.nextBoolean();
            
            if(is_Ep) {
                byte modregrm_bytes[] = EffectiveAddressLayerFactory.prepare(
                        o32? (((new_cs & 0xFFFF) << 32) | (new_eip & 0xFFFFFFFFL)) : (((new_cs & 0xFFFF) << 16) | (new_eip & 0xFFFF)),
                        3, EffectiveAddressLayerFactory.modregrm_reg_t.SET,
                        o32? 6 : 4, a32,
                        layers, random, this, true, false);
//System.out.printf("extra_bytes length: %d, [0] = %x\n", modregrm_bytes.length, modregrm_bytes[0]);
                extra_bytes = modregrm_bytes;
            }
            else {
                long immediate = o32? (((new_cs & 0xFFFF) << 32) | (new_eip & 0xFFFFFFFFL)) : (((new_cs & 0xFFFF) << 16) | (new_eip & 0xFFFF));
            
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