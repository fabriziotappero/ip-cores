/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

RENDERING MODULE

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

module gfx_renderer(clk_i, rst_i,
	target_base_i, zbuffer_base_i, target_size_x_i, target_size_y_i, color_depth_i,
	pixel_x_i, pixel_y_i, pixel_z_i, zbuffer_enable_i, color_i,
	render_addr_o, render_sel_o, render_dat_o,
	ack_o, ack_i,
	write_i, write_o
	);

parameter point_width = 16;

input clk_i;
input rst_i;

// Render target information, used for checking out of bounds and stride when writing pixels
input            [31:2] target_base_i;
input            [31:2] zbuffer_base_i;
input [point_width-1:0] target_size_x_i;
input [point_width-1:0] target_size_y_i;

input             [1:0] color_depth_i;

input [point_width-1:0] pixel_x_i;
input [point_width-1:0] pixel_y_i;
input [point_width-1:0] pixel_z_i;
input                   zbuffer_enable_i;
input            [31:0] color_i;

input      write_i;
output reg write_o;

// Output registers connected to the wbm
output reg [31:2] render_addr_o;
output reg  [3:0] render_sel_o;
output reg [31:0] render_dat_o;

wire        [3:0] target_sel;
wire       [31:0] target_dat;
wire        [3:0] zbuffer_sel;
wire       [31:0] zbuffer_dat;

output reg ack_o;
input      ack_i;

// TODO: Fifo for incoming pixel data?



// Define memory address
// Addr[31:2] = Base + (Y*width + X) * ppb
wire [31:0] pixel_offset;
assign pixel_offset = (color_depth_i == 2'b00) ? (target_size_x_i*pixel_y_i + pixel_x_i)      : // 8  bit
                      (color_depth_i == 2'b01) ? (target_size_x_i*pixel_y_i + pixel_x_i) << 1 : // 16 bit
                                                 (target_size_x_i*pixel_y_i + pixel_x_i) << 2 ; // 32 bit

wire [31:2] target_addr = target_base_i + pixel_offset[31:2];
wire [31:2] zbuffer_addr = zbuffer_base_i + pixel_offset[31:2];

// Color to memory converter
color_to_memory color_proc(
.color_depth_i  (color_depth_i),
.color_i        (color_i),
.x_lsb_i        (pixel_x_i[1:0]),
.mem_o          (target_dat),
.sel_o          (target_sel)
);



// Color to memory converter
color_to_memory depth_proc(
.color_depth_i  (2'b01),
// Note: Padding because z_i is only [15:0]
.color_i        ({ {point_width{1'b0}}, pixel_z_i[point_width-1:0] }),
.x_lsb_i        (pixel_x_i[1:0]),
.mem_o          (zbuffer_dat),
.sel_o          (zbuffer_sel)
);

// State machine
reg [1:0] state;
parameter wait_state        = 2'b00,
          write_pixel_state = 2'b01,
          write_z_state     = 2'b10;

// Acknowledge when a command has completed
always @(posedge clk_i or posedge rst_i)
begin
  //  reset, init component
  if(rst_i)
  begin
    write_o       <= 1'b0;
    ack_o         <= 1'b0;
    render_addr_o <= 1'b0;
    render_sel_o  <= 1'b0;
    render_dat_o  <= 1'b0;
  end
  // Else, set outputs for next cycle
  else
  begin
    case (state)

      wait_state:
      begin
        ack_o   <= 1'b0;
        if(write_i)
        begin
          render_addr_o <= target_addr;
          render_sel_o  <= target_sel;
          render_dat_o  <= target_dat;
          write_o <= 1'b1;
        end
      end

      // Write pixel to memory. If depth buffering is enabled, write z value too
      write_pixel_state:
      begin
        if(ack_i)
        begin
          render_addr_o <= zbuffer_addr;
          render_sel_o  <= zbuffer_sel;
          render_dat_o  <= zbuffer_dat;

          write_o       <= zbuffer_enable_i;
          ack_o         <= ~zbuffer_enable_i;
        end
        else
          write_o       <= 1'b0;
      end

      write_z_state:
      begin
        write_o       <= 1'b0;
        ack_o         <= ack_i;
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
        if(write_i)
          state <= write_pixel_state;

      write_pixel_state:
        if(ack_i & zbuffer_enable_i)
          state <= write_z_state;
        else if(ack_i)
          state <= wait_state;

      write_z_state:
        if(ack_i)
          state <= wait_state;

    endcase
end

endmodule

