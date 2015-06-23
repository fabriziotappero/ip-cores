`timescale 1ps/1ps

`include "defines.v"

module tb_ao486_run();

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

ao486 ao486_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    .rst_internal_n     (rst_n),
    
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
    .avalon_io_readdata         (avalon_io_readdata)        //input [31:0]
);

parameter STDIN  = 32'h8000_0000;
parameter STDOUT = 32'h8000_0001;

integer finished = 0;

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
    
    while(finished == 0) begin
        if($time > 16000) $finish_and_return(-1);
        #10;
        
        $dumpflush();
    end
    
    #60;
    
    $dumpoff();
    $finish_and_return(0);
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
    if(avalon_io_write) begin
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
always @(posedge clk) begin avalon_io_read_delayed <= avalon_io_read; end

integer fscanf_io_ret;
always @(posedge clk) begin
    if(avalon_io_read_delayed) begin
        
        $fwrite(STDOUT, "start_io_read: %x\n",   $time);
        $fwrite(STDOUT, "address:       %04x\n", avalon_io_address);
        $fwrite(STDOUT, "byteena:       %01x\n", avalon_io_byteenable);
        $fwrite(STDOUT, "can_ignore:    %x\n",   finished);
    
        $fwrite(STDOUT, "\n");
        $fflush(STDOUT);
        
        fscanf_io_ret= $fscanf(STDIN, "%x", avalon_io_readdata);
    
        avalon_io_readdatavalid <= `TRUE;
    end
    else begin
        avalon_io_readdatavalid <= `FALSE;
    end
end

endmodule
