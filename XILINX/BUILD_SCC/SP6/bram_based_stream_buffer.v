// Copyright (c) 2011 Synopsys, Inc.  All rights reserved.
//
//
// $Revision: 1.8 $


`timescale 1ns / 1ps

`ifdef PICO_CLOCK_EDGE
`else
   `define PICO_CLOCK_EDGE posedge
`endif
`ifdef PICO_CLOCK_SENSITIVITY
`else
   `define PICO_CLOCK_SENSITIVITY clk
`endif
`ifdef PICO_RESET_SENSITIVITY
`else
   `define PICO_RESET_SENSITIVITY
`endif
`ifdef PICO_RESET_SENSITIVITY2
`else
   `define PICO_RESET_SENSITIVITY2 reset
`endif

`timescale 1 ns / 10 ps

module bram_based_stream_buffer (clk, indata, outdata, store_ready, load_ready,  reset, flush, load_req, store_req );

     parameter width = 48;
     parameter depth = 800;
     parameter awidth = clogb2(depth);

input clk, load_ready, store_ready, reset, flush;
wire  clk, load_ready, store_ready, reset, flush;

input [width-1:0] indata;
wire [width-1:0] indata;

output  load_req, store_req;
wire    load_req, store_req;

output [width-1:0] outdata;
wire   [width-1:0] outdata;


function integer clogb2(input integer depth);
 begin
     for (clogb2=0; depth>0; clogb2=clogb2+1)
          depth= depth>>1;
     end
 endfunction

   // 0in assert -var (depth >= 1)
   // coverage off
   // pragma coverage off
   // VCS coverage off
   // synopsys translate_off
   initial begin
      if ( depth < 1 ) begin
        $display ("ERROR::::");
        $display ("mc_log:  ERROR:  bram_based_stream_buffer of depth %0d in %m. This is unsupported.Stopping simulation",depth);
        $display ("END ERROR");
        $finish;
      end
   end
   // synopsys translate_on
   // VCS coverage on
   // pragma coverage on
   // coverage on

reg [awidth-1:0] read_addr_ff, next_read_addr_ff, write_addr_ff;
reg [awidth-1:0]  count_ff ;
reg   full_ff, not_empty_ff, onefull_ff, init_ff;

reg    [width-1:0] bypass_reg_ff;
reg    bypass_reg_valid_ff;

wire   [width-1:0] bram_outdata;
wire   addq_only, shiftq_only, shiftq_addq, mem_is_empty;

wire addq = load_ready;
wire shiftq = store_ready;

wire  full_mem = full_ff;
assign mem_is_empty = ~not_empty_ff;

assign addq_only = (addq & !full_ff & (!shiftq |(shiftq & mem_is_empty)));
assign shiftq_only = (shiftq & !mem_is_empty & (!addq | (addq & full_mem)) );
assign shiftq_addq = (shiftq & addq & not_empty_ff & !full_mem);

wire rreq, wreq;

assign rreq = not_empty_ff;
assign wreq = addq & !full_mem;
assign load_req = !full_mem;
assign store_req = !mem_is_empty;

always @ (`PICO_CLOCK_EDGE `PICO_CLOCK_SENSITIVITY  `PICO_RESET_SENSITIVITY ) begin
   if (`PICO_RESET_SENSITIVITY2) begin
       not_empty_ff <= 1'b0;
       full_ff      <= 1'b0;
       init_ff      <= 1'b0;
   end
   else if (flush) begin
       not_empty_ff <= 1'b0;
       full_ff      <= 1'b0;
       init_ff      <= 1'b0;
   end    
   else begin
        init_ff      <= 1'b1;
      if (addq & mem_is_empty) begin    
              not_empty_ff <= 1'b1;
      end                     
      else if (shiftq & !addq & onefull_ff)  begin
              not_empty_ff <= 1'b0;
      end   
      
      if (addq_only & (count_ff == depth-1))  full_ff <= 1'b1;
      else if (shiftq_only)   full_ff <= 1'b0;
             
   end
end 

always @ (`PICO_CLOCK_EDGE `PICO_CLOCK_SENSITIVITY  `PICO_RESET_SENSITIVITY ) begin
   if (`PICO_RESET_SENSITIVITY2) begin
       onefull_ff   <= 1'b0;
   end
   else if (flush) begin
       onefull_ff   <= 1'b0;
   end    
   else begin
      if (addq_only) begin    
         if (mem_is_empty) begin
              onefull_ff <= 1'b1;
         end
         else begin
              onefull_ff <= 1'b0;
         end
      end                     
      else if (shiftq_only)  begin
         if (onefull_ff)  begin
              onefull_ff   <= 1'b0;
         end     
         else if (count_ff == 2'b10) begin
              onefull_ff   <= 1'b1;
         end     
      end   
   end
end 

always @ (`PICO_CLOCK_EDGE `PICO_CLOCK_SENSITIVITY  `PICO_RESET_SENSITIVITY ) begin
 if (`PICO_RESET_SENSITIVITY2) begin
     read_addr_ff <= {awidth{1'b0}};
     next_read_addr_ff <= {awidth{1'b0}};
 end
 else if (flush)  begin
     read_addr_ff <= {awidth{1'b0}};
     next_read_addr_ff <= {awidth{1'b0}};
 end    
 else begin
  
   if ( (shiftq & not_empty_ff) | ~init_ff ) begin
         read_addr_ff <= next_read_addr_ff;
     if (next_read_addr_ff == depth-1) begin
         next_read_addr_ff <= {awidth{1'b0}};
     end
     else begin
         next_read_addr_ff <= next_read_addr_ff + 1'b1; 
     end
   end
 end
end 

always @ (`PICO_CLOCK_EDGE `PICO_CLOCK_SENSITIVITY  `PICO_RESET_SENSITIVITY ) begin
 if (`PICO_RESET_SENSITIVITY2) begin
     write_addr_ff <= {awidth{1'b0}};
 end
 else if (flush) begin
     write_addr_ff <= {awidth{1'b0}};
 end
 else begin
    if (wreq) begin
       if (write_addr_ff == depth-1)
         write_addr_ff <= {awidth{1'b0}};
       else
         write_addr_ff <= write_addr_ff + 1'b1;
   end
 end
end

always @ (`PICO_CLOCK_EDGE `PICO_CLOCK_SENSITIVITY  `PICO_RESET_SENSITIVITY ) begin
  if (`PICO_RESET_SENSITIVITY2) begin
       count_ff <= {awidth{1'b0}};
  end
  else if (flush) begin
       count_ff <= {awidth{1'b0}};
  end    
  else begin
     if (addq_only) begin    
       count_ff <= count_ff + 1'b1;
     end
     else if (shiftq_only) begin
       count_ff <= count_ff - 1'b1;
     end 
  end
end 

  always @ (`PICO_CLOCK_EDGE `PICO_CLOCK_SENSITIVITY `PICO_RESET_SENSITIVITY) begin
      if (`PICO_RESET_SENSITIVITY2)
      begin
         bypass_reg_valid_ff <= 1'b0;
         bypass_reg_ff <= {(width){1'b0}};
      end
      else if (flush)
      begin
         bypass_reg_valid_ff <= 1'b0;
      end
      else
      begin
        bypass_reg_valid_ff <= addq & ( mem_is_empty | (shiftq & onefull_ff) );
        bypass_reg_ff <= indata;
      end
   end
   assign outdata = bypass_reg_valid_ff ? bypass_reg_ff[width-1:0] : bram_outdata[width-1:0];

   wire [awidth-1:0] speculative_read_addr = (shiftq & not_empty_ff) ? next_read_addr_ff : read_addr_ff;

   RA2SH #(.dwidth(width), .depth(depth), .awidth(awidth) ) fifo_storage(
                         .QA(),
                         .CLKA(clk),
                         .CENA(~wreq),
                         .WENA(1'b0),
                         .AA(write_addr_ff[awidth-1:0]),
                         .DA(indata[width-1:0]),
                         .QB(bram_outdata[width-1:0]),
                         .CLKB(clk),
                         .CENB(~rreq),
                         .WENB(1'b1),
                         .AB(speculative_read_addr),
                         .DB({width{1'b0}}));


endmodule
