///////////////////////////////////////////////////////////////////////////////
// Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
//
// This source file may be used and distributed without
// restriction provided that this copyright statement is not
// removed from the file and that any derivative work contains
// the original copyright notice and the associated disclaimer.
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
///////////////////////////////////////////////////////////////////////////////
// **************************************************************************
// File             : avalon_to_hibi.v
// Authors          : Juha Arvio
// Date             : 11.05.2010
// Decription       : Avalon to HIBI
// Version          : 0.2
// Version history  : 21.03.2010   jua   Original version
// **************************************************************************

module avalon_to_hibi (
  rst_n,
  clk,
  
  av_wr_data_in,
  av_rd_data_out,
  av_addr_in,
  av_we_in,
  av_re_in,
  av_byte_en_in,
  av_wait_req_out,
  
  hibi_comm_in,
  hibi_data_in,
  hibi_av_in,
  hibi_full_in,
  hibi_one_p_in,
  hibi_empty_in,
  hibi_one_d_in,
  
  hibi_comm_out,
  hibi_data_out,
  hibi_av_out,
  hibi_we_out,
  hibi_re_out );

parameter AV_ADDR_SIZE = 19;

input rst_n;
input clk;

input [31:0] av_wr_data_in;
output [31:0] av_rd_data_out;
input [AV_ADDR_SIZE-1:0] av_addr_in;
input av_we_in;
input av_re_in;
input [3:0] av_byte_en_in;
output av_wait_req_out;

input [2:0] hibi_comm_in;
input [31:0] hibi_data_in;
input hibi_av_in;
input hibi_full_in;
input hibi_one_p_in;
input hibi_empty_in;
input hibi_one_d_in;
  
output [2:0] hibi_comm_out;
output [31:0] hibi_data_out;
output hibi_av_out;
output hibi_we_out;
output hibi_re_out;

parameter AV_M2H2_ADDR = 2'h0;
parameter AV_HIBI_COMP_0_ADDR = 2'h1;
parameter AV_HIBI_COMP_1_ADDR = 2'h2;
parameter AV_HIBI_COMP_2_ADDR = 2'h3;

parameter HIBI_BASE_ADDR = 8'h03;
parameter HIBI_M2H2_BASE_ADDR = 8'h07;
parameter HIBI_M2H2_WRCONF_ADDR = 24'h000200; //24'h000010;
parameter HIBI_M2H2_RDCONF_ADDR = 24'h000100;
parameter HIBI_COMP_0_BASE_ADDR = 8'h05;
parameter HIBI_COMP_1_BASE_ADDR = 8'h15;
parameter HIBI_COMP_2_BASE_ADDR = 8'h29;

localparam HIBI_CMD_IDLE       = 3'b000;
localparam HIBI_CMD_WR_CONF    = 3'b001;
localparam HIBI_CMD_WR         = 3'b010;
localparam HIBI_CMD_WR_MSG     = 3'b011;
localparam HIBI_CMD_RD         = 3'b100;
localparam HIBI_CMD_RD_CONF    = 3'b101;
localparam HIBI_CMD_MCAST_DATA = 3'b110;
localparam HIBI_CMD_MCAST_MSG  = 3'b111;

localparam WAIT_AV        = 3'h0;
localparam DELAY          = 3'h1;
localparam HIBI_SINGLE_WR = 3'h2;
localparam HIBI_SINGLE_RD = 3'h3;
localparam HIBI_EMPTY_WR  = 3'h4;
localparam M2H2_SINGLE_WR = 3'h5;
localparam M2H2_SINGLE_RD = 3'h6;

wire [31:0] av_wr_data;
reg [31:0] av_rd_data;
wire [30:0] av_addr;
wire av_we;
wire av_re;
wire [3:0] av_byte_en;
reg av_wait_req;

reg hibi_rd_req;
reg hibi_wr_req;
reg hibi_rd_fifo_ready;
reg hibi_wr_fifo_ready;


wire hibi_we;
reg hibi_wr_av;
reg [2:0] hibi_wr_comm;
reg [31:0] hibi_wr_data;

wire hibi_re;
wire hibi_rd_av;
reg hibi_rd_av_prev;
wire [2:0] hibi_rd_comm;
reg [2:0] hibi_rd_comm_prev;
wire [31:0] hibi_rd_data;
reg [31:0] hibi_rd_data_prev;

reg [7:0] hibi_rd_operation_index;

reg [2:0] fsm_state;
reg [2:0] sub_state;

assign av_wr_data = av_wr_data_in;
assign av_rd_data_out = av_rd_data;
assign av_addr = av_addr_in;
assign av_we = av_we_in;
assign av_re = av_re_in;
assign av_byte_en = av_byte_en_in;
assign av_wait_req_out = av_wait_req & (av_we | av_re);



assign hibi_re = hibi_rd_fifo_ready & hibi_rd_req;
assign hibi_re_out = hibi_re;

assign hibi_we = hibi_wr_fifo_ready & hibi_wr_req;
assign hibi_we_out = hibi_we;


assign hibi_av_out = hibi_wr_av;
assign hibi_comm_out = hibi_wr_comm;

assign hibi_data_out = hibi_wr_data;

assign hibi_rd_av = hibi_av_in;
assign hibi_rd_comm = hibi_comm_in;
assign hibi_rd_data = hibi_data_in;

always@(posedge clk or negedge rst_n)
begin
  if (!rst_n)
  begin
    hibi_rd_fifo_ready <= 0;
  end
  else
  begin
    if (hibi_one_d_in == 1)
    begin
      if (hibi_re == 1) // last read fifo data word was read
      begin
        hibi_rd_fifo_ready <= 0;
      end
      else
      begin
        hibi_rd_fifo_ready <= 1;
      end
    end
    else if (hibi_empty_in == 0) // hibi read fifo has atleast two data words
    begin
      hibi_rd_fifo_ready <= 1;
    end
    
    if (hibi_re)
    begin
      hibi_rd_av_prev <= hibi_rd_av;
      hibi_rd_comm_prev <= hibi_rd_comm;
      hibi_rd_data_prev <= hibi_rd_data;
    end
  end
end

always@(posedge clk or negedge rst_n)
begin
  if (!rst_n)
  begin
    hibi_wr_fifo_ready <= 0;
  end
  else
  begin
    if (hibi_one_p_in)
    begin
      if (hibi_we)
      begin
        hibi_wr_fifo_ready <= 0;
      end
      else
      begin
        hibi_wr_fifo_ready <= 1;
      end
    end
    else if (!hibi_full_in)
    begin
      hibi_wr_fifo_ready <= 1;
    end
    else
    begin
      hibi_wr_fifo_ready <= 0;
    end
    
    
  end
  
  
end

always@(posedge clk or negedge rst_n)
begin
  if (!rst_n)
  begin
    fsm_state <= WAIT_AV;
    sub_state <= 2'h0;
    
    av_rd_data <= 32'h0;
    av_wait_req <= 1'b0;
    
    hibi_wr_req <= 1'b0;
    hibi_wr_av <= 1'b0;
    hibi_wr_comm <= 3'h0;
    hibi_wr_data <= 32'h0;
    hibi_rd_req <= 1'b0;
    
    hibi_rd_operation_index <= 8'h0;
  end
  else
  begin
    case (fsm_state)
      WAIT_AV:
      begin
        if (av_addr[AV_ADDR_SIZE-1:AV_ADDR_SIZE-2] == AV_M2H2_ADDR) begin
          if (av_we) begin
            fsm_state <= M2H2_SINGLE_WR;
            hibi_wr_req <= 1'b1;
            hibi_wr_av <= 1'b1;
            hibi_wr_comm <= HIBI_CMD_WR;
            hibi_wr_data <= {HIBI_M2H2_BASE_ADDR, HIBI_M2H2_WRCONF_ADDR};
          end
          else if (av_re) begin
            fsm_state <= M2H2_SINGLE_RD;
            hibi_wr_req <= 1'b1;
            hibi_wr_av <= 1'b1;
            hibi_wr_comm <= HIBI_CMD_WR; //HIBI_CMD_RD;
            hibi_wr_data <= {HIBI_M2H2_BASE_ADDR, HIBI_M2H2_RDCONF_ADDR};
          end
        end
        
        else begin // if (av_addr[AV_ADDR_SIZE-1:AV_ADDR_SIZE-2] >= AV_HIBI_COMP_0_ADDR) begin
          case (av_addr[AV_ADDR_SIZE-1:AV_ADDR_SIZE-2])
            AV_HIBI_COMP_0_ADDR:
            begin
              hibi_wr_data <= {HIBI_COMP_0_BASE_ADDR, {(24 - AV_ADDR_SIZE){1'b0}}, av_addr[AV_ADDR_SIZE-3:0], 2'b00};
            end
            AV_HIBI_COMP_1_ADDR:
            begin
              hibi_wr_data <= {HIBI_COMP_1_BASE_ADDR, {(24 - AV_ADDR_SIZE){1'b0}}, av_addr[AV_ADDR_SIZE-3:0], 2'b00};
            end
            AV_HIBI_COMP_2_ADDR:
            begin
              hibi_wr_data <= {HIBI_COMP_2_BASE_ADDR, {(24 - AV_ADDR_SIZE){1'b0}}, av_addr[AV_ADDR_SIZE-3:0], 2'b00};
            end
          endcase
          
          if (av_we) begin
            if (av_byte_en == 4'h0) begin
              fsm_state <= HIBI_EMPTY_WR;
            end
            else begin
              fsm_state <= HIBI_SINGLE_WR;
              hibi_wr_req <= 1'b1;
            end
            
            hibi_wr_av <= 1'b1;
            hibi_wr_comm <= HIBI_CMD_WR;
          end
          else if (av_re) begin
            fsm_state <= HIBI_SINGLE_RD;
            hibi_wr_req <= 1'b1;
            hibi_wr_av <= 1'b1;
            hibi_wr_comm <= HIBI_CMD_RD;
          end
        end
        
        sub_state <= 2'h0;
        av_wait_req <= 1'b1;
      end
      DELAY:
      begin
        av_wait_req <= 1'b1;
        fsm_state <= WAIT_AV;
      end
      HIBI_SINGLE_WR:
      begin
        if (hibi_we) begin
          case (sub_state)
            3'h0:
            begin
              hibi_wr_av <= 1'b0;
              hibi_wr_data <= av_wr_data;
            end
            default: //3'h1:
            begin
              hibi_wr_req <= 1'b0;
              
              
              fsm_state <= DELAY;
              av_wait_req <= 1'b0;
            end
          endcase
          
          sub_state <= sub_state + 1;
        end
      end
      HIBI_SINGLE_RD:
      begin
        if (hibi_we || hibi_re) begin
          sub_state <= sub_state + 1;
          
          case (sub_state)
            3'h0:
            begin
              hibi_wr_av <= 1'b0;
              hibi_wr_data <= {HIBI_BASE_ADDR, 16'h0, hibi_rd_operation_index};
            end
            3'h1:
            begin
              hibi_wr_req <= 1'b0;
              hibi_rd_req <= 1'b1;
            end
            3'h2:
            begin
              if ( !(hibi_rd_av && (hibi_rd_data == {HIBI_BASE_ADDR, 16'h0, hibi_rd_operation_index})) ) begin
                sub_state <= sub_state;
              end
            end
            default: //3'h3:
            begin
              av_rd_data <= hibi_rd_data;
              
              fsm_state <= DELAY;
              av_wait_req <= 1'b0;
              
              hibi_rd_operation_index <= hibi_rd_operation_index + 1;
            end
          endcase
        end
      end
      HIBI_EMPTY_WR:
      begin
        fsm_state <= DELAY;
        av_wait_req <= 1'b0;
      end                 
      M2H2_SINGLE_WR:
      begin
        if (hibi_we || (sub_state == 3'h4)) begin
          case (sub_state)
            3'h0:
            begin
              hibi_wr_av <= 1'b0;
              hibi_wr_data <= {1'h0, av_byte_en, 27'h0000001}; // post_rw_cmd = 0, byte_en = av_byte_en, mem_rw_length = 1
            end
            3'h1:
            begin
              hibi_wr_data <= {HIBI_M2H2_BASE_ADDR, av_addr[23:0]};
            end
            3'h2:
            begin
              hibi_wr_data <= av_wr_data;
            end
            default: //3'h3:
            begin
              hibi_wr_req <= 1'b0;
              av_wait_req <= 1'b0;
              fsm_state <= DELAY;
            end
            
          endcase
          
          sub_state <= sub_state + 1;
        end
      end
      M2H2_SINGLE_RD:
      begin
        if (hibi_we || hibi_re) begin
          sub_state <= sub_state + 1;
          
          case (sub_state)
            3'h0:
            begin
              hibi_wr_av <= 1'b0;
              hibi_wr_data <= 32'h78000001; // post_rw_cmd = 0, byte_en = 0xF, mem_rw_length = 1
            end
            3'h1:
            begin
              hibi_wr_data <= {HIBI_M2H2_BASE_ADDR, av_addr[23:0]};
            end
            3'h2:
            begin
              hibi_wr_data <= {HIBI_BASE_ADDR, 16'h0, hibi_rd_operation_index};
            end
            3'h3:
            begin
              hibi_wr_req <= 1'b0;
              hibi_rd_req <= 1'b1;
            end
            3'h4:
            begin
              if ( !(hibi_rd_av && (hibi_rd_data == {HIBI_BASE_ADDR, 16'h0, hibi_rd_operation_index})) ) begin
                sub_state <= sub_state;
              end
            end
            default: //3'h5:
            begin
              av_rd_data <= hibi_rd_data;
              
              fsm_state <= DELAY;
              av_wait_req <= 1'b0;
              
              hibi_rd_operation_index <= hibi_rd_operation_index + 1;
            end
          endcase
        end
      end
    endcase
  end
end


endmodule
