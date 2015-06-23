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

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.LineNumberReader;
import java.util.Vector;

public class CompareTrack {
    public static void main(String args[]) throws Exception {
        
        File file_hw  = new File("./../backup/run-ok-bad/track.txt");
        File file_sim = new File("./../backup/run-ok/track.txt");
        
        Vector<String> vec_hw  = new Vector<>();
        Vector<String> vec_sim = new Vector<>();
        
        LineNumberReader reader_hw = new LineNumberReader(new FileReader(file_hw));
        while(true) {
            String line = reader_hw.readLine();
            if(line == null) break;
            vec_hw.add(line);
        }
        
        LineNumberReader reader_sim = new LineNumberReader(new FileReader(file_sim));
        while(true) {
            String line = reader_sim.readLine();
            if(line == null) break;
            vec_sim.add(line);
        }
        //350000 + 42719;
        int start_hw  =
                100000 +
                100000 +
                100000 +
                100000 +
                100000 +
                10000
                ;
        //100000 + 28598;
        int start_sim = 
                100000 +
                99831 +
                100000 +
                100000 +
                87282
                ;
        
        //some extra block after IAC 0x50 -- setting 001cdd74
        start_hw = 7100947 - 10000 - 5025 - 10000;
        start_sim= 6079195 - 10000        - 10000;
        
        //f8/c8 difference
        //start_hw = 6271527 + 3*10000;
        //start_sim= 5238455 + 3*10000;
        
        //start_hw = 6271527 + 3*10000 + 5*100000;
        //start_sim= 5238455 + 3*10000 + 5*100000;
        
        int count = 10000;
        
        FileOutputStream fos_hw = new FileOutputStream("cmp_hw.txt");
        for(int i=0; i<count; i++) {
            fos_hw.write(new String(vec_hw.get(start_hw+i) + "\n").getBytes());
        }
        fos_hw.close();
        
        FileOutputStream fos_sim = new FileOutputStream("cmp_sim.txt");
        for(int i=0; i<count; i++) {
            fos_sim.write(new String(vec_sim.get(start_sim+i) + "\n").getBytes());
        }
        fos_sim.close();
        
        Runtime.getRuntime().exec(new String[] {"meld", "cmp_hw.txt", "cmp_sim.txt"});
    }
}
