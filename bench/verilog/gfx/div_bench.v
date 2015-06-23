`include "../../../rtl/verilog/gfx/div_uu.v"

module div_bench();

parameter point_width = 16;

reg                       clk_i;     // system clock
reg                       enable;    // clock enable

reg  [2*point_width -1:0] divident;  // divident
reg    [point_width -1:0] divisor;   // divisor
wire   [point_width -1:0] quotient;  // quotient
wire   [point_width -1:0] remainder; // remainder
wire                      div0;
wire                      overflow;

initial begin
  $dumpfile("div.vcd");
  $dumpvars(0,div_bench);

// init values
  clk_i = 0;
  enable = 1;
  divident = 25;
  divisor = 30;

#2  divident = 30;
  divisor = 5;

#8  enable = 0;
#8  enable = 1;

//timing

// end sim

  #1000 $finish;
end

always begin
  #1 clk_i = ~clk_i;
end

div_uu div(
.clk  (clk_i),
.ena  (enable),
.z    (divident),
.d    (divisor),
.q    (quotient),
.s    (remainder),
.div0 (div0),
.ovf  (overflow)
);

defparam div.z_width = 2*point_width;

endmodule

