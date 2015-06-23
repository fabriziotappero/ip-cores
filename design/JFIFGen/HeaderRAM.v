module HeaderRam(d, waddr, raddr, we, clk, q);
output [7:0] q;
input [7:0] d;
input[9:0] raddr;
input[9:0] waddr;
input clk, we;

reg [9:0] read_addr;
reg[7:0] mem [1023:0] /* synthesis syn_ramstyle="block_ram" */;

initial $readmemh("../design/jfifgen/header.hex", mem);

assign q = mem[read_addr];

always @(posedge clk) begin
if (we)
mem[waddr] <= d;
read_addr <= raddr;
end

endmodule
