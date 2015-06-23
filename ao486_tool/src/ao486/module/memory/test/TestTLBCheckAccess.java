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
import ao486.module.memory.CheckListener;
import ao486.module.memory.GlobalListener;
import ao486.module.memory.Input;
import ao486.module.memory.Listener;
import ao486.module.memory.Output;
import ao486.module.memory.ReadListener;
import ao486.module.memory.Test;
import ao486.module.memory.WriteListener;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Random;

class TestTLBCheckAccessState {
    
    TestTLBCheckAccessState(Random random) {
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
    
    void prepare(AvalonListener avalon) {
        
        //pde
        do {
            pde = random.nextLong();
            pde &= 0xFFFFF000L;
        } while(Test.address_not_in_cache(pde) || Test.address_not_in_cache(pde + 0x1000L) || overlap(cr3_base, cr3_base+ 0x1000L, pde, pde + 0x1000L));
        
        pde_pwt     = true;
        pde_pcd     = true;
        pde_present = random.nextInt(3) == 0;
        pde_rw      = random.nextBoolean();
        pde_su      = random.nextBoolean();
        pde_accessed= random.nextBoolean();
    
        //pte
        do {
            pte = random.nextLong();
            pte &= 0xFFFFF000L;
        } while(Test.address_not_in_cache(pte) || Test.address_not_in_cache(pte + 0x1000L) ||
                overlap(cr3_base, cr3_base+ 0x1000L, pte, pte + 0x1000L) || overlap(pde, pde+ 0x1000L, pte, pte + 0x1000L));
        
        pte_pwt     = true;
        pte_pcd     = true;
        pte_present = random.nextInt(3) == 0;
        pte_rw      = random.nextBoolean();
        pte_su      = random.nextBoolean();
        pte_accessed= random.nextBoolean();
        pte_dirty   = random.nextBoolean();
    
        //linear
        do {
            linear = random.nextLong();
            linear &= 0xFFFFFFFFL;
        } while(linear_set.contains(linear & 0xFFFFF000L));
        
        linear_set.add(linear & 0xFFFFF000L);
        
        linear_pde = (linear >> 22) & 0x3FFL;
        linear_pte = (linear >> 12) & 0x3FFL;
        
        length = (int)(16 - (linear & 0xFL));
        if(length > 8) length = 8;
        length = 1 + random.nextInt(length);
        
        physical = pte | (linear & 0xFFFL);
        
        //----------
        
        long pde_value = pde;
        if(pde_present) pde_value |= 0x1L;
        if(pde_rw)      pde_value |= 0x2L;
        if(pde_su)      pde_value |= 0x4L;
        if(pde_pwt)     pde_value |= 0x8L;
        if(pde_pcd)     pde_value |= 0x10L;
        if(pde_accessed)pde_value |= 0x20L;
        
        avalon.set_memory(cr3_base | (linear_pde << 2), pde_value, 4);
        
        long pte_value = pte;
        if(pte_present) pte_value |= 0x1L;
        if(pte_rw)      pte_value |= 0x2L;
        if(pte_su)      pte_value |= 0x4L;
        if(pte_pwt)     pte_value |= 0x8L;
        if(pte_pcd)     pte_value |= 0x10L;
        if(pte_accessed)pte_value |= 0x20L;
        if(pte_dirty)   pte_value |= 0x40L;
        
        avalon.set_memory(pde | (linear_pte << 2), pte_value, 4);
    }
    
    boolean should_page_fault(boolean is_write, boolean cr0_wp) {
        
        boolean tlb_rw = pde_rw && pte_rw;
        boolean tlb_su = pde_su && pte_su;
        
        if(pde_present == false) return true;
        if(pte_present == false) return true;
        
        if(cr0_wp && tlb_rw == false && is_write) return true;
        
        return false;
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

public class TestTLBCheckAccess extends Test implements Listener, ReadListener.ReadInterface, WriteListener.WriteInterface, CheckListener.CheckInterface {
    
    void go(long seed) throws Exception {
        random = new Random(seed);
        
        avalon = new AvalonListener(random, this);
        check  = new CheckListener();
        global = new GlobalListener();
        
        finish_cycle = 0;
        counter = 1;
        
        state = new TestTLBCheckAccessState(random);
        
        global.set(true, random.nextBoolean(), false, true, true, false, state.cr3_base, state.cr3_pcd, state.cr3_pwt, true, false);
        
//System.out.printf("addr: %x\n", pde | (linear_pde << 2));
        
        state.prepare(avalon);
        
        is_write = random.nextBoolean();
        
        check.check(4, state.linear, is_write, this);
        
        //----------
        
        LinkedList<Listener> listeners = new LinkedList<>();
        listeners.add(avalon);
        listeners.add(check);
        listeners.add(global);
        listeners.add(this);
        
        run_simulation(listeners);
    }
    @Override
    public void read(int cycle, long data) throws Exception {
        //System.out.printf("Read value: %x from linear/physical %x/%x size %d\n", data, state.linear, state.physical, state.length);
    }

    @Override
    public void read_page_fault(int cycle, long cr2, long error_code) throws Exception {
        throw new Exception(String.format("read_page_fault: cr2: %x, error_code: %x", cr2, error_code));
    }
    @Override
    public void read_ac_fault(int cycle) throws Exception {
        throw new Exception("read_ac_fault.");
    }
    
    @Override
    public void written(int cycle) throws Exception {
    }
    @Override
    public void write_page_fault(int cycle, long cr2, long error_code) throws Exception {
        throw new Exception(String.format("write_page_fault: cr2: %x, error_code: %x", cr2, error_code));
    }
    @Override
    public void write_ac_fault(int cycle) throws Exception {
        throw new Exception("write_ac_fault.");
    }
    
    @Override
    public void checked(int cycle) throws Exception {
        
        boolean should_pf = state.should_page_fault(is_write, global.cr0_wp);
        if(should_pf) throw new Exception("checked() but should page fault.");
        
        checked_counter++;

        counter++;
        
        if(counter >= 1000) {
            System.out.println("checked_counter: " + checked_counter);
            
            finish_cycle = cycle+1;
            return;
        }
        
        state.prepare(avalon);
        
        is_write = random.nextBoolean();
        
        check.check(cycle+1, state.linear, is_write, this);
    }
    @Override
    public void check_page_fault(int cycle, long cr2, long error_code) throws Exception {
        //System.out.println("check_page_fault.");
        
        boolean should_pf = state.should_page_fault(is_write, global.cr0_wp);
        if(should_pf == false) throw new Exception("check_page_fault() but should not page fault.");
        
        counter++;
        
        if(counter >= 1000) {
            System.out.println("checked_counter: " + checked_counter);
            
            finish_cycle = cycle+1;
            return;
        }
        
        finish_reset_cycle = cycle+1;
        global.set_reset(false, false, true, false);
        
        state.prepare(avalon);
        
        is_write = random.nextBoolean();
        
        check.check(cycle+3, state.linear, is_write, this);
    }
    
    @Override
    public void set_input(int cycle, Input input) throws Exception {
        if(cycle >= finish_cycle && finish_cycle > 0) {
            input.finished = true;
        }
        
        if(cycle >= finish_reset_cycle && finish_reset_cycle > 0) {
            global.set_reset(false, false, false, false);
            finish_reset_cycle = 0;
        }
    }

    @Override
    public void get_output(int cycle, Output output) throws Exception {
    }
    
    @Override
    public void avalon_read(int cycle, long read_address) throws Exception {
    }
    
    int counter;
    Random random;
    
    int finish_cycle;
    
    TestTLBCheckAccessState state;
    
    int finish_reset_cycle;
    boolean is_write;
    
    int checked_counter;
    
    AvalonListener avalon;
    CheckListener  check;
    GlobalListener global;
    
    //-------------
    
    public static void main(String args[]) throws Exception {
        TestTLBCheckAccess test1 = new TestTLBCheckAccess();
        
        for(int i=0; i<1; i++) {
            test1.go(i);

            System.out.println("Run " + i + " complete.");
        }
        
        System.out.println("[Main] thread end.");
    }
}
