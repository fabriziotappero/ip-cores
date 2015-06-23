/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

The Wishbone slave component accepts incoming register accesses and puts them in a FIFO queue

Loosely based on the vga lcds wishbone slave (LGPL) in orpsocv2 by Julius Baxter, julius@opencores.org

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

//synopsys translate_off
`include "timescale.v"

//synopsys translate_on

/*
This module acts as the main control interface of the orgfx core. It is built as a 32-bit wishbone slave interface with read and write capabilities.

The module has two states, wait and busy. The module enters busy state when a pipeline operation is triggered by a write to the control register.

In the busy state all incoming wishbone writes are queued up in a 64 item fifo. These will be processed in the order they were received when the module returns to wait state.

The module leaves the busy state and enters wait state when it receives an ack from the pipeline.
*/
module gfx_wbs(
  clk_i, rst_i, adr_i, dat_i, dat_o, sel_i, we_i, stb_i, cyc_i, ack_o, rty_o, err_o, inta_o,
  //src pixels
  src_pixel0_x_o, src_pixel0_y_o, src_pixel1_x_o, src_pixel1_y_o,
  // dest pixels
  dest_pixel_x_o, dest_pixel_y_o, dest_pixel_z_o,
  dest_pixel_id_o,
  // matrix
  aa_o, ab_o, ac_o, tx_o,
  ba_o, bb_o, bc_o, ty_o,
  ca_o, cb_o, cc_o, tz_o,
  transform_point_o,
  forward_point_o,
  // clip pixels
  clip_pixel0_x_o, clip_pixel0_y_o, clip_pixel1_x_o, clip_pixel1_y_o,
  color0_o, color1_o, color2_o,
  u0_o, v0_o, u1_o, v1_o, u2_o, v2_o,
  a0_o, a1_o, a2_o,
  target_base_o, target_size_x_o, target_size_y_o, tex0_base_o, tex0_size_x_o, tex0_size_y_o,
  color_depth_o,
  rect_write_o, line_write_o, triangle_write_o, curve_write_o, interpolate_o,
  writer_sint_i, reader_sint_i,

  pipeline_ack_i,
  transform_ack_i,

  texture_enable_o,
  blending_enable_o,
  global_alpha_o,
  colorkey_enable_o,
  colorkey_o,
  clipping_enable_o,
  inside_o,
  zbuffer_enable_o,
  zbuffer_base_o
  );

  // Load register addresses from gfx_params.v file
  `include "gfx_params.v"

  // Adjust these parameters in gfx_top!
  parameter REG_ADR_HIBIT = 9;
  parameter point_width = 16;
  parameter subpixel_width = 16;
  parameter fifo_depth = 10;

  //
  // inputs & outputs
  //

  // wishbone slave interface
  input                    clk_i;
  input                    rst_i;
  input  [REG_ADR_HIBIT:0] adr_i;
  input             [31:0] dat_i;
  output reg        [31:0] dat_o;
  input             [ 3:0] sel_i;
  input                    we_i;
  input                    stb_i;
  input                    cyc_i;
  output reg               ack_o;
  output reg               rty_o;
  output reg               err_o;
  output reg               inta_o;
  // source pixel
  output [point_width-1:0] src_pixel0_x_o;
  output [point_width-1:0] src_pixel0_y_o;
  output [point_width-1:0] src_pixel1_x_o;
  output [point_width-1:0] src_pixel1_y_o;
  // dest pixel
  output signed [point_width-1:-subpixel_width] dest_pixel_x_o;
  output signed [point_width-1:-subpixel_width] dest_pixel_y_o;
  output signed [point_width-1:-subpixel_width] dest_pixel_z_o;
  output                                  [1:0] dest_pixel_id_o;
  // matrix
  output signed [point_width-1:-subpixel_width] aa_o;
  output signed [point_width-1:-subpixel_width] ab_o;
  output signed [point_width-1:-subpixel_width] ac_o;
  output signed [point_width-1:-subpixel_width] tx_o;
  output signed [point_width-1:-subpixel_width] ba_o;
  output signed [point_width-1:-subpixel_width] bb_o;
  output signed [point_width-1:-subpixel_width] bc_o;
  output signed [point_width-1:-subpixel_width] ty_o;
  output signed [point_width-1:-subpixel_width] ca_o;
  output signed [point_width-1:-subpixel_width] cb_o;
  output signed [point_width-1:-subpixel_width] cc_o;
  output signed [point_width-1:-subpixel_width] tz_o;
  output                                 transform_point_o;
  output                                 forward_point_o;
  // clip pixel
  output [point_width-1:0] clip_pixel0_x_o;
  output [point_width-1:0] clip_pixel0_y_o;
  output [point_width-1:0] clip_pixel1_x_o;
  output [point_width-1:0] clip_pixel1_y_o;

  output [31:0] color0_o;
  output [31:0] color1_o;
  output [31:0] color2_o;

  output [point_width-1:0] u0_o;
  output [point_width-1:0] v0_o;
  output [point_width-1:0] u1_o;
  output [point_width-1:0] v1_o;
  output [point_width-1:0] u2_o;
  output [point_width-1:0] v2_o;

  output [7:0] a0_o;
  output [7:0] a1_o;
  output [7:0] a2_o;

  output            [31:2] target_base_o;
  output [point_width-1:0] target_size_x_o;
  output [point_width-1:0] target_size_y_o;
  output            [31:2] tex0_base_o;
  output [point_width-1:0] tex0_size_x_o;
  output [point_width-1:0] tex0_size_y_o;

  output [1:0]  color_depth_o;
	
  output        rect_write_o;
  output        line_write_o;
  output        triangle_write_o;
  output        curve_write_o;
  output        interpolate_o;

  // status register inputs
  input         writer_sint_i;       // system error interrupt request
  input         reader_sint_i;       // system error interrupt request

  // Pipeline feedback
  input         pipeline_ack_i;             // operation done
  input         transform_ack_i;            // transformation done

  // fragment 
  output        texture_enable_o;
  // blender
  output        blending_enable_o;
  output  [7:0] global_alpha_o;
  output        colorkey_enable_o;
  output [31:0] colorkey_o;

  output        clipping_enable_o;
  output        inside_o;
  output        zbuffer_enable_o;

  output [31:2] zbuffer_base_o;

  //
  // variable declarations
  //

  wire [REG_ADR_HIBIT:0] REG_ADR  = {adr_i[REG_ADR_HIBIT : 2], 2'b00};

  // Declaration of local registers
  reg        [31:0] control_reg, status_reg, target_base_reg, tex0_base_reg;
  reg        [31:0] target_size_x_reg, target_size_y_reg, tex0_size_x_reg, tex0_size_y_reg;
  reg        [31:0] src_pixel_pos_0_x_reg, src_pixel_pos_0_y_reg, src_pixel_pos_1_x_reg, src_pixel_pos_1_y_reg;
  reg        [31:0] clip_pixel_pos_0_x_reg, clip_pixel_pos_0_y_reg, clip_pixel_pos_1_x_reg, clip_pixel_pos_1_y_reg;
  reg signed [31:0] dest_pixel_pos_x_reg, dest_pixel_pos_y_reg, dest_pixel_pos_z_reg;
  reg signed [31:0] aa_reg, ab_reg, ac_reg, tx_reg;
  reg signed [31:0] ba_reg, bb_reg, bc_reg, ty_reg;
  reg signed [31:0] ca_reg, cb_reg, cc_reg, tz_reg;
  reg        [31:0] color0_reg, color1_reg, color2_reg;
  reg        [31:0] u0_reg, v0_reg, u1_reg, v1_reg, u2_reg, v2_reg; 
  reg        [31:0] alpha_reg;
  reg        [31:0] colorkey_reg;
  reg        [31:0] zbuffer_base_reg;

  wire        [1:0] active_point;

  // Wishbone access wires
  wire acc, acc32, reg_acc, reg_wacc;

  // State machine variables
  reg state;
  parameter wait_state = 1'b0, busy_state = 1'b1;

  //
  // Module body
  //

  // wishbone access signals
  assign acc      = cyc_i & stb_i;
  assign acc32    = (sel_i == 4'b1111);
  assign reg_acc  = acc & acc32;
  assign reg_wacc = reg_acc & we_i;

  // Generate wishbone ack
  always @(posedge clk_i or posedge rst_i)
  if(rst_i)
    ack_o <= 1'b0;
  else
    ack_o <= reg_acc & acc32 & ~ack_o ;

  // Generate wishbone rty
  always @(posedge clk_i or posedge rst_i)
  if(rst_i)
    rty_o <= 1'b0;
  else
    rty_o <= 1'b0; //reg_acc & acc32 & ~rty_o ;

  // Generate wishbone err
  always @(posedge clk_i or posedge rst_i)
  if(rst_i)
    err_o <= 1'b0;
  else
    err_o <= acc & ~acc32 & ~err_o;

  // generate interrupt request signal
  always @(posedge clk_i or posedge rst_i)
  if(rst_i)
    inta_o <= 1'b0;
  else
    inta_o <= writer_sint_i | reader_sint_i; // | other_int | (int_enable & int) | ...

  // generate registers
  always @(posedge clk_i or posedge rst_i)
  begin : gen_regs
    if (rst_i)
      begin
        control_reg             <= 32'h00000000;
        target_base_reg         <= 32'h00000000;
        target_size_x_reg       <= 32'h00000000;
        target_size_y_reg       <= 32'h00000000;
        tex0_base_reg           <= 32'h00000000;
        tex0_size_x_reg         <= 32'h00000000;
        tex0_size_y_reg         <= 32'h00000000;
        src_pixel_pos_0_x_reg   <= 32'h00000000;
        src_pixel_pos_0_y_reg   <= 32'h00000000;
        src_pixel_pos_1_x_reg   <= 32'h00000000;
        src_pixel_pos_1_y_reg   <= 32'h00000000;
        dest_pixel_pos_x_reg    <= 32'h00000000;
        dest_pixel_pos_y_reg    <= 32'h00000000;
        dest_pixel_pos_z_reg    <= 32'h00000000;
        aa_reg                  <= $signed(1'b1 << subpixel_width);
        ab_reg                  <= 32'h00000000;
        ac_reg                  <= 32'h00000000;
        tx_reg                  <= 32'h00000000;
        ba_reg                  <= 32'h00000000;
        bb_reg                  <= $signed(1'b1 << subpixel_width);
        bc_reg                  <= 32'h00000000;
        ty_reg                  <= 32'h00000000;
        ca_reg                  <= 32'h00000000;
        cb_reg                  <= 32'h00000000;
        cc_reg                  <= $signed(1'b1 << subpixel_width);
        tz_reg                  <= 32'h00000000;
        clip_pixel_pos_0_x_reg  <= 32'h00000000;
        clip_pixel_pos_0_y_reg  <= 32'h00000000;
        clip_pixel_pos_1_x_reg  <= 32'h00000000;
        clip_pixel_pos_1_y_reg  <= 32'h00000000;
        color0_reg              <= 32'h00000000;
        color1_reg              <= 32'h00000000;
        color2_reg              <= 32'h00000000;
        u0_reg                  <= 32'h00000000;
        v0_reg                  <= 32'h00000000;
        u1_reg                  <= 32'h00000000;
        v1_reg                  <= 32'h00000000;
        u2_reg                  <= 32'h00000000;
        v2_reg                  <= 32'h00000000;
        alpha_reg	              <= 32'hffffffff;
        colorkey_reg            <= 32'h00000000;
        zbuffer_base_reg        <= 32'h00000000;
      end
    // Read fifo to write to registers
    else if (instruction_fifo_rreq)
    begin
      case (instruction_fifo_q_adr) // synopsis full_case parallel_case
        GFX_CONTROL          : control_reg            <= instruction_fifo_q_data;
        GFX_TARGET_BASE      : target_base_reg        <= instruction_fifo_q_data;
        GFX_TARGET_SIZE_X    : target_size_x_reg      <= instruction_fifo_q_data;
        GFX_TARGET_SIZE_Y    : target_size_y_reg      <= instruction_fifo_q_data;
        GFX_TEX0_BASE        : tex0_base_reg          <= instruction_fifo_q_data;
        GFX_TEX0_SIZE_X      : tex0_size_x_reg        <= instruction_fifo_q_data;
        GFX_TEX0_SIZE_Y      : tex0_size_y_reg        <= instruction_fifo_q_data;
        GFX_SRC_PIXEL0_X     : src_pixel_pos_0_x_reg  <= instruction_fifo_q_data;
        GFX_SRC_PIXEL0_Y     : src_pixel_pos_0_y_reg  <= instruction_fifo_q_data;
        GFX_SRC_PIXEL1_X     : src_pixel_pos_1_x_reg  <= instruction_fifo_q_data;
        GFX_SRC_PIXEL1_Y     : src_pixel_pos_1_y_reg  <= instruction_fifo_q_data;
        GFX_DEST_PIXEL_X     : dest_pixel_pos_x_reg   <= $signed(instruction_fifo_q_data);
        GFX_DEST_PIXEL_Y     : dest_pixel_pos_y_reg   <= $signed(instruction_fifo_q_data);
        GFX_DEST_PIXEL_Z     : dest_pixel_pos_z_reg   <= $signed(instruction_fifo_q_data);
        GFX_AA               : aa_reg                 <= $signed(instruction_fifo_q_data);
        GFX_AB               : ab_reg                 <= $signed(instruction_fifo_q_data);
        GFX_AC               : ac_reg                 <= $signed(instruction_fifo_q_data);
        GFX_TX               : tx_reg                 <= $signed(instruction_fifo_q_data);
        GFX_BA               : ba_reg                 <= $signed(instruction_fifo_q_data);
        GFX_BB               : bb_reg                 <= $signed(instruction_fifo_q_data);
        GFX_BC               : bc_reg                 <= $signed(instruction_fifo_q_data);
        GFX_TY               : ty_reg                 <= $signed(instruction_fifo_q_data);
        GFX_CA               : ca_reg                 <= $signed(instruction_fifo_q_data);
        GFX_CB               : cb_reg                 <= $signed(instruction_fifo_q_data);
        GFX_CC               : cc_reg                 <= $signed(instruction_fifo_q_data);
        GFX_TZ               : tz_reg                 <= $signed(instruction_fifo_q_data);
        GFX_CLIP_PIXEL0_X    : clip_pixel_pos_0_x_reg <= instruction_fifo_q_data;
        GFX_CLIP_PIXEL0_Y    : clip_pixel_pos_0_y_reg <= instruction_fifo_q_data;
        GFX_CLIP_PIXEL1_X    : clip_pixel_pos_1_x_reg <= instruction_fifo_q_data;
        GFX_CLIP_PIXEL1_Y    : clip_pixel_pos_1_y_reg <= instruction_fifo_q_data;
        GFX_COLOR0           : color0_reg             <= instruction_fifo_q_data;
        GFX_COLOR1           : color1_reg             <= instruction_fifo_q_data;
        GFX_COLOR2           : color2_reg             <= instruction_fifo_q_data;
        GFX_U0               : u0_reg                 <= instruction_fifo_q_data;
        GFX_V0               : v0_reg                 <= instruction_fifo_q_data;
        GFX_U1               : u1_reg                 <= instruction_fifo_q_data;
        GFX_V1               : v1_reg                 <= instruction_fifo_q_data;
        GFX_U2               : u2_reg                 <= instruction_fifo_q_data;
        GFX_V2               : v2_reg                 <= instruction_fifo_q_data;
        GFX_ALPHA            : alpha_reg              <= instruction_fifo_q_data;
        GFX_COLORKEY         : colorkey_reg           <= instruction_fifo_q_data;
        GFX_ZBUFFER_BASE     : zbuffer_base_reg       <= instruction_fifo_q_data;
      endcase
    end
    else
    begin
      /* To prevent entering an infinite write cycle, the bits that start pipeline operations are cleared here */
      control_reg[GFX_CTRL_RECT]  <= 1'b0; // Reset rect write
      control_reg[GFX_CTRL_LINE]  <= 1'b0; // Reset line write
      control_reg[GFX_CTRL_TRI]   <= 1'b0; // Reset triangle write
      // Reset matrix transformation bits
      control_reg[GFX_CTRL_FORWARD_POINT]   <= 1'b0;
      control_reg[GFX_CTRL_TRANSFORM_POINT] <= 1'b0;
    end
  end

  // generate status register
  always @(posedge clk_i or posedge rst_i)
  if (rst_i)
    status_reg <= 32'h00000000;
  else
  begin
    status_reg[GFX_STAT_BUSY] <= (state == busy_state);
    status_reg[31:16]         <= instruction_fifo_count;
  end

  // Assign target and texture signals
  assign target_base_o   = target_base_reg[31:2];
  assign target_size_x_o = target_size_x_reg[point_width-1:0];
  assign target_size_y_o = target_size_y_reg[point_width-1:0];
  assign tex0_base_o     = tex0_base_reg[31:2];
  assign tex0_size_x_o   = tex0_size_x_reg[point_width-1:0];
  assign tex0_size_y_o   = tex0_size_y_reg[point_width-1:0];

  // Assign source pixel signals
  assign src_pixel0_x_o      = src_pixel_pos_0_x_reg[point_width-1:0];
  assign src_pixel0_y_o      = src_pixel_pos_0_y_reg[point_width-1:0];
  assign src_pixel1_x_o      = src_pixel_pos_1_x_reg[point_width-1:0];
  assign src_pixel1_y_o      = src_pixel_pos_1_y_reg[point_width-1:0];
  // Assign clipping pixel signals
  assign clip_pixel0_x_o     = clip_pixel_pos_0_x_reg[point_width-1:0];
  assign clip_pixel0_y_o     = clip_pixel_pos_0_y_reg[point_width-1:0];
  assign clip_pixel1_x_o     = clip_pixel_pos_1_x_reg[point_width-1:0];
  assign clip_pixel1_y_o     = clip_pixel_pos_1_y_reg[point_width-1:0];
  // Assign destination pixel signals
  assign dest_pixel_x_o[point_width-1:-subpixel_width] = $signed(dest_pixel_pos_x_reg);
  assign dest_pixel_y_o[point_width-1:-subpixel_width] = $signed(dest_pixel_pos_y_reg);
  assign dest_pixel_z_o[point_width-1:-subpixel_width] = $signed(dest_pixel_pos_z_reg);
  assign dest_pixel_id_o                               = active_point;

  // Assign matrix signals
  assign aa_o = $signed(aa_reg);
  assign ab_o = $signed(ab_reg);
  assign ac_o = $signed(ac_reg);
  assign tx_o = $signed(tx_reg);
  assign ba_o = $signed(ba_reg);
  assign bb_o = $signed(bb_reg);
  assign bc_o = $signed(bc_reg);
  assign ty_o = $signed(ty_reg);
  assign ca_o = $signed(ca_reg);
  assign cb_o = $signed(cb_reg);
  assign cc_o = $signed(cc_reg);
  assign tz_o = $signed(tz_reg);

  // Assign color signals
  assign color0_o            = color0_reg;
  assign color1_o            = color1_reg;
  assign color2_o            = color2_reg;

  assign u0_o                = u0_reg[point_width-1:0];
  assign v0_o                = v0_reg[point_width-1:0];
  assign u1_o                = u1_reg[point_width-1:0];
  assign v1_o                = v1_reg[point_width-1:0];
  assign u2_o                = u2_reg[point_width-1:0];
  assign v2_o                = v2_reg[point_width-1:0];

  assign a0_o                = alpha_reg[31:24];
  assign a1_o                = alpha_reg[23:16];
  assign a2_o                = alpha_reg[15:8];
  assign global_alpha_o      = alpha_reg[7:0];
  assign colorkey_o          = colorkey_reg;
  assign zbuffer_base_o      = zbuffer_base_reg[31:2];



  // decode control register
  assign color_depth_o      = control_reg[GFX_CTRL_COLOR_DEPTH+1:GFX_CTRL_COLOR_DEPTH];

  assign texture_enable_o   = control_reg[GFX_CTRL_TEXTURE ];
  assign blending_enable_o  = control_reg[GFX_CTRL_BLENDING];
  assign colorkey_enable_o  = control_reg[GFX_CTRL_COLORKEY];
  assign clipping_enable_o  = control_reg[GFX_CTRL_CLIPPING];
  assign zbuffer_enable_o   = control_reg[GFX_CTRL_ZBUFFER ];

  assign rect_write_o       = control_reg[GFX_CTRL_RECT    ];
  assign line_write_o       = control_reg[GFX_CTRL_LINE    ];
  assign triangle_write_o   = control_reg[GFX_CTRL_TRI     ];
  assign curve_write_o      = control_reg[GFX_CTRL_CURVE   ];
  assign interpolate_o      = control_reg[GFX_CTRL_INTERP  ];
  assign inside_o           = control_reg[GFX_CTRL_INSIDE  ];

  assign active_point       = control_reg[GFX_CTRL_ACTIVE_POINT+1:GFX_CTRL_ACTIVE_POINT];
  assign forward_point_o    = control_reg[GFX_CTRL_FORWARD_POINT];
  assign transform_point_o  = control_reg[GFX_CTRL_TRANSFORM_POINT];

  // decode status register TODO

  // assign output from wishbone reads. Note that this does not account for pending writes in the fifo!
  always @(posedge clk_i or posedge rst_i)
    if(rst_i)
      dat_o <= 32'h0000_0000;
    else
      case (REG_ADR) // synopsis full_case parallel_case
        GFX_CONTROL       : dat_o <= control_reg;
        GFX_STATUS        : dat_o <= status_reg;
        GFX_TARGET_BASE   : dat_o <= target_base_reg;
        GFX_TARGET_SIZE_X : dat_o <= target_size_x_reg;
        GFX_TARGET_SIZE_Y : dat_o <= target_size_y_reg;
        GFX_TEX0_BASE     : dat_o <= tex0_base_reg;
        GFX_TEX0_SIZE_X   : dat_o <= tex0_size_x_reg;
        GFX_TEX0_SIZE_Y   : dat_o <= tex0_size_y_reg;
        GFX_SRC_PIXEL0_X  : dat_o <= src_pixel_pos_0_x_reg;
        GFX_SRC_PIXEL0_Y  : dat_o <= src_pixel_pos_0_y_reg;
        GFX_SRC_PIXEL1_X  : dat_o <= src_pixel_pos_1_x_reg;
        GFX_SRC_PIXEL1_Y  : dat_o <= src_pixel_pos_1_y_reg;
        GFX_DEST_PIXEL_X  : dat_o <= dest_pixel_pos_x_reg;
        GFX_DEST_PIXEL_Y  : dat_o <= dest_pixel_pos_y_reg;
        GFX_DEST_PIXEL_Z  : dat_o <= dest_pixel_pos_z_reg;
        GFX_AA            : dat_o <= aa_reg;
        GFX_AB            : dat_o <= ab_reg;
        GFX_AC            : dat_o <= ac_reg;
        GFX_TX            : dat_o <= tx_reg;
        GFX_BA            : dat_o <= ba_reg;
        GFX_BB            : dat_o <= bb_reg;
        GFX_BC            : dat_o <= bc_reg;
        GFX_TY            : dat_o <= ty_reg;
        GFX_CA            : dat_o <= ca_reg;
        GFX_CB            : dat_o <= cb_reg;
        GFX_CC            : dat_o <= cc_reg;
        GFX_TZ            : dat_o <= tz_reg;
        GFX_CLIP_PIXEL0_X : dat_o <= clip_pixel_pos_0_x_reg;
        GFX_CLIP_PIXEL0_Y : dat_o <= clip_pixel_pos_0_y_reg;
        GFX_CLIP_PIXEL1_X : dat_o <= clip_pixel_pos_1_x_reg;
        GFX_CLIP_PIXEL1_Y : dat_o <= clip_pixel_pos_1_y_reg;
        GFX_COLOR0        : dat_o <= color0_reg;
        GFX_COLOR1        : dat_o <= color1_reg;
        GFX_COLOR2        : dat_o <= color2_reg;
        GFX_U0            : dat_o <= u0_reg;
        GFX_V0            : dat_o <= v0_reg;
        GFX_U1            : dat_o <= u1_reg;
        GFX_V1            : dat_o <= v1_reg;
        GFX_U2            : dat_o <= u2_reg;
        GFX_V2            : dat_o <= v2_reg;
        GFX_ALPHA         : dat_o <= alpha_reg;
        GFX_COLORKEY      : dat_o <= colorkey_reg;
        GFX_ZBUFFER_BASE  : dat_o <= zbuffer_base_reg;
        default           : dat_o <= 32'h0000_0000;
      endcase

  // State machine
  always @(posedge clk_i or posedge rst_i)
  if(rst_i)
    state <= wait_state;
  else
    case (state)
      wait_state:
        // Signals that trigger pipeline operations 
        if(rect_write_o | line_write_o | triangle_write_o |
           forward_point_o | transform_point_o)
          state <= busy_state;

      busy_state:
        // If a pipeline operation is finished, go back to wait state
        if(pipeline_ack_i | transform_ack_i)
          state <= wait_state;
    endcase

  /* Instruction fifo */
  wire        instruction_fifo_wreq;
  wire [31:0] instruction_fifo_q_data;
  wire        instruction_fifo_rreq;
  wire        instruction_fifo_valid_out;
  reg         fifo_read_ack;
  reg         fifo_write_ack;
  wire [REG_ADR_HIBIT:0] instruction_fifo_q_adr;
  wire    [fifo_depth:0] instruction_fifo_count;

  always @(posedge clk_i or posedge rst_i)
    if(rst_i)
      fifo_read_ack <= 1'b0;
    else
      fifo_read_ack <= instruction_fifo_rreq & !fifo_read_ack;

  wire ready_next_cycle = (state == wait_state) & ~rect_write_o & ~line_write_o & ~triangle_write_o & ~forward_point_o & ~transform_point_o;
  assign instruction_fifo_rreq = instruction_fifo_valid_out & ~fifo_read_ack & ready_next_cycle;

  always @(posedge clk_i or posedge rst_i)
    if(rst_i)
      fifo_write_ack <= 1'b0;
    else
      fifo_write_ack <= instruction_fifo_wreq ? !fifo_write_ack : reg_wacc;

  assign instruction_fifo_wreq = reg_wacc & ~fifo_write_ack;

  // TODO: 1024 places large enough?
  basic_fifo instruction_fifo(
  .clk_i     ( clk_i ),
  .rst_i     ( rst_i ),

  .data_i    ( {REG_ADR, dat_i} ),
  .enq_i     ( instruction_fifo_wreq ),
  .full_o    ( ), // TODO: use?
  .count_o   ( instruction_fifo_count ),

  .data_o    ( {instruction_fifo_q_adr, instruction_fifo_q_data} ),
  .valid_o   ( instruction_fifo_valid_out ),
  .deq_i     ( instruction_fifo_rreq )
  );

defparam instruction_fifo.fifo_width     = REG_ADR_HIBIT+1+32;
defparam instruction_fifo.fifo_bit_depth = fifo_depth;

endmodule



