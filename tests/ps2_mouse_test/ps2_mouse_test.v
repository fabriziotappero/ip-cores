module ps2_mouse_test(
    input clk_50,
    input reset_ext_n,
    
    inout ps2_mouseclk,
    inout ps2_mousedat,
    
    output [7:0] debug,
    output [7:0] debug2
);

wire CLK_I;
wire pll_locked;

altpll pll_inst(
    .inclk( {1'b0, clk_50} ),
    .clk( CLK_I ), //{5'b0, clk_30} ),
    .locked(pll_locked)
);
defparam    pll_inst.clk0_divide_by = 5,
            pll_inst.clk0_duty_cycle = 50,
            pll_inst.clk0_multiply_by = 3,
            pll_inst.clk0_phase_shift = "0",
            pll_inst.compensate_clock = "CLK0",
            pll_inst.gate_lock_counter = 1048575,
            pll_inst.gate_lock_signal = "YES",
            pll_inst.inclk0_input_frequency = 20000,
            pll_inst.intended_device_family = "Cyclone II",
            pll_inst.invalid_lock_multiplier = 5,
            pll_inst.lpm_hint = "CBX_MODULE_PREFIX=pll30",
            pll_inst.lpm_type = "altpll",
            pll_inst.operation_mode = "NORMAL",
            pll_inst.valid_lock_multiplier = 1;

wire reset_n;
assign reset_n = pll_locked & reset_ext_n;

assign debug = send_counter[7:0];
assign debug2 = ctrl_counter[7:0];

// ----------------------------------------------------------------------------- PS/2 mouse
assign ps2_mouseclk = (send_counter >= 12'd1 && send_counter < 12'd4000) ? 1'b0 : 1'bZ;
assign ps2_mousedat = (send_counter >= 12'd4000 && send_counter <= 12'd4009) ? send_shift[0] : 1'bZ;

reg [15:0] mv;
reg mv_wait;
reg was_ps2_mouseclk;
always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        mv                  <= 16'd0;
        mv_wait             <= 1'b0;
        was_ps2_mouseclk    <= 1'b0;
    end
    else begin
        mv <= { mv[14:0], ps2_mouseclk };
    
        if(mv_wait == 1'b0 && mv[15:12] == 4'b1111 && mv[3:0] == 4'b0000) begin
            was_ps2_mouseclk <= 1'b1;
            mv_wait <= 1'b1;
        end
        else if(mv_wait == 1'b1 && mv[15:0] == 16'h0000) begin
            mv_wait <= 1'b0;
            was_ps2_mouseclk <= 1'b0;
        end
        else begin
            was_ps2_mouseclk <= 1'b0;
        end
    end
end

reg [11:0] send_counter;
reg [9:0] send_shift;
always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        send_counter    <= 12'd0;
        send_shift      <= 10'd0;
    end
    else if(send_start == 1'b1) begin
        send_counter <= 12'd1;
        send_shift <= send_contents;
    end
    else if(send_counter > 12'd0 && send_counter < 12'd4000) begin
        send_counter <= send_counter + 12'd1;
    end
    else if(send_counter >= 12'd4000 && send_counter <= 12'd4009 && was_ps2_mouseclk == 1'b1) begin
        send_counter <= send_counter + 12'd1;
        if(send_counter <= 12'd4007) begin
            send_shift <= { send_shift[9] ^ send_shift[0], 1'b0, send_shift[8:1] };
        end
        else if(send_counter == 12'd4008) begin
            send_shift <= { 9'd0, send_shift[9] ^ send_shift[0] };
        end
    end
    else if(send_counter == 12'd4010 && was_ps2_mouseclk == 1'b1) begin
        if(ps2_mousedat == 1'b0) send_counter <= send_counter + 12'd1;
    end
    else if(send_counter == 12'd4011 && ps2_mouseclk == 1'b1 && ps2_mousedat == 1'b1) begin
        send_counter <= 12'd0;
    end
end

reg send_start;
reg [9:0] send_contents;
reg [23:0] ctrl_counter;
always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        send_start      <= 1'b0;
        send_contents   <= 10'd0;
        ctrl_counter    <= 24'd0;
    end
    else if(ctrl_counter < 24'hFFFFF0) begin
        ctrl_counter <= ctrl_counter + 16'd1;
    end
    else if(ctrl_counter == 24'hFFFFF0) begin
        send_contents <= { 1'b1, 8'hF4, 1'b0 };
        send_start <= 1'b1;
        ctrl_counter <= ctrl_counter + 24'd1;
    end
    else if(ctrl_counter == 24'hFFFFF1) begin
        send_start <= 1'b0;
        ctrl_counter <= ctrl_counter + 24'd1;
    end
    else if(ctrl_counter == 24'hFFFFF2 && send_counter == 12'd0) begin
        ctrl_counter <= ctrl_counter + 24'd1;
    end
    else if(ctrl_counter == 24'hFFFFF3 && new_ps2 == 1'b1 && mousedat[8:1] == 8'hFA) begin
        ctrl_counter <= 24'hFFFFFF;
    end
    else if(ctrl_counter == 24'hFFFFFF && (mousedat_timeout == 24'hFFFFFF || movement_timeout == 24'hFFFFFF)) begin
        ctrl_counter <= 24'h0;
    end
end

wire new_ps2;
assign new_ps2 = (was_ps2_mouseclk == 1'b1 && mousedat_counter == 4'd10 && mousedat[0] == 1'b0 && ps2_mousedat == 1'b1 && mousedat_parity == 1'b1);

reg [9:0] mousedat;
reg [3:0] mousedat_counter;
reg [23:0] mousedat_timeout;
reg mousedat_parity;

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        mousedat            <= 10'd0;
        mousedat_counter    <= 4'd0;
        mousedat_parity     <= 1'b0;
        mousedat_timeout    <= 24'd0;
    end
    else if(ctrl_counter >= 24'hFFFFF3 && mousedat_timeout != 24'hFFFFFF) begin
    
        if(mousedat_counter != 4'd0)        mousedat_timeout <= mousedat_timeout + 24'd1;
        else if(mousedat_counter == 4'd0)   mousedat_timeout <= 24'd0;
        
        if(was_ps2_mouseclk == 1'b1) begin
            mousedat <= { ps2_mousedat, mousedat[9:1] };
            
            if(mousedat_counter == 4'd10) begin
                mousedat_counter <= 4'd0;
            end
            else begin
                mousedat_counter <= mousedat_counter + 4'd1;
                if(mousedat_counter == 4'd0)   mousedat_parity <= 1'b0;
                else if(ps2_mousedat == 1'b1)  mousedat_parity <= ~mousedat_parity;
            end
        end
    end
    else begin
        mousedat            <= 10'd0;
        mousedat_counter    <= 4'd0;
        mousedat_parity     <= 1'b0;
        mousedat_timeout    <= 24'd0;
    end
end

//assign mouse_y_move = (movement[23] == 1'b0)? { movement[21], movement[7:0] }  : 9'd0;
//assign mouse_x_move = (movement[22] == 1'b0)? { movement[20], movement[15:8] }  : 9'd0;
//assign mouse_left_button    = movement[16];
//assign mouse_right_button   = movement[17];
//assign mouse_middle_button  = movement[18];

reg mouse_moved;

reg [1:0] movement_counter;
reg [23:0] movement;
reg [23:0] movement_timeout;

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        movement_counter    <= 2'd0;
        movement            <= 24'd0;
        mouse_moved         <= 1'b0;
        movement_timeout    <= 24'd0;
    end
    else if(ctrl_counter == 24'hFFFFFF && movement_timeout != 24'hFFFFFF) begin
        
        if(movement_counter != 4'd0)        movement_timeout <= movement_timeout + 24'd1;
        else if(movement_counter == 4'd0)   movement_timeout <= 24'd0;
        
        if(mouse_moved == 1'b1) mouse_moved <= 1'b0;
        
        if(new_ps2 == 1'b1) begin
            movement <= { movement[15:0], mousedat[8:1] };
            if(movement_counter == 2'd2) begin
                movement_counter <= 2'd0;
                
                if(movement[11] == 1'b1)    mouse_moved <= 1'b1;
                else                        movement_timeout <= 24'hFFFFFF;
            end
            else movement_counter <= movement_counter + 2'd1;
        end
    end
    else begin
        movement_counter    <= 2'd0;
        movement            <= 24'd0;
        mouse_moved         <= 1'b0;
        movement_timeout    <= 24'd0;
    end
end
// ----------------------------------------------------------------------------- PS/2 mouse END

wire write_ena;
assign write_ena = (mouse_moved == 1'b1); //(was_ps2_mouseclk == 1'b1 && ctrl_counter >= 24'hFFFF00 && (ctrl_counter[3:0] == 4'h3 || ctrl_counter[3:0] == 4'h4));

reg [7:0] debug_addr;
always @(posedge CLK_I) if(write_ena && debug_addr < 8'd255) debug_addr <= debug_addr + 8'd1;

altsyncram debug_ram_inst(
    .clock0(CLK_I),
    .wren_a(write_ena),
    .address_a(debug_addr),
    .data_a( movement )
);
defparam debug_ram_inst.operation_mode = "SINGLE_PORT";
defparam debug_ram_inst.width_a = 24;
defparam debug_ram_inst.widthad_a = 8;
defparam debug_ram_inst.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=mouse";

endmodule
