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

package ao486.test.transfer_data;

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

public class TestMOVSX_MOVZX extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestMOVSX_MOVZX.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        random = new Random(5 + index);
        
        long rpl = random.nextInt(4);
        
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
                    rpl, //getInput("cs_rpl"),
                    getInput("cs_p"),
                    getInput("cs_s"),
                    getInput("cs_type")
            ));
            
            // instruction size
            boolean cs_d_b = getInput("cs_d_b") == 1;
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            // instruction
            instruction = prepare_instr(cs_d_b, a32, o32, null);
            
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
            0xB6,0xB7,0xBE,0xBF
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        
        int     opcode      = opcodes[random.nextInt(opcodes.length)];
        boolean is_modregrm = true;
        
        byte possible_modregrm = (byte)random.nextInt();
        byte possible_sib      = (byte)random.nextInt();
      
        int len = (is_modregrm == false)? 1 : 1 + modregrm_len(!a32, unsigned(possible_modregrm), unsigned(possible_sib));

        byte instr[] = new byte[len];
        instr[0] = (byte)opcode;
        for(int i=1; i<len; i++) {
            if(i==1)        instr[1] = possible_modregrm;
            else if(i==2)   instr[2] = possible_sib;
            else            instr[i] = (byte)random.nextInt();
        }
        return prefix + "0F" + bytesToHex(instr);
    }
}


/*
class TestMOVSX_MOVZXSerializable extends TestBase implements Test, Serializable {
    TestMOVSX_MOVZXSerializable() {
        random = new Random(0);
    }
    
    Random random;
    int index;
    
    boolean d_b;
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 2000;
    }
    
    @Override
    public void init() throws Exception {
        d_b = random.nextBoolean();
    }
    
    @Override
    public boolean fini() throws Exception {
        return index < get_test_count();
    }
    
    int imm_len(boolean o16, int opcode) {
        return 0;
    }
    String prepare_instr() throws Exception {
        int opcodes[] = {
            0xB6,0xB7,0xBE,0xBF
        };
        
        boolean a16 = !d_b;
        boolean o16 = !d_b;
        String prefix = "";
        if(random.nextBoolean()) { prefix = "66" + prefix; o16 = !o16; }
        if(random.nextBoolean()) { prefix = "67" + prefix; a16 = !a16; }
        
        int opcode = opcodes[random.nextInt(opcodes.length)];
        boolean is_modregrm = true;
        
        byte possible_modregrm = (byte)random.nextInt();
        byte possible_sib      = (byte)random.nextInt();
      
        int len = (is_modregrm == false)? 1 : 1 + modregrm_len(a16, unsigned(possible_modregrm), unsigned(possible_sib));
System.out.printf("[len: %d, d_b: %b, modregrm: %02x, sib: %02x]\n", len, d_b, unsigned(possible_modregrm), unsigned(possible_sib));
        //len += imm_len(o16, opcode);
//System.out.println("[len final: " + len + "]");

        byte instr[] = new byte[len];
        instr[0] = (byte)opcode;
        for(int i=1; i<len; i++) {
            if(i==1)        instr[1] = possible_modregrm;
            else if(i==2)   instr[2] = possible_sib;
            else            instr[i] = (byte)random.nextInt();
        }
        
        return prefix + "0F" + bytesToHex(instr);
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
        return random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFF : 0x00000FFF);
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
