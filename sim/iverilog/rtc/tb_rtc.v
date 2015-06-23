
`timescale 1 ps / 1 ps

module tb_rtc();

reg clk;
reg rst_n;

wire interrupt;

reg         io_address      = 1'b0;
reg         io_read         = 1'b0;
wire [7:0]  io_readdata;
reg         io_write        = 1'b0;
reg  [7:0]  io_writedata    = 8'd0;

reg  [7:0]  mgmt_address    = 8'd0;
reg         mgmt_write      = 1'b0;
reg  [31:0] mgmt_writedata  = 32'd0;

rtc rtc_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .interrupt          (interrupt),      //output
    
    //io slave
    .io_address         (io_address),     //input
    .io_read            (io_read),        //input
    .io_readdata        (io_readdata),    //output [7:0]
    .io_write           (io_write),       //input
    .io_writedata       (io_writedata),   //input [7:0]
    
    //mgmt slave
    /*
    128.[26:0]: cycles in second
    129.[12:0]: cycles in 122.07031 us
    */
    .mgmt_address       (mgmt_address),       //input [7:0]
    .mgmt_write         (mgmt_write),         //input
    .mgmt_writedata     (mgmt_writedata)      //input [31:0]
);

//------------------------------------------------------------------------------

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

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
