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
import ao486.test.layers.Layer;
import ao486.test.layers.MemoryPatchLayer;
import ao486.test.layers.Pair;
import ao486.test.layers.TSSCurrentLayer;
import java.util.LinkedList;
import java.util.Random;

public class TestTaskSwitch {
    
    public static enum Source {
        FROM_IRET,
        FROM_CALL,
        FROM_JUMP,
        FROM_INT
    }
    
   /*
    * 3 - new TSS limit (not in CALL_task_gate)
    * 4 - old TSS limit
    * 
    * 5 - LDT TI
    * 6 - LDT out of index
    * 7 - invalid LDT descriptor
    * 
    * 8 - v8086 mode, eip invalid
    * 9 - v8086 mode, eip ok
    * 
    * 10 - SS null
    * 11 - SS out of bounds
    * 12 - SS descriptor invalid
    * 
    * 13 - DS out of bounds
    * 14 - DS descriptor invalid
    * 
    * 15 - ES out of bounds
    * 16 - ES descriptor invalid
    * 
    * 17 - FS out of bounds
    * 18 - FS descriptor invalid
    * 
    * 19 - GS out of bounds
    * 20 - GS descriptor invalid
    * 
    * 21 - CS null
    * 22 - CS out of bounds
    * 23 - CS invalid descriptor
    * 
    * 24 - eip out of bounds
    * 
    * 25 - all ok
    * 
    * 26 - task debug
    */

    
    public static int new_tss_selector;
    public static int old_tss_limit;
    public static DescriptorTableLayer tables;
    
    public static boolean test(Random random, TestUnit test, LinkedList<Pair<Long, Long>> prohibited_list, Source source,
            TestUnit.Descriptor tss_desc,
            int new_tss_rpl,
            DescriptorTableLayer tables,
            int test_type) throws Exception {
        
//TODO: test translate_linear
//TODO: test T trap bit  
//TODO: push error
        
        int type = (test_type == -1)? 3+ random.nextInt(25+1-3) : test_type;

System.out.println("Task type: " + type);

        old_tss_limit = 0xFFFF;
        TestTaskSwitch.tables = tables;
        
        TSSCurrentLayer.Type old_tss_type = random.nextBoolean()? TSSCurrentLayer.Type.BUSY_286 : TSSCurrentLayer.Type.BUSY_386;
        
        if(type == 3) {
            
            tss_desc.g = false;
            
            tss_desc.limit = 
                       (tss_desc.type == (source == Source.FROM_IRET? 0x3 : 0x1))?  0x2B - 3 + random.nextInt(3) :
                                                                                    0x67 - 3 + random.nextInt(3);  

            if(tables == null) {
                tables = new DescriptorTableLayer(random, prohibited_list, true);
                TestTaskSwitch.tables = tables;
                new_tss_selector = tables.addDescriptor(false, tss_desc);
                if(new_tss_selector == -1) return false;

                //copy
                new_tss_selector <<= 3;
                new_tss_selector |= new_tss_rpl;
System.out.printf("[task_switch: new_tss_selector: %x\n", new_tss_selector);
            }
        }
        else if(type >= 4) {
            
            int     new_tss_type    = tss_desc.type;
            long    new_tss_base    = Layer.norm(tss_desc.base);
            
            boolean conds[]         = new boolean[0];
            int     cond            = 0;
            
            if(tables == null) {
                tables = new DescriptorTableLayer(random, prohibited_list, true);
                TestTaskSwitch.tables = tables;
                new_tss_selector = tables.addDescriptor(false, tss_desc);
                if(new_tss_selector == -1) return false;

                //copy
                new_tss_selector <<= 3;
                new_tss_selector |= new_tss_rpl;
            }
            
            if(type == 4) {
                old_tss_limit =
                        (old_tss_type == TSSCurrentLayer.Type.BUSY_286)?    0x29 - 3 + random.nextInt(3) :
                                                                            0x5F - 3 + random.nextInt(3);
            }
            else if(type == 5) {
                long address = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 42 : 96);

                int ldt_selector = random.nextInt(65536);
                ldt_selector |= 4;

                MemoryPatchLayer ldt_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)address, (ldt_selector & 0xFF), ((ldt_selector>>8) & 0xFF));
                test.layers.addFirst(ldt_selector_patch);
            }
            else if(type == 6) {
                long address = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 42 : 96);

                int ldt_selector = tables.getOutOfBoundsIndex(false);
                if(ldt_selector == -1) return false;

                ldt_selector <<= 3;
                ldt_selector |= random.nextInt(0x8);
                ldt_selector &= 0xFFFB;

                MemoryPatchLayer ldt_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)address, (ldt_selector & 0xFF), ((ldt_selector>>8) & 0xFF));
                test.layers.addFirst(ldt_selector_patch);
            }
            else if(type >= 7) {

                boolean is_new_ldt_null = random.nextInt(4) == 0 && type >= 8;
                int ldt_selector = random.nextInt(4);
                long new_ldt_base = 0, new_ldt_limit = 0;

                if(is_new_ldt_null == false) {
                    conds= new boolean[3];
                    cond = (type == 7)? 1 << random.nextInt(conds.length) : 0;

                    boolean new_ldt_seg  = false;
                    int     new_ldt_type = 0;
                    boolean new_ldt_p    = false;

                    int     new_ldt_dpl  = random.nextInt(4);
                    boolean new_ldt_d_b  = random.nextBoolean();
                    boolean new_ldt_l    = random.nextBoolean();
                    boolean new_ldt_avl  = random.nextBoolean();
                    int     new_ldt_rpl  = random.nextInt(4);

                    do {
                        new_ldt_seg = random.nextBoolean();
                        new_ldt_type= random.nextInt(16);
                        new_ldt_p   = random.nextBoolean();

                        conds[0] = new_ldt_seg;
                        conds[1] = new_ldt_type != 0x2; // ldt
                        conds[2] = new_ldt_p == false;
                    }
                    while(!test.isAccepted(cond, conds[0],conds[1],conds[2]));

                    //---------
                    boolean new_ldt_g;
                    while(true) {
                        new_ldt_base = Layer.norm(random.nextInt());
                        new_ldt_g    = false;

                        new_ldt_limit = random.nextInt(new_ldt_g? 0xF+1 : 0xFFFF + 1);
                        if(new_ldt_g) new_ldt_limit = (new_ldt_limit << 12) | 0xFFF;

                        if(new_ldt_g) new_ldt_limit = (new_ldt_limit << 12) | 0xFFF;

                        if( new_ldt_base + new_ldt_limit < 4294967296L &&
                            Layer.collides(prohibited_list, (int)new_ldt_base, (int)(new_ldt_base + new_ldt_limit)) == false)   
                        {
                            prohibited_list.add(new Pair<>(new_ldt_base, new_ldt_base + new_ldt_limit));
                            break;
                        }
                    }

                    long new_ldt_limit_final = new_ldt_g? new_ldt_limit >> 12 : new_ldt_limit;

                    TestUnit.Descriptor ldt_desc = new TestUnit.Descriptor((int)new_ldt_base, (int)new_ldt_limit_final, new_ldt_type, new_ldt_seg, new_ldt_p, new_ldt_dpl, new_ldt_d_b, new_ldt_g, new_ldt_l, new_ldt_avl);

                    ldt_selector = tables.addDescriptor(false, ldt_desc);
                    if(ldt_selector == -1) return false;

                    ldt_selector <<= 3;
                    ldt_selector |= new_ldt_rpl;
                }

                long ldt_offset = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 42 : 96);

                MemoryPatchLayer ldt_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)ldt_offset, (ldt_selector & 0xFF), ((ldt_selector>>8) & 0xFF));
                test.layers.addFirst(ldt_selector_patch);
                
                if(type == 7) {
                    // nothing
                }
                else if(type >= 8) {

                    if(new_tss_type == (source == Source.FROM_IRET? 0xB : 0x9)) {
                        // set trap to zero
                        long trap_offset = new_tss_base + 100;
                        MemoryPatchLayer trap_patch = new MemoryPatchLayer(random, prohibited_list, (int)trap_offset,
                                0,0);
                        test.layers.addFirst(trap_patch);
                    }

                    // set eflags
                    long eflags_offset = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 16 : 36);

                    long eflags = Layer.norm(random.nextInt());
                    // set vm flag
                    if(type == 8 || type == 9)  eflags |= 0x20000;
                    else                        eflags &= 0xFFFDFFFF;

                    if(new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1)) {
                        MemoryPatchLayer elfags_patch = new MemoryPatchLayer(random, prohibited_list, (int)eflags_offset,
                                (int)(eflags & 0xFF), (int)((eflags>>8) & 0xFF));
                        test.layers.addFirst(elfags_patch);
                    }
                    else {
                        MemoryPatchLayer elfags_patch = new MemoryPatchLayer(random, prohibited_list, (int)eflags_offset,
                                (int)(eflags & 0xFF), (int)((eflags>>8) & 0xFF), (int)((eflags>>16) & 0xFF), (int)((eflags>>24) & 0xFF));
                        test.layers.addFirst(elfags_patch);
                    }

                    if(type == 8 || type == 9) {
                        // always new tss is 386

                        // set cs
                        long cs_offset = new_tss_base + 76;

                        long new_cs_base, new_cs_limit;
                        while(true) {
                            new_cs_base = Layer.norm(random.nextInt(65536));
                            new_cs_base <<= 4;
                            new_cs_limit = 0xFFFF;

                            if( new_cs_base + new_cs_limit < 4294967296L &&
                                Layer.collides(prohibited_list, (int)new_cs_base, (int)(new_cs_base + new_cs_limit)) == false)   
                            {
                                prohibited_list.add(new Pair<>(new_cs_base, new_cs_base + new_cs_limit));
                                break;
                            }
                        }
                        MemoryPatchLayer cs_patch = new MemoryPatchLayer(random, prohibited_list, (int)cs_offset,
                                (int)((new_cs_base >> 4) & 0xFF), (int)((new_cs_base>>12) & 0xFF));
                        test.layers.addFirst(cs_patch);

                        // set eip
                        long eip_offset = new_tss_base + 32;

                        long eip = (type == 9)? random.nextInt(0xFFFF) : 0xFFFF + 1 + random.nextInt(5);

                        MemoryPatchLayer eip_patch = new MemoryPatchLayer(random, prohibited_list, (int)eip_offset,
                                (int)(eip & 0xFF), (int)((eip>>8) & 0xFF), (int)((eip>>16) & 0xFF), (int)((eip>>24) & 0xFF));
                        test.layers.addFirst(eip_patch);

                        if(type == 9) {
                            MemoryPatchLayer instr_patch = new MemoryPatchLayer(random, prohibited_list, (int)(new_cs_base + eip),
                                0x0F, 0x0F);
                            test.layers.addFirst(instr_patch);
                        }
                    }
                    else if(type == 10) {
                        long address = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 38 : 80);

                        int ss_selector = random.nextInt(4);

                        MemoryPatchLayer ss_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)address, (ss_selector & 0xFF), ((ss_selector>>8) & 0xFF));
                        test.layers.addFirst(ss_selector_patch);
                    }
                    else if(type == 11) {
                        boolean is_ss_ldt = is_new_ldt_null == false && random.nextBoolean();

                        if(is_ss_ldt) {
                            tables.setup_new_ldt((int)new_ldt_base, (int)new_ldt_limit);
                        }

                        int new_ss_selector = tables.getOutOfBoundsIndex(is_ss_ldt);
                        if(new_ss_selector == -1) return false;

                        new_ss_selector <<= 3;
                        new_ss_selector |= (is_ss_ldt)? 4 : 0;
                        new_ss_selector |= random.nextInt(4);

                        long address = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 38 : 80);

                        MemoryPatchLayer ss_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)address, (new_ss_selector & 0xFF), ((new_ss_selector>>8) & 0xFF));
                        test.layers.addFirst(ss_selector_patch);
                    }
                    else if(type >= 12) {
                        boolean is_ss_ldt = is_new_ldt_null == false && random.nextBoolean();

                        if(is_ss_ldt) {
                            tables.setup_new_ldt((int)new_ldt_base, (int)new_ldt_limit);
                        }

                        int new_cs_rpl = random.nextInt(4);

                        conds= new boolean[6];
                        cond = (type == 12)? 1 << random.nextInt(conds.length) : 0;

                        boolean new_ss_seg  = false;
                        int     new_ss_type = 0;
                        boolean new_ss_p    = false;
                        int     new_ss_dpl  = 0;
                        int     new_ss_rpl  = 0;

                        boolean new_ss_d_b  = random.nextBoolean();
                        boolean new_ss_l    = random.nextBoolean();
                        boolean new_ss_avl  = random.nextBoolean();
                        int     new_ss_limit= random.nextInt(65536);
                        int     new_ss_base = random.nextInt(65536);
                        boolean new_ss_g    = random.nextBoolean();

                        do {
                            new_ss_seg = random.nextBoolean();
                            new_ss_type= random.nextInt(16);
                            new_ss_p   = random.nextBoolean();
                            new_ss_dpl = random.nextInt(4);
                            new_ss_rpl = random.nextInt(4);

                            conds[0] = new_ss_seg == false;
                            conds[1] = (new_ss_type >> 3) == 1; // code segment
                            conds[2] = (new_ss_type >> 3) == 0 && ((new_ss_type >> 1)&1) == 0; // data segment and not writable
                            conds[3] = new_ss_p == false;
                            conds[4] = new_ss_dpl != new_cs_rpl;
                            conds[5] = new_ss_dpl != new_ss_rpl;
                        }
                        while(!test.isAccepted(cond, conds[0],conds[1],conds[2],conds[3],conds[4],conds[5]));

                        TestUnit.Descriptor ss_desc = new TestUnit.Descriptor((int)new_ss_base, (int)new_ss_limit, new_ss_type, new_ss_seg, new_ss_p, new_ss_dpl, new_ss_d_b, new_ss_g, new_ss_l, new_ss_avl);

                        int ss_selector = tables.addDescriptor(is_ss_ldt, ss_desc);
                        if(ss_selector == -1) return false;

                        ss_selector <<= 3;
                        ss_selector |= new_ss_rpl;
                        if(is_ss_ldt) ss_selector |= 4;

                        long ss_address = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 38 : 80);

                        MemoryPatchLayer ss_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)ss_address, (ss_selector & 0xFF), ((ss_selector>>8) & 0xFF));
                        test.layers.addFirst(ss_selector_patch);

                        // cs selector
                        // set cs
                        long cs_offset = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 36 : 76);

                        int new_cs_selector = (type >= 17 && type <= 21)? 0 : random.nextInt(65536);
                        new_cs_selector &= 0xFFFC;
                        new_cs_selector |= new_cs_rpl;

                        MemoryPatchLayer cs_patch = new MemoryPatchLayer(random, prohibited_list, (int)cs_offset,
                                (int)((new_cs_selector >> 0) & 0xFF), (int)((new_cs_selector>>8) & 0xFF));
                        test.layers.addFirst(cs_patch);
                        
                        if(type == 12) {
                            // nothing
                        }
                        else if(type == 13) {
                            boolean is_ds_ldt = is_new_ldt_null == false && random.nextBoolean();

                            if(is_ds_ldt) {
                                tables.setup_new_ldt((int)new_ldt_base, (int)new_ldt_limit);
                            }

                            long ds_offset = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 40 : 84);

                            int new_ds_selector = tables.getOutOfBoundsIndex(is_ds_ldt);
                            if(new_ds_selector == -1) return false;

                            new_ds_selector <<= 3;
                            new_ds_selector |= (is_ds_ldt)? 4 : 0;
                            new_ds_selector |= random.nextInt(4);

                            MemoryPatchLayer ds_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)ds_offset, (new_ds_selector & 0xFF), ((new_ds_selector>>8) & 0xFF));
                            test.layers.addFirst(ds_selector_patch);
                        }
                        else if(type >= 14) {
                            boolean is_ds_null = random.nextInt(10) == 0;
                            int ds_selector = random.nextInt(4);

                            if(is_ds_null == false) {
                                boolean is_ds_ldt = is_new_ldt_null == false && random.nextBoolean();

                                if(is_ds_ldt) {
                                    tables.setup_new_ldt((int)new_ldt_base, (int)new_ldt_limit);
                                }

                                conds= new boolean[4];
                                cond = (type == 14)? 1 << random.nextInt(conds.length) : 0;

                                boolean new_ds_seg  = false;
                                int     new_ds_type = 0;
                                boolean new_ds_p    = false;
                                int     new_ds_dpl  = 0;
                                int     new_ds_rpl  = 0;

                                boolean new_ds_d_b  = random.nextBoolean();
                                boolean new_ds_l    = random.nextBoolean();
                                boolean new_ds_avl  = random.nextBoolean();
                                int     new_ds_limit= random.nextInt(65536);
                                int     new_ds_base = random.nextInt(65536);
                                boolean new_ds_g    = random.nextBoolean();

                                do {
                                    new_ds_seg = random.nextBoolean();
                                    new_ds_type= random.nextInt(16);
                                    new_ds_p   = random.nextBoolean();
                                    new_ds_dpl = random.nextInt(4);
                                    new_ds_rpl = random.nextInt(4);

                                    conds[0] = new_ds_seg == false;
                                    conds[1] = (new_ds_type >> 3) == 1 && ((new_ds_type >> 1)&1) == 0; // code segment and not readable
                                    conds[2] = ((new_ds_type >> 3) == 0 || ((new_ds_type >> 2)&1) == 0) && (new_ds_rpl > new_ds_dpl || new_cs_rpl > new_ds_dpl); // (data segment or code non conforming)
                                    conds[3] = new_ds_p == false;
                                }
                                while(!test.isAccepted(cond, conds[0],conds[1],conds[2],conds[3]));

                                TestUnit.Descriptor ds_desc = new TestUnit.Descriptor((int)new_ds_base, (int)new_ds_limit, new_ds_type, new_ds_seg, new_ds_p, new_ds_dpl, new_ds_d_b, new_ds_g, new_ds_l, new_ds_avl);

                                ds_selector = tables.addDescriptor(is_ds_ldt, ds_desc);
                                if(ds_selector == -1) return false;

                                ds_selector <<= 3;
                                ds_selector |= new_ds_rpl;
                                if(is_ds_ldt) ds_selector |= 4;
                            }

                            long ds_offset = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 40 : 84);

                            MemoryPatchLayer ds_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)ds_offset, (ds_selector & 0xFF), ((ds_selector>>8) & 0xFF));
                            test.layers.addFirst(ds_selector_patch);

                            if(type == 15) {
                                boolean is_es_ldt = is_new_ldt_null == false && random.nextBoolean();

                                if(is_es_ldt) {
                                    tables.setup_new_ldt((int)new_ldt_base, (int)new_ldt_limit);
                                }

                                long es_offset = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 34 : 72);

                                int new_es_selector = tables.getOutOfBoundsIndex(is_es_ldt);
                                if(new_es_selector == -1) return false;

                                new_es_selector <<= 3;
                                new_es_selector |= (is_es_ldt)? 4 : 0;
                                new_es_selector |= random.nextInt(4);

                                MemoryPatchLayer es_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)es_offset, (new_es_selector & 0xFF), ((new_es_selector>>8) & 0xFF));
                                test.layers.addFirst(es_selector_patch);
                            }
                            else if(type >= 16) {
                                boolean is_es_null = random.nextInt(10) == 0;
                                int es_selector = random.nextInt(4);

                                if(is_es_null == false) {
                                    boolean is_es_ldt = is_new_ldt_null == false && random.nextBoolean();

                                    if(is_es_ldt) {
                                        tables.setup_new_ldt((int)new_ldt_base, (int)new_ldt_limit);
                                    }

                                    conds= new boolean[4];
                                    cond = (type == 16)? 1 << random.nextInt(conds.length) : 0;

                                    boolean new_es_seg  = false;
                                    int     new_es_type = 0;
                                    boolean new_es_p    = false;
                                    int     new_es_dpl  = 0;
                                    int     new_es_rpl  = 0;

                                    boolean new_es_d_b  = random.nextBoolean();
                                    boolean new_es_l    = random.nextBoolean();
                                    boolean new_es_avl  = random.nextBoolean();
                                    int     new_es_limit= random.nextInt(65536);
                                    int     new_es_base = random.nextInt(65536);
                                    boolean new_es_g    = random.nextBoolean();

                                    do {
                                        new_es_seg = random.nextBoolean();
                                        new_es_type= random.nextInt(16);
                                        new_es_p   = random.nextBoolean();
                                        new_es_dpl = random.nextInt(4);
                                        new_es_rpl = random.nextInt(4);

                                        conds[0] = new_es_seg == false;
                                        conds[1] = (new_es_type >> 3) == 1 && ((new_es_type >> 1)&1) == 0; // code segment and not readable
                                        conds[2] = ((new_es_type >> 3) == 0 || ((new_es_type >> 2)&1) == 0) && (new_es_rpl > new_es_dpl || new_cs_rpl > new_es_dpl); // (data segment or code non conforming)
                                        conds[3] = new_es_p == false;
                                    }
                                    while(!test.isAccepted(cond, conds[0],conds[1],conds[2],conds[3]));

                                    TestUnit.Descriptor es_desc = new TestUnit.Descriptor((int)new_es_base, (int)new_es_limit, new_es_type, new_es_seg, new_es_p, new_es_dpl, new_es_d_b, new_es_g, new_es_l, new_es_avl);

                                    es_selector = tables.addDescriptor(is_es_ldt, es_desc);
                                    if(es_selector == -1) return false;

                                    es_selector <<= 3;
                                    es_selector |= new_es_rpl;
                                    if(is_es_ldt) es_selector |= 4;
                                }

                                long es_offset = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 34 : 72);

                                MemoryPatchLayer es_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)es_offset, (es_selector & 0xFF), ((es_selector>>8) & 0xFF));
                                test.layers.addFirst(es_selector_patch);

                                if(type == 17) {
                                    if(new_tss_type == (source == Source.FROM_IRET? 0xB : 0x9)) {
                                        boolean is_fs_ldt = is_new_ldt_null == false && random.nextBoolean();

                                        if(is_fs_ldt) {
                                            tables.setup_new_ldt((int)new_ldt_base, (int)new_ldt_limit);
                                        }

                                        long fs_offset = new_tss_base + 88;

                                        int new_fs_selector = tables.getOutOfBoundsIndex(is_fs_ldt);
                                        if(new_fs_selector == -1) return false;

                                        new_fs_selector <<= 3;
                                        new_fs_selector |= (is_fs_ldt)? 4 : 0;
                                        new_fs_selector |= random.nextInt(4);

                                        MemoryPatchLayer fs_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)fs_offset, (new_fs_selector & 0xFF), ((new_fs_selector>>8) & 0xFF));
                                        test.layers.addFirst(fs_selector_patch);
                                    }
                                }
                                else if(type >= 18) {
                                    boolean is_fs_null = random.nextInt(10) == 0;
                                    int fs_selector = random.nextInt(4);

                                    if(is_fs_null == false && new_tss_type == (source == Source.FROM_IRET? 0xB : 0x9)) {
                                        boolean is_fs_ldt = is_new_ldt_null == false && random.nextBoolean();

                                        if(is_fs_ldt) {
                                            tables.setup_new_ldt((int)new_ldt_base, (int)new_ldt_limit);
                                        }

                                        conds= new boolean[4];
                                        cond = (type == 18)? 1 << random.nextInt(conds.length) : 0;

                                        boolean new_fs_seg  = false;
                                        int     new_fs_type = 0;
                                        boolean new_fs_p    = false;
                                        int     new_fs_dpl  = 0;
                                        int     new_fs_rpl  = 0;

                                        boolean new_fs_d_b  = random.nextBoolean();
                                        boolean new_fs_l    = random.nextBoolean();
                                        boolean new_fs_avl  = random.nextBoolean();
                                        int     new_fs_limit= random.nextInt(65536);
                                        int     new_fs_base = random.nextInt(65536);
                                        boolean new_fs_g    = random.nextBoolean();

                                        do {
                                            new_fs_seg = random.nextBoolean();
                                            new_fs_type= random.nextInt(16);
                                            new_fs_p   = random.nextBoolean();
                                            new_fs_dpl = random.nextInt(4);
                                            new_fs_rpl = random.nextInt(4);

                                            conds[0] = new_fs_seg == false;
                                            conds[1] = (new_fs_type >> 3) == 1 && ((new_fs_type >> 1)&1) == 0; // code segment and not readable
                                            conds[2] = ((new_fs_type >> 3) == 0 || ((new_fs_type >> 2)&1) == 0) && (new_fs_rpl > new_fs_dpl || new_cs_rpl > new_fs_dpl); // (data segment or code non conforming)
                                            conds[3] = new_fs_p == false;
                                        }
                                        while(!test.isAccepted(cond, conds[0],conds[1],conds[2],conds[3]));

                                        TestUnit.Descriptor fs_desc = new TestUnit.Descriptor((int)new_fs_base, (int)new_fs_limit, new_fs_type, new_fs_seg, new_fs_p, new_fs_dpl, new_fs_d_b, new_fs_g, new_fs_l, new_fs_avl);

                                        fs_selector = tables.addDescriptor(is_fs_ldt, fs_desc);
                                        if(fs_selector == -1) return false;

                                        fs_selector <<= 3;
                                        fs_selector |= new_fs_rpl;
                                        if(is_fs_ldt) fs_selector |= 4;
                                    }

                                    long fs_offset = new_tss_base + 88;

                                    MemoryPatchLayer fs_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)fs_offset, (fs_selector & 0xFF), ((fs_selector>>8) & 0xFF));
                                    test.layers.addFirst(fs_selector_patch);

                                    if(type == 19) {
                                        if(new_tss_type == (source == Source.FROM_IRET? 0xB : 0x9)) {
                                            boolean is_gs_ldt = is_new_ldt_null == false && random.nextBoolean();

                                            if(is_gs_ldt) {
                                                tables.setup_new_ldt((int)new_ldt_base, (int)new_ldt_limit);
                                            }

                                            long gs_offset = new_tss_base + 92;

                                            int new_gs_selector = tables.getOutOfBoundsIndex(is_gs_ldt);
                                            if(new_gs_selector == -1) return false;

                                            new_gs_selector <<= 3;
                                            new_gs_selector |= (is_gs_ldt)? 4 : 0;
                                            new_gs_selector |= random.nextInt(4);

                                            MemoryPatchLayer gs_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)gs_offset, (new_gs_selector & 0xFF), ((new_gs_selector>>8) & 0xFF));
                                            test.layers.addFirst(gs_selector_patch);
                                        }
                                    }
                                    else if(type >= 20) {
                                        boolean is_gs_null = random.nextInt(10) == 0;
                                        int gs_selector = random.nextInt(4);

                                        if(is_gs_null == false && new_tss_type == (source == Source.FROM_IRET? 0xB : 0x9)) {
                                            boolean is_gs_ldt = is_new_ldt_null == false && random.nextBoolean();

                                            if(is_gs_ldt) {
                                                tables.setup_new_ldt((int)new_ldt_base, (int)new_ldt_limit);
                                            }

                                            conds= new boolean[4];
                                            cond = (type == 20)? 1 << random.nextInt(conds.length) : 0;

                                            boolean new_gs_seg  = false;
                                            int     new_gs_type = 0;
                                            boolean new_gs_p    = false;
                                            int     new_gs_dpl  = 0;
                                            int     new_gs_rpl  = 0;

                                            boolean new_gs_d_b  = random.nextBoolean();
                                            boolean new_gs_l    = random.nextBoolean();
                                            boolean new_gs_avl  = random.nextBoolean();
                                            int     new_gs_limit= random.nextInt(65536);
                                            int     new_gs_base = random.nextInt(65536);
                                            boolean new_gs_g    = random.nextBoolean();

                                            do {
                                                new_gs_seg = random.nextBoolean();
                                                new_gs_type= random.nextInt(16);
                                                new_gs_p   = random.nextBoolean();
                                                new_gs_dpl = random.nextInt(4);
                                                new_gs_rpl = random.nextInt(4);

                                                conds[0] = new_gs_seg == false;
                                                conds[1] = (new_gs_type >> 3) == 1 && ((new_gs_type >> 1)&1) == 0; // code segment and not readable
                                                conds[2] = ((new_gs_type >> 3) == 0 || ((new_gs_type >> 2)&1) == 0) && (new_gs_rpl > new_gs_dpl || new_cs_rpl > new_gs_dpl); // (data segment or code non conforming)
                                                conds[3] = new_gs_p == false;
                                            }
                                            while(!test.isAccepted(cond, conds[0],conds[1],conds[2],conds[3]));

                                            TestUnit.Descriptor gs_desc = new TestUnit.Descriptor((int)new_gs_base, (int)new_gs_limit, new_gs_type, new_gs_seg, new_gs_p, new_gs_dpl, new_gs_d_b, new_gs_g, new_gs_l, new_gs_avl);

                                            gs_selector = tables.addDescriptor(is_gs_ldt, gs_desc);
                                            if(gs_selector == -1) return false;

                                            gs_selector <<= 3;
                                            gs_selector |= new_gs_rpl;
                                            if(is_gs_ldt) gs_selector |= 4;
                                        }

                                        long gs_offset = new_tss_base + 92;

                                        MemoryPatchLayer gs_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)gs_offset, (gs_selector & 0xFF), ((gs_selector>>8) & 0xFF));
                                        test.layers.addFirst(gs_selector_patch);

                                        if(type == 22) {
                                            boolean is_cs_ldt = is_new_ldt_null == false && random.nextBoolean();

                                            if(is_cs_ldt) {
                                                tables.setup_new_ldt((int)new_ldt_base, (int)new_ldt_limit);
                                            }

                                            new_cs_selector = tables.getOutOfBoundsIndex(is_cs_ldt);
                                            if(new_cs_selector == -1) return false;

                                            new_cs_selector <<= 3;
                                            new_cs_selector |= (is_cs_ldt)? 4 : 0;
                                            new_cs_selector |= new_cs_rpl;

                                            MemoryPatchLayer cs_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)cs_offset, (new_cs_selector & 0xFF), ((new_cs_selector>>8) & 0xFF));
                                            test.layers.addFirst(cs_selector_patch);
                                        }
                                        else if(type >= 23) {
                                            boolean is_cs_ldt = is_new_ldt_null == false && random.nextBoolean();

                                            if(is_cs_ldt) {
                                                tables.setup_new_ldt((int)new_ldt_base, (int)new_ldt_limit);
                                            }

                                            conds= new boolean[5];
                                            cond = (type == 23)? 1 << random.nextInt(conds.length) : 0;

                                            boolean new_cs_seg  = false;
                                            int     new_cs_type = 0;
                                            boolean new_cs_p    = false;
                                            int     new_cs_dpl  = 0;

                                            boolean new_cs_d_b  = random.nextBoolean();
                                            boolean new_cs_l    = random.nextBoolean();
                                            boolean new_cs_avl  = random.nextBoolean();

                                            if((cond & 8) != 0 && new_cs_rpl == 3) return false; 

                                            do {
                                                new_cs_seg = random.nextBoolean();
                                                new_cs_type= random.nextInt(16);
                                                new_cs_p   = random.nextBoolean();
                                                new_cs_dpl = random.nextInt(4);

                                                conds[0] = new_cs_seg == false;
                                                conds[1] = (new_cs_type >> 3) == 0; // data segment
                                                conds[2] = (new_cs_type >> 3) == 1 && ((new_cs_type >> 2)&1) == 0 && new_cs_rpl != new_cs_dpl; // (code non conforming)
                                                conds[3] = (new_cs_type >> 3) == 1 && ((new_cs_type >> 2)&1) == 1 && new_cs_dpl > new_cs_rpl;  // (code conforming)
                                                conds[4] = new_cs_p == false;
                                            }
                                            while(!test.isAccepted(cond, conds[0],conds[1],conds[2],conds[3],conds[4]));

                                            long new_cs_base, new_cs_limit;
                                            boolean new_cs_g;
                                            while(true) {
                                                new_cs_base = Layer.norm(random.nextInt());
                                                new_cs_g    = random.nextBoolean();

                                                new_cs_limit = random.nextInt(new_cs_g? 0xF+1 : 0xFFFF + 1);
                                                if(new_cs_g) new_cs_limit = (new_cs_limit << 12) | 0xFFF;

                                                if( new_cs_base + new_cs_limit < 4294967296L &&
                                                    Layer.collides(prohibited_list, (int)new_cs_base, (int)(new_cs_base + new_cs_limit)) == false )
                                                {
                                                    prohibited_list.add(new Pair<>(new_cs_base, new_cs_base + new_cs_limit));
                                                    break;
                                                }
                                            }
                                            long new_cs_limit_final = new_cs_g? new_cs_limit >> 12 : new_cs_limit;


                                            TestUnit.Descriptor cs_desc = new TestUnit.Descriptor((int)new_cs_base, (int)new_cs_limit_final, new_cs_type, new_cs_seg, new_cs_p, new_cs_dpl, new_cs_d_b, new_cs_g, new_cs_l, new_cs_avl);

                                            int cs_selector = tables.addDescriptor(is_cs_ldt, cs_desc);
                                            if(cs_selector == -1) return false;

                                            cs_selector <<= 3;
                                            cs_selector |= new_cs_rpl;
                                            if(is_cs_ldt) cs_selector |= 4;

                                            MemoryPatchLayer cs_selector_patch = new MemoryPatchLayer(random, prohibited_list, (int)cs_offset, (cs_selector & 0xFF), ((cs_selector>>8) & 0xFF));
                                            test.layers.addFirst(cs_selector_patch);

                                            if(type >= 24) {
                                                // set eip
                                                long eip_offset = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? 14 : 32);

                                                long eip = random.nextInt((int)new_cs_limit_final+1);
                                                if(eip >= 65536 && new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1)) eip = random.nextInt(65536);
                                                
                                                if(type == 24) eip = new_cs_limit_final + 1 + random.nextInt(5);
                                                
                                                if(new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1)) {
                                                    MemoryPatchLayer eip_patch = new MemoryPatchLayer(random, prohibited_list, (int)eip_offset,
                                                            (int)(eip & 0xFF), (int)((eip>>8) & 0xFF));
                                                    test.layers.addFirst(eip_patch);
                                                }
                                                else {
                                                    MemoryPatchLayer eip_patch = new MemoryPatchLayer(random, prohibited_list, (int)eip_offset,
                                                            (int)(eip & 0xFF), (int)((eip>>8) & 0xFF), (int)((eip>>16) & 0xFF), (int)((eip>>24) & 0xFF));
                                                    test.layers.addFirst(eip_patch);
                                                }

                                                MemoryPatchLayer instr_patch = new MemoryPatchLayer(random, prohibited_list, (int)(new_cs_base + eip),
                                                    0x0F, 0x0F, 0x0F);
                                                test.layers.addFirst(instr_patch);
                                                
                                                int debug_flag = (type == 26)? 1 : 0;
                                                
                                                long debug_offset = new_tss_base + ((new_tss_type == (source == Source.FROM_IRET? 0x3 : 0x1))? -1 : 100);
                                                if(debug_offset >= 0) {
                                                    MemoryPatchLayer trap_patch = new MemoryPatchLayer(random, prohibited_list, (int)debug_offset,
                                                            (int)(debug_flag & 0xFF), (int)((debug_flag>>8) & 0xFF));
                                                    test.layers.addFirst(trap_patch);
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else throw new Exception("Invalid type");

                    }
                    else throw new Exception("Invalid type");
                }
                else throw new Exception("Invalid type");
            }
            else throw new Exception("Invalid type");
        }
        return true;
    }
}
