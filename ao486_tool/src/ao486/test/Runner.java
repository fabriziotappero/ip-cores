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

import ao486.test.Runner.CMD_start_output;
import ao486.test.Runner.CMD_start_completed;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.OutputStream;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Runner {
    
    //--------------------------------------------------------------------------
    static class CMD_start_completed {
        long time;
        
        long rep;
        long seg;
        long lock;
        long os32;
        long as32;
        long consumed;
    }
    void start_completed(CMD_start_completed params) throws Exception {
        System.out.println("----------------------------------------------------------------[Runner]: start_completed");
        
        unit.run_log.add(params);
    }
    
    //--------------------------------------------------------------------------
    static class CMD_start_output {
        long time;
        
        //only from verilog testbench
        long tb_wr_cmd_last;
        long tb_can_ignore;
        
        long eax, ebx, ecx, edx, esi, edi, ebp, esp;
        long eip;
        long cflag, pflag, aflag, zflag, sflag, tflag, iflag, dflag, oflag, iopl, ntflag, rflag, vmflag, acflag, idflag;
        
        long cs_cache_valid,   cs,   cs_rpl,   cs_base,   cs_limit,   cs_g,   cs_d_b,   cs_avl,   cs_p,   cs_dpl,   cs_s,   cs_type;
        long ds_cache_valid,   ds,   ds_rpl,   ds_base,   ds_limit,   ds_g,   ds_d_b,   ds_avl,   ds_p,   ds_dpl,   ds_s,   ds_type;
        long es_cache_valid,   es,   es_rpl,   es_base,   es_limit,   es_g,   es_d_b,   es_avl,   es_p,   es_dpl,   es_s,   es_type;
        long fs_cache_valid,   fs,   fs_rpl,   fs_base,   fs_limit,   fs_g,   fs_d_b,   fs_avl,   fs_p,   fs_dpl,   fs_s,   fs_type;
        long gs_cache_valid,   gs,   gs_rpl,   gs_base,   gs_limit,   gs_g,   gs_d_b,   gs_avl,   gs_p,   gs_dpl,   gs_s,   gs_type;
        long ss_cache_valid,   ss,   ss_rpl,   ss_base,   ss_limit,   ss_g,   ss_d_b,   ss_avl,   ss_p,   ss_dpl,   ss_s,   ss_type;
        long ldtr_cache_valid, ldtr, ldtr_rpl, ldtr_base, ldtr_limit, ldtr_g, ldtr_d_b, ldtr_avl, ldtr_p, ldtr_dpl, ldtr_s, ldtr_type;
        long tr_cache_valid,   tr,   tr_rpl,   tr_base,   tr_limit,   tr_g,   tr_d_b,   tr_avl,   tr_p,   tr_dpl,   tr_s,   tr_type;
        
        long gdtr_base, gdtr_limit;
        long idtr_base, idtr_limit;
        
        long cr0_pe, cr0_mp, cr0_em, cr0_ts, cr0_ne, cr0_wp, cr0_am, cr0_nw, cr0_cd, cr0_pg;
        
        long cr2, cr3;
        
        long dr0, dr1, dr2, dr3;
        long dr6, dr7;
    }
    void start_output(CMD_start_output params) throws Exception {
        System.out.println("[Runner]: start_output");
        
        unit.run_log.add(params);
    }
    
    //--------------------------------------------------------------------------
    static class CMD_start_check_interrupt {
        long time;
    }
    void start_check_interrupt(CMD_start_check_interrupt params) throws Exception {
        System.out.println("[Runner]: start_check_interrupt");
        
        long value = unit.check_interrupt(params.time);
        
        out.write(String.format("%x\n", value).getBytes());
        out.flush();
    }
    
    //--------------------------------------------------------------------------
    static class CMD_start_interrupt {
        long time;
        
        long vector;
    }
    void start_interrupt(CMD_start_interrupt params) throws Exception {
        System.out.println("[Runner]: start_interrupt");
        
        unit.run_log.add(params);
    }
    
    //--------------------------------------------------------------------------
    static class CMD_start_exception {
        long time;
        
        long vector;
        long push_error;
        long error_code;
    }
    void start_exception(CMD_start_exception params) throws Exception {
        System.out.println("[Runner]: start_exception");
        
        unit.run_log.add(params);
    }
    
    //--------------------------------------------------------------------------
    static class CMD_start_read {
        long time;
        
        long address;
        long byteena;
        long can_ignore;
    }
    void start_read(CMD_start_read params) throws Exception {
        System.out.printf("[Runner]: start_read, address: %08x, byteena: %x\n", params.address, params.byteena);
        
        unit.run_log.add(params);
        
        long value = unit.read(params);
        params.byteena |= (value & 0xFFFFFFFFL) << 8;
        
        out.write(String.format("%x\n", value).getBytes());
        out.flush();
        
System.out.printf("[Runner]: start_read done: %08x\n", value);
    }
    
    //--------------------------------------------------------------------------
    static class CMD_start_read_code {
        long time;
        
        long address;
        long byteena;
    }
    void start_read_code(CMD_start_read_code params) throws Exception {
//System.out.printf("[Runner]: start_read_code: %08x ena %x\n", params.address, params.byteena);
        
        long value = unit.read_code(params);
        
//System.out.printf("[Runner]: start_read_code result: %08x\n", value);
        
        out.write(String.format("%x\n", value).getBytes());
        out.flush();
    }
    
    //--------------------------------------------------------------------------
    static class CMD_start_write {
        long time;
        
        long address;
        long data;
        long byteena;
        long can_ignore;
    }
    void start_write(CMD_start_write params) throws Exception {
        System.out.println("[Runner]: start_write");
        
        if(((params.byteena >> 0) & 1) == 0) params.data &= 0xFFFFFF00L;
        if(((params.byteena >> 1) & 1) == 0) params.data &= 0xFFFF00FFL;
        if(((params.byteena >> 2) & 1) == 0) params.data &= 0xFF00FFFFL;
        if(((params.byteena >> 3) & 1) == 0) params.data &= 0x00FFFFFFL;
        
        unit.run_log.add(params);
        
        unit.write(params);
    }
    
    //--------------------------------------------------------------------------
    static class CMD_start_io_write {
        long time;
        
        long address;
        long data;
        long byteena;
        long can_ignore;
    }
    void start_io_write(CMD_start_io_write params) throws Exception {
        System.out.printf("[Runner]: start_io_write: %04x byteena: %x\n", params.address, params.byteena);
        
        if(((params.byteena >> 0) & 1) == 0) params.data &= 0xFFFFFF00L;
        if(((params.byteena >> 1) & 1) == 0) params.data &= 0xFFFF00FFL;
        if(((params.byteena >> 2) & 1) == 0) params.data &= 0xFF00FFFFL;
        if(((params.byteena >> 3) & 1) == 0) params.data &= 0x00FFFFFFL;
        
        unit.run_log.add(params);
        
        unit.write_io(params);
    }
    
    //--------------------------------------------------------------------------
    static class CMD_start_io_read {
        long time;
        
        long address;
        long byteena;
        long can_ignore;
    }
    void start_io_read(CMD_start_io_read params) throws Exception {
        System.out.println("[Runner]: start_io_read");
        
        unit.run_log.add(params);
        
        boolean read_ff =
                (params.address >= 0x0010 && params.address < 0x0020)     ||         
                (params.address == 0x0020 && (params.byteena & 0x3) == 0) ||
                (params.address >= 0x0024 &&  params.address < 0x0040)    ||
                (params.address >= 0x0044 &&  params.address < 0x0060)    ||
                (params.address >= 0x0068 &&  params.address < 0x0070)    ||
                (params.address == 0x0070 && (params.byteena & 0x3) == 0) ||
                (params.address >= 0x0074 &&  params.address < 0x0080)    ||
                (params.address == 0x00A0 && (params.byteena & 0x3) == 0) ||
                (params.address >= 0x00A4 &&  params.address < 0x00C0)    ||
                (params.address >= 0x00E0 &&  params.address < 0x01F0)    ||
                (params.address >= 0x01F8 &&  params.address < 0x0220)    ||
                (params.address >= 0x0230 &&  params.address < 0x0388)    ||
                (params.address == 0x0388 && (params.byteena & 0x3) == 0) ||
                (params.address >= 0x038C &&  params.address < 0x03B0)    ||
                (params.address >= 0x03E0 &&  params.address < 0x03F0)    ||
                (params.address >= 0x03F8 &&  params.address < 0x8888)    ||
                (params.address >= 0x8890);
        
        boolean read_ff_part =
                (params.address == 0x0020) ||
                (params.address == 0x0070) ||
                (params.address == 0x00A0) ||
                (params.address == 0x0388);
        
        long value =
                (read_ff)?          0xFFFFFFFFL :
                (read_ff_part)?     0xFFFF0000L | unit.read_io(params) :
                                    unit.read_io(params);
        
        params.byteena |= (value & 0xFFFFFFFFL) << 8;
        
        out.write(String.format("%x\n", value).getBytes());
        out.flush();
    }
    
    //--------------------------------------------------------------------------
    static class CMD_start_input {
        long time;
    }
    void start_input(CMD_start_input params) throws Exception {
        System.out.println("[Runner]: start_input");
        
        for(Field field : CMD_start_output.class.getDeclaredFields()) {
            if(field.getName().equals("time"))              continue;
            if(field.getName().equals("tb_wr_cmd_last"))    continue;
            if(field.getName().equals("tb_can_ignore"))     continue;
            
            long value = unit.getInput(field.getName());
//System.out.println("start_input: " + field.getName() + ", " + value);        
            out.write(String.format("%s: %x\n", field.getName(), value).getBytes());
        }
        
        out.write(String.format("test_type: %x\n", unit.getTestType()).getBytes());
        
        out.write("continue: 0\n".getBytes());
        out.flush();
    }
    
    //--------------------------------------------------------------------------
    static class CMD_start_shutdown {
        long time;
    }
    void start_shutdown(CMD_start_shutdown params) throws Exception {
        System.out.println("[Runner]: start_shutdown");
        
        unit.run_log.add(params);
    }
    
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    
    void execute(LinkedList<String> command_line, File directory, TestUnit unit) throws Exception {
        
        Process p = null;
        this.unit = unit;
        
        try {
            ProcessBuilder pb = new ProcessBuilder(command_line);
            pb.directory(directory);
            pb.redirectErrorStream(true);

            p = pb.start();

            InputStream  in  = p.getInputStream();
            out = p.getOutputStream();
            
            boolean started = false;
            LineNumberReader reader = new LineNumberReader(new InputStreamReader(in));
            
            HashMap<String, Long> params = new HashMap<>();
            
            while(true) {
                String line = reader.readLine();
                if(line == null) {
                    in.close();
                    out.close();
                    
                    p.waitFor();
                    break;
                }

                line = line.trim();

//System.out.println("line: " + line);
                if(line.startsWith("START")) {
                    started = true;
                    continue;
                }

                if(started == false) continue;
                
                if(line.startsWith("#")) {
//System.out.println("line: " + line);
                    continue;
                }
                
                
                if(line.equals("")) {
                    if(params.isEmpty()) continue;
                    
                    dispatch(params);
                    params.clear();
                    
                    continue;
                }
                
                //match name: hex_value
                Pattern pat = Pattern.compile("(\\w+?):\\s*([0-9a-fA-F]+)");
                Matcher mat = pat.matcher(line);

                boolean found = mat.find();
                if(found == false) throw new Exception("Invalid line: " + line);

                String s1 = mat.group(1).trim();
                String s2 = mat.group(2).trim();

                params.put(s1, Long.parseLong(s2, 16));
//System.out.println("PUT: " + s1 + " = " + s2);
            }
        }
        finally {
            if(p != null) p.destroy();
        }
    }
    
    private void dispatch(HashMap<String, Long> params) throws Exception {
        
        //find name starting with: start_
        String start = null;
        for(String name : params.keySet()) if(name.startsWith("start_")) { start = name; break; }
        
        if(start == null) throw new Exception("No start_* in command.");
        
        Class this_class = this.getClass();
        
        //find class
        Class command_class = null;
        for(Class inner_class : this_class.getDeclaredClasses()) {
            if(inner_class.getSimpleName().equals("CMD_" + start)) {
                command_class = inner_class;
                break;
            }
        }
        if(command_class == null) throw new Exception("No command class found for: " + start);
        
        //find method
        Method method = null;
        for(Method m : this_class.getDeclaredMethods()) {
            if(m.getName().equals(start)) {
                method = m;
                break;
            }
        }
        if(method == null) throw new Exception("No method found for: " + start);
        
        //command class instance
        Object class_obj = command_class.newInstance();
        
        for(Field f : command_class.getDeclaredFields()) {
            String field_name = f.getName();
            
            if(field_name.equals("time")) {
                f.set(class_obj, params.get(start));
            }
            else if(params.containsKey(field_name)) {
                f.set(class_obj, params.get(field_name));
            }
            else throw new Exception("Unknown field name: " + field_name + " for class: " + command_class.getSimpleName());
        }
        
        //execute method
        method.setAccessible(true);
        method.invoke(this, class_obj);
    }
    
    private TestUnit     unit;
    private OutputStream out;
}
