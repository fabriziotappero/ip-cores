
module bustap_jtag(
        gls_clk,
        gls_reset,
// slave interface signals
        avs_s1_chipselect,
        avs_s1_address,
        avs_s1_read,
        avs_s1_readdata,
        avs_s1_write,
        avs_s1_writedata,
        avs_s1_byteenable,
        avs_s1_waitrequest,
// master interface signals
        avm_m1_waitrequest,
        avm_m1_address,
        avm_m1_read,
        avm_m1_readdata,
        avm_m1_write,
        avm_m1_writedata,
        avm_m1_byteenable);

parameter addr_width = 32;

input  gls_clk,gls_reset;
// slave interface signals
input  avs_s1_chipselect;
output avs_s1_waitrequest;
input  [addr_width-1:0]avs_s1_address;
input  avs_s1_read,avs_s1_write;
output [31:0]avs_s1_readdata;
input  [31:0]avs_s1_writedata;
input  [3:0]avs_s1_byteenable;
// master interface signals
input  avm_m1_waitrequest;
output [addr_width-1:0]avm_m1_address;
output avm_m1_read,avm_m1_write;
input  [31:0]avm_m1_readdata;
output [31:0]avm_m1_writedata;
output [3:0]avm_m1_byteenable;

// bypass avalon bus signals
assign avs_s1_waitrequest = avm_m1_waitrequest;
assign avm_m1_address = avs_s1_address;
assign avm_m1_read  = avs_s1_read  && avs_s1_chipselect;
assign avm_m1_write = avs_s1_write && avs_s1_chipselect;
assign avs_s1_readdata = avm_m1_readdata;
assign avm_m1_writedata = avs_s1_writedata;
assign avm_m1_byteenable = avs_s1_byteenable;

// capture avalon bus signals
reg wr_en_latch, rd_en_latch;
reg [31:0] addr_latch;
reg [31:0] data_latch;

always @(posedge gls_clk) begin
    wr_en_latch <= avs_s1_chipselect && avs_s1_write && !avs_s1_waitrequest;
end

always @(posedge gls_clk) begin
    rd_en_latch <= avs_s1_chipselect && avs_s1_read && !avs_s1_waitrequest;
end

always @(posedge gls_clk) begin
    if (avs_s1_chipselect && (avs_s1_read || avs_s1_write) && !avs_s1_waitrequest)
        addr_latch <= {{(32-addr_width){1'b0}}, avs_s1_address};
end

always @(posedge gls_clk) begin
    if (avs_s1_chipselect && avs_s1_read  && !avs_s1_waitrequest)
        data_latch <= avs_s1_readdata;
    if (avs_s1_chipselect && avs_s1_write && !avs_s1_waitrequest)
        data_latch <= avs_s1_writedata;
end

// map to avalon access interface
wire        clk     = gls_clk;
wire        wr_en   = wr_en_latch;
wire        rd_en   = rd_en_latch;
wire [31:0] addr_in = addr_latch;
wire [31:0] data_in = data_latch;

up_monitor inst (
	.clk(clk),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr_in(addr_in),
	.data_in(data_in)
);

endmodule
