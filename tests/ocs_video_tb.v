`timescale 10ns / 1ns

module ocs_video_tb(
);

// inputs
reg clk;
reg rst_n;

reg [10:0] dma_con;
reg na_clx_dat_read;

wire video_request;

ocs_video ocs_video_inst(
    .CLK_I(clk),
    .reset_n(rst_n),
    
    // WISHBONE master
    .CYC_O(CYC_O),
    .STB_O(STB_O),
    .WE_O(WE_O),
    .ADR_O(ADR_O), /*[31:2]*/
    .SEL_O(SEL_O), /*[3:0]*/
    .master_DAT_I(master_DAT_I), /*[31:0]*/
    .ACK_I(ACK_I),
    
    // WISHBONE slave
    .CYC_I(CYC_I),
    .STB_I(STB_I),
    .WE_I(WE_I),
    .ADR_I(ADR_I), /*[8:2]*/
    .SEL_I(SEL_I), /*[3:0]*/
    .slave_DAT_I(slave_DAT_I), /*[31:0]*/
    .ACK_O(ACK_O),
    
    // video interface
    .video_request(video_request),
    .video_address(), /*[31:2]*/
    .video_data(), /*[35:0]*/
    .video_ready(video_ready),
    
    // line counter
    .line_start(line_start),
    .line_pre_start(line_pre_start),
    .line_number(line_number), /*[8:0]*/
    .column_number(column_number), /*[8:0]*/
    .line_dma_active(),
    
    // Not Aligned address support
        // CLXDAT not implemented here
    .na_clx_dat_read(na_clx_dat_read),
    .na_clx_dat(), /*[14:0]*/
        // INTENA implemented here
    .na_int_ena_write(),
    .na_int_ena(), /*[15:0]*/
    .na_int_ena_sel(), /*[1:0]*/
        // DMACON implemented here
    .na_dma_con_write(),
    .na_dma_con(), /*[15:0]*/
    .na_dma_con_sel(), /*[1:0]*/
    
    // dma enable
   .dma_con(dma_con) /*[10:0]*/
);

initial begin
	clk = 1'b0;
	forever #2 clk = ~clk;
end

reg line_start;
reg line_pre_start;
reg [8:0] line_number;
reg [8:0] column_number;

reg video_ready;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               video_ready <= 1'b0;
    else if(video_request == 1'b1)  video_ready <= 1'b1;
    else                            video_ready <= 1'b0;
end

reg long_frame;
reg [10:0] column_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        line_start <= 1'b0;
        line_pre_start <= 1'b0;
        line_number <= 9'd0;
        column_number <= 9'd0;
        
        column_counter <= 11'd0;
        long_frame <= 1'b0;
    end
    else begin
        if(column_counter == 11'd1919)  column_counter <= 11'd0;
        else                            column_counter <= column_counter + 11'd1;
        
        if(column_counter == 11'd1918)  line_pre_start <= 1'b1;
        else                            line_pre_start <= 1'b0;
        
        if(column_counter == 11'd1919)  line_start <= 1'b1;
        else                            line_start <= 1'b0;
        
        if(column_counter == 11'd1919) begin
            column_number <= 9'd0;
            
            if(line_number == 9'd311 && long_frame == 1'b0) begin
                line_number <= 9'd0;
                long_frame <= 1'b1;
            end
            else if(line_number == 9'd312 && long_frame == 1'b1) begin
                line_number <= 9'd0;
                long_frame <= 1'b0;
            end
            else line_number <= line_number + 9'd1;
        end
        else if(column_counter > 11'd600 /*time for 6 bitplain*/) begin
            if(column_counter[0] == 1'b1 && column_number < 9'd452 /*226*2*/)  column_number <= column_number + 9'd1;
        end
    end
end

// WISHBONE slave
reg CYC_I;
reg STB_I;
reg WE_I;
reg [8:2] ADR_I;
reg [3:0] SEL_I;
reg [31:0] slave_DAT_I;

wire ACK_O;

reg slave_state;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        CYC_I <= 1'b0;
        STB_I <= 1'b0;
        WE_I <= 1'b0;
        ADR_I <= 7'b0;
        SEL_I <= 4'b0;
        slave_DAT_I <= 32'b0;
        
        slave_state <= 1'b0;
    end
    else if(slave_state == 1'b0 && ACK_O == 1'b0) begin
        CYC_I <= 1'b1;
        STB_I <= 1'b1;
        WE_I <= 1'b1;
        ADR_I <= 7'h60;
        SEL_I <= 4'b1100;
        slave_DAT_I <= 32'hA9000000;
    end
    else if(slave_state == 1'b0 && ACK_O == 1'b1) begin
        CYC_I <= 1'b0;
        STB_I <= 1'b0;
        WE_I <= 1'b0;
        ADR_I <= 7'b0;
        SEL_I <= 4'b0;
        slave_DAT_I <= 32'b0;
        
        slave_state <= 1'b1;
    end
end

// WISHBONE master
wire CYC_O;
wire STB_O;
wire WE_O;
wire [31:2] ADR_O;
wire [3:0] SEL_O;

reg [31:0] master_DAT_I;
reg ACK_I;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        master_DAT_I <= 32'd0;
        ACK_I <= 1'b0;
    end
end

initial begin
    $dumpfile("ocs_video.vcd");
	$dumpvars(0);
	$dumpon();
	
	rst_n = 1'b0;
	
	dma_con = 11'b0;
    na_clx_dat_read = 1'b0;
	
	#10
	rst_n = 1'b1;
	
	//full frame: #2500000
	#500000
	
	$dumpoff();
	
	$finish();
end

endmodule

