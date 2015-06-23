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
import ao486.module.memory.ReadListener;
import ao486.module.memory.Test;
import java.util.LinkedList;
import java.util.Random;

class TestReadCacheLRUState {
    
    TestReadCacheLRUState(Random random) {
        this.random = random;
        
        address_middle_base = random.nextLong();
        address_middle_base &= 0x00000FF0L;
    }
    
    boolean select_0() {
        if(active_0 == false) return false;
        
        next_address_base = address_middle_base | address_0_base;
        
        plru_0 = true;
        plru_1 = true;
        
        return true;
    }
    boolean select_1() {
        if(active_1 == false || active_0 == false) return false;
        
        next_address_base = address_middle_base | address_1_base;
        
        plru_0 = true;
        plru_1 = false;
        
        return true;
    }
    boolean select_2() {
        if(active_2 == false || active_0 == false || active_1 == false) return false;
        
        next_address_base = address_middle_base | address_2_base;
        
        plru_0 = false;
        plru_2 = true;
        
        return true;
    }
    boolean select_3() {
        if(active_3 == false || active_0 == false || active_1 == false || active_2 == false) return false;
        
        next_address_base = address_middle_base | address_3_base;
        
        plru_0 = false;
        plru_2 = false;
        
        return true;
    }
    void select_new() {
        if(active_0 == false) {
            active_0 = true;
            
            plru_0 = true;
            plru_1 = true;
            
            do {
                address_0_base = random.nextLong();
                address_0_base &= 0xFFFFF000L;
            } while(Test.address_not_in_cache(address_0_base) || address_0_base == address_1_base || address_0_base == address_2_base || address_0_base == address_3_base);
            
            next_address_base = address_middle_base | address_0_base;
        }
        else if(active_1 == false) {
            active_1 = true;
            
            plru_0 = true;
            plru_1 = false;
            
            do {
                address_1_base = random.nextLong();
                address_1_base &= 0xFFFFF000L;
            } while(Test.address_not_in_cache(address_1_base) || address_1_base == address_0_base || address_1_base == address_2_base || address_1_base == address_3_base);
            
            next_address_base = address_middle_base | address_1_base;
        }
        else if(active_2 == false) {
            active_2 = true;
            
            plru_0 = false;
            plru_2 = true;
            
            do {
                address_2_base = random.nextLong();
                address_2_base &= 0xFFFFF000L;
            } while(Test.address_not_in_cache(address_2_base) || address_2_base == address_0_base || address_2_base == address_1_base || address_2_base == address_3_base);
            
            next_address_base = address_middle_base | address_2_base;
        }
        else if(active_3 == false) {
            active_3 = true;
            
            plru_0 = false;
            plru_2 = false;
            
            do {
                address_3_base = random.nextLong();
                address_3_base &= 0xFFFFF000L;
            } while(Test.address_not_in_cache(address_3_base) || address_3_base == address_0_base || address_3_base == address_1_base || address_3_base == address_2_base);
            
            next_address_base = address_middle_base | address_3_base;
        }
        else {
            if(plru_0 == false && plru_1 == false) { //0
                plru_0 = true;
                plru_1 = true;
                
                next_writeback = true;
                next_writeback_address = address_middle_base | address_0_base;
                
                do {
                    address_0_base = random.nextLong();
                    address_0_base &= 0xFFFFF000L;
                } while(Test.address_not_in_cache(address_0_base) || address_0_base == address_1_base || address_0_base == address_2_base || address_0_base == address_3_base);
                
                next_address_base = address_middle_base | address_0_base;
            }
            else if(plru_0 == false && plru_1 == true) { //1
                plru_0 = true;
                plru_1 = false;
                
                next_writeback = true;
                next_writeback_address = address_middle_base | address_1_base;
                
                do {
                    address_1_base = random.nextLong();
                    address_1_base &= 0xFFFFF000L;
                } while(Test.address_not_in_cache(address_1_base) || address_1_base == address_0_base || address_1_base == address_2_base || address_1_base == address_3_base);
                
                next_address_base = address_middle_base | address_1_base;
            }
            else if(plru_0 == true && plru_2 == false) { //2
                plru_0 = false;
                plru_2 = true;
                
                next_writeback = true;
                next_writeback_address = address_middle_base | address_2_base;
                
                do {
                    address_2_base = random.nextLong();
                    address_2_base &= 0xFFFFF000L;
                } while(Test.address_not_in_cache(address_2_base) || address_2_base == address_0_base || address_2_base == address_1_base || address_2_base == address_3_base);
                
                next_address_base = address_middle_base | address_2_base;
            }
            else if(plru_0 == true && plru_2 == true) { //3
                plru_0 = false;
                plru_2 = false;
                
                next_writeback = true;
                next_writeback_address = address_middle_base | address_3_base;
                
                do {
                    address_3_base = random.nextLong();
                    address_3_base &= 0xFFFFF000L;
                } while(Test.address_not_in_cache(address_3_base) || address_3_base == address_0_base || address_3_base == address_1_base || address_3_base == address_2_base);
                
                next_address_base = address_middle_base | address_3_base;
            }
        }
    }
    
    void select() {
        
        while(true) {
            int val = random.nextInt(5);
            
            if(val >= 0 && val <= 3)    next_read_from_cache = true;
            else                        next_read_from_cache = false;
            
            if(val == 0) {
                boolean accepted = select_0();
                if(accepted == false) continue;
                break;
            }
            else if(val == 1) {
                boolean accepted = select_1();
                if(accepted == false) continue;
                break;
            }
            else if(val == 2) {
                boolean accepted = select_2();
                if(accepted == false) continue;
                break;
            }
            else if(val == 3) {
                boolean accepted = select_3();
                if(accepted == false) continue;
                break;
            }
            else {
                select_new();
                break;
            }
        }
    }
    
    private Random random;
    
    private long address_middle_base;
    
    private long address_0_base;
    private long address_1_base;
    private long address_2_base;
    private long address_3_base;
    
    private boolean active_0;
    private boolean active_1;
    private boolean active_2;
    private boolean active_3;
    
    private boolean plru_0;
    private boolean plru_1;
    private boolean plru_2;
    
    long next_address_base;
    
    boolean next_writeback;
    long    next_writeback_address;
    
    boolean next_read_from_cache;
}

public class TestReadCacheLRU extends Test implements Listener, ReadListener.ReadInterface {
    
    void go(long seed) throws Exception {
        random = new Random(seed);
        state  = new TestReadCacheLRUState(random);
        
        avalon = new AvalonListener(random, this);
        read   = new ReadListener();
        global = new GlobalListener();
        
        global.set(false, false, false, false, true, false, 0xABCDE000, false, false, false, false);
        
        finish_cycle = 0;
        counter = 1;
        
        state.select();
        
        length  = 1 + random.nextInt(8);
        address = state.next_address_base + random.nextInt(16 - length + 1);
        
        read_cycle = 257;
        read.read(read_cycle, 0, address, length, false, false, this);
        
        //----------
        
        LinkedList<Listener> listeners = new LinkedList<>();
        listeners.add(avalon);
        listeners.add(read);
        listeners.add(global);
        listeners.add(this);
        
        run_simulation(listeners);
    }
    @Override
    public void read(int cycle, long data) throws Exception {
        //System.out.printf("Read value: %x\n", data);
        
        for(int i=0; i<length; i++) {
            long value = avalon.get_memory(address+i);
            
            if((value & 0xFF) != (data & 0xFF)) throw new Exception(String.format("Value mismatch: data: %x, value: %x, i: %d, address: %x", data, value, i, address));
            
            value >>= 8;
            data >>= 8;
        }
        
        // read only: no writeback
        //if(state.next_writeback) throw new Exception("No writeback detected.");
        
        if((cycle - read_cycle) >= 5 && state.next_read_from_cache)         throw new Exception("Expected cache read.");
        if((cycle - read_cycle) < 5 && state.next_read_from_cache == false) throw new Exception("Expected not cache read.");
        
        counter++;
        
        if(counter >= 1000) {
            finish_cycle = cycle+1;
            return;
        }
        
        state.select();
        
        length  = 1 + random.nextInt(8);
        address = state.next_address_base + random.nextInt(16 - length + 1);
        
        read_cycle = cycle+1;
        read.read(read_cycle, 0, address, length, false, false, this);
    }

    @Override
    public void read_page_fault(int cycle, long cr2, long error_code) throws Exception {
        throw new Exception("read_page_fault: cr2: " + cr2 + ", error_code: " + error_code);
    }

    @Override
    public void read_ac_fault(int cycle) throws Exception {
        throw new Exception("read_ac_fault.");
    }
    
    @Override
    public void avalon_write(int cycle, long write_address) throws Exception {
        throw new Exception("avalon_write not expected.");
    }
    
    @Override
    public void set_input(int cycle, Input input) throws Exception {
        if(cycle >= finish_cycle && finish_cycle > 0) input.finished = true;
    }

    @Override
    public void get_output(int cycle, Output output) throws Exception {
    }
    
    int  length;
    long address;
    
    TestReadCacheLRUState state;
    
    Random random;
    
    int counter;
    int read_cycle;
    int finish_cycle;
    
    AvalonListener avalon;
    ReadListener   read;
    GlobalListener global;
    
    //-------------
    
    public static void main(String args[]) throws Exception {
        TestReadCacheLRU test1 = new TestReadCacheLRU();
        
        for(int i=0; i<10; i++) {
            test1.go(i);

            System.out.println("Run " + i + " complete.");
        }
        
        System.out.println("[Main] thread end.");
    }
}
