module graycntr (gray, clk, inc, rst_n, gnext);

parameter lpm_width = 4;

output [lpm_width-1:0] gray;
output [lpm_width-1:0] gnext;
input clk, inc, rst_n;
reg [lpm_width-1:0] gnext, gray, bnext, bin;

integer i;
always @(posedge clk or negedge rst_n)
    if (!rst_n) 
        gray <= 0;
    else if (inc)
        gray <= gnext;

always @(gray or inc) begin
    for (i=0; i<lpm_width; i=i+1)
        bin[i] = ^(gray>>i);
    bnext = bin+1'b1;
    gnext = (bnext>>1) ^ bnext;
end

endmodule