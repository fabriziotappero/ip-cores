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
import java.io.FileOutputStream;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Stack;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

class Condition {
    Condition(int index, boolean negation, int level) {
        this.negation = negation;
        this.index = index;
        this.level = level;
    }
    Condition() {
    }
    @Override
    public Object clone() {
        Condition c = new Condition(index, negation, level);
        return c;
    }
    boolean negation;
    int     index;
    int     level;
}
    
class ConditionPoint {
    ConditionPoint(String name, Stack<Condition> stack, String value) throws Exception {
        this.name = name;
        this.value= value;

        conditions_stack = new Stack<>();
        for(int i=0; i<stack.size(); i++) {
            conditions_stack.push((Condition)stack.elementAt(i).clone());
        }
    }
    String           name;
    String           value;
    Stack<Condition> conditions_stack;
}

class Model {
    void IF(String condition) {
       
        int level = 0;
        if(conditions_stack.empty() == false) {
            level = conditions_stack.peek().level + 1;
        }
        
        // find previous
        for(int i=0; i<conditions.size(); i++) {
            String str = conditions.get(i);
            
            if(str.equals(condition)) {
                conditions_stack.push(new Condition(i, false, level));
                return;
            }
        }
        int index = conditions.size();
        conditions_stack.push(new Condition(index, false, level));
        conditions.add(condition);
    }
    void ELSE() {
        conditions_stack.peek().negation = true;
    }
    void ELSE_IF(String condition) {
        conditions_stack.peek().negation = true;
        
        int level = conditions_stack.peek().level;
        
        // find previous
        for(int i=0; i<conditions.size(); i++) {
            String str = conditions.get(i);
            
            if(str.equals(condition)) {
                conditions_stack.push(new Condition(i, false, level));
                return;
            }
        }
        int index = conditions.size();
        conditions_stack.push(new Condition(index, false, level));
        conditions.add(condition);
    }
    void ENDIF() {
        int level = conditions_stack.peek().level;
        
        while(conditions_stack.empty() == false && conditions_stack.peek().level == level) conditions_stack.pop();
    }
    void SET(String wire) throws Exception {
        SET(wire, "`TRUE");
    }
    void SAVE(String register, String value) throws Exception {
        saves.add(new ConditionPoint(register, conditions_stack, value));
    }
    void SET(String wire, String value) throws Exception {
        sets.add(new ConditionPoint(wire, conditions_stack, value));
    }
    
    void NO_ALWAYS_BLOCK(String register) throws Exception {
        no_always_block.add(register);
        
        //add register if signal also in wires
        if(wires.containsKey(register + "_to_reg")) {
            int size_w = wires.get(register + "_to_reg");
            
            if(registers.containsKey(register)) {
                int size_r = registers.get(register);
                if(size_w != size_r) throw new Exception("");
            }
            else {
                registers.put(register, size_w);
            }
        }
    }
    
    String convert_expression(String expression) {
        return expression;
    }
    
    String template(String string, Object... args) {
        for(int i=0; i<args.length; i++) {
            string = string.replaceAll("#" + (i+1), args[i].toString());
        }
        return string;
    }
    
    String generate() throws Exception {
        StringBuilder build = new StringBuilder();
        
        build.append("//======================================================== conditions\n");
        for(int i=0; i<conditions.size(); i++) {
            String condition = conditions.get(i);
            
            condition = convert_expression(condition);
            
            build.append(template("wire cond_#1 = #2;\n", i, condition));
        }
        
        build.append("//======================================================== saves\n");
        HashMap<String, StringBuilder> to_regs_map = new HashMap<>();
        
        for(ConditionPoint point : saves) {
            
            String condition = "";
            for(Condition cond : point.conditions_stack) {
                if(condition.length() > 0) condition += " && ";
                condition += ((cond.negation)? "~" : "") + ("cond_" + cond.index);
            }
            
            if(condition.length() == 0) throw new Exception("Invalid SAVE(): no condition.");
            
            String name  = convert_expression(point.name);
            String value = convert_expression(point.value);
            
            StringBuilder builder = to_regs_map.get(name);
            if(builder == null) {
                builder = new StringBuilder();
                to_regs_map.put(name, builder);
            }
            
            builder.append(template("    (#1)? (#2) :\n", condition,value));
        }
        
        for(String name : to_regs_map.keySet()) {
            
            if(registers.containsKey(name) == false) throw new Exception("Save to unknown register: " + name);
            int size = registers.get(name);
            
            String header = "wire #1";
            if(wires.containsKey(name + "_to_reg")) header = "assign";
            
            build.append(template(header + " #2_to_reg =\n", (size > 1)? "[" + (size-1) + ":0]" : "", name));
            build.append(to_regs_map.get(name));
            build.append(template("    #1;\n", name));
            
        }
        
        build.append("//======================================================== always\n");
        
        for(String name : to_regs_map.keySet()) {
            
            if(registers.containsKey(name) == false) throw new Exception("Save to unknown register: " + name);
            int size = registers.get(name);
            
            if(no_always_block.contains(name)) continue;
            
            build.append(template("always @(posedge clk or negedge rst_n) begin\n"));
            build.append(template("    if(rst_n == 1'b0) #1 <= #2'd0;\n", name, "" + size));
            build.append(template("    else              #1 <= #1_to_reg;\n", name));
            build.append(template("end\n"));
        }
        
        
        build.append("//======================================================== sets\n");
        HashMap<String, StringBuilder> to_wires_map = new HashMap<>();
        
        for(ConditionPoint point : sets) {
            
            String condition = "";
            for(Condition cond : point.conditions_stack) {
                if(condition.length() > 0) condition += " && ";
                condition += ((cond.negation)? "~" : "") + ("cond_" + cond.index);
            }
            
            if(condition.length() == 0) throw new Exception("Invalid SET(): no condition.");
            
            String name  = convert_expression(point.name);
            String value = convert_expression(point.value);
            
            StringBuilder builder = to_wires_map.get(name);
            if(builder == null) {
                builder = new StringBuilder();
                to_wires_map.put(name, builder);
            }
            builder.append(template("    (#1)? (#2) :\n", condition,value));
        }
        
        for(String name : to_wires_map.keySet()) {
            
            if(wires.containsKey(name) == false) throw new Exception("Set to unknown wire: " + name);
            int size = wires.get(name);
            
            build.append(template("assign #1 =\n", name));
            
            build.append(to_wires_map.get(name));
            build.append(template("    #1'd0;\n", "" + size));
        }
        
        return build.toString();
    }
    
    
    Stack<Condition>            conditions_stack= new Stack<>();
    LinkedList<String>          conditions      = new LinkedList<>();
    
    LinkedList<ConditionPoint>  sets            = new LinkedList<>();
    LinkedList<ConditionPoint>  saves           = new LinkedList<>();
    
    HashMap<String, Integer>    registers       = new HashMap<>();
    HashMap<String, Integer>    wires           = new HashMap<>();
    
    HashSet<String>             no_always_block = new HashSet<>();
}

public class AutogenGenerator {
    
    static String strip(String string, String pattern) {
        Pattern p = Pattern.compile(pattern);
        Matcher m = p.matcher(string);
        
        StringBuffer sb = new StringBuffer();
        while (m.find()) {
            m.appendReplacement(sb, "");
        }
        m.appendTail(sb);
        
        return sb.toString();
    }
    
    static void findRegsAndWires(String source, Model model) {
        
        // strip comments
        source = strip(source, "//[^\\n]*");
        
        // regs
        Matcher reg_single = Pattern.compile("reg\\s+(\\w+)\\s*;").matcher(source);
        while(reg_single.find()) model.registers.put(reg_single.group(1), 1);
        
        Matcher reg_vector = Pattern.compile("reg\\s+\\[(\\d+)\\s*:\\s*0\\s*\\]\\s*(\\w+)\\s*;").matcher(source);
        while(reg_vector.find()) model.registers.put(reg_vector.group(2), Integer.parseInt(reg_vector.group(1))+1);
        
        Matcher out_reg_single = Pattern.compile("output\\s+reg\\s+(\\w+)\\s*[,\\)\\s]").matcher(source);
        while(out_reg_single.find()) model.registers.put(out_reg_single.group(1), 1);
        
        Matcher out_reg_vector = Pattern.compile("output\\s+reg\\s+\\[(\\d+)\\s*:\\s*0\\s*\\]\\s*(\\w+)\\s*[,\\)\\s]").matcher(source);
        while(out_reg_vector.find()) model.registers.put(out_reg_vector.group(2), Integer.parseInt(out_reg_vector.group(1))+1);
        
        //wires
        Matcher wire_single = Pattern.compile("wire\\s+(\\w+)\\s*;").matcher(source);
        while(wire_single.find()) model.wires.put(wire_single.group(1), 1);
        
        Matcher wire_vector = Pattern.compile("wire\\s+\\[(\\d+)\\s*:\\s*0\\s*\\]\\s*(\\w+)\\s*;").matcher(source);
        while(wire_vector.find()) model.wires.put(wire_vector.group(2), Integer.parseInt(wire_vector.group(1))+1);
        
        Matcher out_wire_single = Pattern.compile("output\\s+(\\w+)\\s*[,\\)\\s]").matcher(source);
        while(out_wire_single.find()) model.wires.put(out_wire_single.group(1), 1);
        
        Matcher out_wire_vector = Pattern.compile("output\\s+\\[(\\d+)\\s*:\\s*0\\s*\\]\\s*(\\w+)\\s*[,\\)\\s]").matcher(source);
        while(out_wire_vector.find()) model.wires.put(out_wire_vector.group(2), Integer.parseInt(out_wire_vector.group(1))+1);
        
    }
    
    static void parseScript(String script, Model model) throws Exception {
        
        // strip comments
        script = strip(script, "//[^\\n]*");
        
        // strip start and end whitespace
        script = script.trim();
        
        Pattern if_pattern       = Pattern.compile("(?s)^\\s*IF\\s*\\((.*?)\\)\\s*;");
        Pattern set_true_pattern = Pattern.compile("^\\s*SET\\s*\\((.*?)\\)\\s*;");
        Pattern set_pattern      = Pattern.compile("(?s)^\\s*SET\\s*\\(([^,\\)]*),(.*?)\\)\\s*;");
        Pattern save_pattern     = Pattern.compile("(?s)^\\s*SAVE\\s*\\(([^,\\)]*),(.*?)\\)\\s*;");
        Pattern endif_pattern    = Pattern.compile("^\\s*ENDIF\\s*\\(\\s*\\)\\s*;");
        Pattern else_pattern     = Pattern.compile("^\\s*ELSE\\s*\\(\\s*\\)\\s*;");
        Pattern elseif_pattern   = Pattern.compile("(?s)^\\s*ELSE_IF\\s*\\((.*?)\\)\\s*;");
        Pattern no_always_pattern= Pattern.compile("^\\s*NO_ALWAYS_BLOCK\\s*\\((.*?)\\)\\s*;");
        
        while(true) {
            Matcher if_matcher       = if_pattern.matcher(script);
            Matcher set_true_matcher = set_true_pattern.matcher(script);
            Matcher set_matcher      = set_pattern.matcher(script);
            Matcher save_matcher     = save_pattern.matcher(script);
            Matcher endif_matcher    = endif_pattern.matcher(script);
            Matcher else_matcher     = else_pattern.matcher(script);
            Matcher elseif_matcher   = elseif_pattern.matcher(script);
            Matcher no_always_matcher= no_always_pattern.matcher(script);
            
            if(if_matcher.find()) {
                model.IF(if_matcher.group(1));
                script = script.substring(if_matcher.end());
            }
            else if(set_matcher.find()) {
                model.SET(set_matcher.group(1), set_matcher.group(2));
                script = script.substring(set_matcher.end());
            }
            else if(set_true_matcher.find()) {
                model.SET(set_true_matcher.group(1));
                script = script.substring(set_true_matcher.end());
            }
            else if(save_matcher.find()) {
                model.SAVE(save_matcher.group(1), save_matcher.group(2));
                script = script.substring(save_matcher.end());
            }
            else if(endif_matcher.find()) {
                model.ENDIF();
                script = script.substring(endif_matcher.end());
            }
            else if(else_matcher.find()) {
                model.ELSE();
                script = script.substring(else_matcher.end());
            }
            else if(elseif_matcher.find()) {
                model.ELSE_IF(elseif_matcher.group(1));
                script = script.substring(elseif_matcher.end());
            }
            else if(no_always_matcher.find()) {
                model.NO_ALWAYS_BLOCK(no_always_matcher.group(1));
                script = script.substring(no_always_matcher.end());
            }
            else break;
        }
        if(model.conditions_stack.empty() == false) throw new Exception("Condition stack not empty: " +
                model.conditions.get(model.conditions_stack.peek().index));
        
        if(script.length() > 0) throw new Exception("Left not empty: " + script);
    }
    
    static void process_file(File file) throws Exception {
        byte file_bytes[] = Files.readAllBytes(file.toPath());
        String file_string = new String(file_bytes);

        if(file_string.indexOf("//PARSED_COMMENTS") == -1) return;

        System.out.println("Processing file: " + file);

        String start_string = "/*******************************************************************************SCRIPT";
        String end_string   = "*/";

        int index = 0;

        Model model = new Model();

        findRegsAndWires(file_string, model);

        while(true) {
            index = file_string.indexOf(start_string, index);
            if(index == -1) break;

            index += start_string.length();

            int end = file_string.indexOf(end_string, index);
            if(end == -1) throw new Exception("Invalid script: end string not found.");

            String script = file_string.substring(index, end);
            parseScript(script, model);
        }
        // expand macros
        if(file.getName().toLowerCase().equals("decode_commands.v")) {
            String script = Commands.decode.toString();
            
            parseScript(script, model);
        }
        if(file.getName().toLowerCase().equals("microcode_commands.v")) {
            String script = Commands.microcode.toString();
            
            //System.out.println("microcode:\n" + script);
            parseScript(script, model);
        }
        if(file.getName().toLowerCase().equals("read_commands.v")) {
            String script = Commands.read.toString();
            
            //System.out.println("microcode:\n" + script);
            parseScript(script, model);
        }
        if(file.getName().toLowerCase().equals("execute_commands.v")) {
            String script = Commands.execute.toString();
            
            //System.out.println("execute:\n" + script);
            parseScript(script, model);
        }
        if(file.getName().toLowerCase().equals("write_commands.v")) {
            String script = Commands.write.toString();
            
            //System.out.println("execute:\n" + script);
            parseScript(script, model);
        }
        
        // get old contents
        File autogen_file = new File(autogen_dir.getCanonicalPath() + "/" + file.getName());
        
        String old_contents = "";
        if(autogen_file.exists()) {
            old_contents = new String(Files.readAllBytes(autogen_file.toPath()));
        }
        
        // generate new contents
        String new_contents = model.generate();
        
        if(file.getName().toLowerCase().equals("read_commands.v")) {
            new_contents = Commands.read_local + new_contents;
        }
        if(file.getName().toLowerCase().equals("execute_commands.v")) {
            new_contents = Commands.execute_local + new_contents;
        }
        if(file.getName().toLowerCase().equals("write_commands.v")) {
            new_contents = Commands.write_local + new_contents;
        }
        
        if(new_contents.equals(old_contents) == false) {
            FileOutputStream out = new FileOutputStream(autogen_file);
            out.write(new_contents.getBytes());
            out.close();
        }
    }
    
    static void recurrent(File directory) throws Exception {
        for(File file : directory.listFiles()) {
            if(file.isDirectory()) {
                recurrent(file);
                continue;
            }
            
            // skip autogen files
            if(file.getCanonicalPath().indexOf("autogen") != -1) continue;
            
            process_file(file);
        }
    }
    
    static void process_defines() throws Exception {
        File defines_file = new File(autogen_dir.getCanonicalPath() + "/" + "defines.v");
        
        String old_contents = "";
        if(defines_file.exists()) {
            old_contents = new String(Files.readAllBytes(defines_file.toPath()));
        }
        
        StringBuilder new_contents = new StringBuilder();
        for(String key : Commands.defines.keySet()) {
            new_contents.append("`define " + key + " " + Commands.defines.get(key) + "\n");
        }
        
        if(new_contents.toString().equals(old_contents) == false) {
            FileOutputStream out = new FileOutputStream(defines_file);
            out.write(new_contents.toString().getBytes());
            out.close();
        }
    }
    
    public static void main(String args[]) throws Exception {
        
        File rtl_dir = new File("./../rtl/ao486");
        File cmd_dir = new File("./../rtl/ao486/commands");
        autogen_dir = new File("./../rtl/ao486/autogen");
        
        Commands.read_command_files(cmd_dir);
        
        process_defines();
        
        recurrent(rtl_dir);
    }
    
    static File autogen_dir;
}
