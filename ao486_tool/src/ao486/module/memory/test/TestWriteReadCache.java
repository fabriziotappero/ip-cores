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
import ao486.module.memory.WriteListener;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Random;

public class TestWriteReadCache extends Test implements Listener, WriteListener.WriteInterface, ReadListener.ReadInterface {
    void go(long seed) throws Exception {
        random = new Random(seed);
        
        avalon = new AvalonListener(random, this);
        write  = new WriteListener();
        read   = new ReadListener();
        global = new GlobalListener();
        
        global.set(false, false, false, false, random.nextBoolean(), false, 0xABCDE000, false, false, false, false);
        
        written_memory = new HashMap<>();
        
        finish_cycle = 0;
        counter = 1;
        
        long address = random.nextLong();
        address &= 0xFFFFFFFFL;
        
        int length = 1 + random.nextInt(4);
        
        long value = random.nextLong();
        value &= 0xFFFFFFFFL;
        
        for(int i=0; i<length; i++) {
            written_memory.put(address+i, (byte)((value >> (i*8)) & 0xFF));
            //System.out.printf("write[%d]: %x <- %x\n", i, (address+i), (byte)((value >> (i*8)) & 0xFF));
        }
        
        write.write(257, 0, address, length, false, false, value, this);
        
        //----------
        
        LinkedList<Listener> listeners = new LinkedList<>();
        listeners.add(avalon);
        listeners.add(write);
        listeners.add(read);
        listeners.add(global);
        listeners.add(this);
        
        run_simulation(listeners);
    }
    
    @Override
    public void written(int cycle) throws Exception {
        
        counter++;
        
        if(counter >= 1000) {
            finish_cycle = cycle+20;
            return;
        }
        
        boolean read_new = random.nextInt(4) == 0;
        
        if(read_new) {
            boolean read_next = random.nextInt(2) == 0;
            
            if(read_next) {
                // find some written address
                Long addresses[] = new Long[written_memory.keySet().size()];
                written_memory.keySet().toArray(addresses);
                
                read_address = addresses[random.nextInt(addresses.length)];
                
                // find fist not written
                while(true) {
                    read_address++;
                    if(written_memory.containsKey(read_address) == false) break;
                }
                
                // length
                read_length = 1 + random.nextInt(8);
                
                read.read(cycle+1, 0, read_address, read_length, false, false, this);
            }
            else {
                // read from random address
                do {
                    read_address = random.nextLong();
                    read_address &= 0xFFFFFFFFL;
                } while(written_memory.containsKey(read_address));
                
                // length
                read_length = 1 + random.nextInt(8);
                
                read.read(cycle+1, 0, read_address, read_length, false, false, this);
            }
            
        }
        else {
            // read written values
            
            // find some written address
            Long addresses[] = new Long[written_memory.keySet().size()];
            written_memory.keySet().toArray(addresses);

            read_address = addresses[random.nextInt(addresses.length)];
            
            // length
            read_length = 1 + random.nextInt(8);
            
            read.read(cycle+1, 0, read_address, read_length, false, false, this);
        }
        //System.out.printf("read: %x, %d\n", read_address, read_length);
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
    public void read(int cycle, long data) throws Exception {
        
        // check read data
        for(int i=0; i<read_length; i++) {
            if(written_memory.containsKey(read_address+i)) {
                if((byte)(written_memory.get(read_address+i) & 0xFF) != (byte)(data & 0xFFL)) throw new Exception("check read data failed with written_memory.");
            }
            else if((byte)(avalon.get_memory(read_address+i) & 0xFF) != (byte)(data & 0xFFL)) {
                throw new Exception(String.format("check read data failed with avalon memory: read_address: %x, i: %d", (read_address + i), i));
            }
            
            data >>= 8;
        }
        
        // write next value
        long write_address;
        int write_length;
        
        long value = random.nextLong();
        value &= 0xFFFFFFFFL;
        
        boolean write_new = random.nextInt(4) == 0;
        
        if(write_new) {
            boolean write_next = random.nextInt(2) == 0;
            
            if(write_next) {
                // find some written address
                Long addresses[] = new Long[written_memory.keySet().size()];
                written_memory.keySet().toArray(addresses);
                
                write_address = addresses[random.nextInt(addresses.length)];
                
                // find fist not written
                while(true) {
                    write_address++;
                    if(written_memory.containsKey(write_address) == false) break;
                }
                
                // length
                write_length = 1 + random.nextInt(4);
            }
            else {
                // read from random address
                do {
                    write_address = random.nextLong();
                    write_address &= 0xFFFFFFFFL;
                } while(written_memory.containsKey(write_address));
                
                // length
                write_length = 1 + random.nextInt(4);
            }
            
        }
        else {
            // read written values
            
            // find some written address
            Long addresses[] = new Long[written_memory.keySet().size()];
            written_memory.keySet().toArray(addresses);

            write_address = addresses[random.nextInt(addresses.length)];
            
            // length
            write_length = 1 + random.nextInt(4);
        }
        
        for(int i=0; i<write_length; i++) {
            written_memory.put(write_address+i, (byte)((value >> (i*8)) & 0xFF));
            //System.out.printf("write[%d]: %x <- %x\n", i, (write_address+i), (byte)((value >> (i*8)) & 0xFF));
        }
        
        write.write(cycle+1, 0, write_address, write_length, false, false, value, this);
        
    }
    @Override
    public void read_page_fault(int cycle, long cr2, long error_code) throws Exception {
        throw new Exception("read_page_fault: " + cycle + ", cr2: " + cr2 + ", error_code: " + error_code);
    }
    @Override
    public void read_ac_fault(int cycle) throws Exception {
        throw new Exception("read_ac_fault.");
    }
    
    
    @Override
    public void set_input(int cycle, Input input) throws Exception {
        if(cycle >= finish_cycle && finish_cycle > 0) {
            input.finished = true;
        }
    }

    @Override
    public void get_output(int cycle, Output output) throws Exception {
    }
    
    @Override
    public void avalon_read(int cycle, long read_address) throws Exception {
    }
    
    HashMap<Long, Byte> written_memory;
    
    int counter;
    Random random;
    
    int read_length;
    long read_address;
    
    int finish_cycle;
    
    AvalonListener avalon;
    WriteListener  write;
    ReadListener   read;
    GlobalListener global;
    
    //-------------
    
    public static void main(String args[]) throws Exception {
        TestWriteReadCache test1 = new TestWriteReadCache();
        
        for(int i=0; i<100; i++) {
            test1.go(i*i);

            System.out.println("Run " + i + " complete.");
        }
        
        System.out.println("[Main] thread end.");
    }
}
