`include "../../../rtl/verilog/gfx/basic_fifo.v"

module fifo_bench();

parameter fifo_width     = 32;
parameter fifo_bit_depth = 6;

reg                     clk_i;
reg                     rst_i;

reg    [fifo_width-1:0] data_i;
reg                     enq_i;
wire                    full_o;
wire [fifo_bit_depth:0] count_o;

wire [fifo_width-1:0]   data_o;
wire                    valid_o;
reg                     deq_i;


initial begin
  $dumpfile("fifo.vcd");
  $dumpvars(0,fifo_bench);

// init values
  clk_i = 0;
  rst_i = 1;
  data_i = 0;
  enq_i = 1;
  deq_i = 0;

//timing
#2 rst_i = 0;

#200
  enq_i = 0;
  deq_i = 1;
#100 deq_i = 0;
// end sim
  #2000 $finish;
end

always begin
  #1 clk_i = ~clk_i;
end

basic_fifo fifo(
.clk_i   (clk_i),
.rst_i   (rst_i),

.data_i  (data_i),
.enq_i   (enq_i),
.full_o  (full_o),
.count_o (count_o),

.data_o  (data_o),
.valid_o (valid_o),
.deq_i   (deq_i)
);

defparam fifo.fifo_width     = fifo_width;
defparam fifo.fifo_bit_depth = fifo_bit_depth;

endmodule

