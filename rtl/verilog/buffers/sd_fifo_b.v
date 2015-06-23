//----------------------------------------------------------------------
// Srdy/Drdy FIFO "B"
//
// The "B" (big) FIFO is design for larger FIFOs
// based around memories, with sizes that may not be a power of 2.
//
// The bound inputs allow multiple FIFO controllers to share a single
// memory.  The enable input is for arbitration between multiple FIFO
// controllers, or between the fifo head and tail controllers on a
// single port memory.
//
// The commit parameter enables write/commit behavior.  This creates
// two write pointers, one which is used for writing to memory and
// a commit pointer which is sent to the tail block.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

module sd_fifo_b
  #(parameter width=8,
    parameter depth=256,
    parameter rd_commit=0,
    parameter wr_commit=0,
    parameter asz=$clog2(depth),
    parameter usz=$clog2(depth+1)
    )
    (
     input       clk,
     input       reset,

     input       c_srdy,
     output      c_drdy,
     input       c_commit,
     input       c_abort,
     input [width-1:0] c_data,

     output      p_srdy,
     input       p_drdy,
     input       p_commit,
     input       p_abort,
     output [width-1:0] p_data,

     output [usz-1:0] p_usage,
     output [usz-1:0] c_usage
     );

  wire [asz-1:0]	com_rdptr;		// From tail of sd_fifo_tail_b.v
  wire [asz-1:0]	com_wrptr;		// From head of sd_fifo_head_b.v
  wire [asz-1:0]	cur_rdptr;		// From tail of sd_fifo_tail_b.v
  wire [asz-1:0]	cur_wrptr;		// From head of sd_fifo_head_b.v
  wire [width-1:0]	mem_rd_data;
  wire			mem_re;			// From tail of sd_fifo_tail_b.v
  wire			mem_we;			// From head of sd_fifo_head_b.v
  wire [asz-1:0] 	bound_high;

  assign bound_high = depth-1;

  sd_fifo_head_b #(depth, wr_commit) head
    (
     // Outputs
     .c_drdy				(c_drdy),
     .cur_wrptr				(cur_wrptr[asz-1:0]),
     .com_wrptr				(com_wrptr[asz-1:0]),
     .mem_we				(mem_we),
     .c_usage                           (c_usage),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .enable				(1'b1),
     .c_commit				(c_commit),
     .c_abort				(c_abort),
     .c_srdy				(c_srdy),
     .bound_low				(0),
     .bound_high			(bound_high),
     .rdptr				(com_rdptr));

  behave2p_mem #(width, depth) mem
    (
     // Outputs
     .d_out				(mem_rd_data),
     // Inputs
     .wr_en				(mem_we),
     .rd_en				(mem_re),
     .wr_clk				(clk),
     .rd_clk				(clk),
     .d_in				(c_data),
     .rd_addr				(cur_rdptr),
     .wr_addr				(cur_wrptr));

  sd_fifo_tail_b #(width, depth, rd_commit) tail
    (
     // Outputs
     .cur_rdptr				(cur_rdptr[asz-1:0]),
     .com_rdptr				(com_rdptr[asz-1:0]),
     .mem_re				(mem_re),
     .p_usage				(p_usage[asz:0]),
     .p_srdy				(p_srdy),
     .p_data				(p_data[width-1:0]),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .enable				(1'b1),
     .bound_low				(0),
     .mem_we                            (mem_we),
     .bound_high			(bound_high),
     .wrptr				(com_wrptr),
     .p_drdy				(p_drdy),
     .p_commit				(p_commit),
     .p_abort				(p_abort),
     .mem_rd_data			(mem_rd_data[width-1:0]));

endmodule // sd_fifo_b
// Local Variables:
// verilog-library-directories:("." "../memory" )
// End:  
