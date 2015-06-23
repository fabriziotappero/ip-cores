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

public class GlobalListener implements Listener {
    
    public GlobalListener() {
        Input input = new Input();
        set(
            input.cr0_pg, input.cr0_wp, input.cr0_am, input.cr0_cd, input.cr0_nw,
            input.acflag,
            input.cr3_base, input.cr3_pcd, input.cr3_pwt,
            input.pipeline_after_read_empty, input.pipeline_after_prefetch_empty
       );
        
        set_reset(input.pr_reset, input.rd_reset, input.exe_reset, input.wr_reset);
    }
    
    public void set_reset(boolean pr_reset, boolean rd_reset, boolean exe_reset, boolean wr_reset) {
        this.pr_reset = pr_reset;
        this.rd_reset = rd_reset;
        this.exe_reset = exe_reset;
        this.wr_reset = wr_reset;
    }
    
    public void set(
            boolean cr0_pg, boolean cr0_wp, boolean cr0_am, boolean cr0_cd, boolean cr0_nw,
            boolean acflag,
            long cr3_base, boolean cr3_pcd, boolean cr3_pwt,
            boolean pipeline_after_read_empty, boolean pipeline_after_prefetch_empty
            )
    {
        this.cr0_pg = cr0_pg;
        this.cr0_wp = cr0_wp;
        this.cr0_am = cr0_am;
        this.cr0_cd = cr0_cd;
        this.cr0_nw = cr0_nw;
        
        this.acflag = acflag;
        
        this.cr3_base = cr3_base;
        this.cr3_pcd = cr3_pcd;
        this.cr3_pwt = cr3_pwt;
        
        this.pipeline_after_read_empty = pipeline_after_read_empty;
        this.pipeline_after_prefetch_empty = pipeline_after_prefetch_empty;
    }
    
    @Override
    public void set_input(int cycle, Input input) throws Exception {
        input.cr0_pg = cr0_pg;
        input.cr0_wp = cr0_wp;
        input.cr0_am = cr0_am;
        input.cr0_cd = cr0_cd;
        input.cr0_nw = cr0_nw;
        
        input.acflag = acflag;
        
        input.cr3_base = cr3_base;
        input.cr3_pcd = cr3_pcd;
        input.cr3_pwt = cr3_pwt;
        
        input.pipeline_after_read_empty = pipeline_after_read_empty;
        input.pipeline_after_prefetch_empty = pipeline_after_prefetch_empty;
        
        //reset
        
        input.pr_reset = pr_reset;
        input.rd_reset = rd_reset;
        input.exe_reset = exe_reset;
        input.wr_reset = wr_reset;
    }

    @Override
    public void get_output(int cycle, Output output) throws Exception {
    }
    
    boolean cr0_pg;
    public boolean cr0_wp;
    boolean cr0_am;
    boolean cr0_cd;
    public boolean cr0_nw;
    
    boolean acflag;
    
    long cr3_base;
    boolean cr3_pcd;
    boolean cr3_pwt;
    
    boolean pipeline_after_read_empty;
    boolean pipeline_after_prefetch_empty;
    
    //reset
    boolean pr_reset;
    boolean rd_reset;
    boolean exe_reset;
    boolean wr_reset;
}
