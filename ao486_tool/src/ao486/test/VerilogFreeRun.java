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

package ao486.test;

import ao486.test.layers.Layer;
import java.io.File;
import java.util.LinkedList;
import java.util.Random;

public class VerilogFreeRun extends TestUnit {
    
    @Override public int get_test_count() throws Exception { throw new UnsupportedOperationException("Not supported yet."); }

    @Override public void init() throws Exception { 
        random = new Random(10);
        
        layers.clear();
        
        final Random random_final = random;
        layers.addFirst(new Layer() {
            Byte get_memory(long address) {
                if(address == 0xFFFFFFF0L) return (byte)0xEA;
                if(address == 0xFFFFFFF1L) return (byte)0x00;
                if(address == 0xFFFFFFF2L) return (byte)0xFF;
                if(address == 0xFFFFFFF3L) return (byte)0x00;
                if(address == 0xFFFFFFF4L) return (byte)0xF0;
                
                /*
                if(address == 0x000FFF00L) return (byte)0x66;
                if(address == 0x000FFF01L) return (byte)0xB8;
                if(address == 0x000FFF02L) return (byte)0x00;
                if(address == 0x000FFF03L) return (byte)0x00;
                if(address == 0x000FFF04L) return (byte)0x00;
                if(address == 0x000FFF05L) return (byte)0x00;
                if(address == 0x000FFF06L) return (byte)0x66;
                if(address == 0x000FFF07L) return (byte)0xE7;
                if(address == 0x000FFF08L) return (byte)0x04;
                if(address == 0x000FFF09L) return (byte)0x66;
                if(address == 0x000FFF0AL) return (byte)0xB8;
                if(address == 0x000FFF0BL) return (byte)0x61;
                if(address == 0x000FFF0CL) return (byte)0x00;
                if(address == 0x000FFF0DL) return (byte)0x00;
                if(address == 0x000FFF0EL) return (byte)0x00;
                if(address == 0x000FFF0FL) return (byte)0x66;
                if(address == 0x000FFF10L) return (byte)0xE7;
                if(address == 0x000FFF11L) return (byte)0x00;
                if(address == 0x000FFF12L) return (byte)0xEB;
                if(address == 0x000FFF13L) return (byte)0xFE;
                */
                
                /*
                if(address == 0x000FFF00L) return (byte)0x89;
                if(address == 0x000FFF01L) return (byte)0x87;
                if(address == 0x000FFF02L) return (byte)0x58;
                if(address == 0x000FFF03L) return (byte)0x01;
                if(address == 0x000FFF04L) return (byte)0x89;
                if(address == 0x000FFF05L) return (byte)0xB7;
                if(address == 0x000FFF06L) return (byte)0x5A;
                if(address == 0x000FFF07L) return (byte)0x01;
                if(address == 0x000FFF08L) return (byte)0x8A;
                if(address == 0x000FFF09L) return (byte)0x46;
                if(address == 0x000FFF0AL) return (byte)0xFD;
                if(address == 0x000FFF0BL) return (byte)0x30;
                if(address == 0x000FFF0CL) return (byte)0xE4;
                if(address == 0x000FFF0DL) return (byte)0xB9;
                if(address == 0x000FFF0EL) return (byte)0x1E;
                if(address == 0x000FFF0FL) return (byte)0x00;
                */
                
                
                if(address == 0x000FFF00L) return (byte)0xEA;
                if(address == 0x000FFF01L) return (byte)0x00;
                if(address == 0x000FFF02L) return (byte)0x00;
                if(address == 0x000FFF03L) return (byte)0x70;
                if(address == 0x000FFF04L) return (byte)0x00;
                
                
                if(address == 0x00000700L) return (byte)0x2E;
                if(address == 0x00000701L) return (byte)0x89;
                if(address == 0x00000702L) return (byte)0x1E;
                if(address == 0x00000703L) return (byte)0x23;
                if(address == 0x00000704L) return (byte)0x01;
                if(address == 0x00000705L) return (byte)0x2E;
                if(address == 0x00000706L) return (byte)0x88;
                if(address == 0x00000707L) return (byte)0x2E;
                if(address == 0x00000708L) return (byte)0x2F;
                if(address == 0x00000709L) return (byte)0x01;
                if(address == 0x0000070AL) return (byte)0x2E;
                if(address == 0x0000070BL) return (byte)0x88;
                if(address == 0x0000070CL) return (byte)0x16;
                if(address == 0x0000070DL) return (byte)0x2D;
                if(address == 0x0000070EL) return (byte)0x01;
                if(address == 0x0000070FL) return (byte)0x00;
                
                return (byte)(random_final.nextInt() & 0xFFL);
            }
        });
    }
    
    public static void main(String args[]) throws Exception {
        
        Class test_class = VerilogFreeRun.class;
        
        File output_directory = new File(".");
        File directory;
        LinkedList<String> command_line = new LinkedList<>();
        
        Runner runner = new Runner();
        
        //run verilog
        TestUnit test_verilog = (TestUnit)test_class.newInstance();

        test_verilog.init();

        directory = new File("./../sim/ao486_run");
        command_line.clear();
        command_line.add("/opt/iverilog/bin/vvp");
        command_line.add("tb_ao486_run.vvp");
        //command_line.add("-lxt");

        runner.execute(command_line, directory, test_verilog);
    }
}
