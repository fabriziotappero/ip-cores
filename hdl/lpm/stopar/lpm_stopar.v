// Serial to Parallel Shift Register
// Author: Peter Lieber
//

module lpm_stopar(clk,rst,sin,en,pout);

parameter WIDTH = 8;
parameter DEPTH = 2;

input		wire								clk;
input		wire								rst;
input		wire	[(WIDTH-1):0]			sin;
input		wire								en;
output	wire	[(WIDTH*DEPTH-1):0]	pout;

reg	[(WIDTH-1):0]	highreg;

always @(posedge clk)
begin
	if (rst == 1)
		highreg <= 0;
	else if (en == 1)
	begin
		highreg <= sin;
	end
end

assign pout = {highreg, sin};

endmodule
