`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  (C) Athree, 2009
// Engineer: Dmitry Rozhdestvenskiy 
// Email dmitry.rozhdestvenskiy@srisc.com dmitryr@a3.spb.ru divx4log@narod.ru
// 
// Design Name:    Wishbone NOR flash controller
// Module Name:    wbflash 
// Project Name:   SPARC SoC single-core
//
// LICENSE:
// This is a Free Hardware Design; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// version 2 as published by the Free Software Foundation.
// The above named program is distributed in the hope that it will
// be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
//////////////////////////////////////////////////////////////////////////////////
module WBFLASH(
    input             wb_clk_i,
    input             wb_rst_i,
    
    input      [63:0] wb_dat_i, 
    output     [63:0] wb_dat_o, 
    input      [63:0] wb_adr_i, 
    input      [ 7:0] wb_sel_i, 
    input             wb_we_i, 
    input             wb_cyc_i, 
    input             wb_stb_i, 
    output reg        wb_ack_o, 
    output            wb_err_o, 
    output            wb_rty_o, 
    input             wb_cab_i,
     
    input      [63:0] wb1_dat_i, 
    output     [63:0] wb1_dat_o, 
    input      [63:0] wb1_adr_i, 
    input      [ 7:0] wb1_sel_i, 
    input             wb1_we_i, 
    input             wb1_cyc_i, 
    input             wb1_stb_i, 
    output reg        wb1_ack_o, 
    output            wb1_err_o, 
    output            wb1_rty_o, 
    input             wb1_cab_i,

    output reg [24:0] flash_addr,
    input      [15:0] flash_data,
    output            flash_oen,
    output            flash_wen,
    output            flash_cen,
    input      [ 1:0] flash_rev
     //output            flash_ldn
);

assign wb_err_o=0;
assign wb_rty_o=0;

reg  [1:0] wordcnt;
reg  [2:0] cyclecnt;
reg [63:0] wb_dat;
reg [63:0] wb1_dat;
reg [63:0] wb_dat_inv;
reg [63:0] cache_addr;
reg [63:0] cache_addr1;

always @(posedge wb_clk_i or posedge wb_rst_i)
   if(wb_rst_i)
      begin
         cache_addr<=64'b0;
         cache_addr1<=64'b0;
      end
   else
      if((!wb_cyc_i || !wb_stb_i) && (!wb1_cyc_i || !wb1_stb_i))
         begin
            wordcnt<=2'b00;
            cyclecnt<=3'b000;
            wb_ack_o<=0;
            wb1_ack_o<=0;
         end
      else
         if(wb_stb_i)
            if(wb_adr_i==cache_addr)
               wb_ack_o<=1;
            else
               if(cyclecnt!=3'b111)
                  cyclecnt<=cyclecnt+1;
               else
                  begin
                     cyclecnt<=0;
                     case(wordcnt)
                        2'b00:wb_dat[63:48]<={flash_data[7:0],flash_data[15:8]};
                        2'b01:wb_dat[47:32]<={flash_data[7:0],flash_data[15:8]};
                        2'b10:wb_dat[31:16]<={flash_data[7:0],flash_data[15:8]};
                        2'b11:wb_dat[15: 0]<={flash_data[7:0],flash_data[15:8]};
                     endcase
                     if(wordcnt!=2'b11)
                        wordcnt<=wordcnt+1;
                     else
                        begin
                           wb_ack_o<=1;
                           cache_addr<=wb_adr_i;
                        end
                  end      
         else
            if(wb1_adr_i==cache_addr1)
               wb1_ack_o<=1;
            else
               if(cyclecnt!=3'b111)
                  cyclecnt<=cyclecnt+1;
               else
                   begin
                      cyclecnt<=0;
                      case(wordcnt)
                         2'b00:wb1_dat[63:48]<={flash_data[7:0],flash_data[15:8]};
                         2'b01:wb1_dat[47:32]<={flash_data[7:0],flash_data[15:8]};
                         2'b10:wb1_dat[31:16]<={flash_data[7:0],flash_data[15:8]};
                         2'b11:wb1_dat[15: 0]<={flash_data[7:0],flash_data[15:8]};
                      endcase
                      if(wordcnt!=2'b11)
                         wordcnt<=wordcnt+1;
                      else
                         begin
                            wb1_ack_o<=1;
                            cache_addr1<=wb1_adr_i;
                         end
                   end      

assign wb_dat_o=wb_dat;
assign wb1_dat_o=wb1_dat;

wire [1:0] flash_rev_d;

assign flash_rev_d=wb_rst_i ? flash_rev:flash_rev_d;

always @( * )
   case({wb1_stb_i,flash_rev_d})
      3'b000:flash_addr<={wb_adr_i[25:3],wordcnt}+25'h0000000;
      3'b001:flash_addr<={wb_adr_i[25:3],wordcnt}+25'h0100000;
      3'b010:flash_addr<={wb_adr_i[25:3],wordcnt}+25'h0200000;
      3'b011:flash_addr<={wb_adr_i[25:3],wordcnt}+25'h0300000;
      3'b100:flash_addr<={wb1_adr_i[25:3],wordcnt}+25'h0400000;
      3'b101:flash_addr<={wb1_adr_i[25:3],wordcnt}+25'h0400000;
      3'b110:flash_addr<={wb1_adr_i[25:3],wordcnt}+25'h0400000;
      3'b111:flash_addr<={wb1_adr_i[25:3],wordcnt}+25'h0400000;
   endcase

assign flash_oen=((wb_cyc_i && wb_stb_i) || (wb1_cyc_i && wb1_stb_i) ? 0:1);
assign flash_wen=1;
assign flash_cen=0;

endmodule
