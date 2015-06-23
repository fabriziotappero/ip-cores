`include "../../../rtl/verilog/gfx/gfx_wbm_read_arbiter.v"

module arbiter_bench();

// Clock
reg         clk_i;    // master clock reg

// Interface against the wbm read module
wire        master_busy_o;
wire        read_request_o;
wire [31:2] addr_o;
wire  [3:0] sel_o;
reg  [31:0] dat_i;
reg         ack_i;
// Interface against masters (clip)
reg         m0_read_request_i;
reg  [31:2] m0_addr_i;
reg   [3:0] m0_sel_i;
wire [31:0] m0_dat_o;
wire        m0_ack_o;
// Interface against masters (fragment processor)
reg         m1_read_request_i;
reg  [31:2] m1_addr_i;
reg   [3:0] m1_sel_i;
wire [31:0] m1_dat_o;
wire        m1_ack_o;
// Interface against masters (blender)
reg         m2_read_request_i;
reg  [31:2] m2_addr_i;
reg   [3:0] m2_sel_i;
wire [31:0] m2_dat_o;
wire        m2_ack_o;

initial begin
  $dumpfile("arbiter.vcd");
  $dumpvars(0,arbiter_bench);

// init values
  clk_i = 0;
  dat_i = 32'h12345678;
  ack_i = 0;
  m0_read_request_i = 0;
  m0_addr_i = 10;
  m0_sel_i = 0;
  m1_read_request_i = 0;
  m1_addr_i = 20;
  m1_sel_i = 8;
  m2_read_request_i = 0;
  m2_addr_i = 30;
  m2_sel_i = 8;

  #10 m0_read_request_i = 1;
  #10 m0_read_request_i = 0;
  #10 m1_read_request_i = 1;
  #10 m1_read_request_i = 0;

  #10 m1_read_request_i = 1;
  m0_read_request_i = 1;
  #10 m1_read_request_i = 0;
  #10 m0_read_request_i = 0;

//timing

  #100 $finish;
end

always @(posedge clk_i)
begin
  ack_i <= #1 read_request_o;
end

always begin
  #1 clk_i = ~clk_i;
end

gfx_wbm_read_arbiter arbiter(
.master_busy_o (master_busy_o),
// Interface against the wbm read module
.read_request_o (read_request_o),
.addr_o (addr_o),
.sel_o (sel_o),
.dat_i (dat_i),
.ack_i (ack_i),
// Interface against masters (clip)
.m0_read_request_i (m0_read_request_i),
.m0_addr_i (m0_addr_i),
.m0_sel_i (m0_sel_i),
.m0_dat_o (m0_dat_o),
.m0_ack_o (m0_ack_o),
// Interface against masters (fragment processor)
.m1_read_request_i (m1_read_request_i),
.m1_addr_i (m1_addr_i),
.m1_sel_i (m1_sel_i),
.m1_dat_o (m1_dat_o),
.m1_ack_o (m1_ack_o),
// Interface against masters (blender)
.m2_read_request_i (m2_read_request_i),
.m2_addr_i (m2_addr_i),
.m2_sel_i (m2_sel_i),
.m2_dat_o (m2_dat_o),
.m2_ack_o (m2_ack_o)
);

endmodule
