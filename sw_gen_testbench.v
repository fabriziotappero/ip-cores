module sw_gen_testbench;
	    /*(clk,
             rst,
             i_targ_length,
             target,
             i_vld,
             i_data,
             o_vld,
             m_result
                );*/

localparam
    SCORE_WIDTH = 11,
    N_A = 2'b00,        //nucleotide "A"
    N_G = 2'b01,        //nucleotide "G"
    N_T = 2'b10,        //nucleotide "T"
    N_C = 2'b11,        //nucleotide "C"
    INS = 1,            //insertion penalty
    DEL = 1,            //deletion penalty
    TB_UP = 2'b00,      //"UP" traceback pointer
    TB_DIAG = 2'b01,    //"DIAG" traceback pointer
    TB_LEFT = 2'b10;    //"LEFT" traceback pointer

parameter LOGLENGTH=3;                  //log2(total number of comparison blocks instantiated)
parameter LENGTH = 4;      //total number of comparison blocks instantiated - target length must be less than this

reg rst;
reg clk;
reg i_local;
reg [1:0] i_data;

wire [LOGLENGTH-1:0] i_targ_length;            //this is the (length_of_the_actual_target_string - 1) (must be less than the max length value - 0=1 block, 1=2 blocks, etc)
wire [(LENGTH*2-1):0] target;                  //this is the actual target sequence - target[1:0] goes into block0, target[3:2] goes into block1, etc.

wire o_vld;
wire [SCORE_WIDTH-1:0] m_result;
wire [SCORE_WIDTH-1:0] i_result;
wire [SCORE_WIDTH-1:0] h_result;
wire [2*(LENGTH-1)+1:0] data;

reg i_vld;             //master valid signal at start of chain
wire vld[LENGTH-1:0];
wire reset[LENGTH-1:0];

//wire [SCORE_WIDTH*(LENGTH-1)+SCORE_WIDTH-1:0] right;
wire [SCORE_WIDTH-1:0] right_m [LENGTH-1:0];
wire [SCORE_WIDTH-1:0] right_i [LENGTH-1:0];
wire [SCORE_WIDTH-1:0] high  [LENGTH-1:0];
wire [LENGTH-1:0] gap;

//wire [LENGTH-1:0] done;

reg [SCORE_WIDTH-1:0] final_score;



assign o_vld = vld[3];
//assign m_result = right[i_targ_length];

assign target={N_G,N_C,N_C,N_C};
//assign i_targ_length = 3;
genvar i;

assign i_targ_length = 2'b11;
assign m_result = right_m[LENGTH-1];
assign i_result = right_i[LENGTH-1];
assign h_result = high[LENGTH-1];

generate
for (i=0; i < LENGTH; i = i + 1)
   begin: pe_block
      if (i == 0)                       //first module in auto-generated chain
         sw_pe_affine #(.LENGTH(LENGTH), .LOGLENGTH(LOGLENGTH)) 
            pe0 (.clk(clk),
             .i_rst(rst),
	     .o_rst(reset[i]),
             .i_data(i_data[1:0]),
             .i_preload(target[1:0]),
             .i_left_m(11'b10000000000),
	     .i_left_i(11'b10000000000),
             .i_lgap(1'b0),
             .i_vld(i_vld),
	     .i_local(i_local),
             .o_right_m(right_m[i]),
	     .o_right_i(right_i[i]),
	     .i_high(11'b10000000000),
	     .o_high(high[i]),
             .o_rgap(gap[i]),
             .o_vld(vld[i]),
             .o_data(data[2*i+1:2*i]),
             .start(1'b1));
             //.done(done[i]));
      else         //modules other than first one
         sw_pe_affine #(.LENGTH(LENGTH), .LOGLENGTH(LOGLENGTH)) 
            pe1 (.clk(clk),
             .i_rst(reset[i-1]),
             .o_rst(reset[i]),
             .i_data(data[2*(i-1)+1:(i-1)*2]),
             .i_preload(target[i*2+1:i*2]),
             .i_left_m(right_m[i-1]),
             .i_left_i(right_i[i-1]),
             .i_lgap(gap[i-1]),
             .i_vld(vld[i-1]),
             .i_local(i_local),
             .o_right_m(right_m[i]),
	     .o_right_i(right_i[i]),
	     .i_high(high[i-1]),
	     .o_high(high[i]),
             .o_rgap(gap[i]),
             .o_vld(vld[i]),
             .o_data(data[2*(i)+1:2*(i)]),
             .start(1'b0));
            // .done(done[i]));

   end

endgenerate




initial
 begin
        $dumpfile("sw_gen_testbench.dump");
        $dumpvars (0,sw_gen_testbench);
        rst <= 1'b1;
        clk <= 1'b0;
        i_vld <= 1'b0;
        i_data <= 2'b00;
        i_local <= 1'b1;
        #22
        rst <= 1'b0;
        #100
        i_data <= N_G;
        i_vld <= 1'b1;
        #20
        i_data <= N_G;
        #20
        i_data <= N_G;
        #20
        i_data <= N_C;
        #20
        i_vld <= 1'b0;
        #200
        $finish();

 end

always
 begin
        #10 clk <= ~clk;
 end







endmodule
