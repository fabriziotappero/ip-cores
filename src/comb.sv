module comb
/*********************************************************************************************/
#(parameter idw = 8, odw = 9, g = 1)
/*********************************************************************************************/
(
    input   clk,
    input   reset_n,
    input   in_dv,
    input   signed [idw-1:0] data_in,
    output  reg signed [odw-1:0] data_out
);
/*********************************************************************************************/
reg signed [idw-1:0] data_reg[g];
integer i;
/*********************************************************************************************/
always_ff @(posedge clk)
begin
    if (!reset_n) begin
        for (i=0;i<g;i++)
            data_reg[i] <= '0;
        data_out <= '0;
    end
    else if (in_dv) begin
        data_reg[0] <= data_in;
        for (i=1;i<g;i++)
            data_reg[i] <= data_reg[i-1];
        data_out <= data_in - data_reg[g-1];
    end
end
/*********************************************************************************************/
endmodule
