//
// atabuf.v -- parallel ATA data buffer
//


module ata_buffer (clk,
                   bus_write, bus_addr, bus_din, bus_dout,
                   ata_write, ata_addr, ata_din, ata_dout);
    input clk;
    // bus interface
    input bus_write;
    input [11:2] bus_addr;
    input [31:0] bus_din;
    output [31:0] bus_dout;
    // ata interface
    input ata_write;
    input [11:1] ata_addr;
    input [15:0] ata_din;
    output [15:0] ata_dout;

  wire [9:0] internal_bus_addr;
  wire [9:0] internal_ata_addr;
  wire [15:0] lo_din_bus;
  wire [15:0] hi_din_bus;
  wire [15:0] lo_din_ata;
  wire [15:0] hi_din_ata;
  wire [15:0] lo_dout_bus;
  wire [15:0] hi_dout_bus;
  wire [15:0] lo_dout_ata;
  wire [15:0] hi_dout_ata;
  wire lo_write_bus;
  wire hi_write_bus;
  wire lo_write_ata;
  wire hi_write_ata;
  reg ata_out_muxctrl;

  assign internal_bus_addr[9:0] = bus_addr[11:2];
  assign internal_ata_addr[9:0] = ata_addr[11:2];

  assign lo_din_bus = { bus_din[7:0], bus_din[15:8] };
  assign hi_din_bus = { bus_din[23:16], bus_din[31:24] };
  assign lo_din_ata = ata_din;
  assign hi_din_ata = ata_din;

  // pipeline register for ata output mux control
  always @(posedge clk) begin
    ata_out_muxctrl <= ata_addr[1];
  end

  assign bus_dout = { hi_dout_bus[7:0], hi_dout_bus[15:8],
                      lo_dout_bus[7:0], lo_dout_bus[15:8] };
  assign ata_dout = ata_out_muxctrl ? lo_dout_ata : hi_dout_ata;

  assign lo_write_bus = bus_write;
  assign hi_write_bus = bus_write;
  assign lo_write_ata = ata_write & ata_addr[1];
  assign hi_write_ata = ata_write & ~ata_addr[1];

  RAMB16_S18_S18 lo_buffer (
    .DOA(lo_dout_bus),
    .DOB(lo_dout_ata),
    .ADDRA(internal_bus_addr),
    .ADDRB(internal_ata_addr),
    .CLKA(clk),
    .CLKB(clk),
    .DIA(lo_din_bus),
    .DIB(lo_din_ata),
    .DIPA(2'b00),
    .DIPB(2'b00),
    .ENA(1'b1),
    .ENB(1'b1),
    .SSRA(1'b0),
    .SSRB(1'b0),
    .WEA(lo_write_bus),
    .WEB(lo_write_ata)
  );

  RAMB16_S18_S18 hi_buffer (
    .DOA(hi_dout_bus),
    .DOB(hi_dout_ata),
    .ADDRA(internal_bus_addr),
    .ADDRB(internal_ata_addr),
    .CLKA(clk),
    .CLKB(clk),
    .DIA(hi_din_bus),
    .DIB(hi_din_ata),
    .DIPA(2'b00),
    .DIPB(2'b00),
    .ENA(1'b1),
    .ENB(1'b1),
    .SSRA(1'b0),
    .SSRB(1'b0),
    .WEA(hi_write_bus),
    .WEB(hi_write_ata)
  );

endmodule
