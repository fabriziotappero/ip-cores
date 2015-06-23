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

public class PrefetchListener implements Listener {
    
    public interface PrefetchInterface {
        void prefetched(int cycle, long value, long size) throws Exception;
        void prefetch_page_fault(int cycle, long cr2, long error_code) throws Exception;
        void prefetch_gp_fault(int cycle) throws Exception;
    }
    
    public void prefetch(long cpl, long eip, long cs_base, long cs_limit, PrefetchListener.PrefetchInterface prefetch_interface) throws Exception {
        
        prefetch_input = new Input();
        prefetch_input.cpl      = cpl;
        prefetch_input.eip      = eip;
        prefetch_input.cs_base  = cs_base;
        prefetch_input.cs_limit = cs_limit;
        
        prefetch = prefetch_interface;
    }
   
    //------------------------------

    
    @Override
    public void set_input(int cycle, Input input) throws Exception {
        
        input.cpl       = prefetch_input.cpl;
        input.eip       = prefetch_input.eip;
        input.cs_base   = prefetch_input.cs_base;
        input.cs_limit  = prefetch_input.cs_limit;
        
        input.prefetchfifo_accept_do = true;
    }

    @Override
    public void get_output(int cycle, Output output) throws Exception {
        if(output.prefetchfifo_accept_empty == false) {
            long value = output.prefetchfifo_accept_data.longValue();
            long size = output.prefetchfifo_accept_data.shiftRight(64).longValue() & 0xFL;
            
            if(size == 14) { //page fault
                prefetch.prefetch_page_fault(cycle, output.tlb_code_pf_cr2, output.tlb_code_pf_error_code);
            }
            else if(size == 15) { //gp fault
                prefetch.prefetch_gp_fault(cycle);
            }
            else if(size > 0) {
                prefetch.prefetched(cycle, value, size);
            }
        }
    }
    
    /*
    //Input
    public long    cpl                             = 0; //2
    public long    eip                             = 0; //32
    public long    cs_base                         = 0; //32
    public long    cs_limit                        = 0; //32
    
    public boolean prefetchfifo_accept_do          = false;
    
    //Output
    public BigInteger prefetchfifo_accept_data; //68
    public boolean prefetchfifo_accept_empty;
    
    public long    tlb_code_pf_cr2; //32
    public long    tlb_code_pf_error_code; //16
    */
    
    PrefetchInterface   prefetch;
    Input               prefetch_input;
}
