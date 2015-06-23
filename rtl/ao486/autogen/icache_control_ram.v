//======================================================== conditions
wire cond_0 = init_done == `FALSE;
wire cond_1 = invd_counter == 8'd255;
wire cond_2 = state == STATE_IDLE;
wire cond_3 = init_done && invdcode_do;
wire cond_4 = state == STATE_INVD;
//======================================================== saves
wire  after_invalidate_to_reg =
    (cond_0 && cond_1)? ( `TRUE) :
    (cond_2)? ( `FALSE) :
    (cond_4 && cond_1)? ( `TRUE) :
    after_invalidate;
wire [7:0] invd_counter_to_reg =
    (cond_0)? ( invd_counter + 8'd1) :
    (cond_4)? ( invd_counter + 8'd1) :
    invd_counter;
wire  state_to_reg =
    (cond_2 && cond_3)? ( STATE_INVD) :
    (cond_4 && cond_1)? ( STATE_IDLE) :
    state;
wire  init_done_to_reg =
    (cond_0 && cond_1)? ( `TRUE) :
    init_done;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) after_invalidate <= 1'd0;
    else              after_invalidate <= after_invalidate_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) invd_counter <= 8'd0;
    else              invd_counter <= invd_counter_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) state <= 1'd0;
    else              state <= state_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) init_done <= 1'd0;
    else              init_done <= init_done_to_reg;
end
//======================================================== sets
assign invdcode_done =
    (cond_4 && cond_1)? (`TRUE) :
    1'd0;
