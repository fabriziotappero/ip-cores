<##//////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Eyal Hochberg                                      ////
////          eyal@provartec.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 Provartec LTD                            ////
//// www.provartec.com                                           ////
//// info@provartec.com                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
//////////////////////////////////////////////////////////////////##>

OUTFILE PREFIX_single.v

INCLUDE def_axi_master.txt

module PREFIX_single(PORTS);

   parameter                           MASTER_NUM  = 0;
   parameter                           MASTER_ID   = 0;
   parameter                           MASTER_PEND = 0;

CREATE prgen_rand.v DEFCMD(DEFINE NOT_IN_LIST)
`include "prgen_rand.v"
   
   parameter                           MAX_CMDS    = 16; //Depth of command FIFO
   parameter                           DATA_LOG    = LOG2(EXPR(DATA_BITS/8));
   parameter                           PEND_BITS   =
			               (MAX_CMDS <= 16)  ? 4 :
			               (MAX_CMDS <= 32)  ? 5 :
			               (MAX_CMDS <= 64)  ? 6 :
			               (MAX_CMDS <= 128) ? 7 : 
			               (MAX_CMDS <= 256) ? 8 :
			               (MAX_CMDS <= 512) ? 9 : 0; //0 is ilegal
                                       
   
   input 			       clk;
   input                               reset;
   
   port                  	       GROUP_STUB_AXI;

   output                              idle;
   output                              scrbrd_empty;
   

   
   //random parameters   
   integer                             GROUP_AXI_MASTER_RAND = GROUP_AXI_MASTER_RAND.DEFAULT;
   
   reg                                 AWVALID_pre;
   reg                                 WVALID_pre;
   wire                                BREADY_pre;
   reg                                 ARVALID_pre;
   wire                                RREADY_pre;
   
   reg 				       enable = 0;
   reg 				       rd_enable = 0;
   reg                                 wr_enable = 0;
   reg                                 wait_for_write = 0;
   reg                                 err_on_wr_resp = 1;
   reg                                 err_on_rd_resp = 1;
   
   reg                                 scrbrd_enable = 0;
   reg [LEN_BITS-1:0] 		       wvalid_cnt;

   reg 				       rd_cmd_push = 0;
   wire 			       rd_cmd_pop;
   wire [PEND_BITS:0]                  rd_cmd_fullness;
   wire 			       rd_cmd_empty;
   wire 			       rd_cmd_full;
   reg [ADDR_BITS-1:0] 		       rd_cmd_addr_in;
   reg [LEN_BITS-1:0] 		       rd_cmd_len_in;
   reg [SIZE_BITS-1:0] 		       rd_cmd_size_in;
   wire [ADDR_BITS-1:0] 	       rd_cmd_addr;
   wire [LEN_BITS-1:0] 		       rd_cmd_len;
   wire [SIZE_BITS-1:0] 	       rd_cmd_size;
   
   reg 				       rd_resp_push = 0;
   wire 			       rd_resp_pop;
   wire 			       rd_resp_empty;
   wire 			       rd_resp_full;
   reg [ADDR_BITS-1:0] 		       rd_resp_addr_in;
   reg [SIZE_BITS-1:0] 		       rd_resp_size_in;
   wire [ADDR_BITS-1:0] 	       rd_resp_addr;
   wire [SIZE_BITS-1:0] 	       rd_resp_size;
   
   reg 				       wr_cmd_push = 0;
   wire 			       wr_cmd_pop;
   wire [PEND_BITS:0]                  wr_cmd_fullness;
   wire 			       wr_cmd_empty;
   wire 			       wr_cmd_full;
   reg [ADDR_BITS-1:0] 		       wr_cmd_addr_in;
   reg [LEN_BITS-1:0] 		       wr_cmd_len_in;
   reg [SIZE_BITS-1:0] 		       wr_cmd_size_in;
   wire [ADDR_BITS-1:0] 	       wr_cmd_addr;
   wire [LEN_BITS-1:0] 		       wr_cmd_len;
   wire [SIZE_BITS-1:0] 	       wr_cmd_size;
   
   reg 				       wr_data_push = 0;
   wire 			       wr_data_pop;
   wire [PEND_BITS:0]                  wr_data_fullness;
   wire 			       wr_data_empty;
   wire 			       wr_data_full;
   reg [ADDR_BITS-1:0] 		       wr_data_addr_in;
   reg [LEN_BITS-1:0] 		       wr_data_len_in;
   reg [SIZE_BITS-1:0] 		       wr_data_size_in;
   wire [ADDR_BITS-1:0] 	       wr_data_addr;
   wire [LEN_BITS-1:0] 		       wr_data_len;
   wire [SIZE_BITS-1:0] 	       wr_data_size;
   wire [DATA_BITS/8-1:0] 	       wr_data_strb;
   wire [7:0] 			       wr_data_bytes;
   wire [ADDR_BITS-1:0] 	       wr_data_addr_prog;
   wire [7:0] 			       wr_data_offset;
   
   wire                                wr_resp_push;
   reg                                 wr_resp_pop = 0;
   wire 			       wr_resp_empty;
   wire 			       wr_resp_full;
   wire [1:0]                          wr_resp_resp_in;
   wire [1:0]                          wr_resp_resp;
   
   reg 				       wr_fifo_push = 0;
   wire 			       wr_fifo_pop;
   wire 			       wr_fifo_empty;
   wire 			       wr_fifo_full;
   reg [DATA_BITS-1:0]                 wr_fifo_data_in;
   wire [DATA_BITS-1:0]                wr_fifo_data;
   
   wire                                rd_fifo_push;
   reg                                 rd_fifo_pop = 0;
   wire 			       rd_fifo_empty;
   wire 			       rd_fifo_full;
   wire [DATA_BITS-1:0]                rd_fifo_data_in;
   wire [1:0]                          rd_fifo_resp_in;
   wire [DATA_BITS-1:0]                rd_fifo_data;
   wire [1:0]                          rd_fifo_resp;
   
   reg                                 scrbrd_push = 0;
   reg                                 scrbrd_pop = 0;
   wire 			       scrbrd_empty;
   wire 			       scrbrd_full;
   reg [ADDR_BITS-1:0]                 scrbrd_addr_in;
   reg [DATA_BITS-1:0]                 scrbrd_data_in;
   reg [DATA_BITS-1:0]                 scrbrd_mask_in;
   wire [ADDR_BITS-1:0]                scrbrd_addr;
   wire [DATA_BITS-1:0]                scrbrd_data;
   wire [DATA_BITS-1:0]                scrbrd_mask;
   
   integer 			       wr_fullness;
   integer 			       rd_fullness;
   integer                             rd_completed;
   integer                             wr_completed;
   integer 			       wr_pend_max = MASTER_PEND;
   integer 			       rd_pend_max = MASTER_PEND;
   wire 			       wr_hold;
   wire 			       rd_hold;

   integer                             rand_chk_num = 0;


   assign                              idle = rd_cmd_empty & rd_resp_empty & wr_cmd_empty & wr_data_empty & wr_resp_empty;
      
   always @(rand_chk_num)
     if (rand_chk_num > 0)
       insert_rand_chk_loop(rand_chk_num);
   
   always @(posedge enable)
     begin
        @(posedge clk);
        wr_enable = 1;
        repeat (50) @(posedge clk);
        rd_enable = 1;
     end

   //for incremental data
   reg [DATA_BITS-1:0]                 base_data = 0;
   integer                             ww;
   initial
     begin
        ww=0;
        while (ww < DATA_BITS/8)
          begin
             base_data = base_data + ((MASTER_NUM + ww) << (ww*8));
             ww = ww + 1;
          end
     end
   
   assign 	  rd_cmd_pop   = ARVALID & ARREADY;
   assign 	  rd_resp_pop  = RVALID & RREADY & RLAST;
   assign         rd_fifo_push = RVALID & RREADY;
   assign         wr_cmd_pop   = AWVALID & AWREADY;
   assign 	  wr_data_pop  = WVALID & WREADY & WLAST;
   assign         wr_fifo_pop  = WVALID & WREADY;
   assign         wr_resp_push = BVALID & BREADY;

   assign 	  RREADY_pre = 1;
   assign 	  BREADY_pre = 1;
   
   
   always @(posedge clk or posedge reset)
     if (reset)
       AWVALID_pre <= #FFD 1'b0;
     else if ((wr_cmd_fullness == 1) & wr_cmd_pop)
       AWVALID_pre <= #FFD 1'b0;
     else if ((!wr_cmd_empty) & wr_enable)
       AWVALID_pre <= #FFD 1'b1;
   
   
   assign 	  AWADDR  = wr_cmd_addr;
   assign 	  AWLEN   = wr_cmd_len;
   assign 	  AWSIZE  = wr_cmd_size;
   assign         AWID    = MASTER_ID;
   assign 	  AWBURST = 2'd1; //INCR only
   assign 	  AWCACHE = 4'd0; //not supported
   assign 	  AWPROT  = 4'd0; //not supported
   assign 	  AWLOCK  = 2'd0; //not supported
   
   always @(posedge clk or posedge reset)
     if (reset)
       ARVALID_pre <= #FFD 1'b0;
     else if (((rd_cmd_fullness == 1)) & rd_cmd_pop)
       ARVALID_pre <= #FFD 1'b0;
     else if ((!rd_cmd_empty) & rd_enable)
       ARVALID_pre <= #FFD 1'b1;

   assign 	  ARADDR  = rd_cmd_addr;
   assign 	  ARLEN   = rd_cmd_len;
   assign 	  ARSIZE  = rd_cmd_size;
   assign 	  ARID    = MASTER_ID;
   assign 	  ARBURST = 2'd1; //INCR only
   assign 	  ARCACHE = 4'd0; //not supported
   assign 	  ARPROT  = 4'd0; //not supported
   assign 	  ARLOCK  = 2'd0; //not supported

   assign         rd_fifo_data_in = RDATA;
   assign         rd_fifo_resp_in = RRESP;
   
   assign 	  wr_data_bytes = 1'b1 << wr_data_size;

   assign 	  wr_data_strb = 
                  wr_data_size == 'd0 ? 1'b1       :
                  wr_data_size == 'd1 ? 2'b11      :
                  wr_data_size == 'd2 ? 4'b1111    :
                  wr_data_size == 'd3 ? {8{1'b1}}  :
                  wr_data_size == 'd4 ? {16{1'b1}} : 'd0;

   assign 	  wr_data_addr_prog = wr_data_addr + (wvalid_cnt * wr_data_bytes);

   always @(posedge clk or posedge reset)
     if (reset)
       WVALID_pre <= #FFD 1'b0;
     else if ((wr_data_fullness == 1) & wr_data_pop)
       WVALID_pre <= #FFD 1'b0;
     else if ((!wr_data_empty) & wr_enable)
       WVALID_pre <= #FFD 1'b1;

   
   assign 	  wr_data_offset = wr_data_addr_prog[DATA_LOG-1:0];			
   
   assign 	  WID   = MASTER_ID;
   assign 	  WDATA = wr_fifo_empty ? 0 : wr_fifo_data;
   assign 	  WSTRB = wr_data_strb << wr_data_offset;
   
   
   always @(posedge clk or posedge reset)
     if (reset)
       wvalid_cnt <= #FFD {LEN_BITS{1'b0}};
     else if (wr_data_pop)
       wvalid_cnt <= #FFD {LEN_BITS{1'b0}};
     else if (WVALID & WREADY)
       wvalid_cnt <= #FFD wvalid_cnt + 1'b1;

   assign 	  WLAST = WVALID & (wvalid_cnt == wr_data_len);

   assign         wr_resp_resp_in = BRESP;
   
   always @(posedge clk or posedge reset)
     if (reset)
       begin
	  wr_fullness <= #FFD 0;
	  rd_fullness <= #FFD 0;
          rd_completed <= #FFD 0;
          wr_completed <= #FFD 0;
       end
     else
       begin
	  wr_fullness <= #FFD wr_fullness + wr_cmd_pop - wr_resp_push;
	  rd_fullness <= #FFD rd_fullness + rd_cmd_pop - rd_resp_pop;
          rd_completed <= #FFD rd_completed + rd_resp_pop;
          wr_completed <= #FFD wr_completed + wr_resp_push;
       end
   
   assign 	  wr_hold = wr_fullness >= wr_pend_max;
   assign 	  rd_hold = (rd_fullness >= rd_pend_max) | (wait_for_write & (wr_completed <= rd_completed + rd_fullness));
   
   
   
   task insert_rd_cmd;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;
      
      begin
         rd_cmd_addr_in  = addr;
	 rd_cmd_len_in   = len;
	 rd_cmd_size_in  = size;
	 rd_resp_addr_in = addr;
	 rd_resp_size_in = size;

         if (rd_cmd_full) enable = 1; //start stub not started yet
         
         #FFD; wait ((!rd_cmd_full) & (!rd_resp_full));
	 @(negedge clk); #FFD; 
	 rd_cmd_push  = 1;
	 rd_resp_push = 1;
	 @(posedge clk); #FFD; 
	 rd_cmd_push  = 0;
	 rd_resp_push = 0;
      end
   endtask
   
   task insert_wr_cmd;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;
            
      begin
	 wr_cmd_addr_in  = addr;
	 wr_cmd_len_in   = len;
	 wr_cmd_size_in  = size;
	 wr_data_addr_in = addr;
	 wr_data_len_in  = len;
	 wr_data_size_in = size;
	 
         if (wr_cmd_full) enable = 1; //start stub not started yet
         
         #FFD; wait ((!wr_cmd_full) & (!wr_data_full));
	 @(negedge clk); #FFD; 
	 wr_cmd_push  = 1; 
	 wr_data_push = 1;
	 @(posedge clk); #FFD;
	 wr_cmd_push  = 0;
	 wr_data_push = 0;
      end
   endtask

   task insert_wr_data;
      input [DATA_BITS-1:0]  wdata;
            
      begin
	 wr_fifo_data_in  = wdata;
	 
         #FFD; wait (!wr_fifo_full);
	 @(negedge clk); #FFD; 
	 wr_fifo_push = 1; 
	 @(posedge clk); #FFD;
	 wr_fifo_push = 0;
      end
   endtask

   task insert_wr_incr_data;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;

      integer valid_cnt;
      integer wdata_cnt;
      reg [7:0] data_cnt;
      integer bytes;
      reg [DATA_BITS-1:0] add_data;
      reg [DATA_BITS-1:0] next_data;
      begin
         //insert data
         valid_cnt = 0;
         while (valid_cnt <= len)
           begin
              bytes = 1'b1 << size;
              wdata_cnt = valid_cnt+(addr[DATA_LOG-1:0]/bytes);
              data_cnt  = ((wdata_cnt)/(DATA_BITS/(bytes*8))) * (DATA_BITS/8);
              add_data  = {DATA_BITS/8{data_cnt}};
              next_data = (use_addr_base ? addr : base_data) + add_data;
              insert_wr_data(next_data);
              valid_cnt = valid_cnt+1;
           end
         //insert command
         insert_wr_cmd(addr, len, size);
      end
   endtask
   
   task insert_scrbrd;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  data;
      input [DATA_BITS-1:0]  mask;
      begin
         scrbrd_enable = 1;
         scrbrd_addr_in  = addr;
	 scrbrd_data_in  = data;
	 scrbrd_mask_in  = mask;
	 
         #FFD; wait (!scrbrd_full);
	 @(negedge clk); #FFD; 
	 scrbrd_push = 1; 
	 @(posedge clk); #FFD;
	 scrbrd_push = 0;
      end
   endtask
          
   task insert_scrbrd_incr_data;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;

      integer valid_cnt;
      integer wdata_cnt;
      reg [7:0] data_cnt;
      integer bytes;
      reg [DATA_BITS-1:0] add_data;
      reg [DATA_BITS-1:0] next_data;
      reg [DATA_BITS:0] strb;
      reg [DATA_BITS-1:0] mask;
      reg [ADDR_BITS-1:0] next_addr;
      begin
         valid_cnt = 0;
         while (valid_cnt <= len)
           begin
              bytes = 1'b1 << size;
              wdata_cnt = valid_cnt+(addr[DATA_LOG-1:0]/bytes);
              data_cnt  = ((wdata_cnt)/(DATA_BITS/(bytes*8))) * (DATA_BITS/8);
              add_data  = {DATA_BITS/8{data_cnt}};
              next_data = (use_addr_base ? addr : base_data) + add_data;
              next_addr = addr + (bytes * valid_cnt);
              strb = (1 << (bytes*8)) - 1;
              mask = strb << (next_addr[DATA_LOG-1:0]*8);
              insert_scrbrd(next_addr, next_data, mask);
              valid_cnt = valid_cnt+1;
           end
      end
   endtask
   
   task insert_rd_scrbrd;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;

      begin
         insert_scrbrd_incr_data(addr, len, size);
         insert_rd_cmd(addr, len, size);
      end
   endtask
   
   task insert_wr_rd_scrbrd;
      input [ADDR_BITS-1:0]  addr;
      input [LEN_BITS-1:0]   len;
      input [SIZE_BITS-1:0]  size;

      begin
         wait_for_write=1;
         insert_wr_incr_data(addr, len, size);
         insert_rd_scrbrd(addr, len, size);
      end
   endtask

   task insert_wr_rd_scrbrd_rand;
      reg [ADDR_BITS-1:0]  addr;
      reg [LEN_BITS-1:0]   len;
      reg [SIZE_BITS-1:0]  size;

      integer size_bytes;
      integer burst_bytes;
      begin
         if (DATA_BITS==32) size_max = 2'b10;
         len   = rand(len_min, len_max);
         size  = rand(size_min, size_max);
         size_bytes  = 1 << size;
         burst_bytes = size_bytes * (len+1);
         addr  = rand_align(addr_min, addr_max, size_bytes);
         if (addr[11:0] + burst_bytes > 16'h1000) //don't cross 4KByte page
           begin
              addr = addr - burst_bytes;
           end
         
         if (ahb_bursts)
           begin
              len   = 
                      len[3] ? 15 : 
                      len[2] ? 7 : 
                      len[1] ? 3 : 0;
              if (len > 0)
                size = (DATA_BITS == 64) ? 2'b11 : 2'b10; //AHB bursts always full data

              addr = align(addr, EXPR(DATA_BITS/8)*(len+1)); //address aligned to burst size
           end
         insert_wr_rd_scrbrd(addr, len, size);
      end
   endtask
   
   task insert_rand_chk;
      input [31:0]  num;

      rand_chk_num = num;
   endtask
   
   task insert_rand_chk_loop;
      input [31:0]  num;
      
      integer i;
      begin
         i = 0;
         while (i < num)
           begin
              insert_wr_rd_scrbrd_rand;
              i = i + 1;
           end
      end
   endtask
   
   task insert_wr_single;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  wdata;

      reg [SIZE_BITS-1:0] size;
      begin
         size = EXPR((DATA_BITS/32)+1);
         insert_wr_data(wdata);
         insert_wr_cmd(addr, 0, size);
      end
   endtask

   task get_rd_resp;
      output [DATA_BITS-1:0] rdata;
      output [1:0] resp;
      
      reg [DATA_BITS-1:0] rdata;
      reg [1:0] resp;
      begin
         #FFD; wait (!rd_fifo_empty);
         rdata = rd_fifo_data;
         resp = rd_fifo_resp;
         @(negedge clk); #FFD; 
	 rd_fifo_pop = 1; 
	 @(posedge clk); #FFD;
	 rd_fifo_pop = 0;
         if ((resp != 2'b00) && (err_on_rd_resp))
           $display("PREFIX_MASTER%0d: RRESP_ERROR: Received RRESP 2'b%0b.\tTime: %0d ns.", MASTER_NUM, resp, $time);
      end
   endtask
   
   task get_scrbrd;
      output [ADDR_BITS-1:0] addr;
      output [DATA_BITS-1:0] rdata;
      output [DATA_BITS-1:0] mask;
      
      reg [ADDR_BITS-1:0] addr;
      reg [DATA_BITS-1:0] rdata;
      reg [DATA_BITS-1:0] mask;
      begin
         #FFD; wait (!scrbrd_empty);
         addr = scrbrd_addr;
         rdata = scrbrd_data;
         mask = scrbrd_mask;
         @(negedge clk); #FFD; 
	 scrbrd_pop = 1; 
	 @(posedge clk); #FFD;
	 scrbrd_pop = 0;
      end
   endtask
   
   task get_wr_resp;
      output [1:0] resp;

      reg [1:0] resp;
      begin
         #FFD; wait (!wr_resp_empty);
         resp = wr_resp_resp;
         @(negedge clk); #FFD; 
	 wr_resp_pop = 1; 
	 @(posedge clk); #FFD;
	 wr_resp_pop = 0;
         if ((resp != 2'b00) && (err_on_wr_resp))
           $display("PREFIX_MASTER%0d: BRESP_ERROR: Received BRESP 2'b%0b.\tTime: %0d ns.", MASTER_NUM, resp, $time);
      end
   endtask
   
   task insert_rd_single;
      input [ADDR_BITS-1:0]  addr;

      reg [SIZE_BITS-1:0] size;
      begin
         size = EXPR((DATA_BITS/32)+1);
         insert_rd_cmd(addr, 0, size);
      end
   endtask

   task read_single_ack;
      input [ADDR_BITS-1:0]  addr;
      output [DATA_BITS-1:0] rdata;
      output [1:0]           resp;
      
      reg [1:0] resp;
      begin
         insert_rd_single(addr);
         get_rd_resp(rdata, resp);
      end
   endtask
         
   task write_single_ack;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  wdata;
      output [1:0]           resp;

      reg [1:0] resp;
      begin
         insert_wr_single(addr, wdata);
         get_wr_resp(resp);
      end
   endtask
         
   task read_single;
      input [ADDR_BITS-1:0]  addr;
      output [DATA_BITS-1:0] rdata;
      
      reg [1:0] resp;
      begin
         read_single_ack(addr, rdata, resp);
      end
   endtask
         
   task check_single;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  expected;
      
      reg [1:0] resp;
      reg [DATA_BITS-1:0] rdata;  
      begin
         read_single_ack(addr, rdata, resp);
         if (rdata !== expected)
           $display("PREFIX_MASTER%0d: CHK_SINGLE_ERROR: Address: 0x%0h, Expected: 0x%0h, Received: 0x%0h.\tTime: %0d ns.", MASTER_NUM, addr, expected, rdata, $time);
      end
   endtask
               
   task write_and_check_single;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  data;
      
      begin
         write_single(addr, data);
         check_single(addr, data);
      end
   endtask
         
   task write_single;
      input [ADDR_BITS-1:0]  addr;
      input [DATA_BITS-1:0]  wdata;

      reg [1:0] resp;
      begin
         write_single_ack(addr, wdata, resp);
      end
   endtask

   task chk_scrbrd;
      reg [ADDR_BITS-1:0] addr;
      reg [DATA_BITS-1:0] mask;
      reg [DATA_BITS-1:0] expected_data;
      reg [DATA_BITS-1:0] rdata;
      reg [DATA_BITS-1:0] rdata_masked;
      reg [1:0] resp;
      
      begin
         if (!wr_resp_empty) get_wr_resp(resp);
         get_scrbrd(addr, expected_data, mask);
         get_rd_resp(rdata, resp);
         expected_data = expected_data & mask; //TBD insert z as dontcare (for print)
         rdata_masked = rdata & mask;
         
         if (expected_data !== rdata_masked)
           $display("PREFIX_MASTER%0d: SCRBRD_ERROR: Address: 0x%0h, Expected: 0x%0h, Received: 0x%0h.\tTime: %0d ns.", MASTER_NUM, addr, expected_data, rdata, $time);
      end
   endtask

   always @(posedge scrbrd_enable)
     begin
        while (scrbrd_enable)
          begin
             chk_scrbrd;
          end
     end

  
CREATE prgen_fifo.v DEFCMD(DEFINE STUB)
   prgen_fifo_stub #(ADDR_BITS+LEN_BITS+SIZE_BITS, MAX_CMDS) 
   rd_cmd_list(
	       .clk(clk),
	       .reset(reset),
	       .push(rd_cmd_push),
	       .pop(rd_cmd_pop),
	       .din({
		     rd_cmd_size_in,
		     rd_cmd_len_in,
		     rd_cmd_addr_in
		     }),
	       .dout({
		      rd_cmd_size,
		      rd_cmd_len,
		      rd_cmd_addr
		      }),
	       .fullness(rd_cmd_fullness),
	       .empty(rd_cmd_empty),
	       .full(rd_cmd_full)
	       );

   prgen_fifo_stub #(ADDR_BITS+SIZE_BITS, MAX_CMDS) 
   rd_resp_list(
		.clk(clk),
		.reset(reset),
		.push(rd_resp_push),
		.pop(rd_resp_pop),
		.din({
		      rd_resp_addr_in,
		      rd_resp_size_in
		      }),
		.dout({
		       rd_resp_addr,
		       rd_resp_size
		       }),
		.empty(rd_resp_empty),
		.full(rd_resp_full)
		);

   prgen_fifo_stub #(ADDR_BITS+LEN_BITS+SIZE_BITS, MAX_CMDS) 
   wr_cmd_list(
	       .clk(clk),
	       .reset(reset),
	       .push(wr_cmd_push),
	       .pop(wr_cmd_pop),
	       .din({
		     wr_cmd_size_in,
		     wr_cmd_len_in,
		     wr_cmd_addr_in
		     }),
	       .dout({
		      wr_cmd_size,
		      wr_cmd_len,
		      wr_cmd_addr
		      }),
	       .fullness(wr_cmd_fullness),
	       .empty(wr_cmd_empty),
	       .full(wr_cmd_full)
	       );

   prgen_fifo_stub #(ADDR_BITS+LEN_BITS+SIZE_BITS, MAX_CMDS) 
   wr_data_list(
		.clk(clk),
		.reset(reset),
		.push(wr_data_push),
		.pop(wr_data_pop),
		.din({
		      wr_data_size_in,
		      wr_data_len_in,
		      wr_data_addr_in
		      }),
		.dout({
		       wr_data_size,
		       wr_data_len,
		       wr_data_addr
		       }),
		.fullness(wr_data_fullness),
		.empty(wr_data_empty),
		.full(wr_data_full)
		);

   prgen_fifo_stub #(2, MAX_CMDS) 
   wr_resp_list(
		.clk(clk),
		.reset(reset),
		.push(wr_resp_push),
		.pop(wr_resp_pop),
		.din(wr_resp_resp_in),
		.dout(wr_resp_resp),
		.empty(wr_resp_empty),
		.full(wr_resp_full)
		);

   
   prgen_fifo_stub #(DATA_BITS, MAX_CMDS*EXPR(2^LEN_BITS))
   wr_data_fifo(
		.clk(clk),
		.reset(reset),
		.push(wr_fifo_push),
		.pop(wr_fifo_pop),
		.din(wr_fifo_data_in),
		.dout(wr_fifo_data),
		.empty(wr_fifo_empty),
		.full(wr_fifo_full)
		);

   prgen_fifo_stub #(DATA_BITS+2, MAX_CMDS*EXPR(2^LEN_BITS))
   rd_data_fifo(
		.clk(clk),
		.reset(reset),
		.push(rd_fifo_push),
		.pop(rd_fifo_pop),
		.din({
                      rd_fifo_data_in,
                      rd_fifo_resp_in
                      }),
		.dout({
                       rd_fifo_data,
                       rd_fifo_resp
                       }),
		.empty(rd_fifo_empty),
		.full(rd_fifo_full)
		);

   prgen_fifo_stub #(ADDR_BITS+2*DATA_BITS, MAX_CMDS*EXPR(2^LEN_BITS))
   scrbrd_fifo(
		.clk(clk),
		.reset(reset),
		.push(scrbrd_push),
		.pop(scrbrd_pop),
	       .din({
                     scrbrd_addr_in,
                     scrbrd_data_in,
                     scrbrd_mask_in
                     }),
		.dout({
                       scrbrd_addr,
                       scrbrd_data,
                       scrbrd_mask
                       }),
		.empty(scrbrd_empty),
		.full(scrbrd_full)
		);


CREATE axi_master_stall.v
   PREFIX_stall
     PREFIX_stall (
                   .clk(clk),
                   .reset(reset),

                   .rd_hold(rd_hold),
                   .wr_hold(wr_hold),
     
                   .ARVALID_pre(ARVALID_pre),
                   .RREADY_pre(RREADY_pre),
                   .AWVALID_pre(AWVALID_pre),
                   .WVALID_pre(WVALID_pre),
                   .BREADY_pre(BREADY_pre),
     
                   .ARREADY(ARREADY),
                   .AWREADY(AWREADY),
                   .WREADY(WREADY),
     
                   .ARVALID(ARVALID),
                   .RREADY(RREADY),
                   .AWVALID(AWVALID),
                   .WVALID(WVALID),
                   .BREADY(BREADY)
                   );


endmodule


