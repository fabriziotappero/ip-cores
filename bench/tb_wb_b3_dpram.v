module vl_wb_b3_dpram_tb ();

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
		{32'h100,beat4,eob,32'h87654321,4'b1111,wr,1'b1,1'b1}, // write 0x12345678 @ 0x100 with 01,111
		{32'h100,linear,classic,32'h0,4'b1111,rd,1'b1,1'b1},        // read  @ 0x100
		{32'h0,linear,classic,32'h0,4'b1111,rd,1'b0,1'b0},		
		{32'h100,beat4,inc,32'h00010002,4'b1111,wr,1'b1,1'b1}, // write burst
		{32'h104,beat4,inc,32'h00030004,4'b1111,wr,1'b1,1'b1},
		{32'h108,beat4,inc,32'h00050006,4'b1111,wr,1'b1,1'b1},
		{32'h10c,beat4,eob,32'h00070008,4'b1111,wr,1'b1,1'b1},		
		{32'h104,linear,classic,32'hA1FFFFFF,4'b1000,wr,1'b1,1'b1},// write byte		
		{32'h108,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1}, // read burst
		{32'h10c,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h100,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h104,beat4,eob,32'h0,4'b1111,rd,1'b1,1'b1},		
		{32'h100,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1}, // read burst with strobe going low once
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

parameter [32+2+3+32+4+1+1+1:1] inst_rom1 [0:instructions-1]= {
		{32'h0,linear,classic,32'h0,4'b1111,rd,1'b0,1'b0},
		{32'h200,linear,classic,32'h12345678,4'b1111,wr,1'b1,1'b1}, // write 0x12345678 @ 0x100
		{32'h200,linear,classic,32'h0,4'b1111,rd,1'b1,1'b1},        // read  @ 0x100		
		{32'h200,beat4,eob,32'h87654321,4'b1111,wr,1'b1,1'b1}, // write 0x12345678 @ 0x100 with 01,111
		{32'h200,linear,classic,32'h0,4'b1111,rd,1'b1,1'b1},        // read  @ 0x100
		{32'h0,linear,classic,32'h0,4'b1111,rd,1'b0,1'b0},		
		{32'h200,beat4,inc,32'h00010002,4'b1111,wr,1'b1,1'b1}, // write burst
		{32'h204,beat4,inc,32'h00030004,4'b1111,wr,1'b1,1'b1},
		{32'h208,beat4,inc,32'h00050006,4'b1111,wr,1'b1,1'b1},
		{32'h20c,beat4,eob,32'h00070008,4'b1111,wr,1'b1,1'b1},		
		{32'h204,linear,classic,32'hA1FFFFFF,4'b1000,wr,1'b1,1'b1},// write byte		
		{32'h208,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1}, // read burst
		{32'h20c,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h200,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h204,beat4,eob,32'h0,4'b1111,rd,1'b1,1'b1},		
		{32'h200,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1}, // read burst with strobe going low once
		{32'h204,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h204,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b0},
		{32'h208,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h20c,beat4,eob,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h200,linear,inc,32'hdeaddead,4'b1111,1'b1,1'b1,1'b1}, // write
		{32'h204,linear,eob,32'h55555555,4'b1111,1'b1,1'b1,1'b1}, //		
		{32'h200,linear,inc,32'h0,4'b1111,1'b0,1'b1,1'b1}, // read
		{32'h204,linear,eob,32'h0,4'b1111,1'b0,1'b1,1'b1}, // read
		{32'h200,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1}, // read burst with strobe going low
		{32'h204,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b0},
		{32'h204,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h208,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h208,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b0},
		{32'h20c,beat4,inc,32'h0,4'b1111,rd,1'b1,1'b0},
		{32'h20c,beat4,eob,32'h0,4'b1111,rd,1'b1,1'b1},
		{32'h0,linear,classic,32'h0,4'b1111,rd,1'b0,1'b0}};

	parameter [31:0] dat1 [0:instructions-1] = {
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

vl_wb_b3_dpram 
dut (
    .wbsa_dat_i(wbm_a_dat_o),
    .wbsa_adr_i(wbm_a_adr_o[31:2]),
    .wbsa_cti_i(wbm_a_cti_o),
    .wbsa_bte_i(wbm_a_bte_o),
    .wbsa_sel_i(wbm_a_sel_o),
    .wbsa_we_i (wbm_a_we_o),
    .wbsa_stb_i(wbm_a_stb_o),
    .wbsa_cyc_i(wbm_a_cyc_o), 
    .wbsa_dat_o(wbm_a_dat_i),
    .wbsa_ack_o(wbm_a_ack_i),
    .wbsa_clk(wbm_a_clk),
    .wbsa_rst(wbm_a_rst),
    .wbsb_dat_i(wbm_b_dat_o),
    .wbsb_adr_i(wbm_b_adr_o[31:2]),
    .wbsb_cti_i(wbm_b_cti_o),
    .wbsb_bte_i(wbm_b_bte_o),
    .wbsb_sel_i(wbm_b_sel_o),
    .wbsb_we_i (wbm_b_we_o),
    .wbsb_stb_i(wbm_b_stb_o),
    .wbsb_cyc_i(wbm_b_cyc_o), 
    .wbsb_dat_o(wbm_b_dat_i),
    .wbsb_ack_o(wbm_b_ack_i),
    .wbsb_clk(wbm_b_clk),
    .wbsb_rst(wbm_b_rst));

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

wbm # ( .inst_rom(inst_rom1), .dat(dat1), .testcase("\nTest case:\nwb_b3_dpram B side\n"))
wbmi1(
            .adr_o(wbm_b_adr_o),
            .bte_o(wbm_b_bte_o),
            .cti_o(wbm_b_cti_o),
            .dat_o(wbm_b_dat_o),
	    .sel_o(wbm_b_sel_o),
            .we_o (wbm_b_we_o),
            .cyc_o(wbm_b_cyc_o),
            .stb_o(wbm_b_stb_o),
            .dat_i(wbm_b_dat_i),
            .ack_i(wbm_b_ack_i),
            .clk(wbm_b_clk),
            .reset(wbm_b_rst),
            .OK(wbm_OK)
);

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
            #(wb_clk_period/4) wbm_b_clk = !wbm_b_clk;
    end

initial
    #20000 $finish;
endmodule
