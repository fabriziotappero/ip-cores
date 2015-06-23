
`timescale 1 ps / 1 ps

module tb_floppy();

reg clk;
reg rst_n;

wire        dma_floppy_req;
reg         dma_floppy_ack                  = 1'b0;
reg         dma_floppy_terminal             = 1'b0;
reg  [7:0]  dma_floppy_readdata             = 8'd0;
wire [7:0]  dma_floppy_writedata;

//irq
wire        interrupt;

//avalon slave
reg  [2:0]  io_address                      = 3'd0;
reg         io_read                         = 1'b0;
wire [7:0]  io_readdata;
reg         io_write                        = 1'b0;
reg  [7:0]  io_writedata                    = 8'd0;

//ide shared port 0x3F6
wire       ide_3f6_read;
reg  [7:0] ide_3f6_readdata                 = 8'd0;
wire       ide_3f6_write;
wire [7:0] ide_3f6_writedata;

//master to control sd
wire [31:0] sd_master_address;
reg         sd_master_waitrequest           = 1'b0;
wire        sd_master_read;
reg         sd_master_readdatavalid         = 1'b0;
reg  [31:0] sd_master_readdata              = 32'd0;
wire        sd_master_write;
wire [31:0] sd_master_writedata;

//slave for sd
reg  [8:0]  sd_slave_address                = 9'd0;
reg         sd_slave_read                   = 1'b0;
wire [7:0]  sd_slave_readdata;
reg         sd_slave_write                  = 1'b0;
reg  [7:0]  sd_slave_writedata              = 8'd0;

//slave for management
reg  [3:0]  mgmt_address                    = 4'd0;
reg         mgmt_read                       = 1'b0;
wire [31:0] mgmt_readdata;
reg         mgmt_write                      = 1'b0;
reg  [31:0] mgmt_writedata                  = 32'd0;


floppy floppy_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //dma
    .dma_floppy_req             (dma_floppy_req),         //output
    .dma_floppy_ack             (dma_floppy_ack),         //input
    .dma_floppy_terminal        (dma_floppy_terminal),    //input
    .dma_floppy_readdata        (dma_floppy_readdata),    //input [7:0]
    .dma_floppy_writedata       (dma_floppy_writedata),   //output [7:0]
    
    //irq
    .interrupt                  (interrupt),              //output
    
    //avalon slave
    .io_address                 (io_address),     //input [2:0]
    .io_read                    (io_read),        //input
    .io_readdata                (io_readdata),    //output [7:0]
    .io_write                   (io_write),       //input
    .io_writedata               (io_writedata),   //input [7:0]
    
    //ide shared port 0x3F6
    .ide_3f6_read               (ide_3f6_read),           //output
    .ide_3f6_readdata           (ide_3f6_readdata),       //input [7:0]
    .ide_3f6_write              (ide_3f6_write),          //output
    .ide_3f6_writedata          (ide_3f6_writedata),      //output [7:0]
    
    //master to control sd
    .sd_master_address          (sd_master_address),          //output [31:0]
    .sd_master_waitrequest      (sd_master_waitrequest),      //input
    .sd_master_read             (sd_master_read),             //output
    .sd_master_readdatavalid    (sd_master_readdatavalid),    //input
    .sd_master_readdata         (sd_master_readdata),         //input [31:0]
    .sd_master_write            (sd_master_write),            //output
    .sd_master_writedata        (sd_master_writedata),        //output [31:0]
    
    //slave for sd
    .sd_slave_address           (sd_slave_address),           //input [8:0]
    .sd_slave_read              (sd_slave_read),              //input
    .sd_slave_readdata          (sd_slave_readdata),          //output [7:0]
    .sd_slave_write             (sd_slave_write),             //input
    .sd_slave_writedata         (sd_slave_writedata),         //input [7:0]
    
    //slave for management
    .mgmt_address               (mgmt_address),           //input [3:0]
    .mgmt_read                  (mgmt_read),              //input
    .mgmt_readdata              (mgmt_readdata),          //output [31:0]
    .mgmt_write                 (mgmt_write),             //input
    .mgmt_writedata             (mgmt_writedata)          //input [31:0]
);


initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

`define WRITE_MGMT(addr, data)  \
    mgmt_write        = 1'b1;   \
    mgmt_address      = addr;   \
    mgmt_writedata    = data;   \
    #10;                        \
    mgmt_write        = 1'b0;

`define WRITE_IO(addr, data)  \
    io_write        = 1'b1;   \
    io_address      = addr;   \
    io_writedata    = data;   \
    #10;                      \
    io_write        = 1'b0;
    
`define READ_IO(addr)        \
    io_read         = 1'b1;  \
    io_address      = addr;  \
    #10;                     \
    io_read         = 1'b0;
    
//------------------------------------------------------------------------------ read data
/*
integer read_count = 0;
    
always @(posedge clk) begin
    if(sd_master_address == 32'd4 && sd_master_read) begin
        sd_master_readdatavalid <= 1'b1;
        sd_master_readdata <= 3'd1;
    end
    else if(sd_master_address == 32'd12 && sd_master_write && sd_master_writedata == 32'd2) begin
        #22;
        
        for(read_count=0; read_count < 512; read_count = read_count+1) begin
            sd_slave_address = read_count;
            sd_slave_write   = 1;
            sd_slave_writedata = read_count;
            #10;
        end
        
        sd_slave_address = 0;
        sd_slave_write   = 0;
        sd_slave_writedata = 0;
    end
    else begin
        sd_master_readdatavalid <= 1'b0;
        sd_master_readdata <= 3'd0;
    end
end

integer dma_count = 0;

always @(posedge clk) begin
    if(dma_floppy_req) begin
        dma_floppy_ack <= 1'b1;
        dma_count = dma_count + 1;
    end
    else begin
        dma_floppy_ack <= 1'b0;
    end
    
    if(dma_count == 1000) begin
        dma_floppy_terminal <= 1'b1;
    
        #10001;
        dma_count = 0;
        
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
    end
    else begin
        dma_floppy_terminal <= 1'b0;
    end
end
*/

//------------------------------------------------------------------------------ write data

/*
integer read_count = 0;
    
always @(posedge clk) begin
    if(sd_master_address == 32'd4 && sd_master_read) begin
        sd_master_readdatavalid <= 1'b1;
        sd_master_readdata <= 3'd1;
    end
    else if(sd_master_address == 32'd12 && sd_master_write && sd_master_writedata == 32'd3) begin
        #22;
        
        for(read_count=0; read_count < 512; read_count = read_count+1) begin
            sd_slave_address = read_count;
            sd_slave_read   = 1;
            #10;
        end
        
        sd_slave_address = 0;
        sd_slave_read   = 0;
        sd_slave_writedata = 0;
    end
    else begin
        sd_master_readdatavalid <= 1'b0;
        sd_master_readdata <= 3'd0;
    end
end

integer dma_count = 0;

always @(posedge clk) begin
    if(dma_floppy_req) begin
        dma_floppy_ack <= 1'b1;
        dma_floppy_readdata <= dma_count;
        dma_count = dma_count + 1;
    end
    else begin
        dma_floppy_ack <= 1'b0;
    end
    
    if(dma_count == 1000) begin
        dma_floppy_terminal <= 1'b1;
        
    
        #10001;
        dma_count = 0;
        
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
    
    end
    else begin
        dma_floppy_terminal <= 1'b0;
    end
end
*/

//------------------------------------------------------------------------------ format

integer read_count = 0;
    
always @(posedge clk) begin
    if(sd_master_address == 32'd4 && sd_master_read) begin
        sd_master_readdatavalid <= 1'b1;
        sd_master_readdata <= 3'd1;
    end
    else if(sd_master_address == 32'd12 && sd_master_write && sd_master_writedata == 32'd3) begin
        #22;
        
        for(read_count=0; read_count < 512; read_count = read_count+1) begin
            sd_slave_address = read_count;
            sd_slave_read   = 1;
            #10;
        end
        
        sd_slave_address = 0;
        sd_slave_read   = 0;
        sd_slave_writedata = 0;
    end
    else begin
        sd_master_readdatavalid <= 1'b0;
        sd_master_readdata <= 3'd0;
    end
end


integer dma_count = 0;

always @(posedge clk) begin
    if(dma_floppy_req) begin
        dma_floppy_ack <= 1'b1;
        dma_floppy_readdata <=
            ((dma_count % 4) == 0)?     8'd30 : //cylinder
            ((dma_count % 4) == 1)?     8'd01 : //head
            ((dma_count % 4) == 2)?     8'd12 : //sector
                                        8'd02;  //N
        dma_count = dma_count + 1;
    end
    else begin
        dma_floppy_ack <= 1'b0;
    end
    
    if(dma_count == 8) begin
        #11;
        dma_floppy_terminal <= 1'b1;
        dma_floppy_ack = 1'b0;
        
        #10001;
        dma_count = 0;
        
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        `READ_IO(4'h5)
        
    end
    else begin
        dma_floppy_terminal <= 1'b0;
    end
end

integer finished = 0;

reg [255:0] dumpfile_name;
initial begin
    if( $value$plusargs("dumpfile=%s", dumpfile_name) == 0 ) begin
        dumpfile_name = "default.vcd";
    end
    
    $dumpfile(dumpfile_name);
    $dumpvars(0);
    $dumpon();
    
    $display("START");
    
    rst_n = 1'b0;
    #10 rst_n = 1'b1;
    
    //initialize drive
    // 0x00.[0]:      media present
    // 0x01.[0]:      media writeprotect
    // 0x02.[7:0]:    media cylinders
    // 0x03.[7:0]:    media sectors per track
    // 0x04.[31:0]:   media total sector count
    // 0x05.[1:0]:    media heads
    // 0x06.[31:0]:   media sd base
    // 0x07.[15:0]:   media wait cycles
    // 0x08.[15:0]:   media wait rate 0
    // 0x09.[15:0]:   media wait rate 1
    // 0x0A.[15:0]:   media wait rate 2
    // 0x0B.[15:0]:   media wait rate 3
    // 0x0C.[7:0]:    media type: 8'h20 none; 8'h00 old; 8'hC0 720k; 8'h80 1_44M; 8'h40 2_88M
    
    `WRITE_MGMT(4'h0, 1)
    `WRITE_MGMT(4'h1, 0)
    `WRITE_MGMT(4'h2, 80)
    `WRITE_MGMT(4'h3, 18)
    `WRITE_MGMT(4'h4, 2880)
    `WRITE_MGMT(4'h5, 2)
    `WRITE_MGMT(4'h6, 32'h0A0B0C0D)
    `WRITE_MGMT(4'h7, 200)
    `WRITE_MGMT(4'h8, 1000)
    `WRITE_MGMT(4'h9, 1666)
    `WRITE_MGMT(4'hA, 2000)
    `WRITE_MGMT(4'hB, 500)
    `WRITE_MGMT(4'hC, 8'h80)
    
    #10;
    
    //enable motor
    `WRITE_IO(3'd2, 8'h1C)
    
    //------------------------------------------------------------------------------ read data
    /*
    //cmd: READ
    `WRITE_IO(3'd5, 8'hC6)
    `WRITE_IO(3'd5, 8'h04)
    `WRITE_IO(3'd5, 8'h12) //C
    `WRITE_IO(3'd5, 8'h01) //H
    `WRITE_IO(3'd5, 8'h05) //R
    `WRITE_IO(3'd5, 8'h02) //N
    `WRITE_IO(3'd5, 8'h08) //EOT
    `WRITE_IO(3'd5, 8'hFF) //GPL
    `WRITE_IO(3'd5, 8'hFF) //DTL
    */
    
    //------------------------------------------------------------------------------ write data
    /*
    //cmd: WRITE
    `WRITE_IO(3'd5, 8'hC5)
    `WRITE_IO(3'd5, 8'h04)
    `WRITE_IO(3'd5, 8'h12) //C
    `WRITE_IO(3'd5, 8'h01) //H
    `WRITE_IO(3'd5, 8'h05) //R
    `WRITE_IO(3'd5, 8'h02) //N
    `WRITE_IO(3'd5, 8'h08) //EOT
    `WRITE_IO(3'd5, 8'hFF) //GPL
    `WRITE_IO(3'd5, 8'hFF) //DTL
    */
    
    //------------------------------------------------------------------------------ format
    //cmd: FORMAT
    `WRITE_IO(3'd5, 8'h4D)
    `WRITE_IO(3'd5, 8'h04)
    `WRITE_IO(3'd5, 8'h02) //N
    `WRITE_IO(3'd5, 8'd18) //SC
    `WRITE_IO(3'd5, 8'hFF) //GPL
    `WRITE_IO(3'd5, 8'hAB) //D
    
    while(finished == 0) begin
        if($time > 100000) $finish_and_return(-1);
        #10;
        
        //$dumpflush();
    end
    
    #60;
    
    $dumpoff();
    $finish_and_return(0);
end

endmodule
