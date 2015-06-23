`include	"../define.v"

module minimum_number#(
	parameter NUM_OF_INPUTS		=	8,
	parameter DATA_WIDTH			=	5,
	parameter IN_ARRAY_WIDTH	=	NUM_OF_INPUTS	* DATA_WIDTH
)
(
	input  [IN_ARRAY_WIDTH-1			:	0] in_array,
	output [NUM_OF_INPUTS-1				:	0]	min_out
);

		`LOG2
		localparam  COMP_PARAL_NUM		=	log2(NUM_OF_INPUTS);
		
		wire [DATA_WIDTH-1				:	0]	numbers				[NUM_OF_INPUTS-1			:0];	
		wire [DATA_WIDTH-1				: 	0] first_in_array		[NUM_OF_INPUTS-2			:0];
		wire [DATA_WIDTH-1				: 	0] second_in_array	[NUM_OF_INPUTS-2			:0];
		wire [DATA_WIDTH-1				: 	0] min_out_array		[NUM_OF_INPUTS-2			:0];
		wire [NUM_OF_INPUTS-2			:	0] comp;
		wire [NUM_OF_INPUTS-2			:	0] comp_not;
		wire [(NUM_OF_INPUTS-1)*2-1	:	0] comp_all;
		wire [NUM_OF_INPUTS-1			:	0]	min_out_gen			[COMP_PARAL_NUM-1			:0];	
		wire [COMP_PARAL_NUM-1			:	0] min_out_t			[NUM_OF_INPUTS-1			:0];	
		
genvar i,j;		
generate 
	if(NUM_OF_INPUTS==1)begin
		assign min_out = 1'b1;
	end
	else begin //(vc num >1)
		
		
		for(i=0;i<(NUM_OF_INPUTS/2);i=i+1) begin :min_detect_loop1
			assign first_in_array	[i]	=  numbers		[i*2];
			assign second_in_array	[i] 	=  numbers		[(i*2)+1];
		end //for
		for(i=0;i<((NUM_OF_INPUTS/2)-1);i=i+1) begin :min_detect_loop2
			assign first_in_array	[i+(NUM_OF_INPUTS/2)]	=  min_out_array		[i*2];
			assign second_in_array	[i+(NUM_OF_INPUTS/2)] =  min_out_array		[(i*2)+1];
		end //for
		for(i=0;i<(NUM_OF_INPUTS-1);i=i+1) begin :min_detect_loop3
			
			two_in_min_detect#( 
				.DATA_WIDTH(DATA_WIDTH)		
			)
				min_detect
			(
				.first_in	(first_in_array[i]),     
				.second_in	(second_in_array[i]),
				.comp			(comp[i]),
				.min_out		(min_out_array[i])
			);
			
		end //for
		
		
		assign comp_not = ~ comp;
		for(i=0;i<(NUM_OF_INPUTS-1);i=i+1) begin :comp_loop
			assign comp_all[i*2+1	:	i*2] = {comp[i] ,comp_not[i]};
		end//for 
		
		for (j=0; j< COMP_PARAL_NUM	; j=j+1)begin: min_out_loop1
			for(i=0; i<NUM_OF_INPUTS;  i=i+1) begin : min_out_loop2
				if(j==0) 		assign min_out_gen[j][i]  = comp_all[i];
				else if(j==1)	assign min_out_gen[j][i]  = comp_all[NUM_OF_INPUTS+(i/2)];
				else if(j==2)	assign min_out_gen[j][i]  = comp_all[NUM_OF_INPUTS+(NUM_OF_INPUTS/2)+(i/4)];
				else 				assign min_out_gen[j][i]  = comp_all[NUM_OF_INPUTS+(NUM_OF_INPUTS/2)+(NUM_OF_INPUTS/4)+(i/8)];
				assign min_out_t[i][j]	= min_out_gen[j][i];
			end // for i
			
		end//for j
		
		for(i=0; i<NUM_OF_INPUTS;  i=i+1) begin : min_out_final
			assign min_out[i] = & min_out_t[i];
			assign numbers[i]	= in_array	[(i+1)* DATA_WIDTH-1: i*DATA_WIDTH];
		
		end//for
	 	
	end// (vc num >1)
	endgenerate

endmodule



//detecting the minumom of two input
module two_in_min_detect#(
	parameter DATA_WIDTH				=	4
	)	
	(
	input 		[DATA_WIDTH-1				:0] 	first_in,   
	input			[DATA_WIDTH-1				:0]	second_in,	
	output 												comp,
	output 		[DATA_WIDTH-1				:0]	min_out
	);
	
	assign comp		=	(first_in <= second_in);
	assign min_out = (comp)? first_in : second_in;

endmodule


/**********************************


compar all numbers in prallel. needs more hardware cost 
but it is faster when the total numbers is big 

***********************************/


module fast_minimum_number#(
	parameter NUM_OF_INPUTS		=	8,
	parameter DATA_WIDTH			=	5,
	parameter IN_ARRAY_WIDTH	=	NUM_OF_INPUTS	* DATA_WIDTH
)
(
	input  [IN_ARRAY_WIDTH-1			:	0] in_array,
	output [NUM_OF_INPUTS-1				:	0]	min_out
);

	genvar i,j;
	wire [DATA_WIDTH-1					:	0]	numbers				[NUM_OF_INPUTS-1			:0];	
	wire [NUM_OF_INPUTS-2				:	0]	comp_array			[NUM_OF_INPUTS-1			:0];	
		
	generate
	if(NUM_OF_INPUTS==1)begin
		assign min_out = 1'b1;
	end
	else begin //(vc num >1)
		for(i=0; i<NUM_OF_INPUTS;  i=i+1) begin : loop_i
				assign numbers[i]	= in_array	[(i+1)* DATA_WIDTH-1: i*DATA_WIDTH];
				for(j=0; j<NUM_OF_INPUTS-1;  j=j+1) begin : loop_j
							if(i>j)	assign comp_array [i][j] = ~ comp_array [j][i-1];
							else 		assign comp_array [i]	[j] = numbers[i]<= numbers[j+1];
				end//for j
				assign min_out[i]=	& comp_array[i];
		end//for i
	end//else
	endgenerate
	
endmodule
	