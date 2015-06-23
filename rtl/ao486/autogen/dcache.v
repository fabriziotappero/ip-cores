//======================================================== conditions
wire cond_0 = state == STATE_IDLE;
wire cond_1 = invddata_do;
wire cond_2 = wbinvddata_do;
wire cond_3 = dcachewrite_do;
wire cond_4 = dcacheread_do;
wire cond_5 = state == STATE_READ_CHECK;
wire cond_6 = matched;
wire cond_7 = cache_disable;
wire cond_8 = writeback_needed;
wire cond_9 = state == STATE_WRITE_CHECK;
wire cond_10 = matched_index == 2'd0;
wire cond_11 = matched_index == 2'd1;
wire cond_12 = matched_index == 2'd2;
wire cond_13 = matched_index == 2'd3;
wire cond_14 = write_through;
wire cond_15 = state == STATE_READ_BURST;
wire cond_16 = readburst_done;
wire cond_17 = state == STATE_WRITE_BACK;
wire cond_18 = writeline_done;
wire cond_19 = state == STATE_READ_LINE;
wire cond_20 = readline_done;
wire cond_21 = is_write;
wire cond_22 = plru_index == 2'd0;
wire cond_23 = plru_index == 2'd1;
wire cond_24 = plru_index == 2'd2;
wire cond_25 = plru_index == 2'd3;
wire cond_26 = state == STATE_WRITE_THROUGH;
wire cond_27 = writeburst_done;
//======================================================== saves
wire  is_write_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( `TRUE) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? ( `FALSE) :
    is_write;
wire [31:0] address_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (        dcachewrite_address) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (        dcacheread_address) :
    address;
wire [2:0] state_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( STATE_WRITE_CHECK) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? ( STATE_READ_CHECK) :
    (cond_5 && cond_6)? ( STATE_IDLE) :
    (cond_5 && ~cond_6 && cond_7)? ( STATE_READ_BURST) :
    (cond_5 && ~cond_6 && ~cond_7 && cond_8)? ( STATE_WRITE_BACK) :
    (cond_5 && ~cond_6 && ~cond_7 && ~cond_8)? ( STATE_READ_LINE) :
    (cond_9 && cond_6 && cond_14)? ( STATE_WRITE_THROUGH) :
    (cond_9 && cond_6 && ~cond_14)? ( STATE_IDLE) :
    (cond_9 && ~cond_6 && cond_7)? ( STATE_WRITE_THROUGH) :
    (cond_9 && ~cond_6 && ~cond_7 && cond_8)? ( STATE_WRITE_BACK) :
    (cond_9 && ~cond_6 && ~cond_7 && ~cond_8)? ( STATE_READ_LINE) :
    (cond_15 && cond_16)? ( STATE_IDLE) :
    (cond_17 && cond_18)? ( STATE_READ_LINE) :
    (cond_19 && cond_20 && cond_21 && cond_14)? ( STATE_WRITE_THROUGH) :
    (cond_19 && cond_20 && cond_21 && ~cond_14)? ( STATE_IDLE) :
    (cond_19 && cond_20 && ~cond_21)? ( STATE_IDLE) :
    (cond_26 && cond_27)? ( STATE_IDLE) :
    state;
wire [3:0] length_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (         { 1'b0, dcachewrite_length }) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (         dcacheread_length) :
    length;
wire  write_through_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (  dcachewrite_write_through) :
    write_through;
wire [31:0] write_data_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (     dcachewrite_data) :
    write_data;
wire  cache_disable_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (  dcachewrite_cache_disable) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (  dcacheread_cache_disable) :
    cache_disable;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) is_write <= 1'd0;
    else              is_write <= is_write_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) address <= 32'd0;
    else              address <= address_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) state <= 3'd0;
    else              state <= state_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) length <= 4'd0;
    else              length <= length_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) write_through <= 1'd0;
    else              write_through <= write_through_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) write_data <= 32'd0;
    else              write_data <= write_data_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) cache_disable <= 1'd0;
    else              cache_disable <= cache_disable_to_reg;
end
//======================================================== sets
assign control_ram_read_do =
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (`TRUE) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (`TRUE) :
    1'd0;
assign data_ram3_write_do =
    (cond_9 && cond_6 && cond_13)? (`TRUE) :
    (cond_19 && cond_20 && cond_21 && cond_25)? (`TRUE) :
    (cond_19 && cond_20 && ~cond_21 && cond_25)? (`TRUE) :
    1'd0;
assign writeburst_byteenable_0 =
    (cond_9 && cond_6 && cond_14)? ( write_burst_byteenable_0) :
    (cond_9 && ~cond_6 && cond_7)? ( write_burst_byteenable_0) :
    (cond_19 && cond_20 && cond_21 && cond_14)? ( write_burst_byteenable_0) :
    4'd0;
assign writeburst_byteenable_1 =
    (cond_9 && cond_6 && cond_14)? ( write_burst_byteenable_1) :
    (cond_9 && ~cond_6 && cond_7)? ( write_burst_byteenable_1) :
    (cond_19 && cond_20 && cond_21 && cond_14)? ( write_burst_byteenable_1) :
    4'd0;
assign dcachewrite_done =
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (`TRUE) :
    1'd0;
assign data_ram0_address =
    (cond_0 && ~cond_1 && cond_2)? ( { 20'd0, wbinvdread_address, 4'd0 }) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( dcachewrite_address) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? ( dcacheread_address) :
    (cond_9 && cond_6 && cond_10)? (   address) :
    (cond_19 && cond_20 && cond_21 && cond_22)? (   address) :
    (cond_19 && cond_20 && ~cond_21 && cond_22)? (   address) :
    32'd0;
assign data_ram0_data =
    (cond_9 && cond_6 && cond_10)? (      line_merged) :
    (cond_19 && cond_20 && cond_21 && cond_22)? (      line_merged) :
    (cond_19 && cond_20 && ~cond_21 && cond_22)? (      readline_line) :
    128'd0;
assign data_ram1_write_do =
    (cond_9 && cond_6 && cond_11)? (`TRUE) :
    (cond_19 && cond_20 && cond_21 && cond_23)? (`TRUE) :
    (cond_19 && cond_20 && ~cond_21 && cond_23)? (`TRUE) :
    1'd0;
assign readburst_byte_length =
    (cond_5 && ~cond_6 && cond_7)? (  read_burst_byte_length) :
    4'd0;
assign data_ram0_read_do =
    (cond_0 && ~cond_1 && cond_2)? ( wbinvdread_do) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (`TRUE) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (`TRUE) :
    1'd0;
assign data_ram2_data =
    (cond_9 && cond_6 && cond_12)? (      line_merged) :
    (cond_19 && cond_20 && cond_21 && cond_24)? (      line_merged) :
    (cond_19 && cond_20 && ~cond_21 && cond_24)? (      readline_line) :
    128'd0;
assign dcache_writeline_line =
    (cond_5 && ~cond_6 && ~cond_7 && cond_8)? (    plru_data_line[127:0]) :
    (cond_9 && ~cond_6 && ~cond_7 && cond_8)? (    plru_data_line[127:0]) :
    128'd0;
assign readline_do =
    (cond_5 && ~cond_6 && ~cond_7 && ~cond_8)? (`TRUE) :
    (cond_9 && ~cond_6 && ~cond_7 && ~cond_8)? (`TRUE) :
    (cond_17 && cond_18)? (`TRUE) :
    1'd0;
assign readline_address =
    (cond_5 && ~cond_6 && ~cond_7 && ~cond_8)? ( { address[31:4], 4'd0 }) :
    (cond_9 && ~cond_6 && ~cond_7 && ~cond_8)? ( { address[31:4], 4'd0 }) :
    (cond_17 && cond_18)? ( { address[31:4], 4'd0 }) :
    32'd0;
assign dcachetoicache_write_do =
    (cond_9 && cond_6 && ~cond_14)? (`TRUE) :
    (cond_19 && cond_20 && cond_21 && ~cond_14)? (`TRUE) :
    (cond_26 && cond_27)? (`TRUE) :
    1'd0;
assign writeburst_data =
    (cond_9 && cond_6 && cond_14)? (         write_burst_data) :
    (cond_9 && ~cond_6 && cond_7)? (         write_burst_data) :
    (cond_19 && cond_20 && cond_21 && cond_14)? (         write_burst_data) :
    56'd0;
assign readburst_address =
    (cond_5 && ~cond_6 && cond_7)? (      address) :
    32'd0;
assign readburst_dword_length =
    (cond_5 && ~cond_6 && cond_7)? ( read_burst_dword_length) :
    2'd0;
assign dcachetoicache_write_address =
    (cond_9 && cond_6 && ~cond_14)? ( address) :
    (cond_19 && cond_20 && cond_21 && ~cond_14)? ( address) :
    (cond_26 && cond_27)? ( address) :
    32'd0;
assign data_ram0_write_do =
    (cond_9 && cond_6 && cond_10)? (`TRUE) :
    (cond_19 && cond_20 && cond_21 && cond_22)? (`TRUE) :
    (cond_19 && cond_20 && ~cond_21 && cond_22)? (`TRUE) :
    1'd0;
assign dcache_writeline_address =
    (cond_5 && ~cond_6 && ~cond_7 && cond_8)? ( { plru_data_line[147:128], address[11:4], 4'd0 }) :
    (cond_9 && ~cond_6 && ~cond_7 && cond_8)? ( { plru_data_line[147:128], address[11:4], 4'd0 }) :
    32'd0;
assign data_ram2_write_do =
    (cond_9 && cond_6 && cond_12)? (`TRUE) :
    (cond_19 && cond_20 && cond_21 && cond_24)? (`TRUE) :
    (cond_19 && cond_20 && ~cond_21 && cond_24)? (`TRUE) :
    1'd0;
assign data_ram1_read_do =
    (cond_0 && ~cond_1 && cond_2)? ( wbinvdread_do) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (`TRUE) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (`TRUE) :
    1'd0;
assign data_ram3_data =
    (cond_9 && cond_6 && cond_13)? (      line_merged) :
    (cond_19 && cond_20 && cond_21 && cond_25)? (      line_merged) :
    (cond_19 && cond_20 && ~cond_21 && cond_25)? (      readline_line) :
    128'd0;
assign data_ram3_read_do =
    (cond_0 && ~cond_1 && cond_2)? ( wbinvdread_do) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (`TRUE) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (`TRUE) :
    1'd0;
assign data_ram3_address =
    (cond_0 && ~cond_1 && cond_2)? ( { 20'd0, wbinvdread_address, 4'd0 }) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( dcachewrite_address) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? ( dcacheread_address) :
    (cond_9 && cond_6 && cond_13)? (   address) :
    (cond_19 && cond_20 && cond_21 && cond_25)? (   address) :
    (cond_19 && cond_20 && ~cond_21 && cond_25)? (   address) :
    32'd0;
assign writeburst_do =
    (cond_9 && cond_6 && cond_14)? (`TRUE) :
    (cond_9 && ~cond_6 && cond_7)? (`TRUE) :
    (cond_19 && cond_20 && cond_21 && cond_14)? (`TRUE) :
    1'd0;
assign data_ram1_data =
    (cond_9 && cond_6 && cond_11)? (      line_merged) :
    (cond_19 && cond_20 && cond_21 && cond_23)? (      line_merged) :
    (cond_19 && cond_20 && ~cond_21 && cond_23)? ( readline_line) :
    128'd0;
assign dcache_writeline_do =
    (cond_5 && ~cond_6 && ~cond_7 && cond_8)? (`TRUE) :
    (cond_9 && ~cond_6 && ~cond_7 && cond_8)? (`TRUE) :
    1'd0;
assign dcacheread_done =
    (cond_5 && cond_6)? (`TRUE) :
    (cond_15 && cond_16)? (`TRUE) :
    (cond_19 && cond_20 && ~cond_21)? (`TRUE) :
    1'd0;
assign control_ram_write_do =
    (cond_5 && cond_6)? (`TRUE) :
    (cond_9 && cond_6)? (`TRUE) :
    (cond_19 && cond_20 && cond_21)? (`TRUE) :
    (cond_19 && cond_20 && ~cond_21)? (`TRUE) :
    1'd0;
assign control_ram_data =
    (cond_5 && cond_6)? (        control_after_match) :
    (cond_9 && cond_6)? (        control_after_write_to_existing) :
    (cond_19 && cond_20 && cond_21)? (        control_after_write_to_new) :
    (cond_19 && cond_20 && ~cond_21)? (        control_after_line_read) :
    11'd0;
assign writeburst_dword_length =
    (cond_9 && cond_6 && cond_14)? ( write_burst_dword_length) :
    (cond_9 && ~cond_6 && cond_7)? ( write_burst_dword_length) :
    (cond_19 && cond_20 && cond_21 && cond_14)? ( write_burst_dword_length) :
    2'd0;
assign data_ram2_address =
    (cond_0 && ~cond_1 && cond_2)? ( { 20'd0, wbinvdread_address, 4'd0 }) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( dcachewrite_address) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? ( dcacheread_address) :
    (cond_9 && cond_6 && cond_12)? (   address) :
    (cond_19 && cond_20 && cond_21 && cond_24)? (   address) :
    (cond_19 && cond_20 && ~cond_21 && cond_24)? (   address) :
    32'd0;
assign data_ram1_address =
    (cond_0 && ~cond_1 && cond_2)? ( { 20'd0, wbinvdread_address, 4'd0 }) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( dcachewrite_address) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? ( dcacheread_address) :
    (cond_9 && cond_6 && cond_11)? (   address) :
    (cond_19 && cond_20 && cond_21 && cond_23)? (   address) :
    (cond_19 && cond_20 && ~cond_21 && cond_23)? (    address) :
    32'd0;
assign data_ram2_read_do =
    (cond_0 && ~cond_1 && cond_2)? ( wbinvdread_do) :
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? (`TRUE) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (`TRUE) :
    1'd0;
assign writeburst_address =
    (cond_9 && cond_6 && cond_14)? (      address) :
    (cond_9 && ~cond_6 && cond_7)? (      address) :
    (cond_19 && cond_20 && cond_21 && cond_14)? (      address) :
    32'd0;
assign readburst_do =
    (cond_5 && ~cond_6 && cond_7)? (`TRUE) :
    1'd0;
assign control_ram_address =
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( dcachewrite_address) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (     dcacheread_address) :
    (cond_5 && cond_6)? (     address) :
    (cond_9 && cond_6)? (     address) :
    (cond_19 && cond_20 && cond_21)? (     address) :
    (cond_19 && cond_20 && ~cond_21)? (     address) :
    32'd0;
assign dcacheread_data =
    (cond_5 && cond_6)? ( read_from_line) :
    (cond_15 && cond_16)? ( read_from_burst) :
    (cond_19 && cond_20 && ~cond_21)? ( read_from_line) :
    64'd0;
