
module slow_mem(
    input               clk,
    input               rst_n,
    
    input       [9:0]   avs_address,
    input               avs_read,
    output      [7:0]   avs_readdata,
    input               avs_write,
    input       [7:0]   avs_writedata,
    output              avs_waitrequest
);

reg [5:0] wait_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   wait_cnt <= 6'd0;
    else                wait_cnt <= wait_cnt + 6'd1;
end

assign avs_waitrequest = ~(wait_cnt == 4'd0);

altsyncram line_ram_inst(
    .clock0     (clk),
    .address_a  (avs_address),
    .wren_a     (avs_write && ~(avs_waitrequest)),
    .data_a     (avs_writedata),
    
    .clock1     (clk),
    .address_b  (avs_address),
    .q_b        (avs_readdata)
);
defparam    line_ram_inst.operation_mode = "DUAL_PORT",
            line_ram_inst.width_a = 8,
            line_ram_inst.widthad_a = 10,
            line_ram_inst.width_b = 8,
            line_ram_inst.widthad_b = 10;

endmodule
