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
import java.io.*;
import java.util.LinkedList;
import java.util.Random;


public class TestCALL_call_gate_same extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestCALL_call_gate_same.class);
    }
    
    public TestCALL_call_gate_same() {
        
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(16+index);
        
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
             * 0 - pre-(call gate) valid check
             * 1 - cs_selector NULL
             * 2 - cs_selector out of bounds
             * 3 - cs_descriptor valid check
             * 4 - eip out of bounds
             * 
             * 5 - all ok
             */

            int type = random.nextInt(6);
            System.out.println("Running test type: " + type);
            
            DescriptorTableLayer tables = null;
            
            //------------------------------------------------------------------
            //------------------------------------------------------------------
            
            // prepare cs descriptor
            boolean is_cs_ldt = (type == 1)? false : random.nextBoolean();

            boolean conds[] = new boolean[4];
            int cond = 1 << random.nextInt(conds.length);
            if(type >= 4) cond = 0;

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
                while(((new_cs_type >> 2) & 1) == 0 && new_cs_dpl < old_cs_rpl); //non-conforming
                
                conds[0] = new_cs_seg == false;
                conds[1] = ((new_cs_type >> 3) & 1) == 0;
                conds[2] = new_cs_dpl > old_cs_rpl;
                conds[3] = new_cs_p == false;
            }
            while(!isAccepted(cond, conds[0],conds[1],conds[2],conds[3]));

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
            tables = new DescriptorTableLayer(random, prohibited_list, true);

            int index = -1;
            if(type == 1) {
                index = random.nextInt(4);
            }
            else if(type == 2) {
                index = tables.getOutOfBoundsIndex(is_cs_ldt);
                if(index == -1) continue;  
            }
            else {
                index = tables.addDescriptor(is_cs_ldt, cs_desc);
                if(index == -1) continue;
            }
            
            if(type != 1) {
                index <<= 3;
                if(is_cs_ldt) index |= 4;
                index |= new_cs_rpl;
            }

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

            long new_cg_base  = index;
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
            if(type == 4) {
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