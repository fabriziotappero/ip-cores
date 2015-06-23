module wishbone2bus #(
  parameter AW =  2,              // address width
  parameter DW = 32,              // data    width
  parameter SW = DW/8             // select  width
)(
  // Wishbone master port
  input  wire          wb_cyc,    // cycle
  input  wire          wb_stb,    // strobe
  input  wire          wb_we,     // write enable
  input  wire [AW-1:0] wb_adr,    // address
  input  wire [SW-1:0] wb_sel,    // byte select
  input  wire [DW-1:0] wb_dat_w,  // write data
  output wire [DW-1:0] wb_dat_r,  // read  data
  output wire          wb_ack,    // acknowledge
  output wire          wb_err,    // error
  output wire          wb_rty,    // retry
  // Avalon slave port
  output wire          bus_wen,   // write enable
  output wire          bus_ren,   // read  enable
  output wire [AW-1:0] bus_adr,   // address
  output wire [DW-1:0] bus_wdt,   // write data
  input  wire [DW-1:0] bus_rdt    // read  data
);

// bus write and read enable
assign bus_wen = wb_cyc & wb_stb &  wb_we;
assign bus_ren = wb_cyc & wb_stb & ~wb_we;

// address
assign bus_adr = wb_adr;

// write data
assign bus_wdt = wb_dat_w;

// read data
assign wb_dat_r = bus_rdt;

// error if not full width access else acknowledge
assign wb_ack =  &wb_sel;
assign wb_err = ~&wb_sel;
assign wb_rty =     1'b0;

endmodule
