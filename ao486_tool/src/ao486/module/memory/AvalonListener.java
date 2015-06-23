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

package ao486.module.memory;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Random;

public class AvalonListener implements Listener {
    
    public interface AvalonInterface {
        void avalon_read(int cycle, long read_address) throws Exception;
        void avalon_write(int cycle, long write_address) throws Exception;
    }
    
    public AvalonListener(Random random, AvalonInterface avalon_interface) {
        this.random = random;
        this.avalon_interface = avalon_interface;
        
        memory = new HashMap<>();
        to_read = new LinkedList<>();
    }
    
    public void set_memory(long address, long value, int length) {
        for(int i=0; i<length; i++) {
            memory.put(address, (byte)(value & 0xFF));
//System.out.printf("[%x] = %x\n", address, value & 0xFF);
            address++;
            value >>= 8;
        }
    }
    
    //-----------------------------
    
    public int get_memory(long address) {
        address &= 0xFFFFFFFF;
        
        if(memory.containsKey(address) == false) memory.put(address, (byte)random.nextInt());
            
        byte val = memory.get(address);
        return ((int)val) & 0xFF;
    }
    
    // must be continuous '1'
    boolean check_write_byteenable(long byteenable) {
        byteenable &= 0xF;
        
        boolean started = false;
        for(int i=0; i<4; i++) {
            boolean bit = (byteenable & 1) == 1;
            
            if(bit == false && started && byteenable > 0) return false;
            if(bit) started = true;
            
            byteenable >>= 1;
        }
        return true;
    }
    
    void append_written(long address, long data, long byteenable) {
        byteenable &= 0xF;
        
        for(int i=0; i<4; i++) {
            if((byteenable & 1) == 1) {
                memory.put(address+i,(byte)(data & 0xFF));
            }
            
            byteenable >>= 1;
            data >>= 8;
        }
    }
    
    @Override
    public void set_input(int cycle, Input input) throws Exception {
        
        if(state <= 0) {
            input.avm_waitrequest = random.nextInt(4) == 0;
        }
        
        if(state > 0) {
            int index = state-1;
            
            long value =
                    (((int)to_read.get(0) & 0xFF)     ) |
                    (((int)to_read.get(1) & 0xFF) << 8) |
                    (((int)to_read.get(2) & 0xFF) << 16) |
                    (((int)to_read.get(3) & 0xFF) << 24);
            
            input.avm_readdata      = value;
            input.avm_waitrequest   = scenario[index] >= 2;
            input.avm_readdatavalid = scenario[index] == 1 || scenario[index] == 3;
            
            if(input.avm_readdatavalid) for(int i=0; i<4; i++) to_read.removeFirst();
            
            state++;
        }
        
        was_waitrequest = input.avm_waitrequest;
    }
    
    @Override
    public void get_output(int cycle, Output output) throws Exception {
        
        if(output.avm_read && output.avm_write) throw new Exception("avm_read && avm_write");
        
        if(state == 0 && output.avm_read) {
            address    = output.avm_address;
            byteenable = output.avm_byteenable;
            burstcount = output.avm_burstcount;

            if(byteenable != 0xF) throw new Exception("Invalid read byteenable: " + byteenable);
            if(burstcount == 0)   throw new Exception("Invalid read burstcount: " + burstcount);
            
            state = 1;
            
            to_read.clear();
            for(int i=0; i<burstcount; i++) {
                for(int j=0; j<4; j++) to_read.add((byte)get_memory(address + i*4 + j));
            }
            
            LinkedList<Integer> vec = new LinkedList<>();
            for(int i=0; i<burstcount; ) {

                int val = random.nextInt(4);
                vec.add(val);

                if(val == 1 || val == 3) i++;
            }

            scenario = new int[vec.size()];
            for(int i=0; i<scenario.length; i++) {
                scenario[i] = vec.get(i);
                //System.out.println("--- scenario[" + i + "]: " + scenario[i]);
            }
        }
        else if(state > 0 && state > scenario.length) {
            avalon_interface.avalon_read(cycle, address);
            state = 0;
        }
        else if(state > 0) {
           
            if(address != output.avm_address)       throw new Exception(String.format("Invalid read address: %x != %x, cycle: %d, state: %d", address, output.avm_address, cycle, state));
            if(byteenable != output.avm_byteenable) throw new Exception("Invalid read byteenable: " + byteenable);
            if(burstcount != output.avm_burstcount) throw new Exception("Invalid read burstcount: " + burstcount);

            if(output.avm_write) throw new Exception("Invalid avm_write.");

        }
        else if(state == 0 && output.avm_write) {
            address    = output.avm_address;
            writedata  = output.avm_writedata;
            byteenable = output.avm_byteenable;
            burstcount = output.avm_burstcount;
            
            if(check_write_byteenable(byteenable) == false) throw new Exception("Invalid write byteenable: " + byteenable);
            if(burstcount == 0)                             throw new Exception("Invalid write burstcount: " + burstcount);
            
            state = -1;
            
            if(was_waitrequest == false) {
                append_written(address, writedata, byteenable);
                
                if(state == -burstcount) {
                    avalon_interface.avalon_write(cycle, address);
                    state = 0;
                }
                else {
                    state--;
                }
            }
            was_write_accepted = was_waitrequest == false;
        }
        else if(state < 0) {
            if(address != output.avm_address)       throw new Exception("Invalid write address: " + address);
            if(burstcount != output.avm_burstcount) throw new Exception("Invalid write burstcount: " + burstcount);
            
            if(was_write_accepted) {
                byteenable = output.avm_byteenable;
                writedata  = output.avm_writedata;
            }
            else {
                if(byteenable != output.avm_byteenable) throw new Exception("Invalid write byteenable: " + byteenable + ", output.byteenable: " + output.avm_byteenable + ", cycle: " + cycle);
                if(writedata  != output.avm_writedata)  throw new Exception("Invalid writedata: " + writedata);
            }
            was_write_accepted = was_waitrequest == false;

            if(check_write_byteenable(byteenable) == false) throw new Exception("Invalid write byteenable: " + byteenable);
            
            if(output.avm_write == false) throw new Exception("Invalid avm_write.");
            
            if(was_waitrequest == false) {
                append_written(address - 4*(state+1), writedata, byteenable);
                
                if(state == -burstcount) {
                    avalon_interface.avalon_write(cycle, address);
                    state = 0;
                }
                else {
                    state--;
                }
            }
        }
    }
    
    /*
    //Input
    boolean avm_waitrequest                 = false;
    boolean avm_readdatavalid               = false;
    long    avm_readdata                    = 0; //32
    
    //Output
    long    avm_address; //32
    long    avm_writedata; //32
    long    avm_byteenable; //4
    long    avm_burstcount; //3
    boolean avm_write;
    boolean avm_read;
    */
    
    LinkedList<Byte> to_read;
    boolean was_waitrequest;
    
    boolean was_read_accepted;
    boolean was_write_accepted;
    
    long    address;
    long    writedata;
    long    byteenable;
    long    burstcount;
    
    int state; // 0-idle; 1..- read; -1..- write;
    int scenario[]; //0- idle; 1- readdatavalid; 2- waitrequest; 3- readdatavalid && waitrequest
    
    Random random;
    
    HashMap<Long, Byte> memory;
    
    AvalonInterface avalon_interface;
}
