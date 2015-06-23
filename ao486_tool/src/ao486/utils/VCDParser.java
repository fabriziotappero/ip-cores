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

package ao486.utils;

import java.io.FileReader;
import java.io.LineNumberReader;

public class VCDParser {
    public static void main(String args[]) throws Exception {
        
        LineNumberReader reader = new LineNumberReader(new FileReader("./../sim/verilator/ao486/ao486.vcd"));
        
        boolean last_finished = false;
        int last_val = 0;
        int counter = 0;
        int cnt = 77020000;
        
        while(true) {
            String line = reader.readLine();
            if(line == null) break;
            
            if(line.startsWith("#")) {
                if(last_finished) {
                    counter++;
                    if((counter % 2) == 0) System.out.printf("%d: %02x\n", cnt++, last_val);
                }
            }
            if(line.equals("1FF")) last_finished = true;
            if(line.equals("0FF")) last_finished = false;
            if(line.endsWith(" >K") && line.startsWith("b")) {
                String val_str = line.substring(1, 8);
                last_val = Integer.parseInt(val_str, 2);
            }
        }
        
    }
}
