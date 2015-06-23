/* --------------------------------------------------------------------------------
 This file is part of FPGA Median Filter.

    FPGA Median Filter is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FPGA Median Filter is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FPGA Median Filter.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------- */
/* +----------------------------------------------------------------------------
   Universidade Federal da Bahia
  ------------------------------------------------------------------------------
   PROJECT: FPGA Median Filter
  ------------------------------------------------------------------------------
   FILE NAME            : median.v
   AUTHOR               : Joo Carlos Bittencourt
   AUTHOR'S E-MAIL      : joaocarlos@ieee.org
   -----------------------------------------------------------------------------
   RELEASE HISTORY
   VERSION  DATE        AUTHOR        DESCRIPTION
   1.0      2013-08-13  joao.nunes    initial version
   2.0      2013-09-06  laur.rami     fix minnor issues on memory address
   -----------------------------------------------------------------------------
   KEYWORDS: median, filter, image processing, state machine
   -----------------------------------------------------------------------------
   PURPOSE: Windowing Memory Address Controller.
   ----------------------------------------------------------------------------- */
module state_machine
#(
    parameter LUT_ADDR_WIDTH = 10,
    parameter IMG_WIDTH = 234,
    parameter IMG_HEIGHT = 234
)(
    input clk, // Clock
    input rst_n, // Asynchronous reset active low

    output reg [LUT_ADDR_WIDTH-1:0] raddr_a,
    output reg [LUT_ADDR_WIDTH-1:0] raddr_b,
    output reg [LUT_ADDR_WIDTH-1:0] raddr_c,
    output reg [LUT_ADDR_WIDTH-1:0] waddr,
    output reg [1:0] window_line_counter,
    output reg [9:0] window_column_counter,
    output reg [9:0] memory_shift
);

    reg valid;

    always @(posedge clk or negedge rst_n)
    begin : out_memory_counter
        if(~rst_n) begin
            waddr <= {LUT_ADDR_WIDTH{1'b0}};
        end else if(valid) begin
            waddr <= waddr + 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n)
    begin : addr_counter
        if(~rst_n) begin
            window_column_counter <= 10'd0;
            window_line_counter <= 2'b00;
            raddr_a <= {LUT_ADDR_WIDTH{1'b0}};
            raddr_b <= {LUT_ADDR_WIDTH{1'b0}};
            raddr_c <= {LUT_ADDR_WIDTH{1'b0}};
        end else begin
            if(window_column_counter != ((IMG_WIDTH/4)-1)) begin
                window_column_counter <= window_column_counter + 1'b1;
                valid <= 1'b1;
                raddr_a <= raddr_a + 1'b1;
                raddr_b <= raddr_b + 1'b1;
                raddr_c <= raddr_c + 1'b1;
            end else begin
                window_column_counter <= 10'd0;
                case (window_line_counter)
                    2'b00 :
                    begin
                        raddr_a <= raddr_a + 1'b1;
                        raddr_b <= raddr_b - window_column_counter;
                        raddr_c <= raddr_c - window_column_counter;
                        window_line_counter = window_line_counter + 1'b1;
                    end
                    2'b01 :
                    begin
                        raddr_b <= raddr_b + 1'b1;
                        raddr_a <= raddr_a - window_column_counter;
                        raddr_c <= raddr_c - window_column_counter;
                        window_line_counter = window_line_counter + 1'b1;
                    end
                    2'b10 :
                    begin
                        raddr_b <= raddr_b - window_column_counter;
                        raddr_a <= raddr_a - window_column_counter;
                        raddr_c <= raddr_c + 1'b1;
                        window_line_counter = 2'b00;
                    end
                    default :
                    begin
                        raddr_a <= {LUT_ADDR_WIDTH{1'b0}};
                        raddr_b <= {LUT_ADDR_WIDTH{1'b0}};
                        raddr_c <= {LUT_ADDR_WIDTH{1'b0}};
                    end
                endcase
            end
        end
    end

endmodule
