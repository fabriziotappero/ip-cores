/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

CLIPPING/SCISSORING MODULE

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

/*
This module performs clipping by applying the current cliprect and the target size.

This module also performs z-buffer culling (requires reading from memory)
*/
module gfx_clip(clk_i, rst_i,
  clipping_enable_i, zbuffer_enable_i,
  zbuffer_base_i, target_size_x_i, target_size_y_i,
  clip_pixel0_x_i, clip_pixel0_y_i, clip_pixel1_x_i, clip_pixel1_y_i,                              //clip pixel 0 and pixel 1
  raster_pixel_x_i, raster_pixel_y_i, raster_u_i, raster_v_i, flat_color_i, raster_write_i, ack_o, // from raster
  cuvz_pixel_x_i, cuvz_pixel_y_i, cuvz_pixel_z_i, cuvz_u_i, cuvz_v_i, cuvz_color_i, cuvz_write_i,  // from cuvz
  cuvz_a_i,                                                                                        // from cuvz
  z_ack_i, z_addr_o, z_data_i, z_sel_o, z_request_o, wbm_busy_i,                                   // from/to wbm reader
  pixel_x_o, pixel_y_o, pixel_z_o, u_o, v_o, a_o,                                                  // to fragment
  bezier_factor0_i, bezier_factor1_i, bezier_factor0_o, bezier_factor1_o,                          // bezier calculations
  color_o, write_o, ack_i                                                                          // from/to fragment
  );

parameter point_width = 16;

input                   clk_i;
input                   rst_i;

input                   clipping_enable_i;
input                   zbuffer_enable_i;
input            [31:2] zbuffer_base_i;
input [point_width-1:0] target_size_x_i;
input [point_width-1:0] target_size_y_i;
//clip pixels
input [point_width-1:0] clip_pixel0_x_i;
input [point_width-1:0] clip_pixel0_y_i;
input [point_width-1:0] clip_pixel1_x_i;
input [point_width-1:0] clip_pixel1_y_i;

// From cuvz
input [point_width-1:0] cuvz_pixel_x_i;
input [point_width-1:0] cuvz_pixel_y_i;
input signed [point_width-1:0] cuvz_pixel_z_i;
input [point_width-1:0] cuvz_u_i;
input [point_width-1:0] cuvz_v_i;
input             [7:0] cuvz_a_i;
input            [31:0] cuvz_color_i;
input                   cuvz_write_i;
// From raster
input [point_width-1:0] raster_pixel_x_i;
input [point_width-1:0] raster_pixel_y_i;
input [point_width-1:0] raster_u_i;
input [point_width-1:0] raster_v_i;
input            [31:0] flat_color_i;
input                   raster_write_i;
output reg              ack_o;

// Interface against wishbone master (reader)
input             z_ack_i;
output     [31:2] z_addr_o;
input      [31:0] z_data_i;
output reg  [3:0] z_sel_o;
output reg        z_request_o;
input             wbm_busy_i;

// To fragment
output reg [point_width-1:0] pixel_x_o;
output reg [point_width-1:0] pixel_y_o;
output reg [point_width-1:0] pixel_z_o;
output reg [point_width-1:0] u_o;
output reg [point_width-1:0] v_o;
output reg             [7:0] a_o;
input      [point_width-1:0] bezier_factor0_i;
input      [point_width-1:0] bezier_factor1_i;
output reg [point_width-1:0] bezier_factor0_o;
output reg [point_width-1:0] bezier_factor1_o;
output reg            [31:0] color_o;
output reg write_o;
input ack_i;

// 

// State machine
reg [1:0] state;
parameter wait_state = 2'b00, z_read_state = 2'b01, write_pixel_state = 2'b10;

// Calculate address of target pixel
// Addr[31:2] = Base + (Y*width + X) * ppb
wire [31:0] pixel_offset = (target_size_x_i*cuvz_pixel_y_i   + {16'h0,   cuvz_pixel_x_i}) << 1; // 16 bit
assign z_addr_o = zbuffer_base_i + pixel_offset[31:2];

wire [31:0] z_value_at_target32;
wire signed [point_width-1:0] z_value_at_target = z_value_at_target32[point_width-1:0];

// Memory to color converter
memory_to_color memory_proc(
.color_depth_i (2'b01),
.mem_i         (z_data_i),
.mem_lsb_i     (cuvz_pixel_x_i[1:0]),
.color_o       (z_value_at_target32),
.sel_o         ()
);

// Forward texture coordinates, color, alpha etc
always @(posedge clk_i or posedge rst_i)
if(rst_i)
begin
  u_o              <= 1'b0;
  v_o              <= 1'b0;
  bezier_factor0_o <= 1'b0;
  bezier_factor1_o <= 1'b0;
  pixel_x_o        <= 1'b0;
  pixel_y_o        <= 1'b0;
  pixel_z_o        <= 1'b0;
  color_o          <= 1'b0;
  a_o              <= 1'b0;
  z_sel_o          <= 4'b1111;
end
else
begin
  // Implement a MUX, send data from either the raster or from the cuvz module to the fragment processor
  if(raster_write_i)
  begin
    u_o              <= raster_u_i;
    v_o              <= raster_v_i;
    a_o              <= 8'hff;
    color_o          <= flat_color_i;
    pixel_x_o        <= raster_pixel_x_i;
    pixel_y_o        <= raster_pixel_y_i;
    pixel_z_o        <= 1'b0;
  end
  // If the cuvz module is being used, more parameters needs to be forwarded
  else if(cuvz_write_i)
  begin
    u_o              <= cuvz_u_i;
    v_o              <= cuvz_v_i;
    a_o              <= cuvz_a_i;
    color_o          <= cuvz_color_i;
    pixel_x_o        <= cuvz_pixel_x_i;
    pixel_y_o        <= cuvz_pixel_y_i;
    pixel_z_o        <= cuvz_pixel_z_i;
    bezier_factor0_o <= bezier_factor0_i;
    bezier_factor1_o <= bezier_factor1_i;
  end
end

// Check if we should discard this pixel due to failing depth check
wire fail_z_check   = z_value_at_target > cuvz_pixel_z_i;

// Check if we should discard this pixel due to falling outside render target/clip rect
wire outside_target = raster_write_i ? (raster_pixel_x_i >= target_size_x_i) | (raster_pixel_y_i >= target_size_y_i) :
                      (cuvz_pixel_x_i >= target_size_x_i) | (cuvz_pixel_y_i >= target_size_y_i);
wire outside_clip   = raster_write_i ? (raster_pixel_x_i < clip_pixel0_x_i) | (raster_pixel_y_i < clip_pixel0_y_i) | (raster_pixel_x_i >= clip_pixel1_x_i) | (raster_pixel_y_i >= clip_pixel1_y_i) :
                      (cuvz_pixel_x_i < clip_pixel0_x_i) | (cuvz_pixel_y_i < clip_pixel0_y_i) | (cuvz_pixel_x_i >= clip_pixel1_x_i) | (cuvz_pixel_y_i >= clip_pixel1_y_i);
wire discard_pixel  = outside_target | (clipping_enable_i & outside_clip);

// Check if there is a write signal
wire write_i        = raster_write_i | cuvz_write_i;

// Acknowledge when a command has completed
always @(posedge clk_i or posedge rst_i)
// reset, init component
if(rst_i)
begin
  ack_o            <= 1'b0;
  write_o          <= 1'b0;
  z_request_o      <= 1'b0;
  z_sel_o          <= 4'b1111;
end
// Else, set outputs for next cycle
else
begin
  case (state)

    wait_state:
    begin
      if(write_i)
        ack_o         <= discard_pixel;
      else
        ack_o         <= 1'b0;

      if(write_i & zbuffer_enable_i)
        z_request_o   <= ~discard_pixel;
      else if(write_i)
        write_o       <= ~discard_pixel;
        
    end

    // Do a depth check. If it fails, discard pixel, ack and go back to wait. If it succeeds, go to write state
    z_read_state:
      if(z_ack_i)
      begin
        write_o     <= ~fail_z_check;
        ack_o       <= fail_z_check;
        z_request_o <= 1'b0;
      end
      else
        z_request_o <= ~wbm_busy_i | z_request_o;

    // ack, then go back to wait state when the next module is ready
    write_pixel_state:
    begin
      write_o <= 1'b0;
      if(ack_i)
        ack_o <= 1'b1;    
    end

  endcase

end

// State machine
always @(posedge clk_i or posedge rst_i)
// reset, init component
if(rst_i)
  state <= wait_state;
// Move in statemachine
else
  case (state)

    wait_state:
      if(write_i & ~discard_pixel)
      begin
        if(zbuffer_enable_i)
          state <= z_read_state;
        else 
          state <= write_pixel_state;
      end

    z_read_state:
      if(z_ack_i)
        state <= fail_z_check ? wait_state : write_pixel_state;

    write_pixel_state:
      if(ack_i)
        state <= wait_state;

  endcase

endmodule

