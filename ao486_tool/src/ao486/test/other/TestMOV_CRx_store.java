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

package ao486.test.other;

import ao486.test.TestUnit;
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
import java.io.*;
import java.util.LinkedList;
import java.util.Random;


public class TestMOV_CRx_store extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestMOV_CRx_store.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(5 + index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            /* 0 - CPL != 0
             * 1 - all ok
             */
            int type = random.nextInt(2);
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            // if false: v8086 mode
            boolean is_real = (type == 0)? false : random.nextBoolean();
            
            InstructionLayer instr  = new InstructionLayer(random, prohibited_list);
            layers.add(instr);
            StackLayer stack        = new StackLayer(random, prohibited_list);
            layers.add(stack);
            layers.add(new OtherLayer(is_real ? OtherLayer.Type.REAL : OtherLayer.Type.PROTECTED_OR_V8086, random));
            layers.add(new FlagsLayer(FlagsLayer.Type.RANDOM, random));
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
            boolean vmflag = getInput("vmflag") == 1;
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            if(type == 0) {
                final int cs_rpl = (vmflag)? 3 : 1 + random.nextInt(3);
                Layer cs_rpl_layer = new Layer() {
                    long cs_rpl() { return cs_rpl; }
                };
                layers.addFirst(cs_rpl_layer);
            }
            
            // random CR0 bits
            //cr0_pe set above
            final boolean cr0_mp = random.nextBoolean();
            final boolean cr0_em = random.nextBoolean();
            final boolean cr0_ts = random.nextBoolean();
            final boolean cr0_ne = random.nextBoolean();
            final boolean cr0_wp = random.nextBoolean();
            final boolean cr0_am = random.nextBoolean();
            final boolean cr0_nw = random.nextBoolean();
            final boolean cr0_cd = random.nextBoolean();
            
            final int cr2 = random.nextInt();
            final int cr3 = random.nextInt();
            
            Layer cr0_2_3_layer = new Layer() {
                long cr0_mp() { return cr0_mp? 1:0; }
                long cr0_em() { return cr0_em? 1:0; }
                long cr0_ts() { return cr0_ts? 1:0; }
                long cr0_ne() { return cr0_ne? 1:0; }
                long cr0_wp() { return cr0_wp? 1:0; }
                long cr0_am() { return cr0_am? 1:0; }
                long cr0_nw() { return cr0_nw? 1:0; }
                long cr0_cd() { return cr0_cd? 1:0; }
                long cr0_pg() { return 0; }
                
                long cr2() { return cr2; }
                long cr3() { return cr3; }
            };
            layers.addFirst(cr0_2_3_layer);
            
            int idx = random.nextInt(3);
            int cr_reg = (random.nextBoolean())? ( (idx == 0)? 0 : (idx == 1)? 2 : 3 ) : random.nextInt(8);
            
            int cr_mod = random.nextInt(4);
            int cr_rm  = random.nextInt(8);
            
            // instruction
            byte modregrm_byte = (byte)((cr_mod << 6) | (cr_reg << 3) | (cr_rm));
            
            instruction = prepare_instr(cs_d_b, a32, o32, modregrm_byte);
            
            instruction += instruction;
            instruction += "0F0F";
            
            // add instruction
            instr.add_instruction(instruction);
            
            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }

    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32, byte modregrm_byte) throws Exception {
        int opcodes[] = {
            0x20
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        prefix += "0F";
        int opcode = opcodes[random.nextInt(opcodes.length)];
        
        byte instr[] = new byte[1 + 1];
        instr[0] = (byte)opcode;
        instr[1] = modregrm_byte;
        
        return prefix + bytesToHex(instr);
    }
}
