//--------------------------------------------------------------
// Testbench using Fuse Z80 emulator test vectors
//--------------------------------------------------------------
`include "z80.svh"

module test_bench_fuse(z80_if.tb z);

assign clk = z.CLK;

integer f;
// Instead of the PC register, we read the address of the next instruction
logic [15:0] pc;

initial begin : init
    z.nWAIT <= `CLR;
    z.nINT <= `CLR;
    z.nNMI <= `CLR;
    z.nBUSRQ <= `CLR;
    z.nRESET <= `CLR;

    // Run all the tests and write the result to a file
    f = $fopen("fuse.result.txt");
    `include "test_fuse.vh"
    $fclose(f);

end : init

endmodule

module test_fuse();

bit clk = 1;
initial repeat (`TOTAL_CLKS) #1 clk = ~clk;

z80_if z80(clk);            // Instantiate the Z80 bus interface
z80_top_ifc_n dut(z80);     // Create an instance of our Z80 design
test_bench_fuse tb(z80);    // Create an instance of the test bench

ram ram( .Address(z80.A), .Data(z80.D), .CS(z80.nMREQ), .WE(z80.nWR), .OE(z80.nRD) );
io  io( .Address(z80.A), .Data(z80.D), .CS(z80.nIORQ), .WE(z80.nWR), .OE(z80.nRD) );

endmodule
