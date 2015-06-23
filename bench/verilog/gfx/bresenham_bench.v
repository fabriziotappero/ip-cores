`include "../../../rtl/verilog/gfx/gfx_bresenham.v"

module bresenham_bench();
reg clock; 
reg reset;
reg [15:0] MajStart;  // Integer
reg [23:0] MinStart;  // 8.8 FP
reg MajInc;
reg [9:0] MinInc;   // 2.8 FP, signed (by the way we code it)
reg XMaj;
reg do_line;
reg [15:0] Length;

wire [15:0] X, Y;
wire valid_out;
wire busy;

initial begin
  $dumpfile("bresenham.vcd");
  $dumpvars(0,bresenham_bench);
  clock = 0;
  Length = 0;
  reset = 1;
  MajStart = 0;
  MinStart = 0;
  MajInc = 0;
  MinInc = 0;
  XMaj = 0;
  do_line = 0;
  
  //timing
  #2 reset = 0;
  #4 MajStart = 1000;
     MinStart = 1000 << 8;
     XMaj = 1;
     Length = 100;
     MajInc = 1;
   //  MinInc = 127;
     MinInc = 896;
  #2 do_line = 1;

  #1000 $finish;
end

always @(posedge clock)
begin
if(!busy)
do_line <= 0;
end

always begin
  #1 clock = ~clock;
end

FixP_line bresenham(
.clock            (clock), 
.reset            (reset),
.busy             (busy),
.MajStart         (MajStart),
.MinStart         (MinStart),
.MajInc           (MajInc),
.MinInc           (MinInc),
.Length           (Length),
.XMaj             (XMaj),
.do_line          (do_line ),
.X                (X),
.Y                (Y),
.valid_out        (valid_out)
);

endmodule
