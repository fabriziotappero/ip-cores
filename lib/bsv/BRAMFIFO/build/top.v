module top;
  reg clk;
  reg rst_n;

  mkTestBench m(.CLK(clk),.RST_N(rst_n));

always@(clk)
  #5 clk <= ~clk;

initial
  begin
    $dumpfile("dump.vcd");
    $dumpvars(4,m);
    rst_n <= 0;
    clk <= 0;
    #50;
    rst_n <= 1;

  end



endmodule 