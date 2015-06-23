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

public class TestMOV_to_seg_real_v86 extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestMOV_to_seg_real_v86.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(10 + index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            should_be_ss = random.nextInt(3) == 0;
            
            //0-real; 1-v8086; 2-protected
            int mode = random.nextInt(2);
            
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
                    getInput("cs_rpl"),
                    getInput("cs_p"),
                    getInput("cs_s"),
                    getInput("cs_type")
            ));
            
            // instruction size
            boolean cs_d_b = getInput("cs_d_b") == 1;
            long    cs_rpl = getInput("cs_rpl");
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            long selector = random.nextInt(65536);
            
            byte extra_bytes[] = null;
            
            
System.out.printf("selector: %x\n", selector);
            
            int seg = 2;
            if(should_be_ss == false) {
                while(seg == 2) seg = random.nextInt(6);
            }
            
            byte modregrm_bytes[] = EffectiveAddressLayerFactory.prepare(
                    selector,
                    seg, EffectiveAddressLayerFactory.modregrm_reg_t.SET,
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
            0x8E
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        int opcode = opcodes[random.nextInt(opcodes.length)];
       
        byte instr[] = new byte[1 + modregrm_bytes.length];
        instr[0] = (byte)opcode;
        System.arraycopy(modregrm_bytes, 0, instr, 1, modregrm_bytes.length);
        
        return prefix + bytesToHex(instr);
    }
    
    boolean should_be_ss;
}
