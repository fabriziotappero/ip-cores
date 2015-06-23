/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

Bresenham line algarithm 

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
// trigger on high

module bresenham_line(clk_i, rst_i,
pixel0_x_i, pixel0_y_i, pixel1_x_i, pixel1_y_i, 
draw_line_i, read_pixel_i, 
busy_o, x_major_o, major_o, minor_o, valid_o
);

parameter point_width = 16;
parameter subpixel_width = 16;

input clk_i;
input rst_i;

input signed [point_width-1:-subpixel_width] pixel0_x_i;
input signed [point_width-1:-subpixel_width] pixel1_x_i;
input signed [point_width-1:-subpixel_width] pixel0_y_i;
input signed [point_width-1:-subpixel_width] pixel1_y_i;

input draw_line_i;
input read_pixel_i;

output reg busy_o;
output reg valid_o;

output reg signed [point_width-1:0] major_o;
output reg signed [point_width-1:0] minor_o;

//line drawing reg & wires
reg [point_width-1:-subpixel_width] xdiff; // dx
reg [point_width-1:-subpixel_width] ydiff; // dy
output reg x_major_o; // if x is the major axis (for each x, y changes less then x)

reg signed [point_width-1:-subpixel_width] left_pixel_x; // this is the left most pixel of the two input pixels
reg signed [point_width-1:-subpixel_width] left_pixel_y; 
reg signed [point_width-1:-subpixel_width] right_pixel_x; // this is the right most pixel of the two input pixels
reg signed [point_width-1:-subpixel_width] right_pixel_y;

reg [point_width-1:-subpixel_width] delta_major; // if x is major this value is xdiff, else ydiff
reg [point_width-1:-subpixel_width] delta_minor; // if x is minor this value is xdiff, else ydiff

reg minor_slope_positive; // true if slope is in first quadrant 

reg  signed          [point_width-1:0] major_goal;
reg  signed [2*point_width-1:-subpixel_width] eps;
wire signed [2*point_width-1:-subpixel_width] eps_delta_minor;
wire done;

// State machine
reg [2:0] state;
parameter wait_state = 0, line_prep_state = 1, line_state = 2, raster_state = 3;

assign eps_delta_minor = eps+delta_minor;

always@(posedge clk_i or posedge rst_i)
if(rst_i)
  state <= wait_state;
else
  case (state)

    wait_state:
      if(draw_line_i)
        state <= line_prep_state; // if request for drawing a line, go to line drawing state

    line_prep_state:
      state <= line_state;

    line_state:
      state <= raster_state;

    raster_state:
      if(!busy_o)
        state <= wait_state;

  endcase

wire is_inside_screen = (minor_o >= 0) & (major_o >= -1);
reg previously_outside_screen;

always@(posedge clk_i or posedge rst_i)
begin
  if(rst_i)
  begin
    minor_slope_positive <= 1'b0;
    eps                  <= 1'b0;
    major_o              <= 1'b0;
    minor_o              <= 1'b0;
    busy_o               <= 1'b0;
    major_goal           <= 1'b0;
    x_major_o            <= 1'b0;
    delta_minor          <= 1'b0;
    delta_major          <= 1'b0;
    valid_o              <= 1'b0;
    left_pixel_x         <= 1'b0;
    left_pixel_y         <= 1'b0;
    right_pixel_x        <= 1'b0;
    right_pixel_y        <= 1'b0;
    xdiff                <= 1'b0;
    ydiff                <= 1'b0;
    previously_outside_screen <= 1'b0;
  end
  else
  begin

// ## new magic
    // Start a raster line operation 
   case (state)

      wait_state:
        if(draw_line_i)
        begin
          // set busy!
          previously_outside_screen <= 1'b0;
          busy_o  <= 1'b1;
          valid_o <= 1'b0;
          // check diff in x and y
          if(pixel0_x_i > pixel1_x_i)
          begin
            xdiff         <= pixel0_x_i - pixel1_x_i;

            // pixel0 is greater then pixel1, pixel1 is left of pixel0.
            left_pixel_x  <= pixel1_x_i;
            left_pixel_y  <= pixel1_y_i;
            right_pixel_x <= pixel0_x_i;
            right_pixel_y <= pixel0_y_i;

            // check diff for y axis (swapped)
            if(pixel1_y_i > pixel0_y_i)
            begin
              ydiff                <= pixel1_y_i - pixel0_y_i;
              minor_slope_positive <= 1'b0;
            end
            else
            begin
              ydiff                <= pixel0_y_i - pixel1_y_i;
              minor_slope_positive <= 1'b1;
            end

          end
          else
          begin
            xdiff         <= pixel1_x_i - pixel0_x_i;

            // pixel1 is greater then pixel0, pixel0 is left of pixel1.
            left_pixel_x  <= pixel0_x_i;
            left_pixel_y  <= pixel0_y_i;
            right_pixel_x <= pixel1_x_i;
            right_pixel_y <= pixel1_y_i;

            // check diff for y axis
            if(pixel0_y_i > pixel1_y_i)
            begin
              ydiff                <= pixel0_y_i - pixel1_y_i;
              minor_slope_positive <= 1'b0; // the slope is "\" negative
            end
            else
            begin
              ydiff                <= pixel1_y_i - pixel0_y_i;
              minor_slope_positive <= 1'b1; // the slope is "/" positive
            end
          end
        end

    // Prepare linedrawing
      line_prep_state:
      begin
        if(xdiff > ydiff)
        begin // x major axis
          x_major_o    <= 1'b1;
          delta_major  <= xdiff;
          delta_minor  <= ydiff;
        end
        else
        begin // y major axis 
          x_major_o    <= 1'b0;    
          delta_major  <= ydiff;
          delta_minor  <= xdiff; 
        end
      end


      // Rasterize a line between dest_pixel0 and dest_pixel1 (rasterize = generate the pixels)
      line_state:
      begin
          if(x_major_o) 
          begin
            major_o    <= $signed(left_pixel_x[point_width-1:0]);
            minor_o    <= $signed(left_pixel_y[point_width-1:0]);
            major_goal <= $signed(right_pixel_x[point_width-1:0]);
          end
          else 
          begin
            major_o    <= $signed(left_pixel_y[point_width-1:0]);
            minor_o    <= $signed(left_pixel_x[point_width-1:0]);
            major_goal <= $signed(right_pixel_y[point_width-1:0]);
          end
          eps          <= 1'b0;
          busy_o       <= 1'b1;
          valid_o      <= (left_pixel_x >= 0 && left_pixel_y >= 0);

          previously_outside_screen <= ~(left_pixel_x >= 0 && left_pixel_y >= 0);
      end

    raster_state:
    begin
      // pixels is now valid!           
      valid_o <= (previously_outside_screen | read_pixel_i) & is_inside_screen;

      previously_outside_screen <= ~is_inside_screen;

      //bresenham magic
      if((read_pixel_i & is_inside_screen) | previously_outside_screen)
      begin
        if((major_o < major_goal) & minor_slope_positive & x_major_o & busy_o) // if we are between endpoints and want to draw a line, continue
        begin
          major_o   <=  major_o + 1'b1; // major axis increeses
    
          if((eps_delta_minor*2) >= $signed(delta_major))
          begin
            eps     <=  eps_delta_minor - delta_major;
            minor_o <=  minor_o + 1'b1; // minor axis increeses
          end
          else
            eps     <=  eps_delta_minor;
        end
        else if((major_o < major_goal) & minor_slope_positive & !x_major_o & busy_o) 
        begin
          major_o   <=  major_o + 1'b1; // major axis increeses
    
          if((eps_delta_minor*2) >= $signed(delta_major))
          begin
            eps     <=  eps_delta_minor - delta_major;
            minor_o <=  minor_o + 1'b1; // minor axis increeses
          end
          else
            eps     <=  eps_delta_minor;
        end
        else if((major_o > major_goal) & !minor_slope_positive & !x_major_o & busy_o)// the slope is negative
        begin
          major_o   <=  major_o - 1'b1; // major axis decreeses

          if((eps_delta_minor*2) >= $signed(delta_major))
          begin
            eps     <=  eps_delta_minor - delta_major;
            minor_o <=  minor_o + 1'b1; // minor axis increeses
          end
          else
            eps     <=  eps_delta_minor;
        end
        else if((major_o < major_goal) & !minor_slope_positive & x_major_o & busy_o)// special to fix ocant 4 & 8.
        begin
          major_o   <=  major_o + 1'b1; // major axis increeses

          if((eps_delta_minor*2) >= $signed(delta_major))
          begin
            eps     <=  eps_delta_minor - delta_major;
            minor_o <=  minor_o - 1'b1; // minor axis decreeses
          end
          else
            eps     <=  eps_delta_minor;
        end
        // if we have reached tho goal and are busy, stop being busy.
        else if(busy_o)
        begin
          busy_o <=  1'b0;
          valid_o <= 1'b0;
        end
      end
    end
    endcase
  end
end

endmodule

