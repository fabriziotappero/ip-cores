module debug(
    input CLK_I,
    input reset_n,
    
    // WISHBONE master
    output reg CYC_O,
    output reg STB_O,
    output reg WE_O,
    output reg [31:2] ADR_O,
    output reg [3:0] SEL_O,
    output reg [31:0] master_DAT_O,
    input [31:0] master_DAT_I,
    input ACK_I,
    
    input start_dump,
    input start_dump2
);

reg [31:0] adr;

reg [2:0] state;
parameter [2:0]
    S_IDLE          = 3'd0,
    S_READ          = 3'd1,
    S_READ_2        = 3'd2,
    S_READ_3        = 3'd3,
    S_READ_4        = 3'd4,
    S_FINISHED      = 3'd5;
    
    
always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        CYC_O <= 1'b0;
        STB_O <= 1'b0;
        WE_O <= 1'b0;
        ADR_O <= 30'd0;
        SEL_O <= 4'd0;
        master_DAT_O <= 32'd0;
        adr <= 32'd0;
        
        state <= S_IDLE;
    end
    else begin
        case(state)
            S_IDLE: begin
                if(start_dump == 1'b1) begin
                    state <= S_READ;
                end
            end
            S_READ: begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b0;
                ADR_O <= adr[31:2];
                SEL_O <= 4'b1111;
                
                if(ACK_I == 1'b0)   state <= S_READ_2;
            end
            S_READ_2: begin
                if(ACK_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;
                    master_DAT_O <= master_DAT_I;
                    
                    state <= S_READ_3;
                end
            end
            S_READ_3: begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b1;
                ADR_O <= 30'h4000800;
                SEL_O <= 4'b1111;
                adr <= adr + 32'd1;
                
                if(ACK_I == 1'b0)   state <= S_READ_4;
            end
            S_READ_4: begin
                if(ACK_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;
                    
                    if(adr[1:0] == 2'b00 && adr < 32'h80000) begin
                        state <= S_READ;
                    end
                    else if(adr[1:0] == 2'b00 && adr == 32'h80000) begin
                        state <= S_FINISHED;
                    end
                    else begin
                        master_DAT_O <= { master_DAT_O[23:0], 8'd0 };
                        state <= S_READ_3;
                    end
                end
            end
            S_FINISHED: begin
                if(start_dump2 == 1'b0) begin
                    state <= S_READ;
                    adr <= 32'd0;
                end
            end
        endcase
    end
end

endmodule

