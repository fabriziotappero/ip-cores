`timescale 10ns / 1ns

module tb_ocs_floppy();

reg clk_30;
reg reset_n;

reg [31:0] master_DAT_I;
reg ACK_I;
wire CYC_O;
wire STB_O;
wire WE_O;
wire [31:2] ADR_O;
wire [3:0] SEL_O;
wire [31:0] master_DAT_O;

reg CYC_I;
reg STB_I;
reg WE_I;
reg [8:2] ADR_I;
reg [3:0] SEL_I;
reg [31:0] slave_DAT_I;
wire ACK_O;

reg na_dskbytr_read;
wire [15:0] na_dskbytr;

reg fl_mtr_n;
reg [3:0] fl_sel_n;
reg fl_side_n;
reg fl_dir;
reg fl_step_n;

wire floppy_blk_irq;

reg buffer_CYC_I;
reg buffer_STB_I;
reg buffer_WE_I;
reg [13:2] buffer_ADR_I;
reg [3:0] buffer_SEL_I;
reg [31:0] buffer_DAT_I;
wire buffer_ACK_O;

reg line_start;

ocs_floppy ocs_floppy_inst(
    .clk_30(clk_30),
    .reset_n(reset_n),

    // line counter
    .line_start(line_start),
    
    // management
    .floppy_inserted(1'b1),
    .floppy_sector(32'd600),
    .floppy_error(),
    
    // WISHBONE master
    .CYC_O(CYC_O),
    .STB_O(STB_O),
    .WE_O(WE_O),
    .ADR_O(ADR_O),
    .SEL_O(SEL_O),
    .master_DAT_O(master_DAT_O),
    .master_DAT_I(master_DAT_I),
    .ACK_I(ACK_I),

    // WISHBONE slave
    .CYC_I(CYC_I),
    .STB_I(STB_I),
    .WE_I(WE_I),
    .ADR_I(ADR_I),
    .SEL_I(SEL_I),
    .slave_DAT_I(slave_DAT_I),
    .ACK_O(ACK_O),
    
    // WISHBONE slave floppy buffer
    .buffer_CYC_I(buffer_CYC_I),
    .buffer_STB_I(buffer_STB_I),
    .buffer_WE_I(buffer_WE_I),
    .buffer_ADR_I(buffer_ADR_I),
    .buffer_SEL_I(buffer_SEL_I),
    .buffer_DAT_I(buffer_DAT_I),
    .buffer_DAT_O(),
    .buffer_ACK_O(buffer_ACK_O),    
    
    // dma enable
    .dma_con(16'hFFFF),
    .adk_con(16'hFFFF),

    .floppy_syn_irq(),
    .floppy_blk_irq(floppy_blk_irq),

    // Not Aligned address support
        // DSKBYTR read not implemented here
    .na_dskbytr_read(na_dskbytr_read),
    .na_dskbytr(na_dskbytr),

    // floppy CIA interface
    .fl_rdy_n(),
    .fl_tk0_n(),
    .fl_wpro_n(),
    .fl_chng_n(),
    .fl_index_n(),

    .fl_mtr_n(fl_mtr_n),
    .fl_sel_n(fl_sel_n),
    .fl_side_n(fl_side_n),
    .fl_dir(fl_dir),
    .fl_step_n(fl_step_n),
    
    .floppy_debug(),
    .track_debug()
);

initial begin
    clk_30 = 1'b0;
    forever #5 clk_30 = ~clk_30;
end

initial begin
    line_start = 1'b0;
    forever begin
        #500 line_start = 1'b1;
        #10 line_start = 1'b0;
    end
end

integer start_sd;
integer f,cnt,res;
reg [31:0] mfm_contents [0:1023];
initial begin
	f = $fopenr("/home/alek/1.txt");
	for(cnt=0; cnt<543; cnt=cnt+1) begin
		res = $fscanf(f, "%x", mfm_contents[cnt]);
	end
	$fclose(f);
	
	$display("%x", mfm_contents[0]);
	$display("%x", mfm_contents[1]);
	
	
    ACK_I <= 1'b0;
    master_DAT_I <= 32'd3;
    start_sd = 0;
    
    forever begin
        #20
        if(CYC_O == 1'b1 && STB_O == 1'b1) begin
            if(ADR_O == 30'h04000403) start_sd = 1;
			
			if(ADR_O == 30'h04000400 && WE_O == 1'b0) begin
				master_DAT_I <= 32'd2;
			end
			else if(WE_O == 1'b0) begin
				master_DAT_I <= mfm_contents[ADR_O[11:2]];
			end
            ACK_I <= 1'b1;
            #10
            ACK_I <= 1'b0;
        end
    end
end

//buffer_ACK_O
integer bi;
//integer f,res;
initial begin

    //f = $fopenr("tb_ocs_floppy_sector.txt");
    //res = $fscanf(f, "%x", buffer_DAT_I);

    buffer_CYC_I = 0;
    buffer_STB_I = 0;
    buffer_WE_I = 1;
    buffer_ADR_I = 0;
    buffer_SEL_I = 4'b1111;
    buffer_DAT_I = 0;
    bi = 0;
    
    while(start_sd == 1'b0) begin
        #10;
    end
    #5
    #100
    for(bi=0; bi<1408; bi=bi+1) begin
        #250
		buffer_CYC_I = 1;
        buffer_STB_I = 1;
        buffer_ADR_I = bi;
        
        while(buffer_ACK_O == 1'b0) begin
            #10;
        end
        buffer_CYC_I = 0;
        buffer_STB_I = 0;
    end
end

initial begin
    $dumpfile("tb_ocs_floppy.vcd");
    $dumpvars(0);
    $dumpon();
    
    reset_n = 1'b0;
    ACK_I = 1'b0;
    #10 reset_n = 1'b1;
    
    #10
    fl_mtr_n = 1'b0;
    fl_sel_n = 4'b1111;
    fl_side_n = 1'b1;
    fl_dir = 1'b1;
    fl_step_n = 1'b1;
    
    #10
    fl_sel_n = 4'b1110;
    
    #500000
    
    CYC_I = 1;
    STB_I = 1;
    WE_I = 1;
    ADR_I = 31;
    SEL_I = 4'b1111;
    slave_DAT_I = 32'h00004489;
    
    while(ACK_O == 1'b0) #10;
    
    CYC_I = 0;
    STB_I = 0;
    
    #30
    
    CYC_I = 1;
    STB_I = 1;
    WE_I = 1;
    ADR_I = 9;
    SEL_I = 4'b1111;
    slave_DAT_I = 32'hD7790000;
    
    while(ACK_O == 1'b0) #10;
    
    CYC_I = 0;
    STB_I = 0;

    #30
    
    CYC_I = 1;
    STB_I = 1;
    WE_I = 1;
    ADR_I = 9;
    SEL_I = 4'b1111;
    slave_DAT_I = 32'hD7790000;
    
    while(ACK_O == 1'b0) #10;
    
    CYC_I = 0;
    STB_I = 0;
    
    #200000
    
    
    $finish();
end

endmodule

