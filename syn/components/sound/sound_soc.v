
module sound_soc(
    input   CLOCK_50,
    
    output  I2C_SCLK,
    inout   I2C_SDAT,
    output  AUD_XCK,
    output  AUD_BCLK,
    output  AUD_DACDAT,
    output  AUD_DACLRCK
);

//------------------------------------------------------------------------------

wire clk_sys;
wire clk_12;
wire rst_n;

pll pll_inst(
    .inclk0     (CLOCK_50),
    .c0         (clk_sys),
    .c1         (clk_12),
    .locked     (rst_n)
);

//------------------------------------------------------------------------------

soc u0 (
    .clk_sys_clk                              (clk_sys),    //       clk_sys.clk
    .reset_sys_reset_n                        (rst_n),      //     reset_sys.reset_n
    .clk_12_clk                               (clk_12),     //        clk_12.clk
    .reset_12_reset_n                         (rst_n),      //      reset_12.reset_n
    .sound_conduit_speaker_enable             (1'b0),       // sound_conduit.speaker_enable
    .sound_conduit_speaker_out                (1'b0),       //              .speaker_out
    .sound_conduit_dma_soundblaster_req       (),           //              .dma_soundblaster_req
    .sound_conduit_dma_soundblaster_ack       (1'b0),       //              .dma_soundblaster_ack
    .sound_conduit_dma_soundblaster_terminal  (1'b0),       //              .dma_soundblaster_terminal
    .sound_conduit_dma_soundblaster_readdata  (8'd0),       //              .dma_soundblaster_readdata
    .sound_conduit_dma_soundblaster_writedata (),           //              .dma_soundblaster_writedata
    .sound_conduit_ac_sclk                    (I2C_SCLK),    //              .ac_sclk
    .sound_conduit_ac_sdat                    (I2C_SDAT),    //              .ac_sdat
    .sound_conduit_ac_xclk                    (AUD_XCK),    //              .ac_xclk
    .sound_conduit_ac_bclk                    (AUD_BCLK),    //              .ac_bclk
    .sound_conduit_ac_dat                     (AUD_DACDAT),     //              .ac_dat
    .sound_conduit_ac_lr                      (AUD_DACLRCK)       //              .ac_lr
);

//------------------------------------------------------------------------------

endmodule
