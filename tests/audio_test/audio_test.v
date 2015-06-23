
module audio_test(
    input clk_50,
    input reset_ext_n,
    
    // audio codec
    output ac_sclk,
    inout ac_sdat,
    output ac_xclk,
    output reg ac_bclk,
    output ac_dat,
    output reg ac_lr,
    
    output [7:0] pc_debug
);

assign pc_debug = { 4'd0, state };

wire clk_30;
wire clk_12;
wire pll_locked;

altpll pll_inst(
    .inclk( {1'b0, clk_50} ),
    .clk( {clk_12, clk_30} ), //{5'b0, clk_30} ),
    .locked(pll_locked)
);
defparam    pll_inst.clk0_divide_by = 5,
            pll_inst.clk0_duty_cycle = 50,
            pll_inst.clk0_multiply_by = 3,
            pll_inst.clk0_phase_shift = "0",
            pll_inst.clk1_divide_by = 25,
            pll_inst.clk1_duty_cycle = 50,
            pll_inst.clk1_multiply_by = 6,
            pll_inst.clk1_phase_shift = "0",
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

reg [5:0] volume0f;
reg [5:0] volume1f;
reg [5:0] volume2f;
reg [5:0] volume3f;
reg [7:0] sample0f;
reg [7:0] sample1f;
reg [7:0] sample2f;
reg [7:0] sample3f;

always @(posedge clk_12 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        volume0f <= 6'd0;
        volume1f <= 6'd0;
        volume2f <= 6'd0;
        volume3f <= 6'd0;
        sample0f <= 8'd0;
        sample1f <= 8'd0;
        sample2f <= 8'd0;
        sample3f <= 8'd0;
    end
    else begin
        volume0f <= 6'd60;
        volume1f <= 6'd60;
        volume2f <= 6'd60;
        volume3f <= 6'd60;
        
        sample0f <= sample0f + 8'd1;
        sample1f <= sample1f + 8'd1;
        sample2f <= sample2f + 8'd1;
        sample3f <= sample3f + 8'd1;
    end
end



assign ac_dat = left_right_sample[31];
assign ac_xclk = clk_12;

// left MSB-LSB, right MSB-LSB
reg [31:0] left_right_sample;
reg [7:0] data_counter;

wire [13:0] mult_left_1;
assign mult_left_1 =
    ((volume1f[0] == 1'b1)? { {6{sample1f[7]}}, sample1f[7:0] } : 14'd0) +
    ((volume1f[1] == 1'b1)? { {5{sample1f[7]}}, sample1f[7:0], 1'b0 } : 14'd0) +
    ((volume1f[2] == 1'b1)? { {4{sample1f[7]}}, sample1f[7:0], 2'b0 } : 14'd0) +
    ((volume1f[3] == 1'b1)? { {3{sample1f[7]}}, sample1f[7:0], 3'b0 } : 14'd0) +
    ((volume1f[4] == 1'b1)? { {2{sample1f[7]}}, sample1f[7:0], 4'b0 } : 14'd0) +
    ((volume1f[5] == 1'b1)? { {1{sample1f[7]}}, sample1f[7:0], 5'b0 } : 14'd0);

wire [13:0] mult_left_2;
assign mult_left_2 =
    ((volume2f[0] == 1'b1)? { {6{sample2f[7]}}, sample2f[7:0] } : 14'd0) +
    ((volume2f[1] == 1'b1)? { {5{sample2f[7]}}, sample2f[7:0], 1'b0 } : 14'd0) +
    ((volume2f[2] == 1'b1)? { {4{sample2f[7]}}, sample2f[7:0], 2'b0 } : 14'd0) +
    ((volume2f[3] == 1'b1)? { {3{sample2f[7]}}, sample2f[7:0], 3'b0 } : 14'd0) +
    ((volume2f[4] == 1'b1)? { {2{sample2f[7]}}, sample2f[7:0], 4'b0 } : 14'd0) +
    ((volume2f[5] == 1'b1)? { {1{sample2f[7]}}, sample2f[7:0], 5'b0 } : 14'd0);

wire [13:0] mult_right_0;
assign mult_right_0 =
    ((volume0f[0] == 1'b1)? { {6{sample0f[7]}}, sample0f[7:0] } : 14'd0) +
    ((volume0f[1] == 1'b1)? { {5{sample0f[7]}}, sample0f[7:0], 1'b0 } : 14'd0) +
    ((volume0f[2] == 1'b1)? { {4{sample0f[7]}}, sample0f[7:0], 2'b0 } : 14'd0) +
    ((volume0f[3] == 1'b1)? { {3{sample0f[7]}}, sample0f[7:0], 3'b0 } : 14'd0) +
    ((volume0f[4] == 1'b1)? { {2{sample0f[7]}}, sample0f[7:0], 4'b0 } : 14'd0) +
    ((volume0f[5] == 1'b1)? { {1{sample0f[7]}}, sample0f[7:0], 5'b0 } : 14'd0);
    
wire [13:0] mult_right_3;
assign mult_right_3 =
    ((volume3f[0] == 1'b1)? { {6{sample3f[7]}}, sample3f[7:0] } : 14'd0) +
    ((volume3f[1] == 1'b1)? { {5{sample3f[7]}}, sample3f[7:0], 1'b0 } : 14'd0) +
    ((volume3f[2] == 1'b1)? { {4{sample3f[7]}}, sample3f[7:0], 2'b0 } : 14'd0) +
    ((volume3f[3] == 1'b1)? { {3{sample3f[7]}}, sample3f[7:0], 3'b0 } : 14'd0) +
    ((volume3f[4] == 1'b1)? { {2{sample3f[7]}}, sample3f[7:0], 4'b0 } : 14'd0) +
    ((volume3f[5] == 1'b1)? { {1{sample3f[7]}}, sample3f[7:0], 5'b0 } : 14'd0);

wire [14:0] left_channel;
assign left_channel = mult_left_1 + mult_left_2;

wire [14:0] right_channel;
assign right_channel = mult_right_0 + mult_right_3;

always @(posedge clk_12 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        data_counter        <= 8'd0;
        left_right_sample   <= 32'd0;
        ac_bclk             <= 1'b0;
        ac_lr               <= 1'b0;
    end
    else if(data_counter == 8'd0 && state == S_READY) begin
        data_counter <= data_counter + 8'd1;
        left_right_sample <= { 1'b0, left_channel, 1'b0, right_channel };
        ac_bclk <= 1'b0;
        ac_lr <= 1'b1;
    end
    else if(data_counter == 8'd1) begin
        data_counter <= data_counter + 8'd1;
        ac_bclk <= 1'b1;
        ac_lr <= 1'b1;
    end
    else if(data_counter >= 8'd127 && data_counter <= 8'd248) begin
        data_counter <= data_counter + 8'd1;
        left_right_sample <= { left_right_sample[30:0], 1'b0 };
        ac_bclk <= 1'b0;
        ac_lr <= 1'b0;
    end
    else if(data_counter == 8'd249) begin
        data_counter <= 8'd0;
        ac_bclk <= 1'b0;
        ac_lr <= 1'b0;
    end
    else if(data_counter[1:0] == 2'b11) begin
        data_counter <= data_counter + 8'd1;
        left_right_sample <= { left_right_sample[30:0], 1'b0 };
        ac_bclk <= 1'b0;
        ac_lr <= 1'b0;
    end
    else if(data_counter[1:0] == 2'b01) begin
        data_counter <= data_counter + 8'd1;
        ac_bclk <= 1'b1;
        ac_lr <= 1'b0;
    end
    else if(data_counter != 8'd0 && state == S_READY) begin
        data_counter <= data_counter + 8'd1;
    end
end

reg i2c_start;
reg [15:0] i2c_data;
reg [3:0] state;

parameter [3:0]
    S_IDLE      = 4'd0,
    S_RESET     = 4'd1,
    S_POWER     = 4'd2,
    S_OUTPUT    = 4'd3,
    S_SIDE      = 4'd4,
    S_EMPH      = 4'd5,
    S_FORMAT    = 4'd6,
    S_SAMPLING  = 4'd7,
    S_ACTIVATE  = 4'd8,
    S_READY     = 4'd9; 

wire i2c_ready;

i2c_send i2c_send_inst(
    .clk_12(clk_12),
    .reset_n(reset_n),
    
    .start(i2c_start),
    .data(i2c_data),
    .ready(i2c_ready),
    
    .sclk(ac_sclk),
    .sdat(ac_sdat)
);

always @(posedge clk_12 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        i2c_start <= 1'b0;
        i2c_data <= 16'd0;
        state <= S_IDLE;
    end
    else begin
        if(state == S_IDLE) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0001111_000000000;
            state <= S_RESET;
        end
        else if(state == S_RESET && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0000110_001100111; // power down unused parts
            state <= S_POWER;
        end
        else if(state == S_POWER && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0000010_101111111; // +3dB headphone output
            state <= S_OUTPUT;
        end
        else if(state == S_OUTPUT && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0000100_011010010; // DAC select
            state <= S_SIDE;
        end
        else if(state == S_SIDE && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0000101_000000011; // disable mute, 32kHz de-emphasis
            state <= S_EMPH;
        end
        else if(state == S_EMPH && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0000111_000000011; // DSP mode
            state <= S_FORMAT;
        end
        else if(state == S_FORMAT && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0001000_000000001; // USB mode, 12MHz, 48 kHz
            state <= S_SAMPLING;
        end
        else if(state == S_SAMPLING && i2c_ready == 1'b1) begin
            i2c_start <= 1'b1;
            i2c_data <= 16'b0001001_000000001;
            state <= S_ACTIVATE;
        end
        else if(state == S_ACTIVATE && i2c_ready == 1'b1) begin
            state <= S_READY;
        end
        else begin
            i2c_start <= 1'b0;
        end
    end
end

endmodule


module i2c_send(
    input clk_12,
    input reset_n,
    
    input start,
    input [15:0] data,
    output ready,
    
    output reg sclk,
    inout sdat
);

assign ready = (state == S_IDLE && start == 1'b0);
assign sdat = (sdat_oe == 1'b0)? 1'bZ : sdat_o;

reg sdat_oe;
reg sdat_o;
reg [7:0] dat_byte;
reg [1:0] part;
reg [2:0] counter;
reg [3:0] state;
parameter [3:0]
    S_IDLE      = 4'd0,
    S_SEND_0    = 4'd1,
    S_SEND_1    = 4'd2,
    S_SEND_2    = 4'd3,
    S_SEND_3    = 4'd4,
    S_SEND_4    = 4'd5,
    S_END_0     = 4'd6,
    S_END_1     = 4'd7,
    S_END_2     = 4'd8;
    
always @(posedge clk_12 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        sclk <= 1'b1;
        sdat_oe <= 1'b0;
        sdat_o <= 1'b1;
        dat_byte <= 8'd0;
        part <= 2'b0;
        counter <= 3'd0;
        state <= S_IDLE;
    end
    else if(state == S_IDLE && start == 1'b1) begin
        // start
        sdat_oe <= 1'b1;
        sdat_o <= 1'b0;
        sclk <= 1'b1;
        
        part <= 2'b0;
        dat_byte <= 8'b0011010_0;
        counter <= 3'd7;
        state <= S_SEND_0;
    end
    else if(state == S_SEND_0) begin
        sdat_oe <= 1'b1;
        sdat_o <= dat_byte[7];
        sclk <= 1'b0;
        state <= S_SEND_1;
    end
    else if(state == S_SEND_1) begin
        sclk <= 1'b1;
        
        if(counter == 3'd0) state <= S_SEND_2;
        else begin
            dat_byte <= { dat_byte[6:0], 1'b0 };
            counter <= counter - 3'd1; 
            state <= S_SEND_0;
        end
    end
    else if(state == S_SEND_2) begin
        sdat_oe <= 1'b0;
        sclk <= 1'b0;
        state <= S_SEND_3;
    end
    else if(state == S_SEND_3) begin
        sclk <= 1'b1;
        state <= S_SEND_4;
    end
    else if(state == S_SEND_4 && sdat == 1'b0) begin
        sclk <= 1'b0;
        part <= part + 2'b1;
        counter <= 3'd7;
        
        if(part == 2'd0)        dat_byte <= data[15:8];
        else if(part == 2'd1)   dat_byte <= data[7:0];
        
        if(part == 2'd0 || part == 2'd1)    state <= S_SEND_0;
        else                                state <= S_END_0;
    end
    else if(state == S_END_0) begin
        sdat_oe <= 1'b1;
        sdat_o <= 1'b0;
        sclk <= 1'b0;
        state <= S_END_1;
    end
    else if(state == S_END_1) begin
        sclk <= 1'b1;
        state <= S_END_2;
    end
    else if(state == S_END_2) begin
        // end
        sdat_oe <= 1'b0;
        state <= S_IDLE;
    end
end

endmodule

