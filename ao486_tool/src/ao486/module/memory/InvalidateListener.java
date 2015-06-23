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

import java.util.HashSet;

public class InvalidateListener implements Listener {
    
    public interface InvalidateInterface {
        void invdcode_finished(int cycle) throws Exception;
        void invddata_finished(int cycle) throws Exception;
        void wbinvddata_finished(int cycle) throws Exception;
    }
    
    public void invdcode(int cycle, InvalidateInterface invalidate) throws Exception {
        invdcode.add(cycle);
        this.invalidate = invalidate;
    }
    public void invddata(int cycle, InvalidateInterface invalidate) throws Exception {
        invddata.add(cycle);
        this.invalidate = invalidate;
    }
    public void wbinvddata(int cycle, InvalidateInterface invalidate) throws Exception {
        wbinvddata.add(cycle);
        this.invalidate = invalidate;
    }
    
    //----------------
    
    @Override
    public void set_input(int cycle, Input input) throws Exception {
        if(invdcode.contains(cycle) || invdcode_active) {
            invdcode_active = true;
            input.invdcode_do = true;
        }
        if(invddata.contains(cycle) || invddata_active) {
            invddata_active = true;
            input.invddata_do = true;
        }
        if(wbinvddata.contains(cycle) || wbinvddata_active) {
            wbinvddata_active = true;
            input.wbinvddata_do = true;
        }
    }

    @Override
    public void get_output(int cycle, Output output) throws Exception {
        if(output.invdcode_done) {
            invdcode_active   = false;
            invalidate.invdcode_finished(cycle);
        }
        if(output.invddata_done) {
            invddata_active   = false;
            invalidate.invddata_finished(cycle);
        }
        if(output.wbinvddata_done) {
            wbinvddata_active = false;
            invalidate.wbinvddata_finished(cycle);
        }
    }
    
    HashSet<Integer> invdcode   = new HashSet<>();
    boolean invdcode_active;
    
    HashSet<Integer> invddata   = new HashSet<>();
    boolean invddata_active;
    
    HashSet<Integer> wbinvddata = new HashSet<>();
    public boolean wbinvddata_active;
    
    InvalidateInterface invalidate;
}
