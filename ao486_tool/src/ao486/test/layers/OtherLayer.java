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

import java.util.Random;

public class OtherLayer extends Layer {
    public OtherLayer(Random random) {
        this(Type.RANDOM, random);
    }
    public OtherLayer(Type type, Random random) {
        this.random = random;
        
        cr0_pe = (type == Type.REAL)?               false :
                 (type == Type.PROTECTED_OR_V8086)? true :
                                                    random.nextBoolean(); 
        cr0_mp = false;
        cr0_em = false;
        cr0_ts = false;
        cr0_ne = false;
        cr0_wp = false;
        cr0_am = false;
        cr0_nw = true;
        cr0_cd = true;
        cr0_pg = false;
        
        cr2 = 0;
        cr3 = 0;
        
        cs_d_b = random.nextBoolean();
    }
    public enum Type {
        RANDOM,
        REAL,
        PROTECTED_OR_V8086
    }
    
    public long get_test_type() { return 0; }
    
    public long ldtr_limit()    { return 0xFFFF; }
    public long ldtr_s()        { return 0; }
    public long ldtr_type()     { return 2; } //LDT
    
    public long tr_limit()      { return 0xFFFF; }
    public long tr_s()          { return 0; }
    public long tr_type()       { return 0xB; } //BUSY 386 TSS
    
    public long gdtr_base()     { return 0; }
    public long gdtr_limit()    { return 0xFFFF; }
    
    public long idtr_base()     { return 0; }
    public long idtr_limit()    { return 0xFFFF; }
    
    public long cr0_pe()        { return cr0_pe? 1 : 0; }
    public long cr0_mp()        { return cr0_mp? 1 : 0; }
    public long cr0_em()        { return cr0_em? 1 : 0; }
    public long cr0_ts()        { return cr0_ts? 1 : 0; }
    public long cr0_ne()        { return cr0_ne? 1 : 0; }
    public long cr0_wp()        { return cr0_wp? 1 : 0; }
    public long cr0_am()        { return cr0_am? 1 : 0; }
    public long cr0_nw()        { return cr0_nw? 1 : 0; }
    public long cr0_cd()        { return cr0_cd? 1 : 0; }
    public long cr0_pg()        { return cr0_pg? 1 : 0; }
    
    public long cs_d_b()        { return cs_d_b? 1 : 0; }
    
    public long cr2()           { return cr2; }
    public long cr3()           { return cr3; }
    
    public long dr0()           { return 0; }
    public long dr1()           { return 0; }
    public long dr2()           { return 0; }
    public long dr3()           { return 0; }
    
    public long dr6()           { return 0; }
    public long dr7()           { return 0; }
    
    boolean cr0_pe, cr0_mp, cr0_em, cr0_ts, cr0_ne, cr0_wp, cr0_am, cr0_nw, cr0_cd, cr0_pg;
    boolean cs_d_b;
    
    int cr2, cr3;
}
