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

import java.io.File;
import java.io.FileOutputStream;
import java.util.LinkedList;

public class RunRaport {
    static boolean compare(LinkedList<Object> log_bochs, LinkedList<Object> log_verilog, File output_directory) throws Exception {
        
        StringBuilder bochs_build   = new StringBuilder();
        StringBuilder verilog_build = new StringBuilder();
        
        boolean test_failed = false;
        String header_line = "--------------------------------------------------------";
        
        //---------------------------------------------------------------------- CMD_start_shutdown
        bochs_build  .append(header_line).append(" shutdown\n");
        verilog_build.append(header_line).append(" shutdown\n");
        
        StringBuilder bochs_shutdown   = new StringBuilder();
        StringBuilder verilog_shutdown = new StringBuilder();
        
        for(Object obj : log_bochs) {
            if(obj instanceof Runner.CMD_start_shutdown) {
                String s = String.format("shutdown\n"); bochs_build.append(s); bochs_shutdown.append(s);
            }
        }
        for(Object obj : log_verilog) {
            if(obj instanceof Runner.CMD_start_shutdown) {
                String s = String.format("shutdown\n"); verilog_build.append(s); verilog_shutdown.append(s);
            }
        }
        if(bochs_shutdown.toString().equals(verilog_shutdown.toString()) == false) {
            System.out.println("FAILED: shutdown");
            test_failed = true;
        }
        
        //---------------------------------------------------------------------- CMD_start_completed
        bochs_build  .append(header_line).append(" completed\n");
        verilog_build.append(header_line).append(" completed\n");
        
        StringBuilder bochs_completed   = new StringBuilder();
        StringBuilder verilog_completed = new StringBuilder();
        
        int i = 0;
        for(Object obj : log_bochs) {
            if(obj instanceof Runner.CMD_start_completed) {
                Runner.CMD_start_completed completed = (Runner.CMD_start_completed)obj;
                String s;
                
                bochs_build.append(++i).append(".\n");
                s = String.format("rep:  %x\n", completed.rep);      bochs_build.append(s); bochs_completed.append(s);
                s = String.format("lock: %x\n", completed.lock);     bochs_build.append(s); bochs_completed.append(s);
                s = String.format("seg:  %x\n", completed.seg);      bochs_build.append(s);
                s = String.format("as32: %x\n", completed.as32);     bochs_build.append(s); bochs_completed.append(s);
                s = String.format("os32: %x\n", completed.os32);     bochs_build.append(s); bochs_completed.append(s);
                s = String.format("cons: %x\n", completed.consumed); bochs_build.append(s); bochs_completed.append(s);
                bochs_build.append("\n");
            }
        }
        i=0;
        for(Object obj : log_verilog) {
            if(obj instanceof Runner.CMD_start_completed) {
                Runner.CMD_start_completed completed = (Runner.CMD_start_completed)obj;
                String s;
                
                verilog_build.append(++i).append(".\n");
                s = String.format("rep:  %x\n", completed.rep);      verilog_build.append(s); verilog_completed.append(s);
                s = String.format("lock: %x\n", completed.lock);     verilog_build.append(s); verilog_completed.append(s);
                s = String.format("seg:  --\n");                     verilog_build.append(s);
                s = String.format("as32: %x\n", completed.as32);     verilog_build.append(s); verilog_completed.append(s);
                s = String.format("os32: %x\n", completed.os32);     verilog_build.append(s); verilog_completed.append(s);
                s = String.format("cons: %x\n", completed.consumed); verilog_build.append(s); verilog_completed.append(s);
                verilog_build.append("\n");
            }
        }
        if(bochs_completed.toString().equals(verilog_completed.toString()) == false) {
            System.out.println("FAILED: completed");
            test_failed = true;
        }
        
        //---------------------------------------------------------------------- CMD_start_output
        bochs_build  .append(header_line).append(" output\n");
        verilog_build.append(header_line).append(" output\n");
        
        StringBuilder bochs_output   = new StringBuilder();
        StringBuilder verilog_output = new StringBuilder();
        
        i = 0;
        for(Object obj : log_bochs) {
            if(obj instanceof Runner.CMD_start_output) {
                Runner.CMD_start_output output = (Runner.CMD_start_output)obj;
                String s;
                
                bochs_build.append(++i).append(".\n");
                prepare_output(output, bochs_build, bochs_output);
                bochs_build.append("\n");
                s = String.format("tb_wr_cmd_last: --\n"); bochs_build.append(s);
                s = String.format("tb_can_ignore: %x\n", output.tb_can_ignore); bochs_build.append(s); bochs_output.append(s);
                bochs_build.append("\n");
            }
        }
        int bochs_output_count = i;
        i = 0;
        for(Object obj : log_verilog) {
            if(obj instanceof Runner.CMD_start_output) {
                Runner.CMD_start_output output = (Runner.CMD_start_output)obj;
                String s;
                
                if(i == bochs_output_count && output.tb_can_ignore == 1) {
                    System.out.println("[RunRaport]: ignored output.");
                    continue;
                }
                
                verilog_build.append(++i).append(".\n");
                prepare_output(output, verilog_build, verilog_output);
                verilog_build.append("\n");
                s = String.format("tb_wr_cmd_last: %x\n", output.tb_wr_cmd_last); verilog_build.append(s);
                s = String.format("tb_can_ignore: %x\n", output.tb_can_ignore); verilog_build.append(s); verilog_output.append(s);
                verilog_build.append("\n");
            }
        }
        if(bochs_output.toString().equals(verilog_output.toString()) == false) {
            System.out.println("FAILED: output");
            test_failed = true;
        }
        
        //---------------------------------------------------------------------- CMD_start_interrupt
        bochs_build  .append(header_line).append(" interrupt\n");
        verilog_build.append(header_line).append(" interrupt\n");
        
        StringBuilder bochs_interrupt   = new StringBuilder();
        StringBuilder verilog_interrupt = new StringBuilder();
        
        i = 0;
        for(Object obj : log_bochs) {
            if(obj instanceof Runner.CMD_start_interrupt) {
                Runner.CMD_start_interrupt interrupt = (Runner.CMD_start_interrupt)obj;
                String s;
                
                bochs_build.append(++i).append(".\n");
                s = String.format("vector:  %02x\n", interrupt.vector);  bochs_build.append(s); bochs_interrupt.append(s);
                bochs_build.append("\n");
            }
        }
        i = 0;
        for(Object obj : log_verilog) {
            if(obj instanceof Runner.CMD_start_interrupt) {
                Runner.CMD_start_interrupt interrupt = (Runner.CMD_start_interrupt)obj;
                String s;
                
                verilog_build.append(++i).append(".\n");
                s = String.format("vector:  %02x\n", interrupt.vector);  verilog_build.append(s); verilog_interrupt.append(s);
                verilog_build.append("\n");
            }
        }
        if(bochs_interrupt.toString().equals(verilog_interrupt.toString()) == false) {
            System.out.println("FAILED: interrupt");
            test_failed = true;
        }
        
        //---------------------------------------------------------------------- CMD_start_exception
        bochs_build  .append(header_line).append(" exception\n");
        verilog_build.append(header_line).append(" exception\n");
        
        StringBuilder bochs_exception   = new StringBuilder();
        StringBuilder verilog_exception = new StringBuilder();
        
        i = 0;
        for(Object obj : log_bochs) {
            if(obj instanceof Runner.CMD_start_exception) {
                Runner.CMD_start_exception exception = (Runner.CMD_start_exception)obj;
                String s;
                
                bochs_build.append(++i).append(".\n");
                s = String.format("vector:     %02x\n", exception.vector);     bochs_build.append(s); bochs_exception.append(s);
                s = String.format("push_error: %x\n",   exception.push_error); bochs_build.append(s); bochs_exception.append(s);
                s = String.format("error_code: %x\n",   exception.error_code); bochs_build.append(s); bochs_exception.append(s);
                bochs_build.append("\n");
            }
        }
        i = 0;
        for(Object obj : log_verilog) {
            if(obj instanceof Runner.CMD_start_exception) {
                Runner.CMD_start_exception exception = (Runner.CMD_start_exception)obj;
                String s;
                
                verilog_build.append(++i).append(".\n");
                s = String.format("vector:     %02x\n", exception.vector);     verilog_build.append(s); verilog_exception.append(s);
                s = String.format("push_error: %x\n",   exception.push_error); verilog_build.append(s); verilog_exception.append(s);
                s = String.format("error_code: %x\n",   exception.error_code); verilog_build.append(s); verilog_exception.append(s);
                verilog_build.append("\n");
            }
        }
        if(bochs_exception.toString().equals(verilog_exception.toString()) == false) {
            System.out.println("FAILED: exception");
            test_failed = true;
        }
        
        //---------------------------------------------------------------------- CMD_start_read
        bochs_build  .append(header_line).append(" read\n");
        verilog_build.append(header_line).append(" read\n");
        
        StringBuilder bochs_read   = new StringBuilder();
        StringBuilder verilog_read = new StringBuilder();
        
        i = 0;
        for(Object obj : log_bochs) {
            if(obj instanceof Runner.CMD_start_read) {
                Runner.CMD_start_read read = (Runner.CMD_start_read)obj;
                String s;
                
                bochs_build.append(++i).append(".\n");
                s = String.format("address:    %02x\n", read.address);        bochs_build.append(s); bochs_read.append(s);
                s = String.format("byteena:    %x\n",   read.byteena & 0xFL); bochs_build.append(s); bochs_read.append(s);
                s = String.format("data:       %08x\n", read.byteena >> 8);   bochs_build.append(s); bochs_read.append(s);
                s = String.format("can_ignore: %x\n",   read.can_ignore);     bochs_build.append(s); bochs_read.append(s);
                bochs_build.append("\n");
            }
        }
        int bochs_read_count = i;
        i = 0;
        for(Object obj : log_verilog) {
            if(obj instanceof Runner.CMD_start_read) {
                Runner.CMD_start_read read = (Runner.CMD_start_read)obj;
                String s;
                
                if(i == bochs_read_count && read.can_ignore == 1) {
                    System.out.println("[RunRaport]: ignored read.");
                    continue;
                }
                
                verilog_build.append(++i).append(".\n");
                s = String.format("address:    %02x\n", read.address);        verilog_build.append(s); verilog_read.append(s);
                s = String.format("byteena:    %x\n",   read.byteena & 0xFL); verilog_build.append(s); verilog_read.append(s);
                s = String.format("data:       %08x\n", read.byteena >> 8);   verilog_build.append(s); verilog_read.append(s);
                s = String.format("can_ignore: %x\n",   read.can_ignore);     verilog_build.append(s); verilog_read.append(s);
                verilog_build.append("\n");
            }
        }
        if(bochs_read.toString().equals(verilog_read.toString()) == false) {
            System.out.println("FAILED: read");
            test_failed = true;
        }
        
        //---------------------------------------------------------------------- CMD_start_io_read
        bochs_build  .append(header_line).append(" io_read\n");
        verilog_build.append(header_line).append(" io_read\n");
        
        StringBuilder bochs_io_read   = new StringBuilder();
        StringBuilder verilog_io_read = new StringBuilder();
        
        i = 0;
        for(Object obj : log_bochs) {
            if(obj instanceof Runner.CMD_start_io_read) {
                Runner.CMD_start_io_read io_read = (Runner.CMD_start_io_read)obj;
                String s;
                
                bochs_build.append(++i).append(".\n");
                s = String.format("address:    %02x\n", io_read.address);        bochs_build.append(s); bochs_io_read.append(s);
                s = String.format("byteena:    %x\n",   io_read.byteena & 0xFL); bochs_build.append(s); bochs_io_read.append(s);
                s = String.format("data:       %08x\n", io_read.byteena >> 8);   bochs_build.append(s); bochs_io_read.append(s);
                s = String.format("can_ignore: %x\n",   io_read.can_ignore);     bochs_build.append(s); bochs_io_read.append(s);
                bochs_build.append("\n");
            }
        }
        int bochs_io_read_count = i;
        i = 0;
        for(Object obj : log_verilog) {
            if(obj instanceof Runner.CMD_start_io_read) {
                Runner.CMD_start_io_read io_read = (Runner.CMD_start_io_read)obj;
                String s;
                
                if(i == bochs_io_read_count && io_read.can_ignore == 1) {
                    System.out.println("[RunRaport]: io_read ignored.");
                    continue;
                }
                
                verilog_build.append(++i).append(".\n");
                s = String.format("address:    %02x\n", io_read.address);        verilog_build.append(s); verilog_io_read.append(s);
                s = String.format("byteena:    %x\n",   io_read.byteena & 0xFL); verilog_build.append(s); verilog_io_read.append(s);
                s = String.format("data:       %08x\n", io_read.byteena >> 8);   verilog_build.append(s); verilog_io_read.append(s);
                s = String.format("can_ignore: %x\n",   io_read.can_ignore);     verilog_build.append(s); verilog_io_read.append(s);
                verilog_build.append("\n");
            }
        }
        if(bochs_io_read.toString().equals(verilog_io_read.toString()) == false) {
            System.out.println("FAILED: io_read");
            test_failed = true;
        }
        
        //---------------------------------------------------------------------- CMD_start_write
        bochs_build  .append(header_line).append(" write\n");
        verilog_build.append(header_line).append(" write\n");
        
        StringBuilder bochs_write   = new StringBuilder();
        StringBuilder verilog_write = new StringBuilder();
        
        i = 0;
        for(Object obj : log_bochs) {
            if(obj instanceof Runner.CMD_start_write) {
                Runner.CMD_start_write write = (Runner.CMD_start_write)obj;
                String s;
                
                bochs_build.append(++i).append(".\n");
                s = String.format("address:    %02x\n", write.address);        bochs_build.append(s); bochs_write.append(s);
                s = String.format("byteena:    %x\n",   write.byteena & 0xFL); bochs_build.append(s); bochs_write.append(s);
                s = String.format("data:       %08x\n", write.data);           bochs_build.append(s); bochs_write.append(s);
                s = String.format("can_ignore: %x\n",   write.can_ignore);     bochs_build.append(s);
                bochs_build.append("\n");
            }
        }
        int bochs_write_count = i;
        i = 0;
        for(Object obj : log_verilog) {
            if(obj instanceof Runner.CMD_start_write) {
                Runner.CMD_start_write write = (Runner.CMD_start_write)obj;
                String s;
                
                if(i == bochs_write_count && write.can_ignore == 1) {
                    System.out.println("[RunRaport]: ignored write.");
                    continue;
                }
                
                verilog_build.append(++i).append(".\n");
                s = String.format("address:    %02x\n", write.address);        verilog_build.append(s); verilog_write.append(s);
                s = String.format("byteena:    %x\n",   write.byteena & 0xFL); verilog_build.append(s); verilog_write.append(s);
                s = String.format("data:       %08x\n", write.data);           verilog_build.append(s); verilog_write.append(s);
                s = String.format("can_ignore: %x\n",   write.can_ignore);     verilog_build.append(s);
                verilog_build.append("\n");
            }
        }
        if(bochs_write.toString().equals(verilog_write.toString()) == false) {
            System.out.println("FAILED: write");
            test_failed = true;
        }
        
        //---------------------------------------------------------------------- CMD_start_io_write
        bochs_build  .append(header_line).append(" io_write\n");
        verilog_build.append(header_line).append(" io_write\n");
        
        StringBuilder bochs_io_write   = new StringBuilder();
        StringBuilder verilog_io_write = new StringBuilder();
        
        i = 0;
        for(Object obj : log_bochs) {
            if(obj instanceof Runner.CMD_start_io_write) {
                Runner.CMD_start_io_write io_write = (Runner.CMD_start_io_write)obj;
                String s;
                
                bochs_build.append(++i).append(".\n");
                s = String.format("address:    %02x\n", io_write.address);        bochs_build.append(s); bochs_io_write.append(s);
                s = String.format("byteena:    %x\n",   io_write.byteena & 0xFL); bochs_build.append(s); bochs_io_write.append(s);
                s = String.format("data:       %08x\n", io_write.data);           bochs_build.append(s); bochs_io_write.append(s);
                s = String.format("can_ignore: %x\n",   io_write.can_ignore);     bochs_build.append(s);
                bochs_build.append("\n");
            }
        }
        int bochs_io_write_count = i;
        i = 0;
        for(Object obj : log_verilog) {
            if(obj instanceof Runner.CMD_start_io_write) {
                Runner.CMD_start_io_write io_write = (Runner.CMD_start_io_write)obj;
                String s;
                
                if(i == bochs_io_write_count && io_write.can_ignore == 1) {
                    System.out.println("[RunRaport]: ignored io_write.");
                    continue;
                }
                
                verilog_build.append(++i).append(".\n");
                s = String.format("address:    %02x\n", io_write.address);        verilog_build.append(s); verilog_io_write.append(s);
                s = String.format("byteena:    %x\n",   io_write.byteena & 0xFL); verilog_build.append(s); verilog_io_write.append(s);
                s = String.format("data:       %08x\n", io_write.data);           verilog_build.append(s); verilog_io_write.append(s);
                s = String.format("can_ignore: %x\n",   io_write.can_ignore);     verilog_build.append(s);
                verilog_build.append("\n");
            }
        }
        if(bochs_io_write.toString().equals(verilog_io_write.toString()) == false) {
            System.out.println("FAILED: io_write");
            test_failed = true;
        }
        
        //----------------------------------------------------------------------
        FileOutputStream fos = new FileOutputStream(output_directory.getCanonicalPath() + "/output_bochs.txt");
        fos.write(bochs_build.toString().getBytes());
        fos.close();
        
        fos = new FileOutputStream(output_directory.getCanonicalPath() + "/output_verilog.txt");
        fos.write(verilog_build.toString().getBytes());
        fos.close();
        
        //----------------------------------------------------------------------
        
        return test_failed;
    }
    
    static void prepare_output(Runner.CMD_start_output output, StringBuilder build, StringBuilder compare) {
        String s;
        
        s = String.format("eax(%08x) ebx(%08x) ecx(%08x) edx(%08x)\n", output.eax, output.ebx, output.ecx, output.edx);
        build.append(s); compare.append(s);
        s = String.format("esi(%08x) edi(%08x) ebp(%08x) esp(%08x)\n", output.esi, output.edi, output.ebp, output.esp);
        build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("eip(%08x)\n", output.eip); build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("cflag(%x) pflag(%x) aflag(%x) zflag(%x)\n", output.cflag, output.pflag, output.aflag, output.zflag);
        build.append(s); compare.append(s);
        s = String.format("sflag(%x) tflag(%x) iflag(%x) dflag(%x)\n", output.sflag, output.tflag, output.iflag, output.dflag);
        build.append(s); compare.append(s);
        s = String.format("oflag(%x) iopl(%x) ntflag(%x) rflag(%x)\n", output.oflag, output.iopl,  output.ntflag, output.rflag);
        build.append(s); compare.append(s);
        s = String.format("vmflag(%x) acflag(%x) idflag(%x)\n", output.vmflag, output.acflag, output.idflag);
        build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("cs(%04x) cs_rpl(%x) cs_cache_valid(%x)\n", output.cs, output.cs_rpl, output.cs_cache_valid);
        build.append(s); compare.append(s);
        s = String.format("cs_base(%08x) cs_limit(%08x) cs_g(%x) cs_d_b(%x)\n",
                output.cs_base, output.cs_limit, output.cs_g, output.cs_d_b);            build.append(s); compare.append(s);
        s = String.format("cs_avl(%x) cs_p(%x) cs_dpl(%x) cs_s(%x) cs_type(%x)\n",
                output.cs_avl, output.cs_p, output.cs_dpl, output.cs_s, output.cs_type); build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("ds(%04x) ds_rpl(%x) ds_cache_valid(%x)\n", output.ds, output.ds_rpl, output.ds_cache_valid);
        build.append(s); compare.append(s);
        s = String.format("ds_base(%08x) ds_limit(%08x) ds_g(%x) ds_d_b(%x)\n",
                output.ds_base, output.ds_limit, output.ds_g, output.ds_d_b);            build.append(s); compare.append(s);
        s = String.format("ds_avl(%x) ds_p(%x) ds_dpl(%x) ds_s(%x) ds_type(%x)\n",
                output.ds_avl, output.ds_p, output.ds_dpl, output.ds_s, output.ds_type); build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("es(%04x) es_rpl(%x) es_cache_valid(%x)\n", output.es, output.es_rpl, output.es_cache_valid);
        build.append(s); compare.append(s);
        s = String.format("es_base(%08x) es_limit(%08x) es_g(%x) es_d_b(%x)\n",
                output.es_base, output.es_limit, output.es_g, output.es_d_b);            build.append(s); compare.append(s);
        s = String.format("es_avl(%x) es_p(%x) es_dpl(%x) es_s(%x) es_type(%x)\n",
                output.es_avl, output.es_p, output.es_dpl, output.es_s, output.es_type); build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("fs(%04x) fs_rpl(%x) fs_cache_valid(%x)\n", output.fs, output.fs_rpl, output.fs_cache_valid);
        build.append(s); compare.append(s);
        s = String.format("fs_base(%08x) fs_limit(%08x) fs_g(%x) fs_d_b(%x)\n",
                output.fs_base, output.fs_limit, output.fs_g, output.fs_d_b);            build.append(s); compare.append(s);
        s = String.format("fs_avl(%x) fs_p(%x) fs_dpl(%x) fs_s(%x) fs_type(%x)\n",
                output.fs_avl, output.fs_p, output.fs_dpl, output.fs_s, output.fs_type); build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("gs(%04x) gs_rpl(%x) gs_cache_valid(%x)\n", output.gs, output.gs_rpl, output.gs_cache_valid);
        build.append(s); compare.append(s);
        s = String.format("gs_base(%08x) gs_limit(%08x) gs_g(%x) gs_d_b(%x)\n",
                output.gs_base, output.gs_limit, output.gs_g, output.gs_d_b);            build.append(s); compare.append(s);
        s = String.format("gs_avl(%x) gs_p(%x) gs_dpl(%x) gs_s(%x) gs_type(%x)\n",
                output.gs_avl, output.gs_p, output.gs_dpl, output.gs_s, output.gs_type); build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("ld(%04x) ld_rpl(%x) ld_cache_valid(%x)\n", output.ldtr, output.ldtr_rpl, output.ldtr_cache_valid);
        build.append(s); compare.append(s);
        s = String.format("ld_base(%08x) ld_limit(%08x) ld_g(%x) ld_d_b(%x)\n",
                output.ldtr_base, output.ldtr_limit, output.ldtr_g, output.ldtr_d_b);    build.append(s); compare.append(s);
        s = String.format("ld_avl(%x) ld_p(%x) ld_dpl(%x) ld_s(%x) ld_type(%x)\n",
                output.ldtr_avl, output.ldtr_p, output.ldtr_dpl, output.ldtr_s, output.ldtr_type);
        build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("tr(%04x) tr_rpl(%x) tr_cache_valid(%x)\n", output.tr, output.tr_rpl, output.tr_cache_valid);
        build.append(s); compare.append(s);
        s = String.format("tr_base(%08x) tr_limit(%08x) tr_g(%x) tr_d_b(%x)\n",
                output.tr_base, output.tr_limit, output.tr_g, output.tr_d_b);            build.append(s); compare.append(s);
        s = String.format("tr_avl(%x) tr_p(%x) tr_dpl(%x) tr_s(%x) tr_type(%x)\n",
                output.tr_avl, output.tr_p, output.tr_dpl, output.tr_s, output.tr_type); build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("gdtr_base(%08x) gdtr_limit(%04x) idtr_base(%08x) idtr_limit(%04x)",
                output.gdtr_base, output.gdtr_limit, output.idtr_base, output.idtr_limit);
        build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("cr0_pe(%x) cr0_mp(%x) cr0_em(%x) cr0_ts(%x)\n", output.cr0_pe, output.cr0_mp, output.cr0_em, output.cr0_ts);
        build.append(s); compare.append(s);
        s = String.format("cr0_ne(%x) cr0_wp(%x) cr0_am(%x) cr0_nw(%x)\n", output.cr0_ne, output.cr0_wp, output.cr0_am, output.cr0_nw);
        build.append(s); compare.append(s);
        s = String.format("cr0_cd(%x) cr0_pg(%x)\n", output.cr0_cd, output.cr0_pg);
        build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("cr2(%08x) cr3(%08x)\n", output.cr2, output.cr3); build.append(s); compare.append(s);

        build.append("\n");

        s = String.format("dr0(%08x) dr1(%08x) dr2(%08x) dr3(%08x)\n", output.dr0, output.dr1, output.dr2, output.dr3);
        build.append(s); compare.append(s);
        s = String.format("dr6(%08x) dr7(%08x)\n", output.dr6, output.dr7);
        build.append(s); compare.append(s);
    }
    
}
