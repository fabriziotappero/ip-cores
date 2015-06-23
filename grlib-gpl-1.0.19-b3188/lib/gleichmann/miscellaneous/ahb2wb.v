//                              -*- Mode: Verilog -*-
// Filename        : ahb2wb.v
// Description     : this module makes up the interface between the AMBA
//                   AHB slave and the Wishbone slave
// Author          : Thomas Ameseder
// Created On      : Mon Mar 01 13:55:59 2004
//
// CVS entries:
//   $Author: tame $
//   $Date: 2006/08/14 15:25:09 $
//   $Revision: 1.1 $
//   $State: Exp $



// synopsys translate_off
//`include "mc_defines.v"
// synopsys translate_on

// synopsys translate_off
`timescale 1ns/10ps
// synopsys translate_on

// AHB responses
`define HRESP_OK    2'b00
`define HRESP_ERROR 2'b01
`define HRESP_RETRY 2'b10
`define HRESP_SPLIT 2'b11               // unused
`define HRESP_UNDEF 2'bxx



module ahb2wb
  // AMBA interface
  (hclk, hresetn, hsel, hready_ba, haddr, hwrite, htrans, hsize, hburst,
   hwdata, hmaster, hmastlock, hready, hresp, hrdata, hsplit,

  // Wishbone interface
   wb_inta_i, wbm_adr_o, wbm_dat_o, wbm_sel_o, wbm_we_o,
   wbm_stb_o, wbm_cyc_o, wbm_dat_i, wbm_ack_i, wbm_rty_i, wbm_err_i,

  // miscellaneous signals
   irq_o
  );


   parameter HAMAX = 8;
   parameter HDMAX = 8;

   // AHB state machine
   parameter [1:0 ] IDLE = 2'b 00,
                    SELECTED = 2'b 01,
                    RESP_1 = 2'b 10,
                    RESP_2 = 2'b 11;


   input              hclk,
                      hresetn;
   input              hsel,
                      hready_ba,
                      hwrite,
                      hmastlock;          // unused
   input [HAMAX-1:0]  haddr;
   input [1:0]        htrans;             // unused
   input [2:0]        hsize,
                      hburst;             // unused
   input [HDMAX-1:0]  hwdata;
   input [3:0]        hmaster;            // unused
   input              wb_inta_i,
                      wbm_ack_i,
                      wbm_rty_i,
                      wbm_err_i;
   input [HDMAX-1:0]  wbm_dat_i;

   output             hready;
   output [1:0]       hresp;
   output [HDMAX-1:0] hrdata;
   output [15:0]      hsplit;

   output             wbm_we_o,
                      wbm_stb_o,
                      wbm_cyc_o;
   output [HAMAX-1:0] wbm_adr_o;
   output [HDMAX-1:0] wbm_dat_o;
   output [3:0]       wbm_sel_o;

   output             irq_o;

   reg                wbm_stb_o, wbm_we_o, irq_o;
   reg [3:0]          wbm_sel_o;
   reg                hready;
   reg [1:0]          hresp;
   reg [HDMAX-1:0]    hrdata;
   reg [15:0]         hsplit;
   reg [HAMAX-1:0]    wbm_adr_o;
   reg                wbm_cyc_o;
   reg [HDMAX-1:0]    wbm_dat_o;
   

   /****  MODULE BODY  ****/

   // local signals
   wire               wb_stb_start_next, wb_stb_end_next, wb_cyc_next;

   reg                hready_s;
   reg [1:0]          hresp_s;
   reg [HDMAX-1:0]    hrdata_s;
   reg [15:0]         hsplit_s;
   reg [1:0]          state, next_state;


   assign             wb_stb_start_next =  hready_ba & hsel;
   assign             wb_stb_end_next =  wbm_ack_i  | wbm_err_i | wbm_rty_i;
   assign             wb_cyc_next =  hready_ba;


   /*  model wishbone output signals  */
   always @ (posedge hclk or negedge hresetn) begin
      if (!hresetn) begin
         wbm_we_o <= #1 1'b  0;
         wbm_sel_o <= #1 4'h 0;
         wbm_cyc_o <= #1 0;
         wbm_stb_o <= #1 0;
         wbm_adr_o <= #1 0;
         wbm_dat_o <= #1 0;
      end else begin

         // wishbone cycle must not be shorter than strobe signal
         if (wb_cyc_next)
           wbm_cyc_o <= #1 1;
         else if (!wb_cyc_next & wbm_stb_o & !wb_stb_end_next)
           wbm_cyc_o <= #1 1;
         else
           wbm_cyc_o <= #1 0;

         // strobe has to be high until slave
         // acknowledges or signals an error
         if (wb_stb_end_next) begin
            wbm_stb_o <= #1 0;
            wbm_we_o <= #1 1'h  0;
         end else if (wb_stb_start_next) begin
            wbm_dat_o <= #1 hwdata;
            wbm_adr_o <= #1 haddr;
            wbm_stb_o <= #1 1;
            wbm_we_o  <= #1 hwrite;
            case (hsize)
              0: wbm_sel_o <= #1 4'h 1;
              1: wbm_sel_o <= #1 4'h 3;
              2: wbm_sel_o <= #1 4'h f;
              default: wbm_sel_o <= #1 4'h x;
            endcase
         end else if (!wbm_cyc_o) begin // propagate address, data
            wbm_dat_o <= #1 hwdata;     // and write signals
            wbm_adr_o <= #1 haddr;
            wbm_we_o  <= #1 hwrite;
         end
      end
   end // always @ (posedge hclk or negedge hresetn)


   /*  model ahb response signals  */
   always @ ( /*`HRESP_ERROR or `HRESP_OK or `HRESP_RETRY
             or `HRESP_UNDEF or */ hresp or state or wb_cyc_next
             or wb_stb_start_next or wbm_ack_i or wbm_dat_i
             or wbm_err_i or wbm_rty_i) begin

      // defaults to avoid latches
      hsplit_s = 16'b 0; // no split transactions
      hready_s = 1;		
      hresp_s = `HRESP_OK;
      hrdata_s = 8'b 0;
      next_state = IDLE;

      case (state)
        IDLE: begin
           if (wb_stb_start_next) begin
              next_state = SELECTED;
              hready_s = 0;
           end
        end
        SELECTED: begin
           hready_s = 0;
           next_state = SELECTED;
           if (wbm_err_i) begin
              hresp_s = `HRESP_ERROR;
              hready_s = 0;
              next_state = RESP_1;
           end else if (wbm_rty_i) begin
              hresp_s = `HRESP_RETRY;
              hready_s = 0;
              next_state = RESP_1;
           end else if (wbm_ack_i) begin
              hresp_s = `HRESP_OK;
              hready_s = 1;
              hrdata_s = wbm_dat_i;
              next_state = RESP_2;
           end
        end
        RESP_1: begin              // for two-cycle error or retry responses
           hready_s = 1;
           hresp_s = hresp;        // keep previous response
           if (wb_cyc_next)        // only change state when ahb arbiter is ready to sample
             next_state = RESP_2;
           else begin
              next_state = RESP_1;
              hready_s = 0;
           end
        end
        RESP_2: begin
           hready_s = 1;
           if (wb_cyc_next) begin  // only change state when ahb arbiter is ready to sample
              hresp_s = `HRESP_OK;
              hready_s = 1;
              next_state = IDLE;
           end else begin
              next_state = RESP_2;
              hresp_s = hresp;     // keep previous response
           end
        end
        default: begin             // for simulation purposes
           next_state = IDLE;
           hready_s = 1'b x;
           hresp_s = `HRESP_UNDEF;
           hrdata_s = 8'b x;
           hsplit_s = 16'b 0;
        end
      endcase // case(state)
   end // always @ (...


   // change state, propagate interrupt
   always @ (posedge hclk or negedge hresetn) begin
      if (!hresetn) begin
         state  <= #1 IDLE;
         hresp  <= #1 `HRESP_UNDEF;
         hrdata <= #1  8'b x;
         hsplit <= #1 16'b 0;
         hready <= #1 1'b 1;		
         irq_o  <= #1 1'b 0;
      end else begin
         state  <= #1 next_state;
         hresp  <= #1 hresp_s;
         hrdata <= #1 hrdata_s;
         hsplit <= #1 hsplit_s;
         hready <= #1 hready_s;
         irq_o  <= #1  wb_inta_i;
      end
   end


endmodule // ahb2wb



