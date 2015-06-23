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

public class FlagsLayer extends Layer {
    public FlagsLayer(Random random) {
        this(Type.RANDOM, random);
    }
    public FlagsLayer(FlagsLayer.Type type, Random random) {
        this.random = random;
        
        cf = random.nextBoolean();
        pf = random.nextBoolean();
        af = random.nextBoolean();
        zf = random.nextBoolean();
        sf = random.nextBoolean();
        tf = false; //random.nextBoolean();
        iflag = random.nextBoolean();
        df = random.nextBoolean();
        of = random.nextBoolean();
        iopl = random.nextInt(4);
        nt = (type == Type.NOT_V8086_NT)?       true :
             (type == Type.NOT_V8086_NOT_NT)?   false :
                                                random.nextBoolean();
        rf = false;
        vm = (type == Type.V8086)?                                  true :
             (type == Type.NOT_V8086 || type == Type.NOT_V8086_NT || type == Type.NOT_V8086_NOT_NT)? false :
                                                                    random.nextBoolean();
        ac = random.nextBoolean();
        id = random.nextBoolean();
    }
    public enum Type {
        RANDOM,
        V8086,
        NOT_V8086,
        NOT_V8086_NT,
        NOT_V8086_NOT_NT
    }
    
    public long cflag()  { return cf? 1 : 0; }
    public long pflag()  { return pf? 1 : 0; }
    public long aflag()  { return af? 1 : 0; }
    public long zflag()  { return zf? 1 : 0; }
    public long sflag()  { return sf? 1 : 0; }
    public long tflag()  { return tf? 1 : 0; }
    public long iflag()  { return iflag? 1 : 0; }
    public long dflag()  { return df? 1 : 0; }
    public long oflag()  { return of? 1 : 0; }
    public long iopl()   { return iopl; }
    public long ntflag() { return nt? 1 : 0; }
    public long rflag()  { return rf? 1 : 0; }
    public long vmflag() { return vm? 1 : 0; }
    public long acflag() { return ac? 1 : 0; }
    public long idflag() { return id? 1 : 0; }
    
    boolean cf, pf, af, zf, sf, tf, iflag, df, of, nt, rf, vm, ac, id;
    int iopl;
}
