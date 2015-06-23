/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

PER-PIXEL COLORING MODULE, alpha blending


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
This module performs alpha blending by fetching the pixel from the target and mixing it with the texel based on the current alpha value.

The exact formula is:
alpha = global_alpha_i * alpha_i
color_out = color_in * alpha + color_target * (1-alpha)       , where alpha is defined from 0 to 1 

alpha_i[7:0] is used, so the actual span is 0 (transparent) to 255 (opaque)

If alpha blending is disabled (blending_enable_i == 1'b0) the module just passes on the input pixel.
*/
module gfx_blender(clk_i, rst_i,
  blending_enable_i, target_base_i, target_size_x_i, target_size_y_i, color_depth_i,
  x_counter_i, y_counter_i, z_i, alpha_i, global_alpha_i, write_i, ack_o,                      // from fragment
  target_ack_i, target_addr_o, target_data_i, target_sel_o, target_request_o, wbm_busy_i, // from/to wbm reader
  pixel_x_o, pixel_y_o, pixel_z_o, pixel_color_i, pixel_color_o, write_o, ack_i                      // to render
  );

parameter point_width = 16;

input                   clk_i;
input                   rst_i;

input                   blending_enable_i;
input            [31:2] target_base_i;
input [point_width-1:0] target_size_x_i;
input [point_width-1:0] target_size_y_i;
input             [1:0] color_depth_i;

// from fragment
input [point_width-1:0] x_counter_i;
input [point_width-1:0] y_counter_i;
input signed [point_width-1:0] z_i;
input             [7:0] alpha_i;
input             [7:0] global_alpha_i;
input            [31:0] pixel_color_i;
input                   write_i;
output reg              ack_o;

// Interface against wishbone master (reader)
input             target_ack_i;
output     [31:2] target_addr_o;
input      [31:0] target_data_i;
output reg  [3:0] target_sel_o;
output reg        target_request_o;
input             wbm_busy_i;

//to render
output reg [point_width-1:0] pixel_x_o;
output reg [point_width-1:0] pixel_y_o;
output reg signed [point_width-1:0] pixel_z_o;
output reg            [31:0] pixel_color_o;
output reg                   write_o;
input                        ack_i;

// State machine
reg [1:0] state;
parameter wait_state = 2'b00,
          target_read_state = 2'b01,
          write_pixel_state = 2'b10;

// Calculate alpha
reg [15:0] combined_alpha_reg;
wire [7:0] alpha = combined_alpha_reg[15:8];

// Calculate address of target pixel
// Addr[31:2] = Base + (Y*width + X) * ppb
wire [31:0] pixel_offset;
assign pixel_offset = (color_depth_i == 2'b00) ? (target_size_x_i*y_counter_i + {16'h0, x_counter_i})      : // 8  bit
                      (color_depth_i == 2'b01) ? (target_size_x_i*y_counter_i + {16'h0, x_counter_i}) << 1 : // 16 bit
                      (target_size_x_i*y_counter_i + {16'h0, x_counter_i})                            << 2 ; // 32 bit

assign target_addr_o = target_base_i + pixel_offset[31:2];

// Split colors for alpha blending (render color)
wire [7:0] blend_color_r = (color_depth_i == 2'b00) ? pixel_color_i[7:0] :
                           (color_depth_i == 2'b01) ? pixel_color_i[15:11] :
                           pixel_color_i[23:16];
wire [7:0] blend_color_g = (color_depth_i == 2'b00) ? pixel_color_i[7:0] :
                           (color_depth_i == 2'b01) ? pixel_color_i[10:5] :
                           pixel_color_i[15:8];
wire [7:0] blend_color_b = (color_depth_i == 2'b00) ? pixel_color_i[7:0] :
                           (color_depth_i == 2'b01) ? pixel_color_i[4:0] :
                           pixel_color_i[7:0];

// Split colors for alpha blending (from target surface)
wire [7:0] target_color_r = (color_depth_i == 2'b00) ? dest_color[7:0] :
                            (color_depth_i == 2'b01) ? dest_color[15:11] :
                            target_data_i[23:16];
wire [7:0] target_color_g = (color_depth_i == 2'b00) ? dest_color[7:0] :
                            (color_depth_i == 2'b01) ? dest_color[10:5] :
                            target_data_i[15:8];
wire [7:0] target_color_b = (color_depth_i == 2'b00) ? dest_color[7:0] :
                            (color_depth_i == 2'b01) ? dest_color[4:0] :
                            target_data_i[7:0];

// Alpha blending (per color channel):
// rgb = (alpha1)(rgb1) + (1-alpha1)(rgb2)
wire [15:0] alpha_color_r = blend_color_r * alpha + target_color_r * (8'hff - alpha);
wire [15:0] alpha_color_g = blend_color_g * alpha + target_color_g * (8'hff - alpha);
wire [15:0] alpha_color_b = blend_color_b * alpha + target_color_b * (8'hff - alpha);

wire [31:0] dest_color;
// Memory to color converter
memory_to_color memory_proc(
.color_depth_i (color_depth_i),
.mem_i (target_data_i),
.mem_lsb_i (x_counter_i[1:0]),
.color_o (dest_color),
.sel_o ()
);

// Acknowledge when a command has completed
always @(posedge clk_i or posedge rst_i)
begin
  // reset, init component
  if(rst_i)
  begin
    ack_o            <= 1'b0;
    write_o          <= 1'b0;
    pixel_x_o        <= 1'b0;
    pixel_y_o        <= 1'b0;
    pixel_z_o        <= 1'b0;
    pixel_color_o    <= 1'b0;
    target_request_o <= 1'b0;
    target_sel_o     <= 4'b1111;
  end
  // Else, set outputs for next cycle
  else
  begin
    case (state)

      wait_state:
      begin
        ack_o <= 1'b0;

        if(write_i)
        begin
          if(!blending_enable_i)
          begin
            pixel_x_o     <= x_counter_i;
            pixel_y_o     <= y_counter_i;
            pixel_z_o     <= z_i;
            pixel_color_o <= pixel_color_i;
            write_o       <= 1'b1;
          end
          else
          begin
            target_request_o   <= !wbm_busy_i;
            combined_alpha_reg <= alpha_i * global_alpha_i;
          end
        end
      end

      // Read pixel color at target (request is sent through the wbm reader arbiter).
      target_read_state:
        if(target_ack_i)
        begin
          // When we receive an ack from memory, calculate the combined color and send the pixel forward in the pipeline (go to write state)
          write_o          <= 1'b1;
          pixel_x_o        <= x_counter_i;
          pixel_y_o        <= y_counter_i;
          pixel_z_o        <= z_i;
          target_request_o <= 1'b0;

      	  // Recombine colors
          pixel_color_o    <= (color_depth_i == 2'b00) ? {alpha_color_r[15:8]} : // 8 bit grayscale
                              (color_depth_i == 2'b01) ? {alpha_color_r[12:8], alpha_color_g[13:8], alpha_color_b[12:8]} : // 16 bit
                              {alpha_color_r[15:8], alpha_color_g[15:8], alpha_color_b[15:8]}; // 32 bit
        end
        else
          target_request_o <= !wbm_busy_i | target_request_o;

      // Ack and return to wait state
      write_pixel_state:
      begin
        write_o <= 1'b0;
        if(ack_i)
          ack_o <= 1'b1;    
      end

    endcase
  end
end

// State machine
always @(posedge clk_i or posedge rst_i)
begin
  // reset, init component
  if(rst_i)
    state <= wait_state;
  // Move in statemachine
  else
    case (state)

      wait_state:
        if(write_i & blending_enable_i)
          state <= target_read_state;
        else if(write_i)
          state <= write_pixel_state;

      target_read_state:
        if(target_ack_i)
          state <= write_pixel_state;

      write_pixel_state:
        if(ack_i)
          state <= wait_state;

    endcase
end

endmodule

