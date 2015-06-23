
module tb_pic();

reg clk;
reg rst_n;

reg         master_address      = 1'b0;
reg         master_read         = 1'b0;
wire [7:0]  master_readdata;
reg         master_write        = 1'b0;
reg [7:0]   master_writedata    = 8'd0;

reg         slave_address       = 1'b0;
reg         slave_read          = 1'b0;
wire [7:0]  slave_readdata;
reg         slave_write         = 1'b0;
reg [7:0]   slave_writedata     = 8'd0;

reg [15:0]  interrupt           = 16'd0;

wire        interrupt_do;
wire [7:0]  interrupt_vector;
reg         interrupt_done      = 1'b0;

pic pic_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    
    //master pic
    .master_address     (master_address),     //input
    .master_read        (master_read),        //input
    .master_readdata    (master_readdata),    //output [7:0]
    .master_write       (master_write),       //input
    .master_writedata   (master_writedata),   //input [7:0]
    
    //slave pic
    .slave_address      (slave_address),      //input
    .slave_read         (slave_read),         //input
    .slave_readdata     (slave_readdata),     //output [7:0]
    .slave_write        (slave_write),        //input
    .slave_writedata    (slave_writedata),    //input [7:0]
    
    //interrupt input
    .interrupt          (interrupt),          //input [15:0]
    
    //interrupt output
    .interrupt_do       (interrupt_do),       //output
    .interrupt_vector   (interrupt_vector),   //output [7:0]
    .interrupt_done     (interrupt_done)      //input
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

integer finished = 0;

`define WRITE_MAS_IMR(data)     \
    master_write        = 1'b1; \
    master_address      = 1'b1; \
    master_writedata    = data; \
    #10;                        \
    master_write        = 1'b0;

`define WRITE_SLA_IMR(data)     \
    slave_write        = 1'b1; \
    slave_address      = 1'b1; \
    slave_writedata    = data; \
    #10;                        \
    slave_write        = 1'b0;
    
`define WRITE_MAS_OCW2_3(data)  \
    master_write        = 1'b1; \
    master_address      = 1'b0; \
    master_writedata    = data; \
    #10;                        \
    master_write        = 1'b0;

`define WRITE_SLA_OCW2_3(data) \
    slave_write        = 1'b1; \
    slave_address      = 1'b0; \
    slave_writedata    = data; \
    #10;                       \
    slave_write        = 1'b0;
    

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
    
    //clear mask
    `WRITE_MAS_IMR(8'h00)
    `WRITE_SLA_IMR(8'h00)
    
    #10;
    interrupt[15:0] = 16'b0100000000000000;
    
    while(interrupt_do == 1'b0) begin #10; end
    
    interrupt[15:0] = 16'b0000000000000000;
    #10;
    
    #10;
    interrupt_done = 1'b1;
    #10;
    interrupt_done = 1'b0;
    
    #40;
    `WRITE_MAS_OCW2_3(8'h20)
    `WRITE_SLA_OCW2_3(8'h20)
    
    while(finished == 0) begin
        if($time > 50000) $finish_and_return(-1);
        #10;
        
        //$dumpflush();
    end
    
    #60;
    
    $dumpoff();
    $finish_and_return(0);
end

endmodule
