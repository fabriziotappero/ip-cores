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

public class WriteListener implements Listener {
    
    public interface WriteInterface {
        void written(int cycle) throws Exception;
        void write_page_fault(int cycle, long cr2, long error_code) throws Exception;
        void write_ac_fault(int cycle) throws Exception;
    }
    
    public void write(int cycle, long cpl, long address, long length, boolean lock, boolean rmw, long data, WriteListener.WriteInterface write_interface) throws Exception {
        if(map.containsKey(cycle)) throw new Exception("Double write in cycle: " + cycle);
        
        Input input = new Input();
        input.write_address = address;
        input.write_cpl     = cpl;
        input.write_length  = length;
        input.write_lock    = lock;
        input.write_rmw     = rmw;
        input.write_data    = data;
        
        map.put(cycle, input);
        write_map.put(cycle, write_interface);
    }
   
    //------------------------------

    
    @Override
    public void set_input(int cycle, Input input) throws Exception {
        if(write != null && map.containsKey(cycle)) throw new Exception("Overlapping write detected on cycle " + cycle);
        
        if(write != null) {
            input.write_do       = true;
            input.write_cpl      = write_input.write_cpl;
            input.write_address  = write_input.write_address;
            input.write_length   = write_input.write_length;
            input.write_lock     = write_input.write_lock;
            input.write_rmw      = write_input.write_rmw;
            input.write_data     = write_input.write_data;
        }
        
        Input local_input = map.get(cycle);
        if(local_input != null) {
            write = write_map.get(cycle);
            
            input.write_do       = true;
            input.write_cpl      = local_input.write_cpl;
            input.write_address  = local_input.write_address;
            input.write_length   = local_input.write_length;
            input.write_lock     = local_input.write_lock;
            input.write_rmw      = local_input.write_rmw;
            input.write_data     = local_input.write_data;
            
            write_input = input;
        }
    }

    @Override
    public void get_output(int cycle, Output output) throws Exception {
        if(write == null && output.write_page_fault == false && (output.write_done || output.write_page_fault || output.write_ac_fault)) {
            throw new Exception("Unexpected write done.");
        }
        
        if(output.write_done       && output.write_page_fault)    throw new Exception("Double write result.");
        if(output.write_done       && output.write_ac_fault)      throw new Exception("Double write result.");
        if(output.write_page_fault && output.write_ac_fault)      throw new Exception("Double write result.");
        
        if(write != null && output.write_done) {
            write.written(cycle);
            write = null;
        }
        if(write != null && output.write_page_fault) {
            write.write_page_fault(cycle, output.tlb_write_pf_cr2, output.tlb_write_pf_error_code);
            write = null;
        }
        if(write != null && output.write_ac_fault) {
            write.write_ac_fault(cycle);
            write = null;
        }
    }
    
    /*
    //Input
    public boolean write_do                        = false;
    public long    write_cpl                       = 0; //2
    public long    write_address                   = 0; //32
    public long    write_length                    = 0; //3
    public boolean write_lock                      = false;
    public boolean write_rmw                       = false;
    public long    write_data                      = 0; //32
    
    //Output
    public boolean write_done;
    public boolean write_page_fault;
    public boolean write_ac_fault;
    */
    
    WriteInterface write;
    Input          write_input;
    
    HashMap<Integer, Input> map                = new HashMap<>();
    HashMap<Integer, WriteInterface> write_map = new HashMap<>();
}
