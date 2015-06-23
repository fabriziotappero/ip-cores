`timescale 10ns / 1ns

module aoOCS_tb(
);

// inputs
reg clk;
reg rst_n;

wire sram_clk;
wire [18:0] sram_address;
wire sram_oe_n;
wire sram_writeen_n;
wire [3:0] sram_byteen_n;
wire [31:0] sram_data_o;
inout [35:0] sram_data;
assign sram_data = (sram_oe_n == 1'b0)? {4'b0, sram_data_o} : 36'bZ;
wire sram_advance_n;
wire sram_adsc_n;

wire sd_clk;
wire sd_cmd;
wire sd_dat;

reg [2:0] ext_int;

aoOCS aoOCS_inst(
	.clk_50(clk),
	.reset_ext_n(rst_n),
	
	// ssram interface
	.ssram_address(sram_address), //[18:0]
	.ssram_oe_n(sram_oe_n),
	.ssram_writeen_n(sram_writeen_n),
	.ssram_byteen_n(sram_byteen_n), //[3:0]
	.ssram_data(sram_data), //[35:0] inout
	.ssram_clk(sram_clk),
	.ssram_globalw_n(),
	.ssram_advance_n(sram_advance_n),
	.ssram_adsp_n(),
	.ssram_adsc_n(sram_adsc_n),
	.ssram_ce1_n(),
	.ssram_ce2(),
	.ssram_ce3_n(),
	
	// sd interface
	.sd_clk_o(sd_clk),
	.sd_cmd_io(sd_cmd), //inout
	.sd_dat_io(sd_dat), //inout
	
	// serial interface
	.uart_rxd(1'b0),
	.uart_rts(1'b0),
	.uart_txd(),
	.uart_cts(),
	
	// vga output
	.vga_r(), //[9:0]
	.vga_g(), //[9:0]
	.vga_b(), //[9:0]
	.vga_blank_n(),
	.vga_sync_n(),
	.vga_clock(),
	.vga_hsync(),
	.vga_vsync(),
	
	// hex output
    .hex0(),
    .hex1(),
    .hex2(),
    .hex3(),
    .hex4(),
    .hex5(),
    .hex6(),
    .hex7(),
    .hex_switch(1'b0),
    
    // debug
    .sd_debug(),
    .pc_debug(),
    .sd_error(),
    .halt_switch(1'b0),
    .key0(1'b1),
    .blitter_switch(1'b0),
    .floppy_debug()
);

/*
model_sd model_sd_inst(
	.reset_n(rst_n),
	
	.sd_clk(sd_clk),
	.sd_cmd_io(sd_cmd),
	.sd_dat_io(sd_dat)
);
*/

initial begin
	clk = 1'b0;
	forever #2 clk = ~clk;
end

reg [31:0] rom[0:65535];
reg [31:0] ram[0:458751];

integer f;
integer r;

wire [18:0] sram_address_final;
assign sram_address_final = { sram_address[18:2], sram_address[1:0] ^ sram_burst[1:0] };

wire [15:0] rom_index;
assign rom_index = (sram_address_final-458752);

assign sram_data_o = (sram_address_final < 458752)? ram[sram_address_final] : rom[rom_index];

reg [1:0] sram_burst;
always @(posedge sram_clk) begin
    if(sram_adsc_n == 1'b0)         sram_burst = 2'd0;
    else if(sram_advance_n == 1'b0) sram_burst = sram_burst + 2'd1;
end

always @(posedge sram_clk) begin
    if(sram_writeen_n == 1'b0 && {sram_address,2'b00} < 1835008 && sram_byteen_n[0] == 1'b0) ram[sram_address_final][7:0] = sram_data[7:0];
    if(sram_writeen_n == 1'b0 && {sram_address,2'b00} < 1835008 && sram_byteen_n[1] == 1'b0) ram[sram_address_final][15:8] = sram_data[15:8];
    if(sram_writeen_n == 1'b0 && {sram_address,2'b00} < 1835008 && sram_byteen_n[2] == 1'b0) ram[sram_address_final][23:16] = sram_data[23:16];
    if(sram_writeen_n == 1'b0 && {sram_address,2'b00} < 1835008 && sram_byteen_n[3] == 1'b0) ram[sram_address_final][31:24] = sram_data[31:24];
    
    if(sram_writeen_n == 1'b0 && {sram_address,2'b00} < 1835008 && sram_byteen_n[3:0] != 4'b1111)
        $display("Written: %x <- %x, sel: %x", sram_address_final, sram_data, sram_byteen_n);
end

initial begin
    f = $fopen("/home/alek/temp/e-uae-0.8.29-WIP4/build/bin/kick12_a.rom", "rb");
    r = $fread(rom, f);
    $display(r);
    $fclose(f);
    
    for(f=0; f<458752; f=f+1) ram[f] = 32'd0;
    
    $display("%x", rom[54]);
    $display("%x", rom[55]);
    rom[54] = 32'h203c0000; //was 203c0002
    rom[55] = 32'h00045380; //was 00005380
end

//initial begin
//    forever begin
//        #2 aoOCS_inst.control_inst.pc_switch = 32'd0;
//        aoOCS_inst.control_inst.management_mode = 1'd0;
//    end
//end

initial begin
	$dumpfile("aoOCS_tb.vcd");
	$dumpvars(0);
	$dumpon();
	
	ext_int = 3'd0;
	
	rst_n = 1'b0;
	#10
	rst_n = 1'b1;
	
	#580
	ext_int = 3'd3;
	
	#100000 
	
	$dumpoff();
	
	$finish();
end

endmodule
