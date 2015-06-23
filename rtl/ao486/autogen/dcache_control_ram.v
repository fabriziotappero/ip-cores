//======================================================== conditions
wire cond_0 = init_done == `FALSE;
wire cond_1 = invd_counter == 8'd255;
wire cond_2 = state == STATE_IDLE;
wire cond_3 = init_done && invddata_do;
wire cond_4 = init_done && wbinvddata_do;
wire cond_5 = state == STATE_INVD;
wire cond_6 = state == STATE_WBINVD;
wire cond_7 = wbinvd_valid;
wire cond_8 = writeline_done;
wire cond_9 = wbinvd_counter == 10'd1023;
//======================================================== saves
wire [9:0] wbinvd_counter_to_reg =
    (cond_6 && cond_7 && cond_8)? (      wbinvd_counter_next) :
    (cond_6 && ~cond_7)? ( wbinvd_counter_next) :
    wbinvd_counter;
wire  after_invalidate_to_reg =
    (cond_0 && cond_1)? ( `TRUE) :
    (cond_2)? ( `FALSE) :
    (cond_5 && cond_1)? ( `TRUE) :
    (cond_6 && cond_7 && cond_8 && cond_9)? ( `TRUE) :
    (cond_6 && ~cond_7 && cond_9)? ( `TRUE) :
    after_invalidate;
wire [7:0] invd_counter_to_reg =
    (cond_0)? ( invd_counter + 8'd1) :
    (cond_5)? ( invd_counter + 8'd1) :
    invd_counter;
wire [1:0] state_to_reg =
    (cond_2 && cond_3)? ( STATE_INVD) :
    (cond_2 && ~cond_3 && cond_4)? ( STATE_WBINVD) :
    (cond_5 && cond_1)? ( STATE_IDLE) :
    (cond_6 && cond_7 && cond_8 && cond_9)? ( STATE_IDLE) :
    (cond_6 && ~cond_7 && cond_9)? ( STATE_IDLE) :
    state;
wire  init_done_to_reg =
    (cond_0 && cond_1)? (        `TRUE) :
    init_done;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wbinvd_counter <= 10'd0;
    else              wbinvd_counter <= wbinvd_counter_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) after_invalidate <= 1'd0;
    else              after_invalidate <= after_invalidate_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) invd_counter <= 8'd0;
    else              invd_counter <= invd_counter_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) state <= 2'd0;
    else              state <= state_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) init_done <= 1'd0;
    else              init_done <= init_done_to_reg;
end
//======================================================== sets
assign wbinvddata_done =
    (cond_6 && cond_7 && cond_8 && cond_9)? (`TRUE) :
    (cond_6 && ~cond_7 && cond_9)? (`TRUE) :
    1'd0;
assign writeline_do =
    (cond_6 && cond_7)? (`TRUE) :
    1'd0;
assign wbinvdread_address =
    (cond_2 && ~cond_3 && cond_4)? ( wbinvd_counter[9:2]) :
    (cond_6 && cond_7 && cond_8)? ( wbinvd_counter_next[9:2]) :
    (cond_6 && cond_7 && ~cond_8)? ( wbinvd_counter[9:2]) :
    (cond_6 && ~cond_7)? ( wbinvd_counter_next[9:2]) :
    8'd0;
assign wbinvdread_do =
    (cond_2 && ~cond_3 && cond_4)? (`TRUE) :
    (cond_6 && cond_7 && cond_8)? (`TRUE) :
    (cond_6 && ~cond_7)? (`TRUE) :
    1'd0;
assign writeline_line =
    (cond_6 && cond_7)? (    wbinvd_line[127:0]) :
    128'd0;
assign start_wbinvd =
    (cond_2 && ~cond_3 && cond_4)? (`TRUE) :
    1'd0;
assign invddata_done =
    (cond_5 && cond_1)? (`TRUE) :
    1'd0;
assign writeline_address =
    (cond_6 && cond_7)? ( { wbinvd_line[147:128], wbinvd_counter[9:2], 4'd0 }) :
    32'd0;
assign wbinvd_write_control =
    (cond_6 && cond_7 && cond_8)? ( wbinvd_counter[1:0] == 2'd3) :
    (cond_6 && ~cond_7)? ( wbinvd_counter[1:0] == 2'd3) :
    1'd0;
