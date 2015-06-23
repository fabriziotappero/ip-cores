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

package ao486;

import java.util.HashMap;
import java.util.HashSet;

public class ParseDefine extends Parse {
    
    ParseDefine(HashMap<String, String> defines, HashSet<Integer> command_values) {
        this.command_values = command_values;
        this.defines = defines;
    }
    
    private HashSet<Integer> command_values;
    private HashMap<String, String> defines;
    
    int find_mod(HashSet<Integer> command_values, int mod) {
        int index = 0;
        
        while(true) {
            boolean free = true;
            for(int i=0; i<mod; i++) if(command_values.contains(index + i)) free = false;
            if(free) break;
            
            index += mod;
        }
        for(int i=0; i<mod; i++) command_values.add(index + i);
        
//System.out.println("index: " + index + ", mod: " + mod);
        
        return index;
    }
    
    @Override
    void parse(String section) throws Exception {

        HashSet<String> accepted_autogen = new HashSet<>();
        accepted_autogen.add("#AUTOGEN_NEXT_CMD");
        accepted_autogen.add("#AUTOGEN_NEXT_CMD_MOD4");
        accepted_autogen.add("#AUTOGEN_NEXT_CMD_LIKE_PREV");
        accepted_autogen.add("#AUTOGEN_NEXT_CMD_MOD2");
        accepted_autogen.add("#AUTOGEN_NEXT_CMD_MOD8");
        
        int prev_index = -1;
        
        String lines[] = section.split("\\n");
        for(String line : lines) {
            String parts[] = line.split("\\s+");
            
            if(parts.length != 3) throw new Exception("Invalid defines line: " + line);
            if(parts[0].equals("`define") == false) throw new Exception("Invalid defines line: " + line);
            if(parts[2].startsWith("#AUTOGEN") && accepted_autogen.contains(parts[2]) == false) throw new Exception("Unknown #AUTOGEN: " + line);
            
            if(parts[2].equals("#AUTOGEN_NEXT_CMD_MOD8")) {
                prev_index = find_mod(command_values, 8);
                parts[2] = "7'd" + prev_index;
            }
            if(parts[2].equals("#AUTOGEN_NEXT_CMD_MOD4")) {
                prev_index = find_mod(command_values, 4);
                parts[2] = "7'd" + prev_index;
            }
            if(parts[2].equals("#AUTOGEN_NEXT_CMD_MOD2")) {
                prev_index = find_mod(command_values, 2);
                parts[2] = "7'd" + prev_index;
            }
            if(parts[2].equals("#AUTOGEN_NEXT_CMD_LIKE_PREV")) {
                if(prev_index == -1) throw new Exception("Invalid #AUTOGEN_NEXT_CMD_LIKE_PREV position: " + line);
                parts[2] = "7'd" + prev_index;
            }
            if(parts[2].equals("#AUTOGEN_NEXT_CMD")) {
                if(prev_index == -1) {
                    prev_index = find_mod(command_values, 1);
                    parts[2] = "7'd" + prev_index;
                    prev_index = -1;
                }
                else {
                    prev_index++;
//System.out.println("index: " + prev_index);
                    command_values.add(prev_index);
                    
                    parts[2] = "7'd" + prev_index;
                }
            }
            
            if(defines.containsKey(parts[1])) throw new Exception("Double definition of: " + line);
            
            defines.put(parts[1], parts[2]);
        }
    }
}
