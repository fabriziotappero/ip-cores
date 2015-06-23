//======================================================== conditions
wire cond_0 = state == STATE_IDLE;
wire cond_1 = read_do && ~(read_done) && ~(rd_reset) && ~(read_page_fault) && ~(read_ac_fault);
wire cond_2 = state == STATE_FIRST_WAIT;
wire cond_3 = tlbread_page_fault || tlbread_ac_fault || (tlbread_retry && reset_waiting);
wire cond_4 = tlbread_done && length_2_reg != 4'd0;
wire cond_5 = tlbread_done;
wire cond_6 = rd_reset == `FALSE && reset_waiting == `FALSE;
wire cond_7 = state == STATE_SECOND;
wire cond_8 = tlbread_page_fault || tlbread_ac_fault || tlbread_done || (tlbread_retry && reset_waiting);
wire cond_9 = tlbread_done && rd_reset == `FALSE && reset_waiting == `FALSE;
//======================================================== saves
wire [55:0] buffer_to_reg =
    (cond_2 && ~cond_3 && cond_4)? ( tlbread_data[55:0]) :
    buffer;
wire [31:0] address_2_reg_to_reg =
    (cond_0)? ( { address_2[31:4], 4'd0 }) :
    address_2_reg;
wire [3:0] length_2_reg_to_reg =
    (cond_0)? (  length_2) :
    length_2_reg;
wire [63:0] read_data_to_reg =
    (cond_2 && ~cond_3 && ~cond_4 && cond_5 && cond_6)? ( tlbread_data) :
    (cond_7 && cond_9)? ( merged) :
    read_data;
wire [1:0] state_to_reg =
    (cond_0 && cond_1)? ( STATE_FIRST_WAIT) :
    (cond_2 && cond_3)? ( STATE_IDLE) :
    (cond_2 && ~cond_3 && cond_4)? ( STATE_SECOND) :
    (cond_2 && ~cond_3 && ~cond_4 && cond_5)? ( STATE_IDLE) :
    (cond_7 && cond_8)? ( STATE_IDLE) :
    state;
wire  read_done_to_reg =
    (cond_0)? ( `FALSE) :
    (cond_2 && ~cond_3 && ~cond_4 && cond_5 && cond_6)? ( `TRUE) :
    (cond_7 && cond_9)? ( `TRUE) :
    read_done;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) buffer <= 56'd0;
    else              buffer <= buffer_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) address_2_reg <= 32'd0;
    else              address_2_reg <= address_2_reg_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) length_2_reg <= 4'd0;
    else              length_2_reg <= length_2_reg_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) read_data <= 64'd0;
    else              read_data <= read_data_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) state <= 2'd0;
    else              state <= state_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) read_done <= 1'd0;
    else              read_done <= read_done_to_reg;
end
//======================================================== sets
assign tlbread_do =
    (cond_0 && cond_1)? (`TRUE) :
    (cond_2)? (`TRUE) :
    (cond_7)? (`TRUE) :
    1'd0;
assign tlbread_length =
    (cond_0)? (  length_1) :
    (cond_2)? (  length_1) :
    (cond_7)? (  length_2_reg) :
    4'd0;
assign tlbread_address =
    (cond_0)? ( read_address) :
    (cond_2)? ( read_address) :
    (cond_7)? ( address_2_reg) :
    32'd0;
