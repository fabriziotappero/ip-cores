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

public class GeneralRegisterLayer extends Layer {
    public GeneralRegisterLayer(Random random) {
        this.random = random;
        
        eax = random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFFL : 0x00000FFF);
        ebx = random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFFL : 0x00000FFF);
        ecx = random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFFL : 0x00000FFF);
        edx = random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFFL : 0x00000FFF);
        esi = random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFFL : 0x00000FFF);
        edi = random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFFL : 0x00000FFF);
        ebp = random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFFL : 0x00000FFF);
        esp = random.nextInt() & ((random.nextInt(3) == 0)? 0xFFFFFFFFL : 0x00000FFF);
    }
    public long eax() { return eax; }
    public long ebx() { return ebx; }
    public long ecx() { return ecx; }
    public long edx() { return edx; }
    public long esi() { return esi; }
    public long edi() { return edi; }
    public long ebp() { return ebp; }
    public long esp() { return esp; }
    
    long eax, ebx, ecx, edx, esi, edi, ebp, esp;
}
