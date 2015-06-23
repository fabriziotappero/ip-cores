//======================================================== conditions
wire cond_0 = state == STATE_IDLE;
wire cond_1 = tlbflushsingle_do;
wire cond_2 = tlbflushall_do || tlbflushall_do_waiting;
wire cond_3 = ~(wr_reset) && tlbwrite_do && ~(write_ac) && cr0_am && acflag && tlbwrite_cpl == 2'd3 &&
             ( (tlbwrite_length_full == 3'd2 && tlbwrite_address[0] != 1'b0) || (tlbwrite_length_full == 3'd4 && tlbwrite_address[1:0] != 2'b00) )
    ;
wire cond_4 = ~(wr_reset) && tlbwrite_do && ~(write_pf) && ~(write_ac);
wire cond_5 = ~(exe_reset) && tlbcheck_do && ~(tlbcheck_done) && ~(check_pf);
wire cond_6 = ~(rd_reset) && tlbread_do && ~(read_ac) && cr0_am && acflag && tlbread_cpl == 2'd3 &&
             ( (tlbread_length_full == 4'd2 && tlbread_address[0] != 1'b0) || (tlbread_length_full == 4'd4 && tlbread_address[1:0] != 2'b00))
    ;
wire cond_7 = ~(rd_reset) && tlbread_do && ~(read_pf) && ~(read_ac);
wire cond_8 = ~(pr_reset) && tlbcoderequest_do && ~(code_pf) && ~(tlbcode_do);
wire cond_9 = state == STATE_WRITE_DOUBLE;
wire cond_10 = write_double_state == WRITE_DOUBLE_CHECK;
wire cond_11 = state == STATE_WRITE_WAIT;
wire cond_12 = dcachewrite_done;
wire cond_13 = state == STATE_READ_WAIT;
wire cond_14 = dcacheread_done;
wire cond_15 = state == STATE_READ_CHECK;
wire cond_16 = cr0_pg;
wire cond_17 = ~(cr0_pg) || translate_valid;
wire cond_18 = cr0_pg && fault;
wire cond_19 = state == STATE_WRITE_CHECK;
wire cond_20 = translate_valid && write_double_state != WRITE_DOUBLE_NONE;
wire cond_21 = state == STATE_CHECK_CHECK;
wire cond_22 = state == STATE_CODE_CHECK;
wire cond_23 = pr_reset || pr_reset_waiting;
wire cond_24 = state == STATE_LOAD_PDE;
wire cond_25 = dcacheread_data[0] == `FALSE;
wire cond_26 = current_type == TYPE_CODE && ~(pr_reset) && ~(pr_reset_waiting);
wire cond_27 = current_type == TYPE_CHECK;
wire cond_28 = current_type == TYPE_WRITE;
wire cond_29 = current_type == TYPE_READ;
wire cond_30 = state == STATE_LOAD_PTE_START;
wire cond_31 = state == STATE_RETRY;
wire cond_32 = state == STATE_LOAD_PTE;
wire cond_33 = dcacheread_data[0] == `FALSE || fault_before_pte;
wire cond_34 = ((current_type == TYPE_READ && ~(pipeline_after_read_empty)) || (current_type == TYPE_CODE && (~(pipeline_after_prefetch_empty) || pr_reset_waiting))) &&
                 (pde[5] == `FALSE || dcacheread_data[5] == `FALSE || (dcacheread_data[6] == `FALSE && rw));
wire cond_35 = state == STATE_LOAD_PTE_END;
wire cond_36 = pde[5] == `FALSE;
wire cond_37 = pte[5] == `FALSE || (pte[6] == `FALSE && rw);
wire cond_38 = current_type == TYPE_WRITE && write_double_state != WRITE_DOUBLE_NONE;
wire cond_39 = state == STATE_READ_WAIT_START;
wire cond_40 = state == STATE_SAVE_PDE;
wire cond_41 = state == STATE_SAVE_PTE_START;
wire cond_42 = state == STATE_WRITE_WAIT_START;
wire cond_43 = state == STATE_SAVE_PTE;
//======================================================== saves
wire [1:0] current_type_to_reg =
    (cond_15 && ~cond_17)? (   TYPE_READ) :
    (cond_19 && ~cond_17)? (   TYPE_WRITE) :
    (cond_21 && ~cond_17)? (   TYPE_CHECK) :
    (cond_22 && ~cond_23 && ~cond_17)? (   TYPE_CODE) :
    current_type;
wire  read_pf_to_reg =
    (cond_0)? (       `FALSE) :
    (cond_15 && cond_17 && cond_18)? (            `TRUE) :
    (cond_24 && cond_14 && cond_25 && ~cond_26 && ~cond_27 && ~cond_28 && cond_29)? (                `TRUE) :
    (cond_32 && cond_14 && cond_33 && ~cond_26 && ~cond_27 && ~cond_28 && cond_29)? (            `TRUE) :
    read_pf;
wire [31:0] pde_to_reg =
    (cond_24 && cond_14)? ( dcacheread_data[31:0]) :
    pde;
wire  write_pf_to_reg =
    (cond_0)? (      `FALSE) :
    (cond_19 && cond_17 && cond_18)? (                `TRUE) :
    (cond_24 && cond_14 && cond_25 && ~cond_26 && ~cond_27 && cond_28)? (               `TRUE) :
    (cond_32 && cond_14 && cond_33 && ~cond_26 && ~cond_27 && cond_28)? (               `TRUE) :
    write_pf;
wire [4:0] state_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (  STATE_WRITE_CHECK) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && cond_5)? (  STATE_CHECK_CHECK) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && ~cond_6 && cond_7)? (  STATE_READ_CHECK) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && ~cond_6 && ~cond_7 && cond_8)? (  STATE_CODE_CHECK) :
    (cond_9 && cond_10)? (              STATE_WRITE_CHECK) :
    (cond_9 && ~cond_10)? (              STATE_WRITE_CHECK) :
    (cond_11 && cond_12)? ( STATE_IDLE) :
    (cond_13 && cond_14)? ( STATE_IDLE) :
    (cond_15 && cond_17 && cond_18)? ( STATE_IDLE) :
    (cond_15 && cond_17 && ~cond_18)? ( STATE_READ_WAIT) :
    (cond_15 && ~cond_17)? (          STATE_LOAD_PDE) :
    (cond_19 && cond_17 && cond_18)? ( STATE_IDLE) :
    (cond_19 && cond_17 && ~cond_18 && cond_20)? ( STATE_WRITE_DOUBLE) :
    (cond_19 && cond_17 && ~cond_18 && ~cond_20)? ( STATE_WRITE_WAIT) :
    (cond_19 && ~cond_17)? (          STATE_LOAD_PDE) :
    (cond_21 && cond_17)? ( STATE_IDLE) :
    (cond_21 && ~cond_17)? (          STATE_LOAD_PDE) :
    (cond_22 && cond_23)? ( STATE_IDLE) :
    (cond_22 && ~cond_23 && cond_17)? ( STATE_IDLE) :
    (cond_22 && ~cond_23 && ~cond_17)? (          STATE_LOAD_PDE) :
    (cond_24 && cond_14 && cond_25)? ( STATE_IDLE) :
    (cond_24 && cond_14 && ~cond_25)? ( STATE_LOAD_PTE_START) :
    (cond_30)? ( STATE_LOAD_PTE) :
    (cond_31)? ( STATE_IDLE) :
    (cond_32 && cond_14 && cond_33)? ( STATE_IDLE) :
    (cond_32 && cond_14 && ~cond_33 && cond_34)? ( STATE_RETRY) :
    (cond_32 && cond_14 && ~cond_33 && ~cond_34)? ( STATE_LOAD_PTE_END) :
    (cond_35 && cond_36)? ( STATE_SAVE_PDE) :
    (cond_35 && ~cond_36 && cond_37)? ( STATE_SAVE_PTE) :
    (cond_35 && ~cond_36 && ~cond_37 && cond_38)? ( STATE_WRITE_DOUBLE) :
    (cond_35 && ~cond_36 && ~cond_37 && ~cond_38 && cond_28)? ( STATE_WRITE_WAIT) :
    (cond_35 && ~cond_36 && ~cond_37 && ~cond_38 && ~cond_28 && cond_29)? ( STATE_READ_WAIT_START) :
    (cond_35 && ~cond_36 && ~cond_37 && ~cond_38 && ~cond_28 && ~cond_29)? ( STATE_IDLE) :
    (cond_39)? ( STATE_READ_WAIT) :
    (cond_40 && cond_12 && cond_37)? ( STATE_SAVE_PTE_START) :
    (cond_40 && cond_12 && ~cond_37 && cond_28)? ( STATE_WRITE_WAIT_START) :
    (cond_40 && cond_12 && ~cond_37 && ~cond_28 && cond_29)? ( STATE_READ_WAIT) :
    (cond_40 && cond_12 && ~cond_37 && ~cond_28 && ~cond_29)? ( STATE_IDLE) :
    (cond_41)? ( STATE_SAVE_PTE) :
    (cond_42 && cond_38)? ( STATE_WRITE_DOUBLE) :
    (cond_42 && ~cond_38)? ( STATE_WRITE_WAIT) :
    (cond_43 && cond_12 && cond_28)? ( STATE_WRITE_WAIT_START) :
    (cond_43 && cond_12 && ~cond_28 && cond_29)? ( STATE_READ_WAIT) :
    (cond_43 && cond_12 && ~cond_28 && ~cond_29)? ( STATE_IDLE) :
    state;
wire [31:0] tlb_read_pf_cr2_to_reg =
    (cond_15 && cond_17 && cond_18)? (        linear) :
    (cond_24 && cond_14 && cond_25 && ~cond_26 && ~cond_27 && ~cond_28 && cond_29)? (        linear) :
    (cond_32 && cond_14 && cond_33 && ~cond_26 && ~cond_27 && ~cond_28 && cond_29)? (        linear) :
    tlb_read_pf_cr2;
wire [31:0] tlb_code_pf_cr2_to_reg =
    (cond_22 && ~cond_23 && cond_17 && cond_18)? (       linear) :
    (cond_24 && cond_14 && cond_25 && cond_26)? (        linear) :
    (cond_32 && cond_14 && cond_33 && cond_26)? (        linear) :
    tlb_code_pf_cr2;
wire  check_pf_to_reg =
    (cond_21 && cond_17 && cond_18)? (               `TRUE) :
    (cond_24 && cond_14 && cond_25 && ~cond_26 && cond_27)? (               `TRUE) :
    (cond_32 && cond_14 && cond_33 && ~cond_26 && cond_27)? (               `TRUE) :
    check_pf;
wire  su_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (             tlbwrite_cpl == 2'd3) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && cond_5)? (             `FALSE) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && ~cond_6 && cond_7)? (             tlbread_cpl == 2'd3) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && ~cond_6 && ~cond_7 && cond_8)? (             tlbcoderequest_su) :
    su;
wire [15:0] tlb_check_pf_error_code_to_reg =
    (cond_21 && cond_17 && cond_18)? ({ 13'd0, su, rw, `TRUE }) :
    (cond_24 && cond_14 && cond_25 && ~cond_26 && cond_27)? ({ 13'd0, su, rw, `FALSE }) :
    (cond_32 && cond_14 && cond_33 && ~cond_26 && cond_27)? ({ 13'd0, su, rw, dcacheread_data[0] }) :
    tlb_check_pf_error_code;
wire [15:0] tlb_write_pf_error_code_to_reg =
    (cond_19 && cond_17 && cond_18)? ( { 13'd0, su, rw, `TRUE }) :
    (cond_24 && cond_14 && cond_25 && ~cond_26 && ~cond_27 && cond_28)? ({ 13'd0, su, rw, `FALSE }) :
    (cond_32 && cond_14 && cond_33 && ~cond_26 && ~cond_27 && cond_28)? ({ 13'd0, su, rw, dcacheread_data[0] }) :
    tlb_write_pf_error_code;
wire [31:0] write_double_linear_to_reg =
    (cond_9 && cond_10)? ( linear) :
    write_double_linear;
wire  tlbcode_cache_disable_to_reg =
    (cond_22 && ~cond_23 && cond_17 && ~cond_18)? (   cr0_cd || translate_pcd || memtype_cache_disable) :
    tlbcode_cache_disable;
wire [31:0] linear_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? ( tlbwrite_address) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && cond_5)? ( tlbcheck_address) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && ~cond_6 && cond_7)? ( tlbread_address) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && ~cond_6 && ~cond_7 && cond_8)? ( tlbcoderequest_address) :
    (cond_9 && cond_10)? ( { linear[31:12], 12'd0 } + 32'h00001000) :
    (cond_9 && ~cond_10)? ( write_double_linear) :
    linear;
wire [15:0] tlb_code_pf_error_code_to_reg =
    (cond_22 && ~cond_23 && cond_17 && cond_18)? ({ 13'd0, su, rw, `TRUE }) :
    (cond_24 && cond_14 && cond_25 && cond_26)? ( { 13'd0, su, rw, `FALSE }) :
    (cond_32 && cond_14 && cond_33 && cond_26)? ( { 13'd0, su, rw, dcacheread_data[0] }) :
    tlb_code_pf_error_code;
wire  tlbcode_do_to_reg =
    (cond_0)? (    `FALSE) :
    (cond_22 && ~cond_23 && cond_17 && ~cond_18)? ( `TRUE) :
    tlbcode_do;
wire  wp_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (             cr0_wp) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && cond_5)? (             cr0_wp) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && ~cond_6 && cond_7)? (             cr0_wp) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && ~cond_6 && ~cond_7 && cond_8)? (             cr0_wp) :
    wp;
wire  tlbcheck_done_to_reg =
    (cond_0)? ( `FALSE) :
    (cond_21 && cond_17 && ~cond_18)? ( `TRUE) :
    tlbcheck_done;
wire [31:0] tlb_write_pf_cr2_to_reg =
    (cond_19 && cond_17 && cond_18)? (        linear) :
    (cond_24 && cond_14 && cond_25 && ~cond_26 && ~cond_27 && cond_28)? (       linear) :
    (cond_32 && cond_14 && cond_33 && ~cond_26 && ~cond_27 && cond_28)? (       linear) :
    tlb_write_pf_cr2;
wire  read_ac_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && cond_6)? ( `TRUE) :
    read_ac;
wire [31:0] pte_to_reg =
    (cond_32 && cond_14)? ( dcacheread_data[31:0]) :
    pte;
wire [31:0] tlb_check_pf_cr2_to_reg =
    (cond_21 && cond_17 && cond_18)? (       linear) :
    (cond_24 && cond_14 && cond_25 && ~cond_26 && cond_27)? (       linear) :
    (cond_32 && cond_14 && cond_33 && ~cond_26 && cond_27)? (       linear) :
    tlb_check_pf_cr2;
wire [15:0] tlb_read_pf_error_code_to_reg =
    (cond_15 && cond_17 && cond_18)? ( { 13'd0, su, rw, `TRUE }) :
    (cond_24 && cond_14 && cond_25 && ~cond_26 && ~cond_27 && ~cond_28 && cond_29)? ( { 13'd0, su, rw, `FALSE }) :
    (cond_32 && cond_14 && cond_33 && ~cond_26 && ~cond_27 && ~cond_28 && cond_29)? ( { 13'd0, su, rw, dcacheread_data[0] }) :
    tlb_read_pf_error_code;
wire [1:0] write_double_state_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? ( (cr0_pg && tlbwrite_length != tlbwrite_length_full && { 1'b0, tlbwrite_address[11:0] } + { 10'd0, tlbwrite_length_full } >= 13'h1000)? WRITE_DOUBLE_CHECK : WRITE_DOUBLE_NONE) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && cond_5)? ( WRITE_DOUBLE_NONE) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && ~cond_6 && cond_7)? ( WRITE_DOUBLE_NONE) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && ~cond_6 && ~cond_7 && cond_8)? ( WRITE_DOUBLE_NONE) :
    (cond_9 && cond_10)? ( WRITE_DOUBLE_RESTART) :
    (cond_9 && ~cond_10)? ( WRITE_DOUBLE_NONE) :
    write_double_state;
wire  write_ac_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && cond_3)? ( `TRUE) :
    write_ac;
wire [31:0] tlbcode_physical_to_reg =
    (cond_22 && ~cond_23 && cond_17 && ~cond_18)? (        memtype_physical) :
    tlbcode_physical;
wire  rw_to_reg =
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && cond_4)? (             `TRUE) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && cond_5)? (             tlbcheck_rw) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && ~cond_6 && cond_7)? (             tlbread_rmw) :
    (cond_0 && ~cond_1 && ~cond_2 && ~cond_3 && ~cond_4 && ~cond_5 && ~cond_6 && ~cond_7 && cond_8)? (             `FALSE) :
    rw;
wire  code_pf_to_reg =
    (cond_22 && ~cond_23 && cond_17 && cond_18)? (                `TRUE) :
    (cond_24 && cond_14 && cond_25 && cond_26)? (                `TRUE) :
    (cond_32 && cond_14 && cond_33 && cond_26)? (                `TRUE) :
    code_pf;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) current_type <= 2'd0;
    else              current_type <= current_type_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) pde <= 32'd0;
    else              pde <= pde_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) state <= 5'd0;
    else              state <= state_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) tlb_read_pf_cr2 <= 32'd0;
    else              tlb_read_pf_cr2 <= tlb_read_pf_cr2_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) tlb_code_pf_cr2 <= 32'd0;
    else              tlb_code_pf_cr2 <= tlb_code_pf_cr2_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) su <= 1'd0;
    else              su <= su_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) tlb_check_pf_error_code <= 16'd0;
    else              tlb_check_pf_error_code <= tlb_check_pf_error_code_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) tlb_write_pf_error_code <= 16'd0;
    else              tlb_write_pf_error_code <= tlb_write_pf_error_code_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) write_double_linear <= 32'd0;
    else              write_double_linear <= write_double_linear_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) tlbcode_cache_disable <= 1'd0;
    else              tlbcode_cache_disable <= tlbcode_cache_disable_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) linear <= 32'd0;
    else              linear <= linear_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) tlb_code_pf_error_code <= 16'd0;
    else              tlb_code_pf_error_code <= tlb_code_pf_error_code_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) tlbcode_do <= 1'd0;
    else              tlbcode_do <= tlbcode_do_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wp <= 1'd0;
    else              wp <= wp_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) tlbcheck_done <= 1'd0;
    else              tlbcheck_done <= tlbcheck_done_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) tlb_write_pf_cr2 <= 32'd0;
    else              tlb_write_pf_cr2 <= tlb_write_pf_cr2_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) pte <= 32'd0;
    else              pte <= pte_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) tlb_check_pf_cr2 <= 32'd0;
    else              tlb_check_pf_cr2 <= tlb_check_pf_cr2_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) tlb_read_pf_error_code <= 16'd0;
    else              tlb_read_pf_error_code <= tlb_read_pf_error_code_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) write_double_state <= 2'd0;
    else              write_double_state <= write_double_state_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) tlbcode_physical <= 32'd0;
    else              tlbcode_physical <= tlbcode_physical_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) rw <= 1'd0;
    else              rw <= rw_to_reg;
end
//======================================================== sets
assign dcachewrite_do =
    (cond_19 && cond_17 && ~cond_18 && ~cond_20)? (`TRUE) :
    (cond_35 && cond_36)? (`TRUE) :
    (cond_35 && ~cond_36 && cond_37)? (`TRUE) :
    (cond_35 && ~cond_36 && ~cond_37 && ~cond_38 && cond_28)? (`TRUE) :
    (cond_41)? (`TRUE) :
    (cond_42 && ~cond_38)? (`TRUE) :
    1'd0;
assign dcacheread_length =
    (cond_15 && cond_17 && ~cond_18)? (           tlbread_length) :
    (cond_15 && ~cond_17)? (           4'd4) :
    (cond_19 && ~cond_17)? (           4'd4) :
    (cond_21 && ~cond_17)? (           4'd4) :
    (cond_22 && ~cond_23 && ~cond_17)? (           4'd4) :
    (cond_30)? (           4'd4) :
    (cond_39)? (           tlbread_length) :
    (cond_40 && cond_12 && ~cond_37 && ~cond_28 && cond_29)? (           tlbread_length) :
    (cond_43 && cond_12 && ~cond_28 && cond_29)? (           tlbread_length) :
    4'd0;
assign tlbregs_tlbflushall_do =
    (cond_0 && ~cond_1 && cond_2)? (`TRUE) :
    1'd0;
assign dcachewrite_length =
    (cond_19 && cond_17 && ~cond_18 && ~cond_20)? (          tlbwrite_length) :
    (cond_35 && cond_36)? (          3'd4) :
    (cond_35 && ~cond_36 && cond_37)? (          3'd4) :
    (cond_35 && ~cond_36 && ~cond_37 && ~cond_38 && cond_28)? (          tlbwrite_length) :
    (cond_41)? (          3'd4) :
    (cond_42 && ~cond_38)? (          tlbwrite_length) :
    3'd0;
assign tlbregs_write_combined_rw =
    (cond_35)? (   rw_entry) :
    1'd0;
assign tlbregs_write_pcd =
    (cond_35)? (           pte[4]) :
    1'd0;
assign tlbwrite_done =
    (cond_11 && cond_12)? (`TRUE) :
    1'd0;
assign tlbread_retry =
    (cond_31)? ( current_type == TYPE_READ) :
    1'd0;
assign dcachewrite_address =
    (cond_19 && cond_17 && ~cond_18 && ~cond_20)? (         memtype_physical) :
    (cond_35 && cond_36)? (         memtype_physical) :
    (cond_35 && ~cond_36 && cond_37)? (         memtype_physical) :
    (cond_35 && ~cond_36 && ~cond_37 && ~cond_38 && cond_28)? (         memtype_physical) :
    (cond_41)? (         memtype_physical) :
    (cond_42 && ~cond_38)? (         memtype_physical) :
    32'd0;
assign tlbregs_write_pwt =
    (cond_35)? (           pte[3]) :
    1'd0;
assign tlbregs_write_linear =
    (cond_35)? (        linear) :
    32'd0;
assign tlbread_done =
    (cond_13 && cond_14)? (`TRUE) :
    1'd0;
assign dcachewrite_data =
    (cond_19 && cond_17 && ~cond_18 && ~cond_20)? (            tlbwrite_data) :
    (cond_35 && cond_36)? (            pde | 32'h00000020) :
    (cond_35 && ~cond_36 && cond_37)? (            pte[31:0] | 32'h00000020 | ((pte[6] == `FALSE && rw)? 32'h00000040 : 32'h00000000)) :
    (cond_35 && ~cond_36 && ~cond_37 && ~cond_38 && cond_28)? (            tlbwrite_data) :
    (cond_41)? (            pte[31:0] | 32'h00000020 | ((pte[6] == `FALSE && rw)? 32'h00000040 : 32'h00000000)) :
    (cond_42 && ~cond_38)? (            tlbwrite_data) :
    32'd0;
assign tlbregs_tlbflushsingle_do =
    (cond_0 && cond_1)? (`TRUE) :
    1'd0;
assign translate_do =
    (cond_15 && cond_16)? (`TRUE) :
    (cond_19 && cond_16)? (`TRUE) :
    (cond_21 && cond_16)? (`TRUE) :
    (cond_22 && cond_16)? (`TRUE) :
    1'd0;
assign tlbregs_write_physical =
    (cond_35)? (      { pte[31:12], linear[11:0] }) :
    32'd0;
assign tlbregs_write_do =
    (cond_35)? (`TRUE) :
    1'd0;
assign tlbflushsingle_done =
    (cond_0 && cond_1)? (`TRUE) :
    1'd0;
assign dcachewrite_write_through =
    (cond_19 && cond_17 && ~cond_18 && ~cond_20)? (   cr0_nw || translate_pwt || memtype_write_transparent) :
    (cond_35 && cond_36)? (   cr0_nw || cr3_pwt || memtype_write_transparent) :
    (cond_35 && ~cond_36 && cond_37)? (   cr0_nw || pde[3] || memtype_write_transparent) :
    (cond_35 && ~cond_36 && ~cond_37 && ~cond_38 && cond_28)? (   cr0_nw || pte[3] || memtype_write_transparent) :
    (cond_41)? (   cr0_nw || pde[3] || memtype_write_transparent) :
    (cond_42 && ~cond_38)? (   cr0_nw || pte[3] || memtype_write_transparent) :
    1'd0;
assign dcacheread_address =
    (cond_15 && cond_17 && ~cond_18)? (          memtype_physical) :
    (cond_15 && ~cond_17)? (          memtype_physical) :
    (cond_19 && ~cond_17)? (          memtype_physical) :
    (cond_21 && ~cond_17)? (          memtype_physical) :
    (cond_22 && ~cond_23 && ~cond_17)? (          memtype_physical) :
    (cond_30)? (          memtype_physical) :
    (cond_39)? (          memtype_physical) :
    (cond_40 && cond_12 && ~cond_37 && ~cond_28 && cond_29)? (          memtype_physical) :
    (cond_43 && cond_12 && ~cond_28 && cond_29)? (          memtype_physical) :
    32'd0;
assign dcachewrite_cache_disable =
    (cond_19 && cond_17 && ~cond_18 && ~cond_20)? (   cr0_cd || translate_pcd || memtype_cache_disable) :
    (cond_35 && cond_36)? (   cr0_cd || cr3_pcd || memtype_cache_disable) :
    (cond_35 && ~cond_36 && cond_37)? (   cr0_cd || pde[4] || memtype_cache_disable) :
    (cond_35 && ~cond_36 && ~cond_37 && ~cond_38 && cond_28)? (   cr0_cd || pte[4] || memtype_cache_disable) :
    (cond_41)? (   cr0_cd || pde[4] || memtype_cache_disable) :
    (cond_42 && ~cond_38)? (   cr0_cd || pte[4] || memtype_cache_disable) :
    1'd0;
assign tlbregs_write_combined_su =
    (cond_35)? (   su_entry) :
    1'd0;
assign dcacheread_do =
    (cond_15 && cond_17 && ~cond_18)? (`TRUE) :
    (cond_15 && ~cond_17)? (`TRUE) :
    (cond_19 && ~cond_17)? (`TRUE) :
    (cond_21 && ~cond_17)? (`TRUE) :
    (cond_22 && ~cond_23 && ~cond_17)? (`TRUE) :
    (cond_30)? (`TRUE) :
    (cond_39)? (`TRUE) :
    (cond_40 && cond_12 && ~cond_37 && ~cond_28 && cond_29)? (`TRUE) :
    (cond_43 && cond_12 && ~cond_28 && cond_29)? (`TRUE) :
    1'd0;
assign memtype_physical =
    (cond_15 && cond_17 && ~cond_18)? ( translate_physical) :
    (cond_15 && ~cond_17)? ( { cr3_base[31:12], linear[31:22], 2'd0 }) :
    (cond_19 && cond_17 && ~cond_18 && ~cond_20)? ( translate_physical) :
    (cond_19 && ~cond_17)? ( { cr3_base[31:12], linear[31:22], 2'd0 }) :
    (cond_21 && ~cond_17)? ( { cr3_base[31:12], linear[31:22], 2'd0 }) :
    (cond_22 && ~cond_23 && cond_17 && ~cond_18)? ( translate_physical) :
    (cond_22 && ~cond_23 && ~cond_17)? ( { cr3_base[31:12], linear[31:22], 2'd0 }) :
    (cond_30)? ( { pde[31:12], linear[21:12], 2'd0 }) :
    (cond_35 && cond_36)? ( { cr3_base[31:12], linear[31:22], 2'd0 }) :
    (cond_35 && ~cond_36 && cond_37)? ( { pde[31:12], linear[21:12], 2'b00 }) :
    (cond_35 && ~cond_36 && ~cond_37 && ~cond_38 && cond_28)? ( { pte[31:12], linear[11:0] }) :
    (cond_39)? ( { pte[31:12], linear[11:0] }) :
    (cond_40 && cond_12 && ~cond_37 && ~cond_28 && cond_29)? ( { pte[31:12], linear[11:0] }) :
    (cond_41)? ( { pde[31:12], linear[21:12], 2'b00 }) :
    (cond_42 && ~cond_38)? ( { pte[31:12], linear[11:0] }) :
    (cond_43 && cond_12 && ~cond_28 && cond_29)? ( { pte[31:12], linear[11:0] }) :
    32'd0;
assign prefetchfifo_signal_pf_do =
    (cond_22 && ~cond_23 && cond_17 && cond_18)? (`TRUE) :
    (cond_24 && cond_14 && cond_25 && cond_26)? (`TRUE) :
    (cond_32 && cond_14 && cond_33 && cond_26)? (`TRUE) :
    1'd0;
assign dcacheread_cache_disable =
    (cond_15 && cond_17 && ~cond_18)? (    cr0_cd || translate_pcd || memtype_cache_disable) :
    (cond_15 && ~cond_17)? (    cr0_cd || cr3_pcd || memtype_cache_disable) :
    (cond_19 && ~cond_17)? (    cr0_cd || cr3_pcd || memtype_cache_disable) :
    (cond_21 && ~cond_17)? (    cr0_cd || cr3_pcd || memtype_cache_disable) :
    (cond_22 && ~cond_23 && ~cond_17)? (    cr0_cd || cr3_pcd || memtype_cache_disable) :
    (cond_30)? (    cr0_cd || pde[4] || memtype_cache_disable) :
    (cond_39)? (    cr0_cd || pte[4] || memtype_cache_disable) :
    (cond_40 && cond_12 && ~cond_37 && ~cond_28 && cond_29)? (    cr0_cd || pte[4] || memtype_cache_disable) :
    (cond_43 && cond_12 && ~cond_28 && cond_29)? (    cr0_cd || pte[4] || memtype_cache_disable) :
    1'd0;
