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

import ao486.test.TestUnit.Descriptor;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Random;

public class DescriptorTableLayer extends Layer {
    
    public DescriptorTableLayer(Random random, LinkedList<Pair<Long, Long>> prohibited_list, boolean ldtr_valid) {
        this.random = random;
        
        while(true) {
            gdtr_base = norm(random.nextInt());
            gdtr_limit = random.nextInt(0xFFFF + 1);
            
            if( gdtr_base + gdtr_limit < 4294967296L &&
                collides(prohibited_list, gdtr_base, gdtr_base + gdtr_limit) == false    
            ) break;
        }
        prohibited_list.add(new Pair<>(gdtr_base, gdtr_base+gdtr_limit));
        
        while(true) {
            ldtr_base = norm(random.nextInt());
            ldtr_limit = random.nextInt(0xFFFF + 1);
            
            if( ldtr_base + ldtr_limit < 4294967296L &&
                collides(prohibited_list, (int)ldtr_base, (int)(ldtr_base + ldtr_limit)) == false    
            ) break;
        }
        prohibited_list.add(new Pair<>(ldtr_base, ldtr_base+ldtr_limit));
        
        this.ldtr_valid = ldtr_valid;
    }
    
    /** @return -1 : no index that is out of bounds
     */
    public int getOutOfBoundsIndex(boolean is_ldtr) {
        if(is_ldtr) {
            long limit = (new_ldtr_enabled)? new_ldtr_limit : ldtr_limit;
            
            if(limit >= 65535) return -1;
            
            long offset = random.nextInt(65535-(int)limit);
            offset += limit + 1;
            
            return (int)(offset >> 3);
        }
        else {
            if(gdtr_limit >= 65535) return -1;
            
            long offset = random.nextInt(65535-(int)gdtr_limit);
            offset += gdtr_limit + 1;
            
            return (int)(offset >> 3);
        }
    }
    
    public int addDescriptor(boolean is_ldtr, Descriptor desc) {
        long offset = 0;
        long index = 0;
        
        while(true) {
            if(is_ldtr) {
                long limit              = (new_ldtr_enabled)? new_ldtr_limit : ldtr_limit;
                long base               = (new_ldtr_enabled)? new_ldtr_base : ldtr_base;
                HashSet<Integer> set    = (new_ldtr_enabled)? new_ldtr_set : ldtr_set;
                
                if(limit <= 6) return -1;

                long ldtr_limit_norm = (limit+1) & 0xFFF8;
                int ldtr_max = (int)(ldtr_limit_norm/8);
                if(set.size() >= ldtr_max) return -1;

                offset = random.nextInt((int)((limit+1) & 0xFFF8));
                offset &= 0xFFF8;
                
                if(set.contains((int)offset)) continue;
                set.add((int)offset);
                
                index = offset >> 3; 
                offset += base;
            }
            else {
                if(gdtr_limit <= 6) return -1;
                
                long gdtr_limit_norm = (gdtr_limit+1) & 0xFFF8;
                int gdtr_max = (int)(gdtr_limit_norm/8);
                if(gdtr_set.size() >= gdtr_max) return -1;
                
                offset = random.nextInt((int)((gdtr_limit+1) & 0xFFF8));
                offset &= 0xFFF8;
                
                if(gdtr_set.contains((int)offset)) continue;
                gdtr_set.add((int)offset);
                
                index = offset >> 3;
                offset += gdtr_base;
            }
            break;
        }
        
        for(int i=0; i<8; i++) {
            descr_map.put(offset+i, desc.get_byte(i));
        }
        
        return (int)index;
    }
    
    public void setup_new_ldt(int new_ldtr_base, int new_ldtr_limit) {
        if(new_ldtr_enabled) return;
        
        new_ldtr_enabled = true;
        
        this.new_ldtr_base  = norm(new_ldtr_base);
        this.new_ldtr_limit = norm(new_ldtr_limit);
    }
    
    //----------
    public long    gdtr_base()  { return gdtr_base; }
    public long    gdtr_limit() { return gdtr_limit; }
    
    public long    ldtr_base()  { return ldtr_base; }
    public long    ldtr_limit() { return ldtr_limit; }
    
    public long    ldtr_valid() { return ldtr_valid? 1 : 0; }
    
    public boolean is_memory_not_random(long address) { return descr_map.containsKey(address); }
    
    public Byte get_memory(long address) {
        return (descr_map.containsKey(address) == false)? null : descr_map.get(address);
    }
    
    //----------
    long gdtr_base, gdtr_limit;
    long ldtr_base, ldtr_limit;
    boolean ldtr_valid;
    
    HashMap<Long, Byte>    descr_map = new HashMap<>();
    HashSet<Integer>       ldtr_set  = new HashSet<>();
    HashSet<Integer>       gdtr_set  = new HashSet<>();
    
    //--- new ldt
    boolean new_ldtr_enabled;
    long new_ldtr_base, new_ldtr_limit;
    HashSet<Integer> new_ldtr_set  = new HashSet<>();
}
