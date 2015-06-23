
`timescale 1ns/10ps

module memory (
    // Wishbone slave interface
    input         wb_clk_i,
    input         wb_rst_i,
    input  [15:0] wb_dat_i,
    output [15:0] wb_dat_o,
    input  [19:1] wb_adr_i,
    input         wb_we_i,
    input  [ 1:0] wb_sel_i,
    input         wb_stb_i,
    input         wb_cyc_i,
    output        wb_ack_o
  );

  // Registers and nets
  reg  [15:0] ram[2**19-1:0];

  wire       we;
  wire [7:0] bhw, blw;

  // Assignments
  assign wb_dat_o = ram[wb_adr_i];
  assign wb_ack_o = wb_stb_i;
  assign we       = wb_we_i & wb_stb_i & wb_cyc_i;

  assign bhw = wb_sel_i[1] ? wb_dat_i[15:8]
                           : ram[wb_adr_i][15:8];
  assign blw = wb_sel_i[0] ? wb_dat_i[7:0]
                           : ram[wb_adr_i][7:0];

  // Behaviour
  always @(posedge wb_clk_i)
    if (we) ram[wb_adr_i] <= { bhw, blw };

  initial $readmemh("/home/zeus/zet/sim/data.rtlrom",
                    ram, 19'h78000);
endmodule
