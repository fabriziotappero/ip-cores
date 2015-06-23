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

package ao486.test.bcd;

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
import java.io.Serializable;
import java.util.LinkedList;
import java.util.Random;


public class TestAAM extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestAAM.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(3+index);
        
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
            
            
            final int val = random.nextInt() % 10;
            final long eax = 
                (val == 0)? 0 :
                (val == 1)? 1 :
                (val == 2)? 254 :
                (val == 3)? 255 : 
                random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFF : 0x00000FFF);
            
            layers.addFirst(new Layer() {
                public long eax() { return eax; }
            });
            
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
        
        int opcodes[] = {
            0xD4
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        int opcode = opcodes[random.nextInt(opcodes.length)];
        
        byte instr[] = new byte[2];
        instr[0] = (byte)opcode;
        instr[1] = (random.nextInt(10) == 0)? 0 : (byte)(random.nextInt() & 0xFF);
        
        return prefix + bytesToHex(instr);
   }
}


/*
public class TestAAM {
    public static void main(String args[]) throws Exception {
        TestManager manager = new TestManager();

        TestAAMSerializable test = new TestAAMSerializable();
        
        if(false) {
            ObjectInputStream ois = new ObjectInputStream(new FileInputStream("test.obj"));
            test = (TestAAMSerializable)ois.readObject();
            ois.close();
        }
     
        for(; test.index<test.get_test_count(); test.index++) {
            System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Running test " + (test.index+1) + "/" + test.get_test_count());
            
            ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("test.obj"));
            oos.writeObject(test);
            oos.close();
            
            boolean passed = manager.run_test_and_print_result(test);
            if(passed == false) break;
        }
    }
}
class TestAAMSerializable extends TestBase implements Test, Serializable {
    TestAAMSerializable() {
        random = new Random(1);
    }
    
    Random random;
    int index;
    int local;
    
    boolean d_b;
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 1000;
    }
    
    @Override
    public void init() throws Exception {
        d_b = random.nextBoolean();
    }
    
    @Override
    public boolean fini() throws Exception {
        return index < get_test_count();
    }
    
    String prepare_instr() throws Exception {
        byte instr[] = new byte[2];
        
        instr[0] = (byte)0xD4;
        instr[1] = (byte)local++;
        
        return bytesToHex(instr);
    }

    public String get_instructions() throws Exception {
        String instr = ""; 
        
        while(instr.length() < 2*15) {
            instr += prepare_instr();
        }
        instr = instr.substring(0, 2*15);
        
System.out.println("[get_instructions: " + instr + "]");
        return instr;
    }
    @Override
    public byte get_memory(int address) throws Exception {
        return (byte)random.nextInt();
    }
    @Override
    public int eax() throws Exception {
        int val = random.nextInt() % 10;
        return  (val == 0)? 0 :
                (val == 1)? 1 :
                (val == 2)? 254 :
                (val == 3)? 255 : 
                random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFF : 0x00000FFF);
    }
    @Override
    public int get_ebx() throws Exception {
        return random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFF : 0x00000FFF);
    }
    @Override
    public int get_ecx() throws Exception {
        return random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFF : 0x00000FFF);
    }
    @Override
    public int get_edx() throws Exception {
        return random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFF : 0x00000FFF);
    }
    @Override
    public int get_esi() throws Exception {
        return random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFF : 0x00000FFF);
    }
    @Override
    public int get_edi() throws Exception {
        return random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFF : 0x00000FFF);
    }
    @Override
    public int get_ebp() throws Exception {
        return random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFF : 0x00000FFF);
    }
    @Override
    public int get_esp() throws Exception {
        return random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFF : 0x00000FFF);
    }
    @Override
    public boolean get_cf() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public boolean get_pf() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public boolean get_af() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public boolean get_zf() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public boolean get_sf() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public boolean get_tf() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public boolean get_if() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public boolean get_df() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public boolean get_of() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public int get_iopl() throws Exception {
        return random.nextInt(4);
    }
    @Override
    public boolean get_nt() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public boolean get_rf() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public boolean get_vm() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public boolean get_ac() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public boolean get_id() throws Exception {
        return random.nextBoolean();
    }
    @Override
    public int get_cs_base() throws Exception {
        return 0;
    }
    @Override
    public int get_cs_limit() throws Exception {
        return 0x000FFFFF;
    }
    @Override
    public boolean get_cs_d_b() throws Exception {
        return d_b;
    }
    @Override
    public int get_ds_base() throws Exception {
        return 0;
    }
    @Override
    public int get_ds_limit() throws Exception {
        return 0x000FFFFF;
    }
    @Override
    public int get_es_base() throws Exception {
        return 0;
    }
    @Override
    public int get_es_limit() throws Exception {
        return 0x000FFFFF;
    }
    @Override
    public int get_fs_base() throws Exception {
        return 0;
    }
    @Override
    public int get_fs_limit() throws Exception {
        return 0x000FFFFF;
    }
    @Override
    public int get_gs_base() throws Exception {
        return 0;
    }
    @Override
    public int get_gs_limit() throws Exception {
        return 0x000FFFFF;
    }
    @Override
    public int get_ss_base() throws Exception {
        return 0;
    }
    @Override
    public int get_ss_limit() throws Exception {
        return 0x000FFFFF;
    }
}
*/
