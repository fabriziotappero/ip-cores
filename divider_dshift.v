module	divider_dshift(
input	i_clk,
input	i_rst,
input	[31:0]i_dividend,
input	[31:0]i_divisor,
input	i_start,
output	o_ready,
output	reg	[31:0]o_quotient,
output	reg	[31:0]o_remainder
);

parameter	
		state_1=1,
		state_2=2,
		state_3=4,
		state_4=8,
		state_5=16,
		state_6=32;


reg	[31:0]PR;		//partial remainder
reg	signed[31:0]PR_1;
reg	[31:0]DR;		//divisor
reg	[5:0]ct,ct_1;		// ct: index for quotient bit under calculation	ct_1: shift value for last PR
reg	ct_1_en,ct_1_en_1;			// enable calculating of ct_1
reg	DD_sign;		//sign of dividend
reg	[5:0]state;
reg	ready;
assign	o_ready=ready?i_start:0;
reg	[30:0]nq;	//negative quotient
reg	[30:0]q;	//positive quotient
wire	[30:0]nqp1;	// nq+1
wire	[30:0]qp1;	// q+1
assign	nqp1=nq+1;
assign	qp1=q+1;

wire	[31:0]nDR;
assign	nDR=~DR;
wire	nsub;	// not sub	'1' means PR=PR+DR;
		//		'0' means PR=PR-DR;
assign	nsub=PR[31]^DR[31];


/// over subtract detection during final results adjustment
wire	over_sub;
//assign	over_sub=(state==state_4)||(state==state_3)?DD_sign^PR[62]&(PR[62:31]!=0):0;
assign	over_sub=(DD_sign^PR[31])&(PR[31:0]!=0);
//reg	over_sub;
wire	addback_nDR;
wire	addback_DR;
assign	addback_nDR=over_sub&(~nsub);
assign	addback_DR=over_sub&nsub;
///
/// results adjustment
wire	[30:0]final_nq,final_q;
assign	final_nq=addback_DR?nqp1:nq;
assign	final_q=addback_nDR?qp1:q;
wire	[31:0]remainder_addback;
assign	remainder_addback=	addback_DR?i_divisor:
				addback_nDR?~i_divisor:0;
///

/// main subtractor 
wire	[31:0]a,b;
wire	[31:0]sum;
wire	carry_in;
wire	carry_out;

reg	[31:0]reg_a,reg_b;
reg	reg_carry;
reg	[1:0]state_reg;

///////////// Dynamic Shift /////////////
reg	[4:0]shifted,shifted_1;
reg	[31:0]sdata;
wire	[31:0]sdata_o;
wire	[4:0]shifted_o;
shifter	shifter_0(
sdata,
sdata_o,
shifted_o
);

/*
assign	a=	
		state==state_4?{1'b1,~final_nq}:
		state==state_5?remainder_addback:
		nsub?DR:nDR;
*/
assign	a=	ct_1_en?{27'd0,shifted_1}:
		state==state_4?{1'b1,~final_nq}:
		state==state_5?remainder_addback:
		nsub?DR:nDR;
assign	b=	ct_1_en?{26'd0,ct_1}:
		state==state_4?{1'b0,final_q}:
		state==state_5?PR_1:PR;

assign	carry_in=	ct_1_en?0:
		state==state_4?1:
		state==state_5?	addback_nDR?1:0:
		nsub?0:1;
		
adder_32bit	adder_0(
reg_a,
reg_b,
reg_carry,
sum,
carry_out
);




// ct calculation
//reg	UDR;	// update Divisor
wire	[5:0]sum_ct;
wire	[25:0]sum_ct_h;
wire	carry_ct;
adder_32bit	adder_1(
{26'd0,ct},
state[5]?{27'd0,shifted}:~{27'd0,shifted},
state[5]?1'b0:1'b1,
{sum_ct_h,sum_ct},
carry_ct
);






///////////////////////////////////////////

always@(posedge i_clk or negedge i_rst)
	if(!i_rst)begin
		sdata<=0;
		shifted<=0;
		shifted_1<=0;
		PR<=0;
		PR_1<=0;
		DR<=0;
		//UDR<=0;
		ready<=0;
		ct<=0;
		ct_1<=0;
		ct_1_en<=0;
		ct_1_en_1<=0;
		state<=state_1;
		DD_sign<=0;
		o_quotient<=0;
		o_remainder<=0;
		nq<=0;
		q<=0;
		//over_sub<=0;
		reg_a<=0;
		reg_b<=0;
		reg_carry<=0;
		state_reg<=0;
	end
	else begin
		if(ready&&(!i_start))ready<=0;
		case(state_reg)
		0:
		case(state)
			state_1:if((!ready)&&i_start)begin
				sdata<=i_divisor;
				state<=state_6;
				q<=0;
				nq<=0;
				shifted<=0;
				//UDR<=1;
			end
			state_2:begin
				sdata<=i_dividend;
				PR_1<=i_dividend;
				DD_sign<=i_dividend[31];
				state<=state_3;
				state_reg<=1;	
			end
			state_3:begin
				if(ct[5])begin
					state<=state_4;
					ct<=0;
					state_reg<=2;
				end
				else begin
					ct_1_en<=1;
					shifted_1<=shifted;
					nq[ct]<=nsub;
					q[ct]<=~nsub;				
					sdata<=sum;
					state_reg<=1;
				end
			end
			state_4:begin
				state<=state_5;
				o_quotient<=sum;
				PR_1<=PR_1>>>ct_1;
				state_reg<=2;
			end
			state_5:begin
				o_remainder<=sum;
				ct_1<=0;
				state<=state_1;
				ready<=1;
			end

			state_6:begin
				sdata<=sdata_o;
				shifted<=shifted_o;
				ct<=sum_ct;
				if(sdata[31]!=sdata[30])begin
					state<=state_2;
					DR<=sdata;
				end
			end
/*
			state_6:begin
				//if(!over_sub)o_remainder<=sum>>>ct_1;
				o_remainder<=sum;
				ct_1<=0;
				state<=state_1;
				ready<=1;
			end

*/
		endcase
		1:begin
			PR<=sdata_o;
			PR_1<=sdata;
/*
			if(UDR)begin
				UDR<=0;
				ct<=shifted;

				if(shifted==0)begin
					ct<=0;
				end
				else begin
					ct<=shifted-1;
					DR<={DR[31],DR[31:1]};
				end

			end
*/
			shifted<=shifted_o;
			state_reg<=2;
			reg_a<=a;	//calculate ct_1
			reg_b<=b;
			reg_carry<=carry_in;
			ct_1_en<=0;
			ct_1_en_1<=ct_1_en;
		end
		2:begin
			if(state==state_3)begin
				ct<=sum_ct;
			end
			state_reg<=0;
			if(ct_1_en_1)begin
				ct_1<=sum[5:0];
			end
			ct_1_en_1<=0;
			reg_a<=a;	// calculate PR
			reg_b<=b;
			reg_carry<=carry_in;
		end
		endcase
	end




endmodule