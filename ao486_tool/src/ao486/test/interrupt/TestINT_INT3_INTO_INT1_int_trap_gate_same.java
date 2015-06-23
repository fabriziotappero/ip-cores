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
import java.io.*;
import java.util.LinkedList;
import java.util.Random;


public class TestINT_INT3_INTO_INT1_int_trap_gate_same extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestINT_INT3_INTO_INT1_int_trap_gate_same.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(21 + index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            /* 
             * 0 - pre-(interrupt, trap gate) valid check
             * 1 - cs_selector NULL
             * 2 - cs_selector out of bounds
             * 3 - cs_descriptor valid check
             * 4 - cs_descriptor -- v8086 mode active
             * 5 - eip out of bounds
             * 
             * 6 - all ok
             * 
             * TODO error code push test
             */
            
            int type = random.nextInt(7);
            
            boolean is_v8086 = (type == 4)? true : random.nextBoolean();
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
            
            DescriptorTableLayer tables = null;
            
            //------------------------------------------------------------------
            //------------------------------------------------------------------
            
            // prepare cs descriptor
            boolean is_cs_ldt = (type == 1)? false : random.nextBoolean();

            boolean conds[] = new boolean[5];
            int cond = 1 << random.nextInt(conds.length);
            if(type >= 5) cond = 0;

            int     new_cs_rpl  = 0;
            boolean new_cs_seg  = false;
            int     new_cs_type = 0;
            int     new_cs_dpl  = 0;
            boolean new_cs_p    = false;
            int     old_cs_rpl  = 0;
            
            if( ((cond >> 4) & 1) == 1 && is_v8086 == false ) continue; 
            if( ((cond >> 4) & 1) == 0 && is_v8086 == true ) continue; 
            
            do {
                do {
                    new_cs_seg  = random.nextBoolean();
                    new_cs_type = random.nextInt(16);
                    new_cs_p    = random.nextBoolean();

                    new_cs_rpl  = random.nextInt(4);
                    new_cs_dpl  = random.nextInt(4);

                    old_cs_rpl  = (is_v8086)? 3 : random.nextInt(4);
                }
                while(((new_cs_type >> 2) & 1) == 0 && new_cs_dpl < old_cs_rpl); //non-conforming
                
                conds[0] = new_cs_seg == false;
                conds[1] = ((new_cs_type >> 3) & 1) == 0; //data
                conds[2] = new_cs_dpl > old_cs_rpl;
                conds[3] = new_cs_p == false;
                
                conds[4] = is_v8086 && ( ((new_cs_type >> 2) & 1) == 1 || new_cs_dpl != 0 );
            }
            while(!isAccepted(cond, conds[0],conds[1],conds[2],conds[3],conds[4]));

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

            long new_gate_base  = index;
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
            if(type == 5) {
                while(true) {
                    eip = new_cs_limit + 1 + random.nextInt(10);

                    if(new_gate_type < 0xE) eip &= 0xFFFF;

                    if(eip > new_cs_limit) break;
                }
                if(new_gate_type < 0xE) eip |= (random.nextInt() & 0xFFFF0000);
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