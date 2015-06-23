//Using Two Simple Priority Arbiters with a Mask
//author: dongjun_luo@hotmail.com
module round_robin_arbiter (
	rst_an,
	clk,
	req,
	grant
);


input		rst_an;
input		clk;
input	[3:0]	req;
output	[3:0]	grant;

reg	[3:0]	rotate_ptr;
wire	[3:0]	mask_req;
reg	[3:0]	mask_grant;
wire	[3:0]	grant_comb;
reg	[3:0]	grant;
wire		no_mask_req;
reg	[3:0]	nomask_grant;

always @ (posedge clk or negedge rst_an)
begin
	if (!rst_an)
		rotate_ptr[3:0] <= 4'b1111;
	else 
		case (1'b1) // synthesis parallel_case
			grant[0]: rotate_ptr[3:0] <= 4'b1110;
			grant[1]: rotate_ptr[3:0] <= 4'b1100;
			grant[2]: rotate_ptr[3:0] <= 4'b1000;
			grant[3]: rotate_ptr[3:0] <= 4'b1111;
		endcase
end

assign mask_req[3:0] = req[3:0] & rotate_ptr[3:0];

// simple priority arbiter for mask req
always @ (*)
begin
	mask_grant[3:0] = 4'b0;
	if (mask_req[0])	mask_grant[0] = 1'b1;
	else if (mask_req[1])	mask_grant[1] = 1'b1;
	else if (mask_req[2])	mask_grant[2] = 1'b1;
	else if (mask_req[3])	mask_grant[3] = 1'b1;
end

// simple priority arbiter for no mask req
always @ (*)
begin
	nomask_grant[3:0] = 4'b0;
	if (req[0])		nomask_grant[0] = 1'b1;
	else if (req[1])	nomask_grant[1] = 1'b1;
	else if (req[2])	nomask_grant[2] = 1'b1;
	else if (req[3])	nomask_grant[3] = 1'b1;
end

assign no_mask_req = ~|mask_req[3:0];
//assign grant_comb[3:0] = no_mask_req ? nomask_grant[3:0] : mask_grant[3:0];
assign grant_comb[3:0] = (nomask_grant[3:0] & {4{no_mask_req}}) | mask_grant[3:0];

always @ (posedge clk or negedge rst_an)
begin
	if (!rst_an)	grant[3:0] <= 4'b0;
	else		grant[3:0] <= grant_comb[3:0] & ~grant[3:0];
end
endmodule
