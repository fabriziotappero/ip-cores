//======================================================== conditions
wire cond_0 = state == STATE_TLB_REQUEST;
wire cond_1 = ~(pr_reset) && prefetch_length > 5'd0 && prefetchfifo_used < 5'd3;
wire cond_2 = tlbcode_do;
wire cond_3 = state == STATE_ICACHE;
wire cond_4 = page_cross || pr_reset || prefetchfifo_used >= 5'd8;
wire cond_5 = offset_update;
//======================================================== saves
wire [31:0] physical_to_reg =
    (cond_0 && cond_1 && cond_2)? (      tlbcode_physical) :
    (cond_3 && cond_5)? ( { physical[31:12], prefetch_address[11:0] }) :
    physical;
wire [31:0] linear_to_reg =
    (cond_0 && cond_1 && cond_2)? (        tlbcode_linear) :
    (cond_3 && cond_5)? (   { linear[31:12],   prefetch_address[11:0] }) :
    linear;
wire [1:0] state_to_reg =
    (cond_0 && cond_1 && cond_2)? ( STATE_ICACHE) :
    (cond_3 && cond_4)? ( STATE_TLB_REQUEST) :
    state;
wire  cache_disable_to_reg =
    (cond_0 && cond_1 && cond_2)? ( tlbcode_cache_disable) :
    cache_disable;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) physical <= 32'd0;
    else              physical <= physical_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) linear <= 32'd0;
    else              linear <= linear_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) state <= 2'd0;
    else              state <= state_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) cache_disable <= 1'd0;
    else              cache_disable <= cache_disable_to_reg;
end
//======================================================== sets
assign icacheread_length =
    (cond_0 && cond_1 && cond_2)? (        length) :
    (cond_3)? (        length) :
    5'd0;
assign tlbcoderequest_do =
    (cond_0 && cond_1)? (`TRUE) :
    1'd0;
assign icacheread_do =
    (cond_0 && cond_1 && cond_2)? (`TRUE) :
    (cond_3 && ~cond_4)? (`TRUE) :
    1'd0;
assign icacheread_cache_disable =
    (cond_0 && cond_1 && cond_2)? ( tlbcode_cache_disable) :
    (cond_3)? ( cache_disable) :
    1'd0;
assign icacheread_address =
    (cond_0 && cond_1 && cond_2)? (       tlbcode_physical) :
    (cond_3)? (       (offset_update)? { physical[31:12], prefetch_address[11:0] } : physical) :
    32'd0;
