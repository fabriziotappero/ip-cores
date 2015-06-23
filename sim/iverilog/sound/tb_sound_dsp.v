
`timescale 1 ps / 1 ps

module tb_sound_dsp();

reg clk;
reg rst_n;

wire interrupt;

reg  [3:0]  io_address                  = 4'b0;
reg         io_read                     = 1'b0;
wire [7:0]  io_readdata_from_dsp;
reg         io_write                    = 1'b0;
reg  [7:0]  io_writedata                = 8'd0;

wire        dma_soundblaster_req;
reg         dma_soundblaster_ack        = 1'd0;
reg         dma_soundblaster_terminal   = 1'd0;
reg  [7:0]  dma_soundblaster_readdata   = 8'd0;
wire [7:0]  dma_soundblaster_writedata;

wire        sample_from_dsp;
wire [7:0]  sample_from_dsp_value;

reg  [7:0]  mgmt_address                = 8'd0;
reg         mgmt_write                  = 1'b0;
reg  [31:0] mgmt_writedata              = 32'd0;

sound_dsp sound_dsp_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    .interrupt                  (interrupt),                    //output
    
    //io slave 220h-22Fh
    .io_address                 (io_address),                   //input [3:0]
    .io_read                    (io_read),                      //input
    .io_readdata_from_dsp       (io_readdata_from_dsp),         //output [7:0]
    .io_write                   (io_write),                     //input
    .io_writedata               (io_writedata),                 //input [7:0]
    
    //dma
    .dma_soundblaster_req       (dma_soundblaster_req),         //output
    .dma_soundblaster_ack       (dma_soundblaster_ack),         //input
    .dma_soundblaster_terminal  (dma_soundblaster_terminal),    //input
    .dma_soundblaster_readdata  (dma_soundblaster_readdata),    //input [7:0]
    .dma_soundblaster_writedata (dma_soundblaster_writedata),   //output [7:0]
    
    //sample
    .sample_from_dsp            (sample_from_dsp),              //output
    .sample_from_dsp_value      (sample_from_dsp_value),        //output [7:0]
    
    //mgmt slave
    .mgmt_address               (mgmt_address),                 //input [7:0]
    .mgmt_write                 (mgmt_write),                   //input
    .mgmt_writedata             (mgmt_writedata)                //input [31:0]
);

//------------------------------------------------------------------------------

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

`define WRITE_IO(addr, data)  \
    io_write        = 1'b1;   \
    io_address      = addr;   \
    io_writedata    = data;   \
    #10;                      \
    io_write        = 1'b0;

`define READ_IO(addr)       \
    io_read         = 1'b1; \
    io_address      = addr; \
    #10;                    \
    io_read         = 1'b0;

//------------------------------------------------------------------------------

initial begin
    #100;
    
    `WRITE_MGMT(8'd128, 16'd50)
    
    #20
    
    `WRITE_IO(4'hC, 8'hD1) //cmd: speaker on
    
    `WRITE_IO(4'hC, 8'h40) //cmd: time constant
    `WRITE_IO(4'hC, 8'd128)
    
    //-------------------------------------------------------------------------- dma single output
    /*
    `WRITE_IO(4'hC, 8'h14)
    `WRITE_IO(4'hC, 8'h0B)
    `WRITE_IO(4'hC, 8'h00)
    */
    
    //-------------------------------------------------------------------------- dma single input
    /*
    `WRITE_IO(4'hC, 8'h24)
    `WRITE_IO(4'hC, 8'h0B)
    `WRITE_IO(4'hC, 8'h00)
    */
    
    //-------------------------------------------------------------------------- dma single output 4-bit adpcm + ref
    /*
    `WRITE_IO(4'hC, 8'h75)
    `WRITE_IO(4'hC, 8'h04)
    `WRITE_IO(4'hC, 8'h00)
    */
    //-------------------------------------------------------------------------- dma single output 3-bit adpcm + ref
    /*
    `WRITE_IO(4'hC, 8'h77)
    `WRITE_IO(4'hC, 8'h0B)
    `WRITE_IO(4'hC, 8'h00)
    */
    //-------------------------------------------------------------------------- dma single output 2-bit adpcm + ref
    /*
    `WRITE_IO(4'hC, 8'h17)
    `WRITE_IO(4'hC, 8'h0B)
    `WRITE_IO(4'hC, 8'h00)
    */ 
    
    //-------------------------------------------------------------------------- dma single output 4-bit adpcm
    /*
    `WRITE_IO(4'hC, 8'h74)
    `WRITE_IO(4'hC, 8'h04)
    `WRITE_IO(4'hC, 8'h00)
    */
    //-------------------------------------------------------------------------- dma single output 3-bit adpcm
    /*
    `WRITE_IO(4'hC, 8'h76)
    `WRITE_IO(4'hC, 8'h0B)
    `WRITE_IO(4'hC, 8'h00)
    */
    //-------------------------------------------------------------------------- dma single output 2-bit adpcm
    /*
    `WRITE_IO(4'hC, 8'h16)
    `WRITE_IO(4'hC, 8'h04)
    `WRITE_IO(4'hC, 8'h00)
    */
    
    //-------------------------------------------------------------------------- dma auto output
    /*
    `WRITE_IO(4'hC, 8'h48)
    `WRITE_IO(4'hC, 8'h04)
    `WRITE_IO(4'hC, 8'h00)
    
    `WRITE_IO(4'hC, 8'h1C)
    
    #2000
    
    //`WRITE_IO(4'hC, 8'hDA)
    
    `WRITE_IO(4'hC, 8'h17)
    `WRITE_IO(4'hC, 8'h0B)
    `WRITE_IO(4'hC, 8'h00)
    */
    
    //-------------------------------------------------------------------------- dma auto input
    /*
    `WRITE_IO(4'hC, 8'h48)
    `WRITE_IO(4'hC, 8'h04)
    `WRITE_IO(4'hC, 8'h00)
    
    `WRITE_IO(4'hC, 8'h2C)
    
    #2000;
    
    //`WRITE_IO(4'hC, 8'hDA)
    
    `WRITE_IO(4'hC, 8'h17)
    `WRITE_IO(4'hC, 8'h0B)
    `WRITE_IO(4'hC, 8'h00)
    */
    
    //-------------------------------------------------------------------------- dma auto output 2-bit adpcm
    /*
    `WRITE_IO(4'hC, 8'h48)
    `WRITE_IO(4'hC, 8'h04)
    `WRITE_IO(4'hC, 8'h00)
    
    `WRITE_IO(4'hC, 8'h1F)
    
    #20000;
    
    //`WRITE_IO(4'hC, 8'hDA)
    
    `WRITE_IO(4'hC, 8'h17)
    `WRITE_IO(4'hC, 8'h0B)
    `WRITE_IO(4'hC, 8'h00)
    */
    
    //-------------------------------------------------------------------------- dma auto output 3-bit adpcm
    /*
    `WRITE_IO(4'hC, 8'h48)
    `WRITE_IO(4'hC, 8'h04)
    `WRITE_IO(4'hC, 8'h00)
    
    `WRITE_IO(4'hC, 8'h7F)
    
    #20000;
    
    //`WRITE_IO(4'hC, 8'hDA)
    
    `WRITE_IO(4'hC, 8'h17)
    `WRITE_IO(4'hC, 8'h0B)
    `WRITE_IO(4'hC, 8'h00)
    */
    
    //-------------------------------------------------------------------------- dma auto output 4-bit adpcm
    /*
    `WRITE_IO(4'hC, 8'h48)
    `WRITE_IO(4'hC, 8'h04)
    `WRITE_IO(4'hC, 8'h00)
    
    `WRITE_IO(4'hC, 8'h7D)
    
    #20000;
    
    //`WRITE_IO(4'hC, 8'hDA)
    
    `WRITE_IO(4'hC, 8'h17)
    `WRITE_IO(4'hC, 8'h0B)
    `WRITE_IO(4'hC, 8'h00)
    */
    
    //-------------------------------------------------------------------------- dma single output highspeed
    /*
    `WRITE_IO(4'hC, 8'h48)
    `WRITE_IO(4'hC, 8'h04)
    `WRITE_IO(4'hC, 8'h00)
    
    `WRITE_IO(4'hC, 8'h91)
    */
    //-------------------------------------------------------------------------- dma single input highspeed
    /*
    `WRITE_IO(4'hC, 8'h48)
    `WRITE_IO(4'hC, 8'h04)
    `WRITE_IO(4'hC, 8'h00)
    
    `WRITE_IO(4'hC, 8'h99)
    */
    
    //-------------------------------------------------------------------------- dma auto output highspeed
    /*
    `WRITE_IO(4'hC, 8'h48)
    `WRITE_IO(4'hC, 8'h04)
    `WRITE_IO(4'hC, 8'h00)
    
    `WRITE_IO(4'hC, 8'h90)
    
    #2000
    
    `WRITE_IO(4'hC, 8'hDA)
    
    #2000
    
    `WRITE_IO(4'hC, 8'h17)
    `WRITE_IO(4'hC, 8'h0B)
    `WRITE_IO(4'hC, 8'h00)
    
    #2000
    
    `WRITE_IO(4'h6, 8'h01)
    `WRITE_IO(4'h6, 8'h00)
    
    #2000
    
    `WRITE_IO(4'hC, 8'hDA)
    */
    
    //-------------------------------------------------------------------------- dma auto input highspeed
    
    `WRITE_IO(4'hC, 8'h48)
    `WRITE_IO(4'hC, 8'h04)
    `WRITE_IO(4'hC, 8'h00)
    
    `WRITE_IO(4'hC, 8'h98)
    
    #2000
    
    `WRITE_IO(4'hC, 8'hDA)
    
    #2000
    
    `WRITE_IO(4'hC, 8'h17)
    `WRITE_IO(4'hC, 8'h0B)
    `WRITE_IO(4'hC, 8'h00)
    
    #2000
    
    `WRITE_IO(4'h6, 8'h01)
    `WRITE_IO(4'h6, 8'h00)
    
    #2000;
    
    `WRITE_IO(4'hC, 8'hDA)
    
    
end

always @(posedge clk) begin
    if(interrupt) begin
        #100
        `READ_IO(4'hE)
    end
end
//------------------------------------------------------------------------------

always @(posedge clk) begin
    if(dma_soundblaster_req && dma_soundblaster_ack == 1'b0) begin
        dma_soundblaster_readdata <= dma_soundblaster_readdata + 8'd1;
        dma_soundblaster_ack <= 1'b1;
    end
    else begin
        dma_soundblaster_ack <= 1'b0;
    end
    
    if(dma_soundblaster_req == 1'b0 && dma_soundblaster_readdata == 8'd10 && dma_soundblaster_terminal == 1'b0) begin
        dma_soundblaster_terminal <= 1'b1;
        dma_soundblaster_readdata <= dma_soundblaster_readdata + 8'd1;
    end
    else begin
        dma_soundblaster_terminal <= 1'b0;
    end
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
