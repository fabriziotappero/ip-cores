/* Register delay
q is a registered version of d, registered 'STAGES' times.
Clock enable with 'enable'
*/

`default_nettype none

module registerDelay #(
	parameter DATA_WIDTH = 8,
	parameter STAGES = 1
)(
	input wire clk, rst, enable,
	input wire [(DATA_WIDTH-1):0] d,
	output wire [(DATA_WIDTH-1):0] q
);

	reg [DATA_WIDTH*STAGES-1:0] delayReg;
	assign q = delayReg[DATA_WIDTH-1:0];
	
	always @(posedge clk or posedge rst)
	begin
		if(rst)
		begin
			delayReg[DATA_WIDTH*STAGES-1:DATA_WIDTH*(STAGES-1)] <= {DATA_WIDTH{1'b0}};
		end
		else
		begin
			if(enable)
			begin
				delayReg[DATA_WIDTH*STAGES-1:DATA_WIDTH*(STAGES-1)] <= d;
			end
		end
	end
	
	generate
	genvar i;
		for(i = 0; i < (STAGES-1); i = i + 1)
			begin : rd_generate
				always @(posedge clk or posedge rst)
				begin
					if(rst)
					begin
						delayReg[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] <= {DATA_WIDTH*{1'b0}};
					end
					else
					begin
						if(enable)
						begin
							delayReg[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] <= delayReg[DATA_WIDTH*(i+2)-1:DATA_WIDTH*(i+1)];
						end
					end
				end
			end
	endgenerate
endmodule

`default_nettype wire