`timescale 1 ns/100 ps
// Version: 8.5 SP2 8.5.2.4


module TwoPortRAM_256x36(WD,RD,WEN,REN,WADDR,RADDR,WCLK,RCLK);
input [35:0] WD;
output [35:0] RD;
input  WEN, REN;
input [7:0] WADDR, RADDR;
input WCLK, RCLK;

    wire WEAP, WEBP, VCC, GND;
    
    VCC VCC_1_net(.Y(VCC));
    GND GND_1_net(.Y(GND));
    RAM512X18 TwoPortRAM_256x36_R0C1(.RADDR8(GND), .RADDR7(
        RADDR[7]), .RADDR6(RADDR[6]), .RADDR5(RADDR[5]), .RADDR4(
        RADDR[4]), .RADDR3(RADDR[3]), .RADDR2(RADDR[2]), .RADDR1(
        RADDR[1]), .RADDR0(RADDR[0]), .WADDR8(GND), .WADDR7(
        WADDR[7]), .WADDR6(WADDR[6]), .WADDR5(WADDR[5]), .WADDR4(
        WADDR[4]), .WADDR3(WADDR[3]), .WADDR2(WADDR[2]), .WADDR1(
        WADDR[1]), .WADDR0(WADDR[0]), .WD17(WD[35]), .WD16(WD[34])
        , .WD15(WD[33]), .WD14(WD[32]), .WD13(WD[31]), .WD12(
        WD[30]), .WD11(WD[29]), .WD10(WD[28]), .WD9(WD[27]), .WD8(
        WD[26]), .WD7(WD[25]), .WD6(WD[24]), .WD5(WD[23]), .WD4(
        WD[22]), .WD3(WD[21]), .WD2(WD[20]), .WD1(WD[19]), .WD0(
        WD[18]), .RW0(GND), .RW1(VCC), .WW0(GND), .WW1(VCC), 
        .PIPE(GND), .REN(WEBP), .WEN(WEAP), .RCLK(RCLK), .WCLK(
        WCLK), .RESET(VCC), .RD17(RD[35]), .RD16(RD[34]), .RD15(
        RD[33]), .RD14(RD[32]), .RD13(RD[31]), .RD12(RD[30]), 
        .RD11(RD[29]), .RD10(RD[28]), .RD9(RD[27]), .RD8(RD[26]), 
        .RD7(RD[25]), .RD6(RD[24]), .RD5(RD[23]), .RD4(RD[22]), 
        .RD3(RD[21]), .RD2(RD[20]), .RD1(RD[19]), .RD0(RD[18]));
    RAM512X18 TwoPortRAM_256x36_R0C0(.RADDR8(GND), .RADDR7(
        RADDR[7]), .RADDR6(RADDR[6]), .RADDR5(RADDR[5]), .RADDR4(
        RADDR[4]), .RADDR3(RADDR[3]), .RADDR2(RADDR[2]), .RADDR1(
        RADDR[1]), .RADDR0(RADDR[0]), .WADDR8(GND), .WADDR7(
        WADDR[7]), .WADDR6(WADDR[6]), .WADDR5(WADDR[5]), .WADDR4(
        WADDR[4]), .WADDR3(WADDR[3]), .WADDR2(WADDR[2]), .WADDR1(
        WADDR[1]), .WADDR0(WADDR[0]), .WD17(WD[17]), .WD16(WD[16])
        , .WD15(WD[15]), .WD14(WD[14]), .WD13(WD[13]), .WD12(
        WD[12]), .WD11(WD[11]), .WD10(WD[10]), .WD9(WD[9]), .WD8(
        WD[8]), .WD7(WD[7]), .WD6(WD[6]), .WD5(WD[5]), .WD4(WD[4])
        , .WD3(WD[3]), .WD2(WD[2]), .WD1(WD[1]), .WD0(WD[0]), 
        .RW0(GND), .RW1(VCC), .WW0(GND), .WW1(VCC), .PIPE(GND), 
        .REN(WEBP), .WEN(WEAP), .RCLK(RCLK), .WCLK(WCLK), .RESET(
        VCC), .RD17(RD[17]), .RD16(RD[16]), .RD15(RD[15]), .RD14(
        RD[14]), .RD13(RD[13]), .RD12(RD[12]), .RD11(RD[11]), 
        .RD10(RD[10]), .RD9(RD[9]), .RD8(RD[8]), .RD7(RD[7]), 
        .RD6(RD[6]), .RD5(RD[5]), .RD4(RD[4]), .RD3(RD[3]), .RD2(
        RD[2]), .RD1(RD[1]), .RD0(RD[0]));
    INV WEBUBBLEB(.A(REN), .Y(WEBP));
    INV WEBUBBLEA(.A(WEN), .Y(WEAP));
    
endmodule
