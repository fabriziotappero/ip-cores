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

package ao486.test.io;

import ao486.test.TestUnit;
import ao486.test.layers.FlagsLayer;
import ao486.test.layers.GeneralRegisterLayer;
import ao486.test.layers.HandleModeChangeLayer;
import ao486.test.layers.IOLayer;
import ao486.test.layers.InstructionLayer;
import ao486.test.layers.Layer;
import ao486.test.layers.MemoryLayer;
import ao486.test.layers.MemoryPatchLayer;
import ao486.test.layers.OtherLayer;
import ao486.test.layers.Pair;
import ao486.test.layers.SegmentLayer;
import ao486.test.layers.StackLayer;
import java.io.*;
import java.util.LinkedList;
import java.util.Random;


public class TestINS_protected_rep extends TestUnit implements Serializable {
    public static void main(String args[]) throws Exception {
        run_test(TestINS_protected_rep.class);
    }
    
    //--------------------------------------------------------------------------
    @Override
    public int get_test_count() throws Exception {
        return 100;
    }
    
    @Override
    public void init() throws Exception {
        
        random = new Random(7 + index);
        
        String instruction;
        while(true) {
            layers.clear();
            
            LinkedList<Pair<Long, Long>> prohibited_list = new LinkedList<>();
            
            //-----
            
            /* type:
             * 0 - no io_allow
             * 1 - no valid 32-bit TSS
             * 2 - TR.limit < 103
             * 3 - port permission bits >= limit
             * 4 - port permission bits invalid
             * 5 - all ok
             */
       
            int type = 5; //random.nextInt(5+1);
            
            int     next_port = 0;
            int     next_rpl = 0;
            boolean next_cr0_pe = true;
            boolean next_tr_valid = true;
            int     next_tr_base = 0;
            int     next_tr_limit = 0;
            int     next_tr_type = 0;
            boolean next_vm = false;
            int     next_iopl = 0;
            
            if(type == 0) {
                do {
                    next_rpl        = random.nextInt(4);
                    next_cr0_pe     = random.nextBoolean();
                    next_tr_valid   = random.nextBoolean();
                    next_tr_base    = random.nextInt();
                    next_tr_limit   = random.nextInt(1048576);
                    next_tr_type    = random.nextInt(16);
                    next_vm         = random.nextBoolean();
                    next_iopl       = random.nextInt(4);
                }while(next_cr0_pe && (next_vm || next_rpl > next_iopl));

                next_port       = random.nextInt(65536);
            }

            if(type == 1) {
                do {
                    next_rpl        = random.nextInt(4);
                    next_cr0_pe     = random.nextBoolean();
                    next_vm         = random.nextBoolean();
                    next_iopl       = random.nextInt(4);
                }while( !(next_cr0_pe && (next_vm || next_rpl > next_iopl)));

                do {
                    next_tr_valid   = random.nextBoolean();
                    next_tr_type    = random.nextInt(16);
                }while( !(next_tr_valid == false || (next_tr_type != 9 && next_tr_type != 11)));

                next_tr_base    = random.nextInt();
                next_tr_limit   = random.nextInt(1048576);
                next_port       = random.nextInt();
            }

            if(type == 2) {
                do {
                    next_rpl        = random.nextInt(4);
                    next_cr0_pe     = random.nextBoolean();
                    next_vm         = random.nextBoolean();
                    next_iopl       = random.nextInt(4);
                }while( !(next_cr0_pe && (next_vm || next_rpl > next_iopl)));

                do {
                    next_tr_valid   = random.nextBoolean();
                    next_tr_type    = random.nextInt(16);
                }while(next_tr_valid == false || (next_tr_type != 9 && next_tr_type != 11));

                do {
                    next_tr_limit   = random.nextInt(103);
                }while( !(next_tr_limit < 103));

                next_tr_base    = random.nextInt();
                next_port       = random.nextInt();
            }

            if(type == 3) {
                do {
                    next_rpl        = random.nextInt(4);
                    next_cr0_pe     = random.nextBoolean();
                    next_vm         = random.nextBoolean();
                    next_iopl       = random.nextInt(4);
                }while( !(next_cr0_pe && (next_vm || next_rpl > next_iopl)));

                do {
                    next_tr_valid   = random.nextBoolean();
                    next_tr_type    = random.nextInt(16);
                }while(next_tr_valid == false || (next_tr_type != 9 && next_tr_type != 11));

                do {
                    next_tr_limit   = random.nextInt(1048576);
                }while(next_tr_limit < 103);

                int permission_base = 0;
                do {
                    permission_base = random.nextInt(65536);
                    next_port       = random.nextInt(65536);
                    next_tr_limit   = random.nextInt(1048576-103); next_tr_limit += 103;
                }while( !(permission_base + (next_port/8) >= next_tr_limit));

                next_tr_base    = random.nextInt();

                MemoryPatchLayer tss_patch = new MemoryPatchLayer(random, prohibited_list, (int)(next_tr_base + 102),
                         (byte)(permission_base & 0xFF), ((permission_base >> 8) & 0xFF));
                layers.addFirst(tss_patch);
            }

            if(type == 4) {
                do {
                    next_rpl        = random.nextInt(4);
                    next_cr0_pe     = random.nextBoolean();
                    next_vm         = random.nextBoolean();
                    next_iopl       = random.nextInt(4);
                }while( !(next_cr0_pe && (next_vm || next_rpl > next_iopl)));

                do {
                    next_tr_valid   = random.nextBoolean();
                    next_tr_type    = random.nextInt(16);
                }while(next_tr_valid == false || (next_tr_type != 9 && next_tr_type != 11));

                do {
                    next_tr_limit   = random.nextInt(1048576);
                }while(next_tr_limit < 103);

                int permission_base = 0;
                do {
                    permission_base = random.nextInt(65536);
                    next_port       = random.nextInt(65536);
                    next_tr_limit   = random.nextInt(1048576-103); next_tr_limit += 103;
                }while(permission_base + (next_port/8) >= next_tr_limit);

                next_tr_base    = random.nextInt();
                
                MemoryPatchLayer tss_patch = new MemoryPatchLayer(random, prohibited_list, (int)(next_tr_base + 102),
                         (byte)(permission_base & 0xFF), ((permission_base >> 8) & 0xFF));
                layers.addFirst(tss_patch);

                int permission_bits = 0;
                if(random.nextInt(4) == 0) permission_bits = random.nextInt();
                
                 MemoryPatchLayer perm_patch = new MemoryPatchLayer(random, prohibited_list, (int)(next_tr_base + permission_base + next_port/8 + 0),
                         (byte)(permission_bits & 0xFF), (permission_bits >> 8) & 0xFF);
                 layers.addFirst(perm_patch);
            }

            if(type == 5) {
                do {
                    next_rpl        = random.nextInt(4);
                    next_cr0_pe     = random.nextBoolean();
                    next_vm         = random.nextBoolean();
                    next_iopl       = random.nextInt(4);
                }while( !(next_cr0_pe && (next_vm || next_rpl > next_iopl)));

                do {
                    next_tr_valid   = random.nextBoolean();
                    next_tr_type    = random.nextInt(16);
                }while(next_tr_valid == false || (next_tr_type != 9 && next_tr_type != 11));

                do {
                    next_tr_limit   = random.nextInt(1048576);
                }while(next_tr_limit < 103);

                int permission_base = 0;
                do {
                    permission_base = random.nextInt(65536);
                    next_port       = random.nextInt(65536);
                    next_tr_limit   = random.nextInt(1048576-103); next_tr_limit += 103;
                }while(permission_base + (next_port/8) >= next_tr_limit);

                next_tr_base    = random.nextInt();
                
                MemoryPatchLayer tss_patch = new MemoryPatchLayer(random, prohibited_list, (int)(next_tr_base + 102),
                         (byte)(permission_base & 0xFF), ((permission_base >> 8) & 0xFF));
                 layers.addFirst(tss_patch);

                int permission_bits = 0;
                
                 MemoryPatchLayer perm_patch = new MemoryPatchLayer(random, prohibited_list, (int)(next_tr_base + permission_base + next_port/8 + 0),
                         (byte)(permission_bits & 0xFF), (permission_bits >> 8) & 0xFF);
                 layers.addFirst(perm_patch);
            }
            
            InstructionLayer instr  = new InstructionLayer(random, prohibited_list, true);
            layers.add(instr);
            StackLayer stack        = new StackLayer(random, prohibited_list);
            layers.add(stack);
            layers.add(new OtherLayer(next_cr0_pe? OtherLayer.Type.PROTECTED_OR_V8086 : OtherLayer.Type.REAL, random));
            layers.add(new FlagsLayer(next_vm? FlagsLayer.Type.V8086 : FlagsLayer.Type.NOT_V8086, random));
            layers.add(new GeneralRegisterLayer(random));
            layers.add(new SegmentLayer(random));
            layers.add(new MemoryLayer(random));
            layers.add(new IOLayer(random));
            layers.addFirst(new HandleModeChangeLayer(
                    getInput("cr0_pe"),
                    getInput("vmflag"),
                    next_rpl, //getInput("cs_rpl"),
                    getInput("cs_p"),
                    getInput("cs_s"),
                    getInput("cs_type")
            ));
            
            // instruction size
            boolean cs_d_b = getInput("cs_d_b") == 1;
            
            boolean a32 = random.nextBoolean();
            boolean o32 = random.nextBoolean();
            
            long cs_limit = getInput("cs_limit");
            long cs_rpl   = getInput("cs_rpl");
            
            
            final int     final_port        = (random.nextInt() & 0xFFFF0000) | (next_port & 0xFFFF);
            final long    final_rpl         = cs_rpl;
            final boolean final_tr_valid    = next_tr_valid;
            final int     final_tr_base     = next_tr_base;
            final int     final_tr_limit    = next_tr_limit;
            final int     final_tr_type     = next_tr_type;
            final int     final_iopl        = next_iopl;
            
            Layer layer = new Layer() {
                long edx()          { return final_port; }
                
                long iopl()         { return final_iopl; }
                
                long cs_rpl()       { return final_rpl; }
                
                long tr_valid()     { return final_tr_valid? 1 : 0; }
                long tr_base()      { return final_tr_base; }
                
                long tr_limit()     { return final_tr_limit; }
                
                long dr7()          { return 0x22220400L; } // disable debug register
                
                long tr_type()      { return final_tr_type; }
            };
            layers.addFirst(layer);
            
            //-----------
            final Random final_random = random;
            Layer layer_rep = new Layer() {
                long ecx() { return final_random.nextInt(5); }
               
                long esi() { 
                    int val = final_random.nextInt();
                    return ((val % 18) == 0)? 0 :
                           ((val % 18) == 1)? 1 :
                           ((val % 18) == 2)? 2 :
                           ((val % 18) == 3)? 3 :
                           ((val % 18) == 4)? 4 : 
                           ((val % 18) == 5)? 0xFFFFFFFF : 
                           ((val % 18) == 6)? 0x0000FFFF : 
                                             final_random.nextInt() & ((final_random.nextInt(3) == 0)? 0xFFFFFFFF : 0x00000FFF);
                }
                
                long edi() { 
                    int val = final_random.nextInt();
                    return ((val % 18) == 0)? 0 :
                           ((val % 18) == 1)? 1 :
                           ((val % 18) == 2)? 2 :
                           ((val % 18) == 3)? 3 :
                           ((val % 18) == 4)? 4 : 
                           ((val % 18) == 5)? 0xFFFFFFFF : 
                           ((val % 18) == 6)? 0x0000FFFF : 
                                             final_random.nextInt() & ((final_random.nextInt(3) == 0)? 0xFFFFFFFF : 0x00000FFF);
                }
            };
            layers.addFirst(layer_rep);
            //-----------
            
            String instruction_string = prepare_instr(cs_d_b, a32, o32);

            // add instruction
            instruction = instruction_string + instruction_string + "9090900F0F";
            
            instr.add_instruction(instruction); 
            
            // end condition
            break;
            
        }
   
        System.out.println("Instruction: [" + instruction + "]");
    }
    
    String prepare_instr(boolean cs_d_b, boolean a32, boolean o32) throws Exception {
        int opcodes[] = {
            0x6C,0x6D
        };
        
        String prefix = "";
        if(cs_d_b != o32) { prefix = "66" + prefix; }
        if(cs_d_b != a32) { prefix = "67" + prefix; }
        if(random.nextBoolean()) { prefix = "F2" + prefix; }
        if(random.nextBoolean()) { prefix = "F3" + prefix; }
        
        int opcode = opcodes[random.nextInt(opcodes.length)];
        
        int len = 1;
        
        byte instr[] = new byte[len];
        instr[0] = (byte)opcode;
        if(len >= 2) instr[1] = (byte)random.nextInt();
        
        return prefix + bytesToHex(instr);
    }
}
