`timescale 1ps/1ps

module tb_vga();

reg clk_26;
reg rst_n;    

reg [3:0] io_b_address;
reg       io_b_write;
reg [7:0] io_b_writedata;

reg [3:0] io_c_address;
reg       io_c_write;
reg [7:0] io_c_writedata;

reg [3:0] io_d_address;
reg       io_d_write;
reg [7:0] io_d_writedata;

reg [16:0] mem_address;
reg        mem_write;
reg [7:0]  mem_writedata;

vga vga_inst(
    
    .clk_26             (clk_26),
    .rst_n              (rst_n),
    
    //avalon slave for system overlay
    .sys_address        (8'd0),     //input [7:0]
    .sys_read           (1'd0),     //input
    .sys_readdata       (),         //output [15:0]
    .sys_write          (1'd0),     //input
    .sys_writedata      (32'd0),    //input
    
    //avalon slave vga io
    .io_b_address       (io_b_address),     //input [3:0]
    .io_b_read          (1'b0),     //input
    .io_b_readdata      (),         //output [7:0]
    .io_b_write         (io_b_write),     //input
    .io_b_writedata     (io_b_writedata),     //input [7:0]
    
    //avalon slave vga io
    .io_c_address       (io_c_address),     //input [3:0]
    .io_c_read          (1'b0),     //input
    .io_c_readdata      (),         //output [7:0]
    .io_c_write         (io_c_write),     //input
    .io_c_writedata     (io_c_writedata),     //input [7:0]
             
    //avalon slave vga io
    .io_d_address       (io_d_address),     //input [3:0]
    .io_d_read          (1'b0),     //input
    .io_d_readdata      (),         //output [7:0]
    .io_d_write         (io_d_write),     //input
    .io_d_writedata     (io_d_writedata),     //input [7:0]
             
    //avalon slave vga memory
    .mem_address        (mem_address),    //input [16:0]
    .mem_read           (1'b0),     //input
    .mem_readdata       (),         //output [7:0]
    .mem_write          (mem_write),     //input
    .mem_writedata      (mem_writedata),     //input [7:0]

    //vga
    .vga_clock      (), //output
    .vga_sync_n     (), //output
    .vga_blank_n    (), //output
    .vga_horiz_sync (), //output
    .vga_vert_sync  (), //output
    
    .vga_r          (), //output [7:0]
    .vga_g          (), //output [7:0]
    .vga_b          () //output [7:0]
);

initial begin
    clk_26 = 1'b0;
    forever #5 clk_26 = ~clk_26;
end

integer finished = 0;

`define WRITE_B(addr, data) \
    io_b_write = 1'b1;      \
    io_b_address = addr;    \
    io_b_writedata = data;  \
    #10                     \
    io_b_write = 1'b0;

`define WRITE_C(addr, data) \
    io_c_write = 1'b1;      \
    io_c_address = addr;    \
    io_c_writedata = data;  \
    #10                     \
    io_c_write = 1'b0;

`define WRITE_D(addr, data) \
    io_d_write = 1'b1;      \
    io_d_address = addr;    \
    io_d_writedata = data;  \
    #10                     \
    io_d_write = 1'b0;
    
`define WRITE_MEM(addr, data) \
    mem_write = 1'b1;      \
    mem_address = addr;    \
    mem_writedata = data;  \
    #10                     \
    mem_write = 1'b0;

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
    
    io_c_write = 1'b0;
    io_c_address = 4'h0;
    io_c_writedata = 8'h00;
    
    io_b_write = 1'b0;
    io_b_address = 4'h0;
    io_b_writedata = 8'h00;
    
    io_d_write = 1'b0;
    io_d_address = 4'h0;
    io_d_writedata = 8'h00;
    
    mem_write     = 1'b0;
    mem_writedata = 8'h00;
    mem_address   = 17'h00000;
    
    
    rst_n = 1'b0;
    #10 rst_n = 1'b1;
    
    #10;
    
    // write color to dac
    `WRITE_C(4'h8, 8'h1)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h01)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h02)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h03)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h04)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h05)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h06)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h07)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h08)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h09)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h0a)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h0b)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h0c)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h0d)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h0e)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h0f)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h10)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h11)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h12)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h13)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h14)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h15)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h16)
    `WRITE_C(4'h9, 8'h00)
    
    `WRITE_C(4'h9, 8'h00)
    `WRITE_C(4'h9, 8'h17)
    `WRITE_C(4'h9, 8'h00)
    
    //TEST mode 0x13
    
    //write pixel in mode 0x13
    //`WRITE_MEM(17'h0013F, 8'h01)

    
    //TEST mode 0x01
    /*
    //disable chained mode and odd/even mode
    `WRITE_C(4'h4, 8'h04);
    `WRITE_C(4'h5, 8'h06);

    //enable page 2 write
    `WRITE_C(4'h4, 8'h02)
    `WRITE_C(4'h5, 8'h04)

    //load font data
    `WRITE_MEM(17'h0, 8'h81);
    `WRITE_MEM(17'h1, 8'h99);
    
    //load sequencer
    `WRITE_C(4, 1)
        `WRITE_C(5, 8'h08)
    `WRITE_C(4, 2)
        `WRITE_C(5, 8'h03)
    `WRITE_C(4, 3)
        `WRITE_C(5, 8'h00)
    `WRITE_C(4, 4)
        `WRITE_C(5, 8'h02)
    
     //load misc
    `WRITE_C(2, 8'h67)
    
    //load crtc -- disable protect
    `WRITE_D(4, 5'h11)
    `WRITE_D(5, 8'h8E & 8'h7F);
    
    `WRITE_D(4, 5'h00)
        `WRITE_D(5, 8'h2d)
    `WRITE_D(4, 5'h01)
        `WRITE_D(5, 8'h27)
    `WRITE_D(4, 5'h02)
        `WRITE_D(5, 8'h28)
    `WRITE_D(4, 5'h03)
        `WRITE_D(5, 8'h90)
    `WRITE_D(4, 5'h04)
        `WRITE_D(5, 8'h2b)
    `WRITE_D(4, 5'h05)
        `WRITE_D(5, 8'ha0)
    `WRITE_D(4, 5'h06)
        `WRITE_D(5, 8'hbf)
    `WRITE_D(4, 5'h07)
        `WRITE_D(5, 8'h1f)
    `WRITE_D(4, 5'h08)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h09)
        `WRITE_D(5, 8'h4f)
    `WRITE_D(4, 5'h0A)
        `WRITE_D(5, 8'h0d)
    `WRITE_D(4, 5'h0B)
        `WRITE_D(5, 8'h0e)
    `WRITE_D(4, 5'h0C)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h0D)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h0E)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h0F)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h10)
        `WRITE_D(5, 8'h9c)
    `WRITE_D(4, 5'h11)
        `WRITE_D(5, 8'h8e)
    `WRITE_D(4, 5'h12)
        `WRITE_D(5, 8'h8f)
    `WRITE_D(4, 5'h13)
        `WRITE_D(5, 8'h14)
    `WRITE_D(4, 5'h14)
        `WRITE_D(5, 8'h1f)
    `WRITE_D(4, 5'h15)
        `WRITE_D(5, 8'h96)
    `WRITE_D(4, 5'h16)
        `WRITE_D(5, 8'hb9)
    `WRITE_D(4, 5'h17)
        `WRITE_D(5, 8'ha3)
    `WRITE_D(4, 5'h18)
        `WRITE_D(5, 8'hff)
    
    //load attrib
    `WRITE_C(0, 8'h20 | 8'h00)
        `WRITE_C(0, 8'h00)
    `WRITE_C(0, 8'h20 | 8'h01)
        `WRITE_C(0, 8'h01)
    `WRITE_C(0, 8'h20 | 8'h02)
        `WRITE_C(0, 8'h02)
    `WRITE_C(0, 8'h20 | 8'h03)
        `WRITE_C(0, 8'h03)
    `WRITE_C(0, 8'h20 | 8'h04)
        `WRITE_C(0, 8'h04)
    `WRITE_C(0, 8'h20 | 8'h05)
        `WRITE_C(0, 8'h05)
    `WRITE_C(0, 8'h20 | 8'h06)
        `WRITE_C(0, 8'h06)
    `WRITE_C(0, 8'h20 | 8'h07)
        `WRITE_C(0, 8'h07)
    `WRITE_C(0, 8'h20 | 8'h08)
        `WRITE_C(0, 8'h38)
    `WRITE_C(0, 8'h20 | 8'h09)
        `WRITE_C(0, 8'h39)
    `WRITE_C(0, 8'h20 | 8'h0A)
        `WRITE_C(0, 8'h3a)
    `WRITE_C(0, 8'h20 | 8'h0B)
        `WRITE_C(0, 8'h3b)
    `WRITE_C(0, 8'h20 | 8'h0C)
        `WRITE_C(0, 8'h3c)
    `WRITE_C(0, 8'h20 | 8'h0D)
        `WRITE_C(0, 8'h3d)
    `WRITE_C(0, 8'h20 | 8'h0E)
        `WRITE_C(0, 8'h3e)
    `WRITE_C(0, 8'h20 | 8'h0F)
        `WRITE_C(0, 8'h3f)
    `WRITE_C(0, 8'h20 | 8'h10)
        `WRITE_C(0, 8'h0c)
    `WRITE_C(0, 8'h20 | 8'h11)
        `WRITE_C(0, 8'h00)
    `WRITE_C(0, 8'h20 | 8'h12)
        `WRITE_C(0, 8'h0f)
    `WRITE_C(0, 8'h20 | 8'h13)
        `WRITE_C(0, 8'h08)
    
    //load graphic
    `WRITE_C(8'hE, 0)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 1)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 2)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 3)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 4)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 5)
        `WRITE_C(8'hF, 8'h10)
    `WRITE_C(8'hE, 6)
        `WRITE_C(8'hF, 8'h0e)
    `WRITE_C(8'hE, 7)
        `WRITE_C(8'hF, 8'h0f)
    `WRITE_C(8'hE, 8)
        `WRITE_C(8'hF, 8'hff)

    `WRITE_MEM(17'h18001, 8'h01)
    
    `WRITE_MEM(17'h1804f, 8'h01)
    */
    
    //test mode 0x07
    /*
    //disable chained mode and odd/even mode
    `WRITE_C(4'h4, 8'h04);
    `WRITE_C(4'h5, 8'h06);

    //enable page 2 write
    `WRITE_C(4'h4, 8'h02)
    `WRITE_C(4'h5, 8'h04)

    //load font data
    `WRITE_MEM(17'h0, 8'h81);
    `WRITE_MEM(17'h1, 8'h99);
    
    //load sequencer
    `WRITE_C(4, 1)
        `WRITE_C(5, 8'h00)
    `WRITE_C(4, 2)
        `WRITE_C(5, 8'h03)
    `WRITE_C(4, 3)
        `WRITE_C(5, 8'h00)
    `WRITE_C(4, 4)
        `WRITE_C(5, 8'h02)
    
     //load misc
    `WRITE_C(2, 8'h66)
    
    //load crtc -- disable protect
    `WRITE_B(4, 5'h11)
    `WRITE_B(5, 8'h8E & 8'h7F);
    
    `WRITE_B(4, 5'h00)
        `WRITE_B(5, 8'h5f)
    `WRITE_B(4, 5'h01)
        `WRITE_B(5, 8'h4f)
    `WRITE_B(4, 5'h02)
        `WRITE_B(5, 8'h50)
    `WRITE_B(4, 5'h03)
        `WRITE_B(5, 8'h82)
    `WRITE_B(4, 5'h04)
        `WRITE_B(5, 8'h55)
    `WRITE_B(4, 5'h05)
        `WRITE_B(5, 8'h81)
    `WRITE_B(4, 5'h06)
        `WRITE_B(5, 8'hbf)
    `WRITE_B(4, 5'h07)
        `WRITE_B(5, 8'h1f)
    `WRITE_B(4, 5'h08)
        `WRITE_B(5, 8'h00)
    `WRITE_B(4, 5'h09)
        `WRITE_B(5, 8'h4f)
    `WRITE_B(4, 5'h0A)
        `WRITE_B(5, 8'h0d)
    `WRITE_B(4, 5'h0B)
        `WRITE_B(5, 8'h0e)
    `WRITE_B(4, 5'h0C)
        `WRITE_B(5, 8'h00)
    `WRITE_B(4, 5'h0D)
        `WRITE_B(5, 8'h00)
    `WRITE_B(4, 5'h0E)
        `WRITE_B(5, 8'h00)
    `WRITE_B(4, 5'h0F)
        `WRITE_B(5, 8'h00)
    `WRITE_B(4, 5'h10)
        `WRITE_B(5, 8'h9c)
    `WRITE_B(4, 5'h11)
        `WRITE_B(5, 8'h8e)
    `WRITE_B(4, 5'h12)
        `WRITE_B(5, 8'h8f)
    `WRITE_B(4, 5'h13)
        `WRITE_B(5, 8'h28)
    `WRITE_B(4, 5'h14)
        `WRITE_B(5, 8'h0f)
    `WRITE_B(4, 5'h15)
        `WRITE_B(5, 8'h96)
    `WRITE_B(4, 5'h16)
        `WRITE_B(5, 8'hb9)
    `WRITE_B(4, 5'h17)
        `WRITE_B(5, 8'ha3)
    `WRITE_B(4, 5'h18)
        `WRITE_B(5, 8'hff)
        
    //load attrib
    `WRITE_C(0, 8'h20 | 8'h00)
        `WRITE_C(0, 8'h00)
    `WRITE_C(0, 8'h20 | 8'h01)
        `WRITE_C(0, 8'h08)
    `WRITE_C(0, 8'h20 | 8'h02)
        `WRITE_C(0, 8'h08)
    `WRITE_C(0, 8'h20 | 8'h03)
        `WRITE_C(0, 8'h08)
    `WRITE_C(0, 8'h20 | 8'h04)
        `WRITE_C(0, 8'h08)
    `WRITE_C(0, 8'h20 | 8'h05)
        `WRITE_C(0, 8'h08)
    `WRITE_C(0, 8'h20 | 8'h06)
        `WRITE_C(0, 8'h08)
    `WRITE_C(0, 8'h20 | 8'h07)
        `WRITE_C(0, 8'h08)
    `WRITE_C(0, 8'h20 | 8'h08)
        `WRITE_C(0, 8'h10)
    `WRITE_C(0, 8'h20 | 8'h09)
        `WRITE_C(0, 8'h18)
    `WRITE_C(0, 8'h20 | 8'h0A)
        `WRITE_C(0, 8'h18)
    `WRITE_C(0, 8'h20 | 8'h0B)
        `WRITE_C(0, 8'h18)
    `WRITE_C(0, 8'h20 | 8'h0C)
        `WRITE_C(0, 8'h18)
    `WRITE_C(0, 8'h20 | 8'h0D)
        `WRITE_C(0, 8'h18)
    `WRITE_C(0, 8'h20 | 8'h0E)
        `WRITE_C(0, 8'h18)
    `WRITE_C(0, 8'h20 | 8'h0F)
        `WRITE_C(0, 8'h18)
    `WRITE_C(0, 8'h20 | 8'h10)
        `WRITE_C(0, 8'h0e)
    `WRITE_C(0, 8'h20 | 8'h11)
        `WRITE_C(0, 8'h00)
    `WRITE_C(0, 8'h20 | 8'h12)
        `WRITE_C(0, 8'h0f)
    `WRITE_C(0, 8'h20 | 8'h13)
        `WRITE_C(0, 8'h08)
    
    //load graphic
    `WRITE_C(8'hE, 0)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 1)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 2)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 3)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 4)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 5)
        `WRITE_C(8'hF, 8'h10)
    `WRITE_C(8'hE, 6)
        `WRITE_C(8'hF, 8'h0a)
    `WRITE_C(8'hE, 7)
        `WRITE_C(8'hF, 8'h0f)
    `WRITE_C(8'hE, 8)
        `WRITE_C(8'hF, 8'hff)

    `WRITE_MEM(17'h10001, 8'h01)
    
    `WRITE_MEM(17'h1009f, 8'h01)
    */
    
    //test mode 0x04

    `WRITE_C(4, 1)
        `WRITE_C(5, 8'h09)
    `WRITE_C(4, 2)
        `WRITE_C(5, 8'h03)
    `WRITE_C(4, 3)
        `WRITE_C(5, 8'h00)
    `WRITE_C(4, 4)
        `WRITE_C(5, 8'h02)
    
     //load misc
    `WRITE_C(2, 8'h63)
    
    //load crtc -- disable protect
    `WRITE_D(4, 5'h11)
    `WRITE_D(5, 8'h8E & 8'h7F);
    
    `WRITE_D(4, 5'h00)
        `WRITE_D(5, 8'h2d)
    `WRITE_D(4, 5'h01)
        `WRITE_D(5, 8'h27)
    `WRITE_D(4, 5'h02)
        `WRITE_D(5, 8'h28)
    `WRITE_D(4, 5'h03)
        `WRITE_D(5, 8'h90)
    `WRITE_D(4, 5'h04)
        `WRITE_D(5, 8'h2b)
    `WRITE_D(4, 5'h05)
        `WRITE_D(5, 8'h80)
    `WRITE_D(4, 5'h06)
        `WRITE_D(5, 8'hbf)
    `WRITE_D(4, 5'h07)
        `WRITE_D(5, 8'h1f)
    `WRITE_D(4, 5'h08)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h09)
        `WRITE_D(5, 8'hc1)
    `WRITE_D(4, 5'h0A)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h0B)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h0C)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h0D)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h0E)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h0F)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h10)
        `WRITE_D(5, 8'h9c)
    `WRITE_D(4, 5'h11)
        `WRITE_D(5, 8'h8e)
    `WRITE_D(4, 5'h12)
        `WRITE_D(5, 8'h8f)
    `WRITE_D(4, 5'h13)
        `WRITE_D(5, 8'h14)
    `WRITE_D(4, 5'h14)
        `WRITE_D(5, 8'h00)
    `WRITE_D(4, 5'h15)
        `WRITE_D(5, 8'h96)
    `WRITE_D(4, 5'h16)
        `WRITE_D(5, 8'hb9)
    `WRITE_D(4, 5'h17)
        `WRITE_D(5, 8'ha2)
    `WRITE_D(4, 5'h18)
        `WRITE_D(5, 8'hff)
    
        
    //load attrib
    `WRITE_C(0, 8'h20 | 8'h00)
        `WRITE_C(0, 8'h00)
    `WRITE_C(0, 8'h20 | 8'h01)
        `WRITE_C(0, 8'h13)
    `WRITE_C(0, 8'h20 | 8'h02)
        `WRITE_C(0, 8'h15)
    `WRITE_C(0, 8'h20 | 8'h03)
        `WRITE_C(0, 8'h17)
    `WRITE_C(0, 8'h20 | 8'h04)
        `WRITE_C(0, 8'h02)
    `WRITE_C(0, 8'h20 | 8'h05)
        `WRITE_C(0, 8'h04)
    `WRITE_C(0, 8'h20 | 8'h06)
        `WRITE_C(0, 8'h06)
    `WRITE_C(0, 8'h20 | 8'h07)
        `WRITE_C(0, 8'h07)
    `WRITE_C(0, 8'h20 | 8'h08)
        `WRITE_C(0, 8'h10)
    `WRITE_C(0, 8'h20 | 8'h09)
        `WRITE_C(0, 8'h11)
    `WRITE_C(0, 8'h20 | 8'h0A)
        `WRITE_C(0, 8'h12)
    `WRITE_C(0, 8'h20 | 8'h0B)
        `WRITE_C(0, 8'h13)
    `WRITE_C(0, 8'h20 | 8'h0C)
        `WRITE_C(0, 8'h14)
    `WRITE_C(0, 8'h20 | 8'h0D)
        `WRITE_C(0, 8'h15)
    `WRITE_C(0, 8'h20 | 8'h0E)
        `WRITE_C(0, 8'h16)
    `WRITE_C(0, 8'h20 | 8'h0F)
        `WRITE_C(0, 8'h17)
    `WRITE_C(0, 8'h20 | 8'h10)
        `WRITE_C(0, 8'h01)
    `WRITE_C(0, 8'h20 | 8'h11)
        `WRITE_C(0, 8'h00)
    `WRITE_C(0, 8'h20 | 8'h12)
        `WRITE_C(0, 8'h03)
    `WRITE_C(0, 8'h20 | 8'h13)
        `WRITE_C(0, 8'h00)
    
    //load graphic
    `WRITE_C(8'hE, 0)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 1)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 2)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 3)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 4)
        `WRITE_C(8'hF, 8'h00)
    `WRITE_C(8'hE, 5)
        `WRITE_C(8'hF, 8'h30)
    `WRITE_C(8'hE, 6)
        `WRITE_C(8'hF, 8'h0f)
    `WRITE_C(8'hE, 7)
        `WRITE_C(8'hF, 8'h0f)
    `WRITE_C(8'hE, 8)
        `WRITE_C(8'hF, 8'hff)

    `WRITE_MEM(17'h18000, 8'hC0 | 8'h20 | 8'h04 | 8'h3);
    
    `WRITE_MEM(17'h1804f, 8'hC0 | 8'h20 | 8'h04 | 8'h3);
    
    while(finished == 0) begin
        if($time > 5000000) $finish_and_return(-1);
        #10;
        
        //$dumpflush();
    end
    
    #60;
    
    $dumpoff();
    $finish_and_return(0);
end


endmodule
