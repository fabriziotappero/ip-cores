/*Down clocking module
Output clock frequency is the original frequency divided by an even number
*/
module	down_clocking_even(
input	i_clk,
input	i_rst,
input	[15:0]i_divisor,
output	o_clk
);

wire	[15:0]divisor;
wire	borrow;

minus_one	minus_one_0(
i_divisor,
divisor,
borrow
);

wire	go;
assign	go=((i_divisor!=0)&&i_rst);
reg	[15:0]ct;
reg	clk;
always@(posedge i_clk or negedge i_rst)
	if(!i_rst)begin
		ct<=0;
		clk<=0;
	end
	else if(go)begin
		if(ct>=divisor)begin
			ct<=0;
			clk<=~clk;
		end
		else ct<=ct+1;
	end
assign	o_clk=go?clk:i_clk;
endmodule