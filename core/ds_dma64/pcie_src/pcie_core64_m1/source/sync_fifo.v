
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : sync_fifo.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
/******************************************************************************

    Description:    This module is functions as a FIFO

******************************************************************************/

`timescale 1ns/1ps

module sync_fifo
  #(
    parameter WIDTH    = 32,
    parameter DEPTH    = 16,
    parameter STYLE    = "SRL",  //Choices: SRL, REG, BRAM
    parameter AFASSERT = DEPTH-1,
    parameter AEASSERT = 1,
    parameter FWFT     = 0,
    parameter SUP_REWIND = 0,
    parameter INIT_OUTREG = 0,
    parameter ADDRW = (DEPTH<=2)    ? 1:
                      (DEPTH<=4)    ? 2:
                      (DEPTH<=8)    ? 3:
                      (DEPTH<=16)   ? 4:
                      (DEPTH<=32)   ? 5:
                      (DEPTH<=64)   ? 6:
                      (DEPTH<=128)  ? 7:
                      (DEPTH<=256)  ? 8:
                      (DEPTH<=512)  ? 9:
                      (DEPTH<=1024) ?10:
                      (DEPTH<=2048) ?11:
                      (DEPTH<=4096) ?12:
                      (DEPTH<=8192) ?13:
                      (DEPTH<=16384)?14: -1
   )
   (
   input  wire             clk,
   input  wire             rst_n,
   input  wire [WIDTH-1:0] din,
   output wire [WIDTH-1:0] dout,
   input  wire             wr_en,
   input  wire             rd_en,
   output reg              full,
   output reg              afull,
   output wire             empty,
   output wire             aempty,
   output wire [ADDRW:0]   data_count,
   //rewind stuff
   input  wire             mark_addr,
   input  wire             clear_addr,
   input  wire             rewind
   );


   parameter TCQ = 1;
   reg    [WIDTH-1:0] regBank         [DEPTH-1:0];
   wire   [WIDTH-1:0] dout_int;
   reg    [ADDRW:0]   data_count_int;
   wire   [ADDRW-1:0] data_count_int_trunc;
   reg    [ADDRW:0]   data_count_m1;
   wire   [ADDRW-1:0] data_count_m1_trunc;
   wire   [ADDRW:0]   data_count_pkt;
   reg    [ADDRW:0]   data_count_pkt_up;
   reg    [ADDRW:0]   data_count_pkt_down;
   reg    [ADDRW-1:0] bram_waddr;
   reg    [ADDRW-1:0] bram_raddr;
   reg    [ADDRW-1:0] rewind_addr;
   reg    [ADDRW-1:0] packet_size_int;
   reg                clear_addr_d;
   reg                empty_int;
   reg                aempty_int;
   reg    [WIDTH-1:0] output_stage;
   reg                output_stage_empty;
   wire               wr_en_int;
   wire               rd_en_fwft;
   reg                internal_fifo_newdata = 0;
   wire               internal_fifo_newdata_take;
   integer            i,ii;


//{{{ Choose external IO drivers based on mode
// Read Enable must be qualified with Empty; for FWFT, internal logic drives
assign rd_en_int = FWFT ? rd_en_fwft : (rd_en && !empty_int);
// Write Enable must be qualified with Full
assign wr_en_int = wr_en && !full && !(SUP_REWIND && rewind);
// Dout is the output register stage in FWFT mode
assign dout   = FWFT ? output_stage : dout_int;
//Empty indicates that the output stage is not valid in FWFT mode
assign empty  = FWFT ? output_stage_empty : empty_int;
//Aempty may be assert 1 cycle soon for FWFT
assign aempty = FWFT ? (aempty_int || output_stage_empty) : aempty_int;
assign data_count = data_count_int;
//}}}

assign data_count_int_trunc = data_count_int[ADDRW-1:0];
assign data_count_m1_trunc  = data_count_m1[ADDRW-1:0];

//{{{ Infer Memory 
//{{{ SRL 16 should be inferred
generate if (STYLE=="SRL")  begin: srl_style_fifo
   always @(posedge clk) begin
      if (wr_en_int) begin
         for (i=(DEPTH-1); i>0; i=i-1)
            regBank[i] <= #TCQ regBank[i-1];
         regBank[0]    <= #TCQ din;
      end
   end
 
   assign dout_int = FWFT ? regBank[data_count_m1_trunc] : regBank[data_count_int_trunc];

   initial begin
      for (ii=(DEPTH-1); ii>=0; ii=ii-1) regBank[ii] = INIT_OUTREG;
   end
//}}}
//{{{ SRL 16 w/Registered output should be inferred
end else if (STYLE=="SRLREG")  begin: srlreg_style_fifo
   reg    [WIDTH-1:0] dout_reg = INIT_OUTREG;

   always @(posedge clk) begin
      if (wr_en_int) begin
         for (i=(DEPTH-1); i>0; i=i-1)
            regBank[i] <= #TCQ regBank[i-1];
         regBank[0]    <= #TCQ din;
      end
   end

   always @(posedge clk or negedge rst_n) begin
      if (!rst_n)
        dout_reg <= #TCQ INIT_OUTREG;
      else if (rd_en_int) begin
         dout_reg    <= #TCQ regBank[data_count_m1_trunc]; //"m1" points to latest data
      end
   end
 
   assign dout_int = dout_reg;

   initial begin
      for (ii=(DEPTH-1); ii>=0; ii=ii-1) regBank[ii] = INIT_OUTREG;
   end
//}}}
//{{{ BRAM(s) should be inferred
end else if (STYLE=="BRAM") begin: bram_style_fifo
   reg    [WIDTH-1:0] dout_reg;

   always @(posedge clk) begin
      if (wr_en_int) begin
         regBank[bram_waddr]    <= #TCQ din;
      end
   end

   always @(posedge clk) begin
      if (rd_en_int) begin
         dout_reg    <= #TCQ regBank[bram_raddr];
      end
   end

   assign dout_int = dout_reg;

//}}}
//{{{ REGISTERs should be inferred
end else begin: reg_style_fifo //STYLE==REG
   reg    [WIDTH-1:0] dout_reg = INIT_OUTREG;

   always @(posedge clk or negedge rst_n) begin
      if (!rst_n)
         for (i=(DEPTH-1); i>=0; i=i-1) regBank[i] <= #TCQ INIT_OUTREG;
      else if (wr_en_int) begin
         for (i=(DEPTH-1); i>0; i=i-1)  regBank[i] <= #TCQ regBank[i-1];
         regBank[0]    <= #TCQ din;
      end
   end

   always @(posedge clk or negedge rst_n) begin
      if (!rst_n)
        dout_reg <= #TCQ INIT_OUTREG;
      else if (rd_en_int)
        dout_reg <= #TCQ regBank[data_count_m1_trunc];
   end

   assign dout_int = dout_reg;

end
endgenerate
//}}}
//}}}

//{{{ SRL/Reg Address Logic; SRL/Reg/BRAM flag logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       data_count_int  <= #TCQ 'h0;
       data_count_m1   <= #TCQ {(ADDRW+1){1'b1}};
       full            <= #TCQ 1'b0;
       afull           <= #TCQ 1'b0;
    // read from non-empty FIFO, not writing to FIFO
    end else if (rd_en_int && !wr_en_int) begin
       data_count_int  <= #TCQ data_count_int - 1;
       data_count_m1   <= #TCQ data_count_m1  - 1;
       full            <= #TCQ 1'b0;
       if (data_count_int == AFASSERT)
         afull           <= #TCQ 1'b0;
    // write into non-full FIFO, not reading from FIFO
    end else if (!rd_en_int && wr_en_int) begin
       data_count_int  <= #TCQ data_count_int + 1;
       data_count_m1   <= #TCQ data_count_m1  + 1;
       if (data_count_int == (DEPTH-1))
         full            <= #TCQ 1'b1;
       if (data_count_int == (AFASSERT-1))
         afull           <= #TCQ 1'b1;
    end
end

`ifdef SV
  //synthesis translate_off
  ASSERT_FIFO_OVERFLOW:      assert property (@(posedge clk)
    !(data_count_int > DEPTH))                else $fatal;
  ASSERT_FIFO_UNDERFLOW:     assert property (@(posedge clk)
     (data_count_int=='h0) |-> ##1 !(&data_count_int)) else $fatal;
  ASSERT_FIFO_AFULLCHECK1:   assert property (@(posedge clk)
    afull  |-> (data_count_int >= AFASSERT)) else $fatal;
  ASSERT_FIFO_AFULLCHECK2:   assert property (@(posedge clk)
    !afull |-> (data_count_int <  AFASSERT)) else $fatal;
  ASSERT_FIFO_AEMPTYCHECK1R: assert property (@(posedge clk)
    aempty &&  SUP_REWIND && !FWFT |-> (data_count_pkt <= AEASSERT)) else $fatal;
  ASSERT_FIFO_AEMPTYCHECK1 : assert property (@(posedge clk)
    aempty && !SUP_REWIND && !FWFT |-> (data_count_int <= AEASSERT)) else $fatal;
  ASSERT_FIFO_AEMPTYCHECK2R: assert property (@(posedge clk)
   !aempty &&  SUP_REWIND && !FWFT |-> (data_count_pkt >  AEASSERT)) else $fatal;
  ASSERT_FIFO_AEMPTYCHECK2 : assert property (@(posedge clk)
   !aempty && !SUP_REWIND && !FWFT |-> (data_count_int >  AEASSERT)) else $fatal;
  //synthesis translate_on
`endif

//}}}

//{{{ BRAM-Style FIFO Address logic
generate if (STYLE=="BRAM") begin: gen_bram_address_logic
   always @(posedge clk or negedge rst_n) begin
     if (!rst_n) begin
        bram_waddr  <= #TCQ 'h0;
     // Rewind to the stored address
     end else if (SUP_REWIND && rewind) begin
        bram_waddr  <= #TCQ rewind_addr;
     end else if (wr_en_int) begin
        bram_waddr  <= #TCQ bram_waddr + 1;
     end
   end

   always @(posedge clk or negedge rst_n) begin
     if (!rst_n) begin
        bram_raddr      <= #TCQ 'h0;
     end else if (rd_en_int) begin
        bram_raddr      <= #TCQ bram_raddr + 1;
     end
   end
end

`ifdef SV
  //synthesis translate_off
  ASSERT_FIFO_NOTWRITTEN_WHEN_FULL:  assert property (@(posedge clk)
    full      && rst_n |-> ##1 $stable(bram_waddr)) else $fatal;
  ASSERT_FIFO_NOTWRITTEN_WHEN_EMPTY: assert property (@(posedge clk)
    empty_int && rst_n |-> ##1 $stable(bram_raddr)) else $fatal;
  ASSERT_FIFO_REWINDNOWRAP:   assert property (@(posedge clk)
    SUP_REWIND && rewind && (bram_waddr>=bram_raddr) |-> ##1 (bram_waddr>=bram_raddr)) else $fatal;
  ASSERT_FIFO_REWINDWRAP:     assert property (@(posedge clk)
    SUP_REWIND && rewind && (bram_waddr< bram_raddr) |-> ##1 (bram_waddr<$past(bram_waddr))||(bram_waddr>=bram_raddr)) else $fatal;
  //synthesis translate_on
`endif

endgenerate
//}}}






//{{{ Rewind Capture logic
generate if (SUP_REWIND) begin: gen_rewind

   //REWIND Logic: Running count of packet size; location of SOF
   always @(posedge clk or negedge rst_n) begin
     if (!rst_n) begin
        rewind_addr      <= #TCQ 'h0;
        packet_size_int  <= #TCQ 'h1;
     end else if (wr_en_int) begin
        if (mark_addr) begin
           rewind_addr     <= #TCQ bram_waddr;
           packet_size_int <= #TCQ 'h1;
        end else begin
           packet_size_int <= #TCQ packet_size_int + 1;
        end
     end
   end

   assign data_count_pkt = data_count_pkt_up + data_count_pkt_down;

   //REWIND Logic: Compute number words in good packets, calculate empty flags
   always @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
          data_count_pkt_down <= #TCQ 'h0;
          data_count_pkt_up  <= #TCQ 'h0;
          empty_int       <= #TCQ 1'b1;
          aempty_int      <= #TCQ 1'b1;
       // read from non-empty FIFO, not writing a packet count
       end else if (rd_en_int && !clear_addr_d) begin
          data_count_pkt_down <= #TCQ data_count_pkt_down - 1;
          data_count_pkt_up   <= #TCQ data_count_pkt_up;
          empty_int           <= #TCQ (data_count_pkt <= 1);
          aempty_int          <= #TCQ (data_count_pkt <= (AEASSERT+1));
       // write packet count, not reading from FIFO
       end else if (!rd_en_int && clear_addr_d) begin
          data_count_pkt_down <= #TCQ data_count_pkt_down;
          data_count_pkt_up   <= #TCQ data_count_pkt_up + packet_size_int;
          empty_int           <= #TCQ 1'b0;
          aempty_int          <= #TCQ (data_count_pkt + packet_size_int) <= AEASSERT;
       // read from non-empty FIFO and writing a packet count
       end else if (rd_en_int &&  clear_addr_d) begin
          data_count_pkt_down <= #TCQ data_count_pkt_down - 1;
          data_count_pkt_up   <= #TCQ data_count_pkt_up + packet_size_int;
          empty_int           <= #TCQ 1'b0;
          aempty_int          <= #TCQ (data_count_pkt + packet_size_int - 1) <= AEASSERT;
       end
   end

   //Pipeline
   always @(posedge clk or negedge rst_n) begin
     if (!rst_n) begin
        clear_addr_d        <= #TCQ 1'b0;
     end else begin
        clear_addr_d        <= #TCQ clear_addr && !rewind;
     end
   end


end else begin: gen_norewind

   always @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
          empty_int       <= #TCQ 1'b1;
          aempty_int      <= #TCQ 1'b1;
       // read from non-empty FIFO, not writing to FIFO
       end else if (rd_en_int && !wr_en_int) begin
          if (data_count_int == 1)
            empty_int       <= #TCQ 1'b1;
          if (data_count_int == (AEASSERT+1))
            aempty_int      <= #TCQ 1'b1;
       // write into non-full FIFO, not reading from FIFO
       end else if (!rd_en_int && wr_en_int) begin
          empty_int       <= #TCQ 1'b0;
          if (data_count_int == AEASSERT)
            aempty_int      <= #TCQ 1'b0;
       end
   end

end
endgenerate
//}}}






//{{{ FWFT logic
generate if (FWFT) begin: gen_fwft_common
   always @(posedge clk or negedge rst_n) begin
     if (!rst_n) begin
        output_stage       <= #TCQ INIT_OUTREG;
        output_stage_empty <= #TCQ 1'b1;
     end else if (internal_fifo_newdata_take) begin
        output_stage       <= #TCQ dout_int;
        output_stage_empty <= #TCQ 1'b0;
     end else if (rd_en) begin
        output_stage_empty <= #TCQ 1'b1;
     end
   end
end
endgenerate




generate if ((FWFT) && (STYLE=="SRL")) begin: gen_fwft_srl

   always @*    internal_fifo_newdata = !empty_int;
   assign internal_fifo_newdata_take  = internal_fifo_newdata &&  (output_stage_empty || rd_en);
   assign rd_en_fwft = (rd_en || internal_fifo_newdata_take) && !empty_int;

end else if (FWFT) begin: gen_fwft

   always @(posedge clk or negedge rst_n) begin
     if (!rst_n) begin
        internal_fifo_newdata <= #TCQ 1'b0;
     end else if (rd_en_fwft) begin
        internal_fifo_newdata <= #TCQ 1'b1;
     end else if (internal_fifo_newdata_take) begin
        internal_fifo_newdata <= #TCQ 1'b0;
     end
   end

   assign internal_fifo_newdata_take  = internal_fifo_newdata &&  (output_stage_empty || rd_en);
   assign rd_en_fwft = (rd_en || internal_fifo_newdata_take) && !empty_int;

`ifdef SV
  //synthesis translate_off
  ASSERT_FIFO_FWFTEMPTYCHECK1: assert property (@(posedge clk)
    internal_fifo_newdata                     |-> ##1 !empty) else $fatal;
  ASSERT_FIFO_FWFTEMPTYCHECK2: assert property (@(posedge clk)
    !internal_fifo_newdata && !empty && rd_en |-> ##1  empty) else $fatal;
  //synthesis translate_on
`endif

end
endgenerate
//}}}

endmodule
