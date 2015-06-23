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
import java.nio.file.Files;
import java.util.LinkedList;

public class StringHelper {
    
    static class Port {
        String direction;
        boolean is_reg;
        int size;
        String name;
    }
    
    public static void main(String args[]) throws Exception {
        
        File input_file = new File("convert.txt");
        
        byte input_bytes[] = Files.readAllBytes(input_file.toPath());
        
        String input = new String(input_bytes);
        
        String lines[] = input.split(",");
        
        LinkedList<Port> list = new LinkedList<>();
        
        for(String line : lines) {
            String tokens[] = line.split("\\s+");
            
            Port port = new Port();
            int index = 0;
            
            if(tokens[index].equals("")) index++;
            
            //direction
            if(tokens[index].equals("output"))      port.direction = "output";
            else if(tokens[index].equals("input"))  port.direction = "input";
            else throw new Exception("Unknown direction: " + tokens[index]);
            index++;
            
            //is_reg
            if(tokens[index].equals("reg")) {
                index++;
                port.is_reg = true;
            }
            
            //size
            if(tokens[index].startsWith("[")) {
                int end = tokens[index].indexOf(":");
                port.size = Integer.parseInt(tokens[index].substring(1, end));
                port.size++;
                index++;
            }
            else {
                port.size = 1;
            }
            
            //name
            port.name = tokens[index];
            index++;
            
            if(index != tokens.length) throw new Exception("Parse error: too long.");
            
            list.add(port);
        }
        
        StringBuilder build = new StringBuilder();
        
        int l1 = 30;
        int l2 = 30;
        for(Port port : list) {
            
            build.append("    .").append(port.name);
            for(int i=port.name.length(); i<l1; i++) build.append(" ");
            
            build.append("(").append(port.name).append("),");
            for(int i=port.name.length(); i<l2; i++) build.append(" ");
            
            build.append("//").append(port.direction);
            if(port.size > 1) build.append(" [").append(port.size-1).append(":0]");
            
            build.append("\n");
        }
        System.out.println(build);
        System.out.println("---------------");
        
        
        build = new StringBuilder();
        
        l1 = 12;
        for(Port port : list) {
            StringBuilder local = new StringBuilder();
            
            local.append("wire ");
            if(port.size > 1) local.append("[").append(port.size-1).append(":0]");
            
            for(int i=local.length(); i<l1; i++) local.append(" ");
            
            local.append(port.name).append(";\n");
            build.append(local);
        }
        System.out.println(build);
        System.out.println("---------------");
    }
}
