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

public class Input {
    public boolean finished                        = false;
    
    public boolean rst_n                           = true;
    
    public boolean read_do                         = false;
    public long    read_cpl                        = 0; //2
    public long    read_address                    = 0; //32
    public long    read_length                     = 0; //4
    public boolean read_lock                       = false;
    public boolean read_rmw                        = false;
    
    public boolean write_do                        = false;
    public long    write_cpl                       = 0; //2
    public long    write_address                   = 0; //32
    public long    write_length                    = 0; //3
    public boolean write_lock                      = false;
    public boolean write_rmw                       = false;
    public long    write_data                      = 0; //32
    
    public boolean tlbcheck_do                     = false;
    public long    tlbcheck_address                = 0; //32
    public boolean tlbcheck_rw                     = false;
    
    public boolean tlbflushsingle_do               = false;
    public long    tlbflushsingle_address          = 0; //32
    
    public boolean tlbflushall_do                  = false;
    
    public boolean invdcode_do                     = false;
    public boolean invddata_do                     = false;
    public boolean wbinvddata_do                   = false;
    
    public long    cpl                             = 0; //2
    public long    eip                             = 0; //32
    public long    cs_base                         = 0; //32
    public long    cs_limit                        = 0; //32
    
    public boolean prefetchfifo_accept_do          = false;
    
    public boolean cr0_pg                          = false;
    public boolean cr0_wp                          = false;
    public boolean cr0_am                          = false;
    public boolean cr0_cd                          = true;
    public boolean cr0_nw                          = true;
    
    public boolean acflag                          = false;
    
    public long    cr3_base                        = 0; //32
    public boolean cr3_pcd                         = false;
    public boolean cr3_pwt                         = false;
    
    public boolean pipeline_after_read_empty       = false;
    public boolean pipeline_after_prefetch_empty   = false;
    
    public boolean pr_reset                        = false;
    public boolean rd_reset                        = false;
    public boolean exe_reset                       = false;
    public boolean wr_reset                        = false;
    
    public boolean avm_waitrequest                 = false;
    public boolean avm_readdatavalid               = false;
    public long    avm_readdata                    = 0; //32
}
