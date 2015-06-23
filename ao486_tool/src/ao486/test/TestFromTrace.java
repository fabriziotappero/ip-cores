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

package ao486.test;

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
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.Serializable;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.util.LinkedList;
import java.util.Properties;
import java.util.Random;

public class TestFromTrace extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        Properties props = new Properties();
        props.load(new FileInputStream("run.properties"));
        file_offset = Long.parseLong(props.getProperty("file_offset"));
        
        run_test(TestFromTrace.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100000000;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(4+index);
        
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
            
            Layer debug_layer = new Layer() {
                long get_test_type() { return 4; }
            };
            layers.addFirst(debug_layer);
            
            // instruction size
            boolean cs_d_b = getInput("cs_d_b") == 1;
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            // instruction
            instruction = prepare_instr(cs_d_b, a32, o32, null);
            
            instruction += "0F0F";
            
            // add instruction
            instr.add_instruction(instruction);
            
            // end condition
            break;
        }
        
        System.out.println("Instruction: [" + instruction + "]");
    }
    
    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32, byte modregrm_bytes[]) throws Exception {
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        FileInputStream fis = new FileInputStream("/home/alek/temp/bochs-run/dbg_win311_boot.out");
        FileChannel ch = fis.getChannel();
        
        ch.position(file_offset);
        
        ByteBuffer bb = ByteBuffer.allocate(8192);
        ch.read(bb);
        String str = new String(bb.array());
        
        int index1 = str.indexOf("; ");
        int index2 = str.indexOf("\n", index1);
        int index3 = str.indexOf("; ", index2);
        int index4 = str.indexOf("\n", index3);
        
        if(index1 == -1 || index2 == -1 || index3 == -1 || index4 == -1) throw new Exception("index == -1: " + index1 + ", " + index2 + ", " + index3 + ", " + index4);
        
        String s1 = str.substring(index1+1, index2);
        String s2 = str.substring(index3+1, index4);
        
        s1 = s1.trim();
        s2 = s2.trim();
        
        System.out.println("file_offset: " + file_offset + ", file_number: " + file_number);
        if((file_number & 1L) == 1) file_offset += index2;
        file_number++;
        if(file_number==2) {
            file_number = 0;
        
            //Properties props = new Properties();
            //props.load(new FileInputStream("run.properties"));
            //props.setProperty("file_offset", "" + file_offset);
            //props.store(new FileOutputStream("run.properties"), null);
        }
        
        return prefix + s1 + s2 + "909090909090909090909090909090909090909090909090909090909090";
    }
    static long file_number = 0;
    static long file_offset = 301186382;
}
