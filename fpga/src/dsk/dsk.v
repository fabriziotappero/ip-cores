//
// dsk.v -- parallel ATA (IDE) disk interface
//


module dsk(clk, reset,
           en, wr, addr,
           data_in, data_out,
           wt, irq,
           ata_d, ata_a, ata_cs0_n, ata_cs1_n,
           ata_dior_n, ata_diow_n, ata_intrq,
           ata_dmarq, ata_dmack_n, ata_iordy);
    // internal interface signals
    input clk;
    input reset;
    input en;
    input wr;
    input [19:2] addr;
    input [31:0] data_in;
    output [31:0] data_out;
    output wt;
    output irq;
    // external interface signals
    inout [15:0] ata_d;
    output [2:0] ata_a;
    output ata_cs0_n, ata_cs1_n;
    output ata_dior_n, ata_diow_n;
    input ata_intrq;
    input ata_dmarq;
    output ata_dmack_n;
    input ata_iordy;

  ata_ctrl ata_ctrl1 (
    .clk(clk),
    .reset(reset),
    .bus_en(en),
    .bus_wr(wr),
    .bus_addr(addr),
    .bus_din(data_in),
    .bus_dout(data_out),
    .bus_wait(wt),
    .bus_irq(irq),
    .ata_d(ata_d),
    .ata_a(ata_a),
    .ata_cs0_n(ata_cs0_n),
    .ata_cs1_n(ata_cs1_n),
    .ata_dior_n(ata_dior_n),
    .ata_diow_n(ata_diow_n),
    .ata_intrq(ata_intrq),
    .ata_dmarq(ata_dmarq),
    .ata_dmack_n(ata_dmack_n),
    .ata_iordy(ata_iordy)
  );

endmodule
