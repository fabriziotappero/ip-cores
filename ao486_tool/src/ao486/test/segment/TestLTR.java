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

package ao486.test.segment;

import ao486.test.TestUnit;
import static ao486.test.TestUnit.run_test;
import ao486.test.layers.DescriptorTableLayer;
import ao486.test.layers.EffectiveAddressLayerFactory;
import ao486.test.layers.FlagsLayer;
import ao486.test.layers.GeneralRegisterLayer;
import ao486.test.layers.HandleModeChangeLayer;
import ao486.test.layers.IOLayer;
import ao486.test.layers.InstructionLayer;
import ao486.test.layers.MemoryLayer;
import ao486.test.layers.OtherLayer;
import ao486.test.layers.Pair;
import ao486.test.layers.SegmentLayer;
import ao486.test.layers.StackLayer;
import java.io.Serializable;
import java.util.LinkedList;
import java.util.Random;

public class TestLTR extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestLTR.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(707 + index);
        
        /* 0. not protected mode
         * 1. protected mode and CPL != 0
         * 2. zero selector
         *      - null selector TI = 0
         *      - null selector TI = 1
         * 3. fetch descriptor failed:
         *      - index over limit GDT
         * 4. descriptor check failed:
         * 5. all ok
         */

        int type = 5; //random.nextInt(6);
        
        String instruction;
        while(true) {
            layers.clear();
            
            long    next_cs_rpl   = 0;
            boolean descr_seg     = false;
            int     descr_type    = 0;
            int     descr_dpl     = 0;
            boolean descr_present = false;
            long    selector_rpl  = 0;
            
            if(type == 0)      next_cs_rpl = random.nextInt(4);
            else if(type == 1) next_cs_rpl = 1 + random.nextInt(3);
            else               next_cs_rpl = 0;
            
            
            int cond = (type == 5)? 0 : 1 << (random.nextInt(100000) % 3);
            
            System.out.printf("cond: %d, index: %d\n", cond, index);
            
            boolean lldt_cond_1;
            boolean lldt_cond_2;
            boolean lldt_cond_3;

            do {
                descr_seg       = random.nextBoolean();
                descr_type      = random.nextInt(16);
                descr_dpl       = random.nextInt(4);
                descr_present   = (type == 5)? true : random.nextBoolean();
                selector_rpl    = random.nextInt(4);


                lldt_cond_1 = descr_seg;
                lldt_cond_2 = descr_type != 1 && descr_type != 9;
                lldt_cond_3 = descr_present == false;
            }
            while(!isAccepted(cond, lldt_cond_1,lldt_cond_2,lldt_cond_3));
            
            
            //0-real; 1-v8086; 2-protected
            int mode = (type == 0)? random.nextInt(2) : 2;
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            InstructionLayer instr = new InstructionLayer(random, prohibited_list);
            layers.add(instr);
            layers.add(new StackLayer(random, prohibited_list));
            layers.add(new OtherLayer((mode >= 1)? OtherLayer.Type.PROTECTED_OR_V8086 : OtherLayer.Type.REAL, random));
            layers.add(new FlagsLayer((mode == 1)? FlagsLayer.Type.V8086 : (mode == 2)? FlagsLayer.Type.NOT_V8086 : FlagsLayer.Type.RANDOM, random));
            layers.add(new GeneralRegisterLayer(random));
            layers.add(new SegmentLayer(random));
            layers.add(new MemoryLayer(random));
            layers.add(new IOLayer(random));
            layers.addFirst(new HandleModeChangeLayer(
                    getInput("cr0_pe"),
                    getInput("vmflag"),
                    next_cs_rpl, //getInput("cs_rpl"),
                    getInput("cs_p"),
                    getInput("cs_s"),
                    getInput("cs_type")
            ));
            
            // instruction size
            boolean cs_d_b = getInput("cs_d_b") == 1;
            long    cs_rpl = getInput("cs_rpl");
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            long selector = 0;
            
            if(type == 2) {
                selector = random.nextInt(4);
                
                if(random.nextBoolean()) selector |= (random.nextInt(500) | 1) << 2;
            }
            else if(type == 3) {
                boolean ldtr_valid = random.nextInt(5) != 0;
                
                DescriptorTableLayer tables = new DescriptorTableLayer(random, prohibited_list, ldtr_valid);
                
                boolean is_ldt = false;
                
                int index = tables.getOutOfBoundsIndex(is_ldt);
                if(index == -1) continue;
                
                if(ldtr_valid == false && is_ldt) index = 0;
                
                index = index << 3;
                if(is_ldt) index |= 4;
                
                index |= random.nextInt(4);
                
                selector = index;
                
                layers.addFirst(tables);
            }
            else if(type >= 4) {
                TestUnit.Descriptor desc = new TestUnit.Descriptor(
                        random.nextInt(), //base
                        random.nextInt() & 0xFFFFF, //limit
                        descr_type,
                        descr_seg,
                        descr_present,
                        descr_dpl,
                        random.nextBoolean(), //d_b
                        random.nextBoolean(), //g
                        random.nextBoolean(), //l
                        random.nextBoolean()  //avl
                );
                
                DescriptorTableLayer tables = new DescriptorTableLayer(random, prohibited_list, true);
                
                boolean is_ldt = random.nextBoolean();
                
                int index = tables.addDescriptor(is_ldt, desc);
                if(index == -1) continue;

                index = index << 3;
                if(is_ldt) index |= 4;

                index |= selector_rpl;
                
                selector = index;
                
                layers.addFirst(tables);
            }
            
            byte extra_bytes[] = null;
            
            byte modregrm_bytes[] = EffectiveAddressLayerFactory.prepare(
                    selector,
                    3, EffectiveAddressLayerFactory.modregrm_reg_t.SET,
                    2, a32,
                    layers, random, this, false, false);
            extra_bytes = modregrm_bytes;
            
            // instruction
            instruction = prepare_instr(cs_d_b, a32, o32, extra_bytes);
            
            instruction += instruction;
            instruction += "0F0F";
            
            // add instruction
            instr.add_instruction(instruction);
            
            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }
    
    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32, byte modregrm_bytes[]) throws Exception {
        
        int opcodes[] = {
            0x00
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        int opcode = opcodes[random.nextInt(opcodes.length)];
        
        byte instr[] = new byte[1 + modregrm_bytes.length];
        instr[0] = (byte)opcode;
        System.arraycopy(modregrm_bytes, 0, instr, 1, modregrm_bytes.length);
        
        return prefix + "0F" + bytesToHex(instr);
    }
}
