/*Author: Zhuxu
	m99a1@yahoo.cn
Down clocking module
Output clock frequency is the original frequency divided by an odd number
*/
module down_clocking_odd(
input	i_clk,
input	i_rst,
input	[15:0]i_divisor,
output	o_clk
);

reg	a,b;
wire	c;

assign	c=(~a)&(~b);
wire	[15:0]divisor;
wire	borrow;
minus_one	minus_one_0(
i_divisor,
divisor,
borrow
);

wire	go;
assign	go=((i_divisor!=0)&&i_rst);
reg	[15:0]ct_0;
always@(posedge i_clk or negedge i_rst)
	if(!i_rst)begin
		a<=0;
		ct_0<=0;	
	end
	else if(go)begin
		if(a)begin
			if(ct_0>=divisor)begin
				ct_0<=0;
				a<=0;
			end
			else ct_0<=ct_0+1;
		end
		else if(c)a<=c;
	end


reg	[15:0]ct_1;
always@(negedge i_clk or negedge i_rst)
	if(!i_rst)begin
		b<=0;
		ct_1<=0;	
	end
	else if(go)begin
		if(b)begin
			if(ct_1>=divisor)begin
				ct_1<=0;
				b<=0;
			end
			else ct_1<=ct_1+1;
		end
		else if(c)b<=c;
	end

reg	clk;
always@(posedge c or negedge i_rst)
	if(!i_rst)clk<=0;
	else	clk<=~clk;

assign	o_clk=go?clk:i_clk;

endmodule