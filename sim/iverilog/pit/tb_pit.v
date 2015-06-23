
`timescale 1 ps / 1 ps

module tb_rtc();

reg clk;
reg rst_n;

wire interrupt;

reg  [1:0]  io_address      = 2'b0;
reg         io_read         = 1'b0;
wire [7:0]  io_readdata;
reg         io_write        = 1'b0;
reg  [7:0]  io_writedata    = 8'd0;

reg         mgmt_address    = 1'd0;
reg         mgmt_write      = 1'b0;
reg  [31:0] mgmt_writedata  = 32'd0;

reg         speaker_61h_read        = 1'b0;
wire [7:0]  speaker_61h_readdata;
reg         speaker_61h_write       = 1'b0;
reg  [7:0]  speaker_61h_writedata   = 8'd0;

wire        speaker_enable;
wire        speaker_out;

pit pit_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .interrupt              (interrupt),      //output
    
    //io slave 040h-043h
    .io_address             (io_address),     //input [1:0]
    .io_read                (io_read),        //input
    .io_readdata            (io_readdata),    //output [7:0]
    .io_write               (io_write),       //input
    .io_writedata           (io_writedata),   //input [7:0]
    
    //speaker port 61h
    .speaker_61h_read       (speaker_61h_read),       //input
    .speaker_61h_readdata   (speaker_61h_readdata),   //output [7:0]
    .speaker_61h_write      (speaker_61h_write),      //input
    .speaker_61h_writedata  (speaker_61h_writedata),  //input [7:0]
    
    //speaker output
    .speaker_enable         (speaker_enable),     //output
    .speaker_out            (speaker_out),        //output
    
    //mgmt slave
    /*
    0.[7:0]: cycles in sysclock
    */
    .mgmt_address           (mgmt_address),       //input
    .mgmt_write             (mgmt_write),         //input
    .mgmt_writedata         (mgmt_writedata)      //input [31:0]
);

//------------------------------------------------------------------------------

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

//------------------------------------------------------------------------------

`define WRITE_IO(addr, data)  \
    io_write        = 1'b1;   \
    io_address      = addr;   \
    io_writedata    = data;   \
    #10;                      \
    io_write        = 1'b0;

`define WRITE_MGMT(addr, data)  \
    mgmt_write        = 1'b1;   \
    mgmt_address      = addr;   \
    mgmt_writedata    = data;   \
    #10;                      \
    mgmt_write        = 1'b0;
    
//------------------------------------------------------------------------------

initial begin
    #100;
    
    `WRITE_MGMT(1'b0, 32'd5)
    
    /*
    `WRITE_IO(2'd3, 8'h30)
    
    `WRITE_IO(2'd0, 8'h05)
    `WRITE_IO(2'd0, 8'h01)
    */
    
    /*
    `WRITE_IO(2'd3, 8'h32)
    
    `WRITE_IO(2'd0, 8'h05)
    `WRITE_IO(2'd0, 8'h01)
    
    #100;
    pit_inst.pit_counter_0.gate_last = 0;
    #10;
    pit_inst.pit_counter_0.gate_last = 1;
    */
    
    /*
    `WRITE_IO(2'd3, 8'h34)
    
    `WRITE_IO(2'd0, 8'h05)
    `WRITE_IO(2'd0, 8'h01)
    */
    
    /*
    `WRITE_IO(2'd3, 8'h36)
    
    `WRITE_IO(2'd0, 8'h05)
    `WRITE_IO(2'd0, 8'h01)
    */
    
    /*
    `WRITE_IO(2'd3, 8'h38)
    
    `WRITE_IO(2'd0, 8'h05)
    `WRITE_IO(2'd0, 8'h01)
    */
    
    `WRITE_IO(2'd3, 8'h3A)
    
    `WRITE_IO(2'd0, 8'h05)
    `WRITE_IO(2'd0, 8'h01)
    
    #100;
    pit_inst.pit_counter_0.gate_last = 0;
    #10;
    pit_inst.pit_counter_0.gate_last = 1;
end
    
//------------------------------------------------------------------------------

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
    
    while(finished == 0) begin
        if($time > 200000) $finish_and_return(-1);
        #10;
        
        //$dumpflush();
    end
    
    #60;
    
    $dumpoff();
    $finish_and_return(0);
end

//------------------------------------------------------------------------------

endmodule
