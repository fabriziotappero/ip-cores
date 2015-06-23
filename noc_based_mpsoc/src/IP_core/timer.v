
`include "../define.v"

module timer #(
		parameter	DATA_WIDTH		=	32,
		parameter	COUNTER_WIDTH	=	32,
		parameter 	SEL_WIDTH		=	4,
		parameter	ADDR_WIDTH		=	3
		


)(
	input 										clk,
	input											reset,
	// wishbone interface
	input		[DATA_WIDTH-1		:	0]		sa_dat_i,
	input		[SEL_WIDTH-1		:	0]		sa_sel_i,
	input		[ADDR_WIDTH-1		:	0]		sa_addr_i,	
	input											sa_stb_i,
	input											sa_we_i,
	output	[DATA_WIDTH-1		:	0]		sa_dat_o,
	output 	reg								sa_ack_o,
	//intruupt interface
	output 									  	irq
);

`LOG2

localparam TCSR_REG_ADDR	=	0;	//timer control register
localparam TLR_REG_ADDR		=	1;	//timer load register
localparam TCMP_REG_ADDR	=	2;// timer compare value register

localparam	MAX_CLK_DEV		=	256;
localparam	DEV_COUNT_WIDTH=	log2(MAX_CLK_DEV);
localparam	DEV_CTRL_WIDTH	=	log2(DEV_COUNT_WIDTH);

localparam TCSR_REG_WIDTH	=	4+DEV_CTRL_WIDTH;
localparam TCR_REG_WIDTH	=	TCSR_REG_WIDTH-1;
/***************************
tcr: timer control register
bit 

6-3:	clk_dev_ctrl
3	:	timer_isr
2	:	rst_on_cmp_value
1	:	int_enble_on_cmp_value
0	:	timer enable 




***************************/
reg 	[TCSR_REG_WIDTH-1		:	0]	tcsr;
wire	[TCSR_REG_WIDTH-1		:	0]	tcsr_next;	//timer control register 
reg	[TCR_REG_WIDTH-1		:	0]	tcr_next;
reg	timer_isr_next;

reg 	[DEV_COUNT_WIDTH-1	:	0]	clk_dev_counter,clk_dev_counter_next;

wire 	[DEV_COUNT_WIDTH-1	:	0]	dev_one_hot;
wire	[DEV_COUNT_WIDTH-2	:	0]	dev_cmp_val;

wire timer_en,int_en,rst_on_cmp,timer_isr;
wire clk_dev_rst,counter_rst;
wire [DEV_CTRL_WIDTH-1	:	0] clk_dev_ctrl;



reg [COUNTER_WIDTH-1		:	0]	counter,counter_next,cmp,cmp_next,read,read_next;



assign {timer_isr,clk_dev_ctrl,rst_on_cmp,int_en,timer_en} = tcsr;
assign dev_cmp_val	=	dev_one_hot[DEV_COUNT_WIDTH-1	:	1];
assign clk_dev_rst	=	clk_dev_counter	==	dev_cmp_val;
assign counter_rst	=	(rst_on_cmp)? (counter		==	cmp) : 1'b0;
assign sa_dat_o		=	read;
assign irq = timer_isr;
assign tcsr_next		={timer_isr_next,tcr_next};
bcd_to_one_hot #(
	.BCD_WIDTH		(DEV_CTRL_WIDTH),
	.ONE_HOT_WIDTH	(DEV_COUNT_WIDTH)
	)
	conv
	(
	.bcd_code		(clk_dev_ctrl),
	.one_hot_code	(dev_one_hot)
	);

	always @(posedge clk or posedge reset) begin 
		if(reset) begin 
			counter				<= {COUNTER_WIDTH{1'b0}};
			cmp					<=	{COUNTER_WIDTH{1'b1}};
			clk_dev_counter	<=	{DEV_COUNT_WIDTH{1'b0}};
			tcsr					<=	{TCR_REG_WIDTH{1'b0}};
			read					<=	{COUNTER_WIDTH{1'b0}};
			sa_ack_o				<=	1'b0;
		end else begin 
			counter				<= counter_next;
			cmp					<=	cmp_next;
			clk_dev_counter	<=	clk_dev_counter_next;
			tcsr					<=	tcsr_next;
			read					<= read_next;
			sa_ack_o				<= sa_stb_i && ~sa_ack_o;
		end
	end
	
	always@(*)begin 
		counter_next			= counter;
		clk_dev_counter_next	= clk_dev_counter;
		timer_isr_next			=(timer_isr | (counter_rst & clk_dev_rst) ) &  int_en;
		tcr_next					= tcsr[TCR_REG_WIDTH-1		:	0];
		cmp_next					= cmp;
		read_next				=	read;
		//counters
		if(timer_en)begin 
				if(clk_dev_rst)	begin 
					clk_dev_counter_next	=	{DEV_COUNT_WIDTH{1'b0}};
					if(counter_rst) begin 
						counter_next	=	{COUNTER_WIDTH{1'b0}};
					end else begin 
						counter_next	=	counter +1'b1;
					end // count_rst
				end else begin
						clk_dev_counter_next	=	clk_dev_counter	+1'b1;
				end //dev_rst
		end//time_en
		
		if(sa_stb_i )begin
			if(sa_we_i ) begin 
				case(sa_addr_i)
					TCSR_REG_ADDR:	begin 
						tcr_next 		= 	sa_dat_i[TCR_REG_WIDTH-1	:	0];
						timer_isr_next	=	timer_isr & ~sa_dat_i[TCSR_REG_WIDTH-1];// reset isr by writting 1
					end
					TLR_REG_ADDR:	counter_next	= 	sa_dat_i[COUNTER_WIDTH-1	:	0];
					TCMP_REG_ADDR:	cmp_next			=	sa_dat_i[COUNTER_WIDTH-1	:	0];	
					default:			cmp_next			= 	cmp;
				endcase
			end//we
			else begin
				case(sa_addr_i)
					TCSR_REG_ADDR:	read_next		=	tcsr;
					TLR_REG_ADDR:	read_next		=	counter;
					TCMP_REG_ADDR:	read_next		=	cmp;
					default:			read_next		=	read;
				endcase
			end
		end//stb
	end//always



endmodule
