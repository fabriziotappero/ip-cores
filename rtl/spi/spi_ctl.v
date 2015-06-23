//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores SPI Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////



module spi_ctl
       ( clk,
         reset_n,
         sck_int,


         cfg_op_req,
         cfg_op_type,
         cfg_transfer_size,
         cfg_sck_period,
         cfg_sck_cs_period,
         cfg_cs_byte,
         cfg_datain,
         cfg_dataout,
         op_done,

         cs_int_n,
         sck_pe,
         sck_ne,
         shift_out,
         shift_in,
         byte_out,
         byte_in,
         load_byte
         
         );

 //*************************************************************************

  input          clk, reset_n;
  input          cfg_op_req;
  input [1:0]    cfg_op_type;
  input [1:0]    cfg_transfer_size;
    
  input [5:0]    cfg_sck_period;
  input [4:0]    cfg_sck_cs_period; // cs setup & hold period
  input [7:0]    cfg_cs_byte;
  input [31:0]   cfg_datain;
  output [31:0]  cfg_dataout;

  output [7:0]    byte_out; // Byte out for Serial Shifting out
  input  [7:0]    byte_in;  // Serial Received Byte
  output          sck_int;
  output          cs_int_n;
  output          sck_pe;
  output          sck_ne;
  output          shift_out;
  output          shift_in;
  output          load_byte;
  output          op_done;

  reg    [31:0]   cfg_dataout;
  reg             sck_ne;
  reg             sck_pe;
  reg             sck_int;
  reg [5:0]       clk_cnt;
  reg [5:0]       sck_cnt;

  reg [3:0]       spiif_cs;
  reg             shift_enb;
  reg             cs_int_n;
  reg             clr_sck_cnt ;
  reg             sck_out_en;

  wire [5:0]      sck_half_period;
  reg             load_byte;
  reg             shift_in;
  reg             op_done;
  reg [2:0]       byte_cnt;


  `define SPI_IDLE   4'b0000
  `define SPI_CS_SU  4'b0001
  `define SPI_WRITE  4'b0010
  `define SPI_READ   4'b0011
  `define SPI_CS_HLD 4'b0100
  `define SPI_WAIT   4'b0101


  assign sck_half_period = {1'b0, cfg_sck_period[5:1]};
  // The first transition on the sck_toggle happens one SCK period
  // after op_en or boot_en is asserted
  always @(posedge clk or negedge reset_n) begin
     if(!reset_n) begin
        sck_ne   <= 1'b0;
        clk_cnt  <= 6'h1;
        sck_pe   <= 1'b0;
        sck_int  <= 1'b0;
     end // if (!reset_n)
     else 
     begin
        if(cfg_op_req) 
        begin
           if(clk_cnt == sck_half_period) 
           begin
              sck_ne <= 1'b1;
              sck_pe <= 1'b0;
              if(sck_out_en) sck_int <= 0;
              clk_cnt <= clk_cnt + 1'b1;
           end // if (clk_cnt == sck_half_period)
           else 
           begin
              if(clk_cnt == cfg_sck_period) 
              begin
                 sck_ne <= 1'b0;
                 sck_pe <= 1'b1;
                 if(sck_out_en) sck_int <= 1;
                 clk_cnt <= 6'h1;
              end // if (clk_cnt == cfg_sck_period)
              else 
              begin
                 clk_cnt <= clk_cnt + 1'b1;
                 sck_pe <= 1'b0;
                 sck_ne <= 1'b0;
              end // else: !if(clk_cnt == cfg_sck_period)
           end // else: !if(clk_cnt == sck_half_period)
        end // if (op_en)
        else 
        begin
           clk_cnt    <= 6'h1;
           sck_pe     <= 1'b0;
           sck_ne     <= 1'b0;
        end // else: !if(op_en)
     end // else: !if(!reset_n)
  end // always @ (posedge clk or negedge reset_n)
  

wire [1:0] cs_data =  (byte_cnt == 2'b00) ? cfg_cs_byte[7:6]  :
                      (byte_cnt == 2'b01) ? cfg_cs_byte[5:4]  :
                      (byte_cnt == 2'b10) ? cfg_cs_byte[3:2]  : cfg_cs_byte[1:0] ;

wire [7:0] byte_out = (byte_cnt == 2'b00) ? cfg_datain[31:24] :
                      (byte_cnt == 2'b01) ? cfg_datain[23:16] :
                      (byte_cnt == 2'b10) ? cfg_datain[15:8]  : cfg_datain[7:0] ;
         
assign shift_out =  shift_enb && sck_ne;

always @(posedge clk or negedge reset_n) begin
   if(!reset_n) begin
      spiif_cs    <= `SPI_IDLE;
      sck_cnt     <= 6'h0;
      shift_in    <= 1'b0;
      clr_sck_cnt <= 1'b1;
      byte_cnt    <= 2'b00;
      cs_int_n    <= 1'b1;
      sck_out_en  <= 1'b0;
      shift_enb   <= 1'b0;
      cfg_dataout <= 32'h0;
      load_byte   <= 1'b0;
   end
   else begin
      if(sck_ne)
         sck_cnt <=  clr_sck_cnt  ? 6'h0 : sck_cnt + 1 ;

      case(spiif_cs)
      `SPI_IDLE   : 
      begin
          op_done     <= 0;
          clr_sck_cnt <= 1'b1;
          sck_out_en  <= 1'b0;
          shift_enb   <= 1'b0;
          if(cfg_op_req) 
          begin
              cfg_dataout <= 32'h0;
              spiif_cs    <= `SPI_CS_SU;
           end 
           else begin
              spiif_cs <= `SPI_IDLE;
           end 
      end 

      `SPI_CS_SU  : 
       begin
          if(sck_ne) begin
            cs_int_n <= cs_data[1];
            if(sck_cnt == cfg_sck_cs_period) begin
               clr_sck_cnt <= 1'b1;
               if(cfg_op_type == 0) begin // Write Mode
                  load_byte   <= 1'b1;
                  spiif_cs    <= `SPI_WRITE;
                  shift_enb   <= 1'b0;
               end else begin
                  shift_in    <= 1;
                  spiif_cs    <= `SPI_READ;
                end
             end
             else begin 
                clr_sck_cnt <= 1'b0;
             end
         end
      end 

      `SPI_WRITE : 
       begin 
         load_byte   <= 1'b0;
         if(sck_ne) begin
           if(sck_cnt == 3'h7 )begin
              clr_sck_cnt <= 1'b1;
              spiif_cs    <= `SPI_CS_HLD;
              shift_enb   <= 1'b0;
              sck_out_en  <= 1'b0; // Disable clock output
           end
           else begin
              shift_enb   <= 1'b1;
              sck_out_en  <= 1'b1;
              clr_sck_cnt <= 1'b0;
           end
         end else begin
            shift_enb   <= 1'b1;
         end
      end 

      `SPI_READ : 
       begin 
         if(sck_ne) begin
             if( sck_cnt == 3'h7 ) begin
                clr_sck_cnt <= 1'b1;
                shift_in    <= 0;
                spiif_cs    <= `SPI_CS_HLD;
                sck_out_en  <= 1'b0; // Disable clock output
             end
             else begin
                sck_out_en  <= 1'b1; // Disable clock output
                clr_sck_cnt <= 1'b0;
             end
         end
      end 

      `SPI_CS_HLD : begin
         if(sck_ne) begin
             cs_int_n <= cs_data[0];
            if(sck_cnt == cfg_sck_cs_period) begin
               if(cfg_op_type == 1) begin // Read Mode
                  cfg_dataout <= (byte_cnt[1:0] == 2'b00) ? { byte_in, cfg_dataout[23:0] } :
                                 (byte_cnt[1:0] == 2'b01) ? { cfg_dataout[31:24] ,
                                                              byte_in, cfg_dataout[15:0] } :
                                 (byte_cnt[1:0] == 2'b10) ? { cfg_dataout[31:16] ,
                                                              byte_in, cfg_dataout[7:0]  } :
                                                            { cfg_dataout[31:8]  ,
                                                              byte_in  } ;
               end
               clr_sck_cnt <= 1'b1;
               if(byte_cnt == cfg_transfer_size) begin
                  spiif_cs <= `SPI_WAIT;
                  byte_cnt <= 0;
                  op_done  <= 1;
               end else begin
                  byte_cnt <= byte_cnt +1;
                  spiif_cs <= `SPI_CS_SU;
               end
            end
            else begin
                clr_sck_cnt <= 1'b0;
            end
         end 
      end // case: `SPI_CS_HLD    
      `SPI_WAIT : begin
          if(!cfg_op_req) // Wait for Request de-assertion
             spiif_cs <= `SPI_IDLE;
       end
    endcase // casex(spiif_cs)
   end
end // always @(sck_ne

endmodule