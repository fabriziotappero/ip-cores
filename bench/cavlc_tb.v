//2011-8-12  initial version

`include "defines.v"

module cavlc_tb;

//------------------------------------------------
// task : read inputs(nC, rbsp, max_coff_num)
//------------------------------------------------
reg     [0:1023]    rbsp_data;
reg     [7:0]  ch;
integer fp_r, fp_w;
integer rbsp_length;
integer rbsp_offset;
integer i;
reg     signed  [5:0]   nC_t;
reg     [4:0]   max_coeff_num_t;    
task read_test_data;
//format
//AA BB CCC DDD.......
//AA:   nC
//BB:   max_coeff_num
//CCC:  length of D
//DD... rbsp bits 
    begin
        //nC_t
        ch  = $fgetc(fp_r);
        if (ch == 8'h2d)
        begin
            nC_t = -1;
            ch = $fgetc(fp_r);
            ch = $fgetc(fp_r);
        end
        else
        begin
            nC_t = ch - 8'h30;
            ch  = $fgetc(fp_r);
            if (ch != 8'h20)
            begin
                nC_t = nC_t * 10 + ch -8'h30;
            end
            ch = $fgetc(fp_r);  
        end 
        
        //max_coeff_num
        ch  = $fgetc(fp_r);
        max_coeff_num_t =  ch -8'h30;
        
        ch  = $fgetc(fp_r);
        if (ch != 8'h20)
        begin
            max_coeff_num_t = max_coeff_num_t * 10 + ch -8'h30;
        end
        
        ch  = $fgetc(fp_r);
        
        //rbsp_length
        ch  = $fgetc(fp_r);
        rbsp_length = ch -8'h30;
        
        ch  = $fgetc(fp_r);
        if (ch != 8'h20)
        begin
            rbsp_length = rbsp_length * 10 + ch -8'h30;
        end
        
        ch  = $fgetc(fp_r);
        if (ch != 8'h20)
        begin
            rbsp_length = rbsp_length * 10 + ch -8'h30;
        end
        
        ch  = $fgetc(fp_r);
        
        //rbsp
        rbsp_data = 0;
        for(i = 0; i < rbsp_length; i = i+1)
        begin
            ch  = $fgetc(fp_r);
            if (ch == 8'h30)
                rbsp_data[i] = 1'b0;
            else if (ch == 8'h31)
                rbsp_data[i] = 1'b1;
            else 
            begin
		        $fclose(fp_r);
		        $fclose(fp_w);
		        $display(" >> end of file @ %d", $time);
		        $display(" >> tested cavlc blocks : %d", blk_num);
		        $finish;
            end
        end
        ch  = $fgetc(fp_r);
    end
endtask

//-----------------------------------------------------------------------------
// dut
//-----------------------------------------------------------------------------
reg     clk;
reg		rst_n;
reg     ena;
reg     start;
reg     [0:15]  rbsp;
reg     signed  [5:0]   nC;
reg     [4:0]   max_coeff_num;

wire signed [8:0]   coeff_0;
wire signed [8:0]   coeff_1;
wire signed [8:0]   coeff_2;
wire signed [8:0]   coeff_3;
wire signed [8:0]   coeff_4;
wire signed [8:0]   coeff_5;
wire signed [8:0]   coeff_6;
wire signed [8:0]   coeff_7;
wire signed [8:0]   coeff_8;
wire signed [8:0]   coeff_9;
wire signed [8:0]   coeff_10;
wire signed [8:0]   coeff_11;
wire signed [8:0]   coeff_12;
wire signed [8:0]   coeff_13;
wire signed [8:0]   coeff_14;
wire signed [8:0]   coeff_15;

wire    [4:0]   TotalCoeff; 
wire    [4:0]   len_comb;
wire    idle;
wire    valid;

cavlc_top dut(
    clk,
    rst_n,
    ena,
    start,
    rbsp,
    nC,
    max_coeff_num,

    coeff_0,
    coeff_1,
    coeff_2,
    coeff_3,
    coeff_4,
    coeff_5,
    coeff_6,
    coeff_7,
    coeff_8,
    coeff_9,
    coeff_10,
    coeff_11,
    coeff_12,
    coeff_13,
    coeff_14,
    coeff_15,
    TotalCoeff,
    len_comb,
    idle,
    valid
);

parameter
	Tp = 3,
	TestBlockNum = 10000;	//number of cavlc blocks to test

//-----------------------------------------------------------------------------
// clock and reset
//-----------------------------------------------------------------------------
initial
begin
	clk = 0;
	rst_n = 1;
	# 10 rst_n = 0;
	repeat(2) @(posedge clk);
	rst_n = #5 1;
end

initial
forever #10 clk = ~clk;

//-----------------------------------------------------------------------------
// generate module enable signal
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
if (!rst_n)
    ena  <= #Tp 0;
else 
    ena  <= #Tp 1; // always 1, or use {$random} % 2;

//-----------------------------------------------------------------------------
// generate start signal
//-----------------------------------------------------------------------------
initial
begin
   start = 0;
   @(negedge rst_n);
   @(posedge rst_n);
   forever
   begin
      @(posedge clk);
      start = #Tp 1;
      @(posedge clk);
      start = #Tp 0;   //start must be high for one cycle
      @(posedge valid);
   end
end

//-----------------------------------------------------------------------------
// generate rbsp data and deal with forward_len
//-----------------------------------------------------------------------------
always @(*) rbsp <= # Tp rbsp_data[rbsp_offset +: 16];

always @(posedge clk or negedge rst_n)
if (!rst_n)
    rbsp_offset <=  0;
else if (!idle && ena)
    rbsp_offset <=  rbsp_offset + len_comb;
else if(ena)
    rbsp_offset <=  0;
    
    
//-----------------------------------------------------------------------------
// generate inputs(nC, max_coff_num) from 'in.txt' and display output to 'out.txt'
//-----------------------------------------------------------------------------
integer blk_num;
initial
begin
    fp_r = $fopen("in.txt", "r");
    fp_w = $fopen("out.txt", "w");
    if (fp_r == 0 || fp_w == 0)
    begin
    	$display(" >> can not open 'in.txt' or 'out.txt'");
    	$finish;
    end
    blk_num = 0;
    while(blk_num < TestBlockNum)
    begin
        read_test_data;
        nC =  nC_t;
        max_coeff_num =  max_coeff_num_t;
        @(posedge valid);
        blk_num = blk_num + 1;
        @(posedge clk);
        $fdisplay(fp_w, "blk_num:%-5dnC:%-5dTotalCoeff:%-5d", blk_num, nC, TotalCoeff);
        $fdisplay(fp_w, "%5d%5d%5d%5d", coeff_0, coeff_1, coeff_2, coeff_3);
        $fdisplay(fp_w, "%5d%5d%5d%5d", coeff_4, coeff_5, coeff_6, coeff_7);
        $fdisplay(fp_w, "%5d%5d%5d%5d", coeff_8, coeff_9, coeff_10, coeff_11);
        $fdisplay(fp_w, "%5d%5d%5d%5d\n", coeff_12, coeff_13, coeff_14, coeff_15);
    end
   $fclose(fp_r);
   $fclose(fp_w);
   $display(" >> done @ %d", $time);
   $display(" >> tested cavlc blocks : %d", blk_num);
   $finish;
end


endmodule
