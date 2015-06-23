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
import ao486.module.memory.ReadListener;
import ao486.module.memory.Test;
import java.util.LinkedList;
import java.util.Random;

public class TestReadNoCache extends Test implements Listener, ReadListener.ReadInterface {
    
    void go(long seed) throws Exception {
        random = new Random(seed);
        
        avalon = new AvalonListener(random, this);
        read   = new ReadListener();
        
        finish_cycle = 0;
        counter = 1;
        
        long address = (counter << 4) + random.nextInt(16);
        length  = 1 + random.nextInt(8);
        value   = random.nextLong();
        avalon.set_memory(address, value, length);
        
        read.read(4, 0, address, length, false, false, this);
        
        //----------
        
        LinkedList<Listener> listeners = new LinkedList<>();
        listeners.add(avalon);
        listeners.add(read);
        listeners.add(this);
        
        run_simulation(listeners);
    }
    @Override
    public void read(int cycle, long data) throws Exception {
        //System.out.printf("Read value: %x\n", data);
        
        for(int i=0; i<length; i++) {
            if((value & 0xFF) != (data & 0xFF)) throw new Exception(String.format("Value mismatch: value = %x, data: %x", value, data));
            
            value >>= 8;
            data >>= 8;
        }
        
        counter++;
        
        if(counter >= 100) {
            finish_cycle = cycle+1;
            return;
        }
        
        long address = (counter << 4) + random.nextInt(16);
        length  = 1 + random.nextInt(8);
        value   = random.nextLong();
        avalon.set_memory(address, value, length);
        
        read.read(cycle+1, 0, address, length, false, false, this);
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
    public void set_input(int cycle, Input input) throws Exception {
        if(cycle >= finish_cycle && finish_cycle > 0) input.finished = true;
    }

    @Override
    public void get_output(int cycle, Output output) throws Exception {
    }
    
    int  length;
    long value;
    
    int counter;
    Random random;
    
    int finish_cycle;
    
    AvalonListener avalon;
    ReadListener   read;
    
    //-------------
    
    public static void main(String args[]) throws Exception {
        
        TestReadNoCache test1 = new TestReadNoCache();
        
        for(int i=0; i<100; i++) {
            test1.go(i);

            System.out.println("Run " + i + " complete.");
        }
        
        System.out.println("[Main] thread end.");
    }
}
