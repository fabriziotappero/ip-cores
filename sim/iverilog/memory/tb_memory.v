`timescale 1ps/1ps

module tb_memory();

reg             clk;
reg             rst_n;

//REQ:
reg             read_do;
wire            read_done;
wire            read_page_fault;
wire            read_ac_fault;

reg  [1:0]      read_cpl;
reg  [31:0]     read_address;
reg  [3:0]      read_length;
reg             read_lock;
reg             read_rmw;
wire [63:0]     read_data;
//END

//REQ:
reg             write_do;
wire            write_done;
wire            write_page_fault;
wire            write_ac_fault;

reg  [1:0]      write_cpl;
reg  [31:0]     write_address;
reg  [2:0]      write_length;
reg             write_lock;
reg             write_rmw;
reg  [31:0]     write_data;
//END

//REQ:
reg             tlbcheck_do;
wire            tlbcheck_done;
wire            tlbcheck_page_fault;

reg  [31:0]     tlbcheck_address;
reg             tlbcheck_rw;
//END

//RESP:
reg             tlbflushsingle_do;
wire            tlbflushsingle_done;

reg   [31:0]    tlbflushsingle_address;
//END

//RESP:
reg             tlbflushall_do;
//END

//RESP:
reg             invdcode_do;
wire            invdcode_done;
//END

//RESP:
reg             invddata_do;
wire            invddata_done;
//END

//RESP:
reg             wbinvddata_do;
wire            wbinvddata_done;
//END

// prefetch exported
reg [1:0]       prefetch_cpl;
reg [31:0]      prefetch_eip;
reg [63:0]      cs_cache;

// tlb exported
reg             cr0_pg;
reg             cr0_wp;
reg             cr0_am;
reg             cr0_cd;
reg             cr0_nw;

reg             acflag;

reg   [31:0]    cr3;

// prefetch_fifo exported
reg             prefetchfifo_accept_do;
wire [67:0]     prefetchfifo_accept_data;
wire            prefetchfifo_accept_empty;

reg             pipeline_after_read_empty;
reg             pipeline_after_prefetch_empty;

wire [15:0]     tlb_code_pf_error_code;
wire [15:0]     tlb_check_pf_error_code;
wire [15:0]     tlb_write_pf_error_code;
wire [15:0]     tlb_read_pf_error_code;

wire [31:0]     tlb_code_pf_cr2;
wire [31:0]     tlb_check_pf_cr2;
wire [31:0]     tlb_write_pf_cr2;
wire [31:0]     tlb_read_pf_cr2;

// reset exported
reg             pr_reset;
reg             rd_reset;
reg             exe_reset;
reg             wr_reset;

// avalon master
wire  [31:0]    avm_address;
wire  [31:0]    avm_writedata;
wire  [3:0]     avm_byteenable;
wire  [2:0]     avm_burstcount;
wire            avm_write;
wire            avm_read;

reg             avm_waitrequest;
reg             avm_readdatavalid;
reg   [31:0]    avm_readdata;

memory memory_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    //REQ:
    .read_do                       (read_do),                       //input
    .read_done                     (read_done),                     //output
    .read_page_fault               (read_page_fault),               //output
    .read_ac_fault                 (read_ac_fault),                 //output
    
    .read_cpl                      (read_cpl),                      //input [1:0]
    .read_address                  (read_address),                  //input [31:0]
    .read_length                   (read_length),                   //input [3:0]
    .read_lock                     (read_lock),                     //input
    .read_rmw                      (read_rmw),                      //input
    .read_data                     (read_data),                     //output [63:0]
    //END
    
    //REQ:
    .write_do                      (write_do),                      //input
    .write_done                    (write_done),                    //output
    .write_page_fault              (write_page_fault),              //output
    .write_ac_fault                (write_ac_fault),                //output
    
    .write_cpl                     (write_cpl),                     //input [1:0]
    .write_address                 (write_address),                 //input [31:0]
    .write_length                  (write_length),                  //input [2:0]
    .write_lock                    (write_lock),                    //input
    .write_rmw                     (write_rmw),                     //input
    .write_data                    (write_data),                    //input [31:0]
    //END
    
    //REQ:
    .tlbcheck_do                   (tlbcheck_do),                   //input
    .tlbcheck_done                 (tlbcheck_done),                 //output
    .tlbcheck_page_fault           (tlbcheck_page_fault),           //output
    
    .tlbcheck_address              (tlbcheck_address),              //input [31:0]
    .tlbcheck_rw                   (tlbcheck_rw),                   //input
    //END
    
    //RESP:
    .tlbflushsingle_do             (tlbflushsingle_do),             //input
    .tlbflushsingle_done           (tlbflushsingle_done),           //output
    .tlbflushsingle_address        (tlbflushsingle_address),        //input [31:0]
    //END
    
    .tlbflushall_do                (tlbflushall_do),                //input
    
    .invdcode_do                   (invdcode_do),                   //input
    .invdcode_done                 (invdcode_done),                 //output
    
    .invddata_do                   (invddata_do),                   //input
    .invddata_done                 (invddata_done),                 //output
    
    .wbinvddata_do                 (wbinvddata_do),                 //input
    .wbinvddata_done               (wbinvddata_done),               //output
    
    // prefetch exported
    .prefetch_cpl                  (prefetch_cpl),                  //input [1:0]
    .prefetch_eip                  (prefetch_eip),                  //input [31:0]
    .cs_cache                      (cs_cache),                      //input [63:0]
//---    
    .cr0_pg                        (cr0_pg),                        //input
    .cr0_wp                        (cr0_wp),                        //input
    .cr0_am                        (cr0_am),                        //input
    .cr0_cd                        (cr0_cd),                        //input
    .cr0_nw                        (cr0_nw),                        //input
    
    .acflag                        (acflag),                        //input
    
    .cr3                           (cr3),                           //input [31:0]
    
    // prefetch_fifo exported
    .prefetchfifo_accept_do        (prefetchfifo_accept_do),        //input
    .prefetchfifo_accept_data      (prefetchfifo_accept_data),      //output [67:0]
    .prefetchfifo_accept_empty     (prefetchfifo_accept_empty),     //output
    
    // pipeline state
    .pipeline_after_read_empty     (pipeline_after_read_empty),     //input
    .pipeline_after_prefetch_empty (pipeline_after_prefetch_empty), //input
    
    .tlb_code_pf_error_code        (tlb_code_pf_error_code),        //output [15:0]
    .tlb_check_pf_error_code       (tlb_check_pf_error_code),       //output [15:0]
    .tlb_write_pf_error_code       (tlb_write_pf_error_code),       //output [15:0]
    .tlb_read_pf_error_code        (tlb_read_pf_error_code),        //output [15:0]
    
    .tlb_code_pf_cr2               (tlb_code_pf_cr2),               //output [31:0]
    .tlb_check_pf_cr2              (tlb_check_pf_cr2),              //output [31:0]
    .tlb_write_pf_cr2              (tlb_write_pf_cr2),              //output [31:0]
    .tlb_read_pf_cr2               (tlb_read_pf_cr2),               //output [31:0]
                   
    // reset exported
    .pr_reset                      (pr_reset),                      //input
    .rd_reset                      (rd_reset),                      //input
    .exe_reset                     (exe_reset),                     //input
    .wr_reset                      (wr_reset),                      //input
    
    // avalon master
    .avm_address                   (avm_address),                   //output [31:0]
    .avm_writedata                 (avm_writedata),                 //output [31:0]
    .avm_byteenable                (avm_byteenable),                //output [3:0]
    .avm_burstcount                (avm_burstcount),                //output [2:0]
    .avm_write                     (avm_write),                     //output
    .avm_read                      (avm_read),                      //output
    .avm_waitrequest               (avm_waitrequest),               //input
    .avm_readdatavalid             (avm_readdatavalid),             //input
    .avm_readdata                  (avm_readdata)                   //input [31:0]
);


integer     fscanf_ret;

reg [255:0]  name;
reg [63:0]   value;

integer do_loop;

task input_state;
begin
    $fwrite(STDOUT, "request:", $time, "\n");
    $fflush(STDOUT);
    
    do_loop = 1;
    
    while(do_loop == 1) begin
    
        fscanf_ret = $fscanf(STDIN, "%s", name);
        fscanf_ret = $fscanf(STDIN, "%x", value);
        
        case(name)
            "quit:":     begin $dumpoff(); $finish_and_return(0); end
            "continue:": do_loop = 0;
            
            "rst_n:":                   rst_n           = value[0];
            
            "read_do:":                 read_do         = value[0];
            "read_cpl:":                read_cpl        = value[1:0];  //2
            "read_address:":            read_address    = value[31:0]; //32
            "read_length:":             read_length     = value[3:0];  //4
            "read_lock:":               read_lock       = value[0];
            "read_rmw:":                read_rmw        = value[0];
            
            "write_do:":                write_do        = value[0];
            "write_cpl:":               write_cpl       = value[1:0];  //2
            "write_address:":           write_address   = value[31:0]; //32
            "write_length:":            write_length    = value[2:0];  //3
            "write_lock:":              write_lock      = value[0];
            "write_rmw:":               write_rmw       = value[0];
            "write_data:":              write_data      = value[31:0]; //32
            
            "tlbcheck_do:":             tlbcheck_do     = value[0];
            "tlbcheck_address:":        tlbcheck_address= value[31:0]; //32
            "tlbcheck_rw:":             tlbcheck_rw     = value[0];
            
            "tlbflushsingle_do:":       tlbflushsingle_do      = value[0];
            "tlbflushsingle_address:":  tlbflushsingle_address = value[31:0]; //32
            
            "tlbflushall_do:":          tlbflushall_do  = value[0];
            "invdcode_do:":             invdcode_do     = value[0];
            "invddata_do:":             invddata_do     = value[0];
            "wbinvddata_do:":           wbinvddata_do   = value[0];
            
            "prefetch_cpl:":            prefetch_cpl    = value[1:0]; //2
            "prefetch_eip:":            prefetch_eip    = value[31:0]; //32
            "cs_cache:":                cs_cache        = value[63:0]; //64
            
            "prefetchfifo_accept_do:": prefetchfifo_accept_do = value[0];
            
            "cr0_pg:":                  cr0_pg = value[0];
            "cr0_wp:":                  cr0_wp = value[0];
            "cr0_am:":                  cr0_am = value[0];
            "cr0_cd:":                  cr0_cd = value[0];
            "cr0_nw:":                  cr0_nw = value[0];
            
            "acflag:":                  acflag = value[0];
            
            "cr3:":                     cr3    = value[31:0]; //32
            
            "pipeline_after_read_empty:":     pipeline_after_read_empty     = value[0];
            "pipeline_after_prefetch_empty:": pipeline_after_prefetch_empty = value[0];
            
            "pr_reset:":                pr_reset  = value[0];
            "rd_reset:":                rd_reset  = value[0];
            "exe_reset:":               exe_reset = value[0];
            "wr_reset:":                wr_reset  = value[0];
            
            "avm_waitrequest:":         avm_waitrequest   = value[0];
            "avm_readdatavalid:":       avm_readdatavalid = value[0];
            "avm_readdata:":            avm_readdata      = value[31:0]; //32
            
            default: begin $display("Unknown name: %s", name); $finish_and_return(-1); end
        endcase
    end 
end
endtask
//46

task output_state;
begin
    $fwrite(STDOUT, "time:", $time, "\n");
    
    $fwrite(STDOUT, "read_done:        %x\n", read_done);
    $fwrite(STDOUT, "read_page_fault:  %x\n", read_page_fault);
    $fwrite(STDOUT, "read_ac_fault:    %x\n", read_ac_fault);
    $fwrite(STDOUT, "read_data:        %x\n", read_data); //64

    $fwrite(STDOUT, "write_done:       %x\n", write_done);
    $fwrite(STDOUT, "write_page_fault: %x\n", write_page_fault);
    $fwrite(STDOUT, "write_ac_fault:   %x\n", write_ac_fault);

    $fwrite(STDOUT, "tlbcheck_done:       %x\n", tlbcheck_done);
    $fwrite(STDOUT, "tlbcheck_page_fault: %x\n", tlbcheck_page_fault);

    $fwrite(STDOUT, "tlbflushsingle_done: %x\n", tlbflushsingle_done);

    $fwrite(STDOUT, "invdcode_done:   %x\n", invdcode_done);
    $fwrite(STDOUT, "invddata_done:   %x\n", invddata_done);

    $fwrite(STDOUT, "wbinvddata_done: %x\n", wbinvddata_done);

    $fwrite(STDOUT, "prefetchfifo_accept_data:  %x\n", (prefetchfifo_accept_empty)? 68'd0 : prefetchfifo_accept_data); //68
    $fwrite(STDOUT, "prefetchfifo_accept_empty: %x\n", prefetchfifo_accept_empty);

    $fwrite(STDOUT, "tlb_code_pf_cr2:         %x\n", tlb_code_pf_cr2); //32
    $fwrite(STDOUT, "tlb_code_pf_error_code:  %x\n", tlb_code_pf_error_code); //16

    $fwrite(STDOUT, "tlb_check_pf_cr2:        %x\n", tlb_check_pf_cr2); //32
    $fwrite(STDOUT, "tlb_check_pf_error_code: %x\n", tlb_check_pf_error_code); //16

    $fwrite(STDOUT, "tlb_write_pf_cr2:        %x\n", tlb_write_pf_cr2); //32
    $fwrite(STDOUT, "tlb_write_pf_error_code: %x\n", tlb_write_pf_error_code); //16
        
    $fwrite(STDOUT, "tlb_read_pf_cr2:         %x\n", tlb_read_pf_cr2); //32
    $fwrite(STDOUT, "tlb_read_pf_error_code:  %x\n", tlb_read_pf_error_code); //16

    $fwrite(STDOUT, "avm_address:    %x\n", avm_address);    //32
    $fwrite(STDOUT, "avm_writedata:  %x\n", avm_writedata);  //32
    $fwrite(STDOUT, "avm_byteenable: %x\n", avm_byteenable); //4
    $fwrite(STDOUT, "avm_burstcount: %x\n", avm_burstcount); //3
    $fwrite(STDOUT, "avm_write:      %x\n", avm_write);
    $fwrite(STDOUT, "avm_read:       %x\n", avm_read);

    $fwrite(STDOUT, "\n");
    $fflush(STDOUT);
end
endtask
//30

parameter STDIN  = 32'h8000_0000;
parameter STDOUT = 32'h8000_0001;

`define FALSE 1'b0
`define TRUE  1'b1

/*
wire  [31:0]    avm_address;
wire  [31:0]    avm_writedata;
wire  [3:0]     avm_byteenable;
wire  [2:0]     avm_burstcount;
wire            avm_write;
wire            avm_read;

reg             avm_waitrequest;
reg             avm_readdatavalid;
reg   [31:0]    avm_readdata;
*/

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
    
    clk = 1'b0;
    
    forever begin
        if(clk == 1'b0) input_state();
        
        #5 clk = ~clk;
                
        $dumpflush();
                
        if(clk == 1'b1) output_state();
        
        //$display("clk: ", clk, " time: ", $time);
        
    end
end

endmodule
