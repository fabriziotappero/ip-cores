module vl_wb_cache_tb ();

   wire [31:0] wbm_a_dat_o;
   wire [3:0]  wbm_a_sel_o;
   wire [31:0] wbm_a_adr_o;
   wire [2:0]  wbm_a_cti_o;
   wire [1:0]  wbm_a_bte_o;
   wire        wbm_a_we_o ;
   wire        wbm_a_cyc_o;
   wire        wbm_a_stb_o;
   wire [31:0] wbm_a_dat_i;
   wire        wbm_a_ack_i;
   reg         wbm_a_clk  ;
   reg         wbm_a_rst  ;

   wire [31:0] wbm_b_dat_o;
   wire [3:0]  wbm_b_sel_o;
   wire [31:0] wbm_b_adr_o;
   wire [2:0]  wbm_b_cti_o;
   wire [1:0]  wbm_b_bte_o;
   wire        wbm_b_we_o ;
   wire        wbm_b_cyc_o;
   wire        wbm_b_stb_o;
   wire [31:0] wbm_b_dat_i;
   wire        wbm_b_ack_i;
   wire        wbm_b_stall_i;
   reg         wbm_b_clk  ;
   reg         wbm_b_rst  ;

parameter wb_clk_period = 20;

parameter [1:0] linear = 2'b00,
               	beat4  = 2'b01,
               	beat8  = 2'b10,
               	beat16 = 2'b11;
                		
parameter [2:0] classic = 3'b000,
                inc     = 3'b010,
                eob	= 3'b111;
parameter rd = 1'b0;
parameter wr = 1'b1;

parameter instructions = 32;

// {adr_o,bte_o,cti_o,dat_o,sel_o,we_o,cyc_o,stb_o}
parameter [32+2+3+32+4+1+1+1:1] inst_rom0 [0:instructions-1]= {
		{32'h0,linear,classic,32'h0,4'b1111,rd,1'b0,1'b0},
		{32'h100,linear,classic,32'h12345678,4'b1111,wr,1'b1,1'b1}, // write 0x12345678 @ 0x100
		{32'h100,linear,classic,32'h0,4'b1111,rd,1'b1,1'b1},        // read  @ 0x100		
		{32'h1100,beat4,eob,32'h87654321,4'b1111,wr,1'b1,1'b1},     // write 0x87654321 @ 0x1100 with 01,111
		{32'h1100,linear,classic,32'h0,4'b1111,rd,1'b1,1'b1},       // read  @ 0x1100
		{32'h0,linear,classic,32'h0,4'b1111,rd,1'b0,1'b0},		
		{32'h100,beat4,inc,32'h00010002,4'b1111,wr,1'b1,1'b1},      // write burst @ 0x100
		{32'h104,beat4,inc,32'h00030004,4'b1111,wr,1'b1,1'b1},
		{32'h108,beat4,inc,32'h00050006,4'b1111,wr,1'b1,1'b1},
		{32'h10c,beat4,eob,32'h00070008,4'b1111,wr,1'b1,1'b1},		
		{32'h104,linear,classic,32'hA1FFFFFF,4'b1000,wr,1'b1,1'b1}, // write byte a1 @ 104		
		{32'h108,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},             // read burst
		{32'h10c,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h100,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h104,beat4,eob,32'h0,4'b1111,rd,1'b1,1'b1},		
		{32'h100,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},             // read burst with strobe going low once
		{32'h104,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h104,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b0},
		{32'h108,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h10c,beat4,eob,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h100,linear,inc,32'hdeaddead,4'b1111,1'b1,1'b1,1'b1}, // write
		{32'h104,linear,eob,32'h55555555,4'b1111,1'b1,1'b1,1'b1}, //		
		{32'h100,linear,inc,32'h0,4'b1111,1'b0,1'b1,1'b1}, // read
		{32'h104,linear,eob,32'h0,4'b1111,1'b0,1'b1,1'b1}, // read
		{32'h100,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1}, // read burst with strobe going low
		{32'h104,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b0},
		{32'h104,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h108,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h108,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b0},
		{32'h10c,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b0},
		{32'h10c,beat4,eob,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h0,linear,classic,32'h0,4'b1111,rd,1'b0,1'b0}};

	parameter [31:0] dat0 [0:instructions-1] = {
		32'h0,
		32'h0,
		32'h0,
		32'h12345678,
		32'h0,
		32'h87654321,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h0,
		32'h00050006,
		32'h00070008,
		32'h00010002,
		32'ha1030004,
		32'h00010002,
		32'ha1030004,
		32'h0,
		32'h00050006,
		32'h00070008,
		32'h0,
		32'h0,
		32'hdeaddead,
		32'h55555555,
		32'hdeaddead,
		32'h0,
		32'h55555555,
		32'h00050006,
		32'h0,
		32'h0,
		32'h00070008};


vl_wb_cache
# (
    .dw_s(32),
    .aw_s(16),
    .dw_m(32),
    .wbs_max_burst_width(4),
    .wbm_burst_size(4),
    .aw_offset(2),
    .aw_slot(5),
    .valid_mem(1),
    .async(1),
    .debug(0))
dut (
    .wbs_dat_i(wbm_a_dat_o),
    .wbs_adr_i(wbm_a_adr_o[17:2]),
    .wbs_sel_i(wbm_a_sel_o),
    .wbs_cti_i(wbm_a_cti_o),
    .wbs_bte_i(wbm_a_bte_o),
    .wbs_we_i(wbm_a_we_o),
    .wbs_stb_i(wbm_a_stb_o),
    .wbs_cyc_i(wbm_a_cyc_o),
    .wbs_dat_o(wbm_a_dat_i),
    .wbs_ack_o(wbm_a_ack_i),
    .wbs_clk(wbm_a_clk),
    .wbs_rst(wbm_a_rst),
    
    .wbm_dat_o(wbm_b_dat_o),
    .wbm_adr_o(wbm_b_adr_o[17:2]),
    .wbm_sel_o(wbm_b_sel_o),
    .wbm_cti_o(wbm_b_cti_o),
    .wbm_bte_o(wbm_b_bte_o),
    .wbm_we_o(wbm_b_we_o),
    .wbm_stb_o(wbm_b_stb_o),
    .wbm_cyc_o(wbm_b_cyc_o),
    .wbm_dat_i(wbm_b_dat_i),
    .wbm_ack_i(wbm_b_ack_i),
    .wbm_stall_i(wbm_b_stall_i),
    .wbm_clk(wbm_b_clk),
    .wbm_rst(wbm_b_rst));
assign wbm_b_adr_o[31:18] = 14'h00;
assign wbm_b_adr_o[1:0] = 2'b00;

wbm # ( .inst_rom(inst_rom0), .dat(dat0), .testcase("\nTest case:\nwb_b3_dpram A side\n"))
wbmi0(
            .adr_o(wbm_a_adr_o),
            .bte_o(wbm_a_bte_o),
            .cti_o(wbm_a_cti_o),
            .dat_o(wbm_a_dat_o),
	    .sel_o(wbm_a_sel_o),
            .we_o (wbm_a_we_o),
            .cyc_o(wbm_a_cyc_o),
            .stb_o(wbm_a_stb_o),
            .dat_i(wbm_a_dat_i),
            .ack_i(wbm_a_ack_i),
            .clk(wbm_a_clk),
            .reset(wbm_a_rst),
            .OK(wbm_OK)
);

vl_wb_ram # (
    .dat_width(32),
    .adr_width(16),
    .memory_init(2),
    .mode("B4"))
main_mem (
    .wbs_dat_i(wbm_b_dat_o),
    .wbs_adr_i(wbm_b_adr_o[17:2]),
    .wbs_sel_i(wbm_b_sel_o),
    .wbs_we_i (wbm_b_we_o),
    .wbs_bte_i(wbm_b_bte_o),
    .wbs_cti_i(wbm_b_cti_o),
    .wbs_stb_i(wbm_b_stb_o),
    .wbs_cyc_i(wbm_b_cyc_o), 
    .wbs_dat_o(wbm_b_dat_i),
    .wbs_stall_o(wbm_b_stall_i),
    .wbs_ack_o(wbm_b_ack_i),
    .wb_clk(wbm_b_clk),
    .wb_rst(wbm_b_rst));

initial
    begin
        #0      wbm_a_rst = 1'b1;
	#200    wbm_a_rst = 1'b0;	
    end

// Wishbone clock
initial
    begin
	#0 wbm_a_clk = 1'b0;
	forever
            #(wb_clk_period/2) wbm_a_clk = !wbm_a_clk;
    end

initial
    begin
        #0      wbm_b_rst = 1'b1;
	#200    wbm_b_rst = 1'b0;	
    end

// Wishbone clock
initial
    begin
	#0 wbm_b_clk = 1'b0;
	forever
            #(wb_clk_period/5) wbm_b_clk = !wbm_b_clk;
    end

initial
    #20000 $finish;
endmodule
