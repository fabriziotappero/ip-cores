//****************************************************************************************
// FIFO
// Version 2.0
// Modified 23.09.12
// Written by Ruslan Lepetenok(lepetenokr@yahoo.com)
// w_almost_full generation logic was fixed 23.09.12
//****************************************************************************************


//synopsys translate_off
// `include"RTL/timescale.h"
//synopsys translate_on

// `default_nettype none

module fifo #(
	      parameter DEPTH    = 4,
	      parameter WIDTH    = 16,
	      parameter SYNC_RST = 0 
	      ) 
	      (
	      input  wire            nrst,
	      input  wire            clk,
	      // FIFO control
	      input  wire[WIDTH-1:0] din,					 
	      input  wire            we,
	      input  wire            re, 
	      input  wire            flush,
              //~~~~~~~~~~~
	      output wire[WIDTH-1:0] dout,
	      output wire            w_full,
	      output wire            w_almost_full,
	      output wire            r_empty
              );

function integer fn_clog2;
input integer arg;

integer i;
integer result;
begin
 if(arg == 1) begin 
  fn_clog2 = 0; 
 end	 
 else begin
  for (i = 0; 2 ** i < arg; i = i + 1)
   result = i + 1;
   fn_clog2 = result; 
  end
 end 
endfunction // fn_clog2	
					

localparam LP_CNT_WIDTH = fn_clog2(DEPTH)+1;

reg[LP_CNT_WIDTH-1:0] wr_cnt_current; 					
reg[LP_CNT_WIDTH-1:0] wr_cnt_next;

reg[LP_CNT_WIDTH-1:0] rd_cnt_current; 					
reg[LP_CNT_WIDTH-1:0] rd_cnt_next;

reg[WIDTH-1:0] fifo_mem_current[DEPTH-1:0]; 
reg[WIDTH-1:0] fifo_mem_next[DEPTH-1:0];

integer	i;

//********************************************************************************

always@(negedge nrst or posedge clk)
 begin : seq_main
  if(!nrst) 
   begin : seq_main_rst // Reset
	wr_cnt_current <= {LP_CNT_WIDTH{1'b0}};    
	rd_cnt_current <= {LP_CNT_WIDTH{1'b0}}; 

	for(i=0;i<DEPTH;i=i+1) fifo_mem_current[i] <= {WIDTH{1'b0}};
		
   end //   end // seq_main_rst 	  
  else 	  
   begin : seq_main_clk // Clock	 
	wr_cnt_current <= wr_cnt_next;
	rd_cnt_current <= rd_cnt_next;  
    for(i=0;i<DEPTH;i=i+1) fifo_mem_current[i] <= fifo_mem_next[i];
 
   end // seq_main_clk 	  	   
 end // seq_main 
 
 always@(*)
  begin : comb_main
	wr_cnt_next = wr_cnt_current;
	rd_cnt_next = rd_cnt_current;
	for(i=0;i<DEPTH;i=i+1) fifo_mem_next[i] = fifo_mem_current[i];
    //****************	  
	if(flush)
	 begin	// Clear Read/Write counters
	  wr_cnt_next = {LP_CNT_WIDTH{1'b0}};
	  rd_cnt_next = {LP_CNT_WIDTH{1'b0}};
	 end 
	else
	 begin	
      if(we) wr_cnt_next = wr_cnt_current + 1;
      if(re) rd_cnt_next = rd_cnt_current + 1;
	 end 	
  
    if(we) 
	 begin	
	  fifo_mem_next[wr_cnt_current[LP_CNT_WIDTH-2:0]] = din;	   
	 end
		
  end // comb_main	  
			
assign dout = fifo_mem_current[rd_cnt_current[LP_CNT_WIDTH-2:0]];

assign r_empty = (wr_cnt_current != rd_cnt_current)? 1'b0 : 1'b1; 

// Almost full flag
assign w_almost_full = ((wr_cnt_current[LP_CNT_WIDTH-1] == rd_cnt_current[LP_CNT_WIDTH-1] && 
                         wr_cnt_current[LP_CNT_WIDTH-2:0] == rd_cnt_current[LP_CNT_WIDTH-2:0] + 1) ||
                        (wr_cnt_current[LP_CNT_WIDTH-1] != rd_cnt_current[LP_CNT_WIDTH-1] && 
			 wr_cnt_current[LP_CNT_WIDTH-2:0] + 1 == rd_cnt_current[LP_CNT_WIDTH-2:0])) ? 1'b1 : 1'b0; // Fixed 23.09.12


assign w_full  = (wr_cnt_current[LP_CNT_WIDTH-1] != rd_cnt_current[LP_CNT_WIDTH-1] && 
                  wr_cnt_current[LP_CNT_WIDTH-2:0] == rd_cnt_current[LP_CNT_WIDTH-2:0])? 1'b1 : 1'b0;
	
// pragma translate_off				  
always@(posedge clk)
 begin	
	 
  if(w_full===1'b1 && we===1'b1) 
   begin
	$display("%m.FIFO overflow.");   
	$finish;		
   end  
   
  if(r_empty===1'b1 && re===1'b1) 
   begin
	$display("%m.FIFO underflow.");   
	$finish;		
   end     
   
 end				  
// pragma translate_on
				  
endmodule // fifo
