
`timescale 1 ps / 1 ps

module tb_ps2();

reg clk;
reg rst_n;

wire interrupt_keyb;
wire interrupt_mouse;

reg  [2:0]  io_address              = 3'd0;
reg         io_read                 = 1'b0;
wire [7:0]  io_readdata;
reg         io_write                = 1'b0;
reg  [7:0]  io_writedata            = 8'd0;

wire        speaker_61h_read;
reg  [7:0]  speaker_61h_readdata    = 8'd0;
wire        speaker_61h_write;
wire [7:0]  speaker_61h_writedata;

wire        output_a20_enable;
wire        output_reset_n;

reg kbclk_ena       = 1'b0;
reg kbclk           = 1'b0;

reg kbdat_ena       = 1'b0;
reg kbdat           = 1'b0;

reg mouseclk_ena    = 1'b0;
reg mouseclk        = 1'b0;

reg mousedat_ena    = 1'b0;
reg mousedat        = 1'b0;

wire        ps2_kbclk = kbclk_ena? kbclk : 1'bZ;
wire        ps2_kbdat = kbdat_ena? kbdat : 1'bZ;

wire        ps2_mouseclk = mouseclk_ena? mouseclk : 1'bZ;
wire        ps2_mousedat = mousedat_ena? mousedat : 1'bZ;

ps2 ps2_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .interrupt_keyb         (interrupt_keyb),       //output
    .interrupt_mouse        (interrupt_mouse),      //output
    
    //io slave
    .io_address             (io_address),     //input [2:0]
    .io_read                (io_read),        //input
    .io_readdata            (io_readdata),    //output [7:0]
    .io_write               (io_write),       //input
    .io_writedata           (io_writedata),   //input [7:0]
    
    //port 61h
    .speaker_61h_read       (speaker_61h_read),           //output
    .speaker_61h_readdata   (speaker_61h_readdata),       //input [7:0]
    .speaker_61h_write      (speaker_61h_write),          //output
    .speaker_61h_writedata  (speaker_61h_writedata),      //output [7:0]

    //output port
    .output_a20_enable      (output_a20_enable),  //output
    .output_reset_n         (output_reset_n),     //output
    
    //ps2 keyboard
    .ps2_kbclk              (ps2_kbclk),      //inout
    .ps2_kbdat              (ps2_kbdat),      //inout
    
    //ps2 mouse
    .ps2_mouseclk           (ps2_mouseclk),   //inout
    .ps2_mousedat           (ps2_mousedat)    //inout
);

//------------------------------------------------------------------------------

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

//------------------------------------------------------------------------------ keyboard send

`define KB_SEND(data)   \
    kbclk_ena = 1'b1;   \
    kbdat_ena = 1'b1;   \
    kbclk = 1'b1;       \
    kbdat = data;       \
    #20;                 \
    kbclk = 1'b0;       \
    #20;                 \
    kbclk_ena = 1'b0;   \
    kbclk = 1'b0;       \
    kbdat_ena = 1'b0;   \
    kbdat = 1'b0;

`define MOUSE_SEND(data)   \
    mouseclk_ena = 1'b1;   \
    mousedat_ena = 1'b1;   \
    mouseclk = 1'b1;       \
    mousedat = data;       \
    #200;                 \
    mouseclk = 1'b0;       \
    #200;                 \
    mouseclk_ena = 1'b0;   \
    mouseclk = 1'b0;       \
    mousedat_ena = 1'b0;   \
    mousedat = 1'b0;
    
`define MOUSE_CLK  \
    mouseclk_ena = 1'b1;   \
    mouseclk = 1'b1;       \
    #200;                 \
    mouseclk = 1'b0;       \
    #200;                 \
    mouseclk_ena = 1'b0;   \
    mouseclk = 1'b0;
    
`define KB_CLK  \
    kbclk_ena = 1'b1;   \
    kbclk = 1'b1;       \
    #20;                 \
    kbclk = 1'b0;       \
    #20;                 \
    kbclk_ena = 1'b0;   \
    kbclk = 1'b0;
    
`define READ_IO(addr)  \
    io_read         = 1'b1;   \
    io_address      = addr;   \
    #10;                      \
    io_read         = 1'b0;
    
`define WRITE_IO(addr, data)  \
    io_write        = 1'b1;   \
    io_address      = addr;   \
    io_writedata    = data;   \
    #10;                      \
    io_write        = 1'b0;
    
initial begin
    #100;
    
    
    /*
outb(PORT_PS2_STATUS, 0xaa);

max=0xffff;
while ( (inb(PORT_PS2_STATUS) & 0x02) && (--max>0)) outb(PORT_DIAG, 0x00);
if (max==0x0) keyboard_panic(00);

max=0xffff;
while ( ((inb(PORT_PS2_STATUS) & 0x01) == 0) && (--max>0) ) outb(PORT_DIAG, 0x01);
if (max==0x0) keyboard_panic(01);
    */
    
    `WRITE_IO(4, 8'hAA)
    
    #100;
    `READ_IO(3'd4)
    #100;
    `READ_IO(3'd4)
    #100;
    `READ_IO(3'd4)
    #100;
    `READ_IO(3'd4)
    #100;
    `READ_IO(3'd4)
    `READ_IO(3'd4)
    `READ_IO(3'd4)
    
    //--------------------------------------------------------------------------
    
    
    
    /*
    `WRITE_IO(4, 8'h60)
    `WRITE_IO(0, 8'h03)
    
    #10
    
    `WRITE_IO(4, 8'hD4)
    `WRITE_IO(0, 8'hF5)
    
    while(ps2_inst.mouse_state != 5) #10;
    
    #20
    
    `MOUSE_CLK
    `MOUSE_CLK
    `MOUSE_CLK
    `MOUSE_CLK
    `MOUSE_CLK
    `MOUSE_CLK
    `MOUSE_CLK
    `MOUSE_CLK
    `MOUSE_CLK
    `MOUSE_CLK
    `MOUSE_SEND(0)
    
    mouseclk_ena = 1'b1;
    mouseclk     = 1'b1;
    mousedat_ena = 1'b1;
    mousedat     = 1'b1;
    #20;
    mouseclk_ena = 1'b0;
    mouseclk     = 1'b0;
    mousedat_ena = 1'b0;
    mousedat     = 1'b0;
    */
    
//------------------------------------------------------------------------------ keyboard test
    
/*    
    `KB_SEND(0)
    
    `KB_SEND(1)
    `KB_SEND(0)
    `KB_SEND(1)
    `KB_SEND(0)
    `KB_SEND(1)
    `KB_SEND(0)
    `KB_SEND(1)
    `KB_SEND(1)
    
    `KB_SEND(0)
    `KB_SEND(1)
    
    kbclk_ena = 1'b1;
    kbclk     = 1'b1;
    kbdat_ena = 1'b1;
    kbdat     = 1'b1;
    #20;
    kbclk_ena = 1'b0;
    kbclk     = 1'b0;
    kbdat_ena = 1'b0;
    kbdat     = 1'b0;
    
    #50;
    `READ_IO(3'd0)
    
    #50;
    `WRITE_IO(3'd0, 8'h83)
    
    while(ps2_inst.keyb_state != 5) #10;
    
    #20;
    `KB_CLK
    `KB_CLK
    `KB_CLK
    `KB_CLK
    `KB_CLK
    `KB_CLK
    `KB_CLK
    `KB_CLK
    `KB_CLK
    `KB_CLK
    `KB_SEND(0)
    
    kbclk_ena = 1'b1;
    kbclk     = 1'b1;
    kbdat_ena = 1'b1;
    kbdat     = 1'b1;
    #20;
    kbclk_ena = 1'b0;
    kbclk     = 1'b0;
    kbdat_ena = 1'b0;
    kbdat     = 1'b0;
*/  
    
    
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
