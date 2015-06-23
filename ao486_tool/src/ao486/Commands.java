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

import java.io.File;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.HashSet;

public class Commands {
    
    static void parse(String name, Parse parse) throws Exception  {
        for(String key : commands.keySet()) {
            String contents = commands.get(key);
            
            String start = "<"  + name + ">";
            String end   = "</" + name + ">";
            
            while(true) {
                int start_index = contents.indexOf(start);
                int end_index   = contents.indexOf(end);
                
                if((start_index != -1 && end_index == -1) || (start_index == -1 && end_index != -1)) throw new Exception("Invalid <" + name + "> section in file: " + key);
                
                if(start_index != -1 && end_index != -1) {
                    String section = contents.substring(start_index+start.length(), end_index);
                    
                    parse.parse(section.trim());
                    
                    contents = contents.replaceFirst("(?s)<" + name + ">.*?</" + name + ">", "");
                    commands.put(key, contents);
                }
                
                if(start_index == -1 && end_index == -1) break;
            }
        }
    }
    
    static void read_command_files(File command_directory) throws Exception {
        if(command_directory.exists() == false || command_directory.isDirectory() == false) throw new Exception("Can not find commands directory: " + command_directory.getCanonicalPath());
        
        commands = new HashMap<>();
        
        //read all files
        for(File file : command_directory.listFiles()) {
            commands.put(file.getName(), new String(Files.readAllBytes(file.toPath())));
        }
        
        //remove all comments and empty lines
        for(String key : commands.keySet()) {
            String contents = commands.get(key);
            
            contents = contents.replaceAll("//[^\\n]*", "");
            contents = contents.replaceAll("\\n\\s*\\n", "\n");
            contents = contents.trim();
            contents = contents.replaceAll("\\n\\s+", " ");
            
            //System.out.println(contents);
            commands.put(key, contents);
        }
        
        //parse defines
        HashSet<Integer> command_values = new HashSet<>();
        command_values.add(0); //can not use zero
        
        defines = new HashMap<>();
        parse("defines", new ParseDefine(defines, command_values));
        
        //parse decode
        decode = new StringBuilder();
        parse("decode", new ParseDecode(decode));
        
        //parse microcode
        microcode = new StringBuilder();
        StringBuilder microcode_loop = new StringBuilder();
        
        
        parse("microcode", new ParseMicrocode(defines, microcode, microcode_loop));
        
        microcode_loop.append("\n");
        
        microcode.append("IF(\n");
        microcode.append(microcode_loop);
        microcode.append(");\n");
        microcode.append("\tSET(mc_cmd_current,   mc_cmd);\n");
        microcode.append("\tSET(mc_cmdex_current, mc_cmdex_last);\n");
        microcode.append("\tSET(mc_cmd_next,      mc_cmd);\n");
        microcode.append("ENDIF();\n\n");
        
        //parse read_local
        read_local = new StringBuilder();
        parse("read_local", new ParseToString(read_local));
        
        //parse read
        read = new StringBuilder();
        parse("read", new ParseToString(read));
        
        //parse execute_local
        execute_local = new StringBuilder();
        parse("execute_local", new ParseToString(execute_local));
        
        //parse execute
        execute = new StringBuilder();
        parse("execute", new ParseToString(execute));
        
        //parse write_local
        write_local = new StringBuilder();
        parse("write_local", new ParseToString(write_local));
        
        //parse write
        write = new StringBuilder();
        parse("write", new ParseToString(write));
        
        //check if all commands are empty
        for(String name : commands.keySet()) {
            String left = commands.get(name);
            left = left.trim();
            
            if(left.equals("") == false) {
                throw new Exception("Unrecognized file part: " + name + "\n" + left);
            }
        }
    }
    
    public static void main(String args[]) throws Exception {
        read_command_files(new File("./../rtl/commands"));
    }
    
    static HashMap<String, String> defines;
    
    static StringBuilder decode;
    
    static StringBuilder microcode;
    
    static StringBuilder read_local;
    static StringBuilder read;
    
    static StringBuilder execute_local;
    static StringBuilder execute;
    
    static StringBuilder write_local;
    static StringBuilder write;
    
    static HashMap<String, String> commands;
}
