/* *****************************************************************
 *
 *  This file is part of the
 *  
 *  Tone Order and Constellation Encoder Core.
 *
 *  Description:
 *
 *  The conste_enc module implements the tone ordering and 
 *  constellation encoding as described in ITU G.992.1
 *  
 ********************************************************************* 
 *  Copyright (C) 2007 Guenter Dannoritzer
 *
 *   This source is free software; you can redistribute it
 *   and/or modify it under the terms of the 
 *             GNU General Public License
 *   as published by the Free Software Foundation; 
 *   either version 3 of the License,
 *   or (at your option) any later version.
 *
 *   This source is distributed in the hope 
 *   that it will be useful, but WITHOUT ANY WARRANTY;
 *   without even the implied warranty of MERCHANTABILITY
 *   or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the
 *   GNU General Public License along with this source.
 *   If not, see <http://www.gnu.org/licenses/>.
 *
 * *****************************************************************/

module const_encoder( 
                clk,
                reset,
                fast_ready_o,
                we_fast_data_i,
                fast_data_i,
                inter_ready_o,
                we_inter_data_i,
                inter_data_i,
                addr_i,
                we_conf_i,
                conf_data_i,
                xy_ready_o,
                carrier_num_o,
                x_o,
                y_o);


`include "parameters.vh"
              
//
// parameter
// 

input                 clk;
input                 reset;
output                fast_ready_o;
input                 we_fast_data_i;
input   [DW-1:0]      fast_data_i;
output                inter_ready_o;
input                 we_inter_data_i;
input   [DW-1:0]      inter_data_i;
input   [CONFAW-1:0]  addr_i;
input                 we_conf_i;
input   [CONFDW-1:0]  conf_data_i;
output                xy_ready_o;
output  [CNUMW-1:0]   carrier_num_o;
output  [CONSTW-1:0]  x_o;            reg signed [CONSTW-1:0] x_o;
output  [CONSTW-1:0]  y_o;            reg signed [CONSTW-1:0] y_o;



//
// local wire/regs
//
wire    [DW-1:0]          fast_data_o;
wire    [DW-1:0]          inter_data_o;

reg   [SHIFTW-1:0]        fast_shift_reg;
reg   [SHIFTW-1:0]        inter_shift_reg;
reg   [MAXBITNUM-1:0]     cin;
reg   [CONFDW-1:0]        bit_load;

reg   [4:0]               msb;
reg   [1:0]               msb_x;
reg   [1:0]               msb_y;

reg   [CONFDW-1:0]        BitLoading [0:REG_MEM_LEN-1];
reg   [CONFDW-1:0]        CarrierNumber [0:REG_MEM_LEN-1];
reg   [USED_C_REG_W-1:0]  UsedCarrier;
reg   [F_BITS_W-1:0]      FastBits;

//
// intantiate the fast path and interleaved path FIFOs
//
fifo  #(.AWIDTH(AW), .DWIDTH(DW))
      fifo_fast ( .clk(clk),
                  .reset(reset),
                  .empty_o(fast_empty_o),
                  .full_o(fast_full_o),
                  .one_available_o(fast_one_available_o),
                  .two_available_o(fast_two_available_o),
                  .we_i(we_fast_i),
                  .data_i(fast_data_i),
                  .re_i(re_fast_i),
                  .data_o(fast_data_o)
                  );

fifo  #(.AWIDTH(AW), .DWIDTH(DW))
      fifo_inter ( .clk(clk),
                  .reset(reset),
                  .empty_o(inter_empty_o),
                  .full_o(inter_full_o),
                  .one_available_o(inter_one_available_o),
                  .two_available_o(inter_two_available_o),
                  .we_i(we_inter_i),
                  .data_i(inter_data_i),
                  .re_i(re_inter_i),
                  .data_o(inter_data_o)
                  );

     
//
// configuration register access
//
always @(posedge clk or posedge reset) begin

  if(reset) begin
    UsedCarrier <= 0;
    FastBits <= 0;

  end
  else begin
    if(we_conf_i) begin
      if(addr_i >= 0 && addr_i < C_NUM_ST_ADR) begin
        BitLoading[addr_i] <= conf_data_i;
      end
      else if(addr_i >= C_NUM_ST_ADR && addr_i < USED_C_ADR) begin
        CarrierNumber[addr_i - C_NUM_ST_ADR] <= conf_data_i;
      end
      else if(addr_i == USED_C_ADR) begin
        UsedCarrier <= conf_data_i;
      end
      else if(addr_i == F_BITS_ADR) begin
        FastBits <= conf_data_i;
      end
    end
  end
    
end


//
// constellation mapping
//
always @(posedge reset or posedge clk) begin

  if(reset) begin
    x_o <= 9'b0;
    y_o <= 9'b0;
  end
  else begin
    case (bit_load)
      4'b0010:  begin // #2
                  x_o <= {cin[1], cin[1], cin[1], cin[1], cin[1], cin[1], cin[1], cin[1], 1'b1};
                  y_o <= {cin[0], cin[0], cin[0], cin[0], cin[0], cin[0], cin[0], cin[0], 1'b1};
                end
      
      4'b0011:  begin // #3
                  case (cin[2:0])
                    3'b000: begin x_o <= 9'b000000001; y_o <= 9'b000000001; end
                    3'b001: begin x_o <= 9'b000000001; y_o <= 9'b111111111; end
                    3'b010: begin x_o <= 9'b111111111; y_o <= 9'b000000001; end
                    3'b011: begin x_o <= 9'b111111111; y_o <= 9'b111111111; end

                    3'b100: begin x_o <= 9'b111111101; y_o <= 9'b000000001; end
                    3'b101: begin x_o <= 9'b000000001; y_o <= 9'b000000011; end
                    3'b110: begin x_o <= 9'b111111111; y_o <= 9'b111111101; end
                    3'b111: begin x_o <= 9'b000000011; y_o <= 9'b111111111; end
                  endcase
                end
      
      4'b0100:  begin // #4
                  x_o <= {cin[3], cin[3], cin[3], cin[3], cin[3], cin[3], cin[3], cin[1], 1'b1};
                  y_o <= {cin[2], cin[2], cin[2], cin[2], cin[2], cin[2], cin[2], cin[0], 1'b1};
                end
      
      4'b0101:  begin // #5
                  map_msb(cin[4:0], msb_x, msb_y);
                  x_o <= {msb_x[1], msb_x[1], msb_x[1], msb_x[1], msb_x[1], msb_x[1], msb_x[0], cin[1], 1'b1};
                  y_o <= {msb_y[1], msb_y[1], msb_y[1], msb_y[1], msb_y[1], msb_y[1], msb_y[0], cin[0], 1'b1};
                end
      
      4'b0110:  begin // #6
                  x_o <= {cin[4], cin[4], cin[4], cin[4], cin[4], cin[4], cin[2], cin[0], 1'b1};
                  y_o <= {cin[5], cin[5], cin[5], cin[5], cin[5], cin[5], cin[3], cin[1], 1'b1};
                end
      
      4'b0111:  begin // #7
                  map_msb(cin[6:2], msb_x, msb_y);
                  x_o <= {msb_x[1], msb_x[1], msb_x[1], msb_x[1], msb_x[1], msb_x[0], cin[2], cin[0], 1'b1};
                  y_o <= {msb_y[1], msb_y[1], msb_y[1], msb_y[1], msb_y[1], msb_y[0], cin[3], cin[1], 1'b1};
                end
      4'b1000:  begin // #8
                  x_o <= {cin[6], cin[6], cin[6], cin[6], cin[6], cin[4], cin[2], cin[0], 1'b1};
                  y_o <= {cin[7], cin[7], cin[7], cin[7], cin[7], cin[5], cin[3], cin[1], 1'b1};
                end
      
      4'b1001:  begin // #9
                  map_msb(cin[7:3], msb_x, msb_y);
                  x_o <= {msb_x[1], msb_x[1], msb_x[1], msb_x[1], msb_x[0], cin[4], cin[2], cin[0], 1'b1};
                  y_o <= {msb_y[1], msb_y[1], msb_y[1], msb_y[1], msb_y[0], cin[5], cin[3], cin[1], 1'b1};
                end
      4'b1010:  begin // #10
                  x_o <= {cin[8], cin[8], cin[8], cin[8], cin[6], cin[4], cin[2], cin[0], 1'b1};
                  y_o <= {cin[9], cin[9], cin[9], cin[9], cin[7], cin[5], cin[3], cin[1], 1'b1};
                end
      
      4'b1011:  begin // #11
                  map_msb(cin[8:4], msb_x, msb_y);
                  x_o <= {msb_x[1], msb_x[1], msb_x[1], msb_x[0], cin[6], cin[4], cin[2], cin[0], 1'b1};
                  y_o <= {msb_y[1], msb_y[1], msb_y[1], msb_y[0], cin[7], cin[5], cin[3], cin[1], 1'b1};
                end
      4'b1100:  begin // #12
                  x_o <= {cin[10], cin[10], cin[10], cin[8], cin[6], cin[4], cin[2], cin[0], 1'b1};
                  y_o <= {cin[11], cin[11], cin[11], cin[9], cin[7], cin[5], cin[3], cin[1], 1'b1};
                end
      
      4'b1101:  begin // #13
                  map_msb(cin[9:5], msb_x, msb_y);
                  x_o <= {msb_x[1], msb_x[1], msb_x[0], cin[8], cin[6], cin[4], cin[2], cin[0], 1'b1};
                  y_o <= {msb_y[1], msb_y[1], msb_y[0], cin[9], cin[7], cin[5], cin[3], cin[1], 1'b1};
                end
      4'b1110:  begin // #14
                  x_o <= {cin[12], cin[12], cin[10], cin[8], cin[6], cin[4], cin[2], cin[0], 1'b1};
                  y_o <= {cin[13], cin[13], cin[11], cin[9], cin[7], cin[5], cin[3], cin[1], 1'b1};
                end
      
      4'b1111:  begin // #15 TODO
                  map_msb(cin[10:6], msb_x, msb_y);
                  x_o <= {msb_x[1], msb_x[0], cin[10], cin[8], cin[6], cin[4], cin[2], cin[0], 1'b1};
                  y_o <= {msb_y[1], msb_y[0], cin[11], cin[9], cin[7], cin[5], cin[3], cin[1], 1'b1};
                end

    endcase
  end
end

//
// determine the top two bits of X and Y based on table 7-12 in G.992.1
//
task map_msb(input [4:0] t_msb, output [1:0] t_msb_x, output [1:0] t_msb_y );
  begin
  case (t_msb)
    5'b00000: begin t_msb_x <= 2'b00; t_msb_y <= 2'b00; end
    5'b00001: begin t_msb_x <= 2'b00; t_msb_y <= 2'b00; end
    5'b00010: begin t_msb_x <= 2'b00; t_msb_y <= 2'b00; end
    5'b00011: begin t_msb_x <= 2'b00; t_msb_y <= 2'b00; end

    5'b00100: begin t_msb_x <= 2'b00; t_msb_y <= 2'b11; end
    5'b00101: begin t_msb_x <= 2'b00; t_msb_y <= 2'b11; end
    5'b00110: begin t_msb_x <= 2'b00; t_msb_y <= 2'b11; end
    5'b00111: begin t_msb_x <= 2'b00; t_msb_y <= 2'b11; end
    
    5'b01000: begin t_msb_x <= 2'b11; t_msb_y <= 2'b00; end
    5'b01001: begin t_msb_x <= 2'b11; t_msb_y <= 2'b00; end
    5'b01010: begin t_msb_x <= 2'b11; t_msb_y <= 2'b00; end
    5'b01011: begin t_msb_x <= 2'b11; t_msb_y <= 2'b00; end

    5'b01100: begin t_msb_x <= 2'b11; t_msb_y <= 2'b11; end
    5'b01101: begin t_msb_x <= 2'b11; t_msb_y <= 2'b11; end
    5'b01110: begin t_msb_x <= 2'b11; t_msb_y <= 2'b11; end
    5'b01111: begin t_msb_x <= 2'b11; t_msb_y <= 2'b11; end

    5'b10000: begin t_msb_x <= 2'b01; t_msb_y <= 2'b00; end
    5'b10001: begin t_msb_x <= 2'b01; t_msb_y <= 2'b00; end
    5'b10010: begin t_msb_x <= 2'b10; t_msb_y <= 2'b00; end
    5'b10011: begin t_msb_x <= 2'b10; t_msb_y <= 2'b00; end

    5'b10100: begin t_msb_x <= 2'b00; t_msb_y <= 2'b01; end
    5'b10101: begin t_msb_x <= 2'b00; t_msb_y <= 2'b10; end
    5'b10110: begin t_msb_x <= 2'b00; t_msb_y <= 2'b01; end
    5'b10111: begin t_msb_x <= 2'b00; t_msb_y <= 2'b10; end

    5'b11000: begin t_msb_x <= 2'b11; t_msb_y <= 2'b01; end
    5'b11001: begin t_msb_x <= 2'b11; t_msb_y <= 2'b10; end
    5'b11010: begin t_msb_x <= 2'b11; t_msb_y <= 2'b01; end
    5'b11011: begin t_msb_x <= 2'b11; t_msb_y <= 2'b10; end
    
    5'b11100: begin t_msb_x <= 2'b01; t_msb_y <= 2'b11; end
    5'b11101: begin t_msb_x <= 2'b01; t_msb_y <= 2'b11; end
    5'b11110: begin t_msb_x <= 2'b10; t_msb_y <= 2'b11; end
    5'b11111: begin t_msb_x <= 2'b10; t_msb_y <= 2'b11; end
    
  endcase
end
endtask

endmodule
