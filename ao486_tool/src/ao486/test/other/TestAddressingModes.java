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
import static ao486.test.TestUnit.run_test;
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

public class TestAddressingModes extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestAddressingModes.class);
    }
    
    //--------------------------------------------------------------------------
    
    @Override
    public int get_test_count() throws Exception {
        //16-bit: 256
        //32-bit: 256-8*3 + 8*3*256 = 256 + 8*3*255
        
        return REPEAT * (256 + 256-8*3 + 8*3*256);
    }
    
    
    static final int REPEAT = 1;
    
    static int current_repeat      = 0;
    static int current_16bit       = 0;
    static int current_32bit       = 0;
    static int current_32bit_sib   = 0;
    
    static int current_run = 0;
    
    void update() {
        if(current_repeat == REPEAT-1) {
            current_repeat = 0;

            if(current_16bit == 256) {

                if(current_32bit == 256-1) { System.out.println("[TestAddressingModes]: tested all."); }
                else {
                    boolean sib = is_sib();

                    if(sib && current_32bit_sib == 256-1) {
                        current_32bit_sib = 0;
                        current_32bit++;
                    }
                    else if(sib) {
                        current_32bit_sib++;
                    }
                    else {
                        current_32bit++;
                    }
                }
            }
            else current_16bit++;
        }
        else current_repeat++;
    }
    
    boolean is_sib() {
        return current_16bit == 256 && ((current_32bit >> 6) & 0x3) != 3 && (current_32bit & 0x7) == 4;
    }
    
    int modregrm_len() {
        boolean a16  = current_16bit < 256;
        int modregrm = (a16)? current_16bit : current_32bit;
        int mod      = (modregrm >> 6) & 3;
        int rm       = modregrm & 7;
        int base     = current_32bit_sib & 7;
        
        // d_CRx_DRx_condition ignored
        
        if(a16 && mod == 0 && rm == 6) return 3;
        if(a16 && mod == 1) return 2;
        if(a16 && mod == 2) return 3;
        if(a16) return 1;
        
        if(mod == 0 && rm == 5) return 5;
        if(mod == 0 && rm == 4 && base == 5) return 6;
        if(mod == 0 && rm == 4) return 2;
        if(mod == 1 && rm == 4) return 3;
        if(mod == 1) return 2;
        if(mod == 2 && rm == 4) return 6;
        if(mod == 2) return 5;
        
        return 1;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(10 + index);
        
System.out.println("[current_repeat   (" + current_repeat    + ") " +
                   "[current_16bit    (" + current_16bit     + ") " +
                   "[current_32bit    (" + current_32bit     + ") " +
                   "[current_32bit_sib(" + current_32bit_sib + ")]");
    
        String instruction;
        layers.clear();

        LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();

        // if false: v8086 mode
        boolean is_real = true;

        InstructionLayer instr  = new InstructionLayer(random, prohibited_list, true);
        layers.add(instr);
        StackLayer stack        = new StackLayer(random, prohibited_list);
        layers.add(stack);
        layers.add(new OtherLayer(is_real ? OtherLayer.Type.REAL : OtherLayer.Type.PROTECTED_OR_V8086, random));
        layers.add(new FlagsLayer(is_real ? FlagsLayer.Type.RANDOM : FlagsLayer.Type.V8086, random));
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
        
        int d_b = 0;
        if(current_16bit == 256) d_b = 1;
        final int d_b_final = d_b;
        
        Layer layer = new Layer() {
            long cs_d_b()      { return d_b_final; }
        };
        layers.addFirst(layer);
        
        byte bytes[] = hexToBytes("000000000000000000000000000000");
        
        if(current_16bit < 256) bytes[1] = (byte)current_16bit;
        else                    bytes[1] = (byte)current_32bit;
        
        if(is_sib()) {
            bytes[2] = (byte)current_32bit_sib;
            for(int i=0; i<modregrm_len()-2; i++) bytes[3+i] = (byte)random.nextInt();
        }
        else {
            for(int i=0; i<modregrm_len()-1; i++) bytes[2+i] = (byte)random.nextInt();
        }
        
        int final_size = modregrm_len()+1;
        byte final_bytes[] = new byte[final_size];
        System.arraycopy(bytes, 0, final_bytes, 0, final_size);
        
        instruction = bytesToHex(final_bytes) + "0F0F0F0F0F0F0F";
        
        instr.add_instruction(instruction);
        
System.out.println("[get_instructions: " + instruction + "]");
        
        //---------------------------------------------------------------------- update
        current_run++;
        if(current_run == 2) {
            update();
            current_run = 0;
        }
    }
}
