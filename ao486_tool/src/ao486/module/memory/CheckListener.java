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


public class CheckListener implements Listener {
    
    public interface CheckInterface {
        void checked(int cycle) throws Exception;
        void check_page_fault(int cycle, long cr2, long error_code) throws Exception;
    }

    public void check(int cycle, long address, boolean write, CheckInterface check_interface) throws Exception {
        if(map.containsKey(cycle)) throw new Exception("Double check in cycle: " + cycle);
        
        Input input = new Input();
        input.tlbcheck_address = address;
        input.tlbcheck_rw      = write;
        
        map.put(cycle, input);
        check_map.put(cycle, check_interface);
    }
   
    //------------------------------

    @Override
    public void set_input(int cycle, Input input) throws Exception {
        if(check != null && map.containsKey(cycle)) throw new Exception("Overlapping check detected on cycle " + cycle);
        
        if(check != null) {
            input.tlbcheck_do      = true;
            input.tlbcheck_address = check_input.tlbcheck_address;
            input.tlbcheck_rw      = check_input.tlbcheck_rw;
        }
        
        Input local_input = map.get(cycle);
        if(local_input != null) {
            check = check_map.get(cycle);
            
            input.tlbcheck_do      = true;
            input.tlbcheck_address = local_input.tlbcheck_address;
            input.tlbcheck_rw      = local_input.tlbcheck_rw;
            
            check_input = input;
        }
    }
    

    @Override
    public void get_output(int cycle, Output output) throws Exception {
        
        if(check == null && output.tlbcheck_page_fault == false && (output.tlbcheck_done || output.tlbcheck_page_fault)) throw new Exception("Unexpected check done.");
        
        if(output.tlbcheck_done && output.tlbcheck_page_fault) throw new Exception("Double read result.");
        
        if(check != null && output.tlbcheck_done) {
            check.checked(cycle);
            check = null;
        }
        if(check != null && output.tlbcheck_page_fault) {
            check.check_page_fault(cycle, output.tlb_check_pf_cr2, output.tlb_check_pf_error_code);
            check = null;
        }
    }
    
    /*
    //Input
    public boolean tlbcheck_do                     = false;
    public long    tlbcheck_address                = 0; //32
    public boolean tlbcheck_rw                     = false;
    
    //Output
    public boolean tlbcheck_done;
    public boolean tlbcheck_page_fault;
    */
    
    CheckInterface check;
    Input          check_input;
    
    HashMap<Integer, Input> map                = new HashMap<>();
    HashMap<Integer, CheckInterface> check_map = new HashMap<>();
}
