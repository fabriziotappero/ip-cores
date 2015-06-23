module cic_i
/*********************************************************************************************/
#(parameter dw = 8, r = 4, m = 4, g = 1)
/*********************************************************************************************/
//m - CIC order (comb chain length, integrator chain length)
//r - interpolation ratio
//dw - input data width
//g - differential delay in combs
/*********************************************************************************************/
(
    input   clk,
    input   reset_n,
    input   in_dv,
    input   signed [dw-1:0] data_in,
    output  signed [dw+$clog2((r**(m))/r)-1:0] data_out
);
/*********************************************************************************************/
wire signed [dw+m-2:0] upsample;
/*********************************************************************************************/
genvar  i;
generate
    for (i = 0; i < m; i++) begin:comb_stage
        wire signed [dw+i-1:0] comb_in;
        localparam odw = (i == m - 1) ? dw+i : dw+i+1;
        if (i!=0)
            assign comb_in = comb_stage[i-1].comb_out;
        else
            assign comb_in = data_in;
        wire signed [odw-1:0] comb_out;
        comb #(dw+i, odw, g) comb_inst(.clk(clk) , .reset_n(reset_n) , .in_dv(in_dv) , .data_in(comb_in) , .data_out(comb_out));
    end
endgenerate
/*********************************************************************************************/
assign  upsample = (in_dv) ? comb_stage[m-1].comb_out : 0;
/*********************************************************************************************/
genvar  j;
generate
    for (j = 0; j < m; j++) begin:int_stage
        localparam idw = (j == 0) ? dw+m-1 : dw+$clog2(((2**(m-j))*(r**(j)))/r);
        localparam odw = dw+$clog2(((2**(m-j-1))*(r**(j+1)))/r);
        wire signed [idw-1:0] int_in;
        if (j==0)
            assign int_in = upsample;
        else
            assign int_in = int_stage[j-1].int_out;
        wire signed [odw-1:0] int_out;
        integrator #(idw, odw) int_inst(.clk(clk) , .reset_n(reset_n) , .data_in(int_in) , .data_out(int_out));
    end
endgenerate
/*********************************************************************************************/
assign data_out = int_stage[m-1].int_out;
/*********************************************************************************************/
endmodule
