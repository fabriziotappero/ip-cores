`timescale 1 ns/100 ps
// Version: 8.4 8.4.0.33


module gbuf(GL,CLK);
output GL;
input  CLK;

    wire GND;
    
    GND GND_1_net(.Y(GND));
    CLKDLY Inst1(.CLK(CLK), .GL(GL), .DLYGL0(GND), .DLYGL1(GND), 
        .DLYGL2(GND), .DLYGL3(GND), .DLYGL4(GND)) /* synthesis black_box */;
    
endmodule
