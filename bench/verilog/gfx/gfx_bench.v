`include "../../../rtl/verilog/gfx/gfx_wbs.v"
`include "../../../rtl/verilog/gfx/gfx_wbm_write.v"
`include "../../../rtl/verilog/gfx/gfx_wbm_read.v"
`include "../../../rtl/verilog/gfx/gfx_rasterizer.v"
`include "../../../rtl/verilog/gfx/gfx_clip.v"
`include "../../../rtl/verilog/gfx/gfx_fragment_processor.v"
`include "../../../rtl/verilog/gfx/gfx_blender.v"
`include "../../../rtl/verilog/gfx/gfx_renderer.v"
`include "../../../rtl/verilog/gfx/gfx_top.v"
`include "../../../rtl/verilog/gfx/basic_fifo.v"
`include "../../../rtl/verilog/gfx/gfx_color.v"
`include "../../../rtl/verilog/gfx/gfx_wbm_read_arbiter.v"
`include "../../../rtl/verilog/gfx/gfx_line.v"
`include "../../../rtl/verilog/gfx/gfx_triangle.v"
`include "../../../rtl/verilog/gfx/div_uu.v"
`include "../../../rtl/verilog/gfx/gfx_transform.v"
`include "../../../rtl/verilog/gfx/gfx_interp.v"
`include "../../../rtl/verilog/gfx/gfx_cuvz.v"

module gfx_bench();

parameter point_width    = 16;
parameter subpixel_width = 16;
parameter fifo_depth     = 10;

`include "../../../rtl/verilog/gfx/gfx_params.v"

// GENERATE PARAMETERS FROM gfx_params.v
parameter GFX_CTRL_CD8         = 0; // Color Depth 8 
parameter GFX_CTRL_CD16        = 1 << GFX_CTRL_COLOR_DEPTH; // Color Depth 16 
parameter GFX_CTRL_CD24        = 2 << GFX_CTRL_COLOR_DEPTH; // Color Depth 24  Not supported!
parameter GFX_CTRL_CD32        = 3 << GFX_CTRL_COLOR_DEPTH; // Color Depth 32 
parameter GFX_CTRL_CDMASK      = 3 << GFX_CTRL_COLOR_DEPTH; // All color depth bits 
parameter GFX_TEXTURE_ENABLE   = 1 << GFX_CTRL_TEXTURE;     // Enable Texture Reads 
parameter GFX_BLEND_ENABLE     = 1 << GFX_CTRL_BLENDING;    // Enable Alpha Blending 
parameter GFX_COLORKEY_ENABLE  = 1 << GFX_CTRL_COLORKEY;    // Enable Colorkeying 
parameter GFX_CLIPPING_ENABLE  = 1 << GFX_CTRL_CLIPPING;    // Enable Clipping/Scissoring 
parameter GFX_ZBUFFER_ENABLE   = 1 << GFX_CTRL_ZBUFFER;     // Enable depth buffer

parameter GFX_DRAW_RECT        = 1 << GFX_CTRL_RECT;        // Put rect  
parameter GFX_DRAW_LINE        = 1 << GFX_CTRL_LINE;        // Put line  
parameter GFX_DRAW_TRI         = 1 << GFX_CTRL_TRI;         // Put triangle

parameter GFX_DRAW_CURVE       = 1 << GFX_CTRL_CURVE;       // Put curve
parameter GFX_INTERP           = 1 << GFX_CTRL_INTERP;      // Interpolation active (triangles)
parameter GFX_INSIDE           = 1 << GFX_CTRL_INSIDE;      // Inside 

parameter GFX_ACTIVE_POINT0    = 0;
parameter GFX_ACTIVE_POINT1    = 1 << GFX_CTRL_ACTIVE_POINT;
parameter GFX_ACTIVE_POINT2    = 2 << GFX_CTRL_ACTIVE_POINT;
parameter GFX_ACTIVE_POINTMASK = 3 << GFX_CTRL_ACTIVE_POINT;
parameter GFX_FORWARD_POINT    = 1 << GFX_CTRL_FORWARD_POINT;
parameter GFX_TRANSFORM_POINT  = 1 << GFX_CTRL_TRANSFORM_POINT;

// Common wishbone signals
reg         wb_clk_i;    // master clock reg
reg         wb_rst_i;    // Asynchronous active high reset
wire        wb_inta_o;   // interrupt

// Wishbone master signals (write)
wire        wbm_write_cyc_o;    // cycle wire
wire        wbm_write_stb_o;    // strobe wire
wire [ 2:0] wbm_write_cti_o;    // cycle type id
wire [ 1:0] wbm_write_bte_o;    // burst type extension
wire        wbm_write_we_o;     // write enable wire
wire [31:0] wbm_write_adr_o;    // address wire
wire [ 3:0] wbm_write_sel_o;    // byte select wires (only 32bits accesses are supported)
reg         wbm_write_ack_i;    // wishbone cycle acknowledge
reg         wbm_write_err_i;    // wishbone cycle error
wire [31:0] wbm_write_dat_o;    // wishbone data out

// Wishbone master signals (read)
wire        wbm_read_cyc_o;    // cycle wire
wire        wbm_read_stb_o;    // strobe wire
wire [ 2:0] wbm_read_cti_o;    // cycle type id
wire [ 1:0] wbm_read_bte_o;    // burst type extension
wire        wbm_read_we_o;     // write enable wire
wire [31:0] wbm_read_adr_o;    // address wire
wire [ 3:0] wbm_read_sel_o;    // byte select wires (only 32bits accesses are supported)
reg         wbm_read_ack_i;    // wishbone cycle acknowledge
reg         wbm_read_err_i;    // wishbone cycle error
reg  [31:0] wbm_read_dat_i;    // wishbone data in

// Wishbone slave signals
reg         wbs_cyc_i;    // cycle reg
reg         wbs_stb_i;    // strobe reg
reg  [ 2:0] wbs_cti_i;    // cycle type id
reg  [ 1:0] wbs_bte_i;    // burst type extension
reg         wbs_we_i;     // write enable reg
reg  [31:0] wbs_adr_i;    // address reg
reg  [ 3:0] wbs_sel_i;    // byte select reg (only 32bits accesses are supported)
wire        wbs_ack_o;    // wishbone cycle acknowledge
wire        wbs_err_o;    // wishbone cycle error
reg  [31:0] wbs_dat_i;    // wishbone data in
wire [31:0] wbs_dat_o;    // wishbone data out

parameter GFX_VMEM            = 32'h00800000;

initial begin
  $dumpfile("gfx.vcd");
  $dumpvars(0,gfx_bench);

// init values
  wb_clk_i = 0;
  wb_rst_i = 1;
  wbm_write_ack_i = 0;
  wbm_read_ack_i = 0;
  wbm_write_err_i = 0;
  wbm_read_err_i = 0;
  wbs_cyc_i = 0;
  wbs_cti_i = 0;
  wbs_bte_i = 0;
  wbs_adr_i = 0;
  wbs_sel_i = 4'b1111;
  wbs_dat_i = 0;

  // Can be high all the time
  wbs_we_i   = 1;
  wbs_stb_i  = 1;

//  wbm_read_dat_i = 32'hf18ff18f;

  // Set the texture read pixel
  wbm_read_dat_i = 32'h00000000;

  // Finish the reset of the component
  #2 wb_rst_i = 0;


  // Initialize color register
  #2 wbs_cyc_i  = 1;
  wbs_adr_i = GFX_COLOR0;
  wbs_dat_i = 32'h12345671;
  #4 wbs_cyc_i  = 0;

  // Initialize traget base
  #2 wbs_cyc_i  = 1;
  wbs_dat_i  = GFX_VMEM;
  wbs_adr_i  = GFX_TARGET_BASE;
  #4 wbs_cyc_i = 0;

  // oc_gfx_set_videomode(640, 480, 16);
  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 640;
  wbs_adr_i  = GFX_TARGET_SIZE_X;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 480;
  wbs_adr_i  = GFX_TARGET_SIZE_Y;
  #4 wbs_cyc_i = 0;

  // Set 16 bit color depth
  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_CTRL_CD16;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;

// Enable colorkey
  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h0000F18F; // pink color
  wbs_adr_i  = GFX_COLORKEY;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_COLORKEY_ENABLE | GFX_CTRL_CD16;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;

  // set cliparea
  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 0;
  wbs_adr_i  = GFX_CLIP_PIXEL0_X; // Clip Pixel 0
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 0;
  wbs_adr_i  = GFX_CLIP_PIXEL0_Y; // Clip Pixel 0
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 640;
  wbs_adr_i  = GFX_CLIP_PIXEL1_X; // Clip Pixel 1
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 480;
  wbs_adr_i  = GFX_CLIP_PIXEL1_Y; // Clip Pixel 1
  #4 wbs_cyc_i = 0;

// oc_gfx_enable_tex0(1)
  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_TEXTURE_ENABLE | GFX_COLORKEY_ENABLE | GFX_CTRL_CD16;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;

// oc_gfx_bind_tex0(0x01f00000, 10, 10)
  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_VMEM;
  wbs_adr_i  = GFX_TEX0_BASE;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 10;
  wbs_adr_i  = GFX_TEX0_SIZE_X;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 10;
  wbs_adr_i  = GFX_TEX0_SIZE_Y;
  #4 wbs_cyc_i = 0;

// oc_gfx_curve(10, 10, 10, 15, 15, 15, 15, 10, 0xf800f800);
  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 10 << subpixel_width;
  wbs_adr_i  = GFX_DEST_PIXEL_X;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 10 << subpixel_width;
  wbs_adr_i  = GFX_DEST_PIXEL_Y;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_TEXTURE_ENABLE | GFX_COLORKEY_ENABLE | GFX_CTRL_CD16 | GFX_ACTIVE_POINT0 | GFX_FORWARD_POINT;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;

  // p1.x = 10

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 15 << subpixel_width;
  wbs_adr_i  = GFX_DEST_PIXEL_Y;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_TEXTURE_ENABLE | GFX_COLORKEY_ENABLE | GFX_CTRL_CD16 | GFX_ACTIVE_POINT2 | GFX_FORWARD_POINT;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 15 << subpixel_width;
  wbs_adr_i  = GFX_DEST_PIXEL_X;
  #4 wbs_cyc_i = 0;

  // p2.y = 15
  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_TEXTURE_ENABLE | GFX_COLORKEY_ENABLE | GFX_CTRL_CD16 | GFX_ACTIVE_POINT1 | GFX_FORWARD_POINT;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 0;
  wbs_adr_i  = GFX_U0;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 0;
  wbs_adr_i  = GFX_V0;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 100;
  wbs_adr_i  = GFX_U1;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 0;
  wbs_adr_i  = GFX_V1;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 100;
  wbs_adr_i  = GFX_U2;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 100;
  wbs_adr_i  = GFX_V2;
  #4 wbs_cyc_i = 0;
/*
  // p3.x = 15

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 10 << subpixel_width;
  wbs_adr_i  = GFX_DEST_PIXEL_Y;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_TEXTURE_ENABLE | GFX_COLORKEY_ENABLE | GFX_CTRL_CD16 | GFX_ACTIVE_POINT3 | GFX_FORWARD_POINT;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;
*/

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 32'hf800f800; // Red
  wbs_adr_i  = GFX_COLOR0;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1; // TODO CURVE
  wbs_dat_i  = GFX_DRAW_TRI | GFX_DRAW_CURVE | GFX_INTERP | GFX_CTRL_CD16 | GFX_TEXTURE_ENABLE; // | GFX_BEZIER_FILL;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;

  // After a while, set every pixel read to the color key (demonstrates that colorkeyed pixels are not written)
  #200 wbm_read_dat_i = 32'hf18ff18f;

  // TODO: Demonstrate alpha blending



  wbm_read_dat_i = #40 32'hffffffff;

// Draw a Rectangle
// oc_gfx_rect(110, 110, 115, 115, 0xf800f800);
  #200 wbs_cyc_i = 1;
  wbs_dat_i  = 110 << 16; // (110 << 16) | 110
  wbs_adr_i  = GFX_DEST_PIXEL_X;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 110 << 16; // (110 << 16) | 110
  wbs_adr_i  = GFX_DEST_PIXEL_Y;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_TEXTURE_ENABLE | GFX_COLORKEY_ENABLE | GFX_CTRL_CD16 | GFX_ACTIVE_POINT0 | GFX_FORWARD_POINT;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 115 << 16; // (115 << 16) | 115
  wbs_adr_i  = GFX_DEST_PIXEL_X;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 115 << 16; // (115 << 16) | 115
  wbs_adr_i  = GFX_DEST_PIXEL_Y;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_TEXTURE_ENABLE | GFX_COLORKEY_ENABLE | GFX_CTRL_CD16 | GFX_ACTIVE_POINT1 | GFX_FORWARD_POINT;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1; // Draw the rect
  wbs_dat_i  = GFX_DRAW_RECT | GFX_CTRL_CD16;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;

  // Draw a bunch of lines

  //draw line ############### 1
  #200 wbs_cyc_i = 1;
  wbs_dat_i  = 4;
  wbs_adr_i  = GFX_DEST_PIXEL_X;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 4;
  wbs_adr_i  = GFX_DEST_PIXEL_Y;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_TEXTURE_ENABLE | GFX_COLORKEY_ENABLE | GFX_CTRL_CD16 | GFX_ACTIVE_POINT0 | GFX_FORWARD_POINT;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 8;
  wbs_adr_i  = GFX_DEST_PIXEL_X;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 6;
  wbs_adr_i  = GFX_DEST_PIXEL_Y;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_TEXTURE_ENABLE | GFX_COLORKEY_ENABLE | GFX_CTRL_CD16 | GFX_ACTIVE_POINT1 | GFX_FORWARD_POINT;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_DRAW_LINE | GFX_CTRL_CD16;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;
  //#########################
/*
  //draw line ############### 2
  #100 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00040004; // (110 << 16) | 110
  wbs_adr_i  = GFX_DEST_PIXEL0;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00060008; // (115 << 16) | 115
  wbs_adr_i  = GFX_DEST_PIXEL1;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_CONTROL_LINE | GFX_CONTROL_CD16 | GFX_CLIPPING_ENABLE;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;
  //#########################

  //draw line ############### 3
  #10 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00040004; // (110 << 16) | 110
  wbs_adr_i  = GFX_DEST_PIXEL0;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00020008; // (115 << 16) | 115
  wbs_adr_i  = GFX_DEST_PIXEL1;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_CONTROL_LINE | GFX_CONTROL_CD16;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;
  //#########################

  //draw line ############### 4
  #10 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00040004; // (110 << 16) | 110
  wbs_adr_i  = GFX_DEST_PIXEL0;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00000006; // (115 << 16) | 115
  wbs_adr_i  = GFX_DEST_PIXEL1;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_CONTROL_LINE | GFX_CONTROL_CD16;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;
  //#########################

  //draw line ############### 5
  #10 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00040004; // (110 << 16) | 110
  wbs_adr_i  = GFX_DEST_PIXEL0;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00000002; // (115 << 16) | 115
  wbs_adr_i  = GFX_DEST_PIXEL1;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_CONTROL_LINE | GFX_CONTROL_CD16;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;
  //#########################

  //draw line ############### 6
  #10 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00040004; // (110 << 16) | 110
  wbs_adr_i  = GFX_DEST_PIXEL0;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00020000; // (115 << 16) | 115
  wbs_adr_i  = GFX_DEST_PIXEL1;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_CONTROL_LINE | GFX_CONTROL_CD16;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;
  //#########################

  //draw line ############### 7
  #10 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00040004; // (110 << 16) | 110
  wbs_adr_i  = GFX_DEST_PIXEL0;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00060000; // (115 << 16) | 115
  wbs_adr_i  = GFX_DEST_PIXEL1;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_CONTROL_LINE | GFX_CONTROL_CD16;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;
  //#########################

  //draw line ############### 8
  #10 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00040004; // (110 << 16) | 110
  wbs_adr_i  = GFX_DEST_PIXEL0;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = 32'h00080002; // (115 << 16) | 115
  wbs_adr_i  = GFX_DEST_PIXEL1;
  #4 wbs_cyc_i = 0;

  #2 wbs_cyc_i = 1;
  wbs_dat_i  = GFX_CONTROL_LINE | GFX_CONTROL_CD16;
  wbs_adr_i  = GFX_CONTROL;
  #4 wbs_cyc_i = 0;
  //#########################
*/
  #10000 $finish;
end

// Set up ack behaviour from memory circuits
always @(posedge wb_clk_i)
begin
  wbm_write_ack_i <= #1 wbm_write_cyc_o & !wbm_write_ack_i;
  wbm_read_ack_i  <= #1 wbm_read_cyc_o  & !wbm_read_ack_i;
end

// Set up clock
always begin
  #1 wb_clk_i = ~wb_clk_i;
end

// Instansiate module
gfx_top top(
.wb_clk_i (wb_clk_i),
.wb_rst_i (wb_rst_i),
.wb_inta_o (wb_inta_o),
// Wishbone master signals (interfaces with video memory)
.wbm_write_cyc_o (wbm_write_cyc_o),
.wbm_write_stb_o (wbm_write_stb_o),
.wbm_write_cti_o (wbm_write_cti_o),
.wbm_write_bte_o (wbm_write_bte_o),
.wbm_write_we_o (wbm_write_we_o),
.wbm_write_adr_o (wbm_write_adr_o),
.wbm_write_sel_o (wbm_write_sel_o),
.wbm_write_ack_i (wbm_write_ack_i),
.wbm_write_err_i (wbm_write_err_i),
.wbm_write_dat_o (wbm_write_dat_o),
// Wishbone master signals (interfaces with video memory)
.wbm_read_cyc_o (wbm_read_cyc_o),
.wbm_read_stb_o (wbm_read_stb_o),
.wbm_read_cti_o (wbm_read_cti_o),
.wbm_read_bte_o (wbm_read_bte_o),
.wbm_read_we_o (wbm_read_we_o),
.wbm_read_adr_o (wbm_read_adr_o),
.wbm_read_sel_o (wbm_read_sel_o),
.wbm_read_ack_i (wbm_read_ack_i),
.wbm_read_err_i (wbm_read_err_i),
.wbm_read_dat_i (wbm_read_dat_i),
// Wishbone slave signals (interfaces with main bus/CPU)
.wbs_cyc_i (wbs_cyc_i),
.wbs_stb_i (wbs_stb_i), 
.wbs_cti_i (wbs_cti_i), 
.wbs_bte_i (wbs_bte_i), 
.wbs_we_i (wbs_we_i), 
.wbs_adr_i (wbs_adr_i), 
.wbs_sel_i (wbs_sel_i), 
.wbs_ack_o (wbs_ack_o), 
.wbs_err_o (wbs_err_o), 
.wbs_dat_i (wbs_dat_i), 
.wbs_dat_o (wbs_dat_o)
);

defparam top.point_width    = point_width;
defparam top.subpixel_width = subpixel_width;
defparam top.fifo_depth     = fifo_depth;

endmodule
