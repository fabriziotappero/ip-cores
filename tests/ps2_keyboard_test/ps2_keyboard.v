module ps2_keyboard(
	input clk_50,
	input reset_ext_n,
	
	inout ps2_kbclk,
	inout ps2_kbdat,
	
	output [7:0] leds
);

assign leds = {pressed, amiga_keycode[7], 2'b00, amiga_avail };

wire clk_30;
wire pll_locked;

altpll pll_inst(
    .inclk( {1'b0, clk_50} ),
    .clk( clk_30 ), //{5'b0, clk_30} ),
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

assign ps2_kbclk = 1'bZ;
assign ps2_kbdat = 1'bZ;

reg [15:0] mv;
reg mv_wait;
reg was_ps2_kbclk;
always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        mv              <= 16'd0;
        mv_wait         <= 1'b0;
        was_ps2_kbclk   <= 1'b0;
    end
    else begin
        mv <= { mv[14:0], ps2_kbclk };
    
        if(mv_wait == 1'b0 && mv[15:12] == 4'b1111 && mv[3:0] == 4'b0000) begin
            was_ps2_kbclk <= 1'b1;
            mv_wait <= 1'b1;
        end
        else if(mv_wait == 1'b1 && mv[15:0] == 16'h0000) begin
            mv_wait <= 1'b0;
            was_ps2_kbclk <= 1'b0;
        end
        else begin
            was_ps2_kbclk <= 1'b0;
        end
    end
end

/* mouse
reg [12:0] send_counter;
reg [9:0] send_shift;

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        send_counter    <= 13'd0;
        send_shift      <= 10'd0;
    end
    else if(send_start == 1'b1) begin
        send_counter <= 13'd1;
        send_shift <= send_contents;
    end
    else if(send_counter > 13'd0 && send_counter < 13'd8100) begin
        send_counter <= send_counter + 13'd1;
    end
    else if(send_counter >= 13'd8100 && send_counter <= 13'd8109 && was_ps2_kbclk == 1'b1) begin
        send_counter <= send_counter + 13'd1;
        if(send_counter <= 13'd8107) begin
            send_shift <= { send_shift[9] ^ send_shift[0], 1'b0, send_shift[8:1] };
        end
        else if(send_counter == 13'd8108) begin
            send_shift <= { 9'd0, send_shift[9] ^ send_shift[0] };
        end
    end
    else if(send_counter == 13'd8110 && was_ps2_kbclk == 1'b1) begin
        if(ps2_kbdat == 1'b0) send_counter <= send_counter + 13'd1;
    end
    else if(send_counter == 13'd8111 && ps2_kbclk == 1'b1 && ps2_kbdat == 1'b1) begin
        send_counter <= 13'd0;
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
    else if(ctrl_counter == 24'hFFFFFC) begin
        send_start <= 1'b1;
        ctrl_counter <= ctrl_counter + 16'd1;
        send_contents <= { 1'b0, 8'hF4, 1'b0 };
    end
    else if(ctrl_counter == 24'hFFFFFD) begin
        send_start <= 1'b0;
        ctrl_counter <= ctrl_counter + 16'd1;
    end
    else if(ctrl_counter == 24'hFFFFFE) begin
        if(send_counter == 13'd0) ctrl_counter <= ctrl_counter + 16'd1;
    end
    else if(ctrl_counter < 24'hFFFFFC) begin
        ctrl_counter <= ctrl_counter + 16'd1;
    end
end
*/

wire new_ps2;
assign new_ps2 = (was_ps2_kbclk == 1'b1 && kbdat_counter == 4'd10 && kbdat[0] == 1'b0 && ps2_kbdat == 1'b1 && kbdat_parity == 1'b1);

reg [9:0] kbdat;
reg [3:0] kbdat_counter;
reg [23:0] timeout;
reg kbdat_parity;

always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        kbdat           <= 10'd0;
        kbdat_counter   <= 4'd0;
        kbdat_parity    <= 1'b0;
        timeout         <= 24'd0;
    end
    else begin
    
        if(kbdat_counter != 4'd0 && timeout != 24'hFFFFFF)  timeout <= timeout + 24'd1;
        else if(kbdat_counter == 4'd0)                      timeout <= 24'd0;
        
        if(was_ps2_kbclk == 1'b1) begin
            kbdat <= { ps2_kbdat, kbdat[9:1] };
            
            if(kbdat_counter == 4'd10) begin
                kbdat_counter <= 4'd0;
            end
            else begin
                kbdat_counter <= kbdat_counter + 4'd1;
                if(kbdat_counter == 4'd0)   kbdat_parity <= 1'b0;
                else if(ps2_kbdat == 1'b1)  kbdat_parity <= !kbdat_parity;
            end
        end
        else if(timeout == 24'hFFFFFF) begin
            kbdat_counter <= 4'd0;
        end
    end
end
/*
reg [9:0] debug_addr;
always @(posedge clk_30) if(new_ps2 == 1'b1) debug_addr <= debug_addr + 10'd1;

altsyncram debug_ram_inst(
    .clock0(clk_30),
    .wren_a(new_ps2 == 1'b1),
    .address_a(debug_addr),
    .data_a(kbdat[8:1])
);
defparam debug_ram_inst.operation_mode = "SINGLE_PORT";
defparam debug_ram_inst.width_a = 8;
defparam debug_ram_inst.widthad_a = 10;
defparam debug_ram_inst.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=kb";
*/

reg [3:0] debug_addr2;
always @(posedge clk_30) if(last_amiga_new == 1'b1) debug_addr2 <= debug_addr2 + 4'd1;
reg last_amiga_new;
always @(posedge clk_30) last_amiga_new <= amiga_new;

altsyncram debug_ram_inst(
    .clock0(clk_30),
    .wren_a(last_amiga_new == 1'b1),
    .address_a(debug_addr2),
    .data_a(amiga_keycodes)
);
defparam debug_ram_inst.operation_mode = "SINGLE_PORT";
defparam debug_ram_inst.width_a = 96;
defparam debug_ram_inst.widthad_a = 4;
defparam debug_ram_inst.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=kb";




wire pressed;
altsyncram pressed_code_inst(
    .clock0(clk_30),

    .address_a(amiga_keycode[6:0]),
    .wren_a(new_ps2 == 1'b0 && amiga_new == 1'b1 && delay == 1'b1),
    .data_a(amiga_keycode[7] == 1'b0),
    .q_a(pressed)
);
defparam 
    pressed_code_inst.operation_mode = "SINGLE_PORT",
    pressed_code_inst.width_a = 1,
    pressed_code_inst.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=kbpress",
    pressed_code_inst.widthad_a = 7;


reg [95:0]  amiga_keycodes;
reg [3:0]   amiga_avail;
reg [7:0]   amiga_keycode;
reg         amiga_new;
reg         caps_lock;
reg         delay;

reg [2:0]   state;
parameter [2:0]
    S_FIRST             = 3'd0,
    S_E0                = 3'd1,
    S_E0_12             = 3'd2,
    S_E0_12_E0          = 3'd3,
    S_E0_F0_7C          = 3'd4,
    S_E0_F0_7C_E0       = 3'd5,
    S_E0_F0_7C_E0_F0    = 3'd6;
    
always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        amiga_keycodes      <= { 8'hFD, 8'hFE, 80'h0 };
        amiga_avail         <= 4'd2;
        
        amiga_new           <= 1'b0;
        amiga_keycode       <= 8'd0;
        caps_lock           <= 1'b0;
        delay               <= 1'b0;
        state               <= S_FIRST;
    end
    else begin

        if(new_ps2 == 1'b1) begin
            delay <= 1'b0;
            
            if(state == S_FIRST) begin
                if(kbdat[8:1] == 8'hF0 && amiga_keycode[7] == 1'b0) begin
                    amiga_keycode[7] <= 1'b1;
                end
                else if(kbdat[8:1] == 8'hE0) begin
                    state <= S_E0;
                end
                else if(kbdat[8:1] == 8'h58) begin
                    { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_CAPS };
                    
                    if(caps_lock == 1'b0 && amiga_keycode[7] == 1'b1) begin
                        amiga_keycode[7] <= 1'b0;
                        caps_lock <= 1'b1;
                    end
                    else if(caps_lock == 1'b1 && amiga_keycode[7] == 1'b0) begin
                        amiga_keycode[7] <= 1'b1;
                    end
                    else if(caps_lock == 1'b1 && amiga_keycode[7] == 1'b1) begin
                        caps_lock <= 1'b0;
                    end
                end
                else begin
                    case(kbdat[8:1])
                        8'h76:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_ESC };
                        8'h05:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_F1 };
                        8'h06:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_F2 };
                        8'h04:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_F3 };
                        8'h0C:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_F4 };
                        8'h03:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_F5 };
                        8'h0B:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_F6 };
                        8'h83:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_F7 };
                        8'h0A:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_F8 };
                        8'h01:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_F9 };
                        8'h09:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_F10 };
                        8'h78:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_LAMIGA }; //F11
                        8'h07:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_RAMIGA }; //F12
                        8'h0E:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_APO };
                        8'h16:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_1 };
                        8'h1E:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_2 };
                        8'h26:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_3 };
                        8'h25:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_4 };
                        8'h2E:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_5 };
                        8'h36:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_6 };
                        8'h3D:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_7 };
                        8'h3E:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_8 };
                        8'h46:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_9 };
                        8'h45:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_0 };
                        8'h4E:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_MIN };
                        8'h55:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_EQL };
                        8'h5D:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_BSLA };
                        8'h66:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_BACK };
                        8'h0D:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_TAB };
                        8'h15:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_Q };
                        8'h1D:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_W };
                        8'h24:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_E };
                        8'h2D:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_R };
                        8'h2C:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_T };
                        8'h35:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_Y };
                        8'h3C:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_U };
                        8'h43:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_I };
                        8'h44:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_O };
                        8'h4D:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_P };
                        8'h54:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_SBRAL };
                        8'h5B:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_SBRAR };
                        8'h5A:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_ENTER };
                        8'h14:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_CTRL };
                        8'h1C:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_A };
                        8'h1B:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_S };
                        8'h23:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_D };
                        8'h2B:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_F };
                        8'h34:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_G };
                        8'h33:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_H };
                        8'h3B:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_J };
                        8'h42:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_K };
                        8'h4B:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_L };
                        8'h4C:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_SEMIC };
                        8'h52:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_SQUO };
                        8'h12:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_LSHIFT };
                        8'h1A:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_Z };
                        8'h22:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_X };
                        8'h21:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_C };
                        8'h2A:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_V };
                        8'h32:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_B };
                        8'h31:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_N };
                        8'h3A:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_M };
                        8'h41:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_COMMA };
                        8'h49:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_DOT };
                        8'h4A:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_SLA };
                        8'h59:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_RSHIFT };
                        8'h11:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_LALT };
                        8'h7C:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_MULT };
                        8'h6C:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_7 };
                        8'h75:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_8 };
                        8'h7D:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_9 };
                        8'h7B:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_MIN };
                        8'h6B:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_4 };
                        8'h73:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_5 };
                        8'h74:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_6 };
                        8'h79:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_PLUS };
                        8'h69:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_1 };
                        8'h72:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_2 };
                        8'h7A:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_3 };
                        8'h29:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_SPACE };
                        8'h70:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_0 };
                        8'h71:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_DOT };
                        default: begin
                            { amiga_new, amiga_keycode[7] } <= 2'b00;
                            state <= S_FIRST;
                        end
                    endcase
                end
            end
            else if(state == S_E0) begin
                if(kbdat[8:1] == 8'hF0 && amiga_keycode[7] == 1'b0) begin
                    amiga_keycode[7] <= 1'b1;
                end
                else if(kbdat[8:1] == 8'h12 && amiga_keycode[7] == 1'b0) begin
                    state <= S_E0_12;
                end
                else if(kbdat[8:1] == 8'h7C && amiga_keycode[7] == 1'b1) begin
                    state <= S_E0_F0_7C;
                end
                else begin
                    case(kbdat[8:1])
                        8'h11:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_RALT };
                        8'h5B:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_LAMIGA }; //left Windows
                        8'h5C:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_RAMIGA }; //right Windows
                        8'h71:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_DEL };
                        8'h75:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_UP };
                        8'h6B:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_LEFT };
                        8'h72:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_DOWN };
                        8'h74:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_RIGHT };
                        8'h7D:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_LBRA }; // pageUp
                        8'h7A:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_RBRA }; // pageDown
                        8'h4A:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_SLA };
                        8'h5A:  { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_NUM_ENTER };
                        default: begin
                            { amiga_new, amiga_keycode[7] } <= 2'b00;
                            state <= S_FIRST;
                        end
                    endcase
                end
            end
            else if(state == S_E0_12) begin
                if(kbdat[8:1] == 8'hE0) begin
                    state <= S_E0_12_E0;
                end
                else begin
                    { amiga_new, amiga_keycode[7] } <= 2'b00;
                    state <= S_FIRST;
                end
            end
            else if(state == S_E0_12_E0) begin
                if(kbdat[8:1] == 8'h7C) begin
                    { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_HELP }; // make PrintScreen
                end
                else begin
                    { amiga_new, amiga_keycode[7] } <= 2'b00;
                    state <= S_FIRST;
                end
            end
            
            else if(state == S_E0_F0_7C) begin
                if(kbdat[8:1] == 8'hE0) begin
                    state <= S_E0_F0_7C_E0;
                end
                else begin
                    { amiga_new, amiga_keycode[7] } <= 2'b00;
                    state <= S_FIRST;
                end
            end
            else if(state == S_E0_F0_7C_E0) begin
                if(kbdat[8:1] == 8'hF0) begin
                    state <= S_E0_F0_7C_E0_F0;
                end
                else begin
                    { amiga_new, amiga_keycode[7] } <= 2'b00;
                    state <= S_FIRST;
                end
            end
            else if(state == S_E0_F0_7C_E0_F0) begin
                if(kbdat[8:1] == 8'h12) begin
                    { amiga_new, amiga_keycode[6:0] } <= { 1'b1, AKC_HELP }; // break PrintScreen
                end
                else begin
                    { amiga_new, amiga_keycode[7] } <= 2'b00;
                    state <= S_FIRST;
                end
            end
        end
        else if(amiga_new == 1'b1 && delay == 1'b0) begin
            delay <= 1'b1;
            state <= S_FIRST;
        end
        else if(amiga_new == 1'b1 && delay == 1'b1) begin
            amiga_new <= 1'b0;
            amiga_keycode <= 8'd0;
            delay <= 1'b0;
            
            if(pressed == 1'b0 || amiga_keycode[7] == 1'b1) begin
            
                if(amiga_avail >= 4'd0 && amiga_avail <= 4'd11)  amiga_avail <= amiga_avail + 4'd1;
                
                case(amiga_avail)
                    4'd0:   amiga_keycodes[95:88]   <= amiga_keycode;
                    4'd1:   amiga_keycodes[87:80]   <= amiga_keycode;
                    4'd2:   amiga_keycodes[79:72]   <= amiga_keycode;
                    4'd3:   amiga_keycodes[71:64]   <= amiga_keycode;
                    4'd4:   amiga_keycodes[63:56]   <= amiga_keycode;
                    4'd5:   amiga_keycodes[55:48]   <= amiga_keycode;
                    4'd6:   amiga_keycodes[47:40]   <= amiga_keycode;
                    4'd7:   amiga_keycodes[39:32]   <= amiga_keycode;
                    4'd8:   amiga_keycodes[31:24]   <= amiga_keycode;
                    4'd9:   amiga_keycodes[23:16]   <= amiga_keycode;
                    4'd10:  amiga_keycodes[15:8]    <= amiga_keycode;
                    4'd11:  amiga_keycodes[7:0]     <= 8'hFA;
                endcase
            end
        end
        //else if(cnt_counter == 5'd0 && amiga_avail > 4'd0) begin
        //    amiga_avail <= amiga_avail - 4'd1;
        //    amiga_keycodes <= { amiga_keycodes[87:0], 8'd0 };
        //end
    end
end

parameter [6:0]
    AKC_ESC         = 7'h45,
    AKC_F1          = 7'h50,
    AKC_F2          = 7'h51,
    AKC_F3          = 7'h52,
    AKC_F4          = 7'h53,
    AKC_F5          = 7'h54,
    AKC_F6          = 7'h55,
    AKC_F7          = 7'h56,
    AKC_F8          = 7'h57,
    AKC_F9          = 7'h58,
    AKC_F10         = 7'h59,
    AKC_APO         = 7'h00, //`
    AKC_BACK        = 7'h41,
    AKC_1           = 7'h01,
    AKC_2           = 7'h02,
    AKC_3           = 7'h03,
    AKC_4           = 7'h04,
    AKC_5           = 7'h05,
    AKC_6           = 7'h06,
    AKC_7           = 7'h07,
    AKC_8           = 7'h08,
    AKC_9           = 7'h09,
    AKC_0           = 7'h0A,
    AKC_MIN         = 7'h0B, //-
    AKC_EQL         = 7'h0C, //=
    AKC_BSLA        = 7'h0D, //\\
    AKC_TAB         = 7'h42,
    AKC_Q           = 7'h10,
    AKC_W           = 7'h11,
    AKC_E           = 7'h12,
    AKC_R           = 7'h13,
    AKC_T           = 7'h14,
    AKC_Y           = 7'h15,
    AKC_U           = 7'h16,
    AKC_I           = 7'h17,
    AKC_O           = 7'h18,
    AKC_P           = 7'h19, 
    AKC_SBRAL       = 7'h1A, //[
    AKC_SBRAR       = 7'h1B, //]
    AKC_ENTER       = 7'h44,
    AKC_CTRL        = 7'h63,
    AKC_CAPS        = 7'h62,
    AKC_A           = 7'h20,
    AKC_S           = 7'h21,
    AKC_D           = 7'h22,
    AKC_F           = 7'h23,
    AKC_G           = 7'h24,
    AKC_H           = 7'h25,
    AKC_J           = 7'h26,
    AKC_K           = 7'h27,
    AKC_L           = 7'h28,
    AKC_SEMIC       = 7'h29, //;
    AKC_SQUO        = 7'h2A, //'
    AKC_LSHIFT      = 7'h60,
    AKC_Z           = 7'h31,
    AKC_X           = 7'h32,
    AKC_C           = 7'h33,
    AKC_V           = 7'h34,
    AKC_B           = 7'h35,
    AKC_N           = 7'h36,
    AKC_M           = 7'h37,
    AKC_COMMA       = 7'h38, //,
    AKC_DOT         = 7'h39, //.
    AKC_SLA         = 7'h3A, ///
    AKC_RSHIFT      = 7'h61,
    AKC_LALT        = 7'h64,
    AKC_LAMIGA      = 7'h66,
    AKC_SPACE       = 7'h40,
    AKC_RAMIGA      = 7'h67,
    AKC_RALT        = 7'h65,
    AKC_DEL         = 7'h46,
    AKC_HELP        = 7'h5F,
    AKC_UP          = 7'h4C,
    AKC_LEFT        = 7'h4F,
    AKC_DOWN        = 7'h4D,
    AKC_RIGHT       = 7'h4E,
    AKC_NUM_LBRA    = 7'h5A, //(
    AKC_NUM_RBRA    = 7'h5B, //)
    AKC_NUM_SLA     = 7'h5C, ///
    AKC_NUM_MULT    = 7'h5D, //*
    AKC_NUM_7       = 7'h3D,
    AKC_NUM_8       = 7'h3E,
    AKC_NUM_9       = 7'h3F,
    AKC_NUM_MIN     = 7'h4A, //-
    AKC_NUM_4       = 7'h4D,
    AKC_NUM_5       = 7'h4E,
    AKC_NUM_6       = 7'h4F,
    AKC_NUM_PLUS    = 7'h5E, //+
    AKC_NUM_1       = 7'h1D,
    AKC_NUM_2       = 7'h1E,
    AKC_NUM_3       = 7'h1F,
    AKC_NUM_ENTER   = 7'h43,
    AKC_NUM_0       = 7'h0F,
    AKC_NUM_DOT     = 7'h3C; //.

endmodule
