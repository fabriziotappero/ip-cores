//
// Copyright (c) 2004 Guy Hutchison (ghutchis@opencores.org)
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//----------------------------------------------------------------------
//  Simple network interface
//
//  Implements a GMII-like byte-wide interface on one side, and
//  an IO-mapped interface to the tv80.

//  IO-interface:
//    R0  --  Status register
//    R1  --  Control register
//    R2  --  RX Length (low)
//    R3  --  RX Length (high)
//    R4  --  RX Data
//    R5  --  TX Data
//    R6  --  Configuration

//  Status bits:
//    [0]     RX Packet Ready
//    [1]     TX Transmit Complete

//  Control bits:
//    [0]     Send TX Packet
//----------------------------------------------------------------------

module simple_gmii_core
  #(parameter txbuf_sz = 512,
    parameter rxbuf_sz = 512,
    parameter wr_ptr_sz = 10)
  (
   input      clk,
   input      reset,

   // GMII Interface
   input [7:0] rx_data,
   input       rx_clk,
   input       rx_dv,
   input       rx_er,

   output reg [7:0] tx_data,
   input            tx_clk,
   output reg       tx_dv,
   output reg       tx_er,

   // RX Buf RAM
   output reg         rxbuf_we,
   output reg [wr_ptr_sz-1:0] rx_wr_ptr, 
   output reg [wr_ptr_sz-1:0] rx_rd_ptr,
   input [7:0]  rxbuf_data,

   // TX Buf RAM
   output reg                 wr_sel_tx_data,
   output reg [wr_ptr_sz-1:0] txi_wr_ptr,
   //input [7:0]                io_data_in,
   output reg [wr_ptr_sz-1:0] txo_xm_ptr,
   input  [7:0]               txbuf_data,

   // Register interface
   output [1:0]  status_set,
   input         start_transmit,   // control[0]
   output [15:0] rx_len,
   output [7:0]  rx_rd_data,
   input         rx_rd_stb,
   //input [7:0]   tx_wr_data,
   input         tx_wr_stb,
   input         en_preamble       // config[0]
  );
  
  //parameter   io_base_addr = 8'hA0;
  //parameter txbuf_sz = 512, rxbuf_sz = 512;
  //parameter wr_ptr_sz = 10;
  
  //parameter st_tx_idle = 0, st_tx_xmit = 1;
  parameter st_txi_idle = 1'b0, st_txi_xmit = 1'b1;
  parameter st_txo_idle = 2'b0, st_txo_pre = 2'b10, st_txo_xmit = 2'b11, st_txo_wait = 2'b01;
  parameter st_rxo_idle = 2'b00,
            st_rxo_ready = 2'b01,
            st_rxo_ack   = 2'b11;
  
  parameter st_rxin_idle = 2'b00,
            st_rxin_pre  = 2'b01,
            st_rxin_receive = 2'b11,
            st_rxin_hold    = 2'b10;

  parameter SFD = 8'hD5;
  
  //reg [wr_ptr_sz-1:0] tx_wr_ptr, tx_xm_ptr;
  reg [wr_ptr_sz-1:0] rx_count;
  reg         txi_state;
  reg [1:0]   txo_state;
  reg        txi_start;
  wire       txo_start;
  reg        txo_done;
  wire       txi_done;
  reg [wr_ptr_sz-1:0] txo_wr_ptr;
  

  reg         stat_tx_complete;

  reg         stat_rx_avail;

  reg [1:0]   rxin_state;
  reg         rxin_complete;
  reg [1:0]   nxt_rxin_state;
  reg         nxt_rxin_complete;
  reg [wr_ptr_sz-1:0] nxt_rx_wr_ptr;
  reg         rd_sel_rx_data;
  reg [1:0]   rxo_state;
  wire        rxo_complete;
  reg         rxo_ack;
  wire        rxin_ack;
 
  //assign      io_select = ((io_base_addr >> 3) == addr[7:3]);

  //------------------------------
  // IO Read Mux
  //------------------------------

  assign rx_len = { {16-wr_ptr_sz{1'b0}}, rx_count };
  assign status_set = { stat_tx_complete, stat_rx_avail };
  assign rx_rd_data = rxbuf_data;
  
  //------------------------------
  // Receive Logic
  //------------------------------

  always @*
    begin
      rd_sel_rx_data = rx_rd_stb;
      //rxbuf_we = ((rxin_state == st_rxin_idle) | (rxin_state == st_rxin_receive)) & rx_dv;
    end
  /*
  ram_1r_1w #(8, rxbuf_sz, wr_ptr_sz) rxbuf
    (.clk     (rx_clk),
     .wr_en   (rxbuf_we),
     .wr_addr (rx_wr_ptr),
     .wr_data (rx_data),

     .rd_addr (rx_rd_ptr),
     .rd_data (rxbuf_data));
  */

  always @*
    begin
      rxbuf_we = 0;
      nxt_rxin_complete = rxin_complete;
      nxt_rxin_state = rxin_state;
      nxt_rx_wr_ptr = rx_wr_ptr;
      
      case (rxin_state)
        st_rxin_idle :
          begin
            if (rx_dv)
              begin
                nxt_rxin_complete = 0;
                if (en_preamble & (rx_data != SFD))
                  nxt_rxin_state = st_rxin_pre;
                else
                  begin
                    nxt_rx_wr_ptr = rx_wr_ptr + 1;
                    nxt_rxin_state = st_rxin_receive;
                    rxbuf_we = 1;
                  end
              end
            else
              begin
                nxt_rx_wr_ptr = 0;
              end
          end // case: st_rxin_idle

        st_rxin_pre :
          begin
            if (rx_data == SFD)
              nxt_rxin_state = st_rxin_receive;
          end
        
        st_rxin_receive :
          begin
            if (rx_dv)
              begin
                nxt_rx_wr_ptr = rx_wr_ptr + 1;
                rxbuf_we = 1;
              end
            else
              begin
                nxt_rxin_state = st_rxin_hold;
                nxt_rxin_complete = 1;
              end
          end

        st_rxin_hold :
          begin
            if (rxin_ack & !rx_dv)
              begin
                nxt_rxin_state = st_rxin_idle;
                nxt_rxin_complete = 0;
              end
          end

        default :
          nxt_rxin_state = st_rxin_idle;
      endcase // case(rxin_state)
    end // always @ *
  
  always @(posedge rx_clk)
    begin
      if (reset)
        begin
          rxin_state    <= #1 st_rxin_idle;
          rxin_complete <= #1 0;
          rx_wr_ptr     <= #1 0;
        end
      else
       begin
         rxin_state    <= #1 nxt_rxin_state;
         rxin_complete <= #1 nxt_rxin_complete;
         rx_wr_ptr     <= #1 nxt_rx_wr_ptr;
       end // else: !if(reset)
    end // always @ (posedge rx_clk)
  
  /*
  always @(posedge rx_clk)
    begin
      if (reset)
        begin
          rxin_state    <= #1 st_rxin_idle;
          rxin_complete <= #1 0;
          rx_wr_ptr     <= #1 0;
        end
      else
        begin
          case (rxin_state)
            st_rxin_idle :
              begin
                if (rx_dv)
                  begin
                    rxin_complete <= #1 0;
                    if (en_preamble & (rx_data != SFD))
                      rxin_state <= #1 st_rxin_pre;
                    else
                      begin
                        rx_wr_ptr <= #1 rx_wr_ptr + 1;
                        rxin_state <= #1 st_rxin_receive;
                      end
                  end
                else
                  begin
                    rx_wr_ptr <= #1 0;
                  end
              end // case: st_rxin_idle

            st_rxin_pre :
              begin
                if (rx_data == SFD)
                  rxin_state <= #1 st_rxin_receive;
              end
            
            st_rxin_receive :
              begin
                if (rx_dv)
                  rx_wr_ptr <= #1 rx_wr_ptr + 1;
                else
                  begin
                    rxin_state <= #1 st_rxin_hold;
                    rxin_complete <= #1 1;
                  end
              end

            st_rxin_hold :
              begin
                if (rxin_ack & !rx_dv)
                  begin
                    rxin_state <= #1 st_rxin_idle;
                    rxin_complete <= #1 0;
                  end
              end

            default :
              rxin_state <= #1 st_rxin_idle;
          endcase // case(rxin_state)
        end // else: !if(reset)
    end // always @ (posedge rx_clk)
*/
  
  sync2 comp_sync (clk, rxin_complete, rxo_complete);
  sync2 ack_sync  (rx_clk, rxo_ack, rxin_ack);

  always @(posedge clk)
    begin
      if (reset)
        begin
          rx_count <= #1 0;
          rxo_state <= #1 st_rxo_idle;
          stat_rx_avail <= #1 0;
          rxo_ack       <= #1 0;
        end
      else
        begin
          case (rxo_state)
            st_rxo_idle :
              begin
                rx_rd_ptr     <= #1 0;
                if (rxin_complete)
                  begin
                    rxo_state <= #1 st_rxo_ready;
                    stat_rx_avail <= #1 1;
                    rx_count <= #1 rx_wr_ptr;
                  end
              end

            st_rxo_ready :
              begin
                if (rd_sel_rx_data)
                  rx_rd_ptr <= #1 rx_rd_ptr + 1;

                if (rx_rd_ptr == rx_count)
                  begin
                    rxo_ack <= #1 1;
                    rxo_state <= #1 st_rxo_ack;
                    stat_rx_avail <= #1 0;
                  end
              end // case: st_rxo_ready

            st_rxo_ack :
              begin
                if (!rxo_complete)
                  rxo_state <= #1 st_rxo_idle;
              end

            default :
              rxo_state <= #1 st_rxo_idle;
          endcase // case(rxo_state)
        end // else: !if(reset)
    end // always @ (posedge clk)
  
  //------------------------------
  // Transmit Logic
  //------------------------------

  always @*
    begin
      wr_sel_tx_data = tx_wr_stb;
    end

  /*
  ram_1r_1w #(8, txbuf_sz, wr_ptr_sz) txbuf
    (.clk     (clk),
     .wr_en   (wr_sel_tx_data),
     .wr_addr (txi_wr_ptr),
     .wr_data (io_data_in),

     .rd_addr (txo_xm_ptr),
     .rd_data (txbuf_data));  
   */

  always @(posedge clk)
    begin
      if (reset)
        begin
          txi_state <= #1 st_txi_idle;
          txi_start <= #1 0;
          txi_wr_ptr <= #1 0;
          stat_tx_complete <= #1 0;
        end
      else
        begin
          case (txi_state)
            st_txi_idle :
              begin
                stat_tx_complete <= #1 0;
                if (start_transmit)
                  begin
                    txi_state <= #1 st_txi_xmit;
                    txi_start <= #1 1;
                    
                  end
                else if (wr_sel_tx_data)
                  begin
                    txi_wr_ptr <= #1 txi_wr_ptr + 1;
                  end
              end

            st_txi_xmit :
              begin
                if (txi_done)
                  begin
                    txi_start <= #1 0;
                    txi_state <= #1 st_txi_idle;
                    txi_wr_ptr <= #1 0;
                    stat_tx_complete <= #1 1;
                  end
              end

            default :
              txi_state <= #1 st_txi_idle;
          endcase // case(txi_state)
        end
    end // always @ (posedge clk)

  sync2 tx_start_sync (tx_clk, txi_start, txo_start);
  sync2 tx_done_sync  (clk, txo_done, txi_done);


  always @(posedge tx_clk)
    begin
      if (reset)
        begin
          txo_state <= #1 st_txo_idle;
          txo_wr_ptr <= #1 0;
          txo_xm_ptr <= #1 0;
          tx_data   <= #1 0;
          tx_dv     <= #1 0;
          tx_er     <= #1 0;
          txo_done  <= #1 0;
        end
      else
        begin
          case (txo_state)
            st_txo_idle :
              begin
                txo_xm_ptr <= #1 0;
                tx_dv     <= #1 0;
                tx_er     <= #1 0;
                
                if (txo_start)
                  begin
                    if (en_preamble)
                      txo_state <= #1 st_txo_pre;
                    else
                      txo_state <= #1 st_txo_xmit;
                    txo_wr_ptr <= #1 txi_wr_ptr;
                  end
              end

            st_txo_pre :
              begin
                tx_er     <= #1 0;
                tx_dv     <= #1 1;
                if (txo_xm_ptr == 7)
                  begin
                    txo_xm_ptr <= #1 0;
                    txo_state  <= #1 st_txo_xmit;
                    tx_data    <= #1 8'hd5;
                  end
                else
                  begin
                    txo_xm_ptr <= #1 txo_xm_ptr + 1;
                    tx_data    <= #1 8'h55;
                  end
              end
            
            st_txo_xmit :
              begin
                if (txo_xm_ptr == txo_wr_ptr)
                  begin
                    tx_dv     <= #1 0;
                    tx_er     <= #1 0;
                    txo_state  <= #1 st_txo_wait;
                    txo_wr_ptr <= #1 0;
                    txo_done   <= #1 1;
                  end
                else
                  begin
                    tx_data   <= #1 txbuf_data;
                    tx_dv     <= #1 1;
                    tx_er     <= #1 0;
                    txo_xm_ptr <= #1 txo_xm_ptr + 1;
                  end
              end // case: st_txo_xmit

            st_txo_wait :
              begin
                if (!txo_start)
                  begin
                    txo_done <= #1 0;
                    txo_state <= #1 st_txo_idle;
                  end
              end

            default :
              begin
                txo_state <= #1 st_txo_idle;
              end
          endcase // case(tx_state)
        end // else: !if(reset)
    end // always @ (posedge clk)
  
endmodule

