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
import ao486.test.layers.TSSCurrentLayer;
import java.io.*;
import java.util.LinkedList;
import java.util.Random;


public class TestINT_INT3_INTO_INT1_int_trap_gate_more extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestINT_INT3_INTO_INT1_int_trap_gate_more.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(32 + index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            /* 0 - interrupt/trap gate valid check
             * 1 - cs valid check
             * 2 - v8086 condition
             * 
             * 3 - tss length
             * 4 - ss selector null
             * 5 - ss selector out of bounds
             * 6 - ss descriptor check
             * 7 - stack limit
             * 8 - eip out of bounds
             * 
             * 9 - all ok
             * 
             * TODO: push error test
             */
            
            int type = random.nextInt(10);
            
            boolean is_v8086 = (type == 2)? true : random.nextBoolean();
            boolean is_into = random.nextInt(3) == 0;
            boolean is_ib   = random.nextInt(3) == 0;
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            InstructionLayer instr = new InstructionLayer(random, prohibited_list);
            layers.add(instr);
            StackLayer stack = new StackLayer(random, prohibited_list);
            layers.add(stack);
            layers.add(new OtherLayer(OtherLayer.Type.PROTECTED_OR_V8086, random));
            layers.add(new FlagsLayer((is_v8086)? FlagsLayer.Type.V8086 : FlagsLayer.Type.NOT_V8086, random));
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
            

            instruction = prepare_instr(cs_d_b, a32, o32, is_into, is_ib);
            instr.add_instruction(instruction);
            
            //---------------
            
            DescriptorTableLayer tables = new DescriptorTableLayer(random, prohibited_list, true);
            
            //------------------------------------------------------------------
            //------------------------------------------------------------------
            
            // prepare cs descriptor
            boolean is_cs_ldt = random.nextBoolean();

            boolean conds[] = new boolean[4];
            int cond = 1 << random.nextInt(conds.length);
            if(type == 2) cond = 8;
            if(type >= 3) cond = 0;

            int     new_cs_rpl  = 0;
            boolean new_cs_seg  = false;
            int     new_cs_type = 0;
            int     new_cs_dpl  = 0;
            boolean new_cs_p    = false;
            int     old_cs_rpl  = 0;

            if( ((cond >> 3) & 1) == 1 && is_v8086 == false ) continue; 
            
            do {
                do {
                    new_cs_seg  = random.nextBoolean();
                    new_cs_type = random.nextInt(16);
                    new_cs_p    = random.nextBoolean();

                    new_cs_rpl  = random.nextInt(4);
                    new_cs_dpl  = random.nextInt(4);

                    old_cs_rpl  = (is_v8086)? 3 : random.nextInt(4);
                }
                while( (((new_cs_type >> 2) & 1) == 0 && new_cs_dpl < old_cs_rpl) == false ); //non-conforming
                
                conds[0] = new_cs_seg == false;
                conds[1] = ((new_cs_type >> 3) & 1) == 0;
                conds[2] = new_cs_p == false;
                //conds[3] = new_cs_dpl > old_cs_rpl; //not possible; checked in task gate test
                
                conds[3] = is_v8086 && new_cs_dpl != 0;
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
            if(type >= 7) cond = 0;

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
                
                if(type >= 8) new_ss_type &= 0xB; // not expand-down
                
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
                if(new_ss_g) new_ss_limit = (new_ss_limit << 12) | 0xFFF;

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
            if(type == 4) {
                index = random.nextInt(4);
            }
            else if(type == 5) {
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
            
            int tss_limit = (type == 3)? random.nextInt(tss_max_offset-1) : tss_max_offset + random.nextInt(5);
            
            //Random random, TSSCurrentLayer.Type type, int limit, int selector, LinkedList<Pair<Integer, Integer>> prohibited_list
            TSSCurrentLayer current_tss = new TSSCurrentLayer(random, tss_type, tss_limit, random.nextInt(65536), prohibited_list);
            
            long new_esp =
                    (type == 7)? new_ss_limit + 1 + random.nextInt(5) : random.nextInt((new_ss_limit == 0)? 1 : (int)new_ss_limit);
            
            current_tss.add_ss_esp(new_cs_dpl, new_esp, ss_selector);
            
            layers.addFirst(current_tss);
            
            
            //--------------------------------------------------------------
            // prepare interrupt trap gate descriptor

            conds = new boolean[4];
            cond = 1 << random.nextInt(conds.length);
            if(type >= 1) cond = 0;

            boolean new_gate_seg  = false;
            int     new_gate_type = 0;
            int     new_gate_dpl  = 0;
            boolean new_gate_p    = false;

            do {
                new_gate_type = random.nextInt(16); //TASK_GATE: 0x5, 0x6,0x7, 0xE,0xF

                new_gate_dpl  = random.nextInt(4);
                new_gate_p    = random.nextBoolean();
                new_gate_seg  = random.nextBoolean();
                
                if(((cond & 1) == 1) && old_cs_rpl == 0) {
                    cond &= 0xFE;
                    cond |= 1 << (1 + random.nextInt(conds.length-1));
                }
                
                conds[0] = new_gate_dpl < old_cs_rpl;
                conds[1] = new_gate_p == false;
                conds[2] = new_gate_seg == true;
                conds[3] = new_gate_type != 0x5 && new_gate_type != 0x6 && new_gate_type != 0x7 && new_gate_type != 0xE && new_gate_type != 0xF;
            }
            while(!isAccepted(cond, conds[0],conds[1],conds[2],conds[3]));
            
            int types[] = { 0x6,0x7,0xE,0xF };
            if(type >= 1) new_gate_type = types[random.nextInt(types.length)];

            long new_gate_base  = cs_selector;
            long new_gate_limit = Layer.norm(random.nextInt(0xFFFFF+1));
            boolean new_gate_g  = random.nextBoolean();

            boolean new_gate_d_b = random.nextBoolean();
            boolean new_gate_l   = random.nextBoolean();
            boolean new_gate_avl = random.nextBoolean();
            long new_gate_limit_final = new_gate_g? new_gate_limit >> 12 : new_gate_limit;
            Descriptor gate_desc = new Descriptor((int)new_gate_base, (int)new_gate_limit_final, new_gate_type, new_gate_seg, new_gate_p, new_gate_dpl, new_gate_d_b, new_gate_g, new_gate_l, new_gate_avl);

System.out.printf("idt_desc: ");
for(int i=0; i<8; i++) System.out.printf("%02x ", gate_desc.get_byte(i));
System.out.printf("\n");

            final int old_cs_rpl_final = old_cs_rpl;
            Layer cs_rpl_layer = new Layer() {
                long cs_rpl() { return old_cs_rpl_final; }
            };
            layers.addFirst(cs_rpl_layer);

            //---------- prepare IDT and IDTR
            final int idtr_limit = vector * 8 + 7 + 1 + random.nextInt(5);
            Layer idtr_limit_layer = new Layer() {
                long idtr_limit() { return idtr_limit; }
            };
            layers.addFirst(idtr_limit_layer);

            // set idtr base
            long idtr_base;
            while(true) {
                idtr_base = Layer.norm(random.nextInt());

                if( idtr_base + idtr_limit < 4294967296L &&
                    Layer.collides(prohibited_list, (int)idtr_base, (int)(idtr_base + idtr_limit)) == false    
                ) break;
            }
            prohibited_list.add(new Pair<>(idtr_base, idtr_base + idtr_limit));

            final long idtr_base_final = idtr_base;
            Layer idtr_base_layer = new Layer() {
                long idtr_base() { return idtr_base_final; }
            };
            layers.addFirst(idtr_base_layer);

            
            // eip limit
            long eip = 0;
            if(type == 8) {
                while(true) {
                    eip = new_cs_limit + 1 + random.nextInt(10);

                    if(new_gate_type < 0xE) eip &= 0xFFFF;

                    if(eip > new_cs_limit) break;
                }
                if(new_gate_type < 0xE) eip |= (random.nextInt() & 0xFFFF0000);
System.out.printf("eip: %08x, new_cs_limit: %08x, 286: %b\n", eip, new_cs_limit, new_gate_type < 0xE);
            }
            else {
                while(true) {
                    eip = Layer.norm(random.nextInt((int)new_cs_limit+1));

                    if(new_gate_type < 0xE) eip &= 0xFFFF;

                    if(eip <= new_cs_limit) break;
                }
                long dest = new_cs_base + eip;
                // adding always possible
                MemoryPatchLayer patch = new MemoryPatchLayer(random, prohibited_list, (int)dest, 0x0F,0x0F);
                layers.addFirst(patch);

                if(new_gate_type < 0xE) eip |= (random.nextInt() & 0xFFFF0000);
            }
            gate_desc.set_dest_offset(eip);
            
            // idt table entry
            MemoryPatchLayer int_patch = new MemoryPatchLayer(random, prohibited_list, (int)(idtr_base + 8*vector),
                    gate_desc.get_byte(0), gate_desc.get_byte(1), gate_desc.get_byte(2), gate_desc.get_byte(3),
                    gate_desc.get_byte(4), gate_desc.get_byte(5), gate_desc.get_byte(6), gate_desc.get_byte(7));
            layers.addFirst(int_patch);

            
System.out.printf("cond idt: %d, is_ib: %b\n", cond, is_ib);

            layers.addFirst(tables);
            
            //-------------------
            
            if(is_into) {
                Layer of_layer = new Layer() {
                    long oflag() { return 1; }
                };
                layers.addFirst(of_layer);
            }
            if(is_v8086) {
                Layer iopl_layer = new Layer() {
                    long iopl() { return 3; }
                };
                layers.addFirst(iopl_layer);
            }
            
            //------------------------------------------------------------------
            //------------------------------------------------------------------
            
            
            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }

    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32, boolean is_into, boolean is_ib) throws Exception {
        int opcodes[] = {
            0xCC,0xF1,0xCD,0xCE
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        int opcode = opcodes[(is_into)? 3 : (is_ib)? 2 : random.nextInt(3)];
        
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