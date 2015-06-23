//--------------------------------------------------------------
// Testbench for the host board
//--------------------------------------------------------------
`timescale 10 ns/ 10 ns

module test_bench_host();

reg reset;
wire uart_tx;

// Proper sequence for the ModelSim reset
initial begin : init
    force host_.z80_.fpga_reset=1;
#2  force host_.z80_.fpga_reset=0;
    reset = 0;
#10 reset = 1;
end : init

reg clk = 1;
initial forever #1 clk = ~clk;

host host_( .*, .clk(clk), .reset(reset), .uart_tx(uart_tx) );

endmodule
