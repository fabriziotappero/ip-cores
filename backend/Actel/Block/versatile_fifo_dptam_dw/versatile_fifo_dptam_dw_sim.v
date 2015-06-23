`timescale 1 ns/100 ps
// Version: 8.5 8.5.0.34


module versatile_fifo_dptam_dw(
       d_a,
       q_a,
       adr_a,
       we_a,
       clk_a,
       q_b,
       adr_b,
       d_b,
       we_b,
       clk_b
    );
input  [7:0] d_a;
output [7:0] q_a;
input  [10:0] adr_a;
input  we_a;
input  clk_a;
output [7:0] q_b;
input  [10:0] adr_b;
input  [7:0] d_b;
input  we_b;
input  clk_b;

    wire VCC, GND, \ram_tile_2.DOUT0_SIG[2] , 
        \ram_tile_2.DOUT0_SIG[3] , \ram_tile_2.DOUT0_SIG[4] , 
        \ram_tile_2.DOUT0_SIG[5] , \ram_tile_2.DOUT0_SIG[6] , 
        \ram_tile_2.DOUT0_SIG[7] , \ram_tile_2.DOUT0_SIG[8] , 
        \ram_tile_2.DOUT1_SIG[2] , \ram_tile_2.DOUT1_SIG[3] , 
        \ram_tile_2.DOUT1_SIG[4] , \ram_tile_2.DOUT1_SIG[5] , 
        \ram_tile_2.DOUT1_SIG[6] , \ram_tile_2.DOUT1_SIG[7] , 
        \ram_tile_2.DOUT1_SIG[8] , \ram_tile_1.DOUT0_SIG[2] , 
        \ram_tile_1.DOUT0_SIG[3] , \ram_tile_1.DOUT0_SIG[4] , 
        \ram_tile_1.DOUT0_SIG[5] , \ram_tile_1.DOUT0_SIG[6] , 
        \ram_tile_1.DOUT0_SIG[7] , \ram_tile_1.DOUT0_SIG[8] , 
        \ram_tile_1.DOUT1_SIG[2] , \ram_tile_1.DOUT1_SIG[3] , 
        \ram_tile_1.DOUT1_SIG[4] , \ram_tile_1.DOUT1_SIG[5] , 
        \ram_tile_1.DOUT1_SIG[6] , \ram_tile_1.DOUT1_SIG[7] , 
        \ram_tile_1.DOUT1_SIG[8] , \ram_tile_0.DOUT0_SIG[2] , 
        \ram_tile_0.DOUT0_SIG[3] , \ram_tile_0.DOUT0_SIG[4] , 
        \ram_tile_0.DOUT0_SIG[5] , \ram_tile_0.DOUT0_SIG[6] , 
        \ram_tile_0.DOUT0_SIG[7] , \ram_tile_0.DOUT0_SIG[8] , 
        \ram_tile_0.DOUT1_SIG[2] , \ram_tile_0.DOUT1_SIG[3] , 
        \ram_tile_0.DOUT1_SIG[4] , \ram_tile_0.DOUT1_SIG[5] , 
        \ram_tile_0.DOUT1_SIG[6] , \ram_tile_0.DOUT1_SIG[7] , 
        \ram_tile_0.DOUT1_SIG[8] , \ram_tile.DOUT0_SIG[2] , 
        \ram_tile.DOUT0_SIG[3] , \ram_tile.DOUT0_SIG[4] , 
        \ram_tile.DOUT0_SIG[5] , \ram_tile.DOUT0_SIG[6] , 
        \ram_tile.DOUT0_SIG[7] , \ram_tile.DOUT0_SIG[8] , 
        \ram_tile.DOUT1_SIG[2] , \ram_tile.DOUT1_SIG[3] , 
        \ram_tile.DOUT1_SIG[4] , \ram_tile.DOUT1_SIG[5] , 
        \ram_tile.DOUT1_SIG[6] , \ram_tile.DOUT1_SIG[7] , 
        \ram_tile.DOUT1_SIG[8] , we_b_i, we_a_i, GND_net_1, VCC_net_1;
    
    INV we_b_RNIB08 (.A(we_b), .Y(we_b_i));
    VCC VCC_i_0 (.Y(VCC_net_1));
    RAM4K9 ram_tile_0_I_1 (.ADDRA11(GND), .ADDRA10(adr_b[10]), .ADDRA9(
        adr_b[9]), .ADDRA8(adr_b[8]), .ADDRA7(adr_b[7]), .ADDRA6(
        adr_b[6]), .ADDRA5(adr_b[5]), .ADDRA4(adr_b[4]), .ADDRA3(
        adr_b[3]), .ADDRA2(adr_b[2]), .ADDRA1(adr_b[1]), .ADDRA0(
        adr_b[0]), .ADDRB11(GND), .ADDRB10(adr_a[10]), .ADDRB9(
        adr_a[9]), .ADDRB8(adr_a[8]), .ADDRB7(adr_a[7]), .ADDRB6(
        adr_a[6]), .ADDRB5(adr_a[5]), .ADDRB4(adr_a[4]), .ADDRB3(
        adr_a[3]), .ADDRB2(adr_a[2]), .ADDRB1(adr_a[1]), .ADDRB0(
        adr_a[0]), .DINA8(GND), .DINA7(GND), .DINA6(GND), .DINA5(GND), 
        .DINA4(GND), .DINA3(GND), .DINA2(GND), .DINA1(d_b[3]), .DINA0(
        d_b[2]), .DINB8(GND), .DINB7(GND), .DINB6(GND), .DINB5(GND), 
        .DINB4(GND), .DINB3(GND), .DINB2(GND), .DINB1(d_a[3]), .DINB0(
        d_a[2]), .WIDTHA0(VCC), .WIDTHA1(GND), .WIDTHB0(VCC), .WIDTHB1(
        GND), .PIPEA(GND), .PIPEB(GND), .WMODEA(GND), .WMODEB(GND), 
        .BLKA(GND), .BLKB(GND), .WENA(we_b_i), .WENB(we_a_i), .CLKA(
        clk_b), .CLKB(clk_a), .RESET(VCC), .DOUTA8(
        \ram_tile_0.DOUT0_SIG[8] ), .DOUTA7(\ram_tile_0.DOUT0_SIG[7] ), 
        .DOUTA6(\ram_tile_0.DOUT0_SIG[6] ), .DOUTA5(
        \ram_tile_0.DOUT0_SIG[5] ), .DOUTA4(\ram_tile_0.DOUT0_SIG[4] ), 
        .DOUTA3(\ram_tile_0.DOUT0_SIG[3] ), .DOUTA2(
        \ram_tile_0.DOUT0_SIG[2] ), .DOUTA1(q_b[3]), .DOUTA0(q_b[2]), 
        .DOUTB8(\ram_tile_0.DOUT1_SIG[8] ), .DOUTB7(
        \ram_tile_0.DOUT1_SIG[7] ), .DOUTB6(\ram_tile_0.DOUT1_SIG[6] ), 
        .DOUTB5(\ram_tile_0.DOUT1_SIG[5] ), .DOUTB4(
        \ram_tile_0.DOUT1_SIG[4] ), .DOUTB3(\ram_tile_0.DOUT1_SIG[3] ), 
        .DOUTB2(\ram_tile_0.DOUT1_SIG[2] ), .DOUTB1(q_a[3]), .DOUTB0(
        q_a[2]));
    INV we_a_RNIA08 (.A(we_a), .Y(we_a_i));
    GND GND_i_0 (.Y(GND_net_1));
    RAM4K9 ram_tile_I_1 (.ADDRA11(GND), .ADDRA10(adr_b[10]), .ADDRA9(
        adr_b[9]), .ADDRA8(adr_b[8]), .ADDRA7(adr_b[7]), .ADDRA6(
        adr_b[6]), .ADDRA5(adr_b[5]), .ADDRA4(adr_b[4]), .ADDRA3(
        adr_b[3]), .ADDRA2(adr_b[2]), .ADDRA1(adr_b[1]), .ADDRA0(
        adr_b[0]), .ADDRB11(GND), .ADDRB10(adr_a[10]), .ADDRB9(
        adr_a[9]), .ADDRB8(adr_a[8]), .ADDRB7(adr_a[7]), .ADDRB6(
        adr_a[6]), .ADDRB5(adr_a[5]), .ADDRB4(adr_a[4]), .ADDRB3(
        adr_a[3]), .ADDRB2(adr_a[2]), .ADDRB1(adr_a[1]), .ADDRB0(
        adr_a[0]), .DINA8(GND), .DINA7(GND), .DINA6(GND), .DINA5(GND), 
        .DINA4(GND), .DINA3(GND), .DINA2(GND), .DINA1(d_b[1]), .DINA0(
        d_b[0]), .DINB8(GND), .DINB7(GND), .DINB6(GND), .DINB5(GND), 
        .DINB4(GND), .DINB3(GND), .DINB2(GND), .DINB1(d_a[1]), .DINB0(
        d_a[0]), .WIDTHA0(VCC), .WIDTHA1(GND), .WIDTHB0(VCC), .WIDTHB1(
        GND), .PIPEA(GND), .PIPEB(GND), .WMODEA(GND), .WMODEB(GND), 
        .BLKA(GND), .BLKB(GND), .WENA(we_b_i), .WENB(we_a_i), .CLKA(
        clk_b), .CLKB(clk_a), .RESET(VCC), .DOUTA8(
        \ram_tile.DOUT0_SIG[8] ), .DOUTA7(\ram_tile.DOUT0_SIG[7] ), 
        .DOUTA6(\ram_tile.DOUT0_SIG[6] ), .DOUTA5(
        \ram_tile.DOUT0_SIG[5] ), .DOUTA4(\ram_tile.DOUT0_SIG[4] ), 
        .DOUTA3(\ram_tile.DOUT0_SIG[3] ), .DOUTA2(
        \ram_tile.DOUT0_SIG[2] ), .DOUTA1(q_b[1]), .DOUTA0(q_b[0]), 
        .DOUTB8(\ram_tile.DOUT1_SIG[8] ), .DOUTB7(
        \ram_tile.DOUT1_SIG[7] ), .DOUTB6(\ram_tile.DOUT1_SIG[6] ), 
        .DOUTB5(\ram_tile.DOUT1_SIG[5] ), .DOUTB4(
        \ram_tile.DOUT1_SIG[4] ), .DOUTB3(\ram_tile.DOUT1_SIG[3] ), 
        .DOUTB2(\ram_tile.DOUT1_SIG[2] ), .DOUTB1(q_a[1]), .DOUTB0(
        q_a[0]));
    VCC VCC_i (.Y(VCC));
    RAM4K9 ram_tile_2_I_1 (.ADDRA11(GND), .ADDRA10(adr_b[10]), .ADDRA9(
        adr_b[9]), .ADDRA8(adr_b[8]), .ADDRA7(adr_b[7]), .ADDRA6(
        adr_b[6]), .ADDRA5(adr_b[5]), .ADDRA4(adr_b[4]), .ADDRA3(
        adr_b[3]), .ADDRA2(adr_b[2]), .ADDRA1(adr_b[1]), .ADDRA0(
        adr_b[0]), .ADDRB11(GND), .ADDRB10(adr_a[10]), .ADDRB9(
        adr_a[9]), .ADDRB8(adr_a[8]), .ADDRB7(adr_a[7]), .ADDRB6(
        adr_a[6]), .ADDRB5(adr_a[5]), .ADDRB4(adr_a[4]), .ADDRB3(
        adr_a[3]), .ADDRB2(adr_a[2]), .ADDRB1(adr_a[1]), .ADDRB0(
        adr_a[0]), .DINA8(GND), .DINA7(GND), .DINA6(GND), .DINA5(GND), 
        .DINA4(GND), .DINA3(GND), .DINA2(GND), .DINA1(d_b[7]), .DINA0(
        d_b[6]), .DINB8(GND), .DINB7(GND), .DINB6(GND), .DINB5(GND), 
        .DINB4(GND), .DINB3(GND), .DINB2(GND), .DINB1(d_a[7]), .DINB0(
        d_a[6]), .WIDTHA0(VCC), .WIDTHA1(GND), .WIDTHB0(VCC), .WIDTHB1(
        GND), .PIPEA(GND), .PIPEB(GND), .WMODEA(GND), .WMODEB(GND), 
        .BLKA(GND), .BLKB(GND), .WENA(we_b_i), .WENB(we_a_i), .CLKA(
        clk_b), .CLKB(clk_a), .RESET(VCC), .DOUTA8(
        \ram_tile_2.DOUT0_SIG[8] ), .DOUTA7(\ram_tile_2.DOUT0_SIG[7] ), 
        .DOUTA6(\ram_tile_2.DOUT0_SIG[6] ), .DOUTA5(
        \ram_tile_2.DOUT0_SIG[5] ), .DOUTA4(\ram_tile_2.DOUT0_SIG[4] ), 
        .DOUTA3(\ram_tile_2.DOUT0_SIG[3] ), .DOUTA2(
        \ram_tile_2.DOUT0_SIG[2] ), .DOUTA1(q_b[7]), .DOUTA0(q_b[6]), 
        .DOUTB8(\ram_tile_2.DOUT1_SIG[8] ), .DOUTB7(
        \ram_tile_2.DOUT1_SIG[7] ), .DOUTB6(\ram_tile_2.DOUT1_SIG[6] ), 
        .DOUTB5(\ram_tile_2.DOUT1_SIG[5] ), .DOUTB4(
        \ram_tile_2.DOUT1_SIG[4] ), .DOUTB3(\ram_tile_2.DOUT1_SIG[3] ), 
        .DOUTB2(\ram_tile_2.DOUT1_SIG[2] ), .DOUTB1(q_a[7]), .DOUTB0(
        q_a[6]));
    RAM4K9 ram_tile_1_I_1 (.ADDRA11(GND), .ADDRA10(adr_b[10]), .ADDRA9(
        adr_b[9]), .ADDRA8(adr_b[8]), .ADDRA7(adr_b[7]), .ADDRA6(
        adr_b[6]), .ADDRA5(adr_b[5]), .ADDRA4(adr_b[4]), .ADDRA3(
        adr_b[3]), .ADDRA2(adr_b[2]), .ADDRA1(adr_b[1]), .ADDRA0(
        adr_b[0]), .ADDRB11(GND), .ADDRB10(adr_a[10]), .ADDRB9(
        adr_a[9]), .ADDRB8(adr_a[8]), .ADDRB7(adr_a[7]), .ADDRB6(
        adr_a[6]), .ADDRB5(adr_a[5]), .ADDRB4(adr_a[4]), .ADDRB3(
        adr_a[3]), .ADDRB2(adr_a[2]), .ADDRB1(adr_a[1]), .ADDRB0(
        adr_a[0]), .DINA8(GND), .DINA7(GND), .DINA6(GND), .DINA5(GND), 
        .DINA4(GND), .DINA3(GND), .DINA2(GND), .DINA1(d_b[5]), .DINA0(
        d_b[4]), .DINB8(GND), .DINB7(GND), .DINB6(GND), .DINB5(GND), 
        .DINB4(GND), .DINB3(GND), .DINB2(GND), .DINB1(d_a[5]), .DINB0(
        d_a[4]), .WIDTHA0(VCC), .WIDTHA1(GND), .WIDTHB0(VCC), .WIDTHB1(
        GND), .PIPEA(GND), .PIPEB(GND), .WMODEA(GND), .WMODEB(GND), 
        .BLKA(GND), .BLKB(GND), .WENA(we_b_i), .WENB(we_a_i), .CLKA(
        clk_b), .CLKB(clk_a), .RESET(VCC), .DOUTA8(
        \ram_tile_1.DOUT0_SIG[8] ), .DOUTA7(\ram_tile_1.DOUT0_SIG[7] ), 
        .DOUTA6(\ram_tile_1.DOUT0_SIG[6] ), .DOUTA5(
        \ram_tile_1.DOUT0_SIG[5] ), .DOUTA4(\ram_tile_1.DOUT0_SIG[4] ), 
        .DOUTA3(\ram_tile_1.DOUT0_SIG[3] ), .DOUTA2(
        \ram_tile_1.DOUT0_SIG[2] ), .DOUTA1(q_b[5]), .DOUTA0(q_b[4]), 
        .DOUTB8(\ram_tile_1.DOUT1_SIG[8] ), .DOUTB7(
        \ram_tile_1.DOUT1_SIG[7] ), .DOUTB6(\ram_tile_1.DOUT1_SIG[6] ), 
        .DOUTB5(\ram_tile_1.DOUT1_SIG[5] ), .DOUTB4(
        \ram_tile_1.DOUT1_SIG[4] ), .DOUTB3(\ram_tile_1.DOUT1_SIG[3] ), 
        .DOUTB2(\ram_tile_1.DOUT1_SIG[2] ), .DOUTB1(q_a[5]), .DOUTB0(
        q_a[4]));
    GND GND_i (.Y(GND));
    
endmodule
