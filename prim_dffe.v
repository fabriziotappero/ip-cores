module prim_dffe(d, clk, ena, clrn, prn, q);
parameter lpm_width = 1;
parameter lpm_avalue = 0;

input clk, ena;
input clrn,prn;
input [lpm_width-1 : 0] d;
output [lpm_width-1 : 0] q;

tri1 clrn,prn;
wire i_clr, i_prn;
buf(i_clr, clrn);
buf(i_prn, prn);

reg [lpm_width-1 : 0] q;

always @(posedge clk or negedge i_clr or negedge i_prn) begin
    if (!i_clr)
        q <= {lpm_width{1'b0}};
    else if (!i_prn)
        q <= {lpm_width{1'b1}};
    else if (ena)
        q <= d;
end

endmodule
