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


public class ReadListener implements Listener {
    
    public interface ReadInterface {
        void read(int cycle, long data) throws Exception;
        void read_page_fault(int cycle, long cr2, long error_code) throws Exception;
        void read_ac_fault(int cycle) throws Exception;
    }
    
    
    public void read(int cycle, long cpl, long address, long length, boolean lock, boolean rmw, ReadInterface read_interface) throws Exception {
        if(map.containsKey(cycle)) throw new Exception("Double read in cycle: " + cycle);
        
        Input input = new Input();
        input.read_address = address;
        input.read_cpl     = cpl;
        input.read_length  = length;
        input.read_lock    = lock;
        input.read_rmw     = rmw;
        
        map.put(cycle, input);
        read_map.put(cycle, read_interface);
    }
   
    //------------------------------

    @Override
    public void set_input(int cycle, Input input) throws Exception {
        if(read != null && map.containsKey(cycle)) throw new Exception("Overlapping read detected on cycle " + cycle);
        
        if(read != null) {
            input.read_do       = true;
            input.read_cpl      = read_input.read_cpl;
            input.read_address  = read_input.read_address;
            input.read_length   = read_input.read_length;
            input.read_lock     = read_input.read_lock;
            input.read_rmw      = read_input.read_rmw;
        }
        
        Input local_input = map.get(cycle);
        if(local_input != null) {
            read = read_map.get(cycle);
            
            input.read_do       = true;
            input.read_cpl      = local_input.read_cpl;
            input.read_address  = local_input.read_address;
            input.read_length   = local_input.read_length;
            input.read_lock     = local_input.read_lock;
            input.read_rmw      = local_input.read_rmw;
            
            read_input = input;
        }
    }
    

    @Override
    public void get_output(int cycle, Output output) throws Exception {
        
        if(read == null && output.read_page_fault == false && (output.read_done || output.read_page_fault || output.read_ac_fault)) throw new Exception("Unexpected read done.");
        
        if(output.read_done       && output.read_page_fault)    throw new Exception("Double read result.");
        if(output.read_done       && output.read_ac_fault)      throw new Exception("Double read result.");
        if(output.read_page_fault && output.read_ac_fault)      throw new Exception("Double read result.");
        
        if(read != null && output.read_done) {
            read.read(cycle, output.read_data);
            read = null;
        }
        if(read != null && output.read_page_fault) {
            read.read_page_fault(cycle, output.tlb_read_pf_cr2, output.tlb_read_pf_error_code);
            read = null;
        }
        if(read != null && output.read_ac_fault) {
            read.read_ac_fault(cycle);
            read = null;
        }
    }
    
    /*
    //Input
    boolean read_do                         = false;
    long    read_cpl                        = 0; //2
    long    read_address                    = 0; //32
    long    read_length                     = 0; //4
    boolean read_lock                       = false;
    boolean read_rmw                        = false;
    
    //Output
    boolean read_done;
    boolean read_page_fault;
    boolean read_ac_fault;
    long    read_data; //64
    */
    
    ReadInterface read;
    Input         read_input;
    
    HashMap<Integer, Input> map              = new HashMap<>();
    HashMap<Integer, ReadInterface> read_map = new HashMap<>();
}
