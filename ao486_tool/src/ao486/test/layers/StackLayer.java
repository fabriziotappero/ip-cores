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

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Random;

public class StackLayer extends Layer {
    public StackLayer(Random random, LinkedList<Pair<Long, Long>> prohibited_list) {
        this.random = random;
        
        ss_d_b = random.nextBoolean();
        
        while(true) {
            ss_base = norm(random.nextInt());

            ss_limit = random.nextInt(ss_d_b? 0xFFFFF + 1 : 0xFFFF + 1);
            
            if( ss_base + ss_limit < 4294967296L &&
                collides(prohibited_list, ss_base, ss_base + ss_limit) == false    
            ) break;
        }
        esp = random.nextInt((int)ss_limit + 1);
        ss_index = ss_base + esp;
        
        if(ss_d_b == false) {
            esp |= random.nextInt() & 0xFFFF0000;
        }
        
        prohibited_list.add(new Pair<>(ss_base, ss_base+ss_limit));
    }
    public void push_byte(int value) {
//System.out.printf("push_byte: %08x :: %08x\n", ss_index, value);
        if(ss_index > ss_base + ss_limit) return;
        ss_map.put(ss_index, (byte)(value & 0xFF));
        ss_index++;
    }
    public void push_word(int value) {
//System.out.printf("push_word: %08x :: %08x\n", ss_index, value);
        if(ss_index > ss_base + ss_limit) return;
        ss_map.put(ss_index, (byte)(value & 0xFF));
        ss_index++;
        
        if(ss_index > ss_base + ss_limit) return;
        ss_map.put(ss_index, (byte)((value >> 8) & 0xFF));
        ss_index++;
    }
    public void push_dword(int value) {
//System.out.printf("push_dword: %08x :: %08x\n", ss_index, value);
        if(ss_index > ss_base + ss_limit) return;
        ss_map.put(ss_index, (byte)(value & 0xFF));
        ss_index++;
        
        if(ss_index > ss_base + ss_limit) return;
        ss_map.put(ss_index, (byte)((value >> 8) & 0xFF));
        ss_index++;
        
        if(ss_index > ss_base + ss_limit) return;
        ss_map.put(ss_index, (byte)((value >> 16) & 0xFF));
        ss_index++;
        
        if(ss_index > ss_base + ss_limit) return;
        ss_map.put(ss_index, (byte)((value >> 24) & 0xFF));
        ss_index++;
    }
    
    //-----------
    
    public long esp() {
        return esp;
    }
    public long ss_base() {
        return ss_base;
    }
    public long ss_limit() {
        return ss_limit;
    }
    public long ss_d_b() {
        return ss_d_b? 1 : 0;
    }
    public boolean is_memory_not_random(long address) { return ss_map.containsKey(address); }
    
    public Byte get_memory(long address) {
        if(address < ss_base || address > ss_base + ss_limit) return null;
        
        if(ss_map.containsKey(address)) return ss_map.get(address);
        
        return (byte)random.nextInt();
    }
    
    HashMap<Long, Byte> ss_map = new HashMap<>();
    boolean ss_d_b;
    long ss_base, ss_limit, ss_index;
    long esp;
}
