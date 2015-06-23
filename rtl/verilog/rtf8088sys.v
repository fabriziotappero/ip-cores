
module rtf8088sys();

reg rst;
reg sys_clk;
wire cpu_mio;
wire cpu_cyc;
wire cpu_stb;
wire cpu_ack;
wire cpu_we;
wire [19:0] cpu_adr;
wire [7:0] cpu_dato;
reg [7:0] cpu_dati;
wire stkmem_ack;
wire [7:0] stkmem_o;
wire [7:0] bootromo;
wire br_acko;
wire mem_ack;
wire [7:0] memo;

initial begin
	rst = 1'b0;
	sys_clk = 1'b0;
	#100 rst = 1'b1;
	#100 rst = 1'b0;
end

always #10 sys_clk = ~sys_clk;

reg [7:0] mem [0:65535];
wire csmem = cpu_cyc && cpu_stb && cpu_adr[19:16]==4'h0;
always @(posedge sys_clk)
	if (csmem & cpu_we) begin
		$display("wrote mem[%h]=%h", cpu_adr,cpu_dato);
		mem[cpu_adr[15:0]] <= cpu_dato;
	end
assign mem_ack = csmem;
assign memo = csmem ? mem[cpu_adr[15:0]] : 8'h00;

bootrom u3
(
	.cyc(cpu_cyc),
	.stb(cpu_stb),
	.adr(cpu_adr),
	.o(bootromo),
	.acko(br_acko)
);

stkmem u2
(
	.clk_i(sys_clk),
	.cyc_i(cpu_cyc),
	.stb_i(cpu_stb),
	.ack_o(stkmem_ack),
	.we_i(cpu_we),
	.adr_i(cpu_adr),
	.dat_i(cpu_dato),
	.dat_o(stkmem_o)
);

always @(stkmem_o or bootromo or memo)
	cpu_dati = stkmem_o|bootromo|memo;
assign cpu_ack = stkmem_ack|br_acko|mem_ack;

rtf8088 u1
(
	.rst_i(rst),
	.clk_i(sys_clk),
	.nmi_i(1'b0),
	.irq_i(1'b0),
	.busy_i(1'b0),
	.inta_o(),
	.lock_o(),
	.mio_o(cpu_mio),
	.cyc_o(cpu_cyc),
	.stb_o(cpu_stb),
	.ack_i(cpu_ack),
	.we_o(cpu_we),
	.adr_o(cpu_adr),
	.dat_o(cpu_dato),
	.dat_i(cpu_dati)
);

endmodule


module stkmem(clk_i, cyc_i, stb_i, ack_o, we_i, adr_i, dat_i, dat_o);
input clk_i;
input cyc_i;
input stb_i;
output ack_o;
input we_i;
input [19:0] adr_i;
input [7:0] dat_i;
output [7:0] dat_o;

reg [10:0] rra;
reg [7:0] mem [2047:0];
wire cs = cyc_i && stb_i && adr_i[19:11]==9'h003;
assign ack_o = cs;

always @(negedge clk_i)
	rra <= adr_i[10:0];

always @(negedge clk_i)
	if (cs & we_i)
		mem[adr_i[10:0]] <= dat_i;

assign dat_o = cs ? mem[rra] : 8'h00;

endmodule
