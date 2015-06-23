//======================================================== conditions
wire cond_0 = exception_init || wr_debug_init;
wire cond_1 = ~(class_trap) && ~(class_abort);
wire cond_2 = wr_is_esp_speculative;
wire cond_3 = vector != `EXCEPTION_DB;
wire cond_4 = vector == `EXCEPTION_DB;
wire cond_5 = wr_debug_init && ~(wr_string_in_progress_final);
wire cond_6 = wr_debug_init && wr_string_in_progress_final;
wire cond_7 = shutdown_start == `FALSE && count > 2'd0 && exception_type != `EXCEPTION_TYPE_DOUBLE_FAULT && (
        (last_type == `EXCEPTION_TYPE_CONTRIBUTORY && exception_type == `EXCEPTION_TYPE_CONTRIBUTORY) ||
        (last_type == `EXCEPTION_TYPE_PAGE_FAULT   && exception_type == `EXCEPTION_TYPE_CONTRIBUTORY) ||
        (last_type == `EXCEPTION_TYPE_PAGE_FAULT   && exception_type == `EXCEPTION_TYPE_PAGE_FAULT));
wire cond_8 = shutdown_start == `FALSE;
wire cond_9 = shutdown_start;
wire cond_10 = shutdown;
wire cond_11 = interrupt_done;
//======================================================== saves
wire  exc_soft_int_to_reg =
    (cond_0 && ~cond_7 && cond_8)? (    `FALSE) :
    (cond_11)? (    `FALSE) :
    exc_soft_int;
wire  exc_push_error_to_reg =
    (cond_0 && ~cond_7 && cond_8)? ( push_error) :
    (cond_11)? ( `FALSE) :
    exc_push_error;
wire [1:0] count_to_reg =
    (cond_0 && ~cond_7 && cond_8)? (     count + 2'd1) :
    count;
wire [31:0] exc_eip_to_reg =
    (cond_0 && ~cond_1)? ( trap_eip) :
    (cond_0 && cond_4 && cond_5)? ( wr_eip) :
    (cond_0 && cond_4 && cond_6)? ( exception_eip_from_wr) :
    (cond_11)? ( (interrupt_string_in_progress)? exception_eip_from_wr : wr_eip) :
    exc_eip;
wire  external_to_reg =
    (cond_0)? ( `TRUE) :
    (cond_11)? ( `TRUE) :
    external;
wire [1:0] last_type_to_reg =
    (cond_0 && ~cond_7 && cond_8)? ( exception_type) :
    last_type;
wire [8:0] exc_vector_full_to_reg =
    (cond_0 && cond_7)? ( { 1'b1, `EXCEPTION_DF }) :
    (cond_0 && ~cond_7 && cond_8)? ( { 1'b0, vector }) :
    (cond_0 && cond_9)? ( { 1'b0, vector }) :
    (cond_11)? ( { 1'b0, interrupt_vector }) :
    exc_vector_full;
wire [15:0] exc_error_code_to_reg =
    (cond_0 && cond_7)? ( 16'd0) :
    (cond_0 && ~cond_7 && cond_8)? ( error_code) :
    (cond_11)? ( 16'd0) :
    exc_error_code;
wire  exc_soft_int_ib_to_reg =
    (cond_0 && ~cond_7 && cond_8)? ( `FALSE) :
    (cond_11)? ( `FALSE) :
    exc_soft_int_ib;
wire  shutdown_to_reg =
    (cond_0 && cond_9)? ( `TRUE) :
    shutdown;
//======================================================== always
//======================================================== sets
assign exc_set_rflag =
    (cond_0 && cond_1 && cond_3)? (`TRUE) :
    1'd0;
assign exc_dec_reset =
    (cond_0)? (`TRUE) :
    (cond_10)? (`TRUE) :
    (cond_11)? (`TRUE) :
    1'd0;
assign exc_restore_esp =
    (cond_0 && cond_1 && cond_2)? (`TRUE) :
    1'd0;
assign exc_micro_reset =
    (cond_0)? (`TRUE) :
    (cond_10)? (`TRUE) :
    (cond_11)? (`TRUE) :
    1'd0;
assign exc_wr_reset =
    (cond_0)? (`TRUE) :
    (cond_10)? (`TRUE) :
    (cond_11)? (`TRUE) :
    1'd0;
assign exc_rd_reset =
    (cond_0)? (`TRUE) :
    (cond_10)? (`TRUE) :
    (cond_11)? (`TRUE) :
    1'd0;
assign exc_exe_reset =
    (cond_0)? (`TRUE) :
    (cond_10)? (`TRUE) :
    (cond_11)? (`TRUE) :
    1'd0;
assign exception_start =
    (cond_0 && ~cond_7 && cond_8)? (`TRUE) :
    1'd0;
