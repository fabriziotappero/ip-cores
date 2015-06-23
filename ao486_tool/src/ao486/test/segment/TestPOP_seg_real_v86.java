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

public class TestPOP_seg_real_v86 extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestPOP_seg_real_v86.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(354 + index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            should_be_ss = random.nextInt(3) == 0;
            
            //0-real; 1-v8086; 2-protected
            int mode = random.nextInt(2);
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            InstructionLayer instr = new InstructionLayer(random, prohibited_list);
            layers.add(instr);
            StackLayer stack = new StackLayer(random, prohibited_list); 
            layers.add(stack);
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
            
System.out.printf("selector: %x\n", selector);
            
            stack.push_word((int)selector);
            stack.push_word((int)selector);

            // instruction
            instruction = prepare_instr(cs_d_b, a32, o32);
            
            instruction += instruction;
            instruction += "0F0F";
            
            // add instruction
            instr.add_instruction(instruction);
            
            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }
    
    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32) throws Exception {
        
        int opcodes[] = {
            0x07,0x17,0x1F,0xA1,0xA9
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        int opcode = opcodes[random.nextInt(opcodes.length)];
        
        if(should_be_ss) opcode = 0x17;
        
        byte instr[] = new byte[1];
        instr[0] = (byte)opcode;
        
        return prefix + ((opcode == 0xA1 || opcode == 0xA9)? "0F" : "") + bytesToHex(instr);
    }
    
    boolean should_be_ss;
}
