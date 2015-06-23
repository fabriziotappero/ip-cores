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

package ao486.test.arithmetic_logic;

import ao486.test.TestUnit;
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
import java.io.*;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.Random;


public class TestArithLogic extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestArithLogic.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(2+index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            InstructionLayer instr = new InstructionLayer(random, prohibited_list);
            layers.add(instr);
            layers.add(new StackLayer(random, prohibited_list));
            layers.add(new OtherLayer(OtherLayer.Type.RANDOM, random));
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
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            // instruction
            /*
            byte modregrm_bytes[] = EffectiveAddressLayerFactory.prepare(
                    0,
                    4, EffectiveAddressLayerFactory.modregrm_reg_t.SET,
                    o32? 4 : 2, a32,
                    layers, random, this, false, false);
            */
            
            instruction = prepare_instr(cs_d_b, a32, o32, null);
            
            instruction += "0F0F";
            
            // add instruction
            instr.add_instruction(instruction);
            
            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }
    
    int imm_len(boolean o16, int opcode) {
        int l = opcode & 0x0F;
        int h = (opcode >> 4) & 0x0F;
        
        if((h >= 0 && h <= 3) && (l == 0x4 || l == 0xC)) return 1;
        if((h >= 0 && h <= 3) && (l == 0x5 || l == 0xD)) return (o16)? 2 : 4;
        
        if(h == 8 && l == 0) return 1;
        if(h == 8 && l == 1) return (o16)? 2 : 4;
        if(h == 8 && l == 3) return 1;
        
        return 0;
    }
    
    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32, byte modregrm_bytes[]) throws Exception {
        int opcodes[] = {
            0x00,0x01,0x02,0x03,0x04,0x05, 0x08,0x09,0x0A,0x0B,0x0C,0x0D,
            0x10,0x11,0x12,0x13,0x14,0x15, 0x18,0x19,0x1A,0x1B,0x1C,0x1D,
            0x20,0x21,0x22,0x23,0x24,0x25, 0x28,0x29,0x2A,0x2B,0x2C,0x2D,
            0x30,0x31,0x32,0x33,0x34,0x35, 0x38,0x39,0x3A,0x3B,0x3C,0x3D,
            0x80,0x81,0x82,0x83
        };
        int not_modregrm[] = {
            0x04,0x05, 0x0C,0x0D,
            0x14,0x15, 0x1C,0x1D,
            0x24,0x25, 0x2C,0x2D,
            0x34,0x35, 0x3C,0x3D,
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        int     opcode      = opcodes[random.nextInt(opcodes.length)];
        
        boolean is_modregrm = Arrays.binarySearch(not_modregrm, opcode) < 0;
        
        byte possible_modregrm = (byte)random.nextInt();
        byte possible_sib      = (byte)random.nextInt();
      
        int len = (is_modregrm == false)? 1 : 1 + modregrm_len(!a32, unsigned(possible_modregrm), unsigned(possible_sib));
        len += imm_len(!o32, opcode);
System.out.println("instr len: " + len + ", imm_len: " + imm_len(!o32, opcode));

        byte instr[] = new byte[len];
        instr[0] = (byte)opcode;
        for(int i=1; i<len; i++) {
            if(i==1)        instr[1] = possible_modregrm;
            else if(i==2)   instr[2] = possible_sib;
            else            instr[i] = (byte)random.nextInt();
        }
        
        return prefix + bytesToHex(instr);
    }
}
