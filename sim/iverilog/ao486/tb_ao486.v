`timescale 1ps/1ps

`include "defines.v"

module tb_ao486();

reg             clk;
reg             rst_n;

//interrupt
reg     [7:0]   interrupt_vector;
reg             interrupt_do;
wire            interrupt_ack;

//data
wire    [31:0]  avm_address;
wire    [31:0]  avm_writedata;
wire    [3:0]   avm_byteenable;
wire    [2:0]   avm_burstcount;
wire            avm_write;
wire            avm_read;

reg             avm_waitrequest;
reg             avm_readdatavalid;
reg     [31:0]  avm_readdata;

//io
wire    [15:0]  avalon_io_address;
wire    [31:0]  avalon_io_writedata;
wire    [3:0]   avalon_io_byteenable;
wire            avalon_io_read;
wire            avalon_io_write;

reg             avalon_io_waitrequest;
reg             avalon_io_readdatavalid;
reg     [31:0]  avalon_io_readdata;

//debug
wire [17:0] SW = { 10'd0, 8'h00 };

ao486 ao486_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .rst_internal_n     (rst_n),              //input
    
    //-------------------------------------------------------------------------- interrupt
    .interrupt_vector   (interrupt_vector),   //input [7:0]
    .interrupt_do       (interrupt_do),       //input
    .interrupt_done     (interrupt_done),     //output
    
    //-------------------------------------------------------------------------- Altera Avalon memory bus
    .avm_address        (avm_address),        //output [31:0]
    .avm_writedata      (avm_writedata),      //output [31:0]
    .avm_byteenable     (avm_byteenable),     //output [3:0]
    .avm_burstcount     (avm_burstcount),     //output [2:0]
    .avm_write          (avm_write),          //output
    .avm_read           (avm_read),           //output
    
    .avm_waitrequest    (avm_waitrequest),    //input
    .avm_readdatavalid  (avm_readdatavalid),  //input
    .avm_readdata       (avm_readdata),       //input [31:0]
    
    //-------------------------------------------------------------------------- Altera Avalon io bus
    .avalon_io_address          (avalon_io_address),        //output [15:0]
    .avalon_io_writedata        (avalon_io_writedata),      //output [31:0]
    .avalon_io_byteenable       (avalon_io_byteenable),     //output [3:0]
    .avalon_io_read             (avalon_io_read),           //output
    .avalon_io_write            (avalon_io_write),          //output
    
    .avalon_io_waitrequest      (avalon_io_waitrequest),    //input
    .avalon_io_readdatavalid    (avalon_io_readdatavalid),  //input
    .avalon_io_readdata         (avalon_io_readdata),       //input [31:0]

    //debug
    .SW                         (SW) //input[17:0]
);

integer fscanf_ret;

reg [255:0] name;
reg [63:0]  value;

integer do_loop;
integer test_type;

task initialize;
begin
    $fwrite(STDOUT, "start_input: %x\n", $time);
    $fwrite(STDOUT, "\n");
    $fflush(STDOUT);
    
    do_loop = 1;
    
    while(do_loop == 1) begin
    
        fscanf_ret = $fscanf(STDIN, "%s", name);
        fscanf_ret = $fscanf(STDIN, "%x", value);
        
        case(name)
            "quit:":     begin $dumpoff(); $finish_and_return(0); end
            "continue:": begin
                do_loop = 0;
                
                #1
                ao486_inst.memory_inst.prefetch_inst.limit  = ao486_inst.memory_inst.prefetch_inst.cs_limit - ao486_inst.pipeline_inst.decode_inst.eip + 32'd1;
                ao486_inst.memory_inst.prefetch_inst.linear = ao486_inst.memory_inst.prefetch_inst.cs_base  + ao486_inst.pipeline_inst.decode_inst.eip;
                ao486_inst.exception_inst.exc_eip           = ao486_inst.pipeline_inst.decode_inst.eip;
            end
                
            "rst_n:":                   rst_n                   = value[0];
            
            "test_type:":               test_type               = value;
            
            "eax:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.eax = value[31:0];
            "ebx:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.ebx = value[31:0];
            "ecx:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.ecx = value[31:0];
            "edx:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.edx = value[31:0];
            "esi:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.esi = value[31:0];
            "edi:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.edi = value[31:0];
            "ebp:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.ebp = value[31:0];
            "esp:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.esp = value[31:0];
            
            "eip:":                     ao486_inst.pipeline_inst.decode_inst.eip = value[31:0];
            
            "cflag:":                   ao486_inst.pipeline_inst.write_inst.write_register_inst.cflag  = value[0];
            "pflag:":                   ao486_inst.pipeline_inst.write_inst.write_register_inst.pflag  = value[0];
            "aflag:":                   ao486_inst.pipeline_inst.write_inst.write_register_inst.aflag  = value[0];
            "zflag:":                   ao486_inst.pipeline_inst.write_inst.write_register_inst.zflag  = value[0];
            "sflag:":                   ao486_inst.pipeline_inst.write_inst.write_register_inst.sflag  = value[0];
            "tflag:":                   ao486_inst.pipeline_inst.write_inst.write_register_inst.tflag  = value[0];
            "iflag:":                   ao486_inst.pipeline_inst.write_inst.write_register_inst.iflag  = value[0];
            "dflag:":                   ao486_inst.pipeline_inst.write_inst.write_register_inst.dflag  = value[0];
            "oflag:":                   ao486_inst.pipeline_inst.write_inst.write_register_inst.oflag  = value[0];
            "iopl:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.iopl   = value[1:0];
            "ntflag:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.ntflag = value[0];
            "rflag:":                   ao486_inst.pipeline_inst.write_inst.write_register_inst.rflag  = value[0];
            "vmflag:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.vmflag = value[0];
            "acflag:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.acflag = value[0];
            "idflag:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.idflag = value[0];
            
            "cs_cache_valid:":          ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache_valid = value[0];
            "cs:":                      { ao486_inst.pipeline_inst.write_inst.write_register_inst.cs,
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_rpl } = { value[15:0], value[1:0] };
            "cs_rpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_rpl         = value[1:0];
            "cs_base:":                 { ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[63:56],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[39:32],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[31:16] } = value[31:0];
            "cs_limit:":                { ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[51:48],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[15:0]  } = value[19:0];
            "cs_g:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[55]    = value[0];
            "cs_d_b:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[54]    = value[0];
            "cs_avl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[52]    = value[0];
            "cs_p:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[47]    = value[0];
            "cs_dpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[46:45] = value[1:0];
            "cs_s:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[44]    = value[0];
            "cs_type:":                 ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[43:40] = value[3:0];
            
            "ds_cache_valid:":          ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache_valid = value[0];
            "ds:":                      { ao486_inst.pipeline_inst.write_inst.write_register_inst.ds,
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_rpl } = { value[15:0], value[1:0] };
            "ds_rpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_rpl         = value[1:0];
            "ds_base:":                 { ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[63:56],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[39:32],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[31:16] } = value[31:0];
            "ds_limit:":                { ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[51:48],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[15:0]  } = value[19:0];
            "ds_g:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[55]    = value[0];
            "ds_d_b:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[54]    = value[0];
            "ds_avl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[52]    = value[0];
            "ds_p:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[47]    = value[0];
            "ds_dpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[46:45] = value[1:0];
            "ds_s:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[44]    = value[0];
            "ds_type:":                 ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[43:40] = value[3:0];

            "es_cache_valid:":          ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache_valid = value[0];
            "es:":                      { ao486_inst.pipeline_inst.write_inst.write_register_inst.es,
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.es_rpl } = { value[15:0], value[1:0] };
            "es_rpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.es_rpl         = value[1:0];
            "es_base:":                 { ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[63:56],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[39:32],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[31:16] } = value[31:0];
            "es_limit:":                { ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[51:48],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[15:0]  } = value[19:0];
            "es_g:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[55]    = value[0];
            "es_d_b:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[54]    = value[0];
            "es_avl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[52]    = value[0];
            "es_p:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[47]    = value[0];
            "es_dpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[46:45] = value[1:0];
            "es_s:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[44]    = value[0];
            "es_type:":                 ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[43:40] = value[3:0];
            
            "fs_cache_valid:":          ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache_valid = value[0];
            "fs:":                      { ao486_inst.pipeline_inst.write_inst.write_register_inst.fs,
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_rpl } = { value[15:0], value[1:0] };
            "fs_rpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_rpl         = value[1:0];
            "fs_base:":                 { ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[63:56],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[39:32],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[31:16] } = value[31:0];
            "fs_limit:":                { ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[51:48],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[15:0]  } = value[19:0];
            "fs_g:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[55]    = value[0];
            "fs_d_b:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[54]    = value[0];
            "fs_avl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[52]    = value[0];
            "fs_p:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[47]    = value[0];
            "fs_dpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[46:45] = value[1:0];
            "fs_s:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[44]    = value[0];
            "fs_type:":                 ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[43:40] = value[3:0];

            "gs_cache_valid:":          ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache_valid = value[0];
            "gs:":                      { ao486_inst.pipeline_inst.write_inst.write_register_inst.gs,
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_rpl } = { value[15:0], value[1:0] };
            "gs_rpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_rpl         = value[1:0];
            "gs_base:":                 { ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[63:56],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[39:32],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[31:16] } = value[31:0];
            "gs_limit:":                { ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[51:48],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[15:0]  } = value[19:0];
            "gs_g:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[55]    = value[0];
            "gs_d_b:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[54]    = value[0];
            "gs_avl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[52]    = value[0];
            "gs_p:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[47]    = value[0];
            "gs_dpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[46:45] = value[1:0];
            "gs_s:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[44]    = value[0];
            "gs_type:":                 ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[43:40] = value[3:0];
            
            "ss_cache_valid:":          ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache_valid = value[0];
            "ss:":                      { ao486_inst.pipeline_inst.write_inst.write_register_inst.ss,
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_rpl } = { value[15:0], value[1:0] };
            "ss_rpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_rpl         = value[1:0];
            "ss_base:":                 { ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[63:56],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[39:32],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[31:16] } = value[31:0];
            "ss_limit:":                { ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[51:48],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[15:0]  } = value[19:0];
            "ss_g:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[55]    = value[0];
            "ss_d_b:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[54]    = value[0];
            "ss_avl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[52]    = value[0];
            "ss_p:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[47]    = value[0];
            "ss_dpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[46:45] = value[1:0];
            "ss_s:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[44]    = value[0];
            "ss_type:":                 ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[43:40] = value[3:0];
            
            "ldtr_cache_valid:":        ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache_valid = value[0];
            "ldtr:":                    { ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr,
                                        ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_rpl } = { value[15:0], value[1:0] };
            "ldtr_rpl:":                ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_rpl         = value[1:0];
            "ldtr_base:":               { ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[63:56],
                                        ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[39:32],
                                        ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[31:16] } = value[31:0];
            "ldtr_limit:":              { ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[51:48],
                                        ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[15:0]  } = value[19:0];
            "ldtr_g:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[55]    = value[0];
            "ldtr_d_b:":                ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[54]    = value[0];
            "ldtr_avl:":                ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[52]    = value[0];
            "ldtr_p:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[47]    = value[0];
            "ldtr_dpl:":                ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[46:45] = value[1:0];
            "ldtr_s:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[44]    = value[0];
            "ldtr_type:":               ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[43:40] = value[3:0];

            "tr_cache_valid:":          ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache_valid = value[0];
            "tr:":                      { ao486_inst.pipeline_inst.write_inst.write_register_inst.tr,
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_rpl } = { value[15:0], value[1:0] };
            "tr_rpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_rpl         = value[1:0];
            "tr_base:":                 { ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[63:56],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[39:32],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[31:16] } = value[31:0];
            "tr_limit:":                { ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[51:48],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[15:0]  } = value[19:0];
            "tr_g:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[55]    = value[0];
            "tr_d_b:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[54]    = value[0];
            "tr_avl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[52]    = value[0];
            "tr_p:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[47]    = value[0];
            "tr_dpl:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[46:45] = value[1:0];
            "tr_s:":                    ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[44]    = value[0];
            "tr_type:":                 ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[43:40] = value[3:0];

            "gdtr_base:":               ao486_inst.pipeline_inst.write_inst.write_register_inst.gdtr_base  = value[31:0];
            "gdtr_limit:":              ao486_inst.pipeline_inst.write_inst.write_register_inst.gdtr_limit = value[15:0];
            
            "idtr_base:":               ao486_inst.pipeline_inst.write_inst.write_register_inst.idtr_base  = value[31:0];
            "idtr_limit:":              ao486_inst.pipeline_inst.write_inst.write_register_inst.idtr_limit = value[15:0];
            
            "cr0_pe:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_pe = value[0];
            "cr0_mp:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_mp = value[0];
            "cr0_em:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_em = value[0];
            "cr0_ts:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_ts = value[0];
            "cr0_ne:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_ne = value[0];
            "cr0_wp:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_wp = value[0];
            "cr0_am:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_am = value[0];
            "cr0_nw:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_nw = value[0];
            "cr0_cd:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_cd = value[0];
            "cr0_pg:":                  ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_pg = value[0];
            
            "cr2:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.cr2 = value[31:0];
            "cr3:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.cr3 = value[31:0];
            
            "dr0:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.dr0 = value[31:0];
            "dr1:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.dr1 = value[31:0];
            "dr2:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.dr2 = value[31:0];
            "dr3:":                     ao486_inst.pipeline_inst.write_inst.write_register_inst.dr3 = value[31:0];
            
            "dr6:":                     { ao486_inst.pipeline_inst.write_inst.write_register_inst.dr6_bt,
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.dr6_bs,
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.dr6_bd,
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.dr6_b12,
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.dr6_breakpoints } = { value[15:12], value[3:0] };
                                          
            "dr7:":                     { ao486_inst.pipeline_inst.write_inst.write_register_inst.dr7[31:11],
                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.dr7[9:0] } = { value[31:11], value[9:0] };
                                          
            default: begin $display("Unknown name: %s", name); $finish_and_return(-1); end
        endcase
    end 
end
endtask

task output_cpu_state;
begin

    $fwrite(STDOUT, "start_output: %x\n", $time);
    
    $fwrite(STDOUT, "tb_wr_cmd_last: %02x\n", tb_wr_cmd_last);
    $fwrite(STDOUT, "tb_can_ignore:  %x\n",   finished);
    
    $fwrite(STDOUT, "eax: %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.eax);
    $fwrite(STDOUT, "ebx: %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ebx);
    $fwrite(STDOUT, "ecx: %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ecx);
    $fwrite(STDOUT, "edx: %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.edx);
    $fwrite(STDOUT, "esi: %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.esi);
    $fwrite(STDOUT, "edi: %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.edi);
    $fwrite(STDOUT, "ebp: %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ebp);
    $fwrite(STDOUT, "esp: %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.esp);
    
    if(tb_wr_ready_last)    $fwrite(STDOUT, "eip: %08x\n", tb_wr_eip);
    else                    $fwrite(STDOUT, "eip: %08x\n", ao486_inst.exception_inst.exc_eip);
    
    $fwrite(STDOUT, "cflag:  %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cflag);
    $fwrite(STDOUT, "pflag:  %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.pflag);
    $fwrite(STDOUT, "aflag:  %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.aflag);
    $fwrite(STDOUT, "zflag:  %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.zflag);
    $fwrite(STDOUT, "sflag:  %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.sflag);
    $fwrite(STDOUT, "tflag:  %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.tflag);
    $fwrite(STDOUT, "iflag:  %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.iflag);
    $fwrite(STDOUT, "dflag:  %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.dflag);
    $fwrite(STDOUT, "oflag:  %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.oflag);
    $fwrite(STDOUT, "iopl:   %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.iopl);
    $fwrite(STDOUT, "ntflag: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ntflag);
    
    if(tb_wr_ready_last)    $fwrite(STDOUT, "rflag: %01x\n", tb_rflag_last);
    else                    $fwrite(STDOUT, "rflag: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.rflag);
    
    $fwrite(STDOUT, "vmflag: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.vmflag);
    $fwrite(STDOUT, "acflag: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.acflag);
    $fwrite(STDOUT, "idflag: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.idflag);
    
    $fwrite(STDOUT, "cs_cache_valid: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache_valid);
    $fwrite(STDOUT, "cs:             %04x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cs);
    $fwrite(STDOUT, "cs_rpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_rpl);
    $fwrite(STDOUT, "cs_base:        %08x\n", { ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[63:56],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[39:32],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[31:16] });
    $fwrite(STDOUT, "cs_limit:       %08x\n", { 12'd0,
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[51:48],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[15:0] });
    $fwrite(STDOUT, "cs_g:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[55]);
    $fwrite(STDOUT, "cs_d_b:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[54]);
    $fwrite(STDOUT, "cs_avl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[52]);
    $fwrite(STDOUT, "cs_p:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[47]);
    $fwrite(STDOUT, "cs_dpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[46:45]);
    $fwrite(STDOUT, "cs_s:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[44]);
    $fwrite(STDOUT, "cs_type:        %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cs_cache[43:40]);
    
    $fwrite(STDOUT, "ds_cache_valid: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache_valid);
    $fwrite(STDOUT, "ds:             %04x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ds);
    $fwrite(STDOUT, "ds_rpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_rpl);
    $fwrite(STDOUT, "ds_base:        %08x\n", { ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[63:56],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[39:32],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[31:16] });
    $fwrite(STDOUT, "ds_limit:       %08x\n", { 12'd0,
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[51:48],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[15:0] });
    $fwrite(STDOUT, "ds_g:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[55]);
    $fwrite(STDOUT, "ds_d_b:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[54]);
    $fwrite(STDOUT, "ds_avl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[52]);
    $fwrite(STDOUT, "ds_p:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[47]);
    $fwrite(STDOUT, "ds_dpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[46:45]);
    $fwrite(STDOUT, "ds_s:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[44]);
    $fwrite(STDOUT, "ds_type:        %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ds_cache[43:40]);
    
    $fwrite(STDOUT, "es_cache_valid: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache_valid);
    $fwrite(STDOUT, "es:             %04x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.es);
    $fwrite(STDOUT, "es_rpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.es_rpl);
    $fwrite(STDOUT, "es_base:        %08x\n", { ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[63:56],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[39:32],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[31:16] });
    $fwrite(STDOUT, "es_limit:       %08x\n", { 12'd0,
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[51:48],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[15:0] });
    $fwrite(STDOUT, "es_g:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[55]);
    $fwrite(STDOUT, "es_d_b:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[54]);
    $fwrite(STDOUT, "es_avl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[52]);
    $fwrite(STDOUT, "es_p:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[47]);
    $fwrite(STDOUT, "es_dpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[46:45]);
    $fwrite(STDOUT, "es_s:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[44]);
    $fwrite(STDOUT, "es_type:        %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.es_cache[43:40]);
    
    $fwrite(STDOUT, "fs_cache_valid: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache_valid);
    $fwrite(STDOUT, "fs:             %04x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.fs);
    $fwrite(STDOUT, "fs_rpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_rpl);
    $fwrite(STDOUT, "fs_base:        %08x\n", { ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[63:56],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[39:32],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[31:16] });
    $fwrite(STDOUT, "fs_limit:       %08x\n", { 12'd0,
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[51:48],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[15:0] });
    $fwrite(STDOUT, "fs_g:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[55]);
    $fwrite(STDOUT, "fs_d_b:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[54]);
    $fwrite(STDOUT, "fs_avl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[52]);
    $fwrite(STDOUT, "fs_p:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[47]);
    $fwrite(STDOUT, "fs_dpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[46:45]);
    $fwrite(STDOUT, "fs_s:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[44]);
    $fwrite(STDOUT, "fs_type:        %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.fs_cache[43:40]);
    
    $fwrite(STDOUT, "gs_cache_valid: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache_valid);
    $fwrite(STDOUT, "gs:             %04x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.gs);
    $fwrite(STDOUT, "gs_rpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_rpl);
    $fwrite(STDOUT, "gs_base:        %08x\n", { ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[63:56],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[39:32],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[31:16] });
    $fwrite(STDOUT, "gs_limit:       %08x\n", { 12'd0,
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[51:48],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[15:0] });
    $fwrite(STDOUT, "gs_g:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[55]);
    $fwrite(STDOUT, "gs_d_b:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[54]);
    $fwrite(STDOUT, "gs_avl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[52]);
    $fwrite(STDOUT, "gs_p:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[47]);
    $fwrite(STDOUT, "gs_dpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[46:45]);
    $fwrite(STDOUT, "gs_s:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[44]);
    $fwrite(STDOUT, "gs_type:        %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.gs_cache[43:40]);
    
    $fwrite(STDOUT, "ss_cache_valid: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache_valid);
    $fwrite(STDOUT, "ss:             %04x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ss);
    $fwrite(STDOUT, "ss_rpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_rpl);
    $fwrite(STDOUT, "ss_base:        %08x\n", { ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[63:56],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[39:32],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[31:16] });
    $fwrite(STDOUT, "ss_limit:       %08x\n", { 12'd0,
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[51:48],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[15:0] });
    $fwrite(STDOUT, "ss_g:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[55]);
    $fwrite(STDOUT, "ss_d_b:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[54]);
    $fwrite(STDOUT, "ss_avl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[52]);
    $fwrite(STDOUT, "ss_p:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[47]);
    $fwrite(STDOUT, "ss_dpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[46:45]);
    $fwrite(STDOUT, "ss_s:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[44]);
    $fwrite(STDOUT, "ss_type:        %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ss_cache[43:40]);
    
    $fwrite(STDOUT, "ldtr_cache_valid: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache_valid);
    $fwrite(STDOUT, "ldtr:             %04x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr);
    $fwrite(STDOUT, "ldtr_rpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_rpl);
    $fwrite(STDOUT, "ldtr_base:        %08x\n", { ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[63:56],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[39:32],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[31:16] });
    $fwrite(STDOUT, "ldtr_limit:       %08x\n", { 12'd0,
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[51:48],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[15:0] });
    $fwrite(STDOUT, "ldtr_g:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[55]);
    $fwrite(STDOUT, "ldtr_d_b:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[54]);
    $fwrite(STDOUT, "ldtr_avl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[52]);
    $fwrite(STDOUT, "ldtr_p:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[47]);
    $fwrite(STDOUT, "ldtr_dpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[46:45]);
    $fwrite(STDOUT, "ldtr_s:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[44]);
    $fwrite(STDOUT, "ldtr_type:        %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.ldtr_cache[43:40]);
    
    $fwrite(STDOUT, "tr_cache_valid: %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache_valid);
    $fwrite(STDOUT, "tr:             %04x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.tr);
    $fwrite(STDOUT, "tr_rpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_rpl);
    $fwrite(STDOUT, "tr_base:        %08x\n", { ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[63:56],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[39:32],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[31:16] });
    $fwrite(STDOUT, "tr_limit:       %08x\n", { 12'd0,
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[51:48],
                                                ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[15:0] });
    $fwrite(STDOUT, "tr_g:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[55]);
    $fwrite(STDOUT, "tr_d_b:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[54]);
    $fwrite(STDOUT, "tr_avl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[52]);
    $fwrite(STDOUT, "tr_p:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[47]);
    $fwrite(STDOUT, "tr_dpl:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[46:45]);
    $fwrite(STDOUT, "tr_s:           %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[44]);
    $fwrite(STDOUT, "tr_type:        %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.tr_cache[43:40]);
    
    $fwrite(STDOUT, "gdtr_base:      %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.gdtr_base);
    $fwrite(STDOUT, "gdtr_limit:     %04x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.gdtr_limit);
    
    $fwrite(STDOUT, "idtr_base:      %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.idtr_base);
    $fwrite(STDOUT, "idtr_limit:     %04x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.idtr_limit);
   
    $fwrite(STDOUT, "cr0_pe:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_pe);
    $fwrite(STDOUT, "cr0_mp:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_mp);
    $fwrite(STDOUT, "cr0_em:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_em);
    $fwrite(STDOUT, "cr0_ts:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_ts);
    $fwrite(STDOUT, "cr0_ne:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_ne);
    $fwrite(STDOUT, "cr0_wp:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_wp);
    $fwrite(STDOUT, "cr0_am:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_am);
    $fwrite(STDOUT, "cr0_nw:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_nw);
    $fwrite(STDOUT, "cr0_cd:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_cd);
    $fwrite(STDOUT, "cr0_pg:         %01x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cr0_pg);
    
    $fwrite(STDOUT, "cr2:            %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cr2);
    $fwrite(STDOUT, "cr3:            %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.cr3);
    
    $fwrite(STDOUT, "dr0:            %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.dr0);
    $fwrite(STDOUT, "dr1:            %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.dr1);
    $fwrite(STDOUT, "dr2:            %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.dr2);
    $fwrite(STDOUT, "dr3:            %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.dr3);
    
    $fwrite(STDOUT, "dr6:            ffff%01xff%01x\n", { ao486_inst.pipeline_inst.write_inst.write_register_inst.dr6_bt,
                                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.dr6_bs,
                                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.dr6_bd,
                                                          ao486_inst.pipeline_inst.write_inst.write_register_inst.dr6_b12 },
                                                        ao486_inst.pipeline_inst.write_inst.write_register_inst.dr6_breakpoints);
    $fwrite(STDOUT, "dr7:            %08x\n", ao486_inst.pipeline_inst.write_inst.write_register_inst.dr7);
    
    $fwrite(STDOUT, "\n");
    $fflush(STDOUT);
end
endtask

parameter STDIN  = 32'h8000_0000;
parameter STDOUT = 32'h8000_0001;

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

reg [255:0] dumpfile_name;
initial begin
    if( $value$plusargs("dumpfile=%s", dumpfile_name) == 0 ) begin
        dumpfile_name = "default.vcd";
    end
    
    $dumpfile(dumpfile_name);
    $dumpvars(0);
    $dumpon();
    
    $display("START");
    
    //--------------------------------------------------------------------------
    
    rst_n = 1'b0;
    #10 rst_n = 1'b1;
    
    initialize();
    output_cpu_state();
    
    while(finished == 0) begin
        if($time > 18000) $finish_and_return(-1);
        #10;
        
        $dumpflush();
    end
    
    #60;
    
    $dumpoff();
    $finish_and_return(0);
end

//------------------------------------------------------------------------------

reg tb_procedure_exception_delay;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   tb_procedure_exception_delay <= `FALSE;
    else                tb_procedure_exception_delay <= ao486_inst.exception_inst.exc_load && ao486_inst.exception_inst.interrupt_load == `FALSE;
end

reg tb_procedure_interrupt_delay;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   tb_procedure_interrupt_delay <= `FALSE;
    else                tb_procedure_interrupt_delay <= ao486_inst.exception_inst.interrupt_done;
end

//------------------------------------------------------------------------------

integer processing_exception_interrupt = 0;

integer finished = 0;
always @(posedge clk) begin
    if(finished == 0) begin
        if(tb_procedure_interrupt_delay) begin
            $fwrite(STDOUT, "start_interrupt: %x\n", $time);
            $fwrite(STDOUT, "vector: %02x\n", ao486_inst.exception_inst.exc_vector);
            
            $fwrite(STDOUT, "\n");
            $fflush(STDOUT);
        
            output_cpu_state();
            processing_exception_interrupt = 1;
            if(test_type == 0) finished = 1;
            
            instruction_count = instruction_count + 1;
            if(test_type > 0 && instruction_count == test_type) finished = 1;
        end
        else if(tb_procedure_exception_delay) begin
            $fwrite(STDOUT, "start_exception: %x\n", $time);
            $fwrite(STDOUT, "vector:     %02x\n",   ao486_inst.exception_inst.exc_vector);
            $fwrite(STDOUT, "push_error: %01x\n",   ao486_inst.exception_inst.exc_push_error);
            $fwrite(STDOUT, "error_code: %04x\n",   ao486_inst.exception_inst.exc_error_code);
            
            $fwrite(STDOUT, "\n");
            $fflush(STDOUT);
        
            output_cpu_state();
            processing_exception_interrupt = 1;
            if(test_type == 0) finished = 1;
            
            instruction_count = instruction_count + 1;
            if(test_type > 0 && instruction_count == test_type) finished = 1;
        end
        else if(ao486_inst.exception_inst.shutdown) begin
            $fwrite(STDOUT, "start_shutdown: %d\n", $time);
            
            $fwrite(STDOUT, "\n");
            $fflush(STDOUT);
            
            finished = 1;
        end
        else if(ao486_inst.pipeline_inst.decode_inst.dec_consumed > 4'd0) begin
            $fwrite(STDOUT, "#start_decoded: %d\n", $time);
            $fwrite(STDOUT, "#decoded_rep: %x\n",
                        (ao486_inst.pipeline_inst.decode_inst.dec_prefix_group_1_rep == 2'd0)?  2'd0 :
                        (ao486_inst.pipeline_inst.decode_inst.dec_prefix_group_1_rep == 2'd1)?  2'd2 :
                        (ao486_inst.pipeline_inst.decode_inst.dec_prefix_group_1_rep == 2'd2)?  2'd3 :
                                                                                                2'd0);

            $fwrite(STDOUT, "#decoded_seg:      %x\n", ao486_inst.pipeline_inst.decode_inst.dec_prefix_group_2_seg);
            $fwrite(STDOUT, "#decoded_lock:     %x\n", ao486_inst.pipeline_inst.decode_inst.dec_prefix_group_1_lock);
            $fwrite(STDOUT, "#decoded_os32:     %x\n", ao486_inst.pipeline_inst.decode_inst.dec_operand_32bit);
            $fwrite(STDOUT, "#decoded_as32:     %x\n", ao486_inst.pipeline_inst.decode_inst.dec_address_32bit);
            $fwrite(STDOUT, "#decoded_consumed: %x\n", ao486_inst.pipeline_inst.decode_inst.dec_consumed);
            $fwrite(STDOUT, "\n");
            $fflush(STDOUT);
        end
    end
end
 
reg         tb_wr_ready_last;
reg [31:0]  tb_wr_eip;
reg         tb_rflag_last;
reg [6:0]   tb_wr_cmd_last = 7'h7F;

wire tb_wr_finished = ao486_inst.pipeline_inst.write_inst.wr_finished ||
                      (ao486_inst.pipeline_inst.write_inst.wr_ready && ao486_inst.pipeline_inst.write_inst.wr_hlt_in_progress);

always @(posedge clk) begin
    if(tb_wr_finished) begin
        tb_wr_ready_last    <= 1'b1;
        
        tb_wr_eip           <= ao486_inst.pipeline_inst.write_inst.wr_eip;
        tb_wr_cmd_last      <= ao486_inst.pipeline_inst.write_inst.wr_cmd;
        
        //(ao486_inst.pipeline_inst.write_inst.wr_clear_rflag)? ignored
        tb_rflag_last       <= ao486_inst.pipeline_inst.write_inst.rflag_to_reg;
    end
    else begin
        tb_wr_ready_last   <= 1'b0;
    end
    
    if(tb_wr_finished) begin
        
        if(processing_exception_interrupt == 0) begin
            if(test_type == 0 || instruction_count < (test_type-1) || (instruction_count == (test_type-1) && ~(tb_wr_ready_last))) begin
                $fwrite(STDOUT, "start_completed: %d\n", $time);
                $fwrite(STDOUT, "rep: %x\n",
                            (ao486_inst.pipeline_inst.write_inst.wr_prefix_group_1_rep == 2'd0)?   2'd0 :
                            (ao486_inst.pipeline_inst.write_inst.wr_prefix_group_1_rep == 2'd1)?   2'd2 :
                            (ao486_inst.pipeline_inst.write_inst.wr_prefix_group_1_rep == 2'd2)?   2'd3 :
                                                                                                   2'd0);
                        
                $fwrite(STDOUT, "seg:      ff\n");
                $fwrite(STDOUT, "lock:     %x\n", ao486_inst.pipeline_inst.write_inst.wr_prefix_group_1_lock);
                $fwrite(STDOUT, "os32:     %x\n", ao486_inst.pipeline_inst.write_inst.wr_operand_32bit);
                $fwrite(STDOUT, "as32:     %x\n", ao486_inst.pipeline_inst.write_inst.wr_address_32bit);
                $fwrite(STDOUT, "consumed: %x\n", ao486_inst.pipeline_inst.write_inst.wr_consumed);
                $fwrite(STDOUT, "\n");
                $fflush(STDOUT);
            end
        end
    end
end

integer instruction_count = 0;

always @(posedge clk) begin
    if(tb_wr_ready_last) begin
        if(processing_exception_interrupt == 0) begin
            output_cpu_state();
        
           instruction_count = instruction_count + 1;
           if(test_type > 0 && instruction_count == test_type) finished = 1;
           
           //if(test_type == 0 && ao486_inst.pipeline_inst.write_inst.wr_hlt_in_progress) finished = 1;
        end
        else begin
            processing_exception_interrupt = 0;
        end
    end
end

//------------------------------------------------------------------------------ interrupt

integer interrupt_fscanf;
reg     [8:0] interrupt_fscanf_reg;
initial begin
    interrupt_do        = 1'b0;
    interrupt_vector    = 8'd0;

    #27;
    
    forever begin
        if(tb_wr_finished) begin

            if(processing_exception_interrupt == 0) begin
                $fwrite(STDOUT, "start_check_interrupt: %x\n", $time);
                $fwrite(STDOUT, "\n");
                $fflush(STDOUT);
            
                interrupt_fscanf = $fscanf(STDIN, "%x", interrupt_fscanf_reg);
                interrupt_vector = interrupt_fscanf_reg[7:0];
                interrupt_do     = ~(interrupt_fscanf_reg[8]);
            end
        end
        #10;
    end
end

always @(posedge clk) begin
    if(interrupt_done) begin
        interrupt_vector = 8'd0;
        interrupt_do     = `FALSE;
    end
end

//------------------------------------------------------------------------------ avalon memory and io

initial begin
    avm_waitrequest   <= `FALSE;
    avm_readdatavalid <= `FALSE;
    
    avalon_io_waitrequest   <= `FALSE;
    avalon_io_readdatavalid <= `FALSE;
    
    avm_readdata       <= 32'd0;
    avalon_io_readdata <= 32'd0;
end

reg [2:0]  write_burst_count = 3'd0;
reg [31:0] write_burst_address;
always @(posedge clk) begin
    if(avm_write && avm_burstcount > 3'd1 && write_burst_count == 3'd0) begin
        write_burst_count   <= avm_burstcount - 3'd1;
        write_burst_address <= avm_address + 3'd4;
    end
    else if(write_burst_count > 3'd0) begin
        write_burst_count   <= write_burst_count - 3'd1;
        write_burst_address <= write_burst_address + 3'd4;
    end
end

integer write_i;
reg [31:0] write_val;
always @(posedge clk) begin
    if(avm_write) begin
        $fwrite(STDOUT, "start_write:  %x\n",   $time);
        $fwrite(STDOUT, "address:      %08x\n", (write_burst_count > 3'd0)? write_burst_address : avm_address);
        $fwrite(STDOUT, "data:         %08x\n", avm_writedata);
        $fwrite(STDOUT, "byteena:      %01x\n", avm_byteenable);
        $fwrite(STDOUT, "can_ignore:   %x\n",   finished);
    
        $fwrite(STDOUT, "\n");
        $fflush(STDOUT);
    end
end

integer io_write_i;
reg [31:0] io_write_val;
always @(posedge clk) begin
    if(avalon_io_write || ((ao486_inst.avalon_io_inst.state == 3'd1 || ao486_inst.avalon_io_inst.state == 3'd2) && ao486_inst.avalon_io_inst.address_out_of_bounds)) begin
        $fwrite(STDOUT, "start_io_write: %x\n",   $time);
        $fwrite(STDOUT, "address:        %04x\n", avalon_io_address);
        $fwrite(STDOUT, "data:           %08x\n", avalon_io_writedata);
        $fwrite(STDOUT, "byteena:        %01x\n", avalon_io_byteenable);
        $fwrite(STDOUT, "can_ignore:     %x\n",   finished);
    
        $fwrite(STDOUT, "\n");
        $fflush(STDOUT);
    end
end

reg [2:0]  read_burst_count = 3'd0;
reg [31:0] read_burst_address;
always @(posedge clk) begin
    if(avm_read && avm_burstcount > 3'd1 && read_burst_count == 3'd0) begin
        read_burst_count   <= avm_burstcount - 3'd1;
        read_burst_address <= avm_address + 3'd4;
    end
    else if(read_burst_count > 3'd0) begin
        read_burst_count   <= read_burst_count - 3'd1;
        read_burst_address <= read_burst_address + 3'd4;
    end
end

integer fscanf_avm_ret;
always @(posedge clk) begin
    if((avm_read || read_burst_count > 3'd0) && ao486_inst.memory_inst.avalon_mem_inst.state == 2'd3) begin
        
        $fwrite(STDOUT, "start_read_code: %x\n",   $time);
        $fwrite(STDOUT, "address:         %08x\n", (read_burst_count > 3'd0)? read_burst_address : avm_address);
        $fwrite(STDOUT, "byteena:         %01x\n", avm_byteenable);
        
        $fwrite(STDOUT, "\n");
        $fflush(STDOUT);
        
        fscanf_avm_ret= $fscanf(STDIN, "%x", avm_readdata);
    
        avm_readdatavalid <= `TRUE;
    end
    else if(avm_read || read_burst_count > 3'd0) begin
        
        if(ao486_inst.memory_inst.read_do && ao486_inst.memory_inst.memory_read_inst.reset_waiting == `FALSE) begin
            $fwrite(STDOUT, "start_read: %x\n",   $time);
            $fwrite(STDOUT, "address:    %08x\n", (read_burst_count > 3'd0)? read_burst_address : avm_address);
            $fwrite(STDOUT, "byteena:    %01x\n", avm_byteenable);
            $fwrite(STDOUT, "can_ignore: %01x\n", finished);
        
            $fwrite(STDOUT, "\n");
            $fflush(STDOUT);
            
            fscanf_avm_ret= $fscanf(STDIN, "%x", avm_readdata);
        end
        
        avm_readdatavalid <= `TRUE;
    end
    else begin
        avm_readdatavalid <= `FALSE;
    end
end

reg avalon_io_read_delayed;
always @(posedge clk) begin
    avalon_io_read_delayed <= avalon_io_read;
end

integer fscanf_io_ret;
always @(posedge clk) begin
    if(avalon_io_read_delayed || ((ao486_inst.avalon_io_inst.state == 3'd3 || ao486_inst.avalon_io_inst.state == 3'd4) && ao486_inst.avalon_io_inst.address_out_of_bounds)) begin
        
        $fwrite(STDOUT, "start_io_read: %x\n",   $time);
        $fwrite(STDOUT, "address:       %04x\n", avalon_io_address);
        $fwrite(STDOUT, "byteena:       %01x\n", avalon_io_byteenable);
        $fwrite(STDOUT, "can_ignore:    %x\n",   finished);
    
        $fwrite(STDOUT, "\n");
        $fflush(STDOUT);
        
        fscanf_io_ret= $fscanf(STDIN, "%x", avalon_io_readdata);
    
        if(avalon_io_read_delayed) avalon_io_readdatavalid <= `TRUE;
    end
    else begin
        avalon_io_readdatavalid <= `FALSE;
    end
end

endmodule
