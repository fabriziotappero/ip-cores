//======================================================== conditions
wire cond_0 = state == STATE_IDLE;
wire cond_1 = length_1 == 3'd1;
wire cond_2 = length_1 == 3'd2;
wire cond_3 = write_do && ~(wr_reset) && ~(write_page_fault) && ~(write_ac_fault);
wire cond_4 = state == STATE_FIRST_WAIT;
wire cond_5 = tlbwrite_page_fault || tlbwrite_ac_fault;
wire cond_6 = tlbwrite_done && length_2_reg != 3'd0;
wire cond_7 = tlbwrite_done;
wire cond_8 = reset_waiting == `FALSE;
wire cond_9 = state == STATE_SECOND;
wire cond_10 = tlbwrite_page_fault || tlbwrite_ac_fault || tlbwrite_done;
wire cond_11 = tlbwrite_done && reset_waiting == `FALSE;
//======================================================== saves
wire [23:0] buffer_to_reg =
    (cond_0 && cond_1)? ( write_data[31:8]) :
    (cond_0 && ~cond_1 && cond_2)? ( { 8'd0,  write_data[31:16] }) :
    (cond_0 && ~cond_1 && ~cond_2)? ( { 16'd0, write_data[31:24] }) :
    buffer;
wire [31:0] address_2_reg_to_reg =
    (cond_0)? ( { address_2[31:4], 4'd0 }) :
    address_2_reg;
wire [2:0] length_2_reg_to_reg =
    (cond_0)? (  length_2) :
    length_2_reg;
wire [1:0] state_to_reg =
    (cond_0 && cond_3)? ( STATE_FIRST_WAIT) :
    (cond_4 && cond_5)? ( STATE_IDLE) :
    (cond_4 && ~cond_5 && cond_6)? ( STATE_SECOND) :
    (cond_4 && ~cond_5 && ~cond_6 && cond_7)? ( STATE_IDLE) :
    (cond_9 && cond_10)? ( STATE_IDLE) :
    state;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) buffer <= 24'd0;
    else              buffer <= buffer_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) address_2_reg <= 32'd0;
    else              address_2_reg <= address_2_reg_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) length_2_reg <= 3'd0;
    else              length_2_reg <= length_2_reg_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) state <= 2'd0;
    else              state <= state_to_reg;
end
//======================================================== sets
assign write_done =
    (cond_4 && ~cond_5 && ~cond_6 && cond_7 && cond_8)? (`TRUE) :
    (cond_9 && cond_11)? (`TRUE) :
    1'd0;
assign tlbwrite_do =
    (cond_0 && cond_3)? (`TRUE) :
    (cond_4)? (`TRUE) :
    (cond_9)? (`TRUE) :
    1'd0;
assign tlbwrite_address =
    (cond_0)? ( write_address) :
    (cond_4)? ( write_address) :
    (cond_9)? ( address_2_reg) :
    32'd0;
assign tlbwrite_length =
    (cond_0)? (  length_1) :
    (cond_4)? (  length_1) :
    (cond_9)? (  length_2_reg) :
    3'd0;
assign tlbwrite_data =
    (cond_0)? (    write_data) :
    (cond_4)? (    write_data) :
    (cond_9)? (    { 8'd0, buffer }) :
    32'd0;
