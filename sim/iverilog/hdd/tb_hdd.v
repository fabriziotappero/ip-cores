
`timescale 1 ps / 1 ps

module tb_hdd();

reg clk;
reg rst_n;

wire        interrupt;

reg         io_address                  = 1'b0;
reg  [3:0]  io_byteenable               = 4'd0;
reg         io_read                     = 1'b0;
wire [31:0] io_readdata;
reg         io_write                    = 1'b0;
reg  [31:0] io_writedata                = 32'd0;

reg         ide_3f6_read                = 1'b0;
wire [7:0]  ide_3f6_readdata;
reg         ide_3f6_write               = 1'b0;
reg  [7:0]  ide_3f6_writedata           = 8'd0;

wire [31:0] sd_master_address;
reg         sd_master_waitrequest       = 1'b0;
wire        sd_master_read;
reg         sd_master_readdatavalid     = 1'b0;
reg  [31:0] sd_master_readdata          = 1'b0;
wire        sd_master_write;
wire [31:0] sd_master_writedata;

reg  [8:0]  sd_slave_address            = 9'd0;
reg         sd_slave_read               = 1'b0;
wire [31:0] sd_slave_readdata;
reg         sd_slave_write              = 1'b0;
reg  [31:0] sd_slave_writedata          = 32'd0;

reg  [2:0]  mgmt_address                = 3'd0;
reg         mgmt_write                  = 1'b0;
reg  [31:0] mgmt_writedata              = 32'd0;

hdd hdd_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //irq
    .interrupt                  (interrupt),              //output
    
    //avalon slave
    .io_address                 (io_address),             //input
    .io_byteenable              (io_byteenable),          //input [3:0]
    .io_read                    (io_read),                //input
    .io_readdata                (io_readdata),            //output [31:0]
    .io_write                   (io_write),               //input
    .io_writedata               (io_writedata),           //input [31:0]
    
    //ide shared port 0x3F6
    .ide_3f6_read               (ide_3f6_read),           //input
    .ide_3f6_readdata           (ide_3f6_readdata),       //output [7:0]
    .ide_3f6_write              (ide_3f6_write),          //input
    .ide_3f6_writedata          (ide_3f6_writedata),      //input [7:0]
    
    //master to control sd
    .sd_master_address          (sd_master_address),      //output [31:0]
    .sd_master_waitrequest      (sd_master_waitrequest),  //input
    .sd_master_read             (sd_master_read),         //output
    .sd_master_readdatavalid    (sd_master_readdatavalid),//input
    .sd_master_readdata         (sd_master_readdata),     //input [31:0]
    .sd_master_write            (sd_master_write),        //output
    .sd_master_writedata        (sd_master_writedata),    //output [31:0]
    
    //slave with data from/to sd
    .sd_slave_address           (sd_slave_address),       //input [8:0]
    .sd_slave_read              (sd_slave_read),          //input
    .sd_slave_readdata          (sd_slave_readdata),      //output [31:0]
    .sd_slave_write             (sd_slave_write),         //input
    .sd_slave_writedata         (sd_slave_writedata),     //input [31:0]
    
    //management slave
    .mgmt_address               (mgmt_address),           //input [2:0]
    .mgmt_write                 (mgmt_write),             //input
    .mgmt_writedata             (mgmt_writedata)          //input [31:0]
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

//------------------------------------------------------------------------------

`define WRITE_MGMT(addr, data)  \
    mgmt_write        = 1'b1;   \
    mgmt_address      = addr;   \
    mgmt_writedata    = data;   \
    #10;                        \
    mgmt_write        = 1'b0;

`define WRITE_IO(addr, enable, data)  \
    io_write        = 1'b1;   \
    io_address      = addr;   \
    io_byteenable   = enable; \
    io_writedata    = data;   \
    #10;                      \
    io_write        = 1'b0;

`define READ_IO(addr, enable) \
    io_read         = 1'b1;   \
    io_address      = addr;   \
    io_byteenable   = enable; \
    #10;                      \
    io_read         = 1'b0;

//------------------------------------------------------------------------------ read

/*
integer read_count = 0;
    
always @(posedge clk) begin
    if(sd_master_address == 32'd4 && sd_master_read) begin
        sd_master_readdatavalid <= 1'b1;
        sd_master_readdata <= 3'd2;
    end
    else if(sd_master_address == 32'd12 && sd_master_write && sd_master_writedata == 32'd2) begin
        #22;
        
        for(read_count=0; read_count < 16*128; read_count = read_count+1) begin
            sd_slave_address = read_count;
            sd_slave_write   = 1;
            sd_slave_writedata = read_count;
            #10;
        end
        
        sd_slave_address = 0;
        sd_slave_write   = 0;
        sd_slave_writedata = 0;
        
        #100;
        
        for(read_count=0; read_count < 16*128; read_count = read_count+1) begin
            `READ_IO(0, 4'b1111)
        end
        
        #100;
        
        `READ_IO(1, 4'b1000)
        
    end
    else begin
        sd_master_readdatavalid <= 1'b0;
        sd_master_readdata <= 3'd0;
    end
end
*/

//------------------------------------------------------------------------------ write

/*
integer read_count = 0;
integer write_count = 0;

always @(posedge clk) begin
    if(sd_master_address == 32'd4 && sd_master_read) begin
        sd_master_readdatavalid <= 1'b1;
        sd_master_readdata <= 3'd2;
    end
    else if(sd_master_address == 32'd12 && sd_master_write && sd_master_writedata == 32'd3) begin
        #22;
        
        for(read_count=0; read_count < 128; read_count = read_count+1) begin
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
    
    if(hdd_inst.status_drq) begin
        
        #22;
        
        for(write_count = 0; write_count < 128; write_count = write_count + 1) begin
            `WRITE_IO(0, 4'b1111, write_count)
        end
        
        #22;
    end
end
*/

//------------------------------------------------------------------------------ identify

/*
integer read_count = 0;
    
always @(posedge clk) begin
    if(hdd_inst.status_drq) begin
        
        #100;
        
        for(read_count=0; read_count < 128; read_count = read_count+1) begin
            `READ_IO(0, 4'b1111)
        end
        
        #100;
        
        `READ_IO(1, 4'b1000)
        
    end
    else begin
        sd_master_readdatavalid <= 1'b0;
        sd_master_readdata <= 3'd0;
    end
end
*/

//------------------------------------------------------------------------------

integer finished = 0;

integer identify_counter = 0;

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
    
    // 0x00.[31:0]:    identify write
    // 0x01.[16:0]:    media cylinders
    // 0x02.[4:0]:     media heads
    // 0x03.[8:0]:     media spt
    // 0x04.[13:0]:    media sectors per cylinder = spt * heads
    // 0x05.[31:0]:    media sectors total
    // 0x06.[31:0]:    media sd base
    
    for(identify_counter = 0; identify_counter < 128; identify_counter = identify_counter + 1) begin
        `WRITE_MGMT(0, (1 << 31) | (identify_counter << 24) | identify_counter) //identify
    end
    
    `WRITE_MGMT(1, 600)             //cylinders
    `WRITE_MGMT(2, 16)              //heads
    `WRITE_MGMT(3, 63)              //spt
    `WRITE_MGMT(4, 63*16)           //spc
    `WRITE_MGMT(5, 600*16*63)       //total
    `WRITE_MGMT(6, 32'h0A0B0C0D)    //sd base
    
    //-------------------------------------------------------------------------- read
    
    // 0 - data
    // 1 - features
    // 2 - sector count
    // 3 - sector number
    // 4 - cylinder low
    // 5 - cylinder high
    // 6 - lba,drive,head
    // 7 - command
    // 3f6 - reset/disable_irq
    
    /*
    `WRITE_IO(0, 4'b0100, 5 << 16)      //count
    `WRITE_IO(0, 4'b1000, 63 << 24)     //sector
    `WRITE_IO(1, 4'b0001, 7)            //cylinder low
    `WRITE_IO(1, 4'b0010, 1 << 8)       //cylinder high
    `WRITE_IO(1, 4'b0100, 15 << 16)      //lba,drive,head
    
    `WRITE_IO(1, 4'b1000, 32'h21 << 24) //command read
    */
    
    /*
    `WRITE_IO(0, 4'b0100, 16 << 16)      //count
    `WRITE_IO(1, 4'b1000, 32'hC6 << 24)  //set multiple
    
    `WRITE_IO(0, 4'b0100, 0 << 16)          //count
    `WRITE_IO(0, 4'b0100, 32 << 16)         //count
    `WRITE_IO(0, 4'b1000, 0 << 24)          //sector
    `WRITE_IO(0, 4'b1000, 63 << 24)         //sector
    `WRITE_IO(1, 4'b0001, 7)                //cylinder low
    `WRITE_IO(1, 4'b0010, 1 << 8)           //cylinder high
    `WRITE_IO(1, 4'b0100, (64+15) << 16)    //lba,drive,head
    
    `WRITE_IO(1, 4'b1000, 32'h29 << 24) //command read
    */
    
    //-------------------------------------------------------------------------- write
    
    /*
    `WRITE_IO(0, 4'b0100, 5 << 16)          //count
    `WRITE_IO(0, 4'b1000, 63 << 24)         //sector
    `WRITE_IO(1, 4'b0001, 7)                //cylinder low
    `WRITE_IO(1, 4'b0010, 1 << 8)           //cylinder high
    `WRITE_IO(1, 4'b0100, (64+0) << 16)     //lba,drive,head
    
    `WRITE_IO(1, 4'b1000, 32'h30 << 24)     //command write
    */
    
    //-------------------------------------------------------------------------- identify
    
    `WRITE_IO(1, 4'b1000, 32'hEC << 24)     //command identify
    
    #1000; 
    `READ_IO(1, 4'b1000)
    
    #1000; 
    `READ_IO(1, 4'b1000)
    
    #1000; 
    `READ_IO(1, 4'b1000)
    
    #1000; 
    `READ_IO(1, 4'b1000)
    
    #1000; 
    `READ_IO(1, 4'b1000)
    
    //--------------------------------------------------------------------------
    
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
