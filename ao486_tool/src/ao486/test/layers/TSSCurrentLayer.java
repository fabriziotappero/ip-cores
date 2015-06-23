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

public class TSSCurrentLayer extends Layer {
    public TSSCurrentLayer(Random random, Type type, int limit, int selector, LinkedList<Pair<Long, Long>> prohibited_list) {
        this.random = random;
        this.type = type;
        
        for(Pair<Long, Long> pair : prohibited_list) {
            System.out.printf("proh: %08x : %08x\n", pair.a, pair.b);
        }
        
        while(true) {
            tr_base = norm(random.nextInt());
            if(tr_base + tr_limit >= 0x100000000L) continue;
            if(collides(prohibited_list, tr_base, tr_base + limit) == false) break;
        }
        prohibited_list.add(new Pair<>(tr_base, tr_base + limit));
        
        tr_limit = limit;
        
        System.out.printf("TSSCurrentLayer: base: %08x, base+limit: %08x\n", tr_base, tr_base+tr_limit);
        
        tr_map.put(tr_base+0, (byte)(selector & 0xFF));
        tr_map.put(tr_base+1, (byte)((selector >> 8) & 0xFF));
    }
    
    public void add_ss_esp(int pl, long esp, int ss) {
        
        int offset = (type == Type.ACTIVE_286 || type == Type.BUSY_286)? 2 + pl*4 : 4 + pl*8;
        
        if(type == Type.ACTIVE_286 || type == Type.BUSY_286) {
            tr_map.put(tr_base+offset+0, (byte)(esp & 0xFF));
            tr_map.put(tr_base+offset+1, (byte)((esp >> 8) & 0xFF));
            
            tr_map.put(tr_base+offset+2, (byte)(ss & 0xFF));
            tr_map.put(tr_base+offset+3, (byte)((ss >> 8) & 0xFF));
        }
        else {
            tr_map.put(tr_base+offset+0, (byte)(esp & 0xFF));
            tr_map.put(tr_base+offset+1, (byte)((esp >> 8) & 0xFF));
            tr_map.put(tr_base+offset+2, (byte)((esp >> 16) & 0xFF));
            tr_map.put(tr_base+offset+3, (byte)((esp >> 24) & 0xFF));
            
            tr_map.put(tr_base+offset+4, (byte)(ss & 0xFF));
            tr_map.put(tr_base+offset+5, (byte)((ss >> 8) & 0xFF));
            tr_map.put(tr_base+offset+6, (byte)random.nextInt());
            tr_map.put(tr_base+offset+7, (byte)random.nextInt());
        }
    }
    
    public enum Type {
        BUSY_386,
        BUSY_286,
        ACTIVE_386,
        ACTIVE_286
    }
    
    long tr_limit;
    long tr_base;
    Type type;
    
    //-----------
    
    public long tr_base() {
        return tr_base;
    }
    public long tr_limit() {
        return tr_limit;
    }
    public long tr_type() throws Exception {
        //was: return 0xB;
        if(type == Type.BUSY_286)   return 0x3;
        if(type == Type.ACTIVE_286) return 0x1;
        
        if(type == Type.BUSY_386)   return 0xB;
        if(type == Type.ACTIVE_386) return 0x9;
        
        throw new Exception("Invalid TSS type: " + type);
    }
    public boolean is_memory_not_random(long address) { return tr_map.containsKey(address); }
    
    public Byte get_memory(long address) {
        if(address < tr_base || address > tr_base + tr_limit) return null;
        
        if(tr_map.containsKey(address)) return tr_map.get(address);
        
        return (byte)random.nextInt();
    }
    
    HashMap<Long, Byte> tr_map = new HashMap<>();
}
