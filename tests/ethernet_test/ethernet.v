/*
Send UDP packet:
ethernet
    dest mac(6), src mac(6), type(2 = 0x0800 IPv4)
ip
    version,header([1] = 0x45), tos([1] = 0x00), length([2] = 4*5 + 4*2 + len = 992 = 0x03E0)
    id([2] = 0x0000), flags,offset([2] = 0x40, 0x00)
    ttl([1] = 0x0F), protocol([1] = 0x11), header checksum([2] = 0)
    source ip([4])
    dest ip([4])
udp
    source port([2]), dest port([2])
    length([2] = 8 + len = 972 = 0x03CC), checksum([2] = 0)
data
    (len = line num(1) + line(214*36/8 = 963) = 964)

--full ethernet packet len = 992 + 14 = 1006 = 0x03EE

DM9000A control to send:
    set IMR(FFh = 0x80)
    
    set checksum reg (31h = 0x05)
    
    set early transmit (30h = 0x83) ? threshold 75%
    
    power-up PHY (1Fh = 0x00)
    
    dummy MWCDM ?
    
    DO
    
        packet I
        set MWCMD(F8h = 16-bit data) 
        
        wait for packet II
        read TX(02h bit 0 == 0)
        
        set TXPLL(FCh = low byte)
        set TXPLH(FDh = high byte)
        
        write TX(02h 0x01)
        
        packet II
        set MWCMD(F8h = 16-bit data) 
        
        wait for packet I
        read TX(02h bit 0 == 0)
        
        set TXPLL(FCh = low byte)
        set TXPLH(FDh = high byte)
        
        write TX(02h 0x01)
    
    LOOP
    
*/

module ethernet(
    input clk_50,
    input reset_ext_n,
    
    output enet_clk_25,
    output enet_reset_n,
    output enet_cs_n,
    
    input enet_irq,
    
    output reg enet_ior_n,
    output reg enet_iow_n,
    output reg enet_cmd,

    inout [15:0] enet_data,
    
    input key,
    output [7:0] leds
);

assign leds = state_counter[7:0];

/***********************************************************************************************************************
 * System PLL
 **********************************************************************************************************************/

wire [5:0]  pll_clocks;
assign      enet_clk_25 = pll_clocks[0];
wire        clk_30 = pll_clocks[1];
wire        pll_locked;

altpll pll_inst(
    .inclk  ( {1'b0, clk_50} ),
    .clk    (pll_clocks),
    .locked (pll_locked)
);
defparam
    pll_inst.clk0_divide_by             = 2,
    pll_inst.clk0_duty_cycle            = 50,
    pll_inst.clk0_multiply_by           = 1,
    pll_inst.clk0_phase_shift           = "0",
    pll_inst.clk1_divide_by             = 5,
    pll_inst.clk1_duty_cycle            = 50,
    pll_inst.clk1_multiply_by           = 3,
    pll_inst.clk1_phase_shift           = "0",
    pll_inst.compensate_clock           = "CLK0",
    pll_inst.gate_lock_counter          = 1048575,
    pll_inst.gate_lock_signal           = "YES",
    pll_inst.inclk0_input_frequency     = 20000,
    pll_inst.intended_device_family     = "Cyclone II",
    pll_inst.invalid_lock_multiplier    = 5,
    pll_inst.lpm_hint                   = "CBX_MODULE_PREFIX=pll30",
    pll_inst.lpm_type                   = "altpll",
    pll_inst.operation_mode             = "NORMAL",
    pll_inst.valid_lock_multiplier      = 1;

wire reset_n            = pll_locked & reset_ext_n;

/***********************************************************************************************************************
 *
 **********************************************************************************************************************/
assign enet_reset_n = reset_n;
assign enet_cs_n    = 1'b0;

reg tx_active;

reg enet_data_oe;
reg [15:0] enet_data_out;
assign enet_data = (enet_data_oe == 1'b1)? enet_data_out : 16'bZ;

//************
reg [5:0] ram_addr;
wire [15:0] ram_q;

altsyncram ethernet_ram_inst(
    .clock0(clk_30),
    .address_a(ram_addr),
    .q_a(ram_q)
);
defparam
    ethernet_ram_inst.operation_mode = "ROM",
    ethernet_ram_inst.width_a = 16,
    ethernet_ram_inst.widthad_a = 6,
    ethernet_ram_inst.init_file = "ethernet.mif";

//************


reg [15:0] state_counter;
always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        state_counter   <= 16'd0;
        tx_active       <= 1'b0;
        
        enet_iow_n      <= 1'b1;
        enet_ior_n      <= 1'b1;
        enet_cmd        <= 1'b0;        // low: INDEX, high: DATA
        enet_data_oe    <= 1'b0;
        enet_data_out   <= 16'd0;
        
        ram_addr        <= 6'd0;
    end
    else if(state_counter == 16'd50000) begin
        //if(key == 1'b0) begin
            enet_iow_n <= 1'b0;
            enet_cmd <= 1'b0;
            enet_data_oe <= 1'b1;
            enet_data_out <= { 8'd0, 8'hFF }; // set IMR(FFh = 0x80)
            
            state_counter <= state_counter + 16'd1;
        //end
    end
    else if(state_counter == 16'd50002) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 8'd0, 8'h80 }; 
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd50005) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_out <= { 8'd0, 8'h1F }; // power-up PHY (1Fh = 0x00)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd50007) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 8'd0, 8'h00 }; 
        
        state_counter <= state_counter + 16'd1;
    end
    
    else if(state_counter == 16'd50010) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_out <= { 8'd0, 8'h31 }; // set checksum reg (31h = 0x05)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd50012) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 8'd0, 8'h05 }; 
        
        state_counter <= state_counter + 16'd1;
    end
    
    
    else if(state_counter == 16'd50018) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_out <= { 8'd0, 8'hF8 }; // set MWCMD(F8h = 16-bit data) 
        
        ram_addr <= 6'd0;
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter >= 16'd50020 && state_counter <= 16'd50060 && state_counter[0] == 1'b0) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= ram_q;
        
        ram_addr <= ram_addr + 6'd1;
        state_counter <= state_counter + 16'd1;
    end
    
    else if(state_counter >= 16'd50062 && state_counter <= 16'd51024 && state_counter[0] == 1'b0) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 16'hAAAA }; 
        
        if(state_counter == 16'd51024)  state_counter <= 16'd60016 - 16'd1;
        else                            state_counter <= state_counter + 16'd1;
    end
    
    
    else if(state_counter == 16'd60016) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_oe <= 1'b1;
        enet_data_out <= { 8'd0, 8'h02 }; // read TX(02h bit 0 == 0)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd60018) begin
        enet_ior_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_oe <= 1'b0;
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd60020) begin
        enet_ior_n <= 1'b1;
        tx_active <= enet_data[0];
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd60022) begin
        if(tx_active == 1'b0)   state_counter <= 16'd60118;
        else                    state_counter <= 16'd60016;
    end
    
    else if(state_counter == 16'd60118) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_oe <= 1'b1;
        enet_data_out <= { 8'd0, 8'hFC }; // set TXPLL(FCh = low byte)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd60120) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 8'h00, 8'hEE }; 
        
        state_counter <= state_counter + 16'd1;
    end
    
    else if(state_counter == 16'd60123) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_out <= { 8'd0, 8'hFD }; // set TXPLH(FDh = high byte)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd60125) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 8'h00, 8'h03 }; 
        
        state_counter <= state_counter + 16'd1;
    end
    
    else if(state_counter == 16'd60128) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b0;
        enet_data_out <= { 8'd0, 8'h02 }; // write TX(02h = 0x01)
        
        state_counter <= state_counter + 16'd1;
    end
    else if(state_counter == 16'd60130) begin
        enet_iow_n <= 1'b0;
        enet_cmd <= 1'b1;
        enet_data_out <= { 8'h00, 8'h01 }; 
        
        state_counter <= state_counter + 16'd1;
    end
    
    else if(state_counter == 16'd60132) begin
         state_counter <= 16'd50018;
    end
    
    else if(state_counter <= 16'd60132) begin
        enet_iow_n <= 1'b1;
        enet_ior_n <= 1'b1;
        state_counter <= state_counter + 16'd1;
    end
    
end

endmodule
