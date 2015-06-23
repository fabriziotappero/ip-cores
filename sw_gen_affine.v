module sw_gen_affine(clk,
             rst,
             i_query_length,
				 i_local,
             query,
             i_vld,
             i_data,
             o_vld,
             m_result
                );

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

parameter LOGLENGTH=6;                  //log2(total number of comparison blocks instantiated)
//parameter LENGTH = 1 << LOGLENGTH;      //total number of comparison blocks instantiated - query length must be less than this
parameter LENGTH = 48;

input wire rst;
input wire clk;
input wire [1:0] i_data;
input wire i_local;		//=1 if local alignment, =0 if global alignment
input wire [LOGLENGTH-1:0] i_query_length;            //this is the (length_of_the_actual_query_string - 1) (must be less than the max length value - 0=1 block, 1=2 blocks, etc)
input wire [(LENGTH*2-1):0] query;                  //this is the actual query sequence - query[1:0] goes into block0, query [3:2] goes into block1, etc.

output wire o_vld;
output wire [SCORE_WIDTH-1:0] m_result;

wire [2*(LENGTH-1)+1:0] data;

input wire i_vld;             //master valid signal at start of chain
wire vld[LENGTH-1:0];

wire [SCORE_WIDTH-1:0] right_m[LENGTH-1:0];			//the 'match' matrix cell value array 
wire [SCORE_WIDTH-1:0] right_i[LENGTH-1:0];			//the 'indel' matrix cell value array
wire [SCORE_WIDTH-1:0] high_score [LENGTH-1:0];		//the 'current highest score' array
wire [LENGTH-1:0] gap;
wire [LENGTH-1:0] reset;


assign o_vld = vld[i_query_length];
assign m_result = i_local ? high_score[i_query_length] : ((right_m[i_query_length] > right_i[i_query_length]) ? right_m[i_query_length] : right_i[i_query_length]);

//assign query={N_A,N_G,N_T,N_T};

genvar i;
generate
for (i=0; i < LENGTH; i = i + 1)
   begin: pe_block
      if (i == 0)                       //first processing element in auto-generated chain
		begin: pe_block0
         sw_pe_affine pe0(.clk(clk),
             .i_rst(rst),
				 .o_rst(reset[i]),
             .i_data(i_data[1:0]),
             .i_preload(query[1:0]),
             .i_left_m(11'b10000000000),
				 .i_left_i(11'b10000000000),
             .i_vld(i_vld),
				 .i_local(i_local),
				 .i_high(11'b0),
             .o_right_m(right_m[i]),
				 .o_right_i(right_i[i]),
				 .o_high(high_score[i]),
             .o_vld(vld[i]),
             .o_data(data[2*i+1:2*i]),
             .start(1'b1));
		end
		else         //processing elements other than first one
		begin: pe_block1
         sw_pe_affine pe1(.clk(clk),
             .i_rst(reset[i-1]),
				 .o_rst(reset[i]),
             .i_data(data[2*(i-1)+1:(i-1)*2]),
             .i_preload(query[i*2+1:i*2]),
             .i_left_m(right_m[i-1]),
				 .i_left_i(right_i[i-1]),
             .i_local(i_local),
             .i_vld(vld[i-1]),
				 .i_high(high_score[i-1]),
             .o_right_m(right_m[i]),
				 .o_right_i(right_i[i]),
				 .o_high(high_score[i]),
             .o_vld(vld[i]),
             .o_data(data[2*(i)+1:2*(i)]),
             .start(1'b0));
		end
   end
endgenerate


endmodule