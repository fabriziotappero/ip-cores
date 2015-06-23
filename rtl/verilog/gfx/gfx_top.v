/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

TOP MODULE

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

module gfx_top (wb_clk_i, wb_rst_i, wb_inta_o,
  // Wishbone master signals (interfaces with video memory, write)
  wbm_write_cyc_o, wbm_write_stb_o, wbm_write_cti_o, wbm_write_bte_o, wbm_write_we_o, wbm_write_adr_o, wbm_write_sel_o, wbm_write_ack_i, wbm_write_err_i, wbm_write_dat_o,
  // Wishbone master signals (interfaces with video memory, read)
  wbm_read_cyc_o, wbm_read_stb_o, wbm_read_cti_o, wbm_read_bte_o, wbm_read_we_o, wbm_read_adr_o, wbm_read_sel_o, wbm_read_ack_i, wbm_read_err_i, wbm_read_dat_i,
  // Wishbone slave signals (interfaces with main bus/CPU)
  wbs_cyc_i, wbs_stb_i, wbs_cti_i, wbs_bte_i, wbs_we_i, wbs_adr_i, wbs_sel_i, wbs_ack_o, wbs_err_o, wbs_dat_i, wbs_dat_o
);

// Set default parameters
parameter point_width    = 16;
parameter subpixel_width = 16;
parameter fifo_depth     = 10;

parameter REG_ADR_HIBIT = 9;

// Common wishbone signals
input         wb_clk_i;    // master clock input
input         wb_rst_i;    // Asynchronous active high reset
output        wb_inta_o;   // interrupt

// Wishbone master signals (write)
output        wbm_write_cyc_o;    // cycle output
output        wbm_write_stb_o;    // strobe output
output [ 2:0] wbm_write_cti_o;    // cycle type id
output [ 1:0] wbm_write_bte_o;    // burst type extension
output        wbm_write_we_o;     // write enable output
output [31:0] wbm_write_adr_o;    // address output
output [ 3:0] wbm_write_sel_o;    // byte select outputs (only 32bits accesses are supported)
input         wbm_write_ack_i;    // wishbone cycle acknowledge
input         wbm_write_err_i;    // wishbone cycle error
output [31:0] wbm_write_dat_o;    // wishbone data out

// Wishbone master signals (read)
output        wbm_read_cyc_o;    // cycle output
output        wbm_read_stb_o;    // strobe output
output [ 2:0] wbm_read_cti_o;    // cycle type id
output [ 1:0] wbm_read_bte_o;    // burst type extension
output        wbm_read_we_o;     // write enable output
output [31:0] wbm_read_adr_o;    // address output
output [ 3:0] wbm_read_sel_o;    // byte select outputs (only 32bits accesses are supported)
input         wbm_read_ack_i;    // wishbone cycle acknowledge
input         wbm_read_err_i;    // wishbone cycle error
input  [31:0] wbm_read_dat_i;    // wishbone data in

// Wishbone slave signals
input         wbs_cyc_i;    // cycle input
input         wbs_stb_i;    // strobe input
input  [ 2:0] wbs_cti_i;    // cycle type id
input  [ 1:0] wbs_bte_i;    // burst type extension
input         wbs_we_i;     // write enable input
input  [31:0] wbs_adr_i;    // address input
input  [ 3:0] wbs_sel_i;    // byte select input (only 32bits accesses are supported)
output        wbs_ack_o;    // wishbone cycle acknowledge
output        wbs_err_o;    // wishbone cycle error
input  [31:0] wbs_dat_i;    // wishbone data in
output [31:0] wbs_dat_o;    // wishbone data out

// Wires and variables

wire wbmwriter_sint; // connect to slave interface
wire wbmreader_sint;

wire vector_wbs_ack;
wire transform_wbs_ack;

wire            [31:2] target_base_reg;
wire [point_width-1:0] target_size_x_reg;
wire [point_width-1:0] target_size_y_reg;

wire            [31:2] wbs_fragment_tex0_base;
wire [point_width-1:0] wbs_fragment_tex0_size_x;
wire [point_width-1:0] wbs_fragment_tex0_size_y;

wire [31:2] render_wbmwriter_addr;
wire  [3:0] render_wbmwriter_sel;
wire [31:0] render_wbmwriter_dat;

wire [1:0] color_depth_reg;

wire render_wbmwriter_memory_pixel_write;
wire wbs_raster_rect_write;
wire wbs_raster_line_write;
wire wbs_raster_triangle_write;
wire wbs_raster_interpolate;

wire wbs_fragment_curve_write;

wire wbmwriter_render_ack;

// src pixel
wire [point_width-1:0] wbs_raster_src_pixel0_x;
wire [point_width-1:0] wbs_raster_src_pixel0_y;
wire [point_width-1:0] wbs_raster_src_pixel1_x;
wire [point_width-1:0] wbs_raster_src_pixel1_y;

// dest pixel
wire signed [point_width-1:-subpixel_width] wbs_transform_dest_pixel_x;
wire signed [point_width-1:-subpixel_width] wbs_transform_dest_pixel_y;
wire signed [point_width-1:-subpixel_width] wbs_transform_dest_pixel_z;
wire                           [1:0] wbs_transform_dest_pixel_id;

// transformation matrix
wire signed [point_width-1:-subpixel_width] wbs_transform_aa;
wire signed [point_width-1:-subpixel_width] wbs_transform_ab;
wire signed [point_width-1:-subpixel_width] wbs_transform_ac;
wire signed [point_width-1:-subpixel_width] wbs_transform_tx;
wire signed [point_width-1:-subpixel_width] wbs_transform_ba;
wire signed [point_width-1:-subpixel_width] wbs_transform_bb;
wire signed [point_width-1:-subpixel_width] wbs_transform_bc;
wire signed [point_width-1:-subpixel_width] wbs_transform_ty;
wire signed [point_width-1:-subpixel_width] wbs_transform_ca;
wire signed [point_width-1:-subpixel_width] wbs_transform_cb;
wire signed [point_width-1:-subpixel_width] wbs_transform_cc;
wire signed [point_width-1:-subpixel_width] wbs_transform_tz;

// clip pixel
wire [point_width-1:0] clip_pixel0_x_reg;
wire [point_width-1:0] clip_pixel0_y_reg;
wire [point_width-1:0] clip_pixel1_x_reg;
wire [point_width-1:0] clip_pixel1_y_reg;

wire [31:0] color0_reg;
wire [31:0] color1_reg;
wire [31:0] color2_reg;

wire [point_width-1:0] u0_reg;
wire [point_width-1:0] v0_reg;
wire [point_width-1:0] u1_reg;
wire [point_width-1:0] v1_reg;
wire [point_width-1:0] u2_reg;
wire [point_width-1:0] v2_reg;

wire [7:0] alpha0_reg;
wire [7:0] alpha1_reg;
wire [7:0] alpha2_reg;

wire texture_enable_reg;

wire        blending_enable_reg;
wire  [7:0] global_alpha_reg;
wire        colorkey_enable_reg;
wire [31:0] colorkey_reg;
wire        clipping_enable_reg;
wire        inside_reg;
wire        zbuffer_enable_reg;
wire [31:2] zbuffer_base_reg;

wire        wbs_transform_transform;
wire        wbs_transform_forward;

wire        raster_wbs_ack;

// Slave wishbone interface. Reads wishbone bus and fills registers
gfx_wbs wb_databus(
  .clk_i             (wb_clk_i),
  .rst_i             (wb_rst_i),
  .adr_i             (wbs_adr_i[REG_ADR_HIBIT:0]),
  .dat_i             (wbs_dat_i),
  .dat_o             (wbs_dat_o),
  .sel_i             (wbs_sel_i),
  .we_i              (wbs_we_i),
  .stb_i             (wbs_stb_i),
  .cyc_i             (wbs_cyc_i),
  .ack_o             (wbs_ack_o),
  .rty_o             (),
  .err_o             (wbs_err_o),
  .inta_o            (wb_inta_o),

  //source pixel
  .src_pixel0_x_o    (wbs_raster_src_pixel0_x),
  .src_pixel0_y_o    (wbs_raster_src_pixel0_y),
  .src_pixel1_x_o    (wbs_raster_src_pixel1_x),
  .src_pixel1_y_o    (wbs_raster_src_pixel1_y),
  //destination pixel
  .dest_pixel_x_o    (wbs_transform_dest_pixel_x),
  .dest_pixel_y_o    (wbs_transform_dest_pixel_y),
  .dest_pixel_z_o    (wbs_transform_dest_pixel_z),
  .dest_pixel_id_o   (wbs_transform_dest_pixel_id),
  //matrix
  .aa_o              (wbs_transform_aa),
  .ab_o              (wbs_transform_ab),
  .ac_o              (wbs_transform_ac),
  .tx_o              (wbs_transform_tx),
  .ba_o              (wbs_transform_ba),
  .bb_o              (wbs_transform_bb),
  .bc_o              (wbs_transform_bc),
  .ty_o              (wbs_transform_ty),
  .ca_o              (wbs_transform_ca),
  .cb_o              (wbs_transform_cb),
  .cc_o              (wbs_transform_cc),
  .tz_o              (wbs_transform_tz),
  .transform_point_o (wbs_transform_transform),
  .forward_point_o   (wbs_transform_forward),
  //clip pixel
  .clip_pixel0_x_o   (clip_pixel0_x_reg),
  .clip_pixel0_y_o   (clip_pixel0_y_reg),
  .clip_pixel1_x_o   (clip_pixel1_x_reg),
  .clip_pixel1_y_o   (clip_pixel1_y_reg),

  .color0_o          (color0_reg),
  .color1_o          (color1_reg),
  .color2_o          (color2_reg),

  .u0_o              (u0_reg),
  .v0_o              (v0_reg),
  .u1_o              (u1_reg),
  .v1_o              (v1_reg),
  .u2_o              (u2_reg),
  .v2_o              (v2_reg),

  .a0_o              (alpha0_reg),
  .a1_o              (alpha1_reg),
  .a2_o              (alpha2_reg),
  .global_alpha_o    (global_alpha_reg),

  .target_base_o     (target_base_reg),
  .target_size_x_o   (target_size_x_reg),
  .target_size_y_o   (target_size_y_reg),
  .tex0_base_o       (wbs_fragment_tex0_base),
  .tex0_size_x_o     (wbs_fragment_tex0_size_x),
  .tex0_size_y_o     (wbs_fragment_tex0_size_y),

  .color_depth_o     (color_depth_reg),

  .rect_write_o      (wbs_raster_rect_write),
  .line_write_o      (wbs_raster_line_write),
  .triangle_write_o  (wbs_raster_triangle_write),
  .curve_write_o     (wbs_fragment_curve_write),
  .interpolate_o     (wbs_raster_interpolate),

  .writer_sint_i     (wbmwriter_sint),
  .reader_sint_i     (wbmreader_sint),

  .pipeline_ack_i    (raster_wbs_ack),
  .transform_ack_i   (transform_wbs_ack),

  .texture_enable_o  (texture_enable_reg),
  .blending_enable_o (blending_enable_reg),
  .colorkey_enable_o (colorkey_enable_reg),
  .colorkey_o        (colorkey_reg),
  .clipping_enable_o (clipping_enable_reg),
  .inside_o          (inside_reg),
  .zbuffer_enable_o  (zbuffer_enable_reg),
  .zbuffer_base_o    (zbuffer_base_reg)
  );

defparam wb_databus.point_width    = point_width;
defparam wb_databus.subpixel_width = subpixel_width;
defparam wb_databus.fifo_depth     = fifo_depth;
defparam wb_databus.REG_ADR_HIBIT  = REG_ADR_HIBIT;

wire signed [point_width-1:-subpixel_width] transform_raster_dest_pixel0_x;
wire signed [point_width-1:-subpixel_width] transform_raster_dest_pixel0_y;
wire signed [point_width-1:-subpixel_width] transform_raster_dest_pixel1_x;
wire signed [point_width-1:-subpixel_width] transform_raster_dest_pixel1_y;
wire signed [point_width-1:-subpixel_width] transform_raster_dest_pixel2_x;
wire signed [point_width-1:-subpixel_width] transform_raster_dest_pixel2_y;

wire signed [point_width-1:0] transform_cuvz_dest_pixel0_z;
wire signed [point_width-1:0] transform_cuvz_dest_pixel1_z;
wire signed [point_width-1:0] transform_cuvz_dest_pixel2_z;

// Apply transforms to points
gfx_transform transform(
.clk_i           (wb_clk_i),
.rst_i           (wb_rst_i),
.x_i             (wbs_transform_dest_pixel_x),
.y_i             (wbs_transform_dest_pixel_y),
.z_i             (wbs_transform_dest_pixel_z),
.point_id_i      (wbs_transform_dest_pixel_id),
// Matrix
.aa              (wbs_transform_aa),
.ab              (wbs_transform_ab),
.ac              (wbs_transform_ac),
.tx              (wbs_transform_tx),
.ba              (wbs_transform_ba),
.bb              (wbs_transform_bb),
.bc              (wbs_transform_bc),
.ty              (wbs_transform_ty),
.ca              (wbs_transform_ca),
.cb              (wbs_transform_cb),
.cc              (wbs_transform_cc),
.tz              (wbs_transform_tz),
// Output points
.p0_x_o          (transform_raster_dest_pixel0_x),
.p0_y_o          (transform_raster_dest_pixel0_y),
.p0_z_o          (transform_cuvz_dest_pixel0_z),
.p1_x_o          (transform_raster_dest_pixel1_x),
.p1_y_o          (transform_raster_dest_pixel1_y),
.p1_z_o          (transform_cuvz_dest_pixel1_z),
.p2_x_o          (transform_raster_dest_pixel2_x),
.p2_y_o          (transform_raster_dest_pixel2_y),
.p2_z_o          (transform_cuvz_dest_pixel2_z),
.transform_i     (wbs_transform_transform),
.forward_i       (wbs_transform_forward),
.ack_o           (transform_wbs_ack)
);

defparam transform.point_width = point_width;
defparam transform.subpixel_width = subpixel_width;

wire raster_clip_write;
wire [point_width-1:0] raster_x_pixel;
wire [point_width-1:0] raster_y_pixel;
wire clip_ack;
wire raster_interp_write;
wire interp_raster_ack;
wire [point_width-1:0] raster_clip_u;
wire [point_width-1:0] raster_clip_v;

wire [2*point_width-1:0] raster_interp_edge0;
wire [2*point_width-1:0] raster_interp_edge1;
wire [2*point_width-1:0] raster_interp_area;

// Rasterizer generates pixels to calculate
gfx_rasterizer rasterizer0 (
  .clk_i            (wb_clk_i),
  .rst_i            (wb_rst_i),

  .clip_ack_i       (clip_ack),
  .interp_ack_i     (interp_raster_ack),
  .ack_o            (raster_wbs_ack),

  .rect_write_i	    (wbs_raster_rect_write),
  .line_write_i     (wbs_raster_line_write),
  .triangle_write_i (wbs_raster_triangle_write),
  .interpolate_i    (wbs_raster_interpolate),

  .texture_enable_i (texture_enable_reg),
  // source pixel coordinates
  .src_pixel0_x_i   (wbs_raster_src_pixel0_x),
  .src_pixel0_y_i   (wbs_raster_src_pixel0_y),
  .src_pixel1_x_i   (wbs_raster_src_pixel1_x),
  .src_pixel1_y_i   (wbs_raster_src_pixel1_y),

  // destination pixel coordinates
  .dest_pixel0_x_i  (transform_raster_dest_pixel0_x),
  .dest_pixel0_y_i  (transform_raster_dest_pixel0_y),
  .dest_pixel1_x_i  (transform_raster_dest_pixel1_x),
  .dest_pixel1_y_i  (transform_raster_dest_pixel1_y),
  .dest_pixel2_x_i  (transform_raster_dest_pixel2_x),
  .dest_pixel2_y_i  (transform_raster_dest_pixel2_y),

  // clip pixel coordinates
  .clipping_enable_i       (clipping_enable_reg),
  .clip_pixel0_x_i         (clip_pixel0_x_reg),
  .clip_pixel0_y_i         (clip_pixel0_y_reg),
  .clip_pixel1_x_i         (clip_pixel1_x_reg),
  .clip_pixel1_y_i         (clip_pixel1_y_reg),	

  // Screen size
  .target_size_x_i  (target_size_x_reg),
  .target_size_y_i  (target_size_y_reg),

  // Output pixel
  .x_counter_o 	    (raster_x_pixel),
  .y_counter_o 	    (raster_y_pixel),
  .u_o              (raster_clip_u),
  .v_o              (raster_clip_v),
  .clip_write_o     (raster_clip_write),
  // To interp
  .triangle_edge0_o (raster_interp_edge0),
  .triangle_edge1_o (raster_interp_edge1),
  .triangle_area_o  (raster_interp_area),
  .interp_write_o   (raster_interp_write)
  );

defparam rasterizer0.point_width = point_width;
defparam rasterizer0.subpixel_width = subpixel_width;
defparam rasterizer0.delay_width  = 5; // log2(point_width+1)

wire [point_width-1:0] interp_cuvz_x;
wire [point_width-1:0] interp_cuvz_y;

wire [point_width-1:0] interp_cuvz_factor0;
wire [point_width-1:0] interp_cuvz_factor1;

wire                   interp_cuvz_write;

wire                   cuvz_interp_ack;

gfx_interp interp(
.clk_i     (wb_clk_i),
.rst_i     (wb_rst_i),
.ack_i     (cuvz_interp_ack),
.ack_o     (interp_raster_ack),
.write_i   (raster_interp_write),
.edge0_i   (raster_interp_edge0),
.edge1_i   (raster_interp_edge1),
.area_i    (raster_interp_area),
.x_i       (raster_x_pixel),
.y_i       (raster_y_pixel),
.x_o       (interp_cuvz_x),
.y_o       (interp_cuvz_y),
.factor0_o (interp_cuvz_factor0),
.factor1_o (interp_cuvz_factor1),
.write_o   (interp_cuvz_write)
);

defparam interp.point_width  = point_width;
defparam interp.delay_width  = 5; // log2(point_width+1)
defparam interp.result_width = 4; // 16 pipeline slots

wire [point_width-1:0] cuvz_clip_x;
wire [point_width-1:0] cuvz_clip_y;
wire signed [point_width-1:0] cuvz_clip_z;
wire [point_width-1:0] cuvz_clip_u;
wire [point_width-1:0] cuvz_clip_v;
wire             [7:0] cuvz_clip_alpha;
wire [point_width-1:0] cuvz_clip_bezier_factor0;
wire [point_width-1:0] cuvz_clip_bezier_factor1;
wire                   cuvz_clip_write;

wire            [31:0] cuvz_clip_color;

gfx_cuvz cuvz(
.clk_i     (wb_clk_i),
.rst_i     (wb_rst_i),
.ack_i     (clip_ack),
.ack_o     (cuvz_interp_ack),
.write_i   (interp_cuvz_write),
// Variables needed for interpolation
.factor0_i (interp_cuvz_factor0),
.factor1_i (interp_cuvz_factor1),
// Color
.color0_i  (color0_reg),
.color1_i  (color1_reg),
.color2_i  (color2_reg),
.color_depth_i (color_depth_reg),
.color_o   (cuvz_clip_color),
// Depth
.z0_i      (transform_cuvz_dest_pixel0_z),
.z1_i      (transform_cuvz_dest_pixel1_z),
.z2_i      (transform_cuvz_dest_pixel2_z),
.z_o       (cuvz_clip_z),
// Alpha
.a0_i      (alpha0_reg),
.a1_i      (alpha1_reg),
.a2_i      (alpha2_reg),
.a_o       (cuvz_clip_alpha),
// Texture coordinates
.u0_i      (u0_reg),
.v0_i      (v0_reg),
.u1_i      (u1_reg),
.v1_i      (v1_reg),
.u2_i      (u2_reg),
.v2_i      (v2_reg),
.u_o       (cuvz_clip_u),
.v_o       (cuvz_clip_v),
// Bezier calculations
.bezier_factor0_o (cuvz_clip_bezier_factor0),
.bezier_factor1_o (cuvz_clip_bezier_factor1),
// Raster position
.x_i       (interp_cuvz_x),
.y_i       (interp_cuvz_y),
.x_o       (cuvz_clip_x),
.y_o       (cuvz_clip_y),

.write_o   (cuvz_clip_write)
);

defparam cuvz.point_width     = point_width;

wire                   clip_fragment_write_enable;
wire [point_width-1:0] clip_fragment_x_pixel;
wire [point_width-1:0] clip_fragment_y_pixel;
wire signed [point_width-1:0] clip_fragment_z_pixel;
wire                   fragment_clip_ack;
wire [point_width-1:0] clip_fragment_u;
wire [point_width-1:0] clip_fragment_v;
wire             [7:0] clip_fragment_a;
wire [point_width-1:0] clip_fragment_bezier_factor0;
wire [point_width-1:0] clip_fragment_bezier_factor1;

wire            [31:0] clip_fragment_color;

wire                   wbmreader_busy;

// Connected through arbiter
wire        wbmreader_clip_z_ack;
wire [31:2] clip_wbmreader_z_addr;
wire [31:0] wbmreader_clip_z_data;
wire  [3:0] clip_wbmreader_z_sel;
wire        clip_wbmreader_z_request;

// Apply clipping
gfx_clip clip(
.clk_i            (wb_clk_i),
.rst_i            (wb_rst_i),
.clipping_enable_i(clipping_enable_reg),
.zbuffer_enable_i (zbuffer_enable_reg),
.zbuffer_base_i   (zbuffer_base_reg),
.target_size_x_i  (target_size_x_reg),
.target_size_y_i  (target_size_y_reg),
.clip_pixel0_x_i  (clip_pixel0_x_reg),
.clip_pixel0_y_i  (clip_pixel0_y_reg),
.clip_pixel1_x_i  (clip_pixel1_x_reg),
.clip_pixel1_y_i  (clip_pixel1_y_reg),
.raster_pixel_x_i (raster_x_pixel),
.raster_pixel_y_i (raster_y_pixel),
.raster_u_i       (raster_clip_u),
.raster_v_i       (raster_clip_v),
.flat_color_i     (color0_reg),
.raster_write_i   (raster_clip_write),
.cuvz_pixel_x_i   (cuvz_clip_x),
.cuvz_pixel_y_i   (cuvz_clip_y),
.cuvz_pixel_z_i   (cuvz_clip_z),
.cuvz_u_i         (cuvz_clip_u),
.cuvz_v_i         (cuvz_clip_v),
.cuvz_a_i         (cuvz_clip_alpha),
.cuvz_color_i     (cuvz_clip_color),
.cuvz_write_i     (cuvz_clip_write),
.ack_o            (clip_ack),
.z_ack_i          (wbmreader_clip_z_ack),
.z_addr_o         (clip_wbmreader_z_addr),
.z_data_i         (wbmreader_clip_z_data),
.z_sel_o          (clip_wbmreader_z_sel),
.z_request_o      (clip_wbmreader_z_request),
.wbm_busy_i       (wbmreader_busy),
.pixel_x_o        (clip_fragment_x_pixel),
.pixel_y_o        (clip_fragment_y_pixel),
.pixel_z_o        (clip_fragment_z_pixel),
.u_o              (clip_fragment_u),
.v_o              (clip_fragment_v),
.a_o              (clip_fragment_a),
.bezier_factor0_i (cuvz_clip_bezier_factor0),
.bezier_factor1_i (cuvz_clip_bezier_factor1),
.bezier_factor0_o (clip_fragment_bezier_factor0),
.bezier_factor1_o (clip_fragment_bezier_factor1),
.color_o          (clip_fragment_color),
.write_o          (clip_fragment_write_enable),
.ack_i            (fragment_clip_ack)
);

defparam clip.point_width = point_width;

wire                   fragment_blender_write_enable;
wire [point_width-1:0] fragment_blender_x_pixel;
wire [point_width-1:0] fragment_blender_y_pixel;
wire signed [point_width-1:0] fragment_blender_z_pixel;
wire                   blender_fragment_ack;
wire            [31:0] fragment_blender_color;
wire             [7:0] fragment_blender_alpha;

wire        wbmreader_fragment_texture_ack;
wire [31:0] wbmreader_fragment_texture_data;
wire [31:2] fragment_wbmreader_texture_addr;
wire  [3:0] fragment_wbmreader_texture_sel;
wire        fragment_wbmreader_texture_request;


// Fragment processor generates color of pixel (requires RAM read for textures)
gfx_fragment_processor fp0 (
  .clk_i             (wb_clk_i),
  .rst_i             (wb_rst_i),
  .pixel_alpha_i     (clip_fragment_a),
  .x_counter_i       (clip_fragment_x_pixel),
  .y_counter_i       (clip_fragment_y_pixel),
  .z_i               (clip_fragment_z_pixel),
  .u_i               (clip_fragment_u),
  .v_i               (clip_fragment_v),
  .bezier_factor0_i  (clip_fragment_bezier_factor0),
  .bezier_factor1_i  (clip_fragment_bezier_factor1),
  .bezier_inside_i   (inside_reg),
  .ack_i             (blender_fragment_ack),
  .write_i           (clip_fragment_write_enable),
  .curve_write_i     (wbs_fragment_curve_write),
  .pixel_x_o         (fragment_blender_x_pixel),
  .pixel_y_o         (fragment_blender_y_pixel),
  .pixel_z_o         (fragment_blender_z_pixel),
  .pixel_color_i     (clip_fragment_color),
  .pixel_color_o     (fragment_blender_color),
  .pixel_alpha_o     (fragment_blender_alpha),
  .write_o           (fragment_blender_write_enable),
  .ack_o             (fragment_clip_ack),
  .texture_ack_i     (wbmreader_fragment_texture_ack), 
  .texture_data_i    (wbmreader_fragment_texture_data), 
  .texture_addr_o    (fragment_wbmreader_texture_addr), 
  .texture_sel_o     (fragment_wbmreader_texture_sel), 
  .texture_request_o (fragment_wbmreader_texture_request),
  .texture_enable_i  (texture_enable_reg),
  .tex0_base_i       (wbs_fragment_tex0_base), 
  .tex0_size_x_i     (wbs_fragment_tex0_size_x), 
  .tex0_size_y_i     (wbs_fragment_tex0_size_y),
  .color_depth_i     (color_depth_reg),
  .colorkey_enable_i (colorkey_enable_reg),
  .colorkey_i        (colorkey_reg)
  );

defparam fp0.point_width = point_width;

wire                   blender_render_write_enable;
wire [point_width-1:0] blender_render_x_pixel;
wire [point_width-1:0] blender_render_y_pixel;
wire signed [point_width-1:0] blender_render_z_pixel;
wire                   render_blender_ack;
wire            [31:0] blender_render_color;

// Connected through arbiter
wire        wbmreader_blender_target_ack;
wire [31:2] blender_wbmreader_target_addr;
wire [31:0] wbmreader_blender_target_data;
wire  [3:0] blender_wbmreader_target_sel;
wire        blender_wbmreader_target_request;

// Applies alpha blending if enabled (requires RAM read to get target pixel color)
// Fragment processor generates color of pixel (requires RAM read for textures)
gfx_blender blender0 (
  .clk_i            (wb_clk_i),
  .rst_i            (wb_rst_i),
  .blending_enable_i (blending_enable_reg),
  // Render target information
  .target_base_i    (target_base_reg),
  .target_size_x_i  (target_size_x_reg),
  .target_size_y_i  (target_size_y_reg),
  .color_depth_i    (color_depth_reg),
  .x_counter_i      (fragment_blender_x_pixel),
  .y_counter_i      (fragment_blender_y_pixel),
  .z_i              (fragment_blender_z_pixel),
  .alpha_i          (fragment_blender_alpha),
  .global_alpha_i   (global_alpha_reg),
  .ack_i            (render_blender_ack),
  .target_ack_i     (wbmreader_blender_target_ack),
  .target_addr_o    (blender_wbmreader_target_addr),
  .target_data_i    (wbmreader_blender_target_data),
  .target_sel_o     (blender_wbmreader_target_sel),
  .target_request_o (blender_wbmreader_target_request),
  .wbm_busy_i       (wbmreader_busy),
  .write_i          (fragment_blender_write_enable),
  .pixel_x_o        (blender_render_x_pixel),
  .pixel_y_o        (blender_render_y_pixel),
  .pixel_z_o        (blender_render_z_pixel),
  .pixel_color_i    (fragment_blender_color),
  .pixel_color_o    (blender_render_color),
  .write_o          (blender_render_write_enable),
  .ack_o            (blender_fragment_ack)
  );

defparam blender0.point_width = point_width;

// Write pixel to target (check for out of bounds)
gfx_renderer renderer (
  .clk_i           (wb_clk_i),
  .rst_i           (wb_rst_i),
  // Render target information
  .target_base_i   (target_base_reg),
  .zbuffer_base_i  (zbuffer_base_reg),
  .target_size_x_i (target_size_x_reg),
  .target_size_y_i (target_size_y_reg),
  .color_depth_i   (color_depth_reg),
  // Input pixel
  .pixel_x_i       (blender_render_x_pixel),
  .pixel_y_i       (blender_render_y_pixel),
  .pixel_z_i       (blender_render_z_pixel),
  .zbuffer_enable_i(zbuffer_enable_reg),
  .color_i         (blender_render_color),

  .render_addr_o   (render_wbmwriter_addr),
  .render_sel_o    (render_wbmwriter_sel),
  .render_dat_o    (render_wbmwriter_dat),
  .ack_o           (render_blender_ack),
  .ack_i           (wbmwriter_render_ack),
  .write_i         (blender_render_write_enable),
  .write_o         (render_wbmwriter_memory_pixel_write)
  );

defparam renderer.point_width = point_width;

// Instansiate wishbone master interface (write only)
gfx_wbm_write wbm_writer (
  .clk_i           (wb_clk_i),
  .rst_i           (wb_rst_i),
  .cyc_o           (wbm_write_cyc_o),
  .stb_o           (wbm_write_stb_o),
  .cti_o           (wbm_write_cti_o),
  .bte_o           (wbm_write_bte_o),
  .we_o            (wbm_write_we_o),
  .adr_o           (wbm_write_adr_o),
  .sel_o           (wbm_write_sel_o),
  .ack_i           (wbm_write_ack_i),
  .err_i           (wbm_write_err_i),
  .dat_o           (wbm_write_dat_o),
  .sint_o          (wbmwriter_sint),

  .write_i         (render_wbmwriter_memory_pixel_write),
  .ack_o           (wbmwriter_render_ack),

  // send ack to renderer when done writing to memory.
  .render_addr_i   (render_wbmwriter_addr),
  .render_sel_i    (render_wbmwriter_sel),
  .render_dat_i    (render_wbmwriter_dat)
  );

wire        wbmreader_arbiter_ack;
wire [31:2] arbiter_wbmreader_addr;
wire [31:0] wbmreader_arbiter_data;
wire  [3:0] arbiter_wbmreader_sel;
wire        arbiter_wbmreader_request;

// Instansiate wbm reader arbiter
gfx_wbm_read_arbiter wbm_arbiter (
  .master_busy_o     (wbmreader_busy),
  // Interface against the wbm read module
  .read_request_o    (arbiter_wbmreader_request),
  .addr_o            (arbiter_wbmreader_addr),
  .sel_o             (arbiter_wbmreader_sel),
  .dat_i             (wbmreader_arbiter_data),
  .ack_i             (wbmreader_arbiter_ack),
  // Interface against masters (clip)
  .m0_read_request_i (clip_wbmreader_z_request),
  .m0_addr_i         (clip_wbmreader_z_addr),
  .m0_sel_i          (clip_wbmreader_z_sel),
  .m0_dat_o          (wbmreader_clip_z_data),
  .m0_ack_o          (wbmreader_clip_z_ack),
  // Interface against masters (fragment processor)
  .m1_read_request_i (fragment_wbmreader_texture_request),
  .m1_addr_i         (fragment_wbmreader_texture_addr),
  .m1_sel_i          (fragment_wbmreader_texture_sel),
  .m1_dat_o          (wbmreader_fragment_texture_data),
  .m1_ack_o          (wbmreader_fragment_texture_ack),
  // Interface against masters (blender)
  .m2_read_request_i (blender_wbmreader_target_request),
  .m2_addr_i         (blender_wbmreader_target_addr),
  .m2_sel_i          (blender_wbmreader_target_sel),
  .m2_dat_o          (wbmreader_blender_target_data),
  .m2_ack_o          (wbmreader_blender_target_ack)
  );

// Instansiate wishbone master interface (read only for textures)
gfx_wbm_read wbm_reader (
  .clk_i            (wb_clk_i),
  .rst_i            (wb_rst_i),
  .cyc_o            (wbm_read_cyc_o),
  .stb_o            (wbm_read_stb_o),
  .cti_o            (wbm_read_cti_o),
  .bte_o            (wbm_read_bte_o),
  .we_o             (wbm_read_we_o),
  .adr_o            (wbm_read_adr_o),
  .sel_o            (wbm_read_sel_o),
  .ack_i            (wbm_read_ack_i),
  .err_i            (wbm_read_err_i),
  .dat_i            (wbm_read_dat_i),
  .sint_o           (wbmreader_sint),

  // send ack to renderer when done writing to memory.
  .read_request_i   (arbiter_wbmreader_request),
  .texture_addr_i   (arbiter_wbmreader_addr),
  .texture_sel_i    (arbiter_wbmreader_sel),
  .texture_dat_o    (wbmreader_arbiter_data),
  .texture_data_ack (wbmreader_arbiter_ack)
  );

endmodule

