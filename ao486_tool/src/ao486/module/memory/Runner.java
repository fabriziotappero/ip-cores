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

package ao486.module.memory;

import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.OutputStream;
import java.math.BigInteger;
import java.util.LinkedList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Runner {
    Runner(File directory) {
        this.directory = directory;
    }
    
    long make_descriptor(long base, long limit) throws Exception {
        
        if(limit >= 0x100000L && (limit & 0xFFFL) != 0xFFFL) throw new Exception(String.format("Illegal limit: %x", limit));
        
        long g = 0;
        if(limit >= 0x100000L) {
            g = 1L << 55;
            limit = (limit >> 12) & 0xFFFFFL;
        }
//System.out.printf("CS BASE: %x, CS LIMIT: %x\n", base, limit);
        return (((base >> 24) & 0xFFL) << 56) | ((base & 0x00FFFFFFL) << 16) | g | (((limit >> 16) & 0xFL) << 48) | (limit & 0xFFFFL);
    }
    
    void ser_bool(StringBuilder buf, String name, boolean bool) {
        buf.append(name).append(": ");
        buf.append(bool? "1 " : "0 ");
        buf.append("\n");
    }
    void ser_long(StringBuilder buf, String name, long l) {
        buf.append(name).append(": ");
        buf.append(String.format("%x ", l));
        buf.append("\n");
    }
    
    boolean des_bool(String str) {
        return Long.parseLong(str) == 1;
    }
    long des_long(String str) {
        int first = Integer.valueOf(str.substring(0,1), 16);
        if(str.length() == 16 && first >= 8) {
            long val = Long.parseLong(String.format("%x", first-8) + str.substring(1), 16);
            val += Long.MIN_VALUE;
            return val;
        }
        return Long.parseLong(str, 16);
    }
    BigInteger des_BigInteger(String str) {
        return new BigInteger(str, 16);
    }
    
    
    void execute() throws Exception {
        
        Process p = null;
        
        try {
            ProcessBuilder pb = new ProcessBuilder("/opt/iverilog/bin/vvp", "tb_memory.vvp"); //, "-lxt2");
            pb.directory(directory);
            pb.redirectErrorStream(true);

            p = pb.start();

            InputStream in   = p.getInputStream();
            OutputStream out = p.getOutputStream();

            Output output = new Output();
            output_invalid = false;

            boolean started = false;
            int cycle = 0;

            LineNumberReader reader = new LineNumberReader(new InputStreamReader(in));

            while(true) {
                String line = reader.readLine();
                if(line == null) break;

                line = line.trim();

//System.out.println("line: " + line);
                if(line.startsWith("START")) {
                    started = true;
                    continue;
                }

                if(started == false) continue;

                if(line.endsWith("x")) {
                    output_invalid = true;
//System.out.println("line.endsWith: " + line);
                    continue;
                }

                if(line.equals("")) {
                    if(output_invalid && cycle >= 3) throw new Exception("Invalid output.");

                    if(output_invalid == false) {
                        for(Listener listener : listeners) listener.get_output(cycle, output);
                    }

                    cycle++;

                    output = new Output();
                    output_invalid = false;

                    continue;
                }

                Pattern pat = Pattern.compile("(\\w+?):\\s*([0-9a-fA-F]+)");
                Matcher mat = pat.matcher(line);

                boolean found = mat.find();
                if(found == false) throw new Exception("Invalid line: " + line);

                String s1 = mat.group(1);
                String s2 = mat.group(2);

                s1 = s1.trim();
                s2 = s2.trim();

                if(s1.equals("request")) {
                    Input input = new Input();
                    if(cycle == 0) input.rst_n = true;
                    if(cycle == 1) input.rst_n = false;

                    if(cycle >= 3) {
                        for(Listener listener : listeners) listener.set_input(cycle, input);
                    }

                    StringBuilder buf = new StringBuilder();

                    ser_bool(buf, "rst_n", input.rst_n);

                    ser_bool(buf, "read_do",        input.read_do);
                    ser_long(buf, "read_cpl",       input.read_cpl);
                    ser_long(buf, "read_address",   input.read_address);
                    ser_long(buf, "read_length",    input.read_length);
                    ser_bool(buf, "read_lock",      input.read_lock);
                    ser_bool(buf, "read_rmw",       input.read_rmw);

                    ser_bool(buf, "write_do",       input.write_do);
                    ser_long(buf, "write_cpl",      input.write_cpl);
                    ser_long(buf, "write_address",  input.write_address);
                    ser_long(buf, "write_length",   input.write_length);
                    ser_bool(buf, "write_lock",     input.write_lock);
                    ser_bool(buf, "write_rmw",      input.write_rmw);
                    ser_long(buf, "write_data",     input.write_data);

                    ser_bool(buf, "tlbcheck_do",            input.tlbcheck_do);
                    ser_long(buf, "tlbcheck_address",       input.tlbcheck_address);
                    ser_bool(buf, "tlbcheck_rw",            input.tlbcheck_rw);

                    ser_bool(buf, "tlbflushsingle_do",      input.tlbflushsingle_do);
                    ser_long(buf, "tlbflushsingle_address", input.tlbflushsingle_address);

                    ser_bool(buf, "tlbflushall_do",         input.tlbflushall_do);

                    ser_bool(buf, "invdcode_do",            input.invdcode_do);
                    ser_bool(buf, "invddata_do",            input.invddata_do);
                    ser_bool(buf, "wbinvddata_do",          input.wbinvddata_do);

                    ser_long(buf, "prefetch_cpl",           input.cpl);
                    ser_long(buf, "prefetch_eip",           input.eip);
                    ser_long(buf, "cs_cache",               make_descriptor(input.cs_base, input.cs_limit));

                    ser_bool(buf, "prefetchfifo_accept_do", input.prefetchfifo_accept_do);

                    ser_bool(buf, "cr0_pg",             input.cr0_pg);
                    ser_bool(buf, "cr0_wp",             input.cr0_wp);
                    ser_bool(buf, "cr0_am",             input.cr0_am);
                    ser_bool(buf, "cr0_cd",             input.cr0_cd);
                    ser_bool(buf, "cr0_nw",             input.cr0_nw);

                    ser_bool(buf, "acflag",             input.acflag);

                    ser_long(buf, "cr3",                (input.cr3_base & 0xFFFFF000) | (input.cr3_pcd? 1<<4 : 0) | (input.cr3_pwt? 1<<3 : 0));

                    ser_bool(buf, "pipeline_after_read_empty",      input.pipeline_after_read_empty);
                    ser_bool(buf, "pipeline_after_prefetch_empty",  input.pipeline_after_prefetch_empty);

                    ser_bool(buf, "pr_reset",           input.pr_reset);
                    ser_bool(buf, "rd_reset",           input.rd_reset);
                    ser_bool(buf, "exe_reset",          input.exe_reset);
                    ser_bool(buf, "wr_reset",           input.wr_reset);

                    ser_bool(buf, "avm_waitrequest",   input.avm_waitrequest);
                    ser_bool(buf, "avm_readdatavalid", input.avm_readdatavalid);
                    ser_long(buf, "avm_readdata",      input.avm_readdata);

                    if(input.finished)  buf.append("quit: 0\n");
                    else                buf.append("continue: 0\n");

//System.out.println("Send: " + buf.toString());
                    out.write(buf.toString().getBytes());
                    out.flush();

                    continue;
                }

                switch(s1) {
                    case "time": break;

                    case "read_done":                   output.read_done                = des_bool(s2); break;
                    case "read_page_fault":             output.read_page_fault          = des_bool(s2); break;
                    case "read_ac_fault":               output.read_ac_fault            = des_bool(s2); break;
                    case "read_data":                   output.read_data                = des_long(s2); break;

                    case "write_done":                  output.write_done               = des_bool(s2); break;
                    case "write_page_fault":            output.write_page_fault         = des_bool(s2); break;
                    case "write_ac_fault":              output.write_ac_fault           = des_bool(s2); break;

                    case "tlbcheck_done":               output.tlbcheck_done            = des_bool(s2); break;
                    case "tlbcheck_page_fault":         output.tlbcheck_page_fault      = des_bool(s2); break;

                    case "tlbflushsingle_done":         output.tlbflushsingle_done      = des_bool(s2); break;

                    case "invdcode_done":               output.invdcode_done            = des_bool(s2); break;
                    case "invddata_done":               output.invddata_done            = des_bool(s2); break;
                    case "wbinvddata_done":             output.wbinvddata_done          = des_bool(s2); break;

                    case "prefetchfifo_accept_data":    output.prefetchfifo_accept_data = des_BigInteger(s2); break;
                    case "prefetchfifo_accept_empty":   output.prefetchfifo_accept_empty= des_bool(s2); break;

                    case "tlb_code_pf_cr2":             output.tlb_code_pf_cr2          = des_long(s2); break;
                    case "tlb_code_pf_error_code":      output.tlb_code_pf_error_code   = des_long(s2); break;

                    case "tlb_check_pf_cr2":            output.tlb_check_pf_cr2         = des_long(s2); break;
                    case "tlb_check_pf_error_code":     output.tlb_check_pf_error_code  = des_long(s2); break;

                    case "tlb_write_pf_cr2":            output.tlb_write_pf_cr2         = des_long(s2); break;
                    case "tlb_write_pf_error_code":     output.tlb_write_pf_error_code  = des_long(s2); break;

                    case "tlb_read_pf_cr2":             output.tlb_read_pf_cr2          = des_long(s2); break;
                    case "tlb_read_pf_error_code":      output.tlb_read_pf_error_code   = des_long(s2); break; 

                    case "avm_address":                 output.avm_address              = des_long(s2); break;
                    case "avm_writedata":               output.avm_writedata            = des_long(s2); break;
                    case "avm_byteenable":              output.avm_byteenable           = des_long(s2); break;
                    case "avm_burstcount":              output.avm_burstcount           = des_long(s2); break;
                    case "avm_write":                   output.avm_write                = des_bool(s2); break;
                    case "avm_read":                    output.avm_read                 = des_bool(s2); break;

                    default: throw new Exception("Unknown line: " + line);
                }

            }
            int result = p.waitFor();

            System.out.println("[Runner] Run result: " + result);
        }
        finally {
            if(p != null) p.destroy();
        }
    }
    
    boolean output_invalid;
    LinkedList<Listener> listeners;
    File directory;
}
