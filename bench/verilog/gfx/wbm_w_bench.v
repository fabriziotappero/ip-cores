`include "../../../rtl/verilog/gfx/gfx_wbm_write.v"
`include "../../../rtl/verilog/gfx/basic_fifo.v"

module wbm_w_bench();
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
wire [31:0] dat_o;    // wishbone data out

wire        sint_o;     // non recoverable error, interrupt host

// Renderer stuff
reg write_i;
wire ack_o;

reg [31:2] render_addr_i;
reg [3:0]  render_sel_i;
reg [31:0] render_dat_i;

initial begin
  $dumpfile("wbm_w.vcd");
  $dumpvars(0,wbm_w_bench);

// init values
  clk_i = 0;
  rst_i = 1;
  err_i = 0;
  write_i = 0;
  render_addr_i = 0;
  render_sel_i = 4'b1111;
  render_dat_i = 32'h12345678;

  #2 rst_i = 0;
//timing
  # 10 write_i = 1;
  # 2 write_i = 0;
  # 4 write_i = 1;
  # 2 write_i = 0;

// end sim
  #100 $finish;
end

always @(posedge clk_i)
begin
  ack_i <= #1 cyc_o & !ack_i;
end


always begin
  #1 clk_i = ~clk_i;
end

gfx_wbm_write wbm_w(
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
.dat_o (dat_o),
.sint_o (sint_o),
// Control signals
.write_i (write_i),
.ack_o (ack_o),
.render_addr_i (render_addr_i),
.render_sel_i (render_sel_i),
.render_dat_i (render_dat_i)
);
endmodule
