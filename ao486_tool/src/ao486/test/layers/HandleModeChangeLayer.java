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

package ao486.test.layers;

public class HandleModeChangeLayer extends Layer {
    public HandleModeChangeLayer(long cr0_pe, long vm, long cs_rpl, long cs_p, long cs_s, long cs_type) {
        if(cr0_pe == 1 && vm == 1) {
            this.cs_rpl = 3;
            this.cs_p   = cs_p;
            this.cs_s   = cs_s;
            this.cs_type= cs_type;
        }
        else if(cr0_pe == 0) {
            this.cs_rpl = 0;
            this.cs_p   = 1;
            this.cs_s = 1;
            this.cs_type= 3; // data read write accessed
        }
        else {
            this.cs_rpl = cs_rpl;
            this.cs_p   = cs_p;
            this.cs_s   = cs_s;
            this.cs_type= cs_type;
        }
    }
    
    public long cs_p()   { return cs_p; }
    public long cs_s()   { return cs_s; }
    public long cs_type(){ return cs_type; }
    public long cs_rpl() { return cs_rpl; }
    
    long cs_p, cs_s;
    long cs_type, cs_rpl;
}
