module tb_drv_audio();



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


//--------
reg clk_12;
reg reset_n;

reg [5:0] volume0;
reg [5:0] volume1;
reg [5:0] volume2;
reg [5:0] volume3;
reg [7:0] sample0;
reg [7:0] sample1;
reg [7:0] sample2;
reg [7:0] sample3;

wire ac_sdat;
assign ac_sdat = 1'b0;

drv_audio drv_audio_inst(
    .clk_12(clk_12),
    .reset_n(reset_n),
    
    // audio interface
    .volume0(volume0),
    .volume1(volume1),
    .volume2(volume2),
    .volume3(volume3),
    .sample0(sample0),
    .sample1(sample1),
    .sample2(sample2),
    .sample3(sample3),
    
    // audio codec
    .ac_sclk(),
    .ac_sdat(ac_sdat),
    .ac_xclk(),
    .ac_bclk(),
    .ac_dat(),
    .ac_lr()
);

initial begin
    clk_12 = 1'b0;
    forever #5 clk_12 = ~clk_12;
end

initial begin
    $dumpfile("tb_drv_audio.vcd");
    $dumpvars(0);
    $dumpon();
    
    reset_n = 1'b0;
    #10 reset_n = 1'b1;
    
    volume0 = 63;
    volume1 = 30;
    volume2 = 0;
    volume3 = 32;
    
    sample0 = 255;
    sample1 = 128;
    sample2 = 127;
    sample3 = 0;
    
    
    #10000
    
    $finish();
end

endmodule
