module cic_d
/*********************************************************************************************/
#(parameter idw = 8, odw = 8, r = 4, m = 4, g = 1)
/*********************************************************************************************/
//m - CIC order (comb chain length, integrator chain length)
//r - interpolation ratio
//idw - input data width
//odw - output data width
//g - differential delay in combs
/*********************************************************************************************/
(
    input   clk,
    input   reset_n,
    input   signed [idw-1:0] data_in,
    output  signed [odw-1:0] data_out,
    output  out_dv
);
/*********************************************************************************************/
localparam  b_max = $clog2((r*g)**m)+idw;
/*********************************************************************************************/
genvar  i;
generate
    for (i = 0; i < m; i++) begin:int_stage
        localparam idw_cur = b_max-cic_package::B(i+1,r,g,m,idw,odw)+1;
        localparam odw_cur = idw_cur;
        localparam odw_prev = (i!=0) ? b_max-cic_package::B(i,r,g,m,idw,odw)+1 : 0;
        wire signed [idw_cur-1:0] int_in;
        if (i!=0)
            assign int_in = int_stage[i-1].int_out[odw_prev-1:odw_prev-idw_cur];
        else
            assign int_in = data_in;
        wire signed [odw_cur-1:0] int_out;
        integrator #(idw_cur, odw_cur) int_inst(.clk(clk) , .reset_n(reset_n) , .data_in(int_in) , .data_out(int_out));
    end
endgenerate
/*********************************************************************************************/
localparam ds_dw = b_max-cic_package::B(m,r,g,m,idw,odw)+1;
wire signed [ds_dw-1:0] ds_out;
wire    ds_dv;
/*********************************************************************************************/
downsampler #(ds_dw, r) u1
(
    .clk(clk),
    .reset_n(reset_n),
    .data_in(int_stage[m-1].int_out),
    .data_out(ds_out),
    .dv(ds_dv)
);
/*********************************************************************************************/
genvar  j;
generate
    for (j = 0; j < m; j++) begin:comb_stage
        localparam idw_cur = b_max-cic_package::B(m+j+1,r,g,m,idw,odw);
        localparam odw_cur = idw_cur;
        localparam odw_prev = (j!=0) ? b_max-cic_package::B(m+j,r,g,m,idw,odw) : 0;
        wire signed [idw_cur-1:0] comb_in;
        if (j!=0)
            assign comb_in = comb_stage[j-1].comb_out[odw_prev-1:odw_prev-idw_cur];
        else
            assign comb_in = ds_out[ds_dw-1:ds_dw-idw_cur];
        wire signed [odw_cur-1:0] comb_out;
        comb #(idw_cur, odw_cur, g) comb_inst(.clk(clk) , .reset_n(reset_n) , .in_dv(ds_dv) , .data_in(comb_in) , .data_out(comb_out));
    end
endgenerate
/*********************************************************************************************/
localparam dw_out = b_max-cic_package::B(2*m,r,g,m,idw,odw);
assign data_out = comb_stage[m-1].comb_out[dw_out-1:dw_out-odw];
assign out_dv = ds_dv;
/*********************************************************************************************/
endmodule