//----------------------------------------------------------------------
// Srdy/Drdy FIFO Tail "B"
//
// Building block for FIFOs.  The "B" (big) FIFO is design for larger FIFOs
// based around memories, with sizes that may not be a power of 2.
//
// The bound inputs allow multiple FIFO controllers to share a single
// memory.  The enable input is for arbitration between multiple FIFO
// controllers, or between the fifo head and tail controllers on a
// single port memory.
//
// The commit parameter enables read/commit behavior.  This creates
// two read pointers, one which is used for reading from memory and
// a commit pointer which is sent to the head block.  The abort behavior
// has a 3-cycle performance penalty due to pipeline flush.
//
// The FIFO tail assumes a memory with one-cycle read latency, and
// has output buffering to compensate for this.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// Clocking statement for synchronous blocks.  Default is for
// posedge clocking and positive async reset
`ifndef SDLIB_CLOCKING 
 `define SDLIB_CLOCKING posedge clk or posedge reset
`endif

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif


module sd_fifo_tail_b
  #(parameter width=8,
    parameter depth=16,
    parameter commit=0,
    parameter asz=$clog2(depth),
    parameter usz=$clog2(depth+1)
    )
    (
     input       clk,
     input       reset,
     input       enable,

     input [asz-1:0]      bound_low,
     input [asz-1:0]      bound_high,

     output reg [asz-1:0]   cur_rdptr,
     output reg [asz-1:0]   com_rdptr,
     input  [asz-1:0]       wrptr,
     output reg           mem_re,
     input                mem_we,

     output reg [usz-1:0] p_usage,
     
     output               p_srdy,
     input                p_drdy,
     input                p_commit,
     input                p_abort,
     input [width-1:0]    mem_rd_data,
     output [width-1:0]   p_data
     );

  reg [asz-1:0]           nxt_cur_rdptr;
  reg [asz-1:0]           cur_rdptr_p1;
  reg 			empty, full;

  reg 			nxt_irdy;

  reg [width-1:0]       hold_a, hold_b;
  reg                   valid_a, valid_b;
  reg                   prev_re;
  reg [usz:0]           tmp_usage;
  reg [usz:0]           fifo_size;
  wire 			rbuf1_drdy;
  wire 			ip_srdy, ip_drdy;
  wire [width-1:0] 	ip_data;

  // Stage 1 -- Read pipeline
  // issue a read if:
  //   1) we are enabled
  //   2) valid_a is 0, OR
  //   3) valid_b is 0, OR
  //   4) valid_a && valid_b && trdy
  always @*
    begin
      
      if (cur_rdptr[asz-1:0] == (bound_high))
	begin
	  cur_rdptr_p1[asz-1:0] = bound_low;
	end
      else
        cur_rdptr_p1 = cur_rdptr + 1;
      
      empty = (wrptr == cur_rdptr);

      if (commit && p_abort)
	begin
	  nxt_cur_rdptr = com_rdptr;
	  mem_re = 0;
	end
      else if (enable & !empty & (ip_drdy | (rbuf1_drdy & !prev_re)))
        begin
	  nxt_cur_rdptr = cur_rdptr_p1;
          mem_re = 1;
        end
      else
        begin
	  nxt_cur_rdptr = cur_rdptr;
          mem_re = 0;
        end // else: !if(enable & !empty & (!valid_a | !valid_b |...

      fifo_size = (bound_high - bound_low + 1);
      tmp_usage = wrptr[asz-1:0] - cur_rdptr[asz-1:0];
      if (~tmp_usage[usz])
        p_usage = tmp_usage[usz-1:0];
      else
        p_usage = fifo_size - (cur_rdptr[asz-1:0] - wrptr[asz-1:0]);  
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
	cur_rdptr <= `SDLIB_DELAY bound_low;
      else 
	cur_rdptr <= `SDLIB_DELAY nxt_cur_rdptr;
    end

  reg [asz-1:0]  rdaddr_s0, rdaddr_a, rdaddr_b;
  reg [asz-1:0]  nxt_com_rdptr;
  generate
    if (commit == 1)
      begin : gen_s0

	always @(posedge clk)
	  begin
	    if (reset)
	      com_rdptr <= `SDLIB_DELAY bound_low;
	    else
	      com_rdptr <= `SDLIB_DELAY nxt_com_rdptr;

	    if (mem_re)
	      rdaddr_s0 <= `SDLIB_DELAY cur_rdptr;
	  end
      end
    else
      begin : gen_ns0
	always @*
	  com_rdptr = cur_rdptr;
      end
  endgenerate

  // Stage 2 -- read buffering
  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
        begin
          prev_re <= `SDLIB_DELAY 0;
	end
      else 
        begin
	  if (commit && p_abort)
	    prev_re <= `SDLIB_DELAY 0;
	  else
            prev_re <= `SDLIB_DELAY mem_re;
	end // else: !if(reset)
    end // always @ (`SDLIB_CLOCKING)

  generate
    if (commit == 1)
      begin : gen_s2
	wire [asz-1:0] ip_rdaddr, p_rdaddr;

	sd_input #(asz+width) rbuf1
	  (.clk (clk), .reset (p_abort | reset),
	   .c_srdy (prev_re), 
	   .c_drdy (rbuf1_drdy),
	   .c_data ({rdaddr_s0,mem_rd_data}),
	   .ip_srdy (ip_srdy), .ip_drdy (ip_drdy),
	   .ip_data ({ip_rdaddr,ip_data}));
	
	sd_output #(asz+width) rbuf2
	  (.clk (clk), .reset (p_abort | reset),
	   .ic_srdy (ip_srdy), 
	   .ic_drdy (ip_drdy),
	   .ic_data ({ip_rdaddr,ip_data}),
	   .p_srdy (p_srdy), .p_drdy (p_drdy),
	   .p_data ({p_rdaddr,p_data}));

	always @*
	  begin
	    if (p_commit & p_srdy & p_drdy)
	      nxt_com_rdptr = p_rdaddr;
	    else
	      nxt_com_rdptr = com_rdptr;
	  end
      end // if (commit == 1)
    else
      begin : gen_ns2
	sd_input #(width) rbuf1
	  (.clk (clk), .reset (p_abort | reset),
	   .c_srdy (prev_re), 
	   .c_drdy (rbuf1_drdy),
	   .c_data (mem_rd_data),
	   .ip_srdy (ip_srdy), .ip_drdy (ip_drdy),
	   .ip_data (ip_data));
	
	sd_output #(width) rbuf2
	  (.clk (clk), .reset (p_abort | reset),
	   .ic_srdy (ip_srdy), 
	   .ic_drdy (ip_drdy),
	   .ic_data (ip_data),
	   .p_srdy (p_srdy), .p_drdy (p_drdy),
	   .p_data (p_data));
      end // else: !if(commit == 1)
  endgenerate

endmodule // it_fifo
