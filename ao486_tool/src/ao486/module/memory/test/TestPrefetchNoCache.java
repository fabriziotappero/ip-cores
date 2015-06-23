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
import java.util.LinkedList;
import java.util.Random;

public class TestPrefetchNoCache extends Test implements Listener, PrefetchListener.PrefetchInterface {
    
    void go(long seed) throws Exception {
        random = new Random(seed);
        
        avalon   = new AvalonListener(random, this);
        prefetch = new PrefetchListener();
        global   = new GlobalListener();
        
        finish_cycle = 0;
        counter = 1;
        
        
        code_stream = new LinkedList<>();
        
        long cs_base = 0xFFFFFFF0L;
        long eip     = 0x00000;
        long cpl     = 0;
        long cs_limit= 0x00000 + 16;
        
        for(int i=0; i<16; i++) {
            long b = random.nextInt() & 0xFF;
            
            avalon.set_memory(cs_base + eip + i, b, 1);
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
            long cs_base = random.nextLong() & 0xFFFFFFFFL;
            long eip     = random.nextLong() & 0xFFFFFFFFL;
            long cpl     = 0;
            long cs_limit= eip + random.nextInt(512);
            
            if(cs_limit >= 0x100000L) while((cs_limit & 0xFFFL) != 0xFFFL) cs_limit++;
System.out.printf("cs_limit: %x\n", cs_limit);
            if(cs_base + eip >= 0x100000000L) continue;
            
            for(int i=0; i<cs_limit - eip + 1; i++) {
                long b = random.nextInt() & 0xFF;

                avalon.set_memory(cs_base + eip + i, b, 1);
                code_stream.add((byte)b);

                //System.out.printf("[%x] = %x\n", cs_base + eip + i, b);
            }

            prefetch.prefetch(cpl, eip, cs_base, cs_limit, this);
            break;
        }while(true);
        
        global.set_reset(true, false, false, false);
        reset_cycle = cycle+1;
    }
    
    
    @Override
    public void set_input(int cycle, Input input) throws Exception {
        if(cycle >= finish_cycle && finish_cycle > 0) input.finished = true;
        
        if(cycle >= reset_cycle && reset_cycle > 0) {
            global.set_reset(false, false, false, false);
            reset_cycle = 0;
        }
    }

    @Override
    public void get_output(int cycle, Output output) throws Exception {
        
    }
    
    LinkedList<Byte> code_stream;
    
    int counter;
    Random random;
    
    int finish_cycle;
    int reset_cycle;
    
    AvalonListener      avalon;
    GlobalListener      global;
    PrefetchListener    prefetch;
    
    //-------------
    
    public static void main(String args[]) throws Exception {
        TestPrefetchNoCache test1 = new TestPrefetchNoCache();
        
        for(int i=0; i<1; i++) {
            test1.go(i);

            System.out.println("Run " + i + " complete.");
        }
        
        System.out.println("[Main] thread end.");
    }
}
