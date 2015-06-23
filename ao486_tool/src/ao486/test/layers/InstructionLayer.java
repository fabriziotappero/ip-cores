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

package ao486.test.layers;

import ao486.test.TestUnit;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Random;

/** 
 * base ------ eip(offset) ------- base + limit
 * 
 */
public class InstructionLayer extends Layer {
    public InstructionLayer(Random random, LinkedList<Pair<Long, Long>> prohibited_list, boolean is_real) {
        this.random = random;
        
        while(true) {
            cs_base = norm(is_real? random.nextInt(0xFFFF+1) : random.nextInt());
            if(is_real) cs_base &= 0xFFFFFFF0;
            
            cs_limit = random.nextInt(is_real? 0xFFFF + 1 : 0xFFFFF + 1);
            
            if( cs_base + cs_limit < 4294967296L &&
                collides(prohibited_list, (int)cs_base, (int)(cs_base + cs_limit)) == false    
            ) break;
        }
        if(is_real) { cs_selector = (cs_base >> 4); }
        
        eip = random.nextInt((int)cs_limit + 1);
        cs_index = cs_base + eip;
        
        prohibited_list.add(new Pair<>(cs_base, cs_base+cs_limit));
    }
    public InstructionLayer(Random random, LinkedList<Pair<Long, Long>> prohibited_list) {
        this.random = random;
        
        while(true) {
            cs_base = norm(random.nextInt());

            cs_limit = random.nextInt(0xFFFFF + 1);
            
            if( cs_base + cs_limit < 4294967296L &&
                collides(prohibited_list, (int)cs_base, (int)(cs_base + cs_limit)) == false    
            ) break;
        }
        eip = random.nextInt((int)cs_limit + 1);
        cs_index = cs_base + eip;
        
        prohibited_list.add(new Pair<>(cs_base, cs_base+cs_limit));
    }
    
    public void add_instruction(String instruction) throws Exception {
        byte bytes[] = TestUnit.hexToBytes(instruction);
        
        for(byte b : bytes) {
            if(cs_index <= cs_base + cs_limit) {
                cs_map.put(cs_index, b);
//System.out.printf("INSTR: %08x <- %x\n", cs_index, b);
                cs_index++;
            }
        }
    }
    
    //-----------
    public long cs() {
        return cs_selector;
    }
    public long eip() {
        return eip;
    }
    public long cs_base() {
        return cs_base;
    }
    public long cs_limit() {
        return cs_limit;
    }
    public boolean is_memory_not_random(long address) { return cs_map.containsKey(address); }
    
    public Byte get_memory(long address) {
        
//System.out.printf("instr get_memory: %08x, in map: %b\n", address, cs_map.containsKey(address));
        if(address < cs_base || address > cs_base + cs_limit) return null;
        
        if(cs_map.containsKey(address)) return cs_map.get(address);
        
        return (byte)random.nextInt();
    }
    HashMap<Long, Byte> cs_map = new HashMap<>();
    long cs_selector;
    
    long cs_base, cs_limit, cs_index;
    long eip;
}
