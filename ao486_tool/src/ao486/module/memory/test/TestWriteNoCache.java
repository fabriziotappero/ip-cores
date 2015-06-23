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
import ao486.module.memory.Input;
import ao486.module.memory.Listener;
import ao486.module.memory.Output;
import ao486.module.memory.Test;
import ao486.module.memory.WriteListener;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Random;

public class TestWriteNoCache extends Test implements Listener, WriteListener.WriteInterface {
    
    void go(long seed) throws Exception {
        random = new Random(seed);
        
        avalon = new AvalonListener(random, this);
        write  = new WriteListener();
        
        expected_values = new HashMap<>();
        
        finish_cycle = 0;
        counter = 1;
        
        address = (counter << 5) + random.nextInt(16);
        length  = 1 + random.nextInt(4);
        value   = random.nextLong();
        value &= 0xFFFFFFFF;
        
        write.write(4, 0, address, length, false, false, value, this);
        
        //----------
        
        LinkedList<Listener> listeners = new LinkedList<>();
        listeners.add(avalon);
        listeners.add(write);
        listeners.add(this);
        
        run_simulation(listeners);
    }
    
    @Override
    public void written(int cycle) throws Exception {
        
        //check written value
        long key_address = address | (((long)length) << 32);
        expected_values.put(key_address, value);
        //System.out.printf("Adding: address: %x, length: %d, value: %x\n", address, length, value);
        counter++;
        
        if(counter >= 1000) {
            finish_cycle = cycle+20;
            return;
        }
        
        address = (counter << 5) + random.nextInt(16);
        length  = 1 + random.nextInt(4);
        value   = random.nextLong();
        value &= 0xFFFFFFFF;
        
        write.write(cycle+1, 0, address, length, false, false, value, this);
    }

    @Override
    public void write_page_fault(int cycle, long cr2, long error_code) throws Exception {
        throw new Exception("write page fault: " + cycle + ", cr2: " + cr2 + ", error_code: " + error_code);
    }

    @Override
    public void write_ac_fault(int cycle) throws Exception {
        throw new Exception("write ac fault.");
    }
    
    @Override
    public void set_input(int cycle, Input input) throws Exception {
        if(cycle >= finish_cycle && finish_cycle > 0) {
            input.finished = true;
        
            //check written values
            for(long key : expected_values.keySet()) {
                long local_address = key & 0xFFFFFFFFL;
                long local_length  = (key >> 32);
                long local_value   = expected_values.get(key);
                
                for(int i=0; i<local_length; i++) {
                    long data = avalon.get_memory(local_address + i);
                    if((local_value & 0xFF) != (data & 0xFF)) {
                        throw new Exception(String.format("Value mismatch: local_addr: %x, local_length: %d, i: %d, data: %x\n", local_address, local_length, i, data));
                    }
                    local_value >>= 8;
                }
            }
        }
    }

    @Override
    public void get_output(int cycle, Output output) throws Exception {
    }
    
    long address;
    int  length;
    long value;
    
    int counter;
    Random random;
    
    int finish_cycle;
    
    HashMap<Long, Long> expected_values; //map address -> value
    
    AvalonListener avalon;
    WriteListener  write;
    
    //-------------
    
    public static void main(String args[]) throws Exception {
        TestWriteNoCache test1 = new TestWriteNoCache();
        
        for(int i=0; i<10; i++) {
            test1.go(i);

            System.out.println("Run " + i + " complete.");
        }
        
        System.out.println("[Main] thread end.");
    }
}
