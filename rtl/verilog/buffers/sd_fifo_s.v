//----------------------------------------------------------------------
// Srdy/Drdy FIFO "S"
//
// Building block for FIFOs.  The "S" (small or synchronizer) FIFO is 
// designed for smaller FIFOs based around memories or flops, with 
// sizes that are a power of 2.
//
// The "S" FIFO can be used as a two-clock asynchronous FIFO.  When the
// async parameter is set to 1, the pointers will be converted from
// binary to grey code and double-synchronized.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif

module sd_fifo_s
  #(parameter width=8,
    parameter depth=16,
    parameter async=0
    )
    (
     input       c_clk,
     input       c_reset,
     input       c_srdy,
     output      c_drdy,
     input [width-1:0] c_data,

     input       p_clk,
     input       p_reset,
     output      p_srdy,
     input       p_drdy,
     output  [width-1:0] p_data
     );

  localparam asz = $clog2(depth);

  reg [width-1:0] 	mem [0:depth-1];
  wire [width-1:0] 	mem_rddata;
  wire 			rd_en;
  wire [asz:0] 		rdptr_tail, rdptr_tail_sync;
  wire			wr_en;
  wire [asz:0] 		wrptr_head, wrptr_head_sync;
  wire [asz-1:0] 	rd_addr, wr_addr;

/* -----\/----- EXCLUDED -----\/-----
  always @(posedge c_clk)
    if (wr_en)
      mem[wr_addr] <= `SDLIB_DELAY c_data;

  assign mem_rddata = mem[rd_addr];
 -----/\----- EXCLUDED -----/\----- */
  behave2p_mem #(width, depth) mem2p
    (.d_out (p_data),
     .wr_en (wr_en),
     .rd_en (rd_en),
     .wr_clk (c_clk),
     .wr_addr (wr_addr),
     .rd_clk  (p_clk),
     .rd_addr (rd_addr),
     .d_in    (c_data));


  sd_fifo_head_s #(depth, async) head
    (
     // Outputs
     .c_drdy				(c_drdy),
     .wrptr_head			(wrptr_head),
     .wr_en				(wr_en),
     .wr_addr                           (wr_addr),
     // Inputs
     .clk				(c_clk),
     .reset				(c_reset),
     .c_srdy				(c_srdy),
     .rdptr_tail			(rdptr_tail_sync));

  sd_fifo_tail_s #(depth, async) tail
    (
     // Outputs
     .rdptr_tail			(rdptr_tail),
     .rd_en				(rd_en),
     .rd_addr                           (rd_addr),
     .p_srdy				(p_srdy),
     // Inputs
     .clk				(p_clk),
     .reset				(p_reset),
     .wrptr_head			(wrptr_head_sync),
     .p_drdy				(p_drdy));

/* -----\/----- EXCLUDED -----\/-----
  always @(posedge p_clk)
    begin
      if (rd_en)
	p_data <= `SDLIB_DELAY mem_rddata;
    end
 -----/\----- EXCLUDED -----/\----- */

  generate
    if (async)
      begin : gen_sync
	reg [asz:0] r_sync1, r_sync2;
	reg [asz:0] w_sync1, w_sync2;

	always @(posedge p_clk)
	  begin
	    w_sync1 <= `SDLIB_DELAY wrptr_head;
	    w_sync2 <= `SDLIB_DELAY w_sync1;
	  end

	always @(posedge c_clk)
	  begin
	    r_sync1 <= `SDLIB_DELAY rdptr_tail;
	    r_sync2 <= `SDLIB_DELAY r_sync1;
	  end

	assign wrptr_head_sync = w_sync2;
	assign rdptr_tail_sync = r_sync2;
      end
    else
      begin : gen_nosync
	assign wrptr_head_sync = wrptr_head;
	assign rdptr_tail_sync = rdptr_tail;
      end
  endgenerate	

endmodule // sd_fifo_s
