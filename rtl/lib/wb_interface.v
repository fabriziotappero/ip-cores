//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores common library Module                       ////
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

module wb_interface (
          rst          , 
          clk          ,

          dma_req_i    ,
          dma_write_i  ,
          dma_addr_i   ,
          dma_length_i ,
          dma_ack_o    ,
          dma_done_o   ,

          dma_start_o  ,
          dma_wr_o     ,
          dma_rd_o     ,
          dma_last_o   ,
          dma_wdata_i  ,
          dma_rdata_o  ,

    // external memory
          wbd_dat_i    , 
          wbd_dat_o    ,
          wbd_adr_o    , 
          wbd_be_o     , 
          wbd_we_o     , 
          wbd_ack_i    ,
          wbd_stb_o    , 
          wbd_cyc_o    , 
          wbd_err_i    


     );



input            rst             ; 
input            clk             ;

input            dma_req_i       ;
input            dma_write_i     ;
input [25:0]     dma_addr_i      ;
input [7:0]      dma_length_i    ;
output           dma_ack_o       ;
output           dma_done_o      ; // indicates end of DMA transaction

output           dma_start_o     ;
output           dma_wr_o        ;
output           dma_rd_o        ;
output           dma_last_o      ;
input  [31:0]    dma_wdata_i     ;
output [31:0]    dma_rdata_o     ;

//--------------------------------
// WB interface
//--------------------------------
input  [31:0]    wbd_dat_i       ; // data input
output [31:0]    wbd_dat_o       ; // data output
output [23:0]    wbd_adr_o       ; // address
output  [3:0]    wbd_be_o        ; // byte enable
output           wbd_we_o        ; // write 
input            wbd_ack_i       ; // acknowlegement
output           wbd_stb_o       ; // strobe/request
output           wbd_cyc_o       ; // wb cycle
input            wbd_err_i       ; // we error

//------------------------------------
// Reg Declaration
//--------------------------------
reg [2:0]        state           ;
reg [2:0]        state_d         ;
reg [7:0]        preq_len        ; // pending request length in bytes
reg              wbd_we_o        ; // westbone write req
reg [23:0]       wbd_adr_o       ; // westnone address
reg              dma_ack_o       ; // dma ack
reg [7:0]        twbtrans        ; // total westbone transaction
reg              dma_wr_o        ; // dma write request
reg              dma_rd_o        ; // dma read request
reg [31:0]       temp_data       ; // temp holding data
reg [1:0]        be_sof          ; // Byte enable starting alignment
reg [31:0]       wbd_dat_o       ; // westbone data out
reg [3:0]        wbd_be_o        ; // west bone byte enable 
reg [31:0]       dma_rdata_o     ; // dma read data
reg              wbd_stb_o       ; 
reg              dma_start_o     ; // dma first transfer
reg              dma_last_o      ; // dma last transfer

parameter WB_IDLE           = 3'b000;
parameter WB_REQ            = 3'b001;
parameter WB_WR_PHASE       = 3'b010;
parameter WB_RD_PHASE_SOF   = 3'b011;
parameter WB_RD_PHASE_CONT  = 3'b100;

assign dma_done_o = (state == WB_IDLE) && (state_d !=  WB_IDLE);

always @(posedge rst or posedge clk)
begin
   if(rst) begin
      state         <= WB_IDLE;
      state_d       <= WB_IDLE;
      wbd_we_o      <= 0;
      wbd_adr_o     <= 0;
      preq_len      <= 0;
      dma_ack_o     <= 0;
      twbtrans      <= 0;
      dma_wr_o      <= 0;
      dma_rd_o      <= 0;
      temp_data     <= 0;
      be_sof        <= 0;
      wbd_dat_o     <= 0; 
      wbd_be_o      <= 0; 
      dma_rdata_o   <= 0;
      wbd_stb_o     <= 0;
      dma_start_o   <= 0;
      dma_last_o    <= 0;
   end
   else begin
      state_d       <= state;
      case(state)
      WB_IDLE : 
         begin
            if(dma_req_i)
            begin
               dma_ack_o  <= 1;
               wbd_we_o   <= dma_write_i;
               wbd_adr_o  <= dma_addr_i[25:2];
               be_sof     <= dma_addr_i[1] << 1 + dma_addr_i[0];
               preq_len   <= dma_length_i;
               // total wb transfer
               twbtrans   <= dma_length_i[7:2] + 
                             |(dma_length_i[1:0]) + 
                             |(dma_addr_i[1:0]);
               state       <= WB_REQ;
            end 
            dma_wr_o   <= 0;
            dma_rd_o   <= 0;
            wbd_stb_o  <= 0;
            dma_start_o  <= 0;
         end
      WB_REQ :
         begin
            dma_ack_o      <= 0;
            wbd_stb_o      <= 1;
            if(wbd_we_o) begin
               dma_wr_o    <= 1;
               dma_start_o <= 1;
               temp_data   <= dma_wdata_i; 
               if(be_sof == 0) begin
                  wbd_dat_o  <= dma_wdata_i; 
                  wbd_be_o   <= 4'b1111; 
                  preq_len    <= preq_len - 4;
               end 
               else if(be_sof == 1) begin
                  wbd_dat_o  <= {dma_wdata_i[23:0],8'h0}; 
                  wbd_be_o   <= 4'b1110; 
                  preq_len    <= preq_len - 3;
               end
               else if(be_sof == 2) begin
                  wbd_dat_o  <= {dma_wdata_i[15:0],16'h0}; 
                  wbd_be_o   <= 4'b1100; 
                  preq_len    <= preq_len - 2;
               end
               else begin
                  wbd_dat_o  <= {dma_wdata_i[7:0],23'h0}; 
                  wbd_be_o   <= 4'b1000; 
                  preq_len    <= preq_len - 1;
               end
               twbtrans   <= twbtrans -1;
               state      <= WB_WR_PHASE;
               if(twbtrans == 1) 
                   dma_last_o <= 1;
            end
            else begin
               state   <= WB_RD_PHASE_SOF;
            end
         end
      WB_WR_PHASE :
         begin
            dma_start_o       <= 0;
            if(wbd_ack_i) begin
               if(twbtrans == 1) 
                   dma_last_o <= 1;
               else
                   dma_last_o <= 0;
               if(twbtrans > 0) begin
                  temp_data   <= dma_wdata_i; 
                  twbtrans    <= twbtrans -1;
                  if(be_sof == 0) begin
                     wbd_dat_o  <= dma_wdata_i; 
                  end 
                  else if(be_sof == 1) begin
                     wbd_dat_o  <= {dma_wdata_i[23:0],temp_data[31:24]}; 
                  end
                  else if(be_sof == 2) begin
                     wbd_dat_o  <= {dma_wdata_i[15:0],temp_data[31:16]}; 
                  end
                  else begin
                     wbd_dat_o  <= {dma_wdata_i[7:0],temp_data[31:8]}; 
                  end

                  if(twbtrans > 1) begin // If the Pending Transfer is more than 1
                     dma_wr_o   <= 1;
                     wbd_be_o   <= 4'b1111; 
                     preq_len   <= preq_len - 4;
                  end
                  else begin // for last write access
                     wbd_be_o   <= preq_len[1:0] == 2'b00 ? 4'b1111:
                                   preq_len[1:0] == 2'b01 ? 4'b0001:
                                   preq_len[1:0] == 2'b10 ? 4'b0011: 4'b0111;

                     case({be_sof[1:0],preq_len[1:0]})
                        // Start alignment = 0
                        4'b0001 : dma_wr_o   <= 1;
                        4'b0010 : dma_wr_o   <= 1;
                        4'b0011 : dma_wr_o   <= 1;
                        4'b0000 : dma_wr_o   <= 1;
                        // Start alignment = 1
                        4'b0101 : dma_wr_o   <= 0;
                        4'b0110 : dma_wr_o   <= 1;
                        4'b0111 : dma_wr_o   <= 1;
                        4'b0100 : dma_wr_o   <= 1;
                        // Start alignment = 2
                        4'b1001 : dma_wr_o   <= 0;
                        4'b1010 : dma_wr_o   <= 0;
                        4'b1011 : dma_wr_o   <= 1;
                        4'b1000 : dma_wr_o   <= 1;
                        // Start alignment = 3
                        4'b1101 : dma_wr_o   <= 0;
                        4'b1110 : dma_wr_o   <= 0;
                        4'b1111 : dma_wr_o   <= 0;
                        4'b1100 : dma_wr_o   <= 1;
                     endcase
                  end
               end
               else begin
                  dma_wr_o  <= 0;
                  wbd_stb_o <= 0;
                  state     <= WB_IDLE;
               end 
            end
            else begin
               dma_last_o <= 0;
               dma_wr_o   <= 0;
            end
         end
      WB_RD_PHASE_SOF :
         begin
            if(wbd_ack_i) begin
               twbtrans    <= twbtrans -1;
               if(twbtrans == 1) begin // If the Pending Transfer is 1
                   dma_rd_o   <= 1;
                   dma_start_o<= 1;
                   if(be_sof == 0) begin
                       dma_rdata_o  <= wbd_dat_i; 
                       preq_len     <= preq_len - 4;
                   end 
                   else if(be_sof == 1) begin
                       dma_rdata_o  <= {8'h0,wbd_dat_i[31:24]}; 
                       preq_len     <= preq_len - 3;
                   end
                   else if(be_sof == 2) begin
                       dma_rdata_o  <= {16'h0,wbd_dat_i[31:16]}; 
                       preq_len     <= preq_len - 2;
                   end
                   else begin
                       dma_rdata_o  <= {23'h0,wbd_dat_i[31:8]}; 
                       preq_len     <= preq_len - 0;
                   end
                   dma_last_o <= 1;
                   state      <= WB_IDLE;
               end
               else begin // pending transction is more than 1
                  if(be_sof == 0) begin
                      dma_rdata_o  <= wbd_dat_i; 
                      dma_rd_o     <= 1;
                      dma_start_o  <= 1;
                      preq_len     <= preq_len - 4;
                  end 
                  else if(be_sof == 1) begin
                      temp_data    <= {8'h0,wbd_dat_i[31:24]}; 
                      dma_rd_o     <= 0;
                      preq_len     <= preq_len - 3;
                  end
                  else if(be_sof == 2) begin
                      temp_data   <= {16'h0,wbd_dat_i[31:16]}; 
                      preq_len    <= preq_len - 2;
                  end
                  else begin
                      temp_data   <= {23'h0,wbd_dat_i[31:8]}; 
                      preq_len    <= preq_len - 0;
                  end
                  state     <= WB_RD_PHASE_CONT;
               end
            end
            else begin
               dma_rd_o  <= 0;
            end
         end
      WB_RD_PHASE_CONT:
         begin
            dma_start_o  <= 0;
            if(wbd_ack_i) begin
               dma_rd_o         <= 1;
               twbtrans         <= twbtrans -1;
               if(be_sof == 0) begin
                  dma_rdata_o   <= wbd_dat_i; 
                  preq_len      <= preq_len - 4;
               end 
               else if(be_sof == 1) begin
                  dma_rdata_o   <= {wbd_dat_i[7:0],temp_data[23:0]}; 
                  temp_data     <= {8'h0,wbd_dat_i[31:8]};
                  preq_len      <= preq_len - 3;
               end
               else if(be_sof == 2) begin
                  dma_rdata_o   <= {wbd_dat_i[15:0],temp_data[15:0]}; 
                  temp_data     <= {16'h0,wbd_dat_i[31:16]};
                  preq_len      <= preq_len - 2;
               end
               else begin
                  dma_rdata_o   <= {wbd_dat_i[23:0],temp_data[7:0]}; 
                  temp_data     <= {24'h0,wbd_dat_i[31:23]};
                  preq_len      <= preq_len - 1;
               end
               if(twbtrans == 1) begin  // If the it's last transfer
                  dma_last_o <= 1;
                  state      <= WB_IDLE;
               end
            end
            else begin
               dma_last_o <= 0;
               dma_rd_o   <= 0;
            end
         end
      endcase
   end
end 



endmodule
