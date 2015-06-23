
`timescale 1 ps / 1 ps

module tb_sound();

reg clk;
reg rst_n;

wire interrupt;

reg speaker_enable  = 1'b0;
reg speaker_out     = 1'b0;

reg [3:0]  io_address   = 4'd0;
reg        io_read      = 1'd0;
wire [7:0] io_readdata;
reg        io_write     = 1'd0;
reg [7:0]  io_writedata = 8'd0;

reg        fm_address   = 1'd0;
reg        fm_read      = 1'd0;
wire [7:0] fm_readdata;
reg        fm_write     = 1'd0;
reg [7:0]  fm_writedata = 8'd0;

wire        dma_soundblaster_req;
reg         dma_soundblaster_ack        = 1'd0;
reg         dma_soundblaster_terminal   = 1'd0;
reg  [7:0]  dma_soundblaster_readdata   = 8'd0;
wire [7:0]  dma_soundblaster_writedata;

reg [8:0]   mgmt_address    = 9'd0;
reg         mgmt_write      = 1'd0;
reg [31:0]  mgmt_writedata  = 32'd0;

reg clk_12;

wire ac_sclk;
reg  ac_sdat_ena = 1'b0;
reg  ac_sdat_val = 1'b0;
wire ac_sdat = ac_sdat_ena? ac_sdat_val : 1'bZ;
wire ac_xclk;
wire ac_bclk;
wire ac_dat;
wire ac_lr;

sound sound_inst(
    .clk            (clk),
    .rst_n          (rst_n),
    
    .interrupt      (interrupt),        //output
    
    //speaker input
    .speaker_enable (speaker_enable),   //input
    .speaker_out    (speaker_out),      //input
    
    //io slave 220h-22Fh
    .io_address     (io_address),       //input [3:0]
    .io_read        (io_read),          //input
    .io_readdata    (io_readdata),      //output [7:0]
    .io_write       (io_write),         //input
    .io_writedata   (io_writedata),     //input
    
    //fm music io slave 388h-389h
    .fm_address     (fm_address), //input
    .fm_read        (fm_read),    //input
    .fm_readdata    (fm_readdata),    //output [7:0]
    .fm_write       (fm_write),   //input
    .fm_writedata   (fm_writedata),   //input [7:0]

    //dma
    .dma_soundblaster_req       (dma_soundblaster_req),         //output
    .dma_soundblaster_ack       (dma_soundblaster_ack),         //input
    .dma_soundblaster_terminal  (dma_soundblaster_terminal),    //input
    .dma_soundblaster_readdata  (dma_soundblaster_readdata),    //input [7:0]
    .dma_soundblaster_writedata (dma_soundblaster_writedata),   //output [7:0]
    
    //mgmt slave
    /*
    0-255.[15:0]: cycles in period
    256.[12:0]:  cycles in 80us
    257.[9:0]:   cycles in 1 sample: 96000 Hz
    */
    .mgmt_address       (mgmt_address),   //input [8:0]
    .mgmt_write         (mgmt_write),     //input
    .mgmt_writedata     (mgmt_writedata), //input [31:0]
    
    //WM8731 audio codec
    .clk_12             (clk_12),
    
    .ac_sclk            (ac_sclk),  //output
    .ac_sdat            (ac_sdat),  //inout
    .ac_xclk            (ac_xclk),  //output
    .ac_bclk            (ac_bclk),  //output
    .ac_dat             (ac_dat),   //output
    .ac_lr              (ac_lr)     //output
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    clk_12 = 1'b0;
    forever #13 clk_12 = ~clk_12;
end

//------------------------------------------------------------------------------

always @(posedge clk_12) begin
    if(sound_inst.sound_i2c_inst.state == 4'd5) begin
        ac_sdat_ena = 1'b1; //S_SEND_4
        ac_sdat_val = 1'b0;
    end
    else begin
        ac_sdat_ena = 1'b0;
        ac_sdat_val = 1'b0;
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

endmodule
