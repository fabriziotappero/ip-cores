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

import java.math.BigInteger;

public class Output {
    public boolean read_done;
    public boolean read_page_fault;
    public boolean read_ac_fault;
    public long    read_data; //64
    
    public boolean write_done;
    public boolean write_page_fault;
    public boolean write_ac_fault;
    
    public boolean tlbcheck_done;
    public boolean tlbcheck_page_fault;
    
    public boolean tlbflushsingle_done;
    
    public boolean invdcode_done;
    public boolean invddata_done;
    public boolean wbinvddata_done;
    
    public BigInteger prefetchfifo_accept_data; //68
    public boolean prefetchfifo_accept_empty;
    
    public long    tlb_code_pf_cr2; //32
    public long    tlb_code_pf_error_code; //16
    
    public long    tlb_check_pf_cr2; //32
    public long    tlb_check_pf_error_code; //16
    
    public long    tlb_write_pf_cr2; //32
    public long    tlb_write_pf_error_code; //16
    
    public long    tlb_read_pf_cr2; //32
    public long    tlb_read_pf_error_code; //16
    
    public long    avm_address; //32
    public long    avm_writedata; //32
    public long    avm_byteenable; //4
    public long    avm_burstcount; //3
    public boolean avm_write;
    public boolean avm_read;
}
