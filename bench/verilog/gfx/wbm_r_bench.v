`include "../../../rtl/verilog/gfx/gfx_wbm_read.v"

module wbm_r_bench();
// wishbone signals
reg         clk_i;    // master clock reg
reg         rst_i;    // synchronous active high reset
wire        cyc_o;    // cycle wire
wire        stb_o;    // strobe output
wire [ 2:0] cti_o;    // cycle type id
wire [ 1:0] bte_o;    // burst type extension
wire        we_o;     // write enable wire
wire [31:0] adr_o;    // address wire
wire [ 3:0] sel_o;    // byte select wires (only 32bits accesses are supported)
reg         ack_i;    // wishbone cycle acknowledge
reg         err_i;    // wishbone cycle error
reg [31:0]  dat_i;    // wishbone data in

wire        sint_o;     // non recoverable error, interrupt host

// Renderer stuff
reg read_request_i;

reg [31:2] texture_addr_i;
reg [3:0]  texture_sel_i;
wire [31:0] texture_dat_o;
wire texture_data_ack;

initial begin
  $dumpfile("wbm_r.vcd");
  $dumpvars(0,wbm_r_bench);

// init values
  ack_i = 0;
  clk_i = 1;
  rst_i = 1;
  read_request_i = 0;
  err_i = 0;
  texture_sel_i = 4'hf;
  dat_i = 0;
  texture_addr_i = 0;

//timing
 #4 rst_i =0;
 #2 read_request_i = 1;
 #2 read_request_i = 0;

// end sim
  #100 $finish;
end

always begin
  #1 ack_i = !ack_i & cyc_o;
end

always begin
  #1 clk_i = ~clk_i;
end

gfx_wbm_read wbm_r(
// WB signals
.clk_i (clk_i),
.rst_i (rst_i),
.cyc_o (cyc_o),
.stb_o (stb_o),
.cti_o (cti_o),
.bte_o (bte_o),
.we_o (we_o),
.adr_o (adr_o),
.sel_o (sel_o),
.ack_i (ack_i),
.err_i (err_i),
.dat_i (dat_i),
.sint_o (sint_o),
// Control signals
.read_request_i (read_request_i),
.texture_addr_i (texture_addr_i),
.texture_sel_i (texture_sel_i),
.texture_dat_o (texture_dat_o),
.texture_data_ack (texture_data_ack)
);
endmodule
