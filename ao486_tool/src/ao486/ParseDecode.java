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

public class ParseDecode extends Parse {
    
    ParseDecode(StringBuilder build) {
        this.build = build;
    }
    
    private StringBuilder build;
    
    @Override
    void parse(String section) throws Exception {
        
        HashMap<String, String> map = new HashMap<>();
        map.put("#command",    "");
        map.put("#cmdex",      "");
        map.put("#is_8bit",    "");
        map.put("#consume",    "");
        map.put("#is_complex", "");
        map.put("#opcode",     "");
        map.put("#ud_extra",   "");
            
        String lines[] = section.split("\\n");
        for(String line : lines) {
            
            boolean dec_cmd         = false;
            boolean dec_cmdex       = false;
            boolean dec_is_8bit     = false;
            boolean consume         = false;
            boolean dec_is_complex  = false;
            boolean dec_ready       = false;
            boolean prefix_group    = false;
            
            if(line.indexOf("`CMD_") != -1)                 dec_cmd = true;
            if(line.indexOf("SET(dec_cmdex") != -1)        dec_cmdex = true;
            if(line.indexOf("SET(dec_is_8bit") != -1)       dec_is_8bit = true;
            if(line.indexOf("SET(consume_") != -1)          consume = true;
            if(line.indexOf("SET(dec_is_complex") != -1)    dec_is_complex = true;
            if(line.indexOf("dec_ready_") != -1)            dec_ready = true;
            if(line.indexOf("prefix_group_1_lock") != -1)   prefix_group = true;
            
            if(dec_cmd) {
                if(dec_cmdex || dec_is_8bit || consume || dec_is_complex || dec_ready || prefix_group) throw new Exception("Can not distinguish: dec_cmd: " + line);
                
                map.put("#command", line);
            }
            if(dec_cmdex) {
                if(dec_cmd || dec_is_8bit || consume || dec_is_complex || dec_ready || prefix_group) throw new Exception("Can not distinguish: dec_cmdex: " + line);
                
                map.put("#cmdex", line);
            }
            if(dec_is_8bit) {
                if(dec_cmd || dec_cmdex || consume || dec_is_complex || dec_ready || prefix_group) throw new Exception("Can not distinguish: is_8bit: " + line);
                
                map.put("#is_8bit", line);
            }
            if(consume) {
                if(dec_cmd || dec_cmdex || dec_is_8bit || dec_is_complex || dec_ready || prefix_group) throw new Exception("Can not distinguish: consume: " + line);
                
                map.put("#consume", line);
            }
            if(dec_is_complex) {
                if(dec_cmd || dec_cmdex || dec_is_8bit || consume || dec_ready || prefix_group) throw new Exception("Can not distinguish: dec_is_complex: " + line);
                
                map.put("#is_complex", line);
            }
            if(dec_ready) {
                if(dec_cmd || dec_cmdex || dec_is_8bit || consume || dec_is_complex || prefix_group) throw new Exception("Can not distinguish: dec_ready: " + line);
                
                map.put("#opcode", line);
            }
            if(prefix_group) {
                if(dec_cmd || dec_cmdex || dec_is_8bit || consume || dec_is_complex || dec_ready) throw new Exception("Can not distinguish: prefix_group: " + line);
                
                String prefix = "prefix_group_1_lock";
                if(line.startsWith(prefix) == false) throw new Exception("Invalid prefix_group_1_lock: " + line);
                line = line.substring(prefix.length());
                
                map.put("#ud_extra", line);
            }
        }
        
        String decode_macro = 
            "IF(#opcode);" + "\n" + 
                "IF(prefix_group_1_lock #ud_extra); SET(exception_ud);" + "\n" +
                "ELSE();" + "\n" +
                    "#is_complex" + "\n" +
                    "#is_8bit" + "\n" +
                    "SET(dec_cmd, #command);" + "\n" +
                    "#cmdex" + "\n" +
                    "#consume" + "\n" +
                "ENDIF();" + "\n" +
            "ENDIF();" + "\n\n\n";
        
        String expanded_macro = decode_macro;
        for(String key : map.keySet()) {
            //System.out.println(key + "->" + map.get(key));
            expanded_macro = expanded_macro.replaceAll(key, map.get(key));
        }
        build.append(expanded_macro);
    }
}
