//======================================================== conditions
wire cond_0 = state == STATE_IDLE;
wire cond_1 = invdcode_do;
wire cond_2 = ~(dcachetoicache_accept_empty);
wire cond_3 = ~(pr_reset) && icacheread_do && icacheread_length > 5'd0;
wire cond_4 = icacheread_do && icacheread_cache_disable;
wire cond_5 = icacheread_do && ~(icacheread_cache_disable);
wire cond_6 = state == STATE_INVALIDATE_WRITE;
wire cond_7 = state == STATE_CHECK;
wire cond_8 = matched;
wire cond_9 = pr_reset == `FALSE && reset_waiting == `FALSE;
wire cond_10 = ~(cache_disable);
wire cond_11 = state == STATE_READ;
wire cond_12 = readcode_partial_done || readcode_done;
wire cond_13 = partial_length[2:0] > 3'd0 && length > 5'd0;
wire cond_14 = readcode_done && ~(cache_disable);
wire cond_15 = plru_index[1:0] == 2'd0;
wire cond_16 = plru_index[1:0] == 2'd1;
wire cond_17 = plru_index[1:0] == 2'd2;
wire cond_18 = plru_index[1:0] == 2'd3;
wire cond_19 = readcode_done;
//======================================================== saves
wire [31:0] address_to_reg =
    (cond_0 && ~cond_1 && cond_2)? ( dcachetoicache_accept_address) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( icacheread_address) :
    address;
wire [1:0] state_to_reg =
    (cond_0 && ~cond_1 && cond_2)? ( STATE_INVALIDATE_WRITE) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3 && cond_4)? ( STATE_CHECK) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3 && cond_5)? ( STATE_CHECK) :
    (cond_6)? ( STATE_IDLE) :
    (cond_7 && cond_8)? ( STATE_IDLE) :
    (cond_7 && ~cond_8 && cond_10)? ( STATE_READ) :
    (cond_7 && ~cond_8 && ~cond_10)? ( STATE_READ) :
    (cond_11 && cond_19)? ( STATE_IDLE) :
    state;
wire [4:0] length_to_reg =
    (cond_0)? (          icacheread_length) :
    (cond_11 && cond_9 && cond_12 && cond_13)? ( length - partial_length_current) :
    length;
wire  cache_disable_to_reg =
    (cond_0)? (   icacheread_cache_disable) :
    cache_disable;
wire [11:0] partial_length_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && cond_3 && cond_4)? ( length_burst) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3 && cond_5)? ( length_line) :
    (cond_11 && cond_9 && cond_12)? ( { 3'd0, partial_length[11:3] }) :
    partial_length;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) address <= 32'd0;
    else              address <= address_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) state <= 2'd0;
    else              state <= state_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) length <= 5'd0;
    else              length <= length_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) cache_disable <= 1'd0;
    else              cache_disable <= cache_disable_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) partial_length <= 12'd0;
    else              partial_length <= partial_length_to_reg;
end
//======================================================== sets
assign control_ram_read_do =
    (cond_0 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (`TRUE) :
    1'd0;
assign data_ram3_write_do =
    (cond_11 && cond_9 && cond_14 && cond_18)? (`TRUE) :
    1'd0;
assign data_ram0_address =
    (cond_0 && ~cond_1 && cond_2)? ( dcachetoicache_accept_address) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( icacheread_address) :
    (cond_11 && cond_9 && cond_14 && cond_15)? (   address) :
    32'd0;
assign readcode_do =
    (cond_7 && ~cond_8 && cond_10)? (`TRUE) :
    (cond_7 && ~cond_8 && ~cond_10)? (`TRUE) :
    1'd0;
assign data_ram0_data =
    (cond_11 && cond_9 && cond_14 && cond_15)? (      readcode_line) :
    128'd0;
assign data_ram1_write_do =
    (cond_11 && cond_9 && cond_14 && cond_16)? (`TRUE) :
    1'd0;
assign data_ram0_read_do =
    (cond_0 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (`TRUE) :
    1'd0;
assign data_ram2_data =
    (cond_11 && cond_9 && cond_14 && cond_17)? (      readcode_line) :
    128'd0;
assign readcode_address =
    (cond_7 && ~cond_8 && cond_10)? ( { address[31:4], 4'd0 }) :
    (cond_7 && ~cond_8 && ~cond_10)? ( { address[31:2], 2'd0 }) :
    32'd0;
assign dcachetoicache_accept_do =
    (cond_0 && ~cond_1 && cond_2)? (`TRUE) :
    1'd0;
assign prefetched_do =
    (cond_7 && cond_8 && cond_9)? (`TRUE) :
    (cond_11 && cond_9 && cond_12 && cond_13)? (`TRUE) :
    1'd0;
assign prefetched_length =
    (cond_7 && cond_8 && cond_9)? ( 5'd16 - { 1'b0, address[3:0] }) :
    (cond_11 && cond_9 && cond_12 && cond_13)? ( partial_length_current) :
    5'd0;
assign data_ram0_write_do =
    (cond_11 && cond_9 && cond_14 && cond_15)? (`TRUE) :
    1'd0;
assign data_ram1_read_do =
    (cond_0 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (`TRUE) :
    1'd0;
assign data_ram2_write_do =
    (cond_11 && cond_9 && cond_14 && cond_17)? (`TRUE) :
    1'd0;
assign data_ram3_data =
    (cond_11 && cond_9 && cond_14 && cond_18)? (      readcode_line) :
    128'd0;
assign data_ram3_read_do =
    (cond_0 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (`TRUE) :
    1'd0;
assign data_ram3_address =
    (cond_0 && ~cond_1 && cond_2)? ( dcachetoicache_accept_address) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( icacheread_address) :
    (cond_11 && cond_9 && cond_14 && cond_18)? (   address) :
    32'd0;
assign data_ram1_data =
    (cond_11 && cond_9 && cond_14 && cond_16)? (      readcode_line) :
    128'd0;
assign prefetchfifo_write_do =
    (cond_7 && cond_8 && cond_9)? (`TRUE) :
    (cond_11 && cond_9 && cond_12 && cond_13)? (`TRUE) :
    1'd0;
assign control_ram_write_do =
    (cond_6)? (`TRUE) :
    (cond_7 && cond_8 && cond_9)? (`TRUE) :
    (cond_11 && cond_9 && cond_14)? (`TRUE) :
    1'd0;
assign control_ram_data =
    (cond_6)? (    control_after_invalidate_write) :
    (cond_7 && cond_8 && cond_9)? (    control_after_match) :
    (cond_11 && cond_9 && cond_14)? (    control_after_line_read) :
    7'd0;
assign data_ram2_address =
    (cond_0 && ~cond_1 && cond_2)? ( dcachetoicache_accept_address) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( icacheread_address) :
    (cond_11 && cond_9 && cond_14 && cond_17)? (   address) :
    32'd0;
assign data_ram1_address =
    (cond_0 && ~cond_1 && cond_2)? ( dcachetoicache_accept_address) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( icacheread_address) :
    (cond_11 && cond_9 && cond_14 && cond_16)? (   address) :
    32'd0;
assign data_ram2_read_do =
    (cond_0 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (`TRUE) :
    1'd0;
assign prefetchfifo_write_data =
    (cond_7 && cond_8 && cond_9)? ( prefetch_line) :
    (cond_11 && cond_9 && cond_12 && cond_13)? ( prefetch_partial) :
    136'd0;
assign control_ram_address =
    (cond_0 && ~cond_1 && cond_2)? ( dcachetoicache_accept_address) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( icacheread_address) :
    (cond_6)? ( address) :
    (cond_7 && cond_8 && cond_9)? ( address) :
    (cond_11 && cond_9 && cond_14)? ( address) :
    32'd0;
