// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_rf_16x81.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================
module bw_rf_16x81(
   rd_clk,    // read clock
   wr_clk,    // read clock
   csn_rd,    // read enable -- active low 
   csn_wr,    // write enable -- active low
   hold,      // hold signal -- unflopped -- hold =1 holds input data 
   testmux_sel, // bypass  signal -- unflopped -- testmux_sel = 1 bypasses di to do 
   scan_en,   // Scan enable unflopped  
   margin,    // Delay for the circuits--- set to 01010101 
   rd_a,      // read address  
   wr_a,      // Write address
   di,        // Data input
   si,        // scan in  
   so,        // scan out  
   listen_out, // Listening flop-- 
   do          // Data out

);

   input rd_clk;
   input wr_clk;
   input csn_rd;
   input csn_wr;
   input hold;
   input testmux_sel;
   input scan_en;
   input [4:0] margin;
   input [3:0] rd_a;
   input [3:0] wr_a;
   input [80:0] di;
   input si;
   output so;
   output [80:0] do;
   output [80:0] listen_out;

parameter  SYNC_CLOCK_CHK1 = 1;
parameter  SYNC_CLOCK_CHK2 = 1;
parameter  SYNC_CLOCK_CHK3 = 1;
parameter  MARGIN_WARNING = 1; // margin warning is on by default




// Start code
reg [80:0] memarray[15:0] ;
reg [80:0] array_out  ;

reg [80:0] array_out_latch    ;



reg  [3:0] rd_a_ff   ;
wire [3:0] rd_a_ff_so;
wire [3:0] rd_a_ff_si ;

reg  [3:0] wr_a_ff   ;
wire [3:0] wr_a_ff_so;
wire [3:0] wr_a_ff_si ;

reg  [80:0] di_ff   ;
wire [80:0] di_ff_so;
wire [80:0] di_ff_si;

wire [80:0] listen_out_so;
wire [80:0] listen_out_si ;
reg  [80:0] listen_out     ;


reg        csn_rd_ff ;
wire       csn_rd_ff_si ;
wire       csn_rd_ff_so ;

reg        csn_wr_ff ;
wire       csn_wr_ff_si ;
wire       csn_wr_ff_so ;

reg        di_ff_latch_so ;
///////////////////////////////////////
// Scan chain connections            //
///////////////////////////////////////
assign wr_a_ff_si[3:0] = {si      , wr_a_ff_so[3:1]} ;
assign csn_wr_ff_si    = wr_a_ff_so[0] ;
assign di_ff_si        = {csn_wr_ff_so, di_ff_so[80:1]};
assign listen_out_si   = {listen_out_so[79:0], di_ff_latch_so} ;
assign csn_rd_ff_si    = listen_out_so[80] ;
assign rd_a_ff_si[3:0] = {rd_a_ff_so[2:0], csn_rd_ff_so} ;
assign so              = rd_a_ff_so[3] ;
///////////////////////////////////////
// Instantiate a clock headers        //
///////////////////////////////////////

wire   rd_ssclk       = rd_clk ; // clk_en & rd_clk ;
wire   rd_local_clk   = rd_ssclk | scan_en | hold ; 
wire   rd_smclk       = rd_ssclk |  ~(scan_en | hold) ;

wire   wr_ssclk       = wr_clk ; // clk_en & wr_clk ;
wire   wr_local_clk   = wr_ssclk | scan_en | hold ; 
wire   wr_smclk       = wr_ssclk |  ~(scan_en | hold) ;


/////////////////////////////////////////////////////
// csn_rd Flop                                     //
/////////////////////////////////////////////////////

reg                     csn_rd_ff_inst_mdata ;
wire                    csn_rd_ff_inst_smin ;
reg                     csn_rd_ff_scan_out ;

assign csn_rd_ff_inst_smin  = hold ?  csn_rd_ff_scan_out :  csn_rd_ff_si ; 
always @(rd_smclk or rd_local_clk or csn_rd or csn_rd_ff_inst_smin ) begin
       if (!rd_local_clk) begin
          csn_rd_ff_inst_mdata = csn_rd ;
       end
       if (!rd_smclk) begin
          csn_rd_ff_inst_mdata = csn_rd_ff_inst_smin;
       end
end
always @(posedge rd_ssclk) begin
    csn_rd_ff_scan_out    <=  csn_rd_ff_inst_mdata ; 
end
always @(rd_local_clk or csn_rd_ff_inst_mdata) begin
   if (rd_local_clk ) begin
    csn_rd_ff    <=  csn_rd_ff_inst_mdata ; 
   end
end
assign csn_rd_ff_so =  csn_rd_ff_scan_out;
        
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
// rd_a Flop                                       //
/////////////////////////////////////////////////////
reg     [3:0]   rd_a_ff_inst_mdata ;
wire    [3:0]   rd_a_ff_inst_smin ;
reg     [3:0]   rd_a_ff_scan_out ;

assign rd_a_ff_inst_smin[3:0]  = hold ?  rd_a_ff_scan_out[3:0] :  rd_a_ff_si[3:0] ; 
always @(rd_smclk or rd_local_clk or rd_a or rd_a_ff_inst_smin ) begin
       if (!rd_local_clk) begin
          rd_a_ff_inst_mdata = rd_a[3:0] ;
       end
       if (!rd_smclk) begin
          rd_a_ff_inst_mdata = rd_a_ff_inst_smin;
       end
end
always @(posedge rd_ssclk) begin
    rd_a_ff_scan_out[3:0]   <=  rd_a_ff_inst_mdata ; 
end
always @(rd_local_clk or rd_a_ff_inst_mdata) begin
   if (rd_local_clk) begin
    rd_a_ff[3:0]   <=  rd_a_ff_inst_mdata ; 
   end
end
assign rd_a_ff_so[3:0] = rd_a_ff_scan_out[3:0] ;
/////////////////////////////////////////////////////
        
/////////////////////////////////////////////////////
// csn_wr Flop                                     //
/////////////////////////////////////////////////////
reg                     csn_wr_ff_inst_mdata ;
wire                    csn_wr_ff_inst_smin ;

assign csn_wr_ff_inst_smin  = hold ?  csn_wr_ff :  csn_wr_ff_si ; 
always @(wr_smclk or wr_local_clk or csn_wr or csn_wr_ff_inst_smin ) begin
       if (!wr_local_clk) begin
          csn_wr_ff_inst_mdata = csn_wr ;
       end
       if (!wr_smclk) begin
          csn_wr_ff_inst_mdata = csn_wr_ff_inst_smin;
       end
end
always @(posedge wr_ssclk) begin
    csn_wr_ff    <=  csn_wr_ff_inst_mdata ; 
end
assign csn_wr_ff_so =  csn_wr_ff;
/////////////////////////////////////////////////////
        
/////////////////////////////////////////////////////
// wr_a Flop                                       //
/////////////////////////////////////////////////////
reg     [3:0]   wr_a_ff_inst_mdata ;
wire    [3:0]   wr_a_ff_inst_smin ;

assign wr_a_ff_inst_smin[3:0]  = hold ?  wr_a_ff[3:0] :  wr_a_ff_si[3:0] ; 
always @(wr_smclk or wr_local_clk or wr_a or wr_a_ff_inst_smin ) begin
       if (!wr_local_clk) begin
          wr_a_ff_inst_mdata = wr_a[3:0] ;
       end
       if (!wr_smclk) begin
          wr_a_ff_inst_mdata = wr_a_ff_inst_smin;
       end
end
always @(posedge wr_ssclk) begin
    wr_a_ff[3:0]   <=  wr_a_ff_inst_mdata ; 
end
assign wr_a_ff_so[3:0] = wr_a_ff[3:0] ;
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
// di Flop                                         //
/////////////////////////////////////////////////////
reg     [80:0]  di_ff_inst_mdata ;
wire    [80:0]  di_ff_inst_smin ;

assign di_ff_inst_smin[80:0]  = hold ?  di_ff[80:0] :  di_ff_si[80:0] ; 
always @(wr_smclk or wr_local_clk or di or di_ff_inst_smin ) begin
       if (!wr_local_clk) begin
          di_ff_inst_mdata = di[80:0] ;
       end
       if (!wr_smclk) begin
          di_ff_inst_mdata = di_ff_inst_smin;
       end
end
always @(posedge wr_ssclk) begin
    di_ff[80:0]   <=  di_ff_inst_mdata ; 
end
assign di_ff_so[80:0] = di_ff[80:0] ;
/////////////////////////////////////////////////////

wire wr_enable_l = csn_wr_ff | scan_en ;
wire rd_enable_l = csn_rd_ff | scan_en ;

// wire wr_clk_qual = wr_ssclk & ~scan_en ; 
always @(wr_ssclk or wr_a_ff or wr_enable_l or di_ff ) begin
     if (!wr_ssclk) begin
        if (!wr_enable_l) begin
               memarray[wr_a_ff] <= di_ff[80:0] ; 
        end
     end 
end
        
// wire  rd_clk_qual =  (rd_ssclk & ~scan_en) ; 
always @(rd_ssclk or rd_a_ff or rd_enable_l) begin
     if (rd_ssclk) begin
        if (rd_enable_l == 1'b0) begin
             array_out[80:0] <= memarray[rd_a_ff] ;
        end else if (rd_enable_l == 1'b1) begin
             array_out[80:0] <= 81'h1FFFFFFFFFFFFFFFFFFFF;
        end else begin 
             array_out[80:0] <= 81'hXXXXXXXXXXXXXXXXXXXXX;
        end
     end
end


// synopsys translate_off

`ifdef  INNO_MUXEX
`else
  always @(csn_rd_ff or csn_wr_ff or rd_a_ff or wr_a_ff)   begin
   if ((SYNC_CLOCK_CHK1 == 0) & !csn_rd_ff & !csn_wr_ff & (rd_a_ff == wr_a_ff)) begin
      array_out   <= 81'hxxxxxxxxxxxxxxxxxxxxx;
	`ifdef MODELSIM  
      $display ("sram_conflict", "conflict between read: %h and write: %h pointers", rd_a_ff, wr_a_ff);
	`else
      $error ("sram_conflict", "conflict between read: %h and write: %h pointers", rd_a_ff, wr_a_ff);
	`endif
   end
  end
`endif

///////////////////////////////////////////////////////////////
// Purely ERROR checking code.                               //
///////////////////////////////////////////////////////////////
reg  [3:0] rd_a_ff_del ;
reg        csn_rd_ff_del ; 
reg        rd_clk_del ; 
always @(rd_local_clk) begin
     if (rd_local_clk)  rd_clk_del = #300 rd_local_clk;
     else              rd_clk_del = #300 rd_local_clk;
end
always @(posedge rd_clk_del) begin
       rd_a_ff_del <= rd_a_ff ;
       csn_rd_ff_del <= csn_rd_ff ;
end 

`ifdef  INNO_MUXEX
`else
  always @(csn_rd_ff_del or csn_wr_ff or rd_a_ff_del or wr_a_ff or rd_clk_del or wr_ssclk)   begin
   if (SYNC_CLOCK_CHK2 == 0) begin
       if (rd_clk_del & !wr_ssclk & !csn_rd_ff_del & !csn_wr_ff & (rd_a_ff_del == wr_a_ff)) begin
	`ifdef MODELSIM   
	      $display ("sram_conflict", "conflict between read: %h and write: %h pointers ", rd_a_ff_del, wr_a_ff);
	`else
	      $error ("sram_conflict", "conflict between read: %h and write: %h pointers ", rd_a_ff_del, wr_a_ff);
	`endif
       end 
   end
  end
`endif

reg  [3:0] wr_a_ff_del ;
reg        csn_wr_ff_del ; 
reg        wr_clk_del ; 
always @(wr_ssclk) begin
     if (wr_ssclk)  wr_clk_del = #300 wr_ssclk;
     else              wr_clk_del = #300 wr_ssclk;
end
always @(posedge wr_clk_del) begin
       wr_a_ff_del <= wr_a_ff ;
       csn_wr_ff_del <= csn_wr_ff ;
end 

`ifdef  INNO_MUXEX
`else
  always @(csn_rd_ff or csn_wr_ff_del or rd_a_ff or wr_a_ff_del or rd_local_clk or wr_clk_del)   begin
   if (SYNC_CLOCK_CHK3 == 0) begin
       if (rd_local_clk & !wr_clk_del & !csn_rd_ff & !csn_wr_ff_del & (rd_a_ff == wr_a_ff_del)) begin
      $display ("sram_conflict", "conflict between read: %h and write: %h pointers ", rd_a_ff, wr_a_ff_del);
       end
   end
  end
`endif

///////////////////////////////////////////////////////////////
// end the ERROR checking code.                              // 
///////////////////////////////////////////////////////////////
///////////////////////////////////////


// synopsys translate_on

///////////////////////////////////
// Transparent latch with reset
///////////////////////////////////

always @(array_out or rd_ssclk) begin
     if (rd_ssclk) begin
        array_out_latch <= array_out ;
     end
end

always @(di_ff_so[0] or wr_ssclk) begin
     if (!wr_ssclk) begin
        di_ff_latch_so <= di_ff_so[0] ;
     end
end


assign do  = testmux_sel ? di_ff : array_out_latch ;

/////////////////////////////////////////////////////
// listen_out Flop                                 //
/////////////////////////////////////////////////////
reg     [80:0]  listen_out_ff_inst_mdata ;
wire    [80:0]  listen_out_ff_inst_smin ;

assign listen_out_ff_inst_smin[80:0]  = hold ?  do[80:0] :  listen_out_si[80:0] ; 
always @(rd_smclk or rd_local_clk or do or listen_out_ff_inst_smin ) begin
       if (!rd_local_clk) begin
          listen_out_ff_inst_mdata = do[80:0] ;
       end
       if (!rd_smclk) begin
          listen_out_ff_inst_mdata = listen_out_ff_inst_smin;
       end
end
always @(posedge rd_ssclk) begin
    listen_out[80:0]   <=  listen_out_ff_inst_mdata ; 
end
assign listen_out_so[80:0] = listen_out[80:0] ;

// synopsys translate_off 

`ifdef  INNO_MUXEX
`else
   always @(posedge rd_clk) begin
     if ((MARGIN_WARNING == 0) & margin != 5'b10101) begin
	`ifdef MODELSIM 
          $display ("sram_margin", "margin is not set to the default value") ;
	`else
          $error ("sram_margin", "margin is not set to the default value") ;
	`endif
     end
   end
`endif

// synopsys translate_on 

endmodule
