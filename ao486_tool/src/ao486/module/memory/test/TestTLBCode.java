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

package ao486.module.memory.test;

import ao486.module.memory.AvalonListener;
import ao486.module.memory.GlobalListener;
import ao486.module.memory.Input;
import ao486.module.memory.Listener;
import ao486.module.memory.Output;
import ao486.module.memory.PrefetchListener;
import ao486.module.memory.Test;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Random;

class TestTLBCodeState {
    
    TestTLBCodeState(Random random) {
        this.random = random;
        
        do {
            cr3_base = random.nextLong();
            cr3_base &= 0xFFFFF000L;
        } while(Test.address_not_in_cache(cr3_base) || Test.address_not_in_cache(cr3_base + 0x1000L));
        
        cr3_pwt = true;
        cr3_pcd = true;
        
        linear_set = new HashSet<>();
    }
    
    boolean overlap(long a1, long a2, long b1, long b2) {
        if(b2 <= a2 && b2 >= a1) return true;
        if(b1 <= a2 && b1 >= a1) return true;
        return false;
    }
    
    void prepare(AvalonListener avalon, Long linear_requested) {
        
        //pde
        do {
            pde = random.nextLong();
            pde &= 0xFFFFF000L;
        } while(Test.address_not_in_cache(pde) || Test.address_not_in_cache(pde + 0x1000L) || overlap(cr3_base, cr3_base+ 0x1000L, pde, pde + 0x1000L));
        
        pde_pwt     = true;
        pde_pcd     = true;
        pde_present = true;
        pde_rw      = false;
        pde_su      = false;
        pde_accessed= false;
    
        //pte
        do {
            pte = random.nextLong();
            pte &= 0xFFFFF000L;
        } while(Test.address_not_in_cache(pte) || Test.address_not_in_cache(pte + 0x1000L) ||
                overlap(cr3_base, cr3_base+ 0x1000L, pte, pte + 0x1000L) || overlap(pde, pde+ 0x1000L, pte, pte + 0x1000L));
        
        pte_pwt     = true;
        pte_pcd     = true;
        pte_present = true;
        pte_rw      = false;
        pte_su      = false;
        pte_accessed= false;
        pte_dirty   = false;
    
        //linear
        if(linear_requested != null) {
            linear = linear_requested;
        }
        else {
            do {
                linear = random.nextLong();
                linear &= 0xFFFFFFFFL;
            } while(linear_set.contains(linear & 0xFFFFF000L));
        }
        
        linear_set.add(linear & 0xFFFFF000L);
        
        linear_pde = (linear >> 22) & 0x3FFL;
        linear_pte = (linear >> 12) & 0x3FFL;
        
        length = (int)(16 - (linear & 0xFL));
        if(length > 8) length = 8;
        length = 1 + random.nextInt(length);
        
        physical = pte | (linear & 0xFFFL);
        
        System.out.printf("Preparing for linear: %x, physical: %x\n", linear, physical);
        
        //----------
        
        long pde_value = pde;
        if(pde_present) pde_value |= 0x1L;
        if(pde_rw)      pde_value |= 0x2L;
        if(pde_su)      pde_value |= 0x4L;
        if(pde_pwt)     pde_value |= 0x8L;
        if(pde_pcd)     pde_value |= 0x10L;
        if(pde_accessed)pde_value |= 0x20L;
        
        avalon.set_memory(cr3_base | (linear_pde << 2), pde_value, 4);
        
        System.out.printf("set: [%x] = %x\n", cr3_base | (linear_pde << 2), pde_value);
        
        //System.out.printf("linear: %x\n", linear);
        //System.out.printf("pde addr[%x] = %x\n", cr3_base | (linear_pde << 2), pde_value);
        
        long pte_value = pte;
        if(pte_present) pte_value |= 0x1L;
        if(pte_rw)      pte_value |= 0x2L;
        if(pte_su)      pte_value |= 0x4L;
        if(pte_pwt)     pte_value |= 0x8L;
        if(pte_pcd)     pte_value |= 0x10L;
        if(pte_accessed)pte_value |= 0x20L;
        if(pte_dirty)   pte_value |= 0x40L;
        
        avalon.set_memory(pde | (linear_pte << 2), pte_value, 4);
        
        System.out.printf("set: [%x] = %x\n", pde | (linear_pte << 2), pte_value);
        System.out.println("------");
    }
    
    Random random;
    
    long cr3_base;
    boolean cr3_pwt;
    boolean cr3_pcd;
    
    long pde;
    boolean pde_pwt;
    boolean pde_pcd;
    boolean pde_present;
    boolean pde_rw;
    boolean pde_su;
    boolean pde_accessed;
    
    long pte;
    boolean pte_pwt;
    boolean pte_pcd;
    boolean pte_present;
    boolean pte_rw;
    boolean pte_su;
    boolean pte_accessed;
    boolean pte_dirty;
    
    long linear;
    long linear_pde;
    long linear_pte;
    
    long physical;
    
    int length;
    
    HashSet<Long> linear_set;
}

public class TestTLBCode extends Test implements Listener, PrefetchListener.PrefetchInterface {
    
    void go(long seed) throws Exception {
        random = new Random(seed);
        
        avalon   = new AvalonListener(random, this);
        prefetch = new PrefetchListener();
        global   = new GlobalListener();
        
        finish_cycle = 0;
        counter = 1;
        
        state = new TestTLBCodeState(random);
        code_stream = new LinkedList<>();
        
        global.set(true, false, false, true, true, false, state.cr3_base, state.cr3_pcd, state.cr3_pwt, false, true);
        
//System.out.printf("addr: %x\n", pde | (linear_pde << 2));
        
        long cs_base = 0xFFFF0000L;
        long eip     = 0x0FFF0L;
        long cpl     = 0;
        long cs_limit= eip + 16;
        
        state.prepare(avalon, cs_base + eip);
        
        for(int i=0; i<16; i++) {
            long b = avalon.get_memory(state.physical + i);
            code_stream.add((byte)b);
            
            //System.out.printf("[%x] = %x\n", cs_base + eip + i, b);
        }

        prefetch.prefetch(cpl, eip, cs_base, cs_limit, this);
        
        //----------
        
        LinkedList<Listener> listeners = new LinkedList<>();
        listeners.add(avalon);
        listeners.add(prefetch);
        listeners.add(global);
        listeners.add(this);
        
        run_simulation(listeners);
    }
    
    @Override
    public void prefetched(int cycle, long value, long size) throws Exception {
        for(int i=0; i<size; i++) {
            if(code_stream.isEmpty()) throw new Exception("Code stream is empty: i: " + i);
            
            byte expected = code_stream.pop();
            if(expected != (byte)value) throw new Exception("Invalid prefetched code: i: " + i + String.format(", expected: %x, value: %x", expected, (byte)value));
            
            //System.out.printf("expected: %x == value: %x, size: %d\n", expected, (byte)value, code_stream.size());
            
            value >>= 8;
        }
    }
    @Override
    public void prefetch_page_fault(int cycle, long cr2, long error_code) throws Exception {
        throw new Exception("prefetch pf.");
    }
    @Override
    public void prefetch_gp_fault(int cycle) throws Exception {
        if(code_stream.size() > 0) throw new Exception("prefetch gp fault before limit reached.");
        
        counter++;
        
        if(counter >= 100) {
            finish_cycle = cycle+1;
            return;
        }
        
        do {
            long cs_base = random.nextLong() & 0x000FFFFFL;
            long eip     = random.nextLong() & 0x000FFFFFL;
            long cpl     = 0;
            long cs_limit= eip + random.nextInt(512);
            
            //can cross pages
            if(((cs_base+eip) & 0xFFFFF000L) != ((cs_base + cs_limit) & 0xFFFFF000L)) continue;
            
            if(cs_base + eip >= 0x100000000L) continue;
            
            if(state.linear_set.contains((cs_base + eip) & 0xFFFFF000L)) {
                //System.out.printf("can not accept: %x\n", (cs_base + eip) & 0xFFFFF000L);
                continue;
            }
            
            state.prepare(avalon, cs_base + eip);
            
            int minus_i = 0;
            for(int i=0; i<cs_limit - eip + 1; i++) {
                
                long b = avalon.get_memory(state.physical + i - minus_i);
                code_stream.add((byte)b);

                //System.out.printf("[%x] = %x\n", state.physical + i, b);
            }

            prefetch.prefetch(cpl, eip, cs_base, cs_limit, this);
            break;
        }while(true);
        
        global.set_reset(true, false, false, false);
        reset_cycle = cycle+1;
    }
    
    @Override
    public void set_input(int cycle, Input input) throws Exception {
        if(cycle >= finish_cycle && finish_cycle > 0) {
            input.finished = true;
        }
        
        if(cycle >= reset_cycle && reset_cycle > 0) {
            global.set_reset(false, false, false, false);
            reset_cycle = 0;
        }
    }

    @Override
    public void get_output(int cycle, Output output) throws Exception {
    }
    
    @Override
    public void avalon_read(int cycle, long read_address) throws Exception {
        last_read_address = read_address;
    }
    
    int counter;
    Random random;
    
    LinkedList<Byte> code_stream;
    
    int finish_cycle;
    int reset_cycle;
    
    long last_read_address;
    
    TestTLBCodeState state;
    
    AvalonListener      avalon;
    PrefetchListener    prefetch;
    GlobalListener      global;
    
    //-------------
    
    public static void main(String args[]) throws Exception {
        TestTLBCode test1 = new TestTLBCode();
        
        for(int i=0; i<1; i++) {
            test1.go(i);

            System.out.println("Run " + i + " complete.");
        }
        
        System.out.println("[Main] thread end.");
    }
}
