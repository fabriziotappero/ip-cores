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
import java.util.LinkedList;

public class ParseMicrocode extends Parse {
    
    ParseMicrocode(HashMap<String, String> defines, StringBuilder build, StringBuilder build_loop) {
        this.build      = build;
        this.build_loop = build_loop;
        this.defines    = defines;
    }
    
    private StringBuilder build;
    private StringBuilder build_loop;
    private HashMap<String, String> defines;
    
    static class MicrocodeStep {
        String type;
        String cmdex;
        String cmd;
    }
    
    String parse_cmdex(String cmdex) throws Exception {
        if(cmdex.startsWith("CMDEX_") == false) throw new Exception("Invalid cmdex: " + cmdex);
        cmdex = cmdex.substring(6);
        
        //find names (prefixes) to check
        LinkedList<String> names = new LinkedList<>();
        int index = cmdex.length();
        names.add(cmdex.substring(0, index));
        
        while(true) {
            index = cmdex.lastIndexOf("_", index);
            if(index != -1) {
                names.add(cmdex.substring(0, index));
                index--;
            }
            else break;
        }
        
        String cmd = null;
        for(String name : names) {
            
            if(defines.containsKey("CMD_" + name)) {
                cmd = "CMD_" + name;
                break;
            }
        }
        if(cmd == null) throw new Exception("CMD for CMDEX not found: CMDEX_" + cmdex);
        
        return "`" + cmd;
    }
    
    @Override
    void parse(String section) throws Exception {
        section = section.replaceAll("\\n", " ");
        section = section.trim();
        
        LinkedList<MicrocodeStep> list = new LinkedList<>();
        
        while(section.length() > 0) {
            
            if(section.startsWith("`")) {
                int index = section.indexOf(" ");
                if(index == -1) throw new Exception("Invalid `<token>.");
                
                String cmdex = section.substring(0, index);
                String cmd = parse_cmdex(cmdex.substring(1));
                
                MicrocodeStep step = new MicrocodeStep();
                step.cmd    = cmd;
                step.type   = "`";
                step.cmdex  = cmdex;
                
                list.add(step);
                
                section = section.substring(index+1);
            }
            else if(section.startsWith("IF(")) {
                int index = section.indexOf(");");
                if(index == -1) throw new Exception("Invalid IF(<token>);");
                
                if(section.startsWith("IF(`CMDEX_")) {
                    int idx1 = section.indexOf(" ");
                    int idx2 = section.indexOf(")");
                    int idx = (idx1 < idx2)? idx1 : idx2;
                    if(idx1 == -1 || idx2 == -1) throw new Exception("Invalid IF(`<token>);");
                    
                    String cmdex = section.substring(3, idx);
                    String cmd   = parse_cmdex(cmdex.substring(1));
                    
                    MicrocodeStep step = new MicrocodeStep();
                    step.cmd   = cmd;
                    step.type  = "IF";
                    step.cmdex = "mc_cmdex_last == " + section.substring(3, index);

                    list.add(step);
                }
                else {
                    MicrocodeStep step = new MicrocodeStep();
                    step.cmd   = null;
                    step.type  = "IF";
                    step.cmdex = section.substring(3, index);
                    
                    list.add(step);
                }
                
                section = section.substring(index+2);
            }
            else if(section.startsWith("LOOP(")) {
                int index = section.indexOf(");");
                if(index == -1) throw new Exception("Invalid LOOP(<token>);");
                
                String cmdex = section.substring(5, index);
                String cmd   = parse_cmdex(cmdex.substring(1));

                MicrocodeStep step = new MicrocodeStep();
                step.cmd   = cmd;
                step.type  = "LOOP";
                step.cmdex = cmdex;

                list.add(step);
                
                section = section.substring(index+2);
            }
            else if(section.startsWith("CALL(")) {
                int index = section.indexOf(");");
                if(index == -1) throw new Exception("Invalid CALL(<token>);");
                
                String cmdex = section.substring(5, index);
                String cmd   = parse_cmdex(cmdex.substring(1));

                MicrocodeStep step = new MicrocodeStep();
                step.cmd   = cmd;
                step.type  = "CALL";
                step.cmdex = cmdex;

                list.add(step);
                
                section = section.substring(index+2);
            }
            else if(section.startsWith("JMP(")) {
                int index = section.indexOf(");");
                if(index == -1) throw new Exception("Invalid JMP(<token>);");
                
                String cmdex = section.substring(4, index);
                String cmd   = parse_cmdex(cmdex.substring(1));

                MicrocodeStep step = new MicrocodeStep();
                step.cmd   = cmd;
                step.type  = "JMP";
                step.cmdex = cmdex;

                list.add(step);
                
                section = section.substring(index+2);
            }
            else if(section.startsWith("LAST(")) {
                int index = section.indexOf(");");
                if(index == -1) throw new Exception("Invalid LAST(<token>);");
                
                String cmdex = section.substring(5, index);
                String cmd   = parse_cmdex(cmdex.substring(1));

                MicrocodeStep step = new MicrocodeStep();
                step.cmd   = cmd;
                step.type  = "LAST";
                step.cmdex = cmdex;

                list.add(step);
                
                section = section.substring(index+2);
            }
            else if(section.startsWith("LAST_DIRECT(")) {
                int index = section.indexOf(",");
                if(index == -1) throw new Exception("Invalid LAST_DIRECT(<token>);");
                
                int end_index = section.indexOf(");");
                if(end_index == -1) throw new Exception("Invalid LAST_DIRECT(<token>);");
                
                MicrocodeStep step = new MicrocodeStep();
                step.cmd   = section.substring(12, index);
                step.type  = "LAST_DIRECT";
                step.cmdex = section.substring(index+1, end_index);

                list.add(step);
                
                section = section.substring(end_index+2);
            }
            else if(section.startsWith("DIRECT(")) {
                int index = section.indexOf(",");
                if(index == -1) throw new Exception("Invalid DIRECT(<token>);");
                
                int end_index = section.indexOf(");");
                if(end_index == -1) throw new Exception("Invalid DIRECT(<token>);");
                
                MicrocodeStep step = new MicrocodeStep();
                step.cmd   = section.substring(7, index);
                step.type  = "DIRECT";
                step.cmdex = section.substring(index+1, end_index);

                list.add(step);
                
                section = section.substring(end_index+2);
            }
            else if(section.startsWith("RETURN();")) {
                
                MicrocodeStep step = new MicrocodeStep();
                step.cmd   = null;
                step.type  = "RETURN";
                step.cmdex = null;

                list.add(step);
                
                section = section.substring(9);
            }
            else if(section.startsWith("ENDIF();")) {
                section = section.substring(8);
            }
            else throw new Exception("Unknown token: " + section.substring(0, (section.length()>100)? 100 : section.length()));
            
            section = section.trim();
        }
        
        //generate code for loops
        HashSet<String> loop_set = new HashSet<>();

        for(MicrocodeStep step : list) {
            if(step.type.equals("LOOP")) {
                if(loop_set.contains(step.cmd + step.cmdex) == false) {
                    if(build_loop.length() > 0) build_loop.append(" ||\n");
                    
                    build_loop.append("(mc_cmd == " + step.cmd + " && mc_cmdex_last == " + step.cmdex + ")");
                    loop_set.add(step.cmd + step.cmdex);
                }
            }
        }
        
        //generate
        for(int i=1; i<list.size(); i++) {
            MicrocodeStep step1 = list.get(i-1);
            MicrocodeStep step2 = list.get(i);
            
            if(step1.type.equals("DIRECT")      && step2.type.equals("IF") == false) throw new Exception("DIRECT -> not IF");
            if(step1.type.equals("RETURN")      && step2.type.equals("IF") == false) throw new Exception("RETURN -> not IF");
            if(step1.type.equals("LAST_DIRECT") && step2.type.equals("IF") == false) throw new Exception("LAST_DIRECT -> not IF");
            if(step1.type.equals("LAST")        && step2.type.equals("IF") == false) throw new Exception("LAST -> not IF");
            if(step1.type.equals("JMP")         && step2.type.equals("IF") == false) throw new Exception("JMP -> not IF");
            if(step1.type.equals("LOOP")        && step2.type.equals("IF") == false) throw new Exception("LOOP -> not IF");
            
            if(step2.type.equals("IF")) continue;
            
            if(step1.type.equals("CALL")) continue;
            
            //prepare condition
            if(step1.type.equals("IF") && step1.cmd == null) {
                build.append("IF(" + step1.cmdex + ");\n");
            }
            else if(step1.type.equals("IF") && step1.cmd != null) {
                build.append("IF(mc_cmd == " + step1.cmd + " && " + step1.cmdex + ");\n");
            }
            else if(step1.type.equals("`")) {
                build.append("IF(mc_cmd == " + step1.cmd + " && mc_cmdex_last == " + step1.cmdex + ");\n");
            }
            else throw new Exception("Unexpected condition in step1");
            
            //prepare contents
            if(step2.type.equals("DIRECT")) {
                build.append("\tSET(mc_cmd_current,   " + step2.cmd   + ");\n");
                build.append("\tSET(mc_cmdex_current, " + step2.cmdex + ");\n");
                build.append("\tSET(mc_cmd_next,      " + step2.cmd   + "); //DIRECT\n");
            }
            else if(step2.type.equals("RETURN")) {
                build.append("\tSET(mc_cmd_current,   mc_saved_command);\n");
                build.append("\tSET(mc_cmdex_current, mc_saved_cmdex);\n");
                build.append("\tSET(mc_cmd_next,      mc_saved_command); //RETURN\n");
            }
            else if(step2.type.equals("LAST_DIRECT")) {
                build.append("\tSET(mc_cmd_current,   " + step2.cmd   + ");\n");
                build.append("\tSET(mc_cmdex_current, " + step2.cmdex + "); //LAST_DIRECT\n");
            }
            else if(step2.type.equals("LAST")) {
                build.append("\tSET(mc_cmd_current,   " + step2.cmd   + ");\n");
                build.append("\tSET(mc_cmdex_current, " + step2.cmdex + "); //LAST\n");
            }
            else if(step2.type.equals("JMP")) {
                build.append("\tSET(mc_cmd_current,   " + step2.cmd   + ");\n");
                build.append("\tSET(mc_cmdex_current, " + step2.cmdex + ");\n");
                build.append("\tSET(mc_cmd_next,      " + step2.cmd   + "); //JMP\n");
            }
            else if(step2.type.equals("CALL")) {
                build.append("\tSET(mc_cmd_current,   " + step2.cmd   + ");\n");
                build.append("\tSET(mc_cmdex_current, " + step2.cmdex + ");\n");
                build.append("\tSET(mc_cmd_next,      " + step2.cmd   + ");\n");
            
                MicrocodeStep step3 = list.get(i+1);
                if(step3.type.equals("DIRECT")) {
                    build.append("\tSAVE(mc_saved_command, " + step3.cmd   + ");\n");
                    build.append("\tSAVE(mc_saved_cmdex,   " + step3.cmdex + "); //CALL/DIRECT\n");
                }
                else if(step3.type.equals("LOOP")) {
                    build.append("\tSAVE(mc_saved_command, " + step3.cmd   + ");\n");
                    build.append("\tSAVE(mc_saved_cmdex,   " + step3.cmdex + "); //CALL/LOOP\n");
                }
                else if(step3.type.equals("`")) {
                    build.append("\tSAVE(mc_saved_command, " + step3.cmd   + ");\n");
                    build.append("\tSAVE(mc_saved_cmdex,   " + step3.cmdex + "); //CALL/`\n");
                }
                else throw new Exception("Unexpected step after CALL: " + step3.type);
            }
            else if(step2.type.equals("LOOP")) {
                build.append("\tSET(mc_cmd_current,   " + step2.cmd   + ");\n");
                build.append("\tSET(mc_cmdex_current, " + step2.cmdex + ");\n");
                build.append("\tSET(mc_cmd_next,      " + step2.cmd   + "); //LOOP\n");
            }
            else if(step2.type.equals("`")) {
                build.append("\tSET(mc_cmd_current,   " + step2.cmd   + ");\n");
                build.append("\tSET(mc_cmdex_current, " + step2.cmdex + ");\n");
                build.append("\tSET(mc_cmd_next,      " + step2.cmd   + "); //`\n");
            }
            else throw new Exception("Unexpected step2: " + step2.type);
            
            build.append("ENDIF();\n\n");
        }
    }
}
